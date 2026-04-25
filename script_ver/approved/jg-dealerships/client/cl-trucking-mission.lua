



-- Initialize TruckingMission global
if not TruckingMission then
    TruckingMission = {}
end

if not TruckingMission.Client then
    TruckingMission.Client = {}
end

-- Local state variables
local missionActive = false
local truckEntity = nil
local trailerEntity = nil
local cargoEntity = nil
local cargoVehicles = {}
local pickupBlip = nil
local dropoffBlip = nil
local isSpawningVehicles = false
local spawnOnClient = false
local missionData = nil
local currentStage = nil
local pickupLocation = nil
local dropoffLocation = nil
local truckNetId = nil
local trailerNetId = nil

-- Clean up truck
local function CleanupTruck()
    if truckEntity and DoesEntityExist(truckEntity) then
        local plate = GetVehicleNumberPlateText(truckEntity)
        if plate then
            Framework.Client.VehicleRemoveKeys(plate, truckEntity, "truckingMission")
        end
        DeleteEntity(truckEntity)
    end
    truckEntity = nil
end

-- Clean up cargo vehicles
local function CleanupCargoVehicles()
    for _, vehicle in pairs(cargoVehicles) do
        if DoesEntityExist(vehicle) then
            DetachEntity(vehicle, false, false)
            DeleteEntity(vehicle)
        end
    end
    cargoVehicles = {}
    
    if cargoEntity and DoesEntityExist(cargoEntity) then
        DeleteEntity(cargoEntity)
    end
    cargoEntity = nil
end

-- Clean up blips
local function CleanupBlips()
    if pickupBlip and DoesBlipExist(pickupBlip) then
        RemoveBlip(pickupBlip)
        pickupBlip = nil
    end
    
    if dropoffBlip and DoesBlipExist(dropoffBlip) then
        RemoveBlip(dropoffBlip)
        dropoffBlip = nil
    end
end

