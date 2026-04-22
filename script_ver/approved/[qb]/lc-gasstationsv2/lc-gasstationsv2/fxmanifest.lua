fx_version 'cerulean'
game 'gta5'
author 'LixeiroCharmoso'
ui_page "nui/ui.html"
lua54 'yes'

escrow_ignore {
        'config.lua',
        'client.lua',
        'server_utils.lua',
        'lang/de.lua',
        'lang/en.lua',
        'lang/fr.lua',
        'lang/zh-cn.lua',
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
        "lang/de.lua",
        "lang/en.lua",
        "lang/fr.lua",
        "lang/zh-cn.lua",
        "config.lua",
        "@lc_utils/functions/loader.lua",
}

files {
        "nui/lang/de.js",
        "nui/lang/en.js",
        "nui/lang/fr.js",
        "nui/lang/zh-cn.js",
        "nui/ui.html",
        "nui/panel.js",
        "nui/css/bootstrap-night.css",
        "nui/css/dark-style.css",
        "nui/css/light-style.css",
        "nui/css/style.css",
        "nui/img/barril.png",
        "nui/img/caminhao.png",
        "nui/img/combustivel.png",
        "nui/img/electricfast.png",
        "nui/img/electricnormal.png",
        "nui/img/man.png",
        "nui/img/upgrades/delivery-truck.png",
        "nui/img/upgrades/manager.png",
        "nui/img/upgrades/shop.png",
        "nui/vendor/bootstrap/bootstrap.bundle.min.js",
        "nui/vendor/bootstrap/bootstrap.min.css",
        "nui/vendor/fontawesome/css/all.min.css",
        "nui/vendor/fontawesome/webfonts/fa-brands-400.ttf",
        "nui/vendor/fontawesome/webfonts/fa-brands-400.woff2",
        "nui/vendor/fontawesome/webfonts/fa-regular-400.ttf",
        "nui/vendor/fontawesome/webfonts/fa-regular-400.woff2",
        "nui/vendor/fontawesome/webfonts/fa-solid-900.ttf",
        "nui/vendor/fontawesome/webfonts/fa-solid-900.woff2",
        "nui/vendor/fontawesome/webfonts/fa-v4compatibility.ttf",
        "nui/vendor/fontawesome/webfonts/fa-v4compatibility.woff2",
        "nui/vendor/jquery/jquery-3.5.1.min.js",
        "nui/vendor/select2/select2.min.css",
        "nui/vendor/select2/select2.min.js"
}

dependency "lc_utils"
dependency '/assetpacks'
