



-- Initialize namespace
Interactions = Interactions or {}
Interactions.Client = Interactions.Client or {}
Interactions.Client.Object = Interactions.Client.Object or {}

-- Module state
local isPlacementActive = false

-- Placement speeds
local ROTATION_SPEED_FAST = 2.0
local ROTATION_SPEED_SLOW = 2.0
local MOVEMENT_SPEED_HORIZONTAL = 0.01
local MOVEMENT_SPEED_VERTICAL = 0.01

-- Control key mappings
local KEY_MOVE_UP = 21           -- Shift key
local KEY_MOVE_DOWN = 36         -- Ctrl key
local KEY_MOVE_FORWARD = 32      -- W key
local KEY_MOVE_BACKWARD = 33     -- S key
local KEY_MOVE_LEFT = 34         -- A key
local KEY_MOVE_RIGHT = 35        -- D key
local KEY_ROTATE_LEFT = 241      -- Mouse Scroll Up
local KEY_ROTATE_RIGHT = 242     -- Mouse Scroll Down
local KEY_SNAP_GROUND = 47       -- G key
local KEY_CONFIRM = 191          -- Enter key
local KEY_CANCEL = 194           -- Backspace key

-- Adjustment speeds
local MOVEMENT_DISABLED_KEYS = {30, 31, 44, 22, 23, 140}

-- Rotate entity heading by specified amount
local function rotateEntity(entity, currentHeading, rotationDelta)
    local newHeading = (currentHeading + rotationDelta) % 360.0
    SetEntityHeading(entity, newHeading)
    return newHeading
end

-- Move entity in specified direction
local function moveEntity(entity, direction, distance)
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
    SetEntityCoordsNoOffset(entity, newCoords.x, newCoords.y, newCoords.z, false, false, false)
end

-- Snap object to ground with proper Z offset based on model dimensions
local function snapToGround(object)
    local objectCoords = GetEntityCoords(object)
    
    -- Use a high starting point for ground detection
    local testHeight = objectCoords.z + 10.0
    
    -- Try native ground detection first
    local foundGround, groundZ = GetGroundZFor_3dCoord(objectCoords.x, objectCoords.y, testHeight, false)
    
    if foundGround then
        -- Get model dimensions to calculate bottom offset
        local modelHash = GetEntityModel(object)
        local minDim, maxDim = GetModelDimensions(modelHash)
        
        -- Place object so its bottom touches the ground
        -- minDim.z is negative, so we subtract it (which adds the offset)
        return vector3(objectCoords.x, objectCoords.y, groundZ - minDim.z)
    end

    -- Fallback to raycast downward
    local rayHandle = StartShapeTestRay(
        objectCoords.x, objectCoords.y, objectCoords.z + 10.0,
        objectCoords.x, objectCoords.y, objectCoords.z - 100.0,
        -1, -- Hit everything
        object, -- Ignore the object itself
        7
    )
    
    local _, hit, hitCoords = GetShapeTestResult(rayHandle)
    
    if hit then
        -- Get model dimensions
        local modelHash = GetEntityModel(object)
        local minDim, maxDim = GetModelDimensions(modelHash)
        
        -- Place object so its bottom touches the ground
        return vector3(hitCoords.x, hitCoords.y, hitCoords.z - minDim.z)
    end

    -- If all else fails, just return current position on ground level
    local _, groundZ2 = GetGroundZFor_3dCoord(objectCoords.x, objectCoords.y, objectCoords.z + 1000.0, false)
    if groundZ2 then
        return vector3(objectCoords.x, objectCoords.y, groundZ2)
    end
    
    return nil
end

