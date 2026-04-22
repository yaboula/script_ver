function ExecuteSql(query, parameters)
    local IsBusy = true
    local result = nil
    if Config.SQL == "oxmysql" then
        if parameters then
            exports.oxmysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.SQL == "ghmattimysql" then
        if parameters then
            exports.ghmattimysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.ghmattimysql:execute(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.SQL == "mysql-async" then
        if parameters then
            MySQL.Async.fetchAll(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.Async.fetchAll(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

function RegisterCallback(name, cbFunc)
    while not Core do
        Wait(0)
    end
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        Core.RegisterServerCallback(name, function(source, cb, data)
            cbFunc(source, cb, data)
        end)
    else
        Core.Functions.CreateCallback(name, function(source, cb, data)
            cbFunc(source, cb, data)
        end)
    end
end

function WaitCore()
    while Core == nil do
        Wait(0)
    end
end

function GetPlayer(source)
    local Player = false
    while Core == nil do
        Citizen.Wait(0)
    end
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        Player = Core.GetPlayerFromId(source)
    else
        Player = Core.Functions.GetPlayer(source)
    end
    return Player
end

function GetIdentifier(source)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            return Player.getIdentifier()
        else
            return Player.PlayerData.citizenid
        end
    end
end

function GetName(source)
    if Config.Framework == "oldesx" or Config.Framework == "esx" then
        local xPlayer = Core.GetPlayerFromId(tonumber(source))
        if xPlayer then
            return xPlayer.getName()
        else
            return "0"
        end
    elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
        local Player = Core.Functions.GetPlayer(tonumber(source))
        if Player then
            return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        else
            return "0"
        end
    end
end

function GetPlayerMoney(source, value)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            if value == 'bank' then
                return Player.getAccount('bank').money
            end
            if value == 'cash' then
                return Player.getMoney()
            end
        elseif Config.Framework == 'qb' or Config.Framework == 'oldqb' then
            if value == 'bank' then
                return Player.PlayerData.money['bank']
            end
            if value == 'cash' then
                return Player.PlayerData.money['cash']
            end
        end
    end
end

function GetPlayerInventory(source)
    local data = {}
    local Player = GetPlayer(source)
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        for _, v in pairs(Player.getInventory()) do
            if v and tonumber(v.count) > 0 then
                local formattedData = v
                formattedData.name = string.lower(v.name)
                formattedData.label = v.label
                formattedData.amount = v.count
                formattedData.image = v.image or (string.lower(v.name) .. '.png')
            end
        end
    else
        for _, v in pairs(Player.PlayerData.items) do
            if v then
                local amount = v.count or v.amount
                if tonumber(amount) > 0 then
                    local formattedData = v
                    formattedData.name = string.lower(v.name)
                    formattedData.label = v.label
                    formattedData.amount = amount
                    formattedData.image = v.image or (string.lower(v.name) .. '.png')
                    table.insert(data, formattedData)
                end
            end
        end
    end
    return data
end

function OpenPlayerInventory(src, targetID)
    local Player = GetPlayer(src)
    local xTarget = GetPlayer(targetID)
    if Player and xTarget then
        TriggerClientEvent("codem-adminmenu:openPlayerInventory", src, targetID)
    end
end

function addInventoryItem(src, item, amount)
    local Player = GetPlayer(src)
    if Player then
        if Config.Inventory == "qb_inventory" then
            Player.Functions.AddItem(item, amount)
        elseif Config.Inventory == "esx_inventory" then
            Player.addInventoryItem(item, amount)
        elseif Config.Inventory == "ox_inventory" then
            exports.ox_inventory:AddItem(src, item, amount)
        elseif Config.Inventory == "codem-inventory" then
            exports["codem-inventory"]:AddItem(src, item, amount)
        elseif Config.Inventory == "qs_inventory" then
            exports['qs-inventory']:AddItem(src, item, count)
        end
    end
end

function ClearPlayerInventory(src)
    if Config.Inventory == 'qb-inventory' then
        local Player = GetPlayer(src)
        if Player then
            TriggerClientEvent('qb-admin:client:clearInventory', src)
        end
    end
end

function GetPlayerVehicles(source)
    local data = {}
    local playerIdentifer = GetIdentifier(source)
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        local result = ExecuteSql("SELECT vehicle FROM owned_vehicles WHERE owner = '" .. playerIdentifer .. "'")
        if result ~= nil then
            for _, v in pairs(result) do
                local formattedvehicleData = v
                formattedvehicleData.vehicle = string.lower(v.vehicle)
                formattedvehicleData.label = nil
                formattedvehicleData.image = v.image or (string.lower(v.vehicle) .. '.png')
                table.insert(data, formattedvehicleData)
            end
        end
    else
        local result = ExecuteSql("SELECT vehicle FROM player_vehicles WHERE citizenid = '" .. playerIdentifer .. "'")
        if result ~= nil then
            for _, v in pairs(result) do
                local formattedvehicleData = v
                formattedvehicleData.vehicle = string.lower(v.vehicle)
                formattedvehicleData.label = nil
                formattedvehicleData.image = v.image or (string.lower(v.vehicle) .. '.png')
                table.insert(data, formattedvehicleData)
            end
        end
    end
    return data
end

function GetJob(source)
    local Player = GetPlayer(source)
    if Player then
        if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
            return Player.getJob().name
        else
            return Player.PlayerData.job.name
        end
    end
    return false
end

Citizen.CreateThread(function()
    Citizen.Wait(2000)
    while Core == nil do
        Citizen.Wait(0)
    end
    if (Config.Framework == "qb" or Config.Framework == "old-qb") then
        Core.Commands.Add(Config.SetAdminMenuCommand, "Set Codem Admin Menu (Admin Only)",
            {}, false,
            function(source, args)
                local Player = GetPlayer(source)
                if Player then
                    local src = source
                    local identifier = GetIdentifier(src)
                    local data = playerAdminData[identifier]
                    if not data then
                        TriggerClientEvent('codem-adminmenu:notfication', src,
                            'Player data not found for identifier : ' .. identifier,
                            'notification')
                        return
                    end
                    local permTable = {}
                    for k, v in pairs(Config.AllowPermission) do
                        permTable[v.name] = true
                    end

                    data.permissiondata = permTable
                    if onlinePlayersData[identifier] then
                        onlinePlayersData[identifier] = nil
                    end

                    onlinePlayersData[identifier] = {
                        name = GetName(src),
                        permissiondata = data.permissiondata,
                        identifier = identifier,
                        id = src,
                        avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
                        job = 'admin',
                    }


                    TriggerClientEvent('codem-adminmenu:client:updateOnlinePlayersData', -1, identifier,
                        onlinePlayersData[identifier])
                    TriggerClientEvent('codem-adminmenu:notfication', src, 'Admin Menu Loaded..',
                        'notification')
                    saveDataOnline(src)
                end
            end, "god")
    else
        while Core == nil do
            Citizen.Wait(0)
        end
        Core.RegisterCommand(Config.SetAdminMenuCommand, 'admin', function(xPlayer, args, showError)
            local Player = xPlayer.source
            if Player then
                local src = source
                local identifier = GetIdentifier(src)
                local data = playerAdminData[identifier]
                if not data then
                    TriggerClientEvent('codem-adminmenu:notfication', src,
                        'Player data not found for identifier : ' .. identifier,
                        'notification')
                    return
                end
                local permTable = {}
                for k, v in pairs(Config.AllowPermission) do
                    permTable[v.name] = true
                end

                data.permissiondata = permTable
                if onlinePlayersData[identifier] then
                    onlinePlayersData[identifier] = nil
                end

                onlinePlayersData[identifier] = {
                    name = GetName(src),
                    permissiondata = data.permissiondata,
                    identifier = identifier,
                    id = src,
                    avatar = GetDiscordAvatar(src) or Config.ExampleProfilePicture,
                    job = 'admin',
                }


                TriggerClientEvent('codem-adminmenu:client:updateOnlinePlayersData', -1, identifier,
                    onlinePlayersData[identifier])
                TriggerClientEvent('codem-adminmenu:notfication', src, 'Admin Menu Loaded..',
                    'notification')
                saveDataOnline(src)
            end
        end, true, {
            help = 'Set Codem Admin menu',
            validate = true,
            arguments = {
            }
        })
    end
end)
