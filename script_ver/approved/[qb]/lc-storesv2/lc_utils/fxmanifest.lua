--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

fx_version 'cerulean'

game 'gta5'

author 'LixeiroCharmoso'

ui_page "nui/index.html"

lua54 'yes'

client_scripts {

	"functions/client/*.lua",

	"custom_scripts/client/*.lua",

	"frameworks/qbcore/client.lua",

	"frameworks/esx/client.lua",

}

server_scripts {

	"@mysql-async/lib/MySQL.lua",

	"functions/server/*.lua",

	"custom_scripts/server/*.lua",

	"frameworks/qbcore/server.lua",

	"frameworks/esx/server.lua",

}

shared_scripts {

	"config.lua",

	"functions/shared.lua",

	"lang/*.lua"

}

files {
	'functions/loader.lua',
	'nui/css/dark-style.css',
	'nui/css/light-style.css',
	'nui/css/navigation-tabs.css',
	'nui/css/progress.css',
	'nui/css/style.css',
	'nui/css/tooltip.css',
	'nui/index.html',
	'nui/index.js',
	'nui/js/notification.js',
	'nui/js/progress.js',
	'nui/vendor/jquery/jquery-3.5.1.min.js',
	'version'
}

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

