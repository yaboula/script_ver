Photos.Enabled = false
Photos.PhotosToUpload = {}
Photos.LastImageReciveTimer = 0

function Photos.SwitchShadows(enabled)
  local value = 0.0
  if enabled then
    value = 1.0
  end
  CascadeShadowsClearShadowSampleType()
  RopeDrawShadowEnabled(enabled)
  CascadeShadowsSetAircraftMode(enabled)
  CascadeShadowsEnableEntityTracker(enabled)
  CascadeShadowsSetDynamicDepthMode(enabled)
  CascadeShadowsSetEntityTrackerScale(value)
  CascadeShadowsSetDynamicDepthValue(value)
  CascadeShadowsSetCascadeBoundsScale(value)
end

function Photos.ClearPedTasks()
  CreateThread(function()
    while Photos.Enabled do
      if DoesEntityExist(Photos.Scene.Ped.obj) then
        ClearPedTasksImmediately(Photos.Scene.Ped.obj)
      end
      Wait(0)
    end
  end)
end

function Photos.Enter()
  Photos.Enabled = true
  local componentNames = {}
  for _, component in pairs(Photos.Components) do
    table.insert(componentNames, component.name)
  end

  Photos.Scene.Greenscreen.obj = Functions.SpawnObject(Photos.Scene.Greenscreen.model, nil, Photos.Scene.Greenscreen.coords, false, true)
  SetEntityRotation(Photos.Scene.Greenscreen.obj, Photos.Scene.Greenscreen.rotation.x, Photos.Scene.Greenscreen.rotation.y, Photos.Scene.Greenscreen.rotation.z, 0, false)

  local greenScreenCoords = Photos.Scene.Greenscreen.coords
  Photos.Scene.Cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", greenScreenCoords.x, greenScreenCoords.y, greenScreenCoords.z, 0.0, 0.0, Photos.Scene.Greenscreen.cameraHeading, 40.0, true, 2)

  Photos.SwitchShadows(false)
  Photos.ClearPedTasks()
  SetNuiFocus(true, true)

  local pedModels = {
    { model = "mp_m_freemode_01", disabledComponents = {} },
    { model = "mp_f_freemode_01", disabledComponents = {} }
  }

  Functions.SendNuiMessage("TogglePhotos", {
    state = true,
    components = componentNames,
    peds = pedModels
  })

  TriggerEvent("qb-weathersync:client:DisableSync")

  while Photos.Enabled do
    NetworkOverrideClockTime(12, 0, 0)
    Wait(0)
  end
end

function Photos.Exit()
  Photos.Enabled = false
  Photos.SwitchShadows(true)
  SetNuiFocus(false, false)
  Functions.SendNuiMessage("TogglePhotos", { state = false })

  DeletePed(Photos.Scene.Ped.obj)
  DeleteEntity(Photos.Scene.Greenscreen.obj)
  DestroyCam(Photos.Scene.Cam, true)
  RenderScriptCams(false, false, 0, true, false)

  Photos.Scene.Ped.obj = nil
  Photos.Scene.Greenscreen.obj = nil
  Photos.Scene.Cam = nil

  TriggerEvent("qb-weathersync:client:EnableSync")
end

function Photos.GetComponentByName(componentName)
  for _, componentData in pairs(Photos.Components) do
    if componentData.name == componentName then
      return componentData
    end
  end
  return nil
end

function Photos.Upload()
  if #Photos.PhotosToUpload > 0 then
    TriggerServerEvent("17mov_CharacterSystem:UploadPhotos", Photos.PhotosToUpload)
    Photos.PhotosToUpload = {}
  end
end

RegisterNUICallback("ExitPhotos", function(data, cb)
  Photos.Exit()
  cb({})
end)

RegisterNUICallback("RecivePhoto", function(data, cb)
  local componentData = Functions.DeepCopy(Photos.GetComponentByName(data.component))
  if not componentData then
    cb({})
    return
  end

  if data.component == "head_1" then
    local translationTable = nil
    if data.model == "mp_m_freemode_01" then
      translationTable = Skin.MaleFaceTranslation
      componentData.name = "dad"
    elseif data.model == "mp_f_freemode_01" then
      translationTable = Skin.FemaleFaceTranslation
      componentData.name = "mom"
    end

    if translationTable then
      local foundMatch = false
      for original, translated in pairs(translationTable) do
        if data.drawable == translated then
          foundMatch = true
          data.drawable = original
          break
        end
      end
      if not foundMatch then
        if Functions.Debug then
          Functions.Debug("SKIPPING THIS HEAD AS IT BELONGS TO DIFFERENT GENDER")
        end
        cb({})
        return
      end
    end
  end

  Photos.LastImageReciveTimer = GetGameTimer()
  table.insert(Photos.PhotosToUpload, {
    image = data.image,
    model = data.model,
    drawable = data.drawable,
    component = componentData
  })

  if Functions.Debug then
    Functions.Debug(string.format("Recived photo. Component: %s. Drawable: %s, Model: %s", data.component, data.drawable, data.model))
  end

  if #Photos.PhotosToUpload > 5 then
    Photos.Upload()
  else
    SetTimeout(5000, function()
      if (GetGameTimer() - Photos.LastImageReciveTimer) > 4000 then
        Photos.Upload()
      end
    end)
  end
  cb({})
end)

