-- ============================================================
-- Resmon Library - Core client-side utilities
-- Initialises Resmon.Lib sub-tables, detects the active
-- framework (ESX / QBCore), and exposes shared helpers.
-- ============================================================

-- ── Sub-table initialisation ────────────────────────────────
local Lib = Resmon.Lib
Lib.PlayerData       = {}
Lib.CurrentRequestId = 0
Lib.ServerCallbacks  = {}
Lib.UI               = {}
Lib.Callback         = {}
Lib.PropertiesVehicle = {}
Lib.Craft            = {}
Lib.Apartment        = {}
Lib.Craft_V2         = {}

-- ── Framework detection ─────────────────────────────────────
-- Try ESX first, then QBCore. Whichever resource is present wins.
ResmonFramework = nil

if GetResourceState(Config.CoreName.ESX) ~= "missing" then
    Config.Framework = "ESX"
    ResmonFramework  = exports[Config.CoreName.ESX]:getSharedObject()
end

if GetResourceState(Config.CoreName.QBCore) ~= "missing" then
    Config.Framework = "QBCore"
    ResmonFramework  = exports[Config.CoreName.QBCore]:GetCoreObject()
end

-- Returns the name of the active framework ("ESX" or "QBCore")
function Resmon.Lib.GetFramework()
    return Config.Framework
end

-- Cache which event name signals that the local player has loaded
Resmon.Lib.PlayerLoadedEvent = Config.PlayerLoadedEvents[Config.Framework]

-- Export GetFramework so other resources can query the active framework
exports("GetFramework", function()
    return Config.Framework
end)

-- ── String helpers ──────────────────────────────────────────

-- Strips all characters matching `pattern` from `str`, then
-- replaces each remaining character with a random printable ASCII char.
-- (Used internally to obfuscate/hash strings.)
function Resmon.Lib.GenerateHash(str, pattern)
    local stripped = string.gsub(str, pattern, "")
    local result   = ""
    for i = 1, string.len(stripped) do
        result = result .. string.char(math.random(32, 126))
    end
    return result
end

-- Trims leading and trailing whitespace from a string.
-- Returns nil if the input is falsy.
function Resmon.Lib.Trim(str)
    if not str then return nil end
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

-- Capitalises the first character of a string.
-- Returns nil if the input is falsy.
function Resmon.Lib.FirstToUpper(str)
    if not str then return nil end
    return str:gsub("^%l", string.upper)
end

-- Rounds `value` to `decimals` decimal places.
-- If `decimals` is omitted, rounds to the nearest integer.
function Resmon.Lib.Round(value, decimals)
    if not decimals then
        return math.floor(value + 0.5)
    end
    local factor = 10 ^ decimals
    return math.floor(value * factor + 0.5) / factor
end

-- ── Server callback ─────────────────────────────────────────

-- Sends a server callback request, storing `cb` to be invoked
-- when the server responds via 0R:Core:ServerCallback.
-- The request ID wraps at 65535.
function Resmon.Lib.Callback.Client(callbackName, cb, ...)
    local requestId = Resmon.Lib.CurrentRequestId
    Resmon.Lib.ServerCallbacks[requestId] = cb
    TriggerServerEvent("0R:Core:TriggerCallback", callbackName, requestId, ...)

    if Resmon.Lib.CurrentRequestId < 65535 then
        Resmon.Lib.CurrentRequestId = Resmon.Lib.CurrentRequestId + 1
    else
        Resmon.Lib.CurrentRequestId = 0
    end
end

-- ── Player helpers ──────────────────────────────────────────

-- Returns true if the local player is fully loaded and in-game.
function Resmon.Lib.IsPlayerLoaded()
    if Config.Framework == "ESX" then
        return ResmonFramework.IsPlayerLoaded()
    else
        return LocalPlayer.state.isLoggedIn
    end
end

-- Returns a normalised player-data table that works identically
-- regardless of whether the server is running ESX or QBCore.
-- Fields guaranteed: identifier, cash, bank, job (with grade_level).
function Resmon.Lib.GetPlayerData()
    local data = {}

    if Config.Framework == "ESX" then
        data = ResmonFramework.GetPlayerData()

        -- Flatten ESX account list into simple cash/bank keys
        for _, account in pairs(data.accounts or {}) do
            if account.name == "bank" then
                data.bank = account.money
            elseif account.name == "money" then
                data.cash = account.money
            end
        end

        -- Normalise job grade to a common field name
        if data.job then
            data.job.grade_level = data.job.grade
        end
    else
        data = ResmonFramework.Functions.GetPlayerData()

        -- QBCore stores the citizen ID separately from the identifier
        data.identifier = ResmonFramework.Functions.GetPlayerData().citizenid
        data.cash        = data.money.cash
        data.bank        = data.money.bank
        data.job.grade_level = data.job.grade.level
    end

    return data
