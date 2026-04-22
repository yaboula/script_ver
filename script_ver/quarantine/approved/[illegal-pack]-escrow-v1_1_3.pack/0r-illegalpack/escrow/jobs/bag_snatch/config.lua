---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 3,

    -- Job title displayed in the UI
    label = locale('bag_snatch.label'),

    -- Short mission description
    description = locale('bag_snatch.description'),

    -- UI image for the mission
    image = 'bag_snatch.png',

    -- Rewards for completing the mission
    reward = {
        exp = 90,        -- Experience points given
        money = 'Random' -- Random amount of money
    },

    -- Additional info or lore for the mission
    information = locale('bag_snatch.information'),

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('bag_snatch.steps.1'), timeLimit = 900, },
        { label = locale('bag_snatch.steps.2'), timeLimit = 1200, progress = { target = 10 }, },
        { label = locale('bag_snatch.steps.3'), timeLimit = 900, }
    },

    -- Required item(s) to do the mission
    requiredItems = {
        ['crowbar'] = { itemName = 'weapon_crowbar', label = 'Crowbar' }, -- Player must have a crowbar
        ['stolen_bag'] = { itemName = 'stolen_bag', label = 'Stolen Bag' },
    },

    -- Possible loot types from different bags
    loots = {
        -- Junk bags may contain low-value scrap items
        junkBag = {
            maxItems = 3,
            items = {
                { itemName = 'scrapmetal', minCount = 1, maxCount = 3, chance = 0.8, price = 100 },
                { itemName = 'plastic',    minCount = 1, maxCount = 2, chance = 0.6, price = 100 },
                { itemName = 'glass',      minCount = 1, maxCount = 2, chance = 0.5, price = 100 },
                { itemName = 'copperwire', minCount = 1, maxCount = 1, chance = 0.2, price = 500 }
            }
        },

        -- Medical bags contain useful healing items
        medicalBag = {
            maxItems = 2,
            items = {
                { itemName = 'bandage',    minCount = 1, maxCount = 3, chance = 0.7, price = 100 },
                { itemName = 'painkiller', minCount = 1, maxCount = 2, chance = 0.5, price = 100 },
                { itemName = 'medkit',     minCount = 1, maxCount = 1, chance = 0.2, price = 100 },
                { itemName = 'adrenaline', minCount = 1, maxCount = 1, chance = 0.1, price = 500 }
            }
        },

        -- Military bags contain valuable or dangerous items
        militaryBag = {
            maxItems = 3,
            items = {
                { itemName = 'ammo-9',        minCount = 1,  maxCount = 2,  chance = 0.7,  price = 100 },
                { itemName = 'ammo-9',        minCount = 10, maxCount = 20, chance = 0.4,  price = 50 },
                { itemName = 'weapon_pistol', minCount = 1,  maxCount = 1,  chance = 0.01, price = 2000 }
            }
        },
    },

    blips = {
        parking_lot = { sprite = 270, color = 5, text = locale('bag_snatch.blips.parking_lot') },
    },

    --[[ Game mechanics and settings ]]
    game = {
        -- Chance that a police alert is triggered when smashing a window (50%)
        police_alert_chance = .50,

        -- Locations of parking lots where the job takes place
        parking_lots = {
            [1] = {
                -- Parking lot point radius value
                distance = 75.0,
                -- Center point of the parking lot
                center = vector3(658.3257, 637.8564, 128.9108),
                -- Car locations and headings
                places = {
                    vector4(662.1374, 626.6833, 128.5, 71.5),
                    vector4(660.6771, 623.4366, 128.5, 71.5),
                    vector4(657.06, 613.62, 128.5, 247.56),
                    vector4(651.13, 597.24, 128.5, 71.50),
                    vector4(648.81, 590.97, 128.5, 250.77),
                    vector4(642.35, 587.51, 128.5, 158.85),
                    vector4(625.11, 593.44, 128.5, 339.82),
                    vector4(611.87, 598.69, 128.5, 338.43),
                    vector4(605.62, 601.10, 128.5, 160.0),
                    vector4(591.98, 618.42, 128.5, 69.0),
                    vector4(594.21, 625.50, 128.50, 72.0),
                    vector4(607.14, 621.14, 128.5, 250.90),
                    vector4(613.0, 637.95, 128.5, 250.0),
                    vector4(621.10, 630.82, 128.5, 67.61),
                    vector4(618.51, 624.61, 128.5, 70.0),
                    vector4(615.26, 614.41, 128.5, 70.0),
                },
            },
            [2] = {
                -- Parking lot point radius value
                distance = 50.0,
                -- Center point of the parking lot
                center = vector3(343.2067, 3408.9004, 36.5082),
                -- Car locations and headings
                places = {
                    vector4(366.82, 3411.60, 36.08, 200.0),
                    vector4(362.46, 3409.58, 36.08, 203.60),
                    vector4(326.41, 3425.69, 36.15, 75.17),
                    vector4(325.52, 3423.11, 36.22, 257.16),
                    vector4(322.71, 3418.34, 36.32, 78.77),
                    vector4(320.80, 3410.49, 36.40, 257.30),
                    vector4(319.10, 3405.42, 36.43, 73.75),
                    vector4(308.20, 3384.41, 36.09, 123.0),
                    vector4(310.94, 3380.20, 36.10, 302.77),
                    vector4(323.48, 3390.73, 36.10, 297.25),
                },
            },
        },

        -- Bag delivery coords after job
        bag_deliveries = {
            vector4(1918.6519, 587.2681, 175.3672, 211.2927),
            vector4(1212.0997, 1892.8168, 76.9666, 75.2928),
            vector4(774.8378, 2171.1377, 51.3649, 136.0765),
            vector4(731.9585, 2575.5059, 74.3219, 242.8156),
            vector4(698.4141, 2889.8049, 49.1334, 306.1892),
        },

        -- Allowed vehicle models and the bag placement offset on them
        vehicles = {
            { model = 'alpha' },
            { model = 'bestiagts' },
            { model = 'buffalo' },
            { model = 'cypher' },
            { model = 'asterope' },
            { model = 'tailgater' },
            { model = 'primo2' }
        },

        -- Objects to be spawned inside the vehicle
        bagObjects = {
            { model = 'vw_prop_vw_backpack_01a', offset = vector3(0.0, -0.05, -0.1), rotation = vector3(25, 0, 0) }
        },
    },
}
