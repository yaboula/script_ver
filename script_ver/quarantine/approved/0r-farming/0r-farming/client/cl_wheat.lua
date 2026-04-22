CreateThread(function()
    local pedhash = WheatShared.StartPed.hash
    while not HasModelLoaded(pedhash) do
        RequestModel(pedhash)
        Wait(0) 
    end
    local coord = WheatShared.StartPed.coords
    local ped = CreatePed(4, pedhash, coord.x, coord.y, coord.z-1, coord.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(pedhash)
    
    local wheatblip = AddBlipForCoord(coord.x, coord.y, coord.z)
    SetBlipSprite(wheatblip, WheatShared.BlipSprite)
    SetBlipColour(wheatblip, WheatShared.BlipColour)
    SetBlipScale(wheatblip, WheatShared.BlipScale)
    SetBlipAsShortRange(wheatblip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Lan.WheatBlip)
    EndTextCommandSetBlipName(wheatblip)
end)

local Max_Veri = 0
local Yapilan_Veri = 0
local Balya_Count = 0
local Balya_Tablosu = {}

local WHEAT_BLIPS = {}
local tractor = 0
local harvester = 0
local raker = 0
local trailer = 0
local WHEAT_OBJECTS = {}
local OLUSTURULAN_BALYA = 0
local BALES_ON_TRAILER = {}

local function ClearWheatBlips()
    for _,v in pairs(WHEAT_BLIPS) do 
        RemoveBlip(v)	
    end	
    WHEAT_BLIPS = {}
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        ClearWheatBlips()
        if raker ~= 0 then
            DeleteVehicle(raker)
        end

        if harvester ~= 0 then
            DeleteVehicle(harvester)
        end

        if tractor ~= 0 then
            DeleteVehicle(tractor)
        end
        
        if trailer ~= 0 then
            DeleteVehicle(trailer)
        end

        for _,v in pairs(BALES_ON_TRAILER) do
            if DoesEntityExist(v) then 
                DeleteEntity(v)
            end 
            BALES_ON_TRAILER = {}
        end

        for k,v in pairs(WHEAT_OBJECTS) do 
            if DoesEntityExist(v) then 
                DeleteEntity(v)
            end 
            WHEAT_OBJECTS = {}
        end

        for k,v in pairs(Balya_Tablosu) do
            if DoesEntityExist(v) then 
                DeleteEntity(v)
            end 
            Balya_Tablosu = {}
        end
	end
end)

