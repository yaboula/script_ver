---[[
--- All accepted values are specified in `shared/types/__job.lua`.
---]]

---@type Job
return {
    -- Minimum required level to start the job
    level = 3,

    -- Job title displayed in the UI
    label = 'Npc Boxing',

    -- Short mission description
    description = 'Make money with illegal boxing.',

    -- UI image for the mission
    image = 'npc_boxing.png',

    -- Rewards for completing the mission
    reward = { exp = 150, money = 2000 },

    -- Additional info or lore for the mission
    information = 'Make money with illegal boxing.',

    -- Step-by-step instructions for the mission
    steps = {
        { label = locale('npc_boxing.steps.1') },
        { label = locale('npc_boxing.steps.2'), progress = { target = 5 }, },
    },

    -- Blips
    blips = {
        contact_npc = { sprite = 270, color = 5, text = locale('npc_boxing.blips.contact_npc') },
    },

    teamSize = { max = 1 },

    game = {
        fighters = {
            [1] = { model = 'a_m_m_fatlatin_01', health = 300, armor = 0, accuracy = 10, count = 1 },
            [2] = { model = 'g_m_y_mexgoon_01', health = 350, armor = 25, accuracy = 10, count = 2 },
            [3] = { model = 'g_m_y_ballaeast_01', health = 300, armor = 25, accuracy = 10, weapon = 'weapon_bat', count = 1 },
            [4] = { model = 'g_m_y_lost_01', health = 300, armor = 25, accuracy = 25, weapon = 'weapon_bat', count = 2 },
            [5] = { model = 's_m_y_blackops_01', health = 400, armor = 25, accuracy = 25, weapon = 'weapon_bat', count = 2 },
        },

        locations = {
            [1] = {
                npc_location = vector4(-307.5648, -1623.3242, 30.8488, 231.1333),
                opponent_1 = vector4(-299.4271, -1642.6587, 30.8488, 64.1584),
                opponent_2 = vector4(-306.0685, -1639.5559, 30.8488, 238.1419),
                arena_location = {
                    center = vector3(-302.4370, -1641.3625, 32.1851),
                    corners = {
                        vector3(-288.4022, -1637.7311, 31.9),
                        vector3(-306.1488, -1627.3992, 31.9),
                        vector3(-316.9445, -1645.2321, 31.9),
                        vector3(-298.8412, -1655.6877, 31.9),
                    },
                },
                spectator_locations = {
                    vector4(-310.8459, -1627.3339, 31.0373, 246.9308),
                    vector4(-313.2887, -1628.6863, 31.4701, 238.3649),
                    vector4(-313.1098, -1630.8699, 30.8435, 234.3541),
                    vector4(-314.6078, -1632.7397, 31.4297, 245.1833),
                    vector4(-315.6238, -1634.8009, 31.4297, 248.5231),
                },
            },
        },

        npc_model = 'a_m_y_ktown_01',
        spectatorModels = {
            'a_m_m_eastsa_01',
            'a_f_y_hipster_02',
            'a_m_y_musclbeac_01'
        }
    },
}
