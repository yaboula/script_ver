QBCore = exports["qb-core"]:GetCoreObject()
local Config = exports[GetCurrentResourceName()]:GetConfig()
SocietiesAccounts = {}
PlayersCurrentBanks = {}
local playerNearATM = {}
local PlayerOperationCooldowns = {}
local OPERATION_COOLDOWN = 1000 -- Reduced to 1 second


-- Update all online players credit scores every 10 minutes
CreateThread(function()
    while true do
        Wait(600000) -- 10 minutes
        
        local Players = QBCore.Functions.GetQBPlayers()
        for _, Player in pairs(Players) do
            if Player then
                UpdatePlayerCreditScore(Player.PlayerData.citizenid)
            end
        end
    end
end)

-- Clean up cooldowns every minute instead of 5 minutes
CreateThread(function()
    while true do
        Wait(60000) -- 1 minute
        
        local currentTime = GetGameTimer()
        local cleaned = 0
        
        for key, time in pairs(PlayerOperationCooldowns) do
            if (currentTime - time) > (OPERATION_COOLDOWN * 30) then -- Clean after 30 seconds
                PlayerOperationCooldowns[key] = nil
                cleaned = cleaned + 1
            end
        end
    end
end)


local function IsPlayerOnCooldown(playerId, operation)
    local now = GetGameTimer()
    local key = tostring(playerId) .. ":" .. tostring(operation)
    local last = PlayerOperationCooldowns[key]

    if last and (now - last) < OPERATION_COOLDOWN then
        return true
    end

    PlayerOperationCooldowns[key] = now
    return false
end

