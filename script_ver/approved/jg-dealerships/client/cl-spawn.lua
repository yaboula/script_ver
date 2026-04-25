


-- Initialize Spawn namespace
if not Spawn then
  Spawn = {}
end

if not Spawn.Client then
  Spawn.Client = {}
end
---Get vehicle type string from model hash
---@param model number Vehicle model hash
---@return string Vehicle type for CreateVehicle
local function GetVehicleType(model)
  local vehicleClass = GetVehicleClassFromName(model)
  
  if IsThisModelACar(model) then
    return "automobile"
  elseif IsThisModelABicycle(model) then
    return "bike"
  elseif IsThisModelABike(model) then
    return "bike"
  elseif IsThisModelABoat(model) then
    return "boat"
  elseif IsThisModelAHeli(model) then
    return "heli"
  elseif IsThisModelAPlane(model) then
    return "plane"
  elseif IsThisModelAQuadbike(model) then
    return "automobile"
  elseif IsThisModelATrain(model) then
    return "train"
  elseif vehicleClass == 5 then
    return "automobile"
  elseif vehicleClass == 14 then
    return "submarine"
  elseif vehicleClass == 16 then
    return "heli"
  else
    return "trailer"
  end
end
---Apply basic vehicle extras (color, plate, fuel)

local function ApplyVehicleExtras(vehicle, extras)
  -- Apply color and plate if provided
  if extras and type(extras) == "table" then
    if extras.colour then
      Utils.Client.SetVehicleColourNew(vehicle, extras.colour)
    end
    
    if extras.plate then
      SetVehicleNumberPlateText(vehicle, extras.plate)
    end
  end
  
  -- Set fuel to 100%
  Framework.Client.VehicleSetFuel(vehicle, 100.0)
  
  -- Return true if vehicle is not networked (local only)
  return not NetworkGetEntityIsNetworked(vehicle)
end
---Request and validate vehicle model

local function RequestVehicleModel(model, plate)
  local modelHash = ConvertModelToHash(model)
  local vehicleType = GetVehicleType(modelHash)
  
  -- Validate model exists
  if not IsModelInCdimage(modelHash) then
    Framework.Client.Notify(Locale.vehicleModelDoesNotExist, "error")
    print(string.format("^1Vehicle model %s does not exist", model))
    return false
  end
  
  local hasSeats = GetVehicleModelNumberOfSeats(modelHash) > 0
  
  -- Validate plate if provided
  if plate and plate ~= "" then
    if not IsValidGTAPlate(plate) then
      Framework.Client.Notify(Locale.vehiclePlateInvalid, "error")
      print(string.format("^1This vehicle is trying to spawn with the plate '%s' which is invalid for a GTA vehicle plate", plate:upper()))
      print("^1Vehicle plates must be 8 characters long maximum, and can contain ONLY numbers, letters and spaces")
      return false
    end
  end
  
  -- Request model
  lib.requestModel(modelHash, 60000)
  
  -- Check player isn't ragdolled
  if IsPedRagdoll(cache.ped) then
    Framework.Client.Notify(Locale.currentlyInRagdollState, "error")
    SetModelAsNoLongerNeeded(modelHash)
    return false
  end
  
  return modelHash, vehicleType, hasSeats
end
---Finalize vehicle spawn (put player in, set plate, give keys)

local function FinalizeVehicleSpawn(vehicle, vehicleId, modelHash, putInVehicle, plate, extras, financeData)
  -- Validate vehicle
  if not vehicle or vehicle == 0 then
    Framework.Client.Notify(Locale.couldNotSpawnVehicle, "error")
    print("^1Vehicle does not exist (vehicle = 0)")
    return false
  end
  
  -- Check player ragdoll
  if IsPedRagdoll(cache.ped) then
    Framework.Client.Notify(Locale.currentlyInRagdollState, "error")
    SetModelAsNoLongerNeeded(modelHash)
    return false
  end
  
  -- Warp player into vehicle
  if putInVehicle then
    ClearPedTasks(cache.ped)
    local success = pcall(function()
      lib.waitFor(function()
        if GetPedInVehicleSeat(vehicle, -1) == cache.ped then
          return true
        end
        TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
      end, nil, 5000)
    end)
    
    if not success then
      print("^1[ERROR] Could not warp you into the vehicle^0")
      return false
    end
  end
  
  -- Set plate
  if plate and plate ~= "" then
    SetVehicleNumberPlateText(vehicle, plate)
  end
  
  -- Apply extras
  if extras and type(extras) == "table" then
    ApplyVehicleExtras(vehicle, extras)
  end
  
  -- Handle brazzers-fakeplates if installed
  if GetResourceState("brazzers-fakeplates") == "started" then
    local fakePlate = lib.callback.await("jg-dealerships:server:brazzers-get-fakeplate-from-plate", false, plate)
    if fakePlate then
      plate = fakePlate
      SetVehicleNumberPlateText(vehicle, fakePlate)
    end
  end
  
  -- Get plate if not set
  if not plate or plate == "" then
    plate = Framework.Client.GetPlate(vehicle)
  end
  
  -- Validate plate exists
  if not plate or plate == "" then
    print("^1[ERROR] The game thinks the vehicle has no plate - absolutely no idea how you've managed this")
    return false
  end
  
  -- Set vehicle ID in entity state
  Entity(vehicle).state:set("vehicleid", vehicleId, true)
  
  -- Give keys to player
  Framework.Client.VehicleGiveKeys(plate, vehicle, financeData)
  
  return true
end
---Handle server-created vehicle on client

