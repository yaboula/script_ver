Core = nil
nuiLoaded = false
menuOpen = false



function NuiMessage(action, payload)
    while not nuiLoaded do
        Wait(0)
    end
    SendNUIMessage({
        action = action,
        payload = payload
    })
end

RegisterNUICallback("loaded", function(data, cb)
    nuiLoaded = true
    cb("ok")
end)

Citizen.CreateThread(function()
    while not nuiLoaded do
        Wait(0)
    end
    NuiMessage('ItemImagesFolder', Config.ItemImagesFolder)
    NuiMessage('CONFIG_ALLOWPERM', Config.AllowPermission)
    NuiMessage('CONFIG_LOCALES', Config.Locales)
    NuiMessage('CONFIG_ONLINEOVER', Config.OnlineOverviews)
    NuiMessage('CONFIG_PLAYERINFO', Config.playerinfoCategory)
    NuiMessage('CONFIG_PLAYEROPTIONS', Config.PlayerOptions)
    NuiMessage('CONFIG_BANSETTINGS', Config.BanSettings)
    NuiMessage('CONFIG_LASERINFO', Config.LaserInfo)
    NuiMessage('CONFIG_NOCLIP', Config.NoclipDesc)
    NuiMessage('CONFIG_WEATHER', Config.WeatherOption)
    NuiMessage('CONFIG_LASERKEYBIND', Config.LaserKeybind)
    NuiMessage('maincategory', Config.mainCategory)
end)



CreateThread(function()
    while Core == nil do
        Wait(0)
    end
    while not nuiLoaded do
        if NetworkIsSessionStarted() then
            SendNUIMessage({
                action = "CHECK_NUI",

            })
        end
        Wait(2000)
    end
end)
RegisterNUICallback('closeMenu', function()
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    menuOpen = false
end)

RegisterNUICallback('mouseaction', function(data, cb)
    if menuOpen then
        if data then
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(false)
        else
            SetNuiFocus(true, false)
            SetNuiFocusKeepInput(true)
        end
    end
end)


onlinePlayersData = {}




Citizen.CreateThread(function()
    if Config.RegisterKeyMapping then
        RegisterKeyMapping('adminmenu', 'adminmenu', 'keyboard', Config.KeyMapping)
        RegisterCommand('adminmenu', function()
            local playerData = TriggerCallback('codem-admin:server:getPlayerData')
            if playerData then
                SetNuiFocus(true, false)
                SetNuiFocusKeepInput(true)
                menuOpen = true
                NuiMessage('openMenu', {
                    onlinePlayersData = onlinePlayersData,
                    playerData = playerData
                })
            end
        end)
    else
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(1)
                if IsControlJustPressed(0, Config.NotRegisterKeyMapping) then
                    local playerData = TriggerCallback('codem-admin:server:getPlayerData')
                    if playerData then
                        SetNuiFocus(true, false)
                        SetNuiFocusKeepInput(true)
                        menuOpen = true
                        NuiMessage('openMenu', {
                            onlinePlayersData = onlinePlayersData,
                            playerData = playerData
                        })
                    end
                end
            end
        end)
    end
end)

RegisterNetEvent('codem-adminmenu:client:loadData', function(onlineData)
    onlinePlayersData = onlineData
    NuiMessage('loadData', onlinePlayersData)
end)

RegisterNetEvent('codem-adminmenu:client:updateOnlinePlayersData', function(identifier, onlinedata)
    if onlinePlayersData[identifier] then
        onlinePlayersData[identifier] = nil
    end
    onlinePlayersData[identifier] = onlinedata
    NuiMessage('loadData', onlinePlayersData)
end)

RegisterNetEvent('codem-adminmenu:updatePlayerPermission', function(identifier, permissiondata)
    if onlinePlayersData[identifier] then
        onlinePlayersData[identifier].permissiondata = permissiondata
        local data = {
            identifier = identifier,
            permissiondata = permissiondata
        }
        NuiMessage('UPDATE_PLAYER_PERMISSION', data)
    end
end)


RegisterNUICallback('adminOptions', function(data)
    if data then
        TriggerServerEvent('codem-admin:server:adminOptionRequest', data)
    end
end)

RegisterNUICallback('adminPlayerOptions', function(data)
    if data then
        TriggerServerEvent('codem-adminmenu:server:adminPlayerOption', data)
    end
end)

RegisterNUICallback('adminOptionsPermission', function(data)
    if data then
        TriggerServerEvent('codem-adminmenu:server:PermissionData', data)
    end
end)

RegisterNUICallback('searchBan', function(text, cb)
    local result = TriggerCallback('codem-admin:server:searchBan', text)
    cb(result)
end)

RegisterNUICallback('offlineBanData', function(data)
    if data then
        TriggerServerEvent('codem-adminmenu:server:offlineBanPlayer', data)
    end
end)

RegisterNUICallback('bannedPlayers', function(data, cb)
    local result = TriggerCallback('codem-admin:server:getBannedPlayers')
    cb(result)
end)

RegisterNUICallback('playerInfo', function(data, cb)
    local playerInfoData = TriggerCallback('codem-admin:server:getPlayerInfo', data)
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        if playerInfoData and playerInfoData.playerVehicles then
            for key, vehicleData in pairs(playerInfoData.playerVehicles) do
                if type(vehicleData) == "table" then
                    local vehicleModel = string.lower(vehicleData.vehicle)
                    vehicleData.label = GetDisplayNameFromVehicleModel(GetHashKey(vehicleModel)) or "CARNOTFOUND"
                end
            end
        end
    else
        if playerInfoData and playerInfoData.playerVehicles then
            for key, vehicleData in pairs(playerInfoData.playerVehicles) do
                if type(vehicleData) == "table" then
                    local vehicleModel = string.lower(vehicleData.vehicle)
                    vehicleData.label = GetDisplayNameFromVehicleModel(GetHashKey(vehicleModel)) or "CARNOTFOUND"
                end
            end
        end
    end
    cb(playerInfoData)
end)

RegisterNUICallback("OnInputFocus", function()
    SetNuiFocusKeepInput(false)
end)

RegisterNUICallback("OnInputFocusRemove", function()
    SetNuiFocusKeepInput(true)
end)


function TriggerCallback(name, data)
    local incomingData = false
    local status = 'UNKOWN'
    local counter = 0
    while Core == nil do
        Wait(0)
    end
    if Config.Framework == 'esx' then
        Core.TriggerServerCallback(name, function(payload)
            status = 'SUCCESS'
            incomingData = payload
        end, data)
    else
        Core.Functions.TriggerCallback(name, function(payload)
            status = 'SUCCESS'
            incomingData = payload
        end, data)
    end
    CreateThread(function()
        while incomingData == 'UNKOWN' do
            Wait(1000)
            if counter == 4 then
                status = 'FAILED'
                incomingData = false
                break
            end
            counter = counter + 1
        end
    end)

    while status == 'UNKOWN' do
        Wait(0)
    end
    return incomingData
end
