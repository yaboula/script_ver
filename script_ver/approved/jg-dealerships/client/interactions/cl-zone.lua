



-- Initialize namespace
Interactions = Interactions or {}
Interactions.Client = Interactions.Client or {}
Interactions.Client.Zone = Interactions.Client.Zone or {}

-- Control key mappings
local KEY_ADD_POINT = 38        -- E key
local KEY_REMOVE_POINT = 45     -- R key
local KEY_COMPLETE = 191        -- Enter key
local KEY_CANCEL = 194          -- Backspace key

-- Zone settings
local ZONE_HEIGHT = 5.0
local isCreatorActive = false
local zonePoints = {}

-- Get ground Z coordinate at given position using raycast
local function getGroundZ(x, y, z)
    -- Try native ground detection first
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z, false)
    if found then
        return groundZ
    end

    -- Fallback to raycast
    local rayHandle = StartShapeTestRay(
        x, y, z + 10.0,
        x, y, z - 100.0,
        1, -- Hit world
        0, -- No entity
        0
    )
    
    local _, hit, hitCoords = GetShapeTestResult(rayHandle)
    if hit then
        return hitCoords.z
    end

    return z
end

-- Add a point at player's current position
local function addPoint()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local groundZ = getGroundZ(playerCoords.x, playerCoords.y, playerCoords.z)
    
    local point = {
        x = playerCoords.x,
        y = playerCoords.y,
        z = groundZ + Globals.InteractionZOffset
    }
    
    table.insert(zonePoints, point)
    
    DebugPrint(
        string.format(
            "^2[Zone Creator]^7 Point %d added at %.2f, %.2f, %.2f",
            #zonePoints,
            point.x, point.y, point.z
        )
    )
end

-- Remove the last added point
local function removeLastPoint()
    if #zonePoints > 0 then
        table.remove(zonePoints)
        DebugPrint(
            string.format(
                "^2[Zone Creator]^7 Point removed. Total points: %d",
                #zonePoints
            )
        )
    else
        DebugPrint("^1[Zone Creator]^7 No points to remove!")
    end
end

-- Complete zone creation (requires at least 3 points)
local function completeZone()
    if #zonePoints < 3 then
        Framework.Client.Notify(
            string.format(
                "Need at least 3 points to complete zone! (Currently have %d)",
                #zonePoints
            ),
            "error",
            5000
        )
        return nil
    end

    isCreatorActive = false
    return zonePoints
end

-- Draw a vertical line at specified position
local function drawVerticalLine(x, y, z, height, r, g, b, a)
    DrawLine(
        x, y, z,
        x, y, z + height,
        r, g, b, a
    )
end

-- Visualize zone points and boundaries
local function visualizeZone()
    if #zonePoints == 0 then
        return
    end

    -- Adjust points to ground level
    local adjustedPoints = {}
    for _, point in ipairs(zonePoints) do
        local adjustedZ = point.z - Globals.InteractionZOffset
        table.insert(adjustedPoints, {
            x = point.x,
            y = point.y,
            z = adjustedZ
        })
    end

    -- Draw vertical lines at each point
    for _, point in ipairs(adjustedPoints) do
        drawVerticalLine(
            point.x, point.y, point.z,
            ZONE_HEIGHT,
            255, 0, 0, 255
        )
    end

    -- Draw zone polygon if we have enough points
    if #adjustedPoints >= 2 then
        Interactions.Client.Zone.DrawVisualization(
            adjustedPoints,
            ZONE_HEIGHT,
            255, 0, 0, 80
        )
    end
end

