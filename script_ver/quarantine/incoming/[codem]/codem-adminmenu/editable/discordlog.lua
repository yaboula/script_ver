function sendDiscordLogCraft(data)
    local header = false
    if data.type == 'success' then
        header = 'Codem Craftv2 - Item-Craft || Success'
    elseif data.type == 'error' then
        header = 'Codem Craftv2 - Item-Craft || Error'
    elseif data.type == 'cancel' then
        header = 'Codem Craftv2 - Item-Craft || Cancel'
    end


    local message = {
        username = bot_name,
        embeds = {
            {
                title = botname,
                color = 0xFFA500,
                author = {
                    name = header,
                },
                thumbnail = {
                    url = data.avatar
                },
                fields = {
                    { name = "Player Name", value = data.name or false, inline = true },
                    { name = "Player ID",   value = data.id or false,   inline = true },
                    {
                        name = "──────────Craft Information──────────",
                        value = "",
                        inline = false
                    },
                    { name = "Item Name",   value = data.itemname or false,          inline = true },
                    { name = "Item Label", value = data.itemlabel or 'undefined',   inline = true },
                    { name = "Craft Type",  value = data.type  or 'undefined', inline = true },

                },
                footer = {
                    text = "Codem Store - https://discord.gg/zj3QsUfxWs",
                    icon_url =
                    "https://cdn.discordapp.com/attachments/1025789416456867961/1106324039808594011/512x512_Logo.png"
                },

                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        },
        avatar_url = bot_logo
    }
    if data.type == 'cancel' then
        PerformHttpRequest(discord_webhook['cancel'], function(err, text, headers) end,
        "POST",
        json.encode(message),
        { ["Content-Type"] = "application/json" })
    else
        PerformHttpRequest(discord_webhook['itemcraft'], function(err, text, headers) end,
        "POST",
        json.encode(message),
        { ["Content-Type"] = "application/json" })
    end
end

function sendDiscordLogDismantle(data)
    local message = {
        username = bot_name,
        embeds = {
            {
                title = botname,
                color = 0xFFA500,
                author = {
                    name = 'Codem Craftv2 - Item-Craft || Dismantled',
                },
                thumbnail = {
                    url = data.avatar
                },
                fields = {
                    { name = "Player Name", value = data.name or false, inline = true },
                    { name = "Player ID",   value = data.id or false,   inline = true },
                    {
                        name = "──────────Craft Information──────────",
                        value = "",
                        inline = false
                    },
                    { name = "Dismantle Item",   value = data.itemname or false,          inline = true },
                    { name = "Item Label", value = data.itemlabel or 'undefined',   inline = true },
                    { name = "Add Item", value = table.concat(data.requiredItems, ', ') or 'undefined', inline = true },
                },
                footer = {
                    text = "Codem Store - https://discord.gg/zj3QsUfxWs",
                    icon_url =
                    "https://cdn.discordapp.com/attachments/1025789416456867961/1106324039808594011/512x512_Logo.png"
                },

                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        },
        avatar_url = bot_logo
    }

    PerformHttpRequest(discord_webhook['dismantle'], function(err, text, headers) end,
        "POST",
        json.encode(message),
        { ["Content-Type"] = "application/json" })
end