function IsPlayerNearABank(playerId)
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then return false end
    
    local playerCoords = GetEntityCoords(playerPed)
    if not playerCoords then return false end

    -- Check bank locations
    for _, bankCoords in pairs(Config.BankLocations) do
        if type(bankCoords) == "vector4" then
            if (#(playerCoords - vector3(bankCoords.x, bankCoords.y, bankCoords.z)) < 5.0) then
                return true
            end
        else
            -- Handle non-vector4 format if present
            if (#(playerCoords - vector3(bankCoords.x, bankCoords.y, bankCoords.z)) < 5.0) then
                return true
            end
        end
    end
    
    if playerNearATM[playerId] then
        return true
    end

    return false
end


local function safePrint(...)
    local args = {...}
    local output = ""
    for i, arg in ipairs(args) do
        if type(arg) == "table" then
            output = output .. " " .. json.encode(arg)
        else
            output = output .. " " .. tostring(arg)
        end
    end
end

CreateThread(function()
    local result = MySQL.query.await("SELECT `name`, `money` FROM `society`")

    if (result) then
        for i = 1, #result do
            local row = result[i]

            SocietiesAccounts[row.name] = row.money == nil and 0 or tonumber(row.money)
        end
    end
end)


function LogTransaction(playerId, senderName, receiverName, society, amount, transactionType, note)
    -- קוד קיים של LogTransaction...
    local typeNum = Config.LogTypes[transactionType] 
    if not typeNum then
        typeNum = 1
    end
    
    local insertId = MySQL.insert.await(
    "INSERT INTO banking_transactions (sender_name, receiver_name, society, amount, type, note, timestamp) VALUES (?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)",
        {
            senderName,
            receiverName,
            society,
            amount,
            typeNum,
            note
        })
    
    Wait(100)
    
    local Player = QBCore.Functions.GetPlayer(playerId)
    
    if society then
        -- קוד society קיים...
        if Player.PlayerData.job.isboss then
            local societyTransactions = {}
            
            local societyResult = MySQL.query.await("SELECT * FROM banking_transactions WHERE society = ? ORDER BY `id` DESC LIMIT 10000", {
                society
            })
    
            if societyResult then
                for i = 1, #societyResult do
                    local txType = societyResult[i].type
                    local typeString = Config.LogTypes[txType]
                    
                    societyTransactions[#societyTransactions + 1] = {
                        sender = societyResult[i].sender_name,
                        receiver = societyResult[i].receiver_name,
                        society = societyResult[i].society,
                        amount = societyResult[i].amount,
                        type = typeString or "unknown_" .. tostring(txType),
                        note = societyResult[i].note,
                        timestamp = societyResult[i].timestamp,
                    }
                end
            end
            
            TriggerClientEvent("nc-banking:client:updateSocietyTransactions", playerId, societyTransactions)
        end
    else
        -- Personal transaction - retrieve personal transactions AND daily spending
        local personalTransactions = {}
        
        local result = MySQL.query.await("SELECT * FROM banking_transactions WHERE sender_name = ? AND (society IS NULL OR society = '') ORDER BY `id` DESC LIMIT 10000", {
            Player.PlayerData.citizenid
        })
    
        if result then
            for i = 1, #result do
                local txType = result[i].type
                
                local typeString
                if type(txType) == "number" then
                    local typeMap = {
                        [1] = "deposit",
                        [2] = "withdraw",
                        [3] = "society_deposit",
                        [4] = "society_withdraw",
                        [5] = "transfer",
                        [6] = "shared_deposit",
                        [7] = "shared_withdraw",
                        [8] = "shared_transfer"
                    }
                    typeString = typeMap[txType] or "unknown_" .. tostring(txType)
                else
                    typeString = Config.LogTypes[txType] or tostring(txType)
                end
                
                personalTransactions[#personalTransactions + 1] = {
                    sender = result[i].sender_name,
                    receiver = result[i].receiver_name,
                    society = result[i].society,
                    amount = result[i].amount,
                    type = typeString,
                    note = result[i].note,
                    timestamp = result[i].timestamp,
                }
            end
        end
        
        TriggerClientEvent("nc-banking:client:updateTransactions", playerId, personalTransactions)
    end
end

QBCore.Functions.CreateCallback("nc-banking:server:checkBankCard", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb({hasCardInDB = false, hasCardInInventory = false, isFirstTime = true})
        return
    end
    
    local status = GetCardStatus(Player.PlayerData.citizenid, source)
    cb(status)
end)


QBCore.Functions.CreateCallback("nc-banking:server:getSocietyTransactions", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local societyTransactions = {}

    if not Player.PlayerData.job.isboss then
        cb(societyTransactions)
        return
    end

    local result = MySQL.query.await("SELECT * FROM banking_transactions WHERE society = ? ORDER BY `id` DESC LIMIT 10000", {
        Player.PlayerData.job.name
    })

    if result then
        for i = 1, #result do
            -- Fix type conversion - this is the critical part
            local txType = result[i].type
            
            -- Force explicit conversion based on type
            local typeString
            if type(txType) == "number" then
                -- Direct number-to-string mapping
                local typeMap = {
                    [1] = "deposit",
                    [2] = "withdraw",
                    [3] = "society_deposit",
                    [4] = "society_withdraw",
                    [5] = "transfer",
                    [6] = "shared_deposit",
                    [7] = "shared_withdraw",
                    [8] = "shared_transfer"
                }
                typeString = typeMap[txType] or "unknown_" .. tostring(txType)
            else
                -- Already a string, or other type
                typeString = Config.LogTypes[txType] or tostring(txType)
            end
            
            -- השתמש ב societyTransactions במקום personalTransactions
            table.insert(societyTransactions, {
                sender = result[i].sender_name,
                receiver = result[i].receiver_name,
                society = result[i].society,
                amount = result[i].amount,
                type = typeString,
                note = result[i].note,
                timestamp = result[i].timestamp,
            })
        end
    end

    cb(societyTransactions)
end)

function GetPlayerCreditScore(citizenid)
    local result = MySQL.query.await("SELECT credit_score FROM player_credit_scores WHERE citizenid = ?", {citizenid})
    
    if result and #result > 0 then
        return result[1].credit_score
    else
        -- New player gets a realistic starting credit score
        -- In real life, new accounts start around 580-620 ("Fair" range)
        local startingScore = 580 -- Fair credit score for new accounts
        
        MySQL.insert.await("INSERT INTO player_credit_scores (citizenid, credit_score) VALUES (?, ?)", {citizenid, startingScore})
        return startingScore
    end
end

function HasPhysicalCardInInventory(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then return false end
    
    local cardItem = Player.Functions.GetItemByName("bank_card")
    return cardItem ~= nil and cardItem.amount > 0
end

-- Replace the GetPlayerCreditScore function in server main.lua:

function GetPlayerCreditScore(citizenid)
    local result = MySQL.query.await("SELECT credit_score FROM player_credit_scores WHERE citizenid = ?", {citizenid})
    
    if result and #result > 0 then
        return result[1].credit_score
    else
        -- New player gets a realistic starting credit score
        -- In real life, new accounts start around 580-620 ("Fair" range)
        local startingScore = 580 -- Fair credit score for new accounts
        
        MySQL.insert.await("INSERT INTO player_credit_scores (citizenid, credit_score) VALUES (?, ?)", {citizenid, startingScore})
        return startingScore
    end
end

-- Also update the CalculateCreditScore function baseScore:

function CalculateCreditScore(citizenid)
    local baseScore = 580 -- Changed from 500 to realistic starting score
    local bonuses = 0
    local penalties = 0
    
    local thirtyDaysAgo = os.date("!%Y-%m-%d %H:%M:%S", os.time() - (30 * 24 * 60 * 60))
    
    local result = MySQL.query.await([[
        SELECT amount, type, timestamp, 
               DATEDIFF(NOW(), timestamp) as days_ago,
               DATE(timestamp) as transaction_date
        FROM banking_transactions 
        WHERE sender_name = ? 
        AND timestamp >= ?
        AND (society IS NULL OR society = '')
        ORDER BY timestamp DESC
    ]], {
        citizenid,
        thirtyDaysAgo
    })
    
    if not result or #result == 0 then
        -- No transactions = slight penalty for complete inactivity
        return math.max(550, baseScore - 30) -- Minimum 550 for inactive accounts
    end
    
    local totalIncome = 0
    local totalExpenses = 0
    local dailyActivity = {}
    
    for _, tx in ipairs(result) do
        local amount = tonumber(tx.amount) or 0
        local txType = tonumber(tx.type) or 0
        local date = tx.transaction_date
        
        if not dailyActivity[date] then
            dailyActivity[date] = {income = 0, expenses = 0, count = 0}
        end
        
        dailyActivity[date].count = dailyActivity[date].count + 1
        
        if txType == 1 then -- deposit
            totalIncome = totalIncome + amount
            dailyActivity[date].income = dailyActivity[date].income + amount
        elseif txType == 2 or txType == 5 then -- withdraw or transfer
            totalExpenses = totalExpenses + amount
            dailyActivity[date].expenses = dailyActivity[date].expenses + amount
        end
    end
    
    -- Income vs Expenses ratio
    if totalExpenses > 0 then
        local ratio = totalIncome / totalExpenses
        if ratio >= 3.0 then
            bonuses = bonuses + 30
        elseif ratio >= 2.0 then
            bonuses = bonuses + 20
        elseif ratio >= 1.5 then
            bonuses = bonuses + 15
        elseif ratio >= 1.0 then
            bonuses = bonuses + 10
        elseif ratio >= 0.7 then
            bonuses = bonuses + 5
        else
            penalties = penalties + 15
        end
    else
        bonuses = bonuses + 10
    end
    
    -- Activity consistency
    local activeDays = 0
    for _, activity in pairs(dailyActivity) do
        if activity.count >= 1 then
            activeDays = activeDays + 1
        end
    end
    
    if activeDays >= 25 then
        bonuses = bonuses + 25
    elseif activeDays >= 20 then
        bonuses = bonuses + 20
    elseif activeDays >= 15 then
        bonuses = bonuses + 15
    elseif activeDays >= 10 then
        bonuses = bonuses + 10
    elseif activeDays >= 5 then
        bonuses = bonuses + 5
    else
        penalties = penalties + 10
    end
    
    -- Current balance
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Player then
        local currentBalance = Player.PlayerData.money.bank
        
        if currentBalance >= 5000000 then
            bonuses = bonuses + 40
        elseif currentBalance >= 2000000 then
            bonuses = bonuses + 30
        elseif currentBalance >= 1000000 then
            bonuses = bonuses + 25
        elseif currentBalance >= 500000 then
            bonuses = bonuses + 20
        elseif currentBalance >= 100000 then
            bonuses = bonuses + 15
        elseif currentBalance >= 50000 then
            bonuses = bonuses + 10
        elseif currentBalance >= 10000 then
            bonuses = bonuses + 5
        elseif currentBalance < 1000 then
            penalties = penalties + 20
        end
    end
    
    -- Transaction volume
    local transactionCount = #result
    if transactionCount >= 200 then
        bonuses = bonuses + 20
    elseif transactionCount >= 100 then
        bonuses = bonuses + 15
    elseif transactionCount >= 50 then
        bonuses = bonuses + 10
    elseif transactionCount >= 20 then
        bonuses = bonuses + 5
    elseif transactionCount < 5 then
        penalties = penalties + 10
    end
    
    -- Calculate final score
    local finalScore = baseScore + bonuses - penalties
    
    -- Ensure score stays within realistic bounds
    finalScore = math.max(300, math.min(850, finalScore))
    
    -- Add some randomness for realism (-5 to +5)
    local variance = math.random(-5, 5)
    finalScore = math.max(300, math.min(850, finalScore + variance))
    
    return finalScore
end

function UpdatePlayerCreditScore(citizenid)
    local newScore = CalculateCreditScore(citizenid)
    
    MySQL.update.await("UPDATE player_credit_scores SET credit_score = ? WHERE citizenid = ?", {
        newScore,
        citizenid
    })
    
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenid)
    if Player then
        TriggerClientEvent("nc-banking:client:updateCreditScore", Player.PlayerData.source, newScore)
    end
    
    return newScore
end

function GetCardStatus(citizenid, playerId)
    local hasCardInDB = HasBankCard(citizenid)
    local hasCardInInventory = HasPhysicalCardInInventory(playerId)
    local cardInfo = nil
    
    if hasCardInDB then
        cardInfo = GetCardInfo(citizenid)
    end
    
    return {
        hasCardInDB = hasCardInDB,
        hasCardInInventory = hasCardInInventory,
        cardInfo = cardInfo,
        isFirstTime = not hasCardInDB
    }
end

RegisterNetEvent("nc-banking:server:ATMCheckResult")
AddEventHandler("nc-banking:server:ATMCheckResult", function(result)
    local src = source
    playerNearATM[src] = result == true
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerNearATM[src] = nil
    PlayersCurrentBanks[src] = nil
end)

function CalculateDailySpending(citizenid)
    local dailySpending = {
        [0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0  -- Sun to Sat
    }
    
    -- Get transactions from the last 7 days
    local oneWeekAgo = os.date("!%Y-%m-%d 00:00:00", os.time() - (7 * 24 * 60 * 60))
    
    local result = MySQL.query.await([[
        SELECT amount, type, timestamp, DATE(timestamp) as transaction_date,
               DAYOFWEEK(timestamp) - 1 as day_of_week
        FROM banking_transactions 
        WHERE sender_name = ? 
        AND timestamp >= ?
        AND (society IS NULL OR society = '')
        ORDER BY timestamp DESC
    ]], {
        citizenid,
        oneWeekAgo
    })
    
    if result then
        for i = 1, #result do
            local amount = tonumber(result[i].amount) or 0
            local dayOfWeek = tonumber(result[i].day_of_week) or 0
            local transactionType = tonumber(result[i].type) or 0
            

                if transactionType == 1 then -- deposit
                    dailySpending[dayOfWeek] = dailySpending[dayOfWeek] + amount
                elseif transactionType == 2 then -- withdraw
                    dailySpending[dayOfWeek] = dailySpending[dayOfWeek] - math.abs(amount)
                elseif transactionType == 5 then -- transfer (outgoing)
                    dailySpending[dayOfWeek] = dailySpending[dayOfWeek] - math.abs(amount)
                end
            end
        end
    
    return dailySpending
end

QBCore.Functions.CreateCallback("nc-banking:server:retriveNessceryData", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    local personalTransactions = {}
    local societyTransactions = {}

    if Player.PlayerData.job.isboss then
        local result = MySQL.query.await("SELECT * FROM banking_transactions WHERE society = ? ORDER BY `id` DESC LIMIT 10000", {
            Player.PlayerData.job.name
        })

        if result and #result > 0 then
            for i = 1, #result do
                local txType = result[i].type
                local typeString
                if type(txType) == "number" then
                    local typeMap = {
                        [1] = "deposit",
                        [2] = "withdraw",
                        [3] = "society_deposit",
                        [4] = "society_withdraw",
                        [5] = "transfer",
                        [6] = "shared_deposit",
                        [7] = "shared_withdraw",
                        [8] = "shared_transfer"
                    }
                    typeString = typeMap[txType] or "unknown_" .. tostring(txType)
                else
                    typeString = Config.LogTypes[txType] or tostring(txType)
                end
                
                table.insert(societyTransactions, {
                    sender = result[i].sender_name,
                    receiver = result[i].receiver_name,
                    society = result[i].society,
                    amount = result[i].amount,
                    type = typeString,
                    note = result[i].note,
                    timestamp = result[i].timestamp,
                })
            end
        end
        
        TriggerClientEvent("nc-banking:client:updateSocietyTransactions", source, societyTransactions)
    end

    local result = MySQL.query.await("SELECT * FROM banking_transactions WHERE sender_name = ? AND (society IS NULL OR society = '') ORDER BY `id` DESC LIMIT 10000", {
        Player.PlayerData.citizenid
    })

    if result and #result > 0 then
        for i = 1, #result do
            local txType = result[i].type
            local typeString
            if type(txType) == "number" then
                local typeMap = {
                    [1] = "deposit",
                    [2] = "withdraw",
                    [3] = "society_deposit",
                    [4] = "society_withdraw",
                    [5] = "transfer",
                    [6] = "shared_deposit",
                    [7] = "shared_withdraw",
                    [8] = "shared_transfer"
                }
                typeString = typeMap[txType] or "unknown_" .. tostring(txType)
            else
                typeString = Config.LogTypes[txType] or tostring(txType)
            end
            
            table.insert(personalTransactions, {
                sender = result[i].sender_name,
                receiver = result[i].receiver_name,
                society = result[i].society,
                amount = result[i].amount,
                type = typeString,
                note = result[i].note,
                timestamp = result[i].timestamp,
            })
        end
    end

    local societyMoney = (Player.PlayerData.job.isboss and (SocietiesAccounts[Player.PlayerData.job.name] or 0) or nil)
    local dailySpending = CalculateDailySpending(Player.PlayerData.citizenid)
    local creditScore = GetPlayerCreditScore(Player.PlayerData.citizenid)
    
    if Config.SharedAccounts.EnableFeature then
        local sharedAccounts = GetPlayerSharedAccounts(Player.PlayerData.citizenid)
        cb(personalTransactions, societyMoney, sharedAccounts, dailySpending, creditScore)
    else
        cb(personalTransactions, societyMoney, nil, dailySpending, creditScore)
    end
end)


function RemoveSocietyMoney(societyName, amount)
    local societyAccount = SocietiesAccounts[societyName]

    if (societyAccount == nil) then
        MySQL.insert("INSERT INTO `society`(`name`, `money`) VALUES(?, ?)", {
            societyName,
            0
        })

        SocietiesAccounts[societyName] = 0;
        societyAccount = SocietiesAccounts[societyName]
    end

    if (societyAccount - amount < 0) then return false end
    SocietiesAccounts[societyName] = societyAccount - amount

    MySQL.update("UPDATE `society` SET `money` = ? WHERE `name` = ?", {
        SocietiesAccounts[societyName],
        societyName
    })

    return true
end

function AddSocietyMoney(societyName, amount)
    local societyAccount = SocietiesAccounts[societyName]

    if (societyAccount == nil) then
        MySQL.insert("INSERT INTO `society`(`name`, `money`) VALUES(?, ?)", {
            societyName,
            amount
        })

        SocietiesAccounts[societyName] = 0;
    end

    SocietiesAccounts[societyName] = SocietiesAccounts[societyName] + amount
    MySQL.update("UPDATE `society` SET `money` = ? WHERE `name` = ?", {
        SocietiesAccounts[societyName],
        societyName
    })

    return true
end

RegisterCommand("society", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
end)

-- Function to generate a random code
-- Function to generate a random code
local function GenerateRandomCode(length)
    local charset = "0123456789"
    local code = ""
    math.randomseed(os.time() + math.random(1, 100000))
    
    for i = 1, length do
        local rand = math.random(#charset)
        code = code .. string.sub(charset, rand, rand)
    end
    
    -- Ensure code isn't empty and has proper length
    if code == "" or #code ~= length then
        code = tostring(math.random(10^(length-1), 10^length - 1))
    end
    
    return code
end

-- Function to check if a code already exists
local function IsCodeUnique(code)
    local result = MySQL.query.await("SELECT COUNT(*) as count FROM shared_accounts WHERE code = ?", {code})
    return result[1].count == 0
end

-- Get a unique code
local function GetUniqueCode()
    local code
    local isUnique = false
    
    while not isUnique do
        code = GenerateRandomCode(Config.SharedAccounts.CodeLength)
        isUnique = IsCodeUnique(code)
    end
    
    return code
end

-- Function to get player's shared accounts
-- תיקון והוספת דיבאג לפונקציה GetPlayerSharedAccounts
function GetPlayerSharedAccounts(citizenid)
    local accounts = {}
    
    -- Debug info
    
    -- Get accounts where player is a member - שימוש בשאילתא פשוטה יותר
    local memberAccounts = MySQL.query.await([[
        SELECT sa.*, sam.permission_level
        FROM shared_accounts sa
        JOIN shared_account_members sam ON sa.id = sam.account_id
        WHERE sam.citizenid = ?
    ]], {citizenid})
    
    
    if memberAccounts and #memberAccounts > 0 then
        for _, account in ipairs(memberAccounts) do            
            -- Get member count for each account
            local memberCount = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ?", {account.id})
            
            -- Get pending request count for each account
            local pendingCount = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_requests WHERE account_id = ? AND status = 'pending'", {account.id})
            
            -- Check if player is owner
            local isOwner = account.owner_citizenid == citizenid
            
            table.insert(accounts, {
                id = account.id,
                name = account.name,
                code = account.code,
                balance = account.balance,
                memberCount = memberCount[1].count,
                pendingRequests = pendingCount[1].count,
                isOwner = isOwner,
                permissionLevel = account.permission_level
            })
        end
    end
    
    return accounts
end

-- תיקון הקולבק getSharedAccounts
QBCore.Functions.CreateCallback("nc-banking:server:getSharedAccounts", function(source, cb)
    if not Config.SharedAccounts.EnableFeature then
        cb({})
        return
    end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb({})
        return
    end
    
    -- Get direct database info for debugging
    local citizenid = Player.PlayerData.citizenid
    
    local directCheck = MySQL.query.await("SELECT * FROM shared_account_members WHERE citizenid = ?", {citizenid})
    if directCheck then
        for i, entry in ipairs(directCheck) do
        end
    end
    
    -- Get the accounts via the main function
    local accounts = GetPlayerSharedAccounts(citizenid)
    cb(accounts)
end)

-- Function to get pending requests for an account (alternative approach)
local function GetPendingRequests(accountId)
    local requests = {}
    
    -- Make sure we're only getting PENDING requests
    local result = MySQL.query.await([[
        SELECT sar.*, players.charinfo
        FROM shared_account_requests sar
        JOIN players ON players.citizenid = sar.citizenid
        WHERE sar.account_id = ? AND sar.status = 'pending'
    ]], {accountId})
    
    if result then
        for _, request in ipairs(result) do
            -- Parse charinfo JSON in Lua
            local charInfo = json.decode(request.charinfo)
            local fullname = "Unknown"
            
            if charInfo then
                fullname = (charInfo.firstname or "") .. " " .. (charInfo.lastname or "")
            end
            
            table.insert(requests, {
                id = request.id,
                accountId = request.account_id,
                citizenid = request.citizenid,
                fullname = fullname,
                requestedAt = request.requested_at
            })
        end
    end
    
    return requests
end


-- Function to get members of an account (alternative approach)
local function GetAccountMembers(accountId)
    local members = {}
    
    -- Fetch member data without JSON extraction
    local result = MySQL.query.await([[
        SELECT sam.*, players.charinfo 
        FROM shared_account_members sam
        JOIN players ON players.citizenid = sam.citizenid
        WHERE sam.account_id = ?
    ]], {accountId})
    
    if result then
        for _, member in ipairs(result) do
            -- Parse the JSON data in Lua instead of SQL
            local charInfo = json.decode(member.charinfo)
            local fullname = "Unknown"
            
            if charInfo then
                fullname = (charInfo.firstname or "") .. " " .. (charInfo.lastname or "")
            end
            
            table.insert(members, {
                id = member.id,
                accountId = member.account_id,
                citizenid = member.citizenid,
                fullname = fullname,
                permissionLevel = member.permission_level,
                joinedAt = member.joined_at
            })
        end
    end
    
    return members
end

-- Function to get shared account transactions
local function GetSharedAccountTransactions(accountId)
    local transactions = {}
    
    local result = MySQL.query.await([[
        SELECT * FROM banking_transactions 
        WHERE society = ?
        ORDER BY timestamp DESC LIMIT 15
    ]], {
        "shared_" .. accountId
    })
    
    if result then
        for _, tx in ipairs(result) do
            -- Fix type conversion
            local txType = tx.type
            local typeString

            -- Direct type conversion
            if type(txType) == "number" then
                -- Direct number-to-string mapping
                local typeMap = {
                    [1] = "deposit",
                    [2] = "withdraw",
                    [3] = "society_deposit",
                    [4] = "society_withdraw",
                    [5] = "transfer",
                    [6] = "shared_deposit",
                    [7] = "shared_withdraw",
                    [8] = "shared_transfer"
                }
                typeString = typeMap[txType] or "unknown_" .. tostring(txType)
            else
                -- Already a string, or other type
                typeString = Config.LogTypes[txType] or tostring(txType)
            end
            
            table.insert(transactions, {
                sender = tx.sender_name,
                receiver = tx.receiver_name,
                society = tx.society,
                amount = tx.amount,
                type = typeString, -- Use the converted type
                note = tx.note,
                timestamp = tx.timestamp,
            })
        end
    end
    
    return transactions
end

-- Function to update shared account for all online members
function UpdateSharedAccountForMembers(accountId, newBalance)
    -- Get all members of this account
    local members = MySQL.query.await("SELECT citizenid FROM shared_account_members WHERE account_id = ?", {accountId})
    
    if not members then return print("No members") end
    
    for _, member in ipairs(members) do
        local player = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
        
        if player then
            TriggerClientEvent("nc-banking:client:updateSharedAccountBalance", player.PlayerData.source, accountId, newBalance)
        end
    end
end

-- הוספת פונקציה זו לקובץ server/main.lua

-- פונקציה לעדכון כל השחקנים המקוונים שהם חברים בחשבון מסוים
-- Add this function to server/main.lua
function NotifyAccountMembersAboutUpdate(accountId, updateType, affectedCitizenId)
    -- Find all members of the account
    local members = MySQL.query.await("SELECT citizenid FROM shared_account_members WHERE account_id = ?", {accountId})
    
    if not members or #members == 0 then
        return
    end
    
    -- Get account info
    local accountInfo = MySQL.query.await("SELECT name FROM shared_accounts WHERE id = ?", {accountId})
    local accountName = accountInfo and accountInfo[1] and accountInfo[1].name or "Shared Account"
    
    -- Notify all online members
    for _, member in ipairs(members) do
        local player = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
        
        if player then
            -- Send notification
            if updateType == "new_member" and member.citizenid ~= affectedCitizenId then
                -- New member joined (to existing members)
                local newMemberInfo = QBCore.Functions.GetPlayerByCitizenId(affectedCitizenId)
                local name = "Someone"
                
                if newMemberInfo and newMemberInfo.PlayerData.charinfo then
                    name = newMemberInfo.PlayerData.charinfo.firstname .. " " .. newMemberInfo.PlayerData.charinfo.lastname
                end
                
                TriggerClientEvent('QBCore:Notify', player.PlayerData.source, name .. " has joined " .. accountName, "info")
            elseif updateType == "joined" and member.citizenid == affectedCitizenId then
                -- To player who joined
                TriggerClientEvent('QBCore:Notify', player.PlayerData.source, "You have been added to " .. accountName, "success")
            end
            
            -- Send event to refresh data on client side
            TriggerClientEvent("nc-banking:client:refreshSharedAccounts", player.PlayerData.source)
        end
    end
end

-- עדכון פונקציית respondJoinRequest לשלוח הודעה על עדכון
-- מצא את הקטע הזה אחרי שהמשתמש נוסף בהצלחה ולפני ה-cb האחרון:

-- If approved and member added successfully, notify all online members
-- If approved and member added successfully, notify all online members
if approve and result.success then
    -- Add this code
    local newMember = QBCore.Functions.GetPlayerByCitizenId(request.citizenid)
    
    -- Refresh for the new member
    if newMember then
        TriggerClientEvent("QBCore:Notify", newMember.PlayerData.source, "You have been added to a shared account!", "success")
        TriggerClientEvent("nc-banking:client:forceRefreshBanking", newMember.PlayerData.source)
    end
    
    -- Refresh for the approver
    TriggerClientEvent("QBCore:Notify", source, "Member added successfully", "success")
    TriggerClientEvent("nc-banking:client:forceRefreshBanking", source)
    
    -- Optional: Notify other members about the new addition
    local members = MySQL.query.await("SELECT citizenid FROM shared_account_members WHERE account_id = ? AND citizenid != ? AND citizenid != ?", {
        request.account_id,
        request.citizenid,
        Player.PlayerData.citizenid
    })
    
    if members then
        for _, member in ipairs(members) do
            local memberPlayer = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
            if memberPlayer then
                TriggerClientEvent("QBCore:Notify", memberPlayer.PlayerData.source, "A new member has joined your shared account", "info")
                TriggerClientEvent("nc-banking:client:refreshSharedAccounts", memberPlayer.PlayerData.source)
            end
        end
    end
end

QBCore.Functions.CreateCallback("nc-banking:server:getDailySpending", function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        cb({})
        return
    end
    
    local dailySpending = CalculateDailySpending(Player.PlayerData.citizenid)
    cb(dailySpending)
end)


-- CB to create a new shared account
QBCore.Functions.CreateCallback("nc-banking:server:createSharedAccount", function(source, cb, accountName)
    local src = source
    
    -- Check for duplicate operations
    if IsPlayerOnCooldown(src, "createAccount") then
        print("^3[COOLDOWN] Player " .. src .. " attempted duplicate create operation")
        cb(false, "Please wait before creating another account")
        return
    end
    
    if not Config.SharedAccounts.EnableFeature then
        cb(false, "This feature is disabled")
        return
    end
    
    if accountName == nil or accountName == "" then
        cb(false, "Invalid account name")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false, "Player not found")
        return
    end
    
    -- Check if player has enough money for creation fee
    if Player.PlayerData.money.bank < Config.SharedAccounts.CreationFee then
        cb(false, "You don't have enough money to create a shared account")
        return
    end
    
    -- Generate a unique code
    local code = GetUniqueCode()
    
    -- Create the account
    local result = MySQL.insert.await("INSERT INTO shared_accounts (name, code, owner_citizenid, balance) VALUES (?, ?, ?, ?)", {
        accountName,
        code,
        Player.PlayerData.citizenid,
        0
    })
    
    if not result then
        cb(false, "Failed to create shared account")
        return
    end
    
    -- Add the creator as a member with owner permissions
    MySQL.insert.await("INSERT INTO shared_account_members (account_id, citizenid, permission_level) VALUES (?, ?, ?)", {
        result,
        Player.PlayerData.citizenid,
        2 -- Owner level
    })
    
    -- Charge the creation fee
    if Config.SharedAccounts.CreationFee > 0 then
        Player.Functions.RemoveMoney("bank", Config.SharedAccounts.CreationFee)
    end
    
    print("^2[SUCCESS] Shared account created:", accountName, "by player:", src)
    
    -- Return account info
    cb(true, {
        id = result,
        name = accountName,
        code = code,
        balance = 0,
        memberCount = 1,
        pendingRequests = 0,
        isOwner = true,
        permissionLevel = 2
    })
end)


-- CB to get player's shared accounts
QBCore.Functions.CreateCallback("nc-banking:server:getSharedAccounts", function(source, cb)
    if not Config.SharedAccounts.EnableFeature then
        cb({})
        return
    end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb({})
        return
    end
    
    cb(GetPlayerSharedAccounts(Player.PlayerData.citizenid))
end)


QBCore.Functions.CreateCallback("nc-banking:server:requestJoinSharedAccount", function(source, cb, code)
    local src = source
    
    -- Check for duplicate operations
    if IsPlayerOnCooldown(src, "joinAccount") then
        print("^3[COOLDOWN] Player " .. src .. " attempted duplicate join operation")
        cb(false, "Please wait before sending another join request")
        return
    end
    
    if not Config.SharedAccounts.EnableFeature then
        cb(false, "This feature is disabled")
        return
    end
    
    if code == nil or code == "" then
        cb(false, "Invalid code")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false, "Player not found")
        return
    end
    
    -- Find the account with this code
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE code = ?", {code})
    
    if not account or #account == 0 then
        cb(false, "Invalid code. Account not found")
        return
    end
    
    account = account[1]
    
    -- Check if player is already a member
    local isMember = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        account.id,
        Player.PlayerData.citizenid
    })
    
    if isMember and isMember[1] and isMember[1].count > 0 then
        cb(false, "You are already a member of this account")
        return
    end
    
    -- Check if request exists regardless of status
    local existingRequest = MySQL.query.await("SELECT * FROM shared_account_requests WHERE account_id = ? AND citizenid = ?", {
        account.id,
        Player.PlayerData.citizenid
    })
    
    -- If request exists, update its status
    if existingRequest and #existingRequest > 0 then
        if existingRequest[1].status ~= 'pending' then
            MySQL.update.await("UPDATE shared_account_requests SET status = 'pending', updated_at = CURRENT_TIMESTAMP WHERE id = ?", {
                existingRequest[1].id
            })
            
            -- Notify the owner
            local owner = QBCore.Functions.GetPlayerByCitizenId(account.owner_citizenid)
            if owner then
                TriggerClientEvent('QBCore:Notify', owner.PlayerData.source, "You have a new join request for shared account: " .. account.name, "info")
            end
            
            cb(true, "Request renewed successfully")
        else
            cb(false, "You already have a pending request for this account")
        end
        return
    end
    
    -- Create a new request
    local success = pcall(function()
        MySQL.insert.await("INSERT INTO shared_account_requests (account_id, citizenid) VALUES (?, ?)", {
            account.id,
            Player.PlayerData.citizenid
        })
    end)
    
    if not success then
        cb(false, "Failed to create join request")
        return
    end
    
    -- Notify the owner
    local owner = QBCore.Functions.GetPlayerByCitizenId(account.owner_citizenid)
    if owner then
        TriggerClientEvent('QBCore:Notify', owner.PlayerData.source, "You have a new join request for shared account: " .. account.name, "info")
    end
    
    print("^2[SUCCESS] Join request created for account:", account.name, "by player:", src)
    
    cb(true, "Request sent successfully")
end)

