--[[ Contains server-side helper functions. ]]

local Utils = {}

function Utils.getPoliceCount()
    local count = 0
    for _, playerId in pairs(GetPlayers()) do
        local xPlayerJob = server.getPlayerJob(tonumber(playerId))
        if xPlayerJob and Config.PoliceJobName[string.lower(xPlayerJob.name)] then
            count = count + 1
        end
    end
    return count
end

---@param source number
---@param title string
---@param type string
---@param description string
---@param duration number
function Utils.server_notify(source, title, type, description, duration)
    TriggerClientEvent('client:illegalpack:notify', source, title, type, description, duration)
end

---@param params any
---@return number, number
function Utils.spawnVehicle(params)
    local model = params.model
    local coords = params.coords
    local radius = params.radius or 3.0

    if type(coords) == 'vector3' then
        coords = vector4(coords.x, coords.y, coords.z, 0)
    end

    local veh = CreateVehicle(model, coords.x, coords.y, coords.z + 1.0, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end

    SetEntityCoords(veh, coords.x, coords.y, coords.z, false, false, false, true)

    local netId = NetworkGetNetworkIdFromEntity(veh)

    return netId, veh
end

return Utils
