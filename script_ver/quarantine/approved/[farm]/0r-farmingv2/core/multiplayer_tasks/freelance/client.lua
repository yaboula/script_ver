local Utils = require("modules.utils.client")
local Target = require("modules.target.client")
local Config = lib.load("core.multiplayer_tasks.freelance.config")

local PLOT_STATES = {
    EMPTY = "empty",
    PLANTED = "planted",
    WATERED = "watered",
    GROWN = "grown",
    HARVESTED = "harvested"
}

local PLOT_COLORS = {
    [PLOT_STATES.EMPTY] = {r = 255, g = 255, b = 255},
    [PLOT_STATES.PLANTED] = {r = 255, g = 255, b = 0},
    [PLOT_STATES.WATERED] = {r = 130, g = 255, b = 243},
    [PLOT_STATES.GROWN] = {r = 0, g = 255, b = 0},
    [PLOT_STATES.HARVESTED] = {r = 255, g = 165, b = 0}
}

local VEHICLE_OPERATIONS = {
    tractor = {
        action = "planting",
        requiredState = PLOT_STATES.EMPTY,
        targetState = PLOT_STATES.PLANTED,
        maxSpeed = 20.0,
        workRadius = 3.0
    },
    harvester = {
        action = "harvesting",
        requiredState = PLOT_STATES.GROWN,
        targetState = PLOT_STATES.HARVESTED,
        maxSpeed = 16.0,
        workRadius = 4.0
    },
    watercan = {
        action = "watering",
        requiredState = PLOT_STATES.PLANTED,
        targetState = PLOT_STATES.WATERED,
        workRadius = 1.5,
        workTime = 2500,
        actionText = locale("freelance.water_plants"),
        anim = {
            dict = "weapon@w_sp_jerrycan",
            clip = "fire",
            flags = 1
        },
        prop = {
            model = "prop_wateringcan",
            bone = 18905,
            pos = {x = 0.08, y = -0.2, z = 0.3},
            rot = {x = -10.0, y = 80.0, z = 90.0}
        }
    }
}

local GameState = {}

local function InitGameState()
    GameState = {
        showTextUI = false,
        fieldBlips = {},
        fieldPoints = {},
        pointGroundZValues = {},
        pointWaterTimes = {},
        nearbyPoints = {},
        pointObjectNetIds = {},
        vehicleFarmingOperation = {
            isWorking = false,
            lastVehicle = nil,
            currentVehicleType = nil,
            lastProcessedPoints = {},
            selectedCropName = nil,
            grainUnloading = false,
            unloadingParticle = nil,
            lastGrainUpdateTime = 0,
            harvesterDoorIsOpen = false
        },
        carryingState = {
            isCarrying = false,
            carryingProp = nil
        },
        latestSpeedWarningTime = nil
    }
end
InitGameState()

local function hasRequiredItem(item, amount)
    return lib.callback.await(_e("server:inventory:hasRequiredItem"), false, item, amount)
end

local function removeItem(item, amount)
    return lib.callback.await(_e("server:inventory:removeItem"), false, item, amount)
end

local function getField(fieldId)
    return Config.fields[fieldId]
end

local function drawPlantingPointMarker(point)
    local state = point.state or PLOT_STATES.EMPTY
    local color = PLOT_COLORS[state] or PLOT_COLORS[PLOT_STATES.EMPTY]
    
    local markerType = "s1"
    if state == PLOT_STATES.WATERED then
        markerType = "s2"
    elseif state == PLOT_STATES.GROWN then
        markerType = "s3"
    end
    
    if not Config.DisableCustomMarkers then
        DrawMarker(9, point.coords.x, point.coords.y, point.coords.z + 1.0, 
            0.0, 0.0, 0.0, 90.0, 0.0, 0.0, 
            0.2, 0.25, 0.0, 
            color.r, color.g, color.b, 255, 
            false, true, 2, false, "res_markers", markerType, false)
    else
        DrawMarker(28, point.coords.x, point.coords.y, point.coords.z + 1.0, 
            0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 
            0.1, 0.1, 0.1, 
            color.r, color.g, color.b, 200, 
            false, true, 2, false, nil, nil, false)
    end
end

local function selectCropDialog()
    local options = {}
    for name, crop in pairs(Config.crops) do
        table.insert(options, {label = crop.label, value = name})
    end
    
    if #options == 0 then
        Utils.notify(locale("freelance.no_seeds_available"), "error")
        return nil
    end
    
    local input = lib.inputDialog(locale("freelance.select_crop"), {
        {
            type = "select",
            label = locale("freelance.crop_type"),
            options = options,
            required = true
        }
    })
    
    if input and input[1] then
        return input[1]
    end
    return nil
end

local function isPointInState(pointIndex, expectedState)
    local point = client.currentTask.game.plantingPoints[pointIndex]
    if not point then point = {} end
    local state = point.state or PLOT_STATES.EMPTY
    return state == expectedState
end

local function spawnTaskEntity(point)
    local meta = point.meta
    if not meta or not meta.key or not meta.model then return end
    
    local model = meta.model
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    
    if not IsModelValid(model) then
        shared.debug("debug:FreelanceClient.onEnterSpawnTaskEntityPoint: Invalid model", meta.model)
        return
    end
    
    local isVehicle = IsModelAVehicle(model)
    local coords = meta.coords or point.coords
    
    lib.requestModel(model)
    
    local entity
    if isVehicle then
        entity = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
    else
        entity = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    end
    
    while not DoesEntityExist(entity) do
        Wait(0)
    end
    
    local netId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(entity) then
            NetworkRegisterEntityAsNetworked(entity)
        else
            local id = isVehicle and VehToNet(entity) or ObjToNet(entity)
            if id and NetworkDoesNetworkIdExist(id) then
                return id
            end
        end
    end, false, false)
    
    SetModelAsNoLongerNeeded(model)
    SetEntityCoords(entity, coords.x, coords.y, coords.z)
    SetEntityRotation(entity, 0.0, 0.0, coords.w or 0.0, 2)
    
    if isVehicle then
        Utils.setFuel(entity, 100.0)
    else
        FreezeEntityPosition(entity, true)
    end
    
    local entityState = {
        key = meta.key,
        index = meta.index,
        model = meta.model,
        coords = coords,
        netId = netId,
        spawned = true
    }
    client.currentTask.game.taskEntities[meta.key][meta.index] = entityState
    
    GameState.fieldPoints["entity_" .. meta.key .. "_" .. meta.index] = nil
    
    lib.callback.await(_e("server:freelance:onVehicleSpawned"), false, client.lobby.id, entityState)
