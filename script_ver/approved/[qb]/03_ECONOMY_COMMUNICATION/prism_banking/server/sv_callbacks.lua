-- Helper to get player name from identifier (used in ATM mode)
local function GetPlayerNameByIdentifier(identifier)
    if Config.Framework == "esx" then
        local result = exports.oxmysql:executeSync(
            "SELECT firstname, lastname FROM users WHERE identifier = ?",
            { identifier }
        )
        if result and #result > 0 then
            return result[1].firstname .. " " .. result[1].lastname
        else
            return "Unknown Player"
        end
    elseif Config.Framework == "qbx" or Config.Framework == "qb" then
        local result = exports.oxmysql:executeSync(
            "SELECT charinfo FROM players WHERE citizenid = ?",
            { identifier }
        )
        if result and #result > 0 then
            local charinfo = json.decode(result[1].charinfo)
            if charinfo and charinfo.firstname and charinfo.lastname then
                return charinfo.firstname .. " " .. charinfo.lastname
            else
                return "Unknown Player"
            end
        else
            return "Unknown Player"
        end
    end
end

local atmPinAttempts = {}
local ATM_PIN_MAX_ATTEMPTS = 5
local ATM_PIN_LOCKOUT_SECONDS = 120
local ATM_PIN_ATTEMPT_WINDOW_SECONDS = 300

local function GetAtmPinAttemptKey(source, accountNumber)
    return tostring(source) .. ":" .. tostring(accountNumber or "primary")
end

local function CanTryAtmPin(source, accountNumber)
    local key = GetAtmPinAttemptKey(source, accountNumber)
    local now = os.time()
    local state = atmPinAttempts[key]

    if not state then
        return true, nil
    end

    if state.lockedUntil and now < state.lockedUntil then
        local secondsLeft = state.lockedUntil - now
        return false, string.format("Too many PIN attempts. Try again in %s seconds.", secondsLeft)
    end

    if (now - state.windowStart) > ATM_PIN_ATTEMPT_WINDOW_SECONDS then
        atmPinAttempts[key] = nil
        return true, nil
    end

    return true, nil
end

local function RegisterAtmPinFailure(source, accountNumber)
    local key = GetAtmPinAttemptKey(source, accountNumber)
    local now = os.time()
    local state = atmPinAttempts[key]

    if not state or (now - state.windowStart) > ATM_PIN_ATTEMPT_WINDOW_SECONDS then
        state = {
            attempts = 0,
            windowStart = now,
            lockedUntil = 0
        }
    end

    state.attempts = state.attempts + 1
    if state.attempts >= ATM_PIN_MAX_ATTEMPTS then
        state.attempts = 0
        state.windowStart = now
        state.lockedUntil = now + ATM_PIN_LOCKOUT_SECONDS
    end

    atmPinAttempts[key] = state

    if state.lockedUntil and state.lockedUntil > now then
        local secondsLeft = state.lockedUntil - now
        return false, string.format("Too many PIN attempts. Try again in %s seconds.", secondsLeft)
    end

    return true, nil
end

local function ClearAtmPinFailures(source, accountNumber)
    local key = GetAtmPinAttemptKey(source, accountNumber)
    atmPinAttempts[key] = nil
end

