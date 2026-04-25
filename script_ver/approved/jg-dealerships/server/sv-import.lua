



Import = Import or {}
Import.Server = Import.Server or {}

-- ---------------------------------------------------------------------------
-- TableExists(tableName)
-- Returns true if the named MySQL table exists in the current database.
-- ---------------------------------------------------------------------------
local function TableExists(tableName)
  local count = MySQL.scalar.await([[
    SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = ?
  ]], { tableName })
  return count and count > 0
end

-- ---------------------------------------------------------------------------
-- BuildZonePoint(coords, radius, blipData, markerData, hideBlip, hideMarkers)
-- Constructs a zone-point descriptor table used by the dealership zone system.
-- ---------------------------------------------------------------------------
local function BuildZonePoint(coords, radius, blipData, markerData, hideBlip, hideMarkers)
  -- Resolve marker size (default 0.3)
  local markerSize = 0.3
  if markerData and markerData.size and markerData.size.x then
    markerSize = markerData.size.x
  end

  -- Resolve marker colour (default white, semi-transparent)
  local markerColor = { r = 255, g = 255, b = 255, a = 120 }
  if markerData and markerData.color then
    markerColor = {
      r = markerData.color.r or 255,
      g = markerData.color.g or 255,
      b = markerData.color.b or 255,
      a = markerData.color.a or 120,
    }
  end

  -- Build the zone-point table
  local point = { type = "point" }

  point.coords = {
    {
      x = coords.x,
      y = coords.y,
      z = coords.z,
      w = coords.w or 0.0,
    }
  }

  point.radius    = radius or 5.0
  point.enableBlip = not hideBlip and blipData ~= nil

  -- Blip icon (default 326)
  point.blipIconId  = (blipData and blipData.id) or 326

  -- Blip colour (default 2)
  point.blipColourId = (blipData and blipData.color) or 2

  -- Blip scale (default 0.6)
  point.blipSize = (blipData and blipData.scale) or 0.6

  point.enableMarker = not hideMarkers

  -- Marker type (default 21)
  point.markerId = (markerData and markerData.id) or 21

  point.markerSize      = markerSize
  point.markerColor     = markerColor
  point.markerBobUpAndDown = (markerData and markerData.bobUpAndDown) == 1 or (markerData and markerData.bobUpAndDown) or false
  point.markerFaceCamera   = (markerData and markerData.faceCamera)   == 1 or (markerData and markerData.faceCamera)   or false
  point.markerRotate       = (markerData and markerData.rotate)        == 1 or (markerData and markerData.rotate)       or false
  point.markerDrawOnEnts   = (markerData and markerData.drawOnEnts)    == 1 or (markerData and markerData.drawOnEnts)   or false

  return point
end

-- ---------------------------------------------------------------------------
-- BuildSquareZone(center, halfSize)
-- Returns a four-corner polygon (at a fixed Z) around the given centre point.
-- ---------------------------------------------------------------------------
local function BuildSquareZone(center, halfSize)
  local z = center.z
  return {
    { x = center.x - halfSize, y = center.y - halfSize, z = z },
    { x = center.x + halfSize, y = center.y - halfSize, z = z },
    { x = center.x + halfSize, y = center.y + halfSize, z = z },
    { x = center.x - halfSize, y = center.y + halfSize, z = z },
  }
end

-- ---------------------------------------------------------------------------
-- CopyCoords(coordsTable)
-- Shallow-copies an {x, y, z, w} coordinate table.
-- ---------------------------------------------------------------------------
local function CopyCoords(coordsTable)
  return {
    x = coordsTable.x,
    y = coordsTable.y,
    z = coordsTable.z,
    w = coordsTable.w,
  }
end

