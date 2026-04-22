config = {}

-- target resource (only one of these can be true)
-------------------------------------------------------
config.qbtarget = true
config.oxtarget = false
-------------------------------------------------------

config.InventorySystem = 'qb' -- Supports 'ox' & 'qb'
config.useBlip = true
config.pedmodel = 'a_m_m_prolhost_01' -- ped model hash

config.scenario = 'WORLD_HUMAN_CLIPBOARD' -- scenario for ped to play, false to disable

config.locations = {
    ['firsttime'] = {
        ped = true, -- if false uses boxzone (below)
        coords = vector4(1887.8811, 3565.0928, 38.8177, 14.4509),
        -------- boxzone (only used if ped is false) --------
        length = 1.0,  
        width = 1.0,   
        minZ = 30.81,  
        maxZ = 30.81,  
        debug = false, 
        -----------------------------------------------------
        vehicles = {
            ['sh350'] = {
                price = 50,
                image = 'https://i.imgur.com/vuP5xMc.jpeg',
            },
            ['enduro'] = {
                price = 30,
                image = 'https://i.imgur.com/vuP5xMc.jpeg',
            },
            ['faggio'] = {
                price = 30,
                image = 'https://i.imgur.com/vuP5xMc.jpeg',
            },
            ['asterope'] = {
                price = 100,
                image = 'https://i.imgur.com/TKTtwYF.jpeg',
            },
            ['seminole'] = {
                price = 120,
                image = 'https://i.imgur.com/TKTtwYF.jpeg',
            },
        },
        vehiclespawncoords = vector4(1886.6556, 3591.4600, 33.8651, 31.4991), -- where vehicle spawns when rented
    },

    -- add as many locations as you'd like with any type of vehicle (air, water, land) follow same format as above
}

  