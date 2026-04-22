Skin.Cam = nil
Skin.CameraEnabled = false
Skin.CameraZoom = 50.0
Skin.CurrentSkin = {}
Skin.Callbacks = {}
Skin.FirstSpawn = false
local maleTattooData = {}
local maleTattooLabels = {}
local femaleTattooData = {}
local femaleTattooLabels = {}
local currentTattooHash = nil
local currentTattooCollection = nil
local currentTattooZone = nil
local tattooIndex = 0
local pedHeadBlendDataCache = {}
local pedFaceFeaturesCache = {}
local isHeadShrunkCache = {}

for inputName, inputData in pairs(Skin.InputsData) do
    inputData.name = inputName
end

local photoComponentNames = {}
for _, component in pairs(Photos.Components) do
    table.insert(photoComponentNames, component.name)
end

Skin.VariationsToReset = {
    decals_1 = "decals_2",
    shoes_1 = "shoes_2",
    bproof_1 = "bproof_2",
    tshirt_1 = "tshirt_2",
    helmet_1 = "helmet_2",
    mask_1 = "mask_2",
    watches_1 = "watches_2",
    ears_1 = "ears_2",
    glasses_1 = "glasses_2",
    pants_1 = "pants_2",
    bracelets_1 = "bracelets_2",
    torso_1 = "torso_2",
    bags_1 = "bags_2",
    arms_1 = "arms_2"
}

function Skin.TransformSkinTone(value, max)
    while max < value do
        value = value - max
    end
    return value
end

function Skin.ValidateSkinData(skinData)
    local defaultSkin = {
        model = 1885233650,
        dadFace = 0,
        momFace = 0,
        faceMix = 0.5,
        skinMix = 0.5,
        eyeColor = 1,
        hairColor = {
            color = 1,
            highlight = 1
        },
        colorMode = 1,
        gender = "male"
    }
    local isMaleFreemode = skinData.model == GetHashKey("mp_m_freemode_01")
    for key, value in pairs(defaultSkin) do
        if skinData[key] == nil then
            if isMaleFreemode then
                Functions.Debug(string.format("CANNOT FIND REQUIRED VALUE: %s. Setting to default value", key))
                Functions.Debug(debug.traceback())
            end
            skinData[key] = value
        end
    end
    return skinData
end

function Skin.SetOnPed(ped, skinData)
    if not DoesEntityExist(ped) then
        return Functions.Error("Ped given to Skin.SetOnPed function doesn't exist")
    end
    if not skinData then
        return Functions.Error("Skin given to Skin.SetOnPed is nil")
    end
    ClearAllPedProps(ped)
    if PlayerPedId() == ped and skinData and skinData.model and skinData.model ~= GetEntityModel(ped) and GetHashKey(skinData.model) ~= GetEntityModel(ped) then
        Functions.LoadModel(skinData.model)
        SetPlayerModel(PlayerId(), skinData.model)
        ped = PlayerPedId()
        SetPedDefaultComponentVariation(ped)
    end
    ClearPedDecorations(ped)
    for i = 1, 11 do
        SetPedComponentVariation(ped, i, -1, 0, 0)
    end
    -- Treat both male and female freemode models, whether string name or hash
    local function isFreemodeModel(model)
        local hash = (type(model) == "number") and model or GetHashKey(model)
        return hash == GetHashKey("mp_m_freemode_01") or hash == GetHashKey("mp_f_freemode_01")
    end
    local isFreemode = isFreemodeModel(skinData.model)
    skinData = Skin.ValidateSkinData(skinData)
    if not skinData then
        return Functions.Error("Skin after Validation is nil")
    end
    if isFreemode then
        if skinData.dadFace and skinData.momFace and skinData.faceMix and skinData.skinMix then
            local skinDad = skinData.skinDad
            local skinMom = skinData.skinMom
            if not skinDad then
                skinDad = Skin.TransformSkinTone(skinData.dadFace, 45)
            end
            if not skinMom then
                skinMom = Skin.TransformSkinTone(skinData.momFace, 45)
            end
            SetPedHeadBlendData(ped, skinData.dadFace, skinData.momFace, nil, skinDad, skinMom, nil, skinData.faceMix, skinData.skinMix, nil, true)
        end
    end
    local overlayColorTypeMap = {
        [1] = 5,
        [2] = 3,
        [3] = 4
    }
    if isFreemode and skinData.faceData then
        for _, overlay in pairs(skinData.faceData) do
            local ovId = math.floor((overlay.overlayId or 0) + 0.5)
            local ovVal = math.floor((overlay.overlayValue or 0) + 0.5)
            local ovOp = overlay.opacity or 0.0
            if ovOp < 0.0 then ovOp = 0.0 elseif ovOp > 1.0 then ovOp = 1.0 end
            SetPedHeadOverlay(ped, ovId, ovVal, ovOp)
            if overlay.color then
                local colorType = 1
                if overlayColorTypeMap[overlay.overlayId] and skinData and skinData.colorMode then
                    colorType = skinData.colorMode
                end
                local highlight = 0
                if overlay.highlight ~= nil and overlay.highlight then
                    highlight = math.floor(overlay.highlight + 0.5)
                end
                SetPedHeadOverlayColor(ped, ovId, colorType, math.floor((overlay.color or 0) + 0.5), highlight)
            end
        end
    end
    if isFreemode and skinData.faceFeatures then
        for idx, feature in pairs(skinData.faceFeatures) do
            if type(feature) == "table" then
                if feature.index ~= nil and feature.value ~= nil then
                    SetPedFaceFeature(ped, feature.index, feature.value)
                end
            elseif type(feature) == "number" and type(idx) == "number" then
                -- Support map form: [index] = value
                SetPedFaceFeature(ped, idx, feature)
            end
        end
    end
    if skinData.hairColor and skinData.hairColor.color and skinData.hairColor.highlight then
        SetPedHairColor(ped, math.floor(skinData.hairColor.color + 0.5), math.floor(skinData.hairColor.highlight + 0.5))
    end
    if skinData.eyeColor then
        SetPedEyeColor(ped, math.floor(skinData.eyeColor + 0.5))
    end
    if skinData.components then
        for _, component in pairs(skinData.components) do
            if component.component ~= 0 or not isFreemode then
                local texture = component.variation
                if component.component == 2 and component.style then
                    texture = component.style
                end
                SetPedComponentVariation(ped,
                    math.floor(component.component + 0.5),
                    math.floor(component.drawable + 0.5),
                    math.floor(texture + 0.5),
                    0)
            end
        end
    end
    if skinData.props then
        for _, prop in pairs(skinData.props) do
            SetPedPropIndex(ped,
                math.floor((prop.prop or 0) + 0.5),
                math.floor((prop.drawable or 0) + 0.5),
                math.floor((prop.variation or 0) + 0.5),
                true)
        end
    end
    if Skin.EnableAutoMaskClipping then
        isHeadShrunkCache[ped] = false
        pedHeadBlendDataCache[ped] = {}
        pedFaceFeaturesCache[ped] = {}
        Skin.ShrinkFace(ped)
    end
    local modelHash
    if skinData.model == "mp_m_freemode_01" or skinData.model == 1885233650 then
        modelHash = 1885233650
    elseif skinData.model == "mp_f_freemode_01" or skinData.model == -1667301416 then
        modelHash = -1667301416
    else
        modelHash = "custom"
    end
    if Skin.EnableHairFades and modelHash ~= "custom" then
        local collectionHash = Skin.DefaultFade[1]
        local overlayHash = Skin.DefaultFade[2]
        local hairDrawable = 0
        if skinData.components then
            for _, component in pairs(skinData.components) do
                if component.component == 2 then
                    hairDrawable = component.drawable
                end
            end
        end
        if hairDrawable ~= 0 then
            if Skin.HairFades[modelHash] and Skin.HairFades[modelHash][hairDrawable] then
                local fadeData = Skin.HairFades[modelHash][hairDrawable]
                collectionHash = fadeData[1]
                overlayHash = fadeData[2]
            end
        end
        AddPedDecorationFromHashes(ped, collectionHash, overlayHash)
    end
    if skinData.tattoos then
        for _, zoneTattoos in pairs(skinData.tattoos) do
            for _, tattoo in pairs(zoneTattoos) do
                if tattoo.overlay == nil then
                    local hashKey = "hashMale"
                    for _, femaleModel in pairs(Skin.WomanPlayerModels) do
                        if femaleModel == skinData.model or femaleModel == GetHashKey(skinData.model) then
                            hashKey = "hashFemale"
                            break
                        end
                    end
                    if tattoo[hashKey] ~= nil then
                        tattoo.overlay = tattoo[hashKey]
                    end
                end
                if tattoo.overlay then
                    AddPedDecorationFromHashes(ped, tattoo.collection, tattoo.overlay)
                end
            end
        end
    end
    if ped == PlayerPedId() and Config.Framework == "ESX" then
        if Skin.FirstSpawn then
            TriggerServerEvent("esx:onPlayerSpawn")
            TriggerEvent("esx:onPlayerSpawn")
            TriggerEvent("playerSpawned")
            TriggerEvent("esx:restoreLoadout")
            Skin.FirstSpawn = false
        end
        Core.SetPlayerData("ped", ped)
    end
    TriggerServerEvent("rcore_tattoos:reload")
