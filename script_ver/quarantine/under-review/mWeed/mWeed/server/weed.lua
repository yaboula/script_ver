local ALLOWED_SEEDS = {
    [Config.Items['indica_seed'].name] = true,
    [Config.Items['sativa_seed'].name] = true,
}

local ALLOWED_ROLL_INPUT = {
    [Config.Items['grinded_sativa'].name] = true,
    [Config.Items['grinded_indica'].name] = true,
}

local ALLOWED_GRIND_INPUT = {
    [Config.Items['sativa_weed'].name] = true,
    [Config.Items['indica_weed'].name] = true,
}

local function ResolvePlantRefs(areaIndex, block, weedIndex)
    local area = tonumber(areaIndex)
    local weed = tonumber(weedIndex)
    if not area or not weed then
        return false
    end
    if type(block) ~= 'string' or not block:match('^block_%d+$') then
        return false
    end
    if weed < 1 or weed > 20 then
        return false
    end
    return tostring(area), block, tostring(weed)
end

RegisterServerEvent('mWeed:AddPlayerWeedData')
AddEventHandler('mWeed:AddPlayerWeedData', function(areaIndex, block, weedIndex)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    if not weedData[identifier] then
        weedData[identifier] = {}
    end

    if not weedData[identifier][areaIndex] then
        weedData[identifier][areaIndex] = {}
    end

    if not weedData[identifier][areaIndex][block] then
        weedData[identifier][areaIndex][block] = {}
    end
    local data = {
        currentProgress = 2,
        water = 1,
        flounder = 1,
        growth = false,
        isQualityFertilizer = false,
        seedType = false,
    }
    weedData[identifier][areaIndex][block][weedIndex] = data
    TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex, data)
end)

RegisterServerEvent('mWeed:AddProgress')
AddEventHandler('mWeed:AddProgress', function(areaIndex, block, weedIndex, deleteItem)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    if deleteItem then
        if type(deleteItem) ~= 'string' then
            return
        end
        local itemCfg = Config.Items[deleteItem]
        if not itemCfg then
            return
        end
        if not CheckItem(src, {
                name = itemCfg.name,
                reqAmount = 1,
            }) then
            TriggerClientEvent('mWeed:SendNotification', src,
                string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], itemCfg.label))
            return
        end
    end
    local isValidData = weedData[identifier] and weedData[identifier][areaIndex] and
        weedData[identifier][areaIndex][block] and weedData[identifier][areaIndex][block][weedIndex]

    if isValidData then
        local data = weedData[identifier][areaIndex][block][weedIndex]

        if data.currentProgress < 4 then
            data.currentProgress = tonumber(data.currentProgress) + 1
        else
            if data.growth == false then
                data.growth = 1
            end
        end
        if deleteItem then
            local Player = GetPlayer(src)
            if Player then
                local itemCfg = Config.Items[deleteItem]
                if not itemCfg then
                    return
                end
                if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                    Player.removeInventoryItem(itemCfg.name, 1)
                else
                    Player.Functions.RemoveItem(itemCfg.name, 1)
                end
            end
        end
        TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex,
            weedData[identifier][areaIndex][block][weedIndex])
    end
end)

RegisterServerEvent('mWeed:SetSeedType')
AddEventHandler('mWeed:SetSeedType', function(areaIndex, block, weedIndex, val)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea or type(val) ~= 'string' or not ALLOWED_SEEDS[val] then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    local isValidData = weedData[identifier] and weedData[identifier][areaIndex] and
        weedData[identifier][areaIndex][block] and weedData[identifier][areaIndex][block][weedIndex]

    if isValidData then
        local data = weedData[identifier][areaIndex][block][weedIndex]
        data.seedType = val
        TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex,
            weedData[identifier][areaIndex][block][weedIndex])
    end
end)

RegisterServerEvent('mWeed:SetIsQualityFertilizer')
AddEventHandler('mWeed:SetIsQualityFertilizer', function(areaIndex, block, weedIndex, val)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea or type(val) ~= 'boolean' then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    local isValidData = weedData[identifier] and weedData[identifier][areaIndex] and
        weedData[identifier][areaIndex][block] and weedData[identifier][areaIndex][block][weedIndex]

    if isValidData then
        local data = weedData[identifier][areaIndex][block][weedIndex]
        data.isQualityFertilizer = val
        TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex,
            weedData[identifier][areaIndex][block][weedIndex])
    end