-- Spawn an object with specified parameters
function Interactions.Client.Object.Spawn(coords, model, options)
    options = options or {}
    
    -- Default spawn options
    local hasCollision = (options.collision ~= nil) and options.collision or true
    local alpha = options.alpha or 255
    local isFrozen = (options.frozen ~= nil) and options.frozen or true
    local isInvincible = (options.invincible ~= nil) and options.invincible or true

    -- Request model and wait for it to load
    lib.requestModel(model)
    
    -- Create object at specified coordinates
    local object = CreateObject(
        joaat(model),
        coords.x, coords.y, coords.z,
        true,
        false,
        false
    )

    -- Wait for object to exist (with timeout)
    local timeout = GetGameTimer() + 5000
    while not DoesEntityExist(object) do
        if GetGameTimer() > timeout then
            break
        end
        Wait(0)
    end

    if not DoesEntityExist(object) then
        return nil
    end

    -- Apply object properties
    SetEntityAsMissionEntity(object, true, true)
    SetEntityHeading(object, coords.w or 0.0)
    
    -- Set collision
    SetEntityCollision(object, hasCollision, hasCollision)
    
    -- Set alpha/transparency
    SetEntityAlpha(object, alpha, false)
    
    -- Set frozen state
    FreezeEntityPosition(object, isFrozen)
    
    -- Set invincibility
    SetEntityInvincible(object, isInvincible)

    -- Enable streaming if requested
    if options.enableStreaming then
        SetEntityAsNoLongerNeeded(object)
    end

    return {
        entity = object,
        model = model,
        coords = coords,
        options = options
    }
end

-- Spawn a preview object (same as regular spawn but with preview-specific defaults)
function Interactions.Client.Object.SpawnPreview(coords, model)
    return Interactions.Client.Object.Spawn(coords, model, {
        collision = true,
        alpha = 200,
        frozen = true,
        invincible = true
    })
end

