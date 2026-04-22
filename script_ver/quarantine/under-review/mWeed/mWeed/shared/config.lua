Config = {}
Config.Framework = 'qb'                -- esx, qb, oldqb, oldesx, autodetect
Config.InteractionHandler = 'drawtext' -- qb-target, ox_target, drawtext or custom
Config.TextUIHandler = 'default'       -- default, esx_textui, qb_default_textui, custom
Config.Logo = './assets/images/logo.png'
Config.Minventory = false
Config.ActionTimes = { --  time for how long it will take to procedures
    ["dig"] = 10000,
    ["fertilizer"] = 10000,
    ["planting_seed"] = 10000,
    ["closing_area"] = 10000,
    ["watering"] = 10000,
    ["floundering"] = 10000,
    ["harvesting"] = 10000,
    ["destroying"] = 3000,
    ["grinding_weed"] = 10000,
    ["rolling_joint"] = 10000,
}

Config.Items = {
    -- if you change the item name don't forget to change image name located at mWeed\html\assets\item_images
    ["indica_seed"] = {               -- dont change the key
        name = "indica_seed",         -- item name
        label = "Indica Seed",        -- label displayed in ui
    },
    ["sativa_seed"] = {               -- dont change the key
        name = "sativa_seed",         -- item name
        label = "Sativa Seed",        -- label displayed in ui
    },
    ["indica_weed"] = {               -- dont change the key
        name = "indica_weed",         -- item name
        label = "Indica Weed",        -- label displayed in ui
    },
    ["sativa_weed"] = {               -- dont change the key
        name = "sativa_weed",         -- item name
        label = "Sativa Weed",        -- label displayed in ui
    },
    ["fertilizer"] = {                -- dont change the key
        name = "fertilizer",          -- item name
        label = "Fertilizer",         -- label displayed in ui
    },
    ["quality_fertilizer"] = {        -- dont change the key
        name = "quality_fertilizer",  -- item name
        label = "Quality Fertilizer", -- label displayed in ui
    },
    ["spray"] = {                     -- dont change the key
        name = "spray",               -- item name
        label = "Spray",              -- label displayed in ui
    },
    ["water"] = {                     -- dont change the key
        name = "water",               -- item name
        label = "Water",              -- label displayed in ui
    },
    ["grubber"] = {                   -- dont change the key
        name = "grubber",             -- item name
        label = "Grubber",            -- label displayed in ui
    },
    ["raw_paper"] = {                 -- dont change the key
        name = "raw_paper",           -- item name
        label = "Raw Paper",          -- label displayed in ui
    },
    ["grinder"] = {                   -- dont change the key
        name = "grinder",             -- item name
        label = "Grinder",            -- label displayed in ui
    },
    ["indica_joint"] = {              -- dont change the key
        name = "indica_joint",        -- item name
        label = "Indica Joint",       -- label displayed in ui
    },
    ["sativa_joint"] = {              -- dont change the key
        name = "sativa_joint",        -- item name
        label = "Sativa Joint",       -- label displayed in ui
    },
    ["lemon_haze_joint"] = {          -- dont change the key
        name = "lemon_haze_joint",    -- item name
        label = "Lemon Haze Joint",   -- label displayed in ui
    },
    ["purple_haze_joint"] = {         -- dont change the key
        name = "purple_haze_joint",   -- item name
        label = "Purple Haze Joint",  -- label displayed in ui
    },
    ["grinded_indica"] = {            -- dont change the key
        name = "grinded_indica",      -- item name
        label = "Grinded Indica",     -- label displayed in ui
    },
    ["grinded_sativa"] = {            -- dont change the key
        name = "grinded_sativa",      -- item name
        label = "Grinded Sativa",     -- label displayed in ui
    },
}


local effectActive = false
function StopEffect()
    SetPedIsDrunk(PlayerPedId(), false)
    SetPedMotionBlur(PlayerPedId(), false)
    ResetPedMovementClipset(PlayerPedId())
    AnimpostfxStopAll()
    ShakeGameplayCam("DRUNK_SHAKE", 0.0)
    SetTimecycleModifierStrength(0.0)
    effectActive = false
end

