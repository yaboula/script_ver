---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 1,

    -- Job title displayed in the UI
    label = locale('weed_job.label'),

    -- Short mission description
    description = locale('weed_job.description'),

    -- UI image for the mission
    image = 'weed_job.png',

    -- Rewards for completing the mission
    reward = { exp = 50, money = 'Random' },

    -- Additional info or lore for the mission
    information = locale('weed_job.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('weed_job.steps.1') },
        { label = locale('weed_job.steps.2'), timeLimit = 60 * 30, },
    },

    -- Blips
    blips = {
        lab_location = { sprite = 270, color = 5, text = locale('weed_job.blips.lab_location') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when unpacking/cutting/packing weed

        -- If you have an MLO map and want to use it!
        -- Set useShellInterior to false, and you must also adjust all ``coords`` values for ``scene`` scenes to match your map.
        -- We do not provide support for this. You must set it up yourself !

        useShellInterior = true, -- true = use shell interior, false = use mlo interior

        shell_interior = {
            coords = vector3(1051.491, -3196.536, -39.14842),
            entrance = vector4(1065.9543, -3183.2986, -39.1635, 86.7188),
            exitPoint = vector3(1066.3561, -3183.5149, -39.1636),
        },

        shell_interior_lab_locations = {
            vector3(2566.7854, 4273.9097, 41.9890),
            vector3(1546.7220, 2166.5020, 78.7224),
        },

        mlo_interior_lab_locations = {
            vector3(198.9336, 2459.0754, 55.6908), -- MLO interior location 1 - [bamboozled barnlab]
        },

        gatheringScene = {
            requiredItems = {
                { label = 'Plant spray', itemName = 'plant_spray', count = 1, notRemove = true },
            },
            rewardItems = {
                { label = 'Unpacked Weed', itemName = 'unpacked_weed', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1057.61, -3196.85, -39.16),
                        offset = vector3(-0.9, 0.1, -1.18),
                        rotation = vector3(0.0, 0.0, 90.0)
                    },
                    {
                        coords = vector3(1060.54, -3193.35, -39.16),
                        offset = vector3(-0.9, 0.1, -1.18),
                        rotation = vector3(0.0, 0.0, 180.0)
                    },
                    {
                        coords = vector3(1056.25, -3192.8, -39.16),
                        offset = vector3(-0.9, 0.1, -1.18),
                        rotation = vector3(0.0, 0.0, 270.0)
                    },
                    {
                        coords = vector3(1053.94, -3195.96, -39.16),
                        offset = vector3(-0.9, 0.1, -1.18),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                },
            },
        },

        packingScene = {
            requiredItems = {
                { label = 'Unpacked Weed', itemName = 'unpacked_weed', count = 1 },
            },
            rewardItems = {
                { label = 'Packed Weed', itemName = 'packed_weed', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1039.2, -3205.11, -38.17),
                        offset = vector3(-0.76, 0.87, -0.98),
                        rotation = vector3(0.0, 0.0, 90.0)
                    },
                    {
                        coords = vector3(1037.52, -3205.37, -38.17),
                        offset = vector3(0.76, 0.70, -0.98),
                        rotation = vector3(0.0, 0.0, -90.0)
                    },
                    {
                        coords = vector3(1034.67, -3205.44, -38.17),
                        offset = vector3(-0.76, 0.87, -0.98),
                        rotation = vector3(0.0, 0.0, 90.0)
                    },
                    {
                        coords = vector3(1032.95, -3205.49, -38.17),
                        offset = vector3(0.76, 0.70, -0.98),
                        rotation = vector3(0.0, 0.0, -90.0)
                    },
                },
            },
        },

        rollingScene = {
            requiredItems = {
                { label = 'Packed Weed', itemName = 'packed_weed', count = 1 },
            },
            rewardItems = {
                { label = 'Rolled Weed', itemName = 'rolled_weed', count = 3 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1036.3536, -3203.8726, -38.1734),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                    {
                        coords = vector3(1034.15, -3203.81, -38.17),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                },
            },
        },
    },
}