-- Start interactive object placement mode
function Interactions.Client.Object.StartCreator(model)
    model = model or "prop_barrel_01a"

    -- Create promise for async result
    local placementPromise = promise.new()

    CreateThread(function()
        -- Get player position and spawn preview object
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local spawnCoords = vector4(playerCoords.x, playerCoords.y + 2.0, playerCoords.z, 0.0)

        -- Spawn preview object with special properties
        local previewObject = Interactions.Client.Object.Spawn(spawnCoords, model, {
            collision = true,
            alpha = 200,
            frozen = true,
            invincible = true
        }).entity

        if not previewObject or not DoesEntityExist(previewObject) then
            placementPromise:resolve(nil)
            return
        end

        -- Initialize placement state
        local currentHeading = 0.0
        local isConfirmed = false
        local isCancelled = false
        isPlacementActive = true

        -- Show instruction prompt
        Interactions.Client.InstrPrmt.Show(
            "Fine-tune object position",
            {
                {key = "WASD", desc = "Move"},
                {key = "Scroll", desc = "Rotate"},
                {key = "Shift/Ctrl", desc = "Up/Down"},
                {key = "G", desc = "Snap to Ground"},
                {key = "Enter", desc = "Confirm"},
                {key = "Backspace", desc = "Cancel"}
            },
            "Position Object"
        )

        -- Main placement loop
        while isPlacementActive do
            Wait(0)

            -- Disable conflicting controls
            for _, key in ipairs(MOVEMENT_DISABLED_KEYS) do
                DisableControlAction(0, key, true)
            end

            -- Handle rotation (mouse scroll)
            if IsControlJustReleased(0, KEY_ROTATE_LEFT) then
                currentHeading = rotateEntity(previewObject, currentHeading, -ROTATION_SPEED_SLOW)
            elseif IsControlJustReleased(0, KEY_ROTATE_RIGHT) then
                currentHeading = rotateEntity(previewObject, currentHeading, ROTATION_SPEED_SLOW)
            end

            -- Handle horizontal movement (WASD)
            if IsControlPressed(0, KEY_MOVE_FORWARD) then
                moveEntity(previewObject, "forward", MOVEMENT_SPEED_HORIZONTAL)
            elseif IsControlPressed(0, KEY_MOVE_BACKWARD) then
                moveEntity(previewObject, "back", MOVEMENT_SPEED_HORIZONTAL)
            end

            if IsControlPressed(0, KEY_MOVE_LEFT) then
                moveEntity(previewObject, "left", MOVEMENT_SPEED_HORIZONTAL)
            elseif IsControlPressed(0, KEY_MOVE_RIGHT) then
                moveEntity(previewObject, "right", MOVEMENT_SPEED_HORIZONTAL)
            end

            -- Handle vertical movement (Shift/Ctrl)
            if IsControlPressed(0, KEY_MOVE_UP) then
                moveEntity(previewObject, "up", MOVEMENT_SPEED_VERTICAL)
            elseif IsControlPressed(0, KEY_MOVE_DOWN) then
                moveEntity(previewObject, "down", MOVEMENT_SPEED_VERTICAL)
            end
            
            -- Handle snap to ground (G key)
            if IsControlJustReleased(0, KEY_SNAP_GROUND) then
                local groundCoords = snapToGround(previewObject)
                if groundCoords then
                    SetEntityCoordsNoOffset(previewObject, groundCoords.x, groundCoords.y, groundCoords.z, false, false, false)
                    -- Also place on ground properly
                    Wait(10)
                    PlaceObjectOnGroundProperly(previewObject)
                else
                    -- Fallback: just use PlaceObjectOnGroundProperly
                    PlaceObjectOnGroundProperly(previewObject)
                end
            end

            -- Apply entity outline to show selection
            Interactions.Client.SetEntityOutline(previewObject, 106, 226, 119, 255)

            -- Handle confirmation (Enter key)
            if IsControlJustReleased(0, KEY_CONFIRM) then
                local finalCoords = GetEntityCoords(previewObject)
                local finalHeading = GetEntityHeading(previewObject)
                
                DebugPrint(
                    "[ObjectPlacer Saved] vector4(%.2f, %.2f, %.2f, %.2f)",
                    finalCoords.x, finalCoords.y, finalCoords.z,
                    finalHeading
                )
                
                -- Cleanup and return result
                DeleteEntity(previewObject)
                Interactions.Client.InstrPrmt.Hide()
                
                placementPromise:resolve({
                    x = finalCoords.x,
                    y = finalCoords.y,
                    z = finalCoords.z,
                    w = finalHeading
                })
                
                isPlacementActive = false
            end
            
            -- Handle cancellation (Backspace key)
            if IsControlJustReleased(0, KEY_CANCEL) then
                -- Cleanup and return nil
                DeleteEntity(previewObject)
                Interactions.Client.InstrPrmt.Hide()
                
                placementPromise:resolve(nil)
                
                isPlacementActive = false
            end
        end
    end)

    return Citizen.Await(placementPromise)
end

-- NUI Callback handler for object placer
RegisterNUICallback("interactions-object-placer", function(data, cb)
    -- Disable NUI focus during placement
    SetNuiFocus(false, false)
    
    -- Start placement and wait for result
    local result = Interactions.Client.Object.StartCreator(data)
    
    -- Send result back to NUI
    cb(result)
    
    -- Re-enable NUI focus
    SetNuiFocus(true, true)
end)

-- Create a static object with interaction support
function Interactions.Client.Object.Create(coords, model, label, key, onInteract, canInteract)
    -- Spawn object with static properties
    -- Note: enableStreaming is disabled to keep objects persistent when player travels far away
    local objectData = Interactions.Client.Object.Spawn(coords, model, {
        collision = true,
        frozen = true,
        invincible = true,
        enableStreaming = false
    })

    -- Add interaction data
    objectData.interactionData = {
        label = label,
        key = key,
        onInteract = onInteract,
        distance = 2.5,
        canInteract = canInteract
    }

    -- Register interaction if object was spawned successfully
    if objectData.entity and objectData.entity ~= 0 and DoesEntityExist(objectData.entity) then
        objectData.activeInteraction = Interactions.Client.Handler.AddEntityInteraction(
            objectData.entity,
            "object",
            label,
            key,
            onInteract,
            2.5,
            canInteract
        )
    end

    return objectData
end