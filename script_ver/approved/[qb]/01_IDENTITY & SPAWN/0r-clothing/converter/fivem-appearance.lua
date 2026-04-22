local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_fivem-appearance_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

exportHandler('getPedModel', function()
    local model = GetEntityModel(PlayerPedId())
    if Config.ModelSaveType == "modelname" then
        model = GetEntityArchetypeName(PlayerPedId())
    end
    return model
end)

exportHandler('getPedComponents', function()
    return reloadSkin()
end)

exportHandler('getPedProps', function()
    return reloadSkin()
end)

exportHandler('getPedHeadBlend', function()
    return reloadSkin()
end)

exportHandler('getPedFaceFeatures', function()
    return reloadSkin()
end)

exportHandler('getPedHeadOverlays', function()
    return reloadSkin()
end)

exportHandler('getPedHair', function()
    return reloadSkin()
end)

exportHandler('getPedTattoos', function()
    return reloadSkin()
end)

exportHandler('getPedAppearance', function(ped)
    local mySkin = nil
    TriggerCallback('0r-clothing:getSkin:server', function(skin)
        mySkin = skin
    end)
    while mySkin == nil do Citizen.Wait(500) end
    local model = GetEntityModel(ped)
    mySkin.model = model
    if Config.ModelSaveType == "modelname" then
        mySkin.model = GetEntityArchetypeName(ped)
    end
    return mySkin
end)

exportHandler('setPlayerModel', function(model)
    model = model ~= nil and (tonumber(model) or GetHashKey(model)) or false
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

exportHandler('setPedComponent', function(var1, var2)
    local ped, component = nil
    if type(var1) == "table" then
        component = var1
        ped = var2
    end
    if type(var2) == "table" then
        component = var2
        ped = var1
    end
    SetPedComponentVariation(ped, component.component_id, component.drawable, component.texture, 0)
end)

exportHandler('setPedComponents', function()
    return reloadSkin()
end)

exportHandler('setPedProp', function(var1, var2)
    local ped, prop = nil
    if type(var1) == "table" then
        prop = var1
        ped = var2
    end
    if type(var2) == "table" then
        prop = var2
        ped = var1
    end
    if prop.drawable == -1 then
        ClearPedProp(ped, prop.prop_id)
    else
        SetPedPropIndex(ped, prop.prop_id, prop.drawable, prop.texture, false)
    end
end)

exportHandler('setPedProps', function()
    return reloadSkin()
end)

exportHandler('setPedFaceFeatures', function()
    return reloadSkin()
end)

exportHandler('setPedHeadOverlays', function()
    return reloadSkin()
end)

exportHandler('setPedHair', function()
    return reloadSkin()
end)

exportHandler('setPedEyeColor', function()
    return reloadSkin()
end)

exportHandler('setPedTattoos', function()
    return reloadSkin()
end)

exportHandler('setPlayerAppearance', function(appearance)
    if appearance.headBlend or appearance.components or appearance.faceFeatures or appearance.headOverlays then
        local newData = ConvertIlleniumToQB(appearance)
        TriggerEvent('0r-clothing:client:loadPlayerClothing', newData, PlayerPedId())
    else
        TriggerEvent('0r-clothing:client:loadPlayerClothing', appearance, ped)
    end
end)

exportHandler('setPedAppearance', function(var1, var2)
    local ped, data = nil
    if type(var1) == "table" then
        data = var1
        ped = var2
    end
    if type(var2) == "table" then
        data = var2
        ped = var1
    end
    if data.headBlend or data.components or data.faceFeatures or data.headOverlays then
        local newData = ConvertIlleniumToQB(data)
        TriggerEvent('0r-clothing:client:loadPlayerClothing', newData, ped)
    else
        TriggerEvent('0r-clothing:client:loadPlayerClothing', data, ped)
    end
end)

exportHandler('startPlayerCustomization', function()
    if CoreName == "qb" then
        Core.Functions.GetPlayerData(function(pData)
            local gender = "male"
            if pData.charinfo.gender == 1 then
                gender = "female"
            end
            createFirstCharacter(gender, Config.CharacterCreationMenuCategories.Normal, true, true)
        end)
    else
        local pData = GetPlayerData()
        if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
            createFirstCharacterWithoutReset("male", Config.CharacterCreationMenuCategories.Normal, true, true)
        else
            createFirstCharacterWithoutReset("female", Config.CharacterCreationMenuCategories.Normal, true, true)
        end
    end
end)