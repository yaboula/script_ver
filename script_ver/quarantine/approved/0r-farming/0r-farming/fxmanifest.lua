fx_version "adamant"
game "gta5"

ui_page 'html/index.html'

files {
  "html/img/bg.png",
  "html/img/budayalt.png",
  "html/img/budayust.png",
  "html/img/buy.png",
  "html/img/churn.png",
  "html/img/close.png",
  "html/img/cowpng.png",
  "html/img/cow_alt.png",
  "html/img/cow_orta.png",
  "html/img/fare.png",
  "html/img/gereksiz.png",
  "html/img/karpuzalt.png",
  "html/img/karpuzgereksiz.png",
  "html/img/kiyafet.png",
  "html/img/kutucukbuday.png",
  "html/img/kutucukcow.png",
  "html/img/kutucukkarpuz.png",
  "html/img/kutucukpump.png",
  "html/img/melon.png",
  "html/img/melonseed.png",
  "html/img/milkbottle.png",
  "html/img/pumpalt.png",
  "html/img/pumpkin.png",
  "html/img/pumpkinseed.png",
  "html/img/pumpust.png",
  "html/img/raker.png",
  "html/img/readme.txt",
  "html/img/sariarkplan.png",
  "html/img/sell.png",
  "html/img/sepetteki.png",
  "html/img/shovel.png",
  "html/img/sol.png",
  "html/img/tabler_minus.svg",
  "html/img/ustkarpuz.png",
  "html/img/wateringcan.png",
  "html/img/wheat.png",
  "html/img/wheatseed.png",
  "html/index.html",
  "html/script.js",
  "html/style.css"
}

shared_scripts {
  '@ox_lib/init.lua',
  "shared/Language.lua",
  "shared/config.lua",
  "shared/sh_cow.lua",
  "shared/sh_main.lua",
  "shared/sh_melon.lua",
  "shared/sh_pumpkin.lua",
  "shared/sh_wheat.lua"
}

client_scripts {
  "client/cl_cow.lua",
  "client/cl_main.lua",
  "client/cl_melon.lua",
  "client/cl_pumpkin.lua",
  "client/cl_wheat.lua"
}

server_scripts {
  "server/sv_cow.lua",
  "server/sv_main.lua",
  "server/sv_melon.lua",
  "server/sv_pumpkin.lua",
  "server/sv_wheat.lua"
}

lua54 'yes'

escrow_ignore {
  "shared/Language.lua",
  "shared/config.lua",
  "shared/sh_cow.lua",
  "shared/sh_main.lua",
  "shared/sh_melon.lua",
  "shared/sh_pumpkin.lua",
  "shared/sh_wheat.lua",
  "server/sv_cow.lua",
  "server/sv_main.lua",
  "server/sv_melon.lua",
  "server/sv_pumpkin.lua",
  "server/sv_wheat.lua",
  "client/cl_cow.lua",
  "client/cl_main.lua",
  "client/cl_melon.lua",
  "client/cl_pumpkin.lua",
  "client/cl_wheat.lua"
}
dependency '/assetpacks'