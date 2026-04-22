






local ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local CurrentWeaponData

local CurrentPumpProp

local CurrentPumpObj = {}

local CurrentPump

local CurrentRope = {}

local CurrentVehicle

local CurrentBone

local CurrentCapPos

local CurrentCost

local CurrentMessage

local IsMounted

local IsFueling

local VehicleOutOfFuel

local gasStationId = nil

local gasStationStock = nil

local gasStationPrice = nil

local loaded = false

function GetFuel(vehicle)

    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()

    local fuel = DecorGetFloat(vehicle, Config.FuelDecor)

    if Config.TankSizes[vehname] then

        return fuel / Config.TankSizes[vehname] * 100.0

    else

        return fuel / Config.DefaultTankSize * 100.0

    end

end

exports('GetFuel', GetFuel)

function ApplyFuel(vehicle, fuel)

    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()

    if Config.TankSizes[vehname] then

        DecorSetFloat(vehicle, Config.FuelDecor, fuel / 100.0 * Config.TankSizes[vehname])

    else

        DecorSetFloat(vehicle, Config.FuelDecor, fuel / 100.0 * Config.DefaultTankSize)

    end

end

exports('ApplyFuel', ApplyFuel)

function SetFuel(vehicle, fuel)

    if type(fuel) == 'number' and fuel >= 0 and fuel <= 100 then

        local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()

        if Config.ElectricVehicles[vehname] then

            ESX.TriggerServerCallback('esx-fuel:server:GetTimeInGarage', function(time)

                if time then

                    local toadd = 100.0 / (Config.TimeForCompleteCharge * 60) * time

                    if fuel + toadd > 100 then

                        fuel = 100

                    else

                        fuel = fuel + toadd

                    end

                    ApplyFuel(vehicle, fuel)

                end

            end, GetVehicleNumberPlateText(vehicle))

        else

            ApplyFuel(vehicle, fuel)

        end

    end

end

exports('SetFuel', SetFuel)

local Pumps = {}

for v, w in pairs(Config.PumpModels) do

	table.insert(Pumps, v)

end

local options = {

    {

        name = 'pumpfuel',

        event = "esx-fuel:PickupPump",

        icon = "fas fa-gas-pump",

        label = _U("info.pickup_pump"),

        canInteract = function(entity, distance, coords, name, bone)

            return not IsEntityDead(entity)

        end

    }, 

    {

        name = 'jerryfuel',

        event = "esx-fuel:BuyJerrican",

        icon = "fas fa-cart-shopping",

        label = _U("info.buy_jerrican"),

        canInteract = function(entity, distance, coords, name, bone)

            return not IsEntityDead(entity)

        end

    }

}

exports.ox_target:addModel(Pumps, options)

CreateThread(function()
    local Pumps = {}

    for v, w in pairs(Config.PumpModels) do

        table.insert(Pumps, v)

    end

    Wait(100)

    for _, gasStationCoords in pairs(Config.GasStations) do

        local blip = AddBlipForCoord(gasStationCoords.x, gasStationCoords.y, gasStationCoords.z)

        SetBlipSprite(blip, 361)

        SetBlipScale(blip, 0.6)

        SetBlipColour(blip, 4)

        SetBlipDisplay(blip, 4)

        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")

        AddTextComponentString(_U("info.blip_fuel"))

        EndTextCommandSetBlipName(blip)

    end

    for _, elecStationCoords in pairs(Config.SuperchargerStations) do

        local blip = AddBlipForCoord(elecStationCoords.x, elecStationCoords.y, elecStationCoords.z)

        SetBlipSprite(blip, 354)

        SetBlipScale(blip, 0.8)

        SetBlipColour(blip, 4)

        SetBlipDisplay(blip, 4)

        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")

        AddTextComponentString(_U("info.blip_electric"))

        EndTextCommandSetBlipName(blip)

    end

end)

local function Round(num, numDecimalPlaces)

    local mult = 10 ^ (numDecimalPlaces or 0)

    return math.floor(num * mult + 0.5) / mult

end

