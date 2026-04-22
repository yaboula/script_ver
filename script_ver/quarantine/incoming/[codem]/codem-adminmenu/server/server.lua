Core = nil

Citizen.CreateThread(function()
    Core = GetCore()
end)

cooldowns = {}
playerAdminData = {}
onlinePlayersData = {}
adminDuty = {}
onlineAdminSource = {}


Citizen.CreateThread(function()
    local result = ExecuteSql("SELECT * FROM `codem_adminmenu`")
    for i = 1, #result do
        local playerData = result[i]
        local dataInfo = {
            permissiondata = json.decode(playerData.permissiondata),
            historydata = json.decode(playerData.historydata),
            bandata = json.decode(playerData.bandata),
            profiledata = json.decode(playerData.profiledata),

        }
        if not playerAdminData[playerData.identifier] then
            playerAdminData[playerData.identifier] = dataInfo
        end
        playerAdminData[playerData.identifier] = dataInfo
    end
end)


RegisterServerEvent('codem-adminmenu:changePlayerJob', function(newJob)
    local src = source
    local identifier = GetIdentifier(src)
    local data = playerAdminData[identifier]
    if not data then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfound'], identifier),
            'notification')
        return
    end
    if onlinePlayersData[identifier] then
        onlinePlayersData[identifier] = nil
    end

    local playerJob = false
    local isAdmin = checkAdminPermission(src)
    if not isAdmin then
        playerJob = newJob
    else
        playerJob = 'admin'
    end
    onlinePlayersData[identifier] = {
        name = GetName(src),
        permissiondata = data.permissiondata,
        identifier = identifier,
        id = src,
        avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
        job = playerJob,
    }
    TriggerClientEvent('codem-adminmenu:client:updateOnlinePlayersData', -1, identifier, onlinePlayersData[identifier])
end)



RegisterServerEvent('codem-adminmenu:server:PermissionData', function(clientdata)
    local src = source
    local identifier = GetIdentifier(src)
    local data = playerAdminData[identifier]
    if not data then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfound'], identifier),
            'notification')
        return
    end
    local requestname = "giveperm"
    if not data.permissiondata[requestname] then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['nopermissionforthis'], requestname),
            'notification')
        return
    end
    local targetID = clientdata.playerid
    local targetIdentifier = GetIdentifier(targetID)
    local targetData = playerAdminData[targetIdentifier]
    if not targetData then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfoundid'], targetID),
            'notification')
        return
    end
    local permissiondata = targetData.permissiondata

    if not permissiondata then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfoundid'], targetID),
            'notification')
        return
    end

    if clientdata.name == 'allpermission' then
        local allTrue = true
        for k, v in pairs(permissiondata) do
            if not v then
                allTrue = false
                break
            end
        end

        local newPermissionValue = not allTrue
        for k in pairs(permissiondata) do
            permissiondata[k] = newPermissionValue
        end

        TriggerClientEvent('codem-adminmenu:updatePlayerPermission', -1, targetIdentifier, permissiondata)
        saveDataOnline(targetID)
        return
    end

    if permissiondata[clientdata.name] == nil then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfoundid'], targetID),
            'notification')
        return
    end

    permissiondata[clientdata.name] = not permissiondata[clientdata.name]
    SendDiscordLog(src, targetID, 'CodemAdminMenuGivePermission',
        { permission = clientdata.name, value = permissiondata[clientdata.name] })
    saveDataOnline(targetID)
    TriggerClientEvent('codem-adminmenu:updatePlayerPermission', -1, targetIdentifier, permissiondata)
end)


function saveDataOnline(source)
    local src = source
    local identifier = GetIdentifier(src)
    local data = playerAdminData[identifier]
    if not data then
        return
    end
    ExecuteSql(
        'UPDATE codem_adminmenu SET permissiondata = :permissiondata, historydata = :historydata, profiledata = :profiledata, bandata = :bandata WHERE identifier = :identifier',
        {
            identifier = identifier,
            permissiondata = json.encode(data.permissiondata),
            historydata = json.encode(data.historydata),
            bandata = json.encode(data.bandata),
            profiledata = json.encode(data.profiledata),
        }
    )
