local lib = lib
local config = lib.load("core.multiplayer_tasks.livestock_farming.config")
local inventoryModule = require("modules.inventory.server")
local moduleName = "livestock_farming"
local LivestockFarmingServer = {}
local fieldStates = {}

local function deleteEntities(networkIds)
  if type(networkIds) ~= "table" then
    networkIds = {networkIds}
  end
  
  if #networkIds == 0 then
    return
  end
  
  for _, networkId in ipairs(networkIds) do
    local entity = NetworkGetEntityFromNetworkId(networkId)
    if DoesEntityExist(entity) then
      DeleteEntity(entity)
    end
  end
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

function LivestockFarmingServer.start(source, lobbyId)
  shared.debug("debug:LivestockFarmingServer.start", ("source: %s, lobbyId: %s"):format(source, lobbyId))
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  local fieldId, fieldConfig = getFreeField(lobbyId)
  if not fieldId then
    shared.debug("debug:No free livestock field available for lobbyId:", lobbyId)
    return {
      error = locale("no_free_field")
    }
  end
  
  lobby.currentTask.game = {
    fieldId = fieldId,
    taskEntities = {},
    fedCowPoints = {},
    milkedCowPoints = {}
  }
  
  return true
end

function LivestockFarmingServer.stop(source, lobbyId, force)
  shared.debug("debug:LivestockFarmingServer.stop", ("source: %s, lobbyId: %s, force: %s"):format(source, lobbyId, force))
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if lobby.currentTask then
    local netIds = {}
    
    if lobby.currentTask.game.taskEntities then
      for _, entity in pairs(lobby.currentTask.game.taskEntities) do
        table.insert(netIds, entity.netId)
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

lib.callback.register(_e("server:livestock_farming:onVehicleSpawned"), function(source, lobbyId, entityState)
  if not lobbyId then
    return false
  end
  
  if not entityState or not entityState.key or not entityState.model or not entityState.coords then
    shared.debug("debug:livestock_farming:Invalid data received for vehicle spawn:", entityState)
    return false
  end
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if not lobby.currentTask then
    return false
  end
  
  if lobby.owner ~= source then
    return false
  end
  
  local taskEntities = lobby.currentTask.game.taskEntities
  if taskEntities and taskEntities[entityState.key] then
    return false
  end
  
  taskEntities[entityState.key] = entityState
  
  shared.debug("debug:livestock_farming:Vehicle spawned:", entityState)
  
  for _, member in pairs(lobby.members) do
    TriggerClientEvent(_e("client:livestock_farming:onVehicleSpawned"), member.source, entityState)
  end
  
  return true
end)

lib.callback.register(_e("server:livestock_farming:onCowSpawned"), function(source, lobbyId, entityState)
  if not lobbyId then
    return false
  end
  
  if not entityState or not entityState.key or not entityState.model or not entityState.coords then
    shared.debug("debug:livestock_farming:Invalid data received for cow spawn:", entityState)
    return false
  end
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if not lobby.currentTask then
    return false
  end
  
  if lobby.owner ~= source then
    return false
  end
  
  local taskEntities = lobby.currentTask.game.taskEntities
  if taskEntities and taskEntities[entityState.key] then
    return false
  end
  
  taskEntities[entityState.key] = entityState
  
  shared.debug("debug:livestock_farming:Cow spawned:", entityState)
  
  for _, member in pairs(lobby.members) do
    TriggerClientEvent(_e("client:livestock_farming:onCowSpawned"), member.source, entityState)
  end
  
  return true
end)