local function CreateWheatBlip(id)
    for k,v in pairs(WheatShared.WheatFields[id]) do
        local b = AddBlipForCoord(v.c.x , v.c.y, v.c.z)
        SetBlipSprite(b, 373)
        SetBlipColour(b, 46)
        SetBlipScale(b, 0.5)
        SetBlipAsShortRange(b, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString('Wheat')
        EndTextCommandSetBlipName(b)
        table.insert(WHEAT_BLIPS, b)
    end
end

local function createvehnative(veh, tractor)
    SetVehicleColours(veh, math.random(0, 160), math.random(0, 160))
    if tractor then
        SetPedIntoVehicle(PlayerPedId(), veh, -1)
        NetworkFadeInEntity(veh, true, true)
    end
    SetVehicleFuelLevel(veh, 100.0)
    local id = NetworkGetNetworkIdFromEntity(veh)
    SetNetworkIdCanMigrate(id, true)
    SetEntityAsMissionEntity(veh, true, false)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetModelAsNoLongerNeeded(veh)
    SetVehRadioStation(veh, 'OFF')
end

local function JumpAnim()
    RequestAnimDict('amb@prop_human_movie_bulb@exit')
    while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do 
        RequestAnimDict("amb@prop_human_movie_bulb@exit")
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
    TaskJump(PlayerPedId(), false, false, false)
end

local bekle = false
local balya_elimde = false
local elimdeki_balya = 0
local KOYULANBALYA = 1

if WheatShared.HarvesterEasyMode then 
	local deger = 0
	local ekle = 0.05
	local Tersteker = false
	CreateThread(function()
		while true do 
            Wait(1000)
            if Current_Stage == 3 then
                if (IsPedInVehicle(PlayerPedId(), harvester, false)) then
                    Tersteker = true
                else
                    Tersteker = false
                end	
            elseif Tersteker then 
                Tersteker = false	
            else
                Wait(2500)
            end
		end
	end)
	CreateThread(function()
		while true do 
            Wait(0)
			if Tersteker then
				DisableControlAction(0, 59, true)
				if IsControlPressed(0, 34)   then
					deger = deger - ekle
				elseif deger < 0.0 then 
					deger = 0.0
				end

				if IsControlPressed(0, 30) then
					deger = deger + ekle
				elseif deger > 0.0 then 
					deger = 0.0
				end 

				if deger < -1.0 then deger =  -1.0 elseif  deger > 1.0 then  deger = 1.0 end
				SetVehicleSteerBias(harvester, deger)
			else
				Wait(1000)
			end
		end
	end)
end

local function StartWheatTask(id)
    local function SeedP()
        RequestAnimDict("weapon@w_sp_jerrycan")
        while (not HasAnimDictLoaded("weapon@w_sp_jerrycan")) do
            Wait(0)
        end
        TaskPlayAnim(PlayerPedId(), 'weapon@w_sp_jerrycan', 'fire', 8.0, -8.0, -1, 1, 0, false, false, false);
        TriggerEvent('attach-wheat-bag')
        local boneIndex = GetPedBoneIndex(PlayerPedId(), 4089)
        UseParticleFxAssetNextCall("core")
        local fx = StartNetworkedParticleFxLoopedOnEntityBone('ent_sht_beer_barrel', PlayerPedId(), 0.045, 0, -0.1, 0, 0, 0, boneIndex, 1.0, true, true, true)
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(1250)
        FreezeEntityPosition(PlayerPedId(), false)
        StopParticleFxLooped(fx, 0)
        removeAttachedProp()
        ClearPedTasks(PlayerPedId())
        Yapilan_Veri += 1
        Wait(500)
        bekle = false
    end

    CreateWheatBlip(id)
    Current_Stage = 1
    RequestModel('tractor2') while not HasModelLoaded('tractor2') do Wait(0) end
    RequestModel('tractor3') while not HasModelLoaded('tractor3') do Wait(0) end
    RequestModel('raketrailer') while not HasModelLoaded('raketrailer') do Wait(0) end
    RequestModel('baletrailer') while not HasModelLoaded('baletrailer') do Wait(0) end
    tractor = CreateVehicle('tractor2', WheatShared.TractorSpawnPoint.x, WheatShared.TractorSpawnPoint.y, WheatShared.TractorSpawnPoint.z, WheatShared.TractorSpawnPoint.w, true, false)
    createvehnative(tractor, true)
    harvester = CreateVehicle('tractor3', WheatShared.HarvesterSpawnPoint[id].x, WheatShared.HarvesterSpawnPoint[id].y, WheatShared.HarvesterSpawnPoint[id].z, WheatShared.HarvesterSpawnPoint[id].w, true, false)
    SetEntityRotation(harvester, 0, 0, 180)
    createvehnative(harvester, false)
    raker = CreateVehicle('raketrailer', WheatShared.RakerSpawnPoint[id].x, WheatShared.RakerSpawnPoint[id].y, WheatShared.RakerSpawnPoint[id].z, WheatShared.RakerSpawnPoint[id].w, true, false)
    createvehnative(raker, false)
    trailer = CreateVehicle('baletrailer', WheatShared.TrailerSpawnPoint[id].x, WheatShared.TrailerSpawnPoint[id].y, WheatShared.TrailerSpawnPoint[id].z, WheatShared.TrailerSpawnPoint[id].w, true, false)
    createvehnative(trailer, false)

    for k,v in pairs(WheatShared.WheatFields[id]) do
        Max_Veri +=1
    end

    if MainShared.UseKeyFunction then
        MainShared.AddVehicleKey(tractor)
        Wait(100)
        MainShared.AddVehicleKey(harvester)
    end
    
    TriggerServerEvent("0r-farming-insert", NetworkGetNetworkIdFromEntity(tractor))
    TriggerServerEvent("0r-farming-insert", NetworkGetNetworkIdFromEntity(harvester))
    TriggerServerEvent("0r-farming-insert", NetworkGetNetworkIdFromEntity(raker))
    TriggerServerEvent("0r-farming-insert", NetworkGetNetworkIdFromEntity(trailer))

    CreateThread(function()
        while JobStarted do
            local ms = 0
            Wait(ms)
            if not bekle then
                if Current_Stage == 1 then
                    ms = 0
                    for k,v in pairs(WheatShared.WheatFields[id]) do
                        if not v.b and Current_Stage == 1 then
                            DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                            if #(GetEntityCoords(tractor) - vector3(v.c.x ,v.c.y,v.c.z)) <= 1.5 then
                                if IsVehicleAttachedToTrailer(tractor) then
                                    v.b = true
                                    Yapilan_Veri += 1
                                end
                            end
                        end
                    end

                    if Max_Veri == Yapilan_Veri then
                        bekle = true
                        Yapilan_Veri = 0
                        Max_Veri = 0
                        for k,v in pairs(WheatShared.WheatFields[id]) do
                            v.b = false
                            Max_Veri += 1
                        end
                        Current_Stage += 1
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 2 then
                    ms = 0
                    if not IsPedInAnyVehicle(PlayerPedId()) then
                        for k,v in pairs(WheatShared.WheatFields[id]) do
                            if not v.b then 
                                DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                                if #(GetEntityCoords(PlayerPedId()) - vector3(v.c.x ,v.c.y,v.c.z)) <= 0.7 then
                                    MainShared.HelpNotify(Lan.WheatPlant, MainShared.HelpNotifyType, v.c)
                                    if IsControlJustPressed(0, 38) then
                                        ESX.TriggerServerCallback("0r-farming-check-item", function(check)
                                            if check then
                                                bekle = true
                                                v.b = true
                                                SeedP()
                                            else
                                                MainShared.Notify(Lan.DontHaveWheatSeed, 'error')
                                            end
                                        end, "wheatseed")
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
                        for k,v in pairs(WheatShared.WheatFields[id]) do
                            v.b = false
                            local wheat = CreateObject(GetHashKey("prop_veg_crop_04"), v.c.x ,v.c.y,v.c.z - 2.5, true, false, false)
                            FreezeEntityPosition(wheat, true)
                            WHEAT_OBJECTS[k] = wheat
                            Max_Veri += 1
                            TriggerServerEvent("0r-farming-insert", NetworkGetNetworkIdFromEntity(wheat))
                        end
                        Wait(250)
                        bekle = false
                    end
                end

                if Current_Stage == 3 then
                    ms = 0
                    for k,v in pairs(WheatShared.WheatFields[id]) do
                        if not v.b then
                            DrawMarker(2, v.c.x ,v.c.y,v.c.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 0, 0.10, 0, 0, 0, 0.0, 0)
                            if #(GetEntityCoords(harvester) - vector3(v.c.x ,v.c.y,v.c.z)) <= 1.5 then
                                v.b = true
                                Yapilan_Veri += 1
                                DeleteEntity(WHEAT_OBJECTS[k])
                                Balya_Count +=1
                            end
                        end
                    end

                    if Balya_Count == 8 and OLUSTURULAN_BALYA ~= 8 then
                        Balya_Count = 0
                        local coords = GetModelDimensions(GetEntityModel(harvester))
                        local back = GetOffsetFromEntityInWorldCoords(harvester, 0.0, coords.y-1.0)
                        local balya = CreateObject(GetHashKey("prop_haybale_03"), back.x , back.y, back.z, true, false, false)
                        PlaceObjectOnGroundProperly(balya)
                        SetEntityNoCollisionEntity(balya, harvester)
                        FreezeEntityPosition(balya, true)
                        Balya_Tablosu[#Balya_Tablosu+1] = balya
                        OLUSTURULAN_BALYA +=1
                        TriggerServerEvent("0r-farming-insert", NetworkGetNetworkIdFromEntity(balya))
                    end

                    if Max_Veri == Yapilan_Veri then
                        Current_Stage += 1
                        Yapilan_Veri = 0
                        Max_Veri = 0
                    end
                end

                if Current_Stage == 4 then
                    ms = 0 
                    if not balya_elimde then
                        for k, data in pairs(Balya_Tablosu) do
                            local v = GetEntityCoords(data)
                            DrawMarker(2, v.x ,v.y,v.z+1.5, 0, 0.50, 0, 0, 0, 0, 0.75, 0.75, 0.75, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)
                            local balyadist = #(GetEntityCoords(PlayerPedId()) - vector3(v.x, v.y, v.z))
                            if balyadist < 1.25 then
                                balya_elimde = true
                                table.remove(Balya_Tablosu, k)
                                elimdeki_balya = data
                                
                                FreezeEntityPosition(elimdeki_balya, false)
                                local boneIndex = GetPedBoneIndex(PlayerPedId(), 57005)
                                AttachEntityToEntity(elimdeki_balya, PlayerPedId(), boneIndex, 0.75, 0.75, 0.0, 0.0, 0.0, 100.0, true, true, false, true, 1, true)
                                loadAnimDict('anim@heists@box_carry@')
                                Wait(50)
                                TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "walk", 1.0, 1.0, -1, 1 | 16 | 32, 0.0, 0, 0, 0)
                            end
                        end
                    else
                        local coords = GetModelDimensions(GetEntityModel(trailer))
                        if KOYULANBALYA == 1 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x-0.5, coords.y+1.2, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+0.93, coords.y+1.1, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                            end
                        elseif KOYULANBALYA == 2 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x-0.5, coords.y+2.99, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+0.93, coords.y+2.9, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                            end
                        elseif KOYULANBALYA == 3 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x-0.5, coords.y+4.6, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+0.93, coords.y+4.7, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                            end
                        elseif KOYULANBALYA == 4 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x-0.5, coords.y+6.3, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+0.93, coords.y+6.45, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                            end
                        elseif KOYULANBALYA == 5 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x+3.4, coords.y+1.2, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+1.9, coords.y+1.1, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                            end
                        elseif KOYULANBALYA == 6 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x+3.4, coords.y+2.99, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+1.9, coords.y+2.9, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                            end
                        elseif KOYULANBALYA == 7 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x+3.4, coords.y+4.6, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+1.9, coords.y+4.7, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                            end
                        elseif KOYULANBALYA == 8 then
                            local back1 = GetOffsetFromEntityInWorldCoords(trailer, coords.x+3.4, coords.y+6.3, coords.z+0.7)
                            DrawMarker(2, back1.x ,back1.y,back1.z, 0, 0.50, 0, 0, 0, 0, 0.5, 0.5, 0.5, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(back1.x ,back1.y,back1.z))
                            if dist < 1.0 then
                                RequestAnimDict('amb@prop_human_movie_bulb@exit')
                                while not HasAnimDictLoaded("amb@prop_human_movie_bulb@exit") do RequestAnimDict("amb@prop_human_movie_bulb@exit")
                                    Wait(0)
                                end
                                TaskPlayAnim(PlayerPedId(), 'amb@prop_human_movie_bulb@exit', 'exit', 8.0, 8.0, -1, 48, 1, false, false, false)
                                Wait(200)
                                DetachEntity(elimdeki_balya)
                                KOYULANBALYA += 1
                                balya_elimde = false
                                
                                AttachEntityToEntity(elimdeki_balya, trailer, 0, coords.x+1.9, coords.y+6.45, coords.z+2.3, 0.0, 0.0, 0.0, false, false, true, false, 0, true)
                                SetEntityNoCollisionEntity(elimdeki_balya, trailer)
                                SetEntityHeading(elimdeki_balya, GetEntityHeading(trailer))
                                BALES_ON_TRAILER[#BALES_ON_TRAILER+1] = elimdeki_balya
                                Current_Stage += 1
                                KOYULANBALYA = 0
                                MainShared.Notify(Lan.DriveToDeliverLoc, 'primary')
                                ClearCustomBlips()
                                CreateCustomBlip(WheatShared.DropLocation.x, WheatShared.DropLocation.y, 569, 3, 0.7, Lan.WheatDrop)
                            end
                        end
                    end
                end

                if Current_Stage == 5 then
                    ms = 0
                    local bir = GetEntityCoords(trailer)
                    local iki = vector3(WheatShared.DropLocation.x, WheatShared.DropLocation.y, WheatShared.DropLocation.z)
                    local g =  math.floor(255-(#(bir-iki)*20))
                    local r = 255-g
                    local b = 0
                    DrawMarker(30, WheatShared.DropLocation.x, WheatShared.DropLocation.y, WheatShared.DropLocation.z, 220.0, 220.0, 0, 90.0, 0, 0, 2.0, 1.0, 7.6, r, g, b, 255, 0, 0, 0, 0, 0, 0.0, 0)
                    if g >= 200 then
                        MainShared.HelpNotify(Lan.PressForDrop, MainShared.HelpNotifyType, WheatShared.DropLocation)
                        if IsControlJustPressed(0,38) then
                            for _, v in pairs(BALES_ON_TRAILER) do
                                if DoesEntityExist(v) then
                                    DetachEntity(v)
                                    DeleteEntity(v) 
                                end
                            end
                            BALES_ON_TRAILER = {}
                            Current_Stage += 1
                            ClearCustomBlips()
                            CreateCustomBlip(WheatShared.DropTractorLoc.x, WheatShared.DropTractorLoc.y, 557, 3, 0.7, Lan.TractorDrop)
                        end
                    end
                end

                if Current_Stage == 6 then
                    ms = 0
                    DrawMarker(2, WheatShared.DropTractorLoc.x, WheatShared.DropTractorLoc.y, WheatShared.DropTractorLoc.z, 0, 0.50, 0, 0, 0, 0, 0.75, 0.75, 0.75, 240, 185, 4, 210, 1, 0.10, 0, 1, 0, 0.0, 0)  
                    if #(GetEntityCoords(tractor) - vector3(WheatShared.DropTractorLoc.x, WheatShared.DropTractorLoc.y, WheatShared.DropTractorLoc.z)) <= 2.0 then
                        MainShared.HelpNotify(Lan.PressForDropTractor, MainShared.HelpNotifyType, WheatShared.DropTractorLoc)
                        if IsControlJustPressed(0, 38) then
                            ClearCustomBlips()
                            Current_Stage = 0 
                            ClearWheatBlips()
                            TriggerServerEvent('0r-farming-wheat-finished', id)
                            DeleteVehicle(tractor)
                            DeleteVehicle(harvester)
                            DeleteVehicle(raker)
                            DeleteVehicle(trailer)
                            TriggerServerEvent('0r-farming-receive-wheat')
                            MainShared.Notify(string.format(Lan.ReceiveWheat, WheatShared.Wheat), 'primary')
                            JobStarted = false
                            Max_Veri = 0
                            Yapilan_Veri = 0
                            Balya_Count = 0
                            tractor = 0
                            harvester = 0
                            raker = 0
                            trailer = 0
                            OLUSTURULAN_BALYA = 0
                            bekle = false
                            balya_elimde = false
                            elimdeki_balya = 0
                            KOYULANBALYA = 1
                            Balya_Tablosu = {}
                            WHEAT_BLIPS = {}
                            WHEAT_OBJECTS = {}
                            BALES_ON_TRAILER = {}
                            MainShared.ResetClothe()
                            break
                        end
                    end
                end
            end
        end
    end)
end
local function StartWheat(id)
    id = tonumber(id)
    if id == nil then print('[0r-farming:ERR]: Field Id Is Nil') return end

    ESX.TriggerServerCallback('0r-farming-start-wheatfield', function(canStart)
        if canStart then
            JobStarted = true
            MainShared.Notify(Lan.JobStarted, 'primary')
            StartWheatTask(id)
            TriggerServerEvent('0r-farming-wheat-started', id)
        else
            MainShared.Notify(Lan.SomethingWentWrong, 'error')
        end
    end, id)
end RegisterNetEvent('0r-farming-start-wheat', StartWheat)

attachedProp = 0

function removeAttachedProp()
    if attachedProp ~= 0 then
        DeleteEntity(attachedProp)
    end
end

RegisterNetEvent('attach-wheat-bag', function()
    local x = 0.0
    local y = 0.0
    local z = 0.42
    local xR = -10.0
    local yR = 180.0
    local zR = 90.0
	removeAttachedProp()
	Wait(100)
	attachModel = GetHashKey("prop_money_bag_01")
	SetCurrentPedWeapon(PlayerPedId(), 0xA2719263)
	local bone = GetPedBoneIndex(PlayerPedId(), 18905)
	RequestModel(attachModel)
	while not HasModelLoaded(attachModel) do
		Wait(100)
	end
	attachedProp = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
	SetModelAsNoLongerNeeded(attachModel)
	AttachEntityToEntity(attachedProp, PlayerPedId(), bone, x, y, z, xR, yR, zR, 1, 1, 0, 0, 2, 1)
end)