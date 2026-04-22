local playerCooldowns = {}
local activeTimers = {}

local function setPlayerCooldownForTask(source, moduleName, durationInSeconds)
    shared.debug("debug:setPlayerCooldownForTask", ("source: %s, moduleName: %s, durationInSeconds: %s"):format(source, moduleName, durationInSeconds))
    if not playerCooldowns[source] then
        playerCooldowns[source] = {}
    end
    playerCooldowns[source][moduleName] = os.time() + durationInSeconds
end

local function isPlayerOnCooldown(source, moduleName)
    if not playerCooldowns[source] then
        return false
    end
    local cooldownEnd = playerCooldowns[source][moduleName]
    if not cooldownEnd then
        return false
    end
    if cooldownEnd <= os.time() then
        playerCooldowns[source][moduleName] = nil
        if next(playerCooldowns[source]) == nil then
            playerCooldowns[source] = nil
        end
        return false
    end
    return true
end

local function startTaskTimer(lobbyId)
    if activeTimers[lobbyId] then
        return
    end
    activeTimers[lobbyId] = true
    Citizen.CreateThread(function()
        while true do
            local lobby = Lobby.getLobbyById(lobbyId)
            if not lobby then
                break
            end
            if not lobby.currentTask then
                break
            end
            if not lobby.currentTask then
                break
            end
            local moduleName = lobby.currentTask.moduleName
            if not moduleName then
                break
            end
            local timeLimit = lobby.currentTask.timeLimit
            if not timeLimit then
                break
            end
            if not lobby.currentTask.endTime then
                lobby.currentTask.endTime = os.time() + timeLimit
            end
            if lobby.currentTask.endTime <= os.time() then
                MultiplayerTasksServer.abort(nil, moduleName, lobbyId, locale("tasks.time_is_up"))
                break
            end
            lobby = Lobby.getLobbyById(lobbyId)
            if not lobby then
                break
            end
            if not lobby.currentTask then
                break
            end
            Citizen.Wait(1000)
        end
        activeTimers[lobbyId] = nil
    end)
end

MultiplayerTasksServer = {}
MultiplayerTasksServer.modules = MultiplayerTasksServer.modules or {}
MultiplayerTasksServer.configs = MultiplayerTasksServer.configs or {}

function MultiplayerTasksServer.registerModuleState(moduleName, moduleState, config)
    shared.debug("debug:MultiplayerTasksServer.registerModuleState", ("moduleName: %s"):format(moduleName))
    MultiplayerTasksServer.modules[moduleName] = moduleState
    MultiplayerTasksServer.configs[moduleName] = config
end

function MultiplayerTasksServer.getModuleState(moduleName)
    return MultiplayerTasksServer.modules[moduleName]
end

function MultiplayerTasksServer.getModuleConfig(moduleName)
    local config = MultiplayerTasksServer.configs[moduleName]
    if not config then
        return nil
    end
    return lib.table.deepclone(config)
end

function MultiplayerTasksServer.stop(source, moduleName, lobbyId, force)
    shared.debug("debug:MultiplayerTasksServer.stop", ("source: %s, moduleName: %s, lobbyId: %s, force: %s"):format(source, moduleName, lobbyId, force))
    local moduleState = MultiplayerTasksServer.getModuleState(moduleName)
    if not moduleState or not moduleState.stop then
        lib.print.error("Module state for " .. moduleName .. " not found or does not have stop function.")
        return false
    end
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    local taskData = lib.table.deepclone(lobby.currentTask or {})
    local result = moduleState.stop(source, lobbyId, force)
    if not result then
        return false
    end
    
    if not force then
        for _, member in pairs(lobby.members) do
            TriggerClientEvent(_e("client:multiplayer_tasks:onTaskStopped"), member.source, moduleName)
        end
    end
    
    lobby.currentTask = nil
    for _, member in pairs(lobby.members) do
        member.progress = 0
    end
    server.exports.onTaskStopped(lobby, taskData)
    return true
end

function MultiplayerTasksServer.abort(source, moduleName, lobbyId, reason)
    shared.debug("debug:MultiplayerTasksServer.abort", ("source: %s, moduleName: %s, lobbyId: %s, reason: %s"):format(source, moduleName, lobbyId, reason))
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    local taskData = lib.table.deepclone(lobby.currentTask or {})
    MultiplayerTasksServer.stop(source, moduleName, lobbyId, true)
    lobby.currentTask = nil
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:multiplayer_tasks:onTaskAborted"), member.source, moduleName, reason)
    end
    return true
end

