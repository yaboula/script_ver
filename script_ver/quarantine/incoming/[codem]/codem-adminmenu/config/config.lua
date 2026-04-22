Config = {}
Config.Framework = "qb" -- esx, oldesx, qb, oldqb
Config.SQL = "oxmysql"  -- oxmysql, ghmattimysql, mysql-async
Config.ItemImagesFolder = "nui://qb-inventory/web/images/"
Config.ExampleProfilePicture =
"https://cdn.discordapp.com/attachments/983471660684423240/1147567519712940044/example-pp.png"
Config.Inventory =
"qb_inventory"                                        -- qb_inventory , esx_inventory , ox_inventory , codem-inventory, qs_inventory
Config.ClothingMenu =
"illenium-appearance"                                         -- fivem-appearance -- illenium-appearance -- codem-appearance -- esx_skin - -qb-clothing

Config.RegisterKeyMapping = true                      -- true / false
Config.KeyMapping = "F11"                          -- keymapping name
Config.NotRegisterKeyMapping = 316                    -- if you want to register more than one keymapping, you can add it here -- https://docs.fivem.net/docs/game-references/controls/

Config.Ban_Message = "You are banned from the server" -- Ban message

Config.CodemVipSystem = false                         -- true / false

Config.AdminDuty = false                              -- Make it true if you want admins to comply with certain conditions before taking action

Config.FuelSystem = "LegacyFuel"                      -- LegacyFuel / x-fuel

Config.SetAdminMenuCommand = "setadmin"      -- Set Admin Menu Command

Config.SetVehicleFuel = function(vehicle, fuel_level) -- you can change LegacyFuel export if you use another fuel system
    -- if Config.FuelSystem == "LegacyFuel" then
    --     return exports["LegacyFuel"]:SetFuel(vehicle, fuel_level)
    -- elseif Config.FuelSystem == "x-fuel" then
    --     return exports["x-fuel"]:SetFuel(vehicle, fuel_level)
    -- else
        return SetVehicleFuelLevel(vehicle, fuel_level + 0.0)
    -- end
end

Config.Vehiclekey = true
Config.VehicleSystem = "qb-vehiclekeys"        -- cd_garage / qs-vehiclekeys / wasabi-carlock / qb-vehiclekeys

Config.GiveVehicleKey = function(plate, model) -- you can change vehiclekeys export if you use another vehicle key system
    if Config.Vehiclekey then
        if Config.VehicleSystem == "cd_garage" then
            TriggerEvent("cd_garage:AddKeys", exports["cd_garage"]:GetPlate(vehicle))
        elseif Config.VehicleSystem == "qs-vehiclekeys" then
            exports["qs-vehiclekeys"]:GiveKeys(plate, model)
        elseif Config.VehicleSystem == "wasabi-carlock" then
            exports.wasabi_carlock:GiveKey(plate)
        elseif Config.VehicleSystem == "qb-vehiclekeys" then
            TriggerServerEvent("qb-vehiclekeys:server:AcquireVehicleKeys", plate)
        end
    end
end

