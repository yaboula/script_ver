bot_Token = "MTAyNDc0ODkxMjg4NTY0MTM2Nw.Gvn5D8.j7lSPOwt_HoBM18DksUF3_Noux9DbXd8TBai2A"
bot_logo = "https://cdn.discordapp.com/attachments/1025789416456867961/1106324039808594011/512x512_Logo.png"
bot_name = "Codem Store"





Config.Description = {
    CodemAdminMenuKill = {
        ['Description'] = 'Kill Player',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuAdminRevive = {
        ['Description'] = 'Revive Player',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuFreeze = {
        ['Description'] = 'Freeze Player',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuSpectate = {
        ['Description'] = 'Spectate Player',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuGoto = {
        ['Description'] = 'Goto Player',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuBring = {
        ['Description'] = 'Bring Player',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuOpenInventory = {
        ['Description'] = 'Open Player Inventory',
        ['DiscordWebhook'] =
        " "

    },
    CodemAdminMenuClearInventory = {
        ['Description'] = 'Clear Player Inventory',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuChangeJob = {
        ['Description'] = 'Change Player Job',
        ['DiscordWebhook'] =
        " "

    },
    CodemAdminMenuGiveItem = {
        ['Description'] = 'Give Item To Player',
        ['DiscordWebhook'] =
        " "

    },
    CodemAdminMenuAddMoney = {
        ['Description'] = 'Add Money To Player',
        ['DiscordWebhook'] =
        " "

    },
    CodemAdminMenuScreenShot = {
        ['Description'] = 'Take Screenshot From Player',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuSendPM = {
        ['Description'] = 'Send PM To Player',
        ['DiscordWebhook'] =
        " "

    },
    CodemAdminMenuGiveClothingMenu = {
        ['Description'] = 'Give Clothing Menu To Player',
        ['DiscordWebhook'] =
        " "

    },
    CodemAdminMenuKick = {
        ['Description'] = 'Kick Player From Server',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuBan = {
        ['Description'] = 'Ban Player From Server',
        ['DiscordWebhook'] =
        " "
    },
    CodemAdminMenuGivePermission = {
        ['Description'] = 'Give Permission To Player',
        ['DiscordWebhook'] =
        " "
    }

}


AddEventHandler('playerDropped', function(reason)
    local src = source
    local identifier = GetIdentifier(src)
    if onlinePlayersData[identifier] then
        onlinePlayersData[identifier] = nil
    end
    local data = playerAdminData[identifier]
    if data then
        data.profiledata.id = nil
    end

    saveDataOnline(src)
end)

AddEventHandler('QBCore:Server:OnPlayerUnload', function(src)
    local identifier = GetIdentifier(src)
    if onlinePlayersData[identifier] then
        onlinePlayersData[identifier] = nil
    end
    local data = playerAdminData[identifier]
    if data then
        data.profiledata.id = nil
    end
    saveDataOnline(src)
end)

AddEventHandler("esx:playerLogout", function(source)
    local src = source
    local identifier = GetIdentifier(src)
    if onlinePlayersData[identifier] then
        onlinePlayersData[identifier] = nil
    end
    local data = playerAdminData[identifier]
    if data then
        data.profiledata.id = nil
    end
    saveDataOnline(src)
end)
