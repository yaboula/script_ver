



-- Initialize namespace
Interactions = Interactions or {}
Interactions.Client = Interactions.Client or {}
Interactions.Client.Vehicle = Interactions.Client.Vehicle or {}

-- Module state
local isPlacementActive = false

-- Control key mappings
local KEY_MOVE_UP = 21           -- Shift key
local KEY_MOVE_DOWN = 36         -- Ctrl key
local KEY_MOVE_FORWARD = 32      -- W key
local KEY_MOVE_BACKWARD = 33     -- S key
local KEY_MOVE_LEFT = 34         -- A key
local KEY_MOVE_RIGHT = 35        -- D key
local KEY_ROTATE_LEFT = 241      -- Mouse Scroll Up
local KEY_ROTATE_RIGHT = 242     -- Mouse Scroll Down
local KEY_CONFIRM = 191          -- Enter key
local KEY_CANCEL = 194           -- Backspace key

-- Adjustment speeds
local MOVEMENT_DISABLED_KEYS = {30, 31, 22, 23, 140}  -- Disable default game controls only
local ROTATION_SPEED = 5.0
local MOVEMENT_SPEED = 0.05

-- Rotate entity heading by specified amount
local function rotateEntity(entity, currentHeading, rotationDelta)
    local newHeading = (currentHeading + rotationDelta) % 360.0
    SetEntityHeading(entity, newHeading)
    return newHeading
end

-- Move entity in specified direction
local function moveEntity(entity, direction, distance, zoneToCheck)
    local entityCoords = GetEntityCoords(entity)
    local forwardVector = GetEntityForwardVector(entity)
    local rightVector = vector3(-forwardVector.y, forwardVector.x, 0.0)
    local offsetVector = vector3(0.0, 0.0, 0.0)

    -- Calculate offset based on direction
    if direction == "forward" then
        offsetVector = forwardVector * distance
    elseif direction == "back" then
        offsetVector = forwardVector * -distance
    elseif direction == "right" then
        offsetVector = rightVector * distance
    elseif direction == "left" then
        offsetVector = rightVector * -distance
    elseif direction == "up" then
        offsetVector = vector3(0.0, 0.0, distance)
    elseif direction == "down" then
        offsetVector = vector3(0.0, 0.0, -distance)
    end

    local newCoords = entityCoords + offsetVector

    -- Check if new position is within zone (if zone checking enabled)
    if zoneToCheck then
        local isInZone = DealershipZones.Client.IsPointInZone(zoneToCheck, newCoords.x, newCoords.y)
        if not isInZone then
            return
        end
    end

    SetEntityCoordsNoOffset(entity, newCoords.x, newCoords.y, newCoords.z, false, false, false)
end

-- Spawn a vehicle with specified parameters
function Interactions.Client.Vehicle.Spawn(coords, model, options)
    options = options or {}
    
    -- Default spawn options
    local colour = options.colour or 0
    local hasCollision = (options.collision ~= nil) and options.collision or true
    local alpha = options.alpha or 255
    local isFrozen = (options.frozen ~= nil) and options.frozen or true
    local isInvincible = (options.invincible ~= nil) and options.invincible or true
    local hasGravity = (options.gravity ~= nil) and options.gravity or false
    local isUndriveable = (options.undriveable ~= nil) and options.undriveable or true
    local isLocked = (options.locked ~= nil) and options.locked or true

    -- Request model and wait for it to load
    lib.requestModel(model)
    
    -- Create vehicle at specified coordinates
    local vehicle = CreateVehicle(
        joaat(model),
        coords.x, coords.y, coords.z,
        coords.w or 0.0,
        true,
        false
    )

    -- Wait for vehicle to exist
    while not DoesEntityExist(vehicle) do
        Wait(0)
    end

    -- Apply vehicle properties
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    
    -- Set collision
    SetEntityCollision(vehicle, hasCollision, hasCollision)
    
    -- Set alpha/transparency
    SetEntityAlpha(vehicle, alpha, false)
    
    -- Set frozen state
    FreezeEntityPosition(vehicle, isFrozen)
    
    -- Set invincibility
    SetEntityInvincible(vehicle, isInvincible)
    
    -- Set gravity
    SetEntityHasGravity(vehicle, hasGravity)
    
    -- Set driveable state
    if isUndriveable then
        SetVehicleUndriveable(vehicle, true)
    end
    
    -- Set door lock status
    if isLocked then
        SetVehicleDoorsLocked(vehicle, 2)
    end
    
    -- Apply custom colour if specified
    if colour and type(colour) == "table" and colour.r then
        SetVehicleCustomPrimaryColour(vehicle, colour.r, colour.g, colour.b)
        SetVehicleCustomSecondaryColour(vehicle, colour.r, colour.g, colour.b)
    end

    -- Enable streaming if requested
    if options.enableStreaming then
        SetVehicleIsStolen(vehicle, false)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    end

    return {
        entity = vehicle,
        model = model,
        coords = coords,
        options = options
    }
