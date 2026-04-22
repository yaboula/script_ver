local Melon_Fields = {
    [1] = false,
    [2] = false,
    [3] = false,
    [4] = false,
    [5] = false,
    [6] = false
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

local function IsMelonFieldFree(id)
    if not Melon_Fields[id] then
        return true
    end
    return false
end

ESX.RegisterServerCallback('0r-farming-get-melon-fields', function(source, cb)
    cb(Melon_Fields)
end)

ESX.RegisterServerCallback('0r-farming-start-melonfield', function(source, cb, FieldID)
    local src = source
    if IsMelonFieldFree(FieldID) then
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('0r-farming-melon-started', function(FieldID)
    local src = source
    if not IsMelonFieldFree(FieldID) then return end
    if fields[src] then return end
    Melon_Fields[FieldID] = true
    fields[src] = FieldID
    DeleteTable[src] = {}
end)

RegisterServerEvent('0r-farming-insert-melon', function(value)
    local src = source
    if not fields[src] then return end
    for i = 1, 10, 1 do 
        Wait(0)
        if NetworkGetEntityFromNetworkId(value) ~= 0 then
            if DeleteTable[src] == nil then DeleteTable[src] = {} end
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
        Melon_Fields[fields[src]] = false
    end
end)

RegisterServerEvent('0r-farming-melonjob-finished', function(FieldID)
    local src = source
    if fields[src] ~= FieldID then return end
    fields[src] = nil
    Entitydeleter(src)
    Melon_Fields[FieldID] = false
end)

local rateLimitMelon = {}
RegisterNetEvent('0r-farming-receive-melon', function()
    local src = source
    if not fields[src] then return end
    local user = ESX.GetPlayerFromId(src)
    if not user then return end

    if rateLimitMelon[src] and os.time() - rateLimitMelon[src] < 2 then return end
    rateLimitMelon[src] = os.time()

    if MainShared.Inventory == 'esx' then
        if not user.hasItem('melonseed') then return end
        user.addInventoryItem('melon', MelonShared.CuttedMelon)
        user.removeInventoryItem('melonseed', 1)
    elseif MainShared.Inventory == 'ox' then
        local ox_inventory = exports.ox_inventory
        ox_inventory:AddItem(src, 'melon', MelonShared.CuttedMelon)
        ox_inventory:RemoveItem(src, 'melonseed', 1)
    elseif MainShared.Inventory == 'qs' then
        exports['qs-inventory']:AddItem(src, 'melon', MelonShared.CuttedMelon)
        exports['qs-inventory']:RemoveItem(src, 'melonseed', 1)
    end
end)