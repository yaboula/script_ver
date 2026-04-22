local QBCore = exports['qb-core']:GetCoreObject()

local showMenu = false
local DynamicMenuItems = {}

-- Keybind Lookup table
local keybindControls = {
	["`"] = 243, ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18, ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182, ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81, ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178, ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173, ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

function RequestWalking(set)
    RequestAnimSet(set)
    while not HasAnimSetLoaded(set) do
        -- Wait(1)
    end
end
RegisterNetEvent("AnimSet:Brave", function()
    local ped = PlayerPedId()
    RequestWalking("move_m@brave")
    SetPedMovementClipset(ped, "move_m@brave", 0.2)
end)
RegisterNetEvent("AnimSet:Hurry", function()
    local animSet = "move_m@hurry@a"

    RequestAnimSet(animSet)

    local timeout = GetGameTimer() + 5000 -- wait max 5 seconds
    while not HasAnimSetLoaded(animSet) do
        if GetGameTimer() > timeout then
            print("[AnimSet:Hurry] Failed to load anim set: " .. animSet)
            return
        end
        Wait(0)
    end

    SetPedMovementClipset(PlayerPedId(), animSet, 0.2)
end)

RegisterNetEvent("AnimSet:Hurry", function()
    local animSet = "move_m@hurry@a"

    RequestAnimSet(animSet)

    local timeout = GetGameTimer() + 5000 -- wait max 5 seconds
    while not HasAnimSetLoaded(animSet) do
        if GetGameTimer() > timeout then
            print("[AnimSet:Hurry] Failed to load anim set: " .. animSet)
            return
        end
        Wait(0)
    end

    SetPedMovementClipset(PlayerPedId(), animSet, 0.2)
end)


RegisterNetEvent("AnimSet:Business", function()
    RequestWalking("move_m@business@a")
    SetPedMovementClipset(PlayerPedId(), "move_m@business@a", 0.2)
end)

RegisterNetEvent("AnimSet:Tipsy", function()
    RequestWalking("move_m@drunk@slightlydrunk")
    SetPedMovementClipset(PlayerPedId(), "move_m@drunk@slightlydrunk", 0.2)
end)

RegisterNetEvent("AnimSet:Injured", function()
    RequestWalking("move_m@injured")
    SetPedMovementClipset(PlayerPedId(), "move_m@injured", 0.2)
end)

RegisterNetEvent("AnimSet:ToughGuy", function()
    RequestWalking("move_m@tough_guy@")
    SetPedMovementClipset(PlayerPedId(), "move_m@tough_guy@", 0.2)
end)

RegisterNetEvent("AnimSet:Sassy", function()
    RequestWalking("move_m@sassy")
    SetPedMovementClipset(PlayerPedId(), "move_m@sassy", 0.2)
end)

RegisterNetEvent("AnimSet:Sad", function()
    RequestWalking("move_m@sad@a")
    SetPedMovementClipset(PlayerPedId(), "move_m@sad@a", 0.2)
end)

RegisterNetEvent("AnimSet:Posh", function()
    RequestWalking("move_m@posh@")
    SetPedMovementClipset(PlayerPedId(), "move_m@posh@", 0.2)
end)

RegisterNetEvent("AnimSet:Alien", function()
    RequestWalking("move_m@alien")
    SetPedMovementClipset(PlayerPedId(), "move_m@alien", 0.2)
end)

RegisterNetEvent("AnimSet:Hobo", function()
    RequestWalking("move_m@hobo@a")
    SetPedMovementClipset(PlayerPedId(), "move_m@hobo@a", 0.2)
end)

RegisterNetEvent("AnimSet:Money", function()
    RequestWalking("move_m@money")
    SetPedMovementClipset(PlayerPedId(), "move_m@money", 0.2)
end)

RegisterNetEvent("AnimSet:Swagger", function()
    RequestWalking("move_m@swagger")
    SetPedMovementClipset(PlayerPedId(), "move_m@swagger", 0.2)
end)

RegisterNetEvent("AnimSet:Shady", function()
    RequestWalking("move_m@shadyped@a")
    SetPedMovementClipset(PlayerPedId(), "move_m@shadyped@a", 0.2)
end)

RegisterNetEvent("AnimSet:ManEater", function()
    RequestWalking("move_f@maneater")
    SetPedMovementClipset(PlayerPedId(), "move_f@maneater", 0.2)
end)

RegisterNetEvent("AnimSet:ChiChi", function()
    RequestWalking("move_f@chichi")
    SetPedMovementClipset(PlayerPedId(), "move_f@chichi", 0.2)
end)

RegisterNetEvent("AnimSet:default", function()
    ResetPedMovementClipset(PlayerPedId(), 0.2)
end)

RegisterNetEvent("expressions", function(expression)
    local ped = PlayerPedId()
    if not expression then return end

    if expression == "default" then
        ClearFacialIdleAnimOverride(ped)
    else
        ClearFacialIdleAnimOverride(ped)
        Wait(150)
        SetFacialIdleAnimOverride(ped, expression, 0)
    end
end)


local MAX_MENU_ITEMS = 7

--  MenuItemId2 = exports['qb-radialmenu']:AddOption({
--         id = 'open_garage_menu',
--         title = 'Open Garage',
--         icon = 'warehouse',
--         type = 'client',
--         event = 'qb-garages:client:OpenMenu',
--         shouldClose = true
--     }, MenuItemId2)

local function AddOption(data, id)
    local menuID = #DynamicMenuItems + 1
    local newItem = {}

    newItem.id = data.id
    newItem.title = data.title
    newItem.icon = '#' .. data.icon
    newItem.functionName = data.event
    newItem.functionParameters = data.parameters or nil  -- <-- 🔥 THIS IS MISSING
    newItem.eventType = data.type

    DynamicMenuItems[#DynamicMenuItems+1] = newItem
    return menuID
end


local function RemoveOption(id)
    DynamicMenuItems[id] = nil
end

exports('AddOption', AddOption)
exports('RemoveOption', RemoveOption)

-- Main thread
Citizen.CreateThread(function()
    local keyBind = "F1"
    local keyBind2 = "-"
    while true do
        Citizen.Wait(0)
        SetBigmapActive(false, false)
        if IsControlPressed(1, keybindControls[keyBind]) or IsControlPressed(1, keybindControls[keyBind2]) and GetLastInputMethod(2) and showMenu then
            showMenu = false
            SetNuiFocus(false, false)
        end
        if IsControlPressed(1, keybindControls[keyBind]) or IsControlPressed(1, keybindControls[keyBind2]) and GetLastInputMethod(2) then
            showMenu = true
            local enabledMenus = {}
            for _, menuConfig in ipairs(rootMenuConfig) do
                if menuConfig:enableMenu() then
                    local dataElements = {}
                    local hasSubMenus = false
                    if menuConfig.subMenus ~= nil and #menuConfig.subMenus > 0 then
                        hasSubMenus = true
                        local previousMenu = dataElements
                        local currentElement = {}
                        for i = 1, #menuConfig.subMenus do
                            -- if newSubMenus[menuConfig.subMenus[i]] ~= nil and newSubMenus[menuConfig.subMenus[i]].enableMenu ~= nil and not newSubMenus[menuConfig.subMenus[i]]:enableMenu() then
                            --     goto continue
                            -- end
local submenuId = menuConfig.subMenus[i]
local submenu = newSubMenus[submenuId]
if submenu then
    submenu.id = submenuId
    submenu.enableMenu = nil
    currentElement[#currentElement + 1] = submenu
else
    -- print("^1[RadialMenu] WARNING: submenu '" .. tostring(submenuId) .. "' not found in newSubMenus.^7")
end
                            if i % MAX_MENU_ITEMS == 0 and i < (#menuConfig.subMenus - 1) then
                                previousMenu[MAX_MENU_ITEMS + 1] = {
                                    id = "_more",
                                    title = "More",
                                    icon = "#more",
                                    items = currentElement
                                }
                                previousMenu = currentElement
                                currentElement = {}
                            end
                        end
                        if #currentElement > 0 then
                            previousMenu[MAX_MENU_ITEMS + 1] = {
                                id = "_more",
                                title = "More",
                                icon = "#more",
                                items = currentElement
                            }
                        end
                        dataElements = dataElements[MAX_MENU_ITEMS + 1].items

                    end
                    enabledMenus[#enabledMenus+1] = {
                        id = menuConfig.id,
                        title = menuConfig.displayName,
                        functionName = menuConfig.functionName,
                        icon = menuConfig.icon,
                    }
                    if hasSubMenus then
                        enabledMenus[#enabledMenus].items = dataElements
                    end
                end
            end

            if #DynamicMenuItems >= 1 then
                for k,v in pairs(DynamicMenuItems) do
                    enabledMenus[#enabledMenus+1] = {
                        id = v.id,
                        title = v.title,
                        functionName = v.functionName,
                        eventType = v.eventType,
                        icon = v.icon,
                    }
                end
            end

            SendNUIMessage({
                state = "show",
                resourceName = GetCurrentResourceName(),
                data = enabledMenus,
                menuKeyBind = keyBind,
                menuType = (IsPedInAnyVehicle(PlayerPedId(), false) and 'small' or 'default')
            })
            SetCursorLocation(0.5, 0.5)
            SetNuiFocus(true, true)

            -- Play sound
            PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)


            while showMenu == true do Citizen.Wait(100) end
            Citizen.Wait(100)
            while IsControlPressed(1, keybindControls[keyBind]) or IsControlPressed(1, keybindControls[keyBind2]) and GetLastInputMethod(2) do Citizen.Wait(100) end
        end
    end
end)
-- Callback function for closing menu
RegisterNUICallback('closemenu', function(data, cb)
    -- Clear focus and destroy UI
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })

    -- Play sound
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    -- Send ACK to callback function
    cb('ok')
end)

-- Callback function for when a slice is clicked, execute command
RegisterNUICallback('triggerAction', function(data, cb)
    -- Clear focus and destroy UI
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })
    if not data.eventType then data.eventType = "client" end

    -- Play sound
    PlaySoundFrontend(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 1)

    -- Run command
    --ExecuteCommand(data.action)
    if data.eventType == "client" then
        TriggerEvent(data.action, data.parameters)
    elseif data.eventType == "server" then
        TriggerServerEvent(data.action, data.parameters)
    elseif data.eventType == "command" then
        ExecuteCommand(data.action)
    end

    -- Send ACK to callback function
    cb('ok')
end)