end

-- Start interactive vehicle placement mode
function Interactions.Client.Vehicle.StartCreator(model, colour)
    model = model or "adder"
    colour = colour or {r = 0, g = 0, b = 0}

    -- Create promise for async result
    local placementPromise = promise.new()

    CreateThread(function()
        -- Step 1: Show initial positioning prompt
        local waitingForPosition = true
        local userCancelled = false
        
        Interactions.Client.InstrPrmt.Show(
            "Position yourself where you want to spawn the vehicle",
            {
                {key = "Enter", desc = "Spawn Preview"},
                {key = "ESC", desc = "Cancel"}
            }
        )
        
        -- Wait for user to confirm position or cancel
        while waitingForPosition do
            Wait(0)
            
            -- Check for ENTER key to spawn preview
            if IsControlJustPressed(0, KEY_CONFIRM) then
                waitingForPosition = false
            end
            
            -- Check for ESC key to cancel
            if IsControlJustPressed(0, 200) then -- ESC key
                userCancelled = true
                waitingForPosition = false
            end
        end
        
        -- Hide the initial prompt
        Interactions.Client.InstrPrmt.Hide()
        
        -- If user cancelled, exit without spawning
        if userCancelled then
            placementPromise:resolve(nil)
            return
        end
        
        -- Step 2: Spawn preview vehicle and allow fine-tuning
        -- Get player position and spawn preview vehicle in front of player
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local playerHeading = GetEntityHeading(playerPed)
        local forwardVector = GetEntityForwardVector(playerPed)
        
        -- Spawn 3 meters in front of the player
        local spawnOffset = 3.0
        local spawnCoords = vector4(
            playerCoords.x + forwardVector.x * spawnOffset,
            playerCoords.y + forwardVector.y * spawnOffset,
            playerCoords.z,
            playerHeading
        )

        -- Spawn preview vehicle with special properties
        local previewVehicle = Interactions.Client.Vehicle.Spawn(spawnCoords, model, {
            colour = colour,
            collision = true,
            alpha = 200,
            frozen = true,
            invincible = true,
            gravity = false,
            undriveable = true,
            locked = true
        }).entity

        -- Initialize placement state
        local currentHeading = playerHeading
        local hasCollision = false
        local isConfirmed = false
        local isCancelled = false
        isPlacementActive = true
        
        -- Show initial instruction prompt
        Interactions.Client.InstrPrmt.Show(
            "Fine-tune vehicle position",
            {
                {key = "WASD", desc = "Move"},
                {key = "Shift/Ctrl", desc = "Up/Down"},
                {key = "Scroll Wheel", desc = "Rotate"},
                {key = "Enter", desc = "Confirm"},
                {key = "Backspace", desc = "Cancel"}
            },
            "",
            nil
        )

        -- Main placement loop
        local lastCollisionState = false
        
        while isPlacementActive do
            Wait(0)

            -- Disable conflicting controls
            for _, key in ipairs(MOVEMENT_DISABLED_KEYS) do
                DisableControlAction(0, key, true)
            end

            -- Handle rotation (mouse scroll)
            if IsControlJustReleased(0, KEY_ROTATE_LEFT) then
                currentHeading = rotateEntity(previewVehicle, currentHeading, ROTATION_SPEED)
            elseif IsControlJustReleased(0, KEY_ROTATE_RIGHT) then
                currentHeading = rotateEntity(previewVehicle, currentHeading, -ROTATION_SPEED)
            end

            -- Handle vertical movement
            if IsControlPressed(0, KEY_MOVE_UP) then
                moveEntity(previewVehicle, "up", MOVEMENT_SPEED)
            elseif IsControlPressed(0, KEY_MOVE_DOWN) then
                moveEntity(previewVehicle, "down", MOVEMENT_SPEED)
            end

            -- Handle horizontal movement
            if IsControlPressed(0, KEY_MOVE_FORWARD) then
                moveEntity(previewVehicle, "forward", MOVEMENT_SPEED)
            elseif IsControlPressed(0, KEY_MOVE_BACKWARD) then
                moveEntity(previewVehicle, "back", MOVEMENT_SPEED)
            elseif IsControlPressed(0, KEY_MOVE_LEFT) then
                moveEntity(previewVehicle, "left", MOVEMENT_SPEED)
            elseif IsControlPressed(0, KEY_MOVE_RIGHT) then
                moveEntity(previewVehicle, "right", MOVEMENT_SPEED)
            end

            -- Check for collision with other entities using proper collision detection
            hasCollision = false
            
            -- Use native collision detection
            local vehCoords = GetEntityCoords(previewVehicle)
            local minDim, maxDim = GetModelDimensions(GetEntityModel(previewVehicle))
            
            -- Check for overlapping entities using native functions
            -- First disable collision on preview vehicle temporarily to test
            SetEntityCollision(previewVehicle, false, false)
            
            -- Check if the preview vehicle would collide with anything at its current position
            local forwardVector = GetEntityForwardVector(previewVehicle)
            local heading = GetEntityHeading(previewVehicle)
            
            -- Test collision by checking if there's any entity in the bounding box
            local nearbyVehicles = GetGamePool('CVehicle')
            for _, vehicle in ipairs(nearbyVehicles) do
                if vehicle ~= previewVehicle and DoesEntityExist(vehicle) then
                    -- Use proper bounding box collision check
                    if IsEntityTouchingEntity(previewVehicle, vehicle) then
                        hasCollision = true
                        break
                    end
                    
                    -- Additional check using model dimensions
                    local otherCoords = GetEntityCoords(vehicle)
                    local otherMinDim, otherMaxDim = GetModelDimensions(GetEntityModel(vehicle))
                    
                    -- Calculate if bounding boxes overlap
                    local dx = math.abs(vehCoords.x - otherCoords.x)
                    local dy = math.abs(vehCoords.y - otherCoords.y)
                    local dz = math.abs(vehCoords.z - otherCoords.z)
                    
                    local xOverlap = dx < ((maxDim.x - minDim.x) + (otherMaxDim.x - otherMinDim.x)) / 2.0 + 0.3
                    local yOverlap = dy < ((maxDim.y - minDim.y) + (otherMaxDim.y - otherMinDim.y)) / 2.0 + 0.3
                    local zOverlap = dz < ((maxDim.z - minDim.z) + (otherMaxDim.z - otherMinDim.z)) / 2.0 + 0.3
                    
                    if xOverlap and yOverlap and zOverlap then
                        hasCollision = true
                        break
                    end
                end
            end
            
            -- Check for nearby objects if no vehicle collision
            if not hasCollision then
                local nearbyObjects = GetGamePool('CObject')
                for _, object in ipairs(nearbyObjects) do
                    if DoesEntityExist(object) then
                        -- Use touching check
                        if IsEntityTouchingEntity(previewVehicle, object) then
                            hasCollision = true
                            break
                        end
                        
                        -- Bounding box check for objects
                        local otherCoords = GetEntityCoords(object)
                        local otherMinDim, otherMaxDim = GetModelDimensions(GetEntityModel(object))
                        
                        local dx = math.abs(vehCoords.x - otherCoords.x)
                        local dy = math.abs(vehCoords.y - otherCoords.y)
                        local dz = math.abs(vehCoords.z - otherCoords.z)
                        
                        local xOverlap = dx < ((maxDim.x - minDim.x) + (otherMaxDim.x - otherMinDim.x)) / 2.0 + 0.2
                        local yOverlap = dy < ((maxDim.y - minDim.y) + (otherMaxDim.y - otherMinDim.y)) / 2.0 + 0.2
                        local zOverlap = dz < ((maxDim.z - minDim.z) + (otherMaxDim.z - otherMinDim.z)) / 2.0 + 0.2
                        
                        if xOverlap and yOverlap and zOverlap then
                            hasCollision = true
                            break
                        end
                    end
                end
            end
            
            -- Re-enable collision detection for visual feedback
            SetEntityCollision(previewVehicle, true, true)
            
            -- Update instruction prompt if collision state changed
            if hasCollision ~= lastCollisionState then
                lastCollisionState = hasCollision
                
                -- Show instruction prompt with warning if collision detected
                Interactions.Client.InstrPrmt.Show(
                    "Fine-tune vehicle position",
                    {
                        {key = "WASD", desc = "Move"},
                        {key = "Shift/Ctrl", desc = "Up/Down"},
                        {key = "Scroll Wheel", desc = "Rotate"},
                        {key = "Enter", desc = "Confirm"},
                        {key = "Backspace", desc = "Cancel"}
                    },
                    "",
                    hasCollision and "Warning: Collision detected! Press ENTER to ignore and place anyway." or nil
                )
            end
            
            -- Draw outline based on collision state
            if hasCollision then
                -- Red outline for collision
                SetEntityDrawOutline(previewVehicle, true)
                SetEntityDrawOutlineColor(255, 0, 0, 255)
                SetEntityDrawOutlineShader(1)
            else
                -- Green outline for valid placement
                SetEntityDrawOutline(previewVehicle, true)
                SetEntityDrawOutlineColor(0, 255, 0, 255)
                SetEntityDrawOutlineShader(1)
            end

            -- Handle confirmation
            if IsControlJustPressed(0, KEY_CONFIRM) then
                isConfirmed = true
                isPlacementActive = false
            end

            -- Handle cancellation
            if IsControlJustPressed(0, KEY_CANCEL) then
                isCancelled = true
                isPlacementActive = false
            end
        end

        -- Finalize placement
        local finalCoords = GetEntityCoords(previewVehicle)
        
        -- Disable outline before cleanup
        SetEntityDrawOutline(previewVehicle, false)
        
        if isConfirmed then
            if hasCollision then
                -- Collision warning was shown, but user confirmed anyway
                DebugPrint("[VehiclePlacer] Placed with collision warning at vector4(%.2f, %.2f, %.2f, %.2f)",
                    finalCoords.x, finalCoords.y, finalCoords.z, currentHeading)
            else
                DebugPrint("[VehiclePlacer Saved] vector4(%.2f, %.2f, %.2f, %.2f)",
                    finalCoords.x, finalCoords.y, finalCoords.z, currentHeading)
            end
            
            -- Return final position
            placementPromise:resolve({
                x = finalCoords.x,
                y = finalCoords.y,
                z = finalCoords.z,
                w = currentHeading
            })
        else
            -- Cancelled - return nil
            placementPromise:resolve(nil)
        end

        -- Cleanup
        DeleteEntity(previewVehicle)
        Interactions.Client.InstrPrmt.Hide()
    end)

    return Citizen.Await(placementPromise)