end

function SaveOfflineData(playeridentifier, updatedata)
    local identifier = playeridentifier
    local data = playerAdminData[identifier]
    if not data then
        return
    end
    ExecuteSql(
        'UPDATE codem_adminmenu SET permissiondata = :permissiondata, historydata = :historydata, profiledata = :profiledata, bandata = :bandata WHERE identifier = :identifier',
        {
            identifier = identifier,
            permissiondata = json.encode(updatedata.permissiondata),
            historydata = json.encode(updatedata.historydata),
            bandata = json.encode(updatedata.bandata),
            profiledata = json.encode(updatedata.profiledata),
        }
    )
end

RegisterServerEvent('codem-adminmenu:server:loadData', function()
    local src = source
    local identifier = GetIdentifier(src)
    if identifier then
        LoadAdminMenuData(src)
    end
end)

function LoadAdminMenuData(src)
    local identifier = GetIdentifier(src)
    local data = playerAdminData[identifier]
    if not data then
        firstData(src, function()
            data = playerAdminData[identifier]
        end)
    end
    if onlinePlayersData[identifier] then
        onlinePlayersData[identifier] = nil
    end
    data.bandata = {}

    if not onlinePlayersData[identifier] then
        local playerJob = false
        local isAdmin = checkAdminPermission(src)
        if not isAdmin then
            playerJob = GetJob(src)
        else
            playerJob = 'admin'
        end
        local extractdata = ExtractIdentifiers(src)
        data.profiledata.name = GetName(src)
        data.profiledata.avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture
        data.profiledata.license = extractdata.license or 'unkown'
        data.profiledata.discord = extractdata.discord or 'unkown'
        data.profiledata.steam = extractdata.steam or 'unkown'
        data.profiledata.identifier = identifier
        data.profiledata.ip = GetPlayerEndpoint(src)
        data.profiledata.token = GetPlayerToken(src, 0)
        data.profiledata.id = tonumber(src)
        onlinePlayersData[identifier] = {
            name = GetName(src),
            permissiondata = data.permissiondata,
            identifier = identifier,
            id = src,
            avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
            job = playerJob,
        }
    end

    playerAdminData[identifier] = data
    TriggerClientEvent('codem-adminmenu:client:loadData', -1, onlinePlayersData)
end

function firstData(src, callback)
    local identifier = GetIdentifier(src)

    if playerAdminData[identifier] then
        return
    end

    local permTable = {}
    for k, v in pairs(Config.AllowPermission) do
        permTable[v.name] = false --- false olacak
    end
    local extractData = ExtractIdentifiers(src)
    local dataInfo = {
        identifier = identifier,
        permissiondata = permTable,
        historydata = {},
        bandata = {},
        profiledata = {
            name = GetName(src),
            avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
            license = extractData.license or 'unkown',
            discord = extractData.discord or 'unkown',
            steam = extractData.steam or 'unkown',
            identifier =  identifier,
            ip = GetPlayerEndpoint(src),
            token = GetPlayerToken(src, 0),
            id = tonumber(src)
        }
    }
    Citizen.Wait(100)
    playerAdminData[identifier] = dataInfo
    ExecuteSql(
        'INSERT INTO codem_adminmenu (identifier, permissiondata, historydata,bandata,profiledata) VALUES (:identifier, :permissiondata,:historydata, :bandata, :profiledata) ',
        {
            identifier = identifier,
            permissiondata = json.encode(dataInfo.permissiondata),
            historydata = json.encode(dataInfo.historydata),
            bandata = json.encode(dataInfo.bandata),
            profiledata = json.encode(dataInfo.profiledata),
        }
    )
    callback()
end

function checkCooldown(src)
    local src = src
    if cooldowns[src] and (os.time() - cooldowns[src] < 1) then
        TriggerClientEvent('codem-adminmenu:notfication', src, Config.Locales['plasewaitbefore'], 'notification')
        return false
    end
    cooldowns[src] = os.time()
    return true
end

