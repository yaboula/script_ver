function TranslateHashToString(modelHash)
  local modelName = modelHash or ""
  if not modelHash then
    modelName = ""
  end
  for _, manModel in pairs(Skin.ManPlayerModels) do
    if GetHashKey(manModel) == modelHash then
      modelName = manModel
      break
    end
  end
  if modelName == modelHash then
    for _, womanModel in pairs(Skin.WomanPlayerModels) do
      if GetHashKey(womanModel) == modelHash then
        modelName = womanModel
        break
      end
    end
  end
  return modelName
end

function TranslateSkinFromIllenium(illeniumSkinData, model)
  if type(illeniumSkinData) == "string" then
    illeniumSkinData = json.decode(illeniumSkinData)
  end
  if not illeniumSkinData then
    return {}
  end
  local overlayAndFeatureMap = {
    noseWidth = 0,
    nosePeakHigh = 1,
    nosePeakSize = 2,
    noseBoneHigh = 3,
    nosePeakLowering = 4,
    noseBoneTwist = 5,
    eyeBrownHigh = 6,
    eyeBrownForward = 7,
    cheeksBoneHigh = 8,
    cheeksBoneWidth = 9,
    cheeksWidth = 10,
    eyesOpening = 11,
    lipsThickness = 12,
    jawBoneWidth = 13,
    jawBoneBackSize = 14,
    chinBoneLowering = 15,
    chinBoneLenght = 16,
    chinBoneSize = 17,
    chinHole = 18,
    neckThickness = 19,
    blemishes = 0,
    beard = 1,
    eyebrows = 2,
    ageing = 3,
    makeUp = 4,
    blush = 5,
    complexion = 6,
    sunDamage = 7,
    lipstick = 8,
    moleAndFreckles = 9,
    chestHair = 10,
    bodyBlemishes = 11
  }
  local internalSkinData = {}
  local modelToUse = model
  if not model then
    modelToUse = illeniumSkinData.model
    if not modelToUse then
      modelToUse = 1885233650
    end
  end
  internalSkinData.model = modelToUse
  internalSkinData.components = {}
  internalSkinData.props = {}
  internalSkinData.faceData = {}
  internalSkinData.faceFeatures = {}
  internalSkinData.colorMode = 1
  internalSkinData.gender = "male"
  internalSkinData.isIllenium = true
  internalSkinData.tattoos = {}
  if model then
    for _, womanModel in pairs(Skin.WomanPlayerModels) do
      if GetHashKey(womanModel) == model then
        internalSkinData.gender = "female"
        break
      end
    end
  end
  if illeniumSkinData.components then
    for _, componentData in pairs(illeniumSkinData.components) do
      table.insert(internalSkinData.components, {
        component = componentData.component_id,
        drawable = componentData.drawable,
        variation = componentData.texture
      })
    end
  end
  if illeniumSkinData.props then
    for _, propData in pairs(illeniumSkinData.props) do
      table.insert(internalSkinData.props, {
        prop = propData.prop_id,
        drawable = propData.drawable,
        variation = propData.texture
      })
    end
  end
  if illeniumSkinData.faceFeatures then
    for featureName, featureValue in pairs(illeniumSkinData.faceFeatures) do
      table.insert(internalSkinData.faceFeatures, {
        index = overlayAndFeatureMap[featureName],
        value = featureValue
      })
    end
  end
  if illeniumSkinData.headOverlays then
    for overlayName, overlayData in pairs(illeniumSkinData.headOverlays) do
      local opacity = 0.0
      if overlayData.style > 0 and overlayData.opacity then
        opacity = overlayData.opacity + 0.0
      end
      table.insert(internalSkinData.faceData, {
        overlayId = overlayAndFeatureMap[overlayName],
        overlayValue = overlayData.style - 1,
        opacity = opacity,
        color = overlayData.color,
        highlight = overlayData.secondColor
      })
    end
  end
  internalSkinData.eyeColor = illeniumSkinData.eyeColor
  if illeniumSkinData.hair then
    internalSkinData.hairColor = {
      color = illeniumSkinData.hair and illeniumSkinData.hair.color,
      highlight = illeniumSkinData.hair and illeniumSkinData.hair.highlight
    }
    table.insert(internalSkinData.components, {
      component = 2,
      drawable = illeniumSkinData.hair.style,
      texture = 0
    })
  end
  if illeniumSkinData.headBlend then
    internalSkinData.dadFace = illeniumSkinData.headBlend and illeniumSkinData.headBlend.shapeFirst
    internalSkinData.momFace = illeniumSkinData.headBlend and illeniumSkinData.headBlend.shapeSecond
    internalSkinData.faceMix = illeniumSkinData.headBlend and illeniumSkinData.headBlend.shapeMix
    internalSkinData.skinMix = illeniumSkinData.headBlend and illeniumSkinData.headBlend.skinMix
    if internalSkinData.skinMix and internalSkinData.skinMix > 1 then
      internalSkinData.skinMix = 0.99
    end
    if internalSkinData.faceMix and internalSkinData.faceMix > 1 then
      internalSkinData.faceMix = 0.99
    end
    internalSkinData.skinDad = illeniumSkinData.headBlend and illeniumSkinData.headBlend.skinFirst
    internalSkinData.skinMom = illeniumSkinData.headBlend and illeniumSkinData.headBlend.skinSecond
  end
  if illeniumSkinData.tattoos then
    for zone, tattoos in pairs(illeniumSkinData.tattoos) do
      if not internalSkinData.tattoos[zone] then
        internalSkinData.tattoos[zone] = {}
      end
      for i = 1, #tattoos do
        table.insert(internalSkinData.tattoos[zone], tattoos[i])
      end
    end
  end
  return internalSkinData
end

