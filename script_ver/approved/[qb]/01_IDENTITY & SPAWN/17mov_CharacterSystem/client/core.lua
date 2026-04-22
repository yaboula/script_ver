local Callbacks = {}
local callbackIdCounter = 0
SpawnedObjects = {}
Functions.NuiLoaded = false

function Functions.SendNuiMessage(action, payload)
  SendNUIMessage({
    action = action,
    payload = payload
  })
end

function Functions.LoadModel(model)
  if not model then
    if Functions.Debug then
      Functions.Debug("MODEL IS NIL")
    end
    return
  end

  local modelHash = model
  if not IsModelInCdimage(modelHash) then
    local numericModel = tonumber(model)
    if numericModel and IsModelInCdimage(math.floor(numericModel)) then
      modelHash = math.floor(numericModel)
    else
      if Functions.Debug then
        Functions.Debug("CAN'T LOAD BECAUSE MODEL DOESNT EXIST: " .. tostring(model))
      end
      return
    end
  end

  if HasModelLoaded(modelHash) then
    return
  end

  local startTime = GetGameTimer()
  RequestModel(modelHash)

  while not HasModelLoaded(modelHash) do
    RequestModel(modelHash)
    Wait(100)
    local elapsedTime = GetGameTimer() - startTime
    if elapsedTime > 25000 then
      if Functions.Debug then
        Functions.Debug("Failed to load model " .. tostring(modelHash) .. " after 25 seconds.")
      end
      break
    elseif elapsedTime > 15000 then
      if Functions.Debug then
        Functions.Debug("Loading model " .. tostring(modelHash) .. " is taking longer than 15 seconds.")
      end
    end
  end
end

function Functions.RequestAnimDict(animDict)
  if HasAnimDictLoaded(animDict) then
    return
  end
  RequestAnimDict(animDict)
  while not HasAnimDictLoaded(animDict) do
    Wait(0)
  end
end

function Functions.SpawnObject(model, onSpawnCallback, coords, isNetwork, freeze)
  local playerPed = PlayerPedId()
  local modelHash = model

  if type(model) == "string" then
    modelHash = GetHashKey(model)
  end

  if not IsModelInCdimage(modelHash) then
    if Functions.Error then
      Functions.Error("CAN'T SPAWN OBJECT BECAUSE MODEL DOESNT EXIST: " .. tostring(model))
    end
    return
  end

  local spawnCoords = coords
  if not spawnCoords then
    spawnCoords = GetEntityCoords(playerPed)
  elseif type(spawnCoords) == "table" then
    spawnCoords = vec3(spawnCoords.x, spawnCoords.y, spawnCoords.z)
  end

  isNetwork = isNetwork ~= false
  freeze = freeze == true

  Functions.LoadModel(modelHash)
  local obj = CreateObjectNoOffset(modelHash, spawnCoords.x, spawnCoords.y, spawnCoords.z, isNetwork, true, true)

  if type(coords) == "vector4" then
    SetEntityHeading(obj, coords.w)
  end

  table.insert(SpawnedObjects, obj)
  FreezeEntityPosition(obj, freeze)
  SetEntityLodDist(obj, 500)

  if onSpawnCallback then
    onSpawnCallback(obj)
  end

  return obj
end

function Functions.DeleteEntity(entity)
  if entity == nil then
    if Functions.Error then
      Functions.Error("ATTEMPTED TO DELETE A NIL OBJECT")
    end
    return
  end

  if type(entity) ~= "number" then
    if Functions.Error then
      Functions.Error("ATTEMPTED TO DELETE A " .. type(entity) .. " TYPE: " .. tostring(entity))
    end
    return
  end

  DetachEntity(entity, false, false)
  SetEntityAsMissionEntity(entity, false, true)
  DeleteObject(entity)

  for i, spawnedEntity in ipairs(SpawnedObjects) do
    if spawnedEntity == entity then
      table.remove(SpawnedObjects, i)
      return
    end
  end
end

function Functions.ShowHelpNotification(message)
  if message == nil then
    return
  end
  AddTextEntry("HelpNotification", message)
  DisplayHelpTextThisFrame("HelpNotification", false)
end

function Functions.TriggerServerCallback(eventName, callback, ...)
  callbackIdCounter = callbackIdCounter + 1
  local currentId = callbackIdCounter

  if not Callbacks[eventName] then
    Callbacks[eventName] = {}
  end

  Callbacks[eventName][currentId] = callback
  TriggerServerEvent("17mov_Callbacks:GetResponse" .. Functions.ResourceName, eventName, currentId, ...)
end

RegisterNetEvent("17mov_Callbacks:receiveData" .. Functions.ResourceName, function(eventName, callbackId, ...)
  if Callbacks[eventName] and Callbacks[eventName][callbackId] then
    Callbacks[eventName][callbackId](...)
    Callbacks[eventName][callbackId] = nil
    if next(Callbacks[eventName]) == nil then
      Callbacks[eventName] = nil
    end
  end
end)

RegisterNUICallback("NuiLoaded", function(data, cb)
  Functions.NuiLoaded = true
  cb({})
end)

AddEventHandler("onResourceStop", function(resourceName)
  if Functions.ResourceName ~= resourceName then
    return
  end

  for _, entity in pairs(SpawnedObjects) do
    if type(entity) == "table" then
      for _, subEntity in pairs(entity) do
        if type(subEntity) == "number" and DoesEntityExist(subEntity) then
          DeleteEntity(subEntity)
        end
      end
    elseif type(entity) == "number" and DoesEntityExist(entity) then
      DeleteEntity(entity)
    end
  end
end)