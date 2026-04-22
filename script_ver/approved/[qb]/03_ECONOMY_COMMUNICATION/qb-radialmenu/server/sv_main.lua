local QBCore = exports['qb-core']:GetCoreObject()


local trunkBusy = {}

RegisterServerEvent('qb-trunk:server:setTrunkBusy')
AddEventHandler('qb-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

QBCore.Functions.CreateCallback('qb-trunk:server:getTrunkBusy', function(source, cb, plate)
    if trunkBusy[plate] then
        cb(true)
    end
    cb(false)
end)

RegisterServerEvent('qb-trunk:server:KidnapTrunk')
AddEventHandler('qb-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    TriggerClientEvent('qb-trunk:client:KidnapGetIn', targetId, closestVehicle)
end)

RegisterNetEvent('vehicle:flipit')
AddEventHandler('vehicle:flipit', function()
	TriggerClientEvent('vehicle:flipit')
end)


QBCore.Functions.CreateCallback('police:server:isPlayerDead', function(source, cb, playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    cb(Player.PlayerData.metadata["isdead"] or Player.PlayerData.metadata["inlaststand"])
end)
