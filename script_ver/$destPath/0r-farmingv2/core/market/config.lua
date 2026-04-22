return {
    --[[ Drone Delivery Settings ]]
    droneDelivery = {
        time = 10,                                         -- Time in seconds before the drone arrives. Minimum 60s recommended for realism.
        objectModel = 1657647215,                          -- Hash for the drone entity model.
        bagModel = "xm_prop_x17_bag_01a",                  -- Model for the package bag.
        blip = { sprite = 627, color = 5, text = "Drone" } -- Icon and color on the map during delivery.
    },

    ---@type MarketItem[]
    items = {
        { itemName = "wheat",           price = 15,  sellPrice = 7,  label = "Wheat",           description = "A common grain used for food.",      level = 1, type = "sell" },
        { itemName = "wheat_seed",      price = 5,   sellPrice = 1,  label = "Wheat Seed",      description = "Seed used to plant wheat.",                  level = 1, type = "buy" },

        { itemName = "rose",            price = 20,  sellPrice = 10, label = "Rose",            description = "A fragrant plant.",          level = 1, type = "sell" },
        { itemName = "rose_seed",       price = 20,  sellPrice = 10, label = "Rose Seed",       description = "Seed used to plant roses.",                  level = 1, type = "buy" },

        { itemName = "green",           price = 25,  sellPrice = 15, label = "Greens",           description = "A fragrant herbal plant used for cooking.",          level = 2, type = "sell" },
        { itemName = "green_seed",      price = 25,  sellPrice = 15, label = "Greens Seed",      description = "Seed used to plant greens.",                 level = 2, type = "buy" },

        { itemName = "daisy",           price = 30,  sellPrice = 20, label = "Daisy",           description = "A fragrant plant.",          level = 2, type = "sell" },
        { itemName = "daisy_seed",      price = 30,  sellPrice = 20, label = "Daisy Seed",      description = "Seed used to plant daisies.",                level = 2, type = "buy" },

        { itemName = "poppy",           price = 35,  sellPrice = 25, label = "Poppy",           description = "A fragrant plant.",          level = 3, type = "sell" },
        { itemName = "poppy_seed",      price = 35,  sellPrice = 25, label = "Poppy Seed",      description = "Seed used to plant poppies.",                level = 3, type = "buy" },

        { itemName = "melon",           price = 40,  sellPrice = 20, label = "Melon",           description = "A juicy, sweet melon.",                  level = 1, type = "sell" },
        { itemName = "melon_seed",      price = 10,  sellPrice = 2,  label = "Melon Seed",      description = "Seed used to plant melons.",                 level = 1, type = "buy" },

        { itemName = "watermelon",      price = 40,  sellPrice = 20, label = "Watermelon",      description = "A juicy, sweet watermelon.",             level = 1, type = "sell" },
        { itemName = "watermelon_seed", price = 10,  sellPrice = 2,  label = "Watermelon Seed", description = "Seed used to plant watermelons.",            level = 1, type = "buy" },

        { itemName = "pumpkin",         price = 50,  sellPrice = 20, label = "Pumpkin",         description = "A round orange pumpkin.",                   level = 1, type = "sell" },
        { itemName = "pumpkin_seed",    price = 12,  sellPrice = 2,  label = "Pumpkin Seed",    description = "Seed used to plant pumpkins.",               level = 1, type = "buy" },

        { itemName = "watering_can",    price = 30,  sellPrice = 10, label = "Watering Can",    description = "Used to water crops.",                      level = 1, type = "buy" },

        { itemName = "farming_tablet",  price = 100, sellPrice = 50, label = "Farming Tablet",  description = "A tablet used to access the farming menu.", level = 1, type = "buy" },
    }
}