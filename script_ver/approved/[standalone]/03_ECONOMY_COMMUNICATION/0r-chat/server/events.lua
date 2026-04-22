RegisterNetEvent("chat:init")
RegisterNetEvent("chat:addTemplate")
RegisterNetEvent("chat:addMessage")
RegisterNetEvent("chat:addSuggestion")
RegisterNetEvent("chat:removeSuggestion")
RegisterNetEvent("_chat:messageEntered")
RegisterNetEvent("chat:clear")
RegisterNetEvent("__cfx_internal:commandFallback")

local CLIENT_CALLBACK_ALLOWLIST = {
    ["0r-chat:getCommands"] = true,
    ["0r-chat:registerRPText"] = true,
    ["0r-chat:RollTheDice"] = true,
    ["0r-chat:RPS"] = true,
    ["0r-chat:updateNameValue"] = true,
    ["0r-chat:updateMeDoPP"] = true,
    ["0r-chat:sendBalanceInfoMessage"] = true,
}

local function sanitizeHexColor(value, fallback)
    if type(value) ~= "string" then
        return fallback
    end

    local color = value:upper()
    if color:match("^#%x%x%x%x%x%x$") then
        return color
    end

    return fallback
end

local function sanitizeTag(value)
    if type(value) ~= "string" then
        return ""
    end

    local tag = value:gsub("[%c]", "")
    tag = tag:gsub("[<>]", "")
    if #tag > 16 then
        tag = tag:sub(1, 16)
    end

    return tag
end

local function sanitizeMediaUrl(value)
    if type(value) ~= "string" then
        return ""
    end

    local url = value:gsub("[%c]", "")
    if #url > 512 then
        url = url:sub(1, 512)
    end

    if url == "" then
        return ""
    end

    if url:match("^https?://") or url:match("^data:image/") or url:match("^nui://") then
        return url
    end

    return ""
end

AddEventHandler("playerDropped", function()
local src = source
    if gMusics[src] then
        gMusics[src] = false
        TriggerClientEvent("0r-chat:DestroyMusic", src, src)
    end
    TriggerClientEvent("0r-chat:Client:SyncIsWriting", -1, src, false)
end)

RegisterNetEvent("0r-chat:Server:SyncIsWriting", function(state)
local src = source

    TriggerClientEvent("0r-chat:Client:SyncIsWriting", -1, src, state)
end)

Koci.Server:RegisterServerCallback("0r-chat:getCommands", function(source, data, cb)
local commandList = {}
    for _, command in ipairs(GetRegisteredCommands()) do
        if IsPlayerAceAllowed(source, ("command.%s"):format(command.name)) then
            table.insert(commandList, {
                name = command.name,
                description = command.description or "..."
            })
        end
    end
    cb(commandList)
end)

Koci.Server:RegisterServerCallback("0r-chat:registerRPText", function(source, data, cb)
local src = source
    if type(data) ~= "table" then
        cb(false)
        return
    end

    if type(data.type) ~= "string" or #data.type > 16 then
        cb(false)
        return
    end

    if type(data.text) ~= "string" then
        cb(false)
        return
    end

    data.text = data.text:gsub("^%s+", ""):gsub("%s+$", "")
    if #data.text == 0 or #data.text > 240 then
        cb(false)
        return
    end

    if type(data.haveMask) ~= "boolean" then
        data.haveMask = false
    end

    data.sourceId = src
    if type(data.channel) ~= "string" or #data.channel > 32 then
        data.channel = "local"
    end

    data.color = sanitizeHexColor(data.color, "#FFFFFF")
    data.borderColor = sanitizeHexColor(data.borderColor, "#FFFFFF")

local xPlayer = Koci.Server:GetPlayer(src)
    if not xPlayer then
        cb(false)
        return
    end

    xPlayer.name = (Koci.FrameworkName == "esx") and xPlayer.name or
        (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)

local _editedNameData = Koci.Server.Players[src] and Koci.Server.Players[src].editedName or nil
    if _editedNameData and _editedNameData.tag and type(_editedNameData.tag) == "string" then
        xPlayer.name = xPlayer.name .. " " .. _editedNameData.tag
    end
local _meDoPP = Koci.Server.Players[src] and Koci.Server.Players[src].meDoPP or ""

    if Config.AnonymousWithMask and data.haveMask then
        xPlayer.name = "Anonymous"
    end

    for _, player in ipairs(GetPlayers()) do
        if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(player))) < 10 then
            TriggerClientEvent("0r-chat:registerRPText", player, {
                source = src,
                type = data.type,
                text = data.text,
                meDoPP = _meDoPP,
                message = {
                    type = data.type,
                    color = data.color,
                    borderColor = data.borderColor,
                    header = xPlayer.name,
                    args = { data.text },
                    sourceId = data.sourceId,
                    channel = data.channel,
                },
                timeout = 7000
            })
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:RollTheDice", function(source, data, cb)
local src = source
    if type(data) ~= "table" or type(data.diceValue) ~= "number" then
        cb(false)
        return
    end

