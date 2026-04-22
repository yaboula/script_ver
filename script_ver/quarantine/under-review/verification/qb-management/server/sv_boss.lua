local QBCore = exports['qb-core']:GetCoreObject()
local Accounts = {}
local blacklistJobs = {
	["mechanic"] = true,
	["redline"] = true,
	["realestate"] = true,
}

local POLICE_GRADE = 31
local POLICE_GRADE2 = 30

CreateThread(function()
	Wait(500)
	local bossmenu = MySQL.Sync.fetchAll('SELECT * FROM bossmenu', {})
	if not bossmenu then
		return
	end
	for k,v in pairs(bossmenu) do
		local k = tostring(v.job_name)
		local v = tonumber(v.amount)
		if k and v then
			Accounts[k] = v
		end
	end
end)

function GetAccount(account)
	return Accounts[account] or 0
end

function AddMoney(account, amount)
	if not Accounts[account] then
		Accounts[account] = 0
	end

	Accounts[account] = Accounts[account] + amount
	MySQL.insert('INSERT INTO bossmenu (job_name, amount) VALUES (:job_name, :amount) ON DUPLICATE KEY UPDATE amount = :amount',
		{
			['job_name'] = account,
			['amount'] = Accounts[account],
		})
end

function RemoveMoney(account, amount)
	local isRemoved = false
	if amount > 0 then
		if not Accounts[account] then
			Accounts[account] = 0
		end

		if Accounts[account] >= amount then
			Accounts[account] = Accounts[account] - amount
			isRemoved = true
		end

		MySQL.update('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[account], account })
	end
	return isRemoved
end

RegisterNetEvent("qb-bossmenu:server:withdrawMoney", function(amount)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	local job = xPlayer.PlayerData.job.name

	if blacklistJobs[job] then
		return TriggerClientEvent("QBCore:Notify", src, "Oops you can't withdraw money right now", "error")
	end

	if job == "police" and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE2 then
		return TriggerClientEvent("QBCore:Notify", src, "Oops your grade isn't enough right now", "error")
	end

	if not Accounts[job] then
		Accounts[job] = 0
	end

	if Accounts[job] >= amount and amount > 0 then
		Accounts[job] = Accounts[job] - amount
		xPlayer.Functions.AddMoney("cash", amount)
	else
		TriggerClientEvent('QBCore:Notify', src, "Invalid Amount!", "error")
		TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
		return
	end
	
	MySQL.Async.execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[job], job})
	TriggerEvent('qb-logs:server:createLog', 'bossmenu', 'Withdraw Money', "**__Successfully withdraw $" .. amount .. '__** ( ' .. job .. ' )', false, src)
	TriggerClientEvent('QBCore:Notify', src, "You have withdrawn: $" ..amount, "success")
	TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
end)

RegisterNetEvent("qb-bossmenu:server:withdrawMoneyS", function(amount)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	local job = xPlayer.PlayerData.job.name

	if blacklistJobs[job] then
		return TriggerClientEvent("QBCore:Notify", src, "Oops you can't withdraw money right now", "error")
	end

	if job == "police" and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE2 then
		return TriggerClientEvent("QBCore:Notify", src, "Oops your grade isn't enough right now", "error")
	end

	if not Accounts[job] then
		Accounts[job] = 0
	end

	if Accounts[job] >= amount and amount > 0 then
		Accounts[job] = Accounts[job] - amount
		xPlayer.Functions.AddMoney("cash", amount)
	else
		TriggerClientEvent('QBCore:Notify', src, "Invalid Amount!", "error")
		TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
		return
	end
	
	MySQL.Async.execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[job], job})
	TriggerEvent('qb-logs:server:createLog', 'bossmenu', 'Withdraw Money', "**__Successfully withdraw $" .. amount .. '__** ( ' .. job .. ' )', false, src)
	TriggerClientEvent('QBCore:Notify', src, "You have withdrawn: $" ..amount, "success")
end)

