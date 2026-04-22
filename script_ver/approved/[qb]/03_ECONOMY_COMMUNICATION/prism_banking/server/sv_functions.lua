-- Helper: generate a random 10-digit account number (1000000000 to 9999999999)
function GenerateRandomAccountNumber()
    return math.random(1000000000, 9999999999)
end

-- Helper: check if an account number already exists (async callback)
function CheckAccountNumberExists(accountNumber, callback)
    exports.oxmysql:execute(
        "SELECT accno FROM prism_banking_accounts WHERE accno = ?",
        { accountNumber },
        function(result)
            callback(result and #result > 0)
        end
    )
end

-- Generate a unique account number with retry logic (callback returns unique number)
function GenerateUniqueAccountNumber(callback)
    local maxAttempts = 100
    local attempt = 0

    local function tryGenerate()
        if attempt >= maxAttempts then
            callback(nil)
            return
        end

        local newNumber = GenerateRandomAccountNumber()
        attempt = attempt + 1

        CheckAccountNumberExists(newNumber, function(exists)
            if not exists then
                callback(newNumber)
            else
                tryGenerate()
            end
        end)
    end

    tryGenerate()
end

local verifiedAtmCardAccess = {}

function SetVerifiedAtmCardAccess(source, accountNumber, ttlSeconds)
    if type(source) ~= "number" or not accountNumber then
        return
    end

    verifiedAtmCardAccess[source] = {
        accountNumber = tostring(accountNumber),
        expiresAt = os.time() + (ttlSeconds or 90)
    }
end

function IsVerifiedAtmCardAccess(source, accountNumber)
    if type(source) ~= "number" or not accountNumber then
        return false
    end

    local session = verifiedAtmCardAccess[source]
    if not session then
        return false
    end

    if os.time() >= session.expiresAt then
        verifiedAtmCardAccess[source] = nil
        return false
    end

    return session.accountNumber == tostring(accountNumber)
end

function ClearVerifiedAtmCardAccess(source)
    if type(source) ~= "number" then
        return
    end

    verifiedAtmCardAccess[source] = nil
end

AddEventHandler("playerDropped", function()
    local sourceId = tonumber(source)
    if sourceId then
        ClearVerifiedAtmCardAccess(sourceId)
    end
end)

function SanitizeAccountsForClient(accounts)
    local sanitized = {}

    if type(accounts) ~= "table" then
        return sanitized
    end

    for _, account in ipairs(accounts) do
        if type(account) == "table" then
            local cleanAccount = {}
            for key, value in pairs(account) do
                if key ~= "pin" then
                    cleanAccount[key] = value
                end
            end
            table.insert(sanitized, cleanAccount)
        end
    end

    return sanitized
end

-- Get player object by server ID
function GetPlayer(source)
    if Config.Framework == "qb" or Config.Framework == "qbx" then
        return QBCore.Functions.GetPlayer(source)
    elseif Config.Framework == "esx" then
        return ESX.GetPlayerFromId(source)
    end
end

-- Get player's job name and grade level
function GetPlayerJobInfo(source)
    local player = GetPlayer(source)
    if not player then return nil, nil end

    if Config.Framework == "esx" then
        return player.job.name, player.job.grade
    else
        return player.PlayerData.job.name, player.PlayerData.job.grade.level
    end
end

-- Check if player is eligible for a society card type
function IsPlayerEligibleForSociety(source, cardType)
    local cardSettings = Config.CardSettings[cardType]
    if not cardSettings or not cardSettings.isSociety then
        return false
    end

    local jobName, jobGrade = GetPlayerJobInfo(source)
    if not jobName or not jobGrade then
        return false
    end

    local requiredGrade = cardSettings.jobGrades and cardSettings.jobGrades[jobName]
    if not requiredGrade then
        return false
    end

    return jobGrade >= requiredGrade
end

-- Check if a society account already exists for a given job and card type
function DoesSocietyAccountExist(jobName, cardType)
    local promise = promise.new()
    exports.oxmysql:execute(
        "SELECT accno FROM prism_banking_accounts WHERE is_society = 1 AND society_job = ? AND type = ?",
        { jobName, cardType },
        function(result)
            promise:resolve(result and #result > 0)
        end
    )
    return Citizen.Await(promise)
end

-- Get all society accounts the player has access to (based on job)
function GetSocietyAccountsForPlayer(source)
    local jobName, jobGrade = GetPlayerJobInfo(source)
    if not jobName or not jobGrade then
        return {}
    end

    local accounts = {}

    for cardType, settings in pairs(Config.CardSettings) do
        if settings.isSociety then
            local requiredGrade = settings.jobGrades and settings.jobGrades[jobName]
            if requiredGrade and jobGrade >= requiredGrade then
                local result = exports.oxmysql:executeSync(
                    "SELECT * FROM prism_banking_accounts WHERE is_society = 1 AND society_job = ? AND type = ?",
                    { jobName, cardType }
                )
                if result then
                    for _, row in ipairs(result) do
                        local balance = row.balance or 0
                        if Config.SocietySync and Config.SocietySync.enabled and Config.SocietySync.twoWaySync then
                            local frameworkBalance = SyncFrameworkToBankingSociety(jobName)
                            if frameworkBalance then
                                balance = frameworkBalance
                                exports.oxmysql:execute(
                                    "UPDATE prism_banking_accounts SET balance = ? WHERE accno = ?",
                                    { balance, row.accno }
                                )
                            end
                        end
                        accounts[#accounts + 1] = {
                            pin = row.pin,
                            type = row.type,
                            balance = balance,
                            accountNumber = row.accno,
                            identifier = row.identifier,
                            primary = false,
                            isSociety = true,
                            societyJob = row.society_job
                        }
                    end
                end
            end
        end
    end

    return accounts
end

-- Get all bank accounts accessible by the player (personal + nominee + society)
function GetBankAccounts(source)
    local player = GetPlayer(source)
    local promise = promise.new()

    if not player then
        promise:resolve({})
        return Citizen.Await(promise)
    end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    -- Personal accounts
    local personalResult = exports.oxmysql:executeSync(
        "SELECT * FROM prism_banking_accounts WHERE identifier = @identifier AND (is_society = 0 OR is_society IS NULL)",
        { ["@identifier"] = identifier }
    )

    local accounts = {}
    if personalResult then
        for _, row in ipairs(personalResult) do
            accounts[#accounts + 1] = {
                pin = row.pin,
                type = row.type,
                balance = row.balance or 0,
                accountNumber = row.accno,
                identifier = identifier,
                primary = row.primary == 1,
                isSociety = false,
                isNomineeAccount = false
            }
        end
    end

    -- Nominee accounts
    local nomineeResult = exports.oxmysql:executeSync([[
        SELECT a.pin, a.type, a.balance, a.accno, a.identifier, a.primary
        FROM prism_banking_nominees n
        INNER JOIN prism_banking_accounts a ON n.account_number = a.accno
        WHERE n.nominee_identifier = ? AND a.is_society = 0
    ]], { identifier })

    if nomineeResult then
        for _, row in ipairs(nomineeResult) do
            local ownerName = "Unknown Owner"
            if Config.Framework == "esx" then
                local ownerInfo = exports.oxmysql:executeSync(
                    "SELECT firstname, lastname FROM users WHERE identifier = ? LIMIT 1",
                    { row.identifier }
                )
                if ownerInfo and ownerInfo[1] then
                    ownerName = (ownerInfo[1].firstname or "Unknown") .. " " .. (ownerInfo[1].lastname or "Owner")
                end
            else
                local ownerInfo = exports.oxmysql:executeSync(
                    "SELECT charinfo FROM players WHERE citizenid = ? LIMIT 1",
                    { row.identifier }
                )
                if ownerInfo and ownerInfo[1] and ownerInfo[1].charinfo then
                    local charinfo = json.decode(ownerInfo[1].charinfo)
                    if charinfo and charinfo.firstname and charinfo.lastname then
                        ownerName = charinfo.firstname .. " " .. charinfo.lastname
                    end
                end
            end

            accounts[#accounts + 1] = {
                pin = row.pin,
                type = row.type,
                balance = row.balance or 0,
                accountNumber = row.accno,
                identifier = row.identifier,
                primary = false,
                isSociety = false,
                isNomineeAccount = true,
                ownerName = ownerName
            }
        end
    end

    -- Society accounts
    local societyAccounts = GetSocietyAccountsForPlayer(source)
    if societyAccounts then
        for _, acc in ipairs(societyAccounts) do
            if acc.isSociety and acc.societyJob then
                local jobLabel = acc.societyJob
                if Config.Framework == "esx" then
                    local jobInfo = exports.oxmysql:executeSync(
                        "SELECT label FROM jobs WHERE name = ? LIMIT 1",
                        { acc.societyJob }
                    )
                    if jobInfo and jobInfo[1] and jobInfo[1].label then
                        jobLabel = jobInfo[1].label
                    end
                elseif Config.Framework == "qb" or Config.Framework == "qbx" then
                    local qbCore = exports["qb-core"]:GetCoreObject()
                    if qbCore and qbCore.Shared and qbCore.Shared.Jobs and qbCore.Shared.Jobs[acc.societyJob] then
                        jobLabel = qbCore.Shared.Jobs[acc.societyJob].label
                    end
                end
                acc.societyJobLabel = jobLabel
            end
            accounts[#accounts + 1] = acc
        end
    end

    promise:resolve(accounts)
    return Citizen.Await(promise)
end
exports("GetBankAccounts", GetBankAccounts)

-- Get a single bank account by its number
function GetBankAccountByAccountNumber(accountNumber)
    local promise = promise.new()
    exports.oxmysql:execute(
        "SELECT * FROM prism_banking_accounts WHERE accno = ?",
        { accountNumber },
        function(result)
            if result and #result > 0 then
                local row = result[1]
                local account = {
                    pin = row.pin,
                    type = row.type,
                    balance = row.balance or 0,
                    accountNumber = row.accno,
                    identifier = row.identifier,
                    primary = row.primary == 1,
                    isSociety = row.is_society == 1,
                    isNomineeAccount = false
                }
                if account.isSociety and row.society_job then
                    local jobLabel = row.society_job
                    if Config.Framework == "esx" then
                        local jobInfo = exports.oxmysql:executeSync(
                            "SELECT label FROM jobs WHERE name = ? LIMIT 1",
                            { row.society_job }
                        )
                        if jobInfo and jobInfo[1] and jobInfo[1].label then
                            jobLabel = jobInfo[1].label
                        end
                    elseif Config.Framework == "qb" or Config.Framework == "qbx" then
                        local qbCore = exports["qb-core"]:GetCoreObject()
                        if qbCore and qbCore.Shared and qbCore.Shared.Jobs and qbCore.Shared.Jobs[row.society_job] then
                            jobLabel = qbCore.Shared.Jobs[row.society_job].label
                        end
                    end
                    account.societyJob = row.society_job
                    account.societyJobLabel = jobLabel
                end
                promise:resolve(account)
            else
                promise:resolve(nil)
            end
        end
    )
    return Citizen.Await(promise)
end

-- Get player's transaction history (last 7 days)
function GetTransactionHistory(source)
    local player = GetPlayer(source)
    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/data.json") or "{}")
    if data[identifier] and data[identifier].transactions then
        local oneWeekAgo = os.time() - 604800
        local recent = {}
        for _, tx in ipairs(data[identifier].transactions) do
            if tx.timestamp and tx.timestamp >= oneWeekAgo then
                table.insert(recent, tx)
            end
        end
        return recent
    end
    return {}
end
exports("GetTransactionHistory", GetTransactionHistory)

-- Reissue a card (generate new account number, charge fee, update inventory)
function ReIssueCard(source, accountNumber)
    local player = GetPlayer(source)
    if not player then return end

    -- Only owners can reissue (not nominees)
    if not HasAccountAccess(source, accountNumber, true) then
        DebugPrint("[BANKING] Card reissue denied for player " .. source .. " - not account owner (possibly nominee)")
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, "Only account owners can reissue cards. Nominees cannot reissue cards.")
        return
    end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local accounts = exports.oxmysql:executeSync(
        "SELECT * FROM prism_banking_accounts WHERE accno = ? AND identifier = ? AND (is_society = 0 OR is_society IS NULL)",
        { accountNumber, identifier }
    )

    if not accounts or #accounts == 0 then
        DebugPrint("[BANKING] ReIssue denied - player " .. source .. " doesn't own account " .. accountNumber)
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, "You don't own this account")
        return
    end

    local cost = Config.ReIssueCardCost
    if cost > GetPlayerMoney(source) then
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.insufficient_fund)
        return
    end

    RemovePlayerMoney(source, "cash", cost)

    GenerateUniqueAccountNumber(function(newAccno)
        exports.oxmysql:execute(
            "UPDATE prism_banking_accounts SET accno = @newAccno WHERE accno = @accno",
            { ["@newAccno"] = newAccno, ["@accno"] = accountNumber }
        )
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.card_reissued)
        AddItemToInventory(source, newAccno)
        LogCardReissued(source, accountNumber, newAccno, cost)
    end)
