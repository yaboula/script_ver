QBCore.Commands = {}
QBCore.Commands.List = {}

-- Register & Refresh Commands

function QBCore.Commands.Add(name, help, arguments, argsrequired, callback, permission)
    if type(permission) == 'string' then
        permission = permission:lower()
    else
        permission = 'user'
    end
    QBCore.Commands.List[name:lower()] = {
        name = name:lower(),
        permission = permission,
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

function QBCore.Commands.Refresh(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(QBCore.Commands.List) do
            local isGod = QBCore.Functions.HasPermission(src, 'god')
            local hasPerm = QBCore.Functions.HasPermission(src, QBCore.Commands.List[command].permission)
            local isPrincipal = IsPlayerAceAllowed(src, 'command')
            if isGod or hasPerm or isPrincipal then
                suggestions[#suggestions + 1] = {
                    name = '/' .. command,
                    help = info.help,
                    params = info.arguments
                }
            end
        end
        TriggerClientEvent('chat:addSuggestions', tonumber(source), suggestions)
    end
end

-- QBCore.Commands.Add('givecash', 'Give cash to player.', {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'Amount'}}, true, function(source, args)
--     local src = source
-- 	local id = tonumber(args[1])
-- 	local amount = math.ceil(tonumber(args[2]))
    
-- 	if id and amount then
-- 		local xPlayer = QBCore.Functions.GetPlayer(src)
-- 		local xReciv = QBCore.Functions.GetPlayer(id)
		
-- 		if xReciv and xPlayer then
-- 			if not xPlayer.PlayerData.metadata["isdead"] then
-- 				local distance = xPlayer.PlayerData.metadata["inlaststand"] and 3.0 or 10.0
-- 				if #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(id))) < distance then
-- 					if xPlayer.Functions.RemoveMoney('cash', amount) then
-- 						if xReciv.Functions.AddMoney('cash', amount) then
-- 							TriggerClientEvent('QBCore:Notify', src, "Success fully gave to ID " .. tostring(id) .. ' ' .. tostring(amount) .. '$.', "success")
-- 							TriggerClientEvent('QBCore:Notify', id, "Success recived gave " .. tostring(amount) .. '$ from ID ' .. tostring(src), "success")
-- 							TriggerClientEvent("payanimation", src)
--                             TriggerEvent('qb-logs:server:createLog', 'playermoney', '**__Give Cash__**', GetPlayerName(src).. " Give Cash To "..GetPlayerName(tonumber(args[1])).." "..tostring(args[2]).." " , false, src)
-- 						else
-- 							TriggerClientEvent('QBCore:Notify', src, "Could not give item to the given id.", "error")
-- 						end
-- 					else
-- 						TriggerClientEvent('QBCore:Notify', src, "You don\'t have this amount.", "error")
-- 					end
-- 				else
-- 					TriggerClientEvent('QBCore:Notify', src, "You are too far away lmfao.", "error")
-- 				end
-- 			else
-- 				TriggerClientEvent('QBCore:Notify', src, "You are dead LOL.", "error")
-- 			end
-- 		else
-- 			TriggerClientEvent('QBCore:Notify', src, "Wrong ID.", "error")
-- 		end
-- 	else
-- 		TriggerClientEvent('QBCore:Notify', src, "Usage /givecash [ID] [AMOUNT]", "error")
-- 	end
-- end)

QBCore.Commands.Add('addpermission', 'Give Player Permissions (God Only)', { { name = 'id', help = 'ID of player' }, { name = 'permission', help = 'Permission level' } }, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    local permission = tostring(args[2]):lower()
    if Player then
        QBCore.Functions.AddPermission(Player.PlayerData.source, permission)
        exports['ws-log']:Log('permission', Player.PlayerData.source, 'just became `%s` by %s.', permission, Player.PlayerData.source == source and 'himself' or exports['ws-log']:FetchFormatedIds(source));
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'god')

QBCore.Commands.Add('removepermission', 'Remove Players Permissions (God Only)', { { name = 'id', help = 'ID of player' } }, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        QBCore.Functions.RemovePermission(Player.PlayerData.source)
        exports['ws-log']:Log('permission', Player.PlayerData.source, 'permission removed by %s.', Player.PlayerData.source == source and 'himself' or exports['ws-log']:FetchFormatedIds(source));
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'god')



-- Teleport


QBCore.Commands.Add('tp', 'TP To Player or Coords (Admin Only)', { { name = 'id/x', help = 'ID of player or X position' }, { name = 'y', help = 'Y position' }, { name = 'z', help = 'Z position' } }, false, function(source, args)
    local src = source
    if args[1] and not args[2] and not args[3] then
        local target = GetPlayerPed(tonumber(args[1]))
        if target ~= 0 then
            local coords = GetEntityCoords(target)
            TriggerClientEvent('QBCore:Command:TeleportToPlayer', src, coords)
            exports['ws-log']:Log('admin', source, 'just telported to %s.', target == source and 'himself' or exports['ws-log']:FetchFormatedIds(tonumber(args[1])));
        else
            TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
        end
    else
        if args[1] and args[2] and args[3] then
            local x = tonumber(args[1])
            local y = tonumber(args[2])
            local z = tonumber(args[3])
            if (x ~= 0) and (y ~= 0) and (z ~= 0) then
                TriggerClientEvent('QBCore:Command:TeleportToCoords', src, x, y, z)
                exports['ws-log']:Log('admin', source, 'just telported to (%f, %f, %f).', x, y, z);
            else
                TriggerClientEvent('QBCore:Notify', src, 'Incorrect Format', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Not every argument has been entered (x, y, z)', 'error')
        end
    end
end, 'admin')

QBCore.Commands.Add('tpm', 'TP To Marker (Admin Only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('QBCore:Command:GoToMarker', src)
    TriggerEvent('qb-logs:server:createLog', 'admincommands', 'TPM', GetPlayerName(src).. " do tpm", false, src)
end, 'god')


-- Vehicle

QBCore.Commands.Add('car', 'Spawn Vehicle (Admin Only)', { { name = 'model', help = 'Model name of the vehicle' } }, true, function(source, args)
    local src = source
    TriggerClientEvent('QBCore:Command:SpawnVehicle', src, args[1])
    TriggerEvent('qb-logs:server:createLog', 'cars', 'Car', GetPlayerName(src).. " tried to summoned vehicle " .. args[1] , false, src)
    
end, 'god')

QBCore.Commands.Add('dv', 'Delete Vehicle (Admin Only)', {}, false, function(source)
    local src = source
    TriggerClientEvent('QBCore:Command:DeleteVehicle', src)
end, 'god')

-- Money

QBCore.Commands.Add('givemoney', 'Give A Player Money (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'moneytype', help = 'Type of money (cash, bank, crypto)' }, { name = 'amount', help = 'Amount of money' } }, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
        TriggerEvent('qb-logs:server:createLog', 'givemoney', ' (Small Shit) GiveMoney', GetPlayerName(src).. " (Small Shit) Give Money To "..GetPlayerName(tonumber(args[1])).." "..tostring(args[2]).." "..tonumber(args[3]) , false, src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'god')

QBCore.Commands.Add('setmoney', 'Set Players Money Amount (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'moneytype', help = 'Type of money (cash, bank, crypto)' }, { name = 'amount', help = 'Amount of money' } }, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
        TriggerEvent('qb-logs:server:createLog', 'setmoney', ' (gay) SetMoney', GetPlayerName(src).. " (gay) Set Money To "..GetPlayerName(tonumber(args[1])).." "..tostring(args[2]).." "..tonumber(args[3]) , false, src)
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'god')

-- Job

QBCore.Commands.Add('job', 'Check Your Job', {}, false, function(source)
    local src = source
    local PlayerJob = QBCore.Functions.GetPlayer(src).PlayerData.job
    TriggerClientEvent('QBCore:Notify', src, string.format('[Job]: %s [Grade]: %s [On Duty]: %s', PlayerJob.label, PlayerJob.grade.name, PlayerJob.onduty))
end, 'user')

-- before
QBCore.Commands.Add('setjob', 'Set A Players Job (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'job', help = 'Job name' }, { name = 'grade', help = 'Grade' } }, true, function(source, args)
    local src = source
    local plyId = tonumber(args[1])
    local Player = QBCore.Functions.GetPlayer(plyId)
    if Player then
        Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
        exports['ws-log']:Log('admin', plyId, 'just became `%s (%d)` by %s.', args[2], args[3], plyId == source and 'himself' or exports['ws-log']:FetchFormatedIds(source));
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

-- new
-- QBCore.Commands.Add('setjob', 'Set A Players Job (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'job', help = 'Job name' }, { name = 'grade', help = 'Grade' } }, true, function(source, args)
--     local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
--     if Player then
--         Player.Functions.SetJob(tostring(args[2]), tonumber(args[3]))
--         exports['qb-phone']:hireUser(tostring(args[2]), Player.PlayerData.citizenid, tonumber(args[3]))
--     else
--         TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
--     end
-- end, 'admin')
-- QBCore.Commands.Add('removejob', 'Removes A Players Job (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'job', help = 'Job name' } }, true, function(source, args)
--     local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
--     if Player then
--         if Player.PlayerData.job.name == tostring(args[2]) then
--             Player.Functions.SetJob("unemployed", 0)
--         end
--         exports['qb-phone']:fireUser(tostring(args[2]), Player.PlayerData.citizenid)
--     else
--         TriggerClientEvent('QBCore:Notify', source, Lang:t('error.not_online'), 'error')
--     end
-- end, 'admin')
-- Gang

QBCore.Commands.Add('gang', 'Check Your Gang', {}, false, function(source)
    local src = source
    local PlayerGang = QBCore.Functions.GetPlayer(source).PlayerData.gang
    TriggerClientEvent('QBCore:Notify', src, string.format('[Gang]: %s [Grade]: %s', PlayerGang.label, PlayerGang.grade.name))
end, 'user')

QBCore.Commands.Add('setgang', 'Set A Players Gang (Admin Only)', { { name = 'id', help = 'Player ID' }, { name = 'gang', help = 'Name of a gang' }, { name = 'grade', help = 'Grade' } }, true, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(tonumber(args[1]))
    if Player then
        Player.Functions.SetGang(tostring(args[2]), tonumber(args[3]))
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

-- Inventory (should be in qb-inventory?)
QBCore.Commands.Add('clearinv', 'Clear Players Inventory (Admin Only)', { { name = 'id', help = 'Player ID' } }, false, function(source, args)
    local src = source
    local playerId = args[1] or src
    local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if Player then
        Player.Functions.ClearInventory()
    else
        TriggerClientEvent('QBCore:Notify', src, 'Player Not Online', 'error')
    end
end, 'admin')

-- QBCore.Commands.Add("kick", "Kick Player", {{name="ID", help="The ID of the player."}, {name="reason", help="The reason of the kick."}}, false, function(source, args)
--     local src = source
--     local playerId = tonumber(args[1])
--     local Player = QBCore.Functions.GetPlayer(playerId)
--     local msg = tonumber(args[2])
--     table.remove(args,1)
--     DropPlayer(playerId, "You got kicked from the server: \n ".. table.concat(args," ") .." \n \n🔸 Check out our discord for more information: https://Discord.gg/sgx")
--     exports['ws-log']:Log('admin', source, 'just kicked %s. (`%s`)', playerId == source and 'himself' or exports['ws-log']:FetchFormatedIds(playerId), (msg and #msg > 0) and msg or 'no reason');
--   end, 'admin')

-- Out of Character Chat

-- QBCore.Commands.Add('ooc', 'OOC Chat Message', {}, false, function(source, args)
--     local src = source
--     local message = table.concat(args, ' ')
--     local Players = QBCore.Functions.GetPlayers()
--     local Player = QBCore.Functions.GetPlayer(src)
--     for k, v in pairs(Players) do
--         if v == src then
--             TriggerClientEvent('chat:addMessage', v, {
--                 color = { 0, 0, 255},
--                 multiline = true,
--                 args = {'OOC | '.. GetPlayerName(src), message}
--             })
--         elseif #(GetEntityCoords(GetPlayerPed(src)) - GetEntityCoords(GetPlayerPed(v))) < 20.0 then
--             TriggerClientEvent('chat:addMessage', v, {
--                 color = { 0, 0, 255},
--                 multiline = true,
--                 args = {'OOC | '.. GetPlayerName(src), message}
--             })
--         elseif QBCore.Functions.HasPermission(v, 'admin') then
--             if QBCore.Functions.IsOptin(v) then
--                 TriggerClientEvent('chat:addMessage', v, {
--                     color = { 0, 0, 255},
--                     multiline = true,
--                     args = {'Proxmity OOC | '.. GetPlayerName(src), message}
--                 })
--                 TriggerEvent('qb-log:server:CreateLog', 'ooc', 'OOC', 'white', '**' .. GetPlayerName(src) .. '** (CitizenID: ' .. Player.PlayerData.citizenid .. ' | ID: ' .. src .. ') **Message:** ' .. message, false)
--             end
--         end
--     end
-- end, 'user')

-- Me command

-- QBCore.Commands.Add('me', 'Show local message', {name = 'message', help = 'Message to respond with'}, false, function(source, args)
--     local src = source
--     local ped = GetPlayerPed(src)
--     local pCoords = GetEntityCoords(ped)
--     local msg = table.concat(args, ' ')
--     if msg == '' then return end
--     for k,v in pairs(QBCore.Functions.GetPlayers()) do
--         local target = GetPlayerPed(v)
--         local tCoords = GetEntityCoords(target)
--         if #(pCoords - tCoords) < 20 then
--             TriggerClientEvent('QBCore:Command:ShowMe3D', v, src, msg)
--         end
--     end
-- end, 'user')

-------- clear all server chat-------
QBCore.Commands.Add('clearall', 'Clear chat for everyone.', {}, false, function(source, args)
    TriggerClientEvent('chat:client:ClearChat', -1)
end, "god")