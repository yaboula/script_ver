local utils, targetModule
client = {}
client.framework = shared.getFrameworkObject()
client.load = false
client.uiLoad = false
client.uiOpen = false
client.exports = {}
client.currentTask = nil
client.lobby = {}

require("modules.bridge.init")
require("modules.exports.client")
utils = require("modules.utils.client")
targetModule = require("modules.target.client")

local toggleKeybind = nil
local isTaskInfoMenuHidden = false

local function isPlayerNearSellNpc()
    local playerCoords = GetEntityCoords(cache.ped)
    local locations = Config.SellNpc.locations or {}
    
    for _, location in pairs(locations) do
        local distance = #(playerCoords - vec3(location))
        if distance < 5.0 then
            return true
        end
    end
    
    return false
end

local function hideUI()
    client.sendReactMessage("ui:setVisible", false)
    SetNuiFocus(false, false)
    client.uiOpen = false
end

local function onPlayerUnload()
    if client.uiOpen then
        hideUI()
    end
    client.uiOpen = false
    Market.onUnload()
    MultiplayerTasksClient.onUnload()
    client.sendReactMessage("ui:onUnload")
    TriggerServerEvent(_e("server:onPlayerLogout"))
end

local function loadUI()
    if client.uiLoad then
        return
    end
    
    local locale = GetConvar("ox:locale", "en")
    local setupData = {}
    
    setupData.setLocale = lib.loadJson(("locales.%s"):format(locale)).ui
    setupData.setConfig = {
        InventoryImagesFolder = Config.InventoryImagesFolder,
        InfoBoxAlign = Config.InfoBoxAlign,
    }
    setupData.setMarketItems = Market.getDataItems()
    setupData.setHelpTexts = Config.HelpText
    setupData.setMultiplayerTasksConfigs = MultiplayerTasksClient.configs
    
    client.sendReactMessage("ui:setupUI", setupData, true)
end

local function openMenu()
    if not client.uiLoad then
        return
    end
    
    if Config.FarmingMenu.allowedJobs then
        if #Config.FarmingMenu.allowedJobs > 0 then
            if not client.hasPlayerGotGroup(Config.FarmingMenu.allowedJobs) then
                utils.notify(locale("you_do_not_have_permission"), "error")
                return
            end
        end
    end
    
    client.sendReactMessage("ui:setPage", "home")
    client.sendReactMessage("ui:setPlayerNearSellNpc", isPlayerNearSellNpc())
    client.sendReactMessage("ui:setVisible", true)
    client.uiOpen = true
    
    local profile = Profile.get()
    if profile.source == -1 then
        Profile.fetch()
        Profile.updateUI()
    end
    
    SetNuiFocus(true, true)
    
    lib.callback(_e("server:inventory:getPlayerInventory"), false, function(inventory)
        if not inventory then
            return
        end
        client.sendReactMessage("ui:setPlayerInventory", inventory)
    end)
end

local function createSellNpc()
    local npcModel = Config.SellNpc.model
    local blipConfig = Config.SellNpc.blip
    local locations = Config.SellNpc.locations
    
    lib.requestModel(npcModel)
    
    for _, location in pairs(locations) do
        local npc = CreatePed(4, npcModel, location.x, location.y, location.z, location.w or 0.0, false, true)
        
        while not DoesEntityExist(npc) do
            Wait(0)
        end
        
        SetEntityCoords(npc, location.x, location.y, location.z)
        FreezeEntityPosition(npc, true)
        SetEntityInvincible(npc, true)
        SetPedDiesWhenInjured(npc, false)
        TaskSetBlockingOfNonTemporaryEvents(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        
        if blipConfig and blipConfig.active then
            utils.addBlip(npc, blipConfig)
        end
        
        targetModule.addLocalEntity(npc, {
            {
                label = locale("open_sell_menu"),
                icon = "fas fa-shopping-cart",
                distance = 2.0,
                onSelect = function()
                    openMenu()
                end,
            },
        }, true)
    end
    
    SetModelAsNoLongerNeeded(npcModel)
end

function client.sendReactMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data,
    })
