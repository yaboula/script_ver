local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function GiveStarterItems(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    for _, v in pairs(QBCore.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "Class C Driver License"
        end
        Player.Functions.AddItem(v.item, v.amount, false, info)
    end
end

local function loadHouseData(src)
    local HouseGarages = {}
    local Houses = {}
    local result = MySQL.query.await('SELECT * FROM houselocations', {})
    if result[1] ~= nil then
        for _, v in pairs(result) do
            local owned = false
            if tonumber(v.owned) == 1 then
                owned = true
            end
            local garage = v.garage ~= nil and json.decode(v.garage) or {}
            Houses[v.name] = {
                coords = json.decode(v.coords),
                owned = owned,
                price = v.price,
                locked = true,
                adress = v.label,
                tier = v.tier,
                garage = garage,
                decorations = {},
            }
            HouseGarages[v.name] = {
                label = v.label,
                takeVehicle = garage,
            }
        end
    end
    TriggerClientEvent("qb-garages:client:houseGarageConfig", src, HouseGarages)
    TriggerClientEvent("qb-houses:client:setHouseConfig", src, Houses)
end

-- Commands

QBCore.Commands.Add("logout", "Logout of Character (Admin Only)", {}, false, function(source)
    local src = source
    QBCore.Player.Logout(src)
    TriggerClientEvent('nc-multicharacter:client:chooseChar', src)
end, "admin")

QBCore.Commands.Add("closeNUI", "Close Multi NUI", {}, false, function(source)
    local src = source
    TriggerClientEvent('nc-multicharacter:client:closeNUI', src)
end)

-- Events

RegisterNetEvent('nc-multicharacter:server:disconnect', function()
    local src = source
    DropPlayer(src, "You have disconnected from QBCore")
end)

RegisterNetEvent('nc-multicharacter:server:loadUserData', function(cData)
    local src = source
    -- [AUDIT AUD-001] H-03: Validacion de datos del cliente
    if type(cData) ~= 'table' or type(cData.citizenid) ~= 'string' then return end
    if QBCore.Player.Login(src, cData.citizenid) then
        print('^2[qb-core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        QBCore.Commands.Refresh(src)
        loadHouseData(src)

        -- Sync money-as-item
        if GetResourceState("mh-cashasitem") ~= 'missing' then
            exports['mh-cashasitem']:UpdateItem(src, 'cash')
            exports['mh-cashasitem']:UpdateItem(src, 'black_money')
        end

        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("qb-log:server:CreateLog", "joinleave", "Loaded", "green",
            "**".. GetPlayerName(src) .. "** ("..
            (QBCore.Functions.GetIdentifier(src, 'discord') or 'undefined') ..
            " |  ||"  .. (QBCore.Functions.GetIdentifier(src, 'ip') or 'undefined') .. "|| | " ..
            (QBCore.Functions.GetIdentifier(src, 'license') or 'undefined') .. " | " ..
            cData.citizenid .. " | " .. src .. ") loaded.."
        )
    end
end)

RegisterNetEvent('nc-multicharacter:server:createCharacter', function(data)
    local src = source
    -- [AUDIT AUD-001] H-03: Validacion de datos del cliente
    if type(data) ~= 'table' then return end
    if type(data.cid) ~= 'string' and type(data.cid) ~= 'number' then return end
    if type(data.firstname) ~= 'string' or type(data.lastname) ~= 'string' then return end
    if type(data.nationality) ~= 'string' or type(data.birthdate) ~= 'string' then return end
    if #data.firstname > 50 or #data.lastname > 50 or #data.nationality > 50 then return end
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    if QBCore.Player.Login(src, false, newData) then
        if Apartments.Starting then
            local randbucket = (GetPlayerPed(src) .. math.random(1,999))
            SetPlayerRoutingBucket(src, randbucket)
            print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
            QBCore.Commands.Refresh(src)
            loadHouseData(src)

            -- Sync money-as-item
            if GetResourceState("mh-cashasitem") ~= 'missing' then
                exports['mh-cashasitem']:UpdateItem(src, 'cash')
                exports['mh-cashasitem']:UpdateItem(src, 'black_money')
            end

            TriggerClientEvent("nc-multicharacter:client:closeNUI", src)
            TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
            GiveStarterItems(src)
        else
            print('^2[qb-core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
            QBCore.Commands.Refresh(src)
            loadHouseData(src)

            -- Sync money-as-item
            if GetResourceState("mh-cashasitem") ~= 'missing' then
                exports['mh-cashasitem']:UpdateItem(src, 'cash')
                exports['mh-cashasitem']:UpdateItem(src, 'black_money')
            end

            TriggerClientEvent("nc-multicharacter:client:closeNUIdefault", src)
            GiveStarterItems(src)
        end
    end
end)

RegisterNetEvent('nc-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    -- [AUDIT AUD-001] H-03: Validacion de datos del cliente
    if type(citizenid) ~= 'string' or #citizenid == 0 then return end
    QBCore.Player.DeleteCharacter(src, citizenid)
    TriggerClientEvent('QBCore:Notify', src, "Character deleted!" , "success")
end)

Citizen.CreateThread(function()
    if (GetCurrentResourceName() ~= "nc-multicharacter") then
        print("[" .. GetCurrentResourceName() .. "] " .. "IMPORTANT: This resource must be named nc-multicharacter for it to work properly!");
        print("[" .. GetCurrentResourceName() .. "] " .. "IMPORTANT: This resource must be named nc-multicharacter for it to work properly!");
        print("[" .. GetCurrentResourceName() .. "] " .. "IMPORTANT: This resource must be named nc-multicharacter for it to work properly!");
        print("[" .. GetCurrentResourceName() .. "] " .. "IMPORTANT: This resource must be named nc-multicharacter for it to work properly!");
    end
end)

Citizen.CreateThread(function()
    local resourceName = "^2 NCHubMulti Started ("..GetCurrentResourceName()..")"
    print("\n^1----------------------------------------------------------------------------------^7")
    print(resourceName)
    print("^1----------------------------------------------------------------------------------^7")
end)

-- Callbacks

QBCore.Functions.CreateCallback("nc-multicharacter:server:GetUserCharacters", function(source, cb)
    local src = source
    local license = QBCore.Functions.GetIdentifier(src, 'license')

    MySQL.query('SELECT * FROM players WHERE license = ?', {license}, function(result)
        cb(result)
    end)
end)

-- [AUDIT AUD-001] H-02: Callback GetServerLogs ELIMINADO
-- Exponia SELECT * FROM server_logs a cualquier cliente sin autenticacion
-- Si se necesita acceso a logs, usar txAdmin o herramienta dedicada

QBCore.Functions.CreateCallback("nc-multicharacter:server:GetNumberOfCharacters", function(source, cb)
    local src = source
    local license = QBCore.Functions.GetIdentifier(src, 'license')
    local numOfChars = 0

    if next(Config.PlayersNumberOfCharacters) then
        for _, v in pairs(Config.PlayersNumberOfCharacters) do
            if v.license == license then
                numOfChars = v.numberOfChars
                break
            else
                numOfChars = Config.DefaultNumberOfCharacters
            end
        end
    else
        numOfChars = Config.DefaultNumberOfCharacters
    end
    cb(numOfChars)
end)

QBCore.Functions.CreateCallback("nc-multicharacter:server:setupCharacters", function(source, cb)
    local license = QBCore.Functions.GetIdentifier(source, 'license')
    local plyChars = {}
    MySQL.query('SELECT * FROM players WHERE license = ?', {license}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)
            plyChars[#plyChars+1] = result[i]
        end
        cb(plyChars)
    end)
end)

QBCore.Functions.CreateCallback("nc-multicharacter:server:getSkin", function(_, cb, cid)
    local result = MySQL.query.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1})
    if result[1] ~= nil then
        cb(result[1].model, result[1].skin)
    else
        cb(nil)
    end
end)