end

-- Create a new bank account
function CreateBankAccount(pin, cardType, source, isNomineeAccount)
    local player = GetPlayer(source)
    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local bankBalance = (Config.Framework == "esx") and player.getAccount("bank").money or player.PlayerData.money.bank

    local promise = promise.new()
    local cardSettings = Config.CardSettings[cardType]
    local isSociety = cardSettings and cardSettings.isSociety or false
    local societyJob = nil

    if isSociety then
        if not IsPlayerEligibleForSociety(source, cardType) then
            promise:resolve({ success = false, message = "You are not eligible to create this society account" })
            return Citizen.Await(promise)
        end
        local jobName = GetPlayerJobInfo(source)
        societyJob = jobName
        if DoesSocietyAccountExist(jobName, cardType) then
            promise:resolve({ success = false, message = "A society account already exists for your job" })
            return Citizen.Await(promise)
        end
    end

    local isFirstPersonalAccount = false
    if not isSociety then
        local existing = exports.oxmysql:executeSync([[
            SELECT accno FROM prism_banking_accounts
            WHERE identifier = ? AND (is_society = 0 OR is_society IS NULL)
        ]], { identifier })
        if existing and #existing == 0 then
            isFirstPersonalAccount = true
            DebugPrint("[BANKING] Creating first owned personal account for player " .. source .. " - setting as primary")
        end
    end

    GenerateUniqueAccountNumber(function(newAccno)
        local query = "INSERT INTO prism_banking_accounts (identifier, pin, type, accno, balance, `primary`, is_society, society_job) VALUES (@identifier, @pin, @type, @accno, @balance, @primary, @is_society, @society_job)"
        local params = {
            ["@identifier"] = identifier,
            ["@pin"] = pin,
            ["@type"] = cardType,
            ["@accno"] = newAccno,
            ["@balance"] = (isFirstPersonalAccount and bankBalance) or 0,
            ["@primary"] = isFirstPersonalAccount and 1 or 0,
            ["@is_society"] = isSociety and 1 or 0,
            ["@society_job"] = societyJob
        }

        exports.oxmysql:execute(query, params, function()
            -- Update transaction history if initial deposit
            local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/data.json") or "{}")
            if not data[identifier] then
                data[identifier] = { transactions = {} }
            end
            if isFirstPersonalAccount and bankBalance > 0 then
                data[identifier].transactions[#data[identifier].transactions + 1] = {
                    Spendtype = "cash",
                    amount = bankBalance,
                    timestamp = os.time(),
                    transactionType = "deposit",
                    name = "Account Created",
                    description = "Initial deposit when creating bank account"
                }
            end
            SaveResourceFile(GetCurrentResourceName(), "data/data.json", json.encode(data, { indent = true }), -1)

            if Config.CardItemConfig.cardAsItem and not isSociety then
                AddItemToInventory(source, newAccno)
            end

            if isSociety and Config.SocietySync and Config.SocietySync.enabled then
                SetFrameworkSocietyBalance(societyJob, 0)
                DebugPrint("[SOCIETY SYNC] Created framework society account for: " .. societyJob)
            end

            local initialDeposit = (isNomineeAccount or isSociety) and 0 or bankBalance
            LogAccountCreated(source, newAccno, cardType, initialDeposit)

            Wait(50)
            promise:resolve({ success = true, accountNumber = newAccno })
        end)
    end)

    return Citizen.Await(promise)
