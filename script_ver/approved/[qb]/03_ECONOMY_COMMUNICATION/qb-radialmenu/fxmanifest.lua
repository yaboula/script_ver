fx_version 'adamant'
games { 'gta5' }
client_script {
  "@qb-polyzone/client/cl_main.lua",
  "@qb-garages/config.lua",
    "config.lua",
    "client_menu.lua",
	"utils.lua"
}
server_scripts{
  "sv_main.lua"
}
ui_page "nui/dist/index.html"
files {
  "nui/dist/*",
  "nui/dist/index.html",
	"nui/dist/assets/*",
}

shared_script "@qb-core/config.lua"