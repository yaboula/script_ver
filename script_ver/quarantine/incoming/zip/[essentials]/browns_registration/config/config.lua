config = {}

config.Core = {
    framework = 'qb-core', -- 'esx' or 'qb-core'
    inventory = 'qb-inventory', -- 'ox_inventory', 'qb-inventory', 'qs-inventory', 'ps-inventory', or 'lj-inventory'
    target = 'qb-target', -- 'qb-target', 'ox_target', or 'qtarget'
    notify = function(title, message, types, duration) 

        -- you can add your own notification exports/events here (client sided) 

        lib.notify({ -- uses ox_lib by default.
            title = title, 
            description = message,
            type = types, 
            duration = duration,
        })
    end
}

config.locations = {
    registration = vec3(-554.59, -194.32, 38.22), -- coords to get vehicle registration
    insurance = vector3(-291.26, -430.77, 30.24) -- coords to get vehicle insurance
}

config.costs = {
    registration = 1000, -- price per registration
    insurance = 2000 -- price per month (billed all at once, not once per month)
}

config.expire = 30 -- how many days should registration expire after registration date

config.blip = {
    registration = {
        enable = true, -- enable or disable the blip
        sprite = 326, -- the blip icon/sprite (see ref: https://docs.fivem.net/docs/game-references/blips/#blips)
        color = 2, -- the blip color (see ref: https://docs.fivem.net/docs/game-references/blips/#blip-colors)
        scale = 0.8, -- the blip scale/size (0.1 - 1.0)
        label = 'Vehicle Registration', -- the name of the blip
    },
    insurance = {
        enable = true, -- enable or disable the blip
        sprite = 408, -- the blip icon/sprite (see ref: https://docs.fivem.net/docs/game-references/blips/#blips)
        color = 5, -- the blip color (see ref: https://docs.fivem.net/docs/game-references/blips/#blip-colors)
        scale = 0.8, -- the blip scale/size (0.1 - 1.0)
        label = 'Vehicle Insurance', -- the name of the blip
    },
}