end

-- Get player's credit score
function GetCreditScore(source)
    local player = GetPlayer(source)
    if not player then return Config.DefaultCreditScore end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local result = exports.oxmysql:executeSync(
        "SELECT creditscore FROM prism_banking_settings WHERE identifier = ?",
        { identifier }
    )
    if result and result[1] and result[1].creditscore then
        return result[1].creditscore
    else
        exports.oxmysql:execute(
            "INSERT INTO prism_banking_settings (identifier, creditscore, allow_transfer, is_optimized, wit_level, mcard_level) VALUES (?, ?, ?, ?, ?, ?)",
            { identifier, Config.DefaultCreditScore, 1, 1, 1, 1 }
        )
        return Config.DefaultCreditScore
    end
end
exports("GetCreditScore", GetCreditScore)

-- Update player's credit score in DB
function UpdateCreditScore(source, newScore)
    local player = GetPlayer(source)
    if not player then return false end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local exists = exports.oxmysql:executeSync(
        "SELECT identifier FROM prism_banking_settings WHERE identifier = ?",
        { identifier }
    )
    if exists and exists[1] then
        exports.oxmysql:execute(
            "UPDATE prism_banking_settings SET creditscore = ? WHERE identifier = ?",
            { newScore, identifier }
        )
    else
        exports.oxmysql:execute(
            "INSERT INTO prism_banking_settings (identifier, creditscore, allow_transfer, is_optimized, wit_level, mcard_level) VALUES (?, ?, ?, ?, ?, ?)",
            { identifier, newScore, 1, 1, 1, 1 }
        )
    end
    return true
end

-- Calculate new credit score based on transaction history and balances
function CalculateCreditScore(source)
    local player = GetPlayer(source)
    if not player then return Config.DefaultCreditScore end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid
    local history = GetTransactionHistory(source)
    local currentScore = GetCreditScore(source)

    local txCount = #history
    local accounts = GetBankAccounts(source)
    local totalBalance = 0
    for _, acc in ipairs(accounts) do
        if not acc.isSociety then
            totalBalance = totalBalance + acc.balance
        end
    end

    local wealthBonus = math.min(math.floor(totalBalance / 25000), 50)

    local deposits = 0
    local withdrawals = 0
    local startIdx = math.max(1, txCount - 9)
    for i = startIdx, txCount do
        local tx = history[i]
        if tx then
            if tx.transactionType == "deposit" then
                deposits = deposits + tx.amount
            elseif tx.transactionType == "withdraw" then
                withdrawals = withdrawals + tx.amount
            end
        end
    end

    local scoreChange = 0
    if totalBalance < 10000 then
        scoreChange = scoreChange - 3
    end

    if deposits > withdrawals then
        local diff = deposits - withdrawals
        scoreChange = scoreChange + math.min(10, math.floor(diff / 50000))
    elseif deposits < withdrawals then
        local diff = withdrawals - deposits
        scoreChange = scoreChange - math.min(10, math.floor(diff / 50000))
    end

    if txCount > 0 then
        scoreChange = scoreChange + math.min(2, math.floor(txCount / 15))
    end

    scoreChange = scoreChange + math.floor(wealthBonus * 0.05)
    scoreChange = math.max(-15, math.min(15, scoreChange))

    local newScore = currentScore + scoreChange
    newScore = math.max(300, math.min(850, newScore))
    UpdateCreditScore(source, newScore)
    return newScore
end

-- Async version of GetCreditScore (callback)
function GetCreditScoreAsync(source, callback)
    local player = GetPlayer(source)
    if not player then
        callback(Config.DefaultCreditScore)
        return
    end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    exports.oxmysql:execute(
        "SELECT creditscore FROM prism_banking_settings WHERE identifier = ?",
        { identifier },
        function(result)
            if result and result[1] and result[1].creditscore then
                callback(result[1].creditscore)
            else
                exports.oxmysql:execute(
                    "INSERT INTO prism_banking_settings (identifier, creditscore, allow_transfer, is_optimized, wit_level, mcard_level) VALUES (?, ?, ?, ?, ?, ?)",
                    { identifier, Config.DefaultCreditScore, 1, 1, 1, 1 },
                    function()
                        callback(Config.DefaultCreditScore)
                    end
                )
            end
        end
    )
end

-- Get full banking settings for a player
function GetBankingSettings(source)
    local player = GetPlayer(source)
    if not player then return nil end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local result = exports.oxmysql:executeSync(
        "SELECT * FROM prism_banking_settings WHERE identifier = ?",
        { identifier }
    )
    if result and result[1] then
        return result[1]
    else
        exports.oxmysql:execute(
            "INSERT INTO prism_banking_settings (identifier, creditscore, allow_transfer, is_optimized, wit_level, mcard_level) VALUES (?, ?, ?, ?, ?, ?)",
            { identifier, Config.DefaultCreditScore, 1, 1, 1, 1 }
        )
        return {
            identifier = identifier,
            creditscore = Config.DefaultCreditScore,
            allow_transfer = 1,
            is_optimized = 1,
            wit_level = 1,
            mcard_level = 1
        }
    end
end
exports("GetBankingSettings", GetBankingSettings)

