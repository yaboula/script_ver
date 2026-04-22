QBCore = exports["qb-core"]:GetCoreObject()

RegisterNetEvent("nc-banking:server:setCurrentBank", function(bankId)
    local src = source;
    PlayersCurrentBanks[src] = bankId
end)

RegisterNetEvent("nc-banking:server:depositMoney", function(money, note)
    local src = source
    local amount = tonumber(money)

    if(not IsPlayerNearABank(src)) then return end
    if(amount == nil or amount <= 0) then return end

    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.money.cash < amount then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough cash to deposit", "error")
        return
    end

    if(Player.Functions.RemoveMoney("cash", amount)) then
        Player.Functions.AddMoney("bank", amount)
        TriggerClientEvent("nc-banking:client:updateBalance", src, Player.PlayerData.money.bank)
        
        -- Use the note parameter, default to "None" if not provided
        LogTransaction(src, Player.PlayerData.citizenid, nil, nil, amount, "deposit", note or "None")
        
        -- Wait for DB to update, then recalculate and send spending data
        Wait(500)
        local dailySpending = CalculateDailySpending(Player.PlayerData.citizenid)
        TriggerClientEvent("nc-banking:client:updateDailySpending", src, dailySpending)
    end
end)

RegisterNetEvent("nc-banking:server:withdrawMoney", function(money, note)
    local src = source
    local amount = tonumber(money)

    if(not IsPlayerNearABank(src)) then return end
    if(amount == nil or amount <= 0) then return end

    local Player = QBCore.Functions.GetPlayer(src)
    
    if Player.PlayerData.money.bank < amount then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough money in your account", "error")
        return
    end

    if(Player.Functions.RemoveMoney("bank", amount)) then
        Player.Functions.AddMoney("cash", amount)
        TriggerClientEvent("nc-banking:client:updateBalance", src, Player.PlayerData.money.bank)
        
        -- Use the note parameter, default to "None" if not provided
        LogTransaction(src, Player.PlayerData.citizenid, nil, nil, amount, "withdraw", note or "None")
        
        -- Wait for DB to update, then recalculate and send spending data
        Wait(500)
        local dailySpending = CalculateDailySpending(Player.PlayerData.citizenid)
        TriggerClientEvent("nc-banking:client:updateDailySpending", src, dailySpending)
    end
end)

RegisterNetEvent("nc-banking:server:societyDeposit", function(money, note)
    local src = source
    local amount = tonumber(money)

    if(not IsPlayerNearABank(src)) then return end
    if(amount == nil or amount < 1) then return end

    local Player = QBCore.Functions.GetPlayer(src)
    local playerJob = Player.PlayerData.job.name
    
    if Player.PlayerData.money.cash < amount then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough cash to deposit", "error")
        return
    end

    if(Player.Functions.RemoveMoney("cash", amount)) then
        AddSocietyMoney(playerJob, amount)
        TriggerClientEvent("nc-banking:client:updateSocietyBalance", src, SocietiesAccounts[playerJob])
        LogTransaction(src, Player.PlayerData.citizenid, nil, playerJob, amount, "society_deposit", note)
        
        -- Update spending chart
        Wait(500)
        local dailySpending = CalculateDailySpending(Player.PlayerData.citizenid)
        TriggerClientEvent("nc-banking:client:updateDailySpending", src, dailySpending)
    end
end)

RegisterNetEvent("nc-banking:server:societyWithdraw", function(money, note)
    local src = source
    local amount = tonumber(money)

    if(not IsPlayerNearABank(src)) then return end
    if(amount == nil or amount < 1) then return end

    local Player = QBCore.Functions.GetPlayer(src)
    local playerJob = Player.PlayerData.job.name
    
    if not SocietiesAccounts[playerJob] or SocietiesAccounts[playerJob] < amount then
        TriggerClientEvent('QBCore:Notify', src, "The society account doesn't have enough funds", "error")
        return
    end

    if(RemoveSocietyMoney(playerJob, amount)) then
        Player.Functions.AddMoney("cash", amount)
        TriggerClientEvent("nc-banking:client:updateSocietyBalance", src, SocietiesAccounts[playerJob])
        
        LogTransaction(src, Player.PlayerData.citizenid, nil, playerJob, -amount, "society_withdraw", note or "Withdrawal from society")
        
        -- Update spending chart
        Wait(500)
        local dailySpending = CalculateDailySpending(Player.PlayerData.citizenid)
        TriggerClientEvent("nc-banking:client:updateDailySpending", src, dailySpending)
    end
end)

