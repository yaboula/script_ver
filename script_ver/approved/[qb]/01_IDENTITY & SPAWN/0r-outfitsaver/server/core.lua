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

function Notify(source, text, length, type)
    local src = tonumber(source)
    if CoreName == "qb" then
        Core.Functions.Notify(src, text, type, length)
    elseif CoreName == "esx" then
        local player = Core.GetPlayerFromId(src)
        player.showNotification(text)
    end
end

Config.ServerCallbacks = {}
function CreateCallback(name, cb)
    Config.ServerCallbacks[name] = cb
end

function TriggerCallback(name, source, cb, ...)
    if not Config.ServerCallbacks[name] then return end
    Config.ServerCallbacks[name](source, cb, ...)
end

RegisterNetEvent('0r-outfitsaver:server:triggerCallback', function(name, ...)
    local src = source
    TriggerCallback(name, src, function(...)
        TriggerClientEvent('0r-outfitsaver:client:triggerCallback', src, name, ...)
    end, ...)
end)

Citizen.CreateThread(function()
    local table = MySQL.query.await("SHOW TABLES LIKE '0r_clothing_saved_outfits'", {}, function(rowsChanged) end)
    if not next(table) then
        MySQL.query.await([[CREATE TABLE IF NOT EXISTS `0r_clothing_saved_outfits` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `identifier` varchar(50) DEFAULT NULL,
        `outfitname` varchar(50) NOT NULL,
        `skin` text DEFAULT NULL,
        `model` varchar(50) NOT NULL,
        `tags` longtext DEFAULT NULL,
        PRIMARY KEY (`id`),
        KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]], {}, function(rowsChanged) end)
    end
end)

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

function getCharSkin(cid)
    local p = promise:new()
    if GetResourceState('qb-clothing') == "started" or GetResourceState('fivem-appearance') == "started" or GetResourceState('pa-clothing') == "started" or GetResourceState('0r-clothing') == "started" then
        if CoreName == "qb" then
            MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1}, function(cloth)
                if cloth[1] then
                    p:resolve({model = tonumber(cloth[1].model), skin = json.decode(cloth[1].skin)})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
        elseif CoreName == "esx" then
            MySQL.Async.fetchAll('SELECT skin, sex FROM users WHERE identifier = ?', {cid}, function(data)
                if data[1] then
                    local skin =  json.decode(data[1].skin)
                    if skin.model then
                        model = skin.model
                    elseif data[1].sex == 1 then
                        model = "mp_f_freemode_01"
                    else
                        model = "mp_m_freemode_01"
                    end
                    p:resolve({model = model, skin = skin})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
        end
        return Citizen.Await(p)
    end
    if GetResourceState('illenium-appearance') == "started" then
        if CoreName == "qb" then
            MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1}, function(cloth)
                if cloth[1] then
                    p:resolve({model = tonumber(cloth[1].model), skin = json.decode(cloth[1].skin)})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
            return Citizen.Await(p)
        elseif CoreName == "esx" then
            MySQL.Async.fetchAll('SELECT sex, skin FROM users WHERE identifier = ?', {cid}, function(cloth)
                if cloth[1] then
                    local model = ""
                    local skin = json.decode(cloth[1].skin)
                    if skin.model then
                        model = skin.model
                    elseif cloth[1].sex == 1 then
                        model = "mp_f_freemode_01"
                    else
                        model = "mp_m_freemode_01"
                    end
                    p:resolve({model = model, skin = skin})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
            return Citizen.Await(p)
        end
    end
    if GetResourceState('esx_skin') == "started" then
        MySQL.Async.fetchAll('SELECT sex, skin FROM users WHERE identifier = ?', {cid}, function(cloth)
            if cloth[1] then
                local model = ""
                local skin = json.decode(cloth[1].skin)
                if skin.model then
                    model = skin.model
                elseif cloth[1].sex == 1 then
                    model = "mp_f_freemode_01"
                else
                    model = "mp_m_freemode_01"
                end
                p:resolve({model = model, skin = skin})
            else
                p:resolve({model = nil, skin = nil})
            end
        end)
        return Citizen.Await(p)
    end
    if GetResourceState('fivem-appearance') == "started" then
        if CoreName == "esx" then
            MySQL.Async.fetchAll('SELECT sex, skin FROM users WHERE identifier = ?', {cid}, function(cloth)
                if cloth[1] then
                    local model = ""
                    local skin = json.decode(cloth[1].skin)
                    if skin.model then
                        model = skin.model
                    elseif cloth[1].sex == 1 then
                        model = "mp_f_freemode_01"
                    else
                        model = "mp_m_freemode_01"
                    end
                    p:resolve({model = model, skin = skin})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
            return Citizen.Await(p)
        elseif CoreName == "qb" then
            MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1}, function(cloth)
                if cloth[1] then
                    p:resolve({model = tonumber(cloth[1].model), skin = json.decode(cloth[1].skin)})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
            return Citizen.Await(p)
        end
    end
    if GetResourceState('bp_charcreate') == "started" then
        if CoreName == "esx" then
            MySQL.Async.fetchAll('SELECT sex, skin FROM users WHERE identifier = ?', {cid}, function(cloth)
                if cloth[1] then
                    local model = ""
                    local skin = json.decode(cloth[1].skin)
                    if skin.model then
                        model = skin.model
                    elseif cloth[1].sex == 1 then
                        model = "mp_f_freemode_01"
                    else
                        model = "mp_m_freemode_01"
                    end
                    p:resolve({model = model, skin = skin})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
            return Citizen.Await(p)
        elseif CoreName == "qb" then
            MySQL.Async.fetchAll('SELECT * FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1}, function(cloth)
                if cloth[1] then
                    p:resolve({model = tonumber(cloth[1].model), skin = json.decode(cloth[1].skin)})
                else
                    p:resolve({model = nil, skin = nil})
                end
            end)
            return Citizen.Await(p)
        end
    end
    p:resolve({model = nil, skin = nil})
    return Citizen.Await(p)
end