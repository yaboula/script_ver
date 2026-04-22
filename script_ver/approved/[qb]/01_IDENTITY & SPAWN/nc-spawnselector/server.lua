local QBCore = exports['qb-core']:GetCoreObject()
QBCore.Functions.CreateCallback('qb-spawn:server:getOwnedHouses', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then cb(nil) return end

    -- [AUDIT AUD-003] Nunca confiar en cid enviado por cliente.
    local cid = Player.PlayerData.citizenid
    if type(cid) ~= 'string' or cid == '' then cb(nil) return end

    local houses = exports.oxmysql:executeSync("SELECT * FROM player_houses WHERE identifier = ? OR JSON_CONTAINS(keyholders, JSON_ARRAY(?))", {cid, cid})
    if houses[1] ~= nil then
        cb(houses)
    else
        cb(nil)
    end
end)

RegisterNetEvent("orangutan:spawn:getHouseCoords", function(houseName)
    local src = source
    -- [AUDIT AUD-003] Validaciones de tipo/rango y ownership server-side.
    if type(houseName) ~= 'string' then return end
    if #houseName == 0 or #houseName > 64 then return end

    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    if type(cid) ~= 'string' or cid == '' then return end

    local owned = exports.oxmysql:executeSync("SELECT house FROM player_houses WHERE house = ? AND (identifier = ? OR JSON_CONTAINS(keyholders, JSON_ARRAY(?))) LIMIT 1", {houseName, cid, cid})
    if not owned or not owned[1] then return end

    local house = exports.oxmysql:executeSync("SELECT * FROM houselocations WHERE name = ?", {houseName})
    if house[1] then
        local ped = GetPlayerPed(src)
        local data = json.decode(house[1].coords)
        if not data or not data.enter then return end
        local x, y, z = data.enter.x, data.enter.y, data.enter.z
        if type(x) ~= 'number' or type(y) ~= 'number' or type(z) ~= 'number' then return end
        SetEntityCoords(ped, x, y, z, false, false, false, true)
    end
end)

QBCore.Commands.Add("addloc", "Add location for spawn (God Only)", {}, false, function(source)
    local src = source
    TriggerClientEvent('qb-spawn:client:OpenUIForSelectCoord', src)
end, "god")