end

function Skin.GetPedHeadBlendData(ped)
    if not DoesEntityExist(ped) then
        return nil
    end
    -- Newer FiveM builds removed Citizen.PointerValue; guard to avoid runtime errors.
    if Citizen and Citizen.PointerValue then
        local buffer = string.rep("\0", 80)
        local success = Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped, Citizen.PointerValue(buffer), true)
        if not success then
            return nil
        end
        local data = {}
        data.shapeFirst = string.unpack("<i4", buffer, 1)
        data.shapeSecond = string.unpack("<i4", buffer, 9)
        data.shapeThird = string.unpack("<i4", buffer, 17)
        data.skinFirst = string.unpack("<i4", buffer, 25)
        data.skinSecond = string.unpack("<i4", buffer, 33)
        data.skinThird = string.unpack("<i4", buffer, 41)
        data.shapeMix = string.unpack("<f", buffer, 49)
        data.skinMix = string.unpack("<f", buffer, 57)
        data.thirdMix = string.unpack("<f", buffer, 65)
        data.hasParent = string.unpack("b", buffer, 73) ~= 0
        for key, value in pairs(data) do
            if tostring(value) == "inf" then
                data[key] = 0.5
            end
        end
        return data
    end
    -- Fallback: not available in Lua without JS/C# wrapper; return nil so callers use defaults/caches.
    return nil
end

function Skin.ConstructFromPed(ped)
    local skin = {}
    skin.model = GetEntityModel(ped)
    skin.components = {}
    skin.props = {}
    skin.faceData = {}
    skin.faceFeatures = {}
    skin.tattoos = {}
    for i = 1, 11 do
        if i == 2 then
            table.insert(skin.components, {
                component = i,
                drawable = GetPedDrawableVariation(ped, i),
                style = GetPedTextureVariation(ped, i),
                variation = GetPedTextureVariation(ped, i)
            })
        else
            table.insert(skin.components, {
                component = i,
                drawable = GetPedDrawableVariation(ped, i),
                variation = GetPedTextureVariation(ped, i)
            })
        end
    end
    for i = 0, 13 do
        table.insert(skin.props, {
            prop = i,
            drawable = GetPedPropIndex(ped, i),
            variation = GetPedPropTextureIndex(ped, i)
        })
    end
    for i = 0, 12 do
        local success, overlayValue, _, color, highlight, opacity = GetPedHeadOverlayData(PlayerPedId(), i)
        if success then
            table.insert(skin.faceData, {
                overlayId = i,
                overlayValue = overlayValue,
                opacity = opacity,
                color = color,
                highlight = highlight
            })
        end
    end
    for i = 0, 19 do
        table.insert(skin.faceFeatures, {index = i, value = GetPedFaceFeature(ped, i)})
    end
    local headBlendData = Skin.GetPedHeadBlendData(ped)
    if headBlendData then
        skin.dadFace = headBlendData.shapeFirst or 1
        skin.momFace = headBlendData.shapeSecond or 1
        skin.faceMix = headBlendData.shapeMix or 0.5
        skin.skinMix = headBlendData.skinMix or 0.5
        skin.skinDad = headBlendData.skinFirst
        skin.skinMom = headBlendData.skinSecond
    end
    local targetPed = ped
    if Skin.CameraEnabled then
        for p in pairs(pedHeadBlendDataCache) do
            targetPed = p
        end
    end
    if pedHeadBlendDataCache[targetPed] and pedHeadBlendDataCache[targetPed].shapeFirst and pedFaceFeaturesCache[targetPed] then
        for i = 0, 19 do
            for _, feature in pairs(skin.faceFeatures) do
                if feature.index == i then
                    feature.value = pedFaceFeaturesCache[targetPed][i]
                end
            end
        end
        skin.dadFace = pedHeadBlendDataCache[targetPed].shapeFirst or 1
        skin.momFace = pedHeadBlendDataCache[targetPed].shapeSecond or 1
        skin.faceMix = pedHeadBlendDataCache[targetPed].shapeMix or 0.5
        skin.skinMix = pedHeadBlendDataCache[targetPed].skinMix or 0.5
        skin.skinDad = pedHeadBlendDataCache[targetPed].skinFirst
        skin.skinMom = pedHeadBlendDataCache[targetPed].skinSecond
    end
    skin.hairColor = {
        color = GetPedHairColor(ped),
        highlight = GetPedHairHighlightColor(ped)
    }
    skin.eyeColor = GetPedEyeColor(ped)
    skin.gender = "male"
    if skin.model then
        for _, femaleModel in pairs(Skin.WomanPlayerModels) do
            if GetHashKey(femaleModel) == skin.model then
                skin.gender = "female"
                break
            end
        end
    end
    local function toUnsigned(n)
        if n < 0 then
            return n + 4294967296
        end
        return n
    end
    local decorations = GetPedDecorations(ped)
    for _, decoration in pairs(decorations) do
        local decorationHash = toUnsigned(decoration[2])
        for zone, zoneTattoos in pairs(Skin.Tattoos) do
            for _, tattoo in pairs(zoneTattoos) do
                local hashMale = toUnsigned(joaat(tattoo.hashMale))
                local hashFemale = toUnsigned(joaat(tattoo.hashFemale))
                if decorationHash == hashMale or decorationHash == hashFemale then
                    if not skin.tattoos[tattoo.zone] then
                        skin.tattoos[tattoo.zone] = {}
                    end
                    local newTattoo = {collection = tattoo.collection}
                    if skin.gender == "female" then
                        newTattoo.overlay = tattoo.hashFemale
                    else
                        newTattoo.overlay = tattoo.hashMale
                    end
                    table.insert(skin.tattoos[tattoo.zone], newTattoo)
                end
            end
        end
    end
    return skin
end

