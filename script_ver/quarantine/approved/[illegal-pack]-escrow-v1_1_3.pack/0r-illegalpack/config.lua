--[[
    All script settings are found and edited in this file.
    Make sure to configure everything properly before running the script.
]]

Config = {}

---[[ The images folder path of your inventory script ]]
--- So that item names and images will match your inventory - images only PNG !
Config.InventoryImagesFolder = 'ox_inventory/web/images/'

--[[ Menu Command ]]
Config.IllegalMenu = {
    -- Use new kibra tablet - if true, the menu can only be opened with the kibra tablet. If false, it can be opened with keybind or command as well.
    useTabletApp = false,

    -- Command to open the illegal menu.
    openWithCommand = {
        active = true, -- Set to true to enable command-based menu opening.
        command = 'illegalmenu',
    },
    -- Keybind to open the illegal menu.
    openWithKey = {
        active = true, -- Set to true to enable keybind-based menu opening.
        key = 'F9',
    },
    -- Item to open the illegal menu.
    -- This allows players to open the menu by using a specific item.
    openWithItem = {
        active = true,               -- Set to true to enable item-based menu opening.
        itemName = 'illegal_tablet', -- The name of the item that opens the menu.
    },
    -- Jobs allowed to open the illegal menu.
    -- If table is empty, all jobs can access the menu.
    -- If you want to restrict access, add specific job names or gang names.
    allowedJobs = {
        -- 'job-name', -- Replace 'job-name' with the actual job names that can access the menu.
        -- 'gang-name', -- Replace 'gang-name' with the actual gang names that can access the menu.
    },
    forbiddenJobs = {
        'police',
        'sheriff',
        'ambulance',
    },
    -- Show a header button that closes this menu and opens 0r-heistpack
    switchToHeistPack = {
        enabled = true,
    },
}

---[[ Police Jobs ]]
Config.PoliceJobName = {
    ['police'] = true,  -- Name of the police job (used to check player roles).
    ['sheriff'] = true, -- Additional police job name (e.g., for different departments).
}

--[[ Level experience ]]
Config.Levels = { 0, 1000, 2000, 4000, 8000, 10000, 15000 } -- Experience experience for each level. You can adjust or expand as needed.

--[[ Drone Delivery Settings ]]
Config.DroneDelivery = {
    time = 10,                                         -- Time (in seconds) before the drone arrives. Minimum recommended: 60 sec for realism.
    objectModel = 1657647215,                          -- Object model hash for the drone entity.
    bagModel = 'xm_prop_x17_bag_01a',                  -- Bag object model.
    blip = { sprite = 627, color = 5, text = 'Drone' } -- Blip icon and color shown on the map during delivery.
}

--[[ Job Info Box Expansion Key ]]
Config.JobInfoBoxAlign = 'left'  -- Alignment of the job info box (left or right).
Config.ExpandJobInfoBoxKey = 'B' -- Key used to expand additional job-related info (e.g., stats, details).

---[[ Money Configuration ]]
Config.DirtyMoney = {
    isItem = true,               -- If set to true, dirty money will be treated as an item.
    itemName = 'black_money',    -- The name of the dirty money item (if isItem is true).
    accountName = 'black_money', -- The account name used for dirty money transactions.
    label = 'Black Money',
}
Config.CleanMoney = {
    isItem = true,        -- If set to true, dirty money will be treated as an item.
    itemName = 'cash',    -- The name of the dirty money item (if isItem is true).
    accountName = 'cash', -- The account name used for dirty money transactions.
    label = 'Cash',
}

Config.IllegalMarket = {
    enabled = true, -- Enable or disable the illegal market.

    -- Drone delivery settings
    droneDeliveryOptions = {
        time = 10,                                          -- Time (in seconds) before the drone arrives. Minimum recommended: 60 sec for realism.
        objectModel = 1657647215,                           -- Object model hash for the drone entity.
        bagModel = 'xm_prop_x17_bag_01a',                   -- Bag object model.
        blip = { sprite = 627, color = 5, text = 'Drone' }, -- Blip icon and color shown on the map during delivery.
    },

    -- Payment methods available in the market
    paymentMethods = {
        useCash = true,       -- If true, purchases are made using cash.
        useCard = true,       -- If true, purchases can be made using a card payment system.
        useBlackMoney = false -- If true, purchases can be made using black money (dirty money).
    }
}

-- Legacy fallback kept for older references. Prefer Config.IllegalMarket.droneDeliveryOptions.
Config.DroneDelivery = Config.DroneDelivery or Config.IllegalMarket.droneDeliveryOptions

Config.DefaultRoutingBucket = 0 -- Default routing bucket for players

--[[ Debug Mode ]]
Config.debug = false -- Enable (true) or disable (false) debug mode for development/testing.
