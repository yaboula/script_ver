RegisterNuiCallback("closeBanking", function(data, callback)
    IsUiOpened = false
    SetNuiFocus(false, false)
    callback({})
end)

RegisterNuiCallback("InitializeTransaction", function(data, callback)
    local transactionResult = AwaitServerCallback(
        "prism-banking:server:InitializeTransaction",
        data.selectedAccount,
        data.transactionType,
        data.amount,
        data.userId
    )

    if transactionResult.success then
        if transactionResult.data then
            SendNUIMessage({
                action = "updateBankingData",
                data = transactionResult.data
            })
        end

        callback({
            success = true,
            data = transactionResult.data
        })
    else
        callback({ success = false })
    end
end)

RegisterNuiCallback("createAccount", function(data, callback)
    local creationResult = AwaitServerCallback(
        "prism-banking:server:createAccount",
        data.pin,
        data.type,
        data.isNew
    )

    if creationResult.success then
        callback(creationResult)
    end
end)

RegisterNuiCallback("toggleSetting", function(data, callback)
    local toggleResult = AwaitServerCallback("prism-banking:server:toggleSetting", data.settingName)

    if toggleResult.success and toggleResult.data then
        SendNUIMessage({
            action = "updateBankingData",
            data = toggleResult.data
        })

        callback({
            success = true,
            data = toggleResult.data
        })
    else
        callback({ success = false })
    end
end)

RegisterNuiCallback("changePin", function(data, callback)
    local pinChangeResult = AwaitServerCallback(
        "prism-banking:server:changePin",
        data.accountNumber,
        data.oldPin,
        data.newPin
    )

    if pinChangeResult.success and pinChangeResult.data then
        SendNUIMessage({
            action = "updateBankingData",
            data = pinChangeResult.data
        })

        callback({
            success = true,
            message = pinChangeResult.message,
            data = pinChangeResult.data
        })
    else
        callback({
            success = false,
            message = pinChangeResult.message
        })
    end
end)

RegisterNuiCallback("upgradeWithdrawalLevel", function(data, callback)
    local upgradeResult = AwaitServerCallback("prism-banking:server:upgradeWithdrawalLevel")

    if upgradeResult.success and upgradeResult.data then
        SendNUIMessage({
            action = "updateBankingData",
            data = upgradeResult.data
        })

        callback({
            success = true,
            message = upgradeResult.message,
            data = upgradeResult.data
        })
    else
        callback({
            success = false,
            message = upgradeResult.message
        })
    end
end)

RegisterNuiCallback("upgradeAccountLevel", function(data, callback)
    local upgradeResult = AwaitServerCallback("prism-banking:server:upgradeAccountLevel")

    if upgradeResult.success and upgradeResult.data then
        SendNUIMessage({
            action = "updateBankingData",
            data = upgradeResult.data
        })

        callback({
            success = true,
            message = upgradeResult.message,
            data = upgradeResult.data
        })
    else
        callback({
            success = false,
            message = upgradeResult.message
        })
    end
end)

RegisterNuiCallback("allowedtoCreateAccount", function(data, callback)
    local canCreate = AwaitServerCallback("prism-banking:server:allowedtoCreateAccount")
    callback({ success = canCreate })
end)

RegisterNuiCallback("reIssueCard", function(data, callback)
    local reissueSuccess = AwaitServerCallback("prism-banking:server:reIssueCard", data.accountNumber)
    callback({ success = reissueSuccess })
end)

RegisterNuiCallback("bankingshowNotification", function(data, callback)
    TriggerNotification(data.title, data.message)
    callback({ success = true })
end)

RegisterNuiCallback("getNominees", function(data, callback)
    local nominees = AwaitServerCallback("prism-banking:server:getNominees", data.accountNumber)
    callback(nominees)
end)

RegisterNuiCallback("addNominee", function(data, callback)
    local addResult = AwaitServerCallback(
        "prism-banking:server:addNominee",
        data.accountNumber,
        data.targetServerId
    )
    callback(addResult)
end)

RegisterNuiCallback("removeNominee", function(data, callback)
    local removeResult = AwaitServerCallback(
        "prism-banking:server:removeNominee",
        data.accountNumber,
        data.nomineeId
    )
    callback(removeResult)
end)

RegisterNetEvent("prism-banking:client:refreshBankingData", function()
    if not IsUiOpened then
        return
    end

    local accountsData = AwaitServerCallback("prism-banking:server:getAccounts")

    if accountsData then
        SendNUIMessage({
            action = "updateBankingData",
            data = accountsData
        })
    end
end)