RegisterNetEvent('codem-adminmenu:server:adminPlayerOption', function(clientdata)
    local src = source
    if Config.AdminDuty then
        if not adminDuty[src] then
            TriggerClientEvent('codem-adminmenu:notfication', src, Config.Locales['youarenotonadmin'], 'notification')
            return
        end
    end
    local success = checkCooldown(src)
    if not success then
        return
    end
    local identifier = GetIdentifier(src)
    local data = playerAdminData[identifier]
    if not data then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfound'], identifier),
            'notification')
        return
    end

    local targetID = clientdata.playerid
    local targetIdentifier = GetIdentifier(targetID)
    local targetData = playerAdminData[targetIdentifier]
    if not targetData then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfoundid'], targetID),
            'notification')
        return
    end

    local requestname = clientdata.functiondata.name
    if not data.permissiondata[requestname] then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['nopermissionforthis'], requestname),
            'notification')
        return
    end

    local functionname = clientdata.functiondata.functionname or clientdata.functiondata.name
    if functionname == "CodemAdminMenuOpenInventory" then
        SendDiscordLog(src, targetID, functionname)
        OpenPlayerInventory(src, targetID)
        return
    end
    local value = false
    if functionname == 'CodemAdminMenuChangeJob' then
        value = clientdata.jobData
    end
    if functionname == 'CodemAdminMenuGiveItem' then
        value = clientdata.itemData
    end
    if functionname == "CodemAdminMenuAddMoney" then
        value = clientdata.moneyData
    end
    if functionname == "CodemAdminMenuSendPM" then
        value = { pm = clientdata.pm, playername = GetName(src) }
    end
    if functionname == "CodemAdminMenuGoto" then
        value = src
    end
    if functionname == "CodemAdminMenuBring" then
        value = src
    end
    if functionname == "CodemAdminMenuSpectate" then
        value = src
    end
    if functionname == "CodemAdminMenuKick" then
        if tonumber(src) == tonumber(targetID) then
            TriggerClientEvent('codem-adminmenu:notfication', src, Config.Locales['youcannotkick'], 'notification')
            return
        end
        value = { reason = clientdata.reason, adminID = tonumber(src) }
    end
    if functionname == "CodemAdminMenuBan" then
        if tonumber(src) == tonumber(targetID) then
            TriggerClientEvent('codem-adminmenu:notfication', src, Config.Locales['youcannotban'], 'notification')
            return
        end
        value = { reason = clientdata.reason, time = clientdata.time, adminID = tonumber(src) }
    end

    if AdminFunctions[functionname] then
        SendDiscordLog(src, targetID, functionname, value)
        AdminFunctions[functionname](targetID, value)
    else
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['functionnotfound'], functionname),
            'notification')
    end
end)

RegisterServerEvent('codem-admin:server:adminOptionRequest', function(clientdata)
    local src = source
    local success = checkCooldown(src)
    if not success then
        return
    end

    local identifier = GetIdentifier(src)

    local data = playerAdminData[identifier]
    if not data then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfound'], identifier),
            'notification')

        return
    end
    local requestname = clientdata.name
    if Config.AdminDuty then
        if requestname == 'adminduty' then
            adminDuty[src] = not adminDuty[src]
            if adminDuty[src] then
                TriggerClientEvent('codem-adminmenu:notfication', src,
                    Config.Locales['admindutyisactive'],
                    'notification')
                AdminFunctions["CodemAdminMenuAdminDuty"](src, true)
                return
            end
            TriggerClientEvent('codem-adminmenu:notfication', src,
                Config.Locales['admindutisnotactive'],
                'notification')
            AdminFunctions["CodemAdminMenuAdminDuty"](src, false)
            return
        end
        if not adminDuty[src] then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                Config.Locales['plsopenadminduty'],
                'notification')
            return
        end
    end

    if not Config.AdminDuty then
        if requestname == 'adminduty' then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                Config.Locales['systemclosed'],
                'notification')
            return
        end
    end

    if not data.permissiondata[requestname] then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['nopermissionforthis'], requestname),
            'notification')
        return
    end

    local functionname = clientdata.functionname or clientdata.name
    local val = false
    if functionname == 'CodemAdminMenuAnnouncement' or functionname == 'CodemAdminMenuGiveVehicle' or functionname == 'CodemAdminMenuGiveVehicleToPlayer' then
        val = clientdata.text
    end
    if functionname == "CodemAdminMenuWeather" or functionname == "CodemAdminMenuTime" then
        val = clientdata.value
    end



    if AdminFunctions[functionname] then
        AdminFunctions[functionname](src, val)
    else
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['functionnotfound'], functionname),
            'notification')
    end
