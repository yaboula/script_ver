local Cow_Fields = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = false,
    [9] = false,
    [10] = false,
    [11] = false,
    [12] = false
}

local DeleteTable = {}
local fields = {}

local function Entitydeleter(src)
    if DeleteTable[src] then
        for _,v in pairs(DeleteTable[src]) do 
            if DoesEntityExist(v) then 
                DeleteEntity(v)
            end
        end
        DeleteTable[src] = {}
    end
end

local function IsCowFieldFree(id)
    if not Cow_Fields[id] then
        return true
    end
    return false
end

ESX.RegisterServerCallback('0r-farming-get-cow-fields', function(source, cb)
    cb(Cow_Fields)
end)

ESX.RegisterServerCallback('0r-farming-start-cowfield', function(source, cb, FieldID)
    local src = source
    if IsCowFieldFree(FieldID) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('0r-farming-cow-started', function(FieldID)
    local src = source
    if not IsCowFieldFree(FieldID) then return end
    if fields[src] then return end
    Cow_Fields[FieldID] = true
    fields[src] = FieldID
    DeleteTable[src] = {}
end)

RegisterServerEvent('0r-farming-cowjob-finished', function(FieldID)
    local src = source
    if fields[src] ~= FieldID then return end
    fields[src] = nil
    Cow_Fields[FieldID] = false
end)

RegisterServerEvent('0r-farming-insert-cow', function(value)
    local src = source
    if not fields[src] then return end
    for i = 1, 10, 1 do 
        Wait(0)
        if NetworkGetEntityFromNetworkId(value) ~= 0 then
            table.insert(DeleteTable[src], NetworkGetEntityFromNetworkId(value))
            break 
        end
        Wait(100)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    Entitydeleter(src)
    if fields[src] then
        Cow_Fields[fields[src]] = false
    end
end)

local rateLimit = {}
RegisterNetEvent('0r-farming-receive-milk', function()
    local src = source
    if not fields[src] then return end
    local user = ESX.GetPlayerFromId(src)
    if not user then return end

    if rateLimit[src] and os.time() - rateLimit[src] < 2 then return end
    rateLimit[src] = os.time()

    if MainShared.Inventory == 'esx' then
        user.addInventoryItem('milkbottle', CowShared.MilkBottle)
    elseif MainShared.Inventory == 'ox' then
        local ox_inventory = exports.ox_inventory
        ox_inventory:AddItem(src, 'milkbottle', CowShared.MilkBottle)
    elseif MainShared.Inventory == 'qs' then
        exports['qs-inventory']:AddItem(src, 'milkbottle', CowShared.MilkBottle)
    end
end)

local rateLimitChurn = {}
RegisterNetEvent('0r-farming-delete-churn', function()
    local src = source
    if not fields[src] then return end
    local user = ESX.GetPlayerFromId(src)
    if not user then return end

    if rateLimitChurn[src] and os.time() - rateLimitChurn[src] < 2 then return end
    rateLimitChurn[src] = os.time()

    if MainShared.Inventory == 'esx' then
        user.removeInventoryItem('churn', 1)
    elseif MainShared.Inventory == 'ox' then
        local ox_inventory = exports.ox_inventory
        ox_inventory:RemoveItem(src, 'churn', 1)
    elseif MainShared.Inventory == 'qs' then
        exports['qs-inventory']:RemoveItem(src, 'churn', 1)
    end
end)