-- Check if entity is mission vehicle
local function IsMissionVehicle(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return false
    end
    
    if isSpawningVehicles then
        if entity == cargoEntity then
            return true
        end
    end
    
    if pickupLocation then
        for _, vehicle in pairs(cargoVehicles) do
            if entity == vehicle then
                return true
            end
        end
    end
    
    return false
end

-- Start mission
function TruckingMission.Client.Start(dealershipId, trailerType, orderIds, quantities, configHash)
    if missionActive then
        return false, "Mission already active"
    end
    
    local result = lib.callback.await(
        "jg-dealerships:server:start-trucking-mission",
        false,
        dealershipId,
        trailerType,
        orderIds,
        quantities,
        configHash
    )
    
    if not result or not result.success then
        return false, result.error or "Failed to start mission"
    end
    
    missionData = result.data
    missionActive = true
    currentStage = "spawned"
    
    -- Set pickup and dropoff locations
    if missionData.pickupStop then
        pickupLocation = missionData.pickupStop.location
    end
    
    if missionData.dropoffCoords then
        dropoffLocation = missionData.dropoffCoords
    end
    
    -- Create pickup blip using config
    if pickupLocation and pickupLocation.coords then
        local blipConfig = TruckingConfig.Blips.pickup
        pickupBlip = AddBlipForCoord(pickupLocation.coords.x, pickupLocation.coords.y, pickupLocation.coords.z)
        SetBlipSprite(pickupBlip, blipConfig.sprite)
        SetBlipColour(pickupBlip, blipConfig.color)
        SetBlipScale(pickupBlip, blipConfig.scale)
        SetBlipRoute(pickupBlip, false) -- Don't show route until player gets in truck
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(blipConfig.label)
        EndTextCommandSetBlipName(pickupBlip)
    end
    
    -- Spawn the truck at the dealership delivery point
    if missionData.dropoffCoords then
        CreateThread(function()
            local spawnCoords = missionData.dropoffCoords
            local truckModel = GetHashKey(TruckingConfig.TruckModel or "hauler")
            
            -- Request models
            lib.requestModel(truckModel, 10000)
            
            -- Spawn truck
            local truck = CreateVehicle(truckModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w or 0.0, true, false)
            SetVehicleOnGroundProperly(truck)
            SetEntityAsMissionEntity(truck, true, true)
            SetVehicleHasBeenOwnedByPlayer(truck, true)
            
            -- Give keys
            local plate = GetVehicleNumberPlateText(truck)
            Framework.Client.VehicleGiveKeys(plate, truck, "truckingMission")
            
            -- Set truck entity
            truckEntity = truck
            truckNetId = NetworkGetNetworkIdFromEntity(truck)
            
            -- Notify server of truck entity
            lib.callback.await("jg-dealerships:server:set-truck-entity", false, truckNetId)
            
            -- Set models as no longer needed
            SetModelAsNoLongerNeeded(truckModel)
            
            -- Create blip for truck spawn location using config
            if not dropoffBlip then
                local blipConfig = TruckingConfig.Blips.spawn
                dropoffBlip = AddBlipForCoord(spawnCoords.x, spawnCoords.y, spawnCoords.z)
                SetBlipSprite(dropoffBlip, blipConfig.sprite)
                SetBlipColour(dropoffBlip, blipConfig.color)
                SetBlipScale(dropoffBlip, blipConfig.scale)
                SetBlipRoute(dropoffBlip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentSubstringPlayerName(blipConfig.label)
                EndTextCommandSetBlipName(dropoffBlip)
            end
            
            -- Draw marker at truck spawn location
            CreateThread(function()
                while missionActive and currentStage == "spawned" and DoesEntityExist(truck) do
                    Wait(0)
                    local truckCoords = GetEntityCoords(truck)
                    local markerConfig = TruckingConfig.Markers.spawn
                    
                    DrawMarker(
                        markerConfig.type,
                        truckCoords.x, truckCoords.y, truckCoords.z + 2.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        markerConfig.size, markerConfig.size, markerConfig.size,
                        markerConfig.color.r, markerConfig.color.g, markerConfig.color.b, markerConfig.color.a,
                        markerConfig.bobUpAndDown,
                        markerConfig.faceCamera,
                        2,
                        markerConfig.rotate,
                        nil,
                        nil,
                        false
                    )
                end
            end)
            
            -- Show instructional UI
            Interactions.Client.InstrPrmt.Show(
                "Get in the truck at the marked location to start your delivery",
                {
                    {key = "E", desc = "Dismiss"}
                },
                ""
            )
            
            -- Wait for player to enter truck or dismiss
            CreateThread(function()
                while missionActive and currentStage == "spawned" do
                    Wait(100)
                    
                    local ped = PlayerPedId()
                    local vehicle = GetVehiclePedIsIn(ped, false)
                    
                    -- Check if player pressed E to dismiss
                    if IsControlJustPressed(0, 38) then -- E key
                        Interactions.Client.InstrPrmt.Hide()
                        -- Don't break - allow player to still enter truck
                    end
                    
                    -- Check if player is in the truck (driver seat)
                    if vehicle and vehicle == truck and GetPedInVehicleSeat(truck, -1) == ped then
                        Interactions.Client.InstrPrmt.Hide()
                        
                        -- Update stage first to stop marker thread
                        currentStage = "driving_to_pickup"
                        
                        Wait(100) -- Small delay to ensure marker thread stops
                        
                        -- Remove truck blip
                        if dropoffBlip and DoesBlipExist(dropoffBlip) then
                            RemoveBlip(dropoffBlip)
                            dropoffBlip = nil
                        end
                        
                        -- Show pickup location message
                        Framework.Client.Notify("Drive to the pickup location to collect the trailer", "info")
                        
                        -- Show new instructional prompt for driving to pickup
                        Interactions.Client.InstrPrmt.Show(
                            "Drive to the pickup location to collect the trailer",
                            {
                                {key = "E", desc = "Dismiss"}
                            },
                            ""
                        )
                        
                        -- Ensure pickup blip is set and has route
                        if pickupBlip and DoesBlipExist(pickupBlip) then
                            SetBlipRoute(pickupBlip, true)
                            SetBlipRouteColour(pickupBlip, 5)
                        end
                        
                        -- Start checking for pickup location arrival
                        TruckingMission.Client.StartPickupCheck()
                        
                        break
                    end
                end
            end)
        end)
    end
    
    return true, "Mission started successfully"
end

-- Complete mission
function TruckingMission.Client.Complete()
    if not missionActive then
        return false
    end
    
    local result = lib.callback.await("jg-dealerships:server:complete-trucking-mission", false, trailerNetId)
    
    CleanupTruck()
    CleanupCargoVehicles()
    CleanupBlips()
    
    missionActive = false
    missionData = nil
    currentStage = nil
    pickupLocation = nil
    dropoffLocation = nil
    
    return result or false
end

-- Cancel mission
function TruckingMission.Client.Cancel()
    if not missionActive then
        return false
    end
    
    lib.callback.await("jg-dealerships:server:cancel-trucking-mission", false)
    
    CleanupTruck()
    CleanupCargoVehicles()
    CleanupBlips()
    
    missionActive = false
    missionData = nil
    currentStage = nil
    pickupLocation = nil
    dropoffLocation = nil
    
    return true
end

-- Get mission status
function TruckingMission.Client.GetStatus()
    return {
        active = missionActive,
        stage = currentStage,
        data = missionData
    }
end

-- Set truck entity
function TruckingMission.Client.SetTruck(networkId)
    if not networkId then
        return false
    end
    
    local entity = NetworkGetEntityFromNetworkId(networkId)
    if entity and entity ~= 0 then
        truckEntity = entity
        truckNetId = networkId
        return true
    end
    
    return false
end

-- Set trailer entity
function TruckingMission.Client.SetTrailer(networkId)
    if not networkId then
        return false
    end
    
    local entity = NetworkGetEntityFromNetworkId(networkId)
    if entity and entity ~= 0 then
        trailerEntity = entity
        trailerNetId = networkId
        return true
    end
    
    return false
end

-- Start checking for pickup location arrival
function TruckingMission.Client.StartPickupCheck()
    if not pickupLocation or not pickupLocation.coords then
        return
    end
    
    local trailerSpawned = false
    local dismissKeyPressed = false
    
    -- Thread to handle E key dismissal
    CreateThread(function()
        while missionActive and currentStage == "driving_to_pickup" do
            Wait(0)
            if IsControlJustPressed(0, 38) then -- E key
                Interactions.Client.InstrPrmt.Hide()
                dismissKeyPressed = true
                break
            end
        end
    end)
    
    CreateThread(function()
        while missionActive and currentStage == "driving_to_pickup" do
            Wait(1000)
            
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle == truckEntity then
                local truckCoords = GetEntityCoords(truckEntity)
                local pickupCoords = pickupLocation.coords
                local distance = #(truckCoords - vector3(pickupCoords.x, pickupCoords.y, pickupCoords.z))
                
                -- Spawn trailer when player is 200m away (earlier than before)
                if distance < 200.0 and not trailerSpawned then
                    trailerSpawned = true
                    currentStage = "at_pickup"
                    
                    -- Hide previous instructional prompt
                    Interactions.Client.InstrPrmt.Hide()
                    
                    
                    CreateThread(function()
                        local trailerModel = GetHashKey(missionData.trailerType == "small" and TruckingConfig.TrailerSmallVehicle or TruckingConfig.TrailerLargeVehicle)
                        
                        -- Request trailer model
                        lib.requestModel(trailerModel, 10000)
                        
                        -- Spawn trailer near pickup location with proper ground detection
                        -- First, get ground Z coordinate
                        local groundZ = pickupCoords.z
                        local foundGround, zCoord = GetGroundZFor_3dCoord(pickupCoords.x, pickupCoords.y, pickupCoords.z + 100.0, false)
                        if foundGround then
                            groundZ = zCoord
                        end
                        
                        -- Spawn trailer with proper Z offset to prevent underground spawning
                        local trailer = CreateVehicle(trailerModel, pickupCoords.x, pickupCoords.y, groundZ + 1.0, pickupCoords.w or 0.0, true, false)
                        Wait(100) -- Small delay to ensure entity exists
                        SetVehicleOnGroundProperly(trailer)
                        SetEntityAsMissionEntity(trailer, true, true)
                        
                        trailerEntity = trailer
                        trailerNetId = NetworkGetNetworkIdFromEntity(trailer)
                        
                        -- Notify server of trailer entity
                        lib.callback.await("jg-dealerships:server:set-cargo-entity", false, trailerNetId)
                        
                        SetModelAsNoLongerNeeded(trailerModel)
                        
                        -- Spawn vehicles on the trailer based on missionData.orders
                        if missionData.pickupStop and missionData.pickupStop.vehicles then
                            isSpawningVehicles = true
                            cargoVehicles = {}
                            
                            -- Debug: Print vehicle count and details
                            print("^2[Trucking Mission] Spawning " .. #missionData.pickupStop.vehicles .. " vehicles on trailer^0")
                            for idx, veh in ipairs(missionData.pickupStop.vehicles) do
                                print("^3[Trucking Mission] Vehicle " .. idx .. ": " .. veh.model .. " (Order ID: " .. veh.orderId .. ")^0")
                            end
                            
                            -- Get trailer dimensions and forward vector
                            local trailerCoords = GetEntityCoords(trailer)
                            local trailerHeading = GetEntityHeading(trailer)
                            local trailerForward = GetEntityForwardVector(trailer)
                            
                            
                            -- Upper deck: 2 vehicles, Lower deck: 2 vehicles
                            local tr2Positions = {
                                -- Lower deck positions (front to back) - raised by 0.3 units
                                {x = 0.0, y = 4.2, z = 0.7},   -- Lower front
                                {x = 0.0, y = -3.8, z = 0.9},  -- Lower rear
                                -- Upper deck positions (front to back) - raised by 0.3 units
                                {x = 0.0, y = 4.2, z = 2.8},   -- Upper front
                                {x = 0.0, y = -3.6, z = 3.0},  -- Upper rear
                            }
                            
                            for i, vehicleData in ipairs(missionData.pickupStop.vehicles) do
                                if i > 4 then
                                    print("^1[Trucking Mission] Warning: TR2 trailer can only hold 4 vehicles, skipping vehicle " .. i .. "^0")
                                    break
                                end
                                
                                local vehicleModel = GetHashKey(vehicleData.model)
                                
                                -- Request vehicle model
                                lib.requestModel(vehicleModel, 10000)
                                
                                -- Get position for this vehicle slot
                                local position = tr2Positions[i]
                                
                                -- Spawn vehicle at trailer location first
                                local vehicle = CreateVehicle(vehicleModel, trailerCoords.x, trailerCoords.y, trailerCoords.z + 2.0, trailerHeading, true, false)
                                Wait(50) -- Wait for entity to fully spawn
                                
                                SetEntityAsMissionEntity(vehicle, true, true)
                                SetVehicleEngineOn(vehicle, false, true, true)
                                SetVehicleDoorsLocked(vehicle, 2) -- Lock doors
                                
                                -- Attach vehicle to trailer using TR2-specific position
                                AttachEntityToEntity(
                                    vehicle,      -- entity to attach
                                    trailer,      -- entity to attach to
                                    0,            -- bone index
                                    position.x,   -- x offset (left/right - 0 is center)
                                    position.y,   -- y offset (forward/back)
                                    position.z,   -- z offset (height - deck level)
                                    0.0,          -- x rotation
                                    0.0,          -- y rotation
                                    0.0,          -- z rotation
                                    false,        -- physics disabled
                                    false,        -- collision disabled
                                    true,         -- fixed rotation
                                    false,        -- no collision check
                                    2,            -- rotation order
                                    true          -- fix position
                                )
                                
                                -- Make vehicle stable on trailer
                                SetEntityInvincible(vehicle, true)
                                SetVehicleUndriveable(vehicle, true)
                                FreezeEntityPosition(vehicle, false) -- Let attachment handle position
                                
                                print("^2[Trucking Mission] Attached vehicle " .. i .. " (" .. vehicleData.model .. ") at position: x=" .. position.x .. ", y=" .. position.y .. ", z=" .. position.z .. "^0")
                                
                                table.insert(cargoVehicles, vehicle)
                                SetModelAsNoLongerNeeded(vehicleModel)
                            end
                            
                            isSpawningVehicles = false
                        end
                        
                        
                        -- Show instructional prompt for attaching trailer
                        Interactions.Client.InstrPrmt.Show(
                            "Drive under the trailer to attach it",
                            {
                                {key = "E", desc = "Dismiss"}
                            },
                            ""
                        )
                        
                        -- Update stage to waiting for trailer attachment
                        currentStage = "attaching_trailer"
                        
                        -- Start checking for trailer attachment
                        TruckingMission.Client.StartTrailerAttachCheck()
                    end)
                    
                    break
                end
                
                -- Draw pickup marker when close
                if distance < 50.0 then
                    local markerConfig = TruckingConfig.Markers.pickup
                    DrawMarker(
                        markerConfig.type,
                        pickupCoords.x, pickupCoords.y, pickupCoords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        markerConfig.size, markerConfig.size, markerConfig.size,
                        markerConfig.color.r, markerConfig.color.g, markerConfig.color.b, markerConfig.color.a,
                        markerConfig.bobUpAndDown,
                        markerConfig.faceCamera,
                        2,
                        markerConfig.rotate,
                        nil,
                        nil,
                        false
                    )
                end
            end
        end
    end)
end

-- Start checking for trailer attachment
function TruckingMission.Client.StartTrailerAttachCheck()
    if not trailerEntity then
        return
    end
    
    local attachPromptShown = true
    local dismissKeyPressed = false
    
    -- Thread to handle E key dismissal
    CreateThread(function()
        while missionActive and currentStage == "attaching_trailer" do
            Wait(0)
            if IsControlJustPressed(0, 38) then -- E key
                Interactions.Client.InstrPrmt.Hide()
                dismissKeyPressed = true
                attachPromptShown = false
                break
            end
        end
    end)
    
    CreateThread(function()
        while missionActive and currentStage == "attaching_trailer" do
            Wait(500)
            
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle == truckEntity then
                -- Check if trailer is attached using IsVehicleAttachedToTrailer
                local isAttached = IsVehicleAttachedToTrailer(truckEntity)
                
                print("^3[Trucking Mission Debug] Checking attachment... IsAttached: " .. tostring(isAttached) .. " | Truck: " .. tostring(truckEntity) .. " | Trailer: " .. tostring(trailerEntity) .. "^0")
                
                if isAttached then
                    -- Trailer is attached!
                    print("^2[Trucking Mission] TRAILER ATTACHED! Transitioning to dropoff stage...^0")
                    
                    Interactions.Client.InstrPrmt.Hide()
                    
                    -- Update stage immediately to stop other threads
                    currentStage = "driving_to_dropoff"
                    
                    -- Remove pickup blip now that trailer is attached
                    if pickupBlip and DoesBlipExist(pickupBlip) then
                        print("^2[Trucking Mission] Removing pickup blip^0")
                        RemoveBlip(pickupBlip)
                        pickupBlip = nil
                    else
                        print("^1[Trucking Mission] Pickup blip already removed or doesn't exist^0")
                    end
                    
                    -- Small delay to ensure old prompt is cleared before showing new one
                    Wait(100)
                    
                    -- Show instructional prompt for driving to dropoff
                    Interactions.Client.InstrPrmt.Show(
                        "Drive to the delivery location",
                        {
                            {key = "E", desc = "Dismiss"}
                        },
                        ""
                    )
                    
                    print("^2[Trucking Mission] Calling SetStage with dropoff location: " .. tostring(dropoffLocation) .. "^0")
                    if dropoffLocation then
                        print("^2[Trucking Mission] Dropoff coords: " .. dropoffLocation.x .. ", " .. dropoffLocation.y .. ", " .. dropoffLocation.z .. "^0")
                    end
                    
                    -- Update blips and start dropoff check
                    TruckingMission.Client.SetStage("driving_to_dropoff")
                    
                    -- Start checking for dropoff arrival
                    TruckingMission.Client.StartDropoffCheck()
                    
                    break
                end
            end
        end
    end)
end

-- Start checking for dropoff location arrival
function TruckingMission.Client.StartDropoffCheck()
    if not dropoffLocation then
        return
    end
    
    local dismissKeyPressed = false
    local atDropoffPromptShown = false
    
    -- Thread to handle E key dismissal during driving
    CreateThread(function()
        while missionActive and currentStage == "driving_to_dropoff" do
            Wait(0)
            if IsControlJustPressed(0, 38) and not atDropoffPromptShown then -- E key
                Interactions.Client.InstrPrmt.Hide()
                dismissKeyPressed = true
                break
            end
        end
    end)
    
    CreateThread(function()
        while missionActive and (currentStage == "driving_to_dropoff" or currentStage == "at_dropoff") do
            Wait(0)
            
            local ped = PlayerPedId()
            local vehicle = GetVehiclePedIsIn(ped, false)
            
            if vehicle == truckEntity then
                local truckCoords = GetEntityCoords(truckEntity)
                local dropoffCoords = dropoffLocation
                local distance = #(truckCoords - vector3(dropoffCoords.x, dropoffCoords.y, dropoffCoords.z))
                
                -- Draw dropoff marker when close
                if distance < 50.0 then
                    local markerConfig = TruckingConfig.Markers.dropoff or TruckingConfig.Markers.pickup
                    DrawMarker(
                        markerConfig.type,
                        dropoffCoords.x, dropoffCoords.y, dropoffCoords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        markerConfig.size, markerConfig.size, markerConfig.size,
                        markerConfig.color.r, markerConfig.color.g, markerConfig.color.b, markerConfig.color.a,
                        markerConfig.bobUpAndDown,
                        markerConfig.faceCamera,
                        2,
                        markerConfig.rotate,
                        nil,
                        nil,
                        false
                    )
                    
                    -- Show help text when at dropoff
                    if distance < 10.0 then
                        -- Show instructional prompt for delivery completion
                        if not atDropoffPromptShown then
                            print("^2[Trucking Mission] Arrived at dropoff! Distance: " .. distance .. "^0")
                            Interactions.Client.InstrPrmt.Hide()
                            Interactions.Client.InstrPrmt.Show(
                                "Complete the delivery",
                                {
                                    {key = "E", desc = "Deliver Cargo"}
                                },
                                ""
                            )
                            atDropoffPromptShown = true
                            currentStage = "at_dropoff"
                            
                            -- Notify server of stage change
                            lib.callback.await("jg-dealerships:server:set-trucking-stage", false, "at_dropoff")
                        end
                        
                        if IsControlJustPressed(0, 38) then -- E key
                            print("^3[Trucking Mission Debug] E key pressed at dropoff!^0")
                            -- Check if trailer is attached
                            if trailerEntity and DoesEntityExist(trailerEntity) then
                                local isAttached = IsVehicleAttachedToTrailer(truckEntity)
                                
                                print("^3[Trucking Mission Debug] E pressed at dropoff. IsAttached: " .. tostring(isAttached) .. "^0")
                                
                                if not isAttached then
                                    Framework.Client.Notify("You need to attach the trailer to complete the delivery!", "error")
                                else
                                    -- Hide instructional prompt
                                    Interactions.Client.InstrPrmt.Hide()
                                    
                                    -- Complete the delivery
                                    print("^2[Trucking Mission] Completing delivery...^0")
                                    print("^3[Trucking Mission Debug] trailerNetId value: " .. tostring(trailerNetId) .. "^0")
                                    print("^3[Trucking Mission Debug] trailerEntity value: " .. tostring(trailerEntity) .. "^0")
                                    Framework.Client.Notify("Completing delivery...", "info")
                                    local success = TruckingMission.Client.Complete()
                                    
                                    print("^2[Trucking Mission] Complete result: " .. tostring(success) .. "^0")
                                    
                                    if success then
                                        Framework.Client.Notify("Delivery completed successfully!", "success")
                                    else
                                        Framework.Client.Notify("Failed to complete delivery", "error")
                                    end
                                end
                            else
                                Framework.Client.Notify("Trailer not found!", "error")
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- Set mission stage
function TruckingMission.Client.SetStage(stage)
    currentStage = stage
    
    -- Update blips based on stage
    if stage == "driving_to_dropoff" then
        -- Don't cleanup all blips - pickup blip is already removed manually
        -- Just ensure dropoff blip exists
        
        if dropoffLocation then
            -- Remove old dropoff blip if it exists
            if dropoffBlip and DoesBlipExist(dropoffBlip) then
                RemoveBlip(dropoffBlip)
                dropoffBlip = nil
            end
            
            -- Create new dropoff blip with delivery location
            local blipConfig = TruckingConfig.Blips.dropoff
            dropoffBlip = AddBlipForCoord(dropoffLocation.x, dropoffLocation.y, dropoffLocation.z)
            SetBlipSprite(dropoffBlip, blipConfig.sprite)
            SetBlipColour(dropoffBlip, blipConfig.color)
            SetBlipScale(dropoffBlip, blipConfig.scale)
            SetBlipRoute(dropoffBlip, true)
            SetBlipRouteColour(dropoffBlip, blipConfig.color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(blipConfig.label)
            EndTextCommandSetBlipName(dropoffBlip)
            
            print("^2[Trucking Mission] Dropoff blip created at: " .. dropoffLocation.x .. ", " .. dropoffLocation.y .. ", " .. dropoffLocation.z .. "^0")
        else
            print("^1[Trucking Mission] ERROR: dropoffLocation is nil!^0")
        end
    elseif stage == "at_dropoff" then
        -- Keep dropoff blip visible at dropoff location
        -- Only remove when mission completes
    end
    
    return true
end

-- NUI Callbacks
RegisterNUICallback("trucking:start", function(data, cb)
    local success, msg = TruckingMission.Client.Start(
        data.dealershipId,
        data.trailerType,
        data.orderIds,
        data.quantities,
        data.configHash
    )
    
    cb({ success = success, message = msg })
end)

RegisterNUICallback("trucking:complete", function(data, cb)
    local result = TruckingMission.Client.Complete()
    cb({ success = result })
end)

RegisterNUICallback("trucking:cancel", function(data, cb)
    local result = TruckingMission.Client.Cancel()
    cb({ success = result })
end)

-- Clean up on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if missionActive then
            TruckingMission.Client.Cancel()
        end
    end
end)

-- Export check function
exports('IsMissionVehicle', IsMissionVehicle)
