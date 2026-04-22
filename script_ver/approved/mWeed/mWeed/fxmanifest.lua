fx_version 'cerulean'
game 'gta5'
description 'mWeed'
lua54 'yes'
author 'Lucid#3604'
version '1.3'

shared_scripts {
    'shared/GetCore.lua',
    'shared/config.lua',
}

client_scripts {
	'client/animations.lua',
	'client/dealer.lua',
	'client/editable.lua',
	'client/interaction.lua',
	'client/main.lua',
	'client/PlayerLoaded.lua',
	'client/weed.lua',
}

server_scripts {
	'server/botToken.lua',
	'server/dealer.lua',
	'server/main.lua',
	'server/weed.lua',
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/app/*.js',
	'html/app/components/*.js',
	'html/app/modules/*.js',	
	'html/app/utils/*.js',	
	'html/app/pages/**/*.js',
	'html/app/pages/**/*.html',	
	'html/css/*.css',
	'html/assets/fonts/*.otf',
	'html/assets/fonts/*.ttf',
	'html/assets/sounds/*.MP3',
	'html/assets/sounds/*.wav',
	'html/assets/images/*.png',
	'html/assets/item_images/*.png',

}

dependency '/assetpacks'