RegisterNetEvent('carmenuOpen', function ()
    ExecuteCommand('carmenu')
end)

RegisterNetEvent("menu:menuexit")
AddEventHandler("menu:menuexit", function()
    showMenu = false
    SetNuiFocus(false, false)
end)

RegisterCommand("nui_false", function(source, args)
    showMenu = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        state = 'destroy'
    })
end)






RegisterNetEvent("ygx:togglegas")
AddEventHandler("ygx:togglegas", function()
   -- DeleteWaypoint()

    local currentGasBlip = 0

	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords

	for k,v in pairs(GasStations) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
            closestCoords = v
        end
    end

    SetNewWaypoint(closestCoords)

end)

RegisterNetEvent("ygx:togglebarber")
AddEventHandler("ygx:togglebarber", function()
   -- DeleteWaypoint()
	local currentGasBlip = 0
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords1

	for k,v in pairs(BarberShops) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
			closestCoords1 = v
		end
    end
    
    SetNewWaypoint(closestCoords1)
end)


RegisterNetEvent("ygx:toggletattos")
AddEventHandler("ygx:toggletattos", function()
   -- DeleteWaypoint()
	local currentGasBlip = 0
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords2

	for k,v in pairs(TattoShops) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
			closestCoords2 = v
		end
    end
    
    SetNewWaypoint(closestCoords2)
end)

