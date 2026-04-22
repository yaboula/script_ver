local lib = lib
local config = lib.load("core.multiplayer_tasks.melon_pumpkin.config")
local inventoryModule = require("modules.inventory.server")
local moduleName = "melon_pumpkin"
local MelonPumpkinServer = {}

local PlantingPointStates = {}
PlantingPointStates.EMPTY = "empty"
PlantingPointStates.RAKED = "raked"
PlantingPointStates.PLANTED = "planted"
PlantingPointStates.WATERED = "watered"
PlantingPointStates.GROWN = "grown"
PlantingPointStates.HARVESTED = "harvested"

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
  if not fieldId then
    return
  end
  
  if false == isOccupied then
    isOccupied = nil
  end
  
  fieldStates[fieldId] = (isOccupied and lobbyId) or nil
end

local function getFreeField(lobbyId)
  for fieldId, fieldConfig in pairs(config.fields) do
    if fieldStates[fieldId] == nil then
      setFieldState(fieldId, lobbyId, true)
      return fieldId, fieldConfig
    end
  end
  return nil, nil
end

local function generatePlantingPointsInCircle(fieldConfig)
  local points = {}
  local center = fieldConfig.center
  local radius = fieldConfig.radius or 50
  local spacing = 3.0
  local rotation = math.rad(fieldConfig.rotation or 0)
  local maxPoints = fieldConfig.maxPoints or 100
  
  points[#points + 1] = {
    coords = vector3(center.x, center.y, center.z)
  }
  
  if maxPoints <= #points then
    return points
  end
  
  local ring = 1
  while radius >= ring * spacing and maxPoints > #points do
    for xOffset = -ring, ring, 1 do
      if maxPoints <= #points then
        break
      end
      
      local x = xOffset * spacing
      
      for yOffset = -ring, ring, 1 do
        if maxPoints <= #points then
          break
        end
        
        local y = yOffset * spacing
        
        if not (y == 0 and x == 0) then
          if math.abs(y) == ring * spacing or math.abs(x) == ring * spacing then
            local rotatedX = x * math.cos(rotation) - y * math.sin(rotation)
            local rotatedY = x * math.sin(rotation) + y * math.cos(rotation)
            local worldX = center.x + rotatedX
            local worldY = center.y + rotatedY
            local distance = math.sqrt(rotatedX ^ 2 + rotatedY ^ 2)
            
            if radius >= distance then
              points[#points + 1] = {
                coords = vector3(worldX, worldY, center.z)
              }
            end
          end
        end
      end
    end
    
    ring = ring + 1
  end
  
  return points
end

local function updatePlantingPointState(source, lobbyId, data)
  local lobby = Lobby.getLobbyById(lobbyId)
  local meta = {}
  local point = lobby.currentTask.game.plantingPoints[data.pointIndex]
  
  if data.newState then
    point.state = data.newState
  end
  
  if data.cropName then
    point.cropName = data.cropName
  end
  
  local pointObjectNetId = lobby.currentTask.game.pointObjectNetIds[data.pointIndex]
  
  if data.newState == PlantingPointStates.HARVESTED then
    Lobby.incMemberProgress(lobbyId, source)
    
    local netIds = lobby.currentTask.game.pointObjectNetIds[data.pointIndex]
    if netIds then
      deleteEntities(netIds)
      lobby.currentTask.game.pointObjectNetIds[data.pointIndex] = nil
    end
  elseif data.newState == PlantingPointStates.WATERED then
    local entityOwner = nil
    if pointObjectNetId then
      entityOwner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(pointObjectNetId))
    end
    
    if entityOwner then
      TriggerClientEvent(_e("client:melon_pumpkin:playWateringEffect"), entityOwner, {
        lobbyId = lobbyId,
        pointIndex = data.pointIndex,
        cropName = data.cropName,
        networkId = pointObjectNetId
      })
    end
  elseif data.newState == PlantingPointStates.GROWN then
    local entityOwner = nil
    if pointObjectNetId then
      entityOwner = NetworkGetEntityOwner(NetworkGetEntityFromNetworkId(pointObjectNetId))
    end
    
    if entityOwner then
      TriggerClientEvent(_e("client:melon_pumpkin:playGrowthEffect"), entityOwner, {
        lobbyId = lobbyId,
        pointIndex = data.pointIndex,
        cropName = data.cropName,
        networkId = pointObjectNetId,
        newState = data.newState
      })
    end
  end
  
  PersonalChallengesServer.onFarmingActionTriggered(source, data.cropName, data.newState)
  
  for _, member in pairs(lobby.members) do
    TriggerClientEvent(_e("client:melon_pumpkin:onPlantingPointUpdate"), member.source, {
      playerId = source,
      lobbyId = lobbyId,
      pointIndex = data.pointIndex,
      cropName = data.cropName,
      newState = data.newState,
      networkId = pointObjectNetId,
      meta = meta
    })
  end
  
  shared.debug("debug:MelonPumpkinServer.updatePlantingPointState", 
    ("playerId: %s, lobbyId: %s, pointIndex: %s, cropName: %s, newState: %s"):format(source, lobbyId, data.pointIndex, data.cropName, data.newState),
    lobby.currentTask.game.plantingPoints[data.pointIndex])
