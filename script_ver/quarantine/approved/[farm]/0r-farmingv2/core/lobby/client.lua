local utils

Lobby = {}
utils = require("modules.utils.client")

function Lobby.isIn()
    return client.lobby.id ~= nil
end

RegisterNUICallback("nui:lobby:hireTeamMember", function(data, cb)
    local result = lib.callback.await(_e("server:lobby:invite"), false, client.lobby.id, data)
    
    if result.error then
        client.sendReactAlert(result.error, "error")
        return cb(false)
    end
    
    client.sendReactAlert(locale("lobby.invited_player"), "success")
    cb(true)
end)

RegisterNUICallback("nui:lobby:fireTeamMember", function(data, cb)
    local result = lib.callback.await(_e("server:lobby:fireMember"), false, client.lobby.id, data)
    
    if result.error then
        client.sendReactAlert(result.error, "error")
        return cb(false)
    end
    
    cb(true)
end)

RegisterNetEvent(_e("client:lobby:setPlayerLobby"), function(lobby)
    if not lobby then
        client.lobby = {}
    else
        client.lobby = lobby
    end
    
    client.sendReactMessage("ui:setLobby", lobby)
end)

RegisterNetEvent(_e("client:lobby:receiveLobbyInvite"), function(lobbyId, ownerName)
    if client.currentTask then
        return
    end
    
    client.sendReactMessage("ui:inviteReceived", {
        lobbyId = lobbyId,
        ownerName = ownerName,
    })
    
    if not client.uiOpen then
        SetNuiFocus(true, true)
    end
end)

RegisterNUICallback("nui:lobby:acceptJoinInvite", function(data, cb)
    local result = lib.callback.await(_e("server:lobby:join"), false, data)
    
    if result.error then
        if not client.uiOpen then
            client.hideUI()
            utils.notify(result.error, "error")
        else
            client.sendReactAlert(result.error, "error")
        end
        return cb(false)
    end
    
    client.sendReactAlert(locale("lobby.joined_lobby"), "success")
    
    if not client.uiOpen then
        client.hideUI()
    end
    
    cb(true)
end)

RegisterNUICallback("nui:lobby:onInviteModalClosed", function(data, cb)
    if not client.uiOpen then
        client.hideUI()
    end
    cb(true)
end)

RegisterNetEvent(_e("client:lobby:updateLobbyMembers"), function(members)
    client.lobby.members = members
    client.sendReactMessage("ui:setLobbyMembers", members)
end)
