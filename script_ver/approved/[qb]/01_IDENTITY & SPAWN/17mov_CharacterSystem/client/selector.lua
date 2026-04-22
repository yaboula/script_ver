Selector.ObjectsToClear = {}
Selector.ActiveCharacter = nil
Selector.usedPositions = {}

function Selector.GenerateRandomScenarioIndex()
  local usedCount = #Selector.usedPositions
  local totalScenarios = #Selector.PedScenarios

  if usedCount == totalScenarios then
    return nil
  end

  while true do
    Wait(0)
    local randomIndex = math.random(1, totalScenarios)
    if not Selector.usedPositions[randomIndex] then
      Selector.usedPositions[randomIndex] = true
      return randomIndex
    end
  end
end

function Selector.Enter()
  Selector.Active = true
  OnSelectorEnter()

  CreateThread(function()
    while Selector.Active do
      local playerPed = PlayerPedId()
      SetEntityCoords(playerPed, Selector.InteriorCoords.x, Selector.InteriorCoords.y, Selector.InteriorCoords.z, false,
        false, false, false)
      FreezeEntityPosition(playerPed, true)
      SetEntityVisible(playerPed, false, false)
      Wait(50)
    end

    local playerPed = PlayerPedId()
    SetEntityVisible(playerPed, true, false)
    FreezeEntityPosition(playerPed, false)
  end)

  local interior = GetInteriorAtCoords(Selector.InteriorCoords.x, Selector.InteriorCoords.y, Selector.InteriorCoords.z)
  local startTime = GetGameTimer()

  while not interior do
    if GetGameTimer() - startTime > 5000 then
      Functions.Print("Cannot get interior at Selector.InteriorCoords. Make sure that you don't changed this value!")
      break
    end
    interior = GetInteriorAtCoords(Selector.InteriorCoords.x, Selector.InteriorCoords.y, Selector.InteriorCoords.z)
    Wait(100)
  end

  if Selector.RefreshInterior then
    PinInteriorInMemory(interior)
    RefreshInterior(interior)
  end

  local loadStartTime = GetGameTimer()
  while interior and not IsInteriorReady(interior) do
    if GetGameTimer() - loadStartTime > 10000 then
      Functions.Print("Interior loading took more than 10 seconds. Please redownload your stream folder from keymaster.")
      break
    end
    if Selector.RefreshInterior then
      PinInteriorInMemory(interior)
    end
    Wait(100)
  end

  local charactersPromise = promise.new()
  Selector.usedPositions = {}

  Functions.TriggerServerCallback("17mov_CharacterSystem:RequestCharacters", function(characters)
    Selector.Characters = characters

    for charIndex, character in pairs(characters) do
      if character.used then
        local scenarioData = Selector.PedScenarios[Selector.GenerateRandomScenarioIndex()]

        if character.position then
          character.location = Selector.ZonesName
          [GetNameOfZone(character.position.x, character.position.y, character.position.z)]
        end

        if scenarioData ~= nil then
          if not IsModelInCdimage(character.skinData.model) then
            character.skinData.model = tonumber(character.skinData.model)
          end

          Functions.LoadModel(character.skinData.model)

          local success, ped = pcall(CreatePed, 0, character.skinData.model,
            scenarioData.coordinates.x, scenarioData.coordinates.y, scenarioData.coordinates.z,
            0.0, false, true)

          if success then
            character.ped = ped
            table.insert(Selector.ObjectsToClear, character.ped)

            SetPedDefaultComponentVariation(character.ped)
            Skin.SetOnPed(character.ped, character.skinData)
            SetEntityRotation(character.ped, scenarioData.rotation.x, scenarioData.rotation.y, scenarioData.rotation.z, 2,
              false)
            FreezeEntityPosition(character.ped, true)
            SetPedCombatAttributes(character.ped, 46, true)
            SetPedFleeAttributes(character.ped, 0, false)
            SetPedCanRagdoll(character.ped, false)
            SetPedCanBeTargetted(character.ped, false)
            SetPedAsEnemy(character.ped, false)
            SetBlockingOfNonTemporaryEvents(character.ped, true)
            TaskSetBlockingOfNonTemporaryEvents(character.ped, true)
            RemoveAllPedWeapons(character.ped, true)

            if scenarioData.animDict then
              Functions.RequestAnimDict(scenarioData.animDict)
              TaskPlayAnim(character.ped, scenarioData.animDict, scenarioData.animClip, 8.0, 8.0, -1, 1, 0.0, false,
                false, false)
            elseif scenarioData.scenario then
              TaskStartScenarioInPlace(character.ped, scenarioData.scenario, 0, true)
            end

            if scenarioData.animProp then
              Functions.LoadModel(scenarioData.animProp.model)
              Functions.SpawnObject(scenarioData.animProp.model, function(propObject)
                table.insert(Selector.ObjectsToClear, propObject)
                AttachEntityToEntity(propObject, character.ped,
                  GetPedBoneIndex(character.ped, scenarioData.animProp.bone),
                  scenarioData.animProp.offset.x, scenarioData.animProp.offset.y, scenarioData.animProp.offset.z,
                  scenarioData.animProp.rotation.x, scenarioData.animProp.rotation.y, scenarioData.animProp.rotation.z,
                  false, false, false, true, 2, true)
              end, scenarioData.coordinates, false, true)
            end

            character.positionTable = scenarioData
          else
            Functions.Debug(
            "CANNOT SPAWN %s MODEL - IF IT'S ADDON, PLEASE MAKE SURE THAT IT'S STARTING BEFORE MULTICHARACTER SCRIPT. THIS ISSUE CAN ALSO GENERATE CUSTOM CLOTHING PACKS")
          end
        else
          Functions.Print("CANNOT SPAWN " ..
          charIndex .. " PED BECAUSE THERE'S NO FREE LOCATIONS. PLEASE ADD MORE IN configs/selector.lua")
        end
      end
    end

    Functions.SendNuiMessage("SetSeparator", { separator = Config.MoneySeparator })
    Functions.SendNuiMessage("ToggleSelector", {
      state = true,
      characters = characters,
      isDeletingEnabled = Selector.EnableDeleting
    })

    SetNuiFocusKeepInput(false)
    SetNuiFocus(true, true)
    DoScreenFadeIn(300)

    charactersPromise:resolve()

    local cutsceneIndex = 1
    while Selector.Active do
      local cutscenePromise = promise.new()

      Selector.PlayCutscene(Selector.Cutscenes[cutsceneIndex], characters, function()
        cutsceneIndex = cutsceneIndex + 1
        if not Selector.Cutscenes[cutsceneIndex] then
          cutsceneIndex = 1
        end
        cutscenePromise:resolve()
      end)

      Citizen.Await(cutscenePromise)
    end
  end)

  return Citizen.Await(charactersPromise)
