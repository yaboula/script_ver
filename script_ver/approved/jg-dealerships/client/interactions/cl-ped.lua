



-- Initialize module namespace
Interactions = Interactions or {}
Interactions.Client = Interactions.Client or {}
Interactions.Client.Ped = Interactions.Client.Ped or {}

-- Global state
local isPlacingPed = false

-- Key codes
local KEY_MOUSE_SCROLL_UP = 241      -- Scroll Up
local KEY_MOUSE_SCROLL_DOWN = 242    -- Scroll Down
local KEY_W = 32                     -- W key
local KEY_S = 33                     -- S key
local KEY_A = 34                     -- A key
local KEY_D = 35                     -- D key
local KEY_SHIFT = 21                 -- Shift key
local KEY_CTRL = 36                  -- Ctrl key
local KEY_ENTER = 191                -- Enter key
local KEY_BACKSPACE = 194            -- Backspace key
local ROTATION_KEYS = {30, 31, 22, 23, 140}  -- F, R, Enter, Esc, Delete

-- Helper function to rotate entity heading
local function rotateEntityHeading(entity, currentHeading, deltaHeading)
    local newHeading = (currentHeading + deltaHeading) % 360.0
    SetEntityHeading(entity, newHeading)
    return newHeading
end

-- Helper function to move entity in a direction
local function moveEntity(entity, direction, distance)
    local coords = GetEntityCoords(entity)
    local forward = GetEntityForwardVector(entity)
    local right = vector3(-forward.y, forward.x, 0.0)
    local offset = vector3(0.0, 0.0, 0.0)
    
    if direction == "forward" then
        offset = forward * distance
    elseif direction == "back" then
        offset = forward * (-distance)
    elseif direction == "right" then
        offset = right * distance
    elseif direction == "left" then
        offset = right * (-distance)
    elseif direction == "up" then
        offset = vector3(0.0, 0.0, distance)
    elseif direction == "down" then
        offset = vector3(0.0, 0.0, -distance)
    end
    
    local newCoords = coords + offset
    
    -- For vertical movement, use the new Z coordinate
    -- For horizontal movement, keep original Z to stay on ground
    if direction == "up" or direction == "down" then
        SetEntityCoordsNoOffset(entity, newCoords.x, newCoords.y, newCoords.z, false, false, false)
    else
        SetEntityCoordsNoOffset(entity, newCoords.x, newCoords.y, coords.z, false, false, false)
    end
end

-- Main ped spawning function
function Interactions.Client.Ped.Spawn(coords, model, scenario, options)
    options = options or {}
    
    -- Default options
    local hasCollision = options.collision ~= nil and options.collision or true
    local alpha = options.alpha or 255
    local frozen = options.frozen ~= nil and options.frozen or true
    local invincible = options.invincible ~= nil and options.invincible or true
    local blocking = options.blocking ~= nil and options.blocking or true
    local useGroundZ = options.useGroundZ ~= nil and options.useGroundZ or true
    
    -- Get ground Z coordinate if enabled
    local spawnZ = coords.z
    if useGroundZ then
        local foundGround, groundZCoord = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 50.0, false)
        if foundGround then
            spawnZ = groundZCoord
        end
    end
    
    -- Spawn the ped
    local function spawnPed()
        -- Request model
        lib.requestModel(model)
        
        -- Create ped (type 4 = civilian)
        local ped = CreatePed(
            4,
            joaat(model),
            coords.x, coords.y, spawnZ,
            coords.w or 0.0,
            false,
            false
        )
        
        -- Wait for ped to exist (with timeout)
        local timeout = GetGameTimer() + 5000
        while not DoesEntityExist(ped) and GetGameTimer() < timeout do
            Wait(0)
        end
        
        if not DoesEntityExist(ped) then
            return nil
        end
        
        -- Configure ped properties
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, blocking)
        
        -- Place ped on ground properly if using ground Z
        if useGroundZ then
            Wait(50)
            PlaceObjectOnGroundProperly(ped)
            Wait(50)
        end
        
        -- Apply alpha
        if options.alpha and alpha ~= 255 then
            SetEntityAlpha(ped, alpha, false)
        end
        
        -- Apply physics settings
        SetEntityCollision(ped, hasCollision, hasCollision)
        FreezeEntityPosition(ped, frozen)
        SetEntityInvincible(ped, invincible)
        
        -- Apply scenario if provided
        if scenario and scenario ~= "" then
            TaskStartScenarioInPlace(ped, scenario, 0, true)
        end
        
        -- Enable streaming if needed
        if options.enableStreaming then
            -- SetEntityDistanceCullingRadius is not available in all FiveM versions
            -- Using pcall to safely call it if it exists
            pcall(function()
                SetEntityDistanceCullingRadius(ped, 20000.0)
            end)
        end
        
        return ped
    end
    
    local ped = spawnPed()
    
    if not ped then
        return {
            success = false,
            entity = nil
        }
    end
    
    return {
        success = true,
        entity = ped,
        model = model,
        scenario = scenario,
        coords = coords
    }
end

-- Spawn preview ped (for location editor)
function Interactions.Client.Ped.SpawnPreview(coords, model, scenario)
    return Interactions.Client.Ped.Spawn(
        coords,
        model,
        scenario,
        {
            collision = true,
            alpha = 200,
            frozen = true,
            invincible = true,
            blocking = true
        }
    )
end

