Core = nil
CoreName = nil
CoreReady = false
Citizen.CreateThread(function()
    for k, v in pairs(Cores) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            CoreName = v.ConstantName
            Core = v.GetFramework()
            CoreReady = true
        end
    end
end)

function GetPlayer(source)
    if CoreName == "qb" then
        local player = Core.Functions.GetPlayer(source)
        return player
    elseif CoreName == "esx" then
        local player = Core.GetPlayerFromId(source)
        return player
    end
end

function GetPlayerJob(source)
    local src = tonumber(source)
    if CoreName == "qb" then
        local player = Core.Functions.GetPlayer(src)
        if player then
            return player.PlayerData.job
        else
            return false
        end
    elseif CoreName == "esx" then
        local player = Core.GetPlayerFromId(src)
        if player then
            return player.job
        else
            return false
        end
    end
end

function Notify(source, text, type, length)
    local src = tonumber(source)
    if CoreName == "qb" then
        Core.Functions.Notify(src, text, type, length)
    elseif CoreName == "esx" then
        local player = Core.GetPlayerFromId(src)
        player.showNotification(text)
    end
end

if Config then
    Config.ServerCallbacks = {}
end
function CreateCallback(name, cb)
    if not Config.ServerCallbacks then Config.ServerCallbacks = {} end
    Config.ServerCallbacks[name] = cb
end

function TriggerCallback(name, source, cb, ...)
    if not Config.ServerCallbacks[name] then return end
    Config.ServerCallbacks[name](source, cb, ...)
end

RegisterNetEvent('0r-clothing:server:triggerCallback', function(name, ...)
    local src = source
    TriggerCallback(name, src, function(...)
        TriggerClientEvent('0r-clothing:client:triggerCallback', src, name, ...)
    end, ...)
end)

function GetPlayerMoney(src, type)
    if CoreName == "qb" then
        local player = Core.Functions.GetPlayer(src)
        return player.PlayerData.money[type]
    elseif CoreName == "esx" then
        local player = Core.GetPlayerFromId(src)
        local acType = "bank"
        if type == "cash" then
            acType = "money"
        elseif type == "black_money" then
            acType = "black_money"
        end
        --local account = player.getAccount(acType).money -- old esx
        local account = player.accounts
        for k, v in pairs(account) do
            if v.name == acType then
                return v.money
            end 
        end
        return account
    end
end

function RemoveMoney(src, type, amount, description)
    if CoreName == "qb" then
        local player = Core.Functions.GetPlayer(src)
        player.Functions.RemoveMoney(type, amount, description)
    elseif CoreName == "esx" then
        local player = Core.GetPlayerFromId(src)
        if type == "bank" then
            player.removeAccountMoney("bank", amount, description)
        elseif type == "black_money" then
            player.removeAccountMoney("black_money", amount, description)
        elseif type == "cash" then
            player.removeMoney(amount, description)
        end
    end
end

function GetPlayerLicenseCore(source)
    local src = tonumber(source)
    if CoreName == "qb" then
        local player = Core.Functions.GetPlayer(src)
        if not player then return end
        return player.PlayerData.citizenid
    elseif CoreName == "esx" then
        local player = Core.GetPlayerFromId(src)
        if not player then return end
        return player.getIdentifier()
    end
end

Citizen.CreateThread(function()
    local table = MySQL.query.await("SHOW TABLES LIKE '0r_clothing_image_data'", {}, function(rowsChanged) end)
    if not next(table) then
        MySQL.query.await([[CREATE TABLE IF NOT EXISTS `0r_clothing_image_data` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `data` varchar(50) DEFAULT NULL,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;]], {}, function(rowsChanged) end)
    end
    local table2 = MySQL.query.await("SHOW TABLES LIKE '0r_clothing_tattoos'", {}, function(rowsChanged) end)
    if not next(table2) then
        MySQL.query.await([[CREATE TABLE IF NOT EXISTS `0r_clothing_tattoos` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `license` varchar(50) DEFAULT NULL,
        `data` longtext DEFAULT NULL,
        PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;]], {}, function(rowsChanged) end)
    end
    Citizen.Wait(1000)
    local result = MySQL.query.await('SELECT data FROM 0r_clothing_image_data', {})
    if result and result[1] then
        for _, v in pairs(result) do
            if v.data == "face" then
                Config.UseDefaultClothImages.Skin = false
                Config.UseDefaultClothImages.Hair = false
                Config.UseDefaultClothImages.Makeup = false
            end
            if v.data == "body" then
                Config.UseDefaultClothImages.Body = false
            end
            if v.data == "accessories" then
                Config.UseDefaultClothImages.Accessories = false
            end
            if v.data == "clothing" then
                Config.UseDefaultClothImages.Clothing = false
            end
            if v.data == "all" then
                Config.UseDefaultClothImages.Skin = false
                Config.UseDefaultClothImages.Hair = false
                Config.UseDefaultClothImages.Makeup = false
                Config.UseDefaultClothImages.Clothing = false
                Config.UseDefaultClothImages.Accessories = false
                Config.UseDefaultClothImages.Body = false
            end
        end
    end
end)

