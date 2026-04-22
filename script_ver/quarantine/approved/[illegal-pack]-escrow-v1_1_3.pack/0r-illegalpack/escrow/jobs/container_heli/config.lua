---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 5,

    -- Job title displayed in the UI
    label = locale('container_heli.label'),

    -- Short mission description
    description = locale('container_heli.description'),

    -- UI image for the mission
    image = 'container_heli.png',

    -- Rewards for completing the mission
    reward = {
        exp = 200,    -- Experience points given
        money = 25000 -- Money
    },

    teamSize = { min = 1, max = 1, },

    -- Additional info or lore for the mission
    information = locale('container_heli.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('container_heli.steps.1'), timeLimit = 900, },
        { label = locale('container_heli.steps.2'), timeLimit = 1800, },
        { label = locale('container_heli.steps.3'), timeLimit = 1800, },
    },

    -- Blips
    blips = {
        area = { sprite = 270, color = 5, text = locale('container_heli.blips.area') },
        container = { sprite = 478, color = 1, text = locale('container_heli.blips.container') },
        delivery = { sprite = 270, color = 2, text = locale('container_heli.blips.delivery') },
        heli = { sprite = 43, color = 5, text = locale('container_heli.blips.heli') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        -- Chance that a police alert is triggered (10%)
        police_alert_chance = .10,

        -- Heli model
        heli_model = 'skylift',

        -- Container model
        container_model = 'prop_container_ld_d',

        areas = {
            [1] = {
                -- Heli spawn location (open area)
                heli_spawn = vector4(1114.81, -3142.48, 5.5, 270.20),

                -- Container positions (6 containers)
                container_positions = {
                    vector4(1114.223, -3045.113, 16.153, 90.0),
                    vector4(1114.108, -3041.490, 16.153, 90.0),
                    vector4(1128.462, -3031.092, 16.153, 90.0),
                    vector4(1128.609, -3025.906, 16.153, 90.0),
                },

                -- Delivery location for containers
                delivery_point = vector3(2840.8608, -1447.6238, 40.5677),
                delivery_radius = 60.0,
            },
            [2] = {
                -- Heli spawn location (open area)
                heli_spawn = vector4(1158.48, -3080.15, 5.5, 292.78),

                -- Container positions (6 containers)
                container_positions = {
                    vector4(1114.223, -3045.113, 16.153, 90.0),
                    vector4(1114.108, -3041.490, 16.153, 90.0),
                    vector4(1128.462, -3031.092, 16.153, 90.0),
                    vector4(1128.609, -3025.906, 16.153, 90.0),
                },

                -- Delivery location for containers
                delivery_point = vector3(3311.0664, -90.3273, 51.5395),
                delivery_radius = 60.0,
            },
        },
    },
}
