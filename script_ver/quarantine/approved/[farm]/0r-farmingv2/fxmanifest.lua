fx_version "cerulean"
lua54 "yes"
game "gta5"
name "0r-farming-v2"
author "0resmon & alikoc.dev"
version "1.1.7"
description "Farming | alikoc.dev"

shared_scripts {
    'components/utils_lib.js',
	"@ox_lib/init.lua",
	"config.lua",
	"shared/init.lua",
}

files {
	"locales/en.json",
	"modules/bridge/init.lua",
	"modules/bridge/esx/client.lua",
	"modules/bridge/qb/client.lua",
	"modules/bridge/qbx/client.lua",
	"modules/exports/client.lua",
	"modules/target/client.lua",
	"modules/utils/client.lua",
	"core/market/config.lua",
	"core/multiplayer_tasks/freelance/config.lua",
	"core/multiplayer_tasks/livestock_farming/config.lua",
	"core/multiplayer_tasks/melon_pumpkin/config.lua",
	"core/personal_challenges/config.lua",
	"ui/build/index.html",
	"ui/build/assets/index-DR3FTflN.js",
	"ui/build/assets/index-Yod9b-0a.css",
	"ui/build/images/common/farmer2.png",
	"ui/build/images/common/farmer_new.png",
	"ui/build/images/common/freelance.png",
	"ui/build/images/common/izgara_cart_item.png",
	"ui/build/images/common/izgara_header.png",
	"ui/build/images/common/izgara_information_left.png",
	"ui/build/images/common/izgara_market_item.png",
	"ui/build/images/common/livestock_farming.png",
	"ui/build/images/common/melon_pumpkin.png",
	"ui/build/images/icons/exp.svg",
	"ui/build/images/icons/money.svg",
	"ui/build/images/icons/prism.png",
	"ui/build/items/daisy.png",
	"ui/build/items/daisy_seed.png",
	"ui/build/items/default.png",
	"ui/build/items/farming_tablet.png",
	"ui/build/items/green.png",
	"ui/build/items/green_seed.png",
	"ui/build/items/melon.png",
	"ui/build/items/melon_seed.png",
	"ui/build/items/poppy.png",
	"ui/build/items/poppy_seed.png",
	"ui/build/items/pumpkin.png",
	"ui/build/items/pumpkin_seed.png",
	"ui/build/items/rose.png",
	"ui/build/items/rose_seed.png",
	"ui/build/items/watering_can.png",
	"ui/build/items/watermelon.png",
	"ui/build/items/watermelon_seed.png",
	"ui/build/items/wheat.png",
	"ui/build/items/wheat_seed.png"
}

client_scripts {
	"core/lobby/client.lua",
	"core/market/client.lua",
	"core/multiplayer_tasks/client_index.lua",
	"core/multiplayer_tasks/freelance/client.lua",
	"core/multiplayer_tasks/livestock_farming/client.lua",
	"core/multiplayer_tasks/melon_pumpkin/client.lua",
	"core/personal_challenges/client.lua",
	"core/profile/client.lua",
	"client.lua"
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"core/lobby/server.lua",
	"core/market/server.lua",
	"core/multiplayer_tasks/server_index.lua",
	"core/multiplayer_tasks/freelance/server.lua",
	"core/multiplayer_tasks/livestock_farming/server.lua",
	"core/multiplayer_tasks/melon_pumpkin/server.lua",
	"core/personal_challenges/server.lua",
	"core/profile/server.lua",
	"server.lua"
}

ui_page "ui/build/index.html"

dependencies { "ox_lib", "oxmysql", "0r_lib" }

escrow_ignore {
	"config.lua",
	"shared/**/*.lua",
	"modules/**/*.lua",
	"core/**/config.lua",
}

dependency '/assetpacks'