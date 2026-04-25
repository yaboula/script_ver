



-- Initialize Admin namespace
Admin = Admin or {}
Admin.Client = Admin.Client or {}

-- Open the admin panel
function Admin.Client.Open()
  local currencies = lib.callback.await("jg-dealerships:server:get-currencies", false)
  
  SetNuiFocus(true, true)
  SendNUIMessage({
    type = "showNewAdmin",
    locale = Locale,
    config = Config,
    currencies = currencies
  })
end

-- Register event to open admin panel
RegisterNetEvent("jg-dealerships:client:open-admin", function()
  Admin.Client.Open()
end)
-- NUI Callback: Fetch all locations for admin panel
RegisterNUICallback("fetch-all-locations-admin", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:fetch-all-locations-admin")
  cb(result)
end)
-- NUI Callback: Create new location
RegisterNUICallback("create-location", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:create-location", false, data)
  cb(result)
end)
-- NUI Callback: Update existing location
RegisterNUICallback("update-location", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:update-location", false, data)
  cb(result)
end)
-- NUI Callback: Delete location
RegisterNUICallback("delete-location", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:delete-location", false, data)
  cb(result)
end)
-- NUI Callback: Toggle location disabled status
RegisterNUICallback("toggle-location-disabled", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:toggle-location-disabled", false, data)
  cb(result)
end)
-- NUI Callback: Validate job name
RegisterNUICallback("validate-job", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:validate-job", false, data)
  cb(result)
end)
-- NUI Callback: Validate gang name
RegisterNUICallback("validate-gang", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:validate-gang", false, data)
  cb(result)
end)
-- NUI Callback: Open location management
RegisterNUICallback("manage-location", function(data, cb)
  DealershipManagement.Client.Open(data, nil, true)
  cb(true)
end)
-- NUI Callback: Set GPS waypoint to location
RegisterNUICallback("set-waypoint", function(data, cb)
  SetNewWaypoint(data.x, data.y)
  cb(true)
end)
-- NUI Callback: Fetch all vehicles for admin panel
RegisterNUICallback("fetch-all-vehicles-admin", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:fetch-all-vehicles-admin")
  cb(result)
end)
-- NUI Callback: Add new vehicle
RegisterNUICallback("add-vehicle", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:add-vehicle", false, data)
  cb(result)
end)

-- NUI Callback: Update existing vehicle
RegisterNUICallback("update-vehicle", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:update-vehicle", false, data, data.updateDealerPrices)
  cb(result)
end)

-- NUI Callback: Delete vehicle
RegisterNUICallback("delete-vehicle", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:delete-vehicle", false, data)
  cb(result)
end)

-- NUI Callback: Verify if spawn code is valid
RegisterNUICallback("verify-spawn-code", function(spawnCode, cb)
  if not spawnCode then
    return cb(false)
  end
  
  local isValid = IsModelValid(joaat(spawnCode))
  cb(isValid)
end)

-- NUI Callback: Import V1 locations
RegisterNUICallback("import-v1-locations", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:import-v1-locations", false, data)
  cb(result)
end)

-- NUI Callback: Preview vehicles data before import
RegisterNUICallback("preview-vehicles-data", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:preview-vehicles-data", false, data.source)
  cb(result)
end)

-- NUI Callback: Import vehicles data
RegisterNUICallback("import-vehicles-data", function(data, cb)
  local result = lib.callback.await("jg-dealerships:server:import-vehicles-data", false, data.source, data.behaviour, data.stockMethod)
  cb(result)
end)
