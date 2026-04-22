local QBCore = exports['qb-core']:GetCoreObject()

local PlayerJob = {}
local isJudge = false
local isPolice = false
local isTow = false
local isTaxi = false
local isMedic = false
local isDead = false
local myJob = "Unemployed"
local isHandcuffed = false
local hasOxygenTankOn = false
local bennyscivpoly = false
local onDuty = false
local inGarage = false
local inDepots = false
local InPdbennys = false
local isInPdbennys = false
CreateThread(function() 
    if QBCore.Functions.GetPlayerData().job then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)
RegisterNetEvent('pdbennys:updateStatus', function(status)
    isInPdbennys = status
end)
 

rootMenuConfig =  {

    {
        id = "vehicle",
        displayName = "Vehicle",
        icon = "#vehicle-options",
        functionName = "carmenuevent",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and IsPedInAnyVehicle(PlayerPedId(), false))
        end
    },
    {
        id = "blips",
        displayName = "GPS",
        icon = "#blips",
        enableMenu = function()
            local src = source
            local Player = QBCore.Functions.GetPlayerData(src)
            local inlaststand = Player.metadata["inlaststand"]
            local isdead = Player.metadata["isdead"]

            return not isdead and not inlaststand
        end,
        subMenus = { "blips:gasstations",  "blips:barbershop", "blips:tattooshop","blips:motel","blips:restaurant","blips:Banks","blips:carwach"}
    },
    {
        id = "General",
        displayName = "General",
        icon = "#globe-europe",
        enableMenu = function()
            local src = source
            local Player = QBCore.Functions.GetPlayerData(src)
            local inlaststand = Player.metadata["inlaststand"]
            local isdead = Player.metadata["isdead"]
            
            return not inlaststand and not isdead
        end,
        subMenus = {"vehicle:giveKeys", "interact:carry", "interact:trunkin", "interact:trunkout",  "general:flipveh","general:givenum"}
    },
    -- {
    --     id = "Interaction",
    --     displayName = "Interaction",
    --     icon = "#general-contact",
    --     enableMenu = function()
    --         local src = source
    --         local Player = QBCore.Functions.GetPlayerData(src)
    --         local inlaststand = Player.metadata["inlaststand"]
    --         local isdead = Player.metadata["isdead"]

    --         return not isdead and not inlaststand
    --     end,
        
    --     subMenus = {"general:cuff", "general:rob", "general:playerinvehicle", "general:playeroutvehicle", }
    -- },
        {
        id = 'police-locked-storage',
        displayName = 'Locked Storage',
        icon = '#police-locked-compartment',
        functionName = 'police:LockedCompartment',
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)
            local model = GetEntityModel(veh)
            return (not Data.metadata['isdead'] and not Data.metadata['inlaststand'] and IsPedInAnyVehicle(PlayerPedId(), false))  and Data.job ~= nil and (Data.job.name == 'police' and Data.job.onduty and not IsThisModelABike(model))
        end
    },
        {
        id = "mdt",
        displayName = "MDT",
        icon = "#faTablet",
        functionName = "mdt:client:open",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()

            return not (Data.metadata["isdead"] or Data.metadata["inlaststand"]) and (Data.job.name == 'police' and Data.job.onduty)
        end
    },

