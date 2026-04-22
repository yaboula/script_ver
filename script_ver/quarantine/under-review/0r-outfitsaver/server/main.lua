local function isNonEmptyString(v, minLen, maxLen)
    if type(v) ~= 'string' then return false end
    local len = #v
    return len >= (minLen or 1) and len <= (maxLen or 64)
end

local function sanitizeTags(tags)
    if type(tags) ~= 'table' then return nil end
    local out = {}
    for _, tag in pairs(tags) do
        if type(tag) == 'string' then
            local trimmed = tag:gsub('^%s+', ''):gsub('%s+$', '')
            if trimmed ~= '' and #trimmed <= 32 then
                out[#out + 1] = trimmed
            end
        end
        if #out >= 20 then break end
    end
    return out
end

CreateCallback('0r-outfitsaver:getSavedOutfits:server', function(source, cb)
    local src = source
    local myOutfits = MySQL.query.await('SELECT id, outfitname, tags FROM 0r_clothing_saved_outfits WHERE identifier = ?', {GetPlayerLicenseCore(src)})
    if myOutfits and myOutfits[1] and next(myOutfits) then
        cb(myOutfits)
    else
        cb({data = "empty"})
    end
end)

CreateCallback('0r-outfitsaver:getSavedOutfitSkinById:server', function(source, cb, id)
    local src = source
    local outfitId = tonumber(id)
    if not outfitId or outfitId < 1 then
        cb({})
        return
    end
    local myOutfits = MySQL.query.await('SELECT skin, model FROM 0r_clothing_saved_outfits WHERE id = ? AND identifier = ?', {outfitId, GetPlayerLicenseCore(src)})
    if myOutfits and myOutfits[1] and next(myOutfits) then
        cb({skin = json.decode(myOutfits[1].skin), model = myOutfits[1].model})
    else
        cb({})
    end
end)

CreateCallback('0r-outfitsaver:getPlayerSkin:server', function(source, cb)
    local src = source
    local skin = getCharSkin(GetPlayerLicenseCore(src))
    if skin and next(skin) then
        cb(skin)
    else
        cb({})
    end
end)

RegisterNetEvent('0r-outfitsaver:saveOutfit:server', function(outfitName, model, tags)
    local src = source
    if not isNonEmptyString(outfitName, 1, 50) then return end
    if type(model) ~= 'string' and type(model) ~= 'number' then return end
    model = tostring(model)
    if #model > 60 then return end
    local safeTags = sanitizeTags(tags)
    if not safeTags then return end
    local skin = getCharSkin(GetPlayerLicenseCore(src))
    if not skin or type(skin) ~= 'table' or not next(skin) or type(skin.skin) ~= 'table' then return end
    MySQL.insert('INSERT INTO 0r_clothing_saved_outfits (identifier, outfitname, skin, model, tags) VALUES (?, ?, ?, ?, ?)', {
        GetPlayerLicenseCore(src),
        outfitName,
        json.encode(skin.skin),
        model,
        json.encode(safeTags)
    }, function()
        local result = MySQL.query.await('SELECT id, outfitname, tags FROM 0r_clothing_saved_outfits WHERE identifier = ?', {GetPlayerLicenseCore(src)})
        if result[1] ~= nil then
            TriggerClientEvent('0r-outfitsaver:reloadOutfits:client', src, result)
        else
            TriggerClientEvent('0r-outfitsaver:reloadOutfits:client', src, nil)
        end
    end)
end)

RegisterNetEvent('0r-outfitsaver:deleteOutfit:server', function(outfitName, outfitId)
    local src = source
    local id = tonumber(outfitId)
    if not id or id < 1 then return end
    if not isNonEmptyString(outfitName, 1, 50) then return end
    MySQL.query('DELETE FROM 0r_clothing_saved_outfits WHERE identifier = ? AND outfitname = ? AND id = ?', {
        GetPlayerLicenseCore(src),
        outfitName,
        id
    }, function()
        local result = MySQL.query.await('SELECT id, outfitname, tags FROM 0r_clothing_saved_outfits WHERE identifier = ?', {GetPlayerLicenseCore(src)})
        if result[1] ~= nil then
            TriggerClientEvent('0r-outfitsaver:reloadOutfits:client', src, result)
        else
            TriggerClientEvent('0r-outfitsaver:reloadOutfits:client', src, nil)
        end
    end)
end)

RegisterNetEvent('0r-outfitsaver:saveSkin:server', function(model, skin)
    local src = source
    local player = GetPlayer(src)
    if not player then return end
    if type(model) ~= 'string' and type(model) ~= 'number' then return end
    if type(skin) ~= 'table' then return end
    model = tostring(model)
    if #model > 60 then return end
    if CoreName == "qb" then
        MySQL.query('DELETE FROM playerskins WHERE citizenid = ?', {player.PlayerData.citizenid}, function()
            MySQL.insert('INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, ?)', {
                player.PlayerData.citizenid,
                model,
                json.encode(skin),
                1
            })
        end)
    elseif CoreName == "esx" then
        MySQL.Async.execute('UPDATE users SET `skin` = @skin WHERE identifier = @identifier', {
            ['@skin'] = json.encode(skin),
            ['@identifier'] = player.identifier
        })
    end
end)

RegisterNetEvent('0r-outfitsaver:editOutfit:server', function(id, name, tags)
    local src = source
    local outfitId = tonumber(id)
    if not outfitId or outfitId < 1 then return end
    if not isNonEmptyString(name, 1, 50) then return end
    local safeTags = sanitizeTags(tags)
    if not safeTags then return end
    local outfit = MySQL.query.await('SELECT id FROM 0r_clothing_saved_outfits WHERE identifier = ? AND id = ?', {GetPlayerLicenseCore(src), outfitId})
    if outfit and outfit[1] and next(outfit) then
        MySQL.update("UPDATE 0r_clothing_saved_outfits SET outfitname = @outfitname, tags = @tags WHERE id = @id", {
            ["@outfitname"] = name,
            ["@tags"] = json.encode(safeTags),
            ["@id"] = outfitId,
        })
    end
    Citizen.Wait(500)
    local result = MySQL.query.await('SELECT id, outfitname, tags FROM 0r_clothing_saved_outfits WHERE identifier = ?', {GetPlayerLicenseCore(src)})
    if result[1] ~= nil then
        TriggerClientEvent('0r-outfitsaver:reloadOutfits:client', src, result)
    else
        TriggerClientEvent('0r-outfitsaver:reloadOutfits:client', src, nil)
    end
end)

RegisterNetEvent('0r-outfitsaver:openMenu:server', function()
    TriggerClientEvent('0r-outfitsaver:openMenu:client', source)
end)