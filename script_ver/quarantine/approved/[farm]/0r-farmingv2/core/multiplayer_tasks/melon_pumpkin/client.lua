local lib = lib
local utils = require("modules.utils.client")
local config = lib.load("core.multiplayer_tasks.melon_pumpkin.config")

local MelonPumpkinClient = {}

local PlantState = {
  EMPTY = "empty",
  RAKED = "raked",
  PLANTED = "planted",
  WATERED = "watered",
  GROWN = "grown",
  HARVESTED = "harvested",
}

local PlantStateColor = {
  [PlantState.EMPTY] = { r = 255, g = 255, b = 255 },
  [PlantState.RAKED] = { r = 139, g = 69, b = 19 },
  [PlantState.PLANTED] = { r = 255, g = 255, b = 0 },
  [PlantState.WATERED] = { r = 130, g = 255, b = 243 },
  [PlantState.GROWN] = { r = 0, g = 255, b = 0 },
  [PlantState.HARVESTED] = { r = 255, g = 165, b = 0 },
}

local WorkActions = {
  rakering = {
    action = "rakering",
    requiredState = PlantState.EMPTY,
    targetState = PlantState.RAKED,
    workRadius = 1.5,
    workTime = 2000,
    actionText = locale("melon_pumpkin.rake_crops"),
    anim = {
      dict = "anim@amb@drug_field_workers@rake@male_a@base",
      clip = "base",
      flags = 1,
    },
    prop = {
      model = "prop_tool_rake",
      bone = 28422,
      pos = { x = 0.0, y = 0.0, z = -0.03 },
      rot = { x = 0.0, y = 0.0, z = 0.0 },
    },
  },
  planting = {
    action = "planting",
    requiredState = PlantState.RAKED,
    targetState = PlantState.PLANTED,
    workRadius = 1.5,
    workTime = 5000,
    actionText = locale("melon_pumpkin.plant_crops"),
    anim = {
      scenario = "WORLD_HUMAN_GARDENER_PLANT",
    },
  },
  watering = {
    action = "watering",
    requiredState = PlantState.PLANTED,
    targetState = PlantState.WATERED,
    workRadius = 1.5,
    workTime = 2500,
    actionText = locale("melon_pumpkin.water_plants"),
    anim = {
      dict = "weapon@w_sp_jerrycan",
      clip = "fire",
      flags = 1,
    },
    prop = {
      model = "prop_wateringcan",
      bone = 18905,
      pos = { x = 0.08, y = -0.2, z = 0.3 },
      rot = { x = -10.0, y = 80.0, z = 90.0 },
    },
  },
  harvesting = {
    action = "harvesting",
    requiredState = PlantState.GROWN,
    targetState = PlantState.HARVESTED,
    workRadius = 1.5,
    workTime = 5000,
    actionText = locale("melon_pumpkin.harvest_crops"),
    anim = {
      scenario = "WORLD_HUMAN_GARDENER_PLANT",
    },
  },
}

local holdOffsets = config.holdObjectOffsets or {}

local state = {}

local function resetState()
  state = {
    showTextUI = false,
    fieldBlips = {},
    fieldPoints = {},
    pointGroundZValues = {},
    pointWaterTimes = {},
    nearbyPoints = {},
    pointObjectNetIds = {},
    selectedCropName = nil,
    carryingState = {
      isCarrying = false,
      carryingProp = nil,
    },
  }
end

local function hasItem(itemName, amount)
  amount = amount or 1
  return lib.callback.await(_e("server:inventory:hasRequiredItem"), false, itemName, amount)
end

local function removeItem(itemName, amount)
  amount = amount or 1
  return lib.callback.await(_e("server:inventory:removeItem"), false, itemName, amount)
end

local function getFieldConfig(fieldId)
  return config.fields[fieldId]
end

local function drawPointMarker(point)
  local currentState = point.state or PlantState.EMPTY
  local color = PlantStateColor[currentState] or PlantStateColor[PlantState.EMPTY]
  local textureStage = "s1"

  if currentState == PlantState.WATERED then
    textureStage = "s2"
  elseif currentState == PlantState.GROWN then
    textureStage = "s3"
  end

  if not Config.DisableCustomMarkers then
    DrawMarker(
      9,
      point.coords.x,
      point.coords.y,
      point.coords.z + 1.0,
      0.0,
      0.0,
      0.0,
      90.0,
      0.0,
      0.0,
      0.2,
      0.25,
      0.0,
      color.r,
      color.g,
      color.b,
      255,
      false,
      true,
      2,
      false,
      "res_markers",
      textureStage,
      false
    )
  else
    DrawMarker(
      28,
      point.coords.x,
      point.coords.y,
      point.coords.z + 1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      0.1,
      0.1,
      0.1,
      color.r,
      color.g,
      color.b,
      200,
      false,
      true,
      2,
      false,
      nil,
      nil,
      false
    )
  end