Config.AllowPermission = {
    { name = "allpermission",      icon = "allpermissionicon",      label = "All Permission" },
    { name = "giveperm",           icon = "givepermicon",           label = "Give Permission" },
    { name = "revive",             icon = "reviveicon",             label = "Revive" },
    { name = "invisible",          icon = "invicibleicon",          label = "Invisible" },
    { name = "cleararea",          icon = "clearareaicon",          label = "Clear Area" },
    { name = "clearvehicle",       icon = "clearvehicleicon",       label = "Clear Vehicle" },
    { name = "playername",         icon = "playernameicon",         label = "Player Name" },
    { name = "noclip",             icon = "noclipicon",             label = "Noclip" },
    { name = "godmode",            icon = "godmodeicon",            label = "Godmode" },
    { name = "heal",               icon = "healicon",               label = "Heal" },
    { name = "repairvehicle",      icon = "repairvehicleicon",      label = "Repair Vehicle" },
    { name = "gastank",            icon = "gastankicon",            label = "Gas Tank" },
    { name = "announcement",       icon = "announcementicon",       label = "Announcement" },
    { name = "kill",               icon = "killicon",               label = "Kill" },
    { name = "freeze",             icon = "freezeicon",             label = "Freeze" },
    { name = "openinventory",      icon = "openinventoryicon",      label = "Open Inventory" },
    { name = "copyvector3",        icon = "copyvectoricon",         label = "Copy Vector3" },
    { name = "copyvector4",        icon = "copyvector4icon",        label = "Copy Vector4" },
    { name = "copyxyz",            icon = "copyvector4icon",        label = "Copy XYZ" },
    { name = "armor",              icon = "armoricon",              label = "Armor" },
    { name = "copyheading",        icon = "copyheadingicon",        label = "Copy Heading" },
    { name = "showcoords",         icon = "showcoordsicon",         label = "Show Coords" },
    { name = "devlaser",           icon = "devlasericon",           label = "Dev Laser" },
    { name = "givevehicle",        icon = "givevehicleicon",        label = "Give Vehicle" },
    { name = "addvehicletoplayer", icon = "addvehicletoplayericon", label = "Add Vehicle To Player" },
    { name = "changejob",          icon = "changejobicon",          label = "Change Job" },
    { name = "giveitem",           icon = "giveitemicon",           label = "Give Item" },
    { name = "addmoney",           icon = "addmoneyicon",           label = "Add Money" },
    { name = "sendpm",             icon = "sendpmicon",             label = "Send PM" },
    { name = "playerinfo",         icon = "playerinfoicon",         label = "Player Info" },
    { name = "goto",               icon = "gotoicon",               label = "Go to" },
    { name = "bring",              icon = "bringicon",              label = "Bring" },
    { name = "spectate",           icon = "spectateicon",           label = "Spectate" },
    { name = "giveclothingmenu",   icon = "giveclothingmenuicon",   label = "Give Clothing Menu" },
    { name = "takescreenshot",     icon = "takescreenshoticon",     label = "Take Screenshot" },
    { name = "kick",               icon = "kickicon",               label = "Kick Player" },
    { name = "ban",                icon = "banicon",                label = "Ban Player" },
    { name = "allkick",            icon = "kickicon",               label = "All Kick Player" },
    { name = "adminduty",          icon = "adminoutfiticon",        label = "Admin Duty" },
    { name = "weather",            icon = "weathericon",            label = "Weather" },
    { name = "servertime",         icon = "servertimeicon",         label = "Server Time" },
    { name = "clearinventory",     icon = "clearinventoryicon",     label = "Clear Inventory" },
    { name = "offlineban",         icon = "banicon",                label = "Offline Ban" },
    { name = "bannedplayers",      icon = "bannedplayersicon",      label = "Banned Players" },
}

Config.OnlineOverviews = {
    { name = "admin",     label = "Admin",     count = 0, icon = "onlineadminicon" },
    { name = "police",    label = "Police",    count = 0, icon = "onlinepoliceicon" },
    { name = "ambulance", label = "Ambulance", count = 0, icon = "onlineemsicon" },
    { name = "mechanic",  label = "Mechanic",  count = 0, icon = "onlinemechanicicon" }
}

Config.playerinfoCategory = {
    { name = "general",   label = "General" },
    { name = "inventory", label = "Inventory" },
    { name = "vehicles",  label = "Vehicles" },
    { name = "warns",     label = "Warns" }
}

Config.NoclipDesc = {
    { keybind = "W",          label = "Forward" },
    { keybind = "S",          label = "Backward" },
    { keybind = "A",          label = "Left" },
    { keybind = "D",          label = "Right" },
    { keybind = "Q",          label = "Up" },
    { keybind = "E",          label = "Down" },
    { keybind = "LShift",     label = "Speed" },
    { keybind = "MOUSEWHEEL", label = "Adjust Speed" }
}

Config.LaserKeybind = {
    { keybind = "G", label = "Copy Coords" },
    { keybind = "H", label = "Delete" }
}

