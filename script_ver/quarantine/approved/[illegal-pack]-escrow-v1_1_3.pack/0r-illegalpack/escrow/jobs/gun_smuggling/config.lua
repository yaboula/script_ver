---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 3,

    -- Job title displayed in the UI
    label = locale('gun_smuggling.label'),

    -- Short mission description
    description = locale('gun_smuggling.description'),

    -- UI image for the mission
    image = 'gun_smuggling.png',

    -- Rewards for completing the mission
    reward = { exp = 170, money = 8500 },

    -- Additional info or lore for the mission
    information = locale('gun_smuggling.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('gun_smuggling.steps.1') },
        { label = locale('gun_smuggling.steps.2') },
        { label = locale('gun_smuggling.steps.3'), },
        { label = locale('gun_smuggling.steps.4') },
        { label = locale('gun_smuggling.steps.5') },
        { label = locale('gun_smuggling.steps.6'), timeLimit = 600, },
    },

    -- Blips
    blips = {
        contact_npc = { sprite = 270, color = 5, text = locale('gun_smuggling.blips.contact_npc') },
        truck       = { sprite = 477, color = 5, text = locale('gun_smuggling.blips.truck') },
        container   = { sprite = 615, color = 5, text = locale('gun_smuggling.blips.container') },
        delivery    = { sprite = 270, color = 5, text = locale('gun_smuggling.blips.delivery') },
    },

    teamSize = { max = 2 },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when container opened

        locations = {
            [1] = {
                npc_location = vector4(-462.9305, -2748.3926, 5.0002, 11.2053),
                truck_spawn_location = vector4(-477.41, -2749.36, 6.03, 45.0),
                trailer_spawn_location = vector4(-469.24, -2757.37, 7.79, 45.0),
                forklift_location = vector4(-47.54, -2423.39, 5.46, 90.0),
                containers = {
                    { coords = vector4(-58.66, -2421.0, 5.0, 90.0), model = 'tr_prop_tr_container_01a', },
                    { coords = vector4(-58.66, -2418.0, 5.0, 90.0), model = 'tr_prop_tr_container_01b', },
                    { coords = vector4(-58.66, -2415.0, 5.0, 90.0), model = 'tr_prop_tr_container_01c', },
                    { coords = vector4(-58.66, -2412.0, 5.0, 90.0), model = 'tr_prop_tr_container_01d', },
                },
            },
        },

        delivery_locations = {
            vector3(33.3357, -2681.2253, 6.0113),
            vector3(666.3427, -2671.6758, 6.0811),
            vector3(1012.1072, -2523.0203, 28.3083),
            vector3(693.9095, -831.9522, 24.3996),
        },

        truck_model = 'packer',
        trailer_model = 'trflat',
        forklift_model = 'forklift',
        fakecontainer_model = 'prop_ld_container',
        npc_model = 's_m_m_trucker_01',
        crate_model = '3fe_lj_woodbox',
        crate_on_trail_model = '3fe_lj_woodbox2',
    },
}
