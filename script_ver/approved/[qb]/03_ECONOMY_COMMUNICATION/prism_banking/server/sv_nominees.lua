-- Get all nominees for a given account number
local function GetNomineesForAccount(accountNumber)
    local rows = exports.oxmysql:executeSync(
        "SELECT * FROM prism_banking_nominees WHERE account_number = ?",
        { accountNumber }
    )
    if not rows then return {} end

    local nominees = {}
    for _, row in ipairs(rows) do
        local nomineeName = "Unknown Player"
        if Config.Framework == "esx" then
            local nameResult = exports.oxmysql:executeSync(
                "SELECT firstname, lastname FROM users WHERE identifier = ? LIMIT 1",
                { row.nominee_identifier }
            )
            if nameResult and nameResult[1] then
                nomineeName = (nameResult[1].firstname or "Unknown") .. " " .. (nameResult[1].lastname or "Player")
            end
        else
            local nameResult = exports.oxmysql:executeSync(
                "SELECT charinfo FROM players WHERE citizenid = ? LIMIT 1",
                { row.nominee_identifier }
            )
            if nameResult and nameResult[1] and nameResult[1].charinfo then
                local charinfo = json.decode(nameResult[1].charinfo)
                if charinfo and charinfo.firstname and charinfo.lastname then
                    nomineeName = charinfo.firstname .. " " .. charinfo.lastname
                end
            end
        end
        table.insert(nominees, {
            id = row.id,
            nominee_identifier = row.nominee_identifier,
            nominee_name = nomineeName,
            added_date = row.added_date,
            added_by = row.added_by
        })
    end
    return nominees
end

-- Check if a player is a nominee for a specific account
local function IsPlayerNominee(nomineeIdentifier, accountNumber)
    local result = exports.oxmysql:executeSync([[
        SELECT id FROM prism_banking_nominees
        WHERE account_number = ? AND nominee_identifier = ?
    ]], { accountNumber, nomineeIdentifier })
    return result and #result > 0
end

-- Check if a player owns an account (not nominee)
local function DoesPlayerOwnAccount(ownerIdentifier, accountNumber)
    local result = exports.oxmysql:executeSync([[
        SELECT identifier FROM prism_banking_accounts
        WHERE accno = ? AND identifier = ? AND (is_society = 0 OR is_society IS NULL)
    ]], { accountNumber, ownerIdentifier })
    return result and #result > 0
end

-- Add a nominee to an account
function AddNominee(source, accountNumber, targetServerId)
    local player = GetPlayer(source)
    if not player then
        return { success = false, message = Locale.server.player_not_found }
    end

    local ownerIdentifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    if not DoesPlayerOwnAccount(ownerIdentifier, accountNumber) then
        DebugPrint("[NOMINEES] Player " .. source .. " attempted to add nominee to account they don't own: " .. accountNumber)
        return { success = false, message = Locale.server.you_dont_own }
    end

    -- Check if it's a society account (nominees not allowed)
    local isSociety = exports.oxmysql:executeSync(
        "SELECT is_society FROM prism_banking_accounts WHERE accno = ?",
        { accountNumber }
    )
    if isSociety and isSociety[1] and isSociety[1].is_society == 1 then
        return { success = false, message = Locale.server.cannot_add_nominee_society }
    end

    local targetPlayer = GetPlayer(targetServerId)
    if not targetPlayer then
        return { success = false, message = Locale.server.target_not_online }
    end

    local targetIdentifier = (Config.Framework == "esx") and targetPlayer.identifier or targetPlayer.PlayerData.citizenid

    if targetIdentifier == ownerIdentifier then
        return { success = false, message = Locale.server.cannot_add_self_nominee }
    end

    if IsPlayerNominee(targetIdentifier, accountNumber) then
        return { success = false, message = Locale.server.already_nominee }
    end

    DebugPrint("[NOMINEES] Attempting to add nominee - Account: " .. accountNumber .. ", Owner: " .. ownerIdentifier .. ", Nominee: " .. targetIdentifier)

    local insertResult = exports.oxmysql:executeSync([[
        INSERT INTO prism_banking_nominees (account_number, owner_identifier, nominee_identifier, added_by)
        VALUES (?, ?, ?, ?)
    ]], { accountNumber, ownerIdentifier, targetIdentifier, ownerIdentifier })

    -- Verify insertion
    local check = exports.oxmysql:executeSync([[
        SELECT id FROM prism_banking_nominees
        WHERE account_number = ? AND nominee_identifier = ?
    ]], { accountNumber, targetIdentifier })

    if check and #check > 0 then
        local targetName
        if Config.Framework == "esx" then
            targetName = targetPlayer.getName()
        else
            targetName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
        end

        DebugPrint("[NOMINEES] Successfully added " .. targetName .. " (ID: " .. targetIdentifier .. ") as nominee to account " .. accountNumber)

        TriggerClientEvent("prism-banking:client:sendNotification", source,
            Locale.server.bank_activity,
            string.format(Locale.server.nominee_added, targetName))

        TriggerClientEvent("prism-banking:client:sendNotification", targetServerId,
            Locale.server.bank_activity,
            Locale.server.nominee_added_notification)

        TriggerClientEvent("prism-banking:client:refreshBankingData", targetServerId)

        if Config.Webhooks and Config.Webhooks.enabled then
            LogNomineeAdded(source, accountNumber, targetServerId, targetName)
        end

        return { success = true, message = Locale.server.nominee_added }
    else
        DebugPrint("[NOMINEES] Failed to add nominee to account " .. accountNumber .. " - Database insertion failed")
        return { success = false, message = Locale.server.failed_add_nominee }
    end
