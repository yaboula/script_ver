Config = {}

Config.Objects = {
    ["cone"] = {model = "prop_roadcone02a", freeze = false},
    ["barrier"] = {model = "prop_barrier_work06a", freeze = true},
    ["roadsign"] = {model = "prop_snow_sign_road_06g", freeze = true},
    ["tent"] = {model = "prop_gazebo_03", freeze = true},
    ["light"] = {model = "prop_worklight_03b", freeze = true},
}

Config.MaxSpikes = 5

Config.HandCuffItem = 'handcuffs'
Config.CuffKeyItem = "cuffkeys"
Config.TieItem = 'ziptie'
Config.CutTieItem = 'flush_cutter'
Config.CutCuffItem = 'bolt_cutter'
Config.BrokenCuffItem = 'broken_handcuffs'
Config.BreakOutCuffing = {active = true, duration = math.random(500,1000), pos = math.random(10, 30), width = math.random(10, 20)}
Config.BreakoutMinigame = 'ps-ui' -- Choose the cuff breakout minigame : qb-skillbar / ps-ui (circle)
Config.TargetSystem = 'qb-target' -- Target system you want to use : qb-target / qtarget / ox_target
Config.Debug = false -- Enable / Disable debugpoly

--evidenve cleaner item
Config.EvidenceCleanerItem = 'evidencecleaningkit'
Config.RagItem = 'rag'
Config.AlcoholReleaseInterval = {
    min = 5,        -- cada 5 minutos
    promille = 0.1  -- reduce 0.1 por ciclo
}
Config.AlcoholTesterName = 'alcoholtester'

Config.RepairStations = {
    enabled = true, -- enable/disable repair stations
    locations = {
        [1] = {
            pedhash = "s_m_m_armoured_01", -- ped model
            pedloc = { x = 450.65, y = -1027.6, z = 28.38, w = 7.73 },   -- ped spawn location
            walkto = { x = 450.61, y = -1025.85, z = 28.39, w = 0.75 }, -- interaction location
            jobtype = "leo" -- only available for law enforcement jobs
        },
    }
    }


-- itemname = name of the item
-- propname = the prop used for cuffing
-- needkey = does the cuff needs a key to uncuff ? It will give a key when true
-- keyitem = what is the item used to uncuff
-- cufftype = the animation type. 19 - ped is freezed / 49 - ped can move with cuffs
Config.CuffItems = { 
    ['handcuffs'] = {itemname = "handcuffs", propname = "p_cs_cuffs_02_s", needkey = true, keyitem = "cuffkeys", cufftype = 49 },
    ['ziptie'] = {itemname = "ziptie", propname = "ba_prop_battle_cuffs", needkey = false, keyitem = "flush_cutter", cufftype = 49}
}

Config.BlipColors = {
    ['police'] = 29,
    ['bcso'] = 47,
    ['sasp'] = 1
}