end

-- Returns the trimmed plate text for the given vehicle handle,
-- or nil if the handle is 0 (no vehicle).
function Resmon.Lib.GetPlate(vehicle)
    if vehicle == 0 then return end
    return Resmon.Lib.Trim(GetVehicleNumberPlateText(vehicle))
end

-- ── Debug / logging ─────────────────────────────────────────

-- Recursively serialises a value to a human-readable string.
-- Tables are indented by `depth` levels (default 0).
function Resmon.Lib.DumpTable(value, depth)
    depth = depth or 0

    if type(value) == "table" then
        local indent = string.rep("    ", depth)
        local result = "{\n"

        for k, v in pairs(value) do
            -- Quote string keys
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            result = result .. indent .. "    [" .. k .. "] = "
                              .. Resmon.Lib.DumpTable(v, depth + 1) .. ",\n"
        end

        return result .. indent .. "}"
    else
        return tostring(value)
    end
end

-- ── NUI notification helpers ────────────────────────────────

-- Server can push a notification directly to this client's NUI.
RegisterNetEvent("0R:Lib:Notify")
AddEventHandler("0R:Lib:Notify", function(data)
    SendNUIMessage({ type = "showNotify", data = data })
end)

-- Local shortcut for sending a NUI notification.
function Resmon.Lib.Notify(data)
    SendNUIMessage({ type = "showNotify", data = data })
end

-- Shows the interaction hint UI.
-- Uses Config.CustomTextUIFunc if a custom handler is configured.
function Resmon.Lib.ShowTextUI(text, icon)
    if not Config.CustomTextUI then
        SendNUIMessage({ type = "showUI", icon = icon, string = text })
    else
        Config.CustomTextUIFunc(text)
    end
end

-- Hides the interaction hint UI.
-- Uses Config.CustomTextUIHide if a custom handler is configured.
function Resmon.Lib.HideTextUI()
    if not Config.CustomTextUI then
        SendNUIMessage({ type = "hideUI" })
    else
        Config.CustomTextUIHide()
    end
end

-- Shows a framework notification (ESX or QBCore).
-- Skipped entirely if Config.CustomNotify is set.
function Resmon.Lib.ShowNotify(message, notifyType, duration, arg4, arg5)
    if Config.CustomNotify then return end

    if Config.Framework == "ESX" then
        ResmonFramework.ShowNotification(message, notifyType, duration)
    else
        ResmonFramework.Functions.Notify(message, notifyType, duration)
    end
end

-- ── Player lookup helpers ───────────────────────────────────

