--- https://github.com/PenguScript/pengu_digiscanner
--- Credit PenguScript, thanks to him/her. It is used in some places with minor fixes and changes.

local scaleform = RequestScaleformMovie('DIGISCANNER')
local inScaleform = false
local targetCoords = vector3(0, 0, 0)
local wait = 1000

local DigiScanner = {}

local sfbars = {
    { dist = 50, bars = 0.0,   wait = 6000 },
    { dist = 45, bars = 10.0,  wait = 5500 },
    { dist = 40, bars = 20.0,  wait = 5000 },
    { dist = 35, bars = 30.0,  wait = 4500 },
    { dist = 30, bars = 40.0,  wait = 4000 },
    { dist = 25, bars = 50.0,  wait = 3500 },
    { dist = 20, bars = 60.0,  wait = 3000 },
    { dist = 15, bars = 70.0,  wait = 2500 },
    { dist = 10, bars = 80.0,  wait = 2000 },
    { dist = 5,  bars = 90.0,  wait = 1500 },
    { dist = 0,  bars = 100.0, wait = 1000 },
}

-- Renk tanımları
local sfcolors = {
    red       = { r = 255, g = 10, b = 10 },
    yellow    = { r = 255, g = 209, b = 67 },
    lightblue = { r = 67, g = 200, b = 255 },
    green     = { r = 0, g = 255, b = 80 }
}

local function ScaleformMethod(sf, name, data)
    BeginScaleformMovieMethod(sf, name)
    for _, v in pairs(data or {}) do
        if name == 'SET_DISTANCE' then
            PushScaleformMovieMethodParameterFloat(v)
        else
            PushScaleformMovieMethodParameterInt(v)
        end
    end
    PopScaleformMovieFunctionVoid()
end

local function SetScaleformColor(bar, dot)
    if not inScaleform then return end
    ScaleformMethod(scaleform, 'SET_COLOUR', { bar.r, bar.g, bar.b, dot.r, dot.g, dot.b })
end

local function UpdateBars(dist, who)
    if not scaleform then return end

    for _, entry in pairs(sfbars) do
        if dist > entry.dist then
            wait = entry.wait
            ScaleformMethod(scaleform, 'SET_DISTANCE', { entry.bars })
            break
        end
    end

    if dist < 2.0 then
        wait = 250
        SetScaleformColor(sfcolors.green, sfcolors.green)
        inScaleform = false
        TriggerEvent('client:onDigiScannerCompleted', who)
    end
end

local function HeadingCheck(playerCoords, playerHeading, targetCoords)
    local dx = targetCoords.x - playerCoords.x
    local dy = targetCoords.y - playerCoords.y
    local targetHeading = GetHeadingFromVector_2d(dx, dy)
    return math.abs(playerHeading - targetHeading) < 20
end

local function StartScanner(who)
    if inScaleform then return end
    inScaleform = true

    while not HasScaleformMovieLoaded(scaleform) do Wait(0) end

    local renderId = 0

    if not IsNamedRendertargetRegistered('digiscanner') then
        RegisterNamedRendertarget('digiscanner', 0)
    end

    LinkNamedRendertarget(GetWeapontypeModel(joaat('WEAPON_DIGISCANNER')))

    if IsNamedRendertargetRegistered('digiscanner') then
        renderId = GetNamedRendertargetRenderId('digiscanner')
    end

    CreateThread(function()
        local who = who
        while inScaleform do
            local ped = cache.ped
            local playerCoords = GetEntityCoords(ped)
            local playerHeading = GetEntityHeading(ped)
            local dist = #(playerCoords - targetCoords)

            if IsPlayerFreeAiming(PlayerId()) then
                if HeadingCheck(playerCoords, playerHeading, targetCoords) then
                    SetScaleformColor(sfcolors.lightblue, sfcolors.yellow)
                else
                    SetScaleformColor(sfcolors.red, sfcolors.red)
                end

                UpdateBars(dist, who)
            end

            SetTextRenderId(renderId)
            DrawScaleformMovie(scaleform, 0.1, 0.24, 0.21, 0.51, 255, 255, 255, 255, 0)
            SetTextRenderId(1)

            Wait(1)
        end
        EndScaleformMovieMethodReturn()
    end)

    CreateThread(function()
        while true do
            local sleep = 1000
            if inScaleform then
                local ped = cache.ped
                if GetSelectedPedWeapon(ped) == joaat('WEAPON_DIGISCANNER') then
                    if IsPlayerFreeAiming(PlayerId()) then
                        local coords = GetEntityCoords(ped)
                        PlaySoundFromCoord(-1, 'IDLE_BEEP', coords.x, coords.y, coords.z, 'EPSILONISM_04_SOUNDSET', true,
                            5.0, false)
                    end
                    Wait(wait)
                    sleep = 0
                else
                    sleep = 5000
                end
            end
            Wait(sleep)
        end
    end)
end

function DigiScanner.scan(coords, who)
    targetCoords = coords
    StartScanner(who)
end

return DigiScanner