RegisterNetEvent("nc-banking:server:sharedAccountDeposit", function(accountId, amount, note)
    local src = source
    if not IsPlayerNearABank(src) then return end
    amount = tonumber(amount)
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    if not accountId or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid amount", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verify player is a member
    local membership = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or membership[1].count == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not a member of this account", "error")
        return
    end
    
    -- Add cash check
    if Player.PlayerData.money.cash < amount then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough cash to deposit", "error")
        return
    end
    
    -- Remove money from player
    Player.Functions.RemoveMoney("cash", amount)
    
    -- Add money to shared account
    MySQL.update.await("UPDATE shared_accounts SET balance = balance + ? WHERE id = ?", {
        amount,
        accountId
    })
    
    -- Get updated balance
    local account = MySQL.query.await("SELECT balance FROM shared_accounts WHERE id = ?", {accountId})
    
    if account and #account > 0 then
        -- Log transaction with the correct type
        LogTransaction(
            src, 
            Player.PlayerData.citizenid, 
            nil, 
            "shared_" .. accountId, 
            amount, 
            "shared_deposit", 
            note or "Deposit to shared account"
        )
        
        -- Update all online members with new balance
        UpdateSharedAccountForMembers(accountId, account[1].balance)
        
        -- Get fresh transactions and update client
        local transactions = GetSharedAccountTransactions(accountId)
        TriggerClientEvent("nc-banking:client:updateSharedAccountTransactions", src, transactions)
        
        TriggerClientEvent('QBCore:Notify', src, "Successfully deposited $" .. amount .. " to shared account", "success")
        TriggerClientEvent("nc-banking:client:updateDailySpending", src, senderDailySpending)
    end
end)

RegisterNetEvent("nc-banking:server:sharedAccountWithdraw", function(accountId, amount, note)
    local src = source
    if not IsPlayerNearABank(src) then return end
    amount = tonumber(amount)
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    if not accountId or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid amount", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    -- Verify player is a member
    local membership = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or membership[1].count == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not a member of this account", "error")
        return
    end
    
    -- Check if account has enough money
    local account = MySQL.query.await("SELECT balance FROM shared_accounts WHERE id = ?", {accountId})
    
    if not account or #account == 0 or account[1].balance < amount then
        TriggerClientEvent('QBCore:Notify', src, "The account doesn't have enough funds", "error")
        return
    end
    
    -- Remove money from shared account
    MySQL.update.await("UPDATE shared_accounts SET balance = balance - ? WHERE id = ?", {
        amount,
        accountId
    })
    
    -- Add money to player
    Player.Functions.AddMoney("cash", amount)
    
    -- Get updated balance
    account = MySQL.query.await("SELECT balance FROM shared_accounts WHERE id = ?", {accountId})
    
    if account and #account > 0 then
        -- Log transaction with the correct type
        LogTransaction(
            src, 
            Player.PlayerData.citizenid, 
            nil, 
            "shared_" .. accountId, 
            -amount, 
            "shared_withdraw", 
            note or "Withdrawal from shared account"
        )
        
        -- Update all online members with new balance
        UpdateSharedAccountForMembers(accountId, account[1].balance)
        
        -- Get fresh transactions and update client
        local transactions = GetSharedAccountTransactions(accountId)
        TriggerClientEvent("nc-banking:client:updateSharedAccountTransactions", src, transactions)
        
        TriggerClientEvent('QBCore:Notify', src, "Successfully withdrew $" .. amount .. " from shared account", "success")
    end
end)

