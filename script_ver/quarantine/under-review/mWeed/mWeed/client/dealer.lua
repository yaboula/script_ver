function OpenDealerMenu()
    WaitNUI()
    SendNUIMessage({
        action = 'OPEN_DEALER',
        payload = {
          sellableItems = Config.Dealer.sellableItems,
          buyableItems = Config.Dealer.buyableItems,
          name = Config.Dealer.name,
        }
    })
    isMenuOpen.dealer = true
    SetNuiFocus(true, true)
    RefreshPlayerCash()
    RefreshPlayerInventory()
end

RegisterNUICallback('buy', function(data, cb)
    local cart = data.cart
    local success = TriggerCallback('mWeed:buyItem', cart)
    cb(success)
end)

RegisterNUICallback('sell', function(data, cb)
    local cart = data.cart
    local success = TriggerCallback('mWeed:sellItem', cart)
    cb(success)
end)

RegisterNetEvent('mWeed:OpenDealerMenu')
AddEventHandler('mWeed:OpenDealerMenu', function()
    OpenDealerMenu()
end)