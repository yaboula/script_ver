fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name '0r-imagegenerator (safe replacement)'
author 'Admirales Security Team'
version '1.0.0'
description 'Auditable compatibility replacement for 0r-imagegenerator'

shared_scripts {
    'shared/config.lua'
}

server_scripts {
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'images/placeholder.png'
}