-- Draw zone polygon visualization
function Interactions.Client.Zone.DrawVisualization(points, height, r, g, b, a)
    if #points < 2 then
        return
    end

    -- Draw horizontal lines between consecutive points
    for i = 1, #points do
        local currentPoint = points[i]
        local nextPoint = points[(i % #points) + 1]
        
        DrawLine(
            currentPoint.x, currentPoint.y, currentPoint.z,
            nextPoint.x, nextPoint.y, nextPoint.z,
            r, g, b, a
        )
        
        DrawLine(
            currentPoint.x, currentPoint.y, currentPoint.z + height,
            nextPoint.x, nextPoint.y, nextPoint.z + height,
            r, g, b, a
        )
    end

    -- Draw zone polygon if we have enough points for a shape
    if #points >= 3 then
        -- Draw bottom polygon
        for i = 1, #points - 2 do
            local p1 = points[1]
            local p2 = points[i + 1]
            local p3 = points[i + 2]
            
            DrawPoly(
                p1.x, p1.y, p1.z,
                p2.x, p2.y, p2.z,
                p3.x, p3.y, p3.z,
                r, g, b, a
            )
        end

        -- Draw top polygon
        for i = 1, #points - 2 do
            local p1 = points[1]
            local p2 = points[i + 1]
            local p3 = points[i + 2]
            
            DrawPoly(
                p1.x, p1.y, p1.z + height,
                p3.x, p3.y, p3.z + height,
                p2.x, p2.y, p2.z + height,
                r, g, b, a
            )
        end

        -- Draw side walls
        for i = 1, #points do
            local currentPoint = points[i]
            local nextPoint = points[(i % #points) + 1]
            
            -- First triangle of wall quad
            DrawPoly(
                currentPoint.x, currentPoint.y, currentPoint.z,
                currentPoint.x, currentPoint.y, currentPoint.z + height,
                nextPoint.x, nextPoint.y, nextPoint.z,
                r, g, b, a
            )
            
            -- Second triangle of wall quad
            DrawPoly(
                nextPoint.x, nextPoint.y, nextPoint.z,
                currentPoint.x, currentPoint.y, currentPoint.z + height,
                nextPoint.x, nextPoint.y, nextPoint.z + height,
                r, g, b, a
            )
        end
    end
end

-- Create a preview zone (for visualization in editor)
function Interactions.Client.Zone.CreatePreview(points, onEnter, onExit)
    -- Create a visual-only zone for preview purposes
    -- This doesn't create actual interaction zones, just shows the visualization
    CreateThread(function()
        local previewActive = true
        
        while previewActive do
            Wait(0)
            
            if points and #points >= 3 then
                Interactions.Client.Zone.DrawVisualization(
                    points,
                    ZONE_HEIGHT,
                    255, 200, 0, 100
                )
            end
        end
    end)
end

-- Start interactive zone creator mode
function Interactions.Client.Zone.StartCreator()
    -- Reset state
    zonePoints = {}
    isCreatorActive = true

    -- Create promise for async result
    local creatorPromise = promise.new()

    CreateThread(function()
        -- Show instruction prompt
        Interactions.Client.InstrPrmt.Show(
            "Zone Creator",
            {
                {key = "E", desc = "Add Point"},
                {key = "R", desc = "Remove Last"},
                {key = "Enter", desc = "Complete"},
                {key = "Backspace", desc = "Cancel"}
            },
            "Move To Create Zone"
        )

        -- Main creator loop
        while isCreatorActive do
            Wait(0)

            -- Disable conflicting controls
            DisableControlAction(0, KEY_ADD_POINT, true)
            DisableControlAction(0, KEY_REMOVE_POINT, true)
            DisableControlAction(0, 140, true) -- Melee Attack Light
            DisableControlAction(0, 141, true) -- Melee Attack Heavy
            DisableControlAction(0, 142, true) -- Melee Attack Alternate
            DisableControlAction(0, 257, true) -- Attack 2
            DisableControlAction(0, 263, true) -- Melee Attack 1
            DisableControlAction(0, 264, true) -- Melee Attack 2

            -- Visualize current zone
            visualizeZone()

            -- Draw player position indicator
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            drawVerticalLine(
                playerCoords.x, playerCoords.y, playerCoords.z - 2.0,
                4.0,
                0, 255, 0, 200
            )

            -- Handle add point (E)
            if IsDisabledControlJustReleased(0, KEY_ADD_POINT) then
                addPoint()
            end

            -- Handle remove last point (R)
            if IsDisabledControlJustReleased(0, KEY_REMOVE_POINT) then
                removeLastPoint()
            end

            -- Handle complete zone (Enter)
            if IsControlJustReleased(0, KEY_COMPLETE) then
                local completedZone = completeZone()
                if completedZone then
                    Interactions.Client.InstrPrmt.Hide()
                    creatorPromise:resolve(completedZone)
                    break
                end
            end

            -- Handle cancel (Backspace)
            if IsControlJustReleased(0, KEY_CANCEL) then
                DebugPrint("^1[Zone Creator]^7 Cancelled!")
                Interactions.Client.InstrPrmt.Hide()
                isCreatorActive = false
                creatorPromise:resolve(false)
                break
            end

            -- Draw help text (DISABLED - Uncomment to re-enable)
        end
    end)

    return Citizen.Await(creatorPromise)
end

-- NUI Callback handler for zone creator
RegisterNUICallback("interactions-zone-creator", function(data, cb)
    -- Disable NUI focus during zone creation
    SetNuiFocus(false, false)
    
    -- Start creator and wait for result
    local result = Interactions.Client.Zone.StartCreator()
    
    -- Send result back to NUI
    cb(result)
    
    -- Re-enable NUI focus
    SetNuiFocus(true, true)
end)

-- Create a zone interaction with label, key, and callbacks
function Interactions.Client.Zone.Create(points, label, key, onInteract, canInteract)
    -- Calculate center point of zone
    local sumX, sumY, sumZ = 0, 0, 0
    for _, point in ipairs(points) do
        sumX = sumX + point.x
        sumY = sumY + point.y
        sumZ = sumZ + point.z
    end

    local centerPoint = vec3(
        sumX / #points,
        sumY / #points,
        sumZ / #points
    )

    -- Create point interaction at center of zone with zone boundary check
    return Interactions.Client.Handler.AddPointInteraction(
        centerPoint,
        10.0, -- Distance
        label,
        key,
        onInteract,
        points, -- Zone points for boundary checking
        canInteract
    )
end

-- Remove a zone interaction
function Interactions.Client.Zone.Remove(zoneId)
    if not zoneId then
        return
    end

    Interactions.Client.Handler.RemovePointInteraction(zoneId)
end