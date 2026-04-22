Core = nil
alreadyDoingSomething = false
nuiLoaded = false

fieldData = {
  currentArea = false,
  block = false,
  weedIndex = false,
}

isMenuOpen = {
  dealer = false,
  weed = false,
  grinder = false,
}

cam = false
weedData = {}
taskActive = false
removeStatusCache = {}

objects = {
  block_1 = {},
  block_2 = {},
  block_3 = {},
}

local grinderProps = {}
local peds = {}
local isFirstNUIWait = true

CreateThread(function()
  local coreObj, framework = GetCore()
  Config.Framework = framework
  Core = coreObj
end)

function WaitNUI()
  while not nuiLoaded do
    Wait(0)
  end
  if isFirstNUIWait then
    Wait(1500)
    isFirstNUIWait = false
  end
end

function SetPlayerInformations()
  WaitNUI()
  local playerInfo = TriggerCallback("mWeed:GetPlayerInformations")
  SendNUIMessage({
    action = "SET_PLAYER_INFORMATIONS",
    payload = {
      avatar = playerInfo.avatar,
      name = playerInfo.name,
    }
  })
  RefreshPlayerCash()
end

function RefreshPlayerInventory()
  local inventory = TriggerCallback("mWeed:GetPlayerInventory")
  SendNUIMessage({
    action = "REFRESH_PLAYER_INVENTORY",
    payload = inventory,
  })
end

function RefreshPlayerCash()
  local cash = TriggerCallback("mWeed:GetPlayerCash")
  SendNUIMessage({
    action = "REFRESH_PLAYER_CASH",
    payload = cash,
  })
end

RegisterNetEvent("mWeed:RefreshPlayerCash")
AddEventHandler("mWeed:RefreshPlayerCash", function()
  RefreshPlayerCash()
end)

RegisterNetEvent("mWeed:RefreshPlayerInventory")
AddEventHandler("mWeed:RefreshPlayerInventory", function()
  RefreshPlayerInventory()
end)

function SetLogo()
  SendNUIMessage({
    action = "SET_LOGO",
    payload = Config.Logo,
  })
end

function SetItemNames()
  SendNUIMessage({
    action = "SET_ITEM_NAMES",
    payload = Config.Items,
  })
end

function SetTranslation()
  SendNUIMessage({
    action = "SET_TRANSLATION",
    payload = Config.Translation,
  })
end

RegisterNUICallback("loaded", function(data, cb)
  nuiLoaded = true
  cb("ok")
end)

RegisterNUICallback("close", function(data, cb)
  SetNuiFocus(false, false)
  fieldData = {
    currentArea = false,
    block = false,
    weedIndex = false,
  }
  isMenuOpen.weed = false
  isMenuOpen.dealer = false
  isMenuOpen.grinder = false
  taskActive = false
  StopAnim()
  DestroyWeedCam()
  OnMenuClose()
  cb("ok")
end)

CreateThread(function()
  while true do
    Wait(1000)
    if NetworkIsSessionStarted() then
      SendNUIMessage({
        action = "CHECK_NUI",
        payload = GetCurrentResourceName(),
      })
      if nuiLoaded then
        SetLogo()
        SetItemNames()
        SetTranslation()
        return
      end
    end
  end
end)

function SpawnPed(model, position)
  if type(model) == "string" then
    model = GetHashKey(model)
  end
  if not IsModelValid(model) then
    return
  end
  LoadModel(model)
  local ped = CreatePed(0, model, position.x, position.y, position.z, position.w, false, true)
  while not DoesEntityExist(ped) do
    Citizen.Wait(0)
  end
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
  table.insert(peds, ped)
end

AddEventHandler("onResourceStop", function(resourceName)
  if resourceName == GetCurrentResourceName() then
    for _, ped in pairs(peds) do
      if DoesEntityExist(ped) then
        DeleteEntity(ped)
      end
    end
    for _, grinderProp in pairs(grinderProps) do
      if DoesEntityExist(grinderProp) then
        DeleteEntity(grinderProp)
      end
    end
    DestroyWeedCam()
    for _, blockObjects in pairs(objects) do
      if blockObjects then
        for _, objData in pairs(blockObjects) do
          if objData then
            DeleteEntity(objData.obj)
          end
        end
      end
    end
  end
end)

function CreateBlip(label, coords, sprite, scale, color, radius)
  local blip = AddBlipForCoord(coords)
  SetBlipSprite(blip, sprite)
  SetBlipColour(blip, color)
  SetBlipDisplay(blip, 4)
  SetBlipScale(blip, scale)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(label)
  EndTextCommandSetBlipName(blip)
  if radius then
    local radiusBlip = AddBlipForRadius(coords, radius)
    SetBlipColour(radiusBlip, color)
  end
end

-- Spawn dealer NPC and blip
CreateThread(function()
  SpawnPed(Config.Dealer.npc.model, Config.Dealer.position)
  if Config.Dealer.blip.enable then
    CreateBlip(
      Config.Dealer.blip.label,
      Config.Dealer.position,
      Config.Dealer.blip.sprite,
      Config.Dealer.blip.scale,
      Config.Dealer.blip.color
    )
  end
end)

