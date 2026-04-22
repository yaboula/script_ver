if Config.Showcase ~= nil then
  return
end

if Selector.Enable then
  CreateThread(function()
    while not Config.Framework do
      if Functions.Debug then
        Functions.Debug("LOADING FRAMEWORK")
      end
      Wait(10)
    end

    while not Functions.NuiLoaded do
      if Functions.Debug then
        Functions.Debug("LOADING NUI")
      end
      Wait(10)
    end

    Functions.SendNuiMessage("SetNuiBlur", {
      state = Config.NuiBlur
    })

    while not NetworkIsSessionStarted() do
      if Functions.Debug then
        Functions.Debug("SESSION: ", NetworkIsSessionStarted())
      end
      Wait(0)
    end

    local startTime = GetGameTimer()
    while DisableSpawnManager == nil and (GetGameTimer() - startTime) < 1000 do
      Citizen.Wait(10)
    end

    if DisableSpawnManager then
      DisableSpawnManager()
    else
      if Functions.Print then
        Functions.Print("THE DisableSpawnManager FUNCTION DOESN'T EXIST. USING FALLBACK - PLEASE UPDATE UR RESOURCE PROPERLY")
      end
      if GetResourceState("spawnmanager") == "started" then
        exports.spawnmanager:setAutoSpawn(false)
      end
    end

    if Functions.Debug then
      Functions.Debug("OPENING SELECTOR")
    end

    DoScreenFadeOut(10)
    Selector.Enter()

    if Functions.Debug then
      Functions.Debug("SELECTOR OPENED")
    end

    Wait(100)
    ShutDownLoadingScreen()

    if Functions.Debug then
      Functions.Debug("LOADINGSCREEN SHUTDOWN")
    end

    SetNuiFocus(false, false)
    Wait(50)
    SetNuiFocus(true, true)
  end)
end