-- CB to get pending requests for an account
QBCore.Functions.CreateCallback("nc-banking:server:getSharedAccountRequests", function(source, cb, accountId)
    if not Config.SharedAccounts.EnableFeature then
        cb({})
        return
    end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb({})
        return
    end
    
    -- Verify player is the owner or has permission
    local membership = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or #membership == 0 or membership[1].permission_level < 2 then
        cb({})
        return
    end
    
    cb(GetPendingRequests(accountId))
end)

-- CB to respond to a join request
QBCore.Functions.CreateCallback("nc-banking:server:respondJoinRequest", function(source, cb, data)
    
    if not data then
        cb(false, "Invalid request")
        return
    end
    
    local requestId = data.requestId
    local approve = data.approve
    
    
    if not Config.SharedAccounts.EnableFeature then
        cb(false, "This feature is disabled")
        return
    end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false, "Player not found")
        return
    end
    
    -- Get the request with error handling
    local request = nil
    local success = pcall(function()
        local result = MySQL.query.await("SELECT * FROM shared_account_requests WHERE id = ?", {requestId})
        if result and #result > 0 then
            request = result[1]
        else
        end
    end)
    
    if not success or not request then
        cb(false, "Request not found")
        return
    end
    
    -- Check if request is still pending
    if request.status ~= "pending" then
        cb(false, "This request has already been processed")
        return
    end
    
    -- Verify player is the owner or has permission
    local hasPermission = false
    local memberPermission = 0
    
    success = pcall(function()
        local result = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
            request.account_id,
            Player.PlayerData.citizenid
        })
        
        if result and #result > 0 then
            hasPermission = true
            memberPermission = result[1].permission_level
        else
        end
    end)
    
    if not success or not hasPermission or memberPermission < 2 then
        cb(false, "You don't have permission to do this")
        return
    end
    
    -- Check member count if approving
    if approve then
        local memberCount = 0
        success = pcall(function()
            local result = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ?", {request.account_id})
            if result and #result > 0 then
                memberCount = result[1].count
            end
        end)
        
        if not success then
            cb(false, "Failed to get member count")
            return
        end
        
        if memberCount >= Config.SharedAccounts.MaxMembersPerAccount then
            cb(false, "This account has reached the maximum number of members")
            return
        end
    end
    
    -- Update the request status
    local status = approve and "approved" or "denied"
    success = pcall(function()
        MySQL.update.await("UPDATE shared_account_requests SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?", {
            status,
            requestId
        })
    end)
    
    if not success then
        cb(false, "Failed to update request status")
        return
    end
    
    -- If approved, add the player as a member
    local memberAdded = false
    if approve then
        success = pcall(function()
            -- Check if already a member
            local existingMember = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
                request.account_id,
                request.citizenid
            })
            
            
            if not existingMember or #existingMember == 0 then
                -- Add as new member
                local insertId = MySQL.insert.await("INSERT INTO shared_account_members (account_id, citizenid, permission_level) VALUES (?, ?, ?)", {
                    request.account_id,
                    request.citizenid,
                    1 -- Regular member
                })
                
                memberAdded = true
            else
                memberAdded = true
            end
        end)
        
        if not success then
            cb(false, "Failed to add member")
            return
        end
    end
    
    -- Notify the requester
    local requester = QBCore.Functions.GetPlayerByCitizenId(request.citizenid)
    if requester then
        -- Get account name
        local accountName = "Shared Account"
        success = pcall(function()
            local account = MySQL.query.await("SELECT name FROM shared_accounts WHERE id = ?", {request.account_id})
            if account and #account > 0 then
                accountName = account[1].name
            end
        end)
        
        if approve then
            TriggerClientEvent('QBCore:Notify', requester.PlayerData.source, "Your request to join " .. accountName .. " has been approved!", "success")
        else
            TriggerClientEvent('QBCore:Notify', requester.PlayerData.source, "Your request to join " .. accountName .. " has been denied", "error")
        end
    end
        
    -- Return more comprehensive data for the UI update
    if approve then
        cb(true, {
            message = "Request " .. status .. " successfully",
            requestId = requestId,
            citizenid = request.citizenid,
            accountId = request.account_id,
            memberAdded = memberAdded
        })
    else
        cb(true, {
            message = "Request " .. status .. " successfully",
            requestId = requestId
        })
    end