end

function Selector.Exit()
  DoScreenFadeOut(10)

  Selector.Active = false
  Selector.ActiveCharacter = nil

  for i = 1, #Selector.ObjectsToClear do
    DeleteEntity(Selector.ObjectsToClear[i])
  end

  SetNuiFocus(false, false)
  Functions.SendNuiMessage("ToggleSelector", { state = false })
  OnSelectorExit()
end

function Selector.PlayCutscene(cutsceneData, characters, callback)
  Selector.CutsceneCam = CreateCam(cutsceneData.camName, true)

  SetCamCoord(Selector.CutsceneCam, cutsceneData.startingCoordinates.x, cutsceneData.startingCoordinates.y,
    cutsceneData.startingCoordinates.z)
  SetCamRot(Selector.CutsceneCam, cutsceneData.startingCameraRot.x, cutsceneData.startingCameraRot.y,
    cutsceneData.startingCameraRot.z, 2)
  SetCamFov(Selector.CutsceneCam, cutsceneData.startingFov)
  RenderScriptCams(true, false, 0, true, true)

  local progress = 0.0
  local endTime = GetGameTimer() + cutsceneData.duration

  while Selector.Active and (endTime > GetGameTimer() or Selector.ActiveCharacter == nil) do
    if not Selector.ActiveCharacter then
      DisplayRadar(false)

      local elapsedTime = GetGameTimer() - (endTime - cutsceneData.duration)
      progress = elapsedTime / cutsceneData.duration

      local camX = Functions.Lerp(cutsceneData.startingCoordinates.x, cutsceneData.endCoordinates.x, progress)
      local camY = Functions.Lerp(cutsceneData.startingCoordinates.y, cutsceneData.endCoordinates.y, progress)
      local camZ = Functions.Lerp(cutsceneData.startingCoordinates.z, cutsceneData.endCoordinates.z, progress)

      local rotX = Functions.Lerp(cutsceneData.startingCameraRot.x, cutsceneData.endCameraRot.x, progress)
      local rotY = Functions.Lerp(cutsceneData.startingCameraRot.y, cutsceneData.endCameraRot.y, progress)
      local rotZ = Functions.Lerp(cutsceneData.startingCameraRot.z, cutsceneData.endCameraRot.z, progress)

      local fov = Functions.Lerp(cutsceneData.startingFov, cutsceneData.endFov, progress)

      SetCamCoord(Selector.CutsceneCam, camX, camY, camZ)
      SetCamFov(Selector.CutsceneCam, fov)
      SetCamRot(Selector.CutsceneCam, rotX, rotY, rotZ, 2)

      if cutsceneData.shaking then
        ShakeCam(Selector.CutsceneCam, "HAND_SHAKE", 0.5)
      end
    else
      local activeChar = characters[Selector.ActiveCharacter]
      if activeChar and activeChar.positionTable then
        local camCoords = activeChar.positionTable.cameraCoordinates
        local camRot = activeChar.positionTable.cameraRot
        local camFov = activeChar.positionTable.cameraFov

        SetCamCoord(Selector.CutsceneCam, camCoords.x, camCoords.y, camCoords.z)
        SetCamFov(Selector.CutsceneCam, camFov)
        SetCamRot(Selector.CutsceneCam, camRot.x, camRot.y, camRot.z, 2)
      end
    end

    Wait(0)
  end

  RenderScriptCams(false, false, 0, true, true)
  DestroyCam(Selector.CutsceneCam, false)

  if callback and Selector.Active then
    callback()
  end