local diceValue = math.floor(data.diceValue)
    if diceValue < 1 or diceValue > 6 then
        cb(false)
        return
    end

local xPlayer = Koci.Server:GetPlayer(src)
    if not xPlayer then
        cb(false)
        return
    end

    xPlayer.name = (Koci.FrameworkName == "esx") and xPlayer.name or
        (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)

local _editedNameData = Koci.Server.Players[src] and Koci.Server.Players[src].editedName or nil
    if _editedNameData and _editedNameData.tag and type(_editedNameData.tag) == "string" then
        xPlayer.name = xPlayer.name .. " " .. _editedNameData.tag
    end

    if Config.AnonymousWithMask and data.haveMask then
        xPlayer.name = "Anonymous"
    end

    for _, player in ipairs(GetPlayers()) do
        if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(player))) < 10 then
            TriggerClientEvent("0r-chat:registerRPText", player, {
                source = src,
                type = "roll-the-dice",
                text = "roll-the-dice",
                diceValue = diceValue,
                message = {
                    type = "roll-the-dice",
                    color = nil,
                    borderColor = nil,
                    header = xPlayer.name,
                    args = { "roll-the-dice" },
                    sourceId = src,
                    channel = "local",
                    specialMessage = "roll-the-dice",
                    diceValue = diceValue
                },
                timeout = 7000
            })
        end
    end
    cb(true)
end)

Koci.Server:RegisterServerCallback("0r-chat:RPS", function(source, data, cb)
local src = source
    if type(data) ~= "table" or type(data.rpsValue) ~= "string" then
        cb(false)
        return
    end

local validRpsValues = {
        rock = true,
        paper = true,
        scissors = true,
    }

    if not validRpsValues[data.rpsValue] then
        cb(false)
        return
    end

local xPlayer = Koci.Server:GetPlayer(src)
    if not xPlayer then
        cb(false)
        return
    end

    xPlayer.name = (Koci.FrameworkName == "esx") and xPlayer.name or
        (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)

local _editedNameData = Koci.Server.Players[src] and Koci.Server.Players[src].editedName or nil
    if _editedNameData and _editedNameData.tag and type(_editedNameData.tag) == "string" then
        xPlayer.name = xPlayer.name .. " " .. _editedNameData.tag
    end

    if Config.AnonymousWithMask and data.haveMask then
        xPlayer.name = "Anonymous"
    end

    for _, player in ipairs(GetPlayers()) do
        if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(player))) < 10 then
            TriggerClientEvent("0r-chat:registerRPText", player, {
                source = src,
                type = "rps",
                text = "rps",
                rpsValue = data.rpsValue,
                message = {
                    type = "rps",
                    color = nil,
                    borderColor = nil,
                    header = xPlayer.name,
                    args = { "rps" },
                    sourceId = src,
                    channel = "local",
                    specialMessage = "rps",
                    rpsValue = data.rpsValue
                },
                timeout = 7000
            })
        end
    end
    cb(true)
