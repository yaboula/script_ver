---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 2,

    -- Job title displayed in the UI
    label = locale('illegal_delivery.label'),

    -- Short mission description
    description = locale('illegal_delivery.description'),

    -- UI image for the mission
    image = 'illegal_delivery.png',

    -- Rewards for completing the mission
    reward = { exp = 150, money = 7500 },

    -- Additional info or lore for the mission
    information = locale('illegal_delivery.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('illegal_delivery.steps.1') },
        { label = locale('illegal_delivery.steps.2'), progress = { target = 10 }, },
        { label = locale('illegal_delivery.steps.3'), progress = { target = 10 }, },
        { label = locale('illegal_delivery.steps.4'), timeLimit = 600 },
    },

    -- Blips
    blips = {
        location = { sprite = 270, color = 5, text = locale('illegal_delivery.blips.location') },
        vehicle = { sprite = 67, color = 5, text = locale('illegal_delivery.blips.vehicle') },
        delivery = { sprite = 270, color = 5, text = locale('illegal_delivery.blips.delivery') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when a delivery is made

        locations = {
            { vehicle_location = vector4(-70.67, -2230.22, 7.63, 272.20), get_box_zone = vector3(-84.61, -2231.28, 6.81), },
        },

        drop_off_points = {
            vector4(175.2805, -1279.5958, 29.26, 0.0),
            vector4(1228.86, -725.41, 60.80, 0.0),
            vector4(1222.79, -697.04, 60.80, 0.0),
            vector4(1221.39, -668.83, 63.49, 0.0),
            vector4(1206.88, -620.22, 66.44, 0.0),
            vector4(1203.69, -598.96, 68.06, 0.0),
            vector4(1200.84, -575.72, 69.14, 0.0),
            vector4(1204.48, -557.80, 69.62, 0.0),
            vector4(1241.99, -565.69, 69.66, 0.0),
            vector4(1241.38, -601.70, 69.43, 0.0),
            vector4(1251.20, -621.31, 69.41, 0.0),
            vector4(1265.51, -648.17, 67.92, 0.0),
            vector4(1271.05, -683.56, 66.03, 0.0),
            vector4(1265.37, -703.04, 64.57, 0.0),
            vector4(76.20, -1948.22, 21.17, 0.0),
            vector4(85.96, -1959.71, 21.12, 0.0),
            vector4(118.42, -1920.99, 21.32, 0.0),
            vector4(72.24, -1939.14, 21.37, 0.0),
            vector4(23.56, -1896.17, 22.96, 0.0),
            vector4(-4.75, -1872.09, 24.15, 0.0),
            vector4(-42.02, -1792.18, 27.83, 0.0),
            vector4(29.99, -1854.56, 24.07, 0.0),
            vector4(54.33, -1872.97, 22.81, 0.0),
            vector4(98.02, 3682.01, 39.74, 0.0),
            vector4(70.43, 3753.41, 39.77, 0.0),
            vector4(15.22, 3688.84, 40.13, 0.0),
            vector4(68.09, 3693.25, 40.66, 0.0),
            vector4(41.57, 3705.39, 40.52, 0.0),
            vector4(78.08, 3732.46, 40.32, 0.0),
            vector4(-1002.18, -1218.45, 5.76, 0.0),
        },
    },
}