-- Returns a list (or map) of active player IDs / ped handles.
-- excludeSelf   – exclude the local player from results
-- usePlayerIdAsKey – key the result table by player ID instead of index
-- returnPeds    – include ped handles instead of player IDs in value
function Resmon.Lib.GetPlayers(excludeSelf, usePlayerIdAsKey, returnPeds)
    local result   = {}
    local localId  = PlayerId()

    for _, playerId in ipairs(GetActivePlayers()) do
        local ped    = GetPlayerPed(playerId)
        local exists = DoesEntityExist(ped)

        if exists and (excludeSelf and playerId ~= localId or not excludeSelf) then
            if usePlayerIdAsKey then
                result[playerId] = ped
            else
                local value = (returnPeds and ped) and ped or playerId
                result[#result + 1] = value
            end
        end
    end

    return result
end

-- Returns the nearest player ID and their distance from `coords`.
-- If `coords` is nil, uses the local player's position and excludes self.
function Resmon.Lib.GetClosestPlayer(coords)
    local players   = Resmon.Lib.GetPlayers()
    local closestId = -1
    local closestDist = -1
    local excludeSelf = coords == nil
    local localPed  = PlayerPedId()
    local localId   = PlayerId()

    if excludeSelf then
        coords = GetEntityCoords(localPed)
    end

    for i = 1, #players do
        local playerId = players[i]

        -- When no coords were supplied, skip the local player
        if excludeSelf and playerId == localId then
            goto continue
        end

        local ped  = GetPlayerPed(playerId)
        local dist = GetDistanceBetweenCoords(GetEntityCoords(ped), coords.x, coords.y, coords.z, true)

        if closestDist == -1 or dist < closestDist then
            closestId   = playerId
            closestDist = dist
        end

        ::continue::
    end

    return closestId, closestDist
end

-- ── Asset loading helpers ───────────────────────────────────

-- Requests and waits for an animation dictionary to finish loading.
-- Calls `callback` once ready (if provided).
function Resmon.Lib.A11SFUNCTION(animDict, callback)
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(0)
        end
    end
    if callback ~= nil then
        callback()
    end
end

-- Requests and waits for a model to finish streaming.
function Resmon.Lib.LoadModel(modelHash)
    if HasModelLoaded(modelHash) then return end
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(0)
    end
end

-- Requests and waits for a weapon asset to finish streaming.
function Resmon.Lib.LoadWeaponAsset(weaponName)
    local hash = GetHashKey(weaponName)
    if HasWeaponAssetLoaded(hash) then return end
    RequestWeaponAsset(hash, 31, 0)
    while not HasWeaponAssetLoaded(hash) do
        Wait(10)
    end
end

-- ── NUI focus toggle ────────────────────────────────────────

local nuiFocused = false

-- /ra command: toggles NUI focus on/off (debug helper)
-- RegisterCommand("ra", function()
--     nuiFocused = not nuiFocused
--     if nuiFocused then
--         SetNuiFocus(true, true)
--     else
--         SetNuiFocus(false, false)
--     end
-- end)

-- ── World-object helpers ────────────────────────────────────

-- Returns all objects of the given model hash within `radius` of `coords`.
-- If `coords` is omitted, uses the local player's position.
function Resmon.Lib.GetClosestObjectsOfType(modelName, coords, radius)
    local localPed = PlayerPedId()
    local objects  = GetGamePool("CObject")
    local found    = {}

    if type(coords) == "table" then
        coords = vec3(coords.x, coords.y, coords.z) or coords
    elseif not coords then
        coords = GetEntityCoords(localPed)
    end

    local modelHash = GetHashKey(modelName)

    for i = 1, #objects do
        local obj  = objects[i]
        local dist = #(GetEntityCoords(obj) - coords)

        if dist <= radius and GetEntityModel(obj) == modelHash then
            table.insert(found, obj)
        end
    end

    return found
end

-- ── Apartment helper ────────────────────────────────────────

-- Finds garage lift door objects near `coords` and freezes/unfreezes them.
function Resmon.Lib.Apartment._0xcfpFED(coords, freeze)
    local doors = Resmon.Lib.GetClosestObjectsOfType("v_ilev_garageliftdoor", coords, 3.0)
    for _, door in pairs(doors) do
        FreezeEntityPosition(door, freeze)
    end
end

-- ── Craft helpers ───────────────────────────────────────────

-- Spawns a prop or weapon object at the given world position.
-- `objectType` should be "weapon" for weapon objects; anything else creates a regular prop.
function Resmon.Lib.Craft.LoadPropOnTable(modelName, x, y, z, objectType)
    local entity

    if objectType == "weapon" then
        Resmon.Lib.LoadWeaponAsset(modelName)
        entity = CreateWeaponObject(modelName, 0, x, y, z, true, 1.3, 0)
    else
        Resmon.Lib.LoadModel(modelName)
        entity = CreateObject(modelName, x, y, z, false, false, false)
    end

    SetModelAsNoLongerNeeded(modelName)
    return entity
end

-- ── Craft V2 helpers ────────────────────────────────────────

-- Always returns true; can be overridden to gate crafting UI access.
function Resmon.Lib.Craft_V2.canOpenUI()
    return true
end

-- Converts a Euler-angle rotation vector to a forward direction vector.
local function eulerToForward(rot)
    local zRad    = math.rad(rot.z)
    local xRad    = math.rad(rot.x)
    local cosX    = math.cos(xRad)
    return vector3(-math.sin(zRad) * cosX, math.cos(zRad) * cosX, math.sin(xRad))
end

-- Spawns a static world object at `pos` with optional rotation.
-- frozen  (default true)  – freeze position after spawning
-- dynamic (default false) – pass dynamic flag to CreateObject
-- script  (default false) – pass script flag to CreateObject
local function spawnStaticObject(modelName, pos, rot, frozen, dynamic, script)
    if frozen  == nil then frozen  = true  end
    if dynamic == nil then dynamic = false end
    if script  == nil then script  = false end

    Resmon.Lib.LoadModel(modelName)
    local obj = CreateObject(modelName, pos.x, pos.y, pos.z, dynamic, dynamic, script)
    SetEntityCoords(obj, pos.x, pos.y, pos.z, false, false, false, true)

    if rot then
        -- Accept a plain heading number as a shorthand for vector3(0, 0, heading)
        if type(rot) == "number" then
            rot = vector3(0.0, 0.0, rot)
        end
        SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, false)
    end

    FreezeEntityPosition(obj, frozen)
    SetModelAsNoLongerNeeded(modelName)
    return obj
