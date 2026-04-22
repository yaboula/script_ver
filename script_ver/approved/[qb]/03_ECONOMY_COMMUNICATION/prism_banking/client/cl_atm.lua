local nearbyAtmLocations = {}
isAtmPinEntryOpen = false

function FindNearbyATMs()
    if not Config.ATMs.enabled then
        return {}
    end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local foundAtms = {}

    for _, atmProp in ipairs(Config.ATMs.props) do
        local atmObject = GetClosestObjectOfType(
            playerCoords.x, 
            playerCoords.y, 
            playerCoords.z, 
            Config.ATMs.interactionDistance, 
            atmProp, 
            false, 
            false, 
            false
        )

        if atmObject ~= 0 then
            local atmCoords = GetEntityCoords(atmObject)
            table.insert(foundAtms, atmCoords)
        end
    end

    return foundAtms
end

function InteractionThreadATM()
    CreateThread(function()
        while true do
            if not Config.ATMs.enabled then
                break
            end

            if Config.CardItemConfig.cardAsItem then
                break
            end

            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            if not isAtmPinEntryOpen and not IsUiOpened then
                nearbyAtmLocations = FindNearbyATMs()

                if #nearbyAtmLocations > 0 then
                    sleep = 0
                    local nearestAtm = nearbyAtmLocations[1]

                    if Config.Interaction == "textui" then
                        if not isTextUIOpen then
                            isTextUIOpen = true
                            lib.showTextUI(Locale.client.open_atm or "[E] Access ATM")
                        end

                        if IsControlJustReleased(0, 38) then
                            OpenATM()
                        end
                    elseif Config.Interaction == "drawtext" then
                        Draw3DText(nearestAtm, Locale.client.open_atm or "[E] Access ATM")

                        if IsControlJustReleased(0, 38) then
                            OpenATM()
                        end
                    end
                else
                    if isTextUIOpen and Config.Interaction == "textui" then
                        isTextUIOpen = false
                        lib.hideTextUI()
                    end
                end
            else
                if isTextUIOpen and Config.Interaction == "textui" then
                    isTextUIOpen = false
                    lib.hideTextUI()
                end
            end

            Wait(sleep)
        end
    end)
end

function OpenATM(accountNumbers)
    local isRestartImminent = AwaitServerCallback("prism-banking:server:isServerRestartImminent")

    if isRestartImminent then
        TriggerNotification(Locale.client.banking, Locale.client.atm_servers_down)
        return
    end

    isAtmPinEntryOpen = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "openAtmPinVerification",
        data = {
            accountNumbers = accountNumbers or {},
            primaryColor = Config.PrimaryColor
        }
    })
end

RegisterNuiCallback("closeBanking", function(data, callback)
    isAtmPinEntryOpen = false
    IsUiOpened = false
    SetNuiFocus(false, false)
    callback({})
end)

RegisterNuiCallback("verifyAtmPin", function(data, callback)
    local enteredPin = data.pin
    local accountNumbers = data.accountNumbers
    local targetAccount = nil

    if #accountNumbers == 1 then
        targetAccount = accountNumbers[1]
    end

    local verificationResult = AwaitServerCallback("prism-banking:server:verifyAtmPin", enteredPin, targetAccount)

    if verificationResult.success then
        local accountsData = AwaitServerCallback("prism-banking:server:getAtmAccounts", accountNumbers or {})

        if accountsData.success then
            OpenAtmUI(accountsData.accounts, accountsData.main)
            callback({ success = true })
        else
            callback({
                success = false,
                message = Locale.server.failed_to_load_account
            })
        end
    else
        callback({
            success = false,
            message = verificationResult.message or Locale.server.incorrect_pin
        })
    end
end)