local pendingCraftRewards = {}
local pendingThrownWeapons = {}

local function deepCopy(value)
    if type(value) ~= 'table' then
        return value
    end

    local copy = {}
    for k, v in pairs(value) do
        copy[k] = deepCopy(v)
    end

    return copy
end

local function findCraftRecipeByName(list, recipeName)
    if type(list) ~= 'table' or type(recipeName) ~= 'string' then
        return nil
    end

    for _, entry in pairs(list) do
        if type(entry) == 'table' then
            if entry.name == recipeName and type(entry.requiredItems) == 'table' then
                return entry
            end

            local nested = findCraftRecipeByName(entry, recipeName)
            if nested then
                return nested
            end
        end
    end

    return nil
end

local function getInventoryItemAmount(playerInventory, itemName)
    local total = 0

    for _, inventoryItem in pairs(playerInventory or {}) do
        if inventoryItem.name == itemName then
            total = total + (tonumber(inventoryItem.amount) or 0)
        end
    end

    return total
end

local function normalizeCraftRequirements(recipe)
    local normalized = {}

    for _, requiredItem in pairs((recipe and recipe.requiredItems) or {}) do
        if type(requiredItem) == 'table' and type(requiredItem.name) == 'string' then
            local amount = tonumber(requiredItem.amount) or 0
            if amount > 0 then
                table.insert(normalized, {
                    name = requiredItem.name,
                    amount = amount,
                })
            end
        end
    end

    return normalized
end

local function setPendingCraftReward(src, recipe)
    local rewardAmount = tonumber(recipe.finishAmount) or 1
    if rewardAmount < 1 then
        rewardAmount = 1
    end

    local craftTime = tonumber(recipe.time) or 0
    pendingCraftRewards[src] = {
        name = recipe.name,
        amount = rewardAmount,
        info = deepCopy(recipe.info),
        expiresAt = os.time() + math.max(15, craftTime + 10)
    }
end

AddEventHandler('playerDropped', function()
    local src = tonumber(source)
    if not src then return end

    pendingCraftRewards[src] = nil
    pendingThrownWeapons[src] = nil
end)

Citizen.CreateThread(function()
    while not Core do
        Wait(0)
    end

    RegisterCallback('codem-inventory:GetESXCash', function(source, cb)
local Player = GetPlayer(source)
        if not Player then
            return
        end

        cb(Player.getMoney())
    end)
    RegisterCallback('codem-inventory:GetESXBank', function(source, cb)
local Player = GetPlayer(source)
        if not Player then
            return
        end
        cb(Player.getAccount("bank").money)
    end)
    RegisterCallback('codem-inventory:GetClosestPlayers', function(source, cb, clientplayers)
local players = {}
        for k, v in pairs(clientplayers) do
local player = GetPlayer(tonumber(v))
            if player then
                table.insert(players, {
                    id = tonumber(v),
                    name = GetName(tonumber(v)),
                })
            end
        end
        cb(players)
    end)
    RegisterCallback('codem-inventory:GetPlayerNameandid', function(source, cb)
local Player = GetPlayer(source)
        if Player then
local players = {
                id = tonumber(source),
                name = GetName(tonumber(source)),
            }
            cb(players)
        end
    end)
    RegisterCallback('codem-inventory:CheckIsPlayerDead', function(source, cb, id)
        if Config.Framework == 'qb' or Config.Framework == 'oldqb' then
local Player = Core.Functions.GetPlayer(tonumber(id))
local isDead = false
            if Player and (Player.PlayerData.metadata["isdead"] or Player.PlayerData.metadata["inlaststand"]) then
                isDead = true
            end
            cb(isDead)
        end
    end)

    RegisterCallback('codem-inventory:GetStashClientKey', function(source, cb)
local key = ServerPlayerKey[source]
        if key then
            cb(key)
        else
            cb(nil)
        end
    end)
    RegisterCallback('codem-inventory:getUserInventory', function(source, cb)
local items = LoadInventory(source)
        cb(items)
    end)

RegisterCallback('codem-inventory:CraftItem', function(source, cb, craftitem)
local src = source
local identifier = Identifier[src]
        if not identifier then
            TriggerClientEvent('codem-inventory:client:notification', src,
                Locales[Config.Language].notification['IDENTIFIERNOTFOUND'])
            return
        end

        if not Config.CraftSystem then
            cb(false)
            return
        end

local playerInventory = PlayerServerInventory[identifier] and PlayerServerInventory[identifier].inventory
        if not playerInventory then
            TriggerClientEvent('codem-inventory:client:notification', src,
                Locales[Config.Language].notification['PLAYERINVENTORYNOTFOUND'])
            debugprint('DİKKAT ENVANTER BULUNAMADI 1791 SATIR')
            return
        end

        if pendingCraftRewards[src] and os.time() < pendingCraftRewards[src].expiresAt then
            cb(false)
            return
        end

        local recipeName = type(craftitem) == 'table' and craftitem.name or nil
        local recipe = findCraftRecipeByName(Config.CraftItems, recipeName)
        if not recipe then
            TriggerEvent('codem-inventory:cheaterlogs', {
                playername = GetName(src),
                event = 'Invalid craft recipe payload'
            })
            cb(false)
            return
        end

        local requiredItems = normalizeCraftRequirements(recipe)
        if #requiredItems == 0 then
            cb(false)
            return
        end

local hasAllItems = true
        for _, requiredItem in ipairs(requiredItems) do
            if getInventoryItemAmount(playerInventory, requiredItem.name) < requiredItem.amount then
                hasAllItems = false
                break
            end
        end
        if hasAllItems then
            for _, requiredItem in ipairs(requiredItems) do
                local removed = RemoveItem(src, requiredItem.name, requiredItem.amount)
                if not removed then
                    cb(false)
                    return
                end
            end

            setPendingCraftReward(src, recipe)
            cb(true)
        else
            cb(false)
        end
    end)
end)