RegisterNetEvent("qb-bossmenu:server:depositMoneyS", function(amount)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	local job = xPlayer.PlayerData.job.name

	--[[if blacklistJobs[job] then
		return TriggerClientEvent("QBCore:Notify", src, "Oops you can't deposit money right now", "error")
	end]]--

	if job == "police" and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE2 then
		return TriggerClientEvent("QBCore:Notify", src, "Oops your grade isn't enough right now", "error")
	end

	if not Accounts[job] then
		Accounts[job] = 0
	end

	if xPlayer.Functions.RemoveMoney("cash", amount) then
		Accounts[job] = Accounts[job] + amount
	else
		TriggerClientEvent('QBCore:Notify', src, "Invalid Amount!", "error")
		TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
		return
	end

	MySQL.Async.execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[job], job })
	TriggerEvent('qb-logs:server:createLog', 'bossmenudeposit', 'Deposit Money', "Successfully Deposited $" .. amount .. ' (' .. job .. ')', src)
	TriggerClientEvent('QBCore:Notify', src, "You have deposited: $" ..amount, "success")
end)


RegisterNetEvent("qb-bossmenu:server:depositMoney", function(amount)
	local src = source
	local xPlayer = QBCore.Functions.GetPlayer(src)
	local job = xPlayer.PlayerData.job.name

	--[[if blacklistJobs[job] then
		return TriggerClientEvent("QBCore:Notify", src, "Oops you can't deposit money right now", "error")
	end]]--

	if job == "police" and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE and xPlayer.PlayerData.job.grade.level ~= POLICE_GRADE2 then
		return TriggerClientEvent("QBCore:Notify", src, "Oops your grade isn't enough right now", "error")
	end

	if not Accounts[job] then
		Accounts[job] = 0
	end

	if xPlayer.Functions.RemoveMoney("cash", amount) then
		Accounts[job] = Accounts[job] + amount
	else
		TriggerClientEvent('QBCore:Notify', src, "Invalid Amount!", "error")
		TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
		return
	end

	MySQL.Async.execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[job], job })
	TriggerEvent('qb-logs:server:createLog', 'bossmenudeposit', 'Deposit Money', "Successfully Deposited $" .. amount .. ' (' .. job .. ')', src)
	TriggerClientEvent('QBCore:Notify', src, "You have deposited: $" ..amount, "success")
	TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
end)
 
RegisterNetEvent("qb-bossmenu:server:addAccountMoney", function(account, amount)
	if not Accounts[account] then
		Accounts[account] = 0
	end

	Accounts[account] = Accounts[account] + amount
	MySQL.Async.execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[account], account })
end)

RegisterNetEvent("qb-bossmenu:server:removeAccountMoney", function(account, amount)
	if not Accounts[account] then
		Accounts[account] = 0
	end

	if Accounts[account] >= amount then
		Accounts[account] = Accounts[account] - amount
	end

	MySQL.Async.execute('UPDATE bossmenu SET amount = ? WHERE job_name = ?', { Accounts[account], account })
end)

QBCore.Functions.CreateCallback('qb-bossmenu:server:GetAccount', function(source, cb, jobname)
	local result = GetAccount(jobname)
	cb(result)
end)

-- Export
function GetAccount(account)
	return Accounts[account] or 0
end

-- Get Employees
QBCore.Functions.CreateCallback('qb-bossmenu:server:GetEmployees', function(source, cb, jobname)
	local src = source
	local employees = {}
	if not Accounts[jobname] then
		Accounts[jobname] = 0
	end
	local players = MySQL.Sync.fetchAll("SELECT * FROM `players` WHERE `job` LIKE '%".. jobname .."%'", {})
	if players[1] ~= nil then
		for key, value in pairs(players) do
			local isOnline = QBCore.Functions.GetPlayerByCitizenId(value.citizenid)

			if isOnline then
				employees[#employees+1] = {
				empSource = isOnline.PlayerData.citizenid, 
				grade = isOnline.PlayerData.job.grade,
				isboss = isOnline.PlayerData.job.isboss,
				name = '🟢 ' .. isOnline.PlayerData.charinfo.firstname .. ' ' .. isOnline.PlayerData.charinfo.lastname
				}
			else
				employees[#employees+1] = {
				empSource = value.citizenid, 
				grade =  json.decode(value.job).grade,
				isboss = json.decode(value.job).isboss,
				name = '❌ ' ..  json.decode(value.charinfo).firstname .. ' ' .. json.decode(value.charinfo).lastname
				}
			end
		end
		table.sort(employees, function(a, b)
            return a.grade.level > b.grade.level
        end)
	end
	cb(employees)
end)

