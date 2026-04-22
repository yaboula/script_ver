---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 1,

    -- Job title displayed in the UI
    label = locale('meth_job.label'),

    -- Short mission description
    description = locale('meth_job.description'),

    -- UI image for the mission
    image = 'meth_lab.png',

    -- Rewards for completing the mission
    reward = { exp = 50, money = 'Random' },

    -- Additional info or lore for the mission
    information = locale('meth_job.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('meth_job.steps.1') },
        { label = locale('meth_job.steps.2'), timeLimit = 60 * 30, },
    },

    -- Blips
    blips = {
        lab_location = { sprite = 270, color = 5, text = locale('meth_job.blips.lab_location') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when packaging meth

        -- If you have an MLO map and want to use it!
        -- Set useShellInterior to false, and you must also adjust all ``coords`` values for ``scene`` scenes to match your map.
        -- We do not provide support for this. You must set it up yourself !

        useShellInterior = true, -- true = use shell interior, false = use mlo interior

        shell_interior = {
            coords = vector3(1009.5, -3196.6, -38.99682),
            entrance = vector4(997.7157, -3198.7317, -37.3937, 347.3677),
            exitPoint = vector3(996.89, -3200.64, -36.39),
        },

        shell_interior_lab_locations = {
            vector3(2200.7668, 3318.1777, 46.9442),
            vector3(1569.6664, -2130.1208, 78.3301),
            vector3(916.6868, 3576.9949, 33.5550),
        },

        mlo_interior_lab_locations = {
            vector3(198.9336, 2459.0754, 55.6908), -- MLO interior location 1 - [bamboozled barnlab]
        },

        cookScene = {
            requiredItems = {
                { label = 'Ammonia', itemName = 'ammonia', count = 1 },
                { label = 'Sacid',   itemName = 'sacid',   count = 1 },
            },
            rewardItems = {
                { label = 'Cooked Meth', itemName = 'cooked_meth', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1005.74, -3200.39, -38.52),
                        offset = vector3(5.0, 2.0, -0.40),
                        rotation = vector3(0.0, 0.0, 0.0),
                    },
                },
            },
        },

        hammerScene = {
            requiredItems = {
                { label = 'Cooked Meth', itemName = 'cooked_meth', count = 1 },
            },
            rewardItems = {
                { label = 'Breaked Meth', itemName = 'breaked_meth', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1016.44, -3194.87, -38.99),
                        offset = vector3(-3.16, -1.75, -1.0),
                        rotation = vector3(0.0, 0.0, 0.0),
                    }
                },
            },
        },

        packingScene = {
            requiredItems = {
                { label = 'Breaked Meth', itemName = 'breaked_meth', count = 1 },
            },
            rewardItems = {
                { label = 'Packed Meth', itemName = 'packed_meth', count = 1 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1012.07, -3194.95, -38.99),
                        offset = vector3(-4.71, -1.52, -1.0),
                        rotation = vector3(0.0, 0.0, 0.0),
                    },
                },
            },
        },
    },
}
