local inventoryModule

server = {}
server.framework = shared.getFrameworkObject()
server.load = false
server.exports = {}

require("modules.bridge.init")
require("modules.exports.server")
inventoryModule = require("modules.inventory.server")

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= shared.resource then
        return
    end
    
    Citizen.Wait(1000)
    
    if Resmon and Resmon.Lib and Resmon.Lib.hasLicense then
        if Resmon.Lib.hasLicense("0r-farming-v2") then
            Profile.loadDatabase()
            server.load = true
            lib.versionCheck("alikocidev/docs_0resmon_farming_v2")
            return
        end
    end
    
    local errorMsg = "YOU DO NOT HAVE \"0r_lib\" or YOU NEED TO UPDATE FROM KEYMASTER !"
    StopResource(shared.resource)
    lib.print.error(errorMsg)
    error(("Resource %s stopped !"):format(shared.resource))
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= shared.resource then
        return
    end
    
    MultiplayerTasksServer.onUnload()
end)

local function onPlayerUnload(source)
    local lobbyId = Lobby.isPlayerInAnyLobby(source)
    
    if lobbyId then
        local lobby = Lobby.getLobbyById(lobbyId)
        
        if lobby.currentTask then
            if lobby.owner == source then
                MultiplayerTasksServer.abort(
                    source,
                    lobby.currentTask.moduleName,
                    lobbyId,
                    locale("lobby.leader_leave_game")
                )
            end
        end
        
        Lobby.leave(lobbyId, source)
    end
    
    PersonalChallengesServer.onPlayerUnloaded(source)
end

if Config.FarmingMenu.openWithItem then
    if Config.FarmingMenu.openWithItem.active then
        server.createUseableItem(Config.FarmingMenu.openWithItem.itemName, function(source)
            TriggerClientEvent("0r-farming-v2:client:openMenu", source)
        end)
    end
end

lib.callback.register(_e("server:inventory:getPlayerInventory"), function(source)
    local inventory = inventoryModule.getInventory(source)
    
    for _, item in pairs(inventory) do
        if item then
            if not item.count then
                item.count = item.amount or 1
            end
        end
    end
    
    return {
        items = inventory,
    }
end)

lib.callback.register(_e("server:inventory:hasRequiredItem"), function(source, itemName, count, metadata)
    return inventoryModule.hasItem(source, itemName, count, metadata)
end)

lib.callback.register(_e("server:inventory:removeItem"), function(source, itemName, count, metadata)
    return inventoryModule.removeItem(source, itemName, count, metadata)
end)

RegisterNetEvent(_e("server:onPlayerLogout"), function()
    local source = source
    onPlayerUnload(source)
end)

AddEventHandler("playerDropped", function()
    local source = source
    onPlayerUnload(source)
end)
