currentPlayerSkin = {}
previousSkinData = {}
currentTattoos = {}
local oldHealth = nil
local oldArmor = nil
RegisterNetEvent('0r-clothing:loadSkin:client', function(_, model, data)
    oldHealth = GetEntityHealth(PlayerPedId())
    oldArmor = GetPedArmour(PlayerPedId())
    if not model then return end
    model = model ~= nil and (tonumber(model) or GetHashKey(model)) or GetHashKey("mp_m_freemode_01")
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

RegisterNetEvent('0r-clothing:loadPlayerTattoos:client', function(tattooList)
    tattooList = json.decode(tattooList)
    for k, v in pairs(tattooList) do
        if GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') then
            SetPedDecoration(PlayerPedId(), v.collection, v.name)
        else
            SetPedDecoration(PlayerPedId(), v.collection, v.name2)
        end
    end
    currentTattoos = tattooList
end)

RegisterCommand('refreshskin', function()
    if IsEntityDead(PlayerPedId()) then return end
    if GetResourceState("leyendas_ambulancejob") == "starting" or GetResourceState("leyendas_ambulancejob") == "started" then if exports["leyendas_ambulancejob"]:isDead() then return end end
    TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
end)

local currentClothStoreType = nil
skinData = {}
clothingStoreOpen = false
headBlendData = {
    firstShape = 0,
    secondShape = 0,
    thirdShape = 0,
    firstSkin = 0,
    secondSkin = 0,
    thirdSkin = 0,
    shapeMix = 0.0,
    skinMix = 1.0,
    thirdMix = 0.0
}

local hairDecor = {
    male = {
        [0] = {"",""},
        [1] = {"multiplayer_overlays", "FM_M_Hair_001_a"},
        [2] = {"multiplayer_overlays", "NG_M_Hair_002"},
        [3] = {"multiplayer_overlays", "FM_M_Hair_003_a"},
        [4] = {"multiplayer_overlays", "NG_M_Hair_004"},
        [5] = {"multiplayer_overlays", "FM_M_Hair_long_a"},
        [6] = {"multiplayer_overlays", "FM_M_Hair_006_a"},
        [8] = {"multiplayer_overlays", "FM_M_Hair_008_a"},
        [9] = {"multiplayer_overlays", "NG_M_Hair_009"},
        [10] = {"multiplayer_overlays", "NG_M_Hair_013"},
        [11] = {"multiplayer_overlays", "NG_M_Hair_002"},
        [12] = {"multiplayer_overlays", "NG_M_Hair_011"},
        [13] = {"multiplayer_overlays", "NG_M_Hair_012"},
        [14] = {"multiplayer_overlays", "NG_M_Hair_014"},
        [15] = {"multiplayer_overlays", "NG_M_Hair_015"},
        [16] = {"multiplayer_overlays", "NGBea_M_Hair_000"},
        [17] = {"multiplayer_overlays", "NGBea_M_Hair_001"},
        [18] = {"mpbusiness_overlays", "FM_Bus_M_Hair_000_a"},
        [19] = {"mpbusiness_overlays", "FM_Bus_M_Hair_001_a"},
        [20] = {"mphipster_overlays", "FM_Hip_M_Hair_000_a"},
        [21] = {"mphipster_overlays", "FM_Hip_M_Hair_001_a"},
        [22] = {"multiplayer_overlays", "NGInd_M_Hair_000"},
        [24] = {"mplowrider_overlays", "LR_M_Hair_000"},
        [25] = {"mplowrider_overlays", "LR_M_Hair_001"},
        [26] = {"mplowrider_overlays", "LR_M_Hair_002"},
        [27] = {"mplowrider_overlays", "LR_M_Hair_003"},
        [28] = {"mplowrider2_overlays", "LR_M_Hair_004"},
        [29] = {"mplowrider2_overlays", "LR_M_Hair_005"},
        [30] = {"mplowrider2_overlays", "LR_M_Hair_006"},
        [31] = {"mpbiker_overlays", "MP_Biker_Hair_000_M"},
        [32] = {"mpbiker_overlays", "MP_Biker_Hair_001_M"},
        [33] = {"mpbiker_overlays", "MP_Biker_Hair_002_M"},
        [34] = {"mpbiker_overlays", "MP_Biker_Hair_003_M"},
        [35] = {"mpbiker_overlays", "MP_Biker_Hair_004_M"},
        [36] = {"mpbiker_overlays", "MP_Biker_Hair_005_M"},

        [72] = {"mpgunrunning_overlays", "MP_Gunrunning_Hair_M_000_M"},
        [73] = {"mpgunrunning_overlays", "MP_Gunrunning_Hair_M_001_M"},
        [74] = {"mpvinewood_overlays", "MP_Vinewood_Hair_M_000_M"},
        [75] = {"mptuner_overlays", "MP_Tuner_Hair_001_M"},
        [76] = {"mpsecurity_overlays", "MP_Security_Hair_001_M"},
    },
    female = {
        [0] = {"",""},
        [1] = {"multiplayer_overlays", "NG_F_Hair_001"},
        [2] = {"multiplayer_overlays", "NG_F_Hair_002"},
        [3] = {"multiplayer_overlays", "FM_F_Hair_003_a"},
        [4] = {"multiplayer_overlays", "NG_F_Hair_004"},
        [5] = {"multiplayer_overlays", "FM_F_Hair_005_a"},
        [6] = {"multiplayer_overlays", "FM_F_Hair_006_a"},
        [7] = {"multiplayer_overlays", "NG_F_Hair_007"},
        [8] = {"multiplayer_overlays", "NG_F_Hair_008"},
        [9] = {"multiplayer_overlays", "NG_F_Hair_009"},
        [10] = {"multiplayer_overlays", "NG_F_Hair_010"},
        [11] = {"multiplayer_overlays", "NG_F_Hair_011"},
        [12] = {"multiplayer_overlays", "NG_F_Hair_012"},
        [13] = {"multiplayer_overlays", "FM_F_Hair_013_a"},
        [14] = {"multiplayer_overlays", "FM_F_Hair_014_a"},
        [15] = {"multiplayer_overlays", "NG_M_Hair_015"},
        [16] = {"multiplayer_overlays", "NGBea_F_Hair_000"},
        [17] = {"mpbusiness_overlays", "FM_Bus_F_Hair_a"},
        [18] = {"multiplayer_overlays", "NG_F_Hair_007"},
        [19] = {"multiplayer_overlays", "NGBus_F_Hair_000"},
        [20] = {"multiplayer_overlays", "NGBus_F_Hair_001"},
        [21] = {"multiplayer_overlays", "NGBea_F_Hair_001"},
        [22] = {"mphipster_overlays", "FM_Hip_F_Hair_000_a"},
        [23] = {"multiplayer_overlays", "NGInd_F_Hair_000"},
        [25] = {"mplowrider_overlays", "LR_F_Hair_000"},
        [26] = {"mplowrider_overlays", "LR_F_Hair_001"},
        [27] = {"mplowrider_overlays", "LR_F_Hair_002"},
        [29] = {"mplowrider2_overlays", "LR_F_Hair_003"},
        [30] = {"mplowrider2_overlays", "LR_F_Hair_004"},
        [31] = {"mplowrider2_overlays", "LR_F_Hair_006"},
        [32] = {"mpbiker_overlays", "MP_Biker_Hair_000_F"},
        [33] = {"mpbiker_overlays", "MP_Biker_Hair_001_F"},
        [34] = {"mpbiker_overlays", "MP_Biker_Hair_002_F"},
        [35] = {"mpbiker_overlays", "MP_Biker_Hair_003_F"},
        [38] = {"mpbiker_overlays", "MP_Biker_Hair_004_F"},
        [36] = {"mpbiker_overlays", "MP_Biker_Hair_005_F"},
        [37] = {"mpbiker_overlays", "MP_Biker_Hair_005_F"},
        [76] = {"mpgunrunning_overlays", "MP_Gunrunning_Hair_F_000_F"},
        [77] = {"mpgunrunning_overlays", "MP_Gunrunning_Hair_F_001_F"},
        [78] = {"mpvinewood_overlays", "MP_Vinewood_Hair_F_000_F"},
        [79] = {"mptuner_overlays", "MP_Tuner_Hair_000_F"},
        [80] = {"mpsecurity_overlays", "MP_Security_Hair_000_F"},
    }
}

RegisterNetEvent('0r-clothing:client:loadPlayerClothing', function(data, ped)
    loadPlayerClothing(data, ped)
end)

function loadPlayerClothing(data, ped)
    currentPlayerSkin = {}
    if data then
        if not next(data) or (data.sex ~= nil and next(data, "sex") == nil) then return end
    else
        return
    end
    if data.headBlend then
        data = ConvertIlleniumToQB(data)
        Citizen.Wait(1000)
    end
    if ped == nil then ped = PlayerPedId() end
    for i = 0, 11 do SetPedComponentVariation(ped, i, 0, 0, 0) end
    for i = 0, 7 do ClearPedProp(ped, i) end
    -- Face
    if not data["facemix"] then
        data["facemix"] = {skinMix = 0.0, shapeMix = 0.0, thirdMix = 0.0}
    end
    if not data["face"] then
        data["face"] = {item = 1, texture = 0}
    end
    if not data["face2"] then
        data["face2"] = {item = 1, texture = 0}
    end
    if not data["face3"] then
        data["face3"] = {item = 1, texture = 0}
    end
    if type(data["face"]) == "number" or type(data["face"]) == "string" then
        data["face"] = {item = tonumber(data["face"]), texture = 0}
    end
    if data["face"] and data["face2"] and data["face3"] and data["facemix"] then
        if data["face"].item and data["face2"].item and data["face3"].item and data["face"].texture and data["face2"].texture and data["face3"].texture and data["facemix"].shapeMix and data["facemix"].skinMix and data["facemix"].thirdMix then 
            headBlendData = {
                firstShape = data["face"].item,
                secondShape = data["face2"].item,
                thirdShape = data["face3"].item,
                firstSkin = data["face"].texture,
                secondSkin = data["face2"].texture,
                thirdSkin = data["face3"].texture,
                shapeMix = data["facemix"].shapeMix,
                skinMix = data["facemix"].skinMix,
                thirdMix = data["facemix"].thirdMix
            }
            if GetEntityModel(ped) == GetHashKey('mp_m_freemode_01') or GetEntityModel(ped) == GetHashKey('mp_f_freemode_01') then
                SetPedHeadBlendData(ped, data["face"].item, data["face2"].item, data["face3"].item, data["face"].texture, data["face2"].texture, data["face3"].texture, data["facemix"].shapeMix, data["facemix"].skinMix, data["facemix"].thirdMix, false)
            end
        end
    end

    -- Pants
    if data["pants_1"] then data["pants"] = {} data["pants"].item = data["pants_1"] data["pants_1"] = nil end
    if data["pants_2"] then data["pants"].texture = data["pants_2"] data["pants_2"] = nil end
    if not data["pants"] then data["pants"] = {item = 0, texture = 0} end
    SetPedComponentVariation(ped, 4, data["pants"].item, 0, 0)
    SetPedComponentVariation(ped, 4, data["pants"].item, data["pants"].texture, 0)

    -- Hair
    if data["hair_1"] then data["hair"] = {} data["hair"].item = data["hair_1"] data["hair_1"] = nil end
    if data["hair_color_1"] then data["hair"].texture = data["hair_color_1"] data["hair_color_1"] = nil end
    if not data["hair"] then data["hair"] = {item = -1, texture = 0, texture2 = 0} end
    SetPedComponentVariation(ped, 2, data["hair"].item, 0, 0)
    if data["hair"].texture then
        SetPedHairTint(ped, data["hair"].texture, data["hair"].texture)
    end
    if data["hair"].texture and data["hair"].texture2 then
        SetPedHairTint(ped, data["hair"].texture, data["hair"].texture2)
    end

    -- Eyebrows
    if type(data['eyebrows_1']) == "number" then 
        local num = data['eyebrows_1'] 
        data['eyebrows'] = {} 
        data['eyebrows'].item = num 
        data['eyebrows_1'] = nil
    end
    if type(data['eyebrows_2']) == "number" then 
        local num = data['eyebrows_2']
        if not data['eyebrows'] then
            data['eyebrows'] = {} 
        end
        data['eyebrows'].texture = (data["eyebrows_2"] / 10) + 0.0 
        data['eyebrows_2'] = nil
    end
    if not data["eyebrows"] or not data["eyebrows"].item then
        data["eyebrows"] = {item = 0, texture = -1, opacity = 1.0}
    end
    if not data['eyebrows'].opacity then
        data['eyebrows'].opacity = 1.0
    end
    if data['eyebrows'] and data['eyebrows'].opacity <= 1.0 then
        SetPedHeadOverlay(ped, 2, data["eyebrows"].item, data["eyebrows"].opacity + 0.0)
    else
        SetPedHeadOverlay(ped, 2, data["eyebrows"].item, (data["eyebrows"].opacity / 10) + 0.0)
    end
    SetPedHeadOverlayColor(ped, 2, 1, data["eyebrows"].texture, 0)

    -- Beard
    if type(data['beard_1']) == "number" then 
        local num = data['beard_1'] 
        data['beard'] = {} 
        data['beard'].item = num 
        data['beard_1'] = nil
    end
    if type(data['beard_2']) == "number" then 
        local num = data['beard_2']
        if not data['beard'] then
            data['beard'] = {item = 0} 
        end
        data['beard'].opacity = (data["beard_2"] / 10) + 0.0 
        data['beard_2'] = nil
    end
    if type(data['beard_3']) == "number" then 
        local num = data['beard_3']
        if not data['beard'] then
            data['beard'] = {item = 0} 
        end
        data['beard'].texture = (data["beard_3"] / 10) + 0.0 
        data['beard_3'] = nil
    end
    if not data["beard"] or not data["beard"].item then data["beard"] = {item = -1, texture = -1, opacity = 1.0} end
    if not data["beard"].texture then data["beard"].texture = 0 end
    if not data["beard"].opacity then data["beard"].opacity = 1.0 end
    SetPedHeadOverlay(ped, 1, data["beard"].item, data["beard"].opacity)
    SetPedHeadOverlayColor(ped, 1, 1, data["beard"].texture, 0)

    -- Blush
    if data["blush_1"] and data["blush_2"] then
        data["blush"] = {item = data["blush_1"], texture = (data["blush_2"] / 10) + 0.0}
        data["blush_1"] = nil
        data["blush_2"] = nil
    end
    if not data["blush"] then data["blush"] = {item = -1, texture = -1} end
    SetPedHeadOverlay(ped, 5, data["blush"].item, data["blush"].opacity or 1.0)
    SetPedHeadOverlayColor(ped, 5, 2, data["blush"].texture, 0)

    -- Lipstick
    if data["lipstick_1"] and data["lipstick_2"] then
        data["lipstick"] = {item = data["lipstick_1"], texture = (data["lipstick_2"] / 10) + 0.0}
        data["lipstick_1"] = nil
        data["lipstick_2"] = nil
    end
    if not data["lipstick"] then data["lipstick"] = {item = -1, texture = -1} end
    SetPedHeadOverlay(ped, 8, data["lipstick"].item, data["lipstick"].opacity or 1.0)
    SetPedHeadOverlayColor(ped, 8, 2, data["lipstick"].texture, 0)

    -- Makeup
    if data["makeup_1"] and data["makeup_3"] then
        data["makeup"] = {item = data["makeup_1"], texture = data["makeup_3"]}
        data["makeup_1"] = nil
        data["makeup_3"] = nil
    end
    if not data["makeup"] then data["makeup"] = {item = -1, texture = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 4, data["makeup"].item, data["makeup"].opacity or 1.0)
    SetPedHeadOverlayColor(ped, 4, 1, data["makeup"].texture, 0)

    -- Ageing
    if data["age_1"] then data["ageing"] = {} data["ageing"].item = data["age_1"] data["age_1"] = nil end
    if data["age_2"] then data["ageing"].texture = (data["age_2"] / 10) + 0.0 data["age_2"] = nil end
    if not data["ageing"] then data["ageing"] = {item = -1, texture = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 3, data["ageing"].item, data["ageing"].opacity or 1.0)
    SetPedHeadOverlayColor(ped, 3, 1, data["ageing"].texture, 0)

    -- Arms
    if type(data["arms"]) == "string" or type(data["arms"]) == "number" then local num = tonumber(data["arms"]) data["arms"] = {} data["arms"].item = num end
    --if type(data["arms"]) == "table" then local nda = data["arms"] data["arms"] = {} data["arms"].item = end
    if data["arms_2"] then data["arms"].texture = data["arms_2"] data["arms_2"] = nil end
    if data["arms/gloves"] then data["arms"] = {} data["arms"] = data["arms/gloves"] data["arms/gloves"] = nil end
    if not data["arms"] then data["arms"] = {item = 0, texture = 0} end
    SetPedComponentVariation(ped, 3, data["arms"].item, 0, 2)
    SetPedComponentVariation(ped, 3, data["arms"].item, data["arms"].texture, 0)
    
    -- T-Shirt
    if data["undershirt"] then data["t-shirt"] = data["undershirt"] end
    if data["tshirt_1"] then data["t-shirt"] = {} data["t-shirt"].item = data["tshirt_1"] data["tshirt_1"] = nil end
    if data["tshirt_2"] then data["t-shirt"].texture = data["tshirt_2"] data["tshirt_2"] = nil end
    if not data["t-shirt"] then data["t-shirt"] = {item = 0, texture = 0} end
    SetPedComponentVariation(ped, 8, data["t-shirt"].item, 0, 2)
    SetPedComponentVariation(ped, 8, data["t-shirt"].item, data["t-shirt"].texture, 0)
    -- Vest
    if data["bproof_1"] then data["vest"] = {} data["vest"].item = data["bproof_1"] data["bproof_1"] = nil end
    if data["bproof_2"] then data["vest"].texture = data["bproof_2"] data["bproof_2"] = nil end
    if not data["vest"] then data["vest"] = {item = 0, texture = 0} end
    SetPedComponentVariation(ped, 9, data["vest"].item, 0, 2)
    SetPedComponentVariation(ped, 9, data["vest"].item, data["vest"].texture, 0)
    -- Torso 2
    if data["jacket"] then data["torso2"] = data["jacket"] end
    if data["torso_1"] then data["torso2"] = {} data["torso2"].item = data["torso_1"] data["torso_1"] = nil end
    if data["torso_2"] then data["torso2"].texture = data["torso_2"] data["torso_2"] = nil end
    if not data["torso2"] then data["torso2"] = {item = 0, texture = 0} end
    SetPedComponentVariation(ped, 11, data["torso2"].item, 0, 2)
    SetPedComponentVariation(ped, 11, data["torso2"].item, data["torso2"].texture, 0)
    -- Shoes
    if data["shoes_1"] then data["shoes"] = {} data["shoes"].item = data["shoes_1"] data["shoes_1"] = nil end
    if data["shoes_2"] then data["shoes"].texture = data["shoes_2"] data["shoes_2"] = nil end
    if not data["shoes"] then data["shoes"] = {item = 0, texture = 0} end
    SetPedComponentVariation(ped, 6, data["shoes"].item, 0, 2)
    SetPedComponentVariation(ped, 6, data["shoes"].item, data["shoes"].texture, 0)

    -- Mask
    if data["masks"] then data["mask"] = data["masks"] end
    if data["mask_1"] then data["mask"] = {} data["mask"].item = data["mask_1"] data["mask_1"] = nil end
    if data["mask_2"] and data["mask"] then  data["mask"].texture = data["mask_2"] data["mask_2"] = nil  end
    if not data["mask"] then data["mask"] = {item = -1, texture = 0} end
    SetPedComponentVariation(ped, 1, data["mask"].item, 0, 2)
    SetPedComponentVariation(ped, 1, data["mask"].item, data["mask"].texture, 0)

    -- Badge
    if data["decals_1"] then data["decals"] = {} data["decals"].item = data["decals_1"] data["decals_1"] = nil end
    if data["decals_2"] then data["decals"].texture = data["decals_2"] data["decals_2"] = nil end
    if not data["decals"] then data["decals"] = {item = -1, texture = 0} end
    SetPedComponentVariation(ped, 10, data["decals"].item, 0, 2)
    SetPedComponentVariation(ped, 10, data["decals"].item, data["decals"].texture, 0)

    -- Accessory
    if data["scarfs/necklaces"] then data["accessory"] = data["scarfs/necklaces"] end
    if data["chain_1"] then data["accessory"] = {} data["accessory"].item = data["chain_1"] data["chain_1"] = nil end
    if data["chain_2"] then data["accessory"].texture = data["chain_2"] data["chain_2"] = nil end
    SetPedComponentVariation(ped, 7, data["accessory"].item, 0, 2)
    SetPedComponentVariation(ped, 7, data["accessory"].item, data["accessory"].texture, 0)

    -- Bag
    if data["bags_1"] then data["bag"] = {} data["bag"].item = data["bags_1"] data["bags_1"] = nil end
    if data["bags_2"] then data["bag"].texture = data["bags_2"] data["bags_2"] = nil end
    if not data["bag"] then data["bag"] = {item = -1, texture = 0} end
    SetPedComponentVariation(ped, 5, data["bag"].item, 0, 2)
    SetPedComponentVariation(ped, 5, data["bag"].item, data["bag"].texture, 0)

    -- Hat
    if data["helmet_1"] then data["hat"] = {} data["hat"].item = data["helmet_1"] data["helmet_1"] = nil end
    if data["helmet_2"] then data["hat"].texture = data["helmet_2"] data["helmet_2"] = nil end
    if data["hat"].item ~= -1 then
        SetPedPropIndex(ped, 0, data["hat"].item, data["hat"].texture, true)
    else
        ClearPedProp(ped, 0)
    end
    -- Glass
    if data["glasses"] then data["glass"] = data["glasses"] end
    if data["glasses_1"] then data["glass"] = {} data["glass"].item = data["glasses_1"] data["glasses_1"] = nil end
    if data["glasses_2"] then data["glass"].texture = data["glasses_2"] data["glasses_2"] = nil end
    if data["glass"].item == 0 then data["glass"].item = -1 end
    if data["glass"].item ~= -1 and data["glass"].item ~= 0 then
        SetPedPropIndex(ped, 1, data["glass"].item, data["glass"].texture, true)
    else
        ClearPedProp(ped, 1)
    end
    
    -- Ear
    if data["earrings"] then data["ear"] = data["earrings"] end
    if data["ears_1"] then data["ear"] = {} data["ear"].item = data["ears_1"] data["ears_1"] = nil end
    if data["ears_2"] then data["ear"].texture = data["ears_2"] data["ears_2"] = nil end
    if data["ear"].item ~= -1 and data["ear"].item ~= 0 then
        SetPedPropIndex(ped, 2, data["ear"].item, data["ear"].texture, true)
    else
        ClearPedProp(ped, 2)
    end

    -- Watch
    if data["watches"] then data["watch"] = data["watches"] end
    if data["watches_1"] then data["watch"] = {} data["watch"].item = data["watches_1"] data["watches_1"] = nil end
    if data["watches_2"] then data["watch"].texture = data["watches_2"] data["watches_2"] = nil end
    if data["watch"].item ~= -1 and data["watch"].item ~= 0 then
        SetPedPropIndex(ped, 6, data["watch"].item, data["watch"].texture, true)
    else
        ClearPedProp(ped, 6)
    end

    -- Bracelet
    if data["bracelets"] then data["bracelet"] = data["bracelets"] end
    if data["bracelets_1"] then data["bracelet"] = {} data["bracelet"].item = data["bracelets_1"] data["bracelets_2"] = nil end
    if data["bracelets_2"] then data["bracelet"].texture = data["bracelets_2"] data["bracelets_2"] = nil end
    if data["bracelet"].item ~= -1 and data["bracelet"].item ~= 0 then
        SetPedPropIndex(ped, 7, data["bracelet"].item, data["bracelet"].texture, true)
    else
        ClearPedProp(ped, 7)
    end
    -- Eye Color
    if data["eye_color"] and type(data["eye_color"]) == "number" then
        data["eye_color"] = {item = data["eye_color"]}
    end
    if not data['eye_color'] then data['eye_color'] = {item = 0} end
    if data["eye_color"].item ~= -1 and data["eye_color"].item ~= 0 then
        SetPedEyeColor(ped, data['eye_color'].item)
    end

    -- Moles / Freckles
    if data["molesfreckles"] then data["moles"] = data["molesfreckles"] end
    if data["moles_1"] then data["moles"] = {} data["moles"].item = data["moles_1"] data["moles_1"] = nil end
    if data["moles_2"] and data["moles"] then data["moles"].texture = data["moles_2"] data["moles_2"] = nil  end
    if data["moles"] and data["moles"].item ~= -1 and data["moles"].item ~= 0 then
        SetPedHeadOverlay(ped, 9, data['moles'].item, (data['moles'].texture / 10) + 0.0)
    end

    -- Nose
    if data['nose_0'] then
        if data['nose_0'] then
            if data['nose_0'].item <= 1.0 then
                SetPedFaceFeature(ped, 0, data['nose_0'].item + 0.0)
            else
                SetPedFaceFeature(ped, 0, (data['nose_0'].item / 10) + 0.0)
            end
        end
        if data['nose_1'] then
            if data['nose_1'].item <= 1.0 then
                SetPedFaceFeature(ped, 1, data['nose_1'].item + 0.0)
            else
                SetPedFaceFeature(ped, 1, (data['nose_1'].item / 10) + 0.0)
            end
        end
        if data['nose_2'] then
            if data['nose_2'].item <= 1.0 then
                SetPedFaceFeature(ped, 2, data['nose_2'].item + 0.0)
            else
                SetPedFaceFeature(ped, 2, (data['nose_2'].item / 10) + 0.0)
            end
        end
        if data['nose_3'] then
            if data['nose_3'].item <= 1.0 then
                SetPedFaceFeature(ped, 3, data['nose_3'].item + 0.0)
            else
                SetPedFaceFeature(ped, 3, (data['nose_3'].item / 10) + 0.0)
            end
        end
        if data['nose_4'] then
            if data['nose_4'].item <= 1.0 then
                SetPedFaceFeature(ped, 4, data['nose_4'].item + 0.0)
            else
                SetPedFaceFeature(ped, 4, (data['nose_4'].item / 10) + 0.0)
            end
        end
        if data['nose_5'] then
            if data['nose_5'].item <= 1.0 then
                SetPedFaceFeature(ped, 5, data['nose_5'].item + 0.0)
            else
                SetPedFaceFeature(ped, 5, (data['nose_5'].item / 10) + 0.0)
            end
        end
    else
        if data['nose_1'] then
            if data['nose_1'].item <= 1.0 then
                SetPedFaceFeature(ped, 0, data['nose_1'].item + 0.0)
            else
                SetPedFaceFeature(ped, 0, (data['nose_1'].item / 10) + 0.0)
            end
        end
        if data['nose_2'] then
            if data['nose_2'].item <= 1.0 then
                SetPedFaceFeature(ped, 1, data['nose_2'].item + 0.0)
            else
                SetPedFaceFeature(ped, 1, (data['nose_2'].item / 10) + 0.0)
            end
        end
        if data['nose_3'] then
            if data['nose_3'].item <= 1.0 then
                SetPedFaceFeature(ped, 2, data['nose_3'].item + 0.0)
            else
                SetPedFaceFeature(ped, 2, (data['nose_3'].item / 10) + 0.0)
            end
        end
        if data['nose_4'] then
            if data['nose_4'].item <= 1.0 then
                SetPedFaceFeature(ped, 3, data['nose_4'].item + 0.0)
            else
                SetPedFaceFeature(ped, 3, (data['nose_4'].item / 10) + 0.0)
            end
        end
        if data['nose_5'] then
            if data['nose_5'].item <= 1.0 then
                SetPedFaceFeature(ped, 4, data['nose_5'].item + 0.0)
            else
                SetPedFaceFeature(ped, 4, (data['nose_5'].item / 10) + 0.0)
            end
        end
        if data['nose_6'] then
            if data['nose_6'].item <= 1.0 then
                SetPedFaceFeature(ped, 5, data['nose_6'].item + 0.0)
            else
                SetPedFaceFeature(ped, 5, (data['nose_6'].item / 10) + 0.0)
            end
        end
    end

    -- Eyebrows
    if type(data['eyebrows_5']) == "number" then 
        local num = data['eyebrows_5'] 
        data['eyebrown_high'] = {} 
        data['eyebrown_high'].item = num 
        data['eyebrows_5'] = nil
    end
    if type(data['eyebrows_6']) == "number" then 
        local num = data['eyebrows_6'] 
        data['eyebrown_forward'] = {} 
        data['eyebrown_forward'].item = num 
        data['eyebrows_6'] = nil
    end
    if data['eyebrown_high'] then
        if data['eyebrown_high'].item <= 1.0 then
            SetPedFaceFeature(ped, 6, data['eyebrown_high'].item + 0.0)
        else
            SetPedFaceFeature(ped, 6, (data['eyebrown_high'].item / 10) + 0.0)
        end
    end
    if data['eyebrown_forward'] then
        if data['eyebrown_forward'].item <= 1.0 then
            SetPedFaceFeature(ped, 7, data['eyebrown_forward'].item + 0.0)
        else
            SetPedFaceFeature(ped, 7, (data['eyebrown_forward'].item / 10) + 0.0)
        end
    end

    -- Cheeks
    if type(data['cheeks_1']) == "number" then 
        local num = data['cheeks_1'] 
        data['cheek_1'] = {} 
        data['cheek_1'].item = num 
        data['cheeks_1'] = nil
    end
    if type(data['cheeks_2']) == "number" then 
        local num = data['cheeks_2'] 
        data['cheek_2'] = {} 
        data['cheek_2'].item = num 
        data['cheeks_2'] = nil
    end
    if type(data['cheeks_3']) == "number" then 
        local num = data['cheeks_3'] 
        data['cheek_3'] = {} 
        data['cheek_3'].item = num 
        data['cheeks_3'] = nil
    end
    if data['cheek_1'] then
        if data['cheek_1'].item <= 1.0 then
            SetPedFaceFeature(ped, 8, data['cheek_1'].item + 0.0)
        else
            SetPedFaceFeature(ped, 8, (data['cheek_1'].item / 10) + 0.0)
        end
    end
    if data['cheek_2'] then
        if data['cheek_2'].item <= 1.0 then
            SetPedFaceFeature(ped, 9, data['cheek_2'].item + 0.0)
        else
            SetPedFaceFeature(ped, 9, (data['cheek_2'].item / 10) + 0.0)
        end
    end
    if data['cheek_3'] then
        if data['cheek_3'].item <= 1.0 then
            SetPedFaceFeature(ped, 10, data['cheek_3'].item + 0.0)
        else
            SetPedFaceFeature(ped, 10, (data['cheek_3'].item / 10) + 0.0)
        end
    end

    -- Eye Squint
    if type(data['eye_squint']) == "number" then 
        local num = data['eye_squint'] 
        data['eye_opening'] = {} 
        data['eye_opening'].item = num 
        data['eye_squint'] = nil
    end
    if data['eye_opening'] then
        if data['eye_opening'].item <= 1.0 then
            SetPedFaceFeature(ped, 11, data['eye_opening'].item + 0.0)
        else
            SetPedFaceFeature(ped, 11, (data['eye_opening'].item / 10) + 0.0)
        end
    end

    -- Lip Thickness
    if type(data['lip_thickness']) == "number" then 
        local num = data['lip_thickness'] 
        data['lips_thickness'] = {} 
        data['lips_thickness'].item = num 
        data['lip_thickness'] = nil
    end
    if data['lips_thickness'] then
        if data['lips_thickness'].item <= 1.0 then
            SetPedFaceFeature(ped, 12, data['lips_thickness'].item + 0.0)
        else
            SetPedFaceFeature(ped, 12, (data['lips_thickness'].item / 10) + 0.0)
        end
    end

    -- Jaw
    if type(data['jaw_1']) == "number" then 
        local num = data['jaw_1'] 
        data['jaw_bone_width'] = {} 
        data['jaw_bone_width'].item = num 
        data['jaw_1'] = nil
    end
    if type(data['jaw_2']) == "number" then 
        local num = data['jaw_2'] 
        data['jaw_bone_back_lenght'] = {} 
        data['jaw_bone_back_lenght'].item = num 
        data['jaw_2'] = nil
    end
    if data['jaw_bone_width'] then
        if data['jaw_bone_width'].item <= 1.0 then
            SetPedFaceFeature(ped, 13, data['jaw_bone_width'].item + 0.0)
        else
            SetPedFaceFeature(ped, 13, (data['jaw_bone_width'].item / 10) + 0.0)
        end
    end
    if data['jaw_bone_back_lenght'] then
        if data['jaw_bone_back_lenght'].item <= 1.0 then
            SetPedFaceFeature(ped, 14, data['jaw_bone_back_lenght'].item + 0.0)
        else
            SetPedFaceFeature(ped, 14, (data['jaw_bone_back_lenght'].item / 10) + 0.0)
        end
    end

    -- Chimp
    if type(data['chin_1']) == "number" then 
        local num = data['chin_1'] 
        data['chimp_bone_lowering'] = {} 
        data['chimp_bone_lowering'].item = num 
        data['chin_1'] = nil
    end
    if type(data['chin_2']) == "number" then 
        local num = data['chin_2'] 
        data['chimp_bone_lenght'] = {} 
        data['chimp_bone_lenght'].item = num 
        data['chin_2'] = nil
    end
    if type(data['chin_3']) == "number" then 
        local num = data['chin_3'] 
        data['chimp_bone_width'] = {} 
        data['chimp_bone_width'].item = num 
        data['chin_3'] = nil
    end
    if type(data['chin_4']) == "number" then 
        local num = data['chin_4'] 
        data['chimp_hole'] = {} 
        data['chimp_hole'].item = num 
        data['chin_4'] = nil
    end
    if not data['chimp_bone_lowering'] then data['chimp_bone_lowering'] = {} data['chimp_bone_lowering'].item = 0.5 end
    if data['chimp_bone_lowering'] then
        if data['chimp_bone_lowering'].item <= 1.0 then
            SetPedFaceFeature(ped, 15, data['chimp_bone_lowering'].item)
        else
            SetPedFaceFeature(ped, 15, (data['chimp_bone_lowering'].item / 10) + 0.0)
        end
    end
    if not data['chimp_bone_lenght'] then data['chimp_bone_lenght'] = {} data['chimp_bone_lenght'].item = 0.5 end 
    if data['chimp_bone_lenght'] then
        if data['chimp_bone_lenght'].item <= 1.0 then
            SetPedFaceFeature(ped, 16, data['chimp_bone_lenght'].item)
        else
            SetPedFaceFeature(ped, 16, (data['chimp_bone_lenght'].item / 10) + 0.0)
        end
    end
    if not data['chimp_bone_width'] then data['chimp_bone_width'] = {} data['chimp_bone_width'].item = 0.5 end 
    if data['chimp_bone_width'] then
        if data['chimp_bone_width'].item <= 1.0 then
            SetPedFaceFeature(ped, 17, data['chimp_bone_width'].item)
        else
            SetPedFaceFeature(ped, 17, (data['chimp_bone_width'].item / 10) + 0.0)
        end
    end
    if not data['chimp_hole'] then data['chimp_hole'] = {} data['chimp_hole'].item = 0.5 end 
    if data['chimp_hole'] then
        if data['chimp_hole'].item <= 1.0 then
            SetPedFaceFeature(ped, 18, data['chimp_hole'].item)
        else
            SetPedFaceFeature(ped, 18, (data['chimp_hole'].item / 10) + 0.0)
        end
    end

    -- Neck
    if data['neck_thickness'] and type(data['neck_thickness']) == "number" then 
        local num = data['neck_thickness'] 
        data['neck_thickness'] = {} 
        data['neck_thickness'].item = num 
    end
    local NeckThickness = 0.5
    if data['neck_thickness'] then
        NeckThickness = data['neck_thickness'].item + 0.0
        if NeckThickness > 1.0 then
            NeckThickness = NeckThickness / 10
        end
    end
    SetPedFaceFeature(ped, 19, NeckThickness)

    -- Hair Fade
    if data["hairFade"] and data["hairFade"].item == 1 then
        ClearPedDecorationsLeaveScars(ped)
        local gender = "female"
        if GetEntityModel(ped) == GetHashKey('mp_m_freemode_01') then
            gender = "male"
        end
        if data["hair"].item and hairDecor[gender][data["hair"].item] then
            AddPedDecorationFromHashes(ped, hairDecor[gender][data["hair"].item][1], hairDecor[gender][data["hair"].item][2])
        end
    end

    -- Blemishes
    if not data['blemishes'] then data['blemishes'] = {item = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 0, data['blemishes'].item, data['blemishes'].opacity or 1.0)

    -- Ageing
    if not data['ageing'] then data['ageing'] = {item = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 3, data['ageing'].item, data['ageing'].opacity or 1.0)

    -- Complexion
    if not data['complexion'] then data['complexion'] = {item = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 6, data['complexion'].item, data['complexion'].opacity or 1.0)

    -- Sun Damage
    if not data['sundamage'] then data['sundamage'] = {item = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 7, data['sundamage'].item, data['sundamage'].opacity or 1.0)

    -- Moles & Freckles
    if not data['molesfreckles'] then data['molesfreckles'] = {item = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 9, data['molesfreckles'].item, data['molesfreckles'].opacity or 1.0)

    -- Chest Hair
    if not data['chesthair'] then data['chesthair'] = {item = -1, texture = 0, opacity = 1.0} end
    SetPedHeadOverlay(ped, 10, data['chesthair'].item, data['chesthair'].opacity or 1.0)
    SetPedHeadOverlayColor(ped, 10, 1, data['chesthair'].texture, 0)

    -- Body Blemishes
    if not data['bodyblemishes'] then data['bodyblemishes'] = {item = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 11, data['bodyblemishes'].item, data['bodyblemishes'].opacity or 1.0)
    SetPedHeadOverlayColor(ped, 11, 0, data['chesthair'].texture, 0)

    -- Add Body Blemishes
    if not data['addbodyblemishes'] then data['addbodyblemishes'] = {item = -1, opacity = 1.0} end
    SetPedHeadOverlay(ped, 12, data['addbodyblemishes'].item, data['addbodyblemishes'].opacity or 1.0)
    SetPedHeadOverlayColor(ped, 12, 0, data['chesthair'].texture, 0)

    skinData = data
    currentPlayerSkin = data
    Citizen.Wait(500)
    TriggerServerEvent('0r-clothing:loadPlayerTattoos:server')
    Citizen.Wait(1000)
    if oldHealth and tonumber(oldHealth) then
        SetEntityHealth(ped, oldHealth)
    end
    if oldArmor and tonumber(oldArmor) then
        SetPedArmour(ped, oldArmor)
    end
end

creatingChar = false
local charCreateGender = nil
function createFirstCharacter(charGender, menuType, saveable, tp)
    currentClothStoreType = "cfc"
    if not menuType then
        menuType = Config.CharacterCreationMenuCategories.Normal
    end
    local lastReady = false
    creatingChar = true
    charCreateGender = charGender
    gender = charGender
    local defaultPedModel = GetHashKey("mp_m_freemode_01")
    if charGender == "female" then
        defaultPedModel = GetHashKey("mp_f_freemode_01")
    end
    RequestModel(defaultPedModel)
    while not HasModelLoaded(defaultPedModel) do
        RequestModel(defaultPedModel)
        Citizen.Wait(0)
    end
    SetPlayerModel(PlayerId(), defaultPedModel)
    SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
    SetPedDefaultComponentVariation(PlayerPedId())
    while GetResourceState("0r-imagegenerator") == "starting" do Citizen.Wait(0) end
    local uuid = nil
    if Config.UseWebServer then
        TriggerCallback('0r-clothing:getClothingUrl:server', function(urlData)
            uuid = urlData
        end, false)
        local startTime = GetGameTimer()
        while uuid == nil do 
            Citizen.Wait(0)  
            if GetGameTimer() - startTime > 5000 then
                print("Used default UUID.")
                uuid = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6"
                break
            end 
        end
    else
        uuid = "nui://0r-imagegenerator/images/"
    end
    local generalData = {}
    local myPed = GetEntityModel(PlayerPedId())
    -- Male Peds
    local malePeds = {}
    for k, v in pairs(ManPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(malePeds, {
            num = GetHashKey(v),
            model = v,
            image = 'https://docs.fivem.net/peds/' .. v .. '.webp?v=9999'
        })
    end
    for k, v in pairs(CustomManPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(malePeds, {
            num = GetHashKey(v),
            model = v,
            image = uuid .. "_" .. GetHashKey(v) ..  '_PED.webp?v=9999',
            style = "width: 125%;"
        })
    end
    table.insert(generalData, {
        action = "MalePeds",
        data = malePeds,
        imgType = "",
        btnClick = true,
        variationNumber = 111
    })
    -- Female Peds
    local femalePeds = {}
    for k, v in pairs(WomanPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(femalePeds, {
            num = GetHashKey(v),
            model = v,
            image = 'https://docs.fivem.net/peds/' .. v .. '.webp?v=9999'
        })
    end
    for k, v in pairs(CustomWomanPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(femalePeds, {
            num = GetHashKey(v),
            model = v,
            image = uuid .. "_" .. GetHashKey(v) ..  '_PED.webp?v=9999',
            style = "width: 0%;"
        })
    end
    table.insert(generalData, {
        action = "FemalePeds",
        data = femalePeds,
        imgType = "",
        btnClick = true,
        variationNumber = 222
    })
    -- Ped Input
    table.insert(generalData, {
        action = "PedModelInput",
        data = {},
        passDataControl = true
    })
    -- Faces
    local faces = {}
    for i = 0, 9 do
        table.insert(faces, {num = i, image = 'files/faces/SKEL_ROOT.00' .. i .. '.webp?v=9999'})
    end
    for i = 10, 45 do
        table.insert(faces, {num = i, image = 'files/faces/SKEL_ROOT.0' .. i .. '.webp?v=9999'})
    end
    table.insert(generalData, {
        action = "FaceOne",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true
    })
    table.insert(generalData, {
        action = "SkinOne",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true
    })
    table.insert(generalData, {
        action = "FaceTwo",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true
    })
    table.insert(generalData, {
        action = "SkinTwo",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true
    })
    table.insert(generalData, {
        action = "FaceThree",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true
    })
    table.insert(generalData, {
        action = "SkinThree",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true
    })
    table.insert(generalData, {
        action = "FaceMix",
        data = {},
        value = headBlendData["shapeMix"]
    })
    table.insert(generalData, {
        action = "SkinMix",
        data = {},
        value = headBlendData["skinMix"]
    })
    table.insert(generalData, {
        action = "ThirdMix",
        data = {},
        value = headBlendData["thirdMix"]
    })
    table.insert(generalData, {
        action = "FaceFeatures",
        data = {},
        data2 = {
            NoseWidth = GetPedFaceFeature(PlayerPedId(), 0),
            NosePeak = GetPedFaceFeature(PlayerPedId(), 1),
            NoseLength = GetPedFaceFeature(PlayerPedId(), 2),
            NoseBoneCurveness = GetPedFaceFeature(PlayerPedId(), 3),
            NoseTip = GetPedFaceFeature(PlayerPedId(), 4),
            NoseBoneTwist = GetPedFaceFeature(PlayerPedId(), 5),
            EyebrowHeight = GetPedFaceFeature(PlayerPedId(), 6),
            EyebrowDepth = GetPedFaceFeature(PlayerPedId(), 7),
            CheekBoneHeight = GetPedFaceFeature(PlayerPedId(), 8),
            CheekBoneWidth = GetPedFaceFeature(PlayerPedId(), 9),
            CheekBoneWidth2 = GetPedFaceFeature(PlayerPedId(), 10),
            EyesSquint = GetPedFaceFeature(PlayerPedId(), 11),
            LipsThickness = GetPedFaceFeature(PlayerPedId(), 12),
            JawBoneLength = GetPedFaceFeature(PlayerPedId(), 13),
            JawBoneWidth = GetPedFaceFeature(PlayerPedId(), 14),
            ChinBoneHeight = GetPedFaceFeature(PlayerPedId(), 15),
            ChinBoneLength = GetPedFaceFeature(PlayerPedId(), 16),
            ChinBoneWidth = GetPedFaceFeature(PlayerPedId(), 17),
            ChinCleft = GetPedFaceFeature(PlayerPedId(), 18),
            NeckThickness = GetPedFaceFeature(PlayerPedId(), 19)
        }
    })
    table.insert(generalData, {
        action = "Nose",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "Eyebrows2",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "Cheeks",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "JawBone",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "Chin",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "MiscellaneousFeatures",
        data = {},
        passDataControl = true
    })
    -- Eye Color
    local eyeColors = {}
    for i = 0, 31 do
        table.insert(eyeColors, {num = i, image = 'files/eyes/' .. i .. '.webp?v=9999'})
    end
    table.insert(generalData, {
        action = "EyeColor",
        data = eyeColors,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true
    })
    -- Eyebrows
    local eyebrows = {}
    for i = -1, GetPedHeadOverlayNum(2) - 1 do
        table.insert(eyebrows, {num = i, image = 'files/eyebrows/' .. i .. '.webp?v=9999'})
    end
    table.insert(generalData, {
        action = "Eyebrows",
        data = eyebrows,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        variationNumber = 2
    })
    table.insert(generalData, {
        action = "EyebrowColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "EyebrowHighlightColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    -- Facial Hairs
    local facialHairs = {}
    if Config.UseDefaultClothImages.Hair then
        for i = -1, GetPedHeadOverlayNum(1) - 1 do
            table.insert(facialHairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(1) - 1 do
            table.insert(facialHairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "FacialHairs",
        data = facialHairs,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 1
    })
    table.insert(generalData, {
        action = "FacialHairsColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "FacialHairsHighlightColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    -- Hairs
    local hairs = {}
    if Config.UseDefaultClothImages.Hair then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(hairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(hairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Hairs",
        data = hairs,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = false,
        variationNumber = 2
    })
    table.insert(generalData, {
        action = "HairsColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "HairsHighlightColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "HairFade",
        data = {},
        imgType = ""
    })
    table.insert(generalData, {
        action = "HairTexture",
        data = {},
        imgType = ""
    })
    -- Blemishes
    local blemishes = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, 23 do
            table.insert(blemishes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_0_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, 23 do
            table.insert(blemishes, {num = i, image = uuid .. "_" .. gender .."_HEAD_0_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Blemishes",
        data = blemishes,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 0
    })
    -- Ageing
    local ageing = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(3) - 1 do
            table.insert(ageing, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_3_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(3) - 1 do
            table.insert(ageing, {num = i, image = uuid .. "_" .. gender .."_HEAD_3_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Ageing",
        data = ageing,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 3
    })
    -- Complexion
    local complexion = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(6) - 1 do
            table.insert(complexion, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_6_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(6) - 1 do
            table.insert(complexion, {num = i, image = uuid .. "_" .. gender .."_HEAD_6_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Complexion",
        data = complexion,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 6
    })
    -- Complexion
    local sunDamage = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(7) - 1 do
            table.insert(sunDamage, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_7_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(7) - 1 do
            table.insert(sunDamage, {num = i, image = uuid .. "_" .. gender .."_HEAD_7_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "SunDamage",
        data = sunDamage,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 7
    })
    -- Moles/Freckles
    local molesFreckles = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(9) - 1 do
            table.insert(molesFreckles, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_9_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(9) - 1 do
            table.insert(molesFreckles, {num = i, image = uuid .. "_" .. gender .."_HEAD_9_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "MolesFreckles",
        data = molesFreckles,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 9
    })
    -- Chest Hair
    local chestHair = {}
    if Config.UseDefaultClothImages.Body then
        for i = -1, GetPedHeadOverlayNum(10) - 1 do
            table.insert(chestHair, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_BODY_10_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(10) - 1 do
            table.insert(chestHair, {num = i, image = uuid .. "_" .. gender .."_BODY_10_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "ChestHair",
        data = chestHair,
        imgType = "MDLCDivBDivBigIMG3",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 10
    })
    -- Body Blemishes
    local bodyBlemishes = {}
    if Config.UseDefaultClothImages.Body then
        for i = -1, GetPedHeadOverlayNum(11) - 1 do
            table.insert(bodyBlemishes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_BODY_11_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(11) - 1 do
            table.insert(bodyBlemishes, {num = i, image = uuid .. "_" .. gender .."_BODY_11_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "BodyBlemishes",
        data = bodyBlemishes,
        imgType = "MDLCDivBDivBigIMG3",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 11
    })
    -- Add Body Blemishes
    local addBodyBlemishes = {}
    if Config.UseDefaultClothImages.Body then
        for i = -1, GetPedHeadOverlayNum(12) - 1 do
            table.insert(addBodyBlemishes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_BODY_12_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(12) - 1 do
            table.insert(addBodyBlemishes, {num = i, image = uuid .. "_" .. gender .."_BODY_12_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "AddBodyBlemishes",
        data = addBodyBlemishes,
        imgType = "MDLCDivBDivBigIMG3",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 12
    })
    -- Makeup
    local makeup = {}
    if Config.UseDefaultClothImages.Makeup then
        for i = -1, GetPedHeadOverlayNum(4) - 1 do
            table.insert(makeup, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_4_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(4) - 1 do
            table.insert(makeup, {num = i, image = uuid .. "_" .. gender .."_HEAD_4_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Makeup",
        data = makeup,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 4
    })
    -- Makeup Colors
    table.insert(generalData, {
        action = "FirstMakeupColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "SecondMakeupColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    -- Jacket
    local jackets = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
            table.insert(jackets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
            table.insert(jackets, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Jacket",
        data = jackets,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 11,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 11)
    })
    -- Undershirt
    local undershirts = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
            table.insert(undershirts, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
            table.insert(undershirts, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Undershirt",
        data = undershirts,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 8,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 8)
    })
    -- Arms/Gloves
    local armsgloves = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
            table.insert(armsgloves, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
            table.insert(armsgloves, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Arms/Gloves",
        data = armsgloves,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 3,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 3)
    })
    -- Pants
    local pants = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
            table.insert(pants, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
            table.insert(pants, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Pants",
        data = pants,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 4,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 4)
    })
    -- Shoes
    local shoes = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
            table.insert(shoes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
            table.insert(shoes, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Shoes",
        data = shoes,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMG",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 6,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 6)
    })
    -- Decals
    local decals = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 10) do
            table.insert(decals, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_10_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 10) do
            table.insert(decals, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_10_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Decals",
        data = decals,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 10,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 10)
    })
    -- Masks
    local masks = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
            table.insert(masks, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
            table.insert(masks, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Masks",
        data = masks,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 1,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
    })
    -- Scarfs/Necklaces
    local scarfsNecklaces = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 7) do
            table.insert(scarfsNecklaces, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_7_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 7) do
            table.insert(scarfsNecklaces, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_7_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Scarfs/Necklaces",
        data = scarfsNecklaces,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 7,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 7)
    })
    -- Vest
    local vests = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 9) do
            table.insert(vests, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_9_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 9) do
            table.insert(vests, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_9_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Vest",
        data = vests,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 9,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 9)
    })
    -- Bag
    local bags = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
            table.insert(bags, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
            table.insert(bags, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Bag",
        data = bags,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 5,
        minVariationNumber = 0,
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 5)
    })
    -- Hat
    local hat = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
            table.insert(hat, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
            table.insert(hat, {num = i, image = uuid .. "_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Hat",
        data = hat,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 0,
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
    })
    -- Glasses
    local glasses = {}
    local minGlassesNumber = -1
    if gender == "male" then minGlassesNumber = 0 end
    if Config.UseDefaultClothImages.Accessories then
        for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
            table.insert(glasses, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
        end
    else
        for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
            table.insert(glasses, {num = i, image = uuid .. "_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Glasses",
        data = glasses,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGGlasses",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 1,
        minVariationNumber = minGlassesNumber,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1)
    })
    -- Earrings
    local earrings = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(earrings, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_2_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(earrings, {num = i, image = uuid .. "_" .. gender .."_PROPS_2_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Earrings",
        data = earrings,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 2,
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2)
    })
    -- Watches
    local watches = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6) - 1 do
            table.insert(watches, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_6_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6) - 1 do
            table.insert(watches, {num = i, image = uuid .. "_" .. gender .."_PROPS_6_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Watches",
        data = watches,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 6,
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6)
    })
    -- Bracelets
    local bracelets = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7) - 1 do
            table.insert(bracelets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_7_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7) - 1 do
            table.insert(bracelets, {num = i, image = uuid .. "_" .. gender .."_PROPS_7_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Bracelets",
        data = bracelets,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 7,
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7)
    })
    -- Blush
    local blush = {}
    if Config.UseDefaultClothImages.Makeup then
        for i = -1, GetPedHeadOverlayNum(5) - 1 do
            table.insert(blush, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_5_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(5) - 1 do
            table.insert(blush, {num = i, image = uuid .. "_" .. gender .."_HEAD_5_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Blush",
        data = blush,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 5
    })
    table.insert(generalData, {
        action = "FirstBlushColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "SecondBlushColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    -- Lipstick
    local lipstick = {}
    if Config.UseDefaultClothImages.Makeup then
        for i = -1, GetPedHeadOverlayNum(8) - 1 do
            table.insert(lipstick, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_8_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(8) - 1 do
            table.insert(lipstick, {num = i, image = uuid .. "_" .. gender .."_HEAD_8_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Lipstick",
        data = lipstick,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 8
    })
    table.insert(generalData, {
        action = "FirstLipstickColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "SecondLipstickColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    lastReady = true
    while not lastReady do Citizen.Wait(500) end
    local translations = {}
    for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
        if k:sub(0, ('menu.'):len()) then
            translations[k:sub(('menu.'):len() + 1)] = Lang:t(k)
        end
    end
    local categories = {}
    local selectedCategory = Config.ShopCategories["character_creation"]
    if type(selectedCategory[1]) == "table" then
        for pageIndex, categoryList in ipairs(selectedCategory) do
            for _, v in ipairs(categoryList) do
                categories[v .. "_" .. pageIndex] = true
            end
        end
    else
        for _, v in ipairs(selectedCategory or {}) do
            categories[v .. "_1"] = true
        end
    end
    SendNUIMessage({action = "openCreateCharMenu", categories = categories, categoriesLength = #Config.ShopCategories["character_creation"], generalData = generalData, myPed = myPed, gender = gender, ShowAllPeds = Config.ShowAllPeds, saveable = saveable, menuType = menuType, translations = translations})
    Config.HideHUD()
    if not tp then
        if Config.TeleportWhenCreatingChar.Enable then
            SetEntityCoords(PlayerPedId(), Config.TeleportWhenCreatingChar.Coords)
            SetEntityHeading(PlayerPedId(), Config.TeleportWhenCreatingChar.w)
        end
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetNuiFocus(true, true)
    Citizen.Wait(500)
    Citizen.CreateThread(function()
        SetEntityVisible(PlayerPedId(), false, 0)
        while creatingChar do
            Citizen.Wait(0)
            SetEntityLocallyVisible(PlayerPedId())
        end
    end)
    charCam(true)
end

function createFirstCharacterWithoutReset(charGender, menuType, saveable, tp, loadSkin)
    currentClothStoreType = "cfcwr"
    if not loadSkin then
        TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
    end
    --while not next(currentPlayerSkin) do Citizen.Wait(0) end
    Citizen.Wait(500)
    if not menuType then
        menuType = Config.CharacterCreationMenuCategories.Normal
    end
    local lastReady = false
    creatingChar = true
    local gender = "male"
    local myPed = GetEntityModel(PlayerPedId())
    for k, v in pairs(ManPlayerModels) do
        if myPed == GetHashKey(v) then
            gender = "male"
        end
    end
    for k, v in pairs(WomanPlayerModels) do
        if myPed == GetHashKey(v) then
            gender = "female"
        end
    end
    charCreateGender = gender
    while GetResourceState("0r-imagegenerator") == "starting" do Citizen.Wait(0) end
    local uuid = nil
    if Config.UseWebServer then
        TriggerCallback('0r-clothing:getClothingUrl:server', function(urlData)
            uuid = urlData
        end, false)
        local startTime = GetGameTimer()
        while uuid == nil do 
            Citizen.Wait(0)  
            if GetGameTimer() - startTime > 5000 then
                print("Used default UUID.")
                uuid = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6"
                break
            end 
        end
    else
        uuid = "nui://0r-imagegenerator/images/"
    end
    local generalData = {}
    -- Male Peds
    local malePeds = {}
    for k, v in pairs(ManPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(malePeds, {
            num = GetHashKey(v),
            model = v,
            image = 'https://docs.fivem.net/peds/' .. v .. '.webp?v=9999'
        })
    end
    for k, v in pairs(CustomManPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(malePeds, {
            num = GetHashKey(v),
            model = v,
            image = uuid .. "_" .. GetHashKey(v) ..  '_PED.webp?v=9999',
            style = "width: 125%;"
        })
    end
    table.insert(generalData, {
        action = "MalePeds",
        data = malePeds,
        imgType = "",
        btnClick = true,
        variationNumber = 111
    })
    -- Female Peds
    local femalePeds = {}
    for k, v in pairs(WomanPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(femalePeds, {
            num = GetHashKey(v),
            model = v,
            image = 'https://docs.fivem.net/peds/' .. v .. '.webp?v=9999'
        })
    end
    for k, v in pairs(CustomWomanPlayerModels) do
        if myPed == GetHashKey(v) then
            myPed = v
        end
        table.insert(femalePeds, {
            num = GetHashKey(v),
            model = v,
            image = uuid .. "_" .. GetHashKey(v) ..  '_PED.webp?v=9999',
            style = "width: 0%;"
        })
    end
    table.insert(generalData, {
        action = "FemalePeds",
        data = femalePeds,
        imgType = "",
        btnClick = true,
        variationNumber = 222
    })
    -- Ped Input
    table.insert(generalData, {
        action = "PedModelInput",
        data = {},
        passDataControl = true
    })
    -- Faces
    local faces = {}
    for i = 0, 9 do
        table.insert(faces, {num = i, image = 'files/faces/SKEL_ROOT.00' .. i .. '.webp?v=9999'})
    end
    for i = 10, 45 do
        table.insert(faces, {num = i, image = 'files/faces/SKEL_ROOT.0' .. i .. '.webp?v=9999'})
    end
    table.insert(generalData, {
        action = "FaceOne",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        currentDrawableVariation = headBlendData["firstShape"]
    })
    table.insert(generalData, {
        action = "SkinOne",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        currentDrawableVariation = headBlendData["firstSkin"]
    })
    table.insert(generalData, {
        action = "FaceTwo",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        currentDrawableVariation = headBlendData["secondShape"]
    })
    table.insert(generalData, {
        action = "SkinTwo",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        currentDrawableVariation = headBlendData["secondSkin"]
    })
    table.insert(generalData, {
        action = "FaceThree",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        currentDrawableVariation = headBlendData["thirdShape"]
    })
    table.insert(generalData, {
        action = "SkinThree",
        data = faces,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        currentDrawableVariation = headBlendData["thirdSkin"]
    })
    table.insert(generalData, {
        action = "FaceMix",
        data = {},
        value = headBlendData["shapeMix"]
    })
    table.insert(generalData, {
        action = "SkinMix",
        data = {},
        value = headBlendData["skinMix"]
    })
    table.insert(generalData, {
        action = "ThirdMix",
        data = {},
        value = headBlendData["thirdMix"]
    })
    table.insert(generalData, {
        action = "FaceFeatures",
        data = {},
        data2 = {
            NoseWidth = GetPedFaceFeature(PlayerPedId(), 0),
            NosePeak = GetPedFaceFeature(PlayerPedId(), 1),
            NoseLength = GetPedFaceFeature(PlayerPedId(), 2),
            NoseBoneCurveness = GetPedFaceFeature(PlayerPedId(), 3),
            NoseTip = GetPedFaceFeature(PlayerPedId(), 4),
            NoseBoneTwist = GetPedFaceFeature(PlayerPedId(), 5),
            EyebrowHeight = GetPedFaceFeature(PlayerPedId(), 6),
            EyebrowDepth = GetPedFaceFeature(PlayerPedId(), 7),
            CheekBoneHeight = GetPedFaceFeature(PlayerPedId(), 8),
            CheekBoneWidth = GetPedFaceFeature(PlayerPedId(), 9),
            CheekBoneWidth2 = GetPedFaceFeature(PlayerPedId(), 10),
            EyesSquint = GetPedFaceFeature(PlayerPedId(), 11),
            LipsThickness = GetPedFaceFeature(PlayerPedId(), 12),
            JawBoneLength = GetPedFaceFeature(PlayerPedId(), 13),
            JawBoneWidth = GetPedFaceFeature(PlayerPedId(), 14),
            ChinBoneHeight = GetPedFaceFeature(PlayerPedId(), 15),
            ChinBoneLength = GetPedFaceFeature(PlayerPedId(), 16),
            ChinBoneWidth = GetPedFaceFeature(PlayerPedId(), 17),
            ChinCleft = GetPedFaceFeature(PlayerPedId(), 18),
            NeckThickness = GetPedFaceFeature(PlayerPedId(), 19)
        }
    })
    table.insert(generalData, {
        action = "Nose",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "Eyebrows2",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "Cheeks",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "JawBone",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "Chin",
        data = {},
        passDataControl = true
    })
    table.insert(generalData, {
        action = "MiscellaneousFeatures",
        data = {},
        passDataControl = true
    })
    -- Eye Color
    local eyeColors = {}
    for i = 0, 31 do
        table.insert(eyeColors, {num = i, image = 'files/eyes/' .. i .. '.webp?v=9999'})
    end
    table.insert(generalData, {
        action = "EyeColor",
        data = eyeColors,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        currentDrawableVariation = GetPedEyeColor(PlayerPedId())
    })
    -- Eyebrows
    local eyebrows = {}
    for i = -1, GetPedHeadOverlayNum(2) - 1 do
        table.insert(eyebrows, {num = i, image = 'files/eyebrows/' .. i .. '.webp?v=9999'})
    end
    local eyebrowsResultData = {GetPedHeadOverlayData(PlayerPedId(), 2)}
    if eyebrowsResultData[2] == 255 then eyebrowsResultData[2] = -1 end
    table.insert(generalData, {
        action = "Eyebrows",
        data = eyebrows,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        variationNumber = 2,
        currentDrawableVariation = eyebrowsResultData[2],
        currentTextureDrawableVariation = eyebrowsResultData[4],
        currentDrawableVariationOpacity = eyebrowsResultData[6]
    })
    table.insert(generalData, {
        action = "EyebrowColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "EyebrowHighlightColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    -- Facial Hairs
    local facialHairs = {}
    if Config.UseDefaultClothImages.Hair then
        for i = -1, GetPedHeadOverlayNum(1) - 1 do
            table.insert(facialHairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(1) - 1 do
            table.insert(facialHairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
        end
    end
    local facialHairResults = {GetPedHeadOverlayData(PlayerPedId(), 1)}
    if facialHairResults[2] == 255 then facialHairResults[2] = -1 end
    table.insert(generalData, {
        action = "FacialHairs",
        data = facialHairs,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 1,
        currentDrawableVariation = facialHairResults[2],
        currentDrawableVariationOpacity = facialHairResults[6],
        currentTextureDrawableVariation = facialHairResults[4]
    })
    table.insert(generalData, {
        action = "FacialHairsColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "FacialHairsHighlightColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    -- Hairs
    local hairs = {}
    if Config.UseDefaultClothImages.Hair then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(hairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(hairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Hairs",
        data = hairs,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = false,
        variationNumber = 2,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 2),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 2)
    })
    table.insert(generalData, {
        action = "HairsColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "HairsHighlightColors",
        data = Config.HairColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "HairFade",
        data = {},
        imgType = ""
    })
    table.insert(generalData, {
        action = "HairTexture",
        data = {},
        imgType = ""
    })
    -- Blemishes
    local blemishes = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, 23 do
            table.insert(blemishes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_0_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, 23 do
            table.insert(blemishes, {num = i, image = uuid .. "_" .. gender .."_HEAD_0_" .. i .. '.webp?v=9999'})
        end
    end
    local blemishesResultsData = {GetPedHeadOverlayData(PlayerPedId(), 0)}
    if blemishesResultsData[2] == 255 then blemishesResultsData[2] = -1 end
    table.insert(generalData, {
        action = "Blemishes",
        data = blemishes,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 0,
        currentDrawableVariation = blemishesResultsData[2],
        currentDrawableVariationOpacity = blemishesResultsData[6]
    })
    -- Ageing
    local ageing = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(3) - 1 do
            table.insert(ageing, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_3_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(3) - 1 do
            table.insert(ageing, {num = i, image = uuid .. "_" .. gender .."_HEAD_3_" .. i .. '.webp?v=9999'})
        end
    end
    local ageingResultsData = {GetPedHeadOverlayData(PlayerPedId(), 3)}
    if ageingResultsData[2] == 255 then ageingResultsData[2] = -1 end
    table.insert(generalData, {
        action = "Ageing",
        data = ageing,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 3,
        currentDrawableVariation = ageingResultsData[2],
        currentDrawableVariationOpacity = ageingResultsData[6]
    })
    -- Complexion
    local complexion = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(6) - 1 do
            table.insert(complexion, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_6_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(6) - 1 do
            table.insert(complexion, {num = i, image = uuid .. "_" .. gender .."_HEAD_6_" .. i .. '.webp?v=9999'})
        end
    end
    local complexionResultsData = {GetPedHeadOverlayData(PlayerPedId(), 3)}
    if complexionResultsData[2] == 255 then complexionResultsData[2] = -1 end
    table.insert(generalData, {
        action = "Complexion",
        data = complexion,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 6,
        currentDrawableVariation = complexionResultsData[2],
        currentDrawableVariationOpacity = complexionResultsData[6]
    })
    -- Complexion
    local sunDamage = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(7) - 1 do
            table.insert(sunDamage, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_7_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(7) - 1 do
            table.insert(sunDamage, {num = i, image = uuid .. "_" .. gender .."_HEAD_7_" .. i .. '.webp?v=9999'})
        end
    end
    local sunDamageResultsData = {GetPedHeadOverlayData(PlayerPedId(), 7)}
    if sunDamageResultsData[2] == 255 then sunDamageResultsData[2] = -1 end
    table.insert(generalData, {
        action = "SunDamage",
        data = sunDamage,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 7,
        currentDrawableVariation = sunDamageResultsData[2],
        currentDrawableVariationOpacity = sunDamageResultsData[6]
    })
    -- Moles/Freckles
    local molesFreckles = {}
    if Config.UseDefaultClothImages.Skin then
        for i = -1, GetPedHeadOverlayNum(9) - 1 do
            table.insert(molesFreckles, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_9_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(9) - 1 do
            table.insert(molesFreckles, {num = i, image = uuid .. "_" .. gender .."_HEAD_9_" .. i .. '.webp?v=9999'})
        end
    end
    local molesFrecklesResultsData = {GetPedHeadOverlayData(PlayerPedId(), 9)}
    if molesFrecklesResultsData[2] == 255 then molesFrecklesResultsData[2] = -1 end
    table.insert(generalData, {
        action = "MolesFreckles",
        data = molesFreckles,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 9,
        currentDrawableVariation = molesFrecklesResultsData[2],
        currentDrawableVariationOpacity = molesFrecklesResultsData[6]
    })
    -- Chest Hair
    local chestHair = {}
    if Config.UseDefaultClothImages.Body then
        for i = -1, GetPedHeadOverlayNum(10) - 1 do
            table.insert(chestHair, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_BODY_10_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(10) - 1 do
            table.insert(chestHair, {num = i, image = uuid .. "_" .. gender .."_BODY_10_" .. i .. '.webp?v=9999'})
        end
    end
    local chestHairResultsData = {GetPedHeadOverlayData(PlayerPedId(), 10)}
    if chestHairResultsData[2] == 255 then chestHairResultsData[2] = -1 end
    table.insert(generalData, {
        action = "ChestHair",
        data = chestHair,
        imgType = "MDLCDivBDivBigIMG3",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 10,
        currentDrawableVariation = chestHairResultsData[2],
        currentDrawableVariationOpacity = chestHairResultsData[6]
    })
    -- Body Blemishes
    local bodyBlemishes = {}
    if Config.UseDefaultClothImages.Body then
        for i = -1, GetPedHeadOverlayNum(11) - 1 do
            table.insert(bodyBlemishes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_BODY_11_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(11) - 1 do
            table.insert(bodyBlemishes, {num = i, image = uuid .. "_" .. gender .."_BODY_11_" .. i .. '.webp?v=9999'})
        end
    end
    local bodyBlemishesResultsData = {GetPedHeadOverlayData(PlayerPedId(), 11)}
    if bodyBlemishesResultsData[2] == 255 then bodyBlemishesResultsData[2] = -1 end
    table.insert(generalData, {
        action = "BodyBlemishes",
        data = bodyBlemishes,
        imgType = "MDLCDivBDivBigIMG3",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 11,
        currentDrawableVariation = bodyBlemishesResultsData[2],
        currentDrawableVariationOpacity = bodyBlemishesResultsData[6]
    })
    -- Add Body Blemishes
    local addBodyBlemishes = {}
    if Config.UseDefaultClothImages.Body then
        for i = -1, GetPedHeadOverlayNum(12) - 1 do
            table.insert(addBodyBlemishes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_BODY_12_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(12) - 1 do
            table.insert(addBodyBlemishes, {num = i, image = uuid .. "_" .. gender .."_BODY_12_" .. i .. '.webp?v=9999'})
        end
    end
    local addBodyBlemishesResultsData = {GetPedHeadOverlayData(PlayerPedId(), 12)}
    if addBodyBlemishesResultsData[2] == 255 then addBodyBlemishesResultsData[2] = -1 end
    table.insert(generalData, {
        action = "AddBodyBlemishes",
        data = addBodyBlemishes,
        imgType = "MDLCDivBDivBigIMG3",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 12,
        currentDrawableVariation = addBodyBlemishesResultsData[2],
        currentDrawableVariationOpacity = addBodyBlemishesResultsData[6]
    })
    -- Jacket
    local jackets = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
            table.insert(jackets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
            table.insert(jackets, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Jacket",
        data = jackets,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 11,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 11),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 11),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 11)
    })
    -- Undershirt
    local undershirts = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
            table.insert(undershirts, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
            table.insert(undershirts, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Undershirt",
        data = undershirts,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 8,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 8),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 8),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 8)
    })
    -- Arms/Gloves
    local armsgloves = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
            table.insert(armsgloves, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
            table.insert(armsgloves, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Arms/Gloves",
        data = armsgloves,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 3,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 3),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 3),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 3)
    })
    -- Pants
    local pants = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
            table.insert(pants, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
            table.insert(pants, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Pants",
        data = pants,
        imgType = "MDLCDivBDivBigIMG",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 4,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 4),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 4),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 4)
    })
    -- Shoes
    local shoes = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
            table.insert(shoes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
            table.insert(shoes, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Shoes",
        data = shoes,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMG",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 6,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 6),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 6),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 6)
    })
    -- Decals
    local decals = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 10) do
            table.insert(decals, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_10_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 10) do
            table.insert(decals, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_10_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Decals",
        data = decals,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 10,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 10),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 10),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 10)
    })
    -- Masks
    local masks = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
            table.insert(masks, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
            table.insert(masks, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Masks",
        data = masks,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 1,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 1),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 1),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
    })
    -- Scarfs/Necklaces
    local scarfsNecklaces = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 7) do
            table.insert(scarfsNecklaces, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_7_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 7) do
            table.insert(scarfsNecklaces, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_7_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Scarfs/Necklaces",
        data = scarfsNecklaces,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 7,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 7),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 7),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 7)
    })
    -- Vest
    local vests = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 9) do
            table.insert(vests, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_9_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 9) do
            table.insert(vests, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_9_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Vest",
        data = vests,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 9,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 9),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 9),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 9)
    })
    -- Bag
    local bags = {}
    if Config.UseDefaultClothImages.Clothing then
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
            table.insert(bags, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
        end
    else
        for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
            table.insert(bags, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Bag",
        data = bags,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 5,
        currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 5),
        currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 5),
        maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 5)
    })
    -- Hat
    local hat = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
            table.insert(hat, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
            table.insert(hat, {num = i, image = uuid .. "_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Hat",
        data = hat,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 0,
        currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 0),
        currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 0),
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
    })
    -- Glasses
    local glasses = {}
    local minGlassesNumber = -1
    if gender == "male" then minGlassesNumber = 0 end
    if Config.UseDefaultClothImages.Accessories then
        for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
            table.insert(glasses, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
        end
    else
        for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
            table.insert(glasses, {num = i, image = uuid .. "_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
        end
    end
    local currentGlasses = GetPedPropIndex(PlayerPedId(), 1)
    if currentGlasses == -1 then currentGlasses = 0 end
    table.insert(generalData, {
        action = "Glasses",
        data = glasses,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGGlasses",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 1,
        currentDrawableVariation = currentGlasses,
        currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 1),
        minVariationNumber = minGlassesNumber,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1)
    })
    -- Earrings
    local earrings = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(earrings, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_2_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2) - 1 do
            table.insert(earrings, {num = i, image = uuid .. "_" .. gender .."_PROPS_2_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Earrings",
        data = earrings,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 2,
        currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 2),
        currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 2),
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2)
    })
    -- Watches
    local watches = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6) - 1 do
            table.insert(watches, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_6_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6) - 1 do
            table.insert(watches, {num = i, image = uuid .. "_" .. gender .."_PROPS_6_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Watches",
        data = watches,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 6,
        currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 6),
        currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 6),
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6)
    })
    -- Bracelets
    local bracelets = {}
    if Config.UseDefaultClothImages.Accessories then
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7) - 1 do
            table.insert(bracelets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_7_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7) - 1 do
            table.insert(bracelets, {num = i, image = uuid .. "_" .. gender .."_PROPS_7_" .. i .. '.webp?v=9999'})
        end
    end
    table.insert(generalData, {
        action = "Bracelets",
        data = bracelets,
        btnClick = true,
        imgType = "MDLCDivBDivBigIMGMask",
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 7,
        currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 7),
        currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 7),
        minVariationNumber = -1,
        maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7)
    })
    -- Makeup
    local makeup = {}
    if Config.UseDefaultClothImages.Makeup then
        for i = -1, GetPedHeadOverlayNum(4) - 1 do
            table.insert(makeup, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_4_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(4) - 1 do
            table.insert(makeup, {num = i, image = uuid .. "_" .. gender .."_HEAD_4_" .. i .. '.webp?v=9999'})
        end
    end
    local makeupResults = {GetPedHeadOverlayData(PlayerPedId(), 4)}
    if makeupResults[2] == 255 then makeupResults[2] = -1 end
    table.insert(generalData, {
        action = "Makeup",
        data = makeup,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 4,
        currentDrawableVariation = makeupResults[2],
        currentTextureDrawableVariation = makeupResults[4]
    })
    -- Makeup Colors
    table.insert(generalData, {
        action = "FirstMakeupColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "SecondMakeupColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    -- Blush
    local blush = {}
    if Config.UseDefaultClothImages.Makeup then
        for i = -1, GetPedHeadOverlayNum(5) - 1 do
            table.insert(blush, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_5_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(5) - 1 do
            table.insert(blush, {num = i, image = uuid .. "_" .. gender .."_HEAD_5_" .. i .. '.webp?v=9999'})
        end
    end
    local blushResults = {GetPedHeadOverlayData(PlayerPedId(), 5)}
    if blushResults[2] == 255 then blushResults[2] = -1 end
    table.insert(generalData, {
        action = "Blush",
        data = blush,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 5,
        currentDrawableVariation = blushResults[2],
        currentTextureDrawableVariation = blushResults[4]
    })
    table.insert(generalData, {
        action = "FirstBlushColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "SecondBlushColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    -- Lipstick
    local lipstick = {}
    if Config.UseDefaultClothImages.Makeup then
        for i = -1, GetPedHeadOverlayNum(8) - 1 do
            table.insert(lipstick, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_8_" .. i .. '.webp?v=9999'})
        end
    else
        for i = -1, GetPedHeadOverlayNum(8) - 1 do
            table.insert(lipstick, {num = i, image = uuid .. "_" .. gender .."_HEAD_8_" .. i .. '.webp?v=9999'})
        end
    end
    local lipstickResults = {GetPedHeadOverlayData(PlayerPedId(), 8)}
    if lipstickResults[2] == 255 then lipstickResults[2] = -1 end
    table.insert(generalData, {
        action = "Lipstick",
        data = lipstick,
        imgType = "MDLCDivBDivBigIMG2",
        btnClick = true,
        style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
        search = true,
        variationNumber = 8,
        currentDrawableVariation = lipstickResults[2],
        currentTextureDrawableVariation = lipstickResults[4]
    })
    table.insert(generalData, {
        action = "FirstLipstickColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    table.insert(generalData, {
        action = "SecondLipstickColor",
        data = Config.MakeupColors,
        imgType = "",
        btnClick2 = true
    })
    -- Makeup & Blush & Lipstick
    table.insert(generalData, {
        action = "mblOpacity",
        data = {},
        MakeupOpacity = makeupResults[6],
        BlushOpacity = blushResults[6],
        LipstickOpacity = lipstickResults[6]
    })
    lastReady = true
    while not lastReady do Citizen.Wait(500) end
    local translations = {}
    for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
        if k:sub(0, ('menu.'):len()) then
            translations[k:sub(('menu.'):len() + 1)] = Lang:t(k)
        end
    end
    local categories = {}
    local selectedCategory = Config.ShopCategories["character_creation"]
    if type(selectedCategory[1]) == "table" then
        for pageIndex, categoryList in ipairs(selectedCategory) do
            for _, v in ipairs(categoryList) do
                categories[v .. "_" .. pageIndex] = true
            end
        end
    else
        for _, v in ipairs(selectedCategory or {}) do
            categories[v .. "_1"] = true
        end
    end
    SendNUIMessage({action = "openCreateCharMenuWithoutReset", categories = categories, categoriesLength = #Config.ShopCategories["character_creation"], generalData = generalData, myPed = myPed, gender = gender, ShowAllPeds = Config.ShowAllPeds, saveable = saveable, menuType = menuType, translations = translations})
    Config.HideHUD()
    if not tp then
        if Config.TeleportWhenCreatingChar.Enable then
            SetEntityCoords(PlayerPedId(), Config.TeleportWhenCreatingChar.Coords)
            SetEntityHeading(PlayerPedId(), Config.TeleportWhenCreatingChar.w)
        end
    end
    FreezeEntityPosition(PlayerPedId(), true)
    SetNuiFocus(true, true)
    Citizen.Wait(500)
    Citizen.CreateThread(function()
        SetEntityVisible(PlayerPedId(), false, 0)
        while creatingChar do
            Citizen.Wait(0)
            SetEntityLocallyVisible(PlayerPedId())
        end
    end)
    charCam(true)
end

RegisterNetEvent('0r-clothing:openCharacterCreationMenu', function(nottp, dontreset)
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

createdCharCham, createdCharChamPed, camOffset, camHeight, hairFade, rotatingPed, currentZoomIndex, comparingClothes = nil, nil, 0, 0, 0, false, 1, false
function charCam(state)
    if state then
        currentZoomIndex = 2
        if DoesCamExist(createdCharCham) then return end
        while isAnyCamActive() do Citizen.Wait(500) end
        DestroyCam(createdCharCham, false)
        --DestroyAllCams(true)
        RenderScriptCams(false, true, 500, true, false)
        Citizen.Wait(500)
        DestroyCam(createdCharCham, false)
        if not DoesCamExist(createdCharCham) then
            -- Create Ped
            local playerCoords = GetEntityCoords(PlayerPedId())
            RequestModel(GetHashKey("mp_m_freemode_01"))
            while not HasModelLoaded(GetHashKey("mp_m_freemode_01")) do Citizen.Wait(0) end
            createdCharChamPed = CreatePed(2, GetHashKey("mp_m_freemode_01"), playerCoords.x, playerCoords.y, playerCoords.z - 1, GetEntityHeading(PlayerPedId()), false, true)
            FreezeEntityPosition(createdCharChamPed, true)
            SetEntityVisible(createdCharChamPed, false)
            SetEntityNoCollisionEntity(PlayerPedId(), createdCharChamPed, true)
            -- Create Cam
            local coords = GetOffsetFromEntityInWorldCoords(createdCharChamPed, 0.05, 0.9, 0.25)
            createdCharCham = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamActive(createdCharCham, true)
            RenderScriptCams(true, true, 500, true, true)
            SetCamCoord(createdCharCham, coords.x, coords.y, coords.z + 0.2)
            SetCamRot(createdCharCham, 0.0, 0.0, GetEntityHeading(createdCharChamPed) + 190)
            if Config.UseBackgroundBlur then
                SetCamUseShallowDofMode(createdCharCham, true)
                SetCamNearDof(createdCharCham, 0.4)
                SetCamFarDof(createdCharCham, 1.1)
                SetCamDofStrength(createdCharCham, 1.0)
            end
        end
        camOffset = 0.9
        camHeight = 0.25
        if Config.UseBackgroundBlur then
            Citizen.CreateThread(function()
                while DoesCamExist(createdCharCham) do
                    SetUseHiDof()
                    Citizen.Wait(0)
                end
            end)
        end
        Citizen.CreateThread(function()
            while DoesCamExist(createdCharCham) and not rotatingPed do
                local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.05, camOffset, camHeight)
                SetCamCoord(createdCharCham, coords.x, coords.y, coords.z + 0.2)
                SetCamRot(createdCharCham, 0.0, 0.0, GetEntityHeading(PlayerPedId()) + 190)
                Citizen.Wait(0)
            end
        end)
    else
        DeletePed(createdCharChamPed)
        ClearTimecycleModifier()
        --DestroyAllCams(true)
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(createdCharCham, false)
        createdCharCham = nil
    end
end

createdCharCham2, camOffset2, camHeight2 = nil, 0, 0
function charCam2(state)
    if state then
        RequestCollisionAtCoord(Config.CompareClothes.Coords.Cam.x, Config.CompareClothes.Coords.Cam.y, Config.CompareClothes.Coords.Cam.z)
        SetFocusPosAndVel(Config.CompareClothes.Coords.Cam.x, Config.CompareClothes.Coords.Cam.y, Config.CompareClothes.Coords.Cam.z, 0.0, 0.0, 0.0)
        Citizen.Wait(1000)
        currentZoomIndex = 1
        if DoesCamExist(createdCharCham2) then return end
        while isAnyCamActive() do Citizen.Wait(500) end
        DestroyCam(createdCharCham2, false)
        RenderScriptCams(false, true, 500, true, false)
        Citizen.Wait(500)
        DestroyCam(createdCharCham2, false)
        if not DoesCamExist(createdCharCham2) then
            createdCharCham2 = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
            SetCamActive(createdCharCham2, true)
            RenderScriptCams(true, true, 500, true, true)
            SetCamCoord(createdCharCham2, Config.CompareClothes.Coords.Cam.x, Config.CompareClothes.Coords.Cam.y, Config.CompareClothes.Coords.Cam.z + 0.2)
            SetCamRot(createdCharCham2, 0.0, 0.0, Config.CompareClothes.Coords.Cam.w)
            SetCamFov(createdCharCham2, 75.0)
        end
        camOffset2 = 0.7
        camHeight2 = 0.45
        Citizen.Wait(1000)
        DoScreenFadeIn(1000)
    else
        DoScreenFadeOut(1000)
        Citizen.Wait(1000)
        ClearTimecycleModifier()
        --DestroyAllCams(true)
        RenderScriptCams(false, true, 500, true, false)
        DestroyCam(createdCharCham2, false)
        createdCharCham2 = nil
    end
end

function isAnyCamActive()
    for i = 1, 10 do -- Maksimum 10 kamera kontrol edebiliriz (FiveM'de aşırı fazla kamera oluşturulmaz)
        local cam = GetRenderingCam()
        if cam ~= -1 and IsCamActive(cam) then
            return true
        end
    end
    return false
end

local shopTattoos = {}
RegisterNUICallback('callback', function(data, cb)
    if data.action == "nuiFocus" then
        SetNuiFocus(false, false)
        if DoesCamExist(createdCharCham) then charCam(false) end
        --if DoesCamExist(createdCharCham2) then charCam2(false) end
        Config.ShowHUD()
    elseif data.action == "updateRotation" then
        local rotationDelta = data.rotationDelta
        local currentHeading = GetEntityHeading(PlayerPedId())
        local newHeading = currentHeading + (rotationDelta * 0.3) 
        SetEntityHeading(PlayerPedId(), newHeading)
        rotatingPed = true
        Citizen.Wait(500)
        rotatingPed = false
    elseif data.action == "updateRotation2" then
        if data.num == 1 then
            local rotationDelta = data.rotationDelta
            local currentHeading = GetEntityHeading(myClone)
            local newHeading = currentHeading + (rotationDelta * 0.3) 
            SetEntityHeading(myClone, newHeading)
        else
            local rotationDelta = data.rotationDelta
            local currentHeading = GetEntityHeading(myClone2)
            local newHeading = currentHeading + (rotationDelta * 0.3) 
            SetEntityHeading(myClone2, newHeading)
        end
    elseif data.action == "updateZoom" then
        if not DoesCamExist(createdCharCham) then return end
        if data.type == "zoomIn" then
            if currentZoomIndex < #Config.CamZoomLevels then
                currentZoomIndex = currentZoomIndex + 1
            end
        elseif data.type == "zoomOut" then
            if currentZoomIndex > 1 then
                currentZoomIndex = currentZoomIndex - 1
            end
        end
        local zoomData = Config.CamZoomLevels[currentZoomIndex]
        camOffset = zoomData.camOffset
        camHeight = zoomData.camHeight
        if camOffset == 1.5 then
            SetCamNearDof(createdCharCham, 0.9)
            SetCamFarDof(createdCharCham, 1.5)
        else
            SetCamNearDof(createdCharCham, 0.4)
            SetCamFarDof(createdCharCham, 1.1)
        end
        SetCamDofStrength(createdCharCham, 1.0)
        local coords = GetOffsetFromEntityInWorldCoords(createdCharChamPed, 0.05, camOffset, camHeight)
        SetCamCoord(createdCharCham, coords.x, coords.y, coords.z + 0.2)
    elseif data.action == "changeVariation" then
        if data.action2 == "Hat" or data.action2 == "Glasses" or data.action2 == "Earrings" or data.action2 == "Watches" or data.action2 == "Bracelets" then
            SetPedPreloadPropData(PlayerPedId(), data.num1, data.num2, data.num3)
            while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                Citizen.Wait(50)
            end
            ClearPedProp(PlayerPedId(), data.num1)
            SetPedPropIndex(PlayerPedId(), data.num1, data.num2, data.num3, 0)
            skinData[string.lower(data.action2)] = {}
            skinData[string.lower(data.action2)].item = data.num2
            skinData[string.lower(data.action2)].texture = data.num3
            return
        end
        SetPedPreloadVariationData(PlayerPedId(), data.num1, data.num2, data.num3)
        while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
            Citizen.Wait(50)
        end
        SetPedComponentVariation(PlayerPedId(), data.num1, data.num2, data.num3, 0)
        skinData[string.lower(data.action2)] = {}
        skinData[string.lower(data.action2)].item = data.num2
        skinData[string.lower(data.action2)].texture = data.num3
        SendNUIMessage({action = "setMaxNumForComponentVariation", action2 = data.action2, componentId = data.num1, componentVariation = data.num2, textureMaxNum = GetNumberOfPedTextureVariations(PlayerPedId(), data.num1, data.num2) - 1})
        if data.action2 == "Hairs" then
            if data.num2 == 0 then
                ClearPedDecorationsLeaveScars(PlayerPedId())
            else
                if hairFade == 1 then
                    ClearPedDecorationsLeaveScars(PlayerPedId())
                    if hairDecor[charCreateGender][data.num2] then
                        AddPedDecorationFromHashes(PlayerPedId(), hairDecor[charCreateGender][data.num2][1], hairDecor[charCreateGender][data.num2][2])
                    end
                end
            end
            skinData["hair"] = {}
            skinData["hair"].item = data.num2
            skinData["hair"].texture = GetPedHairColor(PlayerPedId())
        end
    elseif data.action == "changePropVariation" then
        SetPedPreloadPropData(PlayerPedId(), data.num1, data.num2, data.num3)
        while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
            Citizen.Wait(50)
        end
        ClearPedProp(PlayerPedId(), data.num1)
        SetPedPropIndex(PlayerPedId(), data.num1, data.num2, data.num3, 0)
        skinData[string.lower(data.action2)] = {}
        skinData[string.lower(data.action2)].item = data.num2
        skinData[string.lower(data.action2)].texture = data.num3
        SendNUIMessage({action = "setMaxNumForComponentVariation", action2 = data.action2, componentId = data.num1, componentVariation = data.num2, textureMaxNum = GetNumberOfPedPropTextureVariations(PlayerPedId(), data.num1, data.num2) - 1})
    elseif data.action == "changeFace" then
        if GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') or GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
            headBlendData = {
                firstShape = data.firstShape,
                secondShape = data.secondShape,
                thirdShape = data.thirdShape,
                firstSkin = data.firstSkin,
                secondSkin = data.secondSkin,
                thirdSkin = data.thirdSkin,
                shapeMix = tonumber(data.shapeMix) / 100.0,
                skinMix = tonumber(data.skinMix) / 100.0,
                thirdMix = tonumber(data.thirdMix) / 100.0
            }
            skinData["face"] = {}
            skinData["face"].item = data.firstShape
            skinData["face"].texture = data.firstSkin
            skinData["face2"] = {}
            skinData["face2"].item = data.secondShape
            skinData["face2"].texture = data.secondSkin
            skinData["face3"] = {}
            skinData["face3"].item = data.thirdShape
            skinData["face3"].texture = data.thirdSkin
            skinData["facemix"] = {skinMix = tonumber(data.skinMix) / 100.0, shapeMix = tonumber(data.shapeMix) / 100.0, thirdMix = tonumber(data.thirdMix) / 100.0}
            SetPedHeadBlendData(PlayerPedId(), data.firstShape, data.secondShape, data.thirdShape, data.firstSkin, data.secondSkin, data.thirdSkin, tonumber(skinData["facemix"].shapeMix), tonumber(skinData["facemix"].skinMix), tonumber(skinData["facemix"].thirdMix), false)
        end
    elseif data.action == "changeHeadOverlay" then
        if GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') or GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
            if data.num2 == nil or data.num3 == nil then return end
            data.num1 = tonumber(data.num1)
            data.num2 = tonumber(data.num2)
            data.num3 = tonumber(data.num3)
            data.opacity = (tonumber(data.opacity) / 100) + 0.0
            SetPedPreloadVariationData(PlayerPedId(), data.num1, data.num2, data.num3)
            while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                Citizen.Wait(50)
            end
            if skinData["face"] then
                SetPedHeadBlendData(ped, skinData["face"].item, skinData["face2"].item, skinData["face3"].item, skinData["face"].texture, skinData["face2"].texture, skinData["face3"].texture, skinData["facemix"].shapeMix, skinData["facemix"].skinMix, skinData["facemix"].thirdMix, false)
            else
                print("There is a problem with face data.")
            end
            SetPedHeadOverlay(PlayerPedId(), data.num1, data.num2, data.opacity)
            local colorType = 0
            if data.action2 == "Eyebrows" or data.action2 == "FacialHairs" or data.action2 == "ChestHair" or data.action2 == "Makeup" then
                colorType = 1
            elseif data.action2 == "Blush" or data.action2 == "Lipstick" then
                colorType = 2
            end
            if data.action2 == "Hairs" then
                SetPedHairTint(PlayerPedId(), data.num3, data.num4)
                if hairFade == 1 then
                    if hairDecor[charCreateGender][data.num2] then
                        AddPedDecorationFromHashes(PlayerPedId(), hairDecor[charCreateGender][data.num2][1], hairDecor[charCreateGender][data.num2][2])
                    end
                end
                skinData["hair"] = {}
                skinData["hair"].item = data.num2
                skinData["hair"].texture = data.num3
                skinData["hair"].texture2 = data.num4
                return
            end
            SetPedHeadOverlayColor(PlayerPedId(), data.num1, colorType, data.num3, data.num4)
            if data.action2 == "FacialHairs" then
                data.action2 = "beard"
            end
            skinData[string.lower(data.action2)] = {}
            skinData[string.lower(data.action2)].item = data.num2
            skinData[string.lower(data.action2)].texture = data.num3
            skinData[string.lower(data.action2)].opacity = data.opacity
        end
    elseif data.action == "setPedEyeColor" then
        SetPedEyeColor(PlayerPedId(), tonumber(data.num1))
        skinData["eye_color"] = {}
        skinData["eye_color"].item = tonumber(data.num1)
        skinData["eye_color"].texture = 0
    elseif data.action == "setHairFade" then
        skinData["hairFade"] = {}
        skinData["hairFade"].item = data.num1
        hairFade = data.num1
        if data.num1 == 0 then
            ClearPedDecorationsLeaveScars(PlayerPedId())
        else
            data.num2 = tonumber(data.num2)
            if hairDecor[charCreateGender][data.num2] then
                AddPedDecorationFromHashes(PlayerPedId(), hairDecor[charCreateGender][data.num2][1], hairDecor[charCreateGender][data.num2][2])
            end
        end
    elseif data.action == "removeCloth" then
        local defaultNum = Config.DefaultClothingVaritaions[data.type][charCreateGender]
        if data.type == "Hat" or data.type == "Glasses" then
            SetPedPreloadPropData(PlayerPedId(), data.component, defaultNum, 0)
            while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                Citizen.Wait(50)
            end
            ClearPedProp(PlayerPedId(), data.component)
            SetPedPropIndex(PlayerPedId(), data.component, defaultNum, 0, 0)
            return
        end
        if data.type == "Jacket" then
            SetPedPreloadVariationData(PlayerPedId(), 8, defaultNum, 0)
            while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                Citizen.Wait(50)
            end
            SetPedComponentVariation(PlayerPedId(), 8, defaultNum, 0, 0)
            -- Arms
            SetPedPreloadVariationData(PlayerPedId(), 3, defaultNum, 0)
            while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                Citizen.Wait(50)
            end
            SetPedComponentVariation(PlayerPedId(), 3, defaultNum, 0, 0)
        end
        SetPedPreloadVariationData(PlayerPedId(), data.component, defaultNum, 0)
        while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
            Citizen.Wait(50)
        end
        SetPedComponentVariation(PlayerPedId(), data.component, defaultNum, 0, 0)
        if data.type == "Hairs" then
            ClearPedDecorationsLeaveScars(PlayerPedId())
            TriggerServerEvent('0r-clothing:loadPlayerTattoos:server')
        end
    elseif data.action == "wearCloth" then
        local defaultNum = data.num
        if data.type == "Hat" or data.type == "Glasses" then
            SetPedPreloadPropData(PlayerPedId(), data.num1, data.num2, 0)
            while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                Citizen.Wait(50)
            end
            ClearPedProp(PlayerPedId(), data.num1)
            SetPedPropIndex(PlayerPedId(), data.num1, data.num2, data.num3, 0)
            return
        end
        if data.type == "Jacket" then
            if data.num1 then
                SetPedPreloadVariationData(PlayerPedId(), 8, data.num1, 0)
                while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                    Citizen.Wait(50)
                end
                SetPedComponentVariation(PlayerPedId(), 8, data.num1, 0, 0)
            end
            -- Arms
            if data.num2 then
                SetPedPreloadVariationData(PlayerPedId(), 3, data.num2, 0)
                while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                    Citizen.Wait(50)
                end
                SetPedComponentVariation(PlayerPedId(), 3, data.num2, 0, 0)
            end
            --
            SetPedPreloadVariationData(PlayerPedId(), data.component, defaultNum, 0)
            while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
                Citizen.Wait(50)
            end
            SetPedComponentVariation(PlayerPedId(), data.component, defaultNum, 0, 0)
            return
        end
        if data.type == "Hairs" then
            data.num3 = 0
            if skinData["hairFade"] and skinData["hairFade"].item == 1 then
                ClearPedDecorationsLeaveScars(PlayerPedId())
                if hairDecor[charCreateGender][defaultNum] then
                    AddPedDecorationFromHashes(PlayerPedId(), hairDecor[charCreateGender][defaultNum][1], hairDecor[charCreateGender][defaultNum][2])
                end
            end
            TriggerServerEvent('0r-clothing:loadPlayerTattoos:server')
        end
        SetPedPreloadVariationData(PlayerPedId(), data.component, defaultNum, data.num3)
        while not HasPedPreloadVariationDataFinished(PlayerPedId()) do
            Citizen.Wait(50)
        end
        SetPedComponentVariation(PlayerPedId(), data.component, defaultNum, data.num3, 0)
    elseif data.action == "loadPed" then
        local model = data.model
        if not IsModelValid(model) then return end
        RequestModel(model)
        while not HasModelLoaded(model) do
            RequestModel(model)
            Citizen.Wait(0)
        end
        SetPlayerModel(PlayerId(), model)
        SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
        SetPedDefaultComponentVariation(PlayerPedId())
        -- Change
        if model == "mp_m_freemode_01" then
            Citizen.Wait(500)
            if currentClothStoreType == "cfc" then
                createFirstCharacter("male", Config.CharacterCreationMenuCategories.Normal, true, true)
            else
                createFirstCharacter("male", Config.CharacterCreationMenuCategories.Normal, true, true, true)
            end
        end
        if model == "mp_f_freemode_01" then
            Citizen.Wait(500)
            if currentClothStoreType == "cfc" then
                createFirstCharacter("female", Config.CharacterCreationMenuCategories.Normal, true, true)
            else
                createFirstCharacter("female", Config.CharacterCreationMenuCategories.Normal, true, true, true)
            end
        end
    elseif data.action == "changeFaceFeature" then
        local nameConverters = {
            ["NoseWidth"] = "nose_0",
            ["NosePeak"] = "nose_1",
            ["NoseLength"] = "nose_2",
            ["NoseBoneCurveness"] = "nose_3",
            ["NoseTip"] = "nose_4",
            ["NoseBoneTwist"] = "nose_5",
            ["EyebrowHeight"] = "eyebrown_high",
            ["EyebrowDepth"] = "eyebrown_forward",
            ["CheekBoneHeight"] = "cheek_1",
            ["CheekBoneWidth"] = "cheek_2",
            ["CheekBoneWidth2"] = "cheek_3",
            ["EyesSquint"] = "eye_opening",
            ["LipsThickness"] = "lips_thickness",
            ["JawBoneLength"] = "jaw_bone_width",
            ["JawBoneWidth"] = "jaw_bone_back_lenght",
            ["ChinBoneHeight"] = "chimp_bone_lowering",
            ["ChinBoneLength"] = "chimp_bone_lenght",
            ["ChinBoneWidth"] = "chimp_bone_width",
            ["ChinCleft"] = "chimp_hole",
            ["NeckThickness"] = "neck_thickness"
        }
        skinData[nameConverters[data.name]] = {}
        skinData[nameConverters[data.name]].item = data.value + 0.0
        SetPedFaceFeature(PlayerPedId(), data.num1, data.value + 0.0)
    elseif data.action == "finalizeCharacter" then
        Config.ShowHUD()
        creatingChar = false
        SetEntityVisible(PlayerPedId(), true, 0)
        SetNuiFocus(false, false)
        ClearTimecycleModifier()
        FreezeEntityPosition(PlayerPedId(), false)
        if DoesCamExist(createdCharCham) then charCam(false) end
        --if DoesCamExist(createdCharCham2) then charCam2(false) end
        if Config.SetCoordsAfterFinalize.Enable then
            SetEntityCoords(PlayerPedId(), vector3(Config.SetCoordsAfterFinalize.Coords.x, Config.SetCoordsAfterFinalize.Coords.y, Config.SetCoordsAfterFinalize.Coords.z))
            SetEntityHeading(PlayerPedId(), Config.SetCoordsAfterFinalize.Coords.w)
        end
        Config.CharacterFinalized()
        if data.type == "discard" then
            TriggerCallback('0r-clothing:getSkin:server', function(skin)
                if next(skin) then
                    TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
                    clothingStoreOpen = false
                    Config.ClothStoreClosed()
                else
                    local model = GetEntityModel(PlayerPedId())
                    skinData.model = model
                    if Config.ModelSaveType == "modelname" then
                        skinData.model = GetEntityArchetypeName(PlayerPedId())
                        model = GetEntityArchetypeName(PlayerPedId())
                    end
                    TriggerServerEvent("0r-clothing:saveSkin:server", model, skinData)
                    TriggerEvent("inventory:c:giveClothesAsItem", skinData, {}, true)
                end
            end)
            return
        end
        local model = GetEntityModel(PlayerPedId())
        skinData.model = model
        if Config.ModelSaveType == "modelname" then
            skinData.model = GetEntityArchetypeName(PlayerPedId())
            model = GetEntityArchetypeName(PlayerPedId())
        end
        TriggerServerEvent("0r-clothing:saveSkin:server", model, skinData)
        TriggerEvent("inventory:c:giveClothesAsItem", skinData, {}, true)
    elseif data.action == "cancelBeforePayment" then
        SetNuiFocus(false, false)
        DeletePed(createdCharChamPed)
        ClearTimecycleModifier()
        RenderScriptCams(false, true, 500, 1, 0)
        DestroyCam(createdCharCham, false)
        createdCharCham = nil
        FreezeEntityPosition(PlayerPedId(), false)
        TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
        clothingStoreOpen = false
        Config.ClothStoreClosed()
        Config.ShowHUD()
        comparingClothes = false
        if DoesEntityExist(myClone) then DeletePed(myClone) end
        if DoesEntityExist(myClone2) then DeletePed(myClone2) end
    elseif data.action == "buyClothing" then
        TriggerCallback('0r-clothing:buyClothing:server', function(hasMoney)
            cb(hasMoney)
            if hasMoney then
                Config.ShowHUD()
                SetNuiFocus(false, false)
                DeletePed(createdCharChamPed)
                ClearTimecycleModifier()
                RenderScriptCams(false, true, 500, 1, 0)
                DestroyCam(createdCharCham, false)
                createdCharCham = nil
                FreezeEntityPosition(PlayerPedId(), false)
                if currentClothStoreType == "tattoo" then
                    for k, v in pairs(shopTattoos) do
                        table.insert(currentTattoos, {collection = v.collection, name = v.name, name2 = v.name2, mname = k})
                    end
                    shopTattoos = {}
                    TriggerServerEvent('0r-clothing:updateTattooList:server', currentTattoos)
                    TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
                else
                    local model = GetEntityModel(PlayerPedId())
                    skinData.model = model
                    if Config.ModelSaveType == "modelname" then
                        skinData.model = GetEntityArchetypeName(PlayerPedId())
                        model = GetEntityArchetypeName(PlayerPedId())
                    end
                    TriggerServerEvent("0r-clothing:saveSkin:server", model, skinData)
                    TriggerEvent("inventory:c:giveClothesAsItem", skinData, previousSkinData, false)
                end
                Notify(Lang:t("notifications.clothes_paid"), "success", 7500)
                clothingStoreOpen = false
                Config.ClothStoreClosed()
            else
                Config.ShowHUD()
                SetNuiFocus(false, false)
                DeletePed(createdCharChamPed)
                ClearTimecycleModifier()
                RenderScriptCams(false, true, 500, 1, 0)
                DestroyCam(createdCharCham, false)
                createdCharCham = nil
                FreezeEntityPosition(PlayerPedId(), false)
                if currentClothStoreType == "tattoo" then
                    TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
                    shopTattoos = {}
                else
                    TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
                end
                Notify(Lang:t("notifications.not_enough_money"), "error", 7500)
                clothingStoreOpen = false
                Config.ClothStoreClosed()
            end
        end, data.type, data.amount)
        comparingClothes = false
        if DoesEntityExist(myClone) then DeletePed(myClone) end
        if DoesEntityExist(myClone2) then DeletePed(myClone2) end
        return
    elseif data.action == "changeTattoo" then
        for k, v in pairs(currentTattoos) do
            if v.mname == data.mname then
                currentTattoos[k] = nil
                return drawTattoo()
            end
        end
        if shopTattoos[data.mname] then
            shopTattoos[data.mname] = nil
        else
            shopTattoos[data.mname] = {collection = data.collection, name = data.name, name2 = data.name2}
        end
        drawTattoo()
    elseif data.action == "createClone" then
        if data.num == 1 then
            -- Clone 1
            if DoesEntityExist(myClone) then return DeletePed(myClone) end
            local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), -0.35, 0.0, 0.0)
            local model = GetEntityModel(PlayerPedId())
            RequestModel(model)
            while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
            end
            myClone = CreatePed(0, model, Config.CompareClothes.Coords.Peds[1].x, Config.CompareClothes.Coords.Peds[1].y, Config.CompareClothes.Coords.Peds[1].z - 1.0, GetEntityHeading(PlayerPedId()), false, false)
            SetEntityHeading(myClone, Config.CompareClothes.Coords.Peds[1].w)
            FreezeEntityPosition(myClone, true)
            PlaceObjectOnGroundProperly(myClone)
            SetBlockingOfNonTemporaryEvents(myClone, true)
            SetEntityCollision(myClone, false, false)
            SetEntityVisible(myClone, false, 0)
            local skin = currentPlayerSkin
            local names = {
                ["Arms/Gloves"] = "arms",
                ["Vest"] = "vest",
                ["Scarfs/Necklaces"] = "accessory",
                ["Watches"] = "watch",
                ["Shoes"] = "shoes",
                ["Earrings"] = "ear",
                ["Bracelets"] = "bracelet",
                ["Jacket"] = "torso2",
                ["Masks"] = "mask",
                ["Decals"] = "decals",
                ["Pants"] = "pants",
                ["Bag"] = "bag",
                ["Glasses"] = "glass",
                ["Hat"] = "hat",
                ["Undershirt"] = "t-shirt",
                ["lipstick"] = "lipstick",
                ["Makeup"] = "makeup",
                ["ChestHair"] = "chesthair",
                ["FacialHairs"] = "beard",
                ["Hairs"] = "hair",
                ["Eyebrows"] = "eyebrows"
            }
            for k, v in pairs(data.data) do
                if k == "Hairs" then v.texture = GetPedHairColor(PlayerPedId()) end
                if names[k] then skin[names[k]] = {item = v.num, texture = v.texture, texture2 = v.texture2} end
            end
            TriggerEvent('0r-clothing:client:loadPlayerClothing', skin, myClone)
        else
            -- Clone 2
            if DoesEntityExist(myClone2) then return DeletePed(myClone2) end
            local coords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.35, 0.0, 0.0)
            local model = GetEntityModel(PlayerPedId())
            RequestModel(model)
            while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
            end
            myClone2 = CreatePed(0, model, Config.CompareClothes.Coords.Peds[2].x, Config.CompareClothes.Coords.Peds[2].y, Config.CompareClothes.Coords.Peds[2].z - 1.0, GetEntityHeading(PlayerPedId()), false, false)
            SetEntityHeading(myClone2, Config.CompareClothes.Coords.Peds[2].w)
            FreezeEntityPosition(myClone2, true)
            PlaceObjectOnGroundProperly(myClone2)
            SetBlockingOfNonTemporaryEvents(myClone2, true)
            SetEntityCollision(myClone2, false, false)
            SetEntityVisible(myClone2, false, 0)
            local skin = currentPlayerSkin
            local names = {
                ["Arms/Gloves"] = "arms",
                ["Vest"] = "vest",
                ["Scarfs/Necklaces"] = "accessory",
                ["Watches"] = "watch",
                ["Shoes"] = "shoes",
                ["Earrings"] = "ear",
                ["Bracelets"] = "bracelet",
                ["Jacket"] = "torso2",
                ["Masks"] = "mask",
                ["Decals"] = "decals",
                ["Pants"] = "pants",
                ["Bag"] = "bag",
                ["Glasses"] = "glass",
                ["Hat"] = "hat",
                ["Undershirt"] = "t-shirt",
                ["lipstick"] = "lipstick",
                ["Makeup"] = "makeup",
                ["ChestHair"] = "chesthair",
                ["FacialHairs"] = "beard",
                ["Hairs"] = "hair",
                ["Eyebrows"] = "eyebrows"
            }
            for k, v in pairs(data.data) do
                if k == "Hairs" then v.texture = GetPedHairColor(PlayerPedId()) end
                if names[k] then skin[names[k]] = {item = v.num, texture = v.texture, texture2 = v.texture2} end
            end
            TriggerEvent('0r-clothing:client:loadPlayerClothing', skin, myClone2)
        end
    elseif data.action == "confirmCompare" then
        DoScreenFadeOut(1000)
        Citizen.Wait(1000)
        oldPedCoords = GetEntityCoords(PlayerPedId())
        SetEntityVisible(myClone, true, 0)
        SetEntityVisible(myClone2, true, 0)
        SetEntityAlpha(myClone, 190, false)
        SetEntityAlpha(myClone2, 190, false)
        comparingClothes = true
        Citizen.CreateThread(function()
            while comparingClothes do
                Citizen.Wait(0)
                SetEntityLocallyInvisible(PlayerPedId())
            end
        end)
        charCam(false)
        while DoesCamExist(createdCharCham) do Citizen.Wait(500) end
        charCam2(true)
    elseif data.action == "stopComparingClothes" then
        comparingClothes = false
        if DoesEntityExist(myClone) then DeletePed(myClone) end
        if DoesEntityExist(myClone2) then DeletePed(myClone2) end
        charCam2(false)
        ClearFocus()
        while DoesCamExist(createdCharCham2) do Citizen.Wait(500) end
        if data.type ~= "closeFull" then
            charCam(true)
        end
        Citizen.Wait(1000)
        DoScreenFadeIn(1000)
    elseif data.action == "hoverPed" then
        if data.num == 1 then
            if data.state then
                SetEntityAlpha(myClone, 255, false)
            else
                SetEntityAlpha(myClone, 190, false)
            end
        else
            if data.state then
                SetEntityAlpha(myClone2, 255, false)
            else
                SetEntityAlpha(myClone2, 190, false)
            end
        end
    elseif data.action == "choosePed" then
        if data.num == 1 then
            SetEntityAlpha(myClone, 255, false)
            SetEntityAlpha(myClone2, 190, false)
        else
            SetEntityAlpha(myClone, 190, false)
            SetEntityAlpha(myClone2, 255, false)
        end
    elseif data.action == "choosePed2" then
        if data.num == 1 then
            ClonePedToTarget(myClone, PlayerPedId())
        else
            ClonePedToTarget(myClone2, PlayerPedId())
        end
    end
    cb(true)
end)

function drawTattoo()
    ClearPedDecorations(PlayerPedId())
    for k, v in pairs(currentTattoos) do
        if GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') then
            SetPedDecoration(PlayerPedId(), v.collection, v.name)
        else
            SetPedDecoration(PlayerPedId(), v.collection, v.name2)
        end
    end
    for k, v in pairs(shopTattoos) do
        if GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') then
            SetPedDecoration(PlayerPedId(), v.collection, v.name)
        else
            SetPedDecoration(PlayerPedId(), v.collection, v.name2)
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        if not clothingStoreOpen then
            TriggerCallback('0r-clothing:getPlayerTattoos:server', function(tattooList)
                if not tattooList then
                    tattooList = {}
                end
                if tattooList then
                    ClearPedDecorations(PlayerPedId())
                    for k, v in pairs(tattooList) do
                        if GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') then
                            SetPedDecoration(PlayerPedId(), v.collection, v.name)
                        else
                            SetPedDecoration(PlayerPedId(), v.collection, v.name2)
                        end
                    end
                    currentTattoos = tattooList
                end
            end)
        end
    end
end)

if Config.Interaction.TextUI.Enable then
    closestClothingArea = {}
    local showTextUI = false
    Citizen.CreateThread(function()
        while true do
            local sleep = 100
            if not menuActive then
                playerPed = PlayerPedId()
                playerCoords = GetEntityCoords(playerPed)
                if not closestClothingArea.id then
                    for k, v in pairs(Config.Stores) do
                        local dist = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))
                        if dist <= 5.0 then
                            if canOpenStore(v.groupType, v.group) then
                                function currentShow()
                                    local label = Lang:t("interaction.get_stylish")
                                    if v.shopType == "barber" then
                                        label = Lang:t("interaction.barber_shop")
                                    elseif v.shopType == "tattoo" then
                                        label = Lang:t("interaction.tattoo_shop")
                                    elseif v.shopType == "surgeon" then
                                        label = Lang:t("interaction.surgeon")
                                    end
                                    Config.Interaction.TextUI.Show(label)
                                    showTextUI = true
                                end
                                function currentHide()
                                    Config.Interaction.TextUI.Hide()
                                end
                                closestClothingArea = {id = k, distance = dist, maxDist = 5.0, type = v.shopType, data = {coords = vector3(v.coords.x, v.coords.y, v.coords.z)}}
                            end
                        end
                    end
                end
                if closestClothingArea.id then
                    while true do
                        playerPed = PlayerPedId()
                        playerCoords = GetEntityCoords(playerPed)
                        closestClothingArea.distance = #(vector3(closestClothingArea.data.coords.x, closestClothingArea.data.coords.y, closestClothingArea.data.coords.z) - playerCoords)
                        if closestClothingArea.distance < closestClothingArea.maxDist then
                            if IsControlJustReleased(0, 38) then
                                openClothStore(closestClothingArea.type)
                            end
                            if not showTextUI then
                                currentShow()
                            end
                        else
                            currentHide()
                            break
                        end
                        Citizen.Wait(0)
                    end
                    showTextUI = false
                    closestClothingArea = {}
                    sleep = 0
                end
            end
            Citizen.Wait(sleep)
        end
    end)
else
    for k, v in pairs(Config.Stores) do
        local label = Lang:t("interaction.get_stylish")
        if v.shopType == "barber" then
            label = Lang:t("interaction.barber_shop")
        elseif v.shopType == "tattoo" then
            label = Lang:t("interaction.tattoo_shop")
        elseif v.shopType == "surgeon" then
            label = Lang:t("interaction.surgeon")
        end
        if GetResourceState('qb-target') == 'started' or GetResourceState('pa-target') == 'started' then
            exports['qb-target']:AddBoxZone(k .. "_clothing_boxzone", vector3(v.coords.x, v.coords.y, v.coords.z), Config.Interaction.Target.Zone, Config.Interaction.Target.Zone, {
                name = k .. "_clothing_boxzone",
                heading = 180.0,
                debugPoly = false,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
            }, {
                options = {
                    {
                        num = 1,
                        icon = Config.Interaction.Target.Icon,
                        label = label,
                        action = function()
                            openClothStore(v.shopType)
                        end,
                        canInteract = function()
                            return canOpenStore(v.groupType, v.group)
                        end
                    }
                },
                distance = Config.Interaction.Target.Distance
            })
        elseif GetResourceState('ox_target') == 'started' then
            exports.ox_target:addBoxZone({
                coords = vector3(v.coords.x, v.coords.y, v.coords.z),
                size = vec3(Config.Interaction.Target.Zone, Config.Interaction.Target.Zone, Config.Interaction.Target.Zone),
                rotation = 180.0,
                options = {
                    {
                        num = 1,
                        icon = Config.Interaction.Target.Icon,
                        label = label,
                        distance = Config.Interaction.Target.Distance,
                        onSelect = function()
                            openClothStore(v.shopType)
                        end,
                        canInteract = function()
                            return canOpenStore(v.groupType, v.group)
                        end
                    }
                },
            })
        end
    end
end

function openClothStore(menuType)
    Config.ClothStoreOpened()
    clothingStoreOpen = true
    -- Citizen.Wait(500)
    while GetResourceState("0r-imagegenerator") == "starting" do Citizen.Wait(0) end
    local uuid = nil
    if Config.UseWebServer then
        TriggerCallback('0r-clothing:getClothingUrl:server', function(urlData)
            uuid = urlData
        end, false)
        local startTime = GetGameTimer()
        while uuid == nil do 
            Citizen.Wait(0)  
            if GetGameTimer() - startTime > 10 then
                print("Used default UUID.")
                uuid = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6"
                break
            end 
        end
    else
        uuid = "nui://0r-imagegenerator/images/"
    end
    local myPed = GetEntityModel(PlayerPedId())
    local myPedExists = false
    for k, v in pairs(Config.AllowedModels) do
        if myPed == GetHashKey(v) then
            myPedExists = true
        end
    end
    Citizen.Wait(250)
    if not myPedExists then return Notify(Lang:t("notifications.char_model_not_allowed"), "error", 7500) end
    -- Gender
    local gender = "male"
    for k, v in pairs(ManPlayerModels) do
        if myPed == GetHashKey(v) then
            gender = "male"
        end
    end
    for k, v in pairs(WomanPlayerModels) do
        if myPed == GetHashKey(v) then
            gender = "female"
        end
    end
    charCreateGender = gender
    -- Data
    local generalData = {}
    currentClothStoreType = menuType
    if menuType == "surgeon" then
        if CoreName == "qb" then
            Core.Functions.GetPlayerData(function(pData)
                local gender = "male"
                if pData.charinfo.gender == 1 then
                    gender = "female"
                end
                createFirstCharacterWithoutReset(gender, Config.CharacterCreationMenuCategories.Normal, true, true)
            end)
        else
            local pData = GetPlayerData()
            if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
                createFirstCharacterWithoutReset("male", Config.CharacterCreationMenuCategories.Normal, true, true)
            else
                createFirstCharacterWithoutReset("female", Config.CharacterCreationMenuCategories.Normal, true, true)
            end
        end
    elseif menuType == "barber" then
        -- Chest Hair
        local chestHair = {}
        if Config.UseDefaultClothImages.Body then
            for i = -1, GetPedHeadOverlayNum(10) - 1 do
                table.insert(chestHair, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_BODY_10_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetPedHeadOverlayNum(10) - 1 do
                table.insert(chestHair, {num = i, image = uuid .. "_" .. gender .."_BODY_10_" .. i .. '.webp?v=9999'})
            end
        end
        local chestHairResultsData = {GetPedHeadOverlayData(PlayerPedId(), 10)}
        if chestHairResultsData[2] == 255 then chestHairResultsData[2] = -1 end
        table.insert(generalData, {
            action = "ChestHair",
            data = chestHair,
            imgType = "MDLCDivBDivBigIMG3",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 10,
            currentDrawableVariation = chestHairResultsData[2],
            currentDrawableVariationOpacity = chestHairResultsData[6]
        })
        -- Makeup
        local makeup = {}
        if Config.UseDefaultClothImages.Makeup then
            for i = -1, GetPedHeadOverlayNum(4) - 1 do
                table.insert(makeup, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_4_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetPedHeadOverlayNum(4) - 1 do
                table.insert(makeup, {num = i, image = uuid .. "_" .. gender .."_HEAD_4_" .. i .. '.webp?v=9999'})
            end
        end
        local makeupResults = {GetPedHeadOverlayData(PlayerPedId(), 4)}
        if makeupResults[2] == 255 then makeupResults[2] = -1 end
        table.insert(generalData, {
            action = "Makeup",
            data = makeup,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 4,
            currentDrawableVariation = makeupResults[2],
            currentTextureDrawableVariation = makeupResults[4]
        })
        -- Makeup Colors
        table.insert(generalData, {
            action = "FirstMakeupColor",
            data = Config.MakeupColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "SecondMakeupColor",
            data = Config.MakeupColors,
            imgType = "",
            btnClick2 = true
        })
        -- Blush
        local blush = {}
        if Config.UseDefaultClothImages.Makeup then
            for i = -1, GetPedHeadOverlayNum(5) - 1 do
                table.insert(blush, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_5_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetPedHeadOverlayNum(5) - 1 do
                table.insert(blush, {num = i, image = uuid .. "_" .. gender .."_HEAD_5_" .. i .. '.webp?v=9999'})
            end
        end
        local blushResults = {GetPedHeadOverlayData(PlayerPedId(), 5)}
        if blushResults[2] == 255 then blushResults[2] = -1 end
        table.insert(generalData, {
            action = "Blush",
            data = blush,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 5,
            currentDrawableVariation = blushResults[2],
            currentTextureDrawableVariation = blushResults[4]
        })
        table.insert(generalData, {
            action = "FirstBlushColor",
            data = Config.MakeupColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "SecondBlushColor",
            data = Config.MakeupColors,
            imgType = "",
            btnClick2 = true
        })
        -- Lipstick
        local lipstick = {}
        if Config.UseDefaultClothImages.Makeup then
            for i = -1, GetPedHeadOverlayNum(8) - 1 do
                table.insert(lipstick, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_8_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetPedHeadOverlayNum(8) - 1 do
                table.insert(lipstick, {num = i, image = uuid .. "_" .. gender .."_HEAD_8_" .. i .. '.webp?v=9999'})
            end
        end
        local lipstickResults = {GetPedHeadOverlayData(PlayerPedId(), 8)}
        if lipstickResults[2] == 255 then lipstickResults[2] = -1 end
        table.insert(generalData, {
            action = "Lipstick",
            data = lipstick,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 8,
            currentDrawableVariation = lipstickResults[2],
            currentTextureDrawableVariation = lipstickResults[4]
        })
        table.insert(generalData, {
            action = "FirstLipstickColor",
            data = Config.MakeupColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "SecondLipstickColor",
            data = Config.MakeupColors,
            imgType = "",
            btnClick2 = true
        })
        -- Makeup & Blush & Lipstick
        table.insert(generalData, {
            action = "mblOpacity",
            data = {},
            MakeupOpacity = makeupResults[6],
            BlushOpacity = blushResults[6],
            LipstickOpacity = lipstickResults[6]
        })
        -- Eyebrows
        local eyebrows = {}
        for i = -1, GetPedHeadOverlayNum(2) - 1 do
            table.insert(eyebrows, {num = i, image = 'files/eyebrows/' .. i .. '.webp?v=9999'})
        end
        local eyebrowsResultData = {GetPedHeadOverlayData(PlayerPedId(), 2)}
        if eyebrowsResultData[2] == 255 then eyebrowsResultData[2] = -1 end
        table.insert(generalData, {
            action = "Eyebrows",
            data = eyebrows,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            variationNumber = 2,
            currentDrawableVariation = eyebrowsResultData[2],
            currentTextureDrawableVariation = eyebrowsResultData[4],
            currentDrawableVariationOpacity = eyebrowsResultData[6]
        })
        table.insert(generalData, {
            action = "EyebrowColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "EyebrowHighlightColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        -- Facial Hairs
        local facialHairs = {}
        if Config.UseDefaultClothImages.Hair then
            for i = -1, GetPedHeadOverlayNum(1) - 1 do
                table.insert(facialHairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetPedHeadOverlayNum(1) - 1 do
                table.insert(facialHairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
            end
        end
        local facialHairResults = {GetPedHeadOverlayData(PlayerPedId(), 1)}
        if facialHairResults[2] == 255 then facialHairResults[2] = -1 end
        table.insert(generalData, {
            action = "FacialHairs",
            data = facialHairs,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = facialHairResults[2],
            currentDrawableVariationOpacity = facialHairResults[6],
            currentTextureDrawableVariation = facialHairResults[4]
        })
        table.insert(generalData, {
            action = "FacialHairsColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "FacialHairsHighlightColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        -- Hairs
        local hairs = {}
        if Config.UseDefaultClothImages.Hair then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(hairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(hairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Hairs",
            data = hairs,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = false,
            variationNumber = 2,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 2),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 2)
        })
        table.insert(generalData, {
            action = "HairsColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "HairsHighlightColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "HairFade",
            data = {},
            imgType = ""
        })
        table.insert(generalData, {
            action = "HairTexture",
            data = {},
            imgType = ""
        })
        -- Jacket
        local jackets = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
                table.insert(jackets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
                table.insert(jackets, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Jacket",
            data = jackets,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 11,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 11),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 11),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 11)
        })
        -- Pants
        local pants = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
                table.insert(pants, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
                table.insert(pants, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Pants",
            data = pants,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 4,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 4),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 4),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 4)
        })
        -- Masks
        local masks = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
                table.insert(masks, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
                table.insert(masks, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Masks",
            data = masks,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 1),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 1),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
        })
        -- Bag
        local bags = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
                table.insert(bags, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
                table.insert(bags, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Bag",
            data = bags,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 5,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 5),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 5),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 5)
        })
        -- Hat
        local hat = {}
        if Config.UseDefaultClothImages.Accessories then
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
                table.insert(hat, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
                table.insert(hat, {num = i, image = uuid .. "_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Hat",
            data = hat,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 0,
            currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 0),
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 0),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
        })
        -- Glasses
        local glasses = {}
        local minGlassesNumber = -1
        if gender == "male" then minGlassesNumber = 0 end
        if Config.UseDefaultClothImages.Accessories then
            for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
                table.insert(glasses, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
                table.insert(glasses, {num = i, image = uuid .. "_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
            end
        end
        local currentGlasses = GetPedPropIndex(PlayerPedId(), 1)
        if currentGlasses == -1 then currentGlasses = 0 end
        table.insert(generalData, {
            action = "Glasses",
            data = glasses,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGGlasses",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = currentGlasses,
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 1),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1)
        })
        -- Undershirt
        local undershirts = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
                table.insert(undershirts, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
                table.insert(undershirts, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Undershirt",
            data = undershirts,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 8,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 8),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 8),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 8)
        })
        -- Arms/Gloves
        local armsgloves = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
                table.insert(armsgloves, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
                table.insert(armsgloves, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Arms/Gloves",
            data = armsgloves,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 3,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 3),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 3),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 3)
        })
        -- Shoes
        local shoes = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
                table.insert(shoes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
                table.insert(shoes, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Shoes",
            data = shoes,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMG",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 6,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 6),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 6),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 6)
        })
    elseif menuType == "clothing" then
        -- Jacket
        local jackets = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
                table.insert(jackets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
                table.insert(jackets, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Jacket",
            data = jackets,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 11,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 11),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 11),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 11)
        })
        -- Pants
        local pants = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
                table.insert(pants, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
                table.insert(pants, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Pants",
            data = pants,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 4,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 4),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 4),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 4)
        })
        -- Facial Hairs
        local facialHairs = {}
        if Config.UseDefaultClothImages.Hair then
            for i = -1, GetPedHeadOverlayNum(1) - 1 do
                table.insert(facialHairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetPedHeadOverlayNum(1) - 1 do
                table.insert(facialHairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_1_" .. i .. '.webp?v=9999'})
            end
        end
        local facialHairResults = {GetPedHeadOverlayData(PlayerPedId(), 1)}
        if facialHairResults[2] == 255 then facialHairResults[2] = -1 end
        table.insert(generalData, {
            action = "FacialHairs",
            data = facialHairs,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = facialHairResults[2],
            currentDrawableVariationOpacity = facialHairResults[6],
            currentTextureDrawableVariation = facialHairResults[4]
        })
        table.insert(generalData, {
            action = "FacialHairsColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "FacialHairsHighlightColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        -- Hairs
        local hairs = {}
        if Config.UseDefaultClothImages.Hair then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(hairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(hairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Hairs",
            data = hairs,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = false,
            variationNumber = 2,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 2),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 2)
        })
        table.insert(generalData, {
            action = "HairsColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "HairsHighlightColors",
            data = Config.HairColors,
            imgType = "",
            btnClick2 = true
        })
        table.insert(generalData, {
            action = "HairFade",
            data = {},
            imgType = ""
        })
        table.insert(generalData, {
            action = "HairTexture",
            data = {},
            imgType = ""
        })
        -- Masks
        local masks = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
                table.insert(masks, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
                table.insert(masks, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_1_" .. i .. '.webp'})
            end
        end
        table.insert(generalData, {
            action = "Masks",
            data = masks,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 1),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 1),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
        })
        -- Bag
        local bags = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
                table.insert(bags, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
                table.insert(bags, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Bag",
            data = bags,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 5,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 5),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 5),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 5)
        })
        -- Hat
        local hat = {}
        if Config.UseDefaultClothImages.Accessories then
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
                table.insert(hat, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
                table.insert(hat, {num = i, image = uuid .. "_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Hat",
            data = hat,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 0,
            currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 0),
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 0),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
        })
        -- Glasses
        local glasses = {}
        local minGlassesNumber = -1
        if gender == "male" then minGlassesNumber = 0 end
        if Config.UseDefaultClothImages.Accessories then
            for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
                table.insert(glasses, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
                table.insert(glasses, {num = i, image = uuid .. "_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
            end
        end
        local currentGlasses = GetPedPropIndex(PlayerPedId(), 1)
        if currentGlasses == -1 then currentGlasses = 0 end
        table.insert(generalData, {
            action = "Glasses",
            data = glasses,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGGlasses",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = currentGlasses,
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 1),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1)
        })
        -- Earrings
        local earrings = {}
        if Config.UseDefaultClothImages.Accessories then
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(earrings, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_2_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(earrings, {num = i, image = uuid .. "_" .. gender .."_PROPS_2_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Earrings",
            data = earrings,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 2,
            currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 2),
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 2),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 2)
        })
        -- Watches
        local watches = {}
        if Config.UseDefaultClothImages.Accessories then
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6) - 1 do
                table.insert(watches, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_6_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6) - 1 do
                table.insert(watches, {num = i, image = uuid .. "_" .. gender .."_PROPS_6_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Watches",
            data = watches,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 6,
            currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 6),
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 6),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 6)
        })
        -- Bracelets
        local bracelets = {}
        if Config.UseDefaultClothImages.Accessories then
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7) - 1 do
                table.insert(bracelets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_7_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7) - 1 do
                table.insert(bracelets, {num = i, image = uuid .. "_" .. gender .."_PROPS_7_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Bracelets",
            data = bracelets,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 7,
            currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 7),
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 7),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 7)
        })
        -- Undershirt
        local undershirts = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
                table.insert(undershirts, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
                table.insert(undershirts, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Undershirt",
            data = undershirts,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 8,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 8),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 8),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 8)
        })
        -- Arms/Gloves
        local armsgloves = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
                table.insert(armsgloves, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
                table.insert(armsgloves, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Arms/Gloves",
            data = armsgloves,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 3,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 3),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 3),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 3)
        })
        -- Decals
        local decals = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 10) do
                table.insert(decals, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_10_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 10) do
                table.insert(decals, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_10_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Decals",
            data = decals,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 10,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 10),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 10),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 10)
        })
        -- Shoes
        local shoes = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
                table.insert(shoes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
                table.insert(shoes, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Shoes",
            data = shoes,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMG",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 6,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 6),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 6),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 6)
        })
        -- Vest
        local vests = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 9) do
                table.insert(vests, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_9_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 9) do
                table.insert(vests, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_9_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Vest",
            data = vests,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 9,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 9),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 9),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 9)
        })
        -- Scarfs/Necklaces
        local scarfsNecklaces = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 7) do
                table.insert(scarfsNecklaces, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_7_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 7) do
                table.insert(scarfsNecklaces, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_7_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Scarfs/Necklaces",
            data = scarfsNecklaces,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 7,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 7),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 7),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 7)
        })
    elseif menuType == "tattoo" then
        local myPed = GetEntityModel(PlayerPedId())
        local myPedExists = false
        for k, v in pairs(Config.AllowedModels) do
            if myPed == GetHashKey(v) then
                myPedExists = true
            end
        end
        Citizen.Wait(250)
        if not myPedExists then return Notify(Lang:t("notifications.char_model_not_allowed"), "error", 7500) end
        -- Hairs
        local hairs = {}
        if Config.UseDefaultClothImages.Hair then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(hairs, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 2) - 1 do
                table.insert(hairs, {num = i, image = uuid .. "_" .. gender .."_HEAD_2_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Hairs",
            data = hairs,
            imgType = "MDLCDivBDivBigIMG2",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = false,
            variationNumber = 2,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 2),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 2)
        })
        -- Arms/Gloves
        local armsgloves = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
                table.insert(armsgloves, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 3) do
                table.insert(armsgloves, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_3_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Arms/Gloves",
            data = armsgloves,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 3,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 3),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 3),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 3)
        })
        -- Jacket
        local jackets = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
                table.insert(jackets, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 11) do
                table.insert(jackets, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_11_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Jacket",
            data = jackets,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 11,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 11),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 11),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 11)
        })
        -- Pants
        local pants = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
                table.insert(pants, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 4) do
                table.insert(pants, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_4_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Pants",
            data = pants,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 4,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 4),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 4),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 4)
        })
        -- Masks
        local masks = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
                table.insert(masks, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 1) do
                table.insert(masks, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_1_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Masks",
            data = masks,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 1),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 1),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 1)
        })
        -- Bag
        local bags = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
                table.insert(bags, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 5) do
                table.insert(bags, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_5_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Bag",
            data = bags,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 5,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 5),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 5),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 5)
        })
        -- Hat
        local hat = {}
        if Config.UseDefaultClothImages.Accessories then
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
                table.insert(hat, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
            end
        else
            for i = -1, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0) - 1 do
                table.insert(hat, {num = i, image = uuid .. "_" .. gender .."_PROPS_0_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Hat",
            data = hat,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGMask",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 0,
            currentDrawableVariation = GetPedPropIndex(PlayerPedId(), 0),
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 0),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 0)
        })
        -- Glasses
        local glasses = {}
        local minGlassesNumber = -1
        if gender == "male" then minGlassesNumber = 0 end
        if Config.UseDefaultClothImages.Accessories then
            for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
                table.insert(glasses, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
            end
        else
            for i = minGlassesNumber, GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1) - 1 do
                table.insert(glasses, {num = i, image = uuid .. "_" .. gender .."_PROPS_1_" .. i .. '.webp?v=9999'})
            end
        end
        local currentGlasses = GetPedPropIndex(PlayerPedId(), 1)
        if currentGlasses == -1 then currentGlasses = 0 end
        table.insert(generalData, {
            action = "Glasses",
            data = glasses,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMGGlasses",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 1,
            currentDrawableVariation = currentGlasses,
            currentTextureDrawableVariation = GetPedPropTextureIndex(PlayerPedId(), 1),
            maxVariationNumber = GetNumberOfPedPropDrawableVariations(PlayerPedId(), 1)
        })
        -- Undershirt
        local undershirts = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
                table.insert(undershirts, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 8) do
                table.insert(undershirts, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_8_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Undershirt",
            data = undershirts,
            imgType = "MDLCDivBDivBigIMG",
            btnClick = true,
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 8,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 8),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 8),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 8)
        })
        -- Shoes
        local shoes = {}
        if Config.UseDefaultClothImages.Clothing then
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
                table.insert(shoes, {num = i, image = "https://i.fmfile.com/inw6pBxDUEnlX7rza66Mp/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
            end
        else
            for i = 0, GetNumberOfPedDrawableVariations(PlayerPedId(), 6) do
                table.insert(shoes, {num = i, image = uuid .. "_" .. gender .."_CLOTHING_6_" .. i .. '.webp?v=9999'})
            end
        end
        table.insert(generalData, {
            action = "Shoes",
            data = shoes,
            btnClick = true,
            imgType = "MDLCDivBDivBigIMG",
            style = "filter: brightness(0.8) contrast(1.2) saturate(1.4) hue-rotate(-10deg);",
            search = true,
            variationNumber = 6,
            currentDrawableVariation = GetPedDrawableVariation(PlayerPedId(), 6),
            currentTextureDrawableVariation = GetPedTextureVariation(PlayerPedId(), 6),
            maxVariationNumber = GetNumberOfPedDrawableVariations(PlayerPedId(), 6)
        })
        -- Tattoo
        local tattoos = nil
        TriggerCallback('0r-clothing:getPlayerTattoos:server', function(tattooList)
            if not tattooList then
                tattooList = {}
            end
            tattoos = tattooList
        end)
        while not tattoos do Citizen.Wait(0) end
        local AllTattooList = json.decode(LoadResourceFile(GetCurrentResourceName(), 'AllTattoos.json'))
        SendNUIMessage({action = "setTattooList", list = AllTattooList, tattoos = tattoos})
    end
    SetNuiFocus(true, true)
    local nameConverters = {
        ["Jacket"] = {type = 1, number = 11},
        ["Hat"] = {type = 2, number = 0},
        ["Hairs"] = {type = 1, number = 2},
        ["FacialHairs"] = {type = 3, number = 1},
        ["Pants"] = {type = 1, number = 4},
        ["Masks"] = {type = 1, number = 1},
        ["Earrings"] = {type = 2, number = 2},
        ["Glasses"] = {type = 2, number = 1},
        ["Decals"] = {type = 1, number = 10},
        ["Undershirt"] = {type = 1, number = 8},
        ["Watches"] = {type = 2, number = 6},
        ["Bags"] = {type = 1, number = 5},
        ["Scarfs/Necklaces"] = {type = 1, number = 7},
        ["Arms/Gloves"] = {type = 1, number = 3},
        ["Shoes"] = {type = 1, number = 6},
        ["Bracelets"] = {type = 2, number = 7},
        ["Vest"] = {type = 1, number = 9},
        ["Eyebrows"] = {type = 3, number = 2},
        ["ChestHair"] = {type = 3, number = 10},
        ["Makeup"] = {type = 3, number = 4},
        ["Blush"] = {type = 3, number = 5},
        ["Lipstick"] = {type = 3, number = 8}
    }
    for k, v in pairs(Config.ClothPrices) do
        local data = nameConverters[k]
        if data.type == 1 then
            v.currentItemNum = GetPedDrawableVariation(PlayerPedId(), data.number)
            v.currentTextureNum = GetPedTextureVariation(PlayerPedId(), data.number)
        elseif data.type == 2 then
            v.currentItemNum = GetPedPropIndex(PlayerPedId(), data.number)
            v.currentTextureNum = GetPedPropTextureIndex(PlayerPedId(), data.number)
        elseif data.type == 3 then
            local results = {GetPedHeadOverlayData(PlayerPedId(), data.number)}
            if results[2] == 255 then results[2] = -1 end
            v.currentItemNum = results[2]
            v.currentTextureNum = results[4]
        end
    end
    Citizen.Wait(500)
    Config.HideHUD()
    local translations = {}
    for k in pairs(Lang.fallback and Lang.fallback.phrases or Lang.phrases) do
        if k:sub(0, ('menu.'):len()) then
            translations[k:sub(('menu.'):len() + 1)] = Lang:t(k)
        end
    end
    local categories = {}
    local selectedCategory = Config.ShopCategories[currentClothStoreType]
    if type(selectedCategory[1]) == "table" then
        for pageIndex, categoryList in ipairs(selectedCategory) do
            for _, v in ipairs(categoryList) do
                categories[v .. "_" .. pageIndex] = true
            end
        end
    else
        for _, v in ipairs(selectedCategory or {}) do
            categories[v .. "_1"] = true
        end
    end
    SendNUIMessage({action = "openClothStore", enableCompare = Config.CompareClothes.Enable, type = menuType, generalData = generalData, cps = Config.ClothPrices, gender = gender, translations = translations, currency = Config.ClothPriceCurrency, categories = categories, categoriesLength = #Config.ShopCategories[currentClothStoreType]})
    charCam(true)
end
exports('openClothStore', openClothStore)

-- RegisterCommand('openbarberStore', function(type)
--     exports["0r-clothing"]:openClothStore("barber")
-- end)
AddEventHandler('openClothingStore', function(type)
    exports["0r-clothing"]:openClothStore("clothing")
end)
AddEventHandler('opentattooStore', function(type) 
    exports["0r-clothing"]:openClothStore("tattoo")
end)
AddEventHandler('openbarberStore', function(type) 
    exports["0r-clothing"]:openClothStore("barber")
end)

AddEventHandler('gameEventTriggered', function(event, data)
    if event == 'CEventNetworkEntityDamage' then
        local victim, attacker, victimDied, weapon = data[1], data[2], data[4], data[7]
		if not IsEntityAPed(victim) then return end
        if victimDied and NetworkGetPlayerIndexFromPed(victim) == PlayerId() and IsEntityDead(PlayerPedId()) then
            if DoesCamExist(createdCharCham) then
                SetNuiFocus(false, false)
                DeletePed(createdCharChamPed)
                ClearTimecycleModifier()
                RenderScriptCams(false, true, 500, 1, 0)
                DestroyCam(createdCharCham, false)
                createdCharCham = nil
                FreezeEntityPosition(PlayerPedId(), false)
                SendNUIMessage({action = "closeAll"})
                Config.ShowHUD()
                if clothingStoreOpen then
                    Config.ClothStoreClosed()
                end
            end
		end
	end
end)

function getPlayerClothing()
    local mySkin = nil
    TriggerCallback('0r-clothing:getSkin:server', function(skin)
        mySkin = skin
    end)
    while mySkin == nil do Citizen.Wait(500) end
    return mySkin
end
exports('getPlayerClothing', getPlayerClothing)

function applyClothingToPed(data)
    if data.model then
        model = data.model ~= nil and (tonumber(data.model) or GetHashKey(data.model)) or false
        Citizen.CreateThread(function()
            RequestModel(model)
            while not HasModelLoaded(model) do
                RequestModel(model)
                Citizen.Wait(0)
            end
            SetPlayerModel(PlayerId(), model)
            SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
            TriggerEvent('0r-clothing:client:loadPlayerClothing', data, PlayerPedId())
        end)
    else
        TriggerEvent('0r-clothing:client:loadPlayerClothing', data, PlayerPedId())
    end
end
exports('applyClothingToPed', applyClothingToPed)

RegisterNetEvent('0r-clothing:saveSkin:client', function(skin)
    local model = GetEntityModel(PlayerPedId())
    skinData.model = model
    if Config.ModelSaveType == "modelname" then
        skinData.model = GetEntityArchetypeName(PlayerPedId())
        model = GetEntityArchetypeName(PlayerPedId())
    end
    TriggerServerEvent('0r-clothing:saveSkin:server', model, skin)
end)

Citizen.CreateThread(function()
    if Config.EditCharacter.Enable then
        for k, v in pairs(Config.EditCharacter.Areas) do
            if v.UsePed then
                local pedHash2 = type(v.PedModel) == "number" and v.PedModel or joaat(v.PedModel)
                RequestModel(pedHash2)
                while not HasModelLoaded(pedHash2) do
                    Citizen.Wait(0)
                end
                v.Ped = CreatePed(0, pedHash2, v.Coords.x, v.Coords.y, v.Coords.z - 1, v.Coords.w, false, true)
                FreezeEntityPosition(v.Ped, true)
                SetEntityInvincible(v.Ped, true)
                SetBlockingOfNonTemporaryEvents(v.Ped, true)
                PlaceObjectOnGroundProperly(v.Ped)
                SetEntityAsMissionEntity(v.Ped, false, false)
                SetPedCanPlayAmbientAnims(v.Ped, false) 
                SetModelAsNoLongerNeeded(pedHash2)
                if Config.EditCharacter.Interaction.Target.Enable then
                    if GetResourceState('ox_target') == 'started' then
                        exports['ox_target']:addLocalEntity(v.Ped, {
                            [1] = {
                                label = Lang:t("interaction.edit_character"),
                                icon = Config.EditCharacter.Interaction.Target.Icon,
                                distance = Config.EditCharacter.Interaction.Target.Distance,
                                onSelect = function()
                                    if CoreName == "qb" then
                                        Core.Functions.GetPlayerData(function(pData)
                                            local gender = "male"
                                            if pData.charinfo.gender == 1 then
                                                gender = "female"
                                            end
                                            createFirstCharacterWithoutReset(gender, Config.CharacterCreationMenuCategories.Normal, true, true)
                                        end)
                                    else
                                        local pData = GetPlayerData()
                                        if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
                                            createFirstCharacterWithoutReset("male", Config.CharacterCreationMenuCategories.Normal, true, true)
                                        else
                                            createFirstCharacterWithoutReset("female", Config.CharacterCreationMenuCategories.Normal, true, true)
                                        end
                                    end
                                end
                            },
                        })
                    elseif GetResourceState('qb-target') == 'started' or GetResourceState('pa-target') == 'started' then
                        exports['qb-target']:AddTargetEntity(v.Ped, {
                            options = {
                                {
                                    label = Lang:t("interaction.edit_character"),
                                    icon = Config.EditCharacter.Interaction.Target.Icon,
                                    action = function()
                                        if CoreName == "qb" then
                                            Core.Functions.GetPlayerData(function(pData)
                                                local gender = "male"
                                                if pData.charinfo.gender == 1 then
                                                    gender = "female"
                                                end
                                                createFirstCharacterWithoutReset(gender, Config.CharacterCreationMenuCategories.Normal, true, true)
                                            end)
                                        else
                                            local pData = GetPlayerData()
                                            if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
                                                createFirstCharacterWithoutReset("male", Config.CharacterCreationMenuCategories.Normal, true, true)
                                            else
                                                createFirstCharacterWithoutReset("female", Config.CharacterCreationMenuCategories.Normal, true, true)
                                            end
                                        end
                                    end
                                }
                            },
                            distance = Config.EditCharacter.Interaction.Target.Distance
                        })
                    end
                else
                    closestClothingArea2 = {}
                    local showTextUI2 = false
                    Citizen.CreateThread(function()
                        while true do
                            local sleep = 100
                            if not menuActive then
                                playerPed = PlayerPedId()
                                playerCoords = GetEntityCoords(playerPed)
                                if not closestClothingArea2.id then
                                    for k, v in pairs(Config.EditCharacter.Areas) do
                                        --if v.Interaction.DrawText.Enable then
                                            local dist = #(playerCoords - vector3(v.Coords.x, v.Coords.y, v.Coords.z))
                                            if dist <= 5.0 then
                                                function currentShow()
                                                    Config.Interaction.TextUI.Show(Lang:t("interaction.edit_character"))
                                                    showTextUI2 = true
                                                end
                                                function currentHide()
                                                    Config.Interaction.TextUI.Hide()
                                                end
                                                closestClothingArea2 = {id = k, distance = dist, maxDist = Config.EditCharacter.Interaction.TextUI.Distance, data = {coords = vector3(v.Coords.x, v.Coords.y, v.Coords.z)}}
                                            end
                                        --end
                                    end
                                end
                                if closestClothingArea2.id then
                                    while true do
                                        playerPed = PlayerPedId()
                                        playerCoords = GetEntityCoords(playerPed)
                                        closestClothingArea2.distance = #(vector3(closestClothingArea2.data.coords.x, closestClothingArea2.data.coords.y, closestClothingArea2.data.coords.z) - playerCoords)
                                        if closestClothingArea2.distance < closestClothingArea2.maxDist then
                                            if IsControlJustReleased(0, 38) then
                                                if CoreName == "qb" then
                                                    Core.Functions.GetPlayerData(function(pData)
                                                        local gender = "male"
                                                        if pData.charinfo.gender == 1 then
                                                            gender = "female"
                                                        end
                                                        createFirstCharacterWithoutReset(gender, Config.CharacterCreationMenuCategories.Normal, true, true)
                                                    end)
                                                else
                                                    local pData = GetPlayerData()
                                                    if pData.sex == 0 or tonumber(pData.sex) == 0 or pData.sex == "m" then
                                                        createFirstCharacterWithoutReset("male", Config.CharacterCreationMenuCategories.Normal, true, true)
                                                    else
                                                        createFirstCharacterWithoutReset("female", Config.CharacterCreationMenuCategories.Normal, true, true)
                                                    end
                                                end
                                            end
                                            if not showTextUI2 then
                                                currentShow()
                                            end
                                        else
                                            currentHide()
                                            break
                                        end
                                        Citizen.Wait(0)
                                    end
                                    showTextUI2 = false
                                    closestClothingArea2 = {}
                                    sleep = 0
                                end
                            end
                            Citizen.Wait(sleep)
                        end
                    end)
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if creatingChar then
        TriggerServerEvent('0r-clothing:loadPlayerSkin:server')
    end
    charCam(false)
    for k, v in pairs(Config.EditCharacter.Areas) do
        if v.UsePed then
            if v.Ped then
                DeletePed(v.Ped)
            end
        end
    end
    if DoesEntityExist(myClone) then DeletePed(myClone) end
    if DoesEntityExist(myClone2) then DeletePed(myClone2) end
end)