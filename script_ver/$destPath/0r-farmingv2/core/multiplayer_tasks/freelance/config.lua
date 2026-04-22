return {

    requiredLevel = 1,              -- Task level, used for task progress and unlock

    requiredJobNames = nil, -- Job names required to start the task => nil means no job requirement => Example: {"farmer", "miner"} or "farmer"

    teamSize = {
        min = 1, -- Minimum number of players required to start the task
        max = 4, -- Maximum number of players allowed to start the task
    },

    timeLimit = 900, -- Task time limit (seconds)

    -- Info box displayed when task starts
    infoBoxTable = {
        locale("freelance.steps.1"), -- Get tractor and seeder
        locale("freelance.steps.2"), -- Seed with seeder
        locale("freelance.steps.3"), -- Water crops
        locale("freelance.steps.4"), -- Wait for crop growth
        locale("freelance.steps.5"), -- Harvest with harvester
        locale("freelance.steps.6"), -- Deliver harvested bales
    },

    ---@type table<string, BlipConfig>
    -- Task blip configuration
    blips = {
        field             = { sprite = 237, color = 5, scale = 0.8, name = locale("freelance.blips.field"), },
        tractor           = { sprite = 846, color = 5, scale = 0.8, name = locale("freelance.blips.tractor"), },
        harvester         = { sprite = 270, color = 5, scale = 0.8, name = locale("freelance.blips.harvester"), },
        trailer           = { sprite = 479, color = 5, scale = 0.8, name = locale("freelance.blips.trailer"), },
        seeder            = { sprite = 270, color = 5, scale = 0.8, name = locale("freelance.blips.seeder"), },
        point             = { sprite = 270, color = 0, scale = 0.4, name = locale("freelance.blips.point"), },
        dropHarvestedBale = { sprite = 270, color = 0, scale = 0.8, name = locale("freelance.blips.dropHarvestedBale"), },
    },

    wateringCan = {
        itemName = "watering_can", -- Watering can item name
    },

    detachTrailerKey = "G", -- Key to detach trailer from tractor

    ---@type table<string, CropConfig>
    -- Crop configuration for farm tasks
    crops = {
        ["wheat"] = {
            label = locale("freelance.crop.wheat"), -- Wheat
            growthTime = 30, -- Growth time
            harvestAmount = 3, -- Harvest amount
            seedItem = "wheat_seed", -- Seed item
            harvestItem = "wheat", -- Harvest item
            model = "prop_veg_crop_06", -- Model used for crop in world
            harvestedBaleModel = "prop_haybale_03", -- Model used for harvested bale in world
        },
        ["rose"] = {
            label = locale("freelance.crop.rose"), -- Rose
            growthTime = 30,
            harvestAmount = 3,
            seedItem = "rose_seed",
            harvestItem = "rose",
            model = "prop_veg_crop_rose",
            harvestedBaleModel = "prop_haybale_rose",
        },
        ["green"] = {
            label = locale("freelance.crop.green"), -- Green crop
            growthTime = 30,
            harvestAmount = 3,
            seedItem = "green_seed",
            harvestItem = "green",
            model = "prop_veg_crop_green",
            harvestedBaleModel = "prop_haybale_green",
        },
        ["daisy"] = {
            label = locale("freelance.crop.daisy"), -- Daisy
            growthTime = 30,
            harvestAmount = 3,
            seedItem = "daisy_seed",
            harvestItem = "daisy",
            model = "prop_veg_crop_daisy",
            harvestedBaleModel = "prop_haybale_green",
        },
        ["poppy"] = {
            label = locale("freelance.crop.poppy"), -- Poppy
            growthTime = 30,
            harvestAmount = 3,
            seedItem = "poppy_seed",
            harvestItem = "poppy",
            model = "prop_veg_crop_poppy",
            harvestedBaleModel = "prop_haybale_green",
        },
    },

    ---@type FreelanceField[]
    -- Farm area configuration
    fields = {
        [1] = {
            center = vector3(2522.7273, 4369.6699, 39.0057),            -- Area center coordinates
            radius = 30,                                                -- Blip radius
            rotation = 45.0,                                            -- Square shape rotation angle
            maxPoints = 49,                                             -- Max planting points
            dropHarvestedBaleCoords = vector3(2412.05, 4989.32, 45.25), -- Drop-off coordinates for harvested bales

            tractor = {
                model = "tractor2",                                -- Tractor model
                locations = {
                    [1] = vector4(2513.26, 4398.51, 37.41, 230.0), -- Tractor spawn coordinates
                },
            },
            harvester = {
                model = "tractor3",                                -- Harvester model
                locations = {
                    [1] = vector4(2505.40, 4394.40, 37.21, 230.0), -- Harvester spawn coordinates
                },
            },
            trailer = {
                model = "baletrailer",                             -- Trailer model
                locations = {
                    [1] = vector4(2501.21, 4387.72, 37.83, 230.0), -- Trailer spawn coordinates
                },
            },
            seeder = {
                model = -1106934735,                               -- Seeder model
                locations = {
                    [1] = vector4(2510.36, 4401.49, 37.22, 230.0), -- Seeder spawn coordinates
                },
            },
        },
    },
}