RegisterNetEvent("fk:motel")
AddEventHandler("fk:motel", function()
   -- DeleteWaypoint()
	local currentGasBlip = 0
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords2

	for k,v in pairs(Motel) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
			closestCoords2 = v
		end
    end
    
    SetNewWaypoint(closestCoords2)
end)



RegisterNetEvent("ygx:togglegarage")
AddEventHandler("ygx:togglegarage", function()
   -- DeleteWaypoint()
	local currentGasBlip = 0
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords2

	for k,v in pairs(Garage) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
			closestCoords2 = v
		end
    end
    
    SetNewWaypoint(closestCoords2)
end)

RegisterNetEvent("fk:restaurant")
AddEventHandler("fk:restaurant", function()
   -- DeleteWaypoint()
	local currentGasBlip = 0
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords2

	for k,v in pairs(restaurant) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
			closestCoords2 = v
		end
    end
    
    SetNewWaypoint(closestCoords2)
end)

RegisterNetEvent("fk:banks")
AddEventHandler("fk:banks", function()
   -- DeleteWaypoint()
	local currentGasBlip = 0
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords2

	for k,v in pairs(banks) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
			closestCoords2 = v
		end
    end
    
    SetNewWaypoint(closestCoords2)
end)

RegisterNetEvent("fk:carwach")
AddEventHandler("fk:carwach", function()
   -- DeleteWaypoint()
	local currentGasBlip = 0
	local coords = GetEntityCoords(PlayerPedId())
	local closest = 1000
	local closestCoords2

	for k,v in pairs(carwach) do
		local dstcheck = GetDistanceBetweenCoords(coords, v)

		if dstcheck < closest then
			closest = dstcheck
			closestCoords2 = v
		end
    end
    
    SetNewWaypoint(closestCoords2)
end)

