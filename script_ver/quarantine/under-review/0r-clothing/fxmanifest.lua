fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '1.0.1'
escrow_ignore {
    'shared/*.lua',
    'converter/*.lua',
    'client/*.lua',
    'server/*.lua',
    'locales/*.lua',
    'client/core.lua',
    'server/core.lua'
}
shared_scripts {
	'shared/cores.lua',
    'shared/locale.lua',
    'locales/en.lua',
    'shared/config.lua',
    'shared/peds.lua'
}
client_scripts {
	'client/core.lua',
    'client/main.lua',
    'client/maskfix.lua',
    'converter/esx_skin.lua',
    'converter/fivem-appearance.lua',
    'converter/illenium-appearance.lua',
    'converter/qb-clothing.lua',
    'converter/skinchanger.lua'
}
server_scripts {
    '@oxmysql/lib/MySQL.lua',
	'server/core.lua',
	'server/main.lua'
}
ui_page 'html/index.html'
files {'html/**', 'AllTattoos.json'}
dependencies {
    '0r-imagegenerator',
    '/assetpacks'
}