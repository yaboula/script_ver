ESX = exports["es_extended"]:getSharedObject()

MainShared = {
    UseKeyFunction = false,
    NeedCloth = false, -- Set true if you want to force start working with outfit.

    Inventory = 'qs', -- ['esx' / 'ox' / 'qs']

    BlipSprite = 272,
    BlipColour = 11,
    BlipScale = 0.5,
    ShopPed = 'a_m_m_hillbilly_01',
    ShopLocations = {
       -- vector4(2936.69, 4628.94, 48.72, 56.3),
       -- vector4(2535.49, 4661.53, 34.08, 313.82),
       -- vector4(2313.78, 4888.23, 41.81, 42.97)
    },

    Notify = function(text, typee)
        lib.notify({
            description = text,
            type = typee
        })
    end,
    
    ServerNotify = function(src, text, type)
        --not using right now..
    end,
    
    -- this function can be used if UseKeyFunction true.
    AddVehicleKey = function(veh) 
        local plate = GetVehicleNumberPlateText(veh)
        --TriggerEvent('vehiclekeys:client:SetOwner', plate)
        exports['qs-vehiclekeys']:GetKey(plate)
    end,

    HelpNotifyType = 'Modern-Draw-Text', -- ['GTA-O' / 'Modern-Draw-Text']

    HelpNotify = function(txt, t, c)
        if t == 'GTA-O' then
            AddTextEntry('HelpNotification', txt)
            BeginTextCommandDisplayHelp('HelpNotification')
            EndTextCommandDisplayHelp(0, false, true, -1)
        elseif t == 'Modern-Draw-Text' then
            AddTextEntry('FloatingHelpNotification', txt)
            SetFloatingHelpTextWorldPosition(1, c.x, c.y, c.z+.8)
            SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
            BeginTextCommandDisplayHelp('FloatingHelpNotification')
            EndTextCommandDisplayHelp(2, false, true, -1)
        end
    end,

    PlayAnimation = function(ped, animDict, animName, duration, bilmem)
        if bilmem == nil then bilmem = 49 end
        if duration == nil then duration = -1 end
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do 
          Wait(0) 
        end
        TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, bilmem, 1, false, false, false)
        RemoveAnimDict(animDict)
    end,

    JobClothe = function()
        local ClothESX = {                        
            ["male"] ={                             
                ['tshirt_1'] = 15, ['tshirt_2'] = 0,
                ['torso_1'] = 319, ['torso_2'] = 2,
                ['decals_1'] = 0, ['decals_2'] = 0,
                ['arms'] = 68,
                ['pants_1'] = 120, ['pants_2'] = 19,
                ['shoes_1'] = 25, ['shoes_2'] = 0,
                ['helmet_1'] = 58, ['helmet_2'] = 0,
                ['chain_1'] = 0, ['chain_2'] = 0,
                ['ears_1'] = -1, ['ears_2'] = 0,
                ['mask_1'] = 0, ['mask_2'] = 0,
                ['bags_1'] = 0, ['bags_2'] = 0,
                ['glasses_1'] = 0, ['glasses_2'] = 0,
                ['bproof_1'] = 0,  ['bproof_2'] = 0
            },
            ["female"] ={
                ['tshirt_1'] = 15, ['tshirt_2'] = 0,
                ['torso_1'] = 333, ['torso_2'] = 2,
                ['decals_1'] = 0, ['decals_2'] = 0,
                ['arms'] = 76,
                ['pants_1'] = 124, ['pants_2'] = 19,
                ['shoes_1'] = 63, ['shoes_2'] = 0,
                ['helmet_1'] = -1, ['helmet_2'] = 0,
                ['chain_1'] = 0, ['chain_2'] = 0,
                ['ears_1'] = -1, ['ears_2'] = 0,
                ['mask_1'] = 0, ['mask_2'] = 0,
                ['bags_1'] = 0, ['bags_2'] = 0,
                ['glasses_1'] = 5, ['glasses_2'] = 0,
                ['bproof_1'] = 0,  ['bproof_2'] = 0
            }
        }
		TriggerEvent('skinchanger:getSkin', function(skin)
			if skin.sex == 0 then
				TriggerEvent('skinchanger:loadClothes', skin, ClothESX["male"])
			else
				TriggerEvent('skinchanger:loadClothes', skin, ClothESX["female"])
			end
		end) 
    end,

    ResetClothe = function()
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end) 
    end,

    HayBaleProp = {
        ["animDict"] = "anim@heists@box_carry@",
        ["animName"] = "idle",
        ["model"] = "prop_haybale_01",
        ["bone"] = 28422,
        ["x"] = 0.01,
        ["y"] = -0.02,
        ["z"] = -0.12,
        ["xR"] = 0.0,
        ["yR"] = 0.0,
        ["zR"] = 90.0,
    },

    ChurnProp = {
        ["animDict"] = "anim@heists@narcotics@trash",
        ["animName"] = "idle",
        ["model"] = "prop_old_churn_01",
        ["bone"] = 28422,
        ["x"] = 0.2,
        ["y"] = -0.15,
        ["z"] = -0.90,
        ["xR"] = 0.0,
        ["yR"] = 0.0,
        ["zR"] = 80.0
    },

    MelonProp = {
        ["animDict"] = "anim@heists@box_carry@",
        ["animName"] = "idle",
        ["model"] = "prop_veg_crop_03_cab",
        ["bone"] = 28422,
        ["x"] = -0.01,
        ["y"] = -0.1,
        ["z"] = -0.25,
        ["xR"] = 0.0,
        ["yR"] = 0.0,
        ["zR"] = 0.0,
    },
}