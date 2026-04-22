ESX = exports["es_extended"]:getSharedObject()

JobStarted = false
isBussy = false
Current_Stage = 0
Has_HayBale = false
carryingObject = false
bliptable = {}
local cloth = false
local current_job = nil

local function OpenUI(x)
    if x == "Wheat" then
        ESX.TriggerServerCallback("0r-farming-get-wheat-fields", function(data)
            SendNUIMessage({
                action = 'open',
                config = Config[x],
                type = x,
                fields = data
            })
            SetNuiFocus(true, true)
        end)
    elseif x == "Cow" then
        ESX.TriggerServerCallback("0r-farming-get-cow-fields", function(data)
            SendNUIMessage({
                action = 'open',
                config = Config[x],
                type = x,
                fields = data
            })
            SetNuiFocus(true, true)
        end)
    elseif x == "Melon" then
        ESX.TriggerServerCallback("0r-farming-get-melon-fields", function(data)
            SendNUIMessage({
                action = 'open',
                config = Config[x],
                type = x,
                fields = data
            })
            SetNuiFocus(true, true)
        end)
    elseif x == "Pumpkin" then
        ESX.TriggerServerCallback("0r-farming-get-pumpkin-fields", function(data)
            SendNUIMessage({
                action = 'open',
                config = Config[x],
                type = x,
                fields = data
            })
            SetNuiFocus(true, true)
        end)
    elseif x == "Shop" then
        SendNUIMessage({
            action = 'open',
            config = Config[x],
            type = x
        })
        SetNuiFocus(true, true)
    end
end

RegisterCommand('farmclose', function()
    SendNUIMessage({
        action = 'close'
    })
    SetNuiFocus(false, false)
end)

local function Close()
    SetNuiFocus(false, false)
end RegisterNUICallback('close', Close)

RegisterNetEvent('0r-farming-notify', MainShared.Notify)

local function BuyFunction(data, cb)
    if data.money == 0 then
        MainShared.Notify(Lan.BasketEmpty, "error")
        return
    end
    ESX.TriggerServerCallback('0r-farming-buy', function(bought)
        if bought then
            cb(true)
        else
            cb(false)
        end
    end, data)
end RegisterNUICallback('buy', BuyFunction)

local function GetSellConfig(_, cb)
    cb(Config["Sell"])
end RegisterNUICallback('GetSellConfig', GetSellConfig)

local function GetShopConfig(_, cb)
    cb(Config["Shop"])
end RegisterNUICallback('GetShopConfig', GetShopConfig)

local function SellItem(data)
    TriggerServerEvent('0r-farming-sell', data)
end RegisterNUICallback('SellItem', SellItem)

-- Thread

local function StartThread()
    CreateThread(function()
        local pedhash = MainShared.ShopPed
        while not HasModelLoaded(pedhash) do
            RequestModel(pedhash)
            Wait(0) 
        end

        for k,v in pairs(MainShared.ShopLocations) do
            print(json.encode(k))
            local ped = CreatePed(4, pedhash, MainShared.ShopLocations[k].x, MainShared.ShopLocations[k].y, MainShared.ShopLocations[k].z-1, MainShared.ShopLocations[k].w, false, false)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            SetModelAsNoLongerNeeded(pedhash)
            
            local shopblip = AddBlipForCoord(MainShared.ShopLocations[k].x, MainShared.ShopLocations[k].y, MainShared.ShopLocations[k].z)
            SetBlipSprite(shopblip, MainShared.BlipSprite)
            SetBlipColour(shopblip, MainShared.BlipColour)
            SetBlipScale(shopblip, MainShared.BlipScale)
            SetBlipAsShortRange(shopblip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Lan.ShopBlip)
            EndTextCommandSetBlipName(shopblip)
        end

        while true do
            local ms = 1000
            local ped = PlayerPedId()
            local cowdist = #(GetEntityCoords(ped) - vector3(CowShared.StartPed.coords.x, CowShared.StartPed.coords.y, CowShared.StartPed.coords.z))
            local wheatdist = #(GetEntityCoords(ped) - vector3(WheatShared.StartPed.coords.x, WheatShared.StartPed.coords.y, WheatShared.StartPed.coords.z))
            local melondist = #(GetEntityCoords(ped) - vector3(MelonShared.StartPed.coords.x, MelonShared.StartPed.coords.y, MelonShared.StartPed.coords.z))
            local pumpdist = #(GetEntityCoords(ped) - vector3(PumpkinShared.StartPed.coords.x, PumpkinShared.StartPed.coords.y, PumpkinShared.StartPed.coords.z))

            for k,v in pairs(MainShared.ShopLocations) do
                local shopdist = #(GetEntityCoords(ped) - vector3(MainShared.ShopLocations[k].x, MainShared.ShopLocations[k].y, MainShared.ShopLocations[k].z))
                if shopdist < 1.8 then
                    ms = 0
                    MainShared.HelpNotify(Lan.OpenShop, MainShared.HelpNotifyType, MainShared.ShopLocations[k])
                    if IsControlJustPressed(0, 38) then
                        OpenUI('Shop')
                    end
                end
            end

            if cowdist < 1.8 then
                current_job = "Cow"
                ms = 0
                MainShared.HelpNotify(Lan.CheckCowFields, MainShared.HelpNotifyType, CowShared.StartPed.coords)
                if IsControlJustPressed(0, 38) then
                    if not JobStarted then
                        OpenUI('Cow')
                    else
                        MainShared.Notify(Lan.YouAreAlreadyInJob, 'error')
                    end
                end
            end

            if wheatdist <= 1.8 then
                current_job = "Wheat"
                ms = 0
                MainShared.HelpNotify(Lan.CheckWheatFields, MainShared.HelpNotifyType, WheatShared.StartPed.coords)
                if IsControlJustPressed(0, 38) then
                    if not JobStarted then
                        OpenUI('Wheat')
                    else
                        MainShared.Notify(Lan.YouAreAlreadyInJob, 'error')
                    end
                end
            end

            if melondist <= 1.8 then
                current_job = "Melon"
                ms = 0
                MainShared.HelpNotify(Lan.CheckMelonFields, MainShared.HelpNotifyType, MelonShared.StartPed.coords)
                if IsControlJustPressed(0, 38) then
                    if not JobStarted then
                        OpenUI('Melon')
                    else
                        MainShared.Notify(Lan.YouAreAlreadyInJob, 'error')
                    end
                end
            end

            if pumpdist <= 1.8 then
                current_job = "Pumpkin"
                ms = 0
                MainShared.HelpNotify(Lan.CheckPumpFields, MainShared.HelpNotifyType, PumpkinShared.StartPed.coords)
                if IsControlJustPressed(0, 38) then
                    if not JobStarted then
                        OpenUI('Pumpkin')
                    else
                        MainShared.Notify(Lan.YouAreAlreadyInJob, 'error')
                    end
                end
            end
            Wait(ms)
        end
    end)