-- ---------------------------------------------------------------------------
-- GetJobRankMapping(jobName)
-- Queries the framework for rank data for the given job and maps employee
-- permission roles (manager, supervisor, sales) to numeric ranks.
-- Returns a mapping table, or nil if the job is invalid.
-- ---------------------------------------------------------------------------
local function GetJobRankMapping(jobName)
  local isValid, grades = Framework.Server.IsValidJob(jobName)

  if not isValid or not grades or #grades == 0 then
    return nil
  end

  -- Copy grades into a plain array and sort descending by rank value
  local sortedGrades = {}
  for _, grade in ipairs(grades) do
    sortedGrades[#sortedGrades + 1] = grade
  end
  table.sort(sortedGrades, function(a, b) return a.rank > b.rank end)

  -- Determine which permission-role keys are configured
  local permissionKeys = TableKeys(Config.EmployeePermissions or {})
  if not permissionKeys or #permissionKeys == 0 then
    permissionKeys = { "manager", "supervisor", "sales" }
  end

  -- Map each permission key to a grade rank, falling back to the lowest grade
  local mapping = {}
  for i, permKey in ipairs(permissionKeys) do
    if sortedGrades[i] then
      mapping[permKey] = sortedGrades[i].rank
    elseif #sortedGrades > 0 then
      mapping[permKey] = sortedGrades[#sortedGrades].rank
    end
  end

  return mapping
end

-- ---------------------------------------------------------------------------
-- ParseColourOptions(useRGB, optionsTable)
-- Parses the Config.VehicleColourOptions list into a normalised array.
-- Returns: parsedOptions (array), errors (array of warning strings).
-- ---------------------------------------------------------------------------
local function ParseColourOptions(useRGB, optionsTable)
  local parsed = {}
  local errors = {}

  if not optionsTable or type(optionsTable) ~= "table" then
    return parsed, errors
  end

  for i, option in ipairs(optionsTable) do
    local optionId    = tostring(i) .. "-" .. (option.label or "Unknown")
    local colorValue  = nil

    if useRGB then
      -- Convert hex string to RGB
      if option.hex then
        local ok, r, g, b = pcall(lib.math.hextorgb, option.hex)
        if ok and r and g and b then
          colorValue = { r = r, g = g, b = b }
        else
          errors[#errors + 1] = ("Failed to convert hex '%s' for colour option '%s'"):format(
            option.hex or "nil", option.label or "Unknown"
          )
        end
      else
        errors[#errors + 1] = ("Missing hex value for colour option '%s'"):format(option.label or "Unknown")
      end
    else
      -- Use a numeric index value
      if option.index then
        colorValue = option.index
      else
        errors[#errors + 1] = ("Missing index value for colour option '%s'"):format(option.label or "Unknown")
      end
    end

    if colorValue then
      parsed[#parsed + 1] = { id = optionId, color = colorValue }
    end
  end

  return parsed, errors
end

-- ---------------------------------------------------------------------------
-- GetCameraData(cameraCfg)
-- Normalises camera configuration from a raw config entry.
-- Returns a table with preset, coords, and zoomLevels.
-- ---------------------------------------------------------------------------
local function GetCameraData(cameraCfg)
  if not cameraCfg then
    return {
      preset     = "Car",
      coords     = { x = 0, y = 0, z = 0, w = 0 },
      zoomLevels = { "5", "8", "12", "8" },
    }
  end

  -- Build zoom levels from config positions, or fall back to defaults
  local zoomLevels
  if cameraCfg.positions then
    zoomLevels = {}
    for _, pos in ipairs(cameraCfg.positions) do
      zoomLevels[#zoomLevels + 1] = tostring(pos)
    end
  else
    zoomLevels = { "5", "8", "12", "8" }
  end

  -- Build coords, defaulting each component to 0
  local coords = {
    x = (cameraCfg.coords and cameraCfg.coords.x) or 0,
    y = (cameraCfg.coords and cameraCfg.coords.y) or 0,
    z = (cameraCfg.coords and cameraCfg.coords.z) or 0,
    w = (cameraCfg.coords and cameraCfg.coords.w) or 0,
  }

  return {
    preset     = cameraCfg.name or "Car",
    coords     = coords,
    zoomLevels = zoomLevels,
  }
end

-- ---------------------------------------------------------------------------
-- ParseLocationConfig(locationId, rawConfig, existingDbData)
-- Converts a raw Config.DealershipLocations entry into the normalised DB
-- schema format.  Returns { data = ..., errors = { ... } }.
-- ---------------------------------------------------------------------------
local function ParseLocationConfig(locationId, rawConfig, existingDbData)
  local errors  = {}
  local locData = { id = locationId }

  -- ---- Name ----------------------------------------------------------------
  if rawConfig.label and rawConfig.label ~= "" then
    locData.name = rawConfig.label
  elseif existingDbData and existingDbData.label and existingDbData.label ~= "" then
    locData.name = existingDbData.label
  else
    locData.name = locationId
  end

  -- ---- Type ----------------------------------------------------------------
  if rawConfig.type == "owned" then
    locData.type = "owned"
  elseif rawConfig.type == "self-service" then
    locData.type = "selfService"
  else
    locData.type = "selfService"
    errors[#errors + 1] = ("Unknown type '%s', defaulting to 'selfService'"):format(tostring(rawConfig.type))
  end

  -- ---- Job (owned dealerships only) ----------------------------------------
  if locData.type == "owned" and rawConfig.job then
    local isValid, _ = Framework.Server.IsValidJob(rawConfig.job)
    if isValid then
      locData.job_name        = rawConfig.job
      locData.job_rank_mapping = GetJobRankMapping(rawConfig.job)
      if not locData.job_rank_mapping then
        errors[#errors + 1] = ("Job '%s' is valid but could not build rank mapping"):format(rawConfig.job)
      end
    else
      errors[#errors + 1] = ("Invalid job '%s', skipping job configuration"):format(rawConfig.job)
    end
  end
  locData.job_rank_permissions = nil

  -- ---- Balance / owner -----------------------------------------------------
  if existingDbData then
    locData.balance      = existingDbData.balance or 0
    locData.owner_id     = existingDbData.owner_id
    locData.owner_name   = existingDbData.owner_name
    locData.employee_commission = existingDbData.employee_commission or 10
  else
    locData.balance             = 0
    locData.employee_commission = 10
  end

  -- ---- Dealership zone -----------------------------------------------------
  if rawConfig.zone then
    if type(rawConfig.zone) == "table" and #rawConfig.zone >= 3 then
      -- Explicit polygon zone
      locData.dealership_zone = {}
      for _, pt in ipairs(rawConfig.zone) do
        locData.dealership_zone[#locData.dealership_zone + 1] = { x = pt.x, y = pt.y, z = pt.z }
      end
    end
  elseif rawConfig.openShowroom and rawConfig.openShowroom.coords then
    -- Auto-generate a square zone from the showroom coords
    local distance = rawConfig.directSaleDistance or 50.0
    locData.dealership_zone = BuildSquareZone(rawConfig.openShowroom.coords, distance)
  else
    errors[#errors + 1] = "Missing zone or openShowroom.coords, cannot generate dealership_zone"
  end

  -- ---- Showroom interaction point ------------------------------------------
  if rawConfig.openShowroom and rawConfig.openShowroom.coords then
    locData.showroom_coords = {
      BuildZonePoint(
        rawConfig.openShowroom.coords,
        rawConfig.openShowroom.size or 5,
        rawConfig.blip,
        rawConfig.markers,
        rawConfig.hideBlip,
        rawConfig.hideMarkers
      )
    }
  else
    errors[#errors + 1] = "Missing openShowroom configuration (required)"
  end

  -- ---- Management interaction point ----------------------------------------
  if rawConfig.openManagement and rawConfig.openManagement.coords then
    locData.management_coords = {
      BuildZonePoint(
        rawConfig.openManagement.coords,
        rawConfig.openManagement.size or 5,
        rawConfig.blip,
        rawConfig.markers,
        rawConfig.hideBlip,
        rawConfig.hideMarkers
      )
    }
  end

  -- ---- Purchase spawn ------------------------------------------------------
  if rawConfig.purchaseSpawn then
    locData.purchase_vehicle_coords = CopyCoords(rawConfig.purchaseSpawn)
    locData.trucking_vehicle_coords  = CopyCoords(rawConfig.purchaseSpawn)
  else
    errors[#errors + 1] = "Missing purchaseSpawn configuration (required)"
  end

  -- ---- Finance / sell options ----------------------------------------------
  locData.enable_finance     = rawConfig.enableFinance     == true
  locData.enable_sell_vehicle = rawConfig.enableSellVehicle == true

  if rawConfig.sellVehicle and rawConfig.sellVehicle.coords then
    locData.sell_vehicle_coords = {
      BuildZonePoint(
        rawConfig.sellVehicle.coords,
        rawConfig.sellVehicle.size or 5,
        rawConfig.blip,
        rawConfig.markers,
        rawConfig.hideBlip,
        rawConfig.hideMarkers
      )
    }
  end

  if rawConfig.sellVehiclePercent then
    locData.sell_vehicle_percent = math.floor(rawConfig.sellVehiclePercent * 100)
  else
    locData.sell_vehicle_percent = 60
  end

  -- ---- Test drive ----------------------------------------------------------
  locData.enable_test_drive = rawConfig.enableTestDrive == true
  if rawConfig.testDriveSpawn then
    locData.test_drive_coords = CopyCoords(rawConfig.testDriveSpawn)
  end

  -- ---- Categories ----------------------------------------------------------
  if rawConfig.categories and type(rawConfig.categories) == "table" and #rawConfig.categories > 0 then
    locData.categories = rawConfig.categories
  else
    errors[#errors + 1] = "Missing or empty categories configuration (required)"
  end

  -- ---- Camera data ---------------------------------------------------------
  locData.camera_data = GetCameraData(rawConfig.camera)

  -- ---- Colour options ------------------------------------------------------
  locData.colour_selection_type = "RGB"
  if Config.VehicleColourOptions and #Config.VehicleColourOptions > 0 then
    local useRGB = Config.UseRGBColors == true
    locData.colour_selection_type = useRGB and "RGBOPT" or "IDOPT"
    local colourOptions, colourErrors = ParseColourOptions(useRGB, Config.VehicleColourOptions)
    locData.colour_options = colourOptions
    for _, err in ipairs(colourErrors) do
      errors[#errors + 1] = err
    end
  end

  -- ---- Purchase toggle & whitelists ----------------------------------------
  locData.enable_purchase = rawConfig.disableShowroomPurchase ~= true

  if rawConfig.showroomJobWhitelist and type(rawConfig.showroomJobWhitelist) == "table" then
    locData.showroom_job_whitelist = rawConfig.showroomJobWhitelist
  end
  if rawConfig.showroomGangWhitelist and type(rawConfig.showroomGangWhitelist) == "table" then
    locData.showroom_gang_whitelist = rawConfig.showroomGangWhitelist
  end
  if rawConfig.societyPurchaseJobWhitelist and type(rawConfig.societyPurchaseJobWhitelist) == "table" then
    locData.society_purchase_job_whitelist = rawConfig.societyPurchaseJobWhitelist
  end
  if rawConfig.societyPurchaseGangWhitelist and type(rawConfig.societyPurchaseGangWhitelist) == "table" then
    locData.society_purchase_gang_whitelist = rawConfig.societyPurchaseGangWhitelist
  end

  return { data = locData, errors = errors }
end

-- ---------------------------------------------------------------------------
-- LocationExists(locationId)
-- Returns true if a row with the given id already exists in dealership_locations.
-- ---------------------------------------------------------------------------
local function LocationExists(locationId)
  local count = MySQL.scalar.await(
    "SELECT COUNT(*) FROM dealership_locations WHERE id = ?",
    { locationId }
  )
  return count and count > 0
end

-- ---------------------------------------------------------------------------
-- InsertLocation(locData)
-- Inserts a fully-parsed location record into dealership_locations.
-- Returns: success (bool), errorMessage (string or nil).
-- ---------------------------------------------------------------------------
local function InsertLocation(locData)
  -- Wrap in pcall so a DB error is returned rather than crashing
  local ok, err = pcall(function()
    MySQL.insert.await([[
      INSERT INTO dealership_locations (
        id, name, type, job_name, job_rank_permissions, job_rank_mapping,
        balance, owner_id, owner_name, employee_commission,
        dealership_zone, showroom_coords, management_coords,
        purchase_vehicle_coords, trucking_vehicle_coords,
        enable_finance, enable_sell_vehicle, sell_vehicle_coords, sell_vehicle_percent,
        enable_test_drive, test_drive_coords, categories, camera_data,
        colour_selection_type, colour_options, enable_purchase,
        showroom_job_whitelist, showroom_gang_whitelist,
        society_purchase_job_whitelist, society_purchase_gang_whitelist
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
      locData.id,
      locData.name,
      locData.type,
      locData.job_name,
      locData.job_rank_permissions and json.encode(locData.job_rank_permissions) or nil,
      locData.job_rank_mapping      and json.encode(locData.job_rank_mapping)     or nil,
      locData.balance or 0,
      locData.owner_id,
      locData.owner_name,
      locData.employee_commission or 10,
      locData.dealership_zone   and json.encode(locData.dealership_zone)   or nil,
      json.encode(locData.showroom_coords),
      locData.management_coords  and json.encode(locData.management_coords) or nil,
      json.encode(locData.purchase_vehicle_coords),
      locData.trucking_vehicle_coords and json.encode(locData.trucking_vehicle_coords) or nil,
      locData.enable_finance      and 1 or 0,
      locData.enable_sell_vehicle and 1 or 0,
      locData.sell_vehicle_coords  and json.encode(locData.sell_vehicle_coords) or nil,
      locData.sell_vehicle_percent,
      locData.enable_test_drive   and 1 or 0,
      locData.test_drive_coords    and json.encode(locData.test_drive_coords)  or nil,
      json.encode(locData.categories),
      json.encode(locData.camera_data),
      locData.colour_selection_type,
      locData.colour_options and json.encode(locData.colour_options) or nil,
      locData.enable_purchase and 1 or 0,
      locData.showroom_job_whitelist             and json.encode(locData.showroom_job_whitelist)             or nil,
      locData.showroom_gang_whitelist            and json.encode(locData.showroom_gang_whitelist)            or nil,
      locData.society_purchase_job_whitelist     and json.encode(locData.society_purchase_job_whitelist)     or nil,
      locData.society_purchase_gang_whitelist    and json.encode(locData.society_purchase_gang_whitelist)    or nil,
    })
  end)

  if not ok then
    return false, tostring(err)
  end
  return true, nil
end

-- ---------------------------------------------------------------------------
-- Import.Server.ImportV1Locations(locationsTable)
-- Imports v1-format Config.DealershipLocations entries into the v2 DB schema.
-- Returns a result table: { success, imported, skipped, errors }.
-- ---------------------------------------------------------------------------
function Import.Server.ImportV1Locations(locationsTable)
  if not locationsTable then
    locationsTable = Config.DealershipLocations
  end

  local result = {
    success  = true,
    imported = {},
    skipped  = {},
    errors   = {},
  }

  -- Verify the target table exists
  if not TableExists("dealership_locations") then
    result.success = false
    result.errors._global = { "Database table 'dealership_locations' does not exist. Please run the v2 migration SQL first." }
    return result
  end

  -- Validate input
  if not locationsTable or type(locationsTable) ~= "table" then
    result.success = false
    result.errors._global = { "No locations provided and Config.DealershipLocations is not a valid table." }
    return result
  end

  -- Optionally load legacy dealership_data rows for carrying over owner/balance info
  local legacyData = {}
  if TableExists("dealership_data") then
    local rows = MySQL.query.await("SELECT * FROM dealership_data")
    if rows then
      for _, row in ipairs(rows) do
        legacyData[row.name] = row
      end
    end
  end

  -- Parse every location and collect blocking errors before any DB writes
  local parsedLocations = {}
  local hasBlockingErrors = false

  for locId, rawCfg in pairs(locationsTable) do
    if LocationExists(locId) then
      result.skipped[#result.skipped + 1] = locId
    else
      local parsed = ParseLocationConfig(locId, rawCfg, legacyData[locId])
      parsedLocations[locId] = parsed

      -- Flag any "(required)" errors as blocking
      local blockingErrs = {}
      for _, errMsg in ipairs(parsed.errors) do
        if errMsg:find("%(required%)") then
          blockingErrs[#blockingErrs + 1] = errMsg
          hasBlockingErrors = true
        end
      end

      if #parsed.errors > 0 then
        result.errors[locId] = parsed.errors
      end
    end
  end

  -- Abort if any required fields are missing
  if hasBlockingErrors then
    result.success = false
    result.errors._global = result.errors._global or {}
    result.errors._global[#result.errors._global + 1] = "Blocking errors found. Fix the issues above before importing."
    return result
  end

  -- Insert each parsed location
  for locId, parsed in pairs(parsedLocations) do
    local ok, dbErr = InsertLocation(parsed.data)
    if ok then
      result.imported[#result.imported + 1] = locId
    else
      result.success = false
      result.errors[locId] = result.errors[locId] or {}
      result.errors[locId][#result.errors[locId] + 1] = "Database insert failed: " .. (dbErr or "Unknown error")
    end
  end

  -- Notify all clients to recreate their dealership zones if anything was imported
  if #result.imported > 0 then
    TriggerClientEvent("jg-dealerships:client:create-dealership-locations", -1, nil, true)
  end

  return result
end

-- Callback: import v1 locations (admin-gated)
lib.callback.register("jg-dealerships:server:import-v1-locations",
  function(source, params)
    if not Framework.Server.IsAdmin(source) then
      Framework.Server.Notify(source, Locale.insufficientPermissions, "error")
      DebugPrint("Player " .. source .. " tried to import locations without permission", "warning")
      return {
        success  = false,
        imported = {},
        skipped  = {},
        errors   = { _global = { "Insufficient permissions" } },
      }
    end

    local locations = (params.source == "default") and DEFAULT_LOCATIONS or Config.DealershipLocations
    local result    = Import.Server.ImportV1Locations(locations)

    -- Optionally sync stock for newly-imported dealerships
    if result.success and #result.imported > 0 and params.syncStock then
      local totalAdded = 0
      for _, locId in ipairs(result.imported) do
        local loc = Locations.Server.GetById(locId, true)
        if loc and loc.categories and #loc.categories > 0 then
          local syncResult = Locations.Server.SyncStockByCategories(locId, loc.categories, {}, false)
          totalAdded = totalAdded + syncResult.added
        end
      end
      if totalAdded > 0 then
        Framework.Server.Notify(source, ("Stock sync: %d vehicles added"):format(totalAdded), "success")
      end
    end

    -- Webhook audit log
    if result.success and #result.imported > 0 then
      local skippedStr = #result.skipped > 0 and table.concat(result.skipped, ", ") or "None"
      SendWebhook(source, Webhooks.Admin, "Admin: Imported Locations", "success", {
        { key = "Source",     value = (params.source == "default") and "Default Locations" or "Config.lua" },
        { key = "Imported",   value = table.concat(result.imported, ", ") },
        { key = "Skipped",    value = skippedStr },
        { key = "Stock Sync", value = params.syncStock and "Yes" or "No" },
      })
    end

    return result
  end
)

-- ---------------------------------------------------------------------------
-- ClearAllVehicleData()
-- Wipes all vehicle-related tables (used for Overwrite imports).
-- ---------------------------------------------------------------------------
local function ClearAllVehicleData()
  MySQL.query.await("DELETE FROM dealership_dispveh")
  MySQL.query.await("DELETE FROM dealership_orders")
  MySQL.query.await("DELETE FROM dealership_sales")
  MySQL.query.await("DELETE FROM dealership_stock")
  MySQL.query.await("DELETE FROM dealership_vehicles")
end

-- ---------------------------------------------------------------------------
-- GetExistingVehicleSpawnCodes()
-- Returns a set (map of spawnCode → true) for all vehicles already in
-- the dealership_vehicles table, used to skip duplicates on Append.
-- ---------------------------------------------------------------------------
local function GetExistingVehicleSpawnCodes()
  local rows = MySQL.query.await("SELECT spawn_code FROM dealership_vehicles")
  local existing = {}
  if rows then
    for _, row in ipairs(rows) do
      existing[row.spawn_code] = true
    end
  end
  return existing
end

-- ---------------------------------------------------------------------------
-- GetLocationCategoryMap()
-- Returns a table mapping location id → categories array for all locations.
-- ---------------------------------------------------------------------------
local function GetLocationCategoryMap()
  local allLocations = Locations.Server.GetAll(true)
  local categoryMap  = {}
  for _, loc in ipairs(allLocations) do
    categoryMap[loc.id] = loc.categories or {}
  end
  return categoryMap
end

-- ---------------------------------------------------------------------------
-- ArrayContains(arr, value)
-- Returns true if the array contains the given value.
-- ---------------------------------------------------------------------------
local function ArrayContains(arr, value)
  if not arr or #arr == 0 then return true end  -- empty = allow all
  for _, v in ipairs(arr) do
    if v == value then return true end
  end
  return false
end

-- ---------------------------------------------------------------------------
-- GetQBCoreVehicles()
-- Returns QBCore.Shared.Vehicles and whether it has shop data.
-- Returns nil, false if QBCore is not the active framework.
-- ---------------------------------------------------------------------------
local function GetQBCoreVehicles()
  if Config.Framework ~= "QBCore" then
    return nil, false
  end
  local vehicles = QBCore and QBCore.Shared and QBCore.Shared.Vehicles
  if not vehicles then
    return nil, false
  end
  -- Detect whether any vehicle has a .shop field
  local hasShopData = false
  for _, veh in pairs(vehicles) do
    if veh.shop then
      hasShopData = true
      break
    end
  end
  return vehicles, hasShopData
end

-- ---------------------------------------------------------------------------
-- GetQBoxVehicles()
-- Returns QBox vehicles via exports and whether shop data is present.
-- Returns nil, false if QBox is not the active framework.
-- ---------------------------------------------------------------------------
local function GetQBoxVehicles()
  if Config.Framework ~= "Qbox" then
    return nil, false
  end
  local ok, vehicles = pcall(function()
    return exports.qbx_core:GetVehiclesByHash()
  end)
  if not ok or not vehicles then
    return nil, false
  end
  local hasShopData = false
  for _, veh in pairs(vehicles) do
    if veh.shop then
      hasShopData = true
      break
    end
  end
  return vehicles, hasShopData
end

-- ---------------------------------------------------------------------------
-- GetESXVehicles()
-- Returns vehicle rows from the ESX `vehicles` table.
-- Returns nil, false if ESX is not the active framework.
-- ---------------------------------------------------------------------------
local function GetESXVehicles()
  if Config.Framework ~= "ESX" then
    return nil, false
  end
  local rows = MySQL.query.await("SELECT * FROM vehicles ORDER BY name DESC")
  if not rows then
    return nil, false
  end
  return rows, false
end

-- ---------------------------------------------------------------------------
-- Import.Server.PreviewVehiclesData(source)
-- Returns metadata about what a given source would import, without writing.
-- ---------------------------------------------------------------------------
Import.Server.PreviewVehiclesData = function(source)
  local vehicles, hasShopData

  if source == "qbshared" then
    vehicles, hasShopData = GetQBCoreVehicles()
    if not vehicles then
      return { available = false, count = 0, hasShopData = false,
               error = "QBCore.Shared.Vehicles not available (wrong framework or not loaded)" }
    end
  elseif source == "qbx_shared" then
    vehicles, hasShopData = GetQBoxVehicles()
    if not vehicles then
      return { available = false, count = 0, hasShopData = false,
               error = "exports.qbx_core:GetVehiclesByHash() not available (wrong framework or not loaded)" }
    end
  elseif source == "esxdb" then
    vehicles, hasShopData = GetESXVehicles()
    if not vehicles then
      return { available = false, count = 0, hasShopData = false,
               error = "ESX vehicles table not found or empty" }
    end
  else
    return { available = false, count = 0, hasShopData = false, error = "Unknown import source" }
  end

  -- Count entries
  local count = 0
  for _ in pairs(vehicles) do count = count + 1 end

  return { available = true, count = count, hasShopData = hasShopData }
end

-- Callback: preview vehicle data (admin-gated)
lib.callback.register("jg-dealerships:server:preview-vehicles-data",
  function(source, requestedSource)
    if not Framework.Server.IsAdmin(source) then
      return { available = false, count = 0, hasShopData = false, error = "INSUFFICIENT_PERMISSIONS" }
    end
    return Import.Server.PreviewVehiclesData(requestedSource)
  end
)

-- ---------------------------------------------------------------------------
-- AddVehicleToDb(spawnCode, hashKey, brand, model, category, price,
--                shop, locationCategoryMap, stockMethod)
-- Inserts a single vehicle into dealership_vehicles and optionally seeds stock.
-- ---------------------------------------------------------------------------
local function AddVehicleToDb(spawnCode, hashKey, brand, model, category, price,
                               shop, locationCategoryMap, stockMethod)
  -- Insert the vehicle record (skip if spawn_code already exists)
  MySQL.query.await([[
    INSERT IGNORE INTO dealership_vehicles (spawn_code, hashkey, brand, model, category, price)
    VALUES(?, ?, ?, ?, ?, ?)
  ]], { spawnCode, hashKey, brand, model, category, price })

  -- Seed stock entries based on the chosen stock method
  local shopFilter = {}

  if stockMethod == "byShop" and shop then
    -- Build a set of shop names to seed for
    if type(shop) == "string" then
      shopFilter[shop] = true
    elseif type(shop) == "table" then
      for _, s in ipairs(shop) do
        shopFilter[s] = true
      end
    end

    -- Insert stock for each matching location
    for shopName in pairs(shopFilter) do
      if locationCategoryMap[shopName] then
        MySQL.query.await([[
          INSERT IGNORE INTO dealership_stock (vehicle, dealership, stock, price)
          VALUES(?, ?, ?, ?)
        ]], { spawnCode, shopName, 0, price })
      end
    end
  else
    -- "byCategory" – seed stock for every location whose categories include this vehicle's category
    for locId, categories in pairs(locationCategoryMap) do
      if ArrayContains(categories, category) then
        MySQL.query.await([[
          INSERT IGNORE INTO dealership_stock (vehicle, dealership, stock, price)
          VALUES(?, ?, ?, ?)
        ]], { spawnCode, locId, 0, price })
      end
    end
  end
end

-- ---------------------------------------------------------------------------
-- ImportQBCoreVehicles(behaviour, stockMethod)
-- Imports vehicles from QBCore.Shared.Vehicles into dealership_vehicles.
-- behaviour: "Overwrite" | "Append"
-- stockMethod: "byCategory" | "byShop"
-- ---------------------------------------------------------------------------
local function ImportQBCoreVehicles(behaviour, stockMethod)
  local vehicles = GetQBCoreVehicles()
  if not vehicles then
    return { success = false, count = 0, imported = 0,
             error = "QBCore.Shared.Vehicles not found" }
  end

  if behaviour == "Overwrite" then ClearAllVehicleData() end

  local existing = (behaviour == "Append") and GetExistingVehicleSpawnCodes() or {}
  local locationCategoryMap = GetLocationCategoryMap()
  local importedCount = 0

  for spawnCode, vehData in pairs(vehicles) do
    local trimmedCode = Trim(spawnCode)
    if behaviour == "Append" and existing[trimmedCode] then
      -- Skip already-present vehicles
    else
      AddVehicleToDb(
        trimmedCode,
        joaat(spawnCode),
        vehData.brand,
        vehData.name,
        vehData.category,
        vehData.price,
        vehData.shop,
        locationCategoryMap,
        stockMethod
      )
      importedCount = importedCount + 1
    end
  end

  Showroom.Server.ClearVehicleCache()
  local totalCount = MySQL.scalar.await("SELECT COUNT(*) FROM dealership_vehicles") or 0

  return { success = true, count = totalCount, imported = importedCount }
end

-- ---------------------------------------------------------------------------
-- ImportQBoxVehicles(behaviour, stockMethod)
-- Imports vehicles from exports.qbx_core:GetVehiclesByHash().
-- ---------------------------------------------------------------------------
local function ImportQBoxVehicles(behaviour, stockMethod)
  local vehicles = GetQBoxVehicles()
  if not vehicles then
    return { success = false, count = 0, imported = 0,
             error = "exports.qbx_core:GetVehiclesByHash() returned nil" }
  end

  if behaviour == "Overwrite" then ClearAllVehicleData() end

  local existing = (behaviour == "Append") and GetExistingVehicleSpawnCodes() or {}
  local locationCategoryMap = GetLocationCategoryMap()
  local importedCount = 0

  for hashKey, vehData in pairs(vehicles) do
    local trimmedCode = Trim(vehData.model)
    if behaviour == "Append" and existing[trimmedCode] then
      -- Skip duplicates
    else
      AddVehicleToDb(
        trimmedCode,
        hashKey,                -- QBox uses hash as the key
        vehData.brand,
        vehData.name,
        vehData.category,
        vehData.price,
        vehData.shop,
        locationCategoryMap,
        stockMethod
      )
      importedCount = importedCount + 1
    end
  end

  Showroom.Server.ClearVehicleCache()
  local totalCount = MySQL.scalar.await("SELECT COUNT(*) FROM dealership_vehicles") or 0

  return { success = true, count = totalCount, imported = importedCount }
end

-- ---------------------------------------------------------------------------
-- ImportESXVehicles(behaviour, stockMethod)
-- Imports vehicles from the ESX `vehicles` database table.
-- ---------------------------------------------------------------------------
local function ImportESXVehicles(behaviour, stockMethod)
  local vehicles = GetESXVehicles()
  if not vehicles then
    return { success = false, count = 0, imported = 0,
             error = "Could not query ESX vehicles table" }
  end

  if behaviour == "Overwrite" then ClearAllVehicleData() end

  local existing = (behaviour == "Append") and GetExistingVehicleSpawnCodes() or {}
  local locationCategoryMap = GetLocationCategoryMap()
  local importedCount = 0

  for _, vehData in pairs(vehicles) do
    local trimmedCode = Trim(vehData.model)
    if behaviour == "Append" and existing[trimmedCode] then
      -- Skip duplicates
    else
      AddVehicleToDb(
        trimmedCode,
        joaat(vehData.model),
        nil,                   -- ESX has no brand field
        vehData.name,
        vehData.category,
        vehData.price,
        nil,                   -- ESX has no shop field
        locationCategoryMap,
        stockMethod
      )
      importedCount = importedCount + 1
    end
  end

  Showroom.Server.ClearVehicleCache()
  local totalCount = MySQL.scalar.await("SELECT COUNT(*) FROM dealership_vehicles") or 0

  return { success = true, count = totalCount, imported = importedCount }
end

-- ---------------------------------------------------------------------------
-- Import.Server.ImportVehiclesData(source, behaviour, stockMethod)
-- Entry point that dispatches vehicle imports to the correct handler.
-- source: "qbshared" | "qbx_shared" | "esxdb"
-- behaviour: "Overwrite" | "Append"   (default "Append")
-- stockMethod: "byCategory" | "byShop" (default "byCategory")
-- ---------------------------------------------------------------------------
function Import.Server.ImportVehiclesData(source, behaviour, stockMethod)
  behaviour   = behaviour  or "Append"
  stockMethod = stockMethod or "byCategory"

  if source == "qbshared" then
    return ImportQBCoreVehicles(behaviour, stockMethod)
  elseif source == "qbx_shared" then
    return ImportQBoxVehicles(behaviour, stockMethod)
  elseif source == "esxdb" then
    return ImportESXVehicles(behaviour, stockMethod)
  end

  return { success = false, count = 0, imported = 0, error = "UNSUPPORTED_SOURCE" }
end

-- Callback: import vehicles (admin-gated)
lib.callback.register("jg-dealerships:server:import-vehicles-data",
  function(source, requestedSource, behaviour, stockMethod)
    if not Framework.Server.IsAdmin(source) then
      Framework.Server.Notify(source, Locale.insufficientPermissions, "error")
      DebugPrint("Player " .. source .. " tried to import vehicles without permission", "warning")
      return { success = false, count = 0, error = "INSUFFICIENT_PERMISSIONS" }
    end

    local result = Import.Server.ImportVehiclesData(requestedSource, behaviour, stockMethod)

    if result.success then
      local imported = result.imported or result.count
      Framework.Server.Notify(source,
        ("Import successful! %d vehicles imported (%d total)"):format(imported, result.count),
        "success"
      )

      local sourceLabels = {
        qbshared    = "QBCore Shared",
        qbx_shared  = "QBox Shared",
        esxdb       = "ESX Database",
      }
      SendWebhook(source, Webhooks.Admin, "Admin: Vehicles Imported", "success", {
        { key = "Method",           value = sourceLabels[requestedSource] or requestedSource },
        { key = "Behaviour",        value = behaviour },
        { key = "Stock Method",     value = stockMethod },
        { key = "Vehicles Imported", value = imported },
        { key = "Total Vehicles",   value = result.count },
      })
    else
      Framework.Server.Notify(source,
        string.gsub(Locale.importFailed, "%%{value}", result.error or "Unknown error"),
        "error"
      )
    end

    return result
  end
)