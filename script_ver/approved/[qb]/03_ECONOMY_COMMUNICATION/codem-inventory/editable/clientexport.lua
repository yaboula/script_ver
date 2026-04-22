function HasItem(items, amount)
    if items == nil then
        return false
    end

local inventory = ClientInventory
    if type(inventory) ~= 'table' then
        return false
    end

local function itemAmount(entry)
        if type(entry) ~= 'table' then
            return 0
        end
local amt = tonumber(entry.amount)
        if not amt then
            amt = tonumber(entry.count)
        end
        return amt or 0
    end

local function hasSingle(itemName, requiredAmount)
        if type(itemName) ~= 'string' or itemName == '' then
            return false
        end
local needed = tonumber(requiredAmount) or 1
        for _, itemData in pairs(inventory) do
            if itemData and itemData.name == itemName and itemAmount(itemData) >= needed then
                return true
            end
        end
        return false
    end

    if type(items) == 'string' then
        return hasSingle(items, amount)
    end

    if type(items) ~= 'table' then
        return false
    end

local hasAny = false
local isArray = true
    for key in pairs(items) do
        hasAny = true
        if type(key) ~= 'number' then
            isArray = false
            break
        end
    end

    if not hasAny then
        return false
    end

    if isArray then
        for _, itemName in ipairs(items) do
            if not hasSingle(itemName, amount) then
                return false
            end
        end
        return true
    end

    for itemName, requiredAmount in pairs(items) do
        if not hasSingle(itemName, requiredAmount) then
            return false
        end
    end
    return true
end

exports('HasItem', HasItem)

local SharedWeapons = {}
Citizen.CreateThread(function()
    for k, v in pairs(Config.Itemlist) do
        if v.type == "weapon" then
            SharedWeapons[GetHashKey(v.name)] = {
                name = v.name,
                ammotype = v.ammotype or nil
            }
        end
    end
end)

exports('SharedWeapons', function(name)
    if SharedWeapons[name] then
        return SharedWeapons[name]
    end
    return false
end)



function GetItemList()
    return Config.Itemlist
end

exports('GetItemList', GetItemList)


function getUserInventory()
local items = TriggerCallback('codem-inventory:getUserInventory')
    return items
end

exports('getUserInventory', getUserInventory)

function GetClientPlayerInventory()
local inventory = ClientInventory
    for k, v in pairs(inventory) do
        if not v.count then
            v.count = v.amount
        end
        v.count = v.amount
    end
    return inventory
end

exports('GetClientPlayerInventory', GetClientPlayerInventory)

function isOpen()
    return OpenInventory
end

exports('isOpen', isOpen)


function ClosePlayerInventory()
    TriggerEvent('codem-inventory:client:closeInventory')
end

exports('CloseInventory', ClosePlayerInventory)

function OpenPlayerInventory()
    TriggerEvent('codem-inventory:openInventory')
end

exports('OpenInventory', OpenPlayerInventory)
