createdCharCham, createdCharChamPed, camOffset, camHeight, camOffsetX, rotatingPed = nil, nil, 0, 0, 0, false
function charCam(state)
    if state then
        if DoesCamExist(createdCharCham) then return end
        RenderScriptCams(false, true, 500, 1, 0)
        DestroyCam(createdCharCham, false)
        if not DoesCamExist(createdCharCham) then
            -- Create Ped
            local playerCoords = GetEntityCoords(PlayerPedId())
            RequestModel(GetHashKey("mp_m_freemode_01"))
            while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) do Citizen.Wait(0) end
            createdCharChamPed = CreatePed(2, GetHashKey("mp_m_freemode_01"), playerCoords.x, playerCoords.y, playerCoords.z - 1, GetEntityHeading(PlayerPedId()), false, true)
            FreezeEntityPosition(createdCharChamPed, true)
            SetEntityVisible(createdCharChamPed, false)
            SetEntityNoCollisionEntity(PlayerPedId(), createdCharChamPed, true)
            -- Create Cam
            local coords = GetOffsetFromEntityInWorldCoords(createdCharChamPed, 0.0, 0.55, 0.45)
            createdCharCham = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamActive(createdCharCham, true)
            RenderScriptCams(true, true, 500, true, true)
            SetCamCoord(createdCharCham, coords.x, coords.y, coords.z + 0.2)
            SetCamRot(createdCharCham, 0.0, 0.0, GetEntityHeading(createdCharChamPed) + 180)
            if Config.UseBackgroundBlur then
                SetCamUseShallowDofMode(createdCharCham, true)
                SetCamNearDof(createdCharCham, 0.4)
                SetCamFarDof(createdCharCham, 1.1)
                SetCamDofStrength(createdCharCham, 1.0)
            end
        end
        camOffsetX = -0.05
        camOffset = 0.6
        camHeight = 0.45
        if Config.UseBackgroundBlur then
            Citizen.CreateThread(function()
                while DoesCamExist(createdCharCham) do
                    SetUseHiDof()
                    Citizen.Wait(0)
                end
            end)
        end
        Citizen.CreateThread(function()
            while DoesCamExist(createdCharCham) and not rotatingPed do
                local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.05, camOffset, camHeight)
                SetCamCoord(createdCharCham, coords.x, coords.y, coords.z + 0.2)
                SetCamRot(createdCharCham, 0.0, 0.0, GetEntityHeading(PlayerPedId()) + 180)
                Citizen.Wait(0)
            end
        end)
    else
        DeletePed(createdCharChamPed)
        ClearTimecycleModifier()
        RenderScriptCams(false, true, 500, 1, 0)
        DestroyCam(createdCharCham, false)
        createdCharCham = nil
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    charCam(false)
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
		if not IsEntityAPed(victim) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
            charCam(false)
            SendNUIMessage({action = "closeOutfitMenu"})
		end
	end
end)

local viewedOutfit = false
RegisterNUICallback('callback', function(data)
    if data.action == "saveOutfit" then
        local model = GetEntityModel(PlayerPedId())
        if Config.ModelSaveType == "modelname" then
            model = GetEntityArchetypeName(PlayerPedId())
        end
        TriggerServerEvent('0r-outfitsaver:saveOutfit:server', data.outfitName, model, data.tags)
    elseif data.action == "deleteOutfit" then
        TriggerServerEvent('0r-outfitsaver:deleteOutfit:server', data.outfitName, data.outfitId)
    elseif data.action == "viewOutfit" then
        TriggerCallback('0r-outfitsaver:getSavedOutfitSkinById:server', function(skin)
            if next(skin) then
                viewedOutfit = true
                SetClothing(skin.skin)
            end
        end, data.id)
    elseif data.action == "wearOutfit" then
        TriggerCallback('0r-outfitsaver:getSavedOutfitSkinById:server', function(skin)
            if next(skin) then
                SetClothing(skin.skin)
                TriggerServerEvent('0r-outfitsaver:saveSkin:server', skin.model, skin.skin)
            end
        end, data.id)
    elseif data.action == "editOutfit" then
        TriggerServerEvent('0r-outfitsaver:editOutfit:server', data.id, data.outfitName, data.tags)
    elseif data.action == "nuiFocus" then
        charCam(false)
        SetNuiFocus(false, false)
        if viewedOutfit then
            viewedOutfit = false
            TriggerCallback('0r-outfitsaver:getPlayerSkin:server', function(skin)
                if next(skin) then
                    SetClothing(skin.skin)
                end
            end)
        end
    elseif data.action == "updateRotation" then
        local rotationDelta = data.rotationDelta
        local currentHeading = GetEntityHeading(PlayerPedId())
        local newHeading = currentHeading + (rotationDelta * 0.3) 
        SetEntityHeading(PlayerPedId(), newHeading)
        rotatingPed = true
        Citizen.Wait(500)
        rotatingPed = false
    elseif data.action == "updateZoom" then
        if data.type == "zoomIn" then
            if camOffset == 0.6 then
                camOffset = 0.9
                camHeight = 0.25
            elseif camOffset == 0.9 then
                camOffset = 1.2
                camHeight = 0.0
            elseif camOffset == 1.2 then
                camOffset = 1.5
                camHeight = -0.25
            end
        elseif data.type == "zoomOut" then
            if camOffset == 1.5 then
                camOffset = 1.2
                camHeight = 0.0
            elseif camOffset == 1.2 then
                camOffset = 0.9
                camHeight = 0.25
            elseif camOffset == 0.9 then
                camOffset = 0.6
                camHeight = 0.45
            end
        end
        if camOffset == 1.5 then
            SetCamNearDof(createdCharCham, 0.9)
            SetCamFarDof(createdCharCham, 1.5)
        else
            SetCamNearDof(createdCharCham, 0.4)
            SetCamFarDof(createdCharCham, 1.1)
        end
        SetCamDofStrength(createdCharCham, 1.0)
        local coords = GetOffsetFromEntityInWorldCoords(createdCharChamPed, 0.05, camOffset, camHeight)
        SetCamCoord(createdCharCham, coords.x, coords.y, coords.z + 0.2)
    end
end)