function TranslateSkinToIllenium(internalSkinData)
  if not internalSkinData then
    return {}
  end
  local faceFeatureNameMap = {
    [0] = "noseWidth",
    [1] = "nosePeakHigh",
    [2] = "nosePeakSize",
    [3] = "noseBoneHigh",
    [4] = "nosePeakLowering",
    [5] = "noseBoneTwist",
    [6] = "eyeBrownHigh",
    [7] = "eyeBrownForward",
    [8] = "cheeksBoneHigh",
    [9] = "cheeksBoneWidth",
    [10] = "cheeksWidth",
    [11] = "eyesOpening",
    [12] = "lipsThickness",
    [13] = "jawBoneWidth",
    [14] = "jawBoneBackSize",
    [15] = "chinBoneLowering",
    [16] = "chinBoneLenght",
    [17] = "chinBoneSize",
    [18] = "chinHole",
    [19] = "neckThickness"
  }
  local headOverlayNameMap = {
    [0] = "blemishes",
    [1] = "beard",
    [2] = "eyebrows",
    [3] = "ageing",
    [4] = "makeUp",
    [5] = "blush",
    [6] = "complexion",
    [7] = "sunDamage",
    [8] = "lipstick",
    [9] = "moleAndFreckles",
    [10] = "chestHair",
    [11] = "bodyBlemishes"
  }
  local illeniumSkinData = {}
  illeniumSkinData.model = TranslateHashToString(internalSkinData.model)
  illeniumSkinData.components = {}
  illeniumSkinData.props = {}
  illeniumSkinData.faceFeatures = {}
  illeniumSkinData.headOverlays = {}
  illeniumSkinData.eyeColor = internalSkinData.eyeColor
  illeniumSkinData.tattoos = {}
  for _, componentData in pairs(internalSkinData.components) do
    if componentData.component == 2 then
      illeniumSkinData.hair = {
        style = componentData.drawable,
        color = internalSkinData and internalSkinData.hairColor and internalSkinData.hairColor.color,
        highlight = internalSkinData and internalSkinData.hairColor and internalSkinData.hairColor.highlight
      }
    else
      table.insert(illeniumSkinData.components, {
        component_id = componentData.component,
        drawable = componentData.drawable,
        texture = componentData.texture or componentData.variation
      })
    end
  end
  for _, propData in pairs(internalSkinData.props) do
    table.insert(illeniumSkinData.props, {
      prop_id = propData.prop,
      drawable = propData.drawable,
      texture = propData.variation
    })
  end
  for _, featureData in pairs(internalSkinData.faceFeatures) do
    local featureName = faceFeatureNameMap[featureData.index]
    if featureName then
      illeniumSkinData.faceFeatures[featureName] = featureData.value
    end
  end
  for _, overlayData in pairs(internalSkinData.faceData) do
    local overlayName = headOverlayNameMap[overlayData.overlayId]
    if overlayName then
      illeniumSkinData.headOverlays[overlayName] = {
        style = overlayData.overlayValue + 1,
        opacity = overlayData.opacity,
        color = overlayData.color,
        secondColor = overlayData.highlight
      }
    end
  end
  if internalSkinData.dadFace then
    illeniumSkinData.headBlend = {
      shapeFirst = internalSkinData.dadFace,
      shapeSecond = internalSkinData.momFace,
      shapeMix = internalSkinData.faceMix,
      skinMix = internalSkinData.skinMix,
      skinFirst = internalSkinData.skinDad,
      skinSecond = internalSkinData.skinMom
    }
  end
  if internalSkinData.tattoos then
    for zone, tattoos in pairs(internalSkinData.tattoos) do
      if not illeniumSkinData.tattoos[zone] then
        illeniumSkinData.tattoos[zone] = {}
      end
      for i = 1, #tattoos do
        table.insert(illeniumSkinData.tattoos[zone], {
          zone = zone,
          collection = tattoos[i].collection,
          hashFemale = tattoos[i].overlay,
          hashMale = tattoos[i].overlay
        })
      end
    end
  end
  return illeniumSkinData
end