function Skin.UpdateComponentInputs(componentData, sendNuiMessage)
    local playerPed = PlayerPedId()
    local model = GetEntityModel(playerPed)
    local isFreemode = model == 1885233650 or model == -1667301416
    local headBlendData = Skin.GetPedHeadBlendData(playerPed)
    local inputs = {}
    for _, inputName in pairs(componentData.inputs) do
        local canAddInput = true
        if Skin.CurrentRestriction ~= nil and not Skin.CurrentRestriction[inputName] then
            canAddInput = false
        end
        if canAddInput then
            local inputData = Skin.InputsData[inputName]
            if type(inputName) == "string" and inputData and inputData.mapping then
                local new_inputData = Functions.DeepCopy(inputData)
                local minVal = nil
                local maxVal = nil
                local currentVal = 0
                local values = nil
                local colors = nil
                local label = nil
                local isEnabled = true
                if inputData.type == "color" then
                    colors = Skin.HairColors
                end
                local mappingIndex = tonumber(inputData.mapping:match("%[(%d+)%]")) or 0
                local mappingKey = inputData.mapping:match("%.([%w_]+)$")
                if isFreemode then
                    if inputData.mapping:find("faceFeatures") then
                        local targetPed = playerPed
                        if Skin.CameraEnabled then
                            for p, _ in pairs(pedHeadBlendDataCache) do
                                if IsPedAPlayer(p) then
                                    targetPed = p
                                end
                            end
                        end
                        local foundInCache = false
                        if pedFaceFeaturesCache[targetPed] and pedFaceFeaturesCache[targetPed][mappingIndex] then
                            currentVal = pedFaceFeaturesCache[targetPed][mappingIndex]
                            foundInCache = true
                        end
                        if not foundInCache then
                            currentVal = (GetPedFaceFeature(playerPed, mappingIndex) + 1.0) / 2
                        end
                    end
                    if inputData.mapping:find("faceData") then
                        local success, overlayValue, _, color, highlight, opacity = GetPedHeadOverlayData(playerPed, mappingIndex)
                        if mappingKey == "overlayValue" then
                            minVal = 0
                            maxVal = GetNumHeadOverlayValues(mappingIndex) + 1
                            currentVal = overlayValue or 0
                            if currentVal == 255 then
                                currentVal = 0
                            elseif currentVal == 0 then
                                currentVal = 1
                            elseif currentVal > -1 then
                                currentVal = currentVal + 1
                            end
                        elseif mappingKey == "color" then
                            currentVal = color or 0
                        elseif mappingKey == "highlight" then
                            currentVal = highlight or 0
                        elseif mappingKey == "opacity" then
                            currentVal = opacity or 0.0
                            if currentVal == 1.0 then
                                currentVal = 0.99
                            elseif currentVal == 0.0 then
                                currentVal = 0.01
                            end
                            currentVal = (currentVal - 0.15) / 0.84
                        else
                            currentVal = 0
                        end
                    end
                end
                if inputData.mapping:find("components") then
                    minVal = 0
                    if mappingKey == "drawable" then
                        maxVal = GetNumberOfPedDrawableVariations(playerPed, mappingIndex)
                    elseif mappingKey == "variation" or mappingKey == "style" then
                        maxVal = GetNumberOfPedTextureVariations(playerPed, mappingIndex, GetPedDrawableVariation(playerPed, mappingIndex))
                    end
                    if mappingKey == "drawable" then
                        currentVal = GetPedDrawableVariation(playerPed, mappingIndex)
                    else
                        currentVal = GetPedTextureVariation(playerPed, mappingIndex)
                    end
                end
                if inputData.mapping:find("props") then
                    minVal = 0
                    if mappingKey == "drawable" then
                        maxVal = GetNumberOfPedPropDrawableVariations(playerPed, mappingIndex)
                    else
                        maxVal = GetNumberOfPedPropTextureVariations(playerPed, mappingIndex, GetPedPropIndex(playerPed, mappingIndex))
                    end
                    if mappingKey == "drawable" then
                        currentVal = GetPedPropIndex(playerPed, mappingIndex)
                    else
                        currentVal = GetPedPropTextureIndex(playerPed, mappingIndex)
                    end
                end
                if isFreemode and inputData.mapping:find("tattoos") then
                    local zone = Skin.TattosIndexTranslator[mappingIndex]
                    local isMale = model == 1885233650
                    if mappingKey == "hash" then
                        if isMale then
                            maxVal = #maleTattooLabels[zone]
                        else
                            maxVal = #femaleTattooLabels[zone]
                        end
                        if isMale then
                            values = maleTattooLabels[zone]
                        else
                            values = femaleTattooLabels[zone]
                        end
                        currentVal = tattooIndex
                    elseif mappingKey == "owned" then
                        if currentTattooHash and currentTattooHash ~= "" then
                            currentVal = 1
                            local found = false
                            if Skin.CurrentSkin[model].tattoos[currentTattooZone] then
                                for _, tattoo in pairs(Skin.CurrentSkin[model].tattoos[currentTattooZone]) do
                                    if tattoo.overlay == currentTattooHash then
                                        currentVal = 0
                                        if not Skin.EnableTattoosDeleting then
                                            isEnabled = false
                                        end
                                        found = true
                                    end
                                end
                            end
                            if currentVal == 1 then
                                label = _L("Skin.Tattoo.AddTattoo")
                            else
                                label = _L("Skin.Tattoo.RemoveTatto")
                            end
                        else
                            isEnabled = false
                        end
                    end
                    minVal = 0
                end
                if isFreemode and inputName == "hair_3" then
                    colors = Skin.HairColors
                    currentVal = GetPedHairColor(playerPed)
                end
                if isFreemode and inputName == "hair_4" then
                    colors = Skin.HairColors
                    currentVal = GetPedHairHighlightColor(playerPed)
                end
                if isFreemode and inputName == "eye_color" then
                    minVal = 0
                    maxVal = Skin.MaxEyeColorValue or 32
                    currentVal = GetPedEyeColor(playerPed)
                end
                if isFreemode and inputName == "mom" then
                    local targetPed = playerPed
                    if Skin.CameraEnabled then
                        for p, _ in pairs(pedHeadBlendDataCache) do
                            if IsPedAPlayer(p) then
                                targetPed = p
                            end
                        end
                    end
                    local foundInCache = false
                    if pedHeadBlendDataCache[targetPed] and pedHeadBlendDataCache[targetPed].shapeSecond then
                        for i, faceId in pairs(Skin.FemaleFaceTranslation) do
                            if faceId == pedHeadBlendDataCache[targetPed].shapeSecond then
                                currentVal = i
                                foundInCache = true
                                break
                            end
                        end
                    end
                    minVal = 0
                    maxVal = #Skin.FemaleFaceTranslation + 1
                    if not foundInCache then
                        for i, faceId in pairs(Skin.FemaleFaceTranslation) do
                            if headBlendData and faceId == headBlendData.shapeSecond then
                                currentVal = i
                            end
                        end
                    end
                end
                if isFreemode and inputName == "dad" then
                    local targetPed = playerPed
                    if Skin.CameraEnabled then
                        for p, _ in pairs(pedHeadBlendDataCache) do
                            if IsPedAPlayer(p) then
                                targetPed = p
                            end
                        end
                    end
                    local foundInCache = false
                    if pedHeadBlendDataCache[targetPed] and pedHeadBlendDataCache[targetPed].shapeFirst then
                        for i, faceId in pairs(Skin.MaleFaceTranslation) do
                            if faceId == pedHeadBlendDataCache[targetPed].shapeFirst then
                                -- Use UI index, not internal faceId
                                currentVal = i
                                foundInCache = true
                            end
                        end
                    end
                    minVal = 0
                    maxVal = #Skin.MaleFaceTranslation + 1
                    if not foundInCache then
                        for i, faceId in pairs(Skin.MaleFaceTranslation) do
                            if headBlendData and faceId == headBlendData.shapeFirst then
                                currentVal = i
                            end
                        end
                    end
                end
                if isFreemode and inputName == "skinDad" then
                    minVal = 0
                    maxVal = 45
                    if headBlendData then
                        currentVal = headBlendData.skinFirst
                    end
                end
                if isFreemode and inputName == "skinMom" then
                    minVal = 0
                    maxVal = 45
                    if headBlendData then
                        currentVal = headBlendData.skinSecond
                    end
                end
                if isFreemode and inputName == "skinMix" then
                    currentVal = (headBlendData and headBlendData.skinMix) or 0.5
                end
                if isFreemode and inputName == "faceMix" then
                    currentVal = (headBlendData and headBlendData.shapeMix) or 0.5
                end
                if inputName == "sex" then
                    local modelList = Skin.ManPlayerModels
                    if Skin.CurrentSkin[model] and Skin.CurrentSkin[model].gender == "female" then
                        modelList = Skin.WomanPlayerModels
                    end
                    local currentIndex = 0
                    for i, m in pairs(modelList) do
                        if GetHashKey(m) == (Skin.CurrentSkin[model] and Skin.CurrentSkin[model].sex) then
                            currentIndex = i
                            break
                        end
                    end
                    minVal = 1
                    maxVal = #modelList + 1
                    currentVal = currentIndex
                end
                if Skin.InputsToShift[inputName] then
                    minVal = 0
                    maxVal = maxVal + 1
                    if currentVal == -1 then
                        currentVal = 0
                    elseif currentVal == 0 then
                        currentVal = 1
                    else
                        currentVal = currentVal + 1
                    end
                end
                if maxVal then
                    maxVal = maxVal - 1
                end
                if isEnabled then
                    new_inputData.min = minVal
                    new_inputData.max = maxVal
                    local currentModel = GetEntityModel(PlayerPedId())
                    if currentVal == -1 and Skin.CurrentSkin[currentModel] then
                        currentVal = Skin.CurrentSkin[currentModel][inputName]
                    end
                    new_inputData.value = currentVal
                    new_inputData.colors = colors
                    new_inputData.values = values
                    if label then
                        new_inputData.label = label
                    end
                    local canInsert = isFreemode or inputData.type ~= "number" or not maxVal or maxVal <= 0
                    if not canInsert then
                        if mappingKey == "variation" and maxVal and maxVal >= 1 then
                            canInsert = true
                        else
                            canInsert = false
                        end
                    end
                    if canInsert then
                        table.insert(inputs, new_inputData)
                    end
                end
            end
        end
    end
    local updatedComponent = Functions.DeepCopy(componentData)
    updatedComponent.inputs = inputs
    if sendNuiMessage then
        Functions.SendNuiMessage("UpdateComponent", {component = updatedComponent})
    end
    return updatedComponent
