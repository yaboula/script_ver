



-- Initialize namespace
Locations = Locations or {}
Locations.Server = Locations.Server or {}

-- Module-level cache for all locations
local locationsCache = {}

-- Clear the locations cache
function Locations.Server.ClearCache()
  locationsCache = {}
end
---Parse a location from database format to Lua format

local function ParseLocation(location)
  if not location or type(location) ~= "table" then
    error("location must be a table")
  end
  
  -- Decode all JSON coordinate fields
  location.showroom_coords = json.decode(location.showroom_coords)
  location.management_coords = json.decode(location.management_coords)
  location.dealership_zone = json.decode(location.dealership_zone)
  location.purchase_vehicle_coords = json.decode(location.purchase_vehicle_coords)
  location.trucking_vehicle_coords = json.decode(location.trucking_vehicle_coords)
  location.categories = json.decode(location.categories)
  location.sell_vehicle_coords = json.decode(location.sell_vehicle_coords)
  location.test_drive_coords = json.decode(location.test_drive_coords)
  
  -- Decode configuration fields
  location.camera_data = json.decode(location.camera_data)
  location.blip_data = json.decode(location.blip_data)
  location.marker_data = json.decode(location.marker_data)
  location.colour_options = json.decode(location.colour_options)
  
  -- Decode whitelist fields
  location.showroom_job_whitelist = json.decode(location.showroom_job_whitelist)
  location.showroom_gang_whitelist = json.decode(location.showroom_gang_whitelist)
  location.society_purchase_job_whitelist = json.decode(location.society_purchase_job_whitelist)
  location.society_purchase_gang_whitelist = json.decode(location.society_purchase_gang_whitelist)
  
  -- Decode job rank fields
  location.job_rank_permissions = json.decode(location.job_rank_permissions)
  location.job_rank_mapping = json.decode(location.job_rank_mapping)
  
  -- Decode payment methods with default fallback
  local paymentMethods = json.decode(location.payment_methods)
  if not paymentMethods then
    paymentMethods = {"bank", "cash"}
  end
  location.payment_methods = paymentMethods
  
  return location
end
---Get all dealership locations