function TranslateSkinFromQB(qbSkinData, model)
  if type(qbSkinData) == "string" then
    qbSkinData = json.decode(qbSkinData)
  end
  if not qbSkinData then
    return {}
  end
  local internalSkinData = {}
  local modelToUse = model or 1885233650
  internalSkinData.model = modelToUse
  internalSkinData.components = {}
  internalSkinData.props = {}
  internalSkinData.faceData = {}
  internalSkinData.faceFeatures = {}
  internalSkinData.colorMode = 1
  internalSkinData.gender = "male"
  internalSkinData.tattoos = {}
  if model then
    for _, womanModel in pairs(Skin.WomanPlayerModels) do
      if GetHashKey(womanModel) == model then
        internalSkinData.gender = "female"
        break
      end
    end
  end
  local qbMapping = {
    head_1 = {index = 0, type = "components"},
    mask = {index = 1, type = "components"},
    hair = {index = 2, type = "components"},
    arms = {index = 3, type = "components"},
    pants = {index = 4, type = "components"},
    bag = {index = 5, type = "components"},
    shoes = {index = 6, type = "components"},
    accessory = {index = 7, type = "components"},
    ["t-shirt"] = {index = 8, type = "components"},
    vest = {index = 9, type = "components"},
    decals = {index = 10, type = "components"},
    torso2 = {index = 11, type = "components"},
    beard = {index = 1, type = "faceData"},
    eyebrows = {index = 2, type = "faceData"},
    ageing = {index = 3, type = "faceData"},
    makeup = {index = 4, type = "faceData"},
    blush = {index = 5, type = "faceData"},
    complexion = {index = 6, type = "faceData"},
    sun_damage = {index = 7, type = "faceData"},
    lipstick = {index = 8, type = "faceData"},
    moles = {index = 9, type = "faceData"},
    chest = {index = 10, type = "faceData"},
    bodyb = {index = 11, type = "faceData"},
    hat = {index = 0, type = "props"},
    glass = {index = 1, type = "props"},
    ear = {index = 2, type = "props"},
    watch = {index = 6, type = "props"},
    bracelet = {index = 7, type = "props"},
    nose_0 = {index = 0, type = "faceFeatures"},
    nose_1 = {index = 1, type = "faceFeatures"},
    nose_2 = {index = 2, type = "faceFeatures"},
    nose_3 = {index = 3, type = "faceFeatures"},
    nose_4 = {index = 4, type = "faceFeatures"},
    nose_5 = {index = 5, type = "faceFeatures"},
    eyebrown_high = {index = 6, type = "faceFeatures"},
    eyebrown_forward = {index = 7, type = "faceFeatures"},
    cheek_1 = {index = 8, type = "faceFeatures"},
    cheek_2 = {index = 9, type = "faceFeatures"},
    cheek_3 = {index = 10, type = "faceFeatures"},
    eye_opening = {index = 11, type = "faceFeatures"},
    lips_thickness = {index = 12, type = "faceFeatures"},
    jaw_bone_width = {index = 13, type = "faceFeatures"},
    jaw_bone_back_lenght = {index = 14, type = "faceFeatures"},
    chimp_bone_lowering = {index = 15, type = "faceFeatures"},
    chimp_bone_lenght = {index = 16, type = "faceFeatures"},
    chimp_bone_width = {index = 17, type = "faceFeatures"},
    chimp_hole = {index = 18, type = "faceFeatures"},
    neck_thikness = {index = 19, type = "faceFeatures"}
  }
  for key, mappingInfo in pairs(qbMapping) do
    local dataTable = internalSkinData[mappingInfo.type]
    local qbItemData = qbSkinData[key]
    if qbItemData then
      if mappingInfo.type == "components" then
        if mappingInfo.index == 2 then
          table.insert(dataTable, {
            component = mappingInfo.index,
            drawable = qbItemData.item,
            variation = qbItemData.style
          })
        else
          table.insert(dataTable, {
            component = mappingInfo.index,
            drawable = qbItemData.item,
            variation = qbItemData.texture
          })
        end
      elseif mappingInfo.type == "faceData" then
        table.insert(dataTable, {
          overlayId = mappingInfo.index,
          overlayValue = qbItemData.item,
          opacity = qbItemData.opacity or 1.0,
          color = qbItemData.texture,
          highlight = qbItemData.highlight or qbItemData.texture
        })
      elseif mappingInfo.type == "props" then
        table.insert(dataTable, {
          prop = mappingInfo.index,
          drawable = qbItemData.item,
          variation = qbItemData.texture
        })
      elseif mappingInfo.type == "faceFeatures" then
        table.insert(dataTable, {
          index = mappingInfo.index,
          value = qbItemData.item / 10
        })
      end
    end
  end
  internalSkinData.eyeColor = qbSkinData.eye_color and qbSkinData.eye_color.item
  internalSkinData.hairColor = {
    color = qbSkinData.hair and qbSkinData.hair.texture,
    highlight = (qbSkinData.hair and qbSkinData.hair.highlight) or (qbSkinData.hair and qbSkinData.hair.texture)
  }
  internalSkinData.dadFace = qbSkinData.face and qbSkinData.face.item
  internalSkinData.momFace = qbSkinData.face2 and qbSkinData.face2.item
  internalSkinData.skinDad = qbSkinData.skinDad
  internalSkinData.skinMom = qbSkinData.skinMom
  internalSkinData.faceMix = qbSkinData.facemix and qbSkinData.facemix.shapeMix
  internalSkinData.skinMix = qbSkinData.facemix and qbSkinData.facemix.skinMix
  if internalSkinData.faceData.moles then
    internalSkinData.faceData.moles = internalSkinData.faceData.moles / 10
  end
  if qbSkinData.tattoos then
    for zone, tattoos in pairs(qbSkinData.tattoos) do
      internalSkinData.tattoos[zone] = tattoos
    end
  end
  return internalSkinData
end