end)

Koci.Server:RegisterServerCallback("0r-chat:showIdentity", function(source, data, cb)
    for _, player in ipairs(GetPlayers()) do
        if #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(player))) < 3 then
            TriggerClientEvent("chat:addMessage", player, {
                type = data.type,
                color = data.color,
                borderColor = data.borderColor,
                header = data.header,
                args = { data.text },
                sourceId = data.sourceId,
                channel = data.channel,
            })
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:sendJobMessages", function(source, data, cb)
    if type(data) ~= "table" or type(data.message) ~= "table" then
        cb(false)
        return
    end

    if type(data.message.type) ~= "string" or #data.message.type > 32 then
        cb(false)
        return
    end

    if type(data.message.header) ~= "string" or #data.message.header > 64 then
        cb(false)
        return
    end

    if type(data.message.text) ~= "string" or #data.message.text > 240 then
        cb(false)
        return
    end

    if type(data.message.color) ~= "string" then
        data.message.color = "#FFFFFF"
    end

    if type(data.message.borderColor) ~= "string" then
        data.message.borderColor = "#FFFFFF"
    end

    data.message.color = sanitizeHexColor(data.message.color, "#FFFFFF")
    data.message.borderColor = sanitizeHexColor(data.message.borderColor, "#FFFFFF")

    if type(data.channel) ~= "string" or #data.channel > 32 then
        data.channel = "local"
    end

    if type(data.sourceId) ~= "number" then
        data.sourceId = source
    end

local hasJobFilter = type(data.job) == "string" and #data.job > 0
local hasJobsFilter = type(data.jobs) == "table"

    if not hasJobFilter and not hasJobsFilter then
        cb(false)
        return
    end

    for _, playerId in ipairs(GetPlayers()) do
local player = Koci.Server:GetPlayer(tonumber(playerId))
local job = (Koci.FrameworkName == "esx") and player.job or player.PlayerData.job
        if player then
            if hasJobFilter and job.name ~= data.job then
                goto continue
            end

            if hasJobsFilter and not data.jobs[job.name] then
                goto continue
            end

            TriggerClientEvent("chat:addMessage", playerId, {
                type = data.message.type,
                color = data.message.color,
                borderColor = data.message.borderColor,
                header = data.message.header,
                args = { data.message.text },
                sourceId = data.sourceId,
                channel = data.channel,
            })

            ::continue::
        end
    end

    cb(true)
end)

Koci.Server:RegisterServerCallback("0r-chat:getCharacterInfo", function(source, data, cb)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
local _PlayerData = {
        job = (Koci.FrameworkName == "esx") and xPlayer.job or xPlayer.PlayerData.job,
        name = (Koci.FrameworkName == "esx") and xPlayer.name or
            (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname),
        birth = (Koci.FrameworkName == "esx") and xPlayer.get("dateofbirth") or xPlayer.PlayerData.charinfo.birthdate,
        gender = (Koci.FrameworkName == "esx") and xPlayer.get("sex") or xPlayer.PlayerData.gender,
        accounts = {
            bank = (Koci.FrameworkName == "esx") and xPlayer.getAccount("bank").money or xPlayer.PlayerData.money.bank,
            cash = (Koci.FrameworkName == "esx") and xPlayer.getAccount("money").money or xPlayer.PlayerData.money.cash,
        },
    }
local _editedNameData = Koci.Server.Players[src] and Koci.Server.Players[src].editedName or nil
    if _editedNameData and _editedNameData.tag and type(_editedNameData.tag) == "string" then
        _PlayerData.name = _PlayerData.name .. " " .. _editedNameData.tag
    end
    cb(_PlayerData)
end)

