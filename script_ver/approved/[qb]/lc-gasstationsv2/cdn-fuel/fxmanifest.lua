






fx_version 'cerulean'

game 'gta5'

author 'https://www.github.com/CodineDev'
description 'cdn-fuel'

version '2.1.9'

client_scripts {

    '@PolyZone/client.lua',

    'client/fuel_cl.lua',

    'client/electric_cl.lua',

    'client/station_cl.lua',

    'client/utils.lua'

}

server_scripts {

    'server/fuel_sv.lua',

    'server/station_sv.lua',

    'server/electric_sv.lua',

    '@oxmysql/lib/MySQL.lua',

}

shared_scripts {

    'shared/config.lua',

    '@qb-core/shared/locale.lua',

    'locales/en.lua',
}

exports {
    'GetFuel',

    'SetFuel'

}

lua54 'yes'

escrow_ignore {
    'shared/config.lua',
    'locales/de.lua',
    'locales/ee.lua',
    'locales/en.lua',
    'locales/es.lua',
    'locales/fr.lua',

}

dependencies {
    'PolyZone',

    'interact-sound',

    'qb-target',

    'qb-input',

    'qb-menu',

    'lc_utils',

}

data_file 'DLC_ITYP_REQUEST' 'stream/[electric_nozzle]/electric_nozzle_typ.ytyp'

data_file 'DLC_ITYP_REQUEST' 'stream/[electric_charger]/electric_charger_typ.ytyp'

provide 'cdn-syphoning'
dependency '/assetpacks'