end

-- Remove a nominee from an account
function RemoveNominee(source, accountNumber, nomineeId)
    local player = GetPlayer(source)
    if not player then
        return { success = false, message = Locale.server.player_not_found }
    end

    local ownerIdentifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    if not DoesPlayerOwnAccount(ownerIdentifier, accountNumber) then
        DebugPrint("[NOMINEES] Player " .. source .. " attempted to remove nominee from account they don't own: " .. accountNumber)
        return { success = false, message = Locale.server.you_dont_own }
    end

    -- Get nominee identifier before deletion
    local nomineeInfo = exports.oxmysql:executeSync([[
        SELECT nominee_identifier FROM prism_banking_nominees
        WHERE id = ? AND account_number = ?
    ]], { nomineeId, accountNumber })

    if not nomineeInfo or #nomineeInfo == 0 then
        return { success = false, message = Locale.server.nominee_not_found }
    end

    local result = exports.oxmysql:executeSync([[
        DELETE FROM prism_banking_nominees
        WHERE id = ? AND account_number = ? AND owner_identifier = ?
    ]], { nomineeId, accountNumber, ownerIdentifier })

    DebugPrint("[NOMINEES] Delete result type: " .. type(result) .. ", value: " .. tostring(result))

    local deleted = false
    if type(result) == "number" and result > 0 then
        deleted = true
    elseif type(result) == "table" and result.affectedRows and result.affectedRows > 0 then
        deleted = true
    end

    if deleted then
        local nomineeIdentifier = nomineeInfo[1].nominee_identifier
        DebugPrint("[NOMINEES] Player " .. source .. " removed nominee from account " .. accountNumber)

        TriggerClientEvent("prism-banking:client:sendNotification", source,
            Locale.server.bank_activity,
            Locale.server.nominee_removed)

        -- Find online nominee and refresh their data
        local players = GetPlayers()
        for _, serverId in ipairs(players) do
            local p = GetPlayer(tonumber(serverId))
            if p then
                local id = (Config.Framework == "esx") and p.identifier or p.PlayerData.citizenid
                if id == nomineeIdentifier then
                    TriggerClientEvent("prism-banking:client:refreshBankingData", tonumber(serverId))
                    TriggerClientEvent("prism-banking:client:sendNotification", tonumber(serverId),
                        Locale.server.bank_activity,
                        Locale.server.nominee_removed_notification)
                    break
                end
            end
        end

        if Config.Webhooks and Config.Webhooks.enabled then
            LogNomineeRemoved(source, accountNumber, nomineeIdentifier)
        end

        return { success = true, message = Locale.server.nominee_removed }
    else
        return { success = false, message = Locale.server.failed_remove_nominee }
    end
end

-- Get all accounts accessible by player (including nominee accounts)
function GetAccessibleAccounts(source)
    local player = GetPlayer(source)
    if not player then return {} end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    local accounts = GetBankAccounts(source)

    -- Add nominee accounts (they are already included in GetBankAccounts, but this function is for explicit nominee listing)
    local nomineeAccounts = exports.oxmysql:executeSync([[
        SELECT a.accno as accountNumber, a.type, a.balance, a.pin, a.primary, a.identifier,
               a.is_society as isSociety, a.society_job as societyJob
        FROM prism_banking_nominees n
        INNER JOIN prism_banking_accounts a ON n.account_number = a.accno
        WHERE n.nominee_identifier = ? AND a.is_society = 0
    ]], { identifier })

    if nomineeAccounts then
        for _, acc in ipairs(nomineeAccounts) do
            acc.isNomineeAccount = true
            acc.isSociety = (acc.isSociety == 1)
            acc.primary = (acc.primary == 1)
            table.insert(accounts, acc)
        end
    end

    return accounts
end

-- Check if a player has access to an account (owner or nominee)
function HasAccountAccess(source, accountNumber, requireOwner)
    local player = GetPlayer(source)
    if not player then return false end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    if DoesPlayerOwnAccount(identifier, accountNumber) then
        return true
    end

    if requireOwner then
        return false
    end

    return IsPlayerNominee(identifier, accountNumber)
end

-- Callback: get nominees for an account
RegisterServerCallback("prism-banking:server:getNominees", function(source, cb, accountNumber)
    local player = GetPlayer(source)
    if not player then
        DebugPrint("[NOMINEES] Player not found for source: " .. source)
        cb({ success = false, message = Locale.server.player_not_found })
        return
    end

    local identifier = (Config.Framework == "esx") and player.identifier or player.PlayerData.citizenid

    if not DoesPlayerOwnAccount(identifier, accountNumber) then
        DebugPrint("[NOMINEES] Player " .. source .. " is not owner of account " .. accountNumber)
        cb({ success = false, message = Locale.server.you_dont_own })
        return
    end

    local nominees = GetNomineesForAccount(accountNumber)
    DebugPrint("[NOMINEES] Found " .. #nominees .. " nominees for account " .. accountNumber)
    cb({ success = true, nominees = nominees })
end)

-- Callback: add a nominee
RegisterServerCallback("prism-banking:server:addNominee", function(source, cb, accountNumber, targetServerId)
    cb(AddNominee(source, accountNumber, targetServerId))
end)

-- Callback: remove a nominee
RegisterServerCallback("prism-banking:server:removeNominee", function(source, cb, accountNumber, nomineeId)
    cb(RemoveNominee(source, accountNumber, nomineeId))
end)

print("^2[Prism Banking]^0 Nominee management system loaded")