function TranslateSkinToQB(internalSkinData)
  local qbSkinData = {tattoos = {}}
  local qbDefaults = {
    head_1 = {defaultItem = 0, defaultTexture = 0},
    head_2 = {defaultItem = 0, defaultTexture = 0},
    face = {defaultItem = 0, defaultTexture = 0},
    face2 = {defaultItem = 0, defaultTexture = 0},
    facemix = {defaultSkinMix = 0.0, defaultShapeMix = 0.0},
    pants = {defaultItem = 0, defaultTexture = 0},
    hair = {defaultItem = 0, defaultTexture = 0},
    eyebrows = {defaultItem = -1, defaultTexture = 1},
    beard = {defaultItem = -1, defaultTexture = 1},
    blush = {defaultItem = -1, defaultTexture = 1},
    lipstick = {defaultItem = -1, defaultTexture = 1},
    makeup = {defaultItem = -1, defaultTexture = 1},
    ageing = {defaultItem = -1, defaultTexture = 0},
    arms = {defaultItem = 0, defaultTexture = 0},
    ["t-shirt"] = {defaultItem = 1, defaultTexture = 0},
    torso2 = {defaultItem = 0, defaultTexture = 0},
    vest = {defaultItem = 0, defaultTexture = 0},
    bag = {defaultItem = 0, defaultTexture = 0},
    shoes = {defaultItem = 1, defaultTexture = 0},
    mask = {defaultItem = 0, defaultTexture = 0},
    hat = {defaultItem = -1, defaultTexture = 0},
    glass = {defaultItem = -1, defaultTexture = -1},
    ear = {defaultItem = -1, defaultTexture = 0},
    watch = {defaultItem = -1, defaultTexture = 0},
    bracelet = {defaultItem = -1, defaultTexture = 0},
    accessory = {defaultItem = 0, defaultTexture = 0},
    decals = {defaultItem = 0, defaultTexture = 0},
    eye_color = {defaultItem = -1, defaultTexture = 0},
    moles = {defaultItem = -1, defaultTexture = 0},
    nose_0 = {defaultItem = 0, defaultTexture = 0},
    nose_1 = {defaultItem = 0, defaultTexture = 0},
    nose_2 = {defaultItem = 0, defaultTexture = 0},
    nose_3 = {defaultItem = 0, defaultTexture = 0},
    nose_4 = {defaultItem = 0, defaultTexture = 0},
    nose_5 = {defaultItem = 0, defaultTexture = 0},
    cheek_1 = {defaultItem = 0, defaultTexture = 0},
    cheek_2 = {defaultItem = 0, defaultTexture = 0},
    cheek_3 = {defaultItem = 0, defaultTexture = 0},
    eye_opening = {defaultItem = 0, defaultTexture = 0},
    lips_thickness = {defaultItem = 0, defaultTexture = 0},
    jaw_bone_width = {defaultItem = 0, defaultTexture = 0},
    eyebrown_high = {defaultItem = 0, defaultTexture = 0},
    eyebrown_forward = {defaultItem = 0, defaultTexture = 0},
    jaw_bone_back_lenght = {defaultItem = 0, defaultTexture = 0},
    chimp_bone_lowering = {defaultItem = 0, defaultTexture = 0},
    chimp_bone_lenght = {defaultItem = 0, defaultTexture = 0},
    chimp_bone_width = {defaultItem = 0, defaultTexture = 0},
    chimp_hole = {defaultItem = 0, defaultTexture = 0},
    neck_thikness = {defaultItem = 0, defaultTexture = 0},
    complexion = {defaultItem = 0, defaultTexture = 0},
    sun_damage = {defaultItem = 0, defaultTexture = 0},
    chest = {defaultItem = 0, defaultTexture = 0},
    bodyb = {defaultItem = 0, defaultTexture = 0}
  }
  local componentMap = {
    [0] = "head_1",
    [1] = "mask",
    [2] = "hair",
    [3] = "arms",
    [4] = "pants",
    [5] = "bag",
    [6] = "shoes",
    [7] = "accessory",
    [8] = "t-shirt",
    [9] = "vest",
    [10] = "decals",
    [11] = "torso2"
  }
  local overlayMap = {
    [1] = "beard",
    [2] = "eyebrows",
    [3] = "ageing",
    [4] = "makeup",
    [5] = "blush",
    [6] = "complexion",
    [7] = "sun_damage",
    [8] = "lipstick",
    [9] = "moles",
    [10] = "chest",
    [11] = "bodyb"
  }
  local propMap = {
    [0] = "hat",
    [1] = "glass",
    [2] = "ear",
    [6] = "watch",
    [7] = "bracelet"
  }
  local featureMap = {
    [0] = "nose_0",
    [1] = "nose_1",
    [2] = "nose_2",
    [3] = "nose_3",
    [4] = "nose_4",
    [5] = "nose_5",
    [6] = "eyebrown_high",
    [7] = "eyebrown_forward",
    [8] = "cheek_1",
    [9] = "cheek_2",
    [10] = "cheek_3",
    [11] = "eye_opening",
    [12] = "lips_thickness",
    [13] = "jaw_bone_width",
    [14] = "jaw_bone_back_lenght",
    [15] = "chimp_bone_lowering",
    [16] = "chimp_bone_lenght",
    [17] = "chimp_bone_width",
    [18] = "chimp_hole",
    [19] = "neck_thikness"
  }
  if internalSkinData.faceData then
    for qbKey, overlayId in pairs(overlayMap) do
      for _, overlayData in ipairs(internalSkinData.faceData) do
        if overlayData.overlayId == qbKey then
          qbSkinData[overlayId] = {
            item = overlayData.overlayValue,
            texture = overlayData.color,
            opacity = overlayData.opacity,
            highlight = overlayData.highlight,
            defaultItem = qbDefaults[overlayId].defaultItem,
            defaultTexture = qbDefaults[overlayId].defaultTexture
          }
        end
      end
    end
  end
  if internalSkinData.faceFeatures then
    for qbKey, featureId in pairs(featureMap) do
      for _, featureData in ipairs(internalSkinData.faceFeatures) do
        if featureData.index == qbKey then
          qbSkinData[featureId] = {
            item = featureData.value * 10,
            defaultItem = qbDefaults[featureId].defaultItem,
            defaultTexture = qbDefaults[featureId].defaultTexture
          }
        end
      end
    end
  end
  if internalSkinData.components then
    for qbKey, componentId in pairs(componentMap) do
      for _, componentData in ipairs(internalSkinData.components) do
        if componentData.component == qbKey then
          if componentId == "hair" then
            qbSkinData[componentId] = {
              item = componentData.drawable,
              texture = internalSkinData.hairColor and internalSkinData.hairColor.color,
              highlight = internalSkinData.hairColor and internalSkinData.hairColor.highlight,
              style = componentData.style or componentData.variation,
              defaultItem = qbDefaults[componentId].defaultItem,
              defaultTexture = qbDefaults[componentId].defaultTexture
            }
          else
            qbSkinData[componentId] = {
              item = componentData.drawable,
              texture = componentData.variation,
              defaultItem = qbDefaults[componentId].defaultItem,
              defaultTexture = qbDefaults[componentId].defaultTexture
            }
          end
        end
      end
    end
  end
  if internalSkinData.props then
    for qbKey, propId in pairs(propMap) do
      for _, propData in ipairs(internalSkinData.props) do
        if propData.prop == qbKey then
          qbSkinData[propId] = {
            item = propData.drawable,
            texture = propData.variation,
            defaultItem = qbDefaults[propId].defaultItem,
            defaultTexture = qbDefaults[propId].defaultTexture
          }
        end
      end
    end
  end
  qbSkinData.eye_color = {
    item = internalSkinData.eyeColor,
    texture = qbDefaults.eye_color.defaultTexture,
    defaultTexture = qbDefaults.eye_color.defaultTexture,
    defaultItem = qbDefaults.eye_color.defaultItem
  }
  qbSkinData.face = {
    item = internalSkinData.dadFace,
    texture = internalSkinData.dadFace,
    defaultTexture = qbDefaults.face.defaultTexture,
    defaultItem = qbDefaults.face.defaultItem
  }
  qbSkinData.face2 = {
    item = internalSkinData.momFace,
    texture = internalSkinData.momFace,
    defaultTexture = qbDefaults.face2.defaultTexture,
    defaultItem = qbDefaults.face2.defaultItem
  }
  qbSkinData.facemix = {
    shapeMix = internalSkinData.faceMix,
    skinMix = internalSkinData.skinMix
  }
  qbSkinData.skinDad = internalSkinData.skinDad
  qbSkinData.skinMom = internalSkinData.skinMom
  if internalSkinData.tattoos then
    for zone, tattoos in pairs(internalSkinData.tattoos) do
      qbSkinData.tattoos[zone] = tattoos
    end
  end
  return qbSkinData