Config.FuelScript = 'cdn-fuel'
Config.Inventory = 'qb-inventory'
Config.LicenseRank = 2
Config.BlockWallThermals = true -- true/false; lowers thermal cam intensity to stop penetration through walls or tunnels
Config.UseTarget = GetConvar('UseTarget', 'true') == 'true'
Config.GaragePedModel = "s_m_y_hwaycop_01"
Config.Locations = {
    ["duty"] = {
        [1] = vector3(450.04, -994.38, 32.01), -- LSPD
        [2] = vector3(453.33, -982.39, 32.09), 
        -- [3] = vector3(463.21, -1000.68, 30.01), 
    },
    ["vehicle"] = {
        [1] = vector4(523.0429, 35.6147, 69.5109, 207.6357), -- LSPD
        [2] = vector4(-458.86, 6031.5, 31.34, 139.15), --BCSO
        [3] = vector4(1858.95, 3681.95, 33.83, 219.83), -- Sandy
    },
    ["vehspawn"] = { -- The numbers [1] must match the numbers in [vehicle]
        [1] = vector4(521.1931, 32.3165, 69.5109, 212.0627), -- LSPD
        [2] = vector4(-474.63, 6030.38, 30.95, 226.12), -- BCSO
        [3] = vector4(1850.89, 3673.04, 33.37, 211.26), -- Sandy
    },
    ["stash"] = {
        [1] = vector3(466.13, -996.84, 31.82), -- LSPD
        -- [2] = vector3(-438.73, 6008.25, 36.99), -- BCSO
        -- [3] = vector3(1837.89, 3688.08, 34.19), -- Sandy
    },
    ["impound"] = {
        [1] = vector3(479.08, -1022.54, 28.01),
        [2] = vector3(1822.14, 3689.16, 33.97),
    },
    ["helicopter"] = {
        [1] = vector4(484.71, -1003.34, 45.91, 88.47), -- LSPD
        -- [2] = vector4(-462.15, 5994.77, 31.25, 134.84), -- BCSO
    },
    ["helispawn"] = { -- The numbers [1] must match the numbers in [helicopter]
        [1] = vector4(476.96, -1003.07, 45.91, 86.06), -- LSPD
        -- [2] = vector4(-475.18, 5988.43, 31.72, 317.27), -- BCSO
    },
    ["armory"] = {
        [1] = vector3(461.79, -1003.01, 31.06), -- LSPD
        [2] = vector3(460.16, -998.74, 31.74), -- BCSO
        -- [3] = vector3(1836.2, 3687.01, 34.19), -- Sandy
    },
    ["trash"] = {
        [1] = vector3(471.26, -989.05, 31.16), -- LSPD
    },
    ["fingerprint"] = {
        [1] = vector3(475.64, -1003.11, 26.20), -- LSPD
        -- [2] = vector3(-452.22, 5997.96, 27.58), --BCSO
    },
    ["evidence"] = {
        [1] = vector3(478.51, -988.09, 31.27), -- LSPD
        -- [2] = vector3(-452.87, 5999.38, 37.00), -- BCSO
        -- [3] = vector3(1817.97, 3672.25, 34.2), -- Sandy
    },
    ["labs"] = {
        [1] = vector3(484.68, -992.46, 27.32), -- LSPD
    },
    ["stations"] = {
        [1] = {label = "Los Santos Police Department", coords = vector4(418.33, -982.29, 29.42, 87.87), sprite= 137, scale= 0.7, colour= 29},
    },
}

Config.PoliceHelicopter = "POLMAV"

