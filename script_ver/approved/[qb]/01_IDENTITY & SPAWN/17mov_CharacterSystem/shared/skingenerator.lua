function GenerateRandomSkin(gender)
    if not Skin.DefaultSkin[gender] then
        Functions.Error("Gender given to GenerateRandomSkin function doesn't exist")
        return
    end

    local randomSkin = {}
    if gender == "female" then
        randomSkin.model = -1667301416
    else
        randomSkin.model = 1885233650
    end

    randomSkin.components = {}
    randomSkin.props = {}
    randomSkin.faceData = {}
    randomSkin.faceFeatures = {}
    randomSkin.gender = gender

    for componentId, componentData in pairs(Skin.DefaultSkin[gender]) do
        if componentData.type == "fixedVal" then
            table.insert(randomSkin.components, {
                component = componentId,
                drawable = componentData.number,
                variation = 0
            })
        elseif componentData.type == "randomMath" then
            table.insert(randomSkin.components, {
                component = componentId,
                drawable = math.random(componentData.from, componentData.to),
                variation = 0
            })
        elseif componentData.type == "randomArr" then
            table.insert(randomSkin.components, {
                component = componentId,
                drawable = componentData.options[math.random(1, #componentData.options)],
                variation = 0
            })
        elseif componentData.type == "torso" then
            local randomIndex = math.random(1, #componentData.optionsWithArms)
            table.insert(randomSkin.components, {
                component = componentId,
                drawable = componentData.optionsWithArms[randomIndex].torso,
                variation = 0
            })
            table.insert(randomSkin.components, {
                component = 3,
                drawable = componentData.optionsWithArms[randomIndex].arms,
                variation = 0
            })
        end
    end

    randomSkin.dadFace = math.random(1, 44)
    randomSkin.momFace = math.random(21, 45)
    randomSkin.skinDad = math.random(1, 44)
    randomSkin.skinMom = math.random(21, 45)
    randomSkin.faceMix = math.random()
    randomSkin.skinMix = math.random()
    randomSkin.eyeColor = 1
    randomSkin.hairColor = { color = 1, highlight = 1 }

    for i = 1, #Skin.DefaultSkin.faceFeatures do
        local featureConfig = Skin.DefaultSkin.faceFeatures[i]
        if featureConfig and featureConfig.enabled then
            table.insert(randomSkin.faceFeatures, {
                index = i,
                value = math.random(featureConfig.from, featureConfig.to) / 100
            })
        end
    end

    local faceDataConfig = Functions.DeepCopy(Skin.DefaultSkin.faceData)
    if gender == "male" then
        faceDataConfig[1] = {
            from = 0,
            to = 28,
            color = 0,
            highlight = 0
        }
    end

    for overlayId, overlayData in pairs(faceDataConfig) do
        if overlayData.enabled then
            table.insert(randomSkin.faceData, {
                overlayId = overlayId,
                overlayValue = math.random(overlayData.from, overlayData.to),
                opacity = math.random(0, 80) / 100,
                color = overlayData.color,
                highlight = overlayData.highlight
            })
        end
    end

    randomSkin.colorMode = 1
    if gender == "female" then
        randomSkin.faceMix = 0.99
    end

    return randomSkin
end