end

local function getNearbyPoints(radius)
  radius = radius or 15.0

  local ped = cache.ped
  local pedCoords = GetEntityCoords(ped)
  local result = {}

  if not client.currentTask or not client.currentTask.game or not client.currentTask.game.plantingPoints then
    return result
  end

  for index, point in pairs(client.currentTask.game.plantingPoints) do
    local distance = #(pedCoords - point.coords)

    if distance <= radius and point.state ~= PlantState.HARVESTED then
      local groundZ = state.pointGroundZValues[index]

      if not groundZ then
        local found
        groundZ, found = utils.getGroundZ(point.coords)
        if found then
          state.pointGroundZValues[index] = groundZ or point.coords.z
        end
      end

      result[index] = {
        coords = vector3(point.coords.x, point.coords.y, state.pointGroundZValues[index] or point.coords.z),
        index = index,
        state = point.state,
        distance = distance,
      }
    end
  end

  return result
end

local function getPlantModel(cropName, stateName)
  local defaultModel = "prop_veg_crop_03_pump"
  local cropConfig = config.crops[cropName]

  if not cropConfig then
    return defaultModel
  end

  if stateName == PlantState.PLANTED then
    if Config.DisableCustomProps then
      return cropConfig.growthModel or defaultModel
    else
      return cropConfig.seedModel or "0r_sapling"
    end
  elseif stateName == PlantState.GROWN then
    if Config.DisableCustomProps then
      return cropConfig.growthModel or defaultModel
    else
      return cropConfig.growthModel or defaultModel
    end
  else
    return defaultModel
  end
end

local function spawnPointObject(cropName, stateName, coords, pointIndex, lobbyId)
  local model = getPlantModel(cropName, stateName)

  lib.requestModel(model)

  local obj = CreateObject(GetHashKey(model), coords.x, coords.y, coords.z, true, true, false)

  if not DoesEntityExist(obj) then
    return nil
  end

  NetworkRegisterEntityAsNetworked(obj)
  FreezeEntityPosition(obj, true)
  SetEntityCoords(obj, coords.x, coords.y, coords.z)
  SetModelAsNoLongerNeeded(model)

  local netId = lib.waitFor(function()
    if NetworkGetEntityIsNetworked(obj) then
      local n = ObjToNet(obj)
      if NetworkDoesNetworkIdExist(n) then
        return n
      end
    end
  end, false, false)

  if not netId then
    return nil
  end

  lib.callback.await(_e("server:melon_pumpkin:registerPointObject"), false, {
    lobbyId = lobbyId or client.lobby.id,
    pointIndex = pointIndex,
    networkId = netId,
    cropName = cropName,
    pointState = stateName,
  })

  return netId
end

local function getModelHeight(modelOrName)
  if not modelOrName then
    return 0.0
  end

  local model = type(modelOrName) == "string" and GetHashKey(modelOrName) or modelOrName
  if not IsModelValid(model) then
    return 0.0
  end

  local minDim, maxDim = GetModelDimensions(model)
  local height = math.abs(maxDim.z - minDim.z)
  return height
end