Config.SecurityCameras = {
    hideradar = false,
    cameras = {
        [1] = {label = "Pacific Bank CAM#1", coords = vector3(257.45, 210.07, 109.08), r = {x = -25.0, y = 0.0, z = 28.05}, canRotate = false, isOnline = true},
        [2] = {label = "Pacific Bank CAM#2", coords = vector3(232.86, 221.46, 107.83), r = {x = -25.0, y = 0.0, z = -140.91}, canRotate = false, isOnline = true},
        [3] = {label = "Pacific Bank CAM#3", coords = vector3(252.27, 225.52, 103.99), r = {x = -35.0, y = 0.0, z = -74.87}, canRotate = false, isOnline = true},
        [4] = {label = "Limited Ltd Grove St. CAM#1", coords = vector3(-53.1433, -1746.714, 31.546), r = {x = -35.0, y = 0.0, z = -168.9182}, canRotate = false, isOnline = true},
        [5] = {label = "Rob's Liqour Prosperity St. CAM#1", coords = vector3(-1482.9, -380.463, 42.363), r = {x = -35.0, y = 0.0, z = 79.53281}, canRotate = false, isOnline = true},
        [6] = {label = "Rob's Liqour San Andreas Ave. CAM#1", coords = vector3(-1224.874, -911.094, 14.401), r = {x = -35.0, y = 0.0, z = -6.778894}, canRotate = false, isOnline = true},
        [7] = {label = "Limited Ltd Ginger St. CAM#1", coords = vector3(-718.153, -909.211, 21.49), r = {x = -35.0, y = 0.0, z = -137.1431}, canRotate = false, isOnline = true},
        [8] = {label = "24/7 Supermarkt Innocence Blvd. CAM#1", coords = vector3(23.885, -1342.441, 31.672), r = {x = -35.0, y = 0.0, z = -142.9191}, canRotate = false, isOnline = true},
        [9] = {label = "Rob's Liqour El Rancho Blvd. CAM#1", coords = vector3(1133.024, -978.712, 48.515), r = {x = -35.0, y = 0.0, z = -137.302}, canRotate = false, isOnline = true},
        [10] = {label = "Limited Ltd West Mirror Drive CAM#1", coords = vector3(1151.93, -320.389, 71.33), r = {x = -35.0, y = 0.0, z = -119.4468}, canRotate = false, isOnline = true},
        [11] = {label = "24/7 Supermarkt Clinton Ave CAM#1", coords = vector3(383.402, 328.915, 105.541), r = {x = -35.0, y = 0.0, z = 118.585}, canRotate = false, isOnline = true},
        [12] = {label = "Limited Ltd Banham Canyon Dr CAM#1", coords = vector3(-1832.057, 789.389, 140.436), r = {x = -35.0, y = 0.0, z = -91.481}, canRotate = false, isOnline = true},
        [13] = {label = "Rob's Liqour Great Ocean Hwy CAM#1", coords = vector3(-2966.15, 387.067, 17.393), r = {x = -35.0, y = 0.0, z = 32.92229}, canRotate = false, isOnline = true},
        [14] = {label = "24/7 Supermarkt Ineseno Road CAM#1", coords = vector3(-3046.749, 592.491, 9.808), r = {x = -35.0, y = 0.0, z = -116.673}, canRotate = false, isOnline = true},
        [15] = {label = "24/7 Supermarkt Barbareno Rd. CAM#1", coords = vector3(-3246.489, 1010.408, 14.705), r = {x = -35.0, y = 0.0, z = -135.2151}, canRotate = false, isOnline = true},
        [16] = {label = "24/7 Supermarkt Route 68 CAM#1", coords = vector3(539.773, 2664.904, 44.056), r = {x = -35.0, y = 0.0, z = -42.947}, canRotate = false, isOnline = true},
        [17] = {label = "Rob's Liqour Route 68 CAM#1", coords = vector3(1169.855, 2711.493, 40.432), r = {x = -35.0, y = 0.0, z = 127.17}, canRotate = false, isOnline = true},
        [18] = {label = "24/7 Supermarkt Senora Fwy CAM#1", coords = vector3(2673.579, 3281.265, 57.541), r = {x = -35.0, y = 0.0, z = -80.242}, canRotate = false, isOnline = true},
        [19] = {label = "24/7 Supermarkt Alhambra Dr. CAM#1", coords = vector3(1966.24, 3749.545, 34.143), r = {x = -35.0, y = 0.0, z = 163.065}, canRotate = false, isOnline = true},
        [20] = {label = "24/7 Supermarkt Senora Fwy CAM#2", coords = vector3(1729.522, 6419.87, 37.262), r = {x = -35.0, y = 0.0, z = -160.089}, canRotate = false, isOnline = true},
        [21] = {label = "Fleeca Bank Hawick Ave CAM#1", coords = vector3(309.341, -281.439, 55.88), r = {x = -35.0, y = 0.0, z = -146.1595}, canRotate = false, isOnline = true},
        [22] = {label = "Fleeca Bank Legion Square CAM#1", coords = vector3(144.871, -1043.044, 31.017), r = {x = -35.0, y = 0.0, z = -143.9796}, canRotate = false, isOnline = true},
        [23] = {label = "Fleeca Bank Hawick Ave CAM#2", coords = vector3(-355.7643, -52.506, 50.746), r = {x = -35.0, y = 0.0, z = -143.8711}, canRotate = false, isOnline = true},
        [24] = {label = "Fleeca Bank Del Perro Blvd CAM#1", coords = vector3(-1214.226, -335.86, 39.515), r = {x = -35.0, y = 0.0, z = -97.862}, canRotate = false, isOnline = true},
        [25] = {label = "Fleeca Bank Great Ocean Hwy CAM#1", coords = vector3(-2958.885, 478.983, 17.406), r = {x = -35.0, y = 0.0, z = -34.69595}, canRotate = false, isOnline = true},
        [26] = {label = "Paleto Bank CAM#1", coords = vector3(-102.939, 6467.668, 33.424), r = {x = -35.0, y = 0.0, z = 24.66}, canRotate = false, isOnline = true},
        [27] = {label = "Del Vecchio Liquor Paleto Bay", coords = vector3(-163.75, 6323.45, 33.424), r = {x = -35.0, y = 0.0, z = 260.00}, canRotate = false, isOnline = true},
        [28] = {label = "Don's Country Store Paleto Bay CAM#1", coords = vector3(166.42, 6634.4, 33.69), r = {x = -35.0, y = 0.0, z = 32.00}, canRotate = false, isOnline = true},
        [29] = {label = "Don's Country Store Paleto Bay CAM#2", coords = vector3(163.74, 6644.34, 33.69), r = {x = -35.0, y = 0.0, z = 168.00}, canRotate = false, isOnline = true},
        [30] = {label = "Don's Country Store Paleto Bay CAM#3", coords = vector3(169.54, 6640.89, 33.69), r = {x = -35.0, y = 0.0, z = 5.78}, canRotate = false, isOnline = true},
        [31] = {label = "Vangelico Jewelery CAM#1", coords = vector3(-627.54, -239.74, 40.33), r = {x = -35.0, y = 0.0, z = 5.78}, canRotate = true, isOnline = true},
        [32] = {label = "Vangelico Jewelery CAM#2", coords = vector3(-627.51, -229.51, 40.24), r = {x = -35.0, y = 0.0, z = -95.78}, canRotate = true, isOnline = true},
        [33] = {label = "Vangelico Jewelery CAM#3", coords = vector3(-620.3, -224.31, 40.23), r = {x = -35.0, y = 0.0, z = 165.78}, canRotate = true, isOnline = true},
        [34] = {label = "Vangelico Jewelery CAM#4", coords = vector3(-622.57, -236.3, 40.31), r = {x = -35.0, y = 0.0, z = 5.78}, canRotate = true, isOnline = true},
    },
}
Config.EnableMods = false -- Enable the mods below to be applied
Config.CarMods = { -- Mods to be enabled / disabled for vehicles
    engine = true,
    brakes = true,
    gearbox = true,
    armour = false,
    turbo = true,
}
Config.EnableExtras = true
Config.CarExtras = { -- Extra options to be enabled / disabled
    ["extras"] = {
        ["1"] = true, -- on/off
        ["2"] = true,
        ["3"] = true,
        ["4"] = true,
        ["5"] = true,
        ["6"] = true,
        ["7"] = true,
        ["8"] = true,
        ["9"] = true,
        ["10"] = true,
        ["11"] = true,
        ["12"] = true,
        ["13"] = true,
    }
}
Config.AuthorizedVehicles = {
    -- Garage 1 vehicles (LSPD)
    [1] = {
        ["11cvpivp"] = {label = "2011 CVPI VS", ranks = {1,2}, livery = 1, price = 10},
        ["13capricevs"] = {label = "2013 Caprice VS", ranks = {1,2}, livery = 1, price = 10},
        ["13capricevw"] = {label = "2013 Caprice VW", ranks = {1,2}, livery = 1, price = 10},
        ["13fpiuvs"] = {label = "2013 FPIU VS", ranks = {1,2}, livery = 1, price = 10},
        ["13fpiuvw"] = {label = "2013 FPIU VW", ranks = {1,2}, livery = 1, price = 10},
        ["14chargervs"] = {label = "2014 Charger VS", ranks = {1,2}, livery = 1, price = 10},
        ["14chargervw"] = {label = "2014 Charger VW", ranks = {1,2}, livery = 1, price = 10},
        ["16fpiuvs"] = {label = "2016 FPIU VS", ranks = {1,2}, livery = 1, price = 10},
        ["16fpiuvw"] = {label = "2016 FPIU VW", ranks = {1,2}, livery = 1, price = 10},
        ["18chargervs"] = {label = "2018 Charger VS", ranks = {1,2}, livery = 1, price = 10},
        ["18chargervw"] = {label = "2018 Charger VW", ranks = {1,2}, livery = 1, price = 10},
        ["18f150vs"] = {label = "2018 F150 VS", ranks = {1,2}, livery = 1, price = 10},
        ["18f150vw"] = {label = "2018 F150 VW", ranks = {1,2}, livery = 1, price = 10},
        ["18tahoevs"] = {label = "2018 Tahoe VS", ranks = {1,2}, livery = 1, price = 10},
        ["18tahoevw"] = {label = "2018 Tahoe VW", ranks = {1,2}, livery = 1, price = 10},
        ["18taurusvs"] = {label = "2018 Taurus VS", ranks = {1,2}, livery = 1, price = 10},
        ["18taurusvw"] = {label = "2018 Taurus VW", ranks = {1,2}, livery = 1, price = 10},
        ["21durangovw"] = {label = "2021 Durango VW", ranks = {1,2}, livery = 1, price = 10},
    },
    -- Garage 2 vehicles (BCSO)
    [2] = {
        ["sheriff"] = {label = "Sheriff Car 1", ranks = {1,2}, livery = 1, price = 10},
        ["sheriff2"] = {label = "Sheriff Car 2", ranks = {2,3,4}, livery = 1, price = 10},
        ["fbi"] = {label = "Unmarked FBI", ranks = {3,4}, livery = 1, price = 10},
        ["fbi2"] = {label = "Unmarked FBI2", ranks = {3,4}, livery = 1, price = nil},
    },
    -- Garage 1 vehicles (Sandy)
    [3] = {
        ["sheriff"] = {label = "Sheriff Car 1", ranks = {1,2}, livery = 1, price = 10},
        ["sheriff2"] = {label = "Sheriff Car 2", ranks = {2,3,4}, livery = 1, price = 10},
        ["fbi"] = {label = "Unmarked FBI", ranks = {3,4}, livery = 1, price = 10},
        ["fbi2"] = {label = "Unmarked FBI2", ranks = {3,4}, livery = 1, price = nil},
    },
}