end

function Skin.RestartComponentsValues(presetName, sendNuiMessage)
    local components = {}
    if not presetName or presetName == "all" then
        for _, component in pairs(Skin.Components) do
            local updatedComponent = Skin.UpdateComponentInputs(component, sendNuiMessage)
            table.insert(components, updatedComponent)
        end
    else
        local preset = Skin.Presets[presetName]
        if not preset then
            return Functions.Print(string.format("You called OpenClothingMenu() function with %s preset, but it's not exist's in Config.Presets", presetName))
        end
        for i = 1, #preset do
            local componentName = preset[i]
            local found = false
            for j = 1, #Skin.Components do
                local component = Skin.Components[j]
                if component.name == componentName then
                    local updatedComponent = Skin.UpdateComponentInputs(component, sendNuiMessage)
                    found = true
                    table.insert(components, updatedComponent)
                    break
                end
            end
            if not found then
                Functions.Print(string.format("Preset %s from Config.Presets has %s component, but it's not exit's into Config.Components", presetName, componentName))
            end
        end
    end
    return components
end

function Skin.OpenMenu(buttons, preset, isNewSession, isMale, lastCoordinates)
    local initialSkin = Skin.ConstructFromPed(PlayerPedId())
    local model = (isNewSession and (isMale and 1885233650 or -1667301416)) or initialSkin.model
    if model == nil then
        return
    end
    tattooIndex = 0
    Skin.OutfitOnStart = initialSkin
    Skin.alreadyPaid = false
    Skin.CurrentPreset = preset
    Skin.CurrentSessionIsNew = isNewSession
    Skin.lastCoordinates = lastCoordinates
    Skin.CurrentSessionIsShop = preset == "surgeon" or preset == "barber" or preset == "clothing" or preset == "tattoo"
    TriggerEvent("17mov_CharacterSystem:SkinMenuOpened")
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)
    local maxArmor = GetPlayerMaxArmour(PlayerId())
    local armor = GetPedArmour(playerPed)
    if Core and Config.Framework == "QBCore" and Core.GetPlayerData ~= nil then
        PlayerData = Core.GetPlayerData()
        armor = PlayerData.metadata.armor
    end
    Functions.LoadModel(model)
    SetPlayerModel(PlayerId(), model)
    local newPlayerPed = PlayerPedId()
    SetPedDefaultComponentVariation(newPlayerPed)
    CreateThread(function()
        if GetResourceState("wasabi_ambulance") == "started" then
            Wait(2000)
        end
        SetPedMaxHealth(newPlayerPed, maxHealth)
        SetEntityHealth(newPlayerPed, health)
        SetPlayerMaxArmour(PlayerId(), maxArmor)
        SetPedArmour(newPlayerPed, armor)
    end)
    local newSkin
    if isNewSession then
        if Skin.GenerateRandomSkin then
            newSkin = GenerateRandomSkin(isMale and "male" or "female")
        end
        if not newSkin then
            newSkin = Skin.ConstructFromPed(PlayerPedId())
        end
        Skin.CurrentSkin[model] = TranslateToHuman(newSkin)
        Skin.CurrentSkin[model].sex = model
        Skin.CurrentSkin[model].gender = isMale and "male" or "female"
        SetEntityCoords(newPlayerPed, Skin.CreatingPoint.x, Skin.CreatingPoint.y, Skin.CreatingPoint.z, false, false, false, false)
        SetEntityHeading(newPlayerPed, Skin.CreatingPoint.w)
        FreezeEntityPosition(newPlayerPed, true)
        SetEntityVisible(newPlayerPed, true, true)
        TriggerServerEvent("17mov_CharacterSystem:MakeSureOfBucket")
    else
        Skin.CurrentSkin[model] = TranslateToHuman(initialSkin)
    end
    Skin.SetOnPed(newPlayerPed, TranslateToInternal(Skin.CurrentSkin[model]))
    local components = Skin.RestartComponentsValues(preset, false)
    local modelList = Skin.ManPlayerModels
    if Skin.CurrentSkin[model].gender == "female" then
        modelList = Skin.WomanPlayerModels
    end
    local modelName = "mp_m_freemode_01"
    for _, name in pairs(modelList) do
        if GetHashKey(name) == Skin.CurrentSkin[model].sex then
            modelName = name
            break
        end
    end
    local blacklisted = Functions.DeepCopy(Skin.BlacklistedInputValues[model])
    local whitelisted = Skin.WhitelistedInputValues[model]
    if whitelisted and blacklisted then
        for _, whitelistItem in pairs(whitelisted) do
            local name = whitelistItem.name
            if blacklisted[name] then
                local shouldRemove = false
                if whitelistItem.jobs and #whitelisted.jobs > 0 then
                    local job = GetJob()
                    for _, j in pairs(whitelistItem.jobs) do
                        if job == j then
                            shouldRemove = true
                            break
                        end
                    end
                end
                if whitelistItem.gangs and #whitelisted.gangs > 0 then
                    local gang = GetGang()
                    for _, g in pairs(whitelistItem.gangs) do
                        if gang == g then
                            shouldRemove = true
                            break
                        end
                    end
                end
                if whitelistItem.identifiers and #whitelisted.identifiers > 0 then
                    local identifier = GetIdentifier()
                    for _, id in pairs(whitelistItem.identifiers) do
                        if identifier == id then
                            shouldRemove = true
                            break
                        end
                    end
                end
                if shouldRemove then
                    for _, val in pairs(whitelistItem.values) do
                        for i = 1, #blacklisted[name] do
                            if blacklisted[name][i] == val then
                                table.remove(blacklisted[name], i)
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    Functions.SendNuiMessage("SetPhotoData", {model = modelName, inputs = photoComponentNames})
    Skin.EnterCamera()
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    Functions.SendNuiMessage("ToggleSkin", {
        state = true,
        categories = Skin.Categories,
        blacklisted = blacklisted,
        components = components,
        buttons = buttons
    })