RegisterNetEvent('vehicle:flipit')
AddEventHandler('vehicle:flipit', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = nil
    if IsPedInAnyVehicle(ped, false) then vehicle = GetVehiclePedIsIn(ped, false) else vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71) end
        if DoesEntityExist(vehicle) then
        exports['progressbar']:Progress({
            name = "flipping_vehicle",
            duration = 5000,
            label = "Flipping Vehicle Over",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "random@mugging4",
                anim = "struggle_loop_b_thief",
                flags = 49,
            }
        }, function(status)

            local playerped = PlayerPedId()
            local coordA = GetEntityCoords(playerped, 1)
            local coordB = GetOffsetFromEntityInWorldCoords(playerped, 0.0, 100.0, 0.0)
            local targetVehicle = getVehicleInDirection(coordA, coordB)
            SetVehicleOnGroundProperly(targetVehicle)
        end)
    else
        QBCore.Functions.Notify('No vehicle nearby.', 'error')
    end
end)

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)    
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    
    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

carwach = {
    vector3(173.60603, -1737.593, 29.346616),
    vector3(25.298984, -1391.963, 29.330305),
    vector3(-699.6106, -932.7052, 19.009902),
    vector3(1363.2237, 3592.6999, 34.918697),
}
---
banks = {
    vector3(313.8475, -280.5742, 54.601627),
    vector3(149.6941, -1040.168, 29.369857),
    vector3(-1211.89, -331.8952, 38.217861),
    vector3(-351.24, -51.28, 49.47),
    vector3(241.82948, 223.70399, 106.28685),
    vector3(-2961.139, 483.08099, 15.693024),
    vector3(1174.826, 2708.2145, 38.524833),
    vector3(-112.2207, 6471.0087, 31.623157),
}

restaurant = {
    vector3(-580.7176, -1066.757, 22.344154),
    vector3(-1178.327, -885.3418, 13.85079),
    vector3(-1340.4, -1080.476, 6.9413461),
    vector3(-1207.945, -1135.764, 7.7098975),
    vector3(385.12521, -330.6776, 46.894351),
}

TattoShops = {
	vector3(1322.6, -1651.9, 51.2),
	vector3(-1153.6, -1425.6, 4.9),
	vector3(322.1, 180.4, 103.5),
	vector3(-3170.0, 1075.0, 20.8),
	vector3(1864.6, 3747.7, 33.0),
	vector3(-293.7, 6200.0, 31.4)
}



Motel = {
	vector3(-620.4843, 44.783145, 43.591423),
}

BarberShops = {
	vector3(-814.308, -183.823, 36.568),
	vector3(136.826, -1708.373, 28.291),
	vector3(-1282.604, -1116.757, 5.990),
	vector3(1931.513, 3729.671, 31.844),
	vector3(1212.840, -472.921, 65.208),
	vector3(-32.885, -152.319, 56.076),
	vector3(-278.077, 6228.463, 30.695),
}

GasStations = {
	vector3(49.4187, 2778.793, 58.043),
	vector3(263.894, 2606.463, 44.983),
	vector3(1039.958, 2671.134, 39.550),
	vector3(1207.260, 2660.175, 37.899),
	vector3(2539.685, 2594.192, 37.944),
	vector3(2679.858, 3263.946, 55.240),
	vector3(2005.055, 3773.887, 32.403),
	vector3(1687.156, 4929.392, 42.078),
	vector3(1701.314, 6416.028, 32.763),
	vector3(179.857, 6602.839, 31.868),
	vector3(-94.4619, 6419.594, 31.489),
	vector3(-2554.996, 2334.40, 33.078),
	vector3(-1800.375, 803.661, 138.651),
	vector3(-1437.622, -276.747, 46.207),
	vector3(-2096.243, -320.286, 13.168),
	vector3(-724.619, -935.1631, 19.213),
	vector3(-526.019, -1211.003, 18.184),
	vector3(-70.2148, -1761.792, 29.534),
	vector3(265.648, -1261.309, 29.292),
	vector3(819.653, -1028.846, 26.403),
	vector3(1208.951, -1402.567,35.224),
	vector3(1181.381, -330.847, 69.316),
	vector3(620.843, 269.100, 103.089),
	vector3(2581.321, 362.039, 108.468),
	vector3(176.631, -1562.025, 29.263),
	vector3(176.631, -1562.025, 29.263),
	vector3(-319.292, -1471.715, 30.549),
	vector3(1784.324, 3330.55, 41.253)
}