end

function MelonPumpkinServer.start(source, lobbyId)
  shared.debug("debug:MelonPumpkinServer.start", ("source: %s, lobbyId: %s"):format(source, lobbyId))
  
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
    taskEntities = {},
    plantingPoints = generatePlantingPointsInCircle(fieldConfig),
    harvestedCropState = {
      harvestedPoints = {},
      loadedCount = 0,
      objectsInDeliveryVehicle = {}
    },
    pointObjectNetIds = {},
    selectedCropName = nil
  }
  
  return true
end

function MelonPumpkinServer.stop(source, lobbyId, force)
  shared.debug("debug:MelonPumpkinServer.stop", ("source: %s, lobbyId: %s, force: %s"):format(source, lobbyId, force))
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if lobby.currentTask then
    local netIds = {}
    
    if lobby.currentTask.game.taskEntities then
      for _, entity in pairs(lobby.currentTask.game.taskEntities or {}) do
        if entity.spawned and entity.netId then
          table.insert(netIds, entity.netId)
        end
      end
    end
    
    if lobby.currentTask.game.harvestedCropState then
      if lobby.currentTask.game.harvestedCropState.objectsInDeliveryVehicle then
        for _, networkId in pairs(lobby.currentTask.game.harvestedCropState.objectsInDeliveryVehicle) do
          table.insert(netIds, networkId)
        end
      end
    end
    
    if lobby.currentTask.game.pointObjectNetIds then
      for _, networkId in pairs(lobby.currentTask.game.pointObjectNetIds) do
        table.insert(netIds, networkId)
      end
    end
    
    if #netIds > 0 then
      deleteEntities(netIds)
    end
    
    if lobby.currentTask.game.fieldId then
      setFieldState(lobby.currentTask.game.fieldId, lobbyId, false)
    end
    
    lobby.currentTask.game = {}
  end
  
  return true
end

lib.callback.register(_e("server:melon_pumpkin:onVehicleSpawned"), function(source, lobbyId, entityState)
  if not entityState or not entityState.key then
    shared.debug("debug:MelonPumpkinServer.onVehicleSpawned - Invalid entityState", 
      ("source: %s, lobbyId: %s, entityState: %s"):format(source, lobbyId, json.encode(entityState)), "error")
    return false
  end
  
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
    shared.debug("debug:MelonPumpkinServer.onVehicleSpawned - Unauthorized access", 
      ("source: %s, lobbyId: %s, key: %s"):format(source, lobbyId, entityState.key), "error")
    return false
  end
  
  local taskEntities = lobby.currentTask.game.taskEntities
  if taskEntities[entityState.key] then
    return false
  end
  
  taskEntities[entityState.key] = entityState
  
  shared.debug("debug:MelonPumpkinServer.onVehicleSpawned", 
    ("source: %s, lobbyId: %s, key: %s"):format(source, lobbyId, entityState.key))
  
  for _, member in pairs(lobby.members) do
    TriggerClientEvent(_e("client:melon_pumpkin:onVehicleSpawned"), member.source, entityState)
  end
  
  return true
end)