-- Grade Change
RegisterNetEvent('qb-bossmenu:server:GradeUpdate', function(data)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Employee = QBCore.Functions.GetPlayerByCitizenId(data.cid)
	if Employee then
		if Employee.Functions.SetJob(Player.PlayerData.job.name, data.grado) then
			TriggerClientEvent('QBCore:Notify', src, "Sucessfulluy promoted!", "success")
			TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source, "You have been promoted to" ..data.nomegrado..".", "success")
		else
			TriggerClientEvent('QBCore:Notify', src, "Promotion grade does not exist.", "error")
		end
	else
		TriggerClientEvent('QBCore:Notify', src, "Civilian not in city.", "error")
	end
	TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
end)

-- Fire Employee
RegisterNetEvent('qb-bossmenu:server:FireEmployee', function(target)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Employee = QBCore.Functions.GetPlayerByCitizenId(target)
	if Employee then
		if target ~= Player.PlayerData.citizenid then
			if Employee.Functions.SetJob("unemployed", '0') then
				TriggerEvent('qb-logs:server:createLog', 'bossmenu', 'Job Fire', Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. " " .. Employee.PlayerData.charinfo.lastname .. " (" .. Player.PlayerData.job.name .. ")", false, src)
				TriggerClientEvent('QBCore:Notify', src, "Employee fired!", "success")
				TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source , "You have been fired! Good luck.", "error")
			else
				TriggerClientEvent('QBCore:Notify', src, "Error..", "error")
			end
		else
			TriggerClientEvent('QBCore:Notify', src, "You can\'t fire yourself", "error")
		end
	else
		local player = MySQL.Sync.fetchAll('SELECT * FROM players WHERE citizenid = ? LIMIT 1', { target })
		if player[1] ~= nil then
			Employee = player[1]
			local job = {}
			job.name = "unemployed"
			job.label = "Unemployed"
			job.payment = 500
			job.onduty = true
			job.isboss = false
			job.grade = {}
			job.grade.name = nil
			job.grade.level = 0
			MySQL.Async.execute('UPDATE players SET job = ? WHERE citizenid = ?', { json.encode(job), target })
			TriggerClientEvent('QBCore:Notify', src, "Employee fired!", "success")
			TriggerEvent('qb-logs:server:createLog', 'bossmenu', 'Job Fire', Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. " " .. Employee.PlayerData.charinfo.lastname .. " (" .. Player.PlayerData.job.name .. ")", false, src)
		else
			TriggerClientEvent('QBCore:Notify', src, "Civilian not in city.", "error")
		end
	end
	TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
end)

-- Recruit Player
RegisterNetEvent('qb-bossmenu:server:HireEmployee', function(recruit)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Target = QBCore.Functions.GetPlayer(recruit)
	if Player.PlayerData.job.isboss == true then
		if Target and Target.Functions.SetJob(Player.PlayerData.job.name, 0) then
			TriggerClientEvent('QBCore:Notify', src, "You hired " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. " come " .. Player.PlayerData.job.label .. "", "success")
			TriggerClientEvent('QBCore:Notify', Target.PlayerData.source , "You were hired as " .. Player.PlayerData.job.label .. "", "success")
			TriggerEvent('qb-logs:server:createLog', 'bossmenu', 'Recruit', (Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname).. " successfully recruited " .. (Target.PlayerData.charinfo.firstname .. ' ' .. Target.PlayerData.charinfo.lastname) .. ' (' .. Player.PlayerData.job.name .. ')', false, src)
		end
	end
	TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
end)

-- Get closest player sv
QBCore.Functions.CreateCallback('qb-bossmenu:getplayers', function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for k, v in pairs(QBCore.Functions.GetPlayers()) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = QBCore.Functions.GetPlayer(v)
			players[#players+1] = {
			id = v,
			coords = GetEntityCoords(targetped),
			name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
			citizenid = ped.PlayerData.citizenid,
			sources = GetPlayerPed(ped.PlayerData.source),
			sourceplayer = ped.PlayerData.source
			}
		end
	end
		table.sort(players, function(a, b)
			return a.name < b.name
		end)
	cb(players)
end)

QBCore.Functions.CreateCallback("qb-bossemenu:getSocietyInfo", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local job = Player.PlayerData.job.name
    local society = MySQL.Sync.fetchAll('SELECT * FROM bossmenu WHERE job_name = ?', {job})
    if(society[1] ~= nil) then
		cb(society[1])
    else
		print("hello")
        cb(0)
    end
end)