function HasItem(source, name)
    local src = tonumber(source)
    if CoreName == "qb" then
        -- OX Inventory
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            local item = exports["ox_inventory"]:GetItem(src, name, nil, false)
            if item then
                return item.count
            end
        end
        -- QS Inventory
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            local items = exports['qs-inventory']:GetInventory(src)
            for item, data in pairs(items) do
                if item == name then
                    return item.amount
                end
            end
        end
        -- Codem Inventory
        local hasCodem = GetResourceState('codem-inventory') == 'started'
        if hasCodem then
            local items = exports['codem-inventory']:GetInventory(false, src)
            for k, v in pairs(items) do
                if v.name == name then
                    return v.count or v.amount
                end
            end
        end
        -- QB Inventory
        local qbPlayer = Core.Functions.GetPlayer(src)
        for _, item in pairs(qbPlayer.PlayerData.items) do
            if item.name == name then
                return item.amount
            end
        end
        return 0
    elseif CoreName == "esx" then
        -- OX Inventory
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            local item = exports["ox_inventory"]:GetItem(src, name, nil, false)
            if item then
                return item.count
            end
        end
        -- Codem Inventory
        local hasCodem = GetResourceState('codem-inventory') == 'started'
        if hasCodem then
            local items = exports['codem-inventory']:GetInventory(false, src)
            for k, v in pairs(items) do
                if v.name == name then
                    return v.count or v.amount
                end
            end
        end
        -- QS Inventory
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            local items = exports['qs-inventory']:GetInventory(src)
            for item, data in pairs(items) do
                if item == name then
                    return item.amount
                end
            end
        end
        -- ESX Inventory
        local player = Core.GetPlayerFromId(src)
        local hasItem = player.getInventoryItem(name)
        if hasItem then
            return hasItem.count
        end
        return 0
    end
end

function RemoveItem(source, name, amount)
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayer(source)
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            return exports['qs-inventory']:RemoveItem(source, name, amount, false, nil)
        end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            return exports.ox_inventory:RemoveItem(source, name, amount, nil, nil)
        end
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            return exports["codem-inventory"]:RemoveItem(source, name, amount, nil)
        end
        player.Functions.RemoveItem(name, amount, false, nil)
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerFromId(source)
        local hasQs = GetResourceState('qs-inventory') == 'started'
        if hasQs then
            return exports['qs-inventory']:RemoveItem(source, name, amount, false, nil)
        end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            return exports.ox_inventory:RemoveItem(source, name, amount, nil, nil)
        end
        local hasCodem = GetResourceState('codem-inventory') == 'started' or GetResourceState('mInventory') == 'started'
        if hasCodem then
            return exports["codem-inventory"]:RemoveItem(source, name, amount, nil)
        end
        player.removeInventoryItem(name, amount)
    end
end

if Config.GiveClothingMenu.Enable then
    Citizen.CreateThread(function()
        while not CoreReady do Citizen.Wait(500) end
        if CoreName == "qb" then
            Core.Commands.Add(Config.GiveClothingMenu.Command, Config.GiveClothingMenu.Description, {{name = "Player ID", help = "Write player id here"}}, false, function(source, args)
                local player = GetPlayer(tonumber(args[1]))
                if player then
                    TriggerClientEvent('qb-clothes:client:CreateFirstCharacter', tonumber(args[1]), true, true)
                end
            end, Config.GiveClothingMenu.Group)
            Core.Commands.Add(Config.GiveClothingMenu.RestrictedCommand, Config.GiveClothingMenu.RestrictedDescription, {{name = "Player ID", help = "Write player id here"}}, false, function(source, args)
                local player = GetPlayer(tonumber(args[1]))
                if player then
                    TriggerClientEvent('qb-clothes:client:CreateRestrictedCharacter', tonumber(args[1]), true)
                end
            end, Config.GiveClothingMenu.Group)
        elseif CoreName == "esx" then
            Core.RegisterCommand(Config.GiveClothingMenu.Command, Config.GiveClothingMenu.Group, function(xPlayer, args, _)
                local player = GetPlayer(tonumber(args.playeridnumber))
                if player then
                    TriggerClientEvent('esx_skin:openSaveableMenu', player.source, nil, nil, true, true)
                end
            end, true, {help = Config.GiveClothingMenu.Description, arguments = {
                {name = "playeridnumber", help = "Player ID", type = "number"}
            }})
            Core.RegisterCommand(Config.GiveClothingMenu.RestrictedCommand, Config.GiveClothingMenu.Group, function(xPlayer, args, _)
                local player = GetPlayer(tonumber(args.playeridnumber))
                if player then
                    TriggerClientEvent('esx_skin:openSaveableRestrictedMenu', player.source, nil, nil, true)
                end
            end, true, {help = Config.GiveClothingMenu.RestrictedDescription, arguments = {
                {name = "playeridnumber", help = "Player ID", type = "number"}
            }})
        end
    end)
end