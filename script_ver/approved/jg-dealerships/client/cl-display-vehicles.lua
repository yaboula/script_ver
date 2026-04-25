



-- Initialize DisplayVehicles namespace
if not DisplayVehicles then
  DisplayVehicles = {}
end

if not DisplayVehicles.Client then
  DisplayVehicles.Client = {}
end

-- Local state management
local displayVehiclesByLocation = {}  -- Stores spawned display vehicles per location
local locationSpawning = {}           -- Tracks if a location is currently spawning
local locationShouldRespawn = {}      -- Tracks if location should respawn after current spawn
local isCreatingDisplayVehicle = false -- Prevents player from entering display vehicles during creation

---Delete all display vehicles for a specific location
---@param locationId string Dealership location ID

local function DeleteLocationDisplayVehicles(locationId)
  local vehicles = displayVehiclesByLocation[locationId]
  
  if vehicles and #vehicles > 0 then
    for _, vehicleData in ipairs(vehicles) do
      -- Remove streaming point if it exists
      if vehicleData.streamingPoint then
        vehicleData.streamingPoint:remove()
      end
      
      -- Delete entity if it exists
      if vehicleData.entity and DoesEntityExist(vehicleData.entity) then
        DeleteEntity(vehicleData.entity)
      end
    end
  end
  
  -- Clear the location's vehicle list
  displayVehiclesByLocation[locationId] = {}
end

-- Public function: Delete all display vehicles across all locations
function DisplayVehicles.Client.DeleteAll()
  for locationId in pairs(displayVehiclesByLocation) do
    DeleteLocationDisplayVehicles(locationId)
  end
end

-- Public function: Delete display vehicles for a specific location
function DisplayVehicles.Client.DeleteLocation(locationId)
  DeleteLocationDisplayVehicles(locationId)
end

-- Public function: Spawn all display vehicles for a location
function DisplayVehicles.Client.SpawnAll(locationId)
  -- If already spawning, mark for respawn after completion
  if locationSpawning[locationId] then
    locationShouldRespawn[locationId] = true
    return
  end
  
  -- Mark as spawning
  locationSpawning[locationId] = true
  locationShouldRespawn[locationId] = false
  
  CreateThread(function()
    -- Delete existing display vehicles
    DeleteLocationDisplayVehicles(locationId)
    
    -- Get display vehicles from server
    local displayVehicles = lib.callback.await("jg-dealerships:server:get-display-vehicles", false, locationId)
    
    if not displayVehicles then
      locationSpawning[locationId] = false
      
      -- Check if we should respawn
      if locationShouldRespawn[locationId] then
        DisplayVehicles.Client.SpawnAll(locationId)
      end
      return
    end
    
    local spawnedVehicles = {}
    
    -- Spawn each display vehicle
    for _, displayVehicle in ipairs(displayVehicles) do
      local spawnCode = displayVehicle.vehicle
      local coords = json.decode(displayVehicle.coords)
      local color = displayVehicle.color
      
      -- Determine text UI prompt
      local prompt = Config.ViewInShowroomPrompt
      local drawTextType = Config.DrawText
      
      if drawTextType == "auto" then
        drawTextType = (GetResourceState("jg-textui") == "started") and "jg-textui" or Config.DrawText
      end
      
      if drawTextType == "jg-textui" then
        prompt = "<h4 style='margin-bottom:5px'>" .. 
                 (displayVehicle.brand or "") .. " " .. 
                 (displayVehicle.model or "") .. 
                 "</h4><p>" .. Config.ViewInShowroomPrompt .. "</p>"
      end
      
      -- Create vehicle interaction
      local vehicleInteraction = Interactions.Client.Vehicle.Create(
        vector4(coords.x, coords.y, coords.z, coords.w),
        spawnCode,
        color,
        prompt,
        Config.ViewInShowroomKeyBind,
        function()
          -- On interaction: Open showroom
          if not isCreatingDisplayVehicle then
            Showroom.Client.Open(locationId, displayVehicle.vehicle, color)
          end
        end,
        function()
          -- Check if player has showroom access
          return Locations.Client.HasShowroomAccess(locationId)
        end
      )
      
      -- Mark entity as display vehicle and set plate
      if vehicleInteraction.entity and DoesEntityExist(vehicleInteraction.entity) then
        Entity(vehicleInteraction.entity).state:set("isDisplayVehicle", true, false)
        SetVehicleNumberPlateText(vehicleInteraction.entity, Config.DisplayVehiclesPlate)
      end
      
      table.insert(spawnedVehicles, vehicleInteraction)
    end
    
    -- Store spawned vehicles
    displayVehiclesByLocation[locationId] = spawnedVehicles
    locationSpawning[locationId] = false
    
    -- Check if we should respawn
    if locationShouldRespawn[locationId] then
      DisplayVehicles.Client.SpawnAll(locationId)
    end
  end)
