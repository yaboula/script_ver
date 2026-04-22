RegisterNetEvent('codem-adminmenu:notfication', function(message, value)
    local data = {
        message = message,
        value = value
    }
    NuiMessage('NOTIFICATION', data)
end)


RegisterNetEvent('codem-adminmenu:checkedData', function(data)
    NuiMessage('setAdminCheckedData', {
        name = data.name,
        value = data.value
    })
end)

local invisible = false
local playerIdActive = false
RegisterNetEvent('codem-adminmenu:setInvinsible', function()
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'invisible')
    if not isAdmin then
        return
    end
    if invisible then
        invisible = false
        SetEntityVisible(PlayerPedId(), 1)
        NuiMessage('setAdminCheckedData', {
            name = 'invisible',
            value = invisible
        })
        TriggerEvent('codem-adminmenu:notfication', 'You are now visible')
    else
        invisible = true
        NuiMessage('setAdminCheckedData', {
            name = 'invisible',
            value = invisible
        })
        TriggerEvent('codem-adminmenu:notfication', 'You are now invisible.')
        SetEntityVisible(PlayerPedId(), 0)
    end
end)
RegisterNetEvent('codem-adminmenu:clearArea', function(coord)
    ClearAreaOfEverything(coord.x, coord.y, coord.z, 100.0, 0, 0, 0, 0)
end)

RegisterNetEvent('codem-adminmenu:showPlayerName', function()
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'playername')
    if not isAdmin then
        return
    end
    playerIdActive = not playerIdActive
    NuiMessage('setAdminCheckedData', {
        name = 'playername',
        value = playerIdActive
    })
    if not playerIdActive then
        cleanUpGamerTags()
    end
end)



RegisterNetEvent("codem-adminmenu:copyXYZ", function()
    local coords = GetEntityCoords(PlayerPedId())
    local vector = '{x = ' .. coords.x .. ', y =  ' .. coords.y .. ', z = ' .. coords.z .. '}'
    NuiMessage('copy', vector)
end)

RegisterNetEvent('codem-adminmenu:copyVector', function()
    local coords = GetEntityCoords(PlayerPedId())
    local vector = 'vector3(' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z .. ')'
    NuiMessage('copy', vector)
end)

RegisterNetEvent('codem-adminmenu:copyVector4', function()
    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local vector = 'vector4(' .. coords.x .. ', ' .. coords.y .. ', ' .. coords.z .. ', ' .. heading .. ')'
    NuiMessage('copy', vector)
end)

RegisterNetEvent('codem-adminmenu:copyHeading', function()
    local heading = GetEntityHeading(PlayerPedId())
    NuiMessage('copy', heading)
end)

local showCoords = false
RegisterNetEvent('codem-adminmenu:toggleCoords', function()
    showCoords = not showCoords
    CreateThread(function()
        while showCoords do
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            NuiMessage('setCoords', {
                coords = coords,
                heading = heading
            })
            Wait(100)
        end
    end)
    NuiMessage('showCoords', showCoords)
    NuiMessage('setAdminCheckedData', {
        name = 'showcoords',
        value = showCoords
    })
end)

RegisterNetEvent('codem-adminmenu:devLaser', function()
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'devlaser')
    if not isAdmin then
        return
    end
    ToggleEntityFreeView()
    NuiMessage('setAdminCheckedData', {
        name = 'devlaser',
        value = EntityFreeAim
    })
end)

local Godmode = false
RegisterNetEvent('codem-adminmenu:setGodmode', function()
    Godmode = not Godmode
    NuiMessage('setAdminCheckedData', {
        name = 'godmode',
        value = Godmode
    })
    local Player = PlayerId()
    if Godmode then
        SetPlayerInvincible(Player, true)
    else
        SetPlayerInvincible(Player, false)
    end
end)

RegisterNetEvent('codem-adminmenu:healPlayer', function()
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
end)

