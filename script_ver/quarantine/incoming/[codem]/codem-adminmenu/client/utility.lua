cam = nil

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
    Wait(1000)
    TriggerServerEvent('codem-adminmenu:server:loadData')
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    Wait(1000)
    TriggerServerEvent('codem-adminmenu:server:loadData')
end)

CreateThread(function()
    Core, Config.Framework = GetCore()
end)


AddEventHandler('onResourceStart', function(resourceName)
    if (resourceName == GetCurrentResourceName()) then
        TriggerServerEvent('codem-adminmenu:server:loadData')
    end
end)


RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(data)
    Wait(1000)
    SetPlayerJob()
end)

function WaitPlayer()
    if Config.Framework == "esx" or Config.Framework == 'oldesx' then
        while Core == nil do
            Wait(0)
        end
        while Core.GetPlayerData() == nil do
            Wait(0)
        end
        while Core.GetPlayerData().job == nil do
            Wait(0)
        end
    else
        while Core == nil do
            Wait(0)
        end
        while Core.Functions.GetPlayerData() == nil do
            Wait(0)
        end
        while Core.Functions.GetPlayerData().metadata == nil do
            Wait(0)
        end
    end
end

function SetPlayerJob()
    while Core == nil do
        Wait(0)
    end
    Wait(500)
    while not nuiLoaded do
        Wait(50)
    end
    WaitPlayer()

    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        local PlayerData = Core.GetPlayerData()
        TriggerServerEvent('codem-adminmenu:changePlayerJob', PlayerData.job.name)
    else
        local PlayerData = Core.Functions.GetPlayerData()
        TriggerServerEvent('codem-adminmenu:changePlayerJob', PlayerData["job"].name)
    end
end

local entityEnumerator = {
    __gc = function(enum)
        if enum.destructor and enum.handle then
            enum.destructor(enum.handle)
        end
        enum.destructor = nil
        enum.handle = nil
    end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(
        function()
            local iter, id = initFunc()
            if not id or id == 0 then
                disposeFunc(iter)
                return
            end

            local enum = { handle = iter, destructor = disposeFunc }
            setmetatable(enum, entityEnumerator)

            local next = true
            repeat
                coroutine.yield(id)
                next, id = moveFunc(iter)
            until not next

            enum.destructor, enum.handle = nil, nil
            disposeFunc(iter)
        end
    )
end

function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end
