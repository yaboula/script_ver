-- $$\   $$\  $$$$$$\  $$\   $$\ $$\   $$\ $$$$$$$\  
-- $$$\  $$ |$$  __$$\ $$ |  $$ |$$ |  $$ |$$  __$$\ 
-- $$$$\ $$ |$$ /  \__|$$ |  $$ |$$ |  $$ |$$ |  $$ |
-- $$ $$\$$ |$$ |      $$$$$$$$ |$$ |  $$ |$$$$$$$\ |
-- $$ \$$$$ |$$ |      $$  __$$ |$$ |  $$ |$$  __$$\ 
-- $$ |\$$$ |$$ |  $$\ $$ |  $$ |$$ |  $$ |$$ |  $$ |
-- $$ | \$$ |\$$$$$$  |$$ |  $$ |\$$$$$$  |$$$$$$$  |
-- \__|  \__| \______/ \__|  \__| \______/ \_______/  
-- Discord.gg/sgx & Patreon.com/NCHub
fx_version 'cerulean'
game 'gta5'

description 'nc-multicharacter'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    -- [AUDIT AUD-001] H-04: wildcard 'locales/*.lua' eliminado, declaracion explicita arriba
    'config.lua'
}
client_script 'client/main.lua'
server_scripts  {
    '@oxmysql/lib/MySQL.lua',
    '@qb-apartments/config.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

-- [AUDIT AUD-001] H-04: Wildcards reemplazados por declaraciones explicitas
files {
    'html/image/action_key.png',
    'html/image/action_dot.gif',
    'html/js/script.js',
    'html/js/materialize.js',
    'html/index.html',
    'html/css/reset.css',
    'html/css/style.css',
}

dependencies {
    'qb-core'
}
