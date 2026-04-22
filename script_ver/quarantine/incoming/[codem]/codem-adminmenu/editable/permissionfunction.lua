local frozenPlayers = {}
AdminFunctions = {
    CodemAdminMenuGetPlayerBlackMoney = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            local inventory = GetPlayerInventory(src)
            for k, v in pairs(inventory) do
                if v.name == 'black_money' or v.name == 'markedbills' then
                    return v.amount
                end
            end
            return 0
        end
    end,
    CodemAdminMenuGetPlayerCoin = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            if Config.CodemVipSystem then
                local result = exports["m-vipsystem"]:getPlayerVipMoney(source)
                return result or 0
            else
                return 0
            end
        end
    end,
    CodemAdminMenuAdminRevive = function(playerId)
        playerId = tonumber(playerId)
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            local xPlayer = GetPlayer(playerId)
            if xPlayer then
                TriggerClientEvent('esx_ambulancejob:revive', playerId)
            end
        else
            local xPlayer = GetPlayer(playerId)
            if xPlayer then
                TriggerClientEvent('hospital:client:Revive', playerId)
            end
        end
    end,
    CodemAdminMenuInvisible = function(playerId)
        TriggerClientEvent("codem-adminmenu:setInvinsible", playerId)
    end,
    CodemAdminMenuGiveVehicle = function(playerId, val)
        TriggerClientEvent('codem-adminmenu:spawnCar', playerId, val)
    end,
    CodemAdminMenuGiveVehicleToPlayer = function(playerId, val)
        giveVehicleDatabase(val.id, val.name)
    end,
    CodemAdminMenuClearArea = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            local xTarget = GetPlayerPed(src)
            local coords = GetEntityCoords(xTarget)
            TriggerClientEvent('codem-adminmenu:clearArea', -1, coords)
        end
    end,
    CodemAdminMenuPlayerName = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:showPlayerName', playerId)
        end
    end,

    CodemAdminMenuNoclip = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:toggleNoclip', playerId)
        end
    end,
    CodemAdminMenuCopyVector = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:copyVector', playerId)
        end
    end,
    CodemAdminMenuCopyVector4 = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:copyVector4', playerId)
        end
    end,
    CodemAdminMenuCopyXYZ = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:copyXYZ', playerId)
        end
    end,
    CodemAdminMenuCopyHeading = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:copyHeading', playerId)
        end
    end,
    CodemAdminMenuShowCoords = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:toggleCoords', playerId)
        end
    end,
    CodemAdminMenuDevLaser = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:devLaser', playerId)
        end
    end,

    CodemAdminMenuGodmode = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:setGodmode', playerId)
        end
    end,
    CodemAdminMenuAdminHeal = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:healPlayer', playerId)
        end
    end,
    CodemAdminMenuRepairVehicle = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:repairVehicle', playerId)
        end
    end,
    CodemAdminMenuGasTank = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:gasTank', playerId)
        end
    end,
    CodemAdminMenuAnnouncement = function(playerId, text)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            if #text < 1 then
                TriggerClientEvent('codem-adminmenu:notfication', src, Config.Locales['typemessage'], 'notification')
                return
            end
            TriggerClientEvent('codem-adminmenu:showAnnouncement', -1, text)
        end
    end,
    CodemAdminMenuKill = function(playerId)
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            local xPlayer = GetPlayer(playerId)
            if xPlayer then
                TriggerClientEvent('esx:killPlayer', playerId)
            end
        else
            local xPlayer = GetPlayer(playerId)
            if xPlayer then
                TriggerClientEvent('hospital:client:KillPlayer', playerId)
            end
        end
    end,
    CodemAdminMenuFreeze = function(playerId)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            if frozenPlayers[playerId] then
                frozenPlayers[playerId] = false
                FreezeEntityPosition(playerId, false)
            else
                frozenPlayers[playerId] = true
                FreezeEntityPosition(playerId, true)
            end
        end
    end,
    CodemAdminMenuArmor = function(playerId, armor)
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            TriggerClientEvent('codem-adminmenu:setArmor', playerId, armor)
        end
    end,
    CodemAdminMenuChangeJob = function(playerId, job)
        local jobname = job.name
        local jobgrade = job.grade
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            jobgrade = tonumber(jobgrade)
            if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                xPlayer.setJob(jobname, jobgrade)
                TriggerClientEvent('codem-adminmenu:notfication', src, "New Job :" .. jobname .. " Grade : " .. jobgrade,
                    'notification')
            else
                xPlayer.Functions.SetJob(jobname, jobgrade)
                TriggerClientEvent('codem-adminmenu:notfication', src, "New Job :" .. jobname .. " Grade : " .. jobgrade,
                    'notification')
            end
        end
    end,
    CodemAdminMenuGiveItem = function(playerId, itemData)
        local itemname = itemData.name
        local itemcount = itemData.count
        if itemname == nil or itemcount == nil then
            return
        end
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            itemcount = tonumber(itemcount)
            addInventoryItem(src, itemname, itemcount)
        end
    end,
    CodemAdminMenuAddMoney = function(playerId, moneyData)
        local moneytype = moneyData.name
        local moneycount = moneyData.count
        if moneytype == nil or moneycount == nil then
            return
        end
        local src = playerId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            moneycount = tonumber(moneycount)
            if moneytype == 'cash' then
                if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                    xPlayer.addMoney(tonumber(moneycount))
                else
                    xPlayer.Functions.AddMoney('cash', tonumber(moneycount))
                end
            elseif moneytype == 'bank' then
                if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                    xPlayer.addAccountMoney('bank', tonumber(moneycount))
                else
                    xPlayer.Functions.AddMoney('bank', tonumber(moneycount))
                end
            end
        end
    end,
    CodemAdminMenuSendPM = function(playerId, message)
        TriggerClientEvent('codem-adminmenu:notfication', playerId, message, 'pm')
    end,
    CodemAdminMenuGoto = function(targetID, playerId)
        local src = playerId
        local staff = GetPlayerPed(src)
        local xTargetPed = GetPlayerPed(targetID)
        local coords = GetEntityCoords(xTargetPed)
        if staff and xTargetPed then
            SetEntityCoords(staff, coords)
        end
    end,
    CodemAdminMenuBring = function(targetID, playerId)
        local src = playerId
        local staff = GetPlayerPed(src)
        local xTarget = GetPlayerPed(targetID)
        local coords = GetEntityCoords(staff)
        if staff and xTarget then
            SetEntityCoords(xTarget, coords)
        end
    end,
    CodemAdminMenuSpectate = function(targetId, playerId)
        TriggerClientEvent('codem-adminmenu:spectate', playerId, targetId)
    end,
    CodemAdminMenuAdminDuty = function(src, value)
        if value then
            TriggerClientEvent('codem-adminmenu:checkedData', src, { name = "adminduty", value = true })
            TriggerClientEvent('codem-adminmenu:adminClothes', src, true)
        else
            TriggerClientEvent('codem-adminmenu:checkedData', src, { name = "adminduty", value = false })
            TriggerClientEvent('codem-adminmenu:adminClothes', src, false)
        end
    end,
    CodemAdminMenuGiveClothingMenu = function(targetId)
        TriggerClientEvent('codem-adminmenu:openClothingMenu', targetId)
    end,
    CodemAdminMenuScreenShot = function(targetId)
        print(Config.Description['CodemAdminMenuScreenShot']['DiscordWebhook'])
        TriggerClientEvent('codem-adminmenu:takePicture', targetId,
            Config.Description['CodemAdminMenuScreenShot']['DiscordWebhook'])
    end,
    CodemAdminMenuClearVehicle = function()
        TriggerClientEvent('codem-adminmenu:clearVehicles', -1)
    end,
    CodemAdminMenuWeather = function(src, value)
        exports['qb-weathersync']:setWeather(value)
    end,
    CodemAdminMenuTime = function(src, value)
        exports['qb-weathersync']:setTime(value)
    end,
    CodemAdminMenuKickAll = function(src)
        for _, playerId in ipairs(GetPlayers()) do
            if tonumber(playerId) ~= tonumber(src) then
                DropPlayer(playerId, "Dont Join")
            end
        end
    end,
    CodemAdminMenuClearInventory = function(src)
        local xPlayer = GetPlayer(src)
        if xPlayer then
            if Config.Inventory == "codem-inventory" then
                exports["codem-inventory"]:ClearInventory(src)
            elseif Config.Inventory == 'ox_inventory' then
                exports.ox_inventory:ClearInventory(src)
            elseif Config.Inventory == 'qb_inventory' then
                exports['qb-inventory']:ClearInventory(src)
            elseif Config.Inventory == 'esx_inventory' then
                TriggerEvent('esx:playerInventoryCleared', src)
            elseif Config.Inventory == 'qs_inventory' then
                local saveItems = {
                    'id_card', -- Add here the items that you do NOT want to be deleted
                    'phone',
                }
                exports['qs-inventory']:ClearInventory(src, saveItems)
            end
        end
    end,

    CodemAdminMenuKick = function(targetId, value)
        local src = targetId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            local identifier = GetIdentifier(src)
            local data = playerAdminData[identifier]
            if not data then
                TriggerClientEvent('codem-adminmenu:notfication', src,
                    string.format(Config.Locales['playerdatanotfound'], identifier),
                    'notification')
                return
            end
            local adminname = GetName(value.adminID) or "Unknown"
            if #value.reason < 1 then
                value.reason = "No Reason"
            end
            local message = "You have been kicked from the server for " .. value.reason .. " by " .. adminname
            local historydata = data.historydata
            local history = {
                type = 'kick',
                reason = message,
                admin = adminname,
                time = os.date("%m.%d.%Y %I:%M")
            }
            table.insert(historydata, history)
            data.historydata = historydata
            DropPlayer(src, message)
        end
    end,
    CodemAdminMenuBan = function(targetId, value)
        local src = targetId
        local xPlayer = GetPlayer(src)
        if xPlayer then
            local identifier = GetIdentifier(src)
            local data = playerAdminData[identifier]
            if not data then
                TriggerClientEvent('codem-adminmenu:notfication', value.adminID,
                    'Player data not found for identifier : ' .. identifier,
                    'notification')
                return
            end
            local adminname = GetName(value.adminID) or "Unknown"
            if #value.reason < 1 then
                value.reason = "No Reason"
            end
            local message = "You have been banned from the server for " ..
                value.reason .. ". " .. value.time.value .. "  " .. value.time.label .. ", by " .. adminname
            local historydata = data.historydata
            local banId = math.random(00000, 99999)
            local history = {
                type = 'ban',
                banID = banId,
                reason = value.reason,
                admin = adminname,
                time = os.date("%m.%d.%Y %I:%M")
            }
            table.insert(historydata, history)
            data.historydata = historydata

            local steamid = "Not Found"
            local discord = "Not Found"
            local license = "Not Found"
            local live = "Not Found"
            local xbl = "Not Found"
            local C = GetPlayerEndpoint(src)
            for _, n in ipairs(GetPlayerIdentifiers(src)) do
                if n:match("steam") then
                    steamid = n
                elseif n:match("discord") then
                    discord = n:gsub("discord:", "")
                elseif n:match("license") then
                    license = n
                elseif n:match("live") then
                    live = n
                elseif n:match("xbl") then
                    xbl = n
                end
            end
            local banTime = 0
            if value.time.type == "day" then
                banTime = tonumber(value.time.value) * 86400
            elseif value.time.type == "hours" then
                banTime = tonumber(value.time.value) * 3600
            elseif value.time.type == "perma" then
                banTime = 999999999
            end
            local banlist = {
                ['steam'] = steamid,
                ['discord'] = discord,
                ['license'] = license,
                ['live'] = live,
                ['xbl'] = xbl,
                ['ip'] = C,
                ['time'] = os.time() + banTime,
                ['token'] = GetPlayerToken(src, 0),
                ['BanId'] = "#" .. banId .. "",
                ['Reason'] = value.reason
            }

            local bandata = data.bandata
            table.insert(bandata, banlist)
            data.bandata = bandata
            DropPlayer(src, message)
        end
    end,
    CodemAdminMenuOfflineBan = function(clientdata, admin)
        local banId = math.random(00000, 99999)
        local data = playerAdminData[clientdata.playeridentifier]
        local banTime = 0
        if clientdata.time.type == "day" then
            banTime = tonumber(clientdata.time.value) * 86400
        elseif clientdata.time.type == "hours" then
            banTime = tonumber(clientdata.time.value) * 3600
        elseif clientdata.time.type == "perma" then
            banTime = 999999999
        end
        local banlist = {
            ['steam'] = data.profiledata.steam,
            ['discord'] = data.profiledata.discord,
            ['license'] = data.profiledata.license,
            ['ip'] = data.profiledata.ip,
            ['time'] = os.time() + banTime,
            ['token'] = data.profiledata.token,
            ['BanId'] = "#" .. banId .. "",
            ['Reason'] = clientdata.reason
        }
        local bandata = {}
        table.insert(bandata, banlist)
        data.bandata = bandata
        if data.profiledata.id then
            DropPlayer(data.profiledata.id,
                "You have been banned from the server for " ..
                clientdata.reason ..
                ". " .. clientdata.time.value .. "  " .. clientdata.time.label .. ", by " .. GetName(tonumber(admin)))
        else
            SaveOfflineData(clientdata.playeridentifier, data)
        end
    end

}