Koci.Server:RegisterServerCallback("0r-chat:sendWhisperMessage", function(source, data, cb)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
local targetPlayer = Koci.Server:GetPlayer(tonumber(data.target))

    if xPlayer and targetPlayer then
        xPlayer.name = (Koci.FrameworkName == "esx") and xPlayer.name or
            (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)
local _editedNameData = Koci.Server.Players[src] and Koci.Server.Players[src].editedName or nil
        if _editedNameData and _editedNameData.tag and type(_editedNameData.tag) == "string" then
            xPlayer.name = xPlayer.name .. " " .. _editedNameData.tag
        end

        if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(tonumber(data.target)))) < 3 then
            TriggerClientEvent("chat:addMessage", src, {
                type = data.message.type,
                color = data.color,
                borderColor = data.borderColor,
                header = xPlayer.name,
                args = { data.message.text },
                sourceId = data.sourceId,
                channel = data.channel,
            })

            TriggerClientEvent("chat:addMessage", data.target, {
                type = data.message.type,
                color = data.color,
                borderColor = data.borderColor,
                header = xPlayer.name,
                args = { data.message.text },
                sourceId = data.sourceId,
                channel = data.channel,
            })
        end
    else
        TriggerClientEvent("chat:addMessage", src, {
            type = "ERROR",
            color = data.color,
            borderColor = data.borderColor,
            header = "SYSTEM ERROR",
            args = { "An error occured while trying to gather character information!" },
            channel = data.channel,
        })
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:sendMessages", function(source, data, cb)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)

    if xPlayer then
        xPlayer.name = (Koci.FrameworkName == "esx") and xPlayer.name or
            (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)
local _editedNameData = Koci.Server.Players[src] and Koci.Server.Players[src].editedName or nil
        if _editedNameData and _editedNameData.tag and type(_editedNameData.tag) == "string" then
            xPlayer.name = xPlayer.name .. " " .. _editedNameData.tag
        end

local global = data.global

        if global then
            for _, player in ipairs(GetPlayers()) do
                TriggerClientEvent("chat:addMessage", player, {
                    type = data.type,
                    color = data.color,
                    borderColor = data.borderColor,
                    header = xPlayer.name,
                    args = { data.text },
                    sourceId = data.sourceId,
                    channel = data.channel,
                })
            end
        else
            for _, player in ipairs(GetPlayers()) do
                if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(player))) < 10 then
                    TriggerClientEvent("chat:addMessage", player, {
                        type = data.type,
                        color = data.color,
                        borderColor = data.borderColor,
                        header = xPlayer.name,
                        args = { data.text },
                        sourceId = data.sourceId,
                        channel = data.channel,
                    })
                end
            end
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:sendYellowPages", function(source, data, cb)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
local PlayerBankBalance = Koci.FrameworkName == "esx" and xPlayer.getAccount("bank").money or
        xPlayer.PlayerData.money.bank
    if xPlayer then
        xPlayer.name = (Koci.FrameworkName == "esx") and xPlayer.name or
            (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)
