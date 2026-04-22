function OpenGrinderMenu()
    WaitNUI()
    SendNUIMessage({
        action = 'OPEN_GRINDER',
        payload = {}
    })
    SetNuiFocus(true, true)
    isMenuOpen.grinder = true
    OnMenuOpen()

end

function OpenWeedMenu()
    WaitNUI()
    SendNUIMessage({
        action = 'OPEN_WEEDS',
    })
    isMenuOpen.weed = true
    UpdateUIWeedData()
    
    SetNuiFocus(true, true)
    RefreshPlayerCash()
    OnMenuOpen()
end

RegisterNetEvent('mWeed:OpenGrinderMenu')
AddEventHandler('mWeed:OpenGrinderMenu', function()
    OpenGrinderMenu()
end)


local alreadyNear = false
CreateThread(function()
    while true do
        local wait = 2000
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local near = false
        for _,v in pairs(Config.Weeds.areas) do
            local dist = #(v.mainLocation - coords)
            if dist < v.radius then
                wait = 0
                ShowHelpNotification(Config.Weeds.helpText)
                near = true
            
                if IsControlJustPressed(0, Config.Weeds.interactionKey) then
                    fieldData.currentArea = _ 
                    OpenWeedMenu()    
                    WeedCam(v.cameraPos, v.cameraRot, v.cameraFov)            
                end

            end
        end

        if isMenuOpen.weed then
            Wait(2000)

        end
        if not near then
            HideHelpNotification()        
        end

        if near and not alreadyNear then
            SpawnAllWeeds()
            alreadyNear = true
        end

        if not near and alreadyNear then
            
            DeleteProps()    
            alreadyNear = false
        end
        Wait(wait)
    end
end)

RegisterNUICallback('selectField', function(data, cb)
    local near = false
    if taskActive then
        return
    end
    if fieldData.currentArea then
        local block = data.block
        local index = data.index
        local weedFieldData = Config.Weeds.areas[fieldData.currentArea]
        if not weedFieldData or not weedFieldData.weedLocations[block] or not weedFieldData.weedLocations[block][index]  then
            cb(false)
            return
        end
        if weedFieldData and weedFieldData.weedLocations[block] and weedFieldData.weedLocations[block][index]  then
            local location = weedFieldData.weedLocations[block][index][2] and 2 or 1
            local formattedCoord = vector3(weedFieldData.weedLocations[block][index][location].x, weedFieldData.weedLocations[block][index][location].y, weedFieldData.weedLocations[block][index][location].z)
           
            ClearPedTasks(PlayerPedId())
            TaskFollowNavMeshToCoord(PlayerPedId(), formattedCoord, 2.0, -1, 1.0)                        
            local myCoords = GetEntityCoords(PlayerPedId())
            local dist = #(myCoords -  formattedCoord)
            taskActive = true
            local attempts = 15
            while dist > 1.2 do
                myCoords = GetEntityCoords(PlayerPedId())
                dist = #(myCoords -  formattedCoord)
                if IsPedStill(PlayerPedId()) then
                    TaskFollowNavMeshToCoord(PlayerPedId(), formattedCoord, 2.0, -1, 1.0)                        
                end
                if not isMenuOpen.weed then
                    ClearPedTasks(PlayerPedId())
                    cb(false)
                    taskActive = false
                    return
                end
                attempts = attempts - 1 
                if attempts <= 0 then
                    ClearPedTasks(PlayerPedId())
                    taskActive = false
                    cb(false)
                    return
                end
                Wait(500)
            end
        
            
            if location == 2 then
                ClearPedTasks(PlayerPedId())
                CreateThread(function()
                    Wait(500)
                    SetEntityHeading(PlayerPedId(), weedFieldData.weedLocations[block][index][location].w)
                end)
            end
            fieldData.block = block
            fieldData.weedIndex = index
            near = true  
            taskActive = false
            cb(true)
        end
    end
    if not near then
        cb(false)
    end
end)

