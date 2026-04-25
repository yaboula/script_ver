



-- Module state
local isPreviewActive = false
local previewEnabled = true
local previewEntities = {}
local previewBlips = {}
local lastLocationId = nil
local lastInteractionType = nil
local isInExplorationMode = false
local isNuiFocusActive = false

-- Control key mappings
local KEY_EXPLORATION_TOGGLE = 200

-- Clean up all preview entities and blips
local function cleanupPreviews(locationId, interactionType, interactions)
    if not isPreviewActive then
        return
    end

    isPreviewActive = false
    isInExplorationMode = false
    previewEnabled = true

    -- Delete all preview entities
    for _, entityData in ipairs(previewEntities) do
        local entityType = entityData.type
        
        -- Only process valid entity types
        if entityType == "ped" or entityType == "vehicle" or entityType == "object" then
            if entityData.entity then
                if DoesEntityExist(entityData.entity) then
                    SetEntityAsMissionEntity(entityData.entity, false, true)
                    
                    -- Clear ped tasks before deletion
                    if entityType == "ped" then
                        ClearPedTasksImmediately(entityData.entity)
                    end
                    
                    DeleteEntity(entityData.entity)
                end
            end
        end
    end

    -- Remove all blips
    for _, blip in ipairs(previewBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end

    -- Clear storage
    previewEntities = {}
    previewBlips = {}

    -- Recreate original interactions if needed
    if lastInteractionType and lastLocationId then
        if locationId and interactionType then
            if interactions then
                Locations.Client.RecreateInteractionTypeFromData(locationId, interactionType, interactions)
            else
                Locations.Client.RecreateInteractionType(locationId, interactionType)
            end
            
            lastInteractionType = nil
            lastLocationId = nil
        end
    end
end

-- Start preview mode for a set of interactions
local function startPreview(interactions, highlightingMode, optionalLocationId, keepInteractionsEnabled)
    if isInExplorationMode then
        return
    end

    isInExplorationMode = true
    previewEnabled = (keepInteractionsEnabled ~= false)

    -- Clean up any existing preview entities first
    if #previewEntities > 0 then
        for _, entityData in ipairs(previewEntities) do
            local entityType = entityData.type
            
            if entityType == "ped" or entityType == "vehicle" or entityType == "object" then
                if entityData.entity then
                    if DoesEntityExist(entityData.entity) then
                        SetEntityAsMissionEntity(entityData.entity, false, true)
                        
                        if entityType == "ped" then
                            ClearPedTasksImmediately(entityData.entity)
                        end
                        
                        DeleteEntity(entityData.entity)
                    end
                end
            end
        end
    end

    -- Initialize preview mode
    isPreviewActive = true
    previewEntities = {}
    previewBlips = {}

    -- Spawn preview entities for each interaction
    for _, interaction in ipairs(interactions) do
        local coords = interaction.coords and interaction.coords[1]
        local interactionType = interaction.type

        -- Spawn preview ped
        if interactionType == "ped" and coords then
            local pedData = Interactions.Client.Ped.SpawnPreview(coords, interaction.model, interaction.pedScenario)
            local pedEntity = pedData.entity or 0
            
            if pedEntity ~= 0 then
                table.insert(previewEntities, {
                    type = "ped",
                    entity = pedEntity
                })
            end
        
        -- Spawn preview vehicle
        elseif interactionType == "vehicle" and coords then
            local vehicleData = Interactions.Client.Vehicle.SpawnPreview(coords, interaction.model, interaction.vehColour)
            local vehicleEntity = vehicleData.entity or 0
            
            if vehicleEntity ~= 0 then
                table.insert(previewEntities, {
                    type = "vehicle",
                    entity = vehicleEntity
                })
            end
        
        -- Spawn preview object
        elseif interactionType == "object" and coords then
            local objectData = Interactions.Client.Object.SpawnPreview(coords, interaction.model)
            local objectEntity = objectData.entity or 0
            
            if objectEntity ~= 0 then
                table.insert(previewEntities, {
                    type = "object",
                    entity = objectEntity
                })
            end
        
        -- Create preview blip
        elseif interactionType == "blip" and coords then
            local blipData = Interactions.Client.Blip.CreatePreview(coords, interaction.blipSprite, interaction.blipColour)
            local blip = blipData.blip
            
            if blip and blip ~= 0 then
                table.insert(previewBlips, blip)
            end
        
        -- Create preview textUI
        elseif interactionType == "textUI" and coords then
            Interactions.Client.TextUI.CreatePreview(coords, interaction.message, interaction.variant)
        
        -- Create preview zone
        elseif interactionType == "zone" then
            local zonePoints = interaction.coords
            Interactions.Client.Zone.CreatePreview(zonePoints, interaction.onEnter, interaction.onExit)
        
        -- Create preview points (multiple coordinates)
        elseif interactionType == "point" then
            local pointCoords = interaction.coords
            Interactions.Client.Point.CreatePreview(pointCoords, interaction.distance, interaction.onEnter, interaction.onExit)
        end
    end

    -- Store location context for restoration
    if optionalLocationId then
        lastLocationId = optionalLocationId
        lastInteractionType = highlightingMode
    end

    -- Start highlighting thread if in highlighting mode
    if highlightingMode then
        CreateThread(function()
            while isPreviewActive do
                Wait(0)

                -- Highlight preview entities
                for index, entityData in ipairs(previewEntities) do
                    if not entityData.highlightHidden then
                        local entity = entityData.entity
                        
                        if entity and DoesEntityExist(entity) then
                            -- Draw highlight marker above entity
                            local entityCoords = GetEntityCoords(entity)
                            DrawMarker(
                                2, -- Down arrow marker
                                entityCoords.x, entityCoords.y, entityCoords.z + 2.0,
                                0.0, 0.0, 0.0, -- Direction
                                0.0, 180.0, 0.0, -- Rotation
                                0.5, 0.5, 0.5, -- Scale
                                255, 200, 0, 200, -- Yellow with alpha
                                false, -- Bob up and down
                                true, -- Face camera
                                2, -- Rotation axis
                                false, nil, nil, false
                            )

                            -- Draw interaction index text
                            local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(
                                entityCoords.x, entityCoords.y, entityCoords.z + 2.5
                            )
                            
                            if onScreen then
                                SetTextScale(0.4, 0.4)
                                SetTextFont(4)
                                SetTextProportional(true)
                                SetTextColour(255, 255, 255, 255)
                                SetTextOutline()
                                SetTextCentre(true)
                                BeginTextCommandDisplayText("STRING")
                                AddTextComponentSubstringPlayerName(tostring(index))
                                EndTextCommandDisplayText(screenX, screenY)
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- NUI Callback: Start preview with location context
RegisterNUICallback("preview-location-interactions", function(data, cb)
    local locationId = data.locationId
    local interactions = data.interactions
    local highlightingMode = data.interactionType
    local keepEnabled = data.keepInteractionsEnabled

    startPreview(interactions, highlightingMode, locationId, keepEnabled)
    
    cb("ok")
end)

-- NUI Callback: Stop preview without restoring original interactions
RegisterNUICallback("cancel-highlighting-preview", function(data, cb)
    cleanupPreviews(nil, nil, nil)
    cb("ok")
end)

-- NUI Callback: Toggle highlighting for specific preview enabled/disabled globally
RegisterNUICallback("toggle-all-interaction-highlights", function(data, cb)
    previewEnabled = (data.enabled ~= false)
    cb("ok")
end)

-- NUI Callback: Toggle highlighting for a single preview entity
RegisterNUICallback("toggle-single-interaction-highlight", function(data, cb)
    local index = data.index + 1 -- Lua arrays are 1-indexed
    
    if previewEntities[index] then
        previewEntities[index].highlightHidden = not data.enabled
    end
    
    cb("ok")
end)

-- NUI Callback: Set NUI focus state and handle exploration mode toggle
RegisterNUICallback("set-nui-focus", function(data, cb)
    SetNuiFocus(data.hasFocus, data.hasCursor)
    isNuiFocusActive = not data.hasFocus

    -- Enable exploration mode toggle when NUI loses focus
    if isNuiFocusActive then
        CreateThread(function()
            while isNuiFocusActive do
                -- Disable and check for exploration toggle key
                DisableControlAction(0, KEY_EXPLORATION_TOGGLE, true)
                
                if IsDisabledControlJustReleased(0, KEY_EXPLORATION_TOGGLE) then
                    SendNUIMessage({
                        action = "toggle-exploration-mode"
                    })
                    isNuiFocusActive = false
                end
                
                Wait(0)
            end
        end)
    end
    
    cb("ok")
end)

-- NUI Callback: Stop preview and optionally restore original interactions
RegisterNUICallback("stop-preview-location-interactions", function(data, cb)
    local locationId = data.locationId
    local interactionType = data.interactionType
    local interactions = data.interactions
    local skipRecreate = data.skipRecreate

    if skipRecreate then
        cleanupPreviews(nil, nil, nil)
    else
        cleanupPreviews(locationId, interactionType, interactions)
    end
    
    cb("ok")
end)

-- NUI Callback: Restore original location interactions
RegisterNUICallback("restore-location-interactions", function(data, cb)
    local locationId = data.locationId

    -- Clean up preview if active
    if isPreviewActive then
        isPreviewActive = false
        isInExplorationMode = false
        previewEnabled = true

        -- Delete entities
        for _, entityData in ipairs(previewEntities) do
            local entityType = entityData.type
            
            if entityType == "ped" or entityType == "vehicle" or entityType == "object" then
                if entityData.entity and DoesEntityExist(entityData.entity) then
                    SetEntityAsMissionEntity(entityData.entity, false, true)
                    
                    if entityType == "ped" then
                        ClearPedTasksImmediately(entityData.entity)
                    end
                    
                    DeleteEntity(entityData.entity)
                end
            end
        end

        -- Remove blips
        for _, blip in ipairs(previewBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end

        previewEntities = {}
        previewBlips = {}
    end

    -- Restore interactions if they match the stored location
    if lastInteractionType and lastLocationId then
        if lastLocationId == locationId then
            Locations.Client.RecreateInteractionType(locationId, lastInteractionType)
            lastInteractionType = nil
            lastLocationId = nil
        end
    end
    
    cb("ok")
end)

-- Event handler: Clean up on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        cleanupPreviews()
    end
end)