function Locations.Server.GetAll(includeDisabled)
  -- If cache exists and has data, use it
  if type(locationsCache) == "table" and next(locationsCache) then
    if includeDisabled then
      return TableValues(locationsCache)
    end
    
    -- Filter out disabled locations
    local filtered = {}
    for _, location in pairs(locationsCache) do
      if not location.disabled or location.disabled == 0 then
        filtered[#filtered + 1] = location
      end
    end
    return filtered
  end
  
  -- Load from database
  local results = MySQL.query.await("SELECT * FROM dealership_locations")
  
  -- Parse and cache each location
  for _, location in ipairs(results) do
    locationsCache[location.id] = ParseLocation(location)
  end
  
  -- Return all or filtered
  if includeDisabled then
    return TableValues(locationsCache)
  end
  
  local filtered = {}
  for _, location in pairs(locationsCache) do
    if not location.disabled or location.disabled == 0 then
      filtered[#filtered + 1] = location
    end
  end
  return filtered
end
---Get all locations with just ID and name (lightweight)

function Locations.Server.GetAllIdAndNameOnly()
  -- Ensure cache is loaded
  if not (type(locationsCache) == "table" and next(locationsCache)) then
    Locations.Server.GetAll()
  end
  
  local simplified = {}
  for _, location in pairs(locationsCache) do
    simplified[#simplified + 1] = {
      id = location.id,
      name = location.name
    }
  end
  
  return simplified
end
---Get all public-facing locations with player permissions calculated

function Locations.Server.GetAllPublic(source)
  local locations = MySQL.query.await([[
    SELECT id, name, type, owner_id, job_name,
    dealership_zone, showroom_coords, management_coords,
    purchase_vehicle_coords, enable_sell_vehicle,
    sell_vehicle_coords, sell_vehicle_percent, enable_test_drive,
    test_drive_coords, colour_selection_type, colour_options,
    showroom_job_whitelist, showroom_gang_whitelist
    FROM dealership_locations
    WHERE disabled = 0
  ]])
  
  local playerJob = Framework.Server.GetPlayerJob(source)
  local playerGang = Framework.Server.GetPlayerGang(source)
  
  for i, location in ipairs(locations) do
    -- Decode JSON fields with fallback to empty object
    locations[i].dealership_zone = json.decode(location.dealership_zone or "{}")
    locations[i].showroom_coords = json.decode(location.showroom_coords or "{}")
    locations[i].management_coords = json.decode(location.management_coords or "{}")
    locations[i].purchase_vehicle_coords = json.decode(location.purchase_vehicle_coords or "{}")
    locations[i].sell_vehicle_coords = json.decode(location.sell_vehicle_coords or "{}")
    locations[i].test_drive_coords = json.decode(location.test_drive_coords or "{}")
    locations[i].blip_data = json.decode(location.blip_data or "{}")
    locations[i].colour_options = json.decode(location.colour_options or "{}")
    locations[i].marker_data = json.decode(location.marker_data or "{}")
    locations[i].showroom_job_whitelist = json.decode(location.showroom_job_whitelist or "{}")
    locations[i].showroom_gang_whitelist = json.decode(location.showroom_gang_whitelist or "{}")
    
    -- Check if location has any whitelists configured
    local hasJobWhitelist = locations[i].showroom_job_whitelist and next(locations[i].showroom_job_whitelist)
    local hasGangWhitelist = locations[i].showroom_gang_whitelist and next(locations[i].showroom_gang_whitelist)
    
    -- Calculate showroom access permission
    if not hasJobWhitelist and not hasGangWhitelist then
      -- No whitelist = everyone can access
      locations[i].playerCanAccessShowroom = true
    else
      -- Check job whitelist
      local passesJobCheck = false
      if hasJobWhitelist then
        passesJobCheck = CheckJobGangWhitelist(
          locations[i].showroom_job_whitelist,
          playerJob.name,
          playerJob.grade
        )
      end
      
      -- Check gang whitelist
      local passesGangCheck = false
      if hasGangWhitelist then
        passesGangCheck = CheckJobGangWhitelist(
          locations[i].showroom_gang_whitelist,
          playerGang.name,
          playerGang.grade
        )
      end
      
      -- Player passes if they pass either check
      locations[i].playerCanAccessShowroom = passesJobCheck or passesGangCheck
    end
    
    -- Calculate employee status for owned dealerships
    if location.type == "owned" then
      local isEmployee = Employees.Server.IsEmployee(source, location.id, nil, false)
      locations[i].playerIsEmployee = isEmployee and true or false
    else
      locations[i].playerIsEmployee = false
    end
    
    -- Strip sensitive whitelist data before sending to client
    locations[i].showroom_job_whitelist = nil
    locations[i].showroom_gang_whitelist = nil
  end
  
  return locations
end
---Get a single location by ID

function Locations.Server.GetById(locationId, includeDisabled)
  -- Check cache first
  if locationsCache[locationId] then
    local location = locationsCache[locationId]
    
    if not includeDisabled then
      if location.disabled and location.disabled == 1 then
        return false
      end
    end
    
    return location
  end
  
  -- Load from database
  local location = MySQL.single.await(
    "SELECT * FROM dealership_locations WHERE id = ?",
    {locationId}
  )
  
  if not location then
    return false
  end
  
  -- Parse and cache
  locationsCache[location.id] = ParseLocation(location)
  
  -- Check disabled status
  if not includeDisabled then
    if location.disabled and location.disabled == 1 then
      return false
    end
  end
  
  return locationsCache[location.id]
end
---Create a new dealership location

function Locations.Server.Create(data)
  -- Generate unique UUID for the location
  local locationId = Utils.Server.GenerateUuid()
  local retries = 10
  
  -- Ensure UUID is unique (retry up to 10 times)
  while true do
    local exists = MySQL.scalar.await(
      "SELECT id FROM dealership_locations WHERE id = ?",
      {locationId}
    )
    
    if not (exists and retries > 0) then
      break
    end
    
    DebugPrint("uuid not available, trying again...")
    locationId = Utils.Server.GenerateUuid()
    retries = retries - 1
  end
  
  -- Encode all JSON fields for database storage
  local paymentMethods = data.payment_methods and json.encode(data.payment_methods) or json.encode({"bank", "cash"})
  
  -- Insert new location into database
  MySQL.insert.await([[
    INSERT INTO dealership_locations
    (id, name, type, job_name, job_rank_permissions, job_rank_mapping, dealership_zone, showroom_coords, management_coords, purchase_vehicle_coords,
    trucking_vehicle_coords, categories, enable_finance, enable_sell_vehicle, sell_vehicle_coords,
    sell_vehicle_percent, enable_test_drive, test_drive_coords, camera_data, colour_selection_type,
    colour_options, enable_purchase, showroom_job_whitelist, showroom_gang_whitelist,
    society_purchase_job_whitelist, society_purchase_gang_whitelist, payment_methods)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  ]], {
    locationId,
    data.name,
    data.type,
    data.job_name,
    data.job_rank_permissions and json.encode(data.job_rank_permissions),
    data.job_rank_mapping and json.encode(data.job_rank_mapping),
    data.dealership_zone and json.encode(data.dealership_zone),
    data.showroom_coords and json.encode(data.showroom_coords),
    data.management_coords and json.encode(data.management_coords),
    data.purchase_vehicle_coords and json.encode(data.purchase_vehicle_coords),
    data.trucking_vehicle_coords and json.encode(data.trucking_vehicle_coords),
    data.categories and json.encode(data.categories),
    data.enable_finance,
    data.enable_sell_vehicle,
    data.sell_vehicle_coords and json.encode(data.sell_vehicle_coords),
    data.sell_vehicle_percent,
    data.enable_test_drive,
    data.test_drive_coords and json.encode(data.test_drive_coords),
    data.camera_data and json.encode(data.camera_data),
    data.colour_selection_type,
    data.colour_options and json.encode(data.colour_options),
    data.enable_purchase,
    data.showroom_job_whitelist and json.encode(data.showroom_job_whitelist),
    data.showroom_gang_whitelist and json.encode(data.showroom_gang_whitelist),
    data.society_purchase_job_whitelist and json.encode(data.society_purchase_job_whitelist),
    data.society_purchase_gang_whitelist and json.encode(data.society_purchase_gang_whitelist),
    paymentMethods
  })
  
  -- Add ID to the data and cache it
  data.id = locationId
  locationsCache[locationId] = data
  
  -- Return refreshed locations and new ID
  local locations = Locations.Server.GetAll(false)
  return locations, locationId
end
---Update an existing dealership location

function Locations.Server.Update(locationId, data)
  -- Encode all JSON fields for database storage
  local paymentMethods = data.payment_methods and json.encode(data.payment_methods) or json.encode({"bank", "cash"})
  
  -- Update location in database
  MySQL.update.await([[
    UPDATE dealership_locations SET name = ?, type = ?, job_name = ?, job_rank_permissions = ?, job_rank_mapping = ?,
    dealership_zone = ?, showroom_coords = ?, management_coords = ?, purchase_vehicle_coords = ?, trucking_vehicle_coords = ?,
    categories = ?, enable_finance = ?,
    enable_sell_vehicle = ?, sell_vehicle_coords = ?, sell_vehicle_percent = ?,
    enable_test_drive = ?, test_drive_coords = ?, camera_data = ?,
    colour_selection_type = ?, colour_options = ?, enable_purchase = ?,
    showroom_job_whitelist = ?, showroom_gang_whitelist = ?,
    society_purchase_job_whitelist = ?, society_purchase_gang_whitelist = ?, payment_methods = ?
    WHERE id = ?
  ]], {
    data.name,
    data.type,
    data.job_name,
    data.job_rank_permissions and json.encode(data.job_rank_permissions),
    data.job_rank_mapping and json.encode(data.job_rank_mapping),
    data.dealership_zone and json.encode(data.dealership_zone),
    data.showroom_coords and json.encode(data.showroom_coords),
    data.management_coords and json.encode(data.management_coords),
    data.purchase_vehicle_coords and json.encode(data.purchase_vehicle_coords),
    data.trucking_vehicle_coords and json.encode(data.trucking_vehicle_coords),
    data.categories and json.encode(data.categories),
    data.enable_finance,
    data.enable_sell_vehicle,
    data.sell_vehicle_coords and json.encode(data.sell_vehicle_coords),
    data.sell_vehicle_percent,
    data.enable_test_drive,
    data.test_drive_coords and json.encode(data.test_drive_coords),
    data.camera_data and json.encode(data.camera_data),
    data.colour_selection_type,
    data.colour_options and json.encode(data.colour_options),
    data.enable_purchase,
    data.showroom_job_whitelist and json.encode(data.showroom_job_whitelist),
    data.showroom_gang_whitelist and json.encode(data.showroom_gang_whitelist),
    data.society_purchase_job_whitelist and json.encode(data.society_purchase_job_whitelist),
    data.society_purchase_gang_whitelist and json.encode(data.society_purchase_gang_whitelist),
    paymentMethods,
    locationId
  })
  
  -- Update cache
  data.id = locationId
  locationsCache[locationId] = data
  
  -- Return refreshed locations
  return Locations.Server.GetAll(false)
end
---Delete a dealership location and all related data

function Locations.Server.Delete(locationId)
  -- Get all coupons for this dealership
  local coupons = MySQL.query.await(
    "SELECT id FROM dealership_coupons WHERE dealership_id = ?",
    {locationId}
  )
  
  -- Delete coupon usage records for each coupon
  for _, coupon in ipairs(coupons or {}) do
    MySQL.query.await(
      "DELETE FROM dealership_coupon_usage WHERE coupon_id = ?",
      {coupon.id}
    )
  end
  
  -- Delete all coupons for this dealership
  MySQL.query.await(
    "DELETE FROM dealership_coupons WHERE dealership_id = ?",
    {locationId}
  )
  
  -- Delete all employees
  MySQL.query.await(
    "DELETE FROM dealership_employees WHERE dealership = ?",
    {locationId}
  )
  
  -- Delete all stock
  MySQL.query.await(
    "DELETE FROM dealership_stock WHERE dealership = ?",
    {locationId}
  )
  
  -- Delete the location itself
  MySQL.query.await(
    "DELETE FROM dealership_locations WHERE id = ?",
    {locationId}
  )
  
  -- Remove from cache
  locationsCache[locationId] = nil
  
  -- Return refreshed locations
  return Locations.Server.GetAll(false)
end
---Enable or disable a dealership location

function Locations.Server.SetDisabled(locationId, disabled)
  -- Convert boolean to database value (1 or 0)
  local disabledValue = disabled and 1 or 0
  
  -- Update the disabled status in database
  MySQL.update.await(
    "UPDATE dealership_locations SET disabled = ? WHERE id = ?",
    {disabledValue, locationId}
  )
  
  -- Refresh the location in cache
  local location = MySQL.single.await(
    "SELECT * FROM dealership_locations WHERE id = ?",
    {locationId}
  )
  
  if location then
    locationsCache[locationId] = ParseLocation(location)
  end
  
  return true
end
---Refresh a single location from the database

function Locations.Server.RefreshLocation(locationId)
  -- Fetch location from database
  local location = MySQL.single.await(
    "SELECT * FROM dealership_locations WHERE id = ?",
    {locationId}
  )
  
  if location then
    -- Parse and update cache
    locationsCache[locationId] = ParseLocation(location)
    return locationsCache[locationId]
  end
  
  return nil
end
---Sync dealership stock based on vehicle categories

function Locations.Server.SyncStockByCategories(locationId, categoriesToAdd, categoriesToRemove, allowRemoval)
  local result = {
    added = 0,
    removed = 0
  }
  
  -- Add vehicles from new categories
  if categoriesToAdd and #categoriesToAdd > 0 then
    local vehicles = MySQL.query.await([[
      SELECT spawn_code, price FROM dealership_vehicles
      WHERE category IN (?)
    ]], {categoriesToAdd})
    
    if vehicles then
      for _, vehicle in ipairs(vehicles) do
        -- INSERT IGNORE will skip if vehicle already exists in stock
        local insertId = MySQL.insert.await([[
          INSERT IGNORE INTO dealership_stock (vehicle, dealership, stock, price)
          VALUES (?, ?, 0, ?)
        ]], {
          vehicle.spawn_code,
          locationId,
          vehicle.price
        })
        
        if insertId then
          result.added = result.added + 1
        end
      end
    end
  end
  
  -- Remove vehicles from removed categories (only if allowed)
  if allowRemoval and categoriesToRemove and #categoriesToRemove > 0 then
    local vehicles = MySQL.query.await([[
      SELECT spawn_code FROM dealership_vehicles
      WHERE category IN (?)
    ]], {categoriesToRemove})
    
    if vehicles then
      for _, vehicle in ipairs(vehicles) do
        local deleteResult = MySQL.query.await([[
          DELETE FROM dealership_stock
          WHERE vehicle = ? AND dealership = ?
        ]], {
          vehicle.spawn_code,
          locationId
        })
        
        if deleteResult and deleteResult.affectedRows and deleteResult.affectedRows > 0 then
          result.removed = result.removed + deleteResult.affectedRows
        end
      end
    end
  end
  
  -- Clear showroom cache if any changes were made
  if result.added > 0 or result.removed > 0 then
    Showroom.Server.ClearVehicleCache()
  end
  
  return result
end
-- Register callback for clients to get all public locations
lib.callback.register("jg-dealerships:server:get-all-locations", Locations.Server.GetAllPublic)
