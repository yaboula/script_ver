fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'
author 'Prism Scripts - Zykem'
version '1.2.1'
dependency 'ox_lib'
file 'init.lua'
file 'config_init.lua'
client_scripts {
    'modules/utils.lua',
    'modules/notify.lua',
    'modules/textui.lua',
    'modules/progress.lua',
    'modules/radial.lua',
    'modules/skillcheck.lua',
    'modules/dialog.lua',
    'modules/context.lua',
    'modules/alert.lua',
    'modules/menu.lua',
    'main.lua'
}
ui_page 'web/build/index.html'
files {
    'web/build/index.html',
    'web/build/assets/index-BgkLwDpx.css',
    'web/build/assets/index-Dk9MkoH6.js',
    'web/build/fonts/Roboto-Black.ttf',
    'web/build/fonts/Roboto-BlackItalic.ttf',
    'web/build/fonts/Roboto-Bold.ttf',
    'web/build/fonts/Roboto-BoldItalic.ttf',
    'web/build/fonts/Roboto-ExtraBold.ttf',
    'web/build/fonts/Roboto-ExtraBoldItalic.ttf',
    'web/build/fonts/Roboto-ExtraLight.ttf',
    'web/build/fonts/Roboto-ExtraLightItalic.ttf',
    'web/build/fonts/Roboto-Italic.ttf',
    'web/build/fonts/Roboto-Light.ttf',
    'web/build/fonts/Roboto-LightItalic.ttf',
    'web/build/fonts/Roboto-Medium.ttf',
    'web/build/fonts/Roboto-MediumItalic.ttf',
    'web/build/fonts/Roboto-Regular.ttf',
    'web/build/fonts/Roboto-SemiBold.ttf',
    'web/build/fonts/Roboto-SemiBoldItalic.ttf',
    'web/build/fonts/Roboto-Thin.ttf',
    'web/build/fonts/Roboto-ThinItalic.ttf',
    'web/build/fonts/RobotoMono-Bold.ttf',
    'web/build/fonts/RobotoMono-BoldItalic.ttf',
    'web/build/fonts/RobotoMono-ExtraLight.ttf',
    'web/build/fonts/RobotoMono-ExtraLightItalic.ttf',
    'web/build/fonts/RobotoMono-Italic.ttf',
    'web/build/fonts/RobotoMono-Light.ttf',
    'web/build/fonts/RobotoMono-LightItalic.ttf',
    'web/build/fonts/RobotoMono-Medium.ttf',
    'web/build/fonts/RobotoMono-MediumItalic.ttf',
    'web/build/fonts/RobotoMono-Regular.ttf',
    'web/build/fonts/RobotoMono-SemiBold.ttf',
    'web/build/fonts/RobotoMono-SemiBoldItalic.ttf',
    'web/build/fonts/RobotoMono-Thin.ttf',
    'web/build/fonts/RobotoMono-ThinItalic.ttf'
}
escrow_ignore {
    'config_init.lua'
}
dependency '/assetpacks'