local _editedNameData = Koci.Server.Players[src] and Koci.Server.Players[src].editedName or nil
        if _editedNameData and _editedNameData.tag and type(_editedNameData.tag) == "string" then
            xPlayer.name = xPlayer.name .. " " .. _editedNameData.tag
        end
        if PlayerBankBalance >= Config.YellowPageFee then
            if Koci.FrameworkName == "esx" then
                xPlayer.removeAccountMoney("bank", Config.YellowPageFee)
            elseif Koci.FrameworkName == "qb" then
                xPlayer.Functions.RemoveMoney("bank", Config.YellowPageFee)
            end
            for _, player in ipairs(GetPlayers()) do
                TriggerClientEvent("chat:addMessage", player, {
                    type = data.type,
                    color = data.color,
                    borderColor = data.borderColor,
                    header = xPlayer.name,
                    args = { data.text },
                    sourceId = data.sourceId,
                    channel = data.channel,
                })
            end
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:sendAdminMessages", function(source, data, cb)
local src = source
    if IsPlayerAceAllowed(src, "command") then
        for _, player in ipairs(GetPlayers()) do
            if IsPlayerAceAllowed(player, "command") then
                TriggerClientEvent("chat:addMessage", player, {
                    type = data.type,
                    color = data.color,
                    borderColor = data.borderColor,
                    header = data.header,
                    args = { data.text },
                    sourceId = data.sourceId,
                    channel = data.channel,
                })
            end
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:sendAdminAnnounce", function(source, data, cb)
local src = source
    if IsPlayerAceAllowed(src, "command") then
        for _, player in ipairs(GetPlayers()) do
            TriggerClientEvent("chat:addMessage", player, {
                type = data.type,
                color = data.color,
                borderColor = data.borderColor,
                header = data.header,
                args = { data.text },
                sourceId = data.sourceId,
                channel = data.channel,
            })
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:playMusicWithUrl", function(source, data)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
local data = {
        url = data.url,
        isPaused = false,
        volume = 0.5,
    }
    if xPlayer and data.url then
        if not gMusics[src] then
            gMusics[src] = {}
        else
            data.volume = gMusics[src].volume
        end
        gMusics[src] = data
        TriggerClientEvent("0r-chat:SynchronizeMusics", src, data, src)
    else
        TriggerClientEvent("chat:addMessage", source, {
            type = "ERROR",
            color = Config.TypeColors["error"].color,
            borderColor = Config.TypeColors["error"].background,
            header = "SYSTEM ERROR",
            args = { "An error occured. Music Url !" },
            channel = "server",
        })
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:stopMusic", function(source)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
    if xPlayer then
        if gMusics[src] then
            gMusics[src] = nil
            TriggerClientEvent("0r-chat:DestroyMusic", -1, src)
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:setMusicVolume", function(source, data)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
    if xPlayer then
        if gMusics[src] then
local volume = data.volume >= 1 and data.volume / 100 or data.volume
            gMusics[src].volume = volume
            TriggerClientEvent("0r-chat:SynchronizeMusics", src, gMusics[src], src)
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:updateNameValue", function(source, data)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
    if type(data) ~= "table" then
        return
    end

local sanitizedNameData = {
        color = sanitizeHexColor(data.color, "#FFF"),
        tag = sanitizeTag(data.tag),
    }

    if xPlayer then
        if Koci.Server.Players[src] then
            Koci.Server.Players[src].editedName = sanitizedNameData
        else
            Koci.Server.Players[src] = {
                editedName = sanitizedNameData,
                meDoPP = nil
            }
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:updateMeDoPP", function(source, data)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
local mediaUrl = sanitizeMediaUrl(data)

    if xPlayer then
        if Koci.Server.Players[src] then
            Koci.Server.Players[src].meDoPP = mediaUrl
        else
            Koci.Server.Players[src] = {
                editedName = nil,
                meDoPP = mediaUrl
            }
        end
    end
end)

Koci.Server:RegisterServerCallback("0r-chat:sendBalanceInfoMessage", function(source)
local src = source
local xPlayer = Koci.Server:GetPlayer(src)
    if xPlayer then
local PlayerName = (Koci.FrameworkName == "esx") and
            xPlayer.getName() or
            (xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname)

local bankBalance = Koci.Server:GetPlayerBalance("bank", xPlayer)
local moneyBalance = Koci.Server:GetPlayerBalance("cash", xPlayer)

        TriggerClientEvent("0r-chat:BalanceInfoMessage", src, {
            sourceId = src,
            header = PlayerName,
            balance = {
                bank = bankBalance,
                money = moneyBalance
            }
        })
    end
end)

RegisterNetEvent("0r-chat:Server:HandleCallback", function(key, payload)
local src = source
    if type(key) ~= "string" or not CLIENT_CALLBACK_ALLOWLIST[key] then
        return
    end

    if Koci.Callbacks[key] then
        Koci.Callbacks[key](src, payload, function(cb)
            TriggerClientEvent("0r-chat:Client:HandleCallback", src, key, cb)
        end)
    end
end)