end)

-- CB to get account members
QBCore.Functions.CreateCallback("nc-banking:server:getSharedAccountMembers", function(source, cb, accountId)
    if not Config.SharedAccounts.EnableFeature then
        cb({})
        return
    end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb({})
        return
    end
    
    -- Verify player is a member
    local membership = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or membership[1].count == 0 then
        cb({})
        return
    end
    
    cb(GetAccountMembers(accountId))
end)

RegisterNetEvent("nc-banking:server:removeSharedAccountMember", function(accountId, memberId)
    local src = source
    print("^2[DEBUG] removeSharedAccountMember event called")
    
    if not IsPlayerNearABank(src) then return end
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verify player is the owner or has permission
    local membership = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or #membership == 0 or membership[1].permission_level < 2 then
        TriggerClientEvent('QBCore:Notify', src, "You don't have permission to do this", "error")
        return
    end
    
    -- Get the member to be removed
    local member = MySQL.query.await("SELECT * FROM shared_account_members WHERE id = ?", {memberId})
    
    if not member or #member == 0 then
        TriggerClientEvent('QBCore:Notify', src, "Member not found", "error")
        return
    end
    
    member = member[1]
    
    -- Cannot remove the owner
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ?", {accountId})
    
    if not account or #account == 0 then
        TriggerClientEvent('QBCore:Notify', src, "Account not found", "error")
        return
    end
    
    if account[1].owner_citizenid == member.citizenid then
        TriggerClientEvent('QBCore:Notify', src, "Cannot remove the account owner", "error")
        return
    end
    
    -- Remove the member
    local removeResult = MySQL.query.await("DELETE FROM shared_account_members WHERE id = ?", {memberId})
    
    if removeResult then
        print("^2[SUCCESS] Member removed successfully")
        
        -- Notify the member if they're online
        local removedPlayer = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
        if removedPlayer then
            TriggerClientEvent('QBCore:Notify', removedPlayer.PlayerData.source, "You have been removed from a shared account", "error")
            TriggerClientEvent("nc-banking:client:refreshSharedAccounts", removedPlayer.PlayerData.source)
        end
        
        TriggerClientEvent('QBCore:Notify', src, "Member removed successfully", "success")
    else
        print("^1[ERROR] Failed to remove member")
        TriggerClientEvent('QBCore:Notify', src, "Failed to remove member", "error")
    end
end)