end

function Skin.CloseMenu(forceNoFocus)
    Skin.ExitCamera()
    if not forceNoFocus then
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
    end
    Functions.SendNuiMessage("ToggleSkin", {state = false})
    Skin.CurrentRestriction = nil
    Skin.Callbacks = {}
    TriggerEvent("17mov_CharacterSystem:SkinMenuClosed")
end

function Skin.EnterCamera()
    local heading = GetEntityHeading(PlayerPedId())
    local rot_z = (heading + 90.0) % 360.0
    local rot_y = 0.0
    Skin.Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(Skin.Cam, true)
    RenderScriptCams(true, false, 0, true, true)
    Skin.CameraEnabled = true
    Functions.RequestAnimDict("move_m@generic")
    Functions.RequestAnimDict("move_f@generic")
    local hiddenPeds = {}
    CreateThread(function()
        while Skin.CameraEnabled do
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local model = GetEntityModel(playerPed)
            local animDict = "move_m@generic"
            if model and Skin.CurrentSkin[model] and Skin.CurrentSkin[model].gender == "female" then
                animDict = "move_f@generic"
            end
            TaskPlayAnim(playerPed, animDict, "idle", 8.0, 8.0, -1, 1, 0.0, true, true, true)
            local move_lr = 0
            local move_ud = 0
            if IsNuiFocusKeepingInput() then
                move_lr = GetDisabledControlNormal(0, 1)
                move_ud = GetDisabledControlNormal(0, 2)
            end
            if math.abs(move_lr) > math.abs(move_ud) or math.abs(move_lr) > 0.15 then
                heading = heading + (move_lr * 20.0) % 360.0
            end
            if math.abs(move_lr) < math.abs(move_ud) or math.abs(move_ud) > 0.15 then
                rot_y = rot_y + (move_ud * 0.15)
            end
            if rot_y < -0.8 then
                rot_y = -0.8
            elseif rot_y > 0.65 then
                rot_y = 0.65
            end
            local offsetX = 2.5 * math.cos(math.rad(rot_z))
            local offsetY = 2.5 * math.sin(math.rad(rot_z))
            local camCoords = vector3(coords.x + offsetX, coords.y + offsetY, coords.z + rot_y)
            SetCamCoord(Skin.Cam, camCoords.x, camCoords.y, camCoords.z)
            if Skin.CameraZoom < 10.0 then
                Skin.CameraZoom = 10.0
            elseif Skin.CameraZoom > 50 then
                Skin.CameraZoom = 50.0
            end
            SetCamFov(Skin.Cam, Skin.CameraZoom)
            PointCamAtCoord(Skin.Cam, coords.x, coords.y, camCoords.z)
            SetEntityHeading(playerPed, heading)
            DisableAllControlActions(0)
            if Skin.CurrentSessionIsNew then
                for _, p in ipairs(GetActivePlayers()) do
                    local ped = GetPlayerPed(p)
                    if ped ~= playerPed then
                        SetEntityVisible(ped, false, false)
                        table.insert(hiddenPeds, ped)
                    end
                end
            end
            Wait(0)
        end
        for _, ped in ipairs(hiddenPeds) do
            SetEntityVisible(ped, true, false)
        end
        hiddenPeds = {}
        ClearPedTasksImmediately(PlayerPedId())
        FreezeEntityPosition(PlayerPedId(), false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(Skin.Cam, false)
        Skin.Cam = nil
        Skin.CameraZoom = 50.0
    end)
end

function Skin.ExitCamera()
    Skin.CameraEnabled = false
end

RegisterNUICallback("SkinToggleCamMovement", function(data, cb)
    SetNuiFocusKeepInput(data.state)
    cb({})
end)

RegisterNUICallback("SkinZoomCam", function(data, cb)
    local targetZoom = Skin.CameraZoom + data.value / 15
    local startZoom = Skin.CameraZoom
    local duration = 0.08
    local startTime = GetGameTimer() / 1000
    CreateThread(function()
        while true do
            local elapsed = (GetGameTimer() / 1000) - startTime
            if elapsed >= duration then
                Skin.CameraZoom = targetZoom
                break
            end
            Skin.CameraZoom = Functions.Lerp(startZoom, targetZoom, elapsed / duration)
            Wait(0)
        end
    end)
    cb({})
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent("qb-clothes:loadPlayerSkin")
    TriggerServerEvent("17mov_CharacterSystem:ReturnToBucket")
end)

RegisterNUICallback("SkinClose", function(data, cb)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)
    local maxArmor = GetPlayerMaxArmour(PlayerId())
    local armor = GetPedArmour(playerPed)
    if Config.Framework == "QBCore" then
        Core.Functions.TriggerCallback("qb-clothing:server:getPlayerSkin", function(playerSkin)
            local skin = TranslateSkinFromQB(playerSkin.skin, playerSkin.model)
            Skin.SetOnPed(PlayerPedId(), skin)
            CreateThread(function()
                if GetResourceState("wasabi_ambulance") == "started" then
                    Wait(2000)
                end
                local ped = PlayerPedId()
                SetPedMaxHealth(ped, maxHealth)
                SetEntityHealth(ped, health)
                SetPlayerMaxArmour(PlayerId(), maxArmor)
                SetPedArmour(ped, armor)
            end)
        end)
    elseif Config.Framework == "ESX" then
        Core.TriggerServerCallback("esx_skin:getPlayerSkin", function(playerSkin)
            local skin = TranslateSkinFromESX(playerSkin)
            Skin.SetOnPed(PlayerPedId(), skin)
            CreateThread(function()
                if GetResourceState("wasabi_ambulance") == "started" then
                    Wait(2000)
                end
                local ped = PlayerPedId()
                SetPedMaxHealth(ped, maxHealth)
                SetEntityHealth(ped, health)
                SetPlayerMaxArmour(PlayerId(), maxArmor)
                SetPedArmour(ped, armor)
            end)
        end)
    end
    if Skin.Callbacks.Cancel then
        Skin.Callbacks.Cancel()
    end
    Skin.CloseMenu()
    cb({})
end)

RegisterNetEvent("17mov_CharacterSystem:SaveCurrentSkin", function()
    local skin = Skin.ConstructFromPed(PlayerPedId())
    local model = GetEntityModel(PlayerPedId())
    if Config.Framework == "QBCore" then
        local qbSkin = TranslateSkinToQB(skin)
        TriggerServerEvent("qb-clothing:saveSkin", nil, qbSkin)
    else
        local esxSkin = TranslateSkinToESX(skin)
        esxSkin.model = model
        TriggerServerEvent("esx_skin:save", esxSkin)
    end
end)

RegisterNUICallback("SaveInWarderobe", function(data, cb)
    local model = GetEntityModel(PlayerPedId())
    if not Skin.alreadyPaid then
        local currentOutfit = Skin.ConstructFromPed(PlayerPedId())
        local outfitsDifferent = not deepCompareTables(currentOutfit, Skin.OutfitOnStart)
        if outfitsDifferent then
            Functions.TriggerServerCallback("17mov_CharacterSystem:TryToCharge", function(success)
                Skin.alreadyPaid = success
                if not success then
                    return Notify(_L("Store.NotEnoughMoney"))
                end
            end, Skin.CurrentSessionStoreIndex)
        end
    end
    if Config.Framework == "QBCore" then
        Core.Functions.TriggerCallback("qb-clothing:server:getPlayerSkin", function(playerSkin)
            local internalSkin = TranslateToInternal(Skin.CurrentSkin[model])
            local qbSkin = TranslateSkinToQB(internalSkin)
            TriggerServerEvent("qb-clothes:saveOutfit", data.value, playerSkin.model, qbSkin, internalSkin)
        end)
    else
        local esxSkin = TranslateSkinToESX(TranslateToInternal(Skin.CurrentSkin[model]))
        TriggerServerEvent("17mov_CharacterSystem:SaveOutfit", esxSkin, data.value)
    end
    cb({})
end)

