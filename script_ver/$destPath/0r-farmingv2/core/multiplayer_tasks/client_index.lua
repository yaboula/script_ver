local utils = require("modules.utils.client")

MultiplayerTasksClient = {}
MultiplayerTasksClient.modules = MultiplayerTasksClient.modules or {}
MultiplayerTasksClient.configs = MultiplayerTasksClient.configs or {}

local vehicleKeys = {}

function MultiplayerTasksClient.registerModuleState(moduleName, moduleState, config)
    if not config then
        config = {}
    end
    config.moduleName = moduleName
    MultiplayerTasksClient.modules[moduleName] = moduleState
    MultiplayerTasksClient.configs[moduleName] = config
end

function MultiplayerTasksClient.getModuleState(moduleName)
    return MultiplayerTasksClient.modules[moduleName]
end

function MultiplayerTasksClient.getModuleConfig(moduleName)
    local config = MultiplayerTasksClient.configs[moduleName]
    if not config then
        return nil
    end
    return lib.table.deepclone(config)
end

function MultiplayerTasksClient.start(moduleName, taskData)
    local moduleState = MultiplayerTasksClient.getModuleState(moduleName)
    if not moduleState or not moduleState.start then
        local errorMsg = "Module state for " .. moduleName .. " not found or does not have start function."
        lib.callback.await(_e("server:multiplayer_tasks:abort"), false, moduleName, client.lobby.id, errorMsg)
        return false
    end
    
    client.currentTask = taskData
    local result = moduleState.start()
    if not result then
        local errorMsg = "Module state for " .. moduleName .. " failed to start."
        lib.callback.await(_e("server:multiplayer_tasks:abort"), false, moduleName, client.lobby.id, errorMsg)
        return false
    end
    return true
end

function MultiplayerTasksClient.stop(moduleName, force)
    local moduleState = MultiplayerTasksClient.getModuleState(moduleName)
    if not moduleState or not moduleState.stop then
        lib.print.error("Module state for " .. moduleName .. " not found or does not have stop function.")
        return false
    end
    
    local taskData = lib.table.deepclone(client.currentTask or {})
    moduleState.stop()
    client.currentTask = nil
    client.exports.onTaskStopped(cache.serverId, taskData)
    
    for _, vehicleData in pairs(vehicleKeys) do
        utils.removeVehicleKey(vehicleData.plate, NetToVeh(vehicleData.netId))
    end
    vehicleKeys = {}
    return true
end

function MultiplayerTasksClient.onUnload()
    if not client.currentTask then
        return
    end
    MultiplayerTasksClient.stop(client.currentTask.moduleName, true)
end

function MultiplayerTasksClient.giveVehicleKey(plate, entity)
    if not plate or not entity then
        return
    end
    local vehicleData = {
        plate = plate,
        netId = VehToNet(entity),
    }
    table.insert(vehicleKeys, vehicleData)
    utils.giveVehicleKey(plate, entity)
end

RegisterNUICallback("nui:startMultiplayerTask", function(data, cb)
    if client.currentTask then
        client.sendReactAlert(locale("tasks.party_already_in_task"), "error")
        return cb(false)
    end
    
    local moduleName = data.moduleName
    local moduleState = MultiplayerTasksClient.getModuleState(moduleName)
    local moduleConfig = MultiplayerTasksClient.getModuleConfig(moduleName)
    
    if not moduleState or not moduleState.start then
        lib.print.error("Module state for " .. moduleName .. " not found or does not have start function.")
        cb(false)
        return
    end
    
    local result = lib.callback.await(_e("server:multiplayer_tasks:start"), false, moduleName, client.lobby.id)
    if not result then
        client.sendReactAlert(locale("tasks.start_failed"), "error")
        return cb(false)
    end
    
    if type(result) == "table" then
        if result.error then
            client.sendReactAlert(result.error, "error")
            return cb(false)
        end
    end
    
    client.hideUI()
    cb(true)
end)

RegisterNUICallback("nui:stopMultiplayerTask", function(data, cb)
    if not client.currentTask then
        return cb(false)
    end
    
    local moduleName = client.currentTask.moduleName
    local moduleState = MultiplayerTasksClient.getModuleState(moduleName)
    
    if not moduleState or not moduleState.stop then
        shared.debug("Module state for " .. moduleName .. " not found or does not have stop function.")
        return cb(false)
    end
    
    local result = lib.callback.await(_e("server:multiplayer_tasks:stop"), false, moduleName, client.lobby.id)
    if not result then
        client.sendReactAlert(locale("tasks.stop_failed"), "error")
        return cb(false)
    end
    
    if type(result) == "table" then
        if result.error then
            client.sendReactAlert(result.error, "error")
            return cb(false)
        end
    end
    
    client.hideUI()
    cb(true)
end)

RegisterNetEvent(_e("client:multiplayer_tasks:onTaskStarted"), function(moduleName, taskData)
    shared.debug("debug:client:multiplayer_tasks:onTaskStarted", moduleName)
    if not MultiplayerTasksClient.start(moduleName, taskData) then
        return
    end
    
    client.setInfoBoxDisabledState(false)
    client.sendReactMessage("ui:setCurrentTask", client.currentTask)
    client.sendReactMessage("ui:setInfoBox", {
        hidden = false,
        texts = client.currentTask.infoBoxTable,
    })
    client.sendReactMessage("ui:setProgressBox", true)
end)

RegisterNetEvent(_e("client:multiplayer_tasks:onTaskStopped"), function(moduleName)
    shared.debug("debug:client:multiplayer_tasks:onTaskStopped", moduleName)
    MultiplayerTasksClient.stop(moduleName)
    client.setInfoBoxDisabledState(true)
    client.sendReactMessage("ui:setInfoBox", nil)
    client.sendReactMessage("ui:setCurrentTask", nil)
    client.sendReactMessage("ui:setProgressBox", false)
    utils.notify(locale("tasks.stopped"), "success", 4000)
end)

RegisterNetEvent(_e("client:multiplayer_tasks:onTaskAborted"), function(moduleName, reason)
    shared.debug("debug:client:multiplayer_tasks:onTaskAborted", moduleName, reason)
    MultiplayerTasksClient.stop(moduleName, true)
    client.currentTask = nil
    client.setInfoBoxDisabledState(true)
    client.sendReactMessage("ui:setInfoBox", nil)
    client.sendReactMessage("ui:setCurrentTask", nil)
    client.sendReactMessage("ui:setProgressBox", false)
    utils.notify(locale("tasks.stopped"), "success", 4000)
    if reason then
        utils.notify(reason, "error", 4000)
    end
end)
