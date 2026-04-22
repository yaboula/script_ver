return {
    requiredLevel     = 1,   -- Task level, used for task progress and unlock conditions

    requiredJobNames  = nil, -- Job names required to start the task => nil means no job requirement => Example: {"farmer", "miner"} or "farmer"

    teamSize          = {
        min = 1, -- Minimum number of players required to start the task
        max = 4, -- Maximum number of players allowed to start the task
    },

    timeLimit         = 900, -- Task time limit (seconds)

    -- Info box displayed when task starts
    infoBoxTable      = {
        locale("melon_pumpkin.steps.1"),
        locale("melon_pumpkin.steps.2"),
        locale("melon_pumpkin.steps.3"),
        locale("melon_pumpkin.steps.4"),
        locale("melon_pumpkin.steps.5"),
        locale("melon_pumpkin.steps.6"),
    },

    ---@type table<string, BlipConfig>
    -- Task blip configuration
    blips             = {
        field = { sprite = 237, color = 5, scale = 0.8, name = locale("melon_pumpkin.blips.field"), },          -- Field
        point = { sprite = 270, color = 0, scale = 0.4, name = locale("melon_pumpkin.blips.point"), },          -- Planting point
        deliveryVehicle = { sprite = 326, color = 5, scale = 0.8, name = locale("melon_pumpkin.blips.delivery_vehicle"), }, -- Delivery vehicle
    },

    wateringCan       = {
        itemName = "watering_can", -- Watering can item name
    },

    holdObjectOffsets = {
        vector3(-0.8, -0.25, -0.13),
        vector3(-0.4, -0.25, -0.13),
        vector3(0.0, -0.25, -0.13),
        vector3(0.4, -0.25, -0.13),
        vector3(0.8, -0.25, -0.13),

        vector3(-0.8, -0.70, -0.13),
        vector3(-0.4, -0.70, -0.13),
        vector3(0.0, -0.70, -0.13),
        vector3(0.4, -0.70, -0.13),
        vector3(0.8, -0.70, -0.13),

        vector3(-0.8, -1.15, -0.13),
        vector3(-0.4, -1.15, -0.13),
        vector3(0.0, -1.15, -0.13),
        vector3(0.4, -1.15, -0.13),
        vector3(0.8, -1.15, -0.13),
    },

    ---@type table<string, CropConfig>
    -- Crop configuration
    crops             = {
        ["melon"] = { -- Melon
            label = locale("melon_pumpkin.crop.melon"),           -- Crop name
            growthTime = 5,                                        -- Growth time
            seedItem = "melon_seed",                               -- Seed item
            harvestItem = "melon",                                 -- Harvest item
            seedModel = "0r_sapling",                              -- Seed model
            growthModel = "0r_melon",                              -- Growth model
            attachOffset = vector3(-0.01, 0.35, 0.15),            -- Attach offset
            spawnOffset = vector3(0.0, 0.0, -0.005),              -- Spawn offset
            sellPrice = 20,                                        -- Sell price
        },
        ["pumpkin"] = { -- Pumpkin
            label = locale("melon_pumpkin.crop.pumpkin"),         -- Crop name
            growthTime = 5,                                        -- Growth time
            seedItem = "pumpkin_seed",                             -- Seed item
            harvestItem = "pumpkin",                               -- Harvest item
            seedModel = "0r_sapling",                              -- Seed model
            growthModel = "prop_veg_crop_03_pump",                 -- Growth model
            attachOffset = vector3(0.0200, 0.35, -0.1200),        -- Attach offset
            spawnOffset = vector3(0.0, 0.0, 0.0),                 -- Spawn offset
            sellPrice = 20,                                        -- Sell price
        },
        ["watermelon"] = { -- Watermelon
            label = locale("melon_pumpkin.crop.watermelon"),      -- Crop name
            growthTime = 5,                                        -- Growth time
            seedItem = "watermelon_seed",                          -- Seed item
            harvestItem = "watermelon",                            -- Harvest item
            seedModel = "0r_sapling",                              -- Seed model
            growthModel = "prop_veg_crop_03_cab",                  -- Growth model
            attachOffset = vector3(0.0200, 0.35, -0.1200),        -- Attach offset
            spawnOffset = vector3(0.0, 0.0, 0.0),                 -- Spawn offset
            sellPrice = 20,                                        -- Sell price
        },
    },

    ---@type MelonPumpkinField[]
    -- Field area configuration
    fields            = {
        [1] = {
            center = vector3(2874.1814, 4657.3740, 48.3337), -- Field center coordinates
            radius = 40,                                     -- Blip radius
            maxPoints = 49,                                  -- Max planting points
            rotation = 195.0,                                -- Field rotation angle

            deliveryVehicle = {
                model = "youga",                                    -- Delivery vehicle model
                location = vector4(2889.48, 4672.78, 48.33, 180.0), -- Vehicle spawn point
            },
        },
    },
}