Config.WeatherOption = {
    { name = "extrasunny", label = "Extra Sunny" },
    { name = "clear",      label = "Clear" },
    { name = "neutral",    label = "Neutral" },
    { name = "smog",       label = "Smog" },
    { name = "foggy",      label = "Foggy" },
    { name = "overcast",   label = "Snow" },
    { name = "clearing",   label = "Clearing" },
    { name = "rain",       label = "Rain" },
    { name = "thunder",    label = "Thunder" },
    { name = "snow",       label = "Snow" },
    { name = "blizzard",   label = "Blizzard" },
    { name = "halloween",  label = "Halloween" }
}

Config.BanSettings = {
    { label = "Hours", type = "hours", value = 1 },
    { label = "Hours", type = "hours", value = 2 },
    { label = "Hours", type = "hours", value = 6 },
    { label = "Hours", type = "hours", value = 12 },
    { label = "Day",   type = "day",   value = 1 },
    { label = "Day",   type = "day",   value = 2 },
    { label = "Day",   type = "day",   value = 5 },
    { label = "Day",   type = "day",   value = 7 },
    { label = "Perma", type = "perma", value = "" }
}

Config.mainCategory = {
    {
        name = "adminoption",
        label = "Admin Options",
        elements = {
            { name = "searchbaradmin" },
            { name = "announcement",  label = "Announcement",     icon = "announcementicon",  functionname = "CodemAdminMenuAnnouncement" },
            { name = "revive",        label = "Revive",           icon = "reviveicon",        functionname = "CodemAdminMenuAdminRevive" },
            { name = "heal",          label = "Heal",             icon = "healicon",          functionname = "CodemAdminMenuAdminHeal" },
            { name = "invisible",     label = "invisible",        icon = "invicibleicon",     functionname = "CodemAdminMenuInvisible",    checked = true },
            { name = "adminduty",     label = "Admin Duty",       icon = "adminoutfiticon",   functionname = "CodemAdminMenuAdminDuty",    checked = true },
            { name = "noclip",        label = "Noclip",           icon = "noclipicon",        functionname = "CodemAdminMenuNoclip",       checked = true },
            { name = "playername",    label = "Player Name",      icon = "playernameicon",    functionname = "CodemAdminMenuPlayerName",   checked = true },
            { name = "allkick",       label = "All Kick Players", icon = "kickicon",          functionname = "CodemAdminMenuKickAll" },
            { name = "armor",         label = "Armor",            icon = "armoricon",         functionname = "CodemAdminMenuArmor" },
            { name = "godmode",       label = "Godmode",          icon = "godmodeicon",       functionname = "CodemAdminMenuGodmode",      checked = true },
            { name = "offlineban",    label = "Offline Ban",      icon = "banicon", },
            { name = "bannedplayers", label = "Banned Players",   icon = "bannedplayersicon", functionname = "CodemAdminMenuBannedPlayers" }

        }
    },
    {
        name = "playeroption",
        label = "Player Options",
        elements = {
            { name = "searchbarplayer" }
        }
    },
    {
        name = "developeroption",
        label = "Developer Options",
        elements = {
            { name = "noclip",      label = "Noclip",       icon = "noclipicon",      functionname = "CodemAdminMenuNoclip",      checked = true },
            { name = "showcoords",  label = "Show Coords",  icon = "showcoordsicon",  functionname = "CodemAdminMenuShowCoords",  checked = true },
            { name = "copyvector3", label = "Copy Vector3", icon = "copyvectoricon",  functionname = "CodemAdminMenuCopyVector",  copy = true },
            { name = "copyvector4", label = "Copy Vector4", icon = "copyvector4icon", functionname = "CodemAdminMenuCopyVector4", copy = true },
            { name = "copyxyz",     label = "Copy XYZ",     icon = "copyvectoricon",  functionname = "CodemAdminMenuCopyXYZ",     copy = true },
            { name = "copyheading", label = "Copy Heading", icon = "copyheadingicon", functionname = "CodemAdminMenuCopyHeading", copy = true },
            { name = "devlaser",    label = "Dev Laser",    icon = "devlasericon",    functionname = "CodemAdminMenuDevLaser",    checked = true }
        }
    },
    {
        name = "serveroption",
        label = "Server Options",
        elements = {
            { name = "weather",      label = "Weather",       icon = "weathericon" },
            { name = "servertime",   label = "Time",          icon = "servertimeicon" },
            { name = "cleararea",    label = "Clear Area",    icon = "clearareaicon",    functionname = "CodemAdminMenuClearArea" },
            { name = "clearvehicle", label = "Clear Vehicle", icon = "clearvehicleicon", functionname = "CodemAdminMenuClearVehicle" }
        }
    },
    {
        name = "vehicleoption",
        label = "Vehicle Options",
        elements = {
            { name = "repairvehicle",      label = "Repair Vehicle",          icon = "repairvehicleicon",      functionname = "CodemAdminMenuRepairVehicle" },
            { name = "gastank",            label = "Fill the gas tank",       icon = "gastankicon",            functionname = "CodemAdminMenuGasTank" },
            { name = "givevehicle",        label = "Spawn Vehicle",           icon = "givevehicleicon",        functionname = "CodemAdminMenuGiveVehicle",         modal = "givevehicle",        vehicle = true },
            { name = "addvehicletoplayer", label = "Add Vehicle To Database", icon = "addvehicletoplayericon", functionname = "CodemAdminMenuGiveVehicleToPlayer", modal = "addvehicletoplayer", vehicle = true }
        }
    }
}


