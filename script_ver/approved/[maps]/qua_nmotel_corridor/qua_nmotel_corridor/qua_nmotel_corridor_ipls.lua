local interiorCoords = {
    x = -419.1095,
    y = -814.1289,
    z = -164.65
}
local interiorIPL = "qua_nmotel_corridor_milo"
local propSet = "tint"
local defaultTintIndex = 55
local commandName = "tint_apart_corridor"
local blockedStaticEmitters = {
    "se_dlc_apt_yacht_bedroom"
}
local scenarioBlockStart = {
    x = -1079.51514,
    y = -1483.87439,
    z = -670.6511
}
local scenarioBlockEnd = {
    x = 234.274963,
    y = -160.420776,
    z = 340.5304
}

local interiorID

Citizen.CreateThread(function()
local x, y, z = interiorCoords.x, interiorCoords.y, interiorCoords.z
    interiorID = GetInteriorAtCoords(x, y, z)
    RequestIpl(interiorIPL)

    if IsValidInterior(interiorID) then
        EnableInteriorProp(interiorID, propSet)
        RefreshInterior(interiorID)
    end
end)

Citizen.CreateThread(function()
    SetInteriorEntitySetColor(interiorID, propSet, defaultTintIndex)
end)

Citizen.CreateThread(function()
    -- [AUDIT AUD-002] RegisterCommand protegido por ACE nativo (3er arg = true)
    -- Requiere: add_ace group.admin command.tint_apart_corridor allow (en server.cfg)
    RegisterCommand(commandName, function(source, args)
        local newTintIndex = tonumber(args[1])
        if not newTintIndex then return end
        SetInteriorEntitySetColor(interiorID, propSet, newTintIndex)
        RefreshInterior(interiorID)
    end, true)
end)

local staticEmitters = {}
staticEmitters[1] = "se_dlc_apt_yacht_bedroom"

Citizen.CreateThread(function()
local startIndex = 1
local endIndex = #staticEmitters
local step = 1
    for i = startIndex, endIndex, step do
local emitterName = staticEmitters[i]
local enable = false
        SetStaticEmitterEnabled(emitterName, enable)
    end
end)

local startVec = vec3(scenarioBlockStart.x, scenarioBlockStart.y, scenarioBlockStart.z)
local endVec = vec3(scenarioBlockEnd.x, scenarioBlockEnd.y, scenarioBlockEnd.z)

if not DoesScenarioBlockingAreaExist(startVec, endVec) then
local checkLOS = 0
local unkParam2 = 1
local unkParam3 = 1
local unkParam4 = 1
    AddScenarioBlockingArea(startVec, endVec, checkLOS, unkParam2, unkParam3, unkParam4)
end