end

function ValidateInfinity(skinData)
  local function traverseAndFix(dataTable, currentPath)
    for key, value in pairs(dataTable) do
      local newPath = currentPath .. "[" .. tostring(key) .. "]"
      if type(value) == "table" then
        traverseAndFix(value, newPath)
      elseif type(value) == "number" then
        local valueStr = tostring(value)
        if valueStr == "inf" or valueStr == "-inf" then
          Functions.Debug("Fixing the ", newPath, " value")
          dataTable[key] = 0
        end
      end
    end
  end
  traverseAndFix(skinData, "skinData")
  return skinData
end

function TranslateSkinToESX(internalSkinData)
  local esxSkin = {}
  esxSkin.sex = 0
  esxSkin.model = TranslateHashToString(internalSkinData and internalSkinData.model)
  esxSkin.dad = internalSkinData and internalSkinData.dadFace
  esxSkin.mom = internalSkinData and internalSkinData.momFace
  esxSkin.skinDad = internalSkinData and internalSkinData.skinDad
  esxSkin.skinMom = internalSkinData and internalSkinData.skinMom
  esxSkin.face_md_weight = internalSkinData and internalSkinData.faceMix
  esxSkin.skin_md_weight = internalSkinData and internalSkinData.skinMix
  esxSkin.eye_color = internalSkinData and internalSkinData.eyeColor
  esxSkin.hair_color_1 = internalSkinData and internalSkinData.hairColor and internalSkinData.hairColor.color
  esxSkin.hair_color_2 = internalSkinData and internalSkinData.hairColor and internalSkinData.hairColor.highlight
  esxSkin.tattoos = {}
  if internalSkinData and internalSkinData.model then
    for _, womanModel in pairs(Skin.WomanPlayerModels) do
      if GetHashKey(womanModel) == internalSkinData.model then
        esxSkin.sex = 1
        break
      end
    end
  end
  local componentMap = {
    [0] = {drawable = "head_1", variation = "head_2"},
    [1] = {drawable = "mask_1", variation = "mask_2"},
    [2] = {drawable = "hair_1", variation = "hair_2", style = "hair_2"},
    [3] = {drawable = "arms", variation = "arms_2"},
    [4] = {drawable = "pants_1", variation = "pants_2"},
    [5] = {drawable = "bags_1", variation = "bags_2"},
    [6] = {drawable = "shoes_1", variation = "shoes_2"},
    [7] = {drawable = "chain_1", variation = "chain_2"},
    [8] = {drawable = "tshirt_1", variation = "tshirt_2"},
    [9] = {drawable = "bproof_1", variation = "bproof_2"},
    [10] = {drawable = "decals_1", variation = "decals_2"},
    [11] = {drawable = "torso_1", variation = "torso_2"}
  }
  local propMap = {
    [0] = {drawable = "helmet_1", variation = "helmet_2"},
    [1] = {drawable = "glasses_1", variation = "glasses_2"},
    [2] = {drawable = "ears_1", variation = "ears_2"},
    [6] = {drawable = "watches_1", variation = "watches_2"},
    [7] = {drawable = "bracelets_1", variation = "bracelets_2"}
  }
  local featureMap = {
    [0] = "nose_1",
    [1] = "nose_2",
    [2] = "nose_3",
    [3] = "nose_4",
    [4] = "nose_5",
    [5] = "nose_6",
    [6] = "eyebrows_5",
    [7] = "eyebrows_6",
    [8] = "cheeks_1",
    [9] = "cheeks_2",
    [10] = "cheeks_3",
    [11] = "eye_squint",
    [12] = "lip_thickness",
    [13] = "jaw_1",
    [14] = "jaw_2",
    [15] = "chin_1",
    [16] = "chin_2",
    [17] = "chin_3",
    [18] = "chin_4",
    [19] = "neck_thickness"
  }
  local overlayMap = {
    [0] = {drawable = "blemishes_1", opacity = "blemishes_2"},
    [1] = {drawable = "beard_1", opacity = "beard_2", color = "beard_3", highlight = "beard_4"},
    [2] = {drawable = "eyebrows_1", opacity = "eyebrows_2", color = "eyebrows_3", highlight = "eyebrows_4"},
    [3] = {drawable = "age_1", opacity = "age_2"},
    [4] = {drawable = "makeup_1", opacity = "makeup_2", color = "makeup_3", highlight = "makeup_4"},
    [5] = {drawable = "blush_1", opacity = "blush_2", color = "blush_3"},
    [6] = {drawable = "complexion_1", opacity = "complexion_2"},
    [7] = {drawable = "sun_1", opacity = "sun_2"},
    [8] = {drawable = "lipstick_1", opacity = "lipstick_2", color = "lipstick_3", highlight = "lipstick_4"},
    [9] = {drawable = "moles_1", opacity = "moles_2"},
    [10] = {drawable = "chest_1", opacity = "chest_2", color = "chest_3"},
    [11] = {drawable = "bodyb_1", opacity = "bodyb_2"},
    [12] = {drawable = "bodyb_3", opacity = "bodyb_4"}
  }
  if internalSkinData and internalSkinData.faceData then
    for _, overlayData in ipairs(internalSkinData.faceData) do
      local mapping = overlayMap[overlayData.overlayId]
      if mapping then
        esxSkin[mapping.drawable] = overlayData.overlayValue
        local opacityValue = overlayData.opacity
        if mapping.opacity == "beard_2" or mapping.opacity == "eyebrows_2" then
          if opacityValue < 1 then
            opacityValue = opacityValue * 10
          end
        end
        esxSkin[mapping.opacity] = opacityValue
        if mapping.color then
          esxSkin[mapping.color] = overlayData.color
        end
        if mapping.highlight then
          esxSkin[mapping.highlight] = overlayData.highlight
        end
      end
    end
  end
  if internalSkinData and internalSkinData.components then
    for _, componentData in ipairs(internalSkinData.components) do
      local mapping = componentMap[componentData.component]
      if mapping then
        esxSkin[mapping.drawable] = componentData.drawable
        esxSkin[mapping.variation] = componentData.variation
        if componentData.style and mapping.style then
          esxSkin[mapping.style] = componentData.style
        end
      end
    end
  end
  if internalSkinData and internalSkinData.faceFeatures then
    for _, featureData in ipairs(internalSkinData.faceFeatures) do
      local esxKey = featureMap[featureData.index]
      if esxKey then
        local value = featureData.value
        if value >= 2 then
          value = math.min(math.max(value * 10.0, -10), 10)
        end
        esxSkin[esxKey] = value
      end
    end
  end
  if internalSkinData and internalSkinData.props then
    for _, propData in ipairs(internalSkinData.props) do
      local mapping = propMap[propData.prop]
      if mapping then
        esxSkin[mapping.drawable] = propData.drawable
        esxSkin[mapping.variation] = propData.variation
      end
    end
  end
  if internalSkinData.tattoos then
    for zone, tattoos in pairs(internalSkinData.tattoos) do
      esxSkin.tattoos[zone] = tattoos
    end
  end
  return ValidateInfinity(esxSkin)