RegisterNetEvent('0r-outfitsaver:reloadOutfits:client', function(outfits)
    local myOutfits = {}
    TriggerCallback('0r-outfitsaver:getSavedOutfits:server', function(outfits)
        for k, v in pairs(outfits) do
            table.insert(myOutfits, {
                id = v.id,
                outfitname = v.outfitname,
                tags = json.decode(v.tags)
            })
        end
    end)
    while not next(myOutfits) do Citizen.Wait(500) end
    local translations = {}
    for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
        if k:sub(0, ('general.'):len()) then
            translations[k:sub(('general.'):len() + 1)] = Lang:t(k)
        end
    end
    SendNUIMessage({action = "openOutfitMenu", outfits = myOutfits, translations = translations})
end)

if Config.Interaction.TextUI.Enable then
    closestClothingArea = {}
    local showTextUI = false
    Citizen.CreateThread(function()
        while true do
            local sleep = 100
            playerPed = PlayerPedId()
            playerCoords = GetEntityCoords(playerPed)
            if not closestClothingArea.id then
                for k, v in pairs(Config.OutfitChangers) do
                    --if v.Interaction.DrawText.Enable then
                        local dist = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                        if dist <= Config.Interaction.TextUI.Distance then
                            function currentShow()
                                Config.Interaction.TextUI.Show(Lang:t("general.interaction"))
                                showTextUI = true
                            end
                            function currentHide()
                                Config.Interaction.TextUI.Hide()
                            end
                            closestClothingArea = {id = k, distance = dist, maxDist = Config.Interaction.TextUI.Distance, data = {coords = vector3(v.coords.x, v.coords.y, v.coords.z)}}
                        end
                    --end
                end
            end
            if closestClothingArea.id then
                while true do
                    playerPed = PlayerPedId()
                    playerCoords = GetEntityCoords(playerPed)
                    closestClothingArea.distance = #(vector3(closestClothingArea.data.coords.x, closestClothingArea.data.coords.y, closestClothingArea.data.coords.z) - playerCoords)
                    if closestClothingArea.distance < closestClothingArea.maxDist then
                        if IsControlJustReleased(0, 38) then
                            openMenu()
                        end
                        if not showTextUI then
                            currentShow()
                        end
                    else
                        currentHide()
                        break
                    end
                    Citizen.Wait(0)
                end
                showTextUI = false
                closestClothingArea = {}
                sleep = 0
            end
            Citizen.Wait(sleep)
        end
    end)
    -- 
    closestClothingArea2 = {}
    local showTextUI2 = false
    Citizen.CreateThread(function()
        while true do
            local sleep = 100
            playerPed = PlayerPedId()
            playerCoords = GetEntityCoords(playerPed)
            if not closestClothingArea2.id then
                for k, v in pairs(Config.ClothingRooms) do
                    --if v.Interaction.DrawText.Enable then
                        local dist = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                        if dist <= Config.Interaction.TextUI.Distance then
                            local myJob = GetPlayerJob()
                            if myJob == v.requiredJob then
                                function currentShow()
                                    Config.Interaction.TextUI.Show(Lang:t("general.interaction"))
                                    showTextUI2 = true
                                end
                                function currentHide()
                                    Config.Interaction.TextUI.Hide()
                                end
                                closestClothingArea2 = {id = k, distance = dist, maxDist = Config.Interaction.TextUI.Distance, data = {coords = vector3(v.coords.x, v.coords.y, v.coords.z)}}
                            end
                        end
                    --end
                end
            end
            if closestClothingArea2.id then
                while true do
                    playerPed = PlayerPedId()
                    playerCoords = GetEntityCoords(playerPed)
                    closestClothingArea2.distance = #(vector3(closestClothingArea2.data.coords.x, closestClothingArea2.data.coords.y, closestClothingArea2.data.coords.z) - playerCoords)
                    if closestClothingArea2.distance < closestClothingArea2.maxDist then
                        if IsControlJustReleased(0, 38) then
                            openMenu()
                        end
                        if not showTextUI2 then
                            currentShow()
                        end
                    else
                        currentHide()
                        break
                    end
                    Citizen.Wait(0)
                end
                showTextUI2 = false
                closestClothingArea2 = {}
                sleep = 0
            end
            Citizen.Wait(sleep)
        end
    end)