-- Get banking settings by identifier (for offline players)
function GetBankingSettingsByIdentifier(identifier)
    local result = exports.oxmysql:executeSync(
        "SELECT * FROM prism_banking_settings WHERE identifier = ?",
        { identifier }
    )
    if result and result[1] then
        return result[1]
    else
        exports.oxmysql:execute(
            "INSERT INTO prism_banking_settings (identifier, creditscore, allow_transfer, is_optimized, wit_level, mcard_level) VALUES (?, ?, ?, ?, ?, ?)",
            { identifier, Config.DefaultCreditScore, 1, 1, 1, 1 }
        )
        return {
            identifier = identifier,
            creditscore = Config.DefaultCreditScore,
            allow_transfer = 1,
            is_optimized = 1,
            wit_level = 1,
            mcard_level = 1
        }
    end
end

-- Get player's withdrawal level
function GetPlayerWithdrawalLevel(source)
    local settings = GetBankingSettings(source)
    return settings and settings.wit_level or 1
end
exports("GetPlayerWithdrawalLevel", GetPlayerWithdrawalLevel)

-- Get player's account level (max accounts level)
function GetPlayerAccountLevel(source)
    local settings = GetBankingSettings(source)
    return settings and settings.mcard_level or 1
end
exports("GetPlayerAccountLevel", GetPlayerAccountLevel)

-- Get max withdrawal amount for player's level
function GetMaxWithdrawal(source)
    local level = GetPlayerWithdrawalLevel(source)
    return Config.BankingLevels.WithDrawLevel[level].maxWithdraw
end

-- Get max number of personal accounts allowed for player's level
function GetMaxAccounts(source)
    local level = GetPlayerAccountLevel(source)
    return Config.BankingLevels.AccountsLevel[level].maxAccounts
end

-- Upgrade withdrawal level (cost, update DB)
function UpgradeWithdrawalLevel(source)
    local player = GetPlayer(source)
    if not player then return false end

    local currentLevel = GetPlayerWithdrawalLevel(source)
    local nextLevel = currentLevel + 1
    local levelData = Config.BankingLevels.WithDrawLevel[nextLevel]
    if not levelData then
        return false, Locale.server.already_maxLevel
    end

    local cost = levelData.price
    if cost > GetPlayerMoney(source) then
        return false, Locale.server.insuff_fund
    end

    RemovePlayerMoney(source, "cash", cost)

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid
    exports.oxmysql:execute(
        "UPDATE prism_banking_settings SET wit_level = ? WHERE identifier = ?",
        { nextLevel, identifier }
    )

    LogUpgradePurchased(source, "Withdrawal Level", nextLevel, cost)
    return true, string.format(Locale.server.withdrawal_lvl_upgraded, nextLevel)
end

-- Upgrade account level (max accounts)
function UpgradeAccountLevel(source)
    local player = GetPlayer(source)
    if not player then return false end

    local currentLevel = GetPlayerAccountLevel(source)
    local nextLevel = currentLevel + 1
    local levelData = Config.BankingLevels.AccountsLevel[nextLevel]
    if not levelData then
        return false, Locale.server.already_maxAccount
    end

    local cost = levelData.price
    if cost > GetPlayerMoney(source) then
        return false, Locale.server.insuff_fund
    end

    RemovePlayerMoney(source, "cash", cost)

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid
    exports.oxmysql:execute(
        "UPDATE prism_banking_settings SET mcard_level = ? WHERE identifier = ?",
        { nextLevel, identifier }
    )

    LogUpgradePurchased(source, "Account Level", nextLevel, cost)
    return true, string.format(Locale.server.account_lvl_upgraded, nextLevel)
end

-- Add money to a bank account (DB update, sync with framework if primary or society)
function AddMoneyBankToAccount(source, account, amount)
    local promise = promise.new()
    local player = GetPlayer(source)
    if not player then
        promise:resolve(false)
        return Citizen.Await(promise)
    end

    if account.primary then
        AddPlayerMoney(source, "bank", amount)
    end

    exports.oxmysql:execute(
        "UPDATE prism_banking_accounts SET balance = balance + ? WHERE accno = ?",
        { amount, account.accountNumber },
        function(result)
            if result.affectedRows > 0 then
                if account.isSociety and account.societyJob and Config.SocietySync and Config.SocietySync.enabled then
                    AddFrameworkSocietyMoney(account.societyJob, amount)
                end
                promise:resolve(true)
            else
                promise:resolve(false)
            end
        end
    )
    return Citizen.Await(promise)
end

-- Remove money from a bank account (DB update, sync with framework if primary or society)
function RemoveMoneyBankFromAccount(source, account, amount)
    local promise = promise.new()
    local player = GetPlayer(source)
    if not player then
        DebugPrint("[BANKING] RemoveMoneyBankFromAccount failed: Player not found")
        promise:resolve(false)
        return Citizen.Await(promise)
    end

    exports.oxmysql:execute(
        "UPDATE prism_banking_accounts SET balance = balance - ? WHERE accno = ? AND balance >= ?",
        { amount, account.accountNumber, amount },
        function(result)
            if result.affectedRows > 0 then
                DebugPrint("[BANKING] Successfully removed $" .. amount .. " from account " .. account.accountNumber)

                if account.primary then
                    RemovePlayerMoney(source, "bank", amount)
                    DebugPrint("[BANKING] Successfully removed $" .. amount .. " from framework bank")
                end

                if account.isSociety and account.societyJob and Config.SocietySync and Config.SocietySync.enabled then
                    RemoveFrameworkSocietyMoney(account.societyJob, amount)
                end

                promise:resolve(true)
            else
                DebugPrint("[BANKING] Failed to remove money from account " .. account.accountNumber .. " - insufficient balance or account not found")
                promise:resolve(false)
            end
        end
    )
    return Citizen.Await(promise)
end

-- Add a transaction to the player's history (JSON file)
function AddTransactionToHistory(source, transactionType, amount, spendType, name, description, nomineeAccountInfo)
    local player = GetPlayer(source)
    if not player then return false end

    local identifier
    if nomineeAccountInfo and nomineeAccountInfo.isNomineeAccount and nomineeAccountInfo.identifier then
        identifier = nomineeAccountInfo.identifier
        DebugPrint("[TRANSACTION HISTORY] Adding transaction to owner's history (nominee transaction)")
    else
        identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid
    end

    local data = json.decode(LoadResourceFile(GetCurrentResourceName(), "data/data.json") or "{}")
    if not data[identifier] then
        data[identifier] = { transactions = {} }
    end

    if not name then
        if transactionType == "deposit" then name = "Bank Deposit"
        elseif transactionType == "withdraw" then name = "Bank Withdrawal"
        elseif transactionType == "transfer" then name = "Bank Transfer"
        else name = "Transaction" end
    end

    if not description then
        if transactionType == "deposit" then
            description = (spendType == "cash") and "Cash deposited to bank account" or ("Deposit from " .. spendType)
        elseif transactionType == "withdraw" then description = "Cash withdrawn from bank account"
        elseif transactionType == "transfer" then description = "Money transferred to another account"
        else description = "Banking transaction" end
    end

    table.insert(data[identifier].transactions, {
        Spendtype = spendType,
        amount = amount,
        timestamp = os.time(),
        transactionType = transactionType,
        name = name,
        description = description
    })

    SaveResourceFile(GetCurrentResourceName(), "data/data.json", json.encode(data, { indent = true }), -1)
    return true
