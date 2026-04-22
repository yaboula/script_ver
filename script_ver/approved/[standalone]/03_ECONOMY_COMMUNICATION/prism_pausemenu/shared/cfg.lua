CFG = {
    Framework = "qb", -- "auto", "esx", "qb", "qbox"
    Locale = "en", -- Language: en, es, fr, de, pt, ru
    Debug = false,

    --"qbcore", "qbox", "rcore_gangs", "op-crime", "brutals_gangs", "rk_factions" string and custom exports
    GetGangFunction = "No gang",

    KeyBind = {
        Command = 'pauseMenu',
        Key = 'ESCAPE',
    },

    EnabledCam = false,

    Anim = {
        Enabled = false,
        AnimName = "base",
        DictName = "amb@world_human_tourist_map@male@base",
        PropName = "prop_tourist_map_01"
    },

    Style = {
        primaryColor = "#FF0000",
        primaryColorBackground = "#FF00001A",
        gradientColor = "rgba(255, 0, 0, 0.329)"
    },
    Links = {
        discord = "https://discord.gg/4VCfxNWZT8"
    },

    FixAnimationCommands = "fixanim"
}

CFG.CheckLocales = function()
    print("[PRISM PAUSEMENU] Current locale: " .. CFG.Locale)
    print("[PRISM PAUSEMENU] Available locales:")
    for locale, _ in pairs(Locales) do
        print("  - " .. locale)
    end
    if Locales[CFG.Locale] then
        print("[PRISM PAUSEMENU] Locale loaded successfully")
    else
        print("[PRISM PAUSEMENU] Locale not found, falling back to 'en'")
    end
end


CFG.isPlayerDead  = function()
    return IsEntityDead(PlayerPedId()) 
end

CFG.AutoDetectFramework = function()
    if CFG.Framework and CFG.Framework ~= "auto" then
        print("[PRISM PAUSEMENU] Framework manually configured: " .. CFG.Framework)
        return CFG.Framework
    end
    
    local detectedFramework = "unknown"
    
    if GetResourceState('es_extended') == 'started' then
        detectedFramework = "esx"
        print("[PRISM PAUSEMENU] Framework auto-detected: ESX")
    
    elseif GetResourceState('qbx_core') == 'started' then
        detectedFramework = "qbox"
        print("[PRISM PAUSEMENU] Framework auto-detected: QBox")


    elseif GetResourceState('qb-core') == 'started' then
        detectedFramework = "qb"
        print("[PRISM PAUSEMENU] Framework auto-detected: QB-Core")
    
    else
        print("[PRISM PAUSEMENU] No supported framework detected!")
        print("[PRISM PAUSEMENU] Supported frameworks: ESX, QB-Core, QBox")
        print("[PRISM PAUSEMENU] You can manually specify the framework in shared/cfg.lua")
    end
    
    CFG.Framework = detectedFramework
    
    return detectedFramework
end

CFG.DetectedFramework = CFG.AutoDetectFramework()

CFG.CheckLocales()

function DebugPrint(message)
    if CFG.Debug then
        print("[PRISM PAUSEMENU DEBUG] " .. tostring(message))
    end
end

