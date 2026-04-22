CreateThread(function()
    RegisterCallback('mWeed:GetPlayerCash', function(source, cb)
        cb(GetPlayerMoney(source))
    end)
end)

function GetPlayerMoney(source)
    local amount = 0
    local Player = GetPlayer(source)
    if not Player then
        return amount
    end
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        amount = Player.getMoney()
    else 
        amount = Player.Functions.GetMoney('cash')
    end
    return amount
end

local function IsPositiveInteger(value)
    local n = tonumber(value)
    if not n then
        return false
    end
    if n ~= math.floor(n) then
        return false
    end
    return n > 0 and n <= 100
end

local function NormalizeCart(cart, resolver)
    if type(cart) ~= 'table' then
        return false
    end

    local safeCart = {}
    for _, entry in pairs(cart) do
        if type(entry) ~= 'table' or type(entry.name) ~= 'string' or not IsPositiveInteger(entry.amount or entry.count) then
            return false
        end

        local item = resolver(entry.name)
        if not item then
            return false
        end

        table.insert(safeCart, {
            name = item.name,
            amount = tonumber(entry.amount or entry.count),
        })
    end

    if #safeCart == 0 then
        return false
    end

    return safeCart
end

function SellItem(source, cart)
    local Player = GetPlayer(source)
    if not Player then
        return false
    end

    local safeCart = NormalizeCart(cart, GetSellableItem)
    if not safeCart then
        TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
        return false
    end

    local totalPrice = 0

    for _,v in pairs(safeCart) do
        local item = GetSellableItem(v.name)
        if item then 
            totalPrice = totalPrice + (item.price * v.amount) 
        end
    end
    if totalPrice <= 0 then
        TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
        return false
    end

    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        for _,v in pairs(safeCart) do       
            local item = Player.getInventoryItem(v.name)
            if not item then
                TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
                return false
            end
            local count = item.amount or item.count
            local vcount = v.amount or v.count
            if Config.Minventory then
                if tonumber(count) < tonumber(vcount) then
                    TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
                    return false
                end
            else
                if tonumber(count) < tonumber(vcount) then
                    TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
                    return false
                end
            end
        end
        for _,v in pairs(safeCart) do        
            Player.removeInventoryItem(v.name, v.amount)
        end
        Player.addMoney(totalPrice)
    else   
        for _,v in pairs(safeCart) do        
            local item = GetQBCoreItemByName(Player.PlayerData.items, v.name)
            if not item then            
                TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
                return false
            end
            local count = item.amount or item.count
            local vcount = v.amount or v.count
            if Config.Minventory then
                if tonumber(count) < tonumber(vcount) then
                    TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
                    return false
                end
            else
                if tonumber(count) < tonumber(vcount) then
                    TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["ITEM_SELL_FAIL"])
                    return false
                end
            end
        end 
        for _,v in pairs(safeCart) do        
            Player.Functions.RemoveItem(v.name, v.amount)
        end
        Player.Functions.AddMoney('cash', totalPrice, 'Weed sell')
    end
    TriggerClientEvent('mWeed:RefreshPlayerCash', source)
    TriggerClientEvent('mWeed:RefreshPlayerInventory', source)
    return true

end

function BuyItem(source, cart)
    local Player = GetPlayer(source)
    if not Player then
        return false
    end

    local safeCart = NormalizeCart(cart, GetBuyableItem)
    if not safeCart then
        TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["YOU_DONT_HAVE_MONEY"])
        return false
    end

    local totalPrice = 0
    for _,v in pairs(safeCart) do
        local item = GetBuyableItem(v.name)
        if item then 
            totalPrice = totalPrice + (item.price * v.amount) 
        end
    end
    if totalPrice <= 0 then
        TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["YOU_DONT_HAVE_MONEY"])
        return false
    end

    if GetPlayerMoney(source) < totalPrice then
        TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["YOU_DONT_HAVE_MONEY"])
        return false
    end
    local addedItems = {}

    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
       
        for _,v in pairs(safeCart) do 
            if not Player.canCarryItem(v.name, v.amount) then
                TriggerClientEvent('mWeed:SendNotification', source,  Config.Notifications["CANT_CARRY"])
                for __,vv in pairs(addedItems) do
                    Player.removeInventoryItem(vv.name, vv.amount)
                    return false
                end
                return false
            end                           
            Player.addInventoryItem(v.name, v.amount)            
            table.insert(addedItems, v)
        end
        Player.removeMoney(totalPrice)
    else   
        for _,v in pairs(safeCart) do  
            if Player.Functions.AddItem(v.name, v.amount) then
                table.insert(addedItems, v)
            else
                for __,vv in pairs(addedItems) do
                    Player.Functions.RemoveItem(vv.name, vv.amount)
                end
                TriggerClientEvent('mWeed:SendNotification', source, Config.Notifications["CANT_CARRY"])
                return false
            end
        end 
        Player.Functions.RemoveMoney('cash', totalPrice, 'Weed ingredients')
    end
    TriggerClientEvent('mWeed:RefreshPlayerCash', source)
    return true
end