end

StartThread()

-- FUNCTIONS

function ClearCustomBlips()
    ClearAllBlipRoutes()
    for _,v in pairs(bliptable) do
        RemoveBlip(v)
    end
end

function CreateCustomBlip(x, y, sprite, colour, scale, text)
    local blip = AddBlipForCoord(x, y)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, colour)
    SetBlipAsShortRange(blip, true)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)
    table.insert(bliptable, blip)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(0)
    end
end

--carry
carryingObject = false
carryObject = 0
carryAnimType = 49
local anim1
local anim2

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
        removeAttachedcarryObject()
        ClearPedSecondaryTask(PlayerPedId())
        ClearPedTasks(PlayerPedId())
	end
end)

function cancelCarryAnim()
    carryingObject = false
end

function removeAttachedcarryObject()
	if DoesEntityExist(carryObject) then
		DeleteEntity(carryObject)
		carryObject = 0
        carryingObject = false
	end
end RegisterNetEvent('0r-farming-stop-carry', removeAttachedcarryObject)

RegisterNetEvent('0r-farming-carry-object', function(attachModelSent, boneNumberSent, x, y, z, xR, yR, zR, Anim1, Anim2)
    anim1 = Anim1
    anim2 = Anim2
	removeAttachedcarryObject()
	attachModel = GetHashKey(attachModelSent)
	boneNumber = boneNumberSent
	SetCurrentPedWeapon(PlayerPedId(), 0xA2719263)
	local bone = GetPedBoneIndex(PlayerPedId(), boneNumberSent)
	RequestModel(attachModel)
	while not HasModelLoaded(attachModel) do
		Wait(100)
	end
	carryObject = CreateObject(attachModel, 1.0, 1.0, 1.0, 1, 1, 0)
    SetEntityCollision(carryObject, false, true)
    if youga ~= 0 then
        SetEntityNoCollisionEntity(carryObject, youga)
    end
	AttachEntityToEntity(carryObject, PlayerPedId(), bone, x, y, z, xR, yR, zR, 1, 1, true, 0, 2, 1)
    carryingObject = true
end)

CreateThread(function()
	while true do
        Wait(1250)
		if carryingObject then
			RequestAnimDict(anim1)
			while not HasAnimDictLoaded(anim1) do
				Wait(0)
				ClearPedTasksImmediately(PlayerPedId())
			end
			if not IsEntityPlayingAnim(PlayerPedId(), anim1, anim2, 3) then
				TaskPlayAnim(PlayerPedId(), anim1, anim2, 8.0, -8, -1, carryAnimType, 0, 0, 0, 0)
			end
		else
			if IsEntityPlayingAnim(PlayerPedId(), anim1, anim2, 3) then
                ClearPedSecondaryTask(PlayerPedId())
                ClearPedTasks(PlayerPedId())
			end
		end
	end
end)

local function WearClothes()
    if JobStarted then return end
    if not cloth then
        cloth = true
        MainShared.JobClothe()
    end
end RegisterNUICallback('WearClothes', WearClothes)

local function ResetClothes()
    if JobStarted then return end
    if cloth then
        cloth = false
        MainShared.ResetClothe()
    end
end RegisterNUICallback('ResetClothes', ResetClothes)

local function StartJob(data, cb)
    if JobStarted then return end if data.id == nil then return end
    if MainShared.NeedCloth then
        if not cloth then 

            return
        end
    end
    if current_job == 'Wheat' then
        if data.id == nil then return end
        TriggerEvent('0r-farming-start-wheat', data.id)
        cb(true)
        SetNuiFocus(false, false)
    elseif current_job == 'Cow' then
        if data.id == nil then return end
        TriggerEvent('0r-farming-start-cow', data.id)
        cb(true)
        SetNuiFocus(false, false)
    elseif current_job == 'Melon' then
        if data.id == nil then return end
        TriggerEvent('0r-farming-start-melon', data.id)
        cb(true)
        SetNuiFocus(false, false)
    elseif current_job == 'Pumpkin' then
        if data.id == nil then return end
        TriggerEvent('0r-farming-start-pumpkin', data.id)
        cb(true)
        SetNuiFocus(false, false)
    else
        cb(false)
    end
end RegisterNUICallback('StartJob', StartJob)