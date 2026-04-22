local bekle = false
local MELON_BLIPS = {}
local MELON_OBJECTS = {}
local Yapilan_Veri = 0
local Max_Veri = 0
local youga = 0
CreateThread(function()
    local pedhash = MelonShared.StartPed.hash
    while not HasModelLoaded(pedhash) do
        RequestModel(pedhash)
        Wait(0) 
    end
    local coord = MelonShared.StartPed.coords
    local ped = CreatePed(4, pedhash, coord.x, coord.y, coord.z-1, coord.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(pedhash)

    local melonblip = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite(melonblip, MelonShared.BlipSprite)
    SetBlipColour(melonblip, MelonShared.BlipColour)
    SetBlipScale (melonblip, MelonShared.BlipScale)
    SetBlipAsShortRange(melonblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Lan.MelonBlip)
    EndTextCommandSetBlipName(melonblip)
end)

local function CreateMelonBlip(id)
    for k,v in pairs(MelonShared.Fields[id]) do
        local b = AddBlipForCoord(v.c.x , v.c.y, v.c.z)
        SetBlipSprite(b, 373)
        SetBlipColour(b, 25)
        SetBlipScale(b, 0.5)
        SetBlipAsShortRange(b, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Lan.MelonField)
        EndTextCommandSetBlipName(b)
        table.insert(MELON_BLIPS, b)
    end
end

local function ClearMelonBlips()
    for _,v in pairs(MELON_BLIPS) do 
        RemoveBlip(v)	
    end	
    PUMPKIN_BLIPS = {}
end


RegisterNetEvent('attach-raker', function()
    Prop = "prop_tool_rake"
    PropBone = 28422
    PropPlacement = {
        0.0,
        0.0,
        -0.0300,
        0.0,
        0.0,
        0.0
    }
    local PropBone = PropBone
    local off1, off2, off3, rot1, rot2, rot3 = table.unpack(PropPlacement)
    local Player = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(Player))

    if not HasModelLoaded(Prop) then
        RequestModel(Prop) while not HasModelLoaded(Prop) do Wait(0) end
    end

    prop = CreateObject(joaat(Prop), x, y, z + 0.2, true, true, true)
    attachedProp = prop
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, PropBone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(Prop)
end)

local karpuzelimde = false