RegisterNetEvent('codem-adminmenu:repairVehicle', function()
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'repairvehicle')
    if not isAdmin then
        return
    end
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        SetVehicleFixed(vehicle)
        TriggerEvent('codem-adminmenu:notfication', 'Vehicle Fixed.', 'notification')
    end
end)

RegisterNetEvent('codem-adminmenu:gasTank', function()
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'gastank')
    if not isAdmin then
        return
    end
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= 0 then
        Config.SetVehicleFuel(vehicle, 100)
        TriggerEvent('codem-adminmenu:notfication', 'Vehicle Fuel 100.0', 'notification')
    end
end)

RegisterNetEvent('codem-adminmenu:showAnnouncement', function(text)
    TriggerEvent('codem-adminmenu:notfication', text, 'announcement')
end)

RegisterNetEvent('codem-adminmenu:setArmor', function()
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'armor')
    if not isAdmin then
        return
    end
    SetPedArmour(PlayerPedId(), 100)
    TriggerEvent('codem-adminmenu:notfication', 'You have been given armor', 'notification')
end)


RegisterNetEvent('codem-adminmenu:takePicture', function(webhook)
    if GetResourceState('screenshot-basic') ~= 'missing' then
        exports['screenshot-basic']:requestScreenshotUpload(tostring(webhook), 'files[]', function(data)
            local resp = json.decode(data)
            cb(resp.attachments[1].proxy_url)
        end)
    else
        TriggerEvent('codem-adminmenu:notfication', 'Screenshot-basic scripti bulunamadi', 'notification')
    end
end)

RegisterNetEvent('codem-adminmenu:spawnCar', function(modelname)
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'givevehicle')
    if not isAdmin then
        return
    end
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        local hash = GetHashKey(modelname)
        if not IsModelValid(hash) then
            return
        end
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        Core.Game.SpawnVehicle(hash, coords, heading, function(callback_vehicle)
            TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
            Config.GiveVehicleKey(GetVehicleNumberPlateText(callback_vehicle),
                GetHashKey(modelname))
        end, true)
    else
        if not IsModelValid(GetHashKey(modelname)) then
            return
        end
        local coords = GetEntityCoords(PlayerPedId())
        local heading = GetEntityHeading(PlayerPedId())
        local vehiclename = GetHashKey(modelname)
        Core.Functions.SpawnVehicle(vehiclename, function(callback_vehicle)
            TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
            Config.GiveVehicleKey(GetVehicleNumberPlateText(callback_vehicle),
                GetHashKey(modelname))
        end, vector4(coords.x, coords.y, coords.z, heading), true)
    end
end)
local isSpectating = false
RegisterNetEvent('codem-adminmenu:spectate', function(targetPed)
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'spectate')
    if not isAdmin then
        return
    end
    local myPed = PlayerPedId()
    local targetplayer = GetPlayerFromServerId(targetPed)
    local target = GetPlayerPed(targetplayer)
    if not isSpectating then
        isSpectating = true
        SetEntityVisible(myPed, false)
        SetEntityCollision(myPed, false, false)
        SetEntityInvincible(myPed, true)
        NetworkSetEntityInvisibleToNetwork(myPed, true)
        lastSpectateCoord = GetEntityCoords(myPed)
        NetworkSetInSpectatorMode(true, target)
    else
        isSpectating = false
        NetworkSetInSpectatorMode(false, target)
        NetworkSetEntityInvisibleToNetwork(myPed, false)
        SetEntityCollision(myPed, true, true)
        SetEntityCoords(myPed, lastSpectateCoord)
        SetEntityVisible(myPed, true)
        SetEntityInvincible(myPed, false)
        lastSpectateCoord = nil
    end
end)

RegisterNetEvent('codem-adminmenu:openPlayerInventory', function(target)
    local isAdmin = TriggerCallback('codem-admin:serverIsAdmin', 'openinventory')
    if not isAdmin then
        return
    end
    if Config.Inventory == 'qb_inventory' or Config.Inventory == "qs_inventory" or Config.Inventory == "ox_inventory" then
        TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', target)
    end
end)