end

-- Creates a preview prop or weapon object in front of the camera.
-- For weapons, also applies any listed components/tints from `components`.
-- Returns: success (bool), entity handle
function Resmon.Lib.Craft_V2.createPreviewObject(modelName, components, camera)
    local camPos     = GetCamCoord(camera)
    local camRot     = GetCamRot(camera, 2)
    local forward    = eulerToForward(camRot)
    local spawnPos   = camPos + forward * 1.2
    local entity

    local isWeapon = modelName:lower():sub(0, 7) == "weapon_"

    if isWeapon then
        -- Load the weapon asset and its visual model
        Resmon.Lib.LoadWeaponAsset(modelName)
        local weaponModel = GetWeapontypeModel(modelName)
        Resmon.Lib.LoadModel(weaponModel)

        entity = CreateWeaponObject(
            modelName, 0,
            spawnPos.x, spawnPos.y, spawnPos.z + 0.1,
            true, 1.3, 0
        )

        -- Wait until the entity actually exists before modifying it
        while not DoesEntityExist(entity) do
            Wait(0)
        end

        -- Hide while we attach components, then reveal
        SetEntityAlpha(entity, 0)
        SetEntityRotation(entity, 0.0, 0.0, (camRot.z + 180.0) % 360.0)

        local skinComponent = nil

        for _, component in ipairs(components) do
            if component.name == "skin" then
                skinComponent = component
            else
                -- Resolve hash: convert string hashes via GetHashKey
                local hash = component.hash
                if type(hash) == "string" then
                    hash = GetHashKey(hash) or hash
                end
                local compModel = GetWeaponComponentTypeModel(hash)
                Resmon.Lib.LoadModel(compModel)
                GiveWeaponComponentToWeaponObject(entity, hash)
                SetModelAsNoLongerNeeded(compModel)
            end
        end

        if skinComponent then
            SetWeaponObjectTintIndex(entity, 2)
        end

        SetEntityAlpha(entity, 255)
        RemoveWeaponAsset(modelName)
        SetModelAsNoLongerNeeded(weaponModel)
    else
        entity = spawnStaticObject(modelName, spawnPos, nil, true, false, false)
    end

    return true, entity
end

-- ── NUI license callbacks ───────────────────────────────────
-- These always return true; server-side validation is done separately.

RegisterNUICallback("hasillegalpacklicense", function(data, cb)
    cb(true)
end)

RegisterNUICallback("haslicense", function(data, cb)
    cb(true)
end)

-- ── Clothing URL helper ─────────────────────────────────────

-- Fetches the clothing URL from the server via callback and returns it.
-- Waits up to 1 second for the response before resolving.
function getUrlDataClient()
    local p   = promise.new()
    local url = nil

    Resmon.Lib.Callback.Client("pa-lib-2:getClothingUrl", function(result)
        url = result
    end)

    Citizen.Wait(1000)
    p:resolve(url)
    return Citizen.Await(p)
end

exports("getUrlDataClient", getUrlDataClient)

-- ── Vehicle properties ──────────────────────────────────────
-- Get: snapshots every cosmetic and mechanical property of a vehicle.
-- Set: applies a previously captured snapshot back onto a vehicle.

