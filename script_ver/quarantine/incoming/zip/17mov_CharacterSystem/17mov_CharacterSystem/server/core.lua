local serverCallbacks = {}

function Functions.RegisterServerCallback(callbackName, callbackFunction)
    serverCallbacks[callbackName] = callbackFunction
end

local getResponseEventName = "17mov_Callbacks:GetResponse" .. Functions.ResourceName
RegisterNetEvent(getResponseEventName, function(callbackName, responseIdentifier, ...)
    local playerSource = source
    local callbackHandler = serverCallbacks[callbackName]

    if callbackHandler == nil then
        return
    end

    local results = { callbackHandler(playerSource, ...) }

    local receiveDataEventName = "17mov_Callbacks:receiveData" .. Functions.ResourceName
    TriggerClientEvent(receiveDataEventName, playerSource, callbackName, responseIdentifier, table.unpack(results))
end)

CreateThread(function()
    local currentResourcePath = GetResourcePath(GetCurrentResourceName())
    while true do
        for resourceName, shouldBeDisabled in pairs(Config.ResourcesToDisable) do
            if shouldBeDisabled then
                local resourceState = GetResourceState(resourceName)
                local resourcePath = GetResourcePath(resourceName)

                if resourcePath ~= currentResourcePath and resourceState == "started" then
                    Functions.Print(resourceName .. " is started. 17mov_CharacterSystem cannot work together with it. Please stop it")
                end
            end
        end
        Citizen.Wait(1000)
    end
end)