end)

RegisterServerEvent('mWeed:harvest')
AddEventHandler('mWeed:harvest', function(areaIndex, block, weedIndex)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    local isValidData = weedData[identifier] and weedData[identifier][areaIndex] and
        weedData[identifier][areaIndex][block] and weedData[identifier][areaIndex][block][weedIndex]

    if isValidData then
        local data = weedData[identifier][areaIndex][block][weedIndex]

        if data.growth >= 4 then
            local itemName = false
            local label = ""
            if data.seedType == Config.Items['indica_seed'].name then
                itemName = Config.Items['indica_weed'].name
                label = Config.Items['indica_weed'].label
            elseif data.seedType == Config.Items['sativa_seed'].name then
                itemName = Config.Items['sativa_weed'].name
                label = Config.Items['sativa_weed'].label
            end
            local Player = GetPlayer(src)
            if not Player then
                return
            end
            if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                if not Player.canCarryItem(itemName, 1) then
                    TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["CANT_CARRY"])
                    return
                end
                Player.addInventoryItem(itemName, 1)
            else
                if itemName and not Player.Functions.AddItem(itemName, 1) then
                    TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["CANT_CARRY"])
                    return
                end
            end
            TriggerClientEvent('mWeed:DestroyedWeed', src, areaIndex, block, weedIndex)
            weedData[identifier][areaIndex][block][weedIndex] = nil
            TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex,
                weedData[identifier][areaIndex][block][weedIndex])
            TriggerClientEvent('mWeed:SendNotification', src, string.format(Config.Notifications["RECEIVED"], label))
        end
    end
end)


RegisterServerEvent('mWeed:water')
AddEventHandler('mWeed:water', function(areaIndex, block, weedIndex)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    if not CheckItem(src, {
            name = Config.Items['water'].name,
            reqAmount = 1,
        }) then
        TriggerClientEvent('mWeed:SendNotification', src,
            string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items["water"].label))
        return
    end
    local isValidData = weedData[identifier] and weedData[identifier][areaIndex] and
        weedData[identifier][areaIndex][block] and weedData[identifier][areaIndex][block][weedIndex]
    if isValidData then
        local data = weedData[identifier][areaIndex][block][weedIndex]
        if data.water <= 2 then
            if data.water == 0 then
                if data.isQualityFertilizer then
                    data.water = 4
                else
                    local luck = math.random(1, 100)
                    if luck <= Config.GeneralSettings.revivalRate then
                        data.water = 4
                    else
                        TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["PLANT_DEAD"])
                        TriggerClientEvent('mWeed:DestroyedWeed', src, areaIndex, block, weedIndex)
                        data = nil
                        weedData[identifier][areaIndex][block][weedIndex] = nil
                    end
                end
            else
                data.water = 4
            end
            if data and data.flounder >= 4 then
                data.growth = data.growth + 1
                if data.growth > 4 then
                    data.growth = 4
                end
            end
        end
        local Player = GetPlayer(src)
        if Player then
            if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                Player.removeInventoryItem(Config.Items['water'].name, 1)
            else
                Player.Functions.RemoveItem(Config.Items['water'].name, 1)
            end
        end
        TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex, data)
    end
end)

RegisterServerEvent('mWeed:flounder')
AddEventHandler('mWeed:flounder', function(areaIndex, block, weedIndex)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    if not CheckItem(src, {
            name = Config.Items["spray"].name,
            reqAmount = 1,
        }) then
        TriggerClientEvent('mWeed:SendNotification', src,
            string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], Config.Items["spray"].label))
        return
    end

    local isValidData = weedData[identifier] and weedData[identifier][areaIndex] and
        weedData[identifier][areaIndex][block] and weedData[identifier][areaIndex][block][weedIndex]
    if isValidData then
        local data = weedData[identifier][areaIndex][block][weedIndex]
        if data.flounder <= 2 then
            if data.flounder == 0 then
                if data.isQualityFertilizer then
                    data.flounder = 4
                else
                    local luck = math.random(1, 100)
                    if luck <= Config.GeneralSettings.revivalRate then
                        data.flounder = 4
                    else
                        TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["PLANT_DEAD"])
                        TriggerClientEvent('mWeed:DestroyedWeed', src, areaIndex, block, weedIndex)
                        data = nil
                        weedData[identifier][areaIndex][block][weedIndex] = nil
                    end
                end
            else
                data.flounder = 4
            end
            if data and data.water >= 4 then
                data.growth = data.growth + 1
                if data.growth > 4 then
                    data.growth = 4
                end
            end
        end
        local Player = GetPlayer(src)
        if Player then
            if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
                Player.removeInventoryItem(Config.Items['spray'].name, 1)
            else
                Player.Functions.RemoveItem(Config.Items['spray'].name, 1)
            end
        end
        TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex, data)
    end