RegisterServerEvent('codem-inventory:server:FinishCraftItem', function(data)
local src = source
    if cooldown[tonumber(src)] then
        return
    else
        cooldown[tonumber(src)] = true
        SetTimeout(1000, function()
            cooldown[tonumber(src)] = nil
        end)
    end
local identifier = Identifier[src]
    if not identifier then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['IDENTIFIERNOTFOUND'])
        return
    end

local playerInventory = PlayerServerInventory[identifier] and PlayerServerInventory[identifier].inventory
    if not playerInventory then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['PLAYERINVENTORYNOTFOUND'])
        debugprint('DİKKAT ENVANTER BULUNAMADI 1791 SATIR')
        return
    end

    local pendingReward = pendingCraftRewards[src]
    if not pendingReward then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['CANTUSEITEM'])
        return
    end

    if os.time() > (pendingReward.expiresAt or 0) then
        pendingCraftRewards[src] = nil
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['CANTUSEITEM'])
        return
    end

    if not Config.Itemlist[pendingReward.name] then
        pendingCraftRewards[src] = nil
        TriggerEvent('codem-inventory:cheaterlogs', {
            playername = GetName(src),
            event = 'Craft reward item missing from server item list'
        })
        return
    end

    local added = AddItem(src, pendingReward.name, pendingReward.amount, nil, pendingReward.info)
    if added then
        pendingCraftRewards[src] = nil
    end
end)


local function decreaseItemDurability(item, elapsedTime, src)
    if item.info.decay == 'use' then  
        debugprint('Item ' .. item.name .. ' is using decay type: use')
        if item.info.quality <= 0 then
            debugprint('Config.RemoveBrokenItems is set to false, item will not be removed')
            debugprint('Item ' .. item.name .. ' is broken and cannot be used anymore')
            item.info.quality = 0
            TriggerClientEvent('codem-inventory:refreshItemsDurability', src, tostring(item.slot), item)
            SetInventory(src)
        else 
            item.info.quality = item.info.quality - (item.info.durability or 0)
            debugprint('Item ' .. item.name .. ' durability decreased by ' .. (item.info.durability or 0))
            debugprint('Current quality: ' .. item.info.quality)
            TriggerClientEvent('codem-inventory:refreshItemsDurability', src, tostring(item.slot), item)
            SetInventory(src)
         end
    else
