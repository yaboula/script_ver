local lib = lib
local config = lib.load("core.multiplayer_tasks.freelance.config")
local inventoryModule = require("modules.inventory.server")
local moduleName = "freelance"

FreelanceServer = {}

local PointState = {}
PointState.EMPTY = "empty"
PointState.PLANTED = "planted"
PointState.WATERED = "watered"
PointState.GROWN = "grown"
PointState.HARVESTED = "harvested"

local fieldStates = {}

local function getFieldConfig(fieldId)
    return config.fields[fieldId]
end

local function deleteEntities(networkIds)
    if type(networkIds) ~= "table" then
        networkIds = {networkIds}
    end
    
    if #networkIds == 0 then
        return false
    end
    
    for _, networkId in ipairs(networkIds) do
        local entity = NetworkGetEntityFromNetworkId(networkId)
        if DoesEntityExist(entity) then
            DeleteEntity(entity)
    end
  end
    
    return true
end

local function setFieldState(fieldId, lobbyId, isOccupied)
    if fieldId then
        local fieldConfig = getFieldConfig(fieldId)
        if not fieldConfig then
            return
        end
    else
        return
    end
    
    if false == isOccupied then
        isOccupied = nil
    end
    
    fieldStates[fieldId] = isOccupied and lobbyId or nil
end

local function getFreeField(lobbyId)
    for fieldId, fieldConfig in pairs(config.fields) do
        local state = fieldStates[fieldId]
        if nil == state then
            setFieldState(fieldId, lobbyId, true)
            return fieldId, fieldConfig
        end
    end
    return nil, nil
end

