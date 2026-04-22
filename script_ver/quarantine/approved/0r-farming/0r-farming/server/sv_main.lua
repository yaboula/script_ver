ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback("0r-farming-buy", function(src, cb, data)
    local user = ESX.GetPlayerFromId(src)
    if not user then return cb(false) end
    if type(data.itemTable) ~= 'table' then return cb(false) end

    local TotalPrice = 0
    local ValidItems = {}

    for i=1, #data.itemTable do
        local itemName = data.itemTable[i].name
        local itemCode = data.itemTable[i].itemCode
        local itemAmount = tonumber(data.itemTable[i].amount)
        
        if type(itemAmount) == 'number' and itemAmount > 0 then
            local shopItem = nil
            if Config and Config["Shop"] then
                for k, v in pairs(Config["Shop"]) do
                    if v.ItemCode == itemCode then
                        shopItem = v
                        break
                    end
                end
            end
            
            if shopItem then
                TotalPrice = TotalPrice + (shopItem.Price * itemAmount)
                table.insert(ValidItems, {itemCode = shopItem.ItemCode, amount = itemAmount})
            end
        end
    end

    if TotalPrice <= 0 or #ValidItems == 0 then return cb(false) end

    if data.type == 'bank' then
        if user.getAccount('bank').money >= TotalPrice then
            user.removeAccountMoney('bank', TotalPrice) 
            for i=1, #ValidItems do
                if MainShared.Inventory == 'esx' then
                    user.addInventoryItem(ValidItems[i].itemCode, ValidItems[i].amount)
                elseif MainShared.Inventory == 'ox' then
                    exports.ox_inventory:AddItem(src, ValidItems[i].itemCode, ValidItems[i].amount)
                elseif MainShared.Inventory == 'qs' then
                    exports['qs-inventory']:AddItem(src, ValidItems[i].itemCode, ValidItems[i].amount)
                end
            end
            cb(true)
        else
            cb(false)
        end
    elseif data.type == 'cash' then
        if user.getMoney() >= TotalPrice then
            user.removeMoney(TotalPrice) 
            for i=1, #ValidItems do
                if MainShared.Inventory == 'esx' then
                    user.addInventoryItem(ValidItems[i].itemCode, ValidItems[i].amount)
                elseif MainShared.Inventory == 'ox' then
                    exports.ox_inventory:AddItem(src, ValidItems[i].itemCode, ValidItems[i].amount)
                elseif MainShared.Inventory == 'qs' then
                    exports['qs-inventory']:AddItem(src, ValidItems[i].itemCode, ValidItems[i].amount)
                end
            end
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

local function SellFunction(data)
    local src = source
    local user = ESX.GetPlayerFromId(src)
    if not user then return end
    if type(data) ~= 'table' or type(data.item) ~= 'string' then return end

    local sellItem = nil
    if Config and Config["Sell"] then
        for k, v in pairs(Config["Sell"]) do
            if v.ItemCode == data.item then
                sellItem = v
                break
            end
        end
    end

    if not sellItem then return end
    local validPrice = sellItem.Price

    if MainShared.Inventory == 'esx' then
        local itemData = user.getInventoryItem(data.item)
        if itemData and itemData.count > 0 then
            local count = itemData.count
            user.removeInventoryItem(data.item, count)
            user.addAccountMoney('bank', validPrice * count)
        else
            TriggerClientEvent('0r-farming-notify', src, Lan.YouDontHaveItem, 'error')
        end
    elseif MainShared.Inventory == 'ox' then
        local items = exports.ox_inventory:Search(src, 'count', data.item)
        if type(items) == 'number' and items > 0 then
            exports.ox_inventory:RemoveItem(src, data.item, items)
            user.addAccountMoney('bank', validPrice * items)
        else
            TriggerClientEvent('0r-farming-notify', src, Lan.YouDontHaveItem, 'error')
        end
    elseif MainShared.Inventory == 'qs' then
        local items = exports['qs-inventory']:GetItemTotalAmount(src, data.item)
        if type(items) == 'number' and items > 0 then
            exports['qs-inventory']:RemoveItem(src, data.item, items)
            user.addMoney(validPrice * items)
        else
            TriggerClientEvent('0r-farming-notify', src, Lan.YouDontHaveItem, 'error')
        end
    end
end 
RegisterServerEvent('0r-farming-sell', SellFunction)

local function GetItem(src, cb, itemname)
    local user = ESX.GetPlayerFromId(src)
    if user then
        if MainShared.Inventory == 'esx' then
            local item = user.getInventoryItem(itemname).count
            if item > 0 then
                cb(true)
            else
                cb(false)
            end
        elseif MainShared.Inventory == 'ox' then
            local ox_inventory = exports.ox_inventory
            local count = ox_inventory:Search('count', itemname)
            if count > 0 then
                cb(true)
            else
                cb(false)
            end
        elseif MainShared.Inventory == 'qs' then
            local items = exports['qs-inventory']:GetItemTotalAmount(src, itemname)
            if items > 0 then
                cb(true)
            else
                cb(false)
            end
        end
    else
        cb(false)
    end
end ESX.RegisterServerCallback('0r-farming-check-item', GetItem)

local function GetItem2(src, cb, itemname)
    local user = ESX.GetPlayerFromId(src)
    if user then
        if MainShared.Inventory == 'esx' then
            local item = user.getInventoryItem(itemname).count
            if item > 0 then
                cb(true)
            else
                cb(false)
            end
        elseif MainShared.Inventory == 'ox' then
            local ox_inventory = exports.ox_inventory
            local count = ox_inventory:Search('count', itemname)
            if count > 0 then
                cb(true)
            else
                cb(false)
            end
        elseif MainShared.Inventory == 'qs' then
            local items = exports['qs-inventory']:GetItemTotalAmount(src, itemname)
            if items > 0 then
                cb(true)
            else
                cb(false)
            end
        end
    else
        cb(false)
    end
end ESX.RegisterServerCallback('0r-farming-check-item2', GetItem2)