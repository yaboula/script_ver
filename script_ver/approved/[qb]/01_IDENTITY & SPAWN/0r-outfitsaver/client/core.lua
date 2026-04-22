Core = nil
CoreName = nil
CoreReady = false
SetClothing = nil
Citizen.CreateThread(function()
    for k, v in pairs(Cores) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            CoreName = v.ConstantName
            Core = v.GetFramework()
            CoreReady = true
            PlayerData = GetPlayerData()
        end
    end
    for k, v in pairs(ClothingScripts) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            print("Using: " .. v.ResourceName)
            function SetClothing(var1) v.SetClothing(var1) end
            break
        else
            function SetClothing(var2) print("No compatible clothing scripts found, please add your clothing script with script name and script export to clothing-scripts.lua file.") end
        end
    end
end)

Config.ServerCallbacks = {}
function TriggerCallback(name, cb, ...)
    Config.ServerCallbacks[name] = cb
    TriggerServerEvent('0r-outfitsaver:server:triggerCallback', name, ...)
end

RegisterNetEvent('0r-outfitsaver:client:triggerCallback', function(name, ...)
    if Config.ServerCallbacks[name] then
        Config.ServerCallbacks[name](...)
        Config.ServerCallbacks[name] = nil
    end
end)

function Notify(text, type, length)
    length = length or 5000
    if CoreName == "qb" then
        Core.Functions.Notify(text, type, length)
    elseif CoreName == "esx" then
        Core.ShowNotification(text)
    end
end

function GetPlayerData()
    if CoreName == "qb" then
        local player = Core.Functions.GetPlayerData()
        return player
    elseif CoreName == "esx" then
        local player = Core.GetPlayerData()
        return player
    end
end

function GetPlayerJob()
    if CoreName == "qb" then
        return Core.Functions.GetPlayerData().job.name
    elseif CoreName == "esx" then
        local player = Core.GetPlayerData()
        return player.job.name
    end
end