local createdPedPool = {}
RegisterNUICallback("GetMaxDrawables", function(data, cb)
  local modelHash = GetHashKey(data.model)
  local pedSpawnCoords = GetOffsetFromEntityInWorldCoords(Photos.Scene.Greenscreen.obj, Photos.Scene.Ped.offset.x, Photos.Scene.Ped.offset.y, Photos.Scene.Ped.offset.z)
  local currentPedModel = Photos.Scene.Ped.obj and GetEntityModel(Photos.Scene.Ped.obj)

  if not Photos.Scene.Ped.obj or currentPedModel ~= modelHash then
    for i = 1, #createdPedPool do
      DeletePed(createdPedPool[i])
      createdPedPool[i] = nil
    end

    Functions.LoadModel(modelHash)
    Photos.Scene.Ped.obj = CreatePed(0, modelHash, pedSpawnCoords.x, pedSpawnCoords.y, pedSpawnCoords.z, Photos.Scene.Ped.heading, false, true)
    SetPedDefaultComponentVariation(Photos.Scene.Ped.obj)
    table.insert(createdPedPool, Photos.Scene.Ped.obj)
    FreezeEntityPosition(Photos.Scene.Ped.obj, true)
  end

  local componentData = Photos.GetComponentByName(data.component)
  local maxDrawables = 0
  if componentData then
    if componentData.type == "component" then
      maxDrawables = GetNumberOfPedDrawableVariations(Photos.Scene.Ped.obj, componentData.id)
    elseif componentData.type == "prop" then
      maxDrawables = GetNumberOfPedPropDrawableVariations(Photos.Scene.Ped.obj, componentData.id)
    end
  end

  cb({ maxDrawables = maxDrawables })
end)

local headBlendComponents = {
  head_1 = true,
  mask_1 = true,
  hair_1 = true,
  ear_1 = true
}

RegisterNUICallback("RequestComponent", function(data, cb)
  local componentData = Photos.GetComponentByName(data.component)

  for i = 1, #createdPedPool do
    if createdPedPool[i] ~= Photos.Scene.Ped.obj then
      DeletePed(createdPedPool[i])
      createdPedPool[i] = nil
    end
  end

  if componentData then
    local pedHeading = Photos.Scene.Ped.heading
    if componentData.rotatePed then
      pedHeading = (pedHeading + componentData.rotatePed) % 360
    end

    local cameraCoords = GetOffsetFromEntityInWorldCoords(Photos.Scene.Greenscreen.obj, componentData.offset.x, componentData.offset.y, componentData.offset.z)
    SetCamCoord(Photos.Scene.Cam, cameraCoords.x, cameraCoords.y, cameraCoords.z)
    RenderScriptCams(true, false, 0, true, false)

    local pedModel = GetEntityModel(Photos.Scene.Ped.obj)
    local pedCoords = GetEntityCoords(Photos.Scene.Ped.obj) - vec3(0.0, 0.0, 1.0)
    local femaleModelHash = GetHashKey("mp_f_freemode_01")
    local shapeMix = (pedModel == femaleModelHash) and 0.0 or 1.0
    local skinMix = (pedModel == femaleModelHash) and 0.0 or 1.0

    if headBlendComponents[data.component] then
      if data.component == "head_1" then
        local transformedSkinTone = Skin.TransfromSkinTone(data.drawable, 45)
        SetPedHeadBlendData(Photos.Scene.Ped.obj, data.drawable, data.drawable, 0, transformedSkinTone, transformedSkinTone, 0, shapeMix, skinMix, 0.5, true)
      else
        SetPedHeadBlendData(Photos.Scene.Ped.obj, 44, 22, 0, 44, 22, 0, shapeMix, skinMix, 0.5, true)
      end
      SetPedHairColor(Photos.Scene.Ped.obj, 2, 2)
    else
      DeleteEntity(Photos.Scene.Ped.obj)
      Photos.Scene.Ped.obj = CreatePed(0, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, false, true)
      SetPedDefaultComponentVariation(Photos.Scene.Ped.obj)
      table.insert(createdPedPool, Photos.Scene.Ped.obj)
      FreezeEntityPosition(Photos.Scene.Ped.obj, true)
      SetPedComponentVariation(Photos.Scene.Ped.obj, 0, -1, -1, -1)
    end

    SetEntityHeading(Photos.Scene.Ped.obj, pedHeading)

    local defaultDrawables = {
      [0] = -1, [1] = 0, [2] = -1, [3] = -1, [4] = -1, [5] = 0,
      [6] = -1, [7] = 0, [8] = -1, [9] = 0, [10] = -1, [11] = -1
    }

    for _, comp in pairs(Photos.Components) do
      if comp.type == "component" then
        SetPedComponentVariation(Photos.Scene.Ped.obj, comp.id, defaultDrawables[comp.id] or 0, 0, 0)
      elseif comp.type == "prop" then
        ClearPedProp(Photos.Scene.Ped.obj, comp.id)
      end
    end

    if Skin.InputsToShift[data.component] then
      data.drawable = data.drawable - 1
    end

    local texture = 0
    if componentData.type == "component" then
      SetPedPreloadVariationData(Photos.Scene.Ped.obj, componentData.id, data.drawable, texture)
      while not HasPedPreloadVariationDataFinished(Photos.Scene.Ped.obj) do
        Wait(0)
      end
      SetPedComponentVariation(Photos.Scene.Ped.obj, componentData.id, data.drawable, texture, 0)
    elseif componentData.type == "prop" then
      SetPedPreloadPropData(Photos.Scene.Ped.obj, componentData.id, data.drawable, 0)
      while not HasPedPreloadPropDataFinished(Photos.Scene.Ped.obj) do
        Wait(0)
      end
      SetPedPropIndex(Photos.Scene.Ped.obj, componentData.id, data.drawable, 0, false)
    end
  end

  Wait(100)
  cb({})
end)

exports("OpenClothesPhotos", Photos.Enter)
RegisterNetEvent("17mov_CharacterSystem:OpenClothesPhotos", Photos.Enter)