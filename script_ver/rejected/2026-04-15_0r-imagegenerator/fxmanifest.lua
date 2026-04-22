fx_version 'cerulean'
game 'gta5'
lua54 'yes'
ui_page 'html/index.html'
files {'html/**', 'images/**'}
escrow_ignore {
    'shared/cores.lua',
    'shared/config.lua'
}
shared_scripts {
    'shared/cores.lua',
    'shared/config.lua'
}
client_scripts {
    'client/*.lua'
}
server_scripts {
    'shared/config_sv.lua',
    'server/*.lua'
}
dependencies {'0r-imagegenerator-map', 'screenshot-basic'}
dependency '/assetpacks'