-- Ped placement creator with interactive controls
function Interactions.Client.Ped.StartCreator(model, scenario, options)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    -- Calculate spawn position in front of player
    local forward = GetEntityForwardVector(playerPed)
    local spawnX = playerCoords.x + forward.x * 3.0
    local spawnY = playerCoords.y + forward.y * 3.0
    
    -- Get ground Z coordinate at spawn position
    local groundZ = playerCoords.z
    local foundGround, groundZCoord = GetGroundZFor_3dCoord(spawnX, spawnY, playerCoords.z + 50.0, false)
    if foundGround then
        groundZ = groundZCoord
    end
    
    local spawnCoords = vector4(
        spawnX,
        spawnY,
        groundZ,
        playerHeading
    )
    
    -- Spawn preview ped
    local pedData = Interactions.Client.Ped.Spawn(
        spawnCoords,
        model,
        scenario,
        {
            collision = true,
            alpha = 200,
            frozen = true,
            invincible = true,
            blocking = true
        }
    )
    
    if not pedData.success then
        return nil
    end
    
    local previewPed = pedData.entity
    local currentHeading = playerHeading
    local rotationSpeed = 1.0
    local moveSpeed = 0.025
    local verticalMoveSpeed = 0.01
    
    -- Create promise for async return
    local promise = promise.new()
    
    isPlacingPed = true
    
    -- Show instructions
    Interactions.Client.InstrPrmt.Show(
        "Fine-tune ped position",
        {
            {key = "WASD", desc = "Move"},
            {key = "Shift/Ctrl", desc = "Up/Down"},
            {key = "Scroll Wheel", desc = "Rotate"},
            {key = "Enter", desc = "Confirm"},
            {key = "Backspace", desc = "Cancel"}
        }
    )
    
    -- Main placement loop
    CreateThread(function()
        while isPlacingPed do
            Wait(0)
            
            -- Disable rotation keys while placing
            for _, key in ipairs(ROTATION_KEYS) do
                DisableControlAction(0, key, true)
            end
            
            -- Movement controls (WASD)
            if IsControlPressed(0, KEY_W) then
                moveEntity(previewPed, "forward", moveSpeed)
            end
            if IsControlPressed(0, KEY_S) then
                moveEntity(previewPed, "back", moveSpeed)
            end
            if IsControlPressed(0, KEY_A) then
                moveEntity(previewPed, "left", moveSpeed)
            end
            if IsControlPressed(0, KEY_D) then
                moveEntity(previewPed, "right", moveSpeed)
            end
            
            -- Vertical movement controls (Shift/Ctrl)
            if IsControlPressed(0, KEY_SHIFT) then
                moveEntity(previewPed, "up", verticalMoveSpeed)
            end
            if IsControlPressed(0, KEY_CTRL) then
                moveEntity(previewPed, "down", verticalMoveSpeed)
            end
            
            -- Rotation controls (Scroll Wheel)
            if IsControlJustReleased(0, KEY_MOUSE_SCROLL_UP) then
                currentHeading = rotateEntityHeading(previewPed, currentHeading, rotationSpeed)
            end
            if IsControlJustReleased(0, KEY_MOUSE_SCROLL_DOWN) then
                currentHeading = rotateEntityHeading(previewPed, currentHeading, -rotationSpeed)
            end
            
            -- Draw position marker
            local pedCoords = GetEntityCoords(previewPed)
            Utils.Client.DrawMarkerOnFrame(
                20,  -- Vertical cylinder marker
                vec3(pedCoords.x, pedCoords.y, pedCoords.z + 1.2),
                0.5,
                {r = 106, g = 226, b = 119, a = 0.7843137254901961},
                vec3(180, 0, 0)
            )
            
            -- Confirm placement (Enter key)
            if IsControlJustReleased(0, KEY_ENTER) then
                local finalCoords = GetEntityCoords(previewPed)
                local scenarioText = scenario and (" | scenario: " .. scenario) or ""
                
                DebugPrint(string.format(
                    "[PedPlacer Saved] vector4(%.2f, %.2f, %.2f, %.2f)%s",
                    finalCoords.x, finalCoords.y, finalCoords.z, currentHeading, scenarioText
                ))
                
                DeletePed(previewPed)
                Interactions.Client.InstrPrmt.Hide()
                isPlacingPed = false
                
                promise:resolve({
                    x = finalCoords.x,
                    y = finalCoords.y,
                    z = finalCoords.z,
                    w = currentHeading
                })
                break
            end
            
            -- Cancel placement (Backspace key)
            if IsControlJustReleased(0, KEY_BACKSPACE) then
                DeletePed(previewPed)
                Interactions.Client.InstrPrmt.Hide()
                isPlacingPed = false
                
                promise:resolve(nil)
                break
            end
        end
    end)
    
    return Citizen.Await(promise)
end

-- NUI Callback for ped placer
RegisterNUICallback("interactions-ped-placer", function(data, cb)
    local model = data.pedModel
    local scenario = data.pedScenario
    
    SetNuiFocus(false, false)
    cb(Interactions.Client.Ped.StartCreator(model, scenario))
    SetNuiFocus(true, true)
end)

-- Create ped with interaction point
function Interactions.Client.Ped.Create(coords, model, scenario, label, key, onInteract, canInteract)
    -- Spawn the ped
    local pedData = Interactions.Client.Ped.Spawn(
        coords,
        model,
        scenario,
        {
            collision = true,
            frozen = true,
            invincible = true,
            blocking = true,
            enableStreaming = true
        }
    )
    
    -- Add interaction data
    pedData.interactionData = {
        label = label,
        key = key,
        onInteract = onInteract,
        distance = 2.5,
        canInteract = canInteract
    }
    
    -- Register entity interaction if ped exists
    if pedData.entity and pedData.entity ~= 0 and DoesEntityExist(pedData.entity) then
        pedData.activeInteraction = Interactions.Client.Handler.AddEntityInteraction(
            pedData.entity,
            "ped",
            label,
            key,
            onInteract,
            2.5,
            canInteract
        )
    end
    
    return pedData
end