lib.callback.register(_e("server:livestock_farming:feedCow"), function(source, lobbyId, cowKey)
  if not lobbyId or not cowKey then
    return false
  end
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if not lobby.currentTask or not lobby.currentTask.game then
    return false
  end
  
  local cowEntity = lobby.currentTask.game.taskEntities["cow_" .. cowKey]
  if not cowEntity then
    return false
  end
  
  lobby.currentTask.game.fedCowPoints = lobby.currentTask.game.fedCowPoints or {}
  lobby.currentTask.game.fedCowPoints[cowKey] = true
  
  local entity = NetworkGetEntityFromNetworkId(cowEntity.netId)
  if not DoesEntityExist(entity) then
    return false
  end
  
  local entityOwner = NetworkGetEntityOwner(entity)
  
  local haybaleNetId = lib.callback.await(_e("client:livestock_farming:playFeedAnimation"), entityOwner, {
    key = cowKey,
    cowNetId = cowEntity.netId
  })
  
  if not haybaleNetId then
    shared.debug("debug:Failed to play feed animation for source:", entityOwner)
    return
  end
  
  lobby.currentTask.game.taskEntities["haybale_" .. cowKey] = {
    netId = haybaleNetId
  }
  
  lobby.currentTask.game.taskEntities["cow_" .. cowKey].fedTime = os.time()
  
  local allFed = true
  for key, entity in pairs(lobby.currentTask.game.taskEntities) do
    if string.find(key, "cow_") and entity then
      if not entity.fedTime then
        allFed = false
        break
      end
    end
  end
  
  for _, member in pairs(lobby.members) do
    TriggerClientEvent(_e("client:livestock_farming:onCowFed"), member.source, cowKey, allFed)
  end
  
  PersonalChallengesServer.onFarmingActionTriggered(source, "cow", "fed")
  
  return true
end)

lib.callback.register(_e("server:livestock_farming:milkCow"), function(source, lobbyId, cowKey)
  if not lobbyId or not cowKey then
    return false
  end
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if not lobby.currentTask or not lobby.currentTask.game then
    return false
  end
  
  local cowEntity = lobby.currentTask.game.taskEntities["cow_" .. cowKey]
  if not cowEntity then
    return false
  end
  
  if not lobby.currentTask.game.fedCowPoints[cowKey] then
    return false
  end
  
  if lobby.currentTask.game.milkedCowPoints[cowKey] then
    if lobby.currentTask.game.milkedCowPoints[cowKey] >= config.animalFeed.maxMilkPerCow then
      return {
        error = locale("livestock_farming.cow_no_more_milk")
      }
    end
  end
  
  local currentTime = os.time()
  local fedTime = cowEntity.fedTime or os.time()
  local timeSinceFed = currentTime - fedTime
  
  if timeSinceFed < config.animalFeed.requiredFeedingTimeForMilk then
    return {
      error = locale("livestock_farming.cow_not_fed")
    }
  end
  
  if not lobby.currentTask.game.milkedCowPoints[cowKey] then
    lobby.currentTask.game.milkedCowPoints[cowKey] = 0
  end
  
  lobby.currentTask.game.milkedCowPoints[cowKey] = lobby.currentTask.game.milkedCowPoints[cowKey] + 1
  
  Lobby.incMemberProgress(lobbyId, source)
  PersonalChallengesServer.onFarmingActionTriggered(source, "cow", "milked")
  
  return true
end)

lib.callback.register(_e("server:livestock_farming:sellMilk"), function(source, lobbyId)
  if not lobbyId then
    return false
  end
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if not lobby.currentTask or not lobby.currentTask.game then
    return false
  end
  
  local totalMilk = 0
  for _, milkCount in pairs(lobby.currentTask.game.milkedCowPoints) do
    if milkCount then
      totalMilk = totalMilk + milkCount
    end
  end
  
  if totalMilk == 0 then
    return false
  end
  
  inventoryModule.giveItem(source, config.milkBottleItemName, totalMilk)
  
  return true
end)

lib.callback.register(_e("server:livestock_farming:canCarryFeed"), function(source, lobbyId)
  if not lobbyId then
    return false
  end
  
  local lobby = Lobby.getLobbyById(lobbyId)
  if not lobby then
    return false
  end
  
  if not lobby.currentTask or not lobby.currentTask.game then
    return false
  end
  
  local hasUnfedCow = false
  for key, entity in pairs(lobby.currentTask.game.taskEntities) do
    if string.find(key, "cow_") and entity then
      if not entity.fedTime then
        hasUnfedCow = true
        break
      end
    end
  end
  
  return hasUnfedCow
end)

if MultiplayerTasksServer and MultiplayerTasksServer.registerModuleState then
  MultiplayerTasksServer.registerModuleState("livestock_farming", LivestockFarmingServer, config)
end