-- Spawn grinder props and blips
CreateThread(function()
  for _, position in pairs(Config.GrinderLocations.positions) do
    local grinderProp = PropSpawner(
      Config.GrinderLocations.object.model,
      vector3(position.x, position.y, position.z),
      position.w
    )
    grinderProps[#grinderProps + 1] = grinderProp
  end
  if Config.GrinderLocations.blip.enable then
    for _, position in pairs(Config.GrinderLocations.positions) do
      CreateBlip(
        Config.GrinderLocations.blip.label,
        position,
        Config.GrinderLocations.blip.sprite,
        Config.GrinderLocations.blip.scale,
        Config.GrinderLocations.blip.color
      )
    end
  end
end)

-- Spawn weed area blips
CreateThread(function()
  if Config.Weeds.blip.enable then
    for _, area in pairs(Config.Weeds.areas) do
      CreateBlip(
        Config.Weeds.blip.label,
        area.mainLocation,
        Config.Weeds.blip.sprite,
        Config.Weeds.blip.scale,
        Config.Weeds.blip.color,
        area.radius
      )
    end
  end
end)

RegisterNetEvent("mWeed:SendNotification")
AddEventHandler("mWeed:SendNotification", function(message)
  SendNUIMessage({
    action = "SEND_NOTIFICATION",
    payload = message,
  })
end)

function DestroyWeedCam()
  if DoesCamExist(cam) then
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 1000, true, true)
  end
end

function ProgressBar(text, time)
  time = time or 5000
  SendNUIMessage({
    action = "PROGRESS_BAR",
    payload = {
      text = text,
      time = time,
    }
  })
end

RegisterNetEvent("mWeed:UpdatePlayerWeedData")
AddEventHandler("mWeed:UpdatePlayerWeedData", function(areaIndex, blockName, weedIndex, data)
  UpdatePlayerWeedData(areaIndex, blockName, weedIndex, data)
end)

RegisterNetEvent("mWeed:ShowRollReward")
AddEventHandler("mWeed:ShowRollReward", function(rewardItems)
  SendNUIMessage({
    action = "SHOW_ROLL_REWARD",
    payload = rewardItems,
  })
end)

function UpdatePlayerWeedData(areaIndex, blockName, weedIndex, data)
  areaIndex = tostring(areaIndex)
  if not weedData[areaIndex] then
    weedData[areaIndex] = {}
  end
  if not weedData[areaIndex][blockName] then
    weedData[areaIndex][blockName] = {}
  end
  weedIndex = tostring(weedIndex)
  weedData[areaIndex][blockName][weedIndex] = data
  UpdateUIWeedData()
  SpawnAllWeeds()
end

RegisterNetEvent("mWeed:SetPlayerWeedData")
AddEventHandler("mWeed:SetPlayerWeedData", function(data)
  weedData = data
  UpdateUIWeedData()
end)

function UpdateUIWeedData()
  if isMenuOpen.weed and fieldData.currentArea then
    local areaKey = tostring(fieldData.currentArea)
    if weedData[areaKey] then
      SendNUIMessage({
        action = "UPDATE_WEED_DATA",
        payload = weedData[areaKey],
      })
    end
  end
end

function CreateStatusCache(areaIndex, blockName, weedIndex)
  if alreadyDoingSomething then
    return
  end
  areaIndex = tostring(areaIndex)
  weedIndex = tostring(weedIndex)

  if not removeStatusCache[areaIndex] then
    removeStatusCache[areaIndex] = {}
  end
  if not removeStatusCache[areaIndex][blockName] then
    removeStatusCache[areaIndex][blockName] = {}
  end
  if not removeStatusCache[areaIndex][blockName][weedIndex] then
    removeStatusCache[areaIndex][blockName][weedIndex] = {
      timer = GetGameTimer() + Config.GeneralSettings.decayTime()
    }
  end
end

-- Status decay loop: periodically reduces water and floundering
CreateThread(function()
  while true do
    if weedData then
      for areaIndex, areaData in pairs(weedData) do
        for blockName, blockData in pairs(areaData) do
          for weedIndex, plantData in pairs(blockData) do
            if plantData and plantData.growth ~= false then
              CreateStatusCache(areaIndex, blockName, weedIndex)
              local areaKey = tostring(areaIndex)
              if removeStatusCache[areaKey]
                  and removeStatusCache[areaKey][blockName]
                  and removeStatusCache[areaKey][blockName][tostring(weedIndex)] then
                local cacheEntry = removeStatusCache[areaKey][blockName][tostring(weedIndex)]
                if GetGameTimer() >= cacheEntry.timer then
                  if not alreadyDoingSomething then
                    TriggerServerEvent("mWeed:removeStatus", areaIndex, blockName, weedIndex)
                    cacheEntry.timer = GetGameTimer() + Config.GeneralSettings.decayTime()
                  end
                end
              end
            end
          end
        end
      end
      Wait(3000)
    else
      Wait(5000)
    end
  end
end)