local function calculateTimeDifference(endTime)
    local currentTime = os.time()
    local diff = endTime - currentTime

    if diff <= 0 then
        return "Ban expired"
    end

    local days = math.floor(diff / 86400)
    diff = diff % 86400
    local hours = math.floor(diff / 3600)
    diff = diff % 3600
    local minutes = math.floor(diff / 60)
    local seconds = diff % 60

    return string.format("%d days, %d hours, %d minutes, %d seconds", days, hours, minutes, seconds)
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local steamid, discord, license, live, xbl, C, tken = "NA", "NA", "NA", "NA", "NA", GetPlayerEndpoint(player),
        GetPlayerToken(player, 0)

    for _, identifier in ipairs(GetPlayerIdentifiers(player)) do
        if identifier:match("steam") then
            steamid = identifier
        elseif identifier:match("discord") then
            discord = identifier:gsub("discord:", "")
        elseif identifier:match("license") then
            license = identifier
        elseif identifier:match("live") then
            live = identifier
        elseif identifier:match("xbl") then
            xbl = identifier
        end
    end
    print("^3 Codem Admin Menu: Player " .. name .. " Connecting...")
    deferrals.defer()
    Wait(0)
    deferrals.update("Checking Ban List...")
    local banFile = ExecuteSql("SELECT `bandata` FROM `codem_adminmenu`")
    for _, row in ipairs(banFile) do
        local banList = json.decode(row.bandata)
        if banList == nil then
            deferrals.done()
            return
        end
        for _, ban in pairs(banList) do
            local banEndTime = ban.time
            if banEndTime ~= 999999999 then
                local remainingTime = calculateTimeDifference(banEndTime)
                if os.time() > banEndTime then
                    deferrals.done()
                    return
                else
                    if ban.steam == steamid or ban.discord == discord or ban.license == license or ban.live == live or ban.xbl == xbl or ban.token == tken or ban.ip == C then
                        print("^3 [Codem Admin Menu]: Player " ..
                            GetPlayerName(player) .. " tried to join the server but is banned!")
                        deferrals.done('\n\n[Codem Admin Menu]: YOU ARE BANNED FROM THIS SERVER\n\n[Reason]: ' ..
                            ban.Reason ..
                            ' \n\n[Ban ID]: ' ..
                            ban.BanId ..
                            '\n\n[Time Remaining]: ' ..
                            remainingTime .. '\n\n[Additional Details]: ' .. Config.Ban_Message)
                        -- deferrals.done()
                        return
                    end
                end
            end
        end
        deferrals.done()
    end
    deferrals.done()