AddEventHandler("playerDropped", function()
    local sourceId = tostring(source)
    local prefix = sourceId .. ":"

    for key, _ in pairs(atmPinAttempts) do
        if key:sub(1, #prefix) == prefix then
            atmPinAttempts[key] = nil
        end
    end
end)

-- Callback: get all accounts data for main UI
RegisterServerCallback("prism-banking:server:getAccounts", function(source, cb)
    local player = GetPlayer(source)
    SyncPrimaryAccountWithFramework(source)

    local accounts = GetBankAccounts(source)
    if not accounts or type(accounts) ~= "table" then
        accounts = {}
    end

    local cashBalance
    if Config.Framework == "esx" then
        cashBalance = player.getMoney()
    else
        cashBalance = player.PlayerData.money.cash
    end

    local playerName
    if Config.Framework == "esx" then
        playerName = player.getName()
    else
        playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end

    local profilePic = GetPlayerProfile(source)
    local history = GetTransactionHistory(source)

    local jobLabel
    if Config.Framework == "esx" then
        jobLabel = GetJobLabel(player.job.name)
    else
        jobLabel = GetJobLabel(player.PlayerData.job)
    end

    local creditScore = GetCreditScore(source)
    local settings = GetBankingSettings(source)

    -- Filter card settings based on eligibility
    local availableCardSettings = {}
    local cardOrder = {}
    for cardType, settings in pairs(Config.CardSettings) do
        if settings.isSociety then
            if IsPlayerEligibleForSociety(source, cardType) then
                availableCardSettings[cardType] = settings
                table.insert(cardOrder, cardType)
            end
        else
            availableCardSettings[cardType] = settings
            table.insert(cardOrder, cardType)
        end
    end

    cb({
        accounts = SanitizeAccountsForClient(accounts),
        cashBalance = cashBalance,
        playerName = playerName,
        playerProfile = profilePic,
        History = history,
        playerJobLabel = jobLabel,
        creditScore = creditScore,
        settings = settings,
        bankingLevels = Config.BankingLevels,
        pinChangeCost = Config.PinChangeCost,
        cardSettings = availableCardSettings,
        cardOrder = cardOrder,
        Locale = Locale.UI,
        reIssueCardCost = Config.ReIssueCardCost,
        IsCardEnabled = Config.CardItemConfig.cardAsItem,
        primaryColor = Config.PrimaryColor
    })
end)

-- Callback: check if server restart is imminent
RegisterServerCallback("prism-banking:server:isServerRestartImminent", function(source, cb)
    cb(IsRestartImminent())
end)

-- Callback: create a new bank account
RegisterServerCallback("prism-banking:server:createAccount", function(source, cb, pin, cardType, isNomineeAccount)
    local player = GetPlayer(source)
    local cardSettings = Config.CardSettings[cardType]
    local isSociety = cardSettings and cardSettings.isSociety or false

    if isSociety then
        -- Ensure player has a primary personal account before creating society account
        local accounts = GetBankAccounts(source)
        local hasPrimary = false
        for _, acc in ipairs(accounts) do
            if acc.primary and not acc.isSociety and not acc.isNomineeAccount then
                hasPrimary = true
                break
            end
        end
        if not hasPrimary then
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.need_primary_before_society)
            cb({ success = false, message = Locale.server.need_primary_before_society, main = nil })
            return
        end
    end

    if not isNomineeAccount then
        local settings = GetBankingSettings(source) or {}
        local level = settings.mcard_level or 1
        local maxAccounts = Config.BankingLevels.AccountsLevel[level].maxAccounts

        local accounts = GetBankAccounts(source)
        local ownedCount = 0
        for _, acc in ipairs(accounts) do
            if not acc.isSociety and not acc.isNomineeAccount then
                ownedCount = ownedCount + 1
            end
        end

        if ownedCount >= maxAccounts and not isSociety then
            DebugPrint("[BANKING] Account creation denied: Player has " .. ownedCount .. " accounts, max is " .. maxAccounts .. " at level " .. level)
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.max_account_alert)
            cb({ success = false, message = Locale.server.max_account_alert, main = nil })
            return
        end
    end

    local result = CreateBankAccount(pin, cardType, source, isNomineeAccount)

    if type(result) == "table" and result.success == false then
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, result.message)
        cb({ success = false, message = result.message, main = nil })
        return
    end

    local history = GetTransactionHistory(source)
    local accounts = GetBankAccounts(source)
    if not accounts or type(accounts) ~= "table" then accounts = {} end

    local cashBalance
    if Config.Framework == "esx" then
        cashBalance = player.getMoney()
    else
        cashBalance = player.PlayerData.money.cash
    end

    local playerName
    if Config.Framework == "esx" then
        playerName = player.getName()
    else
        playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end

    local profilePic = GetPlayerProfile(source)
    local jobLabel
    if Config.Framework == "esx" then
        jobLabel = GetJobLabel(player.job.name)
    else
        jobLabel = GetJobLabel(player.PlayerData.job)
    end
    local creditScore = GetCreditScore(source)
    local settings = GetBankingSettings(source)

    local availableCardSettings = {}
    local cardOrder = {}
    for cardType, settings in pairs(Config.CardSettings) do
        if settings.isSociety then
            if IsPlayerEligibleForSociety(source, cardType) then
                availableCardSettings[cardType] = settings
                table.insert(cardOrder, cardType)
            end
        else
            availableCardSettings[cardType] = settings
            table.insert(cardOrder, cardType)
        end
    end

    cb({
        success = result.success or result,
        main = {
            accounts = SanitizeAccountsForClient(accounts),
            cashBalance = cashBalance,
            playerName = playerName,
            playerProfile = profilePic,
            History = history,
            playerJobLabel = jobLabel,
            creditScore = creditScore,
            settings = settings,
            bankingLevels = Config.BankingLevels,
            pinChangeCost = Config.PinChangeCost,
            Locale = Locale.UI,
            reIssueCardCost = Config.ReIssueCardCost,
            IsCardEnabled = Config.CardItemConfig.cardAsItem,
            cardSettings = availableCardSettings,
            cardOrder = cardOrder,
            primaryColor = Config.PrimaryColor
        }
    })
