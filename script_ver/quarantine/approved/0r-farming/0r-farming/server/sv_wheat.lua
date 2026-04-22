local Wheat_Fields = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false,
    [7] = false,
    [8] = false
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

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    
    for i=1, 256 do
        if DeleteTable[i] then
            for _,v in pairs(DeleteTable[i]) do 
                if DoesEntityExist(v) then 
                    DeleteEntity(v)
                end
            end
            DeleteTable[i] = {}
        end
    end
  end)

local function IsWheatFieldFree(id)
    if not Wheat_Fields[id] then
        return true
    end
    return false
end

ESX.RegisterServerCallback('0r-farming-get-wheat-fields', function(source, cb)
    cb(Wheat_Fields)
end)

ESX.RegisterServerCallback('0r-farming-start-wheatfield', function(source, cb, FieldID)
    local src = source
    if IsWheatFieldFree(FieldID) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('0r-farming-wheat-started', function(FieldID)
    local src = source
    if not IsWheatFieldFree(FieldID) then return end
    if fields[src] then return end
    Wheat_Fields[FieldID] = true
    fields[src] = FieldID
    DeleteTable[src] = {}
end)

RegisterServerEvent('0r-farming-insert', function(value)
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
        Wheat_Fields[fields[src]] = false
    end
end)

RegisterServerEvent('0r-farming-wheat-finished', function(FieldID)
    local src = source
    if fields[src] ~= FieldID then return end
    fields[src] = nil
    Entitydeleter(src)
    local user = ESX.GetPlayerFromId(src)
    Wheat_Fields[FieldID] = false
end)

local rateLimitWheat = {}
RegisterNetEvent('0r-farming-receive-wheat', function()
    local src = source
    if not fields[src] then return end
    local user = ESX.GetPlayerFromId(src)
    if not user then return end

    if rateLimitWheat[src] and os.time() - rateLimitWheat[src] < 2 then return end
    rateLimitWheat[src] = os.time()

    if MainShared.Inventory == 'esx' then
        if not user.hasItem('wheatseed') then return end
        user.addInventoryItem('wheat', WheatShared.Wheat)
        user.removeInventoryItem('wheatseed', 1)
    elseif MainShared.Inventory == 'ox' then
        local ox_inventory = exports.ox_inventory
        ox_inventory:AddItem(src, 'wheat', WheatShared.Wheat)
        ox_inventory:RemoveItem(src, 'wheatseed', 1)
    elseif MainShared.Inventory == 'qs' then
        exports['qs-inventory']:AddItem(src, 'wheat', WheatShared.Wheat)
        exports['qs-inventory']:RemoveItem(src, 'wheatseed', 1)
    end
end)