local function playCarryAnim()
  local ped = cache.ped
  ClearPedTasksImmediately(ped)
  lib.requestAnimDict("anim@heists@box_carry@")
  TaskPlayAnim(ped, "anim@heists@box_carry@",
    "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
end

local function stopCarry()
  local ped = cache.ped
  ClearPedTasks(ped)

  if state.carryingState.carryingProp and DoesEntityExist(state.carryingState.carryingProp) then
    DetachEntity(state.carryingState.carryingProp, true, false)
    DeleteEntity(state.carryingState.carryingProp)
  end

  state.carryingState.isCarrying = false
  state.carryingState.carryingProp = nil
end

local function loadHarvestedCropToDeliveryVehicle(pointIndex, deliveryVehicleNetId)
  if not state.carryingState.isCarrying then
    return
  end

  local vehicle = NetToVeh(deliveryVehicleNetId)
  local vehicleCoords = GetEntityCoords(vehicle)
  local pedCoords = GetEntityCoords(cache.ped)

  local dist = #(vehicleCoords - pedCoords)
  for door = 2, 3 do
    SetVehicleDoorOpen(vehicle, door, false, false)
  end

  if dist > 5.0 then
    return
  end

  local cropName = client.currentTask.game.plantingPoints[pointIndex].cropName
  stopCarry()

  TriggerServerEvent(_e("server:melon_pumpkin:loadHarvestedCropToDeliveryVehicle"), {
    lobbyId = client.lobby.id,
    pointIndex = pointIndex,
    deliveryVehicleNetId = deliveryVehicleNetId,
    cropName = cropName,
  })

  utils.notify(locale("melon_pumpkin.harvested_crop_loaded"), "success")
end

local function pickUpHarvestedCrop(pointIndex, model)
  if state.carryingState.isCarrying then
    utils.notify(locale("melon_pumpkin.already_carrying"), "error")
    return
  end

  local pedCoords = GetEntityCoords(cache.ped)
  local netId = state.pointObjectNetIds[pointIndex]

  if netId then
    local obj = NetToObj(netId)
    if obj and DoesEntityExist(obj) then
      pedCoords = GetEntityCoords(obj)
    end
  end

  model = model or "prop_veg_crop_03_cab"
  lib.requestModel(model)

  local obj = CreateObject(GetHashKey(model), pedCoords.x, pedCoords.y, pedCoords.z, true, true, false)
  NetworkRegisterEntityAsNetworked(obj)

  local cropName = client.currentTask.game.plantingPoints[pointIndex].cropName
  local attachOffset = (config.crops[cropName] and config.crops[cropName].attachOffset) or vector3(0.0, 0.0, 0.0)

  AttachEntityToEntity(
    obj,
    cache.ped,
    GetPedBoneIndex(cache.ped, 28422),
    attachOffset.x,
    attachOffset.y,
    attachOffset.z,
    0.0,
    0.0,
    0.0,
    true,
    true,
    false,
    true,
    2,
    true
  )

  state.carryingState.isCarrying = true
  state.carryingState.carryingProp = obj
  SetModelAsNoLongerNeeded(model)
  playCarryAnim()

  TriggerServerEvent(_e("server:melon_pumpkin:onHarvestedCropPickedUp"), {
    lobbyId = client.lobby.id,
    pointIndex = pointIndex,
  })

  utils.notify(locale("melon_pumpkin.harvested_crop_picked_up"), "success")
  state.pointObjectNetIds[pointIndex] = nil

  Citizen.CreateThread(function()
    local index = pointIndex
    while state.carryingState.isCarrying do
      local wait = 500
      local deliveryNetId

      if client.currentTask and client.currentTask.game and client.currentTask.game.taskEntities.deliveryVehicle then
        deliveryNetId = client.currentTask.game.taskEntities.deliveryVehicle.netId
      end

      if deliveryNetId then
        local vehicle = NetToVeh(deliveryNetId)
        if vehicle and DoesEntityExist(vehicle) then
          local pedCoords2 = GetEntityCoords(cache.ped)
          local backCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.5, 0.0)
          local dist = #(pedCoords2 - backCoords)

          if dist <= 1.5 then
            loadHarvestedCropToDeliveryVehicle(index, deliveryNetId)
            Citizen.Wait(1000)
          end
        end
      end

      Citizen.Wait(wait)
    end
  end)
end

