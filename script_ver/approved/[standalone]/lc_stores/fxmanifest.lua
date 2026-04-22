fx_version 'cerulean'
game 'gta5'
author 'LixeiroCharmoso'

ui_page "nui/ui.html"

lua54 'yes'

escrow_ignore {
        'config.lua',
        'client.lua',
        'server_utils.lua',
        'lang/br.lua',
        'lang/de.lua',
        'lang/en.lua',
}

client_scripts {
        "client.lua",
}

server_scripts {
        "@mysql-async/lib/MySQL.lua",
        "server_utils.lua",
        "server.lua",
}

shared_scripts {
        "config.lua",
        "@lc_utils/functions/loader.lua",
        'lang/br.lua',
        'lang/de.lua',
        'lang/en.lua',
}

files {
        "nui/ui.html",
        "nui/panel.js",
        "nui/lang/br.js",
        "nui/lang/de.js",
        "nui/lang/en.js",
        "nui/css/bootstrap-night.css",
        "nui/css/dark-style.css",
        "nui/css/light-style.css",
        "nui/css/style.css",
        "nui/img/cash.png",
        "nui/img/credit_card.png",
        "nui/img/man.png",
        "nui/img/categories/alcohol-icon.png",
        "nui/img/categories/alcohol.png",
        "nui/img/categories/drinks-icon.png",
        "nui/img/categories/drinks.png",
        "nui/img/categories/electronics-icon.png",
        "nui/img/categories/electronics.png",
        "nui/img/categories/food-icon.png",
        "nui/img/categories/food.png",
        "nui/img/categories/utilities-icon.png",
        "nui/img/categories/utilities.png",
        "nui/img/categories/weapons-ammo-icon.png",
        "nui/img/categories/weapons-ammo.png",
        "nui/img/categories/weapons-attachments.png",
        "nui/img/categories/weapons-melee-icon.png",
        "nui/img/categories/weapons-melee.png",
        "nui/img/categories/weapons-other-icon.png",
        "nui/img/categories/weapons-other.png",
        "nui/img/categories/weapons-pistol-icon.png",
        "nui/img/categories/weapons-pistol.png",
        "nui/img/categories/weapons-rifle-icon.png",
        "nui/img/categories/weapons-rifle.png",
        "nui/img/categories/weapons-shotgun-icon.png",
        "nui/img/categories/weapons-shotgun.png",
        "nui/img/categories/weapons-smg-icon.png",
        "nui/img/categories/weapons-smg.png",
        "nui/img/categories/weapons-sniper.png",
        "nui/img/categories/weapons-throwable-icon.png",
        "nui/img/categories/weapons-throwable.png",
        "nui/img/items/armor.png",
        "nui/img/items/beer.png",
        "nui/img/items/cleaningkit.png",
        "nui/img/items/coffee.png",
        "nui/img/items/cola.png",
        "nui/img/items/grapejuice.png",
        "nui/img/items/iphone.png",
        "nui/img/items/laptop.png",
        "nui/img/items/parachute.png",
        "nui/img/items/phone.png",
        "nui/img/items/pistol_ammo.png",
        "nui/img/items/radio.png",
        "nui/img/items/repairkit.png",
        "nui/img/items/rifle_ammo.png",
        "nui/img/items/samsungphone.png",
        "nui/img/items/sandwich.png",
        "nui/img/items/screwdriverset.png",
        "nui/img/items/shotgun_ammo.png",
        "nui/img/items/smg_ammo.png",
        "nui/img/items/snikkel_candy.png",
        "nui/img/items/tablet.png",
        "nui/img/items/tosti.png",
        "nui/img/items/twerks_candy.png",
        "nui/img/items/vodka.png",
        "nui/img/items/water_bottle.png",
        "nui/img/items/weapon_assaultrifle.png",
        "nui/img/items/weapon_bat.png",
        "nui/img/items/weapon_carbinerifle.png",
        "nui/img/items/weapon_crowbar.png",
        "nui/img/items/weapon_flare.png",
        "nui/img/items/weapon_flaregun.png",
        "nui/img/items/weapon_hammer.png",
        "nui/img/items/weapon_knife.png",
        "nui/img/items/weapon_microsmg.png",
        "nui/img/items/weapon_molotov.png",
        "nui/img/items/weapon_pistol.png",
        "nui/img/items/weapon_pumpshotgun.png",
        "nui/img/items/weapon_smg.png",
        "nui/img/items/weapon_snspistol.png",
        "nui/img/items/weapon_vintagepistol.png",
        "nui/img/items/weapon_wrench.png",
        "nui/img/items/whiskey.png",
        "nui/img/items/wine.png",
        "nui/img/upgrades/delivery-truck.png",
        "nui/img/upgrades/manager.png",
        "nui/img/upgrades/shop.png",
}

dependency "lc_utils"
dependency "/assetpacks"