-- CB to remove a member
QBCore.Functions.CreateCallback("nc-banking:server:removeSharedAccountMember", function(source, cb, accountId, memberId)
    if not Config.SharedAccounts.EnableFeature then
        cb(false, "This feature is disabled")
        return
    end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(false, "Player not found")
        return
    end
    
    -- Verify player is the owner or has permission
    local membership = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or #membership == 0 or membership[1].permission_level < 2 then
        cb(false, "You don't have permission to do this")
        return
    end
    
    -- Get the member to be removed
    local member = MySQL.query.await("SELECT * FROM shared_account_members WHERE id = ?", {memberId})
    
    if not member or #member == 0 then
        cb(false, "Member not found")
        return
    end
    
    member = member[1]
    
    -- Cannot remove the owner
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ?", {accountId})
    
    if not account or #account == 0 then
        cb(false, "Account not found")
        return
    end
    
    if account[1].owner_citizenid == member.citizenid then
        cb(false, "Cannot remove the account owner")
        return
    end
    
    -- Remove the member
    MySQL.query.await("DELETE FROM shared_account_members WHERE id = ?", {memberId})
    
    -- Notify the removed member
    local removedPlayer = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
    if removedPlayer then
        TriggerClientEvent('QBCore:Notify', removedPlayer.PlayerData.source, "You have been removed from a shared account", "error")
    end
    
    cb(true, "Member removed successfully")
end)

