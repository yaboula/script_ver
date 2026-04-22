fx_version 'cerulean'
game 'gta5'

author 'daniworld & DANI-WORLD'
description 'nc-Banking - Advanced Banking System'
version '1.0.0'

ui_page 'html/index.html'

shared_script 'config_loader.lua'
file 'config.json'

client_scripts {
    'client/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/assets/*.png',
}

lua54 'yes'

escrow_ignore {
    'config.json',
    'config_loader.lua',
    'README.md'
}

dependency 'qb-core'