---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]
---@type Job
return {
    -- Minimum required level to start the job
    level = 1,

    -- Job title displayed in the UI
    label = locale('money_laundering.label'),

    -- Short mission description
    description = locale('money_laundering.description'),

    -- UI image for the mission
    image = 'laundering.png',

    -- Rewards for completing the mission
    reward = { exp = 10, money = 'Random' },

    -- Additional info or lore for the mission
    information = locale('money_laundering.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('money_laundering.steps.1') },
    },

    -- Blips
    blips = {
        lab_location = { sprite = 270, color = 5, text = locale('money_laundering.blips.lab_location') }
    },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when washing money

        -- If you have an MLO map and want to use it!
        -- Set useShellInterior to false, and you must also adjust all ``coords`` values for ``scene`` scenes to match your map.
        -- We do not provide support for this. You must set it up yourself !

        useShellInterior = true, -- true = use shell interior, false = use mlo interior

        -- Lab locations can be changed in: 'escrow/jobs/counterfeit_money/config.lua' file
        shell_interior_lab_locations = {},

        mlo_interior_lab_locations = {
            vector3(198.9336, 2459.0754, 55.6908), -- MLO interior location 1 - [bamboozled barnlab]
        },

        washingScene = {
            -- By default 'Black money' is required and the reward is 'Cash'.
            -- If you want to add extra items, you can add them.
            requiredItems = {},
            rewardItems = {},

            -- Max number of cash washes at one time
            maxWashesAtOnce = 5000,
            -- Daily limit for cash washing, it will reset after server/script restart or 24 hours
            dailyLimit = 25000,
            -- Swap rate for cash washing, <1 = more cash, >1 = less cash>
            swapRate = 1.0,

            coords = {
                mlo_interior = {},
                shell_interior = {
                    {
                        coords = vector3(1122.51, -3194.5, -40.4),
                        offset = vector3(0.0, 0.0, 0.0),
                        rotation = vector3(0.0, 0.0, 90.0)
                    },
                    {
                        coords = vector3(1125.55, -3194.5, -40.4),
                        offset = vector3(0.0, 0.0, 0.0),
                        rotation = vector3(0.0, 0.0, 90.0)
                    },
                },
            },
        }
    }
}
