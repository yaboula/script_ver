fx_version 'cerulean'
game 'gta5'
author 'LixeiroCharmoso'
name 'lc_fuel'

ui_page "nui/ui.html"

lua54 'yes'

escrow_ignore {
	'**'
}

client_scripts {
	"client/client.lua",
	"client/client_gas.lua",
	"client/client_electric.lua",
	"client/client_refuel.lua",
	"client/client_fuel_chart.lua",
	"client/client_fuel_type.lua",
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"server/server.lua",
}

shared_scripts {
	"lang/de.lua",
	"lang/en.lua",
	"lang/es.lua",
	"lang/fr.lua",
	"lang/ja.lua",
	"lang/tr.lua",
	"lang/zh-cn.lua",
	"config.lua",
	"@lc_utils/functions/loader.lua",
}

files {
	"version",
	"nui/lang/de.js",
	"nui/lang/en.js",
	"nui/lang/es.js",
	"nui/lang/fr.js",
	"nui/lang/ja.js",
	"nui/lang/tr.js",
	"nui/lang/zh-cn.js",
	"nui/ui.html",
	"nui/panel.js",
	"nui/scripts/chartjs-plugin-streaming@2.0.0",
	"nui/css/style.css",
	"nui/images/electric_charger.png",
	"nui/images/electric_charger_display.png",
	"nui/images/gas_pump.png",
	"nui/images/gas_refuel_display.png",
	"nui/images/jerry_can.png",
	"nui/images/prop_gas_pump_1a.png",
	"nui/images/prop_gas_pump_1b.png",
	"nui/images/prop_gas_pump_1c.png",
	"nui/images/prop_gas_pump_1d.png",
	"nui/fonts/Technology.woff",
}

dependency "lc_utils"
provides 'LegacyFuel'

data_file 'DLC_ITYP_REQUEST' 'stream/prop_electric_01.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/prop_eletricpistol.ytyp'