RegisterNetEvent('codem-adminmenu:clearVehicles', function()
    for vehicle in EnumerateVehicles() do
        if (not IsPedAPlayer(GetPedInVehicleSeat(vehicle, -1))) then
            SetVehicleHasBeenOwnedByPlayer(vehicle, false)
            SetEntityAsMissionEntity(vehicle, false, false)
            DeleteVehicle(vehicle)
            if (DoesEntityExist(vehicle)) then
                DeleteVehicle(vehicle)
            end
        end
    end
end)



gamerTagCompsEnum = {
    GamerName = 0,
    CrewTag = 1,
    HealthArmour = 2,
    BigText = 3,
    AudioIcon = 4,
    UsingMenu = 5,
    PassiveMode = 6,
    WantedStars = 7,
    Driver = 8,
    CoDriver = 9,
    Tagged = 12,
    GamerNameNearby = 13,
    Arrow = 14,
    Packages = 15,
    InvIfPedIsFollowing = 16,
    RankText = 17,
    Typing = 18
}
playerGamerTags = {}

AddEventHandler("onResourceStop", function(name)
    if name == GetCurrentResourceName() then
        cleanUpGamerTags()
    end
end)

function cleanUpGamerTags()
    for _, v in pairs(playerGamerTags) do
        if IsMpGamerTagActive(v.gamerTag) then
            RemoveMpGamerTag(v.gamerTag)
        end
    end
    playerGamerTags = {}
end

local gamerTagCompsEnum = {
    GamerName = 0,
    CrewTag = 1,
    HealthArmour = 2,
    BigText = 3,
    AudioIcon = 4,
    UsingMenu = 5,
    PassiveMode = 6,
    WantedStars = 7,
    Driver = 8,
    CoDriver = 9,
    Tagged = 12,
    GamerNameNearby = 13,
    Arrow = 14,
    Packages = 15,
    InvIfPedIsFollowing = 16,
    RankText = 17,
    Typing = 18
}

local function showGamerTags()
    local curCoords = GetEntityCoords(PlayerPedId())
    local allActivePlayers = GetActivePlayers()
    for _, i in ipairs(allActivePlayers) do
        local targetPed = GetPlayerPed(i)
        local playerStr = "[" .. GetPlayerServerId(i) .. "]" .. " " .. GetPlayerName(i)
        if not playerGamerTags[i] or not IsMpGamerTagActive(playerGamerTags[i].gamerTag) then
            playerGamerTags[i] = {
                gamerTag = CreateFakeMpGamerTag(targetPed, playerStr, false, false, 0),
                ped = targetPed
            }
        end
        local targetTag = playerGamerTags[i].gamerTag
        local targetPedCoords = GetEntityCoords(targetPed)
        if #(targetPedCoords - curCoords) <= 300 then
            SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.GamerName, 1)
            SetMpGamerTagAlpha(targetTag, gamerTagCompsEnum.AudioIcon, 255)
            SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.AudioIcon, NetworkIsPlayerTalking(i))
            SetMpGamerTagHealthBarColor(targetTag, 129)
            SetMpGamerTagAlpha(targetTag, gamerTagCompsEnum.HealthArmour, 255)
            SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.HealthArmour, 1)
        else
            SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.GamerName, 0)
            SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.HealthArmour, 0)
            SetMpGamerTagVisibility(targetTag, gamerTagCompsEnum.AudioIcon, 0)
        end
    end
end
CreateThread(function()
    local sleep = 150
    while true do
        if playerIdActive then
            showGamerTags()
            sleep = 50
        else
            sleep = 500
        end
        Wait(sleep)
    end
end)


