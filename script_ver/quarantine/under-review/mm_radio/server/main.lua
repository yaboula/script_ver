local channels = {}
local jammer = {}
local batteryData = {}
local spawnedDefaultJammer = false

local function toNumber(value)
    local n = tonumber(value)
    if not n then return nil end
    if n ~= n then return nil end
    if n == math.huge or n == -math.huge then return nil end
    return n
end

local function normalizeChannel(value)
    local channel = toNumber(value)
    if not channel then return nil end
    if channel < 1 or channel > Shared.MaxFrequency then return nil end
    return channel
end

local function extractPlayerData(src)
    local player = Framework.core.GetPlayer(src)
    if not player then return nil end

    local jobName = player.job and player.job.name or nil
    local gangName = player.gang and player.gang.name or nil
    local onDuty = player.job and (player.job.onduty or player.job.onDuty) or false
    return player, jobName, gangName, onDuty
end

local function hasJammerPermission(src)
    if not Shared.Jammer.permission or #Shared.Jammer.permission == 0 then return true end
    local _, jobName, gangName = extractPlayerData(src)
    if not jobName and not gangName then return false end
    return lib.table.contains(Shared.Jammer.permission, jobName) or lib.table.contains(Shared.Jammer.permission, gangName)
end

local function hasRestrictedChannelAccess(src, channel)
    local restricted = Shared.RestrictedChannels[math.floor(channel)]
    if not restricted then return true end

    local _, jobName, gangName, onDuty = extractPlayerData(src)
    if restricted.type == 'job' then
        return jobName and lib.table.contains(restricted.name, jobName) and onDuty
    elseif restricted.type == 'gang' then
        return gangName and lib.table.contains(restricted.name, gangName)
    end

    return false
end

local function getCharacterName(src)
    local player = Framework.core.GetPlayer(src)
    if not player then
        return GetPlayerName(src) or ('Player ' .. tostring(src))
    end

    local firstname = player.charinfo and player.charinfo.firstname or nil
    local lastname = player.charinfo and player.charinfo.lastname or nil
    if firstname and lastname then
        return (firstname .. ' ' .. lastname)
    end

    return GetPlayerName(src) or ('Player ' .. tostring(src))
end