RegisterNetEvent("nc-banking:server:sharedAccountTransfer", function(accountId, targetId, amount, note)
    local src = source
    if not IsPlayerNearABank(src) then return end
    amount = tonumber(amount)
    targetId = tonumber(targetId)
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    if not accountId or not targetId or targetId < 1 or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid amount or target", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not Target then
        TriggerClientEvent('QBCore:Notify', src, "Player not found", "error")
        return
    end
    
    -- Verify player is a member
    local membership = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or membership[1].count == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not a member of this account", "error")
        return
    end
    
    -- Check if account has enough money
    local account = MySQL.query.await("SELECT balance FROM shared_accounts WHERE id = ?", {accountId})
    
    if not account or #account == 0 or account[1].balance < amount then
        TriggerClientEvent('QBCore:Notify', src, "The account doesn't have enough funds", "error")
        return
    end
    
    -- Remove money from shared account
    MySQL.update.await("UPDATE shared_accounts SET balance = balance - ? WHERE id = ?", {
        amount,
        accountId
    })
    
    -- Add money to target player's bank account
    Target.Functions.AddMoney("bank", amount)
    
    -- Get updated balance
    account = MySQL.query.await("SELECT balance FROM shared_accounts WHERE id = ?", {accountId})
    
    if account and #account > 0 then
        -- Log transaction
        LogTransaction(
            src, 
            Player.PlayerData.citizenid, 
            Target.PlayerData.citizenid, 
            "shared_" .. accountId, 
            -amount, 
            "shared_transfer", 
            note or "Transfer from shared account"
        )
        
        -- Update all online members
        UpdateSharedAccountForMembers(accountId, account[1].balance)
        
        -- Notify both players
        TriggerClientEvent('QBCore:Notify', src, "Successfully transferred $" .. amount .. " to " .. Target.PlayerData.charinfo.firstname, "success")
        TriggerClientEvent('QBCore:Notify', targetId, "You received $" .. amount .. " from a shared account", "success")
    end
end)

RegisterNetEvent("nc-banking:server:sharedAccountTransfer", function(accountId, targetId, amount, note)
    local src = source
    if not IsPlayerNearABank(src) then return end
    amount = tonumber(amount)
    targetId = tonumber(targetId)
    
    if not Config.SharedAccounts.EnableFeature then
        TriggerClientEvent('QBCore:Notify', src, "Shared accounts are disabled", "error")
        return
    end
    
    if not accountId or not targetId or targetId < 1 or not amount or amount <= 0 then
        TriggerClientEvent('QBCore:Notify', src, "Invalid amount or target", "error")
        return
    end
    
    local Player = QBCore.Functions.GetPlayer(src)
    local Target = QBCore.Functions.GetPlayer(targetId)
    
    if not Player or not Target then
        TriggerClientEvent('QBCore:Notify', src, "Player not found", "error")
        return
    end
    
    -- Verify player is a member
    local membership = MySQL.query.await("SELECT COUNT(*) as count FROM shared_account_members WHERE account_id = ? AND citizenid = ?", {
        accountId,
        Player.PlayerData.citizenid
    })
    
    if not membership or membership[1].count == 0 then
        TriggerClientEvent('QBCore:Notify', src, "You are not a member of this account", "error")
        return
    end
    
    -- Check if account has enough money
    local account = MySQL.query.await("SELECT balance FROM shared_accounts WHERE id = ?", {accountId})
    
    if not account or #account == 0 or account[1].balance < amount then
        TriggerClientEvent('QBCore:Notify', src, "The account doesn't have enough funds", "error")
        return
    end
    
    -- Remove money from shared account
    MySQL.update.await("UPDATE shared_accounts SET balance = balance - ? WHERE id = ?", {
        amount,
        accountId
    })
    
    -- Add money to target player's bank account
    Target.Functions.AddMoney("bank", amount)
    
    -- Get updated balance
    account = MySQL.query.await("SELECT balance FROM shared_accounts WHERE id = ?", {accountId})
    
    if account and #account > 0 then
        -- Log transaction
        LogTransaction(
            src, 
            Player.PlayerData.citizenid, 
            Target.PlayerData.citizenid, 
            "shared_" .. accountId, 
            -amount, 
            "shared_transfer", 
            note or "Transfer from shared account"
        )
        
        -- Update all online members
        UpdateSharedAccountForMembers(accountId, account[1].balance)
        
        -- Notify both players
        TriggerClientEvent('QBCore:Notify', src, "Successfully transferred $" .. amount .. " to " .. Target.PlayerData.charinfo.firstname, "success")
        TriggerClientEvent('QBCore:Notify', targetId, "You received $" .. amount .. " from a shared account", "success")
    end
end)