end

function TranslateSkinFromESX(esxSkinData, model)
  local internalSkinData = {}
  local modelToUse = model
  if not modelToUse then
    if esxSkinData then
      if esxSkinData.model then
        modelToUse = esxSkinData.model
      elseif esxSkinData.sex == 0 then
        modelToUse = 1885233650
      elseif esxSkinData.sex == 1 or esxSkinData.sex == "f" then
        modelToUse = -1667301416
      else
        modelToUse = 1885233650
      end
    end
  end
  internalSkinData.model = modelToUse
  internalSkinData.components = {}
  internalSkinData.props = {}
  internalSkinData.faceData = {}
  internalSkinData.faceFeatures = {}
  internalSkinData.gender = "male"
  internalSkinData.tattoos = {}
  if modelToUse then
    local modelHash = (type(modelToUse) == "number" and modelToUse or GetHashKey(modelToUse))
    for _, womanModel in pairs(Skin.WomanPlayerModels) do
      if GetHashKey(womanModel) == modelHash then
        internalSkinData.gender = "female"
        break
      end
    end
  end
  local esxMapping = {
    mask_1 = {index = 1, type = "components", variation = "mask_2"},
    hair_1 = {index = 2, type = "components", variation = "hair_2", style = "hair_2"},
    arms = {index = 3, type = "components", variation = "arms_2"},
    pants_1 = {index = 4, type = "components", variation = "pants_2"},
    bags_1 = {index = 5, type = "components", variation = "bags_2"},
    shoes_1 = {index = 6, type = "components", variation = "shoes_2"},
    chain_1 = {index = 7, type = "components", variation = "chain_2"},
    tshirt_1 = {index = 8, type = "components", variation = "tshirt_2"},
    bproof_1 = {index = 9, type = "components", variation = "bproof_2"},
    decals_1 = {index = 10, type = "components", variation = "decals_2"},
    torso_1 = {index = 11, type = "components", variation = "torso_2"},
    head_1 = {index = 0, type = "components", variation = "head_2"},
    blemishes_1 = {index = 0, type = "faceData", opacity = "blemishes_2"},
    beard_1 = {index = 1, type = "faceData", opacity = "beard_2", color = "beard_3", highlight = "beard_4"},
    eyebrows_1 = {index = 2, type = "faceData", opacity = "eyebrows_2", color = "eyebrows_3", highlight = "eyebrows_4"},
    age_1 = {index = 3, type = "faceData", opacity = "age_2"},
    makeup_1 = {index = 4, type = "faceData", opacity = "makeup_2", color = "makeup_3", highlight = "makeup_4"},
    blush_1 = {index = 5, type = "faceData", opacity = "blush_2", color = "blush_3"},
    complexion_1 = {index = 6, type = "faceData", opacity = "complexion_2"},
    sun_1 = {index = 7, type = "faceData", opacity = "sun_2"},
    lipstick_1 = {index = 8, type = "faceData", opacity = "lipstick_2", color = "lipstick_3", highlight = "lipstick_4"},
    moles_1 = {index = 9, type = "faceData", opacity = "moles_2"},
    chest_1 = {index = 10, type = "faceData", opacity = "chest_2", color = "chest_3"},
    bodyb_1 = {index = 11, type = "faceData", opacity = "bodyb_2", color = "bodyb_3", highlight = "bodyb_4"},
    helmet_1 = {index = 0, type = "props", variation = "helmet_2"},
    glasses_1 = {index = 1, type = "props", variation = "glasses_2"},
    ears_1 = {index = 2, type = "props", variation = "ears_2"},
    watches_1 = {index = 6, type = "props", variation = "watches_2"},
    bracelets_1 = {index = 7, type = "props", variation = "bracelets_2"},
    nose_1 = {index = 0, type = "faceFeatures"},
    nose_2 = {index = 1, type = "faceFeatures"},
    nose_3 = {index = 2, type = "faceFeatures"},
    nose_4 = {index = 3, type = "faceFeatures"},
    nose_5 = {index = 4, type = "faceFeatures"},
    nose_6 = {index = 5, type = "faceFeatures"},
    eyebrows_5 = {index = 6, type = "faceFeatures"},
    eyebrows_6 = {index = 7, type = "faceFeatures"},
    cheeks_1 = {index = 8, type = "faceFeatures"},
    cheeks_2 = {index = 9, type = "faceFeatures"},
    cheeks_3 = {index = 10, type = "faceFeatures"},
    eye_squint = {index = 11, type = "faceFeatures"},
    lip_thickness = {index = 12, type = "faceFeatures"},
    jaw_1 = {index = 13, type = "faceFeatures"},
    jaw_2 = {index = 14, type = "faceFeatures"},
    chin_1 = {index = 15, type = "faceFeatures"},
    chin_2 = {index = 16, type = "faceFeatures"},
    chin_3 = {index = 17, type = "faceFeatures"},
    chin_4 = {index = 18, type = "faceFeatures"},
    neck_thickness = {index = 19, type = "faceFeatures"}
  }
  for esxKey, mappingInfo in pairs(esxMapping) do
    if esxSkinData and esxSkinData[esxKey] ~= nil then
      if mappingInfo.type == "components" then
        local componentData = {
          component = mappingInfo.index,
          drawable = esxSkinData[esxKey]
        }
        if mappingInfo.variation then
          componentData.variation = esxSkinData[mappingInfo.variation]
        end
        if mappingInfo.style then
          componentData.style = esxSkinData[mappingInfo.style]
        end
        table.insert(internalSkinData.components, componentData)
      elseif mappingInfo.type == "faceData" then
        local opacity = esxSkinData[mappingInfo.opacity]
        if (esxKey == "beard_1" or esxKey == "eyebrows_1") and opacity and opacity > 0 then
          opacity = opacity / 10
          if tostring(opacity) == "inf" then
            opacity = 0.5
          end
        end
        local overlayData = {
          overlayId = mappingInfo.index,
          overlayValue = esxSkinData[esxKey],
          opacity = opacity,
          color = esxSkinData[mappingInfo.color],
          highlight = esxSkinData[mappingInfo.highlight]
        }
        table.insert(internalSkinData.faceData, overlayData)
      elseif mappingInfo.type == "props" then
        local propData = {
          prop = mappingInfo.index,
          drawable = esxSkinData[esxKey],
          variation = esxSkinData[mappingInfo.variation]
        }
        table.insert(internalSkinData.props, propData)
      elseif mappingInfo.type == "faceFeatures" then
        local value = esxSkinData[esxKey]
        if math.abs(value) >= 2 then
          value = value / 10.0
        elseif math.abs(value) > 1 or math.abs(value) <= 0 then
          value = 0.5
        end
        table.insert(internalSkinData.faceFeatures, {
          index = mappingInfo.index,
          value = value
        })
      end
    end
  end
  internalSkinData.eyeColor = esxSkinData and esxSkinData.eye_color
  internalSkinData.hairColor = {
    color = esxSkinData and esxSkinData.hair_color_1,
    highlight = esxSkinData and esxSkinData.hair_color_2
  }
  internalSkinData.dadFace = esxSkinData and esxSkinData.dad
  internalSkinData.momFace = esxSkinData and esxSkinData.mom
  internalSkinData.skinDad = esxSkinData and esxSkinData.skinDad
  internalSkinData.skinMom = esxSkinData and esxSkinData.skinMom
  if esxSkinData and esxSkinData.face_md_weight then
    local fmwStr = tostring(esxSkinData.face_md_weight):gsub(",", ".")
    local fmw = tonumber(fmwStr)
    if fmw == nil or tostring(esxSkinData.face_md_weight) == "inf" then
      internalSkinData.faceMix = 0.5
    elseif fmw >= 2 then
      internalSkinData.faceMix = fmw / 100.0
    else
      internalSkinData.faceMix = fmw
    end
  else
    internalSkinData.faceMix = 0.5
  end
  if esxSkinData and esxSkinData.skin_md_weight then
    local smwStr = tostring(esxSkinData.skin_md_weight):gsub(",", ".")
    local smw = tonumber(smwStr)
    if smw == nil or tostring(esxSkinData.skin_md_weight) == "inf" then
      internalSkinData.skinMix = 0.5
    elseif smw >= 2 then
      internalSkinData.skinMix = smw / 100.0
    else
      internalSkinData.skinMix = smw
    end
  else
    internalSkinData.skinMix = 0.5
  end
  -- Clamp mixes to valid bounds
  if internalSkinData.faceMix and internalSkinData.faceMix > 1 then internalSkinData.faceMix = 0.99 end
  if internalSkinData.faceMix and internalSkinData.faceMix < 0 then internalSkinData.faceMix = 0 end
  if internalSkinData.skinMix and internalSkinData.skinMix > 1 then internalSkinData.skinMix = 0.99 end
  if internalSkinData.skinMix and internalSkinData.skinMix < 0 then internalSkinData.skinMix = 0 end
  if esxSkinData and esxSkinData.tattoos then
    for zone, tattoos in pairs(esxSkinData.tattoos) do
      internalSkinData.tattoos[zone] = tattoos
    end
  end
  internalSkinData.colorMode = 1
  return ValidateInfinity(internalSkinData)