end)

-- Callback: initialize a transaction (deposit/withdraw/transfer)
RegisterServerCallback("prism-banking:server:InitializeTransaction", function(source, cb, account, transactionType, amount, targetPlayerId)
    local success, data = InitializeTransaction(source, account, transactionType, amount, targetPlayerId)
    if data and data.accounts then
        data.accounts = SanitizeAccountsForClient(data.accounts)
    end
    cb({ success = success, data = data })
end)

-- Callback: toggle a banking setting
RegisterServerCallback("prism-banking:server:toggleSetting", function(source, cb, settingName)
    local success, data = ToggleBankingSetting(source, settingName)
    cb({ success = success, data = data })
end)

-- Callback: change account PIN
RegisterServerCallback("prism-banking:server:changePin", function(source, cb, accountNumber, oldPin, newPin)
    local success, message, data = ChangeAccountPin(source, accountNumber, oldPin, newPin)
    TriggerClientEvent("prism-banking:client:sendNotification", source, "Bank Activity", message)
    cb({ success = success, message = message, data = data })
end)

-- Callback: upgrade withdrawal level
RegisterServerCallback("prism-banking:server:upgradeWithdrawalLevel", function(source, cb)
    local success, message = UpgradeWithdrawalLevel(source)
    if success then
        local player = GetPlayer(source)
        local accounts = GetBankAccounts(source)
        local cashBalance
        if Config.Framework == "esx" then
            cashBalance = player.getMoney()
        else
            cashBalance = player.PlayerData.money.cash
        end
        local playerName
        if Config.Framework == "esx" then
            playerName = player.getName()
        else
            playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        end
        local profilePic = GetPlayerProfile(source)
        local history = GetTransactionHistory(source)
        local jobLabel
        if Config.Framework == "esx" then
            jobLabel = GetJobLabel(player.job.name)
        else
            jobLabel = GetJobLabel(player.PlayerData.job)
        end
        local creditScore = GetCreditScore(source)
        local settings = GetBankingSettings(source)

        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, message)
        cb({
            success = true,
            message = message,
            data = {
                accounts = SanitizeAccountsForClient(accounts),
                cashBalance = cashBalance,
                playerName = playerName,
                playerProfile = profilePic,
                History = history,
                playerJobLabel = jobLabel,
                creditScore = creditScore,
                settings = settings,
                bankingLevels = Config.BankingLevels,
                pinChangeCost = Config.PinChangeCost,
                Locale = Locale.UI,
                reIssueCardCost = Config.ReIssueCardCost,
                IsCardEnabled = Config.CardItemConfig.cardAsItem,
                cardSettings = Config.CardSettings,
                cardOrder = Config.CardOrder,
                primaryColor = Config.PrimaryColor
            }
        })
    else
        TriggerClientEvent("prism-banking:client:sendNotification", source, "Bank Activity", message)
        cb({ success = false, message = message })
    end
end)

-- Callback: check if player can create another account
RegisterServerCallback("prism-banking:server:allowedtoCreateAccount", function(source, cb)
    cb(CheckEligibilityToCreateAccount(source))
end)

