


-- Initialize Spawn namespace
if not Spawn then
  Spawn = {}
end

if not Spawn.Server then
  Spawn.Server = {}
end

-- Local state tracking for vehicle spawn retries
local spawnRetries = {}
local MAX_TELEPORT_DISTANCE = 10.0
local MAX_PROP_SET_RETRIES = 3
---Internal function: Spawn vehicle using CreateVehicleServerSetter

local function SpawnVehicleWithServerSetter(source, model, modelType, plate, coords, putInVehicle, props)
  -- Check retry count
  if spawnRetries[source] then
    if spawnRetries[source] == MAX_PROP_SET_RETRIES then
      print("^3[WARNING] Vehicle props failed to set after trying several times. First check if the plate within the vehicle props JSON does not match the plate column. If they match, and you see this message regularly, try setting Config.SpawnVehiclesWithServerSetter = false")
      spawnRetries[source] = 0
      return false
    end
  end
  
  -- Increment retry counter
  spawnRetries[source] = (spawnRetries[source] or 0) + 1
  
  -- Create vehicle using server setter
  local vehicle = CreateVehicleServerSetter(model, modelType, coords.x, coords.y, coords.z, coords.w)
  
  -- Wait for vehicle to exist
  lib.waitFor(function()
    return DoesEntityExist(vehicle) or nil
  end, "Timed out while trying to spawn in vehicle (server)", 10000)
  
  -- Wait for plate to be set
  lib.waitFor(function()
    return GetVehicleNumberPlateText(vehicle) ~= "" or nil
  end, "Vehicle number plate text is nil", 5000)
  
  -- Set routing bucket to match player
  SetEntityRoutingBucket(vehicle, GetPlayerRoutingBucket(source))
  
  -- Set orphan mode if available (prevents vehicle from being deleted when player leaves)
  if SetEntityOrphanMode then
    SetEntityOrphanMode(vehicle, 2)
  end
  
  -- Delete any NPCs in the vehicle
  for seatIndex = -1, 6 do
    local ped = GetPedInVehicleSeat(vehicle, seatIndex)
    if ped ~= 0 then
      DeleteEntity(ped)
    end
  end
  -- Put player in vehicle if requested
  if putInVehicle then
    local playerPed = GetPlayerPed(source)
    pcall(function()
      lib.waitFor(function()
        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
          return true
        end
        SetPedIntoVehicle(playerPed, vehicle, -1)
      end, nil, 1000)
    end)
  end
  -- Wait for entity to have an owner
  lib.waitFor(function()
    return NetworkGetEntityOwner(vehicle) ~= -1 or nil
  end, "Timed out waiting for server-setter entity to have an owner (owner is -1)", 5000)
  
  -- Set vehicle as initialized
  Entity(vehicle).state:set("vehInit", true, true)
  
  -- Set props to be applied by client if provided
  if props and type(props) == "table" then
    Entity(vehicle).state:set("dealershipVehCreatedApplyProps", props, true)
  end
  -- Wait for props to be applied (or verify plate matches if no props)
  local propsApplied = pcall(function()
    lib.waitFor(function()
      -- If props state is cleared, it means they were applied
      if not Entity(vehicle).state.dealershipVehCreatedApplyProps then
        -- If we have a plate to verify, check it matches
        if plate and plate ~= "" then
          if Framework.Server.GetPlate(vehicle) == plate then
            return true
          end
        else
          return true
        end
      end
    end, nil, 2000)
  end)
  
  -- If props failed to apply, delete vehicle and retry
  if not propsApplied then
    DeleteEntity(vehicle)
    JGDeleteVehicle(vehicle)
    return SpawnVehicleWithServerSetter(source, model, modelType, plate, coords, putInVehicle, props)
  end
  
  -- Reset retry counter on success
  spawnRetries[source] = 0
  
  -- Return network ID and entity handle
  return NetworkGetNetworkIdFromEntity(vehicle), vehicle
end
---Create and spawn a vehicle for a player

function Spawn.Server.Create(source, vehicleData, spawnType, plate, coords, putInVehicle, props, financeData)
  -- Request vehicle from client and get spawn details
  local model, modelType, shouldPutInVehicle = lib.callback.await(
    "jg-dealerships:client:req-vehicle-and-get-spawn-details", 
    source, 
    spawnType
  )
  
  if not model then
    return false
  end
  
  -- Get player position and check if teleport is needed
  local playerPed = GetPlayerPed(source)
  local playerCoords = GetEntityCoords(playerPed)
  local wasTeleported = false
  
  -- Teleport player near spawn if too far away
  if #(playerCoords - coords.xyz) > MAX_TELEPORT_DISTANCE then
    SetEntityCoords(playerPed, coords.x + 3.0, coords.y + 3.0, coords.z, false, false, false, false)
    wasTeleported = true
  end
  -- Spawn the vehicle using server setter
  local networkId, vehicle = SpawnVehicleWithServerSetter(
    source,
    model,
    modelType,
    plate,
    coords,
    shouldPutInVehicle or putInVehicle,
    props
  )
  
  if not networkId or not vehicle then
    return false
  end
  
  -- Notify client that vehicle was created
  local clientSuccess = lib.callback.await(
    "jg-dealerships:client:on-server-vehicle-created",
    source,
    networkId,
    wasTeleported and playerCoords or nil,
    shouldPutInVehicle or putInVehicle,
    model,
    vehicleData,
    plate,
    props,
    financeData
  )
  
  -- If client failed to handle vehicle, delete it
  if not clientSuccess then
    if DoesEntityExist(vehicle) then
      DeleteEntity(vehicle)
      DebugPrint("Failed to create vehicle, deleted entity.", "warning", networkId)
    end
    return false
  end
  
  return networkId, vehicle
end
