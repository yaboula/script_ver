local lib = lib
local utils = require("modules.utils.client")
local targetModule = require("modules.target.client")
local config = lib.load("core.multiplayer_tasks.livestock_farming.config")
local LivestockFarmingClient = {}
local state = {}

local function resetState()
  state = {
    showTextUI = false,
    blips = {},
    points = {},
    targets = {},
    carryingState = {
      isCarrying = false,
      carryingProp = nil,
      carryingType = nil
    },
    isMilking = false,
    isBusy = false
  }
end

local function getFieldConfig(fieldId)
  return config.fields[fieldId]
end

local function onEnterVehicleSpawnPoint(point)
  local meta = point.meta
  
  if not meta or not meta.key or not meta.model then
    return point:remove()
  end
  
  local model = type(meta.model) == "string" and GetHashKey(meta.model) or meta.model
  
  if not IsModelValid(model) then
    shared.debug("debug:livestock_farming.onEnterVehicleSpawnPoint: Invalid model", meta.model)
    return point:remove()
  end
  
  local coords = meta.coords or point.coords
  
  lib.requestModel(model)
  
  local vehicle = nil
  local networkId = nil
  
  vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
  
  while not DoesEntityExist(vehicle) do
    Citizen.Wait(0)
  end
  
  networkId = lib.waitFor(function()
    if not NetworkGetEntityIsNetworked(vehicle) then
      NetworkRegisterEntityAsNetworked(vehicle)
    else
      local netId = VehToNet(vehicle)
      if NetworkDoesNetworkIdExist(netId) then
        return netId
      end
    end
  end, false, false)
  
  SetModelAsNoLongerNeeded(model)
  SetEntityCoords(vehicle, coords.x, coords.y, coords.z)
  SetEntityRotation(vehicle, 0.0, 0.0, coords.w or 0.0, 2)
  utils.setFuel(vehicle, 100.0)
  
  local entityState = {
    key = meta.key,
    model = meta.model,
    coords = coords,
    netId = networkId,
    spawned = true
  }
  
  client.currentTask.game.taskEntities[meta.key] = entityState
  point:remove()
  state.points[meta.key] = nil
  
  lib.callback.await(_e("server:livestock_farming:onVehicleSpawned"), false, client.lobby.id, entityState)
end

