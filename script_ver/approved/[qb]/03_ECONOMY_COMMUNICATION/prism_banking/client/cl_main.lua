IsUiOpened = false
isTextUIOpen = false

function SpawnBankPeds()
    if not Config.Peds.enabled then
        return
    end

    RequestModel(Config.Peds.pedModel)

    while not HasModelLoaded(Config.Peds.pedModel) do
        Wait(100)
    end

    for _, bankData in pairs(Config.Banks) do
        local bankPed = CreatePed(
            4,
            Config.Peds.pedModel,
            bankData.pedCoords.x,
            bankData.pedCoords.y,
            bankData.pedCoords.z,
            bankData.pedCoords.w,
            false,
            true
        )

        SetEntityAsMissionEntity(bankPed, true, true)
        FreezeEntityPosition(bankPed, true)
        SetEntityInvincible(bankPed, true)
        SetBlockingOfNonTemporaryEvents(bankPed, true)
    end
end

function CreateBankBlips()
    if not Config.EnableBlips then
        return
    end

    for _, bankData in pairs(Config.Banks) do
        local bankBlip = AddBlipForCoord(bankData.InteractionCoords)

        SetBlipSprite(bankBlip, Config.BlipConfig.sprite)
        SetBlipColour(bankBlip, Config.BlipConfig.color)
        SetBlipScale(bankBlip, Config.BlipConfig.size)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(bankData.bankName)
        EndTextCommandSetBlipName(bankBlip)
        SetBlipAsShortRange(bankBlip, true)
    end
end

function InteractionThread()
    CreateThread(function()
        while true do
            local sleep = 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local isNearBank = false

            if not IsUiOpened then
                for _, bankData in pairs(Config.Banks) do
                    local distance = #(playerCoords - bankData.InteractionCoords)

                    if distance <= Config.InteractionDistance then
                        isNearBank = true
                        sleep = 0

                        if Config.Interaction == "textui" then
                            if not isTextUIOpen then
                                isTextUIOpen = true
                                lib.showTextUI(Locale.client.open_bank)
                            end

                            if IsControlJustReleased(0, 38) then
                                TriggerEvent("prism-banking:client:openBank")
                            end
                            break
                        elseif Config.Interaction == "drawtext" then
                            Draw3DText(bankData.InteractionCoords, Locale.client.open_bank)

                            if IsControlJustReleased(0, 38) then
                                TriggerEvent("prism-banking:client:openBank")
                            end
                            break
                        end
                    end
                end

                if not isNearBank and isTextUIOpen then
                    isTextUIOpen = false
                    lib.hideTextUI()
                end
            else
                if isTextUIOpen then
                    isTextUIOpen = false
                    lib.hideTextUI()
                end
            end

            Wait(sleep)
        end
    end)
end

function OpenBankUI(isNewAccount, accountsData)
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "openBanking",
        data = {
            isNew = isNewAccount,
            main = accountsData,
            Locale = Locale.UI
        }
    })
end

function OpenAtmUI(accounts, mainAccount)
    IsUiOpened = true
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "openAtm",
        data = {
            accounts = accounts,
            main = mainAccount,
            isAtm = true,
            Locale = Locale.UI
        }
    })
end

function SendNuiNotification(title, message)
    SendNUIMessage({
        action = "sendNotification",
        data = {
            title = title,
            msg = message
        }
    })
end

RegisterNetEvent("prism-banking:client:sendNotification", function(title, message)
    SendNuiNotification(title, message)
end)

RegisterNetEvent("prism-bannking:client:notify", function(title, message)
    TriggerNotification(title, message)
end)

RegisterNetEvent("prism-banking:client:OnPlayerLoaded", function()
    CreateThread(function()
        if Config.Interaction == "target" then
            for _, bankData in pairs(Config.Banks) do
                RegisterBankTarget(bankData.InteractionCoords)
            end
            RegisterATMTargets()
        else
            InteractionThread()
            InteractionThreadATM()
        end

        SpawnBankPeds()
        CreateBankBlips()
    end)
end)

RegisterNetEvent("prism-banking:client:openBank", function()
    local accountsData = AwaitServerCallback("prism-banking:server:getAccounts")
    local hasNoAccounts = #accountsData.accounts == 0
    local isRestartImminent = AwaitServerCallback("prism-banking:server:isServerRestartImminent")

    if isRestartImminent then
        TriggerNotification(Locale.client.banking, Locale.client.banking_servers_down)
        return
    end

    IsUiOpened = true
    OpenBankUI(hasNoAccounts, accountsData)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        TriggerEvent("prism-banking:client:OnPlayerLoaded")
        TriggerServerEvent("prism-banking:server:onPlayerLoaded")
    end
end)