end

local function getNearbyPlantingPoints(radius)
    if not radius or radius <= 0 then radius = 15.0 end
    local playerCoords = GetEntityCoords(cache.ped)
    local nearby = {}
    
    if not client.currentTask or not client.currentTask.game or not client.currentTask.game.plantingPoints then
        return nearby
    end
    
    for index, point in pairs(client.currentTask.game.plantingPoints) do
        local distance = #(playerCoords - point.coords)
        if distance <= radius then
            if point.state ~= PLOT_STATES.HARVESTED then
                if not GameState.pointGroundZValues[index] then
                    local z, found = Utils.getGroundZ(point.coords)
                    if found then
                        GameState.pointGroundZValues[index] = z or point.coords.z
                    end
                end
                nearby[index] = {
                    coords = vector3(point.coords.x, point.coords.y, GameState.pointGroundZValues[index] or point.coords.z),
                    index = index,
                    state = point.state,
                    distance = distance
                }
            end
        end
    end
    return nearby
end

local function spawnPlantObject(cropName, state, coords, index, lobbyId)
    local cropConfig = Config.crops[cropName]
    local model = (cropConfig and cropConfig.model) or "prop_plant_01"
    
    lib.requestModel(model)
    local obj = CreateObject(GetHashKey(model), coords.x, coords.y, coords.z, true, true, false)
    
    if DoesEntityExist(obj) then
        NetworkRegisterEntityAsNetworked(obj)
        FreezeEntityPosition(obj, true)
        SetModelAsNoLongerNeeded(model)
        SetEntityCollision(obj, false, false)
        SetEntityCompletelyDisableCollision(obj, false, false)
        
        local netId = lib.waitFor(function()
            if NetworkGetEntityIsNetworked(obj) then
                local id = ObjToNet(obj)
                if id and NetworkDoesNetworkIdExist(id) then
                    return id
                end
            end
        end, false, false)
        
        if netId then
            lib.callback.await(_e("server:freelance:registerPointObject"), false, {
                lobbyId = lobbyId or client.lobby.id,
                pointIndex = index,
                networkId = netId,
                cropName = cropName,
                pointState = state
            })
            return netId
        end
    end
    return nil
end

local function getVehicleOperationType(vehicle)
    if not vehicle then return nil, nil end
    local model = GetEntityModel(vehicle)
    
    for opType, data in pairs(VEHICLE_OPERATIONS) do
        local field = getField(client.currentTask.game.fieldId)
        if field and field[opType] then
            local fieldModel = field[opType].model
            if type(fieldModel) == "string" then
                fieldModel = GetHashKey(fieldModel)
            end
            if model == fieldModel then
                return opType, data
            end
        end
    end
    return nil, nil
end

local function getModelHeight(model)
    if not model then return 0.0 end
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    if not IsModelValid(model) then return 0.0 end
    
    local min, max = GetModelDimensions(model)
    return math.abs(max.z - min.z)
end