RegisterNetEvent("esx-fuel:BuyJerrican", function(data)

    local ped = PlayerPedId()

    local currentCash = ESX.GetAccount('money').money

	loadFuelPriceAndStockFromGasStationScript(GetEntityCoords(ped))

    if not HasPedGotWeapon(ped, 883325847) then

		if currentCash >= Config.JerryCanCost then

			if gasStationStock >= Config.JerryCanCapacity then

				TriggerServerEvent('esx-fuel:server:Pay', Config.JerryCanCost, Config.JerryCanCapacity, gasStationId, true)

			else

				ESX.ShowNotification(_U("message.no_stock"), "error")

			end

		else

			ESX.ShowNotification(_U("message.no_money"), "error")

        end

    else

        local refillCost = Round(Config.JerryCanCapacity * Config.JerryCanLiterPrice * (1 - GetAmmoInPedWeapon(ped, 883325847) / 4500))

		local refillAmount = Round(Config.JerryCanCapacity * (1 - GetAmmoInPedWeapon(ped, 883325847) / 4500))

        if refillCost > 0 then

            if currentCash >= refillCost then

				if gasStationStock >= Config.JerryCanCapacity then

					TriggerServerEvent('esx-fuel:server:Pay', refillCost, refillAmount, gasStationId, true, true)

				else

					ESX.ShowNotification(_U("message.no_stock"), "error")

				end

            else

                ESX.ShowNotification(_U("message.no_money"), "error")

            end

        else

            ESX.ShowNotification(_U("message.jerrican_full"), "error")

        end

    end

end)

RegisterNetEvent("esx-fuel:UpdateWeaponAmmo", function()

    local ped = PlayerPedId()

	ESX.ShowNotification(_U("message.jerrican_refilled"), "success")

	SetPedAmmo(ped, 883325847, 4500)

end)

local function DetectPetrolCap(electric)

    CurrentVehicle = GetVehiclePedIsIn(PlayerPedId(), true)

    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(CurrentVehicle)):lower()

    if Config.ElectricVehicles[vehname] == electric then

        local offset

        if Config.FuelCaps[vehname] then

            offset = Config.FuelCaps[vehname]

        else

            offset = {0.0, 0.0, 0.65}

        end

        local tanks = {"petrolcap", "wheel_lr", "petroltank", "petroltank_l", "engine", "engine_l"}

        for k, v in pairs(tanks) do

            CurrentBone = GetEntityBoneIndexByName(CurrentVehicle, v)

            if CurrentBone ~= -1 then

                CurrentCapPos = GetWorldPositionOfEntityBone(CurrentVehicle, CurrentBone)

                local currentoffset = GetOffsetFromEntityGivenWorldCoords(CurrentVehicle, CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z)

                currentoffset = vector3(currentoffset.x + offset[1], currentoffset.y + offset[2], currentoffset.z + offset[3])

                CurrentCapPos = GetOffsetFromEntityInWorldCoords(CurrentVehicle, currentoffset.x, currentoffset.y, currentoffset.z)

                break

            end

        end    

    end

end

RegisterNetEvent("esx-fuel:PickupPump", function(data)

    if CurrentPump then

        TriggerServerEvent('esx-fuel:server:DetachRope', PlayerPedId())

        CurrentMessage = nil

    else

        local playerPed = PlayerPedId()

        RequestModel('prop_cs_fuel_nozle')

        while not HasModelLoaded('prop_cs_fuel_nozle') do

            Wait(1)

        end

        CurrentPumpProp = CreateObject('prop_cs_fuel_nozle', 1.0, 1.0, 1.0, true, true, false)

        CurrentPump = data.entity

        local bone = GetPedBoneIndex(playerPed, 60309)

        AttachEntityToEntity(CurrentPumpProp, playerPed, bone, 0.0549, 0.049, 0.0, -50.0, -90.0, -50.0, true, true, false, false, 0, true)

        RopeLoadTextures()

        while not RopeAreTexturesLoaded() do

            Wait(1)

        end

        print(GetEntityModel(CurrentPump))

        local pumpcoords = GetEntityCoords(CurrentPump)

        local netIdProp = ObjToNet(CurrentPumpProp)
        SetNetworkIdExistsOnAllMachines(netIdProp, true)

        NetworkSetNetworkIdDynamic(netIdProp, true)

        SetNetworkIdCanMigrate(netIdProp, false)

        TriggerServerEvent('esx-fuel:server:AttachRope', netIdProp, pumpcoords, GetEntityModel(CurrentPump))

        IsMounted = false

        DetectPetrolCap(Config.PumpModels[GetEntityModel(CurrentPump)].electric)

		loadFuelPriceAndStockFromGasStationScript(GetEntityCoords(PlayerPedId()))

        CurrentMessage = _U('info.info_pump',gasStationPrice,gasStationStock)

    end

end)

