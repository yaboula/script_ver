Config = {
    ModelSaveType = "modelname", -- number (hash key) or modelname
    UseBackgroundBlur = false,
    Interaction = {
        TextUI = {
            Enable = false,
            Distance = 4.0,
            Show = function(label)
                exports["qb-core"]:DrawText(label, "left")
            end,
            Hide = function()
                exports["qb-core"]:HideText()
            end
        },
        Target = {
            Enable = true,
            Distance = 4.0,
            Zone = 2.5,
            Icon = "fa-solid fa-shirt"
        }
    },
    OutfitChangers = {
        [1] = {shopType = 'outfit', coords = vector3(1697.41, 4829.25, 41.06)},
        [2] = {shopType = 'outfit', coords = vector3(-703.83, -151.67, 36.42)},
        [3] = {shopType = 'outfit', coords = vector3(-1187.19, -768.64, 16.33)},
        [4] = {shopType = 'outfit', coords = vector3(429.5, -800.15, 28.49)},
        [5] = {shopType = 'outfit', coords = vector3(-168.21, -298.7, 38.73)},
        [6] = {shopType = 'outfit', coords = vector3(71.06, -1399.17, 28.38)},
        [7] = {shopType = 'outfit', coords = vector3(-829.72, -1073.33, 10.33)},
        [8] = {shopType = 'outfit', coords = vector3(-1447.51, -242.81, 48.82)},
        [9] = {shopType = 'outfit', coords = vector3(12.28, 6513.63, 30.88)},
        [10] = {shopType = 'outfit', coords = vector3(617.89, 2766.79, 41.09)},
        [11] = {shopType = 'outfit', coords = vector3(1190.35, 2714.51, 37.22)},
        [12] = {shopType = 'outfit', coords = vector3(-3175.64, 1041.84, 19.86)},
        [13] = {shopType = 'outfit', coords = vector3(-1108.95, 2709.37, 18.11)},
        [14] = {shopType = 'outfit', coords = vector3(-1203.79, -1454.53, 3.38)},
        [15] = {shopType = 'outfit', coords = vector3(120.44, -227.38, 53.56)}
    },
    ClothingRooms = {
        [1] = {requiredJob = 'police', isGang = false, coords = vector3(454.68, -990.89, 29.69)},
        [2] = {requiredJob = 'ambulance', isGang = false, coords = vector4(342.47, -586.15, 43.32, 342.56)},
        [3] = {requiredJob = 'police', isGang = false, coords = vector3(314.76, 671.78, 14.73)},
        [4] = {requiredJob = 'ambulance', isGang = false, coords = vector3(338.70, 659.61, 14.71)},
        [5] = {requiredJob = 'ambulance', isGang = false, coords = vector3(-1098.45, 1751.71, 23.35)},
        [6] = {requiredJob = 'police', isGang = false, coords = vector3(-77.59, -129.17, 5.03)},
        [7] = {requiredJob = "realestate", isGang = false, coords = vector3(-131.45, -633.74, 168.82)}
    },
    Outfits = {
        ['police'] = {
            -- Job
            ['male'] = {
                -- Gender
                [0] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {texture = 0, item = 24, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 19, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [1] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 19, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [2] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 19, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [4] = {
                        outfitLabel = 'Trooper Black',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [3] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 19, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [4] = {
                        outfitLabel = 'Trooper Black',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [5] = {
                        outfitLabel = 'SWAT',
                        outfitData = {
                            ['pants'] = {item = 130, texture = 1, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 172, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 15, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 15, texture = 2, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 336, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['hat'] = {item = 150, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [4] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 19, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = -1, texture = -1, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [4] = {
                        outfitLabel = 'Trooper Black',
                        outfitData = {
                            ['pants'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 20, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 317, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 51, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 58, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [5] = {
                        outfitLabel = 'SWAT',
                        outfitData = {
                            ['pants'] = {item = 130, texture = 1, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 172, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 15, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 15, texture = 2, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 336, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 24, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['hat'] = {item = 150, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                }
            },
            ['female'] = {
                -- Gender
                [0] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 48, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [1] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 48, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [2] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 48, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [4] = {
                        outfitLabel = 'Trooper Black',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [3] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 48, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [4] = {
                        outfitLabel = 'Trooper Black',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [5] = {
                        outfitLabel = 'Swat',
                        outfitData = {
                            ['pants'] = {item = 135, texture = 1, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 213, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 17, texture = 2, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 102, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 149, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                },
                -- Gender
                [4] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 48, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [2] = {
                        outfitLabel = 'Long Sleeve',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [3] = {
                        outfitLabel = 'Trooper Tan',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 3, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [4] = {
                        outfitLabel = 'Trooper Black',
                        outfitData = {
                            ['pants'] = {item = 133, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 31, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    },
                    [5] = {
                        outfitLabel = 'Swat',
                        outfitData = {
                            ['pants'] = {item = 135, texture = 1, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['arms'] = {item = 213, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T Shirt
                            ['vest'] = {item = 17, texture = 2, defaultItem = 0, defaultTexture = 0}, -- Body Vest
                            ['torso2'] = {item = 327, texture = 8, defaultItem = 0, defaultTexture = 0}, -- Jacket
                            ['shoes'] = {item = 52, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['accessory'] = {item = 102, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck Accessory
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['hat'] = {item = 149, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['mask'] = {item = 35, texture = 0, defaultItem = 0, defaultTexture = 0} -- Mask
                        }
                    }
                }
            }
        },
        ['realestate'] = {
            -- Job
            ['male'] = {
                -- Gender
                [0] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 28, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 1, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 31, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 294, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 10, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = 12, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [1] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 28, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 1, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 31, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 294, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 10, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = 12, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [2] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 28, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 1, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 31, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 294, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 10, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = 12, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [3] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 28, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 1, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 31, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 294, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 10, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = 12, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [4] = {
                    -- Grade Level
                    [1] = {
                        -- Outfits
                        outfitLabel = 'Short Sleeve',
                        outfitData = {
                        ["pants"]       = { item = 28, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 1, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 31, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 294, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 10, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = 12, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                }
            },
            ['female'] = {
                -- Gender
                [0] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 57, texture = 2, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 34, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 105, texture = 7, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 8, texture = 5, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 11, texture = 3, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = -1, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [1] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 57, texture = 2, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 34, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 105, texture = 7, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 8, texture = 5, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 11, texture = 3, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = -1, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [2] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 57, texture = 2, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 34, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 105, texture = 7, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 8, texture = 5, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 11, texture = 3, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = -1, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [3] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 57, texture = 2, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 34, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 105, texture = 7, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 8, texture = 5, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 11, texture = 3, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = -1, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                },
                -- Gender
                [4] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'Worker',
                        outfitData = {
                        ["pants"]       = { item = 57, texture = 2, defaultItem = 0, defaultTexture = 0},  -- Pants
                        ["arms"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Arms
                        ["t-shirt"]     = { item = 34, texture = 0, defaultItem = 0, defaultTexture = 0},  -- T Shirt
                        ["vest"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Body Vest
                        ["torso2"]      = { item = 105, texture = 7, defaultItem = 0, defaultTexture = 0},  -- Jacket
                        ["shoes"]       = { item = 8, texture = 5, defaultItem = 0, defaultTexture = 0},  -- Shoes
                        ["accessory"]   = { item = 11, texture = 3, defaultItem = 0, defaultTexture = 0},  -- Neck Accessory
                        ["bag"]         = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Bag
                        ["hat"]         = { item = -1, texture = -1, defaultItem = 0, defaultTexture = 0},  -- Hat
                        ["glass"]       = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Glasses
                        ["mask"]        = { item = 0, texture = 0, defaultItem = 0, defaultTexture = 0},  -- Mask
                        }
                    }
                }
            }
        },
        ['ambulance'] = {
            -- Job
            ['male'] = {
                -- Gender
                [0] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 85, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 129, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 250, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 127, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [1] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 85, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 129, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 250, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 127, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [2] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 85, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 129, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 250, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 127, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [2] = {
                        outfitLabel = 'Polo',
                        outfitData = {
                            ['arms'] = {item = 90, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 15, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 249, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 57, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 126, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [3] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 85, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 129, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 250, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 127, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [2] = {
                        outfitLabel = 'Polo',
                        outfitData = {
                            ['arms'] = {item = 90, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 15, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 249, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 57, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 126, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [3] = {
                        outfitLabel = 'Doctor',
                        outfitData = {
                            ['arms'] = {item = 93, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 32, texture = 3, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 31, texture = 7, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 126, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 28, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 10, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = -1, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [4] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 85, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 129, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 250, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 58, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 127, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [2] = {
                        outfitLabel = 'Polo',
                        outfitData = {
                            ['arms'] = {item = 90, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 15, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 249, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 57, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 126, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 54, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 122, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [3] = {
                        outfitLabel = 'Doctor',
                        outfitData = {
                            ['arms'] = {item = 93, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 32, texture = 3, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 31, texture = 7, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 126, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 28, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 10, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = -1, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                }
            },
            ['female'] = {
                -- Gender
                [0] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 109, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 159, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 258, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 66, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 97, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [1] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 109, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 159, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 258, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 66, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 97, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [2] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 109, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 159, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 258, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 66, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 97, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [2] = {
                        outfitLabel = 'Polo',
                        outfitData = {
                            ['arms'] = {item = 105, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 13, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 257, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 65, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [3] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 109, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 159, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 258, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 66, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 97, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [2] = {
                        outfitLabel = 'Polo',
                        outfitData = {
                            ['arms'] = {item = 105, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 13, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 257, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 65, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [3] = {
                        outfitLabel = 'Doctor',
                        outfitData = {
                            ['arms'] = {item = 105, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 39, texture = 3, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 7, texture = 1, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 29, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = -1, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                },
                [4] = {
                    -- Grade Level
                    [1] = {
                        outfitLabel = 'T-Shirt',
                        outfitData = {
                            ['arms'] = {item = 109, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 159, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 258, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 66, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 97, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [2] = {
                        outfitLabel = 'Polo',
                        outfitData = {
                            ['arms'] = {item = 105, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 13, texture = 0, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 257, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 65, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 99, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 55, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = 121, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    },
                    [3] = {
                        outfitLabel = 'Doctor',
                        outfitData = {
                            ['arms'] = {item = 105, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Arms
                            ['t-shirt'] = {item = 39, texture = 3, defaultItem = 0, defaultTexture = 0}, -- T-Shirt
                            ['torso2'] = {item = 7, texture = 1, defaultItem = 0, defaultTexture = 0}, -- Jackets
                            ['vest'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Vest
                            ['decals'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Decals
                            ['accessory'] = {item = 96, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Neck
                            ['bag'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Bag
                            ['pants'] = {item = 34, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Pants
                            ['shoes'] = {item = 29, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Shoes
                            ['mask'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Mask
                            ['hat'] = {item = -1, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Hat
                            ['glass'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0}, -- Glasses
                            ['ear'] = {item = 0, texture = 0, defaultItem = 0, defaultTexture = 0} -- Ear accessories
                        }
                    }
                }
            }
        }
    }
}