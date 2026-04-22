---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]
---@type Job
return {
    -- Minimum required level to start the job
    level = 1,

    -- Job title displayed in the UI
    label = locale('counterfeit_money.label'),

    -- Short mission description
    description = locale('counterfeit_money.description'),

    -- UI image for the mission
    image = 'counterfeit_money.png',

    -- Rewards for completing the mission
    reward = {
        exp = 50,
        money = 'Random'
    }, -- Black money is handled below

    -- Additional info or lore for the mission
    information = locale('counterfeit_money.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('counterfeit_money.steps.1'), },
        { label = locale('counterfeit_money.steps.2'), timeLimit = 60 * 30, }
    },

    -- Blips (optional)
    blips = {
        lab_location = { sprite = 500, color = 3, text = locale('counterfeit_money.blips.lab_location') }
    },

    -- Game mechanics and settings
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when packing counterfeit money

        -- If you have an MLO map and want to use it!
        -- Set useShellInterior to false, and you must also adjust all ``coords`` values for ``scene`` scenes to match your map.
        -- We do not provide support for this. You must set it up yourself !

        useShellInterior = true, -- true = use shell interior, false = use mlo interior

        shell_interior = {
            coords = vector3(1121.897, -3195.338, -40.4025),
            entrance = vector4(1137.7310, -3196.8601, -39.6657, 80.7380),
            exitPoint = vector3(1138.0, -3198.96, -39.68)
        },

        shell_interior_lab_locations = {
            vector3(84.04, -1551.96, 29.6),
            vector3(-1083.1752, -1262.0634, 5.5935),
        },

        mlo_interior_lab_locations = {
            vector3(198.9336, 2459.0754, 55.6908), -- MLO interior location 1 - [bamboozled barnlab]
        },

        placePaperScene = {
            requiredItems = {
                { label = 'Money Sheet', itemName = 'money_sheet', count = 1 },
            },
            rewardItems = {
                { label = 'Uncutted Money', itemName = 'uncutted_money', count = 8 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1134.33, -3197.23, -39.67),
                        offset = vector3(-1.0, 1.0, -1.0),
                        rotation = vector3(0.0, 0.0, 180.0)
                    },
                    {
                        coords = vector3(1132.94, -3197.27, -39.67),
                        offset = vector3(-1.0, 1.0, -1.0),
                        rotation = vector3(0.0, 0.0, 180.0)
                    },
                    {
                        coords = vector3(1131.37, -3197.28, -39.67),
                        offset = vector3(-1.0, 1.0, -1.0),
                        rotation = vector3(0.0, 0.0, 180.0)
                    },
                    {
                        coords = vector3(1129.88, -3197.29, -39.67),
                        offset = vector3(-1.0, 1.0, -1.0),
                        rotation = vector3(0.0, 0.0, 180.0)
                    },
                    {
                        coords = vector3(1128.52, -3197.31, -39.67),
                        offset = vector3(-1.0, 1.0, -1.0),
                        rotation = vector3(0.0, 0.0, 180.0)
                    },
                },
            }
        },

        cuttingScene = {
            requiredItems = {
                { label = 'Uncutted Money', itemName = 'uncutted_money', count = 8 },
            },
            rewardItems = {
                { label = 'Cutted Money', itemName = 'cutted_money', count = 16 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1122.41, -3197.88, -40.39),
                        offset = vector3(2.29, 0.66, -0.6),
                        rotation = vector3(0.0, 0.0, 180.0),
                    },
                },
            }
        },

        packingScene = {
            requiredItems = {
                { label = 'Cutted Money', itemName = 'cutted_money', count = 16 },
            },
            rewardItems = {
                { label = 'Black Money', itemName = Config.DirtyMoney.itemName, count = 16 },
            },
            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1116.66, -3195.75, -40.4),
                        offset = vector3(-0.8, 0.9, -0.59),
                        rotation = vector3(0.0, 0.0, 90.0)
                    },
                    {
                        coords = vector3(1116.71, -3194.42, -40.4),
                        offset = vector3(-0.8, 0.95, -0.59),
                        rotation = vector3(0.0, 0.0, 90.0)
                    },
                },
            }
        }
    }
}
