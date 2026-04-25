



Showroom = Showroom or {}
Showroom.Server = Showroom.Server or {}

-- Cache for showroom vehicles by dealership
local vehicleCache = {}

-- Storage for active showroom sessions
local activeSessions = {}

--- Clear the entire vehicle cache
function Showroom.Server.ClearVehicleCache()
    vehicleCache = {}
end

--- Get all vehicles available in a dealership's showroom
--- @param dealershipId string The dealership ID
--- @param forceRefresh boolean Optional - Force refresh from database
--- @return table Array of vehicle data
function Showroom.Server.GetVehicles(dealershipId, forceRefresh)
    -- Return cached data if available and not forcing refresh
    if vehicleCache[dealershipId] and not forceRefresh then
        return TableValues(vehicleCache[dealershipId])
    end
    
    -- Get location data
    local location = Locations.Server.GetById(dealershipId)
    if not location then
        return false
    end
    
    -- Check if location has categories configured
    if not location.categories or #location.categories == 0 then
        vehicleCache[dealershipId] = {}
        return {}
    end
    
    -- Query vehicles from database
    local vehicles = MySQL.query.await([[
        SELECT vehicle.*, stock.stock as stock, stock.price as price FROM dealership_vehicles vehicle
        INNER JOIN dealership_stock stock ON vehicle.spawn_code = stock.vehicle
        INNER JOIN dealership_locations dealership ON stock.dealership = dealership.id
        WHERE vehicle.category IN (?) AND (dealership.id = ?)
        ORDER BY vehicle.spawn_code ASC
    ]], {location.categories, dealershipId})
    
    -- Cache vehicles by spawn code
    vehicleCache[dealershipId] = {}
    for _, vehicle in ipairs(vehicles) do
        vehicleCache[dealershipId][vehicle.spawn_code] = vehicle
    end
    
    return TableValues(vehicleCache[dealershipId])
end

--- Get a specific vehicle from a dealership's showroom
--- @param dealershipId string The dealership ID
--- @param vehicleModel string The vehicle model/spawn code
--- @param forceRefresh boolean Optional - Force refresh from database
--- @return table|boolean Vehicle data or false if not found
function Showroom.Server.GetVehicle(dealershipId, vehicleModel, forceRefresh)
    if not vehicleModel or not dealershipId then
        return false
    end
    
    -- Return cached data if available and not forcing refresh
    if vehicleCache[dealershipId] and vehicleCache[dealershipId][vehicleModel] and not forceRefresh then
        return vehicleCache[dealershipId][vehicleModel]
    end
    
    -- Get location data
    local location = Locations.Server.GetById(dealershipId)
    if not location then
        return false
    end
    
    -- Check if location has categories configured
    if not location.categories or #location.categories == 0 then
        return false
    end
    
    -- Query specific vehicle from database
    local vehicle = MySQL.single.await([[
        SELECT vehicle.*, stock.stock as stock, stock.price as price FROM dealership_vehicles vehicle
        INNER JOIN dealership_stock stock ON vehicle.spawn_code = stock.vehicle
        INNER JOIN dealership_locations dealership ON stock.dealership = dealership.id
        WHERE vehicle.spawn_code = ? AND dealership.id = ?
        ORDER BY vehicle.spawn_code ASC
    ]], {vehicleModel, dealershipId})
    
    -- Update cache
    if vehicleCache[dealershipId] then
        vehicleCache[dealershipId][vehicleModel] = vehicle or nil
    end
    
    return vehicle or false
end

--- Update vehicle cache for a dealership
--- @param vehicleModel string The vehicle model to update (or nil to update all)
--- @param dealershipId string The dealership ID
function Showroom.Server.UpdateVehicleCache(vehicleModel, dealershipId)
    if not dealershipId then
        -- Update all dealerships
        for dealerId, _ in pairs(vehicleCache) do
            Showroom.Server.GetVehicle(dealerId, vehicleModel, true)
        end
    else
        -- Update specific dealership
        Showroom.Server.GetVehicle(dealershipId, vehicleModel, true)
    end