-- Reads all properties from `vehicle` and returns them as a table.
function Resmon.Lib.PropertiesVehicle.Get(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local color1, color2               = GetVehicleColours(vehicle)

    -- Prefer custom RGB colours over palette indices
    if GetIsVehiclePrimaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        color1 = { r, g, b }
    end

    if GetIsVehicleSecondaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        color2 = { r, g, b }
    end

    -- Extras (slots 0–12)
    local extras = {}
    for slot = 0, 12 do
        if DoesExtraExist(vehicle, slot) then
            extras[tostring(slot)] = (IsVehicleExtraTurnedOn(vehicle, slot) == 1)
        end
    end

    -- Livery: mod slot 48 takes priority; fall back to GetVehicleLivery
    local livery = GetVehicleMod(vehicle, 48)
    if livery == -1 then
        local legacyLivery = GetVehicleLivery(vehicle)
        if legacyLivery ~= 0 then
            livery = legacyLivery
        end
    end

    -- Tyre health (wheels 0–3)
    local tireHealth = {}
    for wheel = 0, 3 do
        tireHealth[wheel] = GetVehicleWheelHealth(vehicle, wheel)
    end

    -- Tyre burst state (partial and complete, wheels 0–5)
    local tireBurstState, tireBurstCompletely = {}, {}
    for wheel = 0, 5 do
        tireBurstState[wheel]      = IsVehicleTyreBurst(vehicle, wheel, false)
        tireBurstCompletely[wheel] = IsVehicleTyreBurst(vehicle, wheel, true)
    end

    -- Window intact state (windows 0–7)
    local windowStatus = {}
    for win = 0, 7 do
        windowStatus[win] = (IsVehicleWindowIntact(vehicle, win) == 1)
    end

    -- Door damage state (doors 0–5)
    local doorStatus = {}
    for door = 0, 5 do
        doorStatus[door] = (IsVehicleDoorDamaged(vehicle, door) == 1)
    end

    local Lib = Resmon.Lib

    return {
        model          = GetEntityModel(vehicle),
        plate          = Lib.GetPlate(vehicle),
        plateIndex     = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth     = Lib.Round(GetVehicleBodyHealth(vehicle), 0.1),
        engineHealth   = Lib.Round(GetVehicleEngineHealth(vehicle), 0.1),
        tankHealth     = Lib.Round(GetVehiclePetrolTankHealth(vehicle), 0.1),
        fuelLevel      = Lib.Round(GetVehicleFuelLevel(vehicle), 0.1),
        dirtLevel      = Lib.Round(GetVehicleDirtLevel(vehicle), 0.1),
        oilLevel       = Lib.Round(GetVehicleOilLevel(vehicle), 0.1),
        color1         = color1,
        color2         = color2,
        pearlescentColor = pearlescentColor,
        dashboardColor = GetVehicleDashboardColour(vehicle),
        wheelColor     = wheelColor,
        wheels         = GetVehicleWheelType(vehicle),
        wheelSize      = GetVehicleWheelSize(vehicle),
        wheelWidth     = GetVehicleWheelWidth(vehicle),
        tireHealth     = tireHealth,
        tireBurstState = tireBurstState,
        tireBurstCompletely = tireBurstCompletely,
        windowTint     = GetVehicleWindowTint(vehicle),
        windowStatus   = windowStatus,
        doorStatus     = doorStatus,
        xenonColor     = GetVehicleXenonLightsColour(vehicle),
        neonEnabled    = {
            IsVehicleNeonLightEnabled(vehicle, 0),
            IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2),
            IsVehicleNeonLightEnabled(vehicle, 3),
        },
        neonColor      = table.pack(GetVehicleNeonLightsColour(vehicle)),
        headlightColor = GetVehicleHeadlightsColour(vehicle),
        interiorColor  = GetVehicleInteriorColour(vehicle),
        extras         = extras,
        tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
        -- Mods (slot → property name)
        modSpoilers      = GetVehicleMod(vehicle, 0),
        modFrontBumper   = GetVehicleMod(vehicle, 1),
        modRearBumper    = GetVehicleMod(vehicle, 2),
        modSideSkirt     = GetVehicleMod(vehicle, 3),
        modExhaust       = GetVehicleMod(vehicle, 4),
        modFrame         = GetVehicleMod(vehicle, 5),
        modGrille        = GetVehicleMod(vehicle, 6),
        modHood          = GetVehicleMod(vehicle, 7),
        modFender        = GetVehicleMod(vehicle, 8),
        modRightFender   = GetVehicleMod(vehicle, 9),
        modRoof          = GetVehicleMod(vehicle, 10),
        modEngine        = GetVehicleMod(vehicle, 11),
        modBrakes        = GetVehicleMod(vehicle, 12),
        modTransmission  = GetVehicleMod(vehicle, 13),
        modHorns         = GetVehicleMod(vehicle, 14),
        modSuspension    = GetVehicleMod(vehicle, 15),
        modArmor         = GetVehicleMod(vehicle, 16),
        modKit17         = GetVehicleMod(vehicle, 17),
        modTurbo         = IsToggleModOn(vehicle, 18),
        modKit19         = GetVehicleMod(vehicle, 19),
        modSmokeEnabled  = IsToggleModOn(vehicle, 20),
        modKit21         = GetVehicleMod(vehicle, 21),
        modXenon         = IsToggleModOn(vehicle, 22),
        modFrontWheels   = GetVehicleMod(vehicle, 23),
        modBackWheels    = GetVehicleMod(vehicle, 24),
        modCustomTiresF  = GetVehicleModVariation(vehicle, 23),
        modCustomTiresR  = GetVehicleModVariation(vehicle, 24),
        modPlateHolder   = GetVehicleMod(vehicle, 25),
        modVanityPlate   = GetVehicleMod(vehicle, 26),
        modTrimA         = GetVehicleMod(vehicle, 27),
        modOrnaments     = GetVehicleMod(vehicle, 28),
        modDashboard     = GetVehicleMod(vehicle, 29),
        modDial          = GetVehicleMod(vehicle, 30),
        modDoorSpeaker   = GetVehicleMod(vehicle, 31),
        modSeats         = GetVehicleMod(vehicle, 32),
        modSteeringWheel = GetVehicleMod(vehicle, 33),
        modShifterLeavers = GetVehicleMod(vehicle, 34),
        modAPlate        = GetVehicleMod(vehicle, 35),
        modSpeakers      = GetVehicleMod(vehicle, 36),
        modTrunk         = GetVehicleMod(vehicle, 37),
        modHydrolic      = GetVehicleMod(vehicle, 38),
        modEngineBlock   = GetVehicleMod(vehicle, 39),
        modAirFilter     = GetVehicleMod(vehicle, 40),
        modStruts        = GetVehicleMod(vehicle, 41),
        modArchCover     = GetVehicleMod(vehicle, 42),
        modAerials       = GetVehicleMod(vehicle, 43),
        modTrimB         = GetVehicleMod(vehicle, 44),
        modTank          = GetVehicleMod(vehicle, 45),
        modWindows       = GetVehicleMod(vehicle, 46),
        modKit47         = GetVehicleMod(vehicle, 47),
        modLivery        = livery,
        modKit49         = GetVehicleMod(vehicle, 49),
        liveryRoof       = GetVehicleRoofLivery(vehicle),
    }