local function startCarryingAnim()
    local ped = cache.ped
    lib.requestAnimDict("anim@heists@box_carry@")
    TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, 8.0, -1, 50, 0, false, false, false)
    
    if GameState.carryingState.carryingProp and DoesEntityExist(GameState.carryingState.carryingProp) then
        AttachEntityToEntity(GameState.carryingState.carryingProp, ped, GetPedBoneIndex(ped, 28422), 0.0, -0.5, -0.2, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end
end

local function stopCarryingAnim()
    local ped = cache.ped
    ClearPedTasks(ped)
    if GameState.carryingState.carryingProp and DoesEntityExist(GameState.carryingState.carryingProp) then
        DetachEntity(GameState.carryingState.carryingProp, true, false)
        DeleteEntity(GameState.carryingState.carryingProp)
    end
    GameState.carryingState.isCarrying = false
    GameState.carryingState.carryingProp = nil
end

local function loadBaleToTrailer(pointIndex, trailerNetId)
    if not GameState.carryingState.isCarrying then return end
    
    local trailer = NetToVeh(trailerNetId)
    local trailerCoords = GetEntityCoords(trailer)
    local playerCoords = GetEntityCoords(cache.ped)
    
    if #(trailerCoords - playerCoords) > 5.0 then return end
    
    if client.currentTask.game.harvesterState.harvestedBaleState.loadedCount > 5 then
        Utils.notify(locale("freelance.trailer_full"), "error")
        return
    end
    
    stopCarryingAnim()
    TriggerServerEvent(_e("server:freelance:loadHarvestedBaleToTrailer"), {
        lobbyId = client.lobby.id,
        pointIndex = pointIndex,
        trailerNetId = trailerNetId
    })
    Utils.notify(locale("freelance.harvested_bale_loaded"), "success")
end

local function pickupHarvestedBale(pointIndex, model)
    if GameState.carryingState.isCarrying then
        Utils.notify(locale("freelance.already_carrying"), "error")
        return
    end
    
    Target.removeZone("pickup_harvested_bale_" .. pointIndex)
    
    local playerCoords = GetEntityCoords(cache.ped)
    local netId = GameState.pointObjectNetIds[pointIndex]
    if netId then
        local obj = NetToObj(netId)
        if obj and DoesEntityExist(obj) then
            playerCoords = GetEntityCoords(obj)
        end
    end
    
    model = model or "prop_haybale_03"
    lib.requestModel(model)
    local obj = CreateObject(GetHashKey(model), playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
    
    GameState.carryingState.isCarrying = true
    GameState.carryingState.carryingProp = obj
    
    SetModelAsNoLongerNeeded(model)
    startCarryingAnim()
    
    TriggerServerEvent(_e("server:freelance:onHarvestedBalePickedUp"), {
        lobbyId = client.lobby.id,
        pointIndex = pointIndex
    })
end

local function createBalePickupZone(coords, index, model)
    local zoneName = "pickup_harvested_bale_" .. index
    Target.addBoxZone(zoneName, {
        coords = coords,
        name = zoneName,
        size = vector3(1.7, 2.1, 2.0),
        debug = false,
        options = {
            {
                label = locale("freelance.pickup_harvested_bale"),
                icon = "fas fa-hand-paper",
                distance = 2.0,
                canInteract = function()
                    return not GameState.carryingState.isCarrying
                end,
                onSelect = function()
                    pickupHarvestedBale(index, model)
                    
                    Citizen.CreateThread(function()
                        while GameState.carryingState.isCarrying do
                            local sleep = 500
                            local playerCoords = GetEntityCoords(cache.ped)
                            local nearestTrailerNetId = nil
                            local minDistance = math.huge
                            
                            if client.currentTask and client.currentTask.game and client.currentTask.game.taskEntities.trailer then
                                for _, trailerData in pairs(client.currentTask.game.taskEntities.trailer) do
                                    if trailerData.spawned and trailerData.netId then
                                        local trailer = NetToVeh(trailerData.netId)
                                        if DoesEntityExist(trailer) then
                                            local trailerCoords = GetEntityCoords(trailer)
                                            local dist = #(playerCoords - trailerCoords)
                                            if dist < minDistance then
                                                minDistance = dist
                                                nearestTrailerNetId = trailerData.netId
                                            end
                                        end
                                    end
                                end
                            end
                            
                            if nearestTrailerNetId then
                                local trailer = NetToVeh(nearestTrailerNetId)
                                if DoesEntityExist(trailer) then
                                    local trailerCoords = GetEntityCoords(trailer)
                                    local min, max = GetModelDimensions(GetEntityModel(trailer))
                                    local length = max.y - min.y
                                    local frontOffset = GetOffsetFromEntityInWorldCoords(trailer, 0.0, length / 2, 0.0)
                                    local backOffset = GetOffsetFromEntityInWorldCoords(trailer, 0.0, -length / 2, 0.0)
                                    local centerOffset = GetEntityCoords(trailer)
                                    local distFront = #(playerCoords - frontOffset)
                                    local distBack = #(playerCoords - backOffset)
                                    local distCenter = #(playerCoords - centerOffset)
                                    if distFront <= 2.5 or distBack <= 2.5 or distCenter <= 2.5 then
                                        loadBaleToTrailer(index, nearestTrailerNetId)
                                        Wait(1000)
                                    end
                                end
                            end
                            Wait(sleep)
                        end
                    end)
                end
            }
        }
    })
end

local function updatePointState(pointIndex, newState)
    local point = client.currentTask.game.plantingPoints[pointIndex]
    point.state = newState
    local blipColor = 0
    local cropName = point.cropName
    
    if newState == PLOT_STATES.PLANTED then
        blipColor = 5
        local model = (Config.crops[cropName] and Config.crops[cropName].model) or "prop_plant_01"
        local height = getModelHeight(model)
        local z = GameState.pointGroundZValues[pointIndex] or point.coords.z
        local spawnCoords = vector3(point.coords.x, point.coords.y, z - (height / 1.5))
        if model == "prop_veg_crop_rose" or model == "prop_veg_crop_green" or model == "prop_veg_crop_daisy" or model == "prop_veg_crop_poppy" then
            spawnCoords = vector3(spawnCoords.x, spawnCoords.y, spawnCoords.z + 0.02)
        end
        local netId = spawnPlantObject(cropName, newState, spawnCoords, pointIndex)
        if netId then
            GameState.pointObjectNetIds[pointIndex] = netId
        end
    elseif newState == PLOT_STATES.WATERED then
        blipColor = 29
        local netId = GameState.pointObjectNetIds[pointIndex]
        if netId then
            local obj = NetToObj(netId)
            if DoesEntityExist(obj) then
                local objCoords = GetEntityCoords(obj)
                SetEntityCoords(obj, objCoords.x, objCoords.y, objCoords.z + 0.2)
            end
        end
    elseif newState == PLOT_STATES.GROWN then
        blipColor = 2
    elseif newState == PLOT_STATES.HARVESTED then
        blipColor = 17
        GameState.nearbyPoints[pointIndex] = nil
    end
    
    local blip = GameState.fieldBlips["point_" .. pointIndex]
    if blip then
        SetBlipColour(blip, blipColor)
    end
    
    TriggerServerEvent(_e("server:freelance:onPlantingPointStateChanged"), {
        lobbyId = client.lobby.id,
        pointIndex = pointIndex,
        newState = newState,
        cropName = cropName
    })
end

local function processPointOperation(pointIndex, newState, vehicleType)
    if not (pointIndex and newState) or not vehicleType then return false end
    local lastProcessed = GameState.vehicleFarmingOperation.lastProcessedPoints[pointIndex]
    if lastProcessed and GetGameTimer() - lastProcessed < 2000 then
        return false
    end
    
    if vehicleType == "tractor" then
        if newState == PLOT_STATES.PLANTED then
            local cropName = GameState.vehicleFarmingOperation.selectedCropName
            if not cropName then return false, 2000 end
            local cropConfig = Config.crops[cropName]
            if not cropConfig then return false, 2000 end
            if not hasRequiredItem(cropConfig.seedItem, 1) then
                Utils.notify(locale("freelance.insufficient_seeds_for_tractor", cropConfig.label), "error")
                return false, 2000
            end
            if not removeItem(cropConfig.seedItem, 1) then
                Utils.notify(locale("freelance.failed_to_remove_item"), "error")
                return false, 2000
            end
            client.currentTask.game.plantingPoints[pointIndex].cropName = cropName
        end
    end
    
    updatePointState(pointIndex, newState)
    local actionName = (VEHICLE_OPERATIONS[vehicleType] and VEHICLE_OPERATIONS[vehicleType].action) or "farming"
    Utils.notify(locale("freelance.point_processed", pointIndex, actionName), "success", 1500)
    return true
end

local function startGrainUnloading()
    lib.callback.await(_e("server:freelance:onGrainUnloadingStarted"), false, client.lobby.id)
end

local function stopGrainUnloading()
    lib.callback.await(_e("server:freelance:onGrainUnloadingStopped"), false, client.lobby.id)
end

local function handleCropsGrowth()
    if client.lobby.owner ~= cache.serverId then return end
    for index, point in pairs(client.currentTask.game.plantingPoints) do
        if point.state == PLOT_STATES.WATERED then
            if not GameState.pointWaterTimes[index] then
                GameState.pointWaterTimes[index] = GetGameTimer()
            end
            local growthTime = 60
            local cropName = point.cropName
            if cropName and Config.crops[cropName] then
                growthTime = Config.crops[cropName].growthTime
            end
            if GetGameTimer() - GameState.pointWaterTimes[index] >= growthTime * 1000 then
                updatePointState(index, PLOT_STATES.GROWN)
                GameState.pointWaterTimes[index] = nil
            end
        end
    end
    for index, _ in pairs(GameState.pointWaterTimes) do
        local point = client.currentTask.game.plantingPoints[index]
        if point.state ~= PLOT_STATES.WATERED then
            GameState.pointWaterTimes[index] = nil
        end
    end
end

local function handleVehicleOperationsTick()
    local ped = cache.ped
    local vehicle = cache.vehicle
    if not vehicle then
        if GameState.vehicleFarmingOperation.isWorking then
            client.sendReactMessage("ui:setInfoBox", { inHarvester = false })
            Utils.notify(locale("freelance.farming_stopped"), "info")
            if GameState.vehicleFarmingOperation.currentVehicleType == "harvester" then
                if GameState.vehicleFarmingOperation.unloadingParticle then
                    StopParticleFxLooped(GameState.vehicleFarmingOperation.unloadingParticle, false)
                    GameState.vehicleFarmingOperation.unloadingParticle = nil
                end
                if DoesEntityExist(GameState.vehicleFarmingOperation.lastVehicle) then
                    SetVehicleDoorShut(GameState.vehicleFarmingOperation.lastVehicle, 4, false)
                end
            end
            GameState.vehicleFarmingOperation.isWorking = false
            GameState.vehicleFarmingOperation.currentVehicleType = nil
            return false, 2000
        end
        return false
    end
    
    local type, operation = getVehicleOperationType(vehicle)
    if not type or not operation then return false, 2000 end
    
    if GameState.vehicleFarmingOperation.currentVehicleType ~= type then
        GameState.vehicleFarmingOperation.isWorking = true
        GameState.vehicleFarmingOperation.currentVehicleType = type
        GameState.vehicleFarmingOperation.lastVehicle = vehicle
        Utils.notify(locale("freelance.farming_started", operation.action), "info")
        client.sendReactMessage("ui:setInfoBox", { inHarvester = (type == "harvester") })
        if type == "harvester" then
            GameState.vehicleFarmingOperation.grainUnloading = false
            GameState.vehicleFarmingOperation.unloadingParticle = nil
        end
    end
    
    if type == "harvester" then
        local grainLevel = client.currentTask.game.harvesterState.grainLevel or 0
        local speed = GetEntitySpeed(vehicle) * 3.6
        local isMoving = speed > 2.0
        local nearestTrailer = nil
        local minDist = math.huge
        
        if client.currentTask.game.taskEntities.trailer then
            local pipePos = GetEntityBonePosition_2(vehicle, GetEntityBoneIndexByName(vehicle, "bonnet"))
            for _, trailerData in pairs(client.currentTask.game.taskEntities.trailer) do
                if trailerData.spawned and trailerData.netId then
                    local trailer = NetToVeh(trailerData.netId)
                    if DoesEntityExist(trailer) then
                        local trailerUnloadPos = GetOffsetFromEntityInWorldCoords(trailer, 0.0, -3.0, 0.0)
                        local dist = #(pipePos - trailerUnloadPos)
                        if dist < minDist then
                            minDist = dist
                            nearestTrailer = trailer
                        end
                    end
                end
            end
        end
        
        if nearestTrailer and minDist < 15.0 then
            if grainLevel > 0 and not GameState.vehicleFarmingOperation.harvesterDoorIsOpen then
                SetVehicleDoorOpen(vehicle, 4, false, false)
                GameState.vehicleFarmingOperation.harvesterDoorIsOpen = true
            end
        elseif GameState.vehicleFarmingOperation.harvesterDoorIsOpen then
            SetVehicleDoorShut(vehicle, 4, false)
            GameState.vehicleFarmingOperation.harvesterDoorIsOpen = false
        end
        
        if nearestTrailer and minDist <= 10.0 and grainLevel > 0 then
            if not GameState.vehicleFarmingOperation.grainUnloading and not isMoving then
                GameState.vehicleFarmingOperation.grainUnloading = true
                SetVehicleDoorOpen(vehicle, 4, false, false)
                if not GameState.vehicleFarmingOperation.unloadingParticle then
                    local pipePos = GetEntityBonePosition_2(vehicle, GetEntityBoneIndexByName(vehicle, "bonnet"))
                    lib.requestNamedPtfxAsset("core")
                    UseParticleFxAssetNextCall("core")
                    GameState.vehicleFarmingOperation.unloadingParticle = StartParticleFxLoopedAtCoord("ent_amb_sprinkler_crop", pipePos.x, pipePos.y, pipePos.z, 0.0, 0.0, 90.0, 1.0, false, false, false)
                    RemoveNamedPtfxAsset("core")
                end
                startGrainUnloading()
                Utils.notify(locale("freelance.grain_unloading_started"), "info")
            elseif isMoving and GameState.vehicleFarmingOperation.grainUnloading then
                GameState.vehicleFarmingOperation.grainUnloading = false
                SetVehicleDoorShut(vehicle, 4, false)
                if GameState.vehicleFarmingOperation.unloadingParticle then
                    StopParticleFxLooped(GameState.vehicleFarmingOperation.unloadingParticle, false)
                    GameState.vehicleFarmingOperation.unloadingParticle = nil
                end
                stopGrainUnloading()
                Utils.notify(locale("freelance.grain_unloading_stopped"), "warning")
            end
        elseif GameState.vehicleFarmingOperation.grainUnloading and (not nearestTrailer or minDist > 10.0) then
            GameState.vehicleFarmingOperation.grainUnloading = false
            if GameState.vehicleFarmingOperation.unloadingParticle then
                StopParticleFxLooped(GameState.vehicleFarmingOperation.unloadingParticle, false)
                GameState.vehicleFarmingOperation.unloadingParticle = nil
            end
            stopGrainUnloading()
            Utils.notify(locale("freelance.grain_unloading_stopped"), "warning")
        end
        
        if GameState.vehicleFarmingOperation.grainUnloading and grainLevel <= 0 then
            GameState.vehicleFarmingOperation.grainUnloading = false
            SetVehicleDoorShut(vehicle, 4, false)
            if GameState.vehicleFarmingOperation.unloadingParticle then
                StopParticleFxLooped(GameState.vehicleFarmingOperation.unloadingParticle, false)
                GameState.vehicleFarmingOperation.unloadingParticle = nil
            end
            stopGrainUnloading()
            Utils.notify(locale("freelance.grain_unloading_completed"), "success")
        end
        
        if GameState.vehicleFarmingOperation.lastGrainUpdateTime == 0 or (GetGameTimer() - GameState.vehicleFarmingOperation.lastGrainUpdateTime > 2000) then
            GameState.vehicleFarmingOperation.lastGrainUpdateTime = GetGameTimer()
            TriggerServerEvent(_e("server:freelance:fetchGrainLevel"), { lobbyId = client.lobby.id })
        end
    end
    
    local isAttached = IsVehicleAttachedToTrailer(vehicle)
    local seederAttached = false
    local seederEntity = nil
    if client.currentTask.game.taskEntities.seeder then
        for _, seederData in pairs(client.currentTask.game.taskEntities.seeder) do
            if seederData.spawned and seederData.netId then
                local ent = IsModelAVehicle(seederData.model) and NetToVeh(seederData.netId) or NetToObj(seederData.netId)
                if DoesEntityExist(ent) and IsEntityAttached(ent) then
                    seederAttached = true
                    seederEntity = ent
                    break
                end
            end
        end
    end
    
    if seederAttached then
        if not GameState.vehicleFarmingOperation.selectedCropName and client.lobby.owner == cache.serverId then
            local crop = selectCropDialog() or next(Config.crops)
            GameState.vehicleFarmingOperation.selectedCropName = crop
            Utils.notify(locale("freelance.crop_selected_for_tractor", Config.crops[crop].label), "success")
            TriggerServerEvent(_e("server:freelance:onSeederCropSelected"), { lobbyId = client.lobby.id, cropName = crop })
        end
    else
        local nearestSeeder = nil
        local minDist = math.huge
        local playerCoords = GetEntityCoords(vehicle)
        if client.currentTask.game.taskEntities.seeder then
            for _, seederData in pairs(client.currentTask.game.taskEntities.seeder) do
                if seederData.spawned and seederData.netId then
                    local ent = IsModelAVehicle(seederData.model) and NetToVeh(seederData.netId) or NetToObj(seederData.netId)
                    if DoesEntityExist(ent) and not IsEntityAttached(ent) then
                        local dist = #(playerCoords - GetEntityCoords(ent))
                        if dist < minDist then
                            minDist = dist
                            nearestSeeder = ent
                        end
                    end
                end
            end
        end
        if nearestSeeder and minDist < 5.0 then
            AttachEntityToEntity(nearestSeeder, vehicle, 0, 0.0, -3.75, -0.4, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
            Utils.notify(locale("freelance.seeder_attached"), "success")
            return true, 2000
        end
    end
    
    if type == "tractor" then
        local hasTrailer, trailer = GetVehicleTrailerVehicle(vehicle)
        if hasTrailer and DoesEntityExist(trailer) then
            local field = getField(client.currentTask.game.fieldId)
            local trailerModel = field.trailer and GetHashKey(field.trailer.model)
            if trailerModel and GetEntityModel(trailer) == trailerModel then
                local dropCoords = field.dropHarvestedBaleCoords
                local dist = #(GetEntityCoords(vehicle) - dropCoords)
                if dist < 25.0 then
                    DrawMarker(1, dropCoords.x, dropCoords.y, dropCoords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.5, 2.5, 2.0, 255, 255, 255, 150, false, true, 2, false, nil, nil, false)
                    if dist < 5.0 then
                        if not GameState.showTextUI then
                            lib.showTextUI(locale("freelance.drop_harvested_bale"))
                            GameState.showTextUI = true
                        end
                        if IsControlJustPressed(0, 38) then
                            local result = lib.callback.await(_e("server:freelance:dropHarvestedBale"), false, { lobbyId = client.lobby.id })
                            if result and type(result) == "table" and result.error then
                                Utils.notify(result.error, "error")
                            elseif not result then
                                Utils.notify(locale("freelance.harvested_bale_drop_failed"), "error")
                            end
                            if GameState.showTextUI then
                                lib.hideTextUI()
                                GameState.showTextUI = false
                            end
                            return true, 1000
                        end
                    elseif GameState.showTextUI then
                        lib.hideTextUI()
                        GameState.showTextUI = false
                    end
                    return false, 0
                end
            end
        end
        if not seederAttached and not hasTrailer then
            if GameState.vehicleFarmingOperation.isWorking then
                Utils.notify(locale("freelance.tractor_needs_seeder_for_planting"), "error")
            end
            return false, 3000
        end
    end
    
    local speed = GetEntitySpeed(vehicle) * 3.6
    if speed < 5.0 then return false, 500 end
    if operation.maxSpeed and speed > (operation.maxSpeed + 5.0) then
        if not GameState.latestSpeedWarningTime or (GetGameTimer() - GameState.latestSpeedWarningTime > 2000) then
            GameState.latestSpeedWarningTime = GetGameTimer()
            Utils.notify(locale("freelance.too_fast", operation.maxSpeed), "error", 2000)
        end
        return false, 500
    end
    
    local workCoords = GetEntityCoords(vehicle)
    if type == "tractor" and seederAttached then
        workCoords = GetEntityCoords(seederEntity)
    elseif type == "harvester" then
        workCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 2.0, 0.0)
    end
    
    local pointsToProcess = {}
    for index, point in pairs(GameState.nearbyPoints) do
        local dist = #(workCoords - point.coords)
        if dist <= operation.workRadius then
            if isPointInState(index, operation.requiredState) then
                pointsToProcess[index] = point
            end
        end
    end
    for index, _ in pairs(pointsToProcess) do
        local success, waitTime = processPointOperation(index, operation.targetState, type)
        if not success then return false, waitTime end
    end
    return next(pointsToProcess) ~= nil
end

local function handleFootOperationsTick()
    if cache.vehicle then return false end
    local nearby = getNearbyPlantingPoints(5.0)
    if not next(nearby) then
        if GameState.showTextUI then
            lib.hideTextUI()
            GameState.showTextUI = false
        end
        return false
    end
    
    local closestPoint, closestOp = nil, nil
    local minDist = math.huge
    local playerCoords = GetEntityCoords(cache.ped)
    for index, point in pairs(nearby) do
        local state = client.currentTask.game.plantingPoints[index].state or PLOT_STATES.EMPTY
        for opType, opData in pairs(VEHICLE_OPERATIONS) do
            if opType == "watercan" then
                local dx = math.abs(playerCoords.x - point.coords.x)
                local dy = math.abs(playerCoords.y - point.coords.y)
                local dz = math.abs(playerCoords.z - point.coords.z)
                if state == opData.requiredState and dx < opData.workRadius and dy < opData.workRadius and dz < (opData.workRadius + 2.0) then
                    local dist = math.sqrt(dx*dx + dy*dy)
                    if dist < minDist then
                        minDist, closestPoint, closestOp = dist, point, opData
                    end
                end
            end
        end
    end
    
    if closestPoint and closestOp then
        if not GameState.showTextUI then
            lib.showTextUI(locale("freelance.press_to_action", closestOp.actionText))
            GameState.showTextUI = true
        end
        if IsControlJustPressed(0, 38) then
            lib.hideTextUI()
            GameState.showTextUI = false
            local label = (closestOp.action == "watering") and locale("freelance.watering_plants") or "Processing point..."
            if closestOp.action == "watering" and not hasRequiredItem(Config.wateringCan.itemName, 1) then
                Utils.notify(locale("freelance.no_watercan"), "error")
                return false, 1000
            end
            local success = lib.progressBar({ duration = closestOp.workTime, label = label, useWhileDead = false, canCancel = true, disable = { move = true, car = true, mouse = false, combat = true }, anim = closestOp.anim, prop = closestOp.prop })
            if success then
                updatePointState(closestPoint.index, closestOp.targetState)
                if closestOp.action == "watering" then
                    local wateredCount = 1
                    for index, point in pairs(client.currentTask.game.plantingPoints) do
                        if index ~= closestPoint.index and #(closestPoint.coords - point.coords) <= 7.0 and point.state == PLOT_STATES.PLANTED then
                            updatePointState(index, PLOT_STATES.WATERED)
                            wateredCount = wateredCount + 1
                        end
                    end
                    Utils.notify(locale("freelance.watering_success", wateredCount), "success")
                end
                Utils.notify(locale("freelance.point_processed", closestPoint.index, closestOp.action), "success")
                return true, 1000
            end
            return true, 0
        end
    elseif GameState.showTextUI then
        lib.hideTextUI()
        GameState.showTextUI = false
    end
    return false, 1000
end

local function threadWorker()
    Citizen.CreateThread(function()
        local lastUpdate = GetGameTimer()
        GameState.nearbyPoints = getNearbyPlantingPoints(25.0)
        while client.currentTask do
            local wait = 1000
            if next(GameState.nearbyPoints) then
                for _, point in pairs(GameState.nearbyPoints) do drawPlantingPointMarker(point) end
                wait = 1
            end
            if GetGameTimer() - lastUpdate > 1000 then
                GameState.nearbyPoints = getNearbyPlantingPoints(25.0)
                lastUpdate = GetGameTimer()
            end
            Wait(wait)
        end
    end)
    Citizen.CreateThread(function()
        while client.currentTask do
            local wait = 1000
            local vWorking, vWait = handleVehicleOperationsTick()
            local fWorking, fWait = handleFootOperationsTick()
            if vWorking then wait = 100 elseif fWorking then wait = 0 end
            if vWait and fWait then wait = math.max(vWait, fWait) elseif vWait then wait = vWait elseif fWait then wait = fWait end
            Wait(wait)
        end
    end)
    Citizen.CreateThread(function()
        local interval = (Config.debug and 5 or 30) * 1000
        while client.lobby and client.currentTask do
            handleCropsGrowth()
            Wait(interval)
        end
    end)
end

local function clear()
    shared.debug("debug:FreelanceClient.clear")
    if GameState.showTextUI then lib.hideTextUI() end
    if GameState.vehicleFarmingOperation and GameState.vehicleFarmingOperation.unloadingParticle then
        StopParticleFxLooped(GameState.vehicleFarmingOperation.unloadingParticle, false)
    end
    for _, blip in pairs(GameState.fieldBlips) do RemoveBlip(blip) end
    for _, point in pairs(GameState.fieldPoints) do point:remove() end
    if GameState.carryingState.carryingProp and DoesEntityExist(GameState.carryingState.carryingProp) then
        DetachEntity(GameState.carryingState.carryingProp, true, false)
        DeleteEntity(GameState.carryingState.carryingProp)
    end
    InitGameState()
    shared.debug("debug:FreelanceClient.clear: State cleared")
end

local function start()
    shared.debug("debug:FreelanceClient.start", string.format("lobby: %s, field: %s", (client.lobby and client.lobby.id or "nil"), (client.currentTask and client.currentTask.game.fieldId or "nil")))
    local field = getField(client.currentTask.game.fieldId)
    if not field then return false end
    InitGameState()
    GameState.fieldBlips.center = Utils.addBlip(field.center, Config.blips.field, true)
    GameState.fieldBlips.radius = Utils.addRadiusBlip(field.center, field.radius, Config.blips.field)
    GameState.fieldBlips.dropHarvestedBale = Utils.addBlip(field.dropHarvestedBaleCoords, Config.blips.dropHarvestedBale)
    for index, point in pairs(client.currentTask.game.plantingPoints) do
        GameState.fieldBlips["point_" .. index] = Utils.addBlip(point.coords, Config.blips.point)
    end
    if client.lobby.owner == cache.serverId then
        local entities = {"tractor", "harvester", "trailer", "seeder"}
        for _, key in pairs(entities) do
            local entityConfig = field[key]
            if entityConfig then
                for i = 1, math.min(1, #entityConfig.locations) do
                    local coords = entityConfig.locations[i]
                    GameState.fieldPoints["entity_" .. key .. "_" .. i] = lib.points.new({ coords = coords, distance = 50.0, meta = { key = key, model = entityConfig.model, coords = coords, index = i }, onEnter = spawnTaskEntity })
                    GameState.fieldBlips["entity_" .. key .. "_" .. i] = Utils.addBlip(coords, Config.blips[key], true)
                end
            end
        end
    end
    if not Config.DisableCustomMarkers then lib.requestStreamedTextureDict("res_markers") end
    threadWorker()
    Utils.notify(locale("tasks.started"), "success")
    return true
end

local function stop()
    shared.debug("debug:FreelanceClient.stop", string.format("lobby: %s, field: %s", (client.lobby and client.lobby.id or "nil"), (client.currentTask and client.currentTask.game.fieldId or "nil")))
    clear()
    if not Config.DisableCustomMarkers then SetStreamedTextureDictAsNoLongerNeeded("res_markers") end
    return true
end

RegisterNetEvent(_e("client:freelance:onVehicleSpawned"), function(entityState)
    if not entityState or not entityState.key or not entityState.index then return end
    client.currentTask.game.taskEntities[entityState.key][entityState.index] = entityState
    Citizen.CreateThread(function()
        local entity = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(entityState.netId) then
                local ent = (entityState.key == "seedMachine") and NetToObj(entityState.netId) or NetToVeh(entityState.netId)
                if DoesEntityExist(ent) then return ent end
            end
        end, false, false)
        if entityState.key ~= "seedMachine" then MultiplayerTasksClient.giveVehicleKey(GetVehicleNumberPlateText(entity), entity) end
    end)
end)

RegisterNetEvent(_e("client:freelance:onHarvestedBaleDropped"), function(data)
    if client.lobby and data.lobbyId == client.lobby.id then
        client.currentTask.game.harvesterState.harvestedBaleState.loadedCount = 0
        Utils.notify(locale("freelance.harvested_bale_dropped"), "success")
    end
end)

lib.callback.register(_e("client:freelance:spawnHarvestedBale"), function(data)
    if not data.lobbyId or (client.lobby and client.lobby.id ~= data.lobbyId) then return false end
    local cropConfig = Config.crops[data.cropName]
    local model = (cropConfig and cropConfig.harvestedBaleModel) or "prop_haybale_03"
    lib.requestModel(model)
    local spawnBase = cache.vehicle or cache.ped
    local spawnCoords = GetOffsetFromEntityInWorldCoords(spawnBase, 2.5, -5.0, 0.0)
    local z = lib.getGroundZ(spawnCoords)
    local obj = CreateObject(GetHashKey(model), spawnCoords.x, spawnCoords.y, z, true, true, false)
    local netId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(obj) then NetworkRegisterEntityAsNetworked(obj)
        else local id = ObjToNet(obj) if id and NetworkDoesNetworkIdExist(id) then return id end end
    end, false, false)
    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(obj, true)
    createBalePickupZone(spawnCoords, data.pointIndex, model)
    if DoesEntityExist(obj) then return { netId = netId, coords = spawnCoords, pointIndex = data.pointIndex, model = model } end
    return false
end)

RegisterNetEvent(_e("client:freelance:onPlantingPointUpdate"), function(data)
    if not data.lobbyId or (client.lobby and client.lobby.id ~= data.lobbyId) then return end
    local point = client.currentTask.game.plantingPoints[data.pointIndex]
    if data.newState then point.state = data.newState end
    if data.cropName then
        if not GameState.vehicleFarmingOperation.selectedCropName then GameState.vehicleFarmingOperation.selectedCropName = data.cropName end
        point.cropName = data.cropName
    end
    if data.meta and data.meta.grainLevel then
        client.currentTask.game.harvesterState.grainLevel = data.meta.grainLevel
        client.sendReactMessage("ui:setInfoBox", { grainLevel = data.meta.grainLevel })
    end
    if data.playerId ~= cache.serverId then
        local blipColor = 0
        if data.newState == PLOT_STATES.PLANTED then
            blipColor = 5
            if data.networkId then GameState.pointObjectNetIds[data.pointIndex] = data.networkId end
        elseif data.newState == PLOT_STATES.WATERED then blipColor = 29
        elseif data.newState == PLOT_STATES.GROWN then blipColor = 2
        elseif data.newState == PLOT_STATES.HARVESTED then
            blipColor = 17
            local blip = GameState.fieldBlips["point_" .. data.pointIndex]
            if blip then RemoveBlip(blip) GameState.fieldBlips["point_" .. data.pointIndex] = nil end
            GameState.nearbyPoints[data.pointIndex] = nil
        end
        if data.meta and data.meta.harvestedBale then
            local cropConfig = Config.crops[data.cropName]
            createBalePickupZone(data.meta.harvestedBale.coords, data.pointIndex, (cropConfig and cropConfig.harvestedBaleModel) or "prop_haybale_03")
        end
        local blip = GameState.fieldBlips["point_" .. data.pointIndex]
        if blip then SetBlipColour(blip, blipColor) end
    end
end)

RegisterNetEvent(_e("client:freelance:onHarvestedBalePickedUp"), function(data)
    if client.lobby and client.currentTask and data.lobbyId == client.lobby.id then Target.removeZone("pickup_harvested_bale_" .. data.pointIndex) end
end)

lib.callback.register(_e("client:freelance:attachHarvestedBaleToTrailer"), function(data)
    if not data or not data.trailerNetId then return end
    local trailer = NetToVeh(data.trailerNetId)
    if not DoesEntityExist(trailer) then return end
    local trailerCoords = GetEntityCoords(trailer)
    local cropConfig = Config.crops[data.cropName]
    local baleModel = (cropConfig and cropConfig.harvestedBaleModel) or "prop_haybale_03"
    lib.requestModel(baleModel)
    local obj = CreateObject(GetHashKey(baleModel), trailerCoords.x, trailerCoords.y, trailerCoords.z + 1.0, true, true, false)
    if not DoesEntityExist(obj) then return end
    local netId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(obj) then NetworkRegisterEntityAsNetworked(obj)
        else local id = ObjToNet(obj) if id and NetworkDoesNetworkIdExist(id) then return id end end
    end, false, false)
    local offset = vector3(0.0, 1.5 - (((data.loadedCount - 1) % 5) * 1.25), 0.55)
    AttachEntityToEntity(obj, trailer, nil, offset.x, offset.y, offset.z, 0.0, 0.0, 90.0, false, false, false, false, 2, true)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(baleModel)
    return netId
end)

