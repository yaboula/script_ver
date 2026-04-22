---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 2,

    -- Job title displayed in the UI
    label = locale('fraud.label'),

    -- Short mission description
    description = locale('fraud.description'),

    -- UI image for the mission
    image = 'fraud.png',

    -- Rewards for completing the mission
    reward = { exp = 110, money = 12500 },

    -- Additional info or lore for the mission
    information = locale('fraud.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('fraud.steps.1'), },
        { label = locale('fraud.steps.2'), },
        { label = locale('fraud.steps.3'), progress = { target = 3 } },
        { label = locale('fraud.steps.4'), },
        { label = locale('fraud.steps.5'), },
    },

    -- Blips
    blips = {
        atm      = { sprite = 76, color = 5, text = locale('fraud.blips.atm') },
        customer = { sprite = 270, color = 5, text = locale('fraud.blips.customer') },
        office   = { sprite = 270, color = 5, text = locale('fraud.blips.office') },
        banker   = { sprite = 270, color = 5, text = locale('fraud.blips.banker') },
    },

    requiredItems = {
        ['atm_hack_device'] = { itemName = 'atm_hack_device', label = 'Atm Hack Device' },
        ['blank_card'] = { itemName = 'blank_card', label = 'Blank Card' },
        ['fake_credit_card'] = { itemName = 'fake_credit_card', label = 'Credit Card' },
    },

    teamSize = { min = 1, max = 1 },

    --[[ Game mechanics and settings ]]
    game = {
        police_alert_chance = 0.2, -- 20% chance to alert police when capturing data

        time_required_to_capture_data = 10,

        atm_locations = {
            {
                coords = vector4(-386.8752, 6046.0938, 31.5017, 318.0056),
                camera = { coords = vector3(-386.532, 6046.516, 32.085), rotation = vector3(-18.0, 0.0, 140.0) },
                ped_spawn = {
                    vector4(-416.9158, 6077.1396, 31.5001, 181.6317),
                    vector4(-384.6700, 6057.9429, 31.5001, 134.0034),
                },
            },
        },

        office_locations = {
            { laptop_location = vector4(1275.10, -1709.90, 54.50, 0.0) },
        },

        banker_locations = {
            vector3(149.80, -1041.60, 29.58),
        },
    },
}