end)



Citizen.CreateThread(function()
    while Core == nil do
        Citizen.Wait(0)
    end

    RegisterCallback('codem-admin:server:getPlayerInfo', function(source, cb, plyid)
        plyid = tonumber(plyid)
        local src = source
        local identifier = GetIdentifier(src)
        local data = playerAdminData[identifier]
        if not data then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                string.format(Config.Locales['playerdatanotfound'], identifier),
                'notification')
            return
        end
        if Config.AdminDuty then
            if not adminDuty[src] then
                TriggerClientEvent('codem-adminmenu:notfication', src,
                    Config.Locales['youarenotonadminduty']
                    'notification')
                return
            end
        end
        local requestname = "playerinfo"
        if not data.permissiondata[requestname] then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                string.format(Config.Locales['nopermissionforthis'], requestname),
                'notification')
            return
        end
        local extractData = ExtractIdentifiers(src)
        local targetIdentifier = GetIdentifier(plyid)
        local historydata = playerAdminData[targetIdentifier].historydata
        local dataInfo = {
            steam = extractData.steam,
            discord = extractData.discord,
            license = extractData.license,
            playername = GetName(plyid),
            cash = GetPlayerMoney(plyid, 'cash'),
            bank = GetPlayerMoney(plyid, 'bank'),
            blackmoney = AdminFunctions['CodemAdminMenuGetPlayerBlackMoney'](plyid),
            coin = AdminFunctions['CodemAdminMenuGetPlayerCoin'](plyid),
            source = plyid,
            avatar = GetDiscordAvatar(plyid) or Config.ExampleProfilePicture,
            inventory = GetPlayerInventory(plyid),
            job = GetJob(plyid),
            playerVehicles = GetPlayerVehicles(plyid),
            playerHistory = historydata,

        }
        cb(dataInfo)
    end)
    RegisterCallback('codem-admin:server:getPlayerData', function(source, cb)
        local src = source
        local checkAdmin = checkAdminPermission(src)
        if not checkAdmin then
            cb(false)
            return
        end
        local playerData = {
            name = GetName(src),
            avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
        }
        cb(playerData)
    end)
    RegisterCallback('codem-admin:serverIsAdmin', function(source, cb, permname)
        local src = source
        local identifier = GetIdentifier(src)
        local data = playerAdminData[identifier]
        if not data then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                string.format(Config.Locales['playerdatanotfound'], identifier),
                'notification')
            return
        end
        local requestname = permname
        if not data.permissiondata[requestname] then
            DropPlayer(src, 'CODEM ADMINMENU : KICK PLAYER ACTION: ' .. requestname)
            return
        end
        cb(true)
    end)
    RegisterCallback('codem-admin:server:searchBan', function(source, cb, searchtext)
        local src = source
        local identifier = GetIdentifier(src)
        local data = playerAdminData[identifier]
        if not data then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                string.format(Config.Locales['playerdatanotfound'], identifier),
                'notification')
            return
        end

        local matchedResult = {}

        for id, playerData in pairs(playerAdminData) do
            local idStr = tostring(playerData.profiledata.id)
            local steamStr = tostring(playerData.profiledata.steam)
            local licenseStr = tostring(playerData.profiledata.license)
            local discordStr = tostring(playerData.profiledata.discord)
            local nameStr = tostring(playerData.profiledata.name)
            local identifierStr = tostring(playerData.profiledata.identifier)

            if string.match(identifierStr:lower(), searchtext:lower()) or string.match(idStr:lower(), searchtext:lower()) or string.match(steamStr:lower(), searchtext:lower()) or string.match(licenseStr:lower(), searchtext:lower()) or string.match(discordStr:lower(), searchtext:lower()) or string.match(nameStr:lower(), searchtext:lower()) then
                table.insert(matchedResult, playerData)
            end
        end
        cb(matchedResult)
    end)
    RegisterCallback('codem-admin:server:getBannedPlayers', function(source, cb)
        local src = source
        local identifier = GetIdentifier(src)
        local data = playerAdminData[identifier]
        if not data then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                string.format(Config.Locales['playerdatanotfound'], identifier),
                'notification')
            return
        end
        local requestname = "bannedplayers"
        if not data.permissiondata[requestname] then
            TriggerClientEvent('codem-adminmenu:notfication', src,
                string.format(Config.Locales['nopermissionforthis'], requestname),
                'notification')
            return
        end

        local bannedPlayers = {}
        for id, playerData in pairs(playerAdminData) do
            if #playerData.bandata > 0 then
                table.insert(bannedPlayers, playerData)
            end
        end
        cb(bannedPlayers)
    end)
