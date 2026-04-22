local QBCore = exports['qb-core']:GetCoreObject()


function isCloseVeh()
    local ped = PlayerPedId()
    coordA = GetEntityCoords(ped, 1)
    coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 100.0, 0.0)
    vehicle = getVehicleInDirection(coordA, coordB)
    if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
        return true
    end
    return false
end

RegisterNetEvent('vehicle:flipit')
AddEventHandler('vehicle:flipit', function()
    local ped = PlayerPedId()
    local vehicle

    -- Check if player is in a vehicle
    if IsPedInAnyVehicle(ped, false) then
        vehicle = GetVehiclePedIsIn(ped, false)
    else
        -- Find closest vehicle if not inside one
        local coords = GetEntityCoords(ped)
        vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    end

    if DoesEntityExist(vehicle) then
        exports['progressbar']:Progress({
            name = "flipping_vehicle",
            duration = 5000,
            label = "Flipping Vehicle Over",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            },
            animation = {
                animDict = "random@mugging4",
                anim = "struggle_loop_b_thief",
                flags = 49,
            }
        }, function(cancelled)
            if not cancelled then
                -- Freeze vehicle temporarily to prevent physics glitches
                FreezeEntityPosition(vehicle, true)
                
                -- Reset vehicle rotation (pitch & roll to 0)
                local vehRotation = GetEntityRotation(vehicle)
                SetEntityRotation(vehicle, 0.0, 0.0, vehRotation.z, 0, true)
                
                -- Ensure vehicle is on the ground
                SetVehicleOnGroundProperly(vehicle)
                
                -- Small delay for physics to stabilize
                Citizen.Wait(500)
                
                -- Unfreeze the vehicle
                FreezeEntityPosition(vehicle, false)
                
                -- Final check (if still upside down, teleport slightly upwards)
                if GetEntityPitch(vehicle) > 45.0 then
                    local vehCoords = GetEntityCoords(vehicle)
                    SetEntityCoords(vehicle, vehCoords.x, vehCoords.y, vehCoords.z + 0.5, false, false, false, false)
                    SetVehicleOnGroundProperly(vehicle)
                end
            end
        end)
    else
        QBCore.Functions.Notify('No vehicle nearby.', 'error')
    end
end)

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)    
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)
        
        offset = offset - 1

        if vehicle ~= 0 then break end
    end
    
    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))
    
    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end

function hasEnoughOfItem(item)
	local retval = false
	QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
		if result then
			retval = true
		end
		return retval
	end, item)
end