lib.callback.register(_e("server:melon_pumpkin:onSellNpcInteraction"), function(source, data)
  if not data or not data.lobbyId then
    shared.debug("debug:MelonPumpkinServer.onSellNpcInteraction - Invalid data", 
      ("source: %s, lobbyId: %s"):format(source, data.lobbyId), "error")
    return false
  end
  
  local lobby = Lobby.getLobbyById(data.lobbyId)
  if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    shared.debug(("Player not in lobby or lobby not found: %s, %s"):format(source, data.lobbyId), "error")
    return false
  end
  
  local selectedCropName = lobby.currentTask.game.selectedCropName
  if not selectedCropName then
    shared.debug(("Crop name not found for lobbyId: %s, crop: %s"):format(data.lobbyId, selectedCropName), "error")
    return false
  end
  
  local sellPrice = config.crops[selectedCropName].sellPrice
  if not sellPrice then
    shared.debug(("Crop not found: %s"):format(selectedCropName), "error")
    return false
  end
  
  local loadedCount = lobby.currentTask.game.harvestedCropState.loadedCount
  if loadedCount < 1 then
    shared.debug(("No crops loaded for lobbyId: %s"):format(data.lobbyId), "error")
    return {
      error = locale("melon_pumpkin.no_crops_loaded")
    }
  end
  
  local totalPrice = sellPrice * loadedCount
  
  if Config.CleanMoney.isItem then
    local itemName = Config.CleanMoney.itemName
    inventoryModule.giveItem(source, itemName, totalPrice)
  else
    local accountName = Config.CleanMoney.accountName
    server.playerAddMoney(source, accountName, totalPrice)
  end
  
  local objectsInVehicle = lobby.currentTask.game.harvestedCropState.objectsInDeliveryVehicle
  deleteEntities(objectsInVehicle)
  lobby.currentTask.game.harvestedCropState.objectsInDeliveryVehicle = {}
  
  return true
end)

RegisterNetEvent(_e("server:melon_pumpkin:onPlantingPointStateChanged"), function(data)
  local source = source
  
  if not data or not data.lobbyId or not data.pointIndex or not data.newState then
    shared.debug(("Invalid point state update data from source: %s, lobbyId: %s, pointIndex: %s, state: %s"):format(
      source, data.lobbyId, data.pointIndex, data.newState), "error")
    return
  end
  
  local lobby = Lobby.getLobbyById(data.lobbyId)
  if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    shared.debug(("Player not in lobby or lobby not found: %s, %s"):format(source, data.lobbyId), "error")
    return
  end
  
  if not lobby.currentTask then
    shared.debug(("Lobby current task not found for lobbyId: %s"):format(lobbyId), "error")
    return
  end
  
  updatePlantingPointState(source, data.lobbyId, data)
  
  shared.debug("debug:MelonPumpkinServer.onPlantingPointStateChanged", 
    ("source: %s, lobbyId: %s, pointIndex: %s, state: %s"):format(source, data.lobbyId, data.pointIndex, data.newState))
end)

RegisterNetEvent(_e("server:melon_pumpkin:loadHarvestedCropToDeliveryVehicle"), function(data)
  local source = source
  
  if not data or not data.lobbyId or not data.deliveryVehicleNetId then
    return
  end
  
  local lobby = Lobby.getLobbyById(data.lobbyId)
  if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    return
  end
  
  local vehicle = NetworkGetEntityFromNetworkId(data.deliveryVehicleNetId)
  if not DoesEntityExist(vehicle) then
    return
  end
  
  lobby.currentTask.game.harvestedCropState.loadedCount = lobby.currentTask.game.harvestedCropState.loadedCount + 1
  
  local entityOwner = NetworkGetEntityOwner(vehicle)
  if not entityOwner or entityOwner == 0 then
    return
  end
  
  lib.callback(_e("server:melon_pumpkin:spawnObjectInDeliveryVehicle"), entityOwner, function(networkId)
    shared.debug("debug:MelonPumpkinServer.loadHarvestedCropToDeliveryVehicle", networkId)
    if not networkId then
      return
    end
    table.insert(lobby.currentTask.game.harvestedCropState.objectsInDeliveryVehicle, networkId)
  end, {
    deliveryVehicleNetId = data.deliveryVehicleNetId,
    cropName = data.cropName,
    loadedCount = lobby.currentTask.game.harvestedCropState.loadedCount
  })
end)