-- Callback: upgrade account level (max accounts)
RegisterServerCallback("prism-banking:server:upgradeAccountLevel", function(source, cb)
    local success, message = UpgradeAccountLevel(source)
    if success then
        local player = GetPlayer(source)
        local accounts = GetBankAccounts(source)
        local cashBalance
        if Config.Framework == "esx" then
            cashBalance = player.getMoney()
        else
            cashBalance = player.PlayerData.money.cash
        end
        local playerName
        if Config.Framework == "esx" then
            playerName = player.getName()
        else
            playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        end
        local profilePic = GetPlayerProfile(source)
        local history = GetTransactionHistory(source)
        local jobLabel
        if Config.Framework == "esx" then
            jobLabel = GetJobLabel(player.job.name)
        else
            jobLabel = GetJobLabel(player.PlayerData.job)
        end
        local creditScore = GetCreditScore(source)
        local settings = GetBankingSettings(source)

        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, message)
        cb({
            success = true,
            message = message,
            data = {
                accounts = SanitizeAccountsForClient(accounts),
                cashBalance = cashBalance,
                playerName = playerName,
                playerProfile = profilePic,
                History = history,
                playerJobLabel = jobLabel,
                creditScore = creditScore,
                settings = settings,
                bankingLevels = Config.BankingLevels,
                pinChangeCost = Config.PinChangeCost,
                Locale = Locale.UI,
                reIssueCardCost = Config.ReIssueCardCost,
                IsCardEnabled = Config.CardItemConfig.cardAsItem,
                cardSettings = Config.CardSettings,
                cardOrder = Config.CardOrder,
                primaryColor = Config.PrimaryColor
            }
        })
    else
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, message)
        cb({ success = false, message = message })
    end
end)

-- Callback: get accounts for ATM mode (with optional specific account number)
RegisterServerCallback("prism-banking:server:getAtmAccounts", function(source, cb, requestedAccounts)
    local player = GetPlayer(source)
    if not player then
        cb({ success = false, accounts = {}, main = {} })
        return
    end

    requestedAccounts = (type(requestedAccounts) == "table") and requestedAccounts or {}

    local accounts = {}
    local accessibleAccounts = {}

    if #requestedAccounts == 1 then
        local requestedAccountNumber = tonumber(requestedAccounts[1]) or requestedAccounts[1]
        if not requestedAccountNumber then
            cb({ success = false, accounts = {}, main = {} })
            return
        end

        local hasStandardAccess = HasAccountAccess(source, requestedAccountNumber, false)
        local hasVerifiedCardAccess = IsVerifiedAtmCardAccess(source, requestedAccountNumber)
        if not hasStandardAccess and not hasVerifiedCardAccess then
            cb({ success = false, accounts = {}, main = {} })
            return
        end

        local account = GetBankAccountByAccountNumber(requestedAccountNumber)
        if not account or account.isSociety then
            cb({ success = false, accounts = {}, main = {} })
            return
        end

        local playerAccounts = GetBankAccounts(source)
        local contextualAccount = nil
        for _, acc in ipairs(playerAccounts) do
            if tostring(acc.accountNumber) == tostring(requestedAccountNumber) then
                contextualAccount = acc
                break
            end
        end

        if contextualAccount then
            account.primary = contextualAccount.primary == true
            account.isNomineeAccount = contextualAccount.isNomineeAccount == true
            account.identifier = contextualAccount.identifier or account.identifier
        else
            account.primary = false
            account.isNomineeAccount = true
        end

        table.insert(accessibleAccounts, account)
    else
        accounts = GetBankAccounts(source)
        for _, acc in ipairs(accounts) do
            if not acc.isSociety then
                table.insert(accessibleAccounts, acc)
            end
        end
    end

    if #accessibleAccounts == 0 then
        cb({ success = false, accounts = {}, main = {} })
        return
    end

    SyncPrimaryAccountWithFramework(source)

    local cashBalance
    if Config.Framework == "esx" then
        cashBalance = player.getMoney()
    else
        cashBalance = player.PlayerData.money.cash
    end

    local playerName
    if #requestedAccounts == 1 and accessibleAccounts[1] and accessibleAccounts[1].identifier then
        -- ATM mode: show name of account owner
        playerName = GetPlayerNameByIdentifier(accessibleAccounts[1].identifier)
    else
        if Config.Framework == "esx" then
            playerName = player.getName()
        else
            playerName = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        end
    end

    local profilePic = GetPlayerProfile(source)
    local history = GetTransactionHistory(source)

    local jobLabel
    if Config.Framework == "esx" then
        jobLabel = GetJobLabel(player.job.name)
    else
        jobLabel = GetJobLabel(player.PlayerData.job)
    end

    local creditScore = GetCreditScore(source)
    local settings = GetBankingSettings(source)
    local safeAccounts = SanitizeAccountsForClient(accessibleAccounts)

    cb({
        success = true,
        accounts = safeAccounts,
        main = {
            accounts = safeAccounts,
            cashBalance = cashBalance,
            playerName = playerName,
            playerProfile = profilePic,
            History = history,
            playerJobLabel = jobLabel,
            creditScore = creditScore,
            settings = settings,
            bankingLevels = Config.BankingLevels,
            pinChangeCost = Config.PinChangeCost,
            cardSettings = Config.CardSettings,
            cardOrder = Config.CardOrder,
            Locale = Locale.UI,
            reIssueCardCost = Config.ReIssueCardCost,
            IsCardEnabled = Config.CardItemConfig.cardAsItem,
            primaryColor = Config.PrimaryColor
        }
    })
end)