end

RegisterNUICallback("SetSelectedCharacter", function(data, cb)
  local selectedIndex = nil

  if Selector.Characters then
    for i = 1, #Selector.Characters do
      if Selector.Characters[i].id == data.character then
        selectedIndex = i
      end
    end
  end

  if Selector.Characters[selectedIndex].positionTable == nil then
    selectedIndex = nil
  end

  if Selector.ActiveCharacter ~= selectedIndex then
    DoScreenFadeOut(100)
    Wait(100)
    Selector.ActiveCharacter = selectedIndex
    Wait(100)
    DoScreenFadeIn(100)
  end

  cb({})
end)

RegisterNUICallback("SelectCharacter", function(data, cb)
  DoScreenFadeOut(100)
  Wait(350)
  Selector.Exit()

  local characterData = {
    citizenid = data.character.citizenid,
    position = data.character.position
  }

  TriggerServerEvent("17mov_CharacterSystem:SelectCharacter", characterData)
  cb({})
end)

RegisterNUICallback("DeleteCharacter", function(data, cb)
  Selector.Exit()

  local identifier = data.character.citizenid or data.character.license

  Functions.TriggerServerCallback("17mov_CharacterSystem:DeleteCharacter", function()
    Selector.Enter()
  end, identifier)

  cb({})
end)

RegisterNetEvent("17mov_CharacterSystem:CharacterChoosen", function(coords, isNewCharacter, skinData)
  while Selector.Active do
    Wait(10)
  end

  if isNewCharacter and Skin.Enabled then
    Skin.OpenMenu({
      {
        label = _L("Skin.Button.Save"),
        type = "accent",
        action = "callback",
        actionData = { callbackName = "SkinSave" }
      }
    }, "creator", true, skinData, coords)

    Wait(100)
    DoScreenFadeIn(100)
  else
    if Location.Enable and ((isNewCharacter and Location.EnableForNewCharacters) or (not isNewCharacter and Location.EnableForExistingCharacters)) then
      Location.Enter(coords, isNewCharacter)
    else
      if Location.Enable then
        TriggerEvent("17mov_CharacterSystem:PlayerSpawned", isNewCharacter)
      end

      Location.SpawnPlayer({
        name = "lastLocation",
        coords = coords,
        label = _L("Location.LastLocation"),
        type = "location"
      }, isNewCharacter)

      SetNuiFocus(false, false)
    end
  end
end)

RegisterNetEvent("17mov_CharacterSystem:OpenSelector", function()
  DoScreenFadeOut(100)
  Selector.Enter()
end)