Config.PlayerOptions = {
    { name = "playerinfo",       label = "Player Info",        icon = "playerinfoicon" },
    { name = "kill",             label = "Kill",               icon = "killicon",             functionname = "CodemAdminMenuKill" },
    { name = "revive",           label = "Revive",             icon = "reviveicon",           functionname = "CodemAdminMenuAdminRevive" },
    { name = "freeze",           label = "Freeze",             icon = "freezeicon",           functionname = "CodemAdminMenuFreeze" },
    { name = "spectate",         label = "Spectate",           icon = "spectateicon",         functionname = "CodemAdminMenuSpectate" },
    { name = "goto",             label = "Goto",               icon = "gotoicon",             functionname = "CodemAdminMenuGoto" },
    { name = "bring",            label = "Bring",              icon = "bringicon",            functionname = "CodemAdminMenuBring" },
    { name = "openinventory",    label = "Open Inventory",     icon = "openinventoryicon",    functionname = "CodemAdminMenuOpenInventory" },
    { name = "clearinventory",   label = "Clear Inventory",    icon = "clearinventoryicon",   functionname = "CodemAdminMenuClearInventory" },
    { name = "changejob",        label = "Change Job",         icon = "changejobicon",        functionname = "CodemAdminMenuChangeJob" },
    { name = "giveitem",         label = "Give Item",          icon = "giveitemicon",         functionname = "CodemAdminMenuGiveItem" },
    { name = "addmoney",         label = "Add Money",          icon = "addmoneyicon",         functionname = "CodemAdminMenuAddMoney" },
    { name = "takescreenshot",   label = "Take Screenshot",    icon = "takescreenshoticon",   functionname = "CodemAdminMenuScreenShot" },
    { name = "sendpm",           label = "Send PM",            icon = "sendpmicon",           functionname = "CodemAdminMenuSendPM" },
    { name = "giveclothingmenu", label = "Give Clothing Menu", icon = "giveclothingmenuicon", functionname = "CodemAdminMenuGiveClothingMenu" },
    { name = "kick",             label = "Kick",               icon = "kickicon",             functionname = "CodemAdminMenuKick" },
    { name = "ban",              label = "Ban",                icon = "banicon",              functionname = "CodemAdminMenuBan" },
    { name = "permission",       label = "Permission",         icon = "permissionsicon" }
}

Config.AdminClothes = {
    { jacket = 246,  texture = 0 },
    { shirt = 15,    texture = 0 },
    { arms = 3,      texture = 0 },
    { legs = 95,     texture = 0 },
    { shoes = 68,    texture = 0 },
    { mask = 123,    texture = 0 },
    { chain = 0,     texture = 11 },
    { decals = 0,    texture = 11 },
    { helmet = 0,    texture = 11 },
    { glasses = 0,   texture = 11 },
    { watches = 0,   texture = 11 },
    { bracelets = 0, texture = 11 }
}