RegisterNUICallback('weedAction', function(data, cb)
    if alreadyDoingSomething then
        return
    end
    local actionType = data.actionType
    alreadyDoingSomething = true
    if actionType == 'dig' then
        local hasItem = TriggerCallback('mWeed:checkItem', {                    
            name = Config.Items["grubber"].name,
            reqAmount = 1,
        })
        if hasItem then            
            TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)    
            ProgressBar(Config.Notifications["DIGGING_DIRT"], Config.ActionTimes["dig"])
            Wait(Config.ActionTimes["dig"])
            if isMenuOpen.weed then
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent('mWeed:AddPlayerWeedData', fieldData.currentArea, fieldData.block, fieldData.weedIndex)
   
            end
        else
            TriggerEvent('mWeed:SendNotification', string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items["grubber"].label))
        end
    elseif actionType == 2 then
        local hasItem = TriggerCallback('mWeed:checkItem', {
            name = Config.Items[data.requiredItem].name,
            reqAmount = 1,
        })
        if hasItem then
            ProgressBar(Config.Notifications["POURING_FERTILIZER"], Config.ActionTimes["fertilizer"])
            FertilizerAnim(Config.ActionTimes["fertilizer"])
            Wait(Config.ActionTimes["fertilizer"])
            if isMenuOpen.weed then
                TriggerServerEvent('mWeed:AddProgress', fieldData.currentArea, fieldData.block, fieldData.weedIndex, data.requiredItem) 
                if data.requiredItem == 'quality_fertilizer' then
                    TriggerServerEvent('mWeed:SetIsQualityFertilizer', fieldData.currentArea, fieldData.block, fieldData.weedIndex, true)           
                end            
            end
        else
            TriggerEvent('mWeed:SendNotification', string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items["fertilizer"].label))
        end
    elseif actionType == 3 then
        local hasItem = TriggerCallback('mWeed:checkItem', {
            name = Config.Items[data.requiredItem].name,
            reqAmount = 1,
        })
        if hasItem then
            PlayAnim("amb@world_human_gardener_plant@male@idle_a", "idle_a")
            ProgressBar( Config.Notifications["PLANTING_SEED"], Config.ActionTimes["planting_seed"])
            Wait(Config.ActionTimes["planting_seed"])
            if isMenuOpen.weed then
                TriggerServerEvent('mWeed:AddProgress', fieldData.currentArea, fieldData.block, fieldData.weedIndex, data.requiredItem)            
                TriggerServerEvent('mWeed:SetSeedType', fieldData.currentArea, fieldData.block, fieldData.weedIndex, Config.Items[data.requiredItem].name)    
            end
        else
            TriggerEvent('mWeed:SendNotification', string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items[data.requiredItem].label))
        end
    elseif actionType == 4 then
        local hasItem = TriggerCallback('mWeed:checkItem', {
            name = Config.Items['grubber'].name,
            reqAmount = 1,
        })
        
        if hasItem then            
            TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)    
            ProgressBar(Config.Notifications["CLOSING_AREA"], Config.ActionTimes["closing_area"])
            Wait(Config.ActionTimes["closing_area"])
            if isMenuOpen.weed then
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent('mWeed:AddProgress', fieldData.currentArea, fieldData.block, fieldData.weedIndex)            

            end
        else
            TriggerEvent('mWeed:SendNotification',  string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items["grubber"].label))
        end
    elseif actionType == 'water' then
        local hasItem = TriggerCallback('mWeed:checkItem', {
            name = Config.Items['water'].name,
            reqAmount = 1,
        })
        local isValidData = weedData[tostring(fieldData.currentArea)] and weedData[tostring(fieldData.currentArea)][fieldData.block] and weedData[tostring(fieldData.currentArea)][fieldData.block][tostring(fieldData.weedIndex)]
        if isValidData then
            local wData = weedData[tostring(fieldData.currentArea)][fieldData.block][tostring(fieldData.weedIndex)]
            if wData.water <= 2 then
                if hasItem then
                    ProgressBar(Config.Notifications["WATERING_WEED"], Config.ActionTimes["watering"])
                    WateringAnim(Config.ActionTimes["watering"])                
                    Wait(Config.ActionTimes["watering"])
                    if isMenuOpen.weed then
                        TriggerServerEvent('mWeed:water', fieldData.currentArea, fieldData.block, fieldData.weedIndex)            
                    end
                else
                    TriggerEvent('mWeed:SendNotification', string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items["water"].label))
                end
            else
                TriggerEvent('mWeed:SendNotification', Config.Notifications["DONT_NEED_WATER"] )        
            end
        end
    elseif actionType == 'flounder' then
        local hasItem = TriggerCallback('mWeed:checkItem', {
            name = Config.Items['spray'].name,
            reqAmount = 1,
        })
        local isValidData = weedData[tostring(fieldData.currentArea)] and weedData[tostring(fieldData.currentArea)][fieldData.block] and weedData[tostring(fieldData.currentArea)][fieldData.block][tostring(fieldData.weedIndex)]

        if isValidData then
            local wData = weedData[tostring(fieldData.currentArea)][fieldData.block][tostring(fieldData.weedIndex)]
            if wData.flounder <= 2 then
                if hasItem then
                    ProgressBar(Config.Notifications["FLOUNDERING_WEED"], Config.ActionTimes["floundering"])
                    SprayAnim(Config.ActionTimes["floundering"])
                    Wait(Config.ActionTimes["floundering"])
                    if isMenuOpen.weed then
                        TriggerServerEvent('mWeed:flounder', fieldData.currentArea, fieldData.block, fieldData.weedIndex)
                    end
                else
                    TriggerEvent('mWeed:SendNotification', string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items["spray"].label))
                end
            else
                TriggerEvent('mWeed:SendNotification', Config.Notifications["DONT_NEED_FLOUNDER"]  )
            end
        end
    elseif actionType == 'harvest' then
        local isValidData = weedData[tostring(fieldData.currentArea)] and weedData[tostring(fieldData.currentArea)][fieldData.block] and weedData[tostring(fieldData.currentArea)][fieldData.block][tostring(fieldData.weedIndex)]
        if isValidData then
            local wData = weedData[tostring(fieldData.currentArea)][fieldData.block][tostring(fieldData.weedIndex)]
            if wData.growth >= 4 then
                HarvestAnim()
                ProgressBar(Config.Notifications["HARVESTING_WEED"], Config.ActionTimes["harvesting"])
                Wait(Config.ActionTimes["harvesting"])
                if isMenuOpen.weed then
                    TriggerServerEvent('mWeed:harvest', fieldData.currentArea, fieldData.block, fieldData.weedIndex)
                end
            else                
                TriggerEvent('mWeed:SendNotification',  Config.Notifications["HAS_NOT_GROWN"])
            end
        end
    elseif actionType == 'trash' then
        local isValidData = weedData[tostring(fieldData.currentArea)] and weedData[tostring(fieldData.currentArea)][fieldData.block] and weedData[tostring(fieldData.currentArea)][fieldData.block][tostring(fieldData.weedIndex)]
        if isValidData then
            HarvestAnim()
            ProgressBar(Config.Notifications["DESTROYING_WEED"], Config.ActionTimes["destroying"])
            Wait(Config.ActionTimes["destroying"])
            if isMenuOpen.weed then
                TriggerServerEvent('mWeed:trash', fieldData.currentArea, fieldData.block, fieldData.weedIndex)
            end
        end

    elseif actionType == 'grind' then
        local hasGrinder = TriggerCallback('mWeed:checkItem', {
            name = Config.Items['grinder'].name,
            reqAmount = 1,
        })
        local hasWeed = TriggerCallback('mWeed:checkItem', {
            name = Config.Items[data.requiredItem].name,
            reqAmount = 1,
        })
        if hasGrinder and hasWeed then
            ProgressBar(Config.Notifications["GRINDING_WEED"], Config.ActionTimes["grinding_weed"])
            HarvestAnim()
            Wait(Config.ActionTimes["grinding_weed"])
            if isMenuOpen.grinder then
                TriggerServerEvent('mWeed:grindWeed', Config.Items[data.requiredItem].name)
            end
        else
            local missingItems = ""
            if not hasGrinder then
                missingItems = Config.Items["grinder"].label
            end
            if not hasWeed then
                missingItems = missingItems.. ' '.. Config.Items[data.requiredItem].label
            end
            TriggerEvent('mWeed:SendNotification', string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], missingItems))
        end
    elseif actionType == 'roll' then
        local hasPaper = TriggerCallback('mWeed:checkItem', {
            name = Config.Items['raw_paper'].name,
            reqAmount = 4,
        })
        local hasGrindedWeed = TriggerCallback('mWeed:checkItem', {
            name =  Config.Items[data.requiredItem].name,
            reqAmount = 1,
        })
        if hasPaper and hasGrindedWeed then
            ProgressBar(Config.Notifications["ROLLING_JOINT"], Config.ActionTimes["rolling_joint"])
            HarvestAnim()
            Wait(Config.ActionTimes["rolling_joint"])
            if isMenuOpen.grinder then
                TriggerServerEvent('mWeed:rollWeed', Config.Items[data.requiredItem].name)
            end
        else
            local missingItems = ""
            if not hasPaper then
                missingItems = Config.Items["raw_paper"].label
            end
            if not hasGrindedWeed then
                missingItems = missingItems.. ' '.. Config.Items[data.requiredItem].label
            end
            TriggerEvent('mWeed:SendNotification', string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], missingItems))
        end
    end
    StopAnim()
    alreadyDoingSomething = false
    cb('ok')
end)

RegisterNetEvent('mWeed:useJoint')
AddEventHandler('mWeed:useJoint', function(type)
    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_SMOKING_POT", 0, 1)
    Citizen.Wait(3500)
    ClearPedTasks(PlayerPedId())
    Wait(1500)
    Config.UseableItems[type]()
end)

function WeedCam(pos, rot, fov)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos, rot, fov, false, 0)
    SetCamActive(cam, true)
    FreezeEntityPosition(PlayerPed, false)
    RenderScriptCams(true, true, 1000, true, true)
end