function StartEffect()
    if effectActive then
        return
    end
    SetTimecycleModifier("spectator5")
    SetPedMotionBlur(PlayerPedId(), true)
    SetPedMovementClipset(PlayerPedId(), "MOVE_M@QUICK", true)
    SetPedIsDrunk(PlayerPedId(), true)
    AnimpostfxPlay("DrugsMichaelAliensFight", 10000001, true)
    ShakeGameplayCam("DRUNK_SHAKE", 3.0)
    effectActive = true
end

Config.UseableItems = {
    [Config.Items["indica_joint"].name] = function()
        StartEffect()
        Wait(30000)
        StopEffect()
    end,
    [Config.Items["sativa_joint"].name] = function()
        StartEffect()
        Wait(30000)
        StopEffect()
    end,
    [Config.Items["lemon_haze_joint"].name] = function()
        StartEffect()
        Wait(30000)
        StopEffect()
    end,
    [Config.Items["purple_haze_joint"].name] = function()
        StartEffect()
        Wait(30000)
        StopEffect()
    end
}


Config.GeneralSettings = {
    decayTime = function() -- time to reduce watering and floundering status
        return math.random(30000, 60000)
    end,
    revivalRate = 60, -- revival rate if the player did not use Quality Fertilizer and water or floundering status drops to 0 (higher number means more luck) (set the number between 1-100)
    rewardItems = {
        ["grinded_sativa"] = {
            maxamount = 4,
            items = {
                {
                    name = Config.Items['sativa_joint'].name,
                    label = Config.Items['sativa_joint'].label,
                },
                {
                    name = Config.Items['lemon_haze_joint'].name,
                    label = Config.Items['lemon_haze_joint'].label,
                },
                {
                    name = Config.Items['purple_haze_joint'].name,
                    label = Config.Items['purple_haze_joint'].label,
                },
            }
        },
        ["grinded_indica"] = {
            maxamount = 4,
            items = {
                {
                    name = Config.Items['indica_joint'].name,
                    label = Config.Items['indica_joint'].label,
                }
            },
        },
    }, -- items to be given after the player rolls the weed
}

Config.GrinderLocations = {
    positions = {
        vector4(2195.38, 5605.13, 52.55, 338.89),
    },
    object = {
        model = 'bkr_prop_weed_table_01a',
        drawTextLabel = 'Press ~g~E~w~ to open grinder menu', -- Adjust this if Config.InteractionHandler is set to drawtext
    },
    blip = {                                                  -- https://wiki.rage.mp/index.php?title=Blips
        enable = true,
        label = 'Weed Grinder',
        sprite = 140,
        color = 2,
        scale = 0.7,
    },
}