local function StartMelonTask(id)
    local function RakerAnim()
        ClearPedTasksImmediately()
        SetEntityHeading(PlayerPedId(), 194.05)
        local anim1 = "anim@amb@drug_field_workers@rake@male_a@base"
        local anim2 = "base"
        RequestAnimDict(anim1)
        while (not HasAnimDictLoaded(anim1)) do
            Wait(0)
        end
        FreezeEntityPosition(PlayerPedId(), true)
        TaskPlayAnim(PlayerPedId(), anim1, anim2, 8.0, -8.0, -1, 1, 0, false, false, false);
        TriggerEvent('attach-raker')
        Wait(2250)
        FreezeEntityPosition(PlayerPedId(), false)
        removeAttachedProp()
        ClearPedTasks(PlayerPedId())
        Yapilan_Veri += 1
        MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
        Wait(500)
        bekle = false
    end

    local function PlantAnim()
        ClearPedTasksImmediately()
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(50)
        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
        Wait(5500)
        FreezeEntityPosition(PlayerPedId(), false)
        ClearPedTasksImmediately(PlayerPedId())
        Yapilan_Veri += 1
        MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
        Wait(500)
        bekle = false
    end

    local function createvehnative(veh)
        if MainShared.UseKeyFunction then
            MainShared.AddVehicleKey(veh)
        end
        SetVehicleColours(veh, math.random(0, 160), math.random(0, 160))
        SetVehicleFuelLevel(veh, 100.0)
        local id = NetworkGetNetworkIdFromEntity(veh)
        SetNetworkIdCanMigrate(id, true)
        SetEntityAsMissionEntity(veh, true, false)
        SetVehicleHasBeenOwnedByPlayer(veh, true)
        SetVehicleNeedsToBeHotwired(veh, false)
        SetModelAsNoLongerNeeded(veh)
        SetVehRadioStation(veh, 'OFF')
    end

    local function WaterAnim()
        removeAttachedProp()
        RequestAnimDict("weapon@w_sp_jerrycan")
        while (not HasAnimDictLoaded("weapon@w_sp_jerrycan")) do
            Wait(0)
        end
        Wait(100)
        attachModel = GetHashKey("prop_wateringcan")
        SetCurrentPedWeapon(PlayerPedId(), 0xA2719263)
        local bone = GetPedBoneIndex(PlayerPedId(), 18905)
        RequestModel(attachModel)
        while not HasModelLoaded(attachModel) do
            Wait(0)
        end
        attachedProp = CreateObject(attachModel, 0.4, 0.4, 0.4, 1, 1, 0)
        SetModelAsNoLongerNeeded(attachModel)
        local x = 0.08
        local y = -0.2
        local z = 0.3
        local xR = -10.0
        local yR = 80.0
        local zR = 90.0
        AttachEntityToEntity(attachedProp, PlayerPedId(), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
        TaskPlayAnim(PlayerPedId(), 'weapon@w_sp_jerrycan', 'fire', 8.0, -8.0, -1, 1, 0, false, false, false);
        local boneIndex = GetPedBoneIndex(PlayerPedId(), 4089)
        UseParticleFxAssetNextCall("core")
        local fx = StartNetworkedParticleFxLoopedOnEntityBone('ent_ray_heli_aprtmnt_water', PlayerPedId(), 0.045, 0, -0.1, 0, 0, 0, boneIndex, 1.0, true, true, true)
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(50)
        Wait(4000)
        StopParticleFxLooped(fx, 0)
        FreezeEntityPosition(PlayerPedId(), false)
        ClearPedTasks(PlayerPedId())
        Yapilan_Veri += 1  
        MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')      
        removeAttachedProp()
        Wait(500)
        bekle = false
    end

    CreateMelonBlip(id)
    Current_Stage = 1
    RequestModel(MelonShared.VehicleModel) while not HasModelLoaded(MelonShared.VehicleModel) do Wait(0) end
    youga = CreateVehicle(MelonShared.VehicleModel, MelonShared.VehLocs[id].x, MelonShared.VehLocs[id].y, MelonShared.VehLocs[id].z, MelonShared.VehLocs[id].w, true, false)
    createvehnative(youga)
    TriggerServerEvent("0r-farming-insert-melon", NetworkGetNetworkIdFromEntity(youga))

    for k,v in pairs(MelonShared.Fields[id]) do
        Max_Veri += 1
    end

    CreateThread(function()
        while JobStarted do
            local ms = 0
            Wait(ms)
            if not bekle then

                if Current_Stage == 1 then
                    ms = 0
                    if not IsPedInAnyVehicle(PlayerPedId()) then
                        for k,v in pairs(MelonShared.Fields[id]) do
                            if not v.b then 
                                if MelonShared.MarkerListener then
                                    DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 0, 215, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                                end
                                if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.7 then
                                    if MelonShared.KeyListener then
                                        MainShared.HelpNotify(Lan.MelonRake, MainShared.HelpNotifyType, v.c)
                                        if IsControlJustPressed(0, 38) then
                                            ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                                if check then
                                                    bekle = true
                                                    v.b = true
                                                    RakerAnim()
                                                else
                                                    MainShared.Notify(Lan.DontHaveRaker, 'error')
                                                end
                                            end, "raker")
                                        end
                                    else
                                        ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                            if check then
                                                bekle = true
                                                v.b = true
                                                RakerAnim()
                                            else
                                                bekle = true
                                                MainShared.Notify(Lan.DontHaveRaker, 'error')
                                                Wait(500)
                                                bekle = false
                                            end
                                        end, "raker")
                                    end
                                end
                            end
                        end
                    end

                    if Max_Veri == Yapilan_Veri then
                        bekle = true
                        Current_Stage += 1
                        Yapilan_Veri = 0
                        Max_Veri = 0
                        for k,v in pairs(MelonShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 2 then
                    ms = 0
                    for k,v in pairs(MelonShared.Fields[id]) do
                        if not v.b then
                            if MelonShared.MarkerListener then
                                DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 0, 215, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                            end
                            if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.75 then
                                if MelonShared.KeyListener then
                                    MainShared.HelpNotify(Lan.MelonPlant, MainShared.HelpNotifyType, v.c)
                                    if IsControlJustPressed(0, 38) then
                                        ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                            if check then
                                                ESX.TriggerServerCallback("0r-farming-check-item2", function(check2)
                                                    if check2 then
                                                        bekle = true
                                                        v.b = true
                                                        PlantAnim()
                                                    else
                                                        MainShared.Notify(Lan.DontHaveMSeed, 'error')
                                                    end
                                                end, "melonseed")
                                            else
                                                MainShared.Notify(Lan.DontHaveShovel, 'error')
                                            end
                                        end, "shovel")
                                    end
                                else
                                    ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                        if check then
                                            ESX.TriggerServerCallback("0r-farming-check-item2", function(check2)
                                                if check2 then
                                                    Wait(100)
                                                    bekle = true
                                                    v.b = true
                                                    PlantAnim()
                                                else
                                                    MainShared.Notify(Lan.DontHaveMSeed, 'error')
                                                end
                                            end, "melonseed")
                                        else
                                            bekle = true
                                            MainShared.Notify(Lan.DontHaveShovel, 'error')
                                            Wait(500)
                                            bekle = false
                                        end
                                    end, "shovel")
                                end
                            end
                        end
                    end

                    if Max_Veri == Yapilan_Veri then
                        bekle = true
                        Current_Stage += 1
                        Yapilan_Veri = 0
                        Max_Veri = 0
                        for k,v in pairs(MelonShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 3 then
                    ms = 0
                    for k,v in pairs(MelonShared.Fields[id]) do
                        if not v.b then
                            if MelonShared.MarkerListener then
                                DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 0, 215, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                            end
                            if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.75 then
                                if MelonShared.KeyListener then
                                    MainShared.HelpNotify(Lan.MelonWater, MainShared.HelpNotifyType, v.c)
                                    if IsControlJustPressed(0, 38) then
                                        ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                            if check then
                                                bekle = true
                                                v.b = true
                                                WaterAnim()
                                            else
                                                MainShared.Notify(Lan.DontHaveWCan, 'error')
                                            end
                                        end, "wateringcan")
                                    end
                                else
                                    ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                        if check then
                                            bekle = true
                                            v.b = true
                                            WaterAnim()
                                        else
                                            bekle = true
                                            MainShared.Notify(Lan.DontHaveWCan, 'error')
                                            Wait(500)
                                            bekle = false
                                        end
                                    end, "wateringcan")
                                end
                            end
                        end
                    end

                    if Max_Veri == Yapilan_Veri then
                        bekle = true
                        Current_Stage += 1
                        Yapilan_Veri = 0
                        Max_Veri = 0
                        for k,v in pairs(MelonShared.Fields[id]) do
                            Wait(30)
                            v.b = false
                            local melon = CreateObject(GetHashKey("prop_veg_crop_03_cab"), v.c.x ,v.c.y,v.c.z-1.25, true, false, false)
                            SetEntityNoCollisionEntity(melon, youga)
                            FreezeEntityPosition(melon, true)
                            MELON_OBJECTS[k] = melon
                            Max_Veri += 1
                            TriggerServerEvent("0r-farming-insert-melon", NetworkGetNetworkIdFromEntity(melon))
                        end
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 4 then
                    ms = 0
                    if not karpuzelimde then
                        for k,v in pairs(MelonShared.Fields[id]) do
                            if not v.b then
                                if MelonShared.MarkerListener then
                                    DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 0, 215, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                                end
                                if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.75 then
                                    if MelonShared.KeyListener then
                                        MainShared.HelpNotify(Lan.MelonHarvest, MainShared.HelpNotifyType, v.c)
                                        if IsControlJustPressed(0, 38) then
                                            ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                                if check then
                                                    bekle = true
                                                    ClearPedTasksImmediately(PlayerPedId())
                                                    TaskTurnPedToFaceEntity(PlayerPedId(), MELON_OBJECTS[k], 1000)
                                                    Wait(1200)
                                                    FreezeEntityPosition(PlayerPedId(), true)
                                                    v.b = true
                                                    Wait(50)
                                                    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                                                    Wait(5500)
                                                    FreezeEntityPosition(PlayerPedId(), false)
                                                    ClearPedTasksImmediately(PlayerPedId())
                                                    karpuzelimde = true
                                                    Wait(500)
                                                    TriggerEvent('0r-farming-carry-object', MainShared.MelonProp["model"], MainShared.MelonProp["bone"], MainShared.MelonProp["x"],MainShared.MelonProp["y"], MainShared.MelonProp["z"], MainShared.MelonProp["xR"], MainShared.MelonProp["yR"] ,MainShared.MelonProp["zR"], MainShared.MelonProp["animDict"], MainShared.MelonProp["animName"])
                                                    DeleteEntity(MELON_OBJECTS[k])
                                                    MainShared.Notify(Lan.PutMelons, 'primary')
                                                    bekle = false
                                                else
                                                    MainShared.Notify(Lan.DontHaveShovel, 'error')
                                                end
                                            end, "shovel")
                                        end
                                    else
                                        ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                            if check then
                                                bekle = true
                                                ClearPedTasksImmediately(PlayerPedId())
                                                TaskTurnPedToFaceEntity(PlayerPedId(), MELON_OBJECTS[k], 1000)
                                                Wait(1200)
                                                FreezeEntityPosition(PlayerPedId(), true)
                                                v.b = true
                                                Wait(50)
                                                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                                                Wait(5500)
                                                FreezeEntityPosition(PlayerPedId(), false)
                                                ClearPedTasksImmediately(PlayerPedId())
                                                karpuzelimde = true
                                                Wait(500)
                                                TriggerEvent('0r-farming-carry-object', MainShared.MelonProp["model"], MainShared.MelonProp["bone"], MainShared.MelonProp["x"],MainShared.MelonProp["y"], MainShared.MelonProp["z"], MainShared.MelonProp["xR"], MainShared.MelonProp["yR"] ,MainShared.MelonProp["zR"], MainShared.MelonProp["animDict"], MainShared.MelonProp["animName"])
                                                DeleteEntity(MELON_OBJECTS[k])
                                                MainShared.Notify(Lan.PutMelons, 'primary')
                                                bekle = false
                                            else
                                                bekle = true
                                                MainShared.Notify(Lan.DontHaveShovel, 'error')
                                                Wait(500)
                                                bekle = false
                                            end
                                        end, "shovel")
                                    end
                                end
                            end
                        end
                    end

                    if karpuzelimde then
                        ms = 0
                        local coords = GetModelDimensions(GetEntityModel(youga))
                        local back = GetOffsetFromEntityInWorldCoords(youga, 0.0, coords.y-MelonShared.vehicleYoffset, 0.0)
                        local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back.x, back.y, back.z))
                        if MelonShared.MarkerListener then
                            DrawMarker(2, back.x, back.y, back.z+0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 0, 255, 0, 180, true, true, 2, false)
                        end
                        if dist < 0.75 then
                            if MelonShared.KeyListener then
                                MainShared.HelpNotify(Lan.MelonPutVehicle, MainShared.HelpNotifyType, back)
                                if IsControlJustPressed(0, 38) then
                                    bekle = true
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                    Wait(1100)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    TriggerEvent('0r-farming-stop-carry')
                                    ClearPedTasks(PlayerPedId())
                                    karpuzelimde = false
                                    Yapilan_Veri += 1
                                    MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
                                    bekle = false
                                end
                            else
                                bekle = true
                                FreezeEntityPosition(PlayerPedId(), true)
                                MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                Wait(1100)
                                FreezeEntityPosition(PlayerPedId(), false)
                                TriggerEvent('0r-farming-stop-carry')
                                ClearPedTasks(PlayerPedId())
                                karpuzelimde = false
                                Yapilan_Veri += 1
                                MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
                                bekle = false
                            end
                        end
                    end

                    if Max_Veri == Yapilan_Veri then
                        bekle = true
                        Current_Stage += 1
                        Yapilan_Veri = 0
                        Max_Veri = 0
                        for k,v in pairs(MelonShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        ClearCustomBlips()
                        Wait(250)
                        bekle = false
                        ClearMelonBlips()
                        CreateCustomBlip(MelonShared.SellCoords.x, MelonShared.SellCoords.y, 272, 2, 0.7, Lan.MelonDrop)
                        MainShared.Notify(Lan.GoSellMelons, 'primary')
                    end
                end

                if Current_Stage == 5 then
                    ms = 0
                    if karpuzelimde then
                        if MelonShared.MarkerListener then
                            DrawMarker(2, MelonShared.SellCoords.x, MelonShared.SellCoords.y, MelonShared.SellCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 0, 255, 0, 180, true, true, 2, false)
                        end
                        local dist = #(GetEntityCoords(PlayerPedId()) - vector3(MelonShared.SellCoords.x, MelonShared.SellCoords.y, MelonShared.SellCoords.z))
                        if dist < 1.0 then
                            if MelonShared.KeyListener then
                                MainShared.HelpNotify(Lan.MelonSell, MainShared.HelpNotifyType, MelonShared.SellCoords)
                                if IsControlJustPressed(0, 38) then
                                    if not IsPedInAnyVehicle(PlayerPedId()) then
                                        Yapilan_Veri += 1
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                        Wait(1100)
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        TriggerEvent('0r-farming-stop-carry')
                                        MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
                                        karpuzelimde = false
                                    end
                                end
                            else
                                if not IsPedInAnyVehicle(PlayerPedId()) then
                                    Yapilan_Veri += 1
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                    Wait(1100)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    TriggerEvent('0r-farming-stop-carry')
                                    MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
                                    karpuzelimde = false
                                end
                            end
                        end
                    end

                    if not karpuzelimde then
                        if #(vector3(MelonShared.SellCoords.x, MelonShared.SellCoords.y, MelonShared.SellCoords.z) - GetEntityCoords(PlayerPedId())) < 20.0 and not IsPedInAnyVehicle(PlayerPedId()) then
                            local coords = GetModelDimensions(GetEntityModel(youga))
                            local back = GetOffsetFromEntityInWorldCoords(youga, 0.0, coords.y-MelonShared.vehicleYoffset, 0.0)
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back.x, back.y, back.z))
                            if MelonShared.MarkerListener then
                                DrawMarker(2, back.x, back.y, back.z+0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 0, 255, 0, 180, true, true, 2, false)
                            end
                            if dist < 0.75 then
                                if MelonShared.KeyListener then
                                    MainShared.HelpNotify(Lan.MelonGet, MainShared.HelpNotifyType, back)
                                    if IsControlJustPressed(0, 38) then
                                        bekle = true
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        MainShared.PlayAnimation(PlayerPedId(), "mini@repair", "fixing_a_player", 1700)
                                        Wait(1800)
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        ClearPedTasks(PlayerPedId())
                                        Wait(100)
                                        TriggerEvent('0r-farming-carry-object', MainShared.MelonProp["model"], MainShared.MelonProp["bone"], MainShared.MelonProp["x"],MainShared.MelonProp["y"], MainShared.MelonProp["z"], MainShared.MelonProp["xR"], MainShared.MelonProp["yR"] ,MainShared.MelonProp["zR"], MainShared.MelonProp["animDict"], MainShared.MelonProp["animName"])
                                        karpuzelimde = true
                                        bekle = false
                                    end
                                else
                                    bekle = true
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    MainShared.PlayAnimation(PlayerPedId(), "mini@repair", "fixing_a_player", 1700)
                                    Wait(1800)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    ClearPedTasks(PlayerPedId())
                                    Wait(100)
                                    TriggerEvent('0r-farming-carry-object', MainShared.MelonProp["model"], MainShared.MelonProp["bone"], MainShared.MelonProp["x"],MainShared.MelonProp["y"], MainShared.MelonProp["z"], MainShared.MelonProp["xR"], MainShared.MelonProp["yR"] ,MainShared.MelonProp["zR"], MainShared.MelonProp["animDict"], MainShared.MelonProp["animName"])
                                    karpuzelimde = true
                                    bekle = false
                                end
                            end
                        end
                    end

                    if Max_Veri == Yapilan_Veri then
                        ClearCustomBlips()
                        bekle = true
                        Current_Stage += 1
                        Yapilan_Veri = 0
                        Max_Veri = 0
                        for k,v in pairs(MelonShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        Wait(250)
                        CreateCustomBlip(MelonShared.VehicleReturnLoc.x, MelonShared.VehicleReturnLoc.y, 272, 2, 0.7, Lan.MelonBack)
                        MainShared.Notify(Lan.MelonComeBack, 'primary')
                        bekle = false
                    end
                end

                if Current_Stage == 6 then
                    ms = 0
                    if MelonShared.MarkerListener then
                        DrawMarker(2,MelonShared.VehicleReturnLoc.x, MelonShared.VehicleReturnLoc.y, MelonShared.VehicleReturnLoc.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 0, 255, 0, 180, true, true, 2, false)
                    end
                    local dist = #(GetEntityCoords(PlayerPedId()) - vector3(MelonShared.VehicleReturnLoc.x, MelonShared.VehicleReturnLoc.y, MelonShared.VehicleReturnLoc.z))
                    if dist < 4.0 then
                        if MelonShared.KeyListener then
                            MainShared.HelpNotify(Lan.MelonFinish, MainShared.HelpNotifyType, MelonShared.VehicleReturnLoc)
                            if IsControlJustPressed(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId()) then
                                    local money = MelonShared.FinishMoney
                                    MainShared.Notify(string.format(Lan.Payment, money), 'primary')
                                    TriggerServerEvent('0r-farming-melonjob-finished', id, money)
                                    TriggerServerEvent('0r-farming-receive-melon')
                                    MainShared.Notify(string.format(Lan.ReceiveMelon, MelonShared.CuttedMelon), 'primary')
                                    DeleteVehicle(youga)
                                    MainShared.ResetClothe()
                                    JobStarted = false
                                    Current_Stage = 0
                                    ClearCustomBlips()
                                    break
                                end
                            end
                        else
                            if IsPedInAnyVehicle(PlayerPedId()) then
                                TriggerServerEvent('0r-farming-melonjob-finished', id)
                                TriggerServerEvent('0r-farming-receive-melon')
                                MainShared.Notify(string.format(Lan.ReceiveMelon, MelonShared.CuttedMelon), 'primary')
                                DeleteVehicle(youga)
                                MainShared.ResetClothe()
                                JobStarted = false
                                Current_Stage = 0
                                ClearCustomBlips()
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function StartMelon(id)
    id = tonumber(id)
    if id == nil then print('[0r-farming:ERR]: Field Id Is Nil') return end
    ESX.TriggerServerCallback('0r-farming-start-melonfield', function(canStart)
        if canStart then
            JobStarted = true
            MainShared.Notify(Lan.JobStarted, 'primary')
            StartMelonTask(id)
            TriggerServerEvent('0r-farming-melon-started', id)
        else
            MainShared.Notify(Lan.SomethingWentWrong, 'error')
        end
    end, id)
end RegisterNetEvent('0r-farming-start-melon', StartMelon)