local function applyPointStateLocally(pointIndex, newState)
  local plantingPoints = client.currentTask.game.plantingPoints
  local point = plantingPoints[pointIndex]

  point.state = newState

  local cropName = point.cropName
  if not cropName then
    point.cropName = state.selectedCropName
    cropName = state.selectedCropName
  end

  local model = getPlantModel(cropName, newState)
  local spawnOffset = (config.crops[cropName] and config.crops[cropName].spawnOffset) or vector3(0.0, 0.0, 0.0)

  local baseZ = state.pointGroundZValues[pointIndex] or point.coords.z
  local spawnCoords = vector3(
    point.coords.x + spawnOffset.x,
    point.coords.y + spawnOffset.y,
    baseZ + spawnOffset.z
  )

  local blipColor = 0

  if newState == PlantState.PLANTED then
    blipColor = 5

    local netId = spawnPointObject(cropName, newState, spawnCoords, pointIndex)
    if netId then
      local obj = NetToObj(netId)

      if Config.DisableCustomProps and obj and DoesEntityExist(obj) then
        Citizen.Wait(100)
        PlaceObjectOnGroundProperly(obj)

        local height = getModelHeight(model)
        local offsetCoords = GetOffsetFromEntityInWorldCoords(obj, 0.0, 0.0, -(height / 1.2))
        SetEntityCoords(obj, offsetCoords.x, offsetCoords.y, offsetCoords.z)
      end
      state.pointObjectNetIds[pointIndex] = netId
    end
  elseif newState == PlantState.WATERED then
    blipColor = 29
  elseif newState == PlantState.GROWN then
    blipColor = 2

    if state.pointObjectNetIds[pointIndex] then
      -- already spawned on this client via event
    end
  elseif newState == PlantState.HARVESTED then
    blipColor = 17

    local blip = state.fieldBlips["point_" .. pointIndex]
    if blip then
      RemoveBlip(blip)
      state.fieldBlips["point_" .. pointIndex] = nil
    end

    state.nearbyPoints[pointIndex] = nil
  end

  local bl = state.fieldBlips["point_" .. pointIndex]
  if bl then
    SetBlipColour(bl, blipColor)
  end
end

local function processGrowthTimers()
  if client.lobby.owner ~= cache.serverId then
    return
  end

  for index, point in pairs(client.currentTask.game.plantingPoints) do
    if point.state == PlantState.WATERED then
      if not state.pointWaterTimes[index] then
        state.pointWaterTimes[index] = GetGameTimer()
      end

      local cropName = point.cropName
      local growthTime = 60
      if cropName and config.crops[cropName] then
        growthTime = config.crops[cropName].growthTime
      end

      local elapsed = GetGameTimer() - state.pointWaterTimes[index]
      if elapsed >= growthTime * 1000 then
        applyPointStateLocally(index, PlantState.GROWN)
        state.pointWaterTimes[index] = nil
      end
    end
  end

  for index, _ in pairs(state.pointWaterTimes) do
    local point = client.currentTask.game.plantingPoints[index]
    if point.state ~= PlantState.WATERED then
      state.pointWaterTimes[index] = nil
    end
  end
end

local function handlePointInteractionLoop()
  if cache.vehicle then
    return false, 1000
  end

  local nearby = getNearbyPoints(5.0)

  if not next(nearby) then
    if state.showTextUI then
      utils.hideTextUI()
      state.showTextUI = false
    end
    return false, 1000
  end

  local closestPoint
  local closestDistance = math.huge
  local bestAction

  for index, pointInfo in pairs(nearby) do
    local point = client.currentTask.game.plantingPoints[index]
    local currentState = point.state or PlantState.EMPTY

    for _, action in pairs(WorkActions) do
      if currentState == action.requiredState and pointInfo.distance < action.workRadius then
        if pointInfo.distance < closestDistance then
          closestDistance = pointInfo.distance
          closestPoint = { index = index, point = point, info = pointInfo }
          bestAction = action
        end
      end
    end
  end

  if closestPoint and bestAction then
    local text = locale("melon_pumpkin.press_to_action", bestAction.actionText)

    if not state.showTextUI then
      utils.showTextUI(text)
      state.showTextUI = true
    end

    if IsControlJustPressed(0, 38) then
      utils.hideTextUI()
      state.showTextUI = false

      local label = "Processing point..."

      if bestAction.action == "watering" then
        if not hasItem(config.wateringCan.itemName, 1) then
          utils.notify(locale("melon_pumpkin.no_watercan"), "error")
          return false, 1000
        end
        label = locale("melon_pumpkin.watering_plants")
      elseif bestAction.action == "planting" then
        if not state.selectedCropName then
          utils.notify(locale("melon_pumpkin.crop_selection_cancelled"), "error")
          return false, 1000
        end

        local cropConf = config.crops[state.selectedCropName]
        if not hasItem(cropConf.seedItem, 1) then
          utils.notify(locale("melon_pumpkin.no_seeds_available", cropConf.label), "error")
          return false, 2000
        end

        if not removeItem(cropConf.seedItem, 1) then
          utils.notify(locale("melon_pumpkin.failed_to_remove_item"), "error")
          return false, 2000
        end
      end

      utils.progressBar({
        duration = bestAction.workTime,
        label = label,
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, move = true, combat = true },
        anim = bestAction.anim,
        prop = bestAction.prop,
      })

      if bestAction.action == "harvesting" then
        local ok = lib.callback.await(_e("server:melon_pumpkin:canHarvestCrop"), false, {
          lobbyId = client.lobby.id,
          pointIndex = closestPoint.index,
        })
        if not ok then
          return false, 2000
        end
      elseif bestAction.action == "planting" then
        local ok = lib.callback.await(_e("server:melon_pumpkin:canPlantCrop"), false, {
          lobbyId = client.lobby.id,
          pointIndex = closestPoint.index,
          cropName = state.selectedCropName,
        })
        if not ok then
          return false, 2000
        end
      end

      applyPointStateLocally(closestPoint.index, bestAction.targetState)

      if bestAction.action == "harvesting" then
        local cropConf = config.crops[closestPoint.point.cropName]
        pickUpHarvestedCrop(closestPoint.index, cropConf and cropConf.growthModel or nil)
      else
        local spreadRadius = 3.5

        for idx, otherPoint in pairs(client.currentTask.game.plantingPoints) do
          if idx ~= closestPoint.index then
            local dist = #(closestPoint.point.coords - otherPoint.coords)
            if dist <= spreadRadius then
              local targetState = bestAction.targetState
              local requiredState = bestAction.requiredState

              if requiredState == PlantState.EMPTY then
                if not otherPoint.state or otherPoint.state == PlantState.EMPTY then
                  applyPointStateLocally(idx, targetState)
                end
              elseif otherPoint.state == requiredState then
                applyPointStateLocally(idx, targetState)
              end
            end
          end
        end
      end

      utils.notify(locale("melon_pumpkin.point_processed", closestPoint.index, bestAction.action), "success")
      return true, 1000
    end

    return true, 0
  else
    if state.showTextUI then
      utils.hideTextUI()
      state.showTextUI = false
    end
  end

  return false, 1000