end

-- Event: Spawn display vehicles (triggered from server)
RegisterNetEvent("jg-dealerships:client:spawn-display-vehicles", function(locationId)
  DisplayVehicles.Client.SpawnAll(locationId)
end)

-- NUI Callback: Create a new display vehicle
RegisterNUICallback("create-display-vehicle", function(data, cb)
  if isCreatingDisplayVehicle then
    return cb(false)
  end
  
  Framework.Client.HideTextUI()
  isCreatingDisplayVehicle = true
  
  local dealershipId = data.dealershipId
  local color = data.color
  local spawnCode = data.spawnCode
  local fromAdmin = data.fromAdmin
  
  -- Close NUI
  SetNuiFocus(false, false)
  
  -- Start vehicle creator
  local coords = Interactions.Client.Vehicle.StartCreator(
    spawnCode,
    color,
    {
      locationId = dealershipId,
      errorMessage = Locale.displayVehicleOutsideZone
    }
  )
  
  -- Reopen NUI
  SetNuiFocus(true, true)
  isCreatingDisplayVehicle = false
  
  if coords then
    -- Save to database
    lib.callback.await("jg-dealerships:server:create-display-vehicle", false, dealershipId, spawnCode, color, coords)
    
    -- Reopen management UI
    DealershipManagement.Client.Open(dealershipId, "displayVehicles", fromAdmin)
    cb(true)
  else
    -- Reopen management UI
    DealershipManagement.Client.Open(dealershipId, "displayVehicles", fromAdmin)
    cb(false)
  end
end)

-- NUI Callback: Edit an existing display vehicle
RegisterNUICallback("edit-display-vehicle", function(data, cb)
  local id = data.id
  local dealershipId = data.dealershipId
  local spawnCode = data.spawnCode
  local color = data.color
  
  -- Update in database
  lib.callback.await("jg-dealerships:server:edit-display-vehicle", false, dealershipId, id, spawnCode, color)
  
  cb(true)
end)

-- NUI Callback: Delete a display vehicle
RegisterNUICallback("delete-display-vehicle", function(data, cb)
  local id = data.id
  local dealershipId = data.dealershipId
  
  -- Delete from database
  lib.callback.await("jg-dealerships:server:delete-display-vehicle", false, dealershipId, id)
  
  cb(true)
end)

-- NUI Callback: Reset display vehicles (respawn all)
RegisterNUICallback("reset-display-vehicles", function(data, cb)
  local dealershipId = data.dealershipId
  
  DisplayVehicles.Client.SpawnAll(dealershipId)
  
  cb(true)
end)

-- Prevent players from entering display vehicles
lib.onCache("vehicle", function(vehicle)
  if vehicle and Entity(vehicle).state.isDisplayVehicle then
    Framework.Client.Notify(Locale.vehicleSecurityBreachDetected, "warning")
    
    -- Freeze vehicle and trigger alarm
    FreezeEntityPosition(vehicle, true)
    SetVehicleAlarm(vehicle, true)
    StartVehicleAlarm(vehicle)
  end
end)

-- Cleanup on resource stop
AddEventHandler("onResourceStop", function(resourceName)
  if GetCurrentResourceName() == resourceName then
    DisplayVehicles.Client.DeleteAll()
  end
end)