-- CB to get specific shared account details
QBCore.Functions.CreateCallback("nc-banking:server:getSharedAccountDetails", function(source, cb, accountId)
    if not Config.SharedAccounts.EnableFeature then
        cb(nil)
        return
    end
    
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then
        cb(nil)
        return
    end
    
    -- Verify player is a member
    local membership = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or #membership == 0 then
        cb(nil)
        return
    end
    
    -- Get account details
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ?", {accountId})
    
    if not account or #account == 0 then
        cb(nil)
        return
    end
    
    account = account[1]
    
    -- Get members count
    local memberCount = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ?", {accountId})
    
    -- Get pending requests count
    local pendingCount = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_requests WHERE account_id = ? AND status = 'pending'", {accountId})
    
    -- Check if player is owner
    local isOwner = account.owner_citizenid == Player.PlayerData.citizenid
    
    -- Get account transactions with proper type conversion
    local transactions = GetSharedAccountTransactions(accountId)

    cb({
        id = account.id,
        name = account.name,
        code = account.code,
        balance = account.balance,
        memberCount = memberCount[1].count,
        pendingRequests = pendingCount[1].count,
        isOwner = isOwner,
        permissionLevel = membership[1].permission_level,
        transactions = transactions
    })
end)

RegisterNetEvent("nc-banking:server:deleteSharedAccount", function(accountId)
    local src = source
    
    -- Check for duplicate operations
    if IsPlayerOnCooldown(src, "deleteAccount") then
        print("^3[COOLDOWN] Player " .. src .. " attempted duplicate delete operation")
        return
    end
    
    print("^2[DEBUG] deleteSharedAccount event called by player:", src, "for accountId:", accountId)
    
    if not accountId then
        print("^1[ERROR] No accountId received")
        TriggerClientEvent('QBCore:Notify', src, "Invalid account ID", "error")
        return
    end
    
    if not IsPlayerNearABank(src) then 
        print("^1[ERROR] Player not near bank")
        TriggerClientEvent('QBCore:Notify', src, "You must be at a bank to delete an account", "error")
        return 
    end
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then 
        print("^1[ERROR] Player object not found")
        return 
    end
    
    -- Verify player is the owner
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ? AND owner_citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not account or #account == 0 then
        print("^1[ERROR] Player is not owner or account doesn't exist")
        TriggerClientEvent('QBCore:Notify', src, "You are not the owner of this account", "error")
        return
    end
    
    account = account[1]
    print("^3[DEBUG] Account found:", account.name, "Balance:", account.balance)
    
    -- Get all members to notify them
    local members = MySQL.query.await("SELECT citizenid FROM shared_account_members WHERE account_id = ? AND citizenid != ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    -- Return any remaining balance to the owner
    if account.balance > 0 then
        Player.Functions.AddMoney("bank", account.balance)
        print("^3[DEBUG] Returned balance of", account.balance, "to owner")
        TriggerClientEvent('QBCore:Notify', src, "Remaining balance of $" .. account.balance .. " has been transferred to your account", "info")
    end
    
    -- Delete the account
    local deleteResult = MySQL.query.await("DELETE FROM shared_accounts WHERE id = ?", {accountId})
    
    if deleteResult then
        print("^2[SUCCESS] Account deleted successfully")
        
        -- Notify the owner
        TriggerClientEvent('QBCore:Notify', src, "Shared account '" .. account.name .. "' has been deleted", "success")
        
        -- Notify other members
        if members then
            for _, member in ipairs(members) do
                local memberPlayer = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
                
                if memberPlayer then
                    print("^3[DEBUG] Notifying member:", member.citizenid)
                    TriggerClientEvent('QBCore:Notify', memberPlayer.PlayerData.source, "Shared account '" .. account.name .. "' has been deleted by the owner", "error")
                    TriggerClientEvent("nc-banking:client:refreshSharedAccounts", memberPlayer.PlayerData.source)
                end
            end
        end
        
        -- Force refresh for the owner
        TriggerClientEvent("nc-banking:client:refreshSharedAccounts", src)
    else
        print("^1[ERROR] Failed to delete account from database")
        TriggerClientEvent('QBCore:Notify', src, "Failed to delete account", "error")
    end
end)

-- Function to change shared account name (owners only)
RegisterNetEvent("nc-banking:server:renameSharedAccount", function(accountId, newName)
    local src = source
    if not IsPlayerNearABank(src) then return end
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    if not newName or newName == "" then
        TriggerClientEvent('QBCore:Notify', src, "Invalid account name", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verify player is the owner
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ? AND owner_citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not account or #account == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not the owner of this account", "error")
        return
    end
    
    -- Update account name
    MySQL.update.await("UPDATE shared_accounts SET name = ? WHERE id = ?", {
        newName,
        accountId
    })
    
    -- Notify the owner
    TriggerClientEvent('QBCore:Notify', src, "Account renamed to '" .. newName .. "'", "success")
    
    -- Get all members to notify them
    local members = MySQL.query.await("SELECT citizenid FROM shared_account_members WHERE account_id = ? AND citizenid != ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if members then
        for _, member in ipairs(members) do
            local memberPlayer = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
            
            if memberPlayer then
                TriggerClientEvent('QBCore:Notify', memberPlayer.PlayerData.source, "Shared account has been renamed to '" .. newName .. "'", "info")
            end
        end
    end
end)

-- Function to change member permissions
RegisterNetEvent("nc-banking:server:changeSharedAccountPermission", function(accountId, memberId, newPermission)
    local src = source
    if not IsPlayerNearABank(src) then return end
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    if not memberId or not newPermission or newPermission < 1 or newPermission > 2 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid permission level", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verify player is the owner
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ? AND owner_citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not account or #account == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not the owner of this account", "error")
        return
    end
    
    -- Get the member
    local member = MySQL.query.await("SELECT * FROM shared_account_members WHERE id = ? AND account_id = ?", {
        memberId,
        accountId
    })
    
    if not member or #member == 0 then
        TriggerClientEvent('QBCore:Notify', src, "Member not found", "error")
        return
    end
    
    member = member[1]
    
    -- Cannot change owner's permission
    if member.citizenid == account[1].owner_citizenid then
        TriggerClientEvent('QBCore:Notify', src, "Cannot change the owner's permission", "error")
        return
    end
    
    -- Update permission
    MySQL.update.await("UPDATE shared_account_members SET permission_level = ? WHERE id = ?", {
        newPermission,
        memberId
    })
    
    -- Notify the owner
    TriggerClientEvent('QBCore:Notify', src, "Permission updated successfully", "success")
    
    -- Notify the member
    local memberPlayer = QBCore.Functions.GetPlayerByCitizenId(member.citizenid)
    
    if memberPlayer then
        local permissionName = newPermission == 2 and "Manager" or "Member"
        TriggerClientEvent('QBCore:Notify', memberPlayer.PlayerData.source, "Your permission in a shared account has been updated to " .. permissionName, "info")
    end
end)

-- Function to leave a shared account
RegisterNetEvent("nc-banking:server:leaveSharedAccount", function(accountId)
    local src = source
    print("^2[DEBUG] leaveSharedAccount event called by player:", src, "for accountId:", accountId)
    
    if not IsPlayerNearABank(src) then 
        TriggerClientEvent('QBCore:Notify', src, "You must be at a bank to leave an account", "error")
        return 
    end
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Get account details
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ?", {accountId})
    
    if not account or #account == 0 then
        TriggerClientEvent('QBCore:Notify', src, "Account not found", "error")
        return
    end
    
    account = account[1]
    
    -- Cannot leave if you're the owner
    if account.owner_citizenid == Player.PlayerData.citizenid then
        TriggerClientEvent('QBCore:Notify', src, "As the owner, you cannot leave. You must delete the account instead.", "error")
        return
    end
    
    -- Verify player is a member
    local membership = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or #membership == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not a member of this account", "error")
        return
    end
    
    -- Remove the player from members
    local leaveResult = MySQL.query.await("DELETE FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if leaveResult then
        print("^2[SUCCESS] Player left account successfully")
        
        -- Notify the player
        TriggerClientEvent('QBCore:Notify', src, "You have left the shared account '" .. account.name .. "'", "success")
        
        -- Notify the owner
        local owner = QBCore.Functions.GetPlayerByCitizenId(account.owner_citizenid)
        
        if owner then
            TriggerClientEvent('QBCore:Notify', owner.PlayerData.source, Player.PlayerData.charinfo.firstname .. " has left your shared account '" .. account.name .. "'", "info")
        end
        
        -- Refresh shared accounts for the player
        TriggerClientEvent("nc-banking:client:refreshSharedAccounts", src)
    else
        print("^1[ERROR] Failed to remove player from account")
        TriggerClientEvent('QBCore:Notify', src, "Failed to leave account", "error")
    end
end)


-- Function to generate a new code (if the old one is compromised)
RegisterNetEvent("nc-banking:server:regenerateSharedAccountCode", function(accountId)
    local src = source
    if not IsPlayerNearABank(src) then return end
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verify player is the owner
    local account = MySQL.query.await("SELECT * FROM shared_accounts WHERE id = ? AND owner_citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not account or #account == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not the owner of this account", "error")
        return
    end
    
    -- Generate a new code
    local newCode = GetUniqueCode()
    
    -- Update the code
    MySQL.update.await("UPDATE shared_accounts SET code = ? WHERE id = ?", {
        newCode,
        accountId
    })
    
    -- Notify the owner
    TriggerClientEvent('QBCore:Notify', src, "New account code generated: " .. newCode, "success")
    
    -- Return the new code
    TriggerClientEvent("nc-banking:client:sharedAccountCodeUpdated", src, accountId, newCode)
end)

RegisterNetEvent("nc-banking:server:updateCreditScore", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player then
        UpdatePlayerCreditScore(Player.PlayerData.citizenid)
    end
end)

RegisterNetEvent("nc-banking:server:respondToRequest", function(data)
    local src = source
    local requestId = data.requestId
    local approve = data.approve
    
    -- Check for duplicate operations
    if IsPlayerOnCooldown(src, "respondRequest_" .. requestId) then
        print("^3[COOLDOWN] Player " .. src .. " attempted duplicate respond operation for request:", requestId)
        return
    end
    
    print("^2[DEBUG] Responding to request:", requestId, "approve:", approve)
    
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        TriggerClientEvent("QBCore:Notify", src, "Player not found", "error")
        return
    end
    
    -- Get the request
    local request = MySQL.query.await("SELECT * FROM shared_account_requests WHERE id = ?", {requestId})
    
    if not request or #request == 0 then
        TriggerClientEvent("QBCore:Notify", src, "Request not found", "error")
        return
    end
    
    request = request[1]
    
    -- Check if request is still pending
    if request.status ~= "pending" then
        TriggerClientEvent("QBCore:Notify", src, "This request has already been processed", "error")
        return
    end
    
    -- Verify player has permission
    local membership = MySQL.query.await("SELECT * FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        request.account_id,
        Player.PlayerData.citizenid
    })
    
    if not membership or #membership == 0 or membership[1].permission_level < 2 then
        TriggerClientEvent("QBCore:Notify", src, "You don't have permission to do this", "error")
        return
    end
    
    -- Update the request status
    local status = approve and "approved" or "denied"
    MySQL.update.await("UPDATE shared_account_requests SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?", {
        status,
        requestId
    })
    
    -- If approved, add the player as a member
    if approve then
        local success = pcall(function()
            MySQL.insert.await("INSERT IGNORE INTO shared_account_members (account_id, citizenid, permission_level) VALUES (?, ?, ?)", {
                request.account_id,
                request.citizenid,
                1 -- Regular member
            })
        end)
        
        if not success then
            TriggerClientEvent("QBCore:Notify", src, "Failed to add member to database", "error")
            return
        end
        
        -- Notify the requester if online
        local requester = QBCore.Functions.GetPlayerByCitizenId(request.citizenid)
        if requester then
            TriggerClientEvent("QBCore:Notify", requester.PlayerData.source, "Your join request has been approved", "success")
            TriggerClientEvent("nc-banking:client:refreshSharedAccounts", requester.PlayerData.source)
        end
        
        TriggerClientEvent("QBCore:Notify", src, "Request approved successfully", "success")
    else
        TriggerClientEvent("QBCore:Notify", src, "Request denied", "info")
    end
    
    -- Send update signal
    TriggerClientEvent("nc-banking:client:updateRequests", src, request.account_id, requestId)
    
    print("^2[SUCCESS] Request", requestId, "processed successfully")
end)

exports('GetPlayerCreditScore', function(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if not Player then return 0 end
    
    return GetPlayerCreditScore(Player.PlayerData.citizenid)
end)

exports('GetCreditScoreByCitizenId', function(citizenid)
    return GetPlayerCreditScore(citizenid)
end)

-- Card Management Functions
function HashPin(pin)
    local hash = tostring(GetHashKey(pin .. "banking_salt_2024"))
    return hash
end


function HasBankCard(citizenid)
    local result = MySQL.query.await("SELECT COUNT(*) as count FROM player_bank_cards WHERE citizenid = ? AND status = 'active'", {citizenid})
    return result and result[1] and result[1].count > 0
end

function GetCardInfo(citizenid)
    local result = MySQL.query.await("SELECT * FROM player_bank_cards WHERE citizenid = ? AND status = 'active'", {citizenid})
    return result and result[1] or nil
end
function CreateBankCard(citizenid, pin)
    local pinHash = HashPin(pin)
    
    if HasBankCard(citizenid) then
        return false, "You already have an active bank card"
    end
    
    local success = pcall(function()
        MySQL.insert.await("INSERT INTO player_bank_cards (citizenid, pin_hash) VALUES (?, ?)", {
            citizenid,
            pinHash
        })
    end)
    
    return success, success and "Bank card created successfully" or "Failed to create bank card"
end

function UpdateCardPin(citizenid, newPin)
    if not HasBankCard(citizenid) then
        return false, "No active bank card found"
    end
    
    local pinHash = HashPin(newPin)
    
    local success = pcall(function()
        MySQL.update.await("UPDATE player_bank_cards SET pin_hash = ? WHERE citizenid = ? AND status = 'active'", {
            pinHash,
            citizenid
        })
    end)
    
    return success, success and "PIN updated successfully" or "Failed to update PIN"
end

function VerifyCardPin(citizenid, pin)
    local cardInfo = GetCardInfo(citizenid)
    if not cardInfo then
        return false, "No active bank card found"
    end
    
    -- Check if card is blocked
    if cardInfo.blocked_until and cardInfo.blocked_until > os.date("!%Y-%m-%d %H:%M:%S") then
        return false, "Card is temporarily blocked. Try again later."
    end
    
    local pinHash = HashPin(pin)
    
    if cardInfo.pin_hash == pinHash then
        -- Reset failed attempts on successful verification
        MySQL.update.await("UPDATE player_bank_cards SET failed_attempts = 0, last_used = CURRENT_TIMESTAMP, blocked_until = NULL WHERE citizenid = ?", {citizenid})
        return true, "PIN verified successfully"
    else
        local newFailedAttempts = (cardInfo.failed_attempts or 0) + 1
        
        if newFailedAttempts >= 3 then
            local blockUntil = os.date("!%Y-%m-%d %H:%M:%S", os.time() + (15 * 60))
            MySQL.update.await("UPDATE player_bank_cards SET failed_attempts = ?, blocked_until = ? WHERE citizenid = ?", {
                newFailedAttempts,
                blockUntil,
                citizenid
            })
            return false, "Too many failed attempts. Card blocked for 15 minutes."
        else
            MySQL.update.await("UPDATE player_bank_cards SET failed_attempts = ? WHERE citizenid = ?", {
                newFailedAttempts,
                citizenid
            })
            return false, string.format("Incorrect PIN. %d attempts remaining.", 3 - newFailedAttempts)
        end
    end
end