function printTable(node)

	if type(node) == "table" then

		local function tab(amt)

			local str = ""

			for i=1,amt do

				str = str .. "\t"

			end

			return str

		end

		local cache, stack, output = {},{},{}

		local depth = 1

		local output_str = "{\n"

		while true do

			local size = 0

			for k,v in pairs(node) do

				size = size + 1

			end

			local cur_index = 1

			for k,v in pairs(node) do

				if (cache[node] == nil) or (cur_index >= cache[node]) then

					if (string.find(output_str,"}",output_str:len())) then

						output_str = output_str .. ",\n"

					elseif not (string.find(output_str,"\n",output_str:len())) then

						output_str = output_str .. "\n"

					end

					table.insert(output,output_str)

					output_str = ""

					local key

					if (type(k) == "number" or type(k) == "boolean") then

						key = "["..tostring(k).."]"

					else

						key = "['"..tostring(k).."']"

					end

					if (type(v) == "number" or type(v) == "boolean") then

						output_str = output_str .. tab(depth) .. key .. " = "..tostring(v)

					elseif (type(v) == "table") then

						output_str = output_str .. tab(depth) .. key .. " = {\n"

						table.insert(stack,node)

						table.insert(stack,v)

						cache[node] = cur_index+1

						break

					else

						output_str = output_str .. tab(depth) .. key .. " = '"..tostring(v).."'"

					end

					if (cur_index == size) then

						output_str = output_str .. "\n" .. tab(depth-1) .. "}"

					else

						output_str = output_str .. ","

					end

				else

					if (cur_index == size) then

						output_str = output_str .. "\n" .. tab(depth-1) .. "}"

					end

				end

				cur_index = cur_index + 1

			end

			if (#stack > 0) then

				node = stack[#stack]

				stack[#stack] = nil

				depth = cache[node] == nil and depth + 1 or depth - 1

			else

				break

			end

		end

		table.insert(output,output_str)

		output_str = table.concat(output)

		print(output_str)

	else

		print(node)

	end

end

RegisterNetEvent("esx-fuel:RefuelVehicle", function(ped, vehicle)

    local startingfuel = DecorGetFloat(vehicle, Config.FuelDecor)

    local startingCash = ESX.GetAccount('money').money

    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()

    local tank

    if Config.TankSizes[vehname] then

        tank = Config.TankSizes[vehname]

    else

        tank = Config.DefaultTankSize

    end

    print("Refueling")

	loadFuelPriceAndStockFromGasStationScript(GetEntityCoords(ped))

	if gasStationStock == 0 or gasStationPrice == 0 then IsFueling = false end

    while IsFueling or CurrentCost ~= 0 do

        Wait(500)

        local currentFuel = DecorGetFloat(vehicle, Config.FuelDecor)

        local fuelToAdd

        if Config.PumpModels[GetEntityModel(CurrentPump)] and not Config.PumpModels[GetEntityModel(CurrentPump)].electric then

            if currentFuel + 1.0 > tank then

                fuelToAdd = tank - currentFuel

            else

                fuelToAdd = 1.0

            end

        else

            fuelToAdd = ((tank - currentFuel) / (tank - (tank * 0.8)))^(1.0/6.0)

            if currentFuel + fuelToAdd > tank then

                fuelToAdd = tank - currentFuel

            end

        end

        currentFuel = currentFuel + fuelToAdd

        if currentFuel <= tank then

            if CurrentPump == "can" then

                local fuelToRemove

                if Config.JerryCanWeaponAsItem then

                    fuelToRemove = 100 / Config.JerryCanCapacity * fuelToAdd

                else

                    fuelToRemove = 4500 / Config.JerryCanCapacity * fuelToAdd

                end

                if GetAmmoInPedWeapon(ped, 883325847) - fuelToRemove >= 0 then

                    local ammo = math.floor(GetAmmoInPedWeapon(ped, 883325847) - fuelToRemove)

                    SetPedAmmo(ped, 883325847, ammo)

                else

                    IsFueling = false

                end

                CurrentMessage = _U('info.jerrican_refilling', Round(currentFuel - startingfuel, 1))

            else

                if CurrentPump and not Config.PumpModels[GetEntityModel(CurrentPump)].electric then

                    CurrentCost = CurrentCost + (gasStationPrice * fuelToAdd)

                    CurrentMessage = _U('info.refilling', Round(currentFuel - startingfuel, 1), math.floor(CurrentCost))

                else

                    CurrentCost = CurrentCost + (gasStationPrice * fuelToAdd)

                    CurrentMessage = _U('info.recharging', Round(currentFuel - startingfuel, 1), math.floor(CurrentCost))

                end

                if CurrentCost >= startingCash then

                    print("No more cash")

					CurrentCost = startingCash

                    IsFueling = false

                end

				if currentFuel - startingfuel > gasStationStock then

					print("Not enough stock in gas station")

					IsFueling = false

				end

            end

            if currentFuel == tank then

                print("Tank full")

                DecorSetFloat(vehicle, Config.FuelDecor, currentFuel + 0.0)

                IsFueling = false

            end

        end

        if IsFueling then

            DecorSetFloat(vehicle, Config.FuelDecor, currentFuel + 0.0)

        else

            if CurrentCost ~= 0 then

                print("Payment", CurrentCost)

				local liters = math.floor(currentFuel - startingfuel + 0.5)

				if liters > gasStationStock then liters = gasStationStock end

                TriggerServerEvent('esx-fuel:server:Pay', math.floor(CurrentCost),liters,gasStationId,false)

                CurrentCost = 0

            end

        end

    end

end)

local function LoadAnimDict(dict)

	if not HasAnimDictLoaded(dict) then

		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do

			Citizen.Wait(1)

		end

	end

end

CreateThread(function()
    while true do

        local sleep = 1000

        if CurrentPump then

            sleep = 0

            if IsControlPressed(0, Config.ActionKey) and CurrentCapPos then

                local playerPed = PlayerPedId()

                if #(GetEntityCoords(playerPed) - CurrentCapPos) < 3.0 then
                    if not IsMounted then

                        if CurrentPump ~= "can" then

                            local offset = GetOffsetFromEntityGivenWorldCoords(CurrentVehicle, CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z)

                            DetachEntity(CurrentPumpProp, true, true)

                            AttachEntityToEntity(CurrentPumpProp, CurrentVehicle, nil, offset.x, offset.y, offset.z, -50.0, 0.0, -90.0, true, true, false, false, 0, true)

                        else

                            TaskTurnPedToFaceCoord(playerPed, CurrentCapPos, -1)

                            LoadAnimDict("weapons@misc@jerrycan@")

                            TaskPlayAnim(playerPed, "weapons@misc@jerrycan@", "fire", 2.0, 8.0, -1, 50, 0, 0, 0, 0)

                        end

                        IsMounted = true

                        IsFueling = true

                        CurrentCost = 0

                        TriggerEvent("esx-fuel:RefuelVehicle", playerPed, CurrentVehicle)

                    else

                        if CurrentPump ~= "can" then

                            DetachEntity(CurrentPumpProp, true, true)

                            local bone = GetPedBoneIndex(playerPed, 28422)

                            AttachEntityToEntity(CurrentPumpProp, playerPed, bone, 0.0549, 0.049, 0.0, -50.0, -90.0, -50.0, true, true, false, false, 0, true)

                        else

                            ClearPedTasks(playerPed)

                            RemoveAnimDict("weapons@misc@jerrycan@")                            

                            CurrentMessage = nil

                        end

                        IsMounted = false

                        IsFueling = false

                        if CurrentPump ~= "can" then

							loadFuelPriceAndStockFromGasStationScript(GetEntityCoords(PlayerPedId()))

                            CurrentMessage = _U('info.info_pump',gasStationPrice,gasStationStock)

                        end

                    end

                end

                Wait(1000)

            end

        end

        Wait(sleep)

    end

end)

local function DrawText3Ds(x, y, z, text)

    local onScreen, _x, _y = World3dToScreen2d(x, y, z)

    if onScreen then

        SetTextScale(0.35, 0.35)

        SetTextFont(4)

        SetTextProportional(1)

        SetTextColour(255, 255, 255, 215)

        SetTextEntry("STRING")

        SetTextCentre(1)

        AddTextComponentString(text)

        DrawText(_x, _y)

    end

end

CreateThread(function()
    while true do

        local sleep = 1000

        if VehicleOutOfFuel then

            sleep = 0

            SetVehicleCheatPowerIncrease(VehicleOutOfFuel, 0.01)

        end

        if CurrentMessage then

            sleep = 0

            ESX.ShowHelpNotification(CurrentMessage)

        end

        if CurrentCapPos then

            sleep = 0

            if not IsMounted then

                if Config.Texts3d then

                    DrawText3Ds(CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z, _U("info.mount_pump"))                    

                end

            else

                if Config.Texts3d then

                    DrawText3Ds(CurrentCapPos.x, CurrentCapPos.y, CurrentCapPos.z, _U("info.dismount_pump"))

                end

                if CurrentPump == "can" then

                    for _, controlIndex in pairs(Config.DisableKeys) do

                        DisableControlAction(0, controlIndex)

                    end            

                end

            end

        end

        Wait(sleep)

    end

end)

local function ManageFuelUsage(vehicle)

    if not DecorExistOn(vehicle, Config.FuelDecor) then

        ApplyFuel(vehicle, math.random(200, 800) / 10)

    end

    local fuel = DecorGetFloat(vehicle, Config.FuelDecor)

    local vehname = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()

    if not Config.Blacklist[vehname] then

        if IsVehicleEngineOn(vehicle) then

            if Config.ElectricVehicles[vehname] then

                local tank

                if Config.TankSizes[vehname] then

                    tank = Config.TankSizes[vehname]

                else

                    tank = Config.DefaultTankSize

                end

                local charge = ((tank - fuel) / (tank - (tank * 0.8)))^(1.0/4.0)

                if charge == 0 then

                    charge = 0.5

                end

                fuel = fuel - charge * Config.KwUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.ClassFuelUsage[GetVehicleClass(vehicle)] or 1.0) * (Config.ModelFuelUsage[GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()] or 1.0) / 20.0

            else

                fuel = fuel - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.ClassFuelUsage[GetVehicleClass(vehicle)] or 1.0) * (Config.ModelFuelUsage[GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)):lower()] or 1.0) / 20.0

            end

            if fuel > 0 then

                DecorSetFloat(vehicle, Config.FuelDecor, fuel)

                VehicleOutOfFuel = nil

                SetVehicleFuelLevel(vehicle, 50.0)

            else

                DecorSetFloat(vehicle, Config.FuelDecor, 0.0)

                VehicleOutOfFuel = vehicle

                SetVehicleFuelLevel(vehicle, 0.0)

                SetVehicleEngineOn(vehicle, false, true, true)

            end

        else

            if fuel > 0 then

                SetVehicleFuelLevel(vehicle, 50.0)

            end

        end            

    end

