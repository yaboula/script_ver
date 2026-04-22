local QBCore = exports["qb-core"]:GetCoreObject()
local Config = exports[GetCurrentResourceName()]:GetConfig()

-- Variable to store shared accounts data
local PlayerSharedAccounts = {}
local CurrentSharedAccount = nil

local function actuallyOpenBank(isATM)
    isATM = isATM or false
    
    -- Update credit score when opening bank
    TriggerServerEvent("nc-banking:server:updateCreditScore")
    
    SendNUIMessage({
        action = "clearAllTransactions"
    })
    
    QBCore.Functions.TriggerCallback("nc-banking:server:retriveNessceryData", function(transactions, societyMoney, sharedAccounts, dailySpending, creditScore)
        for i = 1, #transactions do
            if type(transactions[i].type) == "number" then
                local typeNum = transactions[i].type
                transactions[i].type = Config.LogTypes[typeNum]
            end
        end

        local PlayerData = QBCore.Functions.GetPlayerData()
        local data = {
            playerName = PlayerData.charinfo.firstname,
            bankBalance = PlayerData.money.bank,
            transactions = transactions,
            society = {},
            isATM = isATM,
            dailySpending = dailySpending,
            creditScore = creditScore
        }

        SetNuiFocus(true, true)

        if (not PlayerData.job.isboss) then
            data["society"]["isBoss"] = false
        else
            data["society"] = {
                isBoss = true,
                balance = societyMoney,
                name = PlayerData.job.name
            }
        end

        if Config.SharedAccounts.EnableFeature and sharedAccounts then
            PlayerSharedAccounts = sharedAccounts
            data.sharedAccounts = sharedAccounts
        end

        -- Check card status
        QBCore.Functions.TriggerCallback("nc-banking:server:checkBankCard", function(cardStatus)
            data.cardStatus = cardStatus
            SendNUIMessage({ action = "open", data = data })
        end)
    end)
end

local function requestATMPin()
    -- First set NUI focus to true to handle input
    SetNuiFocus(true, true)
    
    -- Then send the PIN request message
    Citizen.SetTimeout(100, function()
        SendNUIMessage({
            action = "requestATMPin"
        })
    end)
end

local function openBank(isATM)
    isATM = isATM or false
    
    if isATM then
        QBCore.Functions.TriggerCallback("nc-banking:server:checkBankCard", function(cardStatus)
            if not cardStatus.hasCardInInventory then
                if cardStatus.hasCardInDB then
                    QBCore.Functions.Notify("You don't have your bank card with you", "error")
                    QBCore.Functions.Notify("Your card is registered but not in your inventory", "info")
                else
                    QBCore.Functions.Notify("You need a physical bank card to use the ATM", "error")
                    QBCore.Functions.Notify("Visit any bank branch to request a card", "info")
                end
                return
            end
            
            -- Has card in inventory - request PIN
            requestATMPin()
        end)
        return
    end
    
    actuallyOpenBank(isATM)
end