function deepCompareTables(t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then
        return false
    end
    for k, v in pairs(t1) do
        local v2 = t2[k]
        if type(v) == "table" and type(v2) == "table" then
            if not deepCompareTables(v, v2) then
                return false
            end
        elseif v ~= v2 then
            return false
        end
    end
    for k, _ in pairs(t2) do
        if t1[k] == nil then
            return false
        end
    end
    return true
end

RegisterNUICallback("SkinSave", function(data, cb)
    cb({})
    if Config.Showcase then
        local model = GetEntityModel(PlayerPedId())
        local internalSkin = TranslateToInternal(Skin.CurrentSkin[model])
        local qbSkin = TranslateSkinToQB(internalSkin)
        Skin.SetOnPed(PlayerPedId(), internalSkin)
        if Skin.CurrentSessionIsNew then
            TriggerServerEvent("qb-clothes:saveOutfit", _L("Bridge.Wardrobe.StartingOutfit"), model, qbSkin, internalSkin)
            DoScreenFadeOut(100)
            Wait(200)
            if Location.Enable then
                Location.Enter(Location.DefaultSpawnLocation, Skin.CurrentSessionIsNew)
            else
                Location.SpawnPlayer({
                    name = "lastLocation",
                    coords = Location.DefaultSpawnLocation,
                    label = _L("Location.LastLocation"),
                    type = "location"
                }, Skin.CurrentSessionIsNew)
                SetNuiFocus(false, false)
            end
            Skin.CloseMenu(true)
        else
            Skin.CloseMenu()
        end
        return
    end
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)
    local model = GetEntityModel(PlayerPedId())
    local internalSkin = TranslateToInternal(Skin.CurrentSkin[model])
    Skin.SetOnPed(PlayerPedId(), internalSkin)
    if Skin.CurrentSessionIsShop then
        local currentOutfit = Skin.ConstructFromPed(PlayerPedId())
        local paymentNeeded = not deepCompareTables(currentOutfit, Skin.OutfitOnStart)
        if paymentNeeded then
            local paid = Skin.alreadyPaid
            local waitingForPayment = not Skin.alreadyPaid
            if waitingForPayment then
                Functions.TriggerServerCallback("17mov_CharacterSystem:TryToCharge", function(success)
                    paid = success
                    waitingForPayment = false
                    if not success then
                        return Notify(_L("Store.NotEnoughMoney"))
                    end
                end, Skin.CurrentSessionStoreIndex)
                while waitingForPayment do
                    Citizen.Wait(100)
                end
            end
        end
    end
    if Config.Framework == "QBCore" then
        local qbSkin = TranslateSkinToQB(internalSkin)
        TriggerServerEvent("qb-clothing:saveSkin", model, qbSkin)
        if Skin.CurrentSessionIsNew then
            TriggerServerEvent("qb-clothes:saveOutfit", _L("Bridge.Wardrobe.StartingOutfit"), model, qbSkin, internalSkin)
        end
    else
        local esxSkin = TranslateSkinToESX(internalSkin)
        TriggerServerEvent("esx_skin:save", esxSkin)
    end
    if Skin.CurrentSessionIsShop then
        CreateThread(function()
            if GetResourceState("wasabi_ambulance") == "started" then
                Wait(2000)
            end
            SetPedMaxHealth(PlayerId(), maxHealth)
            SetEntityHealth(PlayerPedId(), health)
        end)
    end
    if Skin.CurrentSessionIsNew then
        DoScreenFadeOut(100)
        Wait(250)
        Skin.SetOnPed(PlayerPedId(), internalSkin)
        if Location.Enable and Location.EnableForNewCharacters then
            Location.Enter(Location.DefaultSpawnLocation, Skin.CurrentSessionIsNew)
        else
            Location.SpawnPlayer({
                name = "lastLocation",
                coords = Location.DefaultSpawnLocation,
                label = _L("Location.LastLocation"),
                type = "location"
            }, Skin.CurrentSessionIsNew)
            SetNuiFocus(false, false)
        end
        if Skin.Callbacks.Submit then
            Skin.Callbacks.Submit()
        end
        Skin.CloseMenu(true)
    else
        if Skin.Callbacks.Submit then
            Skin.Callbacks.Submit()
        end
        Skin.CloseMenu()
    end
end)

