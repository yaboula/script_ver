



--- Calculate the value of a vehicle for selling
--- @param playerId number The player's server ID
--- @param dealershipId string The dealership ID
--- @param plate string The vehicle plate
--- @param model string The vehicle model/spawn code
--- @return number|boolean The calculated value or false if invalid
local function CalculateVehicleValue(playerId, dealershipId, plate, model)
    -- Get location data
    local location = Locations.Server.GetById(dealershipId)
    
    -- Check if location exists and allows selling vehicles
    if not location or not location.enable_sell_vehicle then
        return false
    end
    
    -- Get player identifier
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    
    -- Check if player owns the vehicle
    local vehicleData = MySQL.single.await(
        string.format([[
            SELECT * FROM %s WHERE plate = ? AND %s = ?
        ]], Framework.VehiclesTable, Framework.PlayerId),
        {plate, playerIdentifier}
    )
    
    if not vehicleData then
        DebugPrint("The vehicle " .. plate .. " is not owned by player: " .. playerIdentifier .. " (" .. playerId .. ")", "warning")
        Framework.Server.Notify(playerId, Locale.notYourVehicleError, "error")
        return false
    end
    
    -- Get vehicle model from database
    local dbModel = Framework.Server.GetModelColumn(vehicleData)
    
    -- Normalize model to lowercase if it's a string
    if type(dbModel) == "string" then
        dbModel = dbModel:lower()
    end
    model = model:lower()
    
    -- Verify model matches database (check both string and hash)
    if dbModel ~= model then
        if dbModel ~= joaat(model) then
            DebugPrint("[sell-vehicle]: model does not match db: " .. dbModel .. " doesn't match " .. model .. " or " .. joaat(model), "warning")
            Framework.Server.Notify(playerId, Locale.modelDoesNotMatchDb, "error")
            return false
        end
    end
    
    -- Check if vehicle is financed
    if vehicleData.financed then
        Framework.Server.Notify(playerId, Locale.vehicleFinancedError, "error")
        return false
    end
    
    -- Get vehicle stock data from dealership
    local stockData = MySQL.single.await([[
        SELECT *, stock.price as stock_price FROM dealership_stock stock
        INNER JOIN dealership_vehicles vehicle ON vehicle.spawn_code = stock.vehicle
        WHERE stock.dealership = ? AND vehicle.spawn_code = ?
    ]], {dealershipId, model})
    
    if not stockData then
        Framework.Server.Notify(playerId, Locale.dealershipDoesntSellVehicle, "error")
        return false
    end
    
    -- Calculate sell value (default 60% of stock price)
    local sellPercent = location.sell_vehicle_percent or 60
    local vehicleValue = Round(stockData.stock_price * (sellPercent / 100))
    
    return vehicleValue
end

-- Callback to get vehicle value (for displaying to player)
lib.callback.register("jg-dealerships:server:sell-vehicle-get-value", function(playerId, dealershipId, plate, model)
    local vehicleValue = CalculateVehicleValue(playerId, dealershipId, plate, model)
    
    if not vehicleValue then
        return false
    end
    
    -- Run pre-check hook if it exists
    local preCheckPassed = SellVehiclePreCheck(dealershipId, plate, model, vehicleValue)
    if not preCheckPassed then
        return false
    end
    
    return vehicleValue
end)

-- Callback to execute the vehicle sale
lib.callback.register("jg-dealerships:server:sell-vehicle", function(playerId, dealershipId, plate, model)
    local vehicleValue = CalculateVehicleValue(playerId, dealershipId, plate, model)
    
    if not vehicleValue then
        return false
    end
    
    -- Get location data
    local location = Locations.Server.GetById(dealershipId)
    if not location then
        return false
    end
    
    -- Handle owned dealership balance
    if location.type == "owned" then
        -- Check if dealership has enough funds
        if not DealershipBalance.Server.HasFunds(dealershipId, vehicleValue) then
            Framework.Server.Notify(playerId, Locale.dealershipDoesntSellVehicle, "error")
            return false
        end
        
        -- Remove funds from dealership balance
        DealershipBalance.Server.Remove(dealershipId, vehicleValue)
        
        -- Add vehicle back to dealership stock
        MySQL.update.await(
            "UPDATE dealership_stock SET stock = stock + 1 WHERE dealership = ? AND vehicle = ?",
            {dealershipId, model}
        )
        
        -- Update showroom cache
        Showroom.Server.UpdateVehicleCache(model, dealershipId)
    end
    
    -- Delete vehicle from player's owned vehicles
    MySQL.query.await(
        string.format("DELETE FROM %s WHERE plate = ?", Framework.VehiclesTable),
        {plate}
    )
    
    -- Give money to player
    Framework.Server.PlayerAddMoney(playerId, vehicleValue, "bank")
    
    return true
end)