end

local function selectCrop()
  local options = {}

  for cropName, crop in pairs(config.crops) do
    table.insert(options, {
      label = crop.label,
      value = cropName,
    })
  end

  if #options == 0 then
    utils.notify(locale("melon_pumpkin.no_seeds_available"), "error")
    return nil
  end

  local input = lib.inputDialog(locale("melon_pumpkin.select_crop"), {
    {
      type = "select",
      label = locale("melon_pumpkin.crop_type"),
      options = options,
      required = true,
    },
  })

  if input and input[1] then
    return input[1]
  end

  return nil
end

function MelonPumpkinClient.selectCrop()
  state.selectedCropName = selectCrop()
  if not state.selectedCropName then
    local firstKey = next(config.crops)
    state.selectedCropName = firstKey
  end

  TriggerServerEvent(_e("server:melon_pumpkin:onCropSelected"), {
    lobbyId = client.lobby.id,
    cropName = state.selectedCropName,
  })

  return true
end

function MelonPumpkinClient.threadWorker()
  Citizen.CreateThread(function()
    local startTime = GetGameTimer()
    local searchRadius = 25.0

    state.nearbyPoints = getNearbyPoints(searchRadius)

    while client.currentTask do
      local wait = 1000

      if next(state.nearbyPoints) then
        for _, info in pairs(state.nearbyPoints) do
          drawPointMarker(info)
        end
        wait = 1
      end

      local now = GetGameTimer()
      if now - startTime > 1000 then
        local updated = getNearbyPoints(searchRadius)
        state.nearbyPoints = updated
        startTime = now
      end

      Citizen.Wait(wait)
    end
  end)

  Citizen.CreateThread(function()
    while client.currentTask do
      local wait = 1000
      local active, customWait = handlePointInteractionLoop()

      if active then
        wait = 0
      end

      if customWait then
        wait = customWait
      end

      Citizen.Wait(wait)
    end
  end)

  Citizen.CreateThread(function()
    local interval = (Config.debug and 5 or 30) * 1000

    while client.lobby and client.currentTask do
      processGrowthTimers()
      Citizen.Wait(interval)
    end
  end)

  Citizen.CreateThread(function()
    while client.lobby and client.currentTask do
      local wait = 2000
      local vehicle = cache.vehicle

      if vehicle and cache.seat == -1 then
        local delivery = client.currentTask.game.taskEntities.deliveryVehicle
        local deliveryNetId = delivery and delivery.netId

        if deliveryNetId and VehToNet(vehicle) == deliveryNetId then
          local sellNpcCoords = client.getClosestSellNpc()

          if sellNpcCoords then
            wait = 1000
            local sellPos = vector3(sellNpcCoords.x, sellNpcCoords.y, sellNpcCoords.z)
            local pedPos = GetEntityCoords(cache.ped)
            local distance = #(sellPos - pedPos)

            if distance < 5.0 then
              local result = lib.callback.await(_e("server:melon_pumpkin:onSellNpcInteraction"), false, {
                lobbyId = client.lobby.id,
              })

              if not result then
                utils.notify(locale("melon_pumpkin.sell_npc_interaction_error"), "error")
              elseif type(result) == "table" and result.error then
                utils.notify(result.error, "error")
                wait = 5000
              elseif result then
                return
              end
            end
          end
        end
      end

      Citizen.Wait(wait)
    end
  end)