-- Callback: reissue a card
RegisterServerCallback("prism-banking:server:reIssueCard", function(source, cb, accountNumber)
    cb(ReIssueCard(source, accountNumber))
end)

-- Callback: verify ATM PIN (for card access)
RegisterServerCallback("prism-banking:server:verifyAtmPin", function(source, cb, enteredPin, accountNumber)
    local normalizedPin = tostring(enteredPin or "")
    accountNumber = tonumber(accountNumber) or accountNumber

    local canTry, blockMessage = CanTryAtmPin(source, accountNumber)
    if not canTry then
        cb({ success = false, message = blockMessage })
        return
    end

    local player = GetPlayer(source)
    if not player then
        cb({ success = false, message = Locale.server.player_not_found })
        return
    end

    if #normalizedPin ~= 5 or not tonumber(normalizedPin) then
        local _, lockMessage = RegisterAtmPinFailure(source, accountNumber)
        cb({ success = false, message = lockMessage or Locale.server.incorrect_pin })
        return
    end

    if Config.CardItemConfig.cardStealingEnabled == false and Config.CardItemConfig.cardAsItem then
        -- Check if player owns the account (prevent stolen card usage)
        local accounts = GetBankAccounts(source)
        local owns = false
        for _, acc in ipairs(accounts) do
            if tostring(acc.accountNumber) == tostring(accountNumber) then
                owns = true
                break
            end
        end
        if not owns then
            cb({ success = false, message = Locale.server.cannot_use_stolen_card })
            return
        end
    end

    local primaryAccount = nil

    SyncPrimaryAccountWithFramework(source)

    local accounts = GetBankAccounts(source)

    if accountNumber then
        local hasStandardAccess = HasAccountAccess(source, accountNumber, false)
        local cardStealFlowEnabled = Config.CardItemConfig.cardStealingEnabled and Config.CardItemConfig.cardAsItem
        if not hasStandardAccess and not cardStealFlowEnabled then
            cb({ success = false, message = Locale.server.you_dont_own })
            return
        end

        primaryAccount = GetBankAccountByAccountNumber(accountNumber)
    else
        for _, acc in ipairs(accounts) do
            if acc.primary then
                primaryAccount = GetBankAccountByAccountNumber(acc.accountNumber)
                break
            end
        end
    end

    if not primaryAccount then
        cb({ success = false, message = Locale.server.no_valid_account })
        return
    end

    if primaryAccount.isSociety then
        cb({ success = false, message = Locale.server.no_valid_account })
        return
    end

    if tostring(primaryAccount.pin) == normalizedPin then
        ClearAtmPinFailures(source, accountNumber)
        if accountNumber then
            SetVerifiedAtmCardAccess(source, accountNumber, 120)
        end
        cb({ success = true, message = Locale.server.pin_verified, accountCount = #accounts })
    else
        local _, lockMessage = RegisterAtmPinFailure(source, accountNumber)
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.atm_error, Locale.server.incorrect_pin)
        cb({ success = false, message = lockMessage or Locale.server.incorrect_pin })
    end
end)