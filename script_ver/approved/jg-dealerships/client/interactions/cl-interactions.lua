



-- Initialize namespace
Interactions = Interactions or {}
Interactions.Client = Interactions.Client or {}

-- Blip storage
local allBlips = {}

-- Create a blip at specified coordinates
local function createBlip(label, coords, sprite, colour, scale)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipScale(blip, scale + 0.0)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    
    table.insert(allBlips, blip)
    return blip
end

-- Create a collection of interactions from data array
function Interactions.Client.Create(interactions, key, label, onInteract, blipLabel, canInteract)
    -- Create interaction collection wrapper
    local collection = {
        entities = {},
        points = {},
        zones = {},
        blips = {},
        markers = {},
        _cancelled = false,
        _streamingEntitiesReady = false
    }

    -- Organize interactions by type
    local pedsToCreate = {}
    local vehiclesToCreate = {}
    local objectsToCreate = {}

    -- Whether to spawn non-ped entities
    local shouldSpawnEntities = not canInteract or canInteract

    -- Process each interaction in the data array
    for _, interaction in ipairs(interactions) do
        local coords = interaction.coords and interaction.coords[1]
        local interactionType = interaction.type
        local hasBlipEnabled = interaction.enableBlip

        -- Create blip if enabled
        if hasBlipEnabled and (shouldSpawnEntities or interactionType == "ped") then
            local blipCoords = nil

            -- Get blip position based on interaction type
            if interactionType == "polyzone" then
                blipCoords = Utils.Client.GetPolygonCenter(interaction.coords)
            elseif coords then
                blipCoords = vec3(coords.x, coords.y, coords.z)
            end

            if blipCoords then
                local blip = createBlip(
                    blipLabel or "Interaction",
                    blipCoords,
                    interaction.blipIconId,
                    interaction.blipColourId,
                    interaction.blipSize
                )
                table.insert(collection.blips, blip)
            end
        end

        -- Create marker if enabled (for point and polyzone types)
        if interaction.enableMarker then
            if interactionType == "point" and coords and shouldSpawnEntities then
                local markerCoords = vec3(coords.x, coords.y, coords.z)
                local markerConfig = {
                    id = interaction.markerId,
                    size = interaction.markerSize,
                    color = interaction.markerColor,
                    bobUpAndDown = interaction.markerBobUpAndDown,
                    faceCamera = interaction.markerFaceCamera,
                    rotate = interaction.markerRotate,
                    drawOnEnts = interaction.markerDrawOnEnts
                }

                -- Create streaming point for marker
                local markerPoint = lib.points.new({
                    coords = markerCoords,
                    distance = Config.EntityStreamingDistance or 150.0
                })

                -- Define marker draw function
                function markerPoint:nearby()
                    Utils.Client.DrawMarkerOnFrame(
                        markerConfig.id,
                        markerCoords,
                        markerConfig.size,
                        markerConfig.color,
                        nil, nil,
                        markerConfig.bobUpAndDown,
                        markerConfig.faceCamera,
                        markerConfig.rotate,
                        markerConfig.drawOnEnts
                    )
                end

                table.insert(collection.markers, markerPoint)
            end
        end

        -- Organize entities by type for batch creation
        if interactionType == "ped" then
            table.insert(pedsToCreate, {
                coords = coords,
                model = interaction.model,
                pedScenario = interaction.pedScenario,
                text = label,
                key = key,
                callback = onInteract,
                canInteract = canInteract
            })
        elseif interactionType == "vehicle" then
            table.insert(vehiclesToCreate, {
                coords = coords,
                model = interaction.model,
                vehColour = interaction.vehColour,
                text = label,
                key = key,
                callback = onInteract,
                canInteract = canInteract
            })
        elseif interactionType == "object" then
            table.insert(objectsToCreate, {
                coords = coords,
                model = interaction.model,
                text = label,
                key = key,
                callback = onInteract,
                canInteract = canInteract
            })
        elseif interactionType == "point" then
            if coords and shouldSpawnEntities then
                local pointId = Interactions.Client.Point.Create(
                    coords,
                    interaction.distance,
                    label,
                    key,
                    onInteract,
                    canInteract
                )
                table.insert(collection.points, pointId)
            end
        elseif interactionType == "polyzone" then
            -- Convert coordinates to vec3 array
            local zonePoints = {}
            for _, point in ipairs(interaction.coords) do
                table.insert(zonePoints, vec3(point.x, point.y, point.z))
            end

            -- Create zone interaction
            if shouldSpawnEntities then
                local zoneId = Interactions.Client.Zone.Create(
                    zonePoints,
                    label,
                    key,
                    onInteract,
                    canInteract
                )
                table.insert(collection.zones, zoneId)
            end

            -- Create marker for polyzone if enabled
            if interaction.enableMarker and shouldSpawnEntities then
                local centerCoords = Utils.Client.GetPolygonCenter(zonePoints)
                local markerCoords = vec3(centerCoords.x, centerCoords.y, centerCoords.z)
                local markerConfig = {
                    id = interaction.markerId,
                    size = interaction.markerSize,
                    color = interaction.markerColor,
                    bobUpAndDown = interaction.markerBobUpAndDown,
                    faceCamera = interaction.markerFaceCamera,
                    rotate = interaction.markerRotate,
                    drawOnEnts = interaction.markerDrawOnEnts
                }

                -- Create streaming point for marker
                local markerPoint = lib.points.new({
                    coords = markerCoords,
                    distance = Config.EntityStreamingDistance or 150.0
                })

                -- Define marker draw function
                function markerPoint:nearby()
                    Utils.Client.DrawMarkerOnFrame(
                        markerConfig.id,
                        markerCoords,
                        markerConfig.size,
                        markerConfig.color,
                        nil, nil,
                        markerConfig.bobUpAndDown,
                        markerConfig.faceCamera,
                        markerConfig.rotate,
                        markerConfig.drawOnEnts
                    )
                end

                table.insert(collection.markers, markerPoint)
            end
        end
    end

    -- Spawn entities if there are any to create
    if #pedsToCreate > 0 or #vehiclesToCreate > 0 or #objectsToCreate > 0 then
        CreateThread(function()
            -- Create all peds
            for _, pedData in ipairs(pedsToCreate) do
                if collection._cancelled then
                    return
                end

                local pedWrapper = Interactions.Client.Ped.Create(
                    pedData.coords,
                    pedData.model,
                    pedData.pedScenario,
                    pedData.text,
                    pedData.key,
                    pedData.callback,
                    pedData.canInteract
                )

                table.insert(collection.entities, {
                    type = "ped",
                    wrapper = pedWrapper,
                    entity = pedWrapper.entity or 0,
                    interactionId = "entity_" .. (pedWrapper.entity or 0)
                })

                Wait(100) -- Stagger spawning to avoid performance issues
            end

            -- Create all vehicles
            for _, vehicleData in ipairs(vehiclesToCreate) do
                if collection._cancelled then
                    return
                end

                local vehicleWrapper = Interactions.Client.Vehicle.Create(
                    vehicleData.coords,
                    vehicleData.model,
                    vehicleData.vehColour,
                    vehicleData.text,
                    vehicleData.key,
                    vehicleData.callback,
                    vehicleData.canInteract
                )

                table.insert(collection.entities, {
                    type = "vehicle",
                    wrapper = vehicleWrapper,
                    entity = vehicleWrapper.entity or 0,
                    interactionId = "entity_" .. (vehicleWrapper.entity or 0)
                })

                Wait(100)
            end

            -- Create all objects
            for index, objectData in ipairs(objectsToCreate) do
                if collection._cancelled then
                    return
                end

                local objectWrapper = Interactions.Client.Object.Create(
                    objectData.coords,
                    objectData.model,
                    objectData.text,
                    objectData.key,
                    objectData.callback,
                    objectData.canInteract
                )

                table.insert(collection.entities, {
                    type = "object",
                    wrapper = objectWrapper,
                    entity = objectWrapper.entity or 0,
                    interactionId = "entity_" .. (objectWrapper.entity or 0)
                })

                -- Wait between spawns except for the last one
                if index < #objectsToCreate then
                    Wait(100)
                end
            end

            collection._streamingEntitiesReady = true
        end)
    else
        -- No entities to spawn, mark as ready immediately
        collection._streamingEntitiesReady = true
    end

    return collection
