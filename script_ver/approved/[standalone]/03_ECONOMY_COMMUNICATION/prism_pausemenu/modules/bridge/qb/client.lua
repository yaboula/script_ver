

if CFG.Framework ~= 'qb' and CFG.DetectedFramework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()

TriggerServerCallback = function(name, data)
    local data2 = nil
    QBCore.Functions.TriggerCallback(name, function(data3)
        data2 = data3
    end, data)

    while data2 == nil do
        Wait(0)
    end

    return data2
end