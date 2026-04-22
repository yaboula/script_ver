local QBCore = exports['qb-core']:GetCoreObject()


local trunkBusy = {}

local function isValidPlate(plate)
    return type(plate) == 'string' and plate ~= '' and #plate <= 16
end

RegisterServerEvent('qb-trunk:server:setTrunkBusy')
AddEventHandler('qb-trunk:server:setTrunkBusy', function(plate, busy)
    if not isValidPlate(plate) then return end
    if type(busy) ~= 'boolean' then return end
    trunkBusy[plate] = busy
end)

QBCore.Functions.CreateCallback('qb-trunk:server:getTrunkBusy', function(source, cb, plate)
    if not isValidPlate(plate) then
        cb(false)
        return
    end

    cb(trunkBusy[plate] == true)
end)

RegisterServerEvent('qb-trunk:server:KidnapTrunk')
AddEventHandler('qb-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    local src = source
    local target = tonumber(targetId)
    if not target or target < 1 or target == src then return end

    local srcPed = GetPlayerPed(src)
    local targetPed = GetPlayerPed(target)
    if not srcPed or srcPed == 0 or not targetPed or targetPed == 0 then return end

    local srcCoords = GetEntityCoords(srcPed)
    local targetCoords = GetEntityCoords(targetPed)
    if #(srcCoords - targetCoords) > 5.0 then return end

    TriggerClientEvent('qb-trunk:client:KidnapGetIn', target, closestVehicle)
end)


RegisterNetEvent('vehicle:server:flipit')
AddEventHandler('vehicle:server:flipit', function()
    TriggerClientEvent('vehicle:flipit', source)
end)


QBCore.Functions.CreateCallback('police:server:isPlayerDead', function(source, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    cb(Player.PlayerData.metadata["isdead"] or Player.PlayerData.metadata["inlaststand"])
end)