end

-- Remove an interaction collection and cleanup all resources
function Interactions.Client.Remove(collection)
    if not collection then
        return
    end

    -- Mark collection as cancelled to stop any ongoing spawning
    collection._cancelled = true

    -- Remove all entities
    if collection.entities then
        for _, entityData in ipairs(collection.entities) do
            local wrapper = entityData.wrapper
            if wrapper then
                wrapper._removed = true

                -- Remove interaction handler
                if wrapper.activeInteraction then
                    Interactions.Client.Handler.RemoveEntityInteraction(wrapper.activeInteraction)
                    wrapper.activeInteraction = nil
                end

                -- Delete the entity
                if wrapper.entity and DoesEntityExist(wrapper.entity) then
                    -- Clear ped tasks before deletion
                    if entityData.type == "ped" then
                        ClearPedTasksImmediately(wrapper.entity)
                    end

                    SetEntityAsMissionEntity(wrapper.entity, false, true)
                    DeleteEntity(wrapper.entity)
                    wrapper.entity = nil
                end

                -- Remove streaming point
                if wrapper.streamingPoint then
                    wrapper.streamingPoint:remove()
                    wrapper.streamingPoint = nil
                end
            end
        end
    end

    -- Remove all point interactions
    if collection.points then
        for _, pointId in ipairs(collection.points) do
            Interactions.Client.Point.Remove(pointId)
        end
    end

    -- Remove all zone interactions
    if collection.zones then
        for _, zoneId in ipairs(collection.zones) do
            Interactions.Client.Zone.Remove(zoneId)
        end
    end

    -- Remove all blips
    if collection.blips then
        for _, blip in ipairs(collection.blips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
    end

    -- Remove all markers
    if collection.markers then
        for _, marker in ipairs(collection.markers) do
            marker:remove()
        end
    end
end