RegisterNetEvent("nc-banking:server:transferMoney", function (target, money)
    local senderId = source
    local targetId = target
    local amount = tonumber(money)
    local tId = tonumber(targetId)
    
    if amount == nil or amount <= 0 or not IsPlayerNearABank(senderId) or tId == nil or tId < 1 then
        return
    end

    local Sender = QBCore.Functions.GetPlayer(senderId)
    local Target = QBCore.Functions.GetPlayer(targetId)

    if(Target == nil) then
        return
    end

    if(Sender.Functions.RemoveMoney("bank", amount)) then
        Target.Functions.AddMoney("bank", amount)
        TriggerClientEvent("nc-banking:client:updateBalance", senderId, Sender.PlayerData.money.bank)
        TriggerClientEvent("nc-banking:client:updateBalance", targetId, Target.PlayerData.money.bank)

        LogTransaction(senderId, Sender.PlayerData.citizenid, Target.PlayerData.citizenid, nil, amount, "transfer", "None")
        
        -- Update spending chart for sender
        Wait(500)
        local dailySpending = CalculateDailySpending(Sender.PlayerData.citizenid)
        TriggerClientEvent("nc-banking:client:updateDailySpending", senderId, dailySpending)
    end
end)

function UpdatePersonalTransactions(playerId, Player)
    Wait(300)
    
    local personalTransactions = {} -- Always initialize
    
    local result = MySQL.query.await("SELECT * FROM banking_transactions WHERE sender_name = ? AND (society IS NULL OR society = '') ORDER BY `id` DESC LIMIT 10000", {
        Player.PlayerData.citizenid
    })

    if result and #result > 0 then
        for i = 1, #result do
            -- Direct mapping approach for type conversion
            local txType = result[i].type
            local typeString = txType
            
            if type(txType) == "number" then
                -- Use a specific mapping table instead of Config.LogTypes
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
            end
            
            personalTransactions[#personalTransactions + 1] = {
                sender = result[i].sender_name,
                receiver = result[i].receiver_name,
                society = result[i].society,
                amount = result[i].amount,
                type = typeString, -- Use our directly mapped string
                note = result[i].note,
                timestamp = result[i].timestamp,
            }
        end
    end
    
    -- Console log for debugging
    
    TriggerClientEvent("nc-banking:client:updateTransactions", playerId, personalTransactions)
end

RegisterNetEvent("nc-banking:server:requestPhysicalCard", function(pin, fee)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    fee = tonumber(fee) or 0
    if fee < 0 then return end

    if not IsPlayerNearABank(src) then 
        TriggerClientEvent('QBCore:Notify', src, "You must be at a bank to request a card", "error")
        return 
    end
    
    if Player.PlayerData.money.bank < fee then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough money in your account", "error")
        return
    end
    
    if not pin or string.len(pin) ~= 4 or not string.match(pin, "^%d+$") then
        TriggerClientEvent('QBCore:Notify', src, "Invalid PIN format", "error")
        return
    end
    
    local success, message = CreateBankCard(Player.PlayerData.citizenid, pin)
    
    if success then
        if fee > 0 then
            Player.Functions.RemoveMoney("bank", fee)
LogTransaction(src, Player.PlayerData.citizenid, nil, nil, fee, "withdraw", "Bank card issuance fee")
            TriggerClientEvent("nc-banking:client:subtractFromChart", src, fee)
        end
        
        Player.Functions.AddItem("bank_card", 1, false, {
            citizenid = Player.PlayerData.citizenid,
            issued_date = os.date("%Y-%m-%d"),
            card_holder = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        })
        
        local feeText = fee > 0 and " Fee: $" .. fee or " (Free for first card)"
        TriggerClientEvent('QBCore:Notify', src, "Bank card issued successfully!" .. feeText, "success")
        TriggerClientEvent("nc-banking:client:updateBalance", src, Player.PlayerData.money.bank)
        TriggerClientEvent("nc-banking:client:cardIssued", src)
    else
        TriggerClientEvent('QBCore:Notify', src, message, "error")
    end
end)