local function generatePlantingPoints(fieldConfig)
    local points = {}
    local center = fieldConfig.center
    local radius = fieldConfig.radius or 50
    local spacing = 5.0
    local rotation = math.rad(fieldConfig.rotation or 0)
    local maxPoints = fieldConfig.maxPoints or 100
    
    table.insert(points, {
        coords = vector3(center.x, center.y, center.z)
    })
    
    if maxPoints <= #points then
        return points
    end
    
    local ring = 1
  while true do
        local ringRadius = ring * spacing
        if not (radius >= ringRadius) then
      break
    end
        if not (maxPoints > #points) then
      break
    end
        
        for x = -ring, ring, 1 do
            if maxPoints <= #points then
        break
      end
            local xOffset = x * spacing
            for y = -ring, ring, 1 do
                if maxPoints <= #points then
          break
        end
                local yOffset = y * spacing
                if xOffset == 0 and yOffset == 0 then
                    -- Skip center point
                else
                    local absX = math.abs(xOffset)
                    local ringRadiusCheck = ring * spacing
                    if absX ~= ringRadiusCheck then
                        local absY = math.abs(yOffset)
                        if absY ~= ringRadiusCheck then
                            -- Skip this point
                        else
                            local rotatedX = xOffset * math.cos(rotation) - yOffset * math.sin(rotation)
                            local rotatedY = xOffset * math.sin(rotation) + yOffset * math.cos(rotation)
                            local newX = center.x + rotatedX
                            local newY = center.y + rotatedY
                            local distance = math.sqrt(rotatedX ^ 2 + rotatedY ^ 2)
                            
                            if radius >= distance then
                                table.insert(points, {
                                    coords = vector3(newX, newY, center.z)
                                })
                            end
      end
    else
                        local rotatedX = xOffset * math.cos(rotation) - yOffset * math.sin(rotation)
                        local rotatedY = xOffset * math.sin(rotation) + yOffset * math.cos(rotation)
                        local newX = center.x + rotatedX
                        local newY = center.y + rotatedY
                        local distance = math.sqrt(rotatedX ^ 2 + rotatedY ^ 2)
                        
                        if radius >= distance then
                            table.insert(points, {
                                coords = vector3(newX, newY, center.z)
                            })
                        end
            end
          end
        end
    end
        ring = ring + 1
    end
    return points
end

function FreelanceServer.updatePlantingPointState(playerId, lobbyId, updateData)
    local lobby = Lobby.getLobbyById(lobbyId)
    local meta = {}
    local point = lobby.currentTask.game.plantingPoints[updateData.pointIndex]
    
    if updateData.newState then
        point.state = updateData.newState
    end
    
    if updateData.cropName then
        point.cropName = updateData.cropName
    end
    
    local pointObjectNetId = lobby.currentTask.game.pointObjectNetIds[updateData.pointIndex]
    
    if updateData.newState == PointState.WATERED then
        local owner = nil
        if pointObjectNetId then
            owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(pointObjectNetId))
        end
        if owner then
            TriggerClientEvent(_e("client:freelance:playWateringEffect"), owner, {
                pointIndex = updateData.pointIndex,
                cropName = updateData.cropName,
                networkId = pointObjectNetId,
                newState = updateData.newState,
                lobbyId = lobbyId
            })
        end
    elseif updateData.newState == PointState.GROWN then
        local owner = nil
        if pointObjectNetId then
            owner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(pointObjectNetId))
        end
        if owner then
            TriggerClientEvent(_e("client:freelance:playGrowthEffect"), owner, {
                pointIndex = updateData.pointIndex,
                cropName = updateData.cropName,
                networkId = pointObjectNetId,
                newState = updateData.newState,
                lobbyId = lobbyId
            })
        end
    elseif updateData.newState == PointState.HARVESTED then
        Lobby.incMemberProgress(lobbyId, playerId)
        
        if pointObjectNetId then
            deleteEntities(pointObjectNetId)
            lobby.currentTask.game.pointObjectNetIds[updateData.pointIndex] = nil
        end
        
        lobby.currentTask.game.harvesterState.grainLevel = math.min(100, lobby.currentTask.game.harvesterState.grainLevel + 2)
        lobby.currentTask.game.harvesterState.harvestedBaleState.harvestedCount = lobby.currentTask.game.harvesterState.harvestedBaleState.harvestedCount + 1
        
        if lobby.currentTask.game.harvesterState.harvestedBaleState.harvestedCount % 8 == 0 then
            if updateData.cropName then
                local baleData = lib.callback.await(_e("client:freelance:spawnHarvestedBale"), playerId, {
                    lobbyId = lobbyId,
                    pointIndex = updateData.pointIndex,
                    cropName = updateData.cropName
                })
                if baleData then
                    meta.harvestedBale = {
                        netId = baleData.netId,
                        coords = baleData.coords
                    }
                    lobby.currentTask.game.harvesterState.harvestedBaleState.createdBales[updateData.pointIndex] = {
                        netId = baleData.netId,
                        cropName = updateData.cropName
                    }
          end
        end
      end
        
        meta.grainLevel = lobby.currentTask.game.harvesterState.grainLevel
        point = {
            coords = point.coords
        }
    end
    
    PersonalChallengesServer.onFarmingActionTriggered(playerId, updateData.cropName, updateData.newState)
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:freelance:onPlantingPointUpdate"), member.source, {
            playerId = playerId,
            lobbyId = lobbyId,
            pointIndex = updateData.pointIndex,
            cropName = updateData.cropName,
            newState = updateData.newState,
            networkId = pointObjectNetId,
            meta = meta
        })
    end
    
    shared.debug("debug:FreelanceServer.updatePlantingPointState", ("playerId: %s, lobbyId: %s, pointIndex: %s, cropName: %s, newState: %s"):format(playerId, lobbyId, updateData.pointIndex, updateData.cropName, updateData.newState), lobby.currentTask.game.plantingPoints[updateData.pointIndex])
end

function FreelanceServer.start(source, lobbyId)
    shared.debug("debug:FreelanceServer.start", ("source: %s, lobbyId: %s"):format(source, lobbyId))
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    local fieldId, fieldConfig = getFreeField(lobbyId)
    if not fieldId then
        shared.debug(("debug:No free farming field available for lobbyId: %s"):format(lobbyId), "error")
        return {
            error = locale("no_free_field")
        }
    end
    
    lobby.currentTask.game = {
        fieldId = fieldId,
        taskEntities = {
            tractor = {},
            seeder = {},
            harvester = {},
            trailer = {}
        },
        plantingPoints = generatePlantingPoints(fieldConfig),
        harvesterState = {
            grainLevel = 0,
            lastGrainUnloadingStartTime = nil,
            harvestedBaleState = {
                harvestedCount = 0,
                loadedCount = 0,
                attachedBales = {},
                createdBales = {}
            }
        },
        pointObjectNetIds = {}
    }
    return true