-- {
--     id = "expressions",
--     displayName = "Expressions",
--     icon = "#expressions",
--     enableMenu = function()
--         local src = source
--         local Player = QBCore.Functions.GetPlayerData(src)
--         local inlaststand = Player.metadata["inlaststand"]
--         local isdead = Player.metadata["isdead"]
--         return not inlaststand and not isdead
--     end,
--     subMenus = {
--         "expressions:angry",
--         "expressions:drunk"
--     }
-- },
    --         {
    --     id = "walk",
    --     displayName = "walk",
    --     icon = "#walking",
    --     enableMenu = function()
    --         local src = source
    --         local Player = QBCore.Functions.GetPlayerData(src)
    --         local inlaststand = Player.metadata["inlaststand"]
    --         local isdead = Player.metadata["isdead"]

         
    --         return not inlaststand and not isdead
    --     end,
    --     subMenus = {"animations:default","animations:brave","animations:hurry","animations:business","animations:tipsy","animations:tough","animations:sassy","animations:sad","animations:posh","animations:alien","animations:hobo","animations:money","animations:swagger","animations:shady","animations:maneater","animations:chichi"}
    -- },
    {
        id = "police",
        displayName = "Police Actions",
        icon = "#police-action",
        enableMenu =function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and (Data.job ~= nil and Data.job.name == "police" and Data.job.onduty))
        end,
        subMenus = {"police:cuff", "police:unmask", "panicpolice", "police:checkbank", "police:search", "police:checklicenses"}
    },
        {
        id = "PanicPolice",
        displayName = "10-13A",
        icon = "#police-dead",
        functionName = "cd_dispatch:CallCommand:Panic",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()

            return (Data.metadata["isdead"] or Data.metadata["inlaststand"]) and (Data.job.name == 'police' and Data.job.onduty)
        end
    },
    {
        id = "house",
        displayName = "House Interactions",
        icon = "#house",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return not Data.metadata["isdead"] and not Data.metadata["inlaststand"]
        end,
        subMenus = {"house:setstash", "house:decorate","house:setoutift","house:setlogout"}
    },
    {
        id = "cuff",
        displayName = " Cuff Options",
        icon = "#cuffs",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return not Data.metadata["isdead"] and not Data.metadata["inlaststand"]
        end,
        subMenus = {"cuffing:steal", 'ems:putinvehicle','ems:unseatvehicle','police:drag' }
    },  

    {
        id = "objects",
        displayName = "Objects",
        icon = "#faToolbox",
        enableMenu =function()
            local Data = QBCore.Functions.GetPlayerData() 
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and (Data.job ~= nil and Data.job.name == "police" and Data.job.onduty))
        end,
        subMenus = {"objects:barier", "objects:cone", "objects:tent","objects:spawnLight","objects:spawnRoadSign", "objects:remove"}
    },
        {
        id = "radio",
        displayName = "Radio",
        icon = "#faRadio",
        enableMenu = function()
            local Data, hasItem = QBCore.Functions.GetPlayerData()

            QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                hasItem = result
            end, "radio")

            while hasItem == nil do
                Wait(10)
            end

            return hasItem and (not Data.metadata["isdead"] and not Data.metadata["inlaststand"]) and (Data.job.name == 'police' and Data.job.onduty)
        end,
        subMenus = {'power:off',"radio:1","radio:2","radio:3","radio:4","radio:5"}
    },


    -- EMS --
    {
        id = "ems",
        displayName = "EMS",
        icon = "#medic",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and (Data.job ~= nil and Data.job.name == "ambulance" and Data.job.onduty))
        end,
        subMenus = { 'police:drag', "ems:revive", 'ems:heal',  'ems:putinvehicle','ems:unseatvehicle'}
    },
    
    {
        id = "objects",
        displayName = "Objects",
        icon = "#fabullseye",
        enableMenu =function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and (Data.job ~= nil and Data.job.name == "ambulance" and Data.job.onduty))
        end,
        subMenus = {"objects:barier", "objects:cone", "objects:tent","objects:spawnLight","objects:spawnRoadSign", "objects:remove"}
    },
    {
        id = "radio",
        displayName = "Radio",
        icon = "#faRadio",
        enableMenu = function()
            local Data, hasItem = QBCore.Functions.GetPlayerData()

            QBCore.Functions.TriggerCallback('QBCore:HasItem', function(result)
                hasItem = result
            end, "radio")

            while hasItem == nil do
                Wait(10)
            end

            return hasItem and not Data.metadata["isdead"] and (Data.job.name == "ambulance")
        end,
        subMenus = {'power:off',"radio:6","radio:7","radio:8","radio:9","radio:10"}
    },
        {
        id = "emsDeadA",
        displayName = "10-14A",
        icon = "#ems-dead",
        functionName = "dispatch:emsDown",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return (Data.metadata["isdead"] or Data.metadata["inlaststand"]) and (Data.job.name == 'ambulance' and Data.job.onduty)
        end
    },
        {
        id = "taxi",
        displayName = "Taxi Actions",
        icon = "#drivinginstructor",
        enableMenu =function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and Data.job ~= nil and Data.job.name == "taxi")
        end,
        subMenus = { "taxi:togglemeter", "taxi:npcmission", "npc_mission" }
    },

    {    
        id = "Emotes",
        displayName = "Emotes",
        icon = "#general-emotes",
        functionName = "emotes",
        eventType = "command",
        enableMenu = function()
            local src = source
            local Player = QBCore.Functions.GetPlayerData(src)
            local inlaststand = Player.metadata["inlaststand"]
            local isdead = Player.metadata["isdead"]

            return not isdead and not inlaststand 
        end
    },
    {
        id = "news",
        displayName = "News",
        icon = "#news",
        enableMenu =function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and Data.job ~= nil and (Data.job.name == "reporter"))
        end,
        subMenus = { "news:boom", "news:mic", "news:cam" }
    },

 -- add `,` after `}` if you gonna add new button but last button should ended w/o `,`

    -- NOTE
    -- for add a new function button to menu:
    -- {
    --     id = "generalgarage", -- type group id name, can be any name
    --     displayName = "Garage", -- Display Name
    --     icon = "#general-garage", -- Icon, should be with `#` cuz from HTML and check HTML for edits
    --     functionName = "qb-garages:takeout", -- THIS IS THE FUNCTION NAME THAT WILL BE TRIGGERED AFTER CLICKING THE BUTTON
    --     enableMenu = function()
    --         return (not isDead and inGarage and not isCloseVeh() and not IsPedInAnyVehicle(PlayerPedId(), false)) -- if person is dead or in vehicle. we don't want dead people to see this button if dead
    --     end
    -- }

    -- for open a new menu from the button:
    -- {
    --     id = "general", -- type group id name, can be any name
    --     displayName = "General", -- Display Name
    --     icon = "#globe-europe", -- Icon, should be with `#` cuz from HTML and check HTML for edits
    --     enableMenu = function()
    --         return not isDead -- if person is dead or in vehicle. we don't want dead people to see this button if dead
    --     end,
    --     subMenus = {"general:escort", "general:emotes", "general:putinvehicle", "general:unseatnearest"} -- add submenu names that will be shown after clicking General button
    -- }

    -- NOTE
    -- EXAMPLE:
    -- {
    --     id = "copDead",
    --     displayName = "11-A",
    --     icon = "#police-dead",
    --     enableMenu = function()
    --         return isPolice and isDead and onDuty -- here button checks if person is cop and dead and on duty. if 3 of them true then this will be shown
    --     end,
    --     subMenus = {"general:escort", "general:emotes", "general:putinvehicle", "general:unseatnearest"}
    -- }
}