end

function client.sendReactAlert(text, type)
    client.sendReactMessage("ui:setAlert", {
        type = type,
        text = text,
    })
end

function client.onPlayerLoad(load)
    if not load then
        onPlayerUnload()
        utils.hideTextUI()
        PersonalChallengesClient.clear()
    else
        PersonalChallengesClient.init()
        createSellNpc()
    end
    client.load = load
end

function client.hideUI()
    hideUI()
end

function client.setOutfit(outfit)
    local framework = shared.framework
    
    if outfit then
        if framework == "esx" then
            client.framework.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
                if skin then
                    TriggerEvent("skinchanger:loadClothes", skin, outfit)
                end
            end)
        else
            TriggerEvent("qb-clothing:client:loadOutfit", {
                outfitData = outfit,
            })
        end
    elseif framework == "esx" then
        client.framework.TriggerServerCallback("esx_skin:getPlayerSkin", function(skin)
            if skin then
                TriggerEvent("skinchanger:loadSkin", skin)
            end
        end)
    elseif framework == "qb" then
        TriggerServerEvent("qb-clothes:loadPlayerSkin")
    else
        TriggerEvent("illenium-appearance:client:reloadSkin", true)
    end
end

function client.setInfoBoxDisabledState(disabled)
    toggleKeybind.disable(toggleKeybind, disabled)
    isTaskInfoMenuHidden = false
end

function client.getClosestSellNpc()
    local playerCoords = GetEntityCoords(cache.ped)
    local closestLocation = nil
    local closestDistance = -1
    local locations = Config.SellNpc.locations
    
    for _, location in pairs(locations) do
        local distance = #(playerCoords - vector3(location.x, location.y, location.z))
        if closestDistance == -1 or closestDistance > distance then
            closestDistance = distance
            closestLocation = location
        end
    end
    
    return closestLocation, closestDistance
end

RegisterNUICallback("nui:client:loadUI", function(data, cb)
    cb(true)
    loadUI()
end)

RegisterNUICallback("nui:client:onLoadUI", function(data, cb)
    cb(true)
    client.uiLoad = true
end)

RegisterNUICallback("nui:client:hideFrame", function(data, cb)
    hideUI()
    cb(true)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= shared.resource then
        return
    end
    
    Citizen.Wait(2000)
    
    if not client.isPlayerLoaded() then
        return
    end
    
    client.onPlayerLoad(true)
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= shared.resource then
        return
    end
    
    client.onPlayerLoad(false)
end)

if Config.FarmingMenu.openWithCommand then
    if Config.FarmingMenu.openWithCommand.active then
        RegisterCommand(Config.FarmingMenu.openWithCommand.command, openMenu)
    end
end

if Config.FarmingMenu.openWithKey then
    if Config.FarmingMenu.openWithKey.active then
        lib.addKeybind({
            name = "farming_v2_open_menu",
            description = "Open menu",
            defaultKey = Config.FarmingMenu.openWithKey.key,
            onPressed = openMenu,
        })
    end
end

RegisterNetEvent("0r-farming-v2:client:openMenu", function()
    if not client.uiLoad then
        loadUI()
    end
    openMenu()
end)

RegisterNetEvent("client:farming-v2:notify", function(text, type, duration, position)
    utils.notify(text, type, duration, position)
end)

toggleKeybind = lib.addKeybind({
    name = "toggle_farming_v2_info_box",
    description = "Toggle farming v2 info box",
    defaultKey = Config.ToggleInfoBoxKey,
    onPressed = function(keybind)
        keybind.disable(keybind, true)
        client.sendReactMessage("ui:setInfoBox", {
            hidden = not isTaskInfoMenuHidden,
            texts = client.currentTask and client.currentTask.infoBoxTable or {},
        })
        isTaskInfoMenuHidden = not isTaskInfoMenuHidden
        Citizen.SetTimeout(1000, function()
            keybind.disable(keybind, false)
        end)
    end,
    disabled = true,
})
