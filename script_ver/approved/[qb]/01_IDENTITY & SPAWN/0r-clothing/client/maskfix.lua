local freemodeModels = {
    [`mp_m_freemode_01`] = 'mp_m_freemode_01',
    [`mp_f_freemode_01`] = 'mp_f_freemode_01'
}
  
local function isFreemodeModel(modelHash)
    return freemodeModels[modelHash] ~= nil
end

local function getHeadBlendData(ped)
    local tbl = {
        Citizen.InvokeNative(0x2746BD9D88C5C5D0, ped,
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueIntInitialized(0),
            Citizen.PointerValueFloatInitialized(0),
            Citizen.PointerValueFloatInitialized(0),
            Citizen.PointerValueFloatInitialized(0)
        )
    }
    return {
        shapeFirst = tbl[1],
        shapeSecond = tbl[2],
        shapeThird = tbl[3],
        skinFirst = tbl[4],
        skinSecond = tbl[5],
        skinThird = tbl[6],
        shapeMix = tbl[7],
        skinMix = tbl[8],
        thirdMix = tbl[9]
    }
end
  
local savedBlendData, savedFaceFeatures
local function restoreSavedBlendData(ped)
    SetPedHeadBlendData(ped,
        savedBlendData.shapeFirst, savedBlendData.shapeSecond, savedBlendData.shapeThird,
        savedBlendData.skinFirst, savedBlendData.skinSecond, savedBlendData.skinThird,
        savedBlendData.shapeMix, savedBlendData.skinMix, savedBlendData.thirdMix,
        false
    )
end

local function restoreSavedFaceFeatures(ped)
    for i = 0, 19 do
        SetPedFaceFeature(ped, i, savedFaceFeatures[i])
    end
end
  
local function shrinkFaceFeatures(ped)
    repeat Wait(0) until HasPedHeadBlendFinished(ped)
    for i = 0, 19 do
        if not savedFaceFeatures[i] then savedFaceFeatures[i] = GetPedFaceFeature(ped, i) end
        SetPedFaceFeature(ped, i, 0.0)
    end
end

local function shrinkHead(ped, pedModelHash)
    SetPedHeadBlendData(ped,
        freemodeModels[pedModelHash] == 'mp_m_freemode_01' and 0 or 21, 0, 0, -- Reset shape
        savedBlendData.skinFirst, savedBlendData.skinSecond, savedBlendData.skinThird, -- Keep skin
        0.0, savedBlendData.skinMix, 0.0,
        false
    )
end
  
local function fixMask(ped, pedModelHash)
    local currentMaskDrawable = GetPedDrawableVariation(ped, 1)
    local currentMaskTexture = GetPedTextureVariation(ped, 1)
    local maskHash = GetHashNameForComponent(ped, 1, currentMaskDrawable, currentMaskTexture)
    if currentMaskDrawable > 0 then
        if maskHash == 0 then return end
        local headBlendData = getHeadBlendData(ped)
        if DoesShopPedApparelHaveRestrictionTag(maskHash, `SHRINK_HEAD`, 0) or currentMaskDrawable == 108 or currentMaskDrawable == 30 then
            if not savedBlendData then savedBlendData = headBlendData end
            shrinkHead(ped, pedModelHash)
        elseif savedBlendData then
            restoreSavedBlendData(ped)
            savedBlendData = nil
        end
        if not DoesShopPedApparelHaveRestrictionTag(maskHash, `HAT`, 0) and not DoesShopPedApparelHaveRestrictionTag(maskHash, `EAR_PIECE`, 0) and not (currentMaskDrawable == 11 or currentMaskDrawable == 114 or currentMaskDrawable == 145 or currentMaskDrawable == 148) then
            if not savedFaceFeatures then savedFaceFeatures = {} end
            shrinkFaceFeatures(ped)
        elseif savedFaceFeatures then
            restoreSavedFaceFeatures(ped)
            savedFaceFeatures = nil
        end
    else
        if savedBlendData then
            restoreSavedBlendData(ped)
            savedBlendData = nil
        end
        if savedFaceFeatures then
            restoreSavedFaceFeatures(ped)
            savedFaceFeatures = nil
        end
    end
end
  
local function fixClothing()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end
    local pedModelHash = GetEntityModel(ped)
    if not isFreemodeModel(pedModelHash) then return end
    fixMask(ped, pedModelHash)
end

Citizen.CreateThread(function()
    if Config.EnableMaskFix then
        while true do
            fixClothing()
            Citizen.Wait(10)
        end
    end
end)