end

function FreelanceServer.stop(source, lobbyId, force)
    shared.debug("debug:FreelanceServer.stop", ("source: %s, lobbyId: %s, force: %s"):format(source, lobbyId, force))
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    if lobby.currentTask then
        local networkIdsToDelete = {}
        
        if lobby.currentTask.game.taskEntities then
            for _, entityType in pairs(lobby.currentTask.game.taskEntities) do
                for _, entity in pairs(entityType) do
                    if entity.spawned and entity.netId then
                        table.insert(networkIdsToDelete, entity.netId)
          end
        end
      end
    end
        
        if lobby.currentTask.game.harvesterState then
            if lobby.currentTask.game.harvesterState.harvestedBaleState then
                if lobby.currentTask.game.harvesterState.harvestedBaleState.attachedBales then
                    for _, bale in pairs(lobby.currentTask.game.harvesterState.harvestedBaleState.attachedBales) do
                        table.insert(networkIdsToDelete, bale.netId)
      end
    end
    end
        end
        
        if lobby.currentTask.game.harvesterState then
            if lobby.currentTask.game.harvesterState.harvestedBaleState then
                if lobby.currentTask.game.harvesterState.harvestedBaleState.createdBales then
                    for _, bale in pairs(lobby.currentTask.game.harvesterState.harvestedBaleState.createdBales) do
                        table.insert(networkIdsToDelete, bale.netId)
          end
        end
      end
    end
        
        if lobby.currentTask.game.pointObjectNetIds then
            for _, netId in pairs(lobby.currentTask.game.pointObjectNetIds) do
                table.insert(networkIdsToDelete, netId)
            end
        end
        
        if #networkIdsToDelete > 0 then
            deleteEntities(networkIdsToDelete)
        end
        
        if lobby.currentTask.game.fieldId then
            setFieldState(lobby.currentTask.game.fieldId, lobbyId, false)
        end
        
        lobby.currentTask.game = {}
    end
    
    return true
end

lib.callback.register(_e("server:freelance:onVehicleSpawned"), function(source, lobbyId, entityState)
    if not entityState or not entityState.key or not entityState.index then
        shared.debug("debug:FreelanceServer.onVehicleSpawned - Invalid entityState", ("source: %s, lobbyId: %s, entityState: %s"):format(source, lobbyId, json.encode(entityState)), "error")
        return false
    end
    
    shared.debug("debug:FreelanceServer.onVehicleSpawned", ("source: %s, lobbyId: %s, key: %s"):format(source, lobbyId, entityState.key))
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    if not lobby.currentTask or not lobby.currentTask.game or not lobby.currentTask.game.fieldId then
        return {
            error = locale("tasks.no_active_task")
        }
    end
    
    if lobby.owner ~= source then
        shared.debug("debug:FreelanceServer.onVehicleSpawned - Unauthorized access", ("source: %s, lobbyId: %s, key: %s"):format(source, lobbyId, entityState.key), "error")
        return false
    end
    
    if lobby.currentTask.game.taskEntities[entityState.key] then
        lobby.currentTask.game.taskEntities[entityState.key][entityState.index] = entityState
    end
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:freelance:onVehicleSpawned"), member.source, entityState)
    end
    
    return true
end)