RegisterNUICallback("UpdateClothingComponent", function(data, cb)
    if currentTattooHash ~= nil then
        ClearPedDecorations(PlayerPedId())
    end
    if data.component:find("ZONE") and not data.component:find("SAVE") then
        tattooIndex = data.value
    end
    local function normalizeNumber(v)
        if v == nil then return nil end
        local s = tostring(v)
        s = s:gsub(",", ".")
        return tonumber(s)
    end
    if data.type == "range" then
        local raw = normalizeNumber(data.value) or 0
        -- Clamp slider to [0, 1]
        if raw < 0.0 then raw = 0.0 elseif raw > 1.0 then raw = 1.0 end
        local inputData = Skin.InputsData[data.component]
        if inputData then
            if inputData.mapping:find("faceFeatures") then
                data.value = 2 * raw - 1
            else
                data.value = 0.84 * raw + 0.15
                -- Ensure mix stays within native bounds
                if data.value < 0.0 then data.value = 0.0 elseif data.value > 1.0 then data.value = 1.0 end
            end
        else
            data.value = raw
        end
    else
        -- Coerce non-range numeric inputs safely when possible
        local num = normalizeNumber(data.value)
        if num ~= nil then
            if data.type == "number" then
                -- Discrete indices (overlay types, components, props) should be integers
                data.value = math.floor(num + 0.5)
            else
                data.value = num
            end
        end
    end
    local model = GetEntityModel(PlayerPedId())
    if data.component == "mom" then
        local targetPed = PlayerPedId()
        for p in pairs(pedHeadBlendDataCache) do
            if IsPedAPlayer(p) then
                targetPed = p
            end
        end
        local translated = Skin.FemaleFaceTranslation[data.value]
        if pedHeadBlendDataCache[targetPed] and pedHeadBlendDataCache[targetPed].shapeSecond then
            -- Cache should store internal faceId, not UI index
            pedHeadBlendDataCache[targetPed].shapeSecond = translated
        end
        data.value = translated
    end
    if data.component == "dad" then
        local targetPed = PlayerPedId()
        for p in pairs(pedHeadBlendDataCache) do
            if IsPedAPlayer(p) then
                targetPed = p
            end
        end
        local translated = Skin.MaleFaceTranslation[data.value]
        if pedHeadBlendDataCache[targetPed] and pedHeadBlendDataCache[targetPed].shapeFirst then
            -- Cache should store internal faceId, not UI index
            pedHeadBlendDataCache[targetPed].shapeFirst = translated
        end
        data.value = translated
    end
    if data.component == "sex" then
        local gender = Skin.CurrentSkin[model].gender
        if gender == "male" then
            data.value = Skin.ManPlayerModels[data.value]
        else
            data.value = Skin.WomanPlayerModels[data.value]
        end
        if data and data.value ~= nil then
            Functions.LoadModel(data.value)
            SetPlayerModel(PlayerId(), data.value)
        end
        local playerPed = PlayerPedId()
        SetPedDefaultComponentVariation(playerPed)
        for modelHash, skinData in pairs(Skin.CurrentSkin) do
            if modelHash == GetHashKey(data.value) then
                Skin.SetOnPed(playerPed, TranslateToInternal(skinData))
                break
            end
        end
        Functions.SendNuiMessage("SetPhotoData", {model = data.value, inputs = photoComponentNames})
        local newModelHash = GetHashKey(data.value)
        Skin.CurrentSkin[newModelHash] = TranslateToHuman(Skin.ConstructFromPed(playerPed))
        Skin.RestartComponentsValues(Skin.CurrentPreset, true)
    else
        local affectedComponents = {}
        local componentName = data.component:find("ZONE") and string.gsub(data.component, "_SAVE", "") or data.component
        for _, comp in pairs(Skin.Components) do
            for _, input in pairs(comp.inputs) do
                if input == componentName then
                    table.insert(affectedComponents, comp)
                end
            end
        end
        local inputData = Skin.InputsData[data.component]
        if inputData and inputData.mapping:find("faceData") and data.type == "number" then
            data.value = data.value - 1
        end
        if Skin.InputsToShift[data.component] then
            data.value = data.value - 1
        end
        if Skin.VariationsToReset[data.component] then
            Skin.CurrentSkin[model][Skin.VariationsToReset[data.component]] = 0
        end
        if not data.component:find("ZONE") then
            Skin.CurrentSkin[model][data.component] = data.value
        end
        if data.component:find("ZONE_SAVE") and (model == 1885233650 or model == -1667301416) then
            if currentTattooCollection and currentTattooHash and currentTattooZone then
                if data.value == 0 then
                    if Skin.CurrentSkin[model].tattoos == nil then
                        Skin.CurrentSkin[model].tattoos = {}
                    end
                    if Skin.CurrentSkin[model].tattoos[currentTattooZone] == nil then
                        Skin.CurrentSkin[model].tattoos[currentTattooZone] = {}
                    end
                    table.insert(Skin.CurrentSkin[model].tattoos[currentTattooZone], {collection = currentTattooCollection, overlay = currentTattooHash})
                elseif data.value == 1 then
                    if Skin.CurrentSkin[model].tattoos and Skin.CurrentSkin[model].tattoos[currentTattooZone] then
                        for i, tattoo in pairs(Skin.CurrentSkin[model].tattoos[currentTattooZone]) do
                            if tattoo.collection == currentTattooCollection and tattoo.overlay == currentTattooHash then
                                Skin.CurrentSkin[model].tattoos[currentTattooZone][i] = nil
                            end
                        end
                    end
                end
            end
        end
        Skin.SetOnPed(PlayerPedId(), TranslateToInternal(Skin.CurrentSkin[model]))
        if data.component:find("ZONE") and not data.component:find("SAVE") and (model == 1885233650 or model == -1667301416) then
            local collection, hash = nil, nil
            if model == 1885233650 then
                if maleTattooData[data.component] and maleTattooData[data.component][data.value + 1] then
                    collection = maleTattooData[data.component][data.value + 1].collection
                    hash = maleTattooData[data.component][data.value + 1].hashMale
                end
            else
                if femaleTattooData[data.component] and femaleTattooData[data.component][data.value + 1] then
                    collection = femaleTattooData[data.component][data.value + 1].collection
                    hash = femaleTattooData[data.component][data.value + 1].hashFemale
                end
            end
            if collection and hash then
                AddPedDecorationFromHashes(PlayerPedId(), joaat(collection), joaat(hash))
                currentTattooCollection = collection
                currentTattooHash = hash
                currentTattooZone = data.component
            end
        end
        if data.type ~= "range" then
            for i = 1, #affectedComponents do
                Skin.UpdateComponentInputs(affectedComponents[i], true)
            end
        end
    end
    if Skin.InputsDependency[model] and Skin.InputsDependency[model][data.component] then
        for _, dependency in pairs(Skin.InputsDependency[model][data.component]) do
            if dependency.componentId then
                SetPedComponentVariation(PlayerPedId(), dependency.componentId, dependency.value, 0, 0)
            elseif dependency.propId then
                if dependency.value > 0 then
                    SetPedPropIndex(PlayerPedId(), dependency.propId, dependency.value, 0, false)
                else
                    ClearPedProp(PlayerPedId(), dependency.propId)
                end
            end
        end
    end
    cb({})
end)

if Skin.EnableAutoMaskClipping then
    function Skin.ShrinkFace(ped)
        local targetPed = ped or PlayerPedId()
        if not targetPed then
            return
        end
        if not pedFaceFeaturesCache[ped] then
            pedFaceFeaturesCache[ped] = {}
            isHeadShrunkCache[ped] = false
            pedHeadBlendDataCache[ped] = {}
        end
        local model = GetEntityModel(targetPed)
        if model ~= 1885233650 and model ~= -1667301416 then
            return
        end
        local currentMaskDrawable = GetPedDrawableVariation(targetPed, 1)
        local currentMaskTexture = GetPedTextureVariation(targetPed, 1)
        local maskHash = GetHashNameForComponent(targetPed, 1, currentMaskDrawable, currentMaskTexture)
        if Skin.MaskClippingWhitelist[currentMaskDrawable] then
            return
        end
        if Config.Debug then
            Functions.Debug("currentMaskDrawable, currentMaskTexture, maskHash", currentMaskDrawable, currentMaskTexture, maskHash)
        end
        if currentMaskDrawable > 0 and maskHash ~= 0 then
            local shouldShrink = DoesShopPedApparelHaveRestrictionTag(maskHash, joaat("NO_HEAD"), 0) or Skin.HardcodedMasksToClip[currentMaskDrawable]
            if shouldShrink then
                local shouldNotShrink = DoesShopPedApparelHaveRestrictionTag(maskHash, joaat("HAT"), 0) or DoesShopPedApparelHaveRestrictionTag(maskHash, joaat("HELMET"), 0)
                if not shouldNotShrink and not isHeadShrunkCache[ped] then
                    Functions.Debug("SHOULD SHRINK HEAD")
                    local headBlendData = Skin.GetPedHeadBlendData(targetPed)
                    if not headBlendData then
                        return
                    end
                    pedHeadBlendDataCache[ped] = headBlendData
                    for i = 0, 19 do
                        if not isHeadShrunkCache[ped] and not pedFaceFeaturesCache[ped][i] then
                            pedFaceFeaturesCache[ped][i] = GetPedFaceFeature(targetPed, i)
                        end
                        SetPedFaceFeature(targetPed, i, 0.0)
                    end
                    local shapeFirst = (model == 1885233650) and 0 or 21
                    SetPedHeadBlendData(targetPed, shapeFirst, 0, 0, headBlendData.skinFirst, headBlendData.skinSecond, headBlendData.skinThird, 0.0, headBlendData.skinMix, 0.0, false)
                    Functions.Debug("HEAD SHRINKED")
                    isHeadShrunkCache[ped] = true
                end
            end
        else
            if isHeadShrunkCache[ped] then
                Functions.Debug("MASK IS NOT ON FACE, RESTORING PREVIOUS HEAD")
                Functions.Debug(json.encode(pedHeadBlendDataCache[ped]), json.encode(pedFaceFeaturesCache[ped]))
                if pedHeadBlendDataCache[ped].shapeFirst and pedFaceFeaturesCache[ped][1] then
                    for i = 0, 19 do
                        SetPedFaceFeature(targetPed, i, pedFaceFeaturesCache[ped][i])
                    end
                    local hbd = pedHeadBlendDataCache[ped]
                    SetPedHeadBlendData(targetPed, hbd.shapeFirst, hbd.shapeSecond, 0, hbd.skinFirst, hbd.skinSecond, 0, hbd.shapeMix, hbd.skinMix, 0, false)
                end
                Functions.Debug("RESTORED")
                local restored = true
                for i = 0, 19 do
                    if GetPedFaceFeature(targetPed, i) ~= pedFaceFeaturesCache[ped][i] then
                        Functions.Debug(i, "MISMATCH WITH SAVED VALUE. TRYING AGAIN TO RESTORE")
                        restored = false
                        break
                    end
                end
                if restored then
                    isHeadShrunkCache[ped] = false
                    pedHeadBlendDataCache[ped] = {}
                    pedFaceFeaturesCache[ped] = {}
                end
            end
        end
    end
    CreateThread(function()
        while true do
            Wait(500)
            Skin.ShrinkFace(PlayerPedId())
            for ped, _ in pairs(pedHeadBlendDataCache) do
                if not DoesEntityExist(ped) then
                    pedHeadBlendDataCache[ped] = nil
                end
            end
        end
    end)