function PropSpawner(model, position, heading)
  if type(model) == "string" then
    model = GetHashKey(model)
  end
  if not IsModelValid(model) then
    return
  end
  LoadModel(model)
  local objectHandle = CreateObject(model, position, false, true)
  PlaceObjectOnGroundProperly(objectHandle)
  if heading then
    SetEntityHeading(objectHandle, heading)
  end
  FreezeEntityPosition(objectHandle, true)
  return objectHandle
end

function SetObjData(areaIndex, blockName, weedIndex, objectHandle)
  weedIndex = tostring(weedIndex)
  areaIndex = tostring(areaIndex)
  if not weedData[areaIndex] then return end
  if not weedData[areaIndex][blockName] then return end
  if not weedData[areaIndex][blockName][weedIndex] then return end

  if not objects[blockName] then
    objects[blockName] = {}
  end
  objects[blockName][weedIndex] = {
    obj = objectHandle,
    growth = weedData[areaIndex][blockName][weedIndex].growth,
  }
end

function CheckShouldDeleteProp(areaIndex, blockName, weedIndex)
  weedIndex = tostring(weedIndex)
  areaIndex = tostring(areaIndex)
  if not weedData[areaIndex] then return end
  if not weedData[areaIndex][blockName] then return end
  if not weedData[areaIndex][blockName][weedIndex] then return end
  if not objects[blockName] then return end
  if not objects[blockName][weedIndex] then return end

  local currentGrowth = weedData[areaIndex][blockName][weedIndex].growth
  local storedGrowth = objects[blockName][weedIndex].growth
  if currentGrowth ~= storedGrowth then
    DeleteEntity(objects[blockName][weedIndex].obj)
    objects[blockName][weedIndex] = nil
  end
end

function SpawnAllWeeds()
  if not weedData then return end
  for areaIndex, areaData in pairs(weedData) do
    for blockName, blockData in pairs(areaData) do
      for weedIndex, plantData in pairs(blockData) do
        if plantData and plantData.growth ~= false then
          SpawnProps(areaIndex, blockName, weedIndex)
        end
      end
    end
  end
end

RegisterNetEvent("mWeed:DestroyedWeed")
AddEventHandler("mWeed:DestroyedWeed", function(areaIndex, blockName, weedIndex)
  areaIndex = tostring(areaIndex)
  weedIndex = tostring(weedIndex)
  DeleteProp(blockName, weedIndex)
  if removeStatusCache[areaIndex] and removeStatusCache[areaIndex][blockName] and removeStatusCache[areaIndex][blockName][weedIndex] then
    removeStatusCache[areaIndex][blockName][weedIndex] = nil
  end
end)

function DeleteProp(blockName, weedIndex)
  weedIndex = tostring(weedIndex)
  if not objects[blockName] then return end
  if not objects[blockName][weedIndex] then return end
  if DoesEntityExist(objects[blockName][weedIndex].obj) then
    DeleteEntity(objects[blockName][weedIndex].obj)
    objects[blockName][weedIndex] = nil
  end
end

function DeleteProps()
  for blockName, blockObjects in pairs(objects) do
    for weedIndex, _ in pairs(blockObjects) do
      DeleteProp(blockName, weedIndex)
    end
  end
end

-- Weed growth stage prop models:
-- Growth 1: -305885281 (small seedling)
-- Growth 2: 1027382312 (small plant)
-- Growth 3: -928937343 (medium plant)
-- Growth 4: 469652573  (fully grown)
local GROWTH_MODELS = {
  [1] = -305885281,
  [2] = 1027382312,
  [3] = -928937343,
  [4] = 469652573,
}

function SpawnProps(areaIndex, blockName, weedIndex)
  weedIndex = tostring(weedIndex)
  areaIndex = tostring(areaIndex)
  if not weedData[areaIndex] then return end
  if not weedData[areaIndex][blockName] then return end
  if not weedData[areaIndex][blockName][weedIndex] then return end

  local growthStage = weedData[areaIndex][blockName][weedIndex].growth
  local modelHash = GROWTH_MODELS[growthStage]
  if not modelHash then return end

  CheckShouldDeleteProp(areaIndex, blockName, weedIndex)

  -- Check if object already exists
  local existingObj = objects[blockName] and objects[blockName][weedIndex]
  if existingObj then
    if DoesEntityExist(objects[blockName][tostring(weedIndex)].obj) then
      return
    end
  end

  local areaNum = tonumber(areaIndex)
  local weedNum = tonumber(weedIndex)
  local area = Config.Weeds.areas[areaNum]
  if not area then return end
  local locationBlock = area.weedLocations[blockName]
  if not locationBlock then return end
  local locationEntry = locationBlock[weedNum]
  if not locationEntry then return end

  local spawnedObj = PropSpawner(modelHash, locationEntry[1])
  SetObjData(areaIndex, blockName, weedIndex, spawnedObj)
end