Config.Weeds = {
    helpText = 'PRESS E TO OPEN WEED MENU',
    interactionKey = 38, -- https://docs.fivem.net/docs/game-references/controls/
    blip = {             -- https://wiki.rage.mp/index.php?title=Blips
        enable = true,
        label = 'Weed Area',
        sprite = 140,
        color = 2,
        scale = 0.7,
    },
    areas = {
        {
            mainLocation = vector3(2226.325, 5579.23, 53.94217),
            radius = 20.0,
            cameraPos = vector3(2205.533, 5578.192, 56.82452),
            cameraRot = vector3(-10.0, 0.0, -95.0),
            cameraFov = 50.0,
            weedLocations = { -- Add max 10 location here
                block_1 = {
                    {
                        vector3(2237.667, 5578.614, 52.083),            -- weed location
                        vector4(2237.752, 5577.169, 52.89048, 356.5438) -- player location
                    },
                    {
                        vector3(2235.212, 5578.641, 52.10983),          -- weed location
                        vector4(2235.073, 5577.47, 52.90747, 4.846458), -- player location
                    },
                    {
                        vector3(2231.506, 5578.81, 52.06324),          -- weed location
                        vector4(2231.448, 5577.551, 53.8493, 2.081742) -- player location
                    },
                    {
                        vector3(2228.236, 5579.092, 52.96056),          -- weed location
                        vector4(2228.004, 5577.751, 52.71479, 356.5081) -- player location
                    },
                    {
                        vector3(2224.821, 5579.415, 51.92968),       -- weed location
                        vector4(2224.447, 5578.036, 52.71, 355.6273) -- player location
                    },
                    {
                        vector3(2220.727, 5579.431, 51.95013),          -- weed location
                        vector4(2220.305, 5578.225, 52.71844, 357.3872) -- player location
                    },
                    {
                        vector3(2217.234, 5579.825, 51.96421),          -- weed location
                        vector4(2216.769, 5578.458, 52.71166, 356.5759) -- player location
                    },
                    {
                        vector3(2215.013, 5579.878, 51.94916),         -- weed location
                        vector4(2214.498, 5578.52, 52.70631, 358.9686) -- player location
                    },
                    {
                        vector3(2212.534, 5579.975, 52.95681),          -- weed location
                        vector4(2212.118, 5578.754, 52.72284, 354.5237) -- player location
                    },
                    {
                        vector3(2210.1, 5580.03, 53.08),              -- weed location
                        vector4(2210.72, 5578.96, 52.77142, 358.6247) -- player location
                    },

                },
                block_2 = {                                             -- Add max 10 location here
                    {
                        vector3(2237.537, 5576.39, 52.02205),           -- weed location
                        vector4(2237.508, 5575.084, 52.77503, 0.865274) -- player location
                    },
                    {
                        vector3(2235.143, 5576.343, 52.05054),          -- weed location
                        vector4(2234.759, 5575.077, 52.84046, 1.054227) -- player location
                    },
                    {
                        vector3(2232.755, 5576.411, 52.04098),          -- weed location
                        vector4(2232.309, 5575.198, 53.82559, 351.2079) -- player location
                    },
                    {
                        vector3(2229.601, 5576.558, 51.93465),          -- weed location
                        vector4(2229.297, 5575.488, 52.70596, 355.2654) -- player location
                    },
                    {
                        vector3(2226.528, 5576.881, 51.86523),         -- weed location
                        vector4(2226.481, 5575.375, 53.6587, 357.7014) -- player location
                    },
                    {
                        vector3(2223.891, 5577.121, 52.84274),         -- weed location
                        vector4(2223.59, 5575.706, 52.63181, 357.0569) -- player location
                    },
                    {
                        vector3(2220.981, 5577.19, 52.84929),           -- weed location
                        vector4(2220.665, 5575.795, 52.61718, 357.4456) -- player location
                    },
                    {
                        vector3(2217.333, 5577.528, 52.84986),          -- weed location
                        vector4(2216.958, 5576.164, 53.58484, 1.367346) -- player location
                    },
                    {
                        vector3(2214.168, 5577.616, 52.81589),           -- weed location
                        vector4(2213.742, 5576.198, 52.5746, 0.06138936) -- player location
                    },
                    {
                        vector3(2211.767, 5577.926, 52.84692),          -- weed location
                        vector4(2211.398, 5576.497, 52.61296, 356.4259) -- player location
                    }


                },
                block_3 = { -- Add max 10 location here
                    {

                        vector3(2237.684, 5573.995, 52.88002),          -- weed location
                        vector4(2237.621, 5575.171, 52.78402, 186.4957) -- player location
                    },
                    {
                        vector3(2235.641, 5574.042, 52.9408),           -- weed location
                        vector4(2235.456, 5575.144, 53.82026, 174.7843) -- player location
                    },
                    {
                        vector3(2233.207, 5574.09, 52.99046),           -- weed location
                        vector4(2233.212, 5575.336, 53.86678, 176.2571) -- player location
                    },
                    {
                        vector3(2230.793, 5574.41, 52.91023),           -- weed location
                        vector4(2230.884, 5575.592, 53.78828, 175.6559) -- player location
                    },
                    {
                        vector3(2228.767, 5574.638, 52.83927),          -- weed location
                        vector4(2228.822, 5575.743, 53.71123, 179.4265) -- player location
                    },
                    {
                        vector3(2225.961, 5574.613, 52.78807),          -- weed location
                        vector4(2226.275, 5575.958, 53.66665, 182.9873) -- player location
                    },
                    {
                        vector3(2223.312, 5574.968, 52.7311),           -- weed location
                        vector4(2223.521, 5576.187, 53.65931, 181.7096) -- player location
                    },
                    {
                        vector3(2220.36, 5574.943, 52.72416),           -- weed location
                        vector4(2220.084, 5576.336, 53.63123, 181.3605) -- player location
                    },
                    {
                        vector3(2217.816, 5575.143, 52.72402),          -- weed location
                        vector4(2217.875, 5576.315, 53.59023, 175.3284) -- player location
                    },
                    {
                        vector3(2213.862, 5575.252, 52.67818),          -- weed location
                        vector4(2214.192, 5576.636, 53.59779, 183.9125) -- player location
                    }
                },
            },
        },
    }
}