function MultiplayerTasksServer.start(source, moduleName, lobbyId)
    shared.debug("debug:MultiplayerTasksServer.start", ("source: %s, moduleName: %s, lobbyId: %s"):format(source, moduleName, lobbyId))
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    local moduleState = MultiplayerTasksServer.getModuleState(moduleName)
    local moduleConfig = MultiplayerTasksServer.getModuleConfig(moduleName)
    
    local taskData = {
        moduleName = moduleName,
        startTime = os.time(),
        timeLimit = moduleConfig.timeLimit,
        infoBoxTable = moduleConfig.infoBoxTable or {},
        game = {},
    }
    lobby.currentTask = taskData
    
    if not server.exports.beforeTaskStart(lobby, lobby.currentTask) then
        return false
    end
    
    local result = moduleState.start(source, lobbyId)
    if not result then
        local errorMsg = "Module state for " .. moduleName .. " failed to start."
        MultiplayerTasksServer.abort(source, moduleName, lobbyId, errorMsg)
        return false
    end
    
    if type(result) == "table" then
        if result.error then
            MultiplayerTasksServer.abort(source, moduleName, lobbyId, result.error)
            return { error = result.error }
        end
    end
    
    for _, member in pairs(lobby.members) do
        Lobby.resetMemberProgress(lobbyId, member.source)
        TriggerClientEvent(_e("client:multiplayer_tasks:onTaskStarted"), member.source, moduleName, lobby.currentTask)
    end
    
    server.exports.onTaskStarted(lobby, lobby.currentTask)
    startTaskTimer(lobby.id)
    return true
end

function MultiplayerTasksServer.onUnload()
    shared.debug("debug:MultiplayerTasksServer.onUnload")
    local lobbies = Lobby.getAll()
    for _, lobby in pairs(lobbies) do
        if lobby.currentTask then
            MultiplayerTasksServer.stop(nil, lobby.currentTask.moduleName, lobby.id, true)
        end
    end
end

lib.callback.register(_e("server:multiplayer_tasks:start"), function(source, moduleName, lobbyId)
    local moduleState = MultiplayerTasksServer.getModuleState(moduleName)
    local moduleConfig = MultiplayerTasksServer.getModuleConfig(moduleName)
    
    if not moduleState or not moduleState.start then
        lib.print.error("Module state for " .. moduleName .. " not found or does not have start function.")
        return { error = "Module state not found or invalid." }
    end
    
    if not moduleConfig then
        lib.print.error("Module config for " .. moduleName .. " not found.")
        return { error = "Module config not found." }
    end
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        lobby = Lobby.create(source)
        TriggerClientEvent(_e("client:lobby:setPlayerLobby"), source, lobby)
    end
    
    if lobby.owner ~= source then
        return { error = locale("lobby.you_are_not_leader") }
    end
    
    if lobby.currentTask then
        return { error = locale("tasks.party_already_in_task") }
    end
    
    if moduleConfig.teamSize then
        if moduleConfig.teamSize.min then
            if #lobby.members < moduleConfig.teamSize.min then
                return { error = locale("tasks.not_enough_players", moduleConfig.teamSize.min) }
            end
        end
        if moduleConfig.teamSize.max then
            if #lobby.members > moduleConfig.teamSize.max then
                return { error = locale("tasks.too_many_players", moduleConfig.teamSize.max) }
            end
        end
    end
    
    for _, member in pairs(lobby.members) do
        if moduleConfig.requiredJobNames then
            if type(moduleConfig.requiredJobNames) == "string" then
                moduleConfig.requiredJobNames = { moduleConfig.requiredJobNames }
            end
            local job = server.getPlayerJob(member.source)
            if not moduleConfig.requiredJobNames[job.name] then
                return { error = locale("lobby.member_doesnot_have_required_job", member.name, table.concat(moduleConfig.requiredJobNames, ", ")) }
            end
        end
        
        if moduleConfig.requiredLevel then
            if member.level < moduleConfig.requiredLevel then
                return { error = locale("lobby.member_doesnot_have_required_level", member.name, moduleConfig.requiredLevel) }
            end
        end
        
        if isPlayerOnCooldown(member.source, moduleName) then
            return { error = locale("lobby.member_is_cooldown", member.name) }
        end
    end
    
    local result = MultiplayerTasksServer.start(source, moduleName, lobby.id)
    if not result then
        return false
    end
    
    if type(result) == "table" then
        if result.error then
            return { error = result.error }
        end
    end
    
    return true
end)

lib.callback.register(_e("server:multiplayer_tasks:abort"), function(source, moduleName, lobbyId, reason)
    return MultiplayerTasksServer.abort(source, moduleName, lobbyId, reason)
end)

lib.callback.register(_e("server:multiplayer_tasks:stop"), function(source, moduleName, lobbyId)
    if not moduleName or not lobbyId then
        lib.print.error("Module name or lobby ID is missing.")
        return false
    end
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        lib.print.error("Lobby with ID " .. lobbyId .. " not found.")
        return false
    end
    
    if not lobby.currentTask then
        lib.print.error("Current task does not match the module name or is not set.")
        return false
    end
    
    if lobby.owner ~= source then
        lib.print.error("Only the lobby owner or an admin can stop the task.")
        return false
    end
    
    return MultiplayerTasksServer.stop(source, moduleName, lobbyId)
end)
