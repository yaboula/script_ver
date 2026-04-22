---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 1,

    -- Job title displayed in the UI
    label = locale('cocaine_job.label'),

    -- Short mission description
    description = locale('cocaine_job.description'),

    -- UI image for the mission
    image = 'cocaine.png',

    -- Rewards for completing the mission
    reward = { exp = 50, money = 'Random' },

    -- Additional info or lore for the mission
    information = locale('cocaine_job.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('cocaine_job.steps.1') },
        { label = locale('cocaine_job.steps.2'), timeLimit = 60 * 30, },
    },

    -- Blips
    blips = {
        lab_location = { sprite = 270, color = 5, text = locale('cocaine_job.blips.lab_location') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when unpacking/cutting/packing coke

        -- If you have an MLO map and want to use it!
        -- Set useShellInterior to false, and you must also adjust all ``coords`` values for ``scene`` scenes to match your map.
        -- We do not provide support for this. You must set it up yourself !

        useShellInterior = true, -- true = use shell interior, false = use mlo interior

        shell_interior = {
            coords = vector3(1093.6, -3196.6, -38.99841),
            entrance = vector4(1088.5780, -3190.3882, -39.5, 185.2210),
            exitPoint = vector3(1088.6932, -3187.5713, -38.9935),
        },

        shell_interior_lab_locations = {
            vector3(1002.5323, -1527.9481, 30.8359),
            vector3(173.5297, 2778.8118, 46.0773),
            vector3(2318.8870, 2553.4263, 47.6905),
        },

        mlo_interior_lab_locations = {
            vector3(198.9336, 2459.0754, 55.6908), -- MLO interior location 1 - [bamboozled barnlab]
        },

        unpackingScene = {
            requiredItems = {
                { label = 'Powdered Milk', itemName = 'powdered_milk', count = 1 },
            },
            rewardItems = {
                { label = 'Unpacked Coke', itemName = 'unpacked_coke', count = 1 },
            },
            coords = {
                mlo_interior = {
                    {
                        coords = vector3(193.4815, 2470.8132, 55.9118),
                        offset = vector3(0.4, 0.57, -0.65),
                        rotation = vector3(0.0, 0.0, 160.0)
                    },
                },
                shell_interior = {
                    {
                        coords = vector3(1088.61, -3195.95, -38.99),
                        offset = vector3(0.09, 0.57, -0.65),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                    {
                        coords = vector3(1097.01, -3195.63, -38.99),
                        offset = vector3(0.09, 0.57, -0.65),
                        rotation = vector3(0.0, 0.0, -180.0)
                    },
                },
            },
        },

        cutterScene = {
            requiredItems = {
                { label = 'Unpacked Coke', itemName = 'unpacked_coke', count = 1 },
            },
            rewardItems = {
                { label = 'Cutted Coke', itemName = 'cutted_coke', count = 1 },
            },
            coords = {
                mlo_interior = {
                    {
                        coords = vector3(198.25, 2465.91, 55.91),
                        offset = vector3(-1.910000, -0.320000, -0.640000),
                        rotation = vector3(0.0, 0.0, 288.0)
                    }
                },
                shell_interior = {
                    {
                        coords = vector3(1090.27, -3194.92, -38.99),
                        offset = vector3(-1.91, -0.32, -0.64),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                    {
                        coords = vector3(1095.41, -3194.92, -38.99),
                        offset = vector3(-1.91, -0.32, -0.64),
                        rotation = vector3(0.0, 0.0, 0.0)
                    },
                    {
                        coords = vector3(1093.03, -3196.58, -38.99),
                        offset = vector3(-1.91, -0.32, -0.64),
                        rotation = vector3(0.0, 0.0, -180.0)
                    },
                    {
                        coords = vector3(1099.54, -3194.33, -38.99),
                        offset = vector3(-1.91, -0.32, -0.64),
                        rotation = vector3(0.0, 0.0, -90.0)
                    },
                },
            },
        },

        packingScene = {
            requiredItems = {
                { label = 'Cutted Coke', itemName = 'cutted_coke', count = 1 },
            },
            rewardItems = {
                { label = 'Packed Coke', itemName = 'packed_coke', count = 1 },
            },
            coords = {
                mlo_interior = {
                    {
                        coords = vector3(194.5000, 2462.1899, 55.9100),
                        offset = vector3(-7.66, 2.17, -1.00),
                        rotation = vector3(0.0, 0.0, 291.6)
                    }
                },
                shell_interior = {
                    {
                        coords = vector3(1101.245, -3198.82, -38.99),
                        offset = vector3(-7.66, 2.17, -1.0),
                        rotation = vector3(0.0, 0.0, 0.0),
                    },
                    {
                        coords = vector3(1087.3849, -3198.4241, -38.99),
                        offset = vector3(-7.4, 2.0, -1.0),
                        rotation = vector3(0.0, 0.0, -90.0),
                    },
                },
            },
        },
    },
}