end

-- Applies a previously captured property snapshot back onto `vehicle`.
function Resmon.Lib.PropertiesVehicle.Set(vehicle, props)
    if not DoesEntityExist(vehicle) then return end

    local prevColor1, prevColor2             = GetVehicleColours(vehicle)
    local prevPearlescent, prevWheelColor    = GetVehicleExtraColours(vehicle)

    SetVehicleModKit(vehicle, 0)

    -- Extras
    if props.extras then
        for slot, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(slot), enabled and 0 or 1)
        end
    end

    -- Plate
    if props.plate      then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end

    -- Health / fluids (cast to float where required)
    if props.bodyHealth   then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
    if props.tankHealth   then SetVehiclePetrolTankHealth(vehicle, props.tankHealth) end
    if props.fuelLevel    then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
    if props.dirtLevel    then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
    if props.oilLevel     then SetVehicleOilLevel(vehicle, props.oilLevel) end

    -- Primary colour: palette index or custom RGB
    if props.color1 then
        if type(props.color1) == "number" then
            ClearVehicleCustomPrimaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1, prevColor2)
        else
            SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
        end
    end

    -- Secondary colour: palette index or custom RGB
    if props.color2 then
        if type(props.color2) == "number" then
            ClearVehicleCustomSecondaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1 or prevColor1, props.color2)
        else
            SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
        end
    end

    if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, prevWheelColor) end
    if props.interiorColor    then SetVehicleInteriorColor(vehicle, props.interiorColor) end
    if props.dashboardColor   then SetVehicleDashboardColour(vehicle, props.dashboardColor) end
    if props.wheelColor       then SetVehicleExtraColours(vehicle, props.pearlescentColor or prevPearlescent, props.wheelColor) end
    if props.wheels           then SetVehicleWheelType(vehicle, props.wheels) end
    if props.wheelSize        then SetVehicleWheelSize(vehicle, props.wheelSize) end
    if props.wheelWidth       then SetVehicleWheelWidth(vehicle, props.wheelWidth) end

    -- Tyre health
    if props.tireHealth then
        for wheel, health in pairs(props.tireHealth) do
            SetVehicleWheelHealth(vehicle, wheel, health)
        end
    end

    -- Tyre burst (partial)
    if props.tireBurstState then
        for wheel, burst in pairs(props.tireBurstState) do
            if burst then
                SetVehicleTyreBurst(vehicle, tonumber(wheel), false, 1000.0)
            end
        end
    end

    -- Tyre burst (complete)
    if props.tireBurstCompletely then
        for wheel, burst in pairs(props.tireBurstCompletely) do
            if burst then
                SetVehicleTyreBurst(vehicle, tonumber(wheel), true, 1000.0)
            end
        end
    end

    if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

    -- Smash damaged windows
    if props.windowStatus then
        for win, intact in pairs(props.windowStatus) do
            if not intact then SmashVehicleWindow(vehicle, win) end
        end
    end

    -- Break damaged doors
    if props.doorStatus then
        for door, broken in pairs(props.doorStatus) do
            if broken then SetVehicleDoorBroken(vehicle, tonumber(door), true) end
        end
    end

    -- Neon lights
    if props.neonEnabled then
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(vehicle, i, props.neonEnabled[i + 1])
        end
    end

    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end

    if props.headlightColor then SetVehicleHeadlightsColour(vehicle, props.headlightColor) end
    if props.interiorColor  then SetVehicleInteriorColour(vehicle, props.interiorColor) end

    if props.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end

    if props.xenonColor then SetVehicleXenonLightsColor(vehicle, props.xenonColor) end

    -- Standard mods (SetVehicleMod)
    local standardMods = {
        { "modSpoilers",      0  },
        { "modFrontBumper",   1  },
        { "modRearBumper",    2  },
        { "modSideSkirt",     3  },
        { "modExhaust",       4  },
        { "modFrame",         5  },
        { "modGrille",        6  },
        { "modHood",          7  },
        { "modFender",        8  },
        { "modRightFender",   9  },
        { "modRoof",          10 },
        { "modEngine",        11 },
        { "modBrakes",        12 },
        { "modTransmission",  13 },
        { "modHorns",         14 },
        { "modSuspension",    15 },
        { "modArmor",         16 },
        { "modKit17",         17 },
        { "modKit19",         19 },
        { "modKit21",         21 },
        { "modFrontWheels",   23 },
        { "modBackWheels",    24 },
        { "modPlateHolder",   25 },
        { "modVanityPlate",   26 },
        { "modTrimA",         27 },
        { "modOrnaments",     28 },
        { "modDashboard",     29 },
        { "modDial",          30 },
        { "modDoorSpeaker",   31 },
        { "modSeats",         32 },
        { "modSteeringWheel", 33 },
        { "modShifterLeavers",34 },
        { "modAPlate",        35 },
        { "modSpeakers",      36 },
        { "modTrunk",         37 },
        { "modHydrolic",      38 },
        { "modEngineBlock",   39 },
        { "modAirFilter",     40 },
        { "modStruts",        41 },
        { "modArchCover",     42 },
        { "modAerials",       43 },
        { "modTrimB",         44 },
        { "modTank",          45 },
        { "modWindows",       46 },
        { "modKit47",         47 },
        { "modKit49",         49 },
    }

    for _, entry in ipairs(standardMods) do
        local key, slot = entry[1], entry[2]
        if props[key] then
            SetVehicleMod(vehicle, slot, props[key], false)
        end
    end

    -- Toggle mods
    if props.modTurbo       then ToggleVehicleMod(vehicle, 18, props.modTurbo) end
    if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled) end
    if props.modXenon       then ToggleVehicleMod(vehicle, 22, props.modXenon) end

    -- Custom tyre variations (applied after the wheel mod itself)
    if props.modCustomTiresF then SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF) end
    if props.modCustomTiresR then SetVehicleMod(vehicle, 24, props.modBackWheels,  props.modCustomTiresR) end

    -- Livery: set via both the mod slot and the legacy livery API
    if props.modLivery then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.liveryRoof then SetVehicleRoofLivery(vehicle, props.liveryRoof) end
end