local function sanitizeAllowedChannels(raw)
    if type(raw) ~= 'table' then return {} end
    local result = {}
    local seen = {}
    for i = 1, #raw do
        local channel = normalizeChannel(raw[i])
        if channel and not seen[channel] then
            seen[channel] = true
            result[#result + 1] = channel
            if #result >= 64 then
                break
            end
        end
    end
    return result
end

local function findJammerById(id)
    for i = 1, #jammer do
        if jammer[i].id == id then
            return i, jammer[i]
        end
    end
end

local function isNearJammer(src, jamData, maxDistance)
    local ped = GetPlayerPed(src)
    if not ped or ped <= 0 then return false end
    local coords = GetEntityCoords(ped)
    local target = vector3(jamData.coords.x, jamData.coords.y, jamData.coords.z)
    return #(coords - target) <= (maxDistance or 8.0)
end

local function getPlayerRadioIds(src)
    local ids = {}
    local player = Framework.core.GetPlayer(src)
    if not player or not player.getItem then
        return ids
    end

    for i = 1, #Shared.RadioItem do
        local item = player.getItem(Shared.RadioItem[i])
        if item then
            local meta = item.metadata or item.info or {}
            if type(meta.radioId) == 'string' and meta.radioId ~= '' then
                ids[meta.radioId] = true
            end
        end
    end

    return ids
end

RegisterNetEvent('mm_radio:server:consumeBattery', function(data)
    if type(data) ~= 'table' then return end
    local ownedIds = getPlayerRadioIds(source)
    for i=1, #data do
        local id = data[i]
        if type(id) ~= 'string' or not ownedIds[id] then
            goto continue
        end
        if not batteryData[id] then batteryData[id] = 100 end
        local battery = batteryData[id] - Shared.Battery.consume
        batteryData[id] = math.max(battery, 0)
        if batteryData[id] == 0 then
            TriggerClientEvent('mm_radio:client:nocharge', source)
        end
        ::continue::
    end
end)

RegisterNetEvent('mm_radio:server:rechargeBattery', function()
    local src = source
    local player = Framework.core.GetPlayer(src)
    if not player then return end

    local cell = player.getItem('radiocell')
    if not cell then return end

    for i=1, #Shared.RadioItem do
        local item = player.getItem(Shared.RadioItem[i])
        if item then
            local id = item.metadata?.radioId or false
            if not id then return end
            batteryData[id] = 100
            player.removeItem('radiocell', 1)
            break
        end
    end
end)

RegisterNetEvent('mm_radio:server:spawnobject', function(data)
    local src = source
	if type(data) ~= 'table' then return end
    if not hasJammerPermission(src) then return end

    local coords = data.coords
    if type(coords) ~= 'vector4' and type(coords) ~= 'table' then return end

    local x = toNumber(coords.x)
    local y = toNumber(coords.y)
    local z = toNumber(coords.z)
    local w = toNumber(coords.w) or 0.0
    if not x or not y or not z then return end

    local id = tostring(data.id or '')
    if id == '' then return end
    if findJammerById(id) then return end

    local canRemove = data.canRemove == true

    local range = toNumber(data.range) or Shared.Jammer.range.default
    if range < Shared.Jammer.range.min or range > Shared.Jammer.range.max then
        range = Shared.Jammer.range.default
    end

    local allowedChannels = sanitizeAllowedChannels(data.allowedChannels)

	local player = Framework.core.GetPlayer(src)
	if not player then return end
    if canRemove and not player.getItem('jammer') then
        return
    end

	CreateThread(function()
		local entity = CreateObject(joaat(Shared.Jammer.model), x, y, z, true, true, false)
		while not DoesEntityExist(entity) do Wait(50) end
		SetEntityHeading(entity, w)
        local netobj = NetworkGetNetworkIdFromEntity(entity)
        if canRemove then
            player.removeItem('jammer', 1)
        end
        TriggerClientEvent('mm_radio:client:syncobject', -1, {
            enable = true,
            object = netobj,
            coords = vec4(x, y, z, w),
            id = id,
            range = range,
            allowedChannels = allowedChannels,
            canRemove = canRemove,
            canDamage = data.canDamage == true
        })
        jammer[#jammer+1] = {
            enable = true,
            entity = entity,
            id = id,
            coords = vec4(x, y, z, w),
            range = range,
            allowedChannels = allowedChannels,
            canRemove = canRemove,
            canDamage = data.canDamage == true,
            owner = canRemove and src or 0
        }
	end)
end)

RegisterNetEvent('mm_radio:server:togglejammer', function(id)
    local src = source
    if not hasJammerPermission(src) then return end
    local idx, jamData = findJammerById(tostring(id))
    if not idx or not jamData then return end
    if not isNearJammer(src, jamData, 8.0) then return end

    jammer[idx].enable = not jammer[idx].enable
    TriggerClientEvent('mm_radio:client:togglejammer', -1, jamData.id, jammer[idx].enable)
end)

RegisterNetEvent('mm_radio:server:removejammer', function(id, isDamaged)
    local src = source
	if not hasJammerPermission(src) then return end
	local idx, jamData = findJammerById(tostring(id))
    if not idx or not jamData then return end
    if not isNearJammer(src, jamData, 8.0) then return end

	local currentDamaged = GetEntityHealth(jamData.entity) <= 0
	if jamData.canRemove and jamData.owner ~= 0 and jamData.owner ~= src then
		return
	end

	CreateThread(function()
		DeleteEntity(jamData.entity)
		TriggerClientEvent('mm_radio:client:removejammer', -1, jamData.id)
		table.remove(jammer, idx)
		if not currentDamaged then
			local player = Framework.core.GetPlayer(src)
			if player then
				player.addItem('jammer', 1)
			end
		end
	end)
end)

RegisterNetEvent('mm_radio:server:changeJammerRange', function(id, range)
    local src = source
    if not hasJammerPermission(src) then return end

    local idx, jamData = findJammerById(tostring(id))
    if not idx or not jamData then return end
    if not isNearJammer(src, jamData, 8.0) then return end

    local safeRange = toNumber(range)
    if not safeRange then return end
    if safeRange < Shared.Jammer.range.min or safeRange > Shared.Jammer.range.max then
        return
    end

    jammer[idx].range = safeRange
    TriggerClientEvent('mm_radio:client:changeJammerRange', -1, jamData.id, safeRange)
end)

RegisterNetEvent('mm_radio:server:removeallowedchannel', function(id, allowedChannels)
    local src = source
    if not hasJammerPermission(src) then return end
    local idx, jamData = findJammerById(tostring(id))
    if not idx or not jamData then return end
    if not isNearJammer(src, jamData, 8.0) then return end

    local safeChannels = sanitizeAllowedChannels(allowedChannels)
    jammer[idx].allowedChannels = safeChannels
    TriggerClientEvent('mm_radio:client:removeallowedchannel', -1, jamData.id, safeChannels)
end)

RegisterNetEvent('mm_radio:server:addallowedchannel', function(id, allowedChannels)
    local src = source
    if not hasJammerPermission(src) then return end
    local idx, jamData = findJammerById(tostring(id))
    if not idx or not jamData then return end
    if not isNearJammer(src, jamData, 8.0) then return end

    local safeChannels = sanitizeAllowedChannels(allowedChannels)
    jammer[idx].allowedChannels = safeChannels
    TriggerClientEvent('mm_radio:client:addallowedchannel', -1, jamData.id, safeChannels)
end)

RegisterNetEvent('mm_radio:server:addToRadioChannel', function(channel, username)
    local src = source
    channel = normalizeChannel(channel)
    if not channel then return end
    if not hasRestrictedChannelAccess(src, channel) then return end

    if not channels[channel] then
        channels[channel] = {}
    end

    channels[channel][tostring(src)] = {name = getCharacterName(src), isTalking = false}
    TriggerClientEvent('mm_radio:client:radioListUpdate', -1, channels[channel], channel)
end)

RegisterNetEvent('mm_radio:server:removeFromRadioChannel', function(channel)
    local src = source
	channel = normalizeChannel(channel)
    if not channel then return end

    if not channels[channel] then return end
    channels[channel][tostring(src)] = nil
    TriggerClientEvent('mm_radio:client:radioListUpdate', -1, channels[channel], channel)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    for i=1, #jammer do
        DeleteEntity(jammer[i].entity)
    end
    jammer = {}
    SaveResourceFile(GetCurrentResourceName(), 'battery.json', json.encode(batteryData), -1)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    batteryData = json.decode(LoadResourceFile(GetCurrentResourceName(), 'battery.json')) or {}
end)

AddEventHandler("playerDropped", function()
    local plyid = source
    for id, channel in pairs (channels) do
        if channel[tostring(plyid)] then
            channels[id][tostring(plyid)] = nil
            TriggerClientEvent('mm_radio:client:radioListUpdate', -1, channels[id], id)
            break
        end
    end
end)

RegisterNetEvent("mm_radio:server:createdefaultjammer", function()
    if spawnedDefaultJammer then return end
    for i=1, #Shared.Jammer.default do
        local data = Shared.Jammer.default[i]
        TriggerEvent('mm_radio:server:spawnobject', {
            coords = data.coords,
            id = tostring(data.id),
            range = data.range,
            allowedChannels = data.allowedChannels,
            canRemove = false,
            canDamage = data.canDamage
        })
    end
    spawnedDefaultJammer = true
end)

local function SetRadioData(src, slot)
    local player = Framework.core.GetPlayer(src)
    local radioId = player.id .. math.random(1000, 9999)
    local name = player.charinfo.firstname .. " " .. player.charinfo.lastname
    if Shared.Inventory == 'ox' then
        exports.ox_inventory:SetMetadata(src, slot, { radioId = radioId, name = name })
        return radioId
    elseif Shared.Inventory == 'qb' or Shared.Inventory == 'ps' then
        local items = player.items
        local item = items[slot]
        if item  then
            item.info = item.info or {}
            item.info ={
                radioId = radioId,
                name = name
            }
            local invResourceName = exports.bl_bridge:getFramework('inventory')
            exports[invResourceName]:SetInventory(src, items)
            return radioId
        end
        return false
    elseif Shared.Inventory == 'qs' then
        exports['qs-inventory']:SetItemMetadata(src, slot, { radioId = radioId, name = name })
        return radioId
    else
        return false
    end
end

local function GetSlotWithRadio(source)
    local player = Framework.core.GetPlayer(source)
    for i=1, #Shared.RadioItem do
        local item = player.getItem(Shared.RadioItem[i])
        if item then
            return item.slot
        end
    end
end

lib.callback.register('mm_radio:server:getradiodata', function(source, slot)
    if not Shared.Inventory or not Shared.Battery.state then return 100, 'PERSONAL' end
    local battery = 100
    local id = nil
    local player = Framework.core.GetPlayer(source)
    if not player then return battery, id end
    if not slot then
        slot = GetSlotWithRadio(source)
    end
    local slotData = player.items[slot]
    if slotData and lib.table.contains(Shared.RadioItem, slotData.name) then
        local id = false
        if not slotData.metadata?.radioId then
            id = SetRadioData(source, slot)
        else
            id = slotData.metadata?.radioId
        end
        battery = id and batteryData[id] or 100
    end
    return battery, id
end)

lib.callback.register('mm_radio:server:getjammer', function()
    return jammer
end)

if Shared.UseCommand or not Shared.Inventory then
    if not Shared.Ready then return end
    lib.addCommand('radio', {
        help = 'Open Radio Menu',
        params = {},
    }, function(source)
        TriggerClientEvent('mm_radio:client:use', source, 100)
    end)
    lib.addCommand('jammer', {
        help = 'Setup Jammer',
        params = {},
    }, function(source)
        TriggerClientEvent('mm_radio:client:usejammer', source)
    end)
    lib.addCommand('rechargeradio', {
        help = 'Recharge Radio Battery',
        params = {},
    }, function(source)
        TriggerClientEvent('mm_radio:client:recharge', source)
    end)
end

lib.addCommand('remradiodata', {
    help = 'Remove Radio Data',
    params = {},
}, function(source)
    TriggerClientEvent('mm_radio:client:removedata', source)
end)

lib.versionCheck('SOH69/mm_radio')

if Shared.Ready then
    for i=1, #Shared.RadioItem do
        Framework.core.RegisterUsableItem(Shared.RadioItem[i], function(source, slot, metadata)
            TriggerClientEvent('mm_radio:client:use', source, slot, metadata)
        end)
    end

    if Shared.Jammer.state then
        Framework.core.RegisterUsableItem('jammer', function(source)
            TriggerClientEvent('mm_radio:client:usejammer', source)
        end)
    end

    if Shared.Battery.state then
        Framework.core.RegisterUsableItem('radiocell', function(source)
            TriggerClientEvent('mm_radio:client:recharge', source)
        end)
    end
else
    return error('Cannot Start Resource, MISSING DEPENDENCIES', 0)
end