newSubMenus = { -- NOTE basicly, what will be happen after clicking these buttons and icon of them
---General
    ['general:givenum'] = {
        title = "Give contact",
        icon = "#obj-phone",
        functionName = "qb-phone:client:GiveContactDetails" -- must be client event, work same as TriggerEvent('emotes:OpenMenu')
    },
    ['vehicle:giveKeys'] = {
        title = "Give Keys",
        icon = "#general-keys-give",
        functionName = "vehiclekeys:client:GiveKeys"
    },
    ['interact:carry'] = {
        title = "Carry",
        icon = "#infected-icon",
        functionName = "carry:Event",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"])
        end
    },
    ['interact:trunkin'] = {
        title = "Get In Trunk",
        icon = "#general-put-in-veh",
        functionName = "trunkgetin:event",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"])
        end
    },
    ['general:flipveh'] = {
        title = "Flip Vehicle",
        icon = "#general-flip-vehicle",
        functionName = "vehicle:flipit"
    },

    ['interact:trunkout'] = {
        title = "Get Out Trunk",
        icon = "#general-unseat-nearest",
        functionName = "trunkgetout:event",
    },
----
    ['house:decorate'] = {
        title = "Decorate house",
        icon = "#k9-spawn",
        functionName = "decoratehouse",
    },

    ['house:setstash'] = {
        title = "Set Stash",
        icon = "#more",
        functionName = "qb-houses:client:setStash",
        functionParameters =  "setstash"
    },
    
    ['house:setoutift'] = {
        title = "Outfit Set",
        icon = "#tshirt",
        functionName = "qb-houses:client:setOutfit",
        functionParameters =  "setoutift"
    },
    
    ['house:setlogout'] = {
        title = "Logout",
        icon = "#general-unseat-nearest",
        functionName = "qb-houses:client:setLogout",
        functionParameters =  "setlogout"
    },
---------
 --Police objects
    ['objects:barier'] = {
        title = "Barier",
        icon = "#faBarrier",
        functionName = "police:client:spawnBarrier"
    },

    ['objects:cone'] = {
        title = "Cone",
        icon = "#faCone",
        functionName = "police:client:spawnCone"
    },

    ['objects:tent'] = {
        title = "Tent",
        icon = "#faCampground",
        functionName = "police:client:spawnTent"
    },

    ['objects:spawnRoadSign'] = {
        title = "Road Sign",
        icon = "#faRoadSign",
        functionName = "police:client:spawnRoadSign"
    },

    ['objects:spawnLight'] = {
        title = "Light",
        icon = "#faLightbulb",
        functionName = "police:client:spawnLight"
    },

    ['objects:spike'] = {
        title = "Spike",
        icon = "#spike",
        functionName = "police:client:SpawnSpikeStrip"
    },

    ['objects:remove'] = {
        title = "Remove",
        icon = "#police-action-remove-weapons",
        functionName = "police:client:deleteObject"
    }, 
    ['police:unmask'] = {
        title = "Remove Mask Hat",
        icon = "#cuffs-remove-mask",
        functionName = "police:unmask"
    },
    ['police:cuff'] = {
        title = "Cuff",
        icon = "#cuffs-cuff",
        functionName = "police:client:GetCuffed"
    },
    ['panicpolice'] = {
        title = "Panic Button",
        icon = "#police-dead",
        functionName = "ps-dispatch:client:officerbackup" 
    },
    ['police:checkbank'] = {
        title = "Check status",
        icon = "#police-check-bank",
        functionName = "police:client:CheckStatus"
    },
    ['police:search'] = {
        title = "Frisk",
        icon = "#police-action-gsr",
        functionName = "police:client:SearchPlayer"
    },
    ['police:checklicenses'] = {
        title = "Check GSR",
        icon = "#police-action-frisk",
        functionName = "police:client:gsr"
    },
        ['power:off'] = {
        title = "Disconnect",
        icon = "#ped-sign-out",
        functionName = "remove:radio"
    },
---------
    ['cuffing:steal'] = {
        title = "Rob Person",
        icon = "#cuffs-check-inventory",
        functionName = "police:client:RobPlayer",
    },
    ['ems:putinvehicle'] = {
        title = "Put in Vehicle",
        icon = "#general-put-in-veh",
        functionName = "police:client:PutPlayerInVehicle"
    },
    ['ems:unseatvehicle'] = {
        title = "Unseat Nearest",
        icon = "#general-unseat-nearest",
        functionName = "police:client:SetPlayerOutVehicle"
    },
    ['police:drag'] = {
        title = "Escort",
        icon = "#general-escort",
        functionName = "police:client:EscortPlayer",
    },
--------------
["expressions:angry"] = {
    title = "Angry",
    icon = "#expressions-angry",
    functionName = "expressions",
    functionParameters = { "mood_angry_1" }
},

    ["expressions:drunk"] = {
        title="Drunk",
        icon="#expressions-drunk",
        functionName = "expressions",
        functionParameters =  { "mood_drunk_1" }
    },

    ["expressions:dumb"] = {
        title="Dumb",
        icon="#expressions-dumb",
        functionName = "expressions",
        functionParameters =  { "pose_injured_1" }
    },

    ["expressions:electrocuted"] = {
        title="Electrocuted",
        icon="#expressions-electrocuted",
        functionName = "expressions",
        functionParameters =  { "electrocuted_1" }
    },

    ["expressions:grumpy"] = {
        title="Grumpy",
        icon="#expressions-grumpy",
        functionName = "expressions", 
        functionParameters =  { "mood_drivefast_1" }
    },

    ["expressions:happy"] = {
        title="Happy",
        icon="#expressions-happy",
        functionName = "expressions",
        functionParameters =  { "mood_happy_1" }
    },

    ["expressions:injured"] = {
        title="Injured",
        icon="#expressions-injured",
        functionName = "expressions",
        functionParameters =  { "mood_injured_1" }
    },

    ["expressions:joyful"] = {
        title="Joyful",
        icon="#expressions-joyful",
        functionName = "expressions",
        functionParameters =  { "mood_dancing_low_1" }
    },

    ["expressions:mouthbreather"] = {
        title="Mouthbreather",
        icon="#expressions-mouthbreather",
        functionName = "expressions",
        functionParameters = { "smoking_hold_1" }
    },

    ["expressions:normal"]  = {
        title="Normal",
        icon="#expressions-normal",
        functionName = "expressions:clear"
    },

    ["expressions:oneeye"]  = {
        title="Oneeye",
        icon="#expressions-oneeye",
        functionName = "expressions",
        functionParameters = { "pose_aiming_1" }
    },

    ["expressions:shocked"]  = {
        title="Shocked",
        icon="#expressions-shocked",
        functionName = "expressions",
        functionParameters = { "shocked_1" }
    },

    ["expressions:sleeping"]  = {
        title="Sleeping",
        icon="#expressions-sleeping",
        functionName = "expressions",
        functionParameters = { "dead_1" }
    },

    ["expressions:smug"]  = {
        title="Smug",
        icon="#expressions-smug",
        functionName = "expressions",
        functionParameters = { "mood_smug_1" }
    },

    ["expressions:speculative"]  = {
        title="Speculative",
        icon="#expressions-speculative",
        functionName = "expressions",
        functionParameters = { "mood_aiming_1" }
    },
 
    ["expressions:stressed"]  = {
        title="Stressed",
        icon="#expressions-stressed",
        functionName = "expressions",
        functionParameters = { "mood_stressed_1" }
    },

    ["expressions:sulking"]  = {
        title="Sulking",
        icon="#expressions-sulking",
        functionName = "expressions",
        functionParameters = { "mood_sulk_1" },
    },

    ["expressions:weird"]  = {
        title="Weird",
        icon="#expressions-weird",
        functionName = "expressions",
        functionParameters = { "effort_2" }
    },

    ["expressions:weird2"]  = {
        title="Weird 2",
        icon="#expressions-weird2",
        functionName = "expressions",
        functionParameters = { "effort_3" }
     },  
--------------  
    ['blips:gasstations'] = {
        title = "Gas Station",
        icon = "#blips-gasstations",
        functionName = "ygx:togglegas"
    },
    ['blips:garages'] = {
        title = "Garages",
        icon = "#blips-garages",
        functionName = "Garages:ToggleGarageBlip"
    },
    ['blips:barbershop'] = {
        title = "Barber",
        icon = "#blips-barbershop",
        functionName = "ygx:togglebarber" 
    },
    ['blips:tattooshop'] = {
        title = "Tattoo",
        icon = "#blips-tattooshop",
        functionName = "ygx:toggletattos"
    },
    ['blips:restaurant'] = {
        title = "Restaurant",
        icon = "#k9-follow",
        functionName = "fk:restaurant"
    },
    ['blips:carwach'] = {
        title = "Car wach",
        icon = "#vehicle-options-vehicle",
        functionName = "fk:carwach"
    },
    ['blips:Banks'] = {
        title = "Banks",
        icon = "#animation-gangster",
        functionName = "fk:banks"
    },--
    ['blips:motel'] = {
        title = "motel",
        icon = "#judge-raid-check-owner",
        functionName = "fk:motel" 
    },--
    ['animations:brave'] = {
        title = "Brave",
        icon = "#animation-brave",
        functionName = "AnimSet:Brave"
    },
    ['animations:hurry'] = {
        title = "Hurry",
        icon = "#animation-swagger",
        functionName = "AnimSet:Hurry"
    },
    ['animations:business'] = {
        title = "Business",
        icon = "#animation-business",
        functionName = "AnimSet:Business"
    },
    ['animations:tipsy'] = {
        title = "Tipsy",
        icon = "#animation-tipsy",
        functionName = "AnimSet:Tipsy"
    },
    ['animations:injured'] = {
        title = "Injured",
        icon = "#animation-injured",
        functionName = "AnimSet:Injured"
    },
    ['animations:tough'] = {
        title = "Tough",
        icon = "#animation-tough",
        functionName = "AnimSet:ToughGuy"
    },	
    ['animations:sassy'] = {
        title = "Sassy",
        icon = "#animation-sassy",
        functionName = "AnimSet:Sassy"
    },
    ['animations:sad'] = {
        title = "Sad",
        icon = "#animation-sad",
        functionName = "AnimSet:Sad"
    },
    ['animations:posh'] = {
        title = "Posh",
        icon = "#animation-posh",
        functionName = "AnimSet:Posh"
    },
    ['animations:alien'] = {
        title = "Alien",
        icon = "#animation-alien",
        functionName = "AnimSet:Alien"
    },
    ['animations:hobo'] = {
        title = "Hobo",
        icon = "#animation-hobo",
        functionName = "AnimSet:Hobo"
    },
    ['animations:money'] = {
        title = "Money",
        icon = "#animation-money",
        functionName = "AnimSet:Money"
    },
    ['animations:swagger'] = {
        title = "Swag",
        icon = "#animation-swagger",
        functionName = "AnimSet:Swagger"
    },
    ['animations:shady'] = {
        title = "Gangster",
        icon = "#animation-shady",
        functionName = "AnimSet:Shady"
    },
    ['animations:maneater'] = {
        title = "Sassy3",
        icon = "#animation-sassy",
        functionName = "AnimSet:ManEater"
    },
    ['animations:chichi'] = {
        title = "Sassy2",
        icon = "#animation-sassy",
        functionName = "AnimSet:ChiChi"
    },
    ['animations:default'] = {
        title = "Normal",
        icon = "#animation-default",
        functionName = "AnimSet:default"
    },
    ['general:rob'] = {
        title = "Rob",
        icon = "#general-contact",
        functionName = "police:client:RobPlayer" -- must be client event, work same as TriggerEvent('emotes:OpenMenu')
    },
    ['general:playerinvehicle'] = {
        title = "Seat Vehicle",
        icon = "#general-put-in-veh",
        functionName = "police:client:PutPlayerInVehicle" -- must be client event, work same as TriggerEvent('emotes:OpenMenu')
    },
    ['general:playeroutvehicle'] = {
        title = "Unseat Vehicle",
        icon = "#general-put-in-veh",
        functionName = "police:client:SetPlayerOutVehicle" -- must be client event, work same as TriggerEvent('emotes:OpenMenu')
    }, 
    ['drug:sell'] = {
        title = "Cornersell",
        icon = "#general-drug",
        functionName = "qb-drugs:client:cornerselling"
    },


    ['cuffing:cuff'] = {
        title = "Cuff",
        icon = "#cuffs-cuff",
        enableMenu = function()
            local Data = QBCore.Functions.GetPlayerData()
            return (not Data.metadata["isdead"] and not Data.metadata["inlaststand"] and Data.job ~= nil and Data.job.name ~= "ambulance" and Data.job.name ~= "police" and not IsPedInAnyVehicle(ped, true))
        end,
        functionName = "police:client:CuffPlayerSoft",
    },
    --  POLICE 
    ['police:statuscheck'] = {
        title = "Status Check",
        icon = "#police-checkplayerstatus",
        functionName = "hospital:client:CheckStatus"
    },
    ['police:searchplayer'] = {
        title = "Search player",
        icon = "#police-search",
        functionName = "police:client:SearchPlayer"
    },
    ['police:jail'] = {
        title = "Jail Player",
        icon = "#police-jail",
        functionName = "police:client:JailPlayer"
    },
    ['police:seizecash'] = {
        title = "Seize Cash",
        icon = "#police-seize",
        functionName = "police:client:SeizeCash"
    },
    ['police:bill'] = {
        title = "Bill",
        icon = "#general-cuff",
        functionName = "police:client:BillPlayer"
    },  
    ['police:mdt'] = {
        title = "MDT",
        icon = "#mdt",
        functionName = "mdt:toggleVisibilty"    
    }, 

    ['police:checkvehicle'] = {
        title = "Check Vehicle Status",
        icon = "#police-chechvehiclestatus",
        functionName = "qb-tunerchip:server:TuneStatus"     
    },  
    ['police:takedriverlicense'] = {
        title = "Revoke Drivers License",
        icon = "#police-revokelicense",
        functionName = "police:client:SeizeDriverLicense"     
    },  
    -- POLICE 

    ['news:boom'] = {
        title = "Boom Microphone",
        icon = "#news-boom",
        functionName = "Mic:ToggleBMic"
    },

    ['news:cam'] = {
        title = "Camera",
        icon = "#news-job-news-camera",
        functionName = "Cam:ToggleCam"
    },

    ['news:mic'] = {
        title = "Microphone",
        icon = "#news-job-news-microphone",
        functionName = "Mic:ToggleMic"
    },
    -- HOSPITAL
    ['medic:status'] = {
        title = "StatusCheck",
        icon = "#general-cuff",
        functionName = "" 
    },
    ['medic:revive'] = {
        title = "Revive",
        icon = "#hospital-revivep",
        functionName = "hospital:client:RevivePlayer"
    },
    ['medic:treat'] = {
        title = "Heal wounds",
        icon = "#hospital-treat",
        functionName = "hospital:client:TreatWounds"
    },
    ['medic:stretcherspawn'] = {
        title = "Stretcher",
        icon = "#general-cuff",
        functionName = "hospital:client:TakeStretcher" 
    }, 
    ['medic:stretcherremove'] = {
        title = "Stretcher Remove", 
        icon = "#general-cuff",
        functionName = "hospital:client:RemoveStretcher" 
    },  --TOW --TOW
    ['tow:togglenpc'] = {
        title = "Toggle Npc",
        icon = "#tow-mission",
        functionName = "jobs:client:ToggleNpc"
    }, 
    ['tow:vehicle'] = {
        title = "Tow vehicle",
        icon = "#tow-tow",
        functionName = "qb-tow:client:TowVehicle"
    },  -- Taxi
    ["taxi:togglemeter"] = {
        title = "Show/Hide Meter",
        icon = "#faTablet",
        functionName = "qb-taxi:client:toggleMeter",
    },

    ["taxi:npcmission"] = {
        title = "Start/Stop Meter",
        icon = "#drivinginstructor",
        functionName = "qb-taxi:client:enableMeter",
    },
    
    ["npc_mission"] = {
        title = "NPC Mission",
        icon = "#prisoner-group",
        functionName = "qb-taxi:client:DoTaxiNpc",
    },

}
    
