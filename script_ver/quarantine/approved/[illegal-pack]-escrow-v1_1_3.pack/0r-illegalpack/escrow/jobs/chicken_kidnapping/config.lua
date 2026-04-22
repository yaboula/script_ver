---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 2,

    -- Job title displayed in the UI
    label = locale('chicken_kidnapping.label'),

    -- Short mission description
    description = locale('chicken_kidnapping.description'),

    -- UI image for the mission
    image = 'chicken_kidnapping.png',

    -- Rewards for completing the mission
    reward = {
        exp = 150,    -- Experience points given
        money = 15000 -- Money
    },

    teamSize = {
        min = 1, -- Minimum number of players required
        max = 2, -- Maximum number of players allowed
    },

    -- Additional info or lore for the mission
    information = locale('chicken_kidnapping.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('chicken_kidnapping.steps.1'), timeLimit = 600,  progress = { current = 0, target = 1 }, },
        { label = locale('chicken_kidnapping.steps.2'), timeLimit = 900,  progress = { current = 0, target = 5 }, },
        { label = locale('chicken_kidnapping.steps.3'), timeLimit = 1200, progress = { current = 0, target = 10 }, },
        { label = locale('chicken_kidnapping.steps.4'), timeLimit = 600, },
    },

    -- Blips
    blips = {
        vehicle_spawn = { sprite = 318, color = 5, text = locale('chicken_kidnapping.blips.vehicle_spawn') },
        farm = { sprite = 270, color = 1, text = locale('chicken_kidnapping.blips.farm') },
        delivery = { sprite = 318, color = 2, text = locale('chicken_kidnapping.blips.delivery') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        -- Chance that a police alert is triggered (10%)
        police_alert_chance = .10,

        -- Vehicle model
        vehicle_model = 'burrito3',

        -- Cage model
        cage_model = 'horoz_cage',

        -- Enemy model
        enemy_model = 'g_m_y_mexgoon_03',

        cageVehicleAttachOffsets = {
            vector3(-0.8, -0.35, -0.05),
            vector3(-0.4, -0.35, -0.05),
            vector3(0.0, -0.35, -0.05),
            vector3(0.4, -0.35, -0.05),
            vector3(0.8, -0.35, -0.05),

            vector3(-0.8, -1.0, -0.05),
            vector3(-0.4, -1.0, -0.05),
            vector3(0.0, -1.0, -0.05),
            vector3(0.4, -1.0, -0.05),
            vector3(0.8, -1.0, -0.05),
        },

        areas = {
            [1] = {
                -- Vehicle spawn location
                vehicle_spawn = vector4(1091.27, 2635.77, 37.80, 0.0),
                vehicle_spawn_radius = 60.0,

                -- Farm location (where chickens and enemies are)
                farm_center = vector3(1460.0917, 1113.3566, 114.3272),
                farm_radius = 50.0,

                -- Enemy positions around the farm
                enemy_positions = {
                    vector4(1454.0, 1114.0, 114.33, 45.0),
                    vector4(1458.0, 1118.0, 114.33, 135.0),
                    vector4(1452.0, 1118.0, 114.33, 315.0),
                    vector4(1460.0, 1114.0, 114.33, 225.0),
                    vector4(1456.0, 1112.0, 114.33, 0.0),
                },

                -- Chicken cage positions around the farm
                cage_positions = {
                    vector4(1469.609, 1135.771, 113.540, 0.0),
                    vector4(1469.609, 1135.187, 113.540, 0.0),
                    vector4(1469.609, 1134.594, 113.540, 0.0),
                    vector4(1469.609, 1133.979, 113.540, 0.0),
                    vector4(1469.609, 1133.356, 113.540, 0.0),
                    vector4(1469.609, 1133.356, 113.971, 0.0),
                    vector4(1469.609, 1133.979, 113.971, 0.0),
                    vector4(1469.609, 1134.594, 113.971, 0.0),
                    vector4(1469.609, 1135.187, 113.971, 0.0),
                    vector4(1469.609, 1135.771, 113.971, 0.0),
                },

                -- Delivery point (same as vehicle spawn)
                delivery_point = vector3(1091.27, 2635.77, 37.80),
                delivery_radius = 10.0,
            },
        },
    },
}
