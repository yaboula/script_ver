CreateThread(function()
    local pedhash = CowShared.StartPed.hash
    while not HasModelLoaded(pedhash) do
        RequestModel(pedhash)
        Wait(0) 
    end
    local coord = CowShared.StartPed.coords
    local ped = CreatePed(4, pedhash, coord.x, coord.y, coord.z-1, coord.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(pedhash)

    local cowblip = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite(cowblip, CowShared.BlipSprite)
    SetBlipColour(cowblip, CowShared.BlipColour)
    SetBlipScale (cowblip, CowShared.BlipScale)
    SetBlipAsShortRange(cowblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Lan.CowBlip)
    EndTextCommandSetBlipName(cowblip)
end)

local cowped = 0
local Bale = 0
local veh = 0

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        ClearCustomBlips()
        if cowped ~= 0 then
            DeleteEntity(cowped)
        end
        if Bale ~= 0 then
            DeleteEntity(Bale)
        end
        if veh ~= 0 then
            DeleteVehicle(veh)
        end
	end
end)

local function SpawnCowsAndTasks(id)
    Current_Stage = 1
    local car = CowShared.Vehicle
    RequestModel(car)
    while not HasModelLoaded(car) do
        Wait(0)
    end
    veh = CreateVehicle(car, CowShared.Fields2[id].x, CowShared.Fields2[id].y, CowShared.Fields2[id].z, CowShared.Fields2[id].w, true, false)
    NetworkFadeInEntity(veh, true, true)
    SetVehicleHasBeenOwnedByPlayer(veh, true)

    if MainShared.UseKeyFunction then
        MainShared.AddVehicleKey(veh)
    end
    local inek = 0xFCFA9E1E
    while not HasModelLoaded(inek) do
        RequestModel(inek)
        Wait(0) 
    end
    local max_veri = 0
    local yapilan_veri = 0
    local milkelimde = false

    cowped = CreatePed(4, inek, CowShared.Fields[id].x, CowShared.Fields[id].y, CowShared.Fields[id].z-1, CowShared.Fields[id].w, true, false)
    FreezeEntityPosition(cowped, true)
    SetEntityInvincible(cowped, true)
    SetBlockingOfNonTemporaryEvents(cowped, true)
    SetModelAsNoLongerNeeded(inek)
    TriggerServerEvent("0r-farming-insert-cow", NetworkGetNetworkIdFromEntity(veh))
    TriggerServerEvent("0r-farming-insert-cow", NetworkGetNetworkIdFromEntity(cowped))
    CreateThread(function()
        while JobStarted do
            local ms = 250
            local ped = PlayerPedId()
            local Trying_Enter = GetVehiclePedIsEntering(ped)
            if Trying_Enter ~= 0 then
                if GetDisplayNameFromVehicleModel(GetEntityModel(Trying_Enter)) == 'MULE' then
                    if Trying_Enter ~= veh then
                        ClearPedTasksImmediately(ped)
                        MainShared.Notify(Lan.ThisVehIsNotYours, 'error')
                    end
                end
            end

            if Current_Stage == 1 then
                if not Has_HayBale then
                    local jobdist = #(GetEntityCoords(ped) - vector3(CowShared.HayBaleCoords.x, CowShared.HayBaleCoords.y, CowShared.HayBaleCoords.z))
                    if jobdist > 7.0 or jobdist < 7.0 then
                        ms = 0 
                        DrawMarker(2, CowShared.HayBaleCoords.x, CowShared.HayBaleCoords.y, CowShared.HayBaleCoords.z+0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 240, 255, 240, 180, true, true, 2, false)
                    end

                    if jobdist < 1.9 then
                        MainShared.HelpNotify(Lan.TakeHayBale, MainShared.HelpNotifyType, CowShared.HayBaleCoords)
                        if IsControlJustPressed(0, 38) then
                            Has_HayBale = true
                            Current_Stage += 1
                            TriggerEvent('0r-farming-carry-object', MainShared.HayBaleProp["model"], MainShared.HayBaleProp["bone"], MainShared.HayBaleProp["x"],MainShared.HayBaleProp["y"], MainShared.HayBaleProp["z"], MainShared.HayBaleProp["xR"], MainShared.HayBaleProp["yR"] ,MainShared.HayBaleProp["zR"], MainShared.HayBaleProp["animDict"], MainShared.HayBaleProp["animName"])
                        end
                    end
                end
            end

            if Current_Stage == 2 then
                local jobdist = #(GetEntityCoords(ped) - vector3(CowShared.Fields[id].x, CowShared.Fields[id].y, CowShared.Fields[id].z))
                if jobdist > 7.0 and Has_HayBale then
                    ms = 0 
                    DrawMarker(2, CowShared.Fields[id].x, CowShared.Fields[id].y, CowShared.Fields[id].z+6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 240, 255, 240, 180, true, true, 2, false)
                elseif jobdist < 1.8 and not isBussy and Has_HayBale then
                    ms = 0
                    MainShared.HelpNotify(Lan.FeedCow, MainShared.HelpNotifyType, CowShared.Fields[id])
                    if IsControlJustPressed(0, 38) then
                        local boneCoords = GetWorldPositionOfEntityBone(cowped, 24)
                        isBussy = true
                        RequestModel(MainShared.HayBaleProp["model"])
                        while not HasModelLoaded(MainShared.HayBaleProp["model"]) do
                            Wait(100)
                        end
                        Bale = CreateObject(MainShared.HayBaleProp["model"], boneCoords.x, boneCoords.y, boneCoords.z, 1, 1, 0)
                        PlaceObjectOnGroundProperly(Bale)
                        Wait(50)
                        SetEntityCoords(Bale, GetEntityCoords(Bale).x, GetEntityCoords(Bale).y, GetEntityCoords(Bale).z-0.35)
                        TriggerEvent('0r-farming-stop-carry')
                        MainShared.PlayAnimation(cowped, "creatures@cow@amb@world_cow_grazing@base", "base", 10000)
                        Wait(10000)
                        DeleteEntity(Bale)
                        Current_Stage += 1
                        isBussy = false
                        for i=1, CowShared.PerMilking do
                            max_veri += 1
                        end
                    end
                end
            end

            
            if Current_Stage == 3 then
                ms = 0
                local jobdist = #(GetEntityCoords(ped) - vector3(CowShared.Fields[id].x, CowShared.Fields[id].y, CowShared.Fields[id].z))
                if jobdist > 15.0 then
                    DrawMarker(2, CowShared.Fields[id].x, CowShared.Fields[id].y, CowShared.Fields[id].z+6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.0, 3.0, 3.0, 240, 255, 240, 180, true, true, 2, false)
                else 
                    if not milkelimde then
                        if jobdist < 1.8 and not isBussy  then
                            MainShared.HelpNotify(Lan.MilkCow, MainShared.HelpNotifyType, CowShared.Fields[id])
                            if IsControlJustPressed(0, 38) and not isBussy then
                                ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                    if check then
                                        milkelimde = true
                                        TriggerEvent('0r-farming-stop-carry')
                                        isBussy = true 
                                        TaskTurnPedToFaceEntity(ped, cowped, 500)
                                        Wait(500)
                                        MainShared.PlayAnimation(ped, "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 10000, 0)
                                        Wait(10000)
                                        ClearPedTasks(ped)
                                        Wait(750)
                                        TriggerEvent('0r-farming-carry-object', MainShared.ChurnProp["model"], MainShared.ChurnProp["bone"], MainShared.ChurnProp["x"],MainShared.ChurnProp["y"], MainShared.ChurnProp["z"], MainShared.ChurnProp["xR"], MainShared.ChurnProp["yR"] ,MainShared.ChurnProp["zR"], MainShared.ChurnProp["animDict"], MainShared.ChurnProp["animName"])
                                        isBussy = false
                                    else
                                        MainShared.HelpNotify(Lan.DontHaveChurn, "error")
                                    end
                                end, 'churn')
                            end
                        end
                    end
                    if milkelimde then
                        if not isBussy then
                            local coords = GetModelDimensions(GetEntityModel(veh))
                            local back = GetOffsetFromEntityInWorldCoords(veh, 0.0, coords.y-0.5, 0.0)
                            local dist = #(GetEntityCoords(ped) - vector3(back.x, back.y, back.z))
                            DrawMarker(2, back.x, back.y, back.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 240, 255, 240, 180, true, true, 2, false)
                            if dist <= 1.5 then
                                MainShared.HelpNotify(Lan.PutMilkToTruck, MainShared.HelpNotifyType, back)
                                if IsControlJustPressed(0, 38) and not isBussy then
                                    milkelimde = false
                                    isBussy = true
                                    TriggerServerEvent('0r-farming-delete-churn')
                                    cancelCarryAnim()
                                    Wait(50)
                                    MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                    Wait(800)
                                    TriggerEvent('0r-farming-stop-carry')
                                    isBussy = false
                                    ClearCustomBlips()
                                    CreateCustomBlip(CowShared.SellMilkCoord.x, CowShared.SellMilkCoord.y, 67, 2, 0.7, Lan.SellMilkBlipName)
                                    yapilan_veri += 1
                                    MainShared.Notify(string.format(Lan.Maded, yapilan_veri,max_veri), 'primary')
                                end
                            end
                        end
                    end

                    if yapilan_veri == max_veri then
                        Current_Stage += 1
                    end
                end
            end

            if Current_Stage == 4 then
                ms = 0
                DrawMarker(2,CowShared.SellMilkCoord.x, CowShared.SellMilkCoord.y, CowShared.SellMilkCoord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 240, 255, 240, 180, true, true, 2, false)
                local dist = #(GetEntityCoords(ped) - vector3(CowShared.SellMilkCoord.x, CowShared.SellMilkCoord.y, CowShared.SellMilkCoord.z))
                if dist < 4.0 then
                    MainShared.HelpNotify(Lan.SellMilk, MainShared.HelpNotifyType, CowShared.SellMilkCoord)
                    if IsControlJustPressed(0, 38) and IsPedInAnyVehicle(PlayerPedId()) then
                        Current_Stage += 1
                        ClearCustomBlips()
                        MainShared.Notify(Lan.ReturnVehicle, 'primary')
                        CreateCustomBlip(CowShared.VehicleReturnLoc.x, CowShared.VehicleReturnLoc.y, 473, 3, 0.7, Lan.ReturnVEH)
                    end
                end
            end

            if Current_Stage == 5 then
                ms = 0
                DrawMarker(2,CowShared.VehicleReturnLoc.x, CowShared.VehicleReturnLoc.y, CowShared.VehicleReturnLoc.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 240, 255, 240, 180, true, true, 2, false)
                local dist = #(GetEntityCoords(ped) - vector3(CowShared.VehicleReturnLoc.x, CowShared.VehicleReturnLoc.y, CowShared.VehicleReturnLoc.z))
                if dist < 3.0 then
                    MainShared.HelpNotify(Lan.ReturnVeh, MainShared.HelpNotifyType, CowShared.VehicleReturnLoc)
                    if IsControlJustPressed(0, 38) then
                        ClearCustomBlips()
                        TriggerServerEvent('0r-farming-cowjob-finished', id)
                        DeleteVehicle(veh)
                        DeleteEntity(cowped)
                        -- ExecuteCommand('yenile') -- Removed for security (A-09 finding)
                        JobStarted = false
                        Current_Stage = 0 
                        TriggerServerEvent('0r-farming-receive-milk')
                        MainShared.Notify(string.format(Lan.ReceiveMilk, CowShared.MilkBottle), 'primary')
                        Has_HayBale = false
                        break
                    end
                end
            end
            Wait(ms)
        end
    end)
end

local function StartCow(id)
    id = tonumber(id)
    if id == nil then print('[0r-farming:ERR]: Field Id Is Nil') return end

    ESX.TriggerServerCallback('0r-farming-start-cowfield', function(canStart)
        if canStart then
            local vehicle = GetClosestVehicle(CowShared.Fields2[id].x, CowShared.Fields2[id].y, CowShared.Fields2[id].z, 2.0, 0, 127)
            if DoesEntityExist(vehicle) then
                MainShared.Notify(Lan.VehSpawnFull, 'error')
                return
            end
            JobStarted = true
            MainShared.Notify(Lan.JobStarted, 'primary')
            SpawnCowsAndTasks(id)
            TriggerServerEvent('0r-farming-cow-started', id)
        else
            MainShared.Notify(Lan.SomethingWentWrong, 'error')
        end
    end, id)
end RegisterNetEvent('0r-farming-start-cow', StartCow)