local decreaseTimes = math.floor(elapsedTime / Config.DurabilityTime) 
        if decreaseTimes > 0 then
                item.info.quality = item.info.quality - (item.info.durability or 0) * decreaseTimes 
                item.info.lastuse = os.time()
            if Config.RemoveBrokenItems == 'all' and item.info.quality <= 0 then
                debugprint('Config.RemoveBrokenItems is set to all, all broken items will be removed') 
                debugprint('Item ' .. item.name .. ' removed due to broken quality')
                RemoveItem(src, item.name, item.amount, item.slot)
            elseif Config.RemoveBrokenItems == 'items' and item.info.quality <= 0 and item.type ~= 'weapon' then
                debugprint('Config.RemoveBrokenItems is set to items, no weapon will be removed')
                debugprint('Item ' .. item.name .. ' removed due to broken quality')
                RemoveItem(src, item.name, item.amount, item.slot)
            elseif item.info.quality <= 0 then
                debugprint('Config.RemoveBrokenItems is set to false, item will not be removed')
                debugprint('Item ' .. item.name .. ' is broken and cannot be used anymore')
                item.info.quality = 0
                TriggerClientEvent('codem-inventory:refreshItemsDurability', src, tostring(item.slot), item)
                SetInventory(src)
            else
                debugprint('Item ' .. item.name .. ' durability decreased by ' .. (item.info.durability or 0) * decreaseTimes)
                debugprint('Current quality: ' .. item.info.quality)
                TriggerClientEvent('codem-inventory:refreshItemsDurability', src, tostring(item.slot), item)
                SetInventory(src)
            end
        end
    end
end


-- local function decreaseItemDurability(item, elapsedTime, src)
--     local decreaseTimes = math.floor(elapsedTime / Config.DurabilityTime)
--     if decreaseTimes > 0 then
--         item.info.quality = item.info.quality - (item.info.durability or 0) * decreaseTimes
--         item.info.lastuse = os.time()
--         TriggerClientEvent('codem-inventory:refreshItemsDurability', src, tostring(item.slot), item)
--         SetInventory(src)
--     end
-- end

RegisterServerEvent('codem-inventory:checkdurabilityItems', function()
local src = source
local identifier = Identifier[src]
    if not identifier or lastCheckTime[src] and os.time() - lastCheckTime[src] < 600 then
        return
    end

local playerInventory = PlayerServerInventory[identifier].inventory
    if not playerInventory then
        debugprint('DİKKAT ENVANTER BULUNAMADI 507 SATIR')
        return
    end
    for _, item in pairs(playerInventory) do
        if item.info and item.info.decay == 'time' and item.info.quality and item.info.quality > 0 then
local currentTime = os.time()
local lastUseTime = item.info.lastuse or currentTime
local elapsedTime = currentTime - lastUseTime
            decreaseItemDurability(item, elapsedTime, src)
        else
            if item.info and item.info.quality and item.info.quality < 0 then
                item.info.quality = 0
            end
        end
    end

    lastCheckTime[src] = os.time()
end)


RegisterServerEvent('codem-inventory:server:checkdurabilityUsedItem', function(src, item, identifier)
    if not identifier then
        return
    end
local slot = item.slot
local playerInventory = PlayerServerInventory[identifier].inventory
    if not playerInventory or not playerInventory[slot] then
        debugprint('DİKKAT ENVANTER BULUNAMADI 507 SATIR')
        return
    end
local itemData = playerInventory[slot]
    if itemData.info and itemData.info.decay == 'use' and itemData.info.quality and itemData.info.quality > 0 then
        decreaseItemDurability(itemData, 0, src)
    else
        if itemData.info and itemData.info.quality and itemData.info.quality < 0 then
            itemData.info.quality = 0
        end
    end
end)


RegisterServerEvent('codem-inventory:repairweapon', function(weaponitem)
local src = tonumber(source)
local identifier = Identifier[src]
    if not identifier then
        return
    end
local playerInventory = PlayerServerInventory[identifier].inventory
    if not playerInventory then
        return
    end
    if not weaponitem or not weaponitem.slot then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['UNKOWNWEAPONINFO'])
        return
    end