end

function SearchIndexByComponent(dataTable, componentId)
  local foundIndex = nil
  for i, data in pairs(dataTable) do
    if data.component == componentId or data.overlayId == componentId or data.index == componentId or data.prop == componentId then
      foundIndex = i
      break
    end
    local tattooZoneName = Skin.TattosIndexTranslator[componentId]
    if data.zone and tattooZoneName and data.zone == tattooZoneName then
      foundIndex = i
      break
    end
  end
  return foundIndex
end

function TranslateToInternal(flatSkinData)
  local internalSkinData = Functions.DeepCopy(flatSkinData)
  local newSkin = {
    components = {},
    props = {},
    faceData = {},
    faceFeatures = {},
    hairColor = {},
    colorMode = 1,
    tattoos = {}
  }
  newSkin.model = internalSkinData.model
  newSkin.sex = internalSkinData.model
  if internalSkinData.gender then
    newSkin.gender = internalSkinData.gender
  else
    newSkin.gender = "male"
    if internalSkinData.model then
      for _, womanModel in pairs(Skin.WomanPlayerModels) do
        if GetHashKey(womanModel) == internalSkinData.model then
          newSkin.gender = "female"
          break
        end
      end
    end
  end
  internalSkinData.gender = nil
  for key, data in pairs(Skin.InputsData) do
    if data.mapping and internalSkinData[key] ~= nil then
      local tableName, indexStr, fieldName = data.mapping:match("^(%w+)%[(%d+)%]%.([%w_]+)$")
      if tableName and indexStr and fieldName then
        local indexNum = tonumber(indexStr)
        local targetTable = newSkin[tableName]
        local entryIndex = SearchIndexByComponent(targetTable, indexNum)
        if not entryIndex then
          if data.mapping:find("components") then
            table.insert(targetTable, {
              component = indexNum,
              drawable = 0,
              variation = 0
            })
          elseif data.mapping:find("faceData") then
            table.insert(targetTable, {
              overlayId = indexNum,
              overlayValue = 0,
              opacity = 0.0,
              color = 0,
              highlight = 0
            })
          elseif data.mapping:find("props") then
            table.insert(targetTable, {
              prop = indexNum,
              drawable = 0,
              variation = 0
            })
          elseif data.mapping:find("faceFeatures") then
            table.insert(targetTable, {
              index = indexNum,
              value = 0
            })
          elseif data.mapping:find("tattoos") then
            table.insert(targetTable, {
              zone = Skin.TattosIndexTranslator[indexNum],
              value = 0
            })
          end
          entryIndex = SearchIndexByComponent(targetTable, indexNum)
        end
        if entryIndex then
          targetTable[entryIndex][fieldName] = internalSkinData[key]
        end
      elseif data.mapping:find("hairColor") then
        local hairField = data.mapping:gsub("hairColor%.", "")
        newSkin.hairColor[hairField] = internalSkinData[key]
      else
        newSkin[data.mapping] = internalSkinData[key]
      end
    end
  end
  local hairColorMap = {hair_color_1 = "color", hair_color_2 = "highlight"}
  for key, field in pairs(hairColorMap) do
    if internalSkinData[key] ~= nil then
      newSkin.hairColor[field] = internalSkinData[key]
    end
  end
  if internalSkinData.face_md_weight then
    local fmwStr = tostring(internalSkinData.face_md_weight):gsub(",", ".")
    local fmw = tonumber(fmwStr)
    if fmw == nil or tostring(internalSkinData.face_md_weight) == "inf" then
      newSkin.faceMix = 0.5
    elseif fmw >= 2 then
      newSkin.faceMix = fmw / 100.0
    else
      newSkin.faceMix = fmw
    end
  end
  if internalSkinData.skin_md_weight then
    local smwStr = tostring(internalSkinData.skin_md_weight):gsub(",", ".")
    local smw = tonumber(smwStr)
    if smw == nil or tostring(internalSkinData.skin_md_weight) == "inf" then
      newSkin.skinMix = 0.5
    elseif smw >= 2 then
      newSkin.skinMix = smw / 100.0
    else
      newSkin.skinMix = smw
    end
  end
  -- Clamp mixes to valid bounds
  if newSkin.faceMix and newSkin.faceMix > 1 then newSkin.faceMix = 0.99 end
  if newSkin.faceMix and newSkin.faceMix < 0 then newSkin.faceMix = 0 end
  if newSkin.skinMix and newSkin.skinMix > 1 then newSkin.skinMix = 0.99 end
  if newSkin.skinMix and newSkin.skinMix < 0 then newSkin.skinMix = 0 end
  if internalSkinData.tattoos then
    for zone, tattoos in pairs(internalSkinData.tattoos) do
      newSkin.tattoos[zone] = tattoos
    end
  end
  if newSkin.model == 0 then
    newSkin.model = newSkin.sex
  end
  return newSkin
