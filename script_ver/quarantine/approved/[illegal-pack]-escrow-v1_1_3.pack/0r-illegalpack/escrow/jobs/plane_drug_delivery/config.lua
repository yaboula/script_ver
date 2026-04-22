---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 4,

    -- Job title displayed in the UI
    label = locale('plane_drug_delivery.label'),

    -- Short mission description
    description = locale('plane_drug_delivery.description'),

    -- UI image for the mission
    image = 'plane_drug_delivery.png',

    -- Rewards for completing the mission
    reward = {
        exp = 180,    -- Experience points given
        money = 18000 -- Money
    },

    teamSize = { min = 1, max = 2 }, -- Minimum and maximum team size

    -- Additional info or lore for the mission
    information = locale('plane_drug_delivery.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('plane_drug_delivery.steps.1'), timeLimit = 600 },
        { label = locale('plane_drug_delivery.steps.2'), timeLimit = 900,  progress = { target = 20 } },
        { label = locale('plane_drug_delivery.steps.3'), timeLimit = 1800, progress = { target = 15 } },
        { label = locale('plane_drug_delivery.steps.4'), timeLimit = 600 },
    },

    -- Blips
    blips = {
        airfield = { sprite = 423, color = 5, text = locale('plane_drug_delivery.blips.airfield') },
        plane = { sprite = 423, color = 3, text = locale('plane_drug_delivery.blips.plane') },
        loading_zone = { sprite = 478, color = 1, text = locale('plane_drug_delivery.blips.loading_zone') },
        drop_point = { sprite = 478, color = 2, text = locale('plane_drug_delivery.blips.drop_point') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        -- Chance that a police alert is triggered (15%)
        police_alert_chance = .15,

        -- Plane model
        plane_model = 'dodo',

        -- Drop detection settings
        drop_radius = 80.0,        -- Horizontal radius for drop point detection
        drop_altitude_min = 80.0,  -- Minimum altitude for valid drop
        drop_altitude_max = 300.0, -- Maximum altitude for valid drop

        areas = {
            [1] = {
                -- Plane spawn location (Sandy Shores Airfield)
                plane_spawn = vector4(1729.82, 3282.56, 41.90, 195.0),

                -- Drug loading zone (near plane spawn)
                loading_zone = vector3(1721.822, 3307.205, 40.3),
                loading_radius = 3.5,

                -- Return point (near plane spawn)
                return_point = vector3(1739.5852, 3283.3594, 41.0973),
                return_radius = 50.0,

                -- Air drop points (sequential route with ~200-400m spacing)
                drop_points = {
                    { coords = vector3(238.9040, 3579.2627, 266.5644),   delivered = false }, -- 1.
                    { coords = vector3(24.2945, 4377.7490, 293.6981),    delivered = false }, -- 2.
                    { coords = vector3(-1364.2001, 4461.4707, 230.0593), delivered = false }, -- 3.
                    { coords = vector3(-1957.5815, 4826.5850, 205.9479), delivered = false }, -- 4.
                    { coords = vector3(-1631.3026, 5451.3149, 174.4949), delivered = false }, -- 5.
                    { coords = vector3(-875.6447, 6036.0103, 230.8152),  delivered = false }, -- 6.
                    { coords = vector3(209.6408, 7392.0435, 267.7325),   delivered = false }, -- 7.
                    { coords = vector3(1875.6199, 6617.0020, 242.7901),  delivered = false }, -- 8.
                    { coords = vector3(2561.8896, 6154.0659, 330.7857),  delivered = false }, -- 9.
                    { coords = vector3(2952.0833, 5322.6401, 218.3350),  delivered = false }, -- 10.
                    { coords = vector3(3673.9976, 4966.4751, 128.7964),  delivered = false }, -- 11.
                    { coords = vector3(3948.5034, 4636.5459, 103.1278),  delivered = false }, -- 12.
                    { coords = vector3(4064.5173, 4217.3394, 68.7843),   delivered = false }, -- 13.
                    { coords = vector3(3133.0432, 3648.3328, 214.5813),  delivered = false }, -- 14.
                    { coords = vector3(2490.4656, 3467.3149, 150.6525),  delivered = false }, -- 15.
                },
            },
            [2] = {
                -- Plane spawn location (Sandy Shores Airfield)
                plane_spawn = vector4(1750.34, 3288.51, 41.91, 200.11),

                -- Drug loading zone (near plane spawn)
                loading_zone = vector3(1739.5996, 3315.2007, 40.3),
                loading_radius = 3.5,

                -- Return point (near plane spawn)
                return_point = vector3(1739.5852, 3283.3594, 41.0973),
                return_radius = 50.0,

                -- Air drop points (sequential route with ~200-400m spacing)
                drop_points = {
                    { coords = vector3(238.9040, 3579.2627, 266.5644),   delivered = false }, -- 1.
                    { coords = vector3(24.2945, 4377.7490, 293.6981),    delivered = false }, -- 2.
                    { coords = vector3(-1364.2001, 4461.4707, 230.0593), delivered = false }, -- 3.
                    { coords = vector3(-1957.5815, 4826.5850, 205.9479), delivered = false }, -- 4.
                    { coords = vector3(-1631.3026, 5451.3149, 174.4949), delivered = false }, -- 5.
                    { coords = vector3(-875.6447, 6036.0103, 230.8152),  delivered = false }, -- 6.
                    { coords = vector3(209.6408, 7392.0435, 267.7325),   delivered = false }, -- 7.
                    { coords = vector3(1875.6199, 6617.0020, 242.7901),  delivered = false }, -- 8.
                    { coords = vector3(2561.8896, 6154.0659, 330.7857),  delivered = false }, -- 9.
                    { coords = vector3(2952.0833, 5322.6401, 218.3350),  delivered = false }, -- 10.
                    { coords = vector3(3673.9976, 4966.4751, 128.7964),  delivered = false }, -- 11.
                    { coords = vector3(3948.5034, 4636.5459, 103.1278),  delivered = false }, -- 12.
                    { coords = vector3(4064.5173, 4217.3394, 68.7843),   delivered = false }, -- 13.
                    { coords = vector3(3133.0432, 3648.3328, 214.5813),  delivered = false }, -- 14.
                    { coords = vector3(2490.4656, 3467.3149, 150.6525),  delivered = false }, -- 15.
                },
            },
        },
    },
}