Config.Radars = {
    vector4(-623.44421386719, -823.08361816406, 25.25704574585, 145.0),
    vector4(-652.44421386719, -854.08361816406, 24.55704574585, 325.0),
    vector4(1623.0114746094, 1068.9924316406, 80.903594970703, 84.0),
    vector4(-2604.8994140625, 2996.3391113281, 27.528566360474, 175.0),
    vector4(2136.65234375, -591.81469726563, 94.272926330566, 318.0),
    vector4(2117.5764160156, -558.51013183594, 95.683128356934, 158.0),
    vector4(406.89505004883, -969.06286621094, 29.436267852783, 33.0),
    vector4(657.315, -218.819, 44.06, 320.0),
    vector4(2118.287, 6040.027, 50.928, 172.0),
    vector4(-106.304, -1127.5530, 30.778, 230.0),
    vector4(-823.3688, -1146.980, 8.0, 300.0),
}

Config.CarItems = {
    [1] = {name = "heavyarmor", amount = 2, info = {}, type = "item", slot = 1,},
    [2] = {name = "empty_evidence_bag", amount = 10, info = {}, type = "item", slot = 2,},
    [3] = {name = "police_stormram", amount = 1, info = {}, type = "item", slot = 3,},
}

Config.Items = {
    label = "Police Armory",
    slots = 50,
    items = {
        -- Pistol and ammo
        [1] = {
            name = "weapon_pistol",
            price = 0,
            amount = 1,
            info = { serie = "" },
            type = "weapon",
            slot = 1,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [2] = {
            name = "pistol_ammo",
            price = 0,
            amount = 10,
            info = {},
            type = "item",
            slot = 2,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },

        -- Pistol attachments as items
        [3] = {
            name = "pistol_flashlight",
            price = 0,
            amount = 5,
            info = { label = "Pistol Flashlight" },
            type = "item",
            slot = 3,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [4] = {
            name = "pistol_suppressor",
            price = 0,
            amount = 5,
            info = { label = "Pistol Suppressor" },
            type = "item",
            slot = 4,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [5] = {
            name = "pistol_extendedclip",
            price = 0,
            amount = 5,
            info = { label = "Extended Clip" },
            type = "item",
            slot = 5,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },

        -- Basic police equipment
        [6] = {
            name = "weapon_stungun",
            price = 0,
            amount = 1,
            info = { serie = "" },
            type = "weapon",
            slot = 6,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [7] = {
            name = "weapon_nightstick",
            price = 0,
            amount = 1,
            info = {},
            type = "weapon",
            slot = 7,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [8] = {
            name = "weapon_flashlight",
            price = 0,
            amount = 1,
            info = {},
            type = "weapon",
            slot = 8,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [9] = {
            name = "handcuffs",
            price = 0,
            amount = 1,
            info = {},
            type = "item",
            slot = 9,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [10] = {
            name = "empty_evidence_bag",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 10,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [11] = {
            name = "notebook",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 11,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [12] = {
            name = "radio",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 12,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [13] = {
            name = "heavyarmor", -- Only heavy armor is available, normal armor removed
            price = 0,
            amount = 25,
            info = {},
            type = "item",
            slot = 13,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [14] = {
            name = "pdbadge",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 14,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [15] = {
            name = "bodycam",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 15,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [16] = {
            name = "leo_gps",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 16,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [17] = {
            name = "ziptie",
            price = 0,
            amount = 20,
            info = {},
            type = "item",
            slot = 17,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [18] = {
            name = "flush_cutter",
            price = 0,
            amount = 10,
            info = {},
            type = "item",
            slot = 18,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [19] = {
            name = "bolt_cutter",
            price = 0,
            amount = 5,
            info = {},
            type = "item",
            slot = 19,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [20] = {
            name = "dashcam",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 20,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [21] = {
            name = "camera",
            price = 0,
            amount = 50,
            info = {},
            type = "item",
            slot = 21,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [22] = {
            name = "evidencecleaningkit",
            price = 0,
            amount = 20,
            info = {},
            type = "item",
            slot = 22,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },
        [23] = {
            name = "alcoholtester",
            price = 0,
            amount = 10,
            info = {},
            type = "item",
            slot = 23,
            authorizedJobGrades = {0, 1, 2, 3, 4}
        },

        -- Heavy weapons (commented out, not available)
        -- [24] = {
        --     name = "weapon_pumpshotgun",
        --     price = 0,
        --     amount = 1,
        --     info = {},
        --     type = "weapon",
        --     slot = 24,
        --     authorizedJobGrades = {0, 1, 2, 3, 4}
        -- },
        -- [25] = {
        --     name = "weapon_smg",
        --     price = 0,
        --     amount = 1,
        --     info = {},
        --     type = "weapon",
        --     slot = 25,
        --     authorizedJobGrades = {0, 1, 2, 3, 4}
        -- },
        -- [26] = {
        --     name = "weapon_carbinerifle",
        --     price = 0,
        --     amount = 1,
        --     info = {},
        --     type = "weapon",
        --     slot = 26,
        --     authorizedJobGrades = {0, 1, 2, 3, 4}
        -- },
        -- [27] = {
        --     name = "smg_ammo",
        --     price = 0,
        --     amount = 5,
        --     info = {},
        --     type = "item",
        --     slot = 27,
        --     authorizedJobGrades = {0, 1, 2, 3, 4}
        -- },
        -- [28] = {
        --     name = "shotgun_ammo",
        --     price = 0,
        --     amount = 5,
        --     info = {},
        --     type = "item",
        --     slot = 28,
        --     authorizedJobGrades = {0, 1, 2, 3, 4}
        -- },
        -- [29] = {
        --     name = "rifle_ammo",
        --     price = 0,
        --     amount = 5,
        --     info = {},
        --     type = "item",
        --     slot = 29,
        --     authorizedJobGrades = {0, 1, 2, 3, 4}
        -- }
    }
}