Config.Dealer = {
    position = vector4(-56.63, -1228.747, 27.77, 42.51),
    name = 'MARK BULLSEYE',
    npc = {
        model = 's_m_y_dealer_01',
        drawTextLabel = 'Press ~g~E~w~ to open dealer', -- Adjust this if Config.InteractionHandler is set to drawtext
    },
    blip = {                                            -- https://wiki.rage.mp/index.php?title=Blips
        enable = true,
        label = 'Weed Dealer',
        sprite = 140,
        color = 2,
        scale = 0.7,
    },
    buyableItems = {
        {
            name = Config.Items["indica_seed"].name,
            label = Config.Items["indica_seed"].label,
            price = 2,
            info = 'A cannabis seed that provide indica weed and indica joint.',
        },
        {
            name = Config.Items["sativa_seed"].name,
            label = Config.Items["sativa_seed"].label,
            price = 3,
            info =
            'A cannabis seed that provide sativa weed and by chance sativa joint lemon haze joint, purple haze joint.',
        },
        {
            name = Config.Items["fertilizer"].name,
            label = Config.Items["fertilizer"].label,
            price = 3,
            info = 'Normal quality fertilizer that needed for seed planting.',
        },
        {
            name = Config.Items["quality_fertilizer"].name,
            label = Config.Items["quality_fertilizer"].label,
            price = 7,
            info = 'Quality fertilizer that even if the water and floundering bar empty will save the plant. ',
        },
        {
            name = Config.Items["spray"].name,
            label = Config.Items["spray"].label,
            price = 2,
            info = 'A spray that used in weed growth process to reduce floundering.',
        },
        {
            name = Config.Items["water"].name,
            label = Config.Items["water"].label,
            price = 2,
            info = 'A normal water that for watering the plant.',
        },
        {
            name = Config.Items["grubber"].name,
            label = Config.Items["grubber"].label,
            price = 1,
            info = 'A grubber that used for weed planting process on digging and closing the dirt.',
        },
        {
            name = Config.Items["raw_paper"].name,
            label = Config.Items["raw_paper"].label,
            price = 1,
            info =
            'A paper that used for rolling a joint process. Every 1g weed will use x4 RAW Paper. 1 Package contains x20 paper. ',
        },
        {
            name = Config.Items["grinder"].name,
            label = Config.Items["grinder"].label,
            price = 1,
            info =
            'A grinder that used for grinding weeds. You need this item to grind your weed and gain grinded weed for rolling a joint process.'
        },
    },
    sellableItems = {
        {
            name = Config.Items["indica_joint"].name,
            label = Config.Items["indica_joint"].label,
            price = 2,
        },
        {
            name = Config.Items["sativa_joint"].name,
            label = Config.Items["sativa_joint"].label,
            price = 3,
        },
        {
            name = Config.Items["lemon_haze_joint"].name,
            label = Config.Items["lemon_haze_joint"].label,
            price = 6,
        },
        {
            name = Config.Items["purple_haze_joint"].name,
            label = Config.Items["purple_haze_joint"].label,
            price = 8,
        },
    },
}

Config.Notifications = {
    ["YOU_DONT_HAVE_ITEM"] = "You don't have %s",
    ["DONT_NEED_WATER"] = "The plant doesn't need water",
    ["DONT_NEED_FLOUNDER"] = "The plant doesn't need floundering",
    ["HAS_NOT_GROWN"] = "The plant has not grown yet",
    ["CANT_CARRY"] = "Your inventory is full",
    ["ROLL_WEED_SUCCESS"] = "You succesfully roll the weed.",
    ["GRIND_WEED_SUCCESS"] = "You succesfully grind the weed.",
    ["ITEM_SELL_FAIL"] = "You don't have enough item to sell",
    ["YOU_DONT_HAVE_MONEY"] = "You don't have enough money",
    ["DIGGING_DIRT"] = "You are diggin the dirt.",
    ["POURING_FERTILIZER"] = "You are pouring the fertilizer to plant area.",
    ["PLANTING_SEED"] = "You are planting the seed to plant area.",
    ["CLOSING_AREA"] = "You are closing the plant area.",
    ["WATERING_WEED"] = "You are watering the weed.",
    ["FLOUNDERING_WEED"] = "You are floundering the weed.",
    ["HARVESTING_WEED"] = "You are harvesting the weed.",
    ["DESTROYING_WEED"] = "You are destroying the weed.",
    ["GRINDING_WEED"] = "You are grinding the weeds.",
    ["ROLLING_JOINT"] = "You are rolling the joint.",
    ["PLANT_DEAD"] = "The plant died",
    ["RECEIVED"] = "You received %s",
}