end

-- Sync primary account balance with framework bank money
function SyncPrimaryAccountWithFramework(source)
    local player = GetPlayer(source)
    if not player then return false end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid
    local frameworkBank = (Config.Framework == "esx") and player.getAccount("bank").money or player.PlayerData.money.bank

    local primaryAccount = exports.oxmysql:executeSync(
        "SELECT * FROM prism_banking_accounts WHERE identifier = ? AND `primary` = 1",
        { identifier }
    )
    if primaryAccount and primaryAccount[1] and primaryAccount[1].balance ~= frameworkBank then
        exports.oxmysql:execute(
            "UPDATE prism_banking_accounts SET balance = ? WHERE identifier = ? AND `primary` = 1",
            { frameworkBank, identifier }
        )
        return true
    end
    return false
end

    -- Main transaction handler (deposit, withdraw, transfer)
function InitializeTransaction(source, account, transactionType, amount, targetPlayerId)
    local player = GetPlayer(source)
    if not player then return false end

    -- Distance check for physical transactions (deposit/withdraw)
    if transactionType == "deposit" or transactionType == "withdraw" then
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local isNearBank = false
        local isNearAtm = false

        -- Check banks
        for _, bank in pairs(Config.Banks) do
            local dist = #(playerCoords - bank.InteractionCoords)
            if dist <= 15.0 then
                isNearBank = true
                break
            end
        end

        -- Check ATMs (using interaction distance from config)
        if not isNearBank and Config.ATMs.enabled then
            for _, atmProp in ipairs(Config.ATMs.props) do
                local atm = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, atmProp, false, false, false)
                if atm ~= 0 then
                    isNearAtm = true
                    break
                end
            end
        end

        if not isNearBank and not isNearAtm then
            print(string.format("[ANTIGRAVITY] Security: Player %s (%s) attempted %s of $%s without being near a Bank or ATM!", GetPlayerName(source), source, transactionType, amount))
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, "You must be at a Bank or ATM to do this!")
            return false
        end
    end

    -- Validate amount
    if type(amount) ~= "number" or amount <= 0 or amount ~= math.floor(amount) or amount > 999999999 then
        DebugPrint("[BANKING] Invalid amount: " .. tostring(amount))
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.invalid_amount)
        return false
    end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local accountNumber = nil
    if type(account) == "table" then
        accountNumber = account.accountNumber
    else
        accountNumber = account
    end
    accountNumber = tonumber(accountNumber) or accountNumber

    if not accountNumber then
        DebugPrint("[BANKING] Invalid account reference from player " .. source)
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.no_valid_account)
        return false
    end

    local accounts = GetBankAccounts(source)
    local accessAccount = nil
    for _, acc in ipairs(accounts) do
        if tostring(acc.accountNumber) == tostring(accountNumber) then
            accessAccount = acc
            break
        end
    end

    local hasVerifiedCardAccess = false
    if not accessAccount then
        hasVerifiedCardAccess = IsVerifiedAtmCardAccess(source, accountNumber)
    end

    if not accessAccount and not hasVerifiedCardAccess then
        DebugPrint("[BANKING] Player " .. source .. " attempted to access account they don't own: " .. tostring(accountNumber))
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.you_dont_own)
        return false
    end

    local dbAccount = GetBankAccountByAccountNumber(accountNumber)
    if not dbAccount then
        DebugPrint("[BANKING] Account not found for player " .. source .. ": " .. tostring(accountNumber))
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.no_valid_account)
        return false
    end

    account = dbAccount
    if accessAccount then
        account.primary = accessAccount.primary == true
        account.isNomineeAccount = accessAccount.isNomineeAccount == true
        account.identifier = accessAccount.identifier or account.identifier
    else
        account.primary = false
        account.isNomineeAccount = true
    end

    if hasVerifiedCardAccess and transactionType ~= "withdraw" then
        DebugPrint("[BANKING] Player " .. source .. " attempted non-withdraw transaction via verified card session")
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, "Card access only allows ATM withdrawals")
        return false
    end

    local hasAccess = false
    if account.isSociety then
        hasAccess = IsPlayerEligibleForSociety(source, account.type)
    elseif account.isNomineeAccount then
        hasAccess = true
        DebugPrint("[BANKING] Player " .. source .. " accessing nominee account " .. account.accountNumber)
    elseif account.identifier == identifier then
        hasAccess = true
    end

    if not hasAccess then
        DebugPrint("[BANKING] Access denied after validation for player " .. source .. " on account " .. tostring(account.accountNumber))
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.you_dont_own)
        return false
    end

    local success = false
    local updatedData = nil

    if transactionType == "deposit" then
        local cashOnHand = GetPlayerMoney(source)
        if amount > cashOnHand then
            DebugPrint("[BANKING] Player " .. source .. " attempted to deposit $" .. amount .. " but only has $" .. cashOnHand .. " in cash")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.you_dont_have_enough_cash)
            return false
        end

        if RemovePlayerMoney(source, "cash", amount) then
            local netAmount, taxAmount, taxDesc = ApplyTransactionTax(source, amount, transactionType, account.type)
            local oldBalance = account.balance or 0
            success = AddMoneyBankToAccount(source, account, netAmount)

            if success then
                TriggerPhoneNotification(source, amount .. "$ added to your bank account")
                AddTransactionToHistory(source, "deposit", netAmount, "cash", "Bank Deposit", "Cash deposited to bank account", account)
                if account.isSociety then
                    LogSocietyDeposit(source, account.type or "Unknown", account.accountNumber, netAmount, oldBalance + netAmount, oldBalance)
                else
                    LogDeposit(source, account.accountNumber, netAmount, oldBalance + netAmount, oldBalance)
                end
                if taxAmount > 0 then
                    DebugPrint("[TAX] Deposit tax applied: $" .. taxAmount .. " | Net deposit: $" .. netAmount .. " | " .. taxDesc)
                    LogTaxCollected(source, account.accountNumber, taxAmount, amount, taxDesc, "deposit")
                end
            end
        end

    elseif transactionType == "withdraw" then
        local settings
        if account.isNomineeAccount and account.identifier then
            settings = GetBankingSettingsByIdentifier(account.identifier)
            DebugPrint("[BANKING] Nominee withdrawal - using owner's withdrawal level")
        else
            settings = GetBankingSettings(source)
        end

        local level = settings.wit_level or 1
        local maxWithdraw = Config.BankingLevels.WithDrawLevel[level].maxWithdraw
        if amount > maxWithdraw then
            DebugPrint("[BANKING] Withdrawal denied: Amount $" .. amount .. " exceeds level " .. level .. " limit of $" .. maxWithdraw)
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.withdraw_denied)
            return false
        end

        local currentBalance = exports.oxmysql:executeSync(
            "SELECT balance FROM prism_banking_accounts WHERE accno = ?",
            { account.accountNumber }
        )
        currentBalance = (currentBalance and currentBalance[1] and currentBalance[1].balance) or 0

        success = RemoveMoneyBankFromAccount(source, account, amount)
        if not success then
            DebugPrint("[BANKING] Player " .. source .. " withdrawal of $" .. amount .. " failed - insufficient balance")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.not_enough_money_in_account)
            return false
        end

        if success then
            AddPlayerMoney(source, "cash", amount)
            TriggerPhoneNotification(source, amount .. "$ withdrawn from your bank account")
            AddTransactionToHistory(source, "withdraw", amount, "cash", "Bank Withdrawal", "Cash withdrawn from bank account", account)
            if account.isSociety then
                LogSocietyWithdraw(source, account.type or "Unknown", account.accountNumber, amount, currentBalance - amount, currentBalance)
            else
                LogWithdraw(source, account.accountNumber, amount, currentBalance - amount, currentBalance)
            end
        end

    elseif transactionType == "transfer" then
        if account.isSociety then
            DebugPrint("[BANKING] Player " .. source .. " attempted to transfer from society account")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, "Transfers are not allowed from society accounts")
            return false
        end
        if account.isNomineeAccount then
            DebugPrint("[BANKING] Player " .. source .. " attempted to transfer from nominee account")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, "Nominees cannot transfer money")
            return false
        end
        if not targetPlayerId or targetPlayerId == "" then
            DebugPrint("[BANKING] Player " .. source .. " attempted to transfer $" .. amount .. " but no target player was specified")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.no_target_player)
            return false
        end

        if tonumber(targetPlayerId) == source then
            DebugPrint("[BANKING] Player " .. source .. " attempted to transfer money to themselves")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, "You cannot transfer money to yourself")
            return false
        end

        local targetPlayer = GetPlayer(tonumber(targetPlayerId))
        if not targetPlayer then
            DebugPrint("[BANKING] Player " .. source .. " attempted to transfer $" .. amount .. " but target player " .. targetPlayerId .. " was not found")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.target_player_not_found)
            return false
        end

        local targetIdentifier = (Config.Framework == "esx") and targetPlayer.identifier or targetPlayer.PlayerData.citizenid

        -- Check if target allows transfers
        local targetSettings = exports.oxmysql:executeSync(
            "SELECT allow_transfer FROM prism_banking_settings WHERE identifier = ?",
            { targetIdentifier }
        )
        if not (targetSettings and targetSettings[1] and targetSettings[1].allow_transfer ~= 0) then
            DebugPrint("[BANKING] Transfer denied: Target player has transfers disabled")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.transfer_denied)
            return false
        end

        -- Get target's primary account
        local targetAccount = exports.oxmysql:executeSync(
            "SELECT * FROM prism_banking_accounts WHERE identifier = ? AND `primary` = 1",
            { targetIdentifier }
        )
        if not (targetAccount and targetAccount[1]) then
            DebugPrint("[BANKING] Transfer denied: Target player " .. targetPlayerId .. " does not have a primary bank account")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.transfer_denied_no_bank_account)
            return false
        end

        local targetAccNo = targetAccount[1].accno
        local senderBalance = exports.oxmysql:executeSync(
            "SELECT balance FROM prism_banking_accounts WHERE accno = ?",
            { account.accountNumber }
        )
        local receiverBalance = exports.oxmysql:executeSync(
            "SELECT balance FROM prism_banking_accounts WHERE accno = ?",
            { targetAccNo }
        )

        local oldSenderBalance = (senderBalance and senderBalance[1] and senderBalance[1].balance) or 0
        local oldReceiverBalance = (receiverBalance and receiverBalance[1] and receiverBalance[1].balance) or 0

        success = RemoveMoneyBankFromAccount(source, account, amount)
        if not success then
            DebugPrint("[BANKING] Player " .. source .. " transfer of $" .. amount .. " failed - insufficient balance")
            TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.not_enough_money_in_account)
            return false
        end

        if success then
            exports.oxmysql:execute(
                "UPDATE prism_banking_accounts SET balance = balance + ? WHERE accno = ?",
                { amount, targetAccNo }
            )
            if targetAccount[1].primary == 1 then
                AddPlayerMoney(tonumber(targetPlayerId), "bank", amount)
            end

            local targetName = (Config.Framework == "esx") and targetPlayer.getName() or (targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname)

            AddTransactionToHistory(source, "transfer", amount, "bank", "Bank Transfer", "Money transferred to " .. targetName, account)
            TriggerPhoneNotification(source, amount .. "$ transferred to " .. targetName)

            LogTransfer(source, tonumber(targetPlayerId), account.accountNumber, targetAccNo, amount, oldSenderBalance - amount, oldReceiverBalance + amount)
        end
    end

    if success then
        if account.isSociety then
            Wait(100)
        end
        local updatedAccounts = GetBankAccounts(source)
        local cashBalance = (Config.Framework == "esx") and player.getMoney() or player.PlayerData.money.cash
        local playerName = (Config.Framework == "esx") and player.getName() or (player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname)
        local profilePic = GetPlayerProfile(source)
        local history = GetTransactionHistory(source)
        local jobLabel = (Config.Framework == "esx") and GetJobLabel(player.job.name) or GetJobLabel(player.PlayerData.job)
        local creditScore = account.isSociety and GetCreditScore(source) or CalculateCreditScore(source)
        local settings = GetBankingSettings(source)

        updatedData = {
            accounts = SanitizeAccountsForClient(updatedAccounts),
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

        DebugPrint("[BANKING] Player " .. source .. " successfully " .. transactionType .. "ed $" .. amount)
        TriggerClientEvent("prism-banking:client:sendNotification", source, Locale.server.bank_activity, Locale.server.transaction_successful)
    end

    return success, updatedData
end

-- Toggle a banking setting (allow_transfer, is_optimized)
function ToggleBankingSetting(source, settingName)
    local player = GetPlayer(source)
    if not player then return false, nil end

    local validSettings = { allow_transfer = true, is_optimized = true }
    if not validSettings[settingName] then
        DebugPrint("[BANKING] Attempted to toggle invalid setting: " .. tostring(settingName))
        return false, nil
    end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid
    local settings = GetBankingSettings(source)
    if not settings then return false, nil end

    local newValue = (settings[settingName] == 1) and 0 or 1

    if settingName == "allow_transfer" then
        exports.oxmysql:execute(
            "UPDATE prism_banking_settings SET allow_transfer = ? WHERE identifier = ?",
            { newValue, identifier }
        )
    elseif settingName == "is_optimized" then
        exports.oxmysql:execute(
            "UPDATE prism_banking_settings SET is_optimized = ? WHERE identifier = ?",
            { newValue, identifier }
        )
    end

    local accounts = GetBankAccounts(source)
    local cashBalance = (Config.Framework == "esx") and player.getMoney() or player.PlayerData.money.cash
    local playerName = (Config.Framework == "esx") and player.getName() or (player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname)
    local profilePic = GetPlayerProfile(source)
    local history = GetTransactionHistory(source)
    local jobLabel = (Config.Framework == "esx") and GetJobLabel(player.job.name) or GetJobLabel(player.PlayerData.job)
    local creditScore = GetCreditScore(source)
    local newSettings = GetBankingSettings(source)

    local data = {
        accounts = SanitizeAccountsForClient(accounts),
        cashBalance = cashBalance,
        playerName = playerName,
        playerProfile = profilePic,
        History = history,
        playerJobLabel = jobLabel,
        creditScore = creditScore,
        settings = newSettings,
        bankingLevels = Config.BankingLevels,
        pinChangeCost = Config.PinChangeCost,
        Locale = Locale.UI,
        reIssueCardCost = Config.ReIssueCardCost,
        IsCardEnabled = Config.CardItemConfig.cardAsItem,
        cardSettings = Config.CardSettings,
        cardOrder = Config.CardOrder,
        primaryColor = Config.PrimaryColor
    }

    return true, data
end

-- Change account PIN (requires old PIN, cost)
function ChangeAccountPin(source, accountNumber, oldPin, newPin)
    local player = GetPlayer(source)
    if not player then
        return false, "Player not found", nil
    end

    if not HasAccountAccess(source, accountNumber, true) then
        DebugPrint("[BANKING] PIN change denied for player " .. source .. " - not account owner (possibly nominee)")
        return false, Locale.server.only_owner_can_change_pin, nil
    end

    if type(newPin) ~= "string" or #newPin ~= 5 or not tonumber(newPin) then
        DebugPrint("[BANKING] Invalid PIN format from player " .. source)
        return false, Locale.server.invalid_pin_format, nil
    end

    oldPin = tostring(oldPin)
    if type(oldPin) ~= "string" or #oldPin ~= 5 or not tonumber(oldPin) then
        DebugPrint("[BANKING] Invalid old PIN format from player " .. source)
        return false, Locale.server.invalid_pin_format, nil
    end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local accountCheck = exports.oxmysql:executeSync(
        "SELECT * FROM prism_banking_accounts WHERE identifier = ? AND accno = ? AND pin = ? AND (is_society = 0 OR is_society IS NULL)",
        { identifier, accountNumber, oldPin }
    )
    if not (accountCheck and #accountCheck > 0) then
        DebugPrint("[BANKING] PIN change denied for player " .. source .. " - account not found or wrong PIN")
        return false, Locale.server.invalid_pin_account, nil
    end

    local cost = Config.PinChangeCost
    if cost > GetPlayerMoney(source) then
        return false, Locale.server.insuff_fund_pin, nil
    end

    RemovePlayerMoney(source, "cash", cost)

    exports.oxmysql:execute(
        "UPDATE prism_banking_accounts SET pin = ? WHERE identifier = ? AND accno = ?",
        { newPin, identifier, accountNumber }
    )

    LogPinChanged(source, accountNumber)

    local accounts = GetBankAccounts(source)
    local cashBalance = (Config.Framework == "esx") and player.getMoney() or player.PlayerData.money.cash
    local playerName = (Config.Framework == "esx") and player.getName() or (player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname)
    local profilePic = GetPlayerProfile(source)
    local history = GetTransactionHistory(source)
    local jobLabel = (Config.Framework == "esx") and GetJobLabel(player.job.name) or GetJobLabel(player.PlayerData.job)
    local creditScore = GetCreditScore(source)
    local settings = GetBankingSettings(source)

    local data = {
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

    return true, Locale.server.pin_changed, data
end
exports("AddBankingTransaction", function(source, transactionType, amount, spendType, applyTax, customName, customDesc)
    -- External API to log a transaction without modifying balances
    if type(source) ~= "number" or source <= 0 then
        DebugPrint("[BANKING] AddBankingTransaction: Invalid source: " .. tostring(source))
        return 0, 0
    end
    if type(amount) ~= "number" or amount <= 0 or amount ~= math.floor(amount) then
        DebugPrint("[BANKING] AddBankingTransaction: Invalid amount: " .. tostring(amount))
        return 0, 0
    end
    local validTypes = { deposit = true, withdraw = true, transfer = true, interest = true }
    if not validTypes[transactionType] then
        DebugPrint("[BANKING] AddBankingTransaction: Invalid transaction type: " .. tostring(transactionType))
        return 0, 0
    end
    if type(spendType) ~= "string" or spendType == "" then
        DebugPrint("[BANKING] AddBankingTransaction: Invalid spend type: " .. tostring(spendType))
        return 0, 0
    end

    local player = GetPlayer(source)
    if not player then
        DebugPrint("[BANKING] AddBankingTransaction: Player not found for source: " .. source)
        return 0, 0
    end

    local accounts = GetBankAccounts(source)
    local primaryAccount = nil
    for _, acc in ipairs(accounts) do
        if acc.primary then
            primaryAccount = acc
            break
        end
    end
    if not primaryAccount then
        DebugPrint("[BANKING] AddBankingTransaction: Player has no primary account")
        return 0, 0
    end

    if applyTax == nil then applyTax = true end

    local netAmount = amount
    local taxAmount = 0
    local taxDesc = "No tax applied"
    if applyTax and transactionType == "deposit" then
        netAmount, taxAmount, taxDesc = ApplyTransactionTax(source, amount, transactionType, primaryAccount.type)
        DebugPrint(string.format("[BANKING] Export transaction tax: $%s -> $%s (tax: $%s) | %s", amount, netAmount, taxAmount, taxDesc))
    end

    if not customName or customName == "" then
        local readable = spendType:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest:lower() end)
        if transactionType == "deposit" then
            customName = string.format("Deposit from %s", readable)
        elseif transactionType == "withdraw" then
            customName = string.format("Withdrawal for %s", readable)
        elseif transactionType == "transfer" then
            customName = string.format("Transfer via %s", readable)
        elseif transactionType == "interest" then
            customName = string.format("Interest earned on %s", readable)
        else
            customName = string.format("Transaction via %s", readable)
        end
    end

    if not customDesc or customDesc == "" then
        local readable = spendType:gsub("_", " ")
        if transactionType == "deposit" then
            customDesc = string.format("Deposit from %s", readable)
        elseif transactionType == "withdraw" then
            customDesc = string.format("Withdrawal for %s", readable)
        elseif transactionType == "transfer" then
            customDesc = string.format("Transfer via %s", readable)
        elseif transactionType == "interest" then
            customDesc = string.format("Interest earned on %s", readable)
        else
            customDesc = string.format("Transaction via %s", readable)
        end
    end

    AddTransactionToHistory(source, transactionType, netAmount, spendType, customName, customDesc)
    DebugPrint(string.format("[BANKING] Transaction logged from external resource: %s $%s (%s) | Original: $%s | Tax: $%s | Net to add: $%s",
        transactionType, netAmount, spendType, amount, taxAmount, netAmount))

    return netAmount, taxAmount
end)

-- Calculate and add interest for a player
function CalculateInterest(source)
    if not Config.InterestSystem.enabled then return false end

    local player = GetPlayer(source)
    if not player then return false end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid
    local currentTime = os.time()
    local accounts = GetBankAccounts(source)
    if not accounts or #accounts == 0 then return false end

    local totalInterest = 0
    for _, acc in ipairs(accounts) do
        if not acc.isSociety then
            local lastInterest = exports.oxmysql:executeSync(
                "SELECT last_interest_date FROM prism_banking_accounts WHERE accno = ?",
                { acc.accountNumber }
            )
            lastInterest = (lastInterest and lastInterest[1] and lastInterest[1].last_interest_date) or nil

            local shouldPay = false
            if not lastInterest then
                shouldPay = true
            else
                local diff = currentTime - lastInterest
                if Config.InterestSystem.intervalType == "hour" then
                    if diff / 3600 >= Config.InterestSystem.intervalAmount then
                        shouldPay = true
                    end
                elseif Config.InterestSystem.intervalType == "day" then
                    if diff / 86400 >= Config.InterestSystem.intervalAmount then
                        shouldPay = true
                    end
                elseif Config.InterestSystem.intervalType == "month" then
                    if diff / 2592000 >= Config.InterestSystem.intervalAmount then
                        shouldPay = true
                    end
                end
            end

            if shouldPay and acc.balance >= Config.InterestSystem.minBalance then
                local rate = (Config.CardSettings[acc.type] and Config.CardSettings[acc.type].InterestRate) or 0.05
                local interest = math.floor(acc.balance * (rate / 100))
                interest = math.min(interest, Config.InterestSystem.maxInterest)

                if interest > 0 then
                    if Config.TaxSystem.taxableTransactions.interest then
                        interest = ApplyTransactionTax(source, interest, "interest", acc.type)
                    end

                    AddMoneyBankToAccount(source, acc, interest)
                    exports.oxmysql:execute(
                        "UPDATE prism_banking_accounts SET last_interest_date = ? WHERE accno = ?",
                        { currentTime, acc.accountNumber }
                    )
                    AddTransactionToHistory(source, "deposit", interest, "interest", "Interest Earned", "Interest earned on account balance", acc)
                    totalInterest = totalInterest + interest
                    DebugPrint("[BANKING] Interest paid to player " .. source .. " account " .. acc.accountNumber .. ": $" .. interest)
                end
            end
        end
    end

    if totalInterest > 0 then
        return true, totalInterest
    end
    return false, 0
end

-- Check if player can create another personal account (based on level)
function CheckEligibilityToCreateAccount(source)
    local player = GetPlayer(source)
    if not player then return false end

    local accounts = GetBankAccounts(source)
    local level = GetPlayerAccountLevel(source)
    local ownedCount = 0
    for _, acc in ipairs(accounts) do
        if not acc.isSociety and not acc.isNomineeAccount then
            ownedCount = ownedCount + 1
        end
    end

    local maxAccounts = Config.BankingLevels.AccountsLevel[level].maxAccounts
    return ownedCount < maxAccounts
end

-- Check if player is tax exempt
function IsPlayerTaxExempt(source, transactionType)
    if not Config.TaxSystem.enabled or not Config.TaxSystem.exemptions.enabled then
        return false
    end

    local player = GetPlayer(source)
    if not player then return false end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    -- Check citizen exemptions
    if Config.TaxSystem.exemptions.citizens then
        for _, exemptId in ipairs(Config.TaxSystem.exemptions.citizens) do
            if identifier == exemptId then
                return true
            end
        end
    end

    -- Check job exemptions
    if Config.TaxSystem.exemptions.jobs then
        local jobName = (Config.Framework == "esx") and player.job.name or player.PlayerData.job.name
        for _, exemptJob in ipairs(Config.TaxSystem.exemptions.jobs) do
            if jobName == exemptJob then
                return true
            end
        end
    end

    return false
end

-- Get current holiday tax modifier
function GetHolidayTaxModifier()
    if not Config.TaxSystem.holidays.enabled then return nil end

    local today = os.date("*t")
    for _, holiday in ipairs(Config.TaxSystem.holidays.dates) do
        if holiday[1] == today.month and holiday[2] == today.day then
            return holiday[3]
        end
    end
    return nil
end

-- Calculate tax for a given amount and transaction type
function CalculateTax(amount, transactionType)
    if not Config.TaxSystem.enabled or not Config.TaxSystem.taxableTransactions[transactionType] then
        return 0, 0, "Transaction Type Exempt"
    end

    local holidayMod = GetHolidayTaxModifier()
    local taxAmount = 0
    local taxRate = 0
    local bracketDesc = ""

    if Config.TaxSystem.advanced.progressive then
        local remaining = amount
        for _, bracket in ipairs(Config.TaxSystem.brackets) do
            if remaining <= 0 then break end
            local min = bracket.min
            local max = bracket.max
            local rate = bracket.rate
            if holidayMod then
                rate = rate * (holidayMod / 100)
            end
            if amount > min then
                local taxable = math.min(remaining, max - min)
                if amount >= max then
                    taxable = max - min
                else
                    taxable = amount - min
                end
                local tax = taxable * rate / 100
                taxAmount = taxAmount + tax
                remaining = remaining - taxable
                if tax > 0 then
                    bracketDesc = bracket.description
                    taxRate = rate
                end
            end
        end
    else
        for _, bracket in ipairs(Config.TaxSystem.brackets) do
            if amount >= bracket.min and amount <= bracket.max then
                taxRate = bracket.rate
                if holidayMod then
                    taxRate = taxRate * (holidayMod / 100)
                end
                taxAmount = amount * taxRate / 100
                bracketDesc = bracket.description
                break
            end
        end
    end

    taxAmount = math.floor(taxAmount + 0.5) -- round
    if taxAmount < Config.TaxSystem.advanced.minTaxAmount then
        return 0, 0, "Below Minimum Tax Amount"
    end

    return taxAmount, taxRate, bracketDesc
end

-- Process tax payment (log, notify, add to society)
function ProcessTaxPayment(source, taxAmount, transactionType, originalAmount)
    if taxAmount <= 0 then return true end

    local player = GetPlayer(source)
    if not player then return false end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    if Config.TaxSystem.advanced.logTransactions then
        local logEntry = {
            identifier = identifier,
            amount = originalAmount,
            taxAmount = taxAmount,
            transactionType = transactionType,
            timestamp = os.time(),
            date = os.date("%Y-%m-%d %H:%M:%S")
        }
        local logs = json.decode(LoadResourceFile(GetCurrentResourceName(), Config.TaxSystem.advanced.logPath) or "[]")
        table.insert(logs, logEntry)
        SaveResourceFile(GetCurrentResourceName(), Config.TaxSystem.advanced.logPath, json.encode(logs, { indent = true }), -1)
    end

    AddTaxToSociety(taxAmount)

    if Config.TaxSystem.collection.notification then
        local percent = (taxAmount / originalAmount) * 100
        local msg = string.format("Tax deducted: $%s (%.1f%%)", taxAmount, percent)
        TriggerClientEvent("prism-banking:client:sendNotification", source, "Tax Notice", msg)
    end

    return true
end

-- Apply tax to a transaction amount, return net amount, tax amount, and description
function ApplyTransactionTax(source, amount, transactionType, cardType)
    if not Config.TaxSystem.enabled then
        return amount, 0, "Tax system disabled"
    end

    if IsPlayerTaxExempt(source, transactionType) then
        return amount, 0, "Player is tax exempt"
    end

    local taxAmount, taxRate, bracketDesc = CalculateTax(amount, transactionType)
    if taxAmount > 0 then
        ProcessTaxPayment(source, taxAmount, transactionType, amount)
        local netAmount = amount - taxAmount
        DebugPrint(string.format("[TAX] Transaction: $%s | Tax: $%s (%.1f%%) | Net: $%s | Bracket: %s",
            amount, taxAmount, taxRate, netAmount, bracketDesc))
        return netAmount, taxAmount, bracketDesc
    end

    return amount, 0, "No tax applied"
end