end)



function SendDiscordLog(src, targetId, functionname, value)
    local extractData = ExtractIdentifiers(targetId)
    local description = Config.Description[functionname]['Description']
    if functionname == 'CodemAdminMenuGiveItem' then
        description = description .. "  Item Name: " .. value.name .. " Item Count: " .. value.count
    end
    if functionname == 'CodemAdminMenuAddMoney' then
        description = description .. " Account Type: " .. value.name .. " Amount: " .. value.count
    end
    if functionname == 'CodemAdminMenuSendPM' then
        description = description .. " Message: " .. value.pm
    end
    if functionname == 'CodemAdminMenuGivePermission' then
        local text = ""
        if value.value then
            text = "true"
        else
            text = "false"
        end
        description = description .. " Permission: " .. value.permission .. " Value: " .. text
    end

    local message = {
        username = bot_name,
        embeds = {
            {
                title = botname,
                color = 0xFFA500,
                author = {
                    name = GetName(src) .. ' ID : ' .. src .. ' ADMIN',
                    icon_url = GetDiscordAvatar(src) or Config.ExampleProfilePicture
                },

                description = description,
                thumbnail = {
                    url = GetDiscordAvatar(targetId) or Config.ExampleProfilePicture
                },
                fields = {

                    { name = "Player Name",    value = GetName(targetId),                  inline = true },
                    { name = "Player ID",      value = targetId,                           inline = true },
                    { name = "Player Steam",   value = extractData.steam or 'undefined',   inline = true },
                    { name = "Player License", value = extractData.license or 'undefined', inline = true },
                    { name = "Player Discord", value = extractData.discord or 'undefined', inline = true },
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

    PerformHttpRequest(Config.Description[functionname]['DiscordWebhook'],
        function(err, text, headers) end,
        "POST",
        json.encode(message),
        { ["Content-Type"] = "application/json" })
end