Config.Translation = {
    ["DEALER"] = {
        ["TITLE"] = "DEALER",
        ["WEED_INGREDIENTS"] = 'WEED INGREDIENTS',
        ["SELL_WEEDS"] = "SELL WEEDS",
        ["BUY_INGREDIENTS"] = "BUY INGREDIENTS",
        ["BUY_WEEDS_DESC"] =
        "Welcome {0}, here is some materials that you can use it to produce your own drugs or you can sell your drugs to me.",
        ["SELL_WEEDS_DESC"] = "Hello {0}, here is the weeds that you can sell it tome for fair prices.",
        ["INVENTORY"] = "INVENTORY",
        ["INFO"] = "INFO",
        ["ITEM_INFO"] = "You have “ <span>{0}</span> “ {1} in your inventory.",
        ["ADD_ALL"] = "ADD ALL",
        ["HOVER_INFO"] = "Hover on item to see how much you it on your inventoy",
        ["HOVER_INFO_2"] = "Hover on item to see the info",
        ["YOUR_CART"] = "YOUR CART",
        ["YOUR_DRUGS"] = "YOUR DRUGS",
        ["TOTAL"] = "Total - $ {0}",
        ["PAYMENT_METHOD"] = "You can only pay with cash",
        ["VIEW"] = "You can view how much drug in your inventory down below.",
        ["BUY"] = "BUY",
        ["SELL"] = "SELL",
    },
    ["GRINDER"] = {
        ["TITLE"] = "WEED GRINDING",
        ["GRIND_WEEDS"] = "GRIND WEEDS",
        ["GRIND_WEEDS_TITLE"] = "Grind Your Weeds",
        ["GRIND_WEEDS_DESC"] =
        "You need to grind your weeds to roll a joint. Grind the weed and you will gain 1g grinded weed.",
        ["CONGRATS"] = "CONGRATS",
        ["SUCCESS_MSG"] = "You have succesfully produce joints.",
        ["ROLL"] = "ROLL A JOINT",
        ["ROLL_DESC"] = "Every 1g grinded weed and 4 paper of Raw will provide you a 4 Joint.",
        ["ROLL_JOINTS"] = "ROLL THE JOINTS",
        ["GRINDED_WEEDS"] = "GRINDED WEEDS",
        ["RAW_PAPER"] = "RAW PAPER",
    },
    ["WEED"] = {
        ["TITLE"] = "WEED PLANTING",
        ["POUR"] = "POUR THE FERTILIZER",
        ["PUT_SEED"] = "PUT SEED",
        ["CLOSE_AREA"] = "CLOSE THE AREA",

        ["DIG"] = "DIG THE DIRT",
        ["PROGRESS_DESC_1"] = "You need to dig the dirt to open a seed area for the weed plant.",
        ["PROGRESS_DESC_2"] = "You need to pour the fertilizer to plant area to make your seed grow proper.",
        ["PROGRESS_DESC_3"] = "You need to put the weed seed to plant area.",
        ["PROGRESS_DESC_4"] = "For the last step just use grubber to close the plant area.",
        ["GROWTH"] = "GROWTH",
        ["PLANT_WEED"] = "PLANT WEED",
        ["PLANT_PROCESS"] = "PLANT PROCESS",
        ["WEED_FARM"] = "WEED FARM",
        ["SELECT_FIELD"] = "Select a field from right side to start.",
        ["FLOUNDERING"] = "FLOUNDERING",
        ["WATER"] = "WATER",
        ["STEP"] = "STEP {0}",
        ["WARNING"] = "Are you sure to delete this plant",
        ["YES"] = "YES",
        ["NO"] = "NO",
    },
}