local NUI_CALLBACKS = {
    ["close"] = function(data)
        SetNuiFocus(false, false)
    end,

["deposit"] = function(data)
    local amount = tonumber(data.amount)

    if amount ~= nil and amount > 0 then
        -- Pass the note to the server event
        TriggerServerEvent("nc-banking:server:depositMoney", amount, data.note)
    else
        QBCore.Functions.Notify("Invalid money amount", "error")
    end
end,

["withdraw"] = function(data)
    local amount = tonumber(data.amount)

    if amount ~= nil and amount > 0 then
        -- Pass the note to the server event
        TriggerServerEvent("nc-banking:server:withdrawMoney", amount, data.note)
    else
        QBCore.Functions.Notify("Invalid money amount", "error")
    end
end,

    ["transfer"] = function(data)
        local amount = tonumber(data.amount)
        local target = tonumber(data.target)

        if (amount ~= nil and amount > 0) and (target ~= nil and target > 0) then
            TriggerServerEvent("nc-banking:server:transferMoney", target, amount)
        else
            QBCore.Functions.Notify("Invalid money amount or target id", "error")
        end
    end,

["requestReplacementCard"] = function(data)
    TriggerServerEvent("nc-banking:server:requestReplacementCard", data.pin, data.fee)
  end,

    ["societyDeposit"] = function(data)
        local amount = tonumber(data.amount)

        if amount ~= nil and amount > 0 then
            TriggerServerEvent("nc-banking:server:societyDeposit", amount, data.note)
        else
            QBCore.Functions.Notify("Invalid money amount", "error")
        end
    end,

    ["societyWithdraw"] = function(data)
        local amount = tonumber(data.amount)

        if amount ~= nil and amount > 0 then
            TriggerServerEvent("nc-banking:server:societyWithdraw", amount, data.note)
        else
            QBCore.Functions.Notify("Invalid money amount", "error")
        end
    end,

    -- Card Management Callbacks
    ["requestPhysicalCard"] = function(data)
        TriggerServerEvent("nc-banking:server:requestPhysicalCard", data.pin, data.fee)
    end,

    ["changeCardPin"] = function(data)
        TriggerServerEvent("nc-banking:server:changeCardPin", data.pin, data.fee)
    end,

    ["verifyATMPin"] = function(data)
        TriggerServerEvent("nc-banking:server:verifyATMPin", data.pin)
    end,


["openBankAfterPin"] = function(data)
    actuallyOpenBank(data.isATM)
end,

    -- Shared Accounts NUI Callbacks
    ["getSharedAccounts"] = function(data, cb)
        QBCore.Functions.TriggerCallback("nc-banking:server:getSharedAccounts", function(accounts)
            PlayerSharedAccounts = accounts
            cb(accounts)
        end)
    end,

    ["getSocietyTransactions"] = function(data, cb)
        QBCore.Functions.TriggerCallback("nc-banking:server:getSocietyTransactions", function(transactions)
            -- שלח את העסקאות לממשק המשתמש
            SendNUIMessage({
                action = "updateSocietyTransactions",
                data = {
                    transactions = transactions
                }
            })
            
            cb({ success = true, count = #transactions })
        end)
    end,

    ["createSharedAccount"] = function(data, cb)
        QBCore.Functions.TriggerCallback("nc-banking:server:createSharedAccount", function(success, result)
            if success then
                -- Add to local cache
                table.insert(PlayerSharedAccounts, result)
            end
            cb({success = success, data = result})
        end, data.name)
    end,

    ["joinSharedAccount"] = function(data, cb)
        QBCore.Functions.TriggerCallback("nc-banking:server:requestJoinSharedAccount", function(success, message)
            cb({success = success, message = message})
        end, data.code)
    end,

    ["getSharedAccountDetails"] = function(data, cb)
        CurrentSharedAccount = nil
        QBCore.Functions.TriggerCallback("nc-banking:server:getSharedAccountDetails", function(accountDetails)
            if accountDetails then
                CurrentSharedAccount = accountDetails
            end
            cb(accountDetails)
        end, data.accountId)
    end,

    ["getSharedAccountMembers"] = function(data, cb)
        QBCore.Functions.TriggerCallback("nc-banking:server:getSharedAccountMembers", function(members)
            cb(members)
        end, data.accountId)
    end,

    ["getSharedAccountRequests"] = function(data, cb)
        QBCore.Functions.TriggerCallback("nc-banking:server:getSharedAccountRequests", function(requests)
            cb(requests)
        end, data.accountId)
    end,

    ["respondToJoinRequest"] = function(data, cb)
        print("^2[DEBUG] respondToJoinRequest callback called")
        
        if not data.requestId then
            print("^1[ERROR] No requestId provided")
            if cb then cb({success = false, message = "Invalid request ID"}) end
            return
        end
        
        -- Send the event directly to server
        TriggerServerEvent("nc-banking:server:respondToRequest", data)
        
        -- Return immediate success to UI
        if cb then 
            cb({success = true, message = "Processing request..."}) 
        end
        
        -- Force a delayed refresh of the interface
        Citizen.SetTimeout(1500, function()
            SendNUIMessage({ action = "refreshSharedAccounts" })
        end)
    end,

    ["directRespondToRequest"] = function(data, callback)
        print("^2[DEBUG] directRespondToRequest callback called")
        
        if not data.requestId then
            print("^1[ERROR] No requestId provided")
            if callback then callback({success = false, message = "Invalid request ID"}) end
            return
        end
        
        -- Simply pass the event through directly
        TriggerServerEvent("nc-banking:server:respondToRequest", data)
        
        if callback then 
            callback({success = true, message = "Request processed"}) 
        end
    end,
    
    ["forceRefresh"] = function(data, callback)
        SetNuiFocus(false, false)
        callback("ok")
        
        Citizen.SetTimeout(500, function()
            TriggerEvent("nc-banking:client:forceRefreshBanking")
        end)
    end,

    ["removeSharedAccountMember"] = function(data, cb)
        print("^2[DEBUG] removeSharedAccountMember callback called")
        
        if not data.accountId or not data.memberId then
            print("^1[ERROR] Missing accountId or memberId")
            QBCore.Functions.Notify("Invalid request data", "error")
            if cb then cb({success = false, message = "Invalid request data"}) end
            return
        end
        
        -- Use QBCore callback for this operation since we need to wait for the result
        QBCore.Functions.TriggerCallback("nc-banking:server:removeSharedAccountMember", function(success, message)
            if cb then
                cb({success = success, message = message})
            end
        end, data.accountId, data.memberId)
    end,

    ["leaveSharedAccount"] = function(data, cb)
        print("^2[DEBUG] leaveSharedAccount callback called with accountId:", data.accountId)
        
        if not data.accountId then
            print("^1[ERROR] No accountId provided")
            QBCore.Functions.Notify("Invalid account ID", "error")
            if cb then cb({success = false, message = "Invalid account ID"}) end
            return
        end
        
        -- Trigger the server event
        TriggerServerEvent("nc-banking:server:leaveSharedAccount", data.accountId)
        
        -- Remove from local cache immediately (optimistic update)
        for i, account in ipairs(PlayerSharedAccounts) do
            if account.id == data.accountId then
                table.remove(PlayerSharedAccounts, i)
                print("^3[DEBUG] Removed account from local cache")
                break
            end
        end
        
        -- Return success immediately
        if cb then 
            cb({success = true, message = "Leave request sent"}) 
        end
    end,

    ["deleteSharedAccount"] = function(data, cb)
        print("^2[DEBUG] deleteSharedAccount callback called with accountId:", data.accountId)
        
        if not data.accountId then
            print("^1[ERROR] No accountId provided")
            QBCore.Functions.Notify("Invalid account ID", "error")
            if cb then cb({success = false, message = "Invalid account ID"}) end
            return
        end
        
        -- Trigger the server event
        TriggerServerEvent("nc-banking:server:deleteSharedAccount", data.accountId)
        
        -- Remove from local cache immediately (optimistic update)
        for i, account in ipairs(PlayerSharedAccounts) do
            if account.id == data.accountId then
                table.remove(PlayerSharedAccounts, i)
                print("^3[DEBUG] Removed account from local cache")
                break
            end
        end
        
        -- Return success immediately
        if cb then 
            cb({success = true, message = "Delete request sent"}) 
        end
    end,

    ["renameSharedAccount"] = function(data)
        TriggerServerEvent("nc-banking:server:renameSharedAccount", data.accountId, data.newName)
        
        -- Update in local cache
        for i, account in ipairs(PlayerSharedAccounts) do
            if account.id == data.accountId then
                PlayerSharedAccounts[i].name = data.newName
                break
            end
        end
    end,

    ["regenerateSharedAccountCode"] = function(data, cb)
        print("^2[DEBUG] regenerateSharedAccountCode callback called")
        
        if not data.accountId then
            print("^1[ERROR] No accountId provided")
            QBCore.Functions.Notify("Invalid account ID", "error")
            if cb then cb({success = false, message = "Invalid account ID"}) end
            return
        end
        
        -- Trigger the server event
        TriggerServerEvent("nc-banking:server:regenerateSharedAccountCode", data.accountId)
        
        -- Return success immediately
        if cb then 
            cb({success = true, message = "Code regeneration request sent"}) 
        end
    end,

["depositToSharedAccount"] = function(data, cb)
    local amount = tonumber(data.amount)
    
    if amount ~= nil and amount > 0 then
        TriggerServerEvent("nc-banking:server:sharedAccountDeposit", data.accountId, amount, data.note)
        if cb then cb({success = true}) end
    else
        QBCore.Functions.Notify("Invalid amount", "error")
        if cb then cb({success = false, message = "Invalid amount"}) end
    end
end,

["withdrawFromSharedAccount"] = function(data, cb)
    local amount = tonumber(data.amount)
    
    if amount ~= nil and amount > 0 then
        TriggerServerEvent("nc-banking:server:sharedAccountWithdraw", data.accountId, amount, data.note)
        if cb then cb({success = true}) end
    else
        QBCore.Functions.Notify("Invalid amount", "error")
        if cb then cb({success = false, message = "Invalid amount"}) end
    end
end,

    ["refreshDailySpending"] = function(data, cb)
        QBCore.Functions.TriggerCallback("nc-banking:server:getDailySpending", function(dailySpending)
            SendNUIMessage({
                action = "updateDailySpending",
                data = {
                    dailySpending = dailySpending
                }
            })
            cb("ok")
        end)
    end,

    ["sendNotification"] = function(data, callback)
        if data.message then
            local msgType = data.type or "primary"
            QBCore.Functions.Notify(data.message, msgType, 3500)
        end
        
        callback("ok")
    end,

["transferFromSharedAccount"] = function(data, cb)
    local amount = tonumber(data.amount)
    local target = tonumber(data.target)
    
    if (amount ~= nil and amount > 0) and (target ~= nil and target > 0) then
        TriggerServerEvent("nc-banking:server:sharedAccountTransfer", data.accountId, target, amount, data.note)
        if cb then cb({success = true}) end
    else
        QBCore.Functions.Notify("Invalid amount or target ID", "error")
        if cb then cb({success = false, message = "Invalid amount or target ID"}) end
    end
end,

    ["changeSharedAccountPermission"] = function(data)
        local newPermission = tonumber(data.newPermission)
        
        if newPermission ~= nil and (newPermission == 1 or newPermission == 2) then
            TriggerServerEvent("nc-banking:server:changeSharedAccountPermission", data.accountId, data.memberId, newPermission)
        else
            QBCore.Functions.Notify("Invalid permission level", "error")
        end
    end
}

RegisterNUICallback("sendNotification", function(data, callback)
    if data.message then
        local msgType = data.type or "primary"
        QBCore.Functions.Notify(data.message, msgType, 3500)
    end
    
    callback("ok")
end)

RegisterNetEvent("nc-banking:client:refreshSharedAccounts", function()
    print("^3[DEBUG] Received refresh shared accounts event")
    
    -- Update the UI
    SendNUIMessage({ 
        action = "refreshSharedAccounts" 
    })
    
    -- Refresh local data
    QBCore.Functions.TriggerCallback("nc-banking:server:getSharedAccounts", function(accounts)
        PlayerSharedAccounts = accounts or {}
        print("^3[DEBUG] Updated local shared accounts cache, count:", #PlayerSharedAccounts)
    end)
end)

RegisterNetEvent("nc-banking:client:accountDeleted", function(accountId, accountName)
    print("^2[DEBUG] Account deleted confirmation received:", accountId, accountName)
    
    -- Remove from local cache if not already removed
    for i, account in ipairs(PlayerSharedAccounts) do
        if account.id == accountId then
            table.remove(PlayerSharedAccounts, i)
            break
        end
    end
    
    -- Update UI
    SendNUIMessage({ 
        action = "refreshSharedAccounts" 
    })
    
    -- Show success notification
    QBCore.Functions.Notify("Shared account '" .. (accountName or "Unknown") .. "' has been deleted", "success")
end)

RegisterNetEvent("nc-banking:client:accountLeft", function(accountId, accountName)
    print("^2[DEBUG] Account left confirmation received:", accountId, accountName)
    
    -- Remove from local cache if not already removed
    for i, account in ipairs(PlayerSharedAccounts) do
        if account.id == accountId then
            table.remove(PlayerSharedAccounts, i)
            break
        end
    end
    
    -- Update UI
    SendNUIMessage({ 
        action = "refreshSharedAccounts" 
    })
    
    -- Show success notification
    QBCore.Functions.Notify("You have left '" .. (accountName or "Unknown") .. "'", "success")
end)

RegisterNUICallback("action", function(data, callback)
    local action = data.action
    local func = NUI_CALLBACKS[action]
    
    print("^3[DEBUG] NUI callback received:", action)

    if func == nil then
        print("^1[ERROR] Unknown action:", action)
        if callback then callback({success = false, message = "Unknown action"}) end
        return
    end

    -- Execute the function with proper error handling
    local success, result = pcall(function()
        if data.data then
            func(data.data, callback)
        else
            func(data, callback)
        end
    end)
    
    if not success then
        print("^1[ERROR] Callback execution failed:", result)
        if callback then 
            callback({success = false, message = "Execution failed"}) 
        end
    end
end)

RegisterNetEvent("nc-banking:client:subtractFromChart", function(amount)
    SendNUIMessage({
        action = "subtractFromChart",
        data = { amount = amount }
    })
end)

RegisterNetEvent("nc-banking:client:updateRequests", function(accountId, requestId)
    -- Only update UI if we're looking at the same account
    if CurrentSharedAccount and CurrentSharedAccount.id == accountId then
        SendNUIMessage({
            action = "removeRequest",
            data = {
                requestId = requestId
            }
        })
    end
end)

RegisterNetEvent("gnc-banking:client:updateSharedAccountTransactions", function(transactions)
    -- המרת סוגי העסקאות לפורמט שהממשק מצפה לו
    for i = 1, #transactions do
        if type(transactions[i].type) == "number" then
            transactions[i].type = Config.LogTypes[transactions[i].type]
        end
    end

    -- שליחת העסקאות לממשק
    SendNUIMessage({
        action = "renderTransactions",
        data = {
            transactions = transactions
        }
    })
end)

RegisterNetEvent("nc-banking:client:updateDailySpending", function(dailySpending)
    SendNUIMessage({
        action = "updateDailySpending",
        data = {
            dailySpending = dailySpending
        }
    })
end)

RegisterNetEvent("nc-banking:client:updateCreditScore", function(newScore)
    SendNUIMessage({
        action = "updateCreditScore",
        data = {
            creditScore = newScore
        }
    })
end)

RegisterNetEvent("nc-banking:client:updateSocietyTransactions", function(transactions)
    if transactions then
        for i=1, #transactions do
            -- Handle type conversion directly here
            if type(transactions[i].type) == "number" then
                local typeNum = transactions[i].type
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
                transactions[i].type = typeMap[typeNum] or "unknown_" .. tostring(typeNum)
            end
        end
    end
    
    SendNUIMessage({
        action = "updateSocietyTransactions",
        data = { transactions = transactions }
    })
end)

-- Card Events
RegisterNetEvent("nc-banking:client:actuallyOpenBank", function(isATM)
    actuallyOpenBank(isATM)
end)

RegisterNetEvent("nc-banking:client:atmPinVerified", function()
    SendNUIMessage({
        action = "atmPinVerified"
    })
end)

RegisterNetEvent("nc-banking:client:atmPinFailed", function(message)
    SendNUIMessage({
        action = "atmPinFailed",
        data = { message = message }
    })
end)
RegisterNetEvent("nc-banking:client:cardIssued", function()
    SendNUIMessage({
        action = "cardIssued"
    })
end)

CreateThread(function()
    -- Setup bank locations
    for k, v in pairs(Config.BankLocations) do
        -- Setup targets based on selected target system
        if Config.TargetSystem == 'qb-target' then
            -- QBCore target implementation
            exports["qb-target"]:AddBoxZone(
                "bank_" .. k,
                vector3(v.x, v.y, v.z),
                2.0, -- length
                2.0, -- width
                {
                    name = "bank_" .. k,
                    heading = v.w or 0.0,
                    debugPoly = false,
                    minZ = v.z - 1.0,
                    maxZ = v.z + 1.0,
                },
                {
                    options = {
                        {
                            action = function() -- This needs to be a function that calls openBank
                                openBank(false) -- Explicitly pass false for regular banks
                            end,
                            icon = "fas fa-university",
                            label = "Access Bank",
                        },
                    },
                    distance = 2.0
                }
            )
        elseif Config.TargetSystem == 'ox_target' then
            -- ox_target implementation (corrected format)
            exports.ox_target:addBoxZone({
                coords = vector3(v.x, v.y, v.z),
                size = vec3(2.0, 2.0, 2.0),
                rotation = v.w or 0.0,
                debug = false,
                options = {
                    {
                        name = 'bank_access_' .. k,
                        icon = 'fas fa-university',
                        label = 'Access Bank',
                        onSelect = function()
                            openBank(false)
                        end
                    }
                }
            })
        end
        
        -- Create blip for this bank location
        local blip = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blip, 108) -- Bank blip sprite
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 2) -- Green
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bank")
        EndTextCommandSetBlipName(blip)
    end

    -- Setup ATM targets
    for _, model in pairs(Config.ATMProps) do
        if Config.TargetSystem == 'qb-target' then
            -- QBCore target implementation for ATMs
            exports['qb-target']:AddTargetModel(model, {
                options = {
                    {
                        icon = "fas fa-credit-card",
                        label = "Use ATM",
                        action = function()
                            openBank(true) -- Pass true to indicate it's an ATM
                        end,
                    },
                },
                distance = 2.0
            })
        elseif Config.TargetSystem == 'ox_target' then
            -- ox_target implementation for ATMs (corrected format)
            exports.ox_target:addModel(model, {
                {
                    name = 'atm_access',
                    icon = 'fas fa-credit-card',
                    label = 'Use ATM',
                    onSelect = function()
                        openBank(true)
                    end
                }
            })
        end
    end
    
    -- Bank NPCs (if enabled)
    if Config.UseBankPeds then
        for _, v in pairs(Config.BankLocations) do
            local model = Config.BankPed or "ig_bankman" -- Default bank ped
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(0)
            end

            local ped = CreatePed(4, model, v.x, v.y, v.z - 1.0, v.w or 0.0, false, true)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)

            if Config.TargetSystem == 'qb-target' then
                -- QBCore target implementation for peds
                exports["qb-target"]:AddTargetEntity(ped, {
                    options = {
                        {
                            action = function()
                                openBank(false) -- Bank access via ped
                            end,
                            icon = "fas fa-university",
                            label = "Access Bank",
                        },
                    },
                    distance = 2.0
                })
            elseif Config.TargetSystem == 'ox_target' then
                -- ox_target implementation for peds (corrected format)
                exports.ox_target:addEntity(ped, {
                    {
                        name = 'bank_ped_access',
                        icon = 'fas fa-university',
                        label = 'Access Bank',
                        onSelect = function()
                            openBank(false)
                        end
                    }
                })
            end
        end
    end
end)