end

function MelonPumpkinClient.clear()
  shared.debug("debug:MelonPumpkinClient.clear")

  if state.showTextUI then
    utils.hideTextUI()
  end

  for _, blip in pairs(state.fieldBlips) do
    RemoveBlip(blip)
  end

  for _, point in pairs(state.fieldPoints) do
    if point then
      point:remove()
    end
  end

  stopCarry()
  resetState()

  shared.debug("debug:MelonPumpkinClient.clear: State cleared")
end

function MelonPumpkinClient.start()
  shared.debug(
    "debug:MelonPumpkinClient.start",
    ("lobby: %s, field: %s"):format(
      client.lobby and client.lobby.id or "nil",
      client.currentTask and client.currentTask.game and client.currentTask.game.fieldId or "nil"
    )
  )

  local fieldConfig = getFieldConfig(client.currentTask.game.fieldId)
  if not fieldConfig then
    shared.debug(("MelonPumpkinClient start error: Field not found for ID %s"):format(client.currentTask.game.fieldId), "error")
    return false
  end

  resetState()

  -- field center + radius blips
  state.fieldBlips.center = utils.addBlip(fieldConfig.center, config.blips.field, true)
  state.fieldBlips.radius = utils.addRadiusBlip(fieldConfig.center, fieldConfig.radius, config.blips.field)

  for index, point in pairs(client.currentTask.game.plantingPoints) do
    state.fieldBlips["point_" .. index] = utils.addBlip(point.coords, config.blips.point)
  end

  state.fieldBlips.entity_deliveryVehicle =
    utils.addBlip(fieldConfig.deliveryVehicle.location, config.blips.deliveryVehicle, false)

  shared.debug(
    ("debug:MelonPumpkinClient.start: Field blips created for ID %s"):format(
      client.currentTask.game.fieldId
    )
  )

  if client.lobby.owner == cache.serverId then
    state.fieldPoints.entity_deliveryVehicle = lib.points.new({
      coords = fieldConfig.deliveryVehicle.location,
      distance = 50.0,
      meta = {
        key = "deliveryVehicle",
        model = fieldConfig.deliveryVehicle.model,
        coords = fieldConfig.deliveryVehicle.location,
      },
      onEnter = function(point)
        local meta = point.meta
        if not meta or not meta.key or not meta.model then
          return
        end

        local model = type(meta.model) == "string" and GetHashKey(meta.model) or meta.model
        if not IsModelValid(model) then
          shared.debug("debug:MelonPumpkinClient.onEnterSpawnTaskEntityPoint: Invalid model", meta.model)
          return
        end

        local coords = meta.coords or point.coords
        lib.requestModel(model)

        local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
        while not DoesEntityExist(veh) do
          Citizen.Wait(0)
        end

        local netId = lib.waitFor(function()
          if not NetworkGetEntityIsNetworked(veh) then
            NetworkRegisterEntityAsNetworked(veh)
          else
            local n = VehToNet(veh)
            if NetworkDoesNetworkIdExist(n) then
              return n
            end
          end
        end, false, false)

        SetModelAsNoLongerNeeded(model)
        SetEntityCoords(veh, coords.x, coords.y, coords.z)
        SetEntityRotation(veh, 0.0, 0.0, coords.w or 0.0, 2)
        utils.setFuel(veh, 100.0)

        local entityState = {
          key = meta.key,
          model = meta.model,
          coords = coords,
          netId = netId,
          spawned = true,
        }

        client.currentTask.game.taskEntities[meta.key] = entityState
        point:remove()
        state.fieldPoints["entity_" .. meta.key] = nil

        lib.callback.await(_e("server:melon_pumpkin:onVehicleSpawned"), false, client.lobby.id, entityState)
      end,
    })
  end

  if not Config.DisableCustomMarkers then
    lib.requestStreamedTextureDict("res_markers")
  end

  MelonPumpkinClient.threadWorker()
  utils.notify(locale("tasks.started"), "success")

  if client.lobby.owner == cache.serverId then
    MelonPumpkinClient.selectCrop()
  end

  return true
