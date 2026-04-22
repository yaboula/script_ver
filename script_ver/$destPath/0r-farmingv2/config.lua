--[[
    All script settings are found and edited in this file.
    Before running the script, make sure to configure everything correctly.
]]

Config = {}

---[[ Image folder path for your inventory script ]]
--- So item names and images match your inventory - PNG images only!
Config.InventoryImagesFolder = "ox_inventory/web/images/"

--[[ Menu Commands ]]
Config.FarmingMenu = {
    -- Command to open the menu.
    openWithCommand = {
        active = false, -- Set to true to enable command-based menu opening.
        command = "farmingmenu",
    },
    -- Keybind to open the menu.
    openWithKey = {
        active = false, -- Set to true to enable keybind-based menu opening.
        key = "F7",
    },
    -- Item to open the menu.
    -- This allows players to open the menu by using a specific item.
    openWithItem = {
        active = false,               -- Set to true to enable item-based menu opening.
        itemName = "farming_tablet", -- Item name to open the menu.
    },
    -- Jobs allowed to open the menu.
    -- If the table is empty, all jobs can access the menu.
    -- If you want to restrict access, add specific job names.
    allowedJobs = {
        -- "job-name", -- Replace "job-name" with the actual job name that can access the menu.
    },
}

--[[ Level Experience ]]
Config.Levels = { 0, 1000, 2000, 4000, 8000, 10000, 15000 } -- Experience required for each level. You can adjust or expand as needed.

--[[ Task Info Box Expansion Key ]]
Config.InfoBoxAlign = "left"  -- Task info box alignment (left or right).
Config.ToggleInfoBoxKey = "B" -- Key to toggle extra info related to tasks (e.g. stats, details).

---[[ Money Configuration ]]
Config.CleanMoney = {
    isItem = true,        -- If set to true, clean money will be treated as an item.
    itemName = "cash",    -- Item name for clean money (if isItem is true).
    accountName = "cash", -- Account name used for money transactions.
    label = "Cash",
}

--[[ Sell NPC Configuration ]]
Config.SellNpc = {
    model = "a_m_m_farmer_01",                                                             -- NPC model used for selling harvested hay bales
    blip = { active = true, sprite = 237, color = 5, scale = 0.8, name = "Farming NPC", }, -- Whether to show the NPC's blip
    locations = {
        [1] = vector4(2416.1697, 4993.7061, 45.25, 135.0),                                 -- NPC spawn location
    },
}

--[[ Help Text ]]
Config.HelpText = {
    {
        title = "How to start farming?",
        description =
        "You can start farming by using the command `/farmingmenu`, pressing the F7 key, or using the farming tablet item.",
    },
    {
        title = "How to use the farming menu?",
        description =
        "The farming menu allows you to manage farming tasks, check your inventory, and access various farming-related features.",
    },
    {
        title = "What is a personal challenge?",
        description =
        "Personal challenges are tasks you can complete to earn rewards and improve your farming skills.",
    },
    {
        title = "How to check my current level?",
        description =
        "You can check your current level in the farming menu.",
    },
    {
        title = "How to start a multiplayer task?",
        description =
        "You can start a multiplayer task from the farming menu.",
    },
    {
        title = "How to earn experience?",
        description =
        "You can earn experience by completing farming tasks, harvesting crops, and finishing personal challenges. Each completed task rewards you with XP.",
    },
    {
        title = "Where can I sell my harvested crops?",
        description =
        "You can sell harvested crops and hay bales to the farming NPC on the map (look for the farming NPC blip).",
    },
    {
        title = "What is a farming tablet?",
        description =
        "A farming tablet is a special item that allows you to access the farming menu from anywhere. Make sure you have this item in your inventory.",
    },
    {
        title = "How to view task information?",
        description =
        "Press the 'B' key to toggle extra task information and view detailed statistics of your current farming activities.",
    },
    {
        title = "What happens when I level up?",
        description =
        "When you level up, you unlock new farming opportunities, better rewards, and more challenging tasks with higher profits.",
    },
    {
        title = "Can I farm with friends?",
        description =
        "Yes! You can participate in multiplayer farming tasks with other players to complete larger projects and earn extra rewards.",
    },
    {
        title = "How does the money system work?",
        description =
        "Completed farming tasks reward you with cash, which is deposited directly into your account. Some tasks might provide items you can sell for extra profit.",
    },
    {
        title = "What if I don't have the required job?",
        description =
        "If job restrictions are enabled, you need to have one of the allowed jobs to access the farming system. Please contact an admin for job assignment.",
    },
    {
        title = "How do I track my progress?",
        description =
        "Your farming progress, including experience, level, and completed tasks, is saved automatically and can be viewed in the farming menu.",
    },
    {
        title = "What if the menu doesn't open?",
        description =
        "Make sure you have the farming tablet item, try using the `/farmingmenu` command or pressing F7. Check if you have the required job permissions.",
    },
}

Config.DisableCustomProps = false   -- Set to true to disable custom props/markers at farming locations.
Config.DisableCustomMarkers = false -- Set to true to disable custom markers at farming locations.

--[[ Debug Mode ]]
Config.debug = false -- Enable (true) or disable (false) debug mode for development/testing.