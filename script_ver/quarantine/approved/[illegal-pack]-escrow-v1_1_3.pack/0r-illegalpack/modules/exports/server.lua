local Utils = require 'modules.utils.server'

---@param lobby Lobby
---@param job Job
---@return boolean
---Called before a job starts in the given lobby.
---Return `true` to allow the job to start, or `false` to prevent it.
function server.exports.beforeJobStart(lobby, job)
    -- ?
    return true
end

---@param lobby Lobby
---@param job Job
---Called after a job has successfully started in the given lobby.
---Use this to initialize job-related server-side logic.
function server.exports.onJobStarted(lobby, job)
    -- ?
end

---@param lobby Lobby
---@param lastJob Job
---Called after a job has successfully stopped in the given lobby.
---Use this to finalize job data, give rewards, or clean up.
function server.exports.onJobStopped(lobby, lastJob)
    -- ?
end

--[[ Global Server Events ]]

---global event used to open the doors of a networked vehicle
---@param netId number
---@param door number
---@param open boolean
RegisterNetEvent('illegalpack:server:toggleEntityDoor', function(netId, door, open)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(entity) then return end

    local owner = NetworkGetEntityOwner(entity)
    TriggerClientEvent('illegalpack:client:toggleEntityDoor', owner, netId, door, open)
end)
