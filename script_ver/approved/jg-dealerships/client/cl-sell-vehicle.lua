



SellVehicle = SellVehicle or {}
SellVehicle.Client = SellVehicle.Client or {}

--- Request to sell a vehicle to a dealership
--- @param dealershipId string The ID of the dealership
--- @return boolean Success status
function SellVehicle.Client.Request(dealershipId)
    local vehicle = cache.vehicle
    
    -- Check if player is in a vehicle
    if not vehicle then
        Framework.Client.Notify(Locale.notInVehicle, "error")
        return false
    end
    
    -- Get vehicle plate
    local plate = Framework.Client.GetPlate(vehicle)
    if not plate then
        return false
    end
    
    -- Get vehicle model
    local model = GetEntityArchetypeName(vehicle)
    
    DebugPrint("Trying to sell vehicle with plate: " .. plate .. " and model: " .. model, "debug")
    
    -- Request vehicle value from server
    local vehicleValue = lib.callback.await("jg-dealerships:server:sell-vehicle-get-value", false, dealershipId, plate, model)
    
    if not vehicleValue then
        return false
    end
    
    -- Open NUI to show sell offer
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "sell-vehicle-to-dealer",
        dealershipId = dealershipId,
        plate = plate,
        value = vehicleValue,
        config = Config,
        locale = Locale
    })
    
    return true
end

--- Execute the vehicle sale (called when player accepts the offer)
--- @param dealershipId string The ID of the dealership
--- @return boolean Success status
local function ExecuteVehicleSale(dealershipId)
    local vehicle = cache.vehicle
    
    if not vehicle then
        return false
    end
    
    local plate = Framework.Client.GetPlate(vehicle)
    if not plate then
        return false
    end
    
    local model = GetEntityArchetypeName(vehicle)
    
    -- Call server to process the sale
    local success = lib.callback.await("jg-dealerships:server:sell-vehicle", 2500, dealershipId, plate, model)
    
    if not success then
        return false
    end
    
    -- Fade screen out
    DoScreenFadeOut(500)
    Wait(500)
    
    -- Make all passengers exit the vehicle
    for seatIndex = -1, 5 do
        local ped = GetPedInVehicleSeat(vehicle, seatIndex)
        if ped then
            TaskLeaveVehicle(ped, vehicle, 0)
        end
    end
    
    -- Remove vehicle keys
    Framework.Client.VehicleRemoveKeys(plate, vehicle, "vehicleSale")
    
    -- Lock the vehicle
    SetVehicleDoorsLocked(vehicle, 2)
    
    Wait(1500)
    
    -- Trigger config event (likely for vehicle removal/cleanup)
    TriggerEvent("jg-dealerships:client:sell-vehicle:config", vehicle, plate)
    
    -- Fade screen back in
    DoScreenFadeIn(500)
    
    return true
end

-- NUI Callback when player accepts the sell price
RegisterNUICallback("sell-vehicle-price-accepted", function(data, cb)
    cb(ExecuteVehicleSale(data))
end)

-- Network event to trigger vehicle sell request
RegisterNetEvent("jg-dealerships:client:sell-vehicle", function(dealershipId)
    SellVehicle.Client.Request(dealershipId)
end)