end

function MelonPumpkinClient.stop()
  shared.debug(
    "debug:MelonPumpkinClient.stop",
    ("lobby: %s, field: %s"):format(
      client.lobby and client.lobby.id or "nil",
      client.currentTask and client.currentTask.game and client.currentTask.game.fieldId or "nil"
    )
  )

  MelonPumpkinClient.clear()

  if not Config.DisableCustomMarkers then
    SetStreamedTextureDictAsNoLongerNeeded("res_markers")
  end

  return true
end

RegisterNetEvent(_e("client:melon_pumpkin:onVehicleSpawned"), function(entityState)
  if not entityState or not entityState.key then
    shared.debug(
      "debug:MelonPumpkinClient.onVehicleSpawned - Invalid entityState",
      ("entityState: %s"):format(json.encode(entityState)),
      "error"
    )
    return
  end

  client.currentTask.game.taskEntities[entityState.key] = entityState

  Citizen.CreateThread(function()
    local vehicle = lib.waitFor(function()
      if NetworkDoesEntityExistWithNetworkId(entityState.netId) then
        local v = NetToVeh(entityState.netId)
        if DoesEntityExist(v) then
          return v
        end
      end
    end, false, false)

    MultiplayerTasksClient.giveVehicleKey(GetVehicleNumberPlateText(vehicle), vehicle)
  end)
end)

RegisterNetEvent(_e("client:melon_pumpkin:onPlantingPointUpdate"), function(data)
  if not data.lobbyId then
    return
  end

  if not client.lobby or client.lobby.id ~= data.lobbyId then
    return
  end

  local point = client.currentTask.game.plantingPoints[data.pointIndex]

  if data.newState then
    point.state = data.newState
  end

  if data.cropName then
    point.cropName = data.cropName
  end

  if data.playerId ~= cache.serverId then
    local cropName = data.cropName
    local baseZ = state.pointGroundZValues[data.pointIndex] or point.coords.z
    local spawnCoords = vector3(point.coords.x, point.coords.y, baseZ)
    local model = getPlantModel(cropName, data.newState)
    local blipColor = 0

    if data.newState == PlantState.PLANTED then
      blipColor = 5
      if data.networkId then
        state.pointObjectNetIds[data.pointIndex] = data.networkId

        if Config.DisableCustomProps then
          local obj = NetToObj(data.networkId)
          if obj and DoesEntityExist(obj) then
            local h = getModelHeight(model)
            local offsetCoords = GetOffsetFromEntityInWorldCoords(obj, 0.0, 0.0, -(h / 1.3))
            SetEntityCoords(obj, offsetCoords.x, offsetCoords.y, offsetCoords.z)
          end
        end
      end
    elseif data.newState == PlantState.WATERED then
      blipColor = 29
    elseif data.newState == PlantState.GROWN then
      blipColor = 2
      if data.networkId then
        state.pointObjectNetIds[data.pointIndex] = data.networkId
      end
    elseif data.newState == PlantState.HARVESTED then
      blipColor = 17

      local blip = state.fieldBlips["point_" .. data.pointIndex]
      if blip then
        RemoveBlip(blip)
        state.fieldBlips["point_" .. data.pointIndex] = nil
      end

      state.nearbyPoints[data.pointIndex] = nil
    end

    local bl = state.fieldBlips["point_" .. data.pointIndex]
    if bl then
      SetBlipColour(bl, blipColor)
    end
  end
end)

RegisterNetEvent(_e("client:melon_pumpkin:onHarvestedCropPickedUp"), function(data)
  if not client.lobby or not client.currentTask or not data.lobbyId then
    return
  end

  if client.lobby.id ~= data.lobbyId then
    return
  end
end)