end

--- Enter showroom (server-side logic)
--- @param playerId number The player's server ID
--- @param dealershipId string The dealership ID
--- @param originalCoords vector3 The player's original coordinates
--- @return table|boolean Showroom data or false if access denied
local function EnterShowroom(playerId, dealershipId, originalCoords)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    
    if not playerIdentifier then
        DebugPrint("jg-dealerships:server:enter-showroom: no identifier found for player " .. playerId, "warning")
        return false
    end
    
    -- Get location data
    local location = Locations.Server.GetById(dealershipId)
    if not location then
        return false
    end
    
    -- Get player job and gang
    local playerJob = Framework.Server.GetPlayerJob(playerId)
    local playerGang = Framework.Server.GetPlayerGang(playerId)
    
    -- Check showroom access whitelists
    local hasJobWhitelist = location.showroom_job_whitelist and next(location.showroom_job_whitelist)
    local hasGangWhitelist = location.showroom_gang_whitelist and next(location.showroom_gang_whitelist)
    
    if hasJobWhitelist or hasGangWhitelist then
        -- Check job whitelist
        local jobAllowed = false
        if hasJobWhitelist then
            jobAllowed = CheckJobGangWhitelist(location.showroom_job_whitelist, playerJob.name, playerJob.grade)
        end
        
        -- Check gang whitelist
        local gangAllowed = false
        if hasGangWhitelist then
            gangAllowed = CheckJobGangWhitelist(location.showroom_gang_whitelist, playerGang.name, playerGang.grade)
        end
        
        -- Deny access if neither job nor gang is allowed
        if not jobAllowed and not gangAllowed then
            DebugPrint("jg-dealerships:server:enter-showroom: player " .. playerId .. " not allowed in showroom", "debug")
            return false
        end
    end
    
    -- Build society purchase options
    local societies = {}
    
    local hasSocietyJobWhitelist = location.society_purchase_job_whitelist and next(location.society_purchase_job_whitelist)
    local hasSocietyGangWhitelist = location.society_purchase_gang_whitelist and next(location.society_purchase_gang_whitelist)
    
    -- Add job society if player is whitelisted
    if hasSocietyJobWhitelist and playerJob.name then
        if CheckJobGangWhitelist(location.society_purchase_job_whitelist, playerJob.name, playerJob.grade) then
            table.insert(societies, {
                name = playerJob.name,
                label = playerJob.label or playerJob.name,
                type = "job",
                balance = Framework.Server.GetSocietyBalance(playerJob.name, "job")
            })
        end
    end
    
    -- Add gang society if player is whitelisted
    if hasSocietyGangWhitelist and playerGang.name then
        if CheckJobGangWhitelist(location.society_purchase_gang_whitelist, playerGang.name, playerGang.grade) then
            table.insert(societies, {
                name = playerGang.name,
                label = playerGang.label or playerGang.name,
                type = "gang",
                balance = Framework.Server.GetSocietyBalance(playerGang.name, "gang")
            })
        end
    end
    
    -- Store original routing bucket for return
    local originalBucket = 0
    if Config.ReturnToPreviousRoutingBucket then
        originalBucket = GetPlayerRoutingBucket(playerId)
    end
    
    -- Store session data
    activeSessions[playerIdentifier] = {
        dealership = dealershipId,
        originalBucket = originalBucket,
        originalCoords = originalCoords
    }
    
    -- Freeze player and clear tasks
    local playerPed = GetPlayerPed(playerId)
    ClearPedTasksImmediately(playerPed)
    FreezeEntityPosition(playerPed, true)
    
    -- Check financed vehicle limit
    local financedCount = MySQL.scalar.await(
        string.format([[
            SELECT COUNT(*) as total FROM %s
            WHERE financed = 1 AND %s = ?
        ]], Framework.VehiclesTable, Framework.PlayerId),
        {playerIdentifier}
    )
    
    local maxFinanced = Config.MaxFinancedVehiclesPerPlayer or 999999
    local financeAllowed = financedCount < maxFinanced
    
    -- Return showroom data
    return {
        vehicles = Showroom.Server.GetVehicles(dealershipId),
        financeAllowed = financeAllowed,
        locationData = location,
        societies = societies
    }
