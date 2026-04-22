
fx_version 'cerulean'
game 'gta5'

description 'qb-bossmenu'
version '2.0.0'

client_scripts {
    'config.lua',
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

server_exports {
    'AddMoney',
    'AddGangMoney',
    'RemoveMoney',
    'RemoveGangMoney',
    'GetAccount',
    'GetGangAccount',
}

server_export "GetAccount"
server_export "RemoveMoney"
lua54 'yes'