else
    for k, v in pairs(Config.OutfitChangers) do
        if GetResourceState('qb-target') == 'started' or GetResourceState('pa-target') == 'started' then
            exports['qb-target']:AddBoxZone(k .. "_clothing_outfit_boxzone", vector3(v.coords.x, v.coords.y, v.coords.z), Config.Interaction.Target.Zone, Config.Interaction.Target.Zone, {
                name = k .. "_clothing_outfit_boxzone",
                heading = 180.0,
                debugPoly = false,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
            }, {
                options = {
                    {
                        num = 1,
                        icon = Config.Interaction.Target.Icon,
                        label = Lang:t("general.interaction"),
                        action = function()
                            openMenu()
                        end
                    }
                },
                distance = Config.Interaction.Target.Distance
            })
        elseif GetResourceState('ox_target') == 'started' then
            exports.ox_target:addBoxZone({
                coords = vector3(v.coords.x, v.coords.y, v.coords.z),
                size = vec3(Config.Interaction.Target.Zone, Config.Interaction.Target.Zone, Config.Interaction.Target.Zone),
                rotation = 180.0,
                options = {
                    {
                        num = 1,
                        icon = Config.Interaction.Target.Icon,
                        label = Lang:t("general.interaction"),
                        distance = Config.Interaction.Target.Distance,
                        onSelect = function()
                            openMenu()
                        end
                    }
                },
            })
        end
    end
    for k, v in pairs(Config.ClothingRooms) do
        if GetResourceState('qb-target') == 'started' or GetResourceState('pa-target') == 'started' then
            local options = {
                num = 1,
                icon = Config.Interaction.Target.Icon,
                label = Lang:t("general.interaction"),
                job = v.requiredJob,
                action = function()
                    openMenu()
                end
            }
            if v.isGang then
                options = {
                    num = 1,
                    icon = Config.Interaction.Target.Icon,
                    label = Lang:t("general.interaction") + " 1",
                    gang = v.requiredJob,
                    action = function()
                        openMenu()
                    end
                }
            end
            exports['qb-target']:AddBoxZone(k .. "_clothing_outfit2_boxzone", vector3(v.coords.x, v.coords.y, v.coords.z), Config.Interaction.Target.Zone, Config.Interaction.Target.Zone, {
                name = k .. "_clothing_outfit2_boxzone",
                heading = 180.0,
                debugPoly = false,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
            }, {
                options = {options},
                distance = Config.Interaction.Target.Distance
            })
        elseif GetResourceState('ox_target') == 'started' then
            exports.ox_target:addBoxZone({
                coords = vector3(v.coords.x, v.coords.y, v.coords.z),
                size = vec3(Config.Interaction.Target.Zone, Config.Interaction.Target.Zone, Config.Interaction.Target.Zone),
                rotation = 180.0,
                options = {
                    {
                        num = 1,
                        icon = Config.Interaction.Target.Icon,
                        label = Lang:t("general.interaction"),
                        distance = Config.Interaction.Target.Distance,
                        onSelect = function()
                            openMenu()
                        end,
                        canInteract = function()
                            return GetPlayerJob() == v.requiredJob
                        end,
                        groups = v.requiredJob
                    }
                },
            })
        end
    end
end

function openMenu()
    SetNuiFocus(true, true)
    charCam(true)
    local myOutfits = {}
    TriggerCallback('0r-outfitsaver:getSavedOutfits:server', function(outfits)
        for k, v in pairs(outfits) do
            table.insert(myOutfits, {
                id = v.id,
                outfitname = v.outfitname,
                tags = json.decode(v.tags)
            })
        end
    end)
    while not next(myOutfits) do Citizen.Wait(500) end
    local translations = {}
    for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
        if k:sub(0, ('general.'):len()) then
            translations[k:sub(('general.'):len() + 1)] = Lang:t(k)
        end
    end
    SendNUIMessage({action = "openOutfitMenu", outfits = myOutfits, translations = translations})
end
exports('openMenu', openMenu)

RegisterNetEvent('0r-outfitsaver:openMenu:client', openMenu)