end)

RegisterServerEvent('mWeed:trash')
AddEventHandler('mWeed:trash', function(areaIndex, block, weedIndex)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    if weedData[identifier] and weedData[identifier][areaIndex] and weedData[identifier][areaIndex][block][weedIndex] then
        TriggerClientEvent('mWeed:DestroyedWeed', src, areaIndex, block, weedIndex)
        weedData[identifier][areaIndex][block][weedIndex] = nil
        TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex,
            weedData[identifier][areaIndex][block][weedIndex])
    end
end)

RegisterServerEvent('mWeed:removeStatus')
AddEventHandler('mWeed:removeStatus', function(areaIndex, block, weedIndex)
    local src = source
    local identifier = GetIdentifier(src)
    local parsedArea, parsedBlock, parsedWeed = ResolvePlantRefs(areaIndex, block, weedIndex)
    if not parsedArea then
        return
    end

    areaIndex = parsedArea
    block = parsedBlock
    weedIndex = parsedWeed

    local isValidData = weedData[identifier] and weedData[identifier][areaIndex] and
        weedData[identifier][areaIndex][block] and weedData[identifier][areaIndex][block][weedIndex]

    if isValidData then
        local data = weedData[identifier][areaIndex][block][weedIndex]

        local current = data.flounder
        data.flounder = current - 1
        if data.flounder <= 0 then
            data.flounder = 0
        end
        local current = data.water
        data.water = current - 1
        if data.water <= 0 then
            data.water = 0
        end
        TriggerClientEvent('mWeed:UpdatePlayerWeedData', src, areaIndex, block, weedIndex,
            weedData[identifier][areaIndex][block][weedIndex])
    end
end)

RegisterServerEvent('mWeed:RequestData')
AddEventHandler('mWeed:RequestData', function()
    local src = source
    local identifier = GetIdentifier(src)
    if not weedData[identifier] then
        weedData[identifier] = {}
    end
    TriggerClientEvent('mWeed:SetPlayerWeedData', src, weedData[identifier])
end)


RegisterServerEvent('mWeed:rollWeed')
AddEventHandler('mWeed:rollWeed', function(item)
    local src = source
    if type(item) ~= 'string' or not ALLOWED_ROLL_INPUT[item] then
        return
    end

    local hasWeed = CheckItem(src, {
        name = item,
        reqAmount = 1,
    })
    local hasPaper = CheckItem(src, {
        name = Config.Items['raw_paper'].name,
        reqAmount = 4,
    })

    if not hasWeed or not hasPaper then
        local missingItems = ""
        if not hasPaper then
            missingItems = Config.Items["raw_paper"].label
        end
        if not hasWeed then
            local weedLabel = Config.Items[item] and Config.Items[item].label or item
            missingItems = missingItems .. ' ' .. weedLabel
        end
        TriggerClientEvent('mWeed:SendNotification', src,
            string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], missingItems))
        return
    end

    local rewardData = Config.GeneralSettings["rewardItems"][item]
    if not rewardData or type(rewardData.items) ~= 'table' or #rewardData.items == 0 then
        return
    end

    local addItems = {}
    local items = rewardData.items

    for i = 1, rewardData.maxamount do
        local item = items[math.random(1, #items)]
        local formattedData = {}

        local existData = GetIncludedItem(addItems, item.name)
        if existData then
            existData.amount = existData.amount + 1
        else
            table.insert(addItems, { name = item.name, label = item.label, amount = 1 })
        end
    end

    local Player = GetPlayer(src)
    if not Player then
        return
    end

    local addedItems = {}
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        for _, v in pairs(addItems) do
            if not Player.canCarryItem(v.name, v.amount) then
                TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["CANT_CARRY"])
                for __, vv in pairs(addedItems) do
                    Player.removeInventoryItem(vv.name, vv.amount)
                    return false
                end
                return false
            end
            Player.addInventoryItem(v.name, v.amount)
            table.insert(addedItems, v)
        end

        Player.removeInventoryItem(item, 1)
        Player.removeInventoryItem(Config.Items['raw_paper'].name, 4)
    else
        for _, v in pairs(addItems) do
            if Player.Functions.AddItem(v.name, v.amount) then
                table.insert(addedItems, v)
            else
                for __, vv in pairs(addedItems) do
                    Player.Functions.RemoveItem(vv.name, vv.amount)
                end
                TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["CANT_CARRY"])
                return false
            end
        end

        Player.Functions.RemoveItem(item, 1)
        Player.Functions.RemoveItem(Config.Items['raw_paper'].name, 4)
    end
    TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["ROLL_WEED_SUCCESS"])
    TriggerClientEvent('mWeed:ShowRollReward', src, addItems)