for i=1, 10 do
    newSubMenus["radio:"..i] = {
        title = "Radio\n"..i,
        icon = "#vehicle-flight-data",
        functionName = "qb-radio:radialmenu",
        functionParameters = i,
    }
end
RegisterNetEvent("isJudge") -- these are all up to you and your job system, if person become Judge, script will see him as Judge too.
AddEventHandler("isJudge", function()
    isJudge = true
end)

RegisterNetEvent("isJudgeOff") -- opposite of the above
AddEventHandler("isJudgeOff", function()
    isJudge = false
end)

RegisterNetEvent("isTow") -- these are all up to you and your job system, if person become Judge, script will see him as Judge too.
AddEventHandler("isTow", function()
    isTow = true
end)

RegisterNetEvent("isTowOff") -- these are all up to you and your job system, if person become Judge, script will see him as Judge too.
AddEventHandler("isTowOff", function()
    isTow = false
end)

RegisterNetEvent("isTaxi") -- these are all up to you and your job system, if person become Judge, script will see him as Judge too.
AddEventHandler("isTaxi", function()
    isTaxi = true
end)

RegisterNetEvent("isTaxiOff") -- opposite of the above
AddEventHandler("isTaxiOff", function()
    isTaxi = false
end)

RegisterNetEvent("QBCore:Client:OnJobUpdate") -- dont edit this unless you don't use qb-core
AddEventHandler("QBCore:Client:OnJobUpdate", function(jobInfo)
    myJob = jobInfo.name
    if isMedic and myJob ~= "ambulance" then isMedic = false end
    if isPolice and myJob ~= "police" then isPolice = false end
    if isTow and myJob ~= "tow" then isTow = false end
    if isTaxi and myJob ~= "taxi" then isTaxi = false end
    if myJob == "police" then isPolice = true end
    if myJob == "tow" then isTow = true end
    if myJob == "taxi" then isTaxi = true end
    if myJob == "ambulance" then isMedic = true end
end)

