Config = {
    -- [AUDIT AUD-005] Secure default: avoid unknown external image hosts.
    UseWebServer = false, -- Uses 0r-imagegenerator/images locally.
    EnableMaskFix = true, -- Resmon values may increase due to the cycles contained in it.
    EditCharacter = {
        Enable = true,
        Interaction = {
            TextUI = {
                Enable = true,
                Distance = 4.0,
                Show = function(label)
                    exports["qb-core"]:DrawText(label, "left")
                end,
                Hide = function()
                    exports["qb-core"]:HideText()
                end
            },
            Target = {
                Enable = false,
                Distance = 4.0,
                Zone = 2.5,
                Icon = "fa-solid fa-shirt"
            }
        },
        Areas = { -- Use vector4
            {UsePed = true, PedModel = "s_m_m_doctor_01", Coords = vector4(326.56, -582.98, 43.32, 342.49)}
        }
    },
    ModelSaveType = "modelname", -- number (hash key) or modelname
    UseBackgroundBlur = true,
    CamZoomLevels = {
        {camOffset = 0.7, camHeight = 0.45},
        {camOffset = 0.9, camHeight = 0.25},
        {camOffset = 1.2, camHeight = 0.0},
        {camOffset = 1.5, camHeight = -0.25},
        {camOffset = 0.7, camHeight = -0.95}
    },
    UseDefaultClothImages = {
        Skin = false,
        Hair = false,
        Makeup = false,
        Clothing = false,
        Accessories = false,
        Body = false
    },
    ShowAllPeds = true, -- If it is false, you can only see female characters if your character is female and only male characters if your character is male.
    SetCoordsAfterFinalize = {
        Enable = false,
        Coords = vector4(-1038.1, -2738.23, 20.17, 325.03)
    },
    TeleportWhenCreatingChar = {
        Enable = false,
        Coords = vector4(-1038.1, -2738.23, 20.17, 325.03)
    },
    CharacterFinalized = function()
        -- Write something here
    end,
    ClothStoreOpened = function()
        -- Write something here
        TriggerServerEvent('0r-clothing:loadPlayerSkin:server') -- Don't delete
    end,
    ClothStoreClosed = function()
        -- Write something here
    end,
    GiveClothingMenu = {
        Enable = true,
        Command = "giveclothingmenu",
        RestrictedCommand = "giverestrictedclothingmenu",
        Description = "Give advanced clothing menu",
        RestrictedDescription = "Give restricted clothing menu",
        Group = "admin"
    },
    ShopCategories = {
        character_creation = {
            [1] = {"MalePeds", "FemalePeds", "PedModelInput"},
            [2] = {"FaceOne", "SkinOne", "FaceTwo", "SkinTwo", "FaceThree", "SkinThree", "FaceMix", "SkinMix", "ThirdMix"},
            [3] = {"Nose", "Eyebrows2", "Cheeks", "JawBone", "Chin", "MiscellaneousFeatures", "EyeColor"},
            [4] = {"Blemishes", "Ageing", "Complexion", "SunDamage", "MolesFreckles", "ChestHair", "BodyBlemishes", "AddBodyBlemishes"},
            [5] = {"Eyebrows", "EyebrowColors", "EyebrowHighlightColors", "FacialHairs", "FacialHairsColors", "FacialHairsHighlightColors", "Hairs", "HairsColors", "HairsHighlightColors", "HairFade", "HairTexture"},
            [6] = {"Makeup", "FirstMakeupColor", "SecondMakeupColor", "Blush", "FirstBlushColor", "SecondBlushColor", "Lipstick", "FirstLipstickColor", "SecondLipstickColor"},
            [7] = {"Jacket",  "Vest", "Pants", "Undershirt", "Shoes", "Arms/Gloves"},
            [8] = {"Hat", "Masks", "Watches", "Earrings", "Scarfs/Necklaces", "Decals", "Glasses", "Bracelets", "Bag"}
        },
        clothing = { -- Page 1, 2
            [1] = {"Jacket",  "Vest", "Pants", "Undershirt", "Shoes", "Arms/Gloves"},
            [2] = {"Hat", "Masks", "Watches", "Earrings", "Scarfs/Necklaces", "Decals", "Glasses", "Bracelets", "Bag"}
        },
        barber = { -- Page 1, 2
            [1] = {"ChestHair", "Makeup", "FirstMakeupColor", "SecondMakeupColor", "Blush", "FirstBlushColor", "SecondBlushColor", "Lipstick", "FirstLipstickColor", "SecondLipstickColor"},
            [2] = {"Eyebrows", "EyebrowColors", "EyebrowHighlightColors", "FacialHairs", "FacialHairsColors", "FacialHairsHighlightColors", "Hairs", "HairsColors", "HairsHighlightColors", "HairFade", "HairTexture"}
        },
        tattoo = {"Tattoos"}
    },
    CompareClothes = {
        Enable = true,
        Coords = {
            Cam = vector4(-166.77, -298.42, 39.73, 120.12),
            Peds = {
                [1] = vector4(-168.71, -300.69, 39.73, 301.11),
                [2] = vector4(-169.73, -298.71, 39.73, 292.11)
            }
        }
    },
    CharacterCreationMenuCategories = {
        Normal = {
            Peds = true,
            Face = true,
            FaceFeatures = true,
            Skin = true,
            Hair = true,
            Makeup = true,
            Clothing = true,
            Accessories = true
        },
        Restricted = {
            Peds = false,
            Face = false,
            FaceFeatures = false,
            Skin = true,
            Hair = true,
            Makeup = false,
            Clothing = true,
            Accessories = true
        }
    },
    CashAsItem = { -- For those who use cash as an item
        Enable = false,
        Name = "cashitem"
    },
    Stores = {
        {shopType = 'clothing', coords = vector3(1693.32, 4823.48, 41.06)},
        {shopType = 'clothing', coords = vector3(-712.215881, -155.352982, 37.4151268)},
        {shopType = 'clothing', coords = vector3(-1192.94495, -772.688965, 17.3255997)},
        {shopType = 'clothing', coords = vector3(425.236, -806.008, 28.491)},
        {shopType = 'clothing', coords = vector3(-162.658, -303.397, 38.733)},
        {shopType = 'clothing', coords = vector3(75.950, -1392.891, 28.376)},
        {shopType = 'clothing', coords = vector3(-822.194, -1074.134, 10.328)},
        {shopType = 'clothing', coords = vector3(-1450.711, -236.83, 48.809)},
        {shopType = 'clothing', coords = vector3(4.254, 6512.813, 30.877)},
        {shopType = 'clothing', coords = vector3(615.180, 2762.933, 41.088)},
        {shopType = 'clothing', coords = vector3(1196.785, 2709.558, 37.222)},
        {shopType = 'clothing', coords = vector3(-3171.453, 1043.857, 19.863)},
        {shopType = 'clothing', coords = vector3(-1100.959, 2710.211, 18.107)},
        {shopType = 'clothing', coords = vector3(-1207.65, -1456.88, 4.3784737586975)},
        {shopType = 'clothing', coords = vector3(121.76, -224.6, 53.56)},
        {shopType = 'barber', coords = vector3(-814.3, -183.8, 36.6)},
        {shopType = 'barber', coords = vector3(136.8, -1708.4, 28.3)},
        {shopType = 'barber', coords = vector3(-1282.6, -1116.8, 6.0)},
        {shopType = 'barber', coords = vector3(1931.5, 3729.7, 31.8)},
        {shopType = 'barber', coords = vector3(1212.8, -472.9, 65.2)},
        {shopType = 'barber', coords = vector3(-32.9, -152.3, 56.1)},
        {shopType = 'barber', coords = vector3(-278.1, 6228.5, 30.7)},
        {shopType = 'tattoo', coords = vector3(1322.6, -1651.9, 51.2)},
        {shopType = 'tattoo', coords = vector3(-1153.6, -1425.6, 4.9)},
        {shopType = 'tattoo', coords = vector3(322.1, 180.4, 103.5)},
        {shopType = 'tattoo', coords = vector3(-3170.0, 1075.0, 20.8)},
        {shopType = 'tattoo', coords = vector3(1864.6, 3747.7, 33.0)},
        {shopType = 'tattoo', coords = vector3(-293.7, 6200.0, 31.4)},
        {groupType = "job", group = "police", hideBlip = true, shopType = 'clothing', coords = vector3(422.81, -1010.16, 29.05)},
    },
    Interaction = {
        TextUI = {
            Enable = false,
            Show = function(label)
                exports["qb-core"]:DrawText(label, "left")
            end,
            Hide = function()
                exports["qb-core"]:HideText()
            end
        },
        Target = {
            Enable = true,
            Distance = 4.0,
            Zone = 2.5,
            Icon = "fa-solid fa-shirt"
        }
    },
    AllowedModels = {"mp_m_freemode_01", "mp_f_freemode_01"},
    DefaultClothingVaritaions = {
        ["Hat"] = {
            ["male"] = -1,
            ["female"] = -1
        },
        ["Masks"] = {
            ["male"] = -1,
            ["female"] = -1
        },
        ["Glasses"] = {
            ["male"] = -1,
            ["female"] = -1
        },
        ["Jacket"] = {
            ["male"] = 15,
            ["female"] = 15
        },
        ["Bag"] = {
            ["male"] = -1,
            ["female"] = -1
        },
        ["Hairs"] = {
            ["male"] = 0,
            ["female"] = 0
        },
        ["Shoes"] = {
            ["male"] = 34,
            ["female"] = 34
        },
        ["Pants"] = {
            ["male"] = 14,
            ["female"] = 14
        }
    },
    ClothPriceCurrency = "€",
    ClothPrices = {
        ["Jacket"] = {
            Default = 150,
            Customs = {
                [255] = 500,
                [230] = 500
            },
            Blacklist = {
                [999] = true,
                [1000] = true
            }
        },
        ["Hat"] = {
            Default = 75
        },
        ["Hairs"] = {
            Default = 95
        },
        ["FacialHairs"] = {
            Default = 95
        },
        ["ChestHair"] = {
            Default = 95
        },
        ["Makeup"] = {
            Default = 75
        },
        ["Blush"] = {
            Default = 75
        },
        ["Lipstick"] = {
            Default = 75
        },
        ["Eyebrows"] = {
            Default = 75
        },
        ["Pants"] = {
            Default = 130
        },
        ["Masks"] = {
            Default = 90
        },
        ["Earrings"] = {
            Default = 50
        },
        ["Glasses"] = {
            Default = 65
        },
        ["Decals"] = {
            Default = 45
        },
        ["Undershirt"] = {
            Default = 140
        },
        ["Watches"] = {
            Default = 100
        },
        ["Bags"] = {
            Default = 90
        },
        ["Scarfs/Necklaces"] = { -- Scarfs & Necklaces
            Default = 80
        },
        ["Arms/Gloves"] = { -- Arms & Gloves
            Default = 70
        },
        ["Shoes"] = {
            Default = 135
        },
        ["Bracelets"] = {
            Default = 80
        },
        ["Vest"] = {
            Default = 160
        }
    },
    ShowHUD = function()
    end,
    HideHUD = function()
    end,
    MakeupColors = {
        {r = 153, g = 38, b = 51},
        {r = 197, g = 57, b = 92},
        {r = 188, g = 82, b = 105},
        {r = 184, g = 87, b = 123},
        {r = 167, g = 81, b = 106},
        {r = 176, g = 69, b = 79},
        {r = 128, g = 47, b = 53},
        {r = 164, g = 99, b = 97},
        {r = 193, g = 133, b = 123},
        {r = 204, g = 159, b = 154},
        {r = 199, g = 145, b = 145},
        {r = 172, g = 112, b = 101},
        {r = 174, g = 94, b = 80},
        {r = 167, g = 75, b = 52},
        {r = 179, g = 114, b = 118},
        {r = 201, g = 128, b = 145},
        {r = 238, g = 157, b = 190},
        {r = 230, g = 117, b = 163},
        {r = 224, g = 64, b = 128},
        {r = 181, g = 75, b = 111},
        {r = 111, g = 40, b = 56},
        {r = 78, g = 30, b = 44},
        {r = 170, g = 34, b = 48},
        {r = 223, g = 32, b = 50},
        {r = 207, g = 5, b = 19},
        {r = 232, g = 81, b = 112},
        {r = 219, g = 61, b = 180},
        {r = 194, g = 39, b = 177},
        {r = 160, g = 29, b = 171},
        {r = 113, g = 24, b = 114},
        {r = 111, g = 20, b = 100},
        {r = 83, g = 22, b = 91},
        {r = 107, g = 27, b = 158},
        {r = 24, g = 54, b = 114},
        {r = 26, g = 80, b = 168},
        {r = 28, g = 116, b = 187},
        {r = 34, g = 162, b = 207},
        {r = 41, g = 194, b = 210},
        {r = 36, g = 206, b = 167},
        {r = 40, g = 191, b = 124},
        {r = 26, g = 158, b = 48},
        {r = 16, g = 133, b = 1},
        {r = 110, g = 207, b = 68},
        {r = 199, g = 232, b = 55},
        {r = 223, g = 228, b = 47},
        {r = 255, g = 221, b = 35},
        {r = 250, g = 190, b = 40},
        {r = 245, g = 139, b = 39},
        {r = 255, g = 88, b = 13},
        {r = 192, g = 110, b = 28},
        {r = 248, g = 200, b = 128},
        {r = 251, g = 228, b = 197},
        {r = 247, g = 243, b = 244},
        {r = 179, g = 179, b = 181},
        {r = 144, g = 144, b = 144},
        {r = 86, g = 77, b = 78},
        {r = 23, g = 15, b = 13},
        {r = 87, g = 150, b = 155},
        {r = 77, g = 111, b = 138},
        {r = 25, g = 42, b = 85},
        {r = 159, g = 127, b = 106},
        {r = 131, g = 99, b = 88},
        {r = 110, g = 82, b = 70},
        {r = 62, g = 44, b = 40}
    },
    HairColors = {
        {r = 29, g = 30, b = 32},
        {r = 42, g = 42, b = 44},
        {r = 48, g = 46, b = 49},
        {r = 52, g = 39, b = 30},
        {r = 70, g = 51, b = 34},
        {r = 91, g = 58, b = 39},
        {r = 108, g = 77, b = 57},
        {r = 105, g = 79, b = 62},
        {r = 113, g = 93, b = 69},
        {r = 126, g = 104, b = 83},
        {r = 153, g = 129, b = 93},
        {r = 166, g = 146, b = 109},
        {r = 175, g = 156, b = 114},
        {r = 183, g = 162, b = 99},
        {r = 211, g = 185, b = 128},
        {r = 216, g = 194, b = 145},
        {r = 158, g = 125, b = 90},
        {r = 156, g = 126, b = 90},
        {r = 101, g = 43, b = 32},
        {r = 93, g = 20, b = 13},
        {r = 97, g = 17, b = 10},
        {r = 122, g = 20, b = 16},
        {r = 158, g = 46, b = 26},
        {r = 180, g = 76, b = 41},
        {r = 158, g = 82, b = 50},
        {r = 171, g = 78, b = 44},
        {r = 98, g = 98, b = 98},
        {r = 128, g = 128, b = 128},
        {r = 170, g = 170, b = 170},
        {r = 197, g = 197, b = 198},
        {r = 71, g = 57, b = 83},
        {r = 90, g = 63, b = 108},
        {r = 118, g = 60, b = 119},
        {r = 237, g = 117, b = 225},
        {r = 232, g = 75, b = 144},
        {r = 239, g = 155, b = 189},
        {r = 6, g = 149, b = 157},
        {r = 5, g = 95, b = 130},
        {r = 5, g = 57, b = 114},
        {r = 63, g = 160, b = 109},
        {r = 37, g = 123, b = 96},
        {r = 23, g = 93, b = 85},
        {r = 180, g = 191, b = 52},
        {r = 113, g = 69, b = 10},
        {r = 70, g = 156, b = 21},
        {r = 219, g = 185, b = 88},
        {r = 230, g = 178, b = 0},
        {r = 233, g = 144, b = 2},
        {r = 244, g = 135, b = 50},
        {r = 250, g = 128, b = 87},
        {r = 225, g = 139, b = 88},
        {r = 205, g = 90, b = 61},
        {r = 209, g = 47, b = 36},
        {r = 166, g = 12, b = 2},
        {r = 137, g = 2, b = 6}
    }
}