Config.LaserInfo = {
    ["object"] = {
        elements = {
            { name = "modelhash",     label = "Model Hash",     value = false, icon = "modelhashicon",     addborder = true },
            { name = "entityid",      label = "Entity ID",      value = false, icon = "entityidicon" },
            { name = "objectname",    label = "Object Name",    value = false, icon = "objectnameicon" },
            { name = "netid",         label = "Net ID",         value = false, icon = "netidicon" },
            { name = "entityowner",   label = "Entity Owner",   value = false, icon = "entityownericon",   addborder = true },
            { name = "currenthealth", label = "Current Health", value = false, icon = "currenthealthicon", addborder = true },
            { name = "distance",      label = "Distance",       value = false, icon = "distanceicon" },
            { name = "heading",       label = "Heading",        value = false, icon = "headingicon" },
            { name = "coords",        label = "Coords",         value = false, icon = "coordsicon" },
            { name = "rotation",      label = "Rotation",       value = false, icon = "rotationicon" },
            { name = "velocity",      label = "Velocity",       value = false, icon = "velocityicon" }
        }
    },
    ["ped"] = {
        elements = {
            { name = "modelhash",        label = "Model Hash",          value = false, icon = "modelhashicon",        addborder = true },
            { name = "entityid",         label = "Entity ID",           value = false, icon = "entityidicon" },
            { name = "objectname",       label = "Object Name",         value = false, icon = "objectnameicon" },
            { name = "netid",            label = "Net ID",              value = false, icon = "netidicon" },
            { name = "entityowner",      label = "Entity Owner",        value = false, icon = "entityownericon",      addborder = true },
            { name = "currenthealth",    label = "Current Health",      value = false, icon = "currenthealthicon" },
            { name = "maxhealth",        label = "Max Health",          value = false, icon = "maxhealthicon" },
            { name = "armour",           label = "Armour",              value = false, icon = "armouricon" },
            { name = "relationgroup",    label = "Relation Group",      value = false, icon = "relationgroupicon" },
            { name = "relationtoplayer", label = "Relation To Player ", value = false, icon = "relationtoplayericon", addborder = true },
            { name = "distance",         label = "Distance",            value = false, icon = "distanceicon" },
            { name = "heading",          label = "Heading",             value = false, icon = "headingicon" },
            { name = "coords",           label = "Coords",              value = false, icon = "coordsicon" },
            { name = "rotation",         label = "Rotation",            value = false, icon = "rotationicon" },
            { name = "velocity",         label = "Velocity",            value = false, icon = "velocityicon" }
        }
    },
    ["vehicle"] = {
        elements = {
            { name = "modelhash",    label = "Model Hash",    value = false, icon = "modelhashicon",    addborder = true },
            { name = "entityid",     label = "Entity ID",     value = false, icon = "entityidicon" },
            { name = "objectname",   label = "Object Name",   value = false, icon = "objectnameicon" },
            { name = "netid",        label = "Net ID",        value = false, icon = "netidicon" },
            { name = "entityowner",  label = "Entity Owner",  value = false, icon = "entityownericon",  addborder = true },
            { name = "rpm",          label = "RPM",           value = false, icon = "rpmicon" },
            { name = "kmh",          label = "KMH",           value = false, icon = "kmhicon" },
            { name = "gear",         label = "Current Gear",  value = false, icon = "gearicon" },
            { name = "acceleration", label = "Acceleration",  value = false, icon = "accelerationicon" },
            { name = "bodyhealth",   label = "Body Health",   value = false, icon = "bodyhealthicon" },
            { name = "enginehealth", label = "Engine Health", value = false, icon = "enginehealthicon", addborder = true },
            { name = "distance",     label = "Distance",      value = false, icon = "distanceicon" },
            { name = "heading",      label = "Heading",       value = false, icon = "headingicon" },
            { name = "coords",       label = "Coords",        value = false, icon = "coordsicon" },
            { name = "rotation",     label = "Rotation",      value = false, icon = "rotationicon" },
            { name = "velocity",     label = "Velocity",      value = false, icon = "velocityicon" }
        }
    }
}
