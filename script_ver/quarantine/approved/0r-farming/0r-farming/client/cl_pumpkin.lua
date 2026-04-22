local bekle = false
local PUMPKIN_BLIPS = {}
local PUMKIN_OBJECTS = {}
local Yapilan_Veri = 0
local Max_Veri = 0
local youga = 0
CreateThread(function()
    local pedhash = PumpkinShared.StartPed.hash
    while not HasModelLoaded(pedhash) do
        RequestModel(pedhash)
        Wait(0) 
    end
    local coord = PumpkinShared.StartPed.coords
    local ped = CreatePed(4, pedhash, coord.x, coord.y, coord.z-1, coord.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(pedhash)

    local pumpkinblip = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite(pumpkinblip, PumpkinShared.BlipSprite)
    SetBlipColour(pumpkinblip, PumpkinShared.BlipColour)
    SetBlipScale (pumpkinblip, PumpkinShared.BlipScale)
    SetBlipAsShortRange(pumpkinblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Lan.PumpkinBlip)
    EndTextCommandSetBlipName(pumpkinblip)
end)

local function CreatePumpkinBlip(id)
    for k,v in pairs(PumpkinShared.Fields[id]) do
        local b = AddBlipForCoord(v.c.x , v.c.y, v.c.z)
        SetBlipSprite(b, 373)
        SetBlipColour(b, 47)
        SetBlipScale(b, 0.5)
        SetBlipAsShortRange(b, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Lan.PumpkinField)
        EndTextCommandSetBlipName(b)
        table.insert(PUMPKIN_BLIPS, b)
    end
end

local function ClearPBlips()
    for _,v in pairs(PUMPKIN_BLIPS) do 
        RemoveBlip(v)	
    end	
    PUMPKIN_BLIPS = {}
end

local karpuzelimde = false

RegisterNetEvent('attach-pumpkin', function()
    Prop = "prop_veg_crop_03_pump"
    PropBone = 28422
    PropPlacement = {
        0.0200,
        0.0600,
        -0.1200,
        0.0,
        0.0,
        0.0
    }
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
    SetEntityCollision(attachedProp, false, true)
end)

local function StartPumpkinTask(id)
    local function RakerAnim()
        ClearPedTasksImmediately(PlayerPedId())
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
    
    local function PumpkinAnim()
        ClearPedTasksImmediately(PlayerPedId())
        local anim1 = "missfbi4prepp1"
        local anim2 = "idle"
        RequestAnimDict(anim1)
        while (not HasAnimDictLoaded(anim1)) do
            Wait(0)
        end
        TaskPlayAnim(PlayerPedId(), anim1, anim2, 8.0, -8.0, -1, 49, 0, false, false, false);
        TriggerEvent('attach-pumpkin')
    end

    local function PumkinAnimClear()
        removeAttachedProp()
        ClearPedTasks(PlayerPedId())
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
        attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
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

    CreatePumpkinBlip(id)
    Current_Stage = 1
    RequestModel(PumpkinShared.VehicleModel) while not HasModelLoaded(PumpkinShared.VehicleModel) do Wait(0) end
    youga = CreateVehicle(PumpkinShared.VehicleModel, PumpkinShared.VehLocs[id].x, PumpkinShared.VehLocs[id].y, PumpkinShared.VehLocs[id].z, PumpkinShared.VehLocs[id].w, true, false)
    createvehnative(youga)
    TriggerServerEvent("0r-farming-insert-pumpkin", NetworkGetNetworkIdFromEntity(youga))

    for k,v in pairs(PumpkinShared.Fields[id]) do
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
                        for k,v in pairs(PumpkinShared.Fields[id]) do
                            if not v.b then 
                                if PumpkinShared.MarkerListener then
                                    DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 230, 138, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                                end
                                if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.7 then
                                    if PumpkinShared.KeyListener then
                                        MainShared.HelpNotify(Lan.PumpkinRake, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
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
                        for k,v in pairs(PumpkinShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 2 then
                    ms = 0
                    for k,v in pairs(PumpkinShared.Fields[id]) do
                        if not v.b then
                            if PumpkinShared.MarkerListener then
                                DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 230, 138, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                            end
                            if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.75 then
                                if PumpkinShared.KeyListener then
                                    MainShared.HelpNotify(Lan.PumpkinPlant, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
                                    if IsControlJustPressed(0, 38) then
                                        ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                            if check then
                                                ESX.TriggerServerCallback("0r-farming-check-item2", function(check2)
                                                    if check2 then
                                                        bekle = true
                                                        v.b = true
                                                        PlantAnim()
                                                    else
                                                        MainShared.Notify(Lan.DontHavePSeed, 'error')
                                                    end
                                                end, "pumpkinseed")
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
                                                    bekle = true
                                                    v.b = true
                                                    PlantAnim()
                                                else
                                                    MainShared.Notify(Lan.DontHavePSeed, 'error')
                                                end
                                            end, "pumpkinseed")
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
                        for k,v in pairs(PumpkinShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 3 then
                    ms = 0
                    for k,v in pairs(PumpkinShared.Fields[id]) do
                        if not v.b then
                            if PumpkinShared.MarkerListener then
                                DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 230, 138, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                            end
                            if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.75 then
                                if PumpkinShared.KeyListener then
                                    MainShared.HelpNotify(Lan.PumpkinWater, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
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
                        for k,v in pairs(PumpkinShared.Fields[id]) do
                            Wait(30)
                            v.b = false
                            local pumkin = CreateObject(GetHashKey("prop_veg_crop_03_pump"), v.c.x, v.c.y, v.c.z-1.05, true, false, false)
                            FreezeEntityPosition(pumkin, true)
                            PUMKIN_OBJECTS[k] = pumkin
                            Max_Veri += 1
                            TriggerServerEvent("0r-farming-insert-pumkin", NetworkGetNetworkIdFromEntity(pumkin))
                        end
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 4 then
                    ms = 0
                    if not karpuzelimde then
                        for k,v in pairs(PumpkinShared.Fields[id]) do
                            if not v.b then
                                if PumpkinShared.MarkerListener then
                                    DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.4, 0.4, 0.4, 230, 138, 0, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                                end
                                if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.75 then
                                    if PumpkinShared.KeyListener then
                                        MainShared.HelpNotify(Lan.PumpkinHarvest, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
                                        if IsControlJustPressed(0, 38) then
                                            ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                                if check then
                                                    bekle = true
                                                    ClearPedTasksImmediately(PlayerPedId())
                                                    TaskTurnPedToFaceEntity(PlayerPedId(), PUMKIN_OBJECTS[k], 1000)
                                                    Wait(1200)
                                                    FreezeEntityPosition(PlayerPedId(), true)
                                                    v.b = true
                                                    Wait(50)
                                                    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                                                    Wait(5500)
                                                    DeleteEntity(PUMKIN_OBJECTS[k])
                                                    FreezeEntityPosition(PlayerPedId(), false)
                                                    PumpkinAnim()
                                                    karpuzelimde = true
                                                    Wait(500)
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
                                                TaskTurnPedToFaceEntity(PlayerPedId(), PUMKIN_OBJECTS[k], 1000)
                                                Wait(1200)
                                                FreezeEntityPosition(PlayerPedId(), true)
                                                v.b = true
                                                Wait(50)
                                                TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                                                Wait(5500)
                                                DeleteEntity(PUMKIN_OBJECTS[k])
                                                FreezeEntityPosition(PlayerPedId(), false)
                                                PumpkinAnim()
                                                karpuzelimde = true
                                                Wait(500)
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
                        local back = GetOffsetFromEntityInWorldCoords(youga, 0.0, coords.y-PumpkinShared.vehicleYoffset, 0.0)
                        local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back.x, back.y, back.z))
                        if PumpkinShared.MarkerListener then
                            DrawMarker(2, back.x, back.y, back.z+0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 230, 138, 0, 180, true, true, 2, false)
                        end
                        if dist < 0.75 then
                            if PumpkinShared.KeyListener then
                                MainShared.HelpNotify(Lan.PumpkinPutVehicle, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
                                if IsControlJustPressed(0, 38) then
                                    bekle = true
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                    Wait(1100)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    PumkinAnimClear()
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
                                PumkinAnimClear()
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
                        for k,v in pairs(PumpkinShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        ClearCustomBlips()
                        Wait(250)
                        ClearPBlips()
                        CreateCustomBlip(PumpkinShared.SellCoords.x, PumpkinShared.SellCoords.y, 272, 47, 0.7, Lan.PumpkinDrop)
                        MainShared.Notify(Lan.GoSellPumpkins, 'primary')
                        bekle = false
                    end
                end

                if Current_Stage == 5 then
                    ms = 0
                    if karpuzelimde then
                        if PumpkinShared.MarkerListener then
                            DrawMarker(2,PumpkinShared.SellCoords.x, PumpkinShared.SellCoords.y, PumpkinShared.SellCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.35, 230, 138, 0, 180, true, true, 2, false)
                        end
                       
                        local dist = #(GetEntityCoords(PlayerPedId()) - vector3(PumpkinShared.SellCoords.x, PumpkinShared.SellCoords.y, PumpkinShared.SellCoords.z))
                        if dist < 1.0 then
                            if PumpkinShared.KeyListener then
                                MainShared.HelpNotify(Lan.PumpkinSell, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
                                if IsControlJustPressed(0, 38) then
                                    if not IsPedInAnyVehicle(PlayerPedId()) then
                                        Yapilan_Veri += 1
                                        MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
                                        karpuzelimde = false
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                        Wait(1100)
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        PumkinAnimClear()
                                    end
                                end
                            else
                                if not IsPedInAnyVehicle(PlayerPedId()) then
                                    Yapilan_Veri += 1
                                    MainShared.Notify(string.format(Lan.Maded, Yapilan_Veri,Max_Veri), 'primary')
                                    karpuzelimde = false
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    MainShared.PlayAnimation(PlayerPedId(), "anim@heists@narcotics@trash", "throw_ranged_a", 1000)
                                    Wait(1100)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    PumkinAnimClear()
                                end
                            end
                        end
                    end

                    if not karpuzelimde then
                        if #(vector3(PumpkinShared.SellCoords.x, PumpkinShared.SellCoords.y, PumpkinShared.SellCoords.z) - GetEntityCoords(PlayerPedId())) < 20.0 and not IsPedInAnyVehicle(PlayerPedId()) then
                            local coords = GetModelDimensions(GetEntityModel(youga))
                            local back = GetOffsetFromEntityInWorldCoords(youga, 0.0, coords.y-PumpkinShared.vehicleYoffset, 0.0)
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back.x, back.y, back.z))
                            if PumpkinShared.MarkerListener then
                                DrawMarker(2, back.x, back.y, back.z+0.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 230, 138, 0, 180, true, true, 2, false)
                            end
                            if dist < 0.75 then
                                if PumpkinShared.KeyListener then
                                    MainShared.HelpNotify(Lan.PumpkinGet, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
                                    if IsControlJustPressed(0, 38) then
                                        bekle = true
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        MainShared.PlayAnimation(PlayerPedId(), "mini@repair", "fixing_a_player", 1700)
                                        Wait(1800)
                                        FreezeEntityPosition(PlayerPedId(), false)
                                        PumpkinAnim()
                                        karpuzelimde = true
                                        bekle = false
                                    end
                                else
                                    bekle = true
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    MainShared.PlayAnimation(PlayerPedId(), "mini@repair", "fixing_a_player", 1700)
                                    Wait(1800)
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    PumpkinAnim()
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
                        for k,v in pairs(PumpkinShared.Fields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        Wait(250)
                        CreateCustomBlip(PumpkinShared.VehicleReturnLoc.x, PumpkinShared.VehicleReturnLoc.y, 272, 2, 0.7, Lan.PumpkinBack)
                        MainShared.Notify(Lan.PumpkinComeBack, 'primary')
                        bekle = false
                    end
                end

                if Current_Stage == 6 then
                    ms = 0
                    if PumpkinShared.MarkerListener then
                        DrawMarker(2,PumpkinShared.VehicleReturnLoc.x, PumpkinShared.VehicleReturnLoc.y, PumpkinShared.VehicleReturnLoc.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 230, 138, 0, 180, true, true, 2, false)
                    end
                    local dist = #(GetEntityCoords(PlayerPedId()) - vector3(PumpkinShared.VehicleReturnLoc.x, PumpkinShared.VehicleReturnLoc.y, PumpkinShared.VehicleReturnLoc.z))
                    if dist < 4.0 then
                        if PumpkinShared.KeyListener then
                            MainShared.HelpNotify(Lan.PumpkinFinish, MainShared.HelpNotifyType, GetEntityCoords(PlayerPedId()))
                            if IsControlJustPressed(0, 38) then
                                if IsPedInAnyVehicle(PlayerPedId()) then
                                    TriggerServerEvent('0r-farming-pumpkinjob-finished', id)
                                    TriggerServerEvent('0r-farming-receive-pumpkin')
                                    MainShared.Notify(string.format(Lan.ReceivePumpkin, PumpkinShared.CuttedPumpkin), 'primary')
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
                                local money = PumpkinShared.FinishMoney
                                MainShared.Notify(string.format(Lan.Payment, money), 'primary')
                                TriggerServerEvent('0r-farming-pumpkinjob-finished', id, money)
                                TriggerServerEvent('0r-farming-receive-pumpkin')
                                MainShared.Notify(string.format(Lan.ReceivePumpkin, PumpkinShared.CuttedPumpkin), 'primary')
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

local function StartPumpkin(id)
    id = tonumber(id)
    if id == nil then print('[0r-farming:ERR]: Field Id Is Nil') return end
    ESX.TriggerServerCallback('0r-farming-start-pumpkinfield', function(canStart)
        if canStart then
            JobStarted = true
            MainShared.Notify(Lan.JobStarted, 'primary')
            StartPumpkinTask(id)
            TriggerServerEvent('0r-farming-pumpkin-started', id)
        else
            MainShared.Notify(Lan.SomethingWentWrong, 'error')
        end
    end, id)
end RegisterNetEvent('0r-farming-start-pumpkin', StartPumpkin)