end

CreateThread(function()

    local inBlacklisted

    DecorRegister(Config.FuelDecor, 1)

    while true do

        Wait(1000)

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then

            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped then

                ManageFuelUsage(vehicle)

            end

        else

            if GetSelectedPedWeapon(ped) == 883325847 then

                if GetAmmoInPedWeapon(ped, 883325847) >= 100 and not CurrentCapPos then

                    CurrentPump = "can"

                    DetectPetrolCap(nil)

                end

            else

                if CurrentPump == "can" then

                    CurrentPump = nil

                    CurrentCapPos = nil

                    CurrentCost = 0

                end

            end

        end

        if CurrentPump and not IsMounted and CurrentPump ~= "can" then
            if #(GetEntityCoords(ped) - GetEntityCoords(CurrentPump)) >= Config.RopeMaxLength then

                TriggerEvent('esx-fuel:PickupPump')

                ESX.ShowNotification(_U("message.to_far_away"), "error")

            end

        end

        if IsMounted and CurrentPump ~= "can" and #(GetEntityCoords(CurrentVehicle) - GetEntityCoords(CurrentPump)) >= Config.RopeMaxLength then

            IsFueling = false

            IsMounted = false

            Wait(1000)

            TriggerEvent('esx-fuel:PickupPump')

            ESX.ShowNotification(_U("message.to_far_away"), "error")

        end

    end

end)