local item = playerInventory[tostring(weaponitem.slot)]
    if not item then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['ITEMNOTFOUND'])
        return
    end
    if item.info and item.info.quality and item.info.quality < 100 then
        if item.info.maxrepair and item.info.repair and item.info.repair >= item.info.maxrepair then
            TriggerClientEvent('codem-inventory:client:notification', src,
                Locales[Config.Language].notification['WEAPON_REPAIR'])
            return
        end
local repairPrice = Config.WeaponRepairCosts[item.name] or nil
        if not repairPrice then
            TriggerClientEvent('codem-inventory:client:notification', src,
                Locales[Config.Language].notification['WEAPONREPAIRPRICENOTFOUND'])
            return
        end
local money = GetPlayerMoney(src, 'cash')
        if tonumber(money) < tonumber(repairPrice) then
            TriggerClientEvent('codem-inventory:client:notification', src,
                Locales[Config.Language].notification['ENOUGHMONEY'])
            return
        end
        RemoveMoney(src, 'cash', repairPrice)

        item.info.quality = 100
        item.info.repair = item.info.repair + 1
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['WEAPONREPAIRED'])
        TriggerClientEvent('codem-inventory:refreshItemsDurability', src, tostring(item.slot), item)
        SetInventory(src)
    else
        if item.info.quality and item.info.quality >= 100 then
            TriggerClientEvent('codem-inventory:client:notification', src,
                Locales[Config.Language].notification['DOESNTREPAIRS'])
        else
            TriggerClientEvent('codem-inventory:client:notification', src,
                Locales[Config.Language].notification['UNKOWNWEAPONINFO'])
        end
    end
end)

RegisterNetEvent('codem-inventory:removeWeaponItem', function(data)
local src = tonumber(source)
local identifier = Identifier[src]
    if not identifier then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['IDENTIFIERNOTFOUND'])
        return
    end
local playerInventory = PlayerServerInventory[identifier] and PlayerServerInventory[identifier].inventory
    if not playerInventory then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['PLAYERINVENTORYNOTFOUND'])
        debugprint('DİKKAT ENVANTER BULUNAMADI 459 SATIR')
        return
    end
    if type(data) ~= 'table' or data.slot == nil then
        TriggerEvent('codem-inventory:cheaterlogs', {
            playername = GetName(src),
            event = 'removeWeaponItem received invalid payload'
        })
        return
    end
local itemData = playerInventory[tostring(data.slot)]
    if not itemData then
        TriggerClientEvent('codem-inventory:client:notification', src,
            Locales[Config.Language].notification['ITEMNOTFOUNDINGIVENSLOT'])
        return
    end

    if itemData.type ~= 'weapon' then
        TriggerEvent('codem-inventory:cheaterlogs', {
            playername = GetName(src),
            event = 'removeWeaponItem called with non-weapon payload'
        })
        return
    end

    local removed = RemoveItem(src, itemData.name, 1, itemData.slot)
    if not removed then
        return
    end

    local droppedItem = deepCopy(itemData)
    droppedItem.object = nil
    droppedItem.amount = 1
    droppedItem.count = 1
    droppedItem.slot = "1"

    pendingThrownWeapons[src] = {
        item = droppedItem,
        expiresAt = os.time() + 15
    }
end)

RegisterServerEvent('codem-inventory:server:throwweapon', function(data, coords, entity)
local src = tonumber(source)
    local pendingDrop = pendingThrownWeapons[src]
    if not pendingDrop then
        return
    end

    if os.time() > (pendingDrop.expiresAt or 0) then
        pendingThrownWeapons[src] = nil
        return
    end

    pendingThrownWeapons[src] = nil

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return
    end

    local groundId = GenerateGroundId()
    local playerCoords = GetEntityCoords(ped)
    local droppedItem = deepCopy(pendingDrop.item)

    ServerGround[groundId] = { inventory = { ["1"] = droppedItem }, coord = playerCoords, id = groundId }
    TriggerClientEvent('codem-inventory:client:SetGroundTable', -1, groundId, playerCoords,
        ServerGround[groundId].inventory)
end)
