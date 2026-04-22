
local QBCore = exports['qb-core']:GetCoreObject()

local function sanitizeMessage(message, maxLen)
    if type(message) ~= 'string' then return nil end
    local trimmed = message:gsub('^%s+', ''):gsub('%s+$', '')
    if trimmed == '' then return nil end
    if #trimmed > (maxLen or 300) then
        trimmed = trimmed:sub(1, maxLen or 300)
    end
    return trimmed
end

local function getCharacterName(src)
    local player = QBCore.Functions.GetPlayer(src)
    if player and player.PlayerData and player.PlayerData.charinfo then
        local c = player.PlayerData.charinfo
        local firstname = c.firstname or ''
        local lastname = c.lastname or ''
        local full = (firstname .. ' ' .. lastname):gsub('^%s+', ''):gsub('%s+$', '')
        if full ~= '' then
            return full
        end
    end

    return GetPlayerName(src) or ('Player ' .. tostring(src))
end

function getIdentity(source)
    local fullname = getCharacterName(source)
    return {
        firstname = fullname,
        lastname = ''
    }
end

AddEventHandler("chatMessage", function(source, color, message)
    local src = source
    if type(message) ~= 'string' then return end
    args = stringsplit(message, " ")
    CancelEvent()
    if string.find(args[1], "/") then
        local cmd = args[1]
        table.remove(args, 1)
    end
    TriggerEvent('tg-logs:server:createLog', 'chat', 'Chat message:', message, src)
end)

RegisterServerEvent('chat:server:ServerPSA')
AddEventHandler('chat:server:ServerPSA', function(message)
    local src = source
    if src ~= 0 and not QBCore.Functions.HasPermission(src, 'admin') then
        return
    end
    local safeMessage = sanitizeMessage(message, 300)
    if not safeMessage then
        return
    end

    TriggerClientEvent('chat:addMessage', -1, {
        template = '<div class="chat-message server">SERVER: {0}</div>',
        args = { safeMessage }
    })
    CancelEvent()
end)

RegisterServerEvent('911')
AddEventHandler('911', function(_, _, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    if not safeMessage then
        return
    end

    local fal = getCharacterName(src)
    TriggerClientEvent('chat:EmergencySend911', -1, src, fal, safeMessage)
end)

RegisterServerEvent('001')
AddEventHandler('001', function(_, _, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    if not safeMessage then
        return
    end

    local fal = getCharacterName(src)
    TriggerClientEvent('chat:EmergencySend001', -1, src, fal, safeMessage)
end)


RegisterServerEvent('911r')
AddEventHandler('911r', function(_, _, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    if not safeMessage then
        return
    end

    local fal = getCharacterName(src)
    TriggerClientEvent('chat:EmergencySend911r', -1, src, fal, safeMessage)
end)



RegisterServerEvent('chat:server:911source')
AddEventHandler('chat:server:911source', function(_, _, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    if not safeMessage then
        return
    end

	local fal = getCharacterName(src)
    TriggerClientEvent('chat:addMessage', src, {
        template = '<div class="chat-message emergency">911 {0} ({1}): {2} </div>',
        args = { fal, src, safeMessage }
    })
    CancelEvent()
end)

RegisterServerEvent('chat:server:911r')
AddEventHandler('chat:server:911r', function(target, caller, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    local safeTarget = tonumber(target)
    if not safeMessage or not safeTarget or not GetPlayerName(safeTarget) then
        return
    end

	local fal = getCharacterName(src)
    TriggerClientEvent('chat:addMessage', safeTarget, {
        template = '<div class="chat-message emergency">911r {0} : {1} </div>',
        args = { fal, safeMessage }
    })
    CancelEvent()
end)

RegisterServerEvent('chat:server:001r')
AddEventHandler('chat:server:001r', function(target, caller, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    local safeTarget = tonumber(target)
    if not safeMessage or not safeTarget or not GetPlayerName(safeTarget) then
        return
    end

	local fal = getCharacterName(src)
    TriggerClientEvent('chat:addMessage', safeTarget, {
        template = '<div class="chat-message emergency">001r {0} : {1} </div>',
        args = { fal, safeMessage }
    })
    CancelEvent()
end)


RegisterServerEvent('chat:server:311r')
AddEventHandler('chat:server:311r', function(target, caller, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    local safeTarget = tonumber(target)
    if not safeMessage or not safeTarget or not GetPlayerName(safeTarget) then
        return
    end

	local fal = getCharacterName(src)
    TriggerClientEvent('chat:addMessage', safeTarget, {
        template = '<div class="chat-message nonemergency">311r {0}: {1} </div>',
        args = { fal, safeMessage }
    })
    CancelEvent()
end)

RegisterServerEvent('chat:server:311source')
AddEventHandler('chat:server:311source', function(_, _, msg)
    local src = source
    local safeMessage = sanitizeMessage(msg, 300)
    if not safeMessage then
        return
    end

	local fal = getCharacterName(src)
    TriggerClientEvent('chat:addMessage', src, {
        template = '<div class="chat-message nonemergency">311 {0} ({1}): {2} </div>',
        args = { fal, src, safeMessage }
    })
    CancelEvent()
end)

function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
    sep = " "
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end