RegisterNetEvent("nc-banking:server:requestReplacementCard", function(pin, fee)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    fee = tonumber(fee) or 0
    if fee < 0 then return end

    if not IsPlayerNearABank(src) then 
        TriggerClientEvent('QBCore:Notify', src, "You must be at a bank to request a card", "error")
        return 
    end
    
    if Player.PlayerData.money.bank < fee then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough money in your account", "error")
        return
    end
    
    if not pin or string.len(pin) ~= 4 or not string.match(pin, "^%d+$") then
        TriggerClientEvent('QBCore:Notify', src, "Invalid PIN format", "error")
        return
    end
    
    local success, message = UpdateCardPin(Player.PlayerData.citizenid, pin)
    if success then
        Player.Functions.RemoveMoney("bank", fee)
        LogTransaction(src, Player.PlayerData.citizenid, nil, nil, fee, "withdraw", "Replacement bank card fee")
        TriggerClientEvent("nc-banking:client:subtractFromChart", src, fee)
        
        Player.Functions.AddItem("bank_card", 1, false, {
            citizenid = Player.PlayerData.citizenid,
            issued_date = os.date("%Y-%m-%d"),
            card_holder = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        })
        
        TriggerClientEvent('QBCore:Notify', src, "Replacement card issued successfully! Fee: $" .. fee, "success")
        TriggerClientEvent("nc-banking:client:updateBalance", src, Player.PlayerData.money.bank)
        TriggerClientEvent("nc-banking:client:cardIssued", src)
    else
        TriggerClientEvent('QBCore:Notify', src, message, "error")
    end
end)

RegisterNetEvent("nc-banking:server:changeCardPin", function(pin, fee)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    
    fee = tonumber(fee) or 0
    if fee < 0 then return end

    if not IsPlayerNearABank(src) then 
        TriggerClientEvent('QBCore:Notify', src, "You must be at a bank to change your PIN", "error")
        return 
    end
    
    if Player.PlayerData.money.bank < fee then
        TriggerClientEvent('QBCore:Notify', src, "You don't have enough money in your account", "error")
        return
    end
    
    if not pin or string.len(pin) ~= 4 or not string.match(pin, "^%d+$") then
        TriggerClientEvent('QBCore:Notify', src, "Invalid PIN format", "error")
        return
    end
    
    local success, message = UpdateCardPin(Player.PlayerData.citizenid, pin)
    
    if success then
        Player.Functions.RemoveMoney("bank", fee)
        LogTransaction(src, Player.PlayerData.citizenid, nil, nil, fee, "withdraw", "PIN change fee")
        TriggerClientEvent("nc-banking:client:subtractFromChart", src, fee)
        
        TriggerClientEvent('QBCore:Notify', src, "PIN changed successfully! Fee: $" .. fee, "success")
        TriggerClientEvent("nc-banking:client:updateBalance", src, Player.PlayerData.money.bank)
    else
        TriggerClientEvent('QBCore:Notify', src, message, "error")
    end
end)


RegisterNetEvent("nc-banking:server:verifyATMPin", function(pin)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    if not Player then return end
    if type(pin) ~= 'string' or not pin:match('^%d%d%d%d$') then
        TriggerClientEvent("nc-banking:client:atmPinFailed", src, "Invalid PIN format")
        return
    end
    
    local success, message = VerifyCardPin(Player.PlayerData.citizenid, pin)
    
    if success then
        TriggerClientEvent("nc-banking:client:atmPinVerified", src)
    else
        TriggerClientEvent("nc-banking:client:atmPinFailed", src, message)
    end
end)