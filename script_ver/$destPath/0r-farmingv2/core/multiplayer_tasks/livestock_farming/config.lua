return {
    teamSize = {
        min = 1, -- Minimum number of players required to start the task
        max = 4, -- Maximum number of players allowed to start the task
    },

    infoBoxTable = {
        locale("livestock_farming.steps.1"),
        locale("livestock_farming.steps.2"),
        locale("livestock_farming.steps.3"),
        locale("livestock_farming.steps.4"),
        locale("livestock_farming.steps.5"),
    },

    ---@type table<string, BlipConfig>
    --- Task blip configuration
    blips = {
        cow = { sprite = 177, color = 5, scale = 0.8, name = locale("livestock_farming.blips.cow"), },
        truck = { sprite = 853, color = 5, scale = 0.8, name = locale("livestock_farming.blips.truck"), },
        feed = { sprite = 618, color = 5, scale = 0.8, name = locale("livestock_farming.blips.feed"), },
    },

    milkBottleItemName = "milk_bottle", -- Milk bottle item name

    animalFeed = {
        targetModels = { 1700312454, 533342826 }, -- Target model hash values
        hold = {
            model = "prop_haybale_01", -- Model name
            offset = vector3(0.01, -0.02, -0.12), -- Offset
            rotation = vector3(-90.0, 0.0, 0.0), -- Rotation angle
            bone = 28422, -- Bone index
            dict = "anim@heists@box_carry@", -- Animation dictionary
            name = "idle", -- Animation name
            type = "feed", -- Type: feed
        },
        requiredFeedingTimeForMilk = 10, -- Feeding time required to produce milk (seconds)
        maxMilkPerCow = 3,               -- Maximum amount of milk per cow
        milkProp = {
            model = "prop_old_churn_01", -- Model name
            offset = vector3(0.2, -0.15, -0.90), -- Offset
            rotation = vector3(0.0, 0.0, 80.0), -- Rotation angle
            bone = 28422, -- Bone index
            dict = "anim@heists@narcotics@trash", -- Animation dictionary
            name = "idle", -- Animation name
            type = "milk", -- Type: milk
        },
    },

    ---@type LivestockFarmingField[]>
    fields = {
        [1] = {
            cowLocations = {
                {
                    coords = vector4(2266.62, 4893.65, 39.90, 240.85), -- Cow location coords example
                    model = "a_c_cow",                                 -- Cow model
                },
                {
                    coords = vector4(2263.7666, 4890.4160, 39.90, 228.5575), -- Cow location coords example
                    model = "a_c_cow",                                       -- Cow model
                },
                {
                    coords = vector4(2267.2371, 4896.5601, 39.90, 240.85), -- Cow location coords example
                    model = "a_c_cow",                                     -- Cow model
                }
            },
            truckLocation = {
                coords = vector4(2260.34, 4888.05, 40.9, 44.93), -- Truck spawn location coords
                model = "mule3",                                 -- Truck model
            },
            feedBlipLocations = {
                vector3(2279.7319, 4891.0884, 40.4996), -- Feed blip location coords example
            },
        },
    },

    feedMarker = {
        type = 1, -- Marker type
        scale = vector3(2.0, 2.0, 1.0), -- Scale size
        color = { r = 255, g = 229, b = 145, a = 100 }, -- Color (red, green, blue, alpha)
    },
}