RegisterNetEvent("nc-banking:client:forceRefreshBanking", function()
    SendNUIMessage({ action = "close" })
    Citizen.SetTimeout(1000, function() openBank() end)
end)

RegisterNetEvent("nc-banking:open", function()
    openBank()
end)

RegisterNetEvent("nc-banking:client:updateBalance", function(newBalance)
    SendNUIMessage({
        action = "updateBalance",
        data = {
            newBalance = newBalance
        }
    })
end)

RegisterNetEvent("nc-banking:client:updateSocietyBalance", function(newBalance)
    SendNUIMessage({
        action = "updateSocietyBalance",
        data = {
            newBalance = newBalance
        }
    })
end)

RegisterNetEvent('nc-banking:client:openATM', function()
    QBCore.Functions.TriggerCallback('nc-banking:server:checkBankCard', function(hasCard, cardInfo)
        if hasCard then
            TriggerEvent('nc-banking:client:requestATMPin')
        else
            QBCore.Functions.Notify('You need a bank card to use the ATM', 'error')
        end
    end)
end)

RegisterNetEvent("nc-banking:client:checkNearATM")
AddEventHandler("nc-banking:client:checkNearATM", function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local nearATM = false
    
    -- Check ATM props
    for _, propName in ipairs(Config.ATMProps) do
        local closestAtm = GetClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 3.0, GetHashKey(propName), false, false, false)
        if closestAtm ~= 0 then
            nearATM = true
            break
        end
    end
    
    TriggerServerEvent("nc-banking:server:ATMCheckResult", nearATM)