RegisterNetEvent('QBCore:Client:SetDuty') -- dont edit this unless you don't use qb-core
AddEventHandler('QBCore:Client:SetDuty', function(duty)
    myJob = QBCore.Functions.GetPlayerData().job.name
    if isMedic and myJob ~= "ambulance" then isMedic = false end
    if isPolice and myJob ~= "police" then isPolice = false end
    if myJob == "police" then isPolice = true onDuty = duty end
    if myJob == "ambulance" then isMedic = true onDuty = duty end
end)

RegisterNetEvent('deathcheck') -- YOU SHOULD ADD THIS IN YOUR ambulancejob system, basically let the function trigger here when the ped playing anim and add this to
-- your revived function so everytime if person dies, this will be triggered to isDead = true, if he get revived this will be triggered to isDead = false
AddEventHandler('deathcheck', function()
    if not isDead then
        isDead = true
    else
        isDead = false
    end
end)


RegisterNetEvent("police:currentHandCuffedState") -- add this your police:client:GetCuffed @qb-policejob\client\interactions.lua
AddEventHandler("police:currentHandCuffedState", function(pIsHandcuffed)
    isHandcuffed = pIsHandcuffed
end)

RegisterNetEvent("menu:hasOxygenTank") -- add this to your oxygentank wear place, idk where is this for qb-inventory so find out please
AddEventHandler("menu:hasOxygenTank", function(pHasOxygenTank)
    hasOxygenTankOn = pHasOxygenTank
end)


RegisterNetEvent('police:client:PutInVehicle')
AddEventHandler('police:client:PutInVehicle', function()
    if isEscorted then
    end
end)
function isCloseVeh()
    local ped = PlayerPedId()
    coordA = GetEntityCoords(ped, 1)
    coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, 100.0, 0.0)
    vehicle = getVehicleInDirection(coordA, coordB)
    if DoesEntityExist(vehicle) and NetworkHasControlOfEntity(vehicle) then
        return true
    end
    return false
end

function GetPlayers()
    local players = {}
    
    for i = 0, 128 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local closestPed = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        for index,value in ipairs(players) do
            local target = GetPlayerPed(value)
            if(target ~= ply) then
                local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
                local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
                if(closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
                    closestPlayer = value
                    closestPed = target
                    closestDistance = distance
                end
            end
        end
        return closestPlayer, closestDistance, closestPed
    end
end
