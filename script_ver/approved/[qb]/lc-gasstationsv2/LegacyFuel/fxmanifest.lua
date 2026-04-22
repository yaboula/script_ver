






fx_version 'bodacious'

game 'gta5'

author 'InZidiuZ'

description 'Legacy Fuel'

version '1.3'

ui_page 'html/ui.html'

lua54 'yes'

escrow_ignore {
	'config.lua',

}

client_scripts {

	'config.lua',

	'functions/functions_client.lua',

	'source/fuel_client.lua'

}

server_scripts {

	'config.lua',

	'source/fuel_server.lua'

}

exports {

	'GetFuel',

	'SetFuel'

}

files {

	'html/ui.html',

	'html/ui.css', 

	'html/logo.png',

	'html/ui.js',

	'html/vendor/jquery/jquery-3.5.1.min.js'

}

dependency "lc_utils"

dependency '/assetpacks'