end

RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function(playerData, isNew, skin)
    Skin.FirstSpawn = true
    if isNew then
        if not Skin.Enabled then
            local defaultSkin = {mom = 43, dad = 29, face_md_weight = 61, skin_md_weight = 27, nose_1 = -5, nose_2 = 6, nose_3 = 5, nose_4 = 8, nose_5 = 10, nose_6 = 0, cheeks_1 = 2, cheeks_2 = -10, cheeks_3 = 6, lip_thickness = -2, jaw_1 = 0, jaw_2 = 0, chin_1 = 0, chin_2 = 0, chin_13 = 0, chin_4 = 0, neck_thickness = 0, hair_1 = 76, hair_2 = 0, hair_color_1 = 61, hair_color_2 = 29, tshirt_1 = 4, tshirt_2 = 2, torso_1 = 23, torso_2 = 2, decals_1 = 0, decals_2 = 0, arms = 1, arms_2 = 0, pants_1 = 28, pants_2 = 3, shoes_1 = 70, shoes_2 = 2, mask_1 = 0, mask_2 = 0, bproof_1 = 0, bproof_2 = 0, chain_1 = 22, chain_2 = 2, helmet_1 = -1, helmet_2 = 0, glasses_1 = 0, glasses_2 = 0, watches_1 = -1, watches_2 = 0, bracelets_1 = -1, bracelets_2 = 0, bags_1 = 0, bags_2 = 0, eye_color = 0, eye_squint = 0, eyebrows_2 = 0, eyebrows_1 = 0, eyebrows_3 = 0, eyebrows_4 = 0, eyebrows_5 = 0, eyebrows_6 = 0, makeup_1 = 0, makeup_2 = 0, makeup_3 = 0, makeup_4 = 0, lipstick_1 = 0, lipstick_2 = 0, lipstick_3 = 0, lipstick_4 = 0, ears_1 = -1, ears_2 = 0, chest_1 = 0, chest_2 = 0, chest_3 = 0, bodyb_1 = -1, bodyb_2 = 0, bodyb_3 = -1, bodyb_4 = 0, age_1 = 0, age_2 = 0, blemishes_1 = 0, blemishes_2 = 0, blush_1 = 0, blush_2 = 0, blush_3 = 0, complexion_1 = 0, complexion_2 = 0, sun_1 = 0, sun_2 = 0, moles_1 = 0, moles_2 = 0, beard_1 = 11, beard_2 = 10, beard_3 = 0, beard_4 = 0}
            if playerData.sex == "f" then
                defaultSkin = {mom = 28, dad = 6, face_md_weight = 63, skin_md_weight = 60, nose_1 = -10, nose_2 = 4, nose_3 = 5, nose_4 = 0, nose_5 = 0, nose_6 = 0, cheeks_1 = 0, cheeks_2 = 0, cheeks_3 = 0, lip_thickness = 0, jaw_1 = 0, jaw_2 = 0, chin_1 = -10, chin_2 = 10, chin_13 = -10, chin_4 = 0, neck_thickness = -5, hair_1 = 43, hair_2 = 0, hair_color_1 = 29, hair_color_2 = 35, tshirt_1 = 111, tshirt_2 = 5, torso_1 = 25, torso_2 = 2, decals_1 = 0, decals_2 = 0, arms = 3, arms_2 = 0, pants_1 = 12, pants_2 = 2, shoes_1 = 20, shoes_2 = 10, mask_1 = 0, mask_2 = 0, bproof_1 = 0, bproof_2 = 0, chain_1 = 85, chain_2 = 0, helmet_1 = -1, helmet_2 = 0, glasses_1 = 33, glasses_2 = 12, watches_1 = -1, watches_2 = 0, bracelets_1 = -1, bracelets_2 = 0, bags_1 = 0, bags_2 = 0, eye_color = 8, eye_squint = -6, eyebrows_2 = 7, eyebrows_1 = 32, eyebrows_3 = 52, eyebrows_4 = 9, eyebrows_5 = -5, eyebrows_6 = -8, makeup_1 = 0, makeup_2 = 0, makeup_3 = 0, makeup_4 = 0, lipstick_1 = 0, lipstick_2 = 0, lipstick_3 = 0, lipstick_4 = 0, ears_1 = -1, ears_2 = 0, chest_1 = 0, chest_2 = 0, chest_3 = 0, bodyb_1 = -1, bodyb_2 = 0, bodyb_3 = -1, bodyb_4 = 0, age_1 = 0, age_2 = 0, blemishes_1 = 0, blemishes_2 = 0, blush_1 = 0, blush_2 = 0, blush_3 = 0, complexion_1 = 0, complexion_2 = 0, sun_1 = 0, sun_2 = 0, moles_1 = 12, moles_2 = 8, beard_1 = 0, beard_2 = 0, beard_3 = 0, beard_4 = 0}
            end
            skin = defaultSkin
            local sex = (playerData.sex == "m" or playerData.sex == 0) and 0 or 1
            skin.sex = sex
            local hasLoaded = false
            local modelHash = (skin.sex == 0) and 1885233650 or -1667301416
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                RequestModel(modelHash)
                Wait(0)
            end
            SetPlayerModel(PlayerId(), modelHash)
            SetModelAsNoLongerNeeded(modelHash)
            TriggerEvent("skinchanger:loadSkin", skin, function()
                local playerPed = PlayerPedId()
                SetPedAoBlobRendering(playerPed, true)
                ResetEntityAlpha(playerPed)
                if Skin.OpenCustomSkinMenuOnLoad then
                    TriggerEvent("esx_skin:openSaveableMenu", function()
                        hasLoaded = true
                    end, function()
                        hasLoaded = true
                    end)
                end
            end)
            repeat
                Wait(10)
            until hasLoaded
        end
    end
    Wait(500)
    if not isNew and skin then
        skin.sex = playerData.sex
        TriggerEvent("skinchanger:loadSkin", skin)
        TriggerServerEvent("esx_skin:setWeight", skin)
    end
    TriggerServerEvent("17mov_CharacterSystem:ReturnToBucket")
end)

RegisterNetEvent("esx:onPlayerLogout")
AddEventHandler("esx:onPlayerLogout", function()
    Skin.FirstSpawn = true
    TriggerEvent("esx_skin:resetFirstSpawn")
end)

CreateThread(function()
    for zone, tattoos in pairs(Skin.Tattoos) do
        for i = 1, #tattoos do
            local tattoo = Skin.Tattoos[zone][i]
            if tattoo.hashMale ~= "" then
                if maleTattooLabels[zone] == nil then
                    maleTattooData[zone] = {{label = "-"}}
                    maleTattooLabels[zone] = {"-"}
                end
                if tattoo.hashMale then
                    table.insert(maleTattooLabels[zone], tattoo.label)
                    table.insert(maleTattooData[zone], tattoo)
                end
            end
            if tattoo.hashFemale ~= "" then
                if not femaleTattooLabels[zone] then
                    femaleTattooData[zone] = {{label = "-"}}
                    femaleTattooLabels[zone] = {"-"}
                end
                table.insert(femaleTattooLabels[zone], tattoo.label)
                table.insert(femaleTattooData[zone], tattoo)
            end
        end
    end
end)