local config = lib.load("core.market.config")
local utils = require("modules.utils.client")
local targetModule = require("modules.target.client")

Market = {}
local droneEntity = nil
local bagEntity = nil

local function deleteDrone()
    if droneEntity then
        if DoesEntityExist(droneEntity) then
            DeleteEntity(droneEntity)
            SetEntityAsNoLongerNeeded(droneEntity)
        end
    end
    droneEntity = nil
end

local function deleteBag()
    if bagEntity then
        if DoesEntityExist(bagEntity) then
            DeleteEntity(bagEntity)
            SetEntityAsNoLongerNeeded(bagEntity)
        end
    end
    bagEntity = nil
end

local function setupBagTarget()
    FreezeEntityPosition(bagEntity, false)
    DetachEntity(bagEntity, true, true)
    SetEntityDynamic(bagEntity, true)
    ActivatePhysics(bagEntity)
    targetModule.addLocalEntity(bagEntity, {
        {
            label = locale("market.collect"),
            icon = "fa-solid fa-briefcase",
            distance = 2.0,
            onSelect = function()
                targetModule.removeLocalEntity(bagEntity)
                lib.playAnim(cache.ped, "pickup_object", "pickup_low")
                lib.callback.await(_e("server:market:collectLootableBag"), false)
                Citizen.Wait(1000)
                deleteBag()
            end,
        },
    })
end

function Market.onUnload()
    deleteBag()
    deleteDrone()
end

function Market.getBuyItems()
    local items = {}
    for _, item in pairs(config.items) do
        if item.type == nil or item.type == "buy" then
            table.insert(items, item)
        end
    end
    return items
end

function Market.getSellItems()
    local items = {}
    for _, item in pairs(config.items) do
        if item.type == nil or item.type == "sell" then
            table.insert(items, item)
        end
    end
    return items
end

function Market.getDataItems()
    return config.items
end

RegisterNUICallback("nui:market:payCart", function(data, cb)
    local result = lib.callback.await(_e("server:market:payCart"), false, data)
    
    if result.error then
        client.sendReactAlert(result.error, "error")
        return cb(false)
    end
    
    client.hideUI()
    utils.notify(locale("market.order_delivered"), "success")
    client.sendReactMessage("ui:setOrderInfo", {
        delivery_time = result.pendingDelivery.delivery_time,
    })
    cb(true)
end)

RegisterNUICallback("nui:market:sellItems", function(data, cb)
    local result = lib.callback.await(_e("server:market:sellItems"), false, data)
    
    if result.error then
        client.sendReactAlert(result.error, "error")
        return cb(false)
    end
    
    client.sendReactAlert(locale("market.items_sold"), "success")
    cb(true)
end)

RegisterNetEvent(_e("client:market:spawnDeliveryDrone"), function()
    local delivery = lib.callback.await(_e("server:market:getPlayerDelivery"), false)
    if not delivery then
        return
    end
    
    local ped = cache.ped
    local playerCoords = GetEntityCoords(ped)
    local distance = 75.0
    local angle = math.rad(math.random(0, 360))
    local spawnCoords = vector3(
        playerCoords.x + math.cos(angle) * distance,
        playerCoords.y + math.sin(angle) * distance,
        playerCoords.z + 10.0
    )
    
    local droneModel = config.droneDelivery.objectModel
    local bagModel = config.droneDelivery.bagModel
    
    droneEntity = utils.createObject(droneModel, spawnCoords, nil, true, true, false)
    SetEntityAsMissionEntity(droneEntity, true, true)
    utils.addBlip(droneEntity, config.droneDelivery.blip)
    
    bagEntity = utils.createObject(bagModel, spawnCoords, nil, true, true, false)
    SetEntityAsMissionEntity(bagEntity, true, true)
    AttachEntityToEntity(bagEntity, droneEntity, 0, 0.0, 0.0, -0.5, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    
    local speed = 3.5
    local hasReached = false
    Citizen.CreateThread(function()
        while true do
            if not DoesEntityExist(droneEntity) then
                break
            end
            if hasReached then
                break
            end
            
            local droneCoords = GetEntityCoords(droneEntity)
            playerCoords = GetEntityCoords(ped)
            local distanceToPlayer = #(playerCoords - droneCoords)
            
            if distanceToPlayer < 5.0 then
                hasReached = true
                break
            end
            
            local targetCoords = vector3(playerCoords.x, playerCoords.y, playerCoords.z + 4.0)
            local direction = targetCoords - droneCoords
            local normalized = direction / #direction
            local movement = normalized * speed * 0.02
            
            SetEntityCoords(droneEntity, droneCoords + movement, false, false, false, true)
            Citizen.Wait(0)
        end
        
        Citizen.Wait(3000)
        setupBagTarget()
        client.sendReactMessage("ui:setOrderInfo", nil)
        Citizen.Wait(5000)
        DeleteEntity(droneEntity)
    end)
end)