RegisterNetEvent(_e("client:freelance:onHarvestedBaleAttached"), function(data)
    if client.lobby and client.currentTask and data.lobbyId == client.lobby.id then client.currentTask.game.harvesterState.harvestedBaleState.loadedCount = data.loadedCount end
end)

RegisterNetEvent(_e("client:freelance:onGrainLevelChanged"), function(data)
    if client.lobby and client.currentTask and data.lobbyId == client.lobby.id then
        client.currentTask.game.harvesterState.grainLevel = data.grainLevel
        client.sendReactMessage("ui:setInfoBox", { grainLevel = data.grainLevel })
    end
end)

RegisterNetEvent(_e("client:freelance:onSeederCropSelected"), function(data)
    if client.lobby and client.currentTask and data.lobbyId == client.lobby.id then
        if not GameState.vehicleFarmingOperation.selectedCropName then GameState.vehicleFarmingOperation.selectedCropName = data.cropName end
        Utils.notify(locale("freelance.seeder_crop_selected", Config.crops[data.cropName].label), "success")
    end
end)

RegisterNetEvent(_e("client:freelance:playWateringEffect"), function(data)
    if data.networkId then
        local obj = NetToObj(data.networkId)
        if DoesEntityExist(obj) then local coords = GetEntityCoords(obj) SetEntityCoords(obj, coords.x, coords.y, coords.z + 0.2) end
    end
end)

