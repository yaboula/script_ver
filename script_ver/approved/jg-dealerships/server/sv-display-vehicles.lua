



-- Callback: Get all display vehicles for a dealership
lib.callback.register("jg-dealerships:server:get-display-vehicles", function(playerId, dealershipId)
  -- Query display vehicles with vehicle info
  local displayVehicles = MySQL.query.await(
    "SELECT dispveh.*, vehicle.model, vehicle.brand FROM dealership_dispveh dispveh INNER JOIN dealership_vehicles vehicle ON dispveh.vehicle = vehicle.spawn_code WHERE dealership = ?",
    {dealershipId}
  )
  
  -- Decode color JSON for each vehicle
  for index, vehicle in ipairs(displayVehicles) do
    displayVehicles[index].color = json.decode(vehicle.color)
  end
  
  return displayVehicles
end)

-- Callback: Create a new display vehicle
lib.callback.register("jg-dealerships:server:create-display-vehicle", function(playerId, dealershipId, spawnCode, color, coords)
  -- Encode color if it's a table
  if type(color) == "table" then
    color = json.encode(color) or color
  end
  
  -- Insert display vehicle into database
  MySQL.query.await(
    "INSERT INTO dealership_dispveh (dealership,vehicle,color,coords) VALUES(?,?,?,?)",
    {dealershipId, spawnCode, color, json.encode(coords)}
  )
  
  -- Notify all clients to refresh display vehicles
  TriggerClientEvent("jg-dealerships:client:spawn-display-vehicles", -1, dealershipId)
  
  return true
end)

-- Callback: Edit an existing display vehicle
lib.callback.register("jg-dealerships:server:edit-display-vehicle", function(playerId, dealershipId, displayVehicleId, newSpawnCode, newColor)
  -- Encode color if it's a table
  if type(newColor) == "table" then
    newColor = json.encode(newColor) or newColor
  end
  
  -- Update display vehicle in database
  MySQL.query.await(
    "UPDATE dealership_dispveh SET vehicle = ?, color = ? WHERE id = ?",
    {newSpawnCode, newColor, displayVehicleId}
  )
  
  -- Notify all clients to refresh display vehicles
  TriggerClientEvent("jg-dealerships:client:spawn-display-vehicles", -1, dealershipId)
  
  return true
end)

-- Callback: Delete a display vehicle
lib.callback.register("jg-dealerships:server:delete-display-vehicle", function(playerId, dealershipId, displayVehicleId)
  -- Delete display vehicle from database
  MySQL.query.await(
    "DELETE FROM dealership_dispveh WHERE id = ?",
    {displayVehicleId}
  )
  
  -- Notify all clients to refresh display vehicles
  TriggerClientEvent("jg-dealerships:client:spawn-display-vehicles", -1, dealershipId)
  
  return true
end)
