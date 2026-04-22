local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_qb-clothing_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

exportHandler('reloadSkin', function()
    return reloadSkin()
end)

exportHandler('IsCreatingCharacter', function()
    local var = creatingChar or clothingStoreOpen
    return var
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if not creatingChar then
        TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
    end
    PlayerData = GetPlayerData()
end)

RegisterNetEvent("qb-clothes:loadSkin", function(_, model, data)
    model = model ~= nil and tonumber(model) or false
    Citizen.CreateThread(function()
        RequestModel(model)
        while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
        data = json.decode(data)
        TriggerEvent('0r-clothing:client:loadPlayerClothing', data, PlayerPedId())
    end)
end)

RegisterNetEvent('qb-clothing:client:loadPlayerClothing', function(data, ped)
    TriggerEvent('0r-clothing:client:loadPlayerClothing', data, ped)
end)

RegisterNetEvent('qb-clothing:client:loadOutfit', function(oData)
    local ped = PlayerPedId()
    if not oData then return end
    local data = oData.outfitData
    if not data then return end
    if type(data) == "string" and string.sub(data, 1, 1) == "{" then
        data = json.decode(data)
    end
    local validKeys = {
        pants = true,
        arms = true,
        ["arms/gloves"] = true,
        undershirt = true,
        jacket = true,
        ["t-shirt"] = true,
        vest = true,
        torso2 = true,
        shoes = true,
        bag = true,
        decals = true,
        accessory = true,
        mask = true,
        glass = true,
        glasses = true,
        hat = true,
        ear = true,
        watch = true,
        watches = true
    }
    for k in pairs(data) do
        if validKeys[k] then
            if skinData[k] then
                skinData[k].item = data[k].item
                skinData[k].texture = data[k].texture
            else
                skinData[k] = {item = data[k].item, texture = data[k].texture}
            end
            if currentPlayerSkin[k] then
                currentPlayerSkin[k].item = data[k].item
                currentPlayerSkin[k].texture = data[k].texture
            else
                currentPlayerSkin[k] = {item = data[k].item, texture = data[k].texture}
            end
        end
    end
    -- Pants
    if data["pants"] ~= nil then
        SetPedComponentVariation(ped, 4, data["pants"].item, data["pants"].texture, 0)
    end
    -- Arms
    if data["arms"] ~= nil then
        SetPedComponentVariation(ped, 3, data["arms"].item, data["arms"].texture, 0)
    end
    if data["arms/gloves"] ~= nil then
        SetPedComponentVariation(ped, 3, data["arms/gloves"].item, data["arms/gloves"].texture, 0)
    end
    -- T-Shirt
    if data["t-shirt"] ~= nil then
        SetPedComponentVariation(ped, 8, data["t-shirt"].item, data["t-shirt"].texture, 0)
    end
    if data["undershirt"] ~= nil then
        SetPedComponentVariation(ped, 8, data["undershirt"].item, data["undershirt"].texture, 0)
    end
    -- Vest
    if data["vest"] ~= nil then
        SetPedComponentVariation(ped, 9, data["vest"].item, data["vest"].texture, 0)
    end
    -- Torso 2
    if data["torso2"] ~= nil then
        SetPedComponentVariation(ped, 11, data["torso2"].item, data["torso2"].texture, 0)
    end
    if data["jacket"] ~= nil then
        SetPedComponentVariation(ped, 11, data["jacket"].item, data["jacket"].texture, 0)
    end
    -- Shoes
    if data["shoes"] ~= nil then
        SetPedComponentVariation(ped, 6, data["shoes"].item, data["shoes"].texture, 0)
    end
    -- Bag
    if data["bag"] ~= nil then
        SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0)
    end
    -- Badge
    if data["decals"] ~= nil then
        SetPedComponentVariation(ped, 10, data["decals"].item, data["decals"].texture, 0)
    end
    -- Accessory
    if data["accessory"] ~= nil then
        if Core.Functions.GetPlayerData().metadata["tracker"] then
            SetPedComponentVariation(ped, 7, 13, 0, 0)
        else
            SetPedComponentVariation(ped, 7, data["accessory"].item, data["accessory"].texture, 0)
        end
    else
        if Core.Functions.GetPlayerData().metadata["tracker"] then
            SetPedComponentVariation(ped, 7, 13, 0, 0)
        else
            SetPedComponentVariation(ped, 7, -1, 0, 2)
        end
    end
    -- Mask
    if data["mask"] ~= nil then
        SetPedComponentVariation(ped, 1, data["mask"].item, data["mask"].texture, 0)
    end
    -- Bag
    if data["bag"] ~= nil then
        SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0)
    end
    -- Hat
    if data["hat"] ~= nil then
        if data["hat"].item ~= -1 and data["hat"].item ~= 0 then
            SetPedPropIndex(ped, 0, data["hat"].item, data["hat"].texture, true)
        else
            ClearPedProp(ped, 0)
        end
    end
    -- Glass
    if data["glass"] ~= nil then
        if data["glass"].item ~= -1 and data["glass"].item ~= 0 then
            SetPedPropIndex(ped, 1, data["glass"].item, data["glass"].texture, true)
        else
            ClearPedProp(ped, 1)
        end
    end
    if data["glasses"] ~= nil then
        if data["glasses"].item ~= -1 and data["glasses"].item ~= 0 then
            SetPedPropIndex(ped, 1, data["glasses"].item, data["glasses"].texture, true)
        else
            ClearPedProp(ped, 1)
        end
    end
    -- Ear
    if data["ear"] ~= nil then
        if data["ear"].item ~= -1 and data["ear"].item ~= 0 then
            SetPedPropIndex(ped, 2, data["ear"].item, data["ear"].texture, true)
        else
            ClearPedProp(ped, 2)
        end
    end
    -- Watch
    if data["watch"] ~= nil then
        if data["watch"].item ~= -1 and data["watch"].item ~= 0 then
            SetPedPropIndex(ped, 6, data["watch"].item, data["watch"].texture, true)
        else
            ClearPedProp(ped, 6)
        end
    end
    if data["watches"] ~= nil then
        if data["watches"].item ~= -1 and data["watches"].item ~= 0 then
            SetPedPropIndex(ped, 6, data["watches"].item, data["watches"].texture, true)
        else
            ClearPedProp(ped, 6)
        end
    end