end

function TranslateToHuman(internalSkinData)
  local flatSkinData = Functions.DeepCopy(internalSkinData)
  local humanReadableSkin = {tattoos = {}}
  if flatSkinData.gender then
    humanReadableSkin.gender = flatSkinData.gender
  else
    if flatSkinData.sex then
      humanReadableSkin.gender = "male"
      for _, womanModel in pairs(Skin.WomanPlayerModels) do
        if GetHashKey(womanModel) == flatSkinData.model then
          humanReadableSkin.gender = "female"
          break
        end
      end
    end
    humanReadableSkin.gender = "male"
  end
  for key, data in pairs(Skin.InputsData) do
    local tableName, indexStr, fieldName = data.mapping:match("^(%w+)%[(%d+)%]%.([%w_]+)$")
    if tableName and indexStr and fieldName then
      local dataTable = flatSkinData[tableName]
      if dataTable then
        for _, entry in ipairs(dataTable) do
          local componentId = entry.component or entry.index or entry.overlayId or entry.prop
          if componentId == tonumber(indexStr) then
            humanReadableSkin[key] = entry[fieldName]
          end
        end
      end
    elseif data.mapping:find("hairColor") then
      local hairField = data.mapping:gsub("hairColor%.", "")
      humanReadableSkin[key] = flatSkinData.hairColor and flatSkinData.hairColor[hairField]
    else
      humanReadableSkin[key] = flatSkinData[data.mapping]
    end
  end
  if flatSkinData.tattoos then
    for zone, tattoos in pairs(flatSkinData.tattoos) do
      humanReadableSkin.tattoos[zone] = tattoos
    end
  end
  return humanReadableSkin
end