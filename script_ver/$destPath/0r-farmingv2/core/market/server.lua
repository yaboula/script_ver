local inventoryModule = require("modules.inventory.server")
local config = lib.load("core.market.config")

local deliveries = {}

local function getBuyItems()
    local items = {}
    for _, item in pairs(config.items) do
        if item.type == nil or item.type == "buy" then
            table.insert(items, item)
        end
    end
    return items
end

local function getSellItems()
    local items = {}
    for _, item in pairs(config.items) do
        if item.type == nil or item.type == "sell" then
            table.insert(items, item)
        end
    end
    return items
end

local function giveItems(source, items)
    for _, item in pairs(items) do
        inventoryModule.giveItem(source, item.itemName, item.count)
    end
end

local function getDelivery(source)
    local delivery = deliveries[source]
    if not delivery then
        return false
    end
    return delivery
end

local function hasDelivery(source)
    local delivery = deliveries[source]
    return delivery ~= nil
end

local function createDelivery(deliveryData)
    local time = math.max(10, config.droneDelivery.time or 60)
    local endTime = GetGameTimer() + (time * 1000)
    deliveryData.endTime = endTime
    deliveryData.delivery_time = time
    deliveries[deliveryData.owner] = deliveryData
    return deliveryData
end

local function getItemPrice(itemName)
    for _, item in pairs(config.items) do
        if item.itemName == itemName then
            return item.price
        end
    end
    return nil
end

local function getItemSellPrice(itemName)
    for _, item in pairs(config.items) do
        if item.itemName == itemName then
            return item.sellPrice
        end
    end
    return nil
end

Citizen.CreateThread(function()
    while true do
        local currentTime = GetGameTimer()
        for source, delivery in pairs(deliveries) do
            if delivery then
                if not delivery.isDroneSpawned then
                    if currentTime >= delivery.endTime then
                        TriggerClientEvent(_e("client:market:spawnDeliveryDrone"), source, delivery)
                        delivery.isDroneSpawned = true
                    end
                end
            end
        end
        Citizen.Wait(5000)
    end
end)

lib.callback.register(_e("server:market:payCart"), function(source, cartData)
    local buyItems = getBuyItems()
    local validItems = {}
    for _, item in pairs(buyItems) do
        validItems[item.itemName] = true
    end
    
    if hasDelivery(source) then
        return { error = locale("market.already_have_order") }
    end
    
    local paymentType = cartData.type
    local totalPrice = 0
    local orderItems = {}
    
    for _, item in pairs(cartData.items) do
        if not validItems[item.itemName] then
            return { error = locale("market.invalid_item", item.label or item.itemName) }
        end
        
        local price = getItemPrice(item.itemName)
        if not price then
            return { error = locale("market.invalid_item", item.label or item.itemName) }
        end
        
        local count = math.max(1, math.min(100, item.count or 1))
        totalPrice = totalPrice + (price * count)
        
        table.insert(orderItems, {
            itemName = item.itemName,
            count = count,
            price = price,
        })
    end
    
    local balance = server.getPlayerBalance(source, paymentType)
    if totalPrice > balance then
        return { error = locale("dont_have_enough_money", totalPrice) }
    end
    
    if paymentType == "cash" then
        if Config.CleanMoney.isItem then
            inventoryModule.removeItem(source, Config.CleanMoney.itemName, totalPrice)
        else
            if Config.CleanMoney.accountName then
                server.playerRemoveMoney(source, Config.CleanMoney.accountName, totalPrice)
            end
        end
    elseif paymentType == "bank" then
        server.playerRemoveMoney(source, "bank", totalPrice)
    end
    
    local delivery = createDelivery({
        owner = source,
        items = orderItems,
    })
    
    return {
        pendingDelivery = delivery,
    }
end)

lib.callback.register(_e("server:market:collectLootableBag"), function(source)
    local delivery = getDelivery(source)
    if not delivery then
        return false
    end
    
    if not delivery.isDroneSpawned then
        return false
    end
    
    TriggerClientEvent("farming-v2:client:market:onCustomerReceivedOrder", source, delivery.items)
    giveItems(source, delivery.items)
    deliveries[source] = nil
    return true
end)

lib.callback.register(_e("server:market:getPlayerDelivery"), function(source)
    return getDelivery(source)
end)

lib.callback.register(_e("server:market:sellItems"), function(source, sellData)
    local items = sellData.items
    if not items or #items == 0 then
        return { error = locale("market.no_items_to_sell") }
    end
    
    local sellItems = getSellItems()
    local validItems = {}
    for _, item in pairs(sellItems) do
        validItems[item.itemName] = true
    end
    
    local totalPrice = 0
    for _, item in pairs(items) do
        if not validItems[item.itemName] then
            return { error = locale("market.invalid_item", item.label or item.itemName) }
        end
        
        if item.count <= 0 then
            return { error = locale("market.invalid_item_count", item.label or item.itemName) }
        end
        
        if not inventoryModule.hasItem(source, item.itemName, item.count) then
            return { error = locale("market.dont_have_enough_item", item.label or item.itemName) }
        end
        
        local sellPrice = getItemSellPrice(item.itemName)
        if not sellPrice then
            return { error = locale("market.invalid_item", item.label or item.itemName) }
        end
        
        totalPrice = totalPrice + (sellPrice * item.count)
    end
    
    if totalPrice <= 0 then
        return { error = locale("market.no_items_to_sell") }
    end
    
    for _, item in pairs(items) do
        inventoryModule.removeItem(source, item.itemName, item.count)
    end
    
    if Config.CleanMoney.isItem then
        inventoryModule.giveItem(source, Config.CleanMoney.itemName, totalPrice)
    else
        server.playerAddMoney(source, Config.CleanMoney.accountName, totalPrice)
    end
    
    return { success = true }
end)
