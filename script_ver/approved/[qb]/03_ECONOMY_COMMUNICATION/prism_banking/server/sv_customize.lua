if Config.Framework == 'qb' or Config.Framework == 'qbx' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

local SteamApiKey = '' -- https://steamcommunity.com/dev/apikey (required for steam profile pictures)
local DiscordBotToken = '' -- https://discord.com/developers/applications (required for discord profile pictures)

-- Get player's profile picture URL (discord or steam)
GetPlayerProfile = function(source)
    local result = promise.new()

    if Config.ProfileType == 'discord' then
        local discordId = GetPlayerIdentifierByType(source, 'discord')
        if discordId then
            discordId = discordId:gsub('discord:', '')
        end
        local url = string.format("https://discord.com/api/v10/users/%s", discordId)
        PerformHttpRequest(url, function(statusCode, response)
            if statusCode == 200 then
                local data = json.decode(response)
                if data and data.avatar then
                    local baseUrl = "https://cdn.discordapp.com/avatars/" .. discordId .. "/" .. data.avatar .. ".png"
                    result:resolve(baseUrl)
                else
                    result:resolve('')
                end
            else
                result:resolve('')
            end
        end, "GET", "", {
            ["Authorization"] = "Bot " .. DiscordBotToken,
            ["Content-Type"] = "application/json"
        })

    elseif Config.ProfileType == 'steam' then
        local steamId = GetPlayerIdentifierByType(source, 'steam')
        if steamId then
            steamId = steamId:gsub('steam:', '')
        end
        local steamId64 = tonumber(steamId)
        if not steamId64 then
            result:resolve('')
            return
        end
        local url = string.format("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=%s&steamids=%s", SteamApiKey, steamId64)
        PerformHttpRequest(url, function(statusCode, response)
            if statusCode == 200 then
                local data = json.decode(response)
                if data and data.response and data.response.players and data.response.players[1] and data.response.players[1].avatarfull then
                    result:resolve(data.response.players[1].avatarfull)
                else
                    result:resolve('')
                end
            else
                result:resolve('')
            end
        end, "GET", "", { ["Content-Type"] = "application/json" })
    end

    return Citizen.Await(result)
end

-- Get job label from job name/object
function GetJobLabel(job)
    local p = promise.new()
    if Config.Framework == 'esx' then
        exports.oxmysql:execute('SELECT * FROM jobs WHERE name = ?', { job }, function(result)
            if result and result[1] then
                p:resolve(result[1].label)
            end
        end)
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        p:resolve(job.label)
    end
    return Citizen.Await(p)
end

-- Register a server callback according to framework
RegisterServerCallback = function(name, cb)
    if Config.Framework == 'qb' or Config.Framework == 'qbx' then
        QBCore.Functions.CreateCallback(name, cb)
    elseif Config.Framework == 'esx' then
        ESX.RegisterServerCallback(name, cb)
    end
end

-- Get player's cash on hand
function GetPlayerMoney(src)
    local player = GetPlayer(src)
    if not player then return false end
    local money = (Config.Framework == 'esx') and player.getMoney() or player.PlayerData.money['cash']
    return money
end

-- Send phone notification if enabled
function TriggerPhoneNotification(src, message)
    if not Config.phoneNotification.enabled then return end
    if Config.phoneNotification.phone_resourcename == 'lb_phone' then
        exports["lb-phone"]:EmergencyNotification(src, {
            title = "Transaction Alert",
            content = message,
            icon = "warning",
        })
    end
end

-- Remove money from player (cash or bank)
function RemovePlayerMoney(src, moneyType, amount)
    local player = GetPlayer(src)
    if not player or not moneyType or not amount then return false end
    local reason = Locale.server.bank_transaction
    if Config.Framework == 'esx' then
        if moneyType == 'cash' then
            player.removeMoney(amount, reason)
        elseif moneyType == 'bank' then
            player.removeAccountMoney('bank', amount, reason)
        else
            DebugPrint(('[^3WARN^7] Unknown money type "%s" for ESX'):format(moneyType))
            return false
        end
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        player.Functions.RemoveMoney(moneyType, amount, reason)
    else
        DebugPrint('[^1ERROR^7] Unsupported framework in RemovePlayerMoney')
        return false
    end
    return true
end

-- Add money to player (cash or bank)
function AddPlayerMoney(src, moneyType, amount)
    local player = GetPlayer(src)
    if not player or not moneyType or not amount then return false end
    local reason = Locale.server.bank_transaction
    if Config.Framework == 'esx' then
        if moneyType == 'cash' then
            player.addMoney(amount, reason)
        elseif moneyType == 'bank' then
            player.addAccountMoney('bank', amount, reason)
        else
            DebugPrint(('[^3WARN^7] Unknown money type "%s" for ESX'):format(moneyType))
            return false
        end
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        player.Functions.AddMoney(moneyType, amount, reason)
    else
        DebugPrint('[^1ERROR^7] Unsupported framework in AddPlayerMoney')
        return false
    end
    return true
end

-- Add tax to society (placeholder – implement if needed)
function AddTaxToSociety(amount)
    -- To be implemented per server requirements
end

-- Add card item to player's inventory
function AddItemToInventory(src, cardNumber)
    if Config.CardItemConfig.cardAsItem then
        exports.ox_inventory:AddItem(src, Config.CardItemConfig.cardItemName, 1, { card_no = cardNumber })
    end
end

-- Register a usable item according to framework
function RegisterUsableItem(item, cb)
    if Config.Framework == 'esx' then
        ESX.RegisterUsableItem(item, cb)
    elseif Config.Framework == 'qb' or Config.Framework == 'qbx' then
        QBCore.Functions.CreateUseableItem(item, cb)
    end
end