local function HandleServerCreatedVehicle(networkId, teleportBackCoords, putInVehicle, modelHash, vehicleId, plate, extras, financeData)
  -- Clean up model
  SetModelAsNoLongerNeeded(modelHash)
  
  -- Validate network ID
  if not networkId then
    Framework.Client.Notify(Locale.couldNotSpawnVehicle, "error")
    print("^1Server returned false for netId")
    return false
  end
  
  -- Wait for network ID to exist
  lib.waitFor(function()
    if NetworkDoesNetworkIdExist(networkId) and NetworkDoesEntityExistWithNetworkId(networkId) then
      return true
    end
    return nil
  end, "Timed out while waiting for a server-setter netId to exist on client", 10000)
  
  -- Convert network ID to vehicle entity
  local vehicle = NetToVeh(networkId)
  
  -- Wait for vehicle entity to exist
  lib.waitFor(function()
    return DoesEntityExist(vehicle) or nil
  end, "Timed out while waiting for a server-setter vehicle to exist on client", 10000)
  
  -- Teleport player back if they were moved
  if teleportBackCoords then
    SetEntityCoords(cache.ped, teleportBackCoords.x, teleportBackCoords.y, teleportBackCoords.z, false, false, false, false)
  end
  
  -- Finalize the spawn
  local success = FinalizeVehicleSpawn(vehicle, vehicleId, modelHash, putInVehicle, plate, extras, financeData)
  if not success then
    DeleteEntity(vehicle)
    return false
  end
  
  return true
end
---Create a vehicle on the client side

local function CreateVehicleClient(modelHash, coords, plate, isNetworked)
  -- Request the model
  lib.requestModel(modelHash, 60000)
  
  -- Create the vehicle
  local vehicle = CreateVehicle(
    modelHash,
    coords.x,
    coords.y,
    coords.z,
    coords.w,
    isNetworked or false,
    isNetworked or false
  )
  
  -- Wait for vehicle to exist
  lib.waitFor(function()
    return DoesEntityExist(vehicle) or nil
  end, "Timed out while trying to spawn in vehicle (client)", 10000)
  
  -- Clean up model
  SetModelAsNoLongerNeeded(modelHash)
  
  -- Set plate if provided
  if plate and plate ~= "" then
    SetVehicleNumberPlateText(vehicle, plate)
  end
  
  return vehicle
end
---Create a vehicle on client side (only used when server spawning is disabled)

function Spawn.Client.Create(vehicleId, model, plate, coords, putInVehicle, extras, financeData)
  -- Check if server spawning is enabled (this function is for client spawning only)
  if Config.SpawnVehiclesWithServerSetter then
    print("^1This function is disabled as client spawning is enabled")
    return false
  end
  
  -- Request and validate the model
  local modelHash, vehicleType, hasSeats = RequestVehicleModel(model, plate)
  if not modelHash then
    return false
  end
  
  -- Create the vehicle
  local vehicle = CreateVehicleClient(modelHash, coords, plate, true)
  if not vehicle then
    return false
  end
  
  -- Finalize the spawn (warp player, set plate, give keys)
  local success = FinalizeVehicleSpawn(
    vehicle,
    vehicleId,
    modelHash,
    hasSeats and putInVehicle or false,
    plate,
    extras,
    financeData
  )
  
  if not success then
    DeleteEntity(vehicle)
    return false
  end
  
  return vehicle
end
---State bag handler: vehInit

AddStateBagChangeHandler("vehInit", "", function(bagName, key, value)
  -- Only process when value is set to true
  if not value then
    return
  end
  
  -- Get the vehicle entity from state bag
  local vehicle = GetEntityFromStateBagName(bagName)
  if vehicle == 0 then
    return
  end
  
  -- Wait for vehicle to finish loading collision
  lib.waitFor(function()
    return not IsEntityWaitingForWorldCollision(vehicle)
  end)
  
  -- Only process if this client owns the entity
  local owner = NetworkGetEntityOwner(vehicle)
  if owner ~= cache.playerId then
    return
  end
  
  -- Get entity state reference
  local state = Entity(vehicle).state
  
  -- Set vehicle on ground properly
  SetVehicleOnGroundProperly(vehicle)
  
  -- Clear the init flag after next frame
  SetTimeout(0, function()
    state:set("vehInit", nil, true)
  end)
end)
---State bag handler: dealershipVehCreatedApplyProps

AddStateBagChangeHandler("dealershipVehCreatedApplyProps", "", function(bagName, key, props)
  -- Only process when props are set
  if not props then
    return
  end
  
  -- Get the vehicle entity from state bag
  local vehicle = GetEntityFromStateBagName(bagName)
  if vehicle == 0 then
    return
  end
  
  -- Wait next frame then try to apply props
  SetTimeout(0, function()
    local state = Entity(vehicle).state
    
    -- Try up to 10 times (1 second total) to apply props
    for i = 0, 9 do
      local owner = NetworkGetEntityOwner(vehicle)
      
      -- Only apply props if this client owns the vehicle
      if owner == cache.playerId then
        -- Apply the vehicle properties
        local success = ApplyVehicleExtras(vehicle, props)
        
        if success then
          -- Clear the props flag after successful application
          state:set("dealershipVehCreatedApplyProps", nil, true)
          break
        end
      end
      
      -- Wait before retry
      Wait(100)
    end
  end)
end)
-- Callback: Request vehicle model and get spawn details
-- Called by server when spawning a vehicle
lib.callback.register("jg-dealerships:client:req-vehicle-and-get-spawn-details", RequestVehicleModel)

-- Callback: Handle server-created vehicle on client
-- Called by server after vehicle is created with CreateVehicleServerSetter
lib.callback.register("jg-dealerships:client:on-server-vehicle-created", HandleServerCreatedVehicle)