RegisterNetEvent('codem-adminmenu:openClothingMenu', function()
    if Config.ClothingMenu == 'fivem-appearance' then
        TriggerEvent("fivem-appearance:client:openClothingShopMenu", false)
    end
    if Config.ClothingMenu == 'illenium-appearance' then
        TriggerEvent("illenium-appearance:client:openClothingShop", false)
    end
    if Config.ClothingMenu == 'codem-appearance' then
        TriggerEvent("codem-appereance:OpenClothing")
        --[[
            // Add this code in codem-appereance client/clothing.lua

           RegisterNetEvent("codem-appereance:OpenClothing")
            AddEventHandler("codem-appereance:OpenClothing", function()
                OpenMenu("binco")
            end)
        --]]
    end
    if Config.ClothingMenu == 'esx_skin' then
        TriggerEvent("esx_skin:openMenu")
    end
    if Config.ClothingMenu == 'qb-clothing' then
        TriggerEvent("qb-clothing:client:openMenu")
    end
end)

RegisterNetEvent('codem-adminmenu:adminClothes', function(value)
    print('worked', value)
    if value then
        print('worked2')
        TriggerEvent('skinchanger:getSkin', function(skin) TriggerEvent("esx_skin:setLastSkin", skin) end)

        for _, clothes in ipairs(Config.AdminClothes) do
            for part, id in pairs(clothes) do
                if part ~= "texture" then
                    ChangeClothes(part, id, clothes.texture)
                end
            end
        end
    else
        RefreshSkin()
    end
end)



function ChangeClothes(key, value, texture)
    local playerPed = PlayerPedId()
    value = tonumber(value)
    texture = tonumber(texture)

    if key == 'jacket' then
        SetPedComponentVariation(playerPed, 11, value, texture, 2)
    end
    if key == 'shirt' then
        SetPedComponentVariation(playerPed, 8, value, texture, 2)
    end
    if key == 'arms' then
        SetPedComponentVariation(playerPed, 3, value, texture, 2)
    end
    if key == 'legs' then
        SetPedComponentVariation(playerPed, 4, value, texture, 2)
    end
    if key == 'shoes' then
        SetPedComponentVariation(playerPed, 6, value, texture, 2)
    end
    if key == 'mask' then
        SetPedComponentVariation(playerPed, 1, value, texture, 2)
    end
    if key == 'chain' then
        SetPedComponentVariation(playerPed, 7, value, texture, 2)
    end
    if key == 'decals' then
        SetPedComponentVariation(playerPed, 10, value, texture, 2)
    end
    if key == 'helmet' then
        SetPedPropIndex(playerPed, 0, value, texture, 2)
    end
    if key == 'glasses' then
        SetPedPropIndex(playerPed, 1, value, texture, 2)
    end
    if key == 'watches' then
        SetPedPropIndex(playerPed, 6, value, texture, 2)
    end
    if key == 'bracelets' then
        SetPedPropIndex(playerPed, 7, value, texture, 2)
    end
end

function RefreshSkin()
    if Config.ClothingMenu == 'fivem-appearance' then
        TriggerEvent("fivem-appearance:client:reloadSkin")
    end
    if Config.ClothingMenu == 'illenium-appearance' then
        TriggerEvent("illenium-appearance:client:reloadSkin")
    end
    if Config.ClothingMenu == 'codem-appearance' then
        TriggerEvent("codem-appearance:reloadSkin")
    end
    if Config.ClothingMenu == 'esx_skin' then
        TriggerEvent("esx_skin:getLastSkin", function(lastSkin)
            TriggerEvent('skinchanger:loadSkin', lastSkin)
        end)
    end
    if Config.ClothingMenu == 'qb-clothing' then
        TriggerEvent("qb-clothing:reloadSkin")
        --[[
            // Add this code in qb-clothing client/main.lua

            RegisterNetEvent("qb-clothing:reloadSkin")
            AddEventHandler("qb-clothing:reloadSkin", function()
                local playerPed = PlayerPedId()
                local health = GetEntityHealth(playerPed)
                reloadSkin(health)
            end)
        --]]
    end
end