lib.callback.register(_e("server:freelance:dropHarvestedBale"), function(source, data)
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
        return {
            error = locale("lobby.not_in_lobby")
        }
    end
    
    if lobby.currentTask.game.harvesterState.harvestedBaleState.loadedCount == 0 then
        return {
            error = locale("freelance.trailer_empty")
        }
    end
    
    local playerCoords = GetEntityCoords(GetPlayerPed(source))
    local dropCoords = vector3(getFieldConfig(lobby.currentTask.game.fieldId).dropHarvestedBaleCoords)
    local distance = #(playerCoords - dropCoords)
    if distance > 15.0 then
        -- Too far from drop location
    end
    
    local attachedBales = lobby.currentTask.game.harvesterState.harvestedBaleState.attachedBales
    local networkIdsToDelete = {}
    for _, bale in pairs(attachedBales) do
        table.insert(networkIdsToDelete, bale.netId)
    end
    deleteEntities(networkIdsToDelete)
    
    for _, bale in pairs(attachedBales) do
        local cropName = bale.cropName
        local cropConfig = config.crops[cropName]
        local harvestAmount = cropConfig and cropConfig.harvestAmount or 1
        local harvestItem = cropConfig and cropConfig.harvestItem or nil
        if harvestItem then
            inventoryModule.giveItem(source, harvestItem, harvestAmount)
    end
  end
    
    lobby.currentTask.game.harvesterState.harvestedBaleState.attachedBales = {}
    lobby.currentTask.game.harvesterState.harvestedBaleState.loadedCount = 0
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:freelance:onHarvestedBaleDropped"), member.source, {
            lobbyId = data.lobbyId
        })
    end
    
    return true
end)

RegisterNetEvent(_e("server:freelance:onPlantingPointStateChanged"), function(data)
    local source = source
    if not data or not data.lobbyId or not data.pointIndex or not data.newState then
        shared.debug(("Invalid point state update data from source: %s, lobbyId: %s, pointIndex: %s, state: %s"):format(source, data.lobbyId, data.pointIndex, data.newState), "error")
        return
    end
    
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
        shared.debug(("Player not in lobby or lobby not found: %s, %s"):format(source, data.lobbyId), "error")
        return
    end
    
    if not lobby.currentTask then
        shared.debug(("Lobby current task not found for lobbyId: %s"):format(data.lobbyId), "error")
        return
    end
    
    FreelanceServer.updatePlantingPointState(source, data.lobbyId, data)
    shared.debug("debug:FreelanceServer.onPlantingPointStateChanged", ("source: %s, lobbyId: %s, pointIndex: %s, state: %s"):format(source, data.lobbyId, data.pointIndex, data.newState))
end)

RegisterNetEvent(_e("server:freelance:onHarvestedBalePickedUp"), function(data)
    local source = source
    if not data or not data.lobbyId or not data.pointIndex then
        return
    end
    
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
        return
    end
    
    local baleData = lobby.currentTask.game.harvesterState.harvestedBaleState.createdBales[data.pointIndex]
    if baleData then
        deleteEntities({baleData.netId})
    end
    
    for _, member in pairs(lobby.members) do
        if member.source ~= source then
            TriggerClientEvent(_e("client:freelance:onHarvestedBalePickedUp"), member.source, data)
    end
  end
end)

RegisterNetEvent(_e("server:freelance:loadHarvestedBaleToTrailer"), function(data)
    local source = source
    if not data or not data.lobbyId or not data.trailerNetId then
    return
  end
    
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    return
  end
    
    local trailer = NetworkGetEntityFromNetworkId(data.trailerNetId)
    if not DoesEntityExist(trailer) then
    return
  end
    
    local owner = NetworkGetEntityOwner(trailer)
    if not owner or owner == 0 then
    return
  end
    
    local point = lobby.currentTask.game.plantingPoints[data.pointIndex]
    lobby.currentTask.game.harvesterState.harvestedBaleState.loadedCount = lobby.currentTask.game.harvesterState.harvestedBaleState.loadedCount + 1
    
    local baleNetId = lib.callback.await(_e("client:freelance:attachHarvestedBaleToTrailer"), owner, {
        lobbyId = data.lobbyId,
        trailerNetId = data.trailerNetId,
        loadedCount = lobby.currentTask.game.harvesterState.harvestedBaleState.loadedCount,
        cropName = point.cropName
    })
    
    if not baleNetId then
    return
  end
    
    table.insert(lobby.currentTask.game.harvesterState.harvestedBaleState.attachedBales, {
        netId = baleNetId,
        cropName = point.cropName
    })
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:freelance:onHarvestedBaleAttached"), member.source, {
            lobbyId = data.lobbyId,
            harvestedBaleNetId = baleNetId,
            trailerNetId = data.trailerNetId,
            loadedCount = lobby.currentTask.game.harvesterState.harvestedBaleState.loadedCount
        })
    end
