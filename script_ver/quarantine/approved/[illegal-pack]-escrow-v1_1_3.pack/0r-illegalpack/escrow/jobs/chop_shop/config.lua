---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 1,

    -- Job title displayed in the UI
    label = locale('chop_shop.label'),

    -- Short mission description
    description = locale('chop_shop.description'),

    -- UI image for the mission
    image = 'chop_shop.png',

    -- Rewards for completing the mission
    reward = { exp = 120, money = 6000 },

    -- Additional info or lore for the mission
    information = locale('chop_shop.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('chop_shop.steps.1'), timeLimit = 600, },
        { label = locale('chop_shop.steps.2'), timeLimit = 900, },
        { label = locale('chop_shop.steps.3'), timeLimit = 900, },
        { label = locale('chop_shop.steps.4'), timeLimit = 900, },
    },

    -- Required item(s) to do the mission
    requiredItems = {
        ['WEAPON_DIGISCANNER'] = { itemName = 'WEAPON_DIGISCANNER', label = 'Digi Scanner' },
    },

    -- Blips
    blips = {
        vehicle_location = { sprite = 225, color = 5, text = locale('chop_shop.blips.vehicle_location') },
        drop_off_location = { sprite = 270, color = 5, text = locale('chop_shop.blips.drop_off_location') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.4, -- 40% chance to alert police when stealing a vehicle

        -- Location settings where vehicles can be stolen
        locations           = {
            [1] = {
                vehicle_location = vector4(-462.2772, 641.7559, 144.1884, 47.4927),
                key_locations = {
                    vector3(-475.6673, 635.8160, 144.3836),
                    vector3(-484.4647, 632.1751, 144.3836),
                    vector3(-497.0341, 643.3725, 144.3858),
                    vector3(-476.8703, 647.8550, 144.3866),
                    vector3(-451.6906, 635.5141, 143.1911),
                },
            },
            [2] = {
                vehicle_location = vector4(-710.04, 643.80, 154.83, 170.0),
                key_locations = {
                    vector3(-720.8038, 638.1844, 155.1644),
                    vector3(-704.3148, 628.2702, 155.1604),
                    vector3(-691.9509, 639.9639, 155.1647),
                    vector3(-694.2796, 644.8789, 155.1752),
                    vector3(-700.6077, 646.9736, 155.3706),
                },
            },
        },

        -- The point where the parts will be dismantled and dropped off
        -- Should be at least as many as the number of 'locations'
        drop_off_locations  = {
            { vehicle_lock = vector3(-560.1563, -1687.4324, 19.3006), drop_off = vector3(-555.8652, -1684.7043, 19.5) },
            { vehicle_lock = vector3(-423.9329, -1686.1304, 19.0290), drop_off = vector3(-417.9132, -1685.7708, 19.5) },
            { vehicle_lock = vector3(1731.6963, 3312.0889, 41.2234),  drop_off = vector3(1741.1049, 3318.3652, 41.2234) },
            { vehicle_lock = vector3(2352.0449, 3132.6443, 48.2087),  drop_off = vector3(2350.8103, 3127.9507, 48.2087) },
        },

        -- Vehicle models that can be stolen
        -- Should be at least as many as the number of 'locations'
        vehicle_models      = { 'cheetah', 'emerus', 'pfister811', 't20' },
    },
}