lib.callback.register(_e("server:melon_pumpkin:spawnObjectInDeliveryVehicle"), function(data)
  if not data or not data.deliveryVehicleNetId then
    shared.debug("debug:MelonPumpkinClient.spawnObjectInDeliveryVehicle - Invalid data", "error")
    return false
  end

  local vehicleNetId = data.deliveryVehicleNetId
  local vehicle = NetToVeh(vehicleNetId)

  if not vehicle or not DoesEntityExist(vehicle) then
    shared.debug("debug:MelonPumpkinClient.spawnObjectInDeliveryVehicle - Invalid delivery vehicle", "error")
    return false
  end

  local cropConfig = config.crops[data.cropName]
  local model = (cropConfig and cropConfig.growthModel) or "prop_veg_crop_03_pump"

  lib.requestModel(model)

  local offset = holdOffsets[data.loadedCount]
  if not offset then
    return false
  end

  local vehicleCoords = GetEntityCoords(vehicle)
  local obj = CreateObject(model, vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, true, true, false)

  shared.debug(("debug:melon_pumpkin:Object created: %s"):format(obj))

  while not DoesEntityExist(obj) do
    Wait(0)
  end

  SetEntityCollision(obj, false, false)
  SetEntityCompletelyDisableCollision(obj, true)
  SetEntityVisible(obj, false)
  SetModelAsNoLongerNeeded(model)

  AttachEntityToEntity(
    obj,
    vehicle,
    nil,
    offset.x,
    offset.y,
    offset.z,
    0.0,
    0.0,
    90.0,
    false,
    false,
    false,
    false,
    0,
    true
  )

  local netId = lib.waitFor(function()
    if not NetworkGetEntityIsNetworked(obj) then
      NetworkRegisterEntityAsNetworked(obj)
    else
      local n = ObjToNet(obj)
      if NetworkDoesNetworkIdExist(n) then
        return n
      end
    end
  end, false, false)

  SetEntityVisible(obj, true)
  return netId
end)

RegisterNetEvent(_e("client:melon_pumpkin:onCropSelected"), function(data)
  if not data or not data.cropName then
    shared.debug("debug:MelonPumpkinClient.onCropSelected - Invalid data", "error")
    return false
  end

  state.selectedCropName = data.cropName
end)

RegisterNetEvent(_e("client:melon_pumpkin:playWateringEffect"), function(data)
  local netId = data.networkId
  local cropName = data.cropName

  if not netId then
    return
  end

  local obj = NetToObj(netId)
  if not obj or not DoesEntityExist(obj) then
    return
  end

  local model = getPlantModel(cropName, PlantState.PLANTED)

  if Config.DisableCustomProps then
    local pos = GetEntityCoords(obj)
    local height = getModelHeight(model)

    SetEntityCoords(obj, pos.x, pos.y, pos.z + (height * 0.1))
  end
end)

RegisterNetEvent(_e("client:melon_pumpkin:playGrowthEffect"), function(data)
  local netId = data.networkId
  local cropName = data.cropName

  if not netId then
    return
  end

  local obj = NetToObj(netId)
  if not obj or not DoesEntityExist(obj) then
    return
  end

  local pos = GetEntityCoords(obj)

  TriggerServerEvent(_e("server:melon_pumpkin:deletePointObject"), {
    lobbyId = client.lobby.id,
    pointIndex = data.pointIndex,
  })

  local newNetId = spawnPointObject(cropName, data.newState, pos, data.pointIndex, data.lobbyId)

  if newNetId then
    local newObj = NetToObj(newNetId)
    if newObj and DoesEntityExist(newObj) then
      PlaceObjectOnGroundProperly(newObj)
    end
    state.pointObjectNetIds[data.pointIndex] = newNetId
  end
end)

if MultiplayerTasksClient and MultiplayerTasksClient.registerModuleState then
  MultiplayerTasksClient.registerModuleState("melon_pumpkin", MelonPumpkinClient, config)
end

if Config.debug then
  RegisterCommand("debug_melon_pumpkin", function()
    if not client.currentTask or not client.currentTask.game then
      utils.notify(locale("tasks.no_active_task"), "error")
      return
    end

    getNearbyPoints(50.0)

    local processed = 0

    for index, point in pairs(client.currentTask.game.plantingPoints) do
      if processed >= 10 then
        break
      end

      point.cropName = "melon"

      for _, st in pairs({ PlantState.PLANTED, PlantState.WATERED, PlantState.GROWN }) do
        applyPointStateLocally(index, st)
        Citizen.Wait(50)
      end

      processed = processed + 1
    end

    shared.debug("debug:FreelanceClient.debug_freelance", ("Processed %s points"):format(processed))
  end, false)
end