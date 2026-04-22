






local ESX = nil

ESX = exports["es_extended"]:getSharedObject() 

RegisterServerEvent('esx-fuel:server:Pay', function(amount,liters,gasStationId,isGasCan,isRefuelGasCan)

    local src = source

    local Player = ESX.GetPlayerFromId(src)

    Player.removeMoney(amount)

	if removeStockFromGasStationScript(gasStationId,amount,liters,isGasCan) and isGasCan then

		if isRefuelGasCan then

			TriggerClientEvent("esx-fuel:UpdateWeaponAmmo", src)

		else

			if Config.JerryCanWeaponAsItem then

				Player.addInventoryItem('weapon_petrolcan', 1)

			else

				Player.addWeapon('weapon_petrolcan', 4500)

			end

			Player.showNotification(_U("message.jerrican_bought"), 'success')

		end

	end

end)

RegisterServerEvent('esx-fuel:server:GiveJerrican', function()

    local src = source

    local Player = ESX.GetPlayerFromId(src)

    if Config.JerryCanWeaponAsItem then

        Player.addInventoryItem('weapon_petrolcan', 1)

    else

        Player.addWeapon('weapon_petrolcan', 4500)

    end

end)

RegisterServerEvent('esx-fuel:server:AttachRope', function(netIdProp, coordPumps, model)

	local src = source

    local Player = ESX.GetPlayerFromId(src)

    local citizenid = Player.identifier

    TriggerClientEvent('esx-fuel:client:AttachRope', -1, netIdProp, coordPumps, model, citizenid)

end)

RegisterServerEvent('esx-fuel:server:DetachRope', function(src)

	local srctemp = source

    local Player = ESX.GetPlayerFromId(srctemp)

    local citizenid = Player.identifier

    TriggerClientEvent('esx-fuel:client:DetachRope', -1, citizenid, src)

end)

RegisterNetEvent('esx-fuel:server:UpdateVehicleDateTimeIn', function(plate)

    MySQL.update('UPDATE owned_vehicles SET datetimein = ? WHERE plate = ?', {os.time(), plate})

end)

ESX.RegisterServerCallback('esx-fuel:server:GetTimeInGarage', function(source, cb, plate)

    local result = MySQL.single.await('SELECT * FROM owned_vehicles WHERE plate = ?', { plate })

    if result then

        if result.datetimein and result.datetimein ~= 0 then

            cb(os.time() - result.datetimein)

        else

            cb(false)            

        end

    else

        cb(false)

    end

end)

ESX.RegisterCommand("fuel", 'admin', function(xPlayer, args, showError)

    local amount = tonumber(args.amount)

    if not amount then

        amount = 100

    end

    xPlayer.triggerEvent('esx-fuel:SetFuel', amount)

end, false, {help = "Set fuel/charge for vehicle", validate = false, arguments = {

	{name = 'amount',validate = false, help = "Amount", type = 'string'}

}}) 

RegisterNetEvent('esx-sna-fuel:server:getFuelPriceAndStockFromGasStationScript', function(gasStationId)

	local source = source

	local stock, price = getFuelPriceAndStockFromGasStationScript(gasStationId)

	TriggerClientEvent('esx-sna-fuel:client:getFuelPriceAndStockFromGasStationScript', source, stock, price)

end)

function getFuelPriceAndStockFromGasStationScript(gasStationId)

	if not gasStationId then

		return Config.defaultGasStock, Config.defaultGasPrice

	end

	local sql = "SELECT stock, price FROM gas_station_business WHERE gas_station_id = @gas_station_id";

	local query = MySQL.Sync.fetchAll(sql, {['@gas_station_id'] = gasStationId});

	if not query or not query[1] then

		return Config.defaultGasStock, Config.defaultGasPrice

	end

	local sql = "UPDATE `gas_station_business` SET total_visits = total_visits + 1 WHERE gas_station_id = @gas_station_id";

	MySQL.Sync.execute(sql, {['@gas_station_id'] = gasStationId});

	return query[1].stock, query[1].price/100

end

function removeStockFromGasStationScript(gasStationId,pricePaid,fuelAmount,isGasCan)

	if not gasStationId then

		return true

	end

	local sql = "SELECT stock, price FROM gas_station_business WHERE gas_station_id = @gas_station_id";

	local query = MySQL.Sync.fetchAll(sql, {['@gas_station_id'] = gasStationId});

	if not query or not query[1] then

		return true

	end

	if query[1].stock < fuelAmount then

		return false

	end

	local sql = "UPDATE `gas_station_business` SET stock = @stock, customers = customers + 1, money = money + @price, total_money_earned = total_money_earned + @price, gas_sold = gas_sold + @amount WHERE gas_station_id = @gas_station_id";

	MySQL.Sync.execute(sql, {['@gas_station_id'] = gasStationId, ['@stock'] = (query[1].stock - fuelAmount), ['@price'] = pricePaid, ['@amount'] = fuelAmount});

	if isGasCan then

		local sql = "INSERT INTO `gas_station_balance` (gas_station_id,income,title,amount,date) VALUES (@gas_station_id,@income,@title,@amount,@date)";

		MySQL.Sync.execute(sql, {['@gas_station_id'] = gasStationId, ['@income'] = 0, ['@title'] = "Gas can sold ("..fuelAmount.." Liters)", ['@amount'] = pricePaid, ['@date'] = os.time()});

	else

		local sql = "INSERT INTO `gas_station_balance` (gas_station_id,income,title,amount,date) VALUES (@gas_station_id,@income,@title,@amount,@date)";

		MySQL.Sync.execute(sql, {['@gas_station_id'] = gasStationId, ['@income'] = 0, ['@title'] = "Fuel sold ("..fuelAmount.." Liters)", ['@amount'] = pricePaid, ['@date'] = os.time()});

	end

	return true

end