local function onEnterCowSpawnPoint(point)
  local meta = point.meta
  
  if not meta or not meta.key or not meta.model then
    return point:remove()
  end
  
  local model = type(meta.model) == "string" and GetHashKey(meta.model) or meta.model
  
  if not IsModelValid(model) then
    shared.debug("debug:livestock_farming.onEnterCowSpawnPoint: Invalid model", meta.model)
    return point:remove()
  end
  
  local coords = meta.coords or point.coords
  
  lib.requestModel(model)
  
  local ped = nil
  local networkId = nil
  
  ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
  
  while not DoesEntityExist(ped) do
    Citizen.Wait(0)
  end
  
  networkId = lib.waitFor(function()
    if not NetworkGetEntityIsNetworked(ped) then
      NetworkRegisterEntityAsNetworked(ped)
    else
      local netId = ObjToNet(ped)
      if NetworkDoesNetworkIdExist(netId) then
        return netId
      end
    end
  end, false, false)
  
  FreezeEntityPosition(ped, true)
  SetEntityCoords(ped, coords.x, coords.y, coords.z)
  SetEntityRotation(ped, 0.0, 0.0, coords.w or 0.0, 2)
  SetEntityInvincible(ped, true)
  SetPedDiesWhenInjured(ped, false)
  TaskSetBlockingOfNonTemporaryEvents(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  SetModelAsNoLongerNeeded(model)
  
  local entityState = {
    key = meta.key,
    model = meta.model,
    coords = coords,
    netId = networkId,
    spawned = true
  }
  
  client.currentTask.game.taskEntities[meta.key] = entityState
  point:remove()
  state.points[meta.key] = nil
  
  lib.callback.await(_e("server:livestock_farming:onCowSpawned"), false, client.lobby.id, entityState)
end

local function attachCarryProp(propConfig)
  local ped = cache.ped
  local playerCoords = GetEntityCoords(ped)
  
  state.carryingState.isCarrying = true
  
  lib.requestModel(propConfig.model)
  local prop = CreateObject(GetHashKey(propConfig.model), playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
  NetworkRegisterEntityAsNetworked(prop)
  AttachEntityToEntity(prop, cache.ped, GetPedBoneIndex(ped, propConfig.bone), 
    propConfig.offset.x, propConfig.offset.y, propConfig.offset.z,
    propConfig.rotation.x, propConfig.rotation.y, propConfig.rotation.z,
    true, true, false, true, 2, true)
  SetModelAsNoLongerNeeded(propConfig.model)
  
  state.carryingState.carryingProp = prop
  state.carryingState.carryingType = propConfig.type
  
  ClearPedTasksImmediately(ped)
  lib.requestAnimDict(propConfig.dict)
  TaskPlayAnim(ped, propConfig.dict, propConfig.name, 8.0, 8.0, -1, 50, 0, false, false, false)
end

local function removeCarryProp()
  local ped = cache.ped
  ClearPedTasks(ped)
  
  if state.carryingState.carryingProp then
    if DoesEntityExist(state.carryingState.carryingProp) then
      DetachEntity(state.carryingState.carryingProp, true, false)
      DeleteEntity(state.carryingState.carryingProp)
    end
  end
  
  state.carryingState.isCarrying = false
  state.carryingState.carryingProp = nil
end

local function setupFeedTargets(models)
  local options = {
    {
      label = locale("livestock_farming.feed_animal"),
      icon = "fa-solid fa-wheat-awn",
      distance = 2.0,
      onSelect = function()
        if state.carryingState.isCarrying then
          utils.notify(locale("livestock_farming.already_carrying"), "error")
      return
    end
        
        local canCarry = lib.callback.await(_e("server:livestock_farming:canCarryFeed"), false, client.lobby.id)
        if not canCarry then
          utils.notify(locale("livestock_farming.cannot_carry"), "error")
      return
    end
        
        attachCarryProp(config.animalFeed.hold)
      end,
      canInteract = function()
        if not client.currentTask or not client.currentTask.game or not client.currentTask.game.taskEntities then
          return true
        end
        
        local playerCoords = GetEntityCoords(cache.ped)
        
        for key, entity in pairs(client.currentTask.game.taskEntities) do
          if type(key) == "string" and key:find("^cow_") then
            if entity.netId then
              local cowPed = NetToPed(entity.netId)
              if DoesEntityExist(cowPed) then
                local cowCoords = GetEntityCoords(cowPed)
                if #(playerCoords - cowCoords) <= 5.0 then
                  return false
        end
      end
    end
              end
            end
        
        return true
      end
    }
  }
  
  targetModule.addModel(models, options)
  table.insert(state.targets, {
    type = "model",
    model = models
  })
end

local function setupCowTargets(cowLocations)
  for cowIndex, cowConfig in pairs(cowLocations) do
    local zoneName = ("livestock_farming_cow_feed_%s"):format(cowIndex)
    
    local options = {
      {
        label = locale("livestock_farming.feed_cow"),
        distance = 2.0,
        icon = "fa-solid fa-bowl-food",
        canInteract = function()
          if state.carryingState.isCarrying then
            return not client.currentTask.game.fedCowPoints[cowIndex]
          end
          return false
        end,
        onSelect = function()
          if not state.carryingState.isCarrying then
            utils.notify(locale("livestock_farming.not_carrying"), "error")
        return
      end
          
          if client.currentTask.game.fedCowPoints[cowIndex] then
        return
      end
          
          local result = lib.callback.await(_e("server:livestock_farming:feedCow"), false, client.lobby.id, cowIndex)
          if not result then
            return utils.notify(locale("livestock_farming.feed_failed"), "error")
          end
          
          client.currentTask.game.fedCowPoints[cowIndex] = true
          removeCarryProp()
          utils.notify(locale("livestock_farming.cow_fed"), "success")
        end
      },
      {
        label = locale("livestock_farming.milk_cow"),
        distance = 2.0,
        icon = "fa-solid fa-cow",
        canInteract = function()
          local notCarrying = not state.carryingState.isCarrying
          local isFed = client.currentTask.game.fedCowPoints[cowIndex]
          local notMilking = not state.isMilking
          return isFed and notMilking
        end,
        onSelect = function()
          if state.isBusy then
        return
      end
          
          if state.carryingState.isCarrying then
        return
      end
          
          if not client.currentTask.game.fedCowPoints[cowIndex] then
        return
      end
          
          if client.currentTask.game.milkedCowPoints[cowIndex] then
        return
      end
          
          local result = lib.callback.await(_e("server:livestock_farming:milkCow"), false, client.lobby.id, cowIndex)
          if not result then
            return utils.notify(locale("livestock_farming.feed_failed"), "error")
          end
          
          if type(result) == "table" and result.error then
            return utils.notify(result.error, "error")
          end
          
          local cowNetId = client.currentTask.game.taskEntities["cow_" .. cowIndex].netId
          if cowNetId then
            local cowPed = NetToPed(cowNetId)
            if cowPed ~= 0 and DoesEntityExist(cowPed) then
              FreezeEntityPosition(cache.ped, true)
              TaskTurnPedToFaceEntity(cache.ped, cowPed, 500)
              Citizen.Wait(500)
              FreezeEntityPosition(cache.ped, false)
            end
          end
          
          state.isBusy = true
          lib.playAnim(cache.ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", nil, nil, 10000)
          utils.progressBar({
            duration = 10000,
            label = locale("livestock_farming.milk_cow"),
            useWhileDead = false,
            canCancel = false,
            disable = {
              move = true,
              combat = true,
              vehicle = true
            }
          })
          ClearPedTasks(cache.ped)
          state.isBusy = false
          
          attachCarryProp(config.animalFeed.milkProp)
          
          Citizen.CreateThread(function()
            while state.carryingState.isCarrying do
              local wait = 500
              local playerCoords = GetEntityCoords(cache.ped)
              
              local truckNetId = client.currentTask.game.taskEntities.truck and client.currentTask.game.taskEntities.truck.netId
              if truckNetId then
                local truck = NetToVeh(truckNetId)
                if DoesEntityExist(truck) then
                  local truckBackCoords = GetOffsetFromEntityInWorldCoords(truck, 0.0, -4.0, 0.0)
                  local distance = #(playerCoords - truckBackCoords)
                  
                  if distance < 2.0 then
                    wait = 1
                    if not state.showTextUI then
                      utils.showTextUI(locale("livestock_farming.deliver_milk"))
                      state.showTextUI = true
                    end
                    
                    if IsControlJustPressed(0, 38) then
                      removeCarryProp()
                      local sellNpcCoords = client.getClosestSellNpc()
                      if sellNpcCoords then
                        SetNewWaypoint(sellNpcCoords.x, sellNpcCoords.y)
                      end
                      utils.hideTextUI()
                      state.showTextUI = false
                  return
                end
              else
                    if state.showTextUI then
                      utils.hideTextUI()
                      state.showTextUI = false
                end
              end
            end
          end
              
              Citizen.Wait(wait)
            end
          end)
        end
      }
    }
    
    targetModule.addBoxZone(zoneName, {
      name = zoneName,
      coords = vector3(cowConfig.coords.x, cowConfig.coords.y, cowConfig.coords.z + 1.0),
      size = vector3(1.2, 2.0, 1.5),
      debug = false,
      options = options,
      rotation = cowConfig.coords.w or 0.0
    })
    
    table.insert(state.targets, {
      type = "zone",
      zone = zoneName
    })
  end
end

local function startSellMilkThread()
  Citizen.CreateThread(function()
    while client.currentTask do
      local wait = 1000
      local vehicle = cache.vehicle
      local truckEntity = client.currentTask.game.taskEntities.truck
      
      if vehicle and truckEntity then
        if VehToNet(vehicle) == truckEntity.netId then
          if cache.seat == -1 then
            local sellNpcCoords, distance = client.getClosestSellNpc()
            if sellNpcCoords then
              if distance < 20.0 then
                DrawMarker(1, sellNpcCoords.x, sellNpcCoords.y, sellNpcCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 10.0, 10.0, 1.0, 255, 255, 0, 100, false, true, 2, nil, nil, false)
                
                if not state.showTextUI then
                  utils.showTextUI(locale("livestock_farming.deliver_milk"))
                  state.showTextUI = true
                end
                
                wait = 0
                
                if IsControlJustPressed(0, 38) then
                  utils.hideTextUI()
                  state.showTextUI = false
                  lib.callback.await(_e("server:livestock_farming:sellMilk"), false, client.lobby.id)
                  break
                end
              else
                if state.showTextUI then
                  state.showTextUI = false
                  utils.hideTextUI()
                end
              end
            end
          end
        end
      end
      
      Citizen.Wait(wait)
    end
    
    if client.currentTask then
      utils.notify(locale("livestock_farming.return_truck"), "info")
      
      local truckEntity = client.currentTask.game.taskEntities.truck
      local truckSpawnCoords = truckEntity.coords
      SetNewWaypoint(truckEntity.coords.x, truckEntity.coords.y)
      
      while client.currentTask do
        local wait = 1000
        local vehicle = cache.vehicle
        
        if vehicle and truckEntity then
          if VehToNet(vehicle) == truckEntity.netId then
            if cache.seat == -1 then
              local vehicleCoords = GetEntityCoords(vehicle)
              local spawnPoint = vector3(truckSpawnCoords.x, truckSpawnCoords.y, truckSpawnCoords.z)
              local distance = #(vehicleCoords - spawnPoint)
              
              if distance < 35.0 then
                wait = 0
                DrawMarker(1, truckSpawnCoords.x, truckSpawnCoords.y, truckSpawnCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 1.0, 255, 255, 0, 100, false, true, 2, nil, nil, false)
                
                if distance < 7.5 then
                  lib.callback.await(_e("server:multiplayer_tasks:stop"), false, client.currentTask.moduleName, client.lobby.id)
                  return
                end
              end
            end
          end
        end
        
        Citizen.Wait(wait)
      end
    end
  end)
end

local function startFeedMarkerThread()
  if not config.feedMarker then
    return
  end
  
  Citizen.CreateThread(function()
    if not client.currentTask then
      return
    end
    
    local fieldConfig = getFieldConfig(client.currentTask.game.fieldId)
    
    while client.currentTask do
      local wait = 1000
      local playerCoords = GetEntityCoords(cache.ped)
      
      for _, feedCoords in pairs(fieldConfig.feedBlipLocations) do
        local distance = #(playerCoords - feedCoords)
        if distance < 20.0 then
          wait = 0
          DrawMarker(config.feedMarker.type, feedCoords.x, feedCoords.y, feedCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
            config.feedMarker.scale.x, config.feedMarker.scale.y, config.feedMarker.scale.z, 
            config.feedMarker.color.r, config.feedMarker.color.g, config.feedMarker.color.b, config.feedMarker.color.a, 
            false, true, 2, false, nil, nil, false)
        end
      end
      
      Citizen.Wait(wait)
    end
  end)
end

function LivestockFarmingClient.clear()
  shared.debug("debug:livestock_farming.clear")
  
  if state.showTextUI then
    utils.hideTextUI()
  end
  
  for _, blip in pairs(state.blips) do
    if DoesBlipExist(blip) then
      RemoveBlip(blip)
    end
  end
  
  for _, point in pairs(state.points) do
    point:remove()
  end
  
  if state.carryingState.isCarrying then
    removeCarryProp()
  end
  
  for _, target in pairs(state.targets) do
    if target.type == "model" then
      targetModule.removeModel(target.model)
    elseif target.type == "zone" then
      targetModule.removeZone(target.zone)
    end
  end
  
  resetState()
  shared.debug("debug:livestock_farming.clear: Cleared state")
end

function LivestockFarmingClient.start()
  shared.debug("debug:livestock_farming.start", ("lobby: %s, field: %s"):format(client.lobby.id, client.currentTask.game.fieldId))
  
  local fieldConfig = getFieldConfig(client.currentTask.game.fieldId)
  if not fieldConfig then
    shared.debug(("debug:livestock_farming.start: Field not found for ID %s"):format(client.currentTask.game.fieldId))
    return false
  end
  
  resetState()
  
  for cowIndex, cowConfig in pairs(fieldConfig.cowLocations) do
    state.blips["cow_" .. cowIndex] = utils.addBlip(cowConfig.coords, config.blips.cow, cowIndex == 1)
  end
  
  state.blips.truck = utils.addBlip(fieldConfig.truckLocation.coords, config.blips.truck)
  
  for feedIndex, feedCoords in pairs(fieldConfig.feedBlipLocations) do
    state.blips["feed_" .. feedIndex] = utils.addBlip(feedCoords, config.blips.feed)
  end
  
  startSellMilkThread()
  
  if client.lobby.owner == cache.serverId then
    state.points.truck = lib.points.new({
      coords = fieldConfig.truckLocation.coords,
      distance = 50.0,
      meta = {
        key = "truck",
        model = fieldConfig.truckLocation.model,
        coords = fieldConfig.truckLocation.coords
      },
      onEnter = onEnterVehicleSpawnPoint
    })
    
    for cowIndex, cowConfig in pairs(fieldConfig.cowLocations) do
      state.points["cow_" .. cowIndex] = lib.points.new({
        coords = cowConfig.coords,
        distance = 50.0,
        meta = {
          key = "cow_" .. cowIndex,
          model = cowConfig.model,
          coords = cowConfig.coords
        },
        onEnter = onEnterCowSpawnPoint
      })
    end
  end
  
  setupFeedTargets(config.animalFeed.targetModels)
  setupCowTargets(fieldConfig.cowLocations)
  startFeedMarkerThread()
  
  utils.notify(locale("tasks.started"), "success")
  return true
end

function LivestockFarmingClient.stop()
  shared.debug("debug:livestock_farming.stop", "Stopping Livestock Farming Client")
  LivestockFarmingClient.clear()
  return true
end

RegisterNetEvent(_e("client:livestock_farming:onVehicleSpawned"), function(entityState)
  if not entityState or not entityState.key then
    return
  end
  
  client.currentTask.game.taskEntities[entityState.key] = entityState
  
  Citizen.CreateThread(function()
    local vehicle = lib.waitFor(function()
      if NetworkDoesEntityExistWithNetworkId(entityState.netId) then
        local veh = NetToVeh(entityState.netId)
        if DoesEntityExist(veh) then
          return veh
        end
      end
    end, false, false)
    
    MultiplayerTasksClient.giveVehicleKey(GetVehicleNumberPlateText(vehicle), vehicle)
  end)
end)

RegisterNetEvent(_e("client:livestock_farming:onCowSpawned"), function(entityState)
  if not entityState or not entityState.key then
    return
  end
  
  client.currentTask.game.taskEntities[entityState.key] = entityState
end)

RegisterNetEvent(_e("client:livestock_farming:onCowFed"), function(cowKey, allFed)
  if not client.currentTask then
    return
  end
  
  if not cowKey then
    return
  end
  
  client.currentTask.game.fedCowPoints[cowKey] = true
  
  if allFed then
    targetModule.removeModel(config.animalFeed.targetModels)
    if state.carryingState.isCarrying then
      removeCarryProp()
    end
  end
end)

lib.callback.register(_e("client:livestock_farming:playFeedAnimation"), function(data)
  local cowKey = data.key
  local cowNetId = data.cowNetId
  
  local cowPed = lib.waitFor(function()
    if NetworkDoesEntityExistWithNetworkId(cowNetId) then
      local ped = NetToPed(cowNetId)
      if DoesEntityExist(ped) then
        return ped
      end
    end
  end, false, false)
  
  local haybaleNetId = nil
  local haybaleModel = config.animalFeed.hold.model
  local cowBoneCoords = GetWorldPositionOfEntityBone(cowPed, 24)
  
  lib.requestModel(haybaleModel)
  local haybale = CreateObject(haybaleModel, cowBoneCoords.x, cowBoneCoords.y, cowBoneCoords.z, true, true, false)
  PlaceObjectOnGroundProperly(haybale)
  
  local haybaleCoords = GetEntityCoords(haybale)
  SetEntityCoords(haybale, haybaleCoords.x, haybaleCoords.y, haybaleCoords.z - 0.35)
  
  lib.playAnim(cowPed, "creatures@cow@amb@world_cow_grazing@base", "base", 8.0, -8.0, -1, 50, 0, false, false, false)
  
  haybaleNetId = lib.waitFor(function()
    if NetworkGetEntityIsNetworked(haybale) then
      local netId = ObjToNet(haybale)
      if NetworkDoesNetworkIdExist(netId) then
        return netId
      end
    else
      NetworkRegisterEntityAsNetworked(haybale)
    end
  end, false, false)
  
  SetModelAsNoLongerNeeded(haybaleModel)
  return haybaleNetId
end)

if MultiplayerTasksClient and MultiplayerTasksClient.registerModuleState then
  MultiplayerTasksClient.registerModuleState("livestock_farming", LivestockFarmingClient, config)
end

