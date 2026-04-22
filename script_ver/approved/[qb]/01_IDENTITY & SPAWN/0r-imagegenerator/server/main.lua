local CALLBACK_NAME = '0r-clothing:getClothingUrl:server'
local TRIGGER_EVENT = '0r-clothing:server:triggerCallback'
local RESPONSE_EVENT = '0r-clothing:client:triggerCallback'

local function pickBaseUrl(useDefault)
    if useDefault then
        return Config.DefaultImageBase
    end

    return Config.ImageBase
end

local function safeDebug(msg)
    if Config.Debug then
        print(('[0r-imagegenerator-safe] %s'):format(msg))
    end
end

exports('getClothingUrl', function()
    return pickBaseUrl(false)
end)

exports('getDefaultClothingUrl', function()
    return pickBaseUrl(true)
end)

RegisterNetEvent(TRIGGER_EVENT, function(name, ...)
    if name ~= CALLBACK_NAME then
        return
    end

    local src = source
    local args = { ... }
    local useDefault = args[1] == true
    local imageBase = pickBaseUrl(useDefault)

    safeDebug(('Resolved callback for source %s -> %s'):format(src, imageBase))
    TriggerClientEvent(RESPONSE_EVENT, src, name, imageBase)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    safeDebug('Resource started and callback bridge is active.')
end)