end)

RegisterCommand('qb', function()
    Core.Functions.GetPlayerData(function(pData)
        local gender = "male"
        if pData.charinfo.gender == 1 then
            gender = "female"
        end
        createFirstCharacter(gender, Config.CharacterCreationMenuCategories.Normal, true, nottp)
    end)
end)

RegisterNetEvent('qb-clothes:client:CreateFirstCharacter', function(nottp, dontreset)
    if CoreName == "qb" then
        if not dontreset then
            Core.Functions.GetPlayerData(function(pData)
                local gender = "male"
                if pData.charinfo.gender == 1 then
                    gender = "female"
                end
                createFirstCharacter(gender, Config.CharacterCreationMenuCategories.Normal, true, nottp)
            end)
        else
            Core.Functions.GetPlayerData(function(pData)
                local gender = "male"
                if pData.charinfo.gender == 1 then
                    gender = "female"
                end
                createFirstCharacterWithoutReset(gender, Config.CharacterCreationMenuCategories.Normal, true, nottp)
            end)
        end
    else
        if not dontreset then
            local pData = GetPlayerData()
            if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
                createFirstCharacter("male", Config.CharacterCreationMenuCategories.Normal, true, nottp)
            else
                createFirstCharacter("female", Config.CharacterCreationMenuCategories.Normal, true, nottp)
            end
        else
            local pData = GetPlayerData()
            if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
                createFirstCharacterWithoutReset("male", Config.CharacterCreationMenuCategories.Normal, true, nottp)
            else
                createFirstCharacterWithoutReset("female", Config.CharacterCreationMenuCategories.Normal, true, nottp)
            end
        end
    end
end)

RegisterNetEvent('qb-clothes:client:CreateRestrictedCharacter', function(nottp)
    if CoreName == "qb" then
        Core.Functions.GetPlayerData(function(pData)
            local gender = "male"
            if pData.charinfo.gender == 1 then
                gender = "female"
            end
            createFirstCharacterWithoutReset(gender, Config.CharacterCreationMenuCategories.Restricted, true, nottp)
        end)
    else
        local pData = GetPlayerData()
       if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
            createFirstCharacterWithoutReset("male", Config.CharacterCreationMenuCategories.Restricted, true, nottp)
        else
            createFirstCharacterWithoutReset("female", Config.CharacterCreationMenuCategories.Restricted, true, nottp)
        end
    end
end)

RegisterNetEvent('qb-clothing:client:loadPlayerClothing', function(data, ped)
    loadPlayerClothing(data, ped)
end)