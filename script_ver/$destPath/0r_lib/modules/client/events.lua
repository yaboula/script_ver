-- ============================================================
-- Core event bridge: notifies server when a player joins
-- and keeps local PlayerData in sync with job/data updates.
-- ============================================================

-- ESX: fired when the local player has fully loaded
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- QBCore: fired when the local player has fully loaded
RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- ESX: fired when the player's job changes
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(newJob)
    -- Keep the local cache in sync, then tell the server
    Resmon.Lib.PlayerData.job = newJob
    TriggerServerEvent("0R:Core:SetPlayerJob", newJob)
end)

-- QBCore: fired when the player's job changes
RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(newJob)
    -- Keep the local cache in sync, then tell the server
    Resmon.Lib.PlayerData.job = newJob
    TriggerServerEvent("0R:Core:SetPlayerJob", newJob)
end)

-- QBCore spawn screen: treat opening the spawn UI as a fresh join
RegisterNetEvent("qb-spawn:client:openUI")
AddEventHandler("qb-spawn:client:openUI", function()
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- On resource (re)start, re-announce this player to the server
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- Server pushed fresh PlayerData down to this client — store it
RegisterNetEvent("0R:Core:SetPlayerData")
AddEventHandler("0R:Core:SetPlayerData", function(playerData)
    Resmon.Lib.PlayerData = playerData
end)

-- Server is responding to a TriggerServerCallback call;
-- invoke the stored callback then clean it up to avoid leaks.
RegisterNetEvent("0R:Core:ServerCallback")
AddEventHandler("0R:Core:ServerCallback", function(callbackId, ...)
    local cb = Resmon.Lib.ServerCallbacks[callbackId]
    if cb then
        cb(...)
        Resmon.Lib.ServerCallbacks[callbackId] = nil
    end
end)