end)

RegisterNetEvent("nc-banking:client:updateTransactions", function(transactions)
    -- Add type conversion here before sending to UI
    if transactions then
        for i=1, #transactions do
            -- Handle type conversion directly here
            if type(transactions[i].type) == "number" then
                local typeNum = transactions[i].type
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
                transactions[i].type = typeMap[typeNum] or "unknown_" .. tostring(typeNum)
            end
        end
    end
    
    SendNUIMessage({
        action = "updateTransactions",
        data = {
            transactions = transactions
        }
    })
end)

-- Shared account events
RegisterNetEvent("nc-banking:client:updateSharedAccountBalance", function(accountId, newBalance)
    if not Config.SharedAccounts.EnableFeature then return end
    
    -- Update the balance in local cache
    for i, account in ipairs(PlayerSharedAccounts) do
        if account.id == accountId then
            PlayerSharedAccounts[i].balance = newBalance
            break
        end
    end
    
    -- If this is the currently viewed account, update UI
    if CurrentSharedAccount and CurrentSharedAccount.id == accountId then
        SendNUIMessage({
            action = "updateSharedAccountBalance",
            data = {
                accountId = accountId,
                newBalance = newBalance
            }
        })
    end
end)

RegisterNetEvent("nc-banking:client:updateSharedAccountTransactions", function(transactions)
    SendNUIMessage({
        action = "renderTransactions",
        data = {
            transactions = transactions
        }
    })
end)

-- Event for code regeneration response
RegisterNetEvent("nc-banking:client:sharedAccountCodeUpdated", function(accountId, newCode)
    -- Update in local cache
    for i, account in ipairs(PlayerSharedAccounts) do
        if account.id == accountId then
            PlayerSharedAccounts[i].code = newCode
            break
        end
    end
    
    -- If this is the currently viewed account, update UI
    if CurrentSharedAccount and CurrentSharedAccount.id == accountId then
        SendNUIMessage({
            action = "updateSharedAccountCode",
            data = {
                accountId = accountId,
                newCode = newCode
            }
        })
    end
end)