end

--- Callback: Enter showroom
lib.callback.register("jg-dealerships:server:enter-showroom", EnterShowroom)

--- Callback: Check showroom whitelist access
lib.callback.register("jg-dealerships:server:check-showroom-whitelist", function(playerId, dealershipId)
    local location = Locations.Server.GetById(dealershipId)
    
    if not location then
        DebugPrint("[ShowroomWhitelist] Location not found: " .. tostring(dealershipId) .. " - returning true", "debug")
        return true
    end
    
    -- Get player job and gang
    local playerJob = Framework.Server.GetPlayerJob(playerId)
    local playerGang = Framework.Server.GetPlayerGang(playerId)
    
    -- Check if whitelists exist
    local hasJobWhitelist = location.showroom_job_whitelist and next(location.showroom_job_whitelist)
    local hasGangWhitelist = location.showroom_gang_whitelist and next(location.showroom_gang_whitelist)
    
    -- Debug logging
    DebugPrint("[ShowroomWhitelist] Checking access for player " .. playerId .. " at " .. dealershipId, "debug")
    DebugPrint("[ShowroomWhitelist] Player job: " .. tostring(playerJob.name) .. " grade: " .. tostring(playerJob.grade), "debug")
    DebugPrint("[ShowroomWhitelist] Player gang: " .. tostring(playerGang.name) .. " grade: " .. tostring(playerGang.grade), "debug")
    DebugPrint("[ShowroomWhitelist] Job whitelist: " .. json.encode(location.showroom_job_whitelist or {}), "debug")
    DebugPrint("[ShowroomWhitelist] Gang whitelist: " .. json.encode(location.showroom_gang_whitelist or {}), "debug")
    DebugPrint("[ShowroomWhitelist] Has job whitelist: " .. tostring(hasJobWhitelist) .. ", Has gang whitelist: " .. tostring(hasGangWhitelist), "debug")
    
    -- If no whitelists are set, allow access
    if not hasJobWhitelist and not hasGangWhitelist then
        DebugPrint("[ShowroomWhitelist] No whitelists set - allowing access", "debug")
        return true
    end
    
    -- Check job whitelist
    local jobAllowed = false
    if hasJobWhitelist then
        jobAllowed = CheckJobGangWhitelist(location.showroom_job_whitelist, playerJob.name, playerJob.grade)
    end
    
    -- Check gang whitelist
    local gangAllowed = false
    if hasGangWhitelist then
        gangAllowed = CheckJobGangWhitelist(location.showroom_gang_whitelist, playerGang.name, playerGang.grade)
    end
    
    DebugPrint("[ShowroomWhitelist] Job allowed: " .. tostring(jobAllowed) .. ", Gang allowed: " .. tostring(gangAllowed), "debug")
    DebugPrint("[ShowroomWhitelist] Final result: " .. tostring(jobAllowed or gangAllowed), "debug")
    
    return jobAllowed or gangAllowed
end)

--- Callback: Exit showroom
lib.callback.register("jg-dealerships:server:exit-showroom", function(playerId, data)
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    
    if not playerIdentifier then
        DebugPrint("jg-dealerships:server:exit-showroom: no identifier found for player " .. playerId, "warning")
        return false
    end
    
    -- Unfreeze player and clear tasks
    local playerPed = GetPlayerPed(playerId)
    FreezeEntityPosition(playerPed, false)
    ClearPedTasksImmediately(playerPed)
    
    -- Remove session data
    activeSessions[playerIdentifier] = nil
    
    return true
end)
