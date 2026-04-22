local Utils = require 'modules.utils.client'

---@param source number
---@param job Job
---@return boolean
---Called before a job starts.
---Return `true` to allow the job to start, or `false` to block it.
function client.exports.beforeJobStart(source, job)
    -- ?
    return true
end

---@param source number
---@param job Job
---Called after a job has successfully started.
---You can use this to set up job data, targets, or notify the player.
function client.exports.onJobStarted(source, job)
    -- ?
end

---@param source number
---@param lastJob Job
---Called after a job has been successfully stopped.
---Use this to clean up, give rewards, or log the completion.
function client.exports.onJobStopped(source, lastJob)
    -- ?
end

exports("activeJob", function()
    return client.currentJob
end)

--[[ Global Client Events ]]

---global event used to open the doors of a networked vehicle
---@param netId number
---@param door number
---@param open boolean
RegisterNetEvent('illegalpack:client:toggleEntityDoor', function(netId, door, open)
    local entity = NetToVeh(netId)
    for _, d in pairs(type(door) == 'table' and door or { door }) do
        (open and SetVehicleDoorOpen or SetVehicleDoorShut)(entity, d, false, false)
    end
end)