end)

lib.callback.register(_e("server:freelance:onGrainUnloadingStarted"), function(source, lobbyId)
    if not lobbyId then
        return false
    end
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    if not lobby.currentTask or not lobby.currentTask.game or not lobby.currentTask.game.harvesterState then
        return false
    end
    
    if lobby.currentTask.game.harvesterState.grainLevel <= 0 then
        return false
    end
    
    if not lobby.currentTask.game.harvesterState.lastGrainUnloadingStartTime then
        lobby.currentTask.game.harvesterState.lastGrainUnloadingStartTime = os.time()
    end
    
    return true
end)

lib.callback.register(_e("server:freelance:onGrainUnloadingStopped"), function(source, lobbyId)
    if not lobbyId then
        return false
    end
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    if not lobby.currentTask or not lobby.currentTask.game or not lobby.currentTask.game.harvesterState then
        return false
    end
    
    lobby.currentTask.game.harvesterState.lastGrainUnloadingStartTime = nil
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:freelance:onGrainLevelChanged"), member.source, {
            lobbyId = lobbyId,
            grainLevel = lobby.currentTask.game.harvesterState.grainLevel
        })
    end
    
    return true
end)

RegisterNetEvent(_e("server:freelance:fetchGrainLevel"), function(data)
    if not data or not data.lobbyId then
        return
    end
    
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby then
        return
    end
    
    if lobby.currentTask.game.harvesterState.lastGrainUnloadingStartTime then
        lobby.currentTask.game.harvesterState.grainLevel = math.max(0, lobby.currentTask.game.harvesterState.grainLevel - 1)
    end
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:freelance:onGrainLevelChanged"), member.source, {
            lobbyId = data.lobbyId,
            grainLevel = lobby.currentTask.game.harvesterState.grainLevel
        })
    end
end)

RegisterNetEvent(_e("server:freelance:onSeederCropSelected"), function(data)
    local source = source
    if not data or not data.lobbyId or not data.cropName then
        return
    end
    
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
        return
    end
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:freelance:onSeederCropSelected"), member.source, {
            lobbyId = data.lobbyId,
            cropName = data.cropName
        })
    end
end)

lib.callback.register(_e("server:freelance:registerPointObject"), function(source, data)
    if not data or not data.lobbyId or not data.pointIndex or not data.networkId then
        return
    end
    
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
        return
    end
    
    if not lobby.currentTask or not lobby.currentTask.game then
    return
  end
    
    lobby.currentTask.game.pointObjectNetIds[data.pointIndex] = data.networkId
    shared.debug("debug:FreelanceServer.registerPointObject", ("pointIndex: %s, networkId: %s, cropName: %s"):format(data.pointIndex, data.networkId, data.cropName))
end)

RegisterNetEvent(_e("server:freelance:deletePointObject"), function(data)
    local source = source
    if not data or not data.lobbyId or not data.pointIndex then
        return
    end
    
    local lobby = Lobby.getLobbyById(data.lobbyId)
    if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
        return
    end
    
    if not lobby.currentTask or not lobby.currentTask.game then
        return
    end
    
    local netId = lobby.currentTask.game.pointObjectNetIds[data.pointIndex]
    if netId then
        deleteEntities(netId)
        lobby.currentTask.game.pointObjectNetIds[data.pointIndex] = nil
        shared.debug("debug:FreelanceServer.deletePointObject", ("pointIndex: %s, networkId: %s"):format(data.pointIndex, netId))
    end
end)

if MultiplayerTasksServer then
    if MultiplayerTasksServer.registerModuleState then
        MultiplayerTasksServer.registerModuleState("freelance", FreelanceServer, config)
  end
end