AddEventHandler("onResourceStop", function(resource)

    if resource == GetCurrentResourceName() then

        if CurrentPumpProp then

            DetachEntity(CurrentPumpProp, false, false)

            DeleteEntity(CurrentPumpProp)

        end

        CurrentMessage = nil

    end

end)

RegisterNetEvent("esx-fuel:SetFuel", function(fuel)

    local ped = PlayerPedId()

    local vehicle = GetVehiclePedIsIn(ped, false)

    if GetPedInVehicleSeat(vehicle, -1) == ped then

        ApplyFuel(vehicle, fuel)

    else

        ESX.ShowNotification(_U("message.must_be_driver"), "primary")

    end

end)

RegisterNetEvent("esx-fuel:client:AttachRope", function(netIdProp, posPump, model, citizenid)

    local object = GetHashKey('bkr_prop_bkr_cash_roll_01')

    RequestModel(object)

    while not HasModelLoaded(object) do

        Wait(1)

    end

    CurrentPumpObj[citizenid] = CreateObject(object, posPump.x, posPump.y, posPump.z, true, true, false)

    SetEntityRecordsCollisions(CurrentPumpObj[citizenid], false)

    SetEntityLoadCollisionFlag(CurrentPumpObj[citizenid], false)

    local timeout = 0

    local IdProp

    while true do

        if timeout > 50 then

            break

        end

        if NetworkDoesEntityExistWithNetworkId(netIdProp) then

            IdProp = NetworkGetEntityFromNetworkId(netIdProp)

            break                            

        else

            Wait(100)

            timeout = timeout + 1

        end

    end

    local pumppropcoords = GetOffsetFromEntityInWorldCoords(IdProp, 0.0, -0.019, -0.1749)

    CurrentRope[citizenid] = AddRope(posPump.x, posPump.y, posPump.z + Config.PumpModels[model].z, 0.0, 0.0, 0.0, Config.RopeLength, 1, 1000.0, 0.5, 1.0, false, false, false, 5.0, false, 0)

    AttachEntitiesToRope(CurrentRope[citizenid], IdProp, CurrentPumpObj[citizenid], pumppropcoords.x, pumppropcoords.y, pumppropcoords.z, posPump.x, posPump.y, posPump.z + Config.PumpModels[model].z, Config.RopeMaxLength, 0, 0)

end)