RegisterNetEvent(_e("server:melon_pumpkin:onHarvestedCropPickedUp"), function(data)
  if not data.pointIndex or not data.lobbyId then
    shared.debug("debug:MelonPumpkinServer.onHarvestedCropPickedUp - Invalid data", 
      ("pointIndex: %s, lobbyId: %s"):format(data.pointIndex, data.lobbyId), "error")
    return
  end
  
  local lobby = Lobby.getLobbyById(data.lobbyId)
  if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    return
  end
  
  local point = lobby.currentTask.game.plantingPoints[data.pointIndex]
  if not point then
    return
  end
  
  if point.state == PlantingPointStates.HARVESTED then
    return
  end
  
  if lobby.currentTask.game.harvestedCropState.harvestedPoints[data.pointIndex] then
    return
  end
  
  lobby.currentTask.game.harvestedCropState.harvestedPoints[data.pointIndex] = true
  
  for _, member in pairs(lobby.members) do
    TriggerClientEvent(_e("client:melon_pumpkin:onHarvestedCropPickedUp"), member.source, data)
  end
end)

RegisterNetEvent(_e("server:melon_pumpkin:onCropSelected"), function(data)
  local source = source
  
  if not data or not data.lobbyId or not data.cropName then
    return
  end
  
  local lobby = Lobby.getLobbyById(data.lobbyId)
  if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    return
  end
  
  lobby.currentTask.game.selectedCropName = data.cropName
  
  for _, member in pairs(lobby.members) do
    if member.source ~= source then
      TriggerClientEvent(_e("client:melon_pumpkin:onCropSelected"), member.source, {
        cropName = lobby.currentTask.game.selectedCropName
      })
    end
  end
end)

lib.callback.register(_e("server:melon_pumpkin:registerPointObject"), function(source, data)
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
  
  shared.debug("debug:MelonPumpkinServer.registerPointObject", 
    ("pointIndex: %s, networkId: %s, cropName: %s"):format(data.pointIndex, data.networkId, data.cropName))
end)

RegisterNetEvent(_e("server:melon_pumpkin:deletePointObject"), function(data)
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
  
  local networkId = lobby.currentTask.game.pointObjectNetIds[data.pointIndex]
  if networkId then
    deleteEntities(networkId)
    lobby.currentTask.game.pointObjectNetIds[data.pointIndex] = nil
    shared.debug("debug:MelonPumpkinServer.deletePointObject", 
      ("pointIndex: %s, networkId: %s"):format(data.pointIndex, networkId))
  end
end)

lib.callback.register(_e("server:melon_pumpkin:canHarvestCrop"), function(source, data)
  if not data or not data.lobbyId or not data.pointIndex then
    return false
  end
  
  local lobby = Lobby.getLobbyById(data.lobbyId)
  if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    return false
  end
  
  local point = lobby.currentTask.game.plantingPoints[data.pointIndex]
  if not point then
    return false
  end
  
  if point.state ~= PlantingPointStates.GROWN then
    return false
  end
  
  if lobby.currentTask.game.harvestedCropState.harvestedPoints[data.pointIndex] then
    return false
  end
  
  if point._isBeingHarvested then
    return false
  end
  
  point._isBeingHarvested = true
  return true
end)

lib.callback.register(_e("server:melon_pumpkin:canPlantCrop"), function(source, data)
  if not data or not data.lobbyId or not data.pointIndex then
    return false
  end
  
  local lobby = Lobby.getLobbyById(data.lobbyId)
  if not lobby or not Lobby.isPlayerInLobby(data.lobbyId, source) then
    return false
  end
  
  local point = lobby.currentTask.game.plantingPoints[data.pointIndex]
  if not point then
    return false
  end
  
  if point.state ~= PlantingPointStates.RAKED then
    return false
  end
  
  if point._isBeingPlanted then
    return false
  end
  
  point._isBeingPlanted = true
  return true
end)

if MultiplayerTasksServer and MultiplayerTasksServer.registerModuleState then
  MultiplayerTasksServer.registerModuleState("melon_pumpkin", MelonPumpkinServer, config)
end