RegisterNetEvent(_e("client:freelance:playGrowthEffect"), function(data)
    if data.networkId then
        local oldObj = NetToObj(data.networkId)
        if DoesEntityExist(oldObj) then
            TriggerServerEvent(_e("server:freelance:deletePointObject"), { lobbyId = client.lobby.id, pointIndex = data.pointIndex })
            local netId = spawnPlantObject(data.cropName, data.newState, GetEntityCoords(oldObj), data.pointIndex)
            if netId then
                local newObj = NetToObj(netId)
                if DoesEntityExist(newObj) then
                    PlaceObjectOnGroundProperly(newObj)
                    local newCoords = GetEntityCoords(newObj)
                    local cropConfig = Config.crops[data.cropName]
                    local model = (cropConfig and cropConfig.model) or "prop_plant_01"
                    if model == "prop_veg_crop_rose" or model == "prop_veg_crop_green" or model == "prop_veg_crop_daisy" or model == "prop_veg_crop_poppy" then SetEntityCoords(newObj, newCoords.x, newCoords.y, newCoords.z - 2.0)
                    else SetEntityCoords(newObj, newCoords.x, newCoords.y, newCoords.z - 0.1) end
                    SetEntityRotation(newObj, 0.0, 0.0, 0.0, 2, true)
                end
                GameState.pointObjectNetIds[data.pointIndex] = netId
            end
        end
    end
end)