RegisterNetEvent("esx-fuel:client:DetachRope", function(citizenid, src)

    DetachRopeFromEntity(CurrentRope[citizenid], CurrentPumpProp)

    DeleteRope(CurrentRope[citizenid])

    DeleteEntity(CurrentPumpObj[citizenid])

    if PlayerPedId() == src then

        DetachEntity(CurrentPumpProp, true, true)

        DeleteEntity(CurrentPumpProp)

        CurrentPumpProp = nil

        CurrentPump = nil

        CurrentCapPos = nil

        CurrentVehicle = nil

        CurrentBone = nil

    end

end)

function loadFuelPriceAndStockFromGasStationScript(entityCoords)

	local localGasStationId = nil

	loaded = false

	for k,v in pairs(Config.GasStationOwner) do

		if #(vector3(v[1],v[2],v[3])-entityCoords) <= v[4] then

			localGasStationId = k

		end

	end

	TriggerServerEvent('esx-sna-fuel:server:getFuelPriceAndStockFromGasStationScript',localGasStationId)

	while loaded == false do Wait(10) end

	gasStationId = localGasStationId

	return

end

RegisterNetEvent("esx-sna-fuel:client:getFuelPriceAndStockFromGasStationScript")

AddEventHandler('esx-sna-fuel:client:getFuelPriceAndStockFromGasStationScript', function(stockServer, priceServer)

	gasStationStock = stockServer

	gasStationPrice = priceServer

	loaded = true

end)