end)


RegisterServerEvent('codem-adminmenu:server:offlineBanPlayer', function(clientdata)
    local src = source
    local identifier = GetIdentifier(src)
    local data = playerAdminData[identifier]
    if not data then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfound'], identifier),
            'notification')
        return
    end
    local requestname = "offlineban"
    if not data.permissiondata[requestname] then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['nopermissionforthis'], requestname),
            'notification')
        return
    end
    local targetData = playerAdminData[clientdata.playeridentifier]
    if not targetData then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfoundid'], clientdata.playeridentifier),
            'notification')
        return
    end


    local functionname = 'CodemAdminMenuOfflineBan' or 'offlineban'

    if AdminFunctions[functionname] then
        -- SendDiscordLog(src, targetID, functionname, value)
        AdminFunctions[functionname](clientdata, src)
    else
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['functionnotfound'], functionname),
            'notification')
    end
end)

function checkAdminPermission(src)
    local src = src
    local identifier = GetIdentifier(src)
    local data = playerAdminData[identifier]
    if not data then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfound'], identifier),
            'notification')
        return false
    end
    local permissiondata = data.permissiondata
    if not permissiondata then
        TriggerClientEvent('codem-adminmenu:notfication', src,
            string.format(Config.Locales['playerdatanotfoundid'], src),
            'notification')
        return false
    end

    for k, v in pairs(permissiondata) do
        if v then
            return true
        end
    end

    return false
end

local Caches = {
    Avatars = {}
}
local FormattedToken = "Bot " .. bot_Token
function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest(
        "https://discordapp.com/api/" .. endpoint,
        function(errorCode, resultData, resultHeaders)
            data = { data = resultData, code = errorCode, headers = resultHeaders }
        end,
        method,
        #jsondata > 0 and json.encode(jsondata) or "",
        { ["Content-Type"] = "application/json", ["Authorization"] = FormattedToken }
    )
    while data == nil do
        Citizen.Wait(0)
    end
    return data
end

function GetDiscordAvatar(user)
    local discordId = nil
    local imgURL = nil
    for _, id in ipairs(GetPlayerIdentifiers(user)) do
        if string.match(id, "discord:") then
            discordId = string.gsub(id, "discord:", "")
            break
        end
    end
    if discordId then
        if Caches.Avatars[discordId] == nil then
            local endpoint = ("users/%s"):format(discordId)
            local member = DiscordRequest("GET", endpoint, {})
            if member.code == 200 then
                local data = json.decode(member.data)
                if data ~= nil and data.avatar ~= nil then
                    if (data.avatar:sub(1, 1) and data.avatar:sub(2, 2) == "_") then
                        imgURL = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. data.avatar .. ".gif"
                    else
                        imgURL = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. data.avatar .. ".png"
                    end
                end
            end
            Caches.Avatars[discordId] = imgURL
        else
            imgURL = Caches.Avatars[discordId]
        end
    end
    return imgURL
end

function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        discord = "",
        license = ""
    }
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "discord") then
            identifiers.discord = "<@" .. id:gsub("discord:", "") .. ">"
        elseif string.find(id, "license") then
            identifiers.license = id
        end
    end
    return identifiers
end