if Config.detachTrailerKey then
    lib.addKeybind({
        name = "farming_v2_detach_trailer",
        description = "Detach trailer/object from Tractor",
        defaultKey = Config.detachTrailerKey,
        onPressed = function()
            if not client.lobby or not client.currentTask or not cache.vehicle then return end
            local vehicle = cache.vehicle
            local netId = VehToNet(vehicle)
            if netId == 0 then return end
            local isTractor = false
            if client.currentTask.game.taskEntities.tractor then
                for _, tractorData in pairs(client.currentTask.game.taskEntities.tractor) do if tractorData.spawned and tractorData.netId == netId then isTractor = true break end end
            end
            if not isTractor then return end
            local detached, detachedType = false, ""
            if IsVehicleAttachedToTrailer(vehicle) then DetachVehicleFromTrailer(vehicle) detached, detachedType = true, "trailer"
            else
                local seeder = nil
                if client.currentTask.game.taskEntities.seeder then
                    for _, seederData in pairs(client.currentTask.game.taskEntities.seeder) do if seederData.spawned and seederData.netId then seeder = seederData break end end
                end
                if seeder then
                    local ent = NetToObj(seeder.netId)
                    if DoesEntityExist(ent) and IsEntityAttached(ent) then DetachEntity(ent, true, false) detached, detachedType = true, "seeder" end
                end
            end
            if detached then Utils.notify(locale("freelance." .. detachedType .. "_detached"), "success")
            else Utils.notify(locale("freelance.nothing_to_detach"), "info") end
        end
    })
end

if Config.debug then
    RegisterCommand("debug_freelance", function()
        if not client.currentTask or not client.currentTask.game then Utils.notify(locale("tasks.no_active_task"), "error") return end
        getNearbyPlantingPoints(50.0)
        local count = 0
        local crop = selectCropDialog() or next(Config.crops)
        for index, point in pairs(client.currentTask.game.plantingPoints) do
            if count >= 20 then break end
            point.cropName = crop
            for _, state in pairs({PLOT_STATES.PLANTED, PLOT_STATES.WATERED, PLOT_STATES.GROWN}) do updatePointState(index, state) Wait(50) end
            count = count + 1
        end
        shared.debug("debug:FreelanceClient.debug_freelance", string.format("Processed %s points", count))
    end, false)
end

local FreelanceModule = { start = start, stop = stop, clear = clear, threadWorker = threadWorker }
if MultiplayerTasksClient and MultiplayerTasksClient.registerModuleState then
    MultiplayerTasksClient.registerModuleState("freelance", FreelanceModule, Config)
end
