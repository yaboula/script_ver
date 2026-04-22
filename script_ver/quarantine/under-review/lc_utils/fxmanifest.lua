fx_version 'cerulean'
game 'gta5'
author 'LixeiroCharmoso'

ui_page "nui/index.html"

lua54 'yes'

client_scripts {
        "functions/client/callback.lua",
        "functions/client/main.lua",
        "custom_scripts/client/custom_core.lua",
        "custom_scripts/client/custom_draw_text.lua",
        "custom_scripts/client/custom_inventory.lua",
        "custom_scripts/client/custom_keys.lua",
        "custom_scripts/client/custom_notify.lua",
        "custom_scripts/client/custom_progressbar.lua",
        "custom_scripts/client/custom_target.lua",
        "frameworks/qbcore/client.lua",
        "frameworks/esx/client.lua"
}

server_scripts {
        "@mysql-async/lib/MySQL.lua",
        "functions/server/callback.lua",
        "functions/server/database.lua",
        "functions/server/main.lua",
        "functions/server/webhook.lua",
        "custom_scripts/server/custom_core.lua",
        "custom_scripts/server/custom_discord.lua",
        "custom_scripts/server/custom_inventory.lua",
        "custom_scripts/server/custom_notify.lua",
        "frameworks/qbcore/server.lua",
        "frameworks/esx/server.lua"
}

shared_scripts {
        "config.lua",
        "functions/shared.lua",
        "lang/br.lua",
        "lang/de.lua",
        "lang/en.lua",
        "lang/es.lua",
        "lang/fr.lua",
        "lang/ja.lua",
        "lang/no.lua",
        "lang/zh-cn.lua"
}

files {
        "version",
        "functions/loader.lua",
        "nui/index.html",
        "nui/index.js",
        "nui/js/notifying.js",
        "nui/js/progressbar.js",
        "nui/css/dark-style.css",
        "nui/css/light-style.css",
        "nui/css/nav.css",
        "nui/css/progressbar.css",
        "nui/css/style.css",
        "nui/css/toast.css"
}