end)

RegisterServerEvent('mWeed:grindWeed')
AddEventHandler('mWeed:grindWeed', function(item)
    local src = source
    if type(item) ~= 'string' or not ALLOWED_GRIND_INPUT[item] then
        return
    end

    local hasWeed = CheckItem(src, {
        name = item,
        reqAmount = 1,
    })
    local hasGrinder = CheckItem(src, {
        name = Config.Items['grinder'].name,
        reqAmount = 1,
    })

    if not hasWeed or not hasGrinder then
        local missingItems = ""
        if not hasGrinder then
            missingItems = Config.Items["grinder"].label
        end
        if not hasWeed then
            local weedLabel = Config.Items[item] and Config.Items[item].label or item
            missingItems = missingItems .. ' ' .. weedLabel
        end
        TriggerClientEvent('mWeed:SendNotification', src,
            string.format(Config.Notifications["YOU_DONT_HAVE_ITEM"], missingItems))
        return
    end


    local addItem = Config.Items['grinded_sativa'].name
    if item == Config.Items['indica_weed'].name then
        addItem = Config.Items['grinded_indica'].name
    end
    local Player = GetPlayer(src)
    if not Player then
        return
    end

    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        if not Player.canCarryItem(addItem, 1) then
            TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["CANT_CARRY"])
            return
        end
        Player.addInventoryItem(addItem, 1)
        Player.removeInventoryItem(item, 1)
        Player.removeInventoryItem(Config.Items['grinder'].name, 1)
    else
        if not Player.Functions.AddItem(addItem, 1) then
            TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["CANT_CARRY"])
            return
        end
        Player.Functions.RemoveItem(item, 1)
        Player.Functions.RemoveItem(Config.Items['grinder'].name, 1)
    end
    TriggerClientEvent('mWeed:SendNotification', src, Config.Notifications["GRIND_WEED_SUCCESS"])
end)

-- ox_inventory server export for using joints
exports('useJoint', function(source, item, inventory, slot)
    TriggerClientEvent("mWeed:useJoint", source, item.name)
end)

CreateThread(function()
    while not Core do
        Wait(0)
    end
    if Config.Framework == 'esx' or Config.Framework == 'oldesx' then
        for _, v in pairs(Config.UseableItems) do
            Core.RegisterUsableItem(_, function(source)
                local Player = GetPlayer(source)
                Player.removeInventoryItem(_, 1)
                TriggerClientEvent("mWeed:useJoint", source, _)
            end)
        end
    end
end)

Citizen.CreateThread(function()
    local resource_name = 'mWeed'
    local current_version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0)
    PerformHttpRequest('https://raw.githubusercontent.com/Aiakos232/versionchecker/main/version.json',
        function(error, result, headers)
            if not result then
                print('^1Version check disabled because github is down.^0')
                return
            end
            local result = json.decode(result)
            if tonumber(result[resource_name]) ~= nil then
                if tonumber(result[resource_name]) > tonumber(current_version) then
                    print('\n')
                    print('^1======================================================================^0')
                    print('^1' .. resource_name ..
                        ' is outdated, new version is available: ' .. result[resource_name] .. '^0')
                    print('^1======================================================================^0')
                    print('\n')
                elseif tonumber(result[resource_name]) == tonumber(current_version) then
                    print('^2' .. resource_name .. ' is up to date! -  ^4 Thanks for choose CodeM ^4 ^0')
                elseif tonumber(result[resource_name]) < tonumber(current_version) then
                    print('^3' .. resource_name .. ' is a higher version than the official version!^0')
                end
            else
                print('^1' .. resource_name .. ' is not in the version database^0')
            end
        end, 'GET')
end)