end

-- NUI Callback handler for vehicle placer
RegisterNUICallback("interactions-vehicle-placer", function(data, cb)
    local model = (data and data.vehModel) or "adder"
    local colour = (data and data.vehColour) or {r = 0, g = 0, b = 0}

    -- Disable NUI focus during placement
    SetNuiFocus(false, false)
    
    -- Start placement and wait for result
    local result = Interactions.Client.Vehicle.StartCreator(model, colour)
    
    -- Send result back to NUI
    cb(result)
    
    -- Re-enable NUI focus
    SetNuiFocus(true, true)
end)

-- Create a static vehicle with interaction support
function Interactions.Client.Vehicle.Create(coords, model, colour, label, key, onInteract, canInteract)
    model = model or "adder"
    colour = colour or {r = 0, g = 0, b = 0}

    -- Spawn vehicle with static properties
    local vehicleData = Interactions.Client.Vehicle.Spawn(coords, model, {
        colour = colour,
        collision = true,
        frozen = true,
        invincible = true,
        gravity = false,
        undriveable = true,
        locked = true,
        enableStreaming = true
    })

    -- Add interaction data
    vehicleData.interactionData = {
        label = label,
        key = key,
        onInteract = onInteract,
        distance = 3.0,
        canInteract = canInteract
    }

    -- Register interaction if vehicle was spawned successfully
    if vehicleData.entity and vehicleData.entity ~= 0 and DoesEntityExist(vehicleData.entity) then
        vehicleData.activeInteraction = Interactions.Client.Handler.AddEntityInteraction(
            vehicleData.entity,
            "vehicle",
            label,
            key,
            onInteract,
            3.0,
            canInteract
        )
    end

    return vehicleData
end