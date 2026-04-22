local lobbies = {}
local nextId = "0"

local function generateNextId(currentId)
    local carry = 1
    local result = ""
    local length = #currentId
    
    for i = length, 1, -1 do
        local digit = tonumber(currentId:sub(i, i))
        digit = digit + carry
        if digit >= 10 then
            digit = 0
            carry = 1
        else
            carry = 0
        end
        result = tostring(digit) .. result
    end
    
    if carry == 1 then
        result = "1" .. result
    end
    
    return result
end

Lobby = {}

function Lobby.getLobbyById(lobbyId)
    if lobbyId then
        if lobbies[lobbyId] then
            return lobbies[lobbyId]
        end
    end
    return false
end

function Lobby.isPlayerFree(source)
    for _, lobby in pairs(lobbies) do
        for _, member in pairs(lobby.members) do
            if member.source == source then
                return false
            end
        end
    end
    return true
end

function Lobby.updateMembers(lobbyId, excludeSource)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    for _, member in pairs(lobby.members) do
        if member.source ~= excludeSource then
            TriggerClientEvent(_e("client:lobby:updateLobbyMembers"), member.source, lobby.members)
        end
    end
    
    return true
end

function Lobby.updateData(lobbyId)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    if #lobby.members < 1 then
        return Lobby.delete(lobby.id)
    end
    
    if not lobby.owner then
        lobby.owner = lobby.members[1].source
    end
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:lobby:setPlayerLobby"), member.source, lobby)
    end
    
    return true
end

function Lobby.create(playerData)
    if type(playerData) == "number" then
        local source = playerData
        local profile = Profile.getBySource(source)
        playerData = {
            source = source,
            level = profile.level,
            name = server.getPlayerCharacterName(source),
            progress = 0,
        }
    end
    
    nextId = generateNextId(nextId)
    local lobbyId = nextId
    
    local lobby = {
        id = lobbyId,
        members = { playerData },
        owner = playerData.source,
        name = playerData.name,
        progress = playerData.progress,
    }
    
    lobbies[lobbyId] = lobby
    return lobbies[lobbyId]
end

function Lobby.join(lobbyId, playerData)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return { error = locale("lobby.lobby_not_found") }
    end
    
    if lobby.currentTask then
        return { error = locale("lobby.on_mission") }
    end
    
    if #lobby.members >= 4 then
        return { error = locale("lobby.lobby_is_full") }
    end
    
    if not Lobby.isPlayerFree(playerData.source) then
        Lobby.leaveInternal(lobbyId, playerData.source)
    end
    
    table.insert(lobby.members, playerData)
    
    local share = math.floor((100 / #lobby.members) * 10) / 10
    for _, member in pairs(lobby.members) do
        member.share = share
    end
    
    TriggerClientEvent(_e("client:lobby:setPlayerLobby"), playerData.source, lobby)
    Lobby.updateMembers(lobbyId, playerData.source)
    
    return {}
end

function Lobby.leaveInternal(lobbyId, source)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    for index, member in pairs(lobby.members) do
        if member.source == source then
            table.remove(lobby.members, index)
            if lobby.owner == source then
                lobby.owner = nil
            end
            return Lobby.updateData(lobbyId)
        end
    end
    
    return false
end

function Lobby.leave(lobbyId, source)
    return Lobby.leaveInternal(lobbyId, source)
end

function Lobby.delete(lobbyId)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    for _, member in pairs(lobby.members) do
        TriggerClientEvent(_e("client:lobby:setPlayerLobby"), member.source, nil)
    end
    
    lobbies[lobbyId] = nil
    return true
end

function Lobby.isPlayerInLobby(lobbyId, source)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    for _, member in pairs(lobby.members) do
        if member.source == source then
            return true
        end
    end
    
    return false
end

function Lobby.isPlayerInAnyLobby(source)
    for lobbyId, lobby in pairs(lobbies) do
        for _, member in pairs(lobby.members) do
            if member.source == source then
                return lobbyId
            end
        end
    end
    return false
end

function Lobby.getAll()
    return lobbies
end

function Lobby.invite(lobbyId, inviterSource, targetSource)
    if inviterSource == targetSource then
        return { error = locale("lobby.player_not_available") }
    end
    
    local targetPlayer = server.getPlayer(targetSource)
    if not targetPlayer then
        return { error = locale("lobby.player_not_available") }
    end
    
    local targetLobbyId = Lobby.isPlayerInAnyLobby(targetSource)
    if targetLobbyId then
        local targetLobby = Lobby.getLobbyById(targetLobbyId)
        if targetLobby then
            if targetLobby.currentTask then
                return { error = locale("lobby.on_mission") }
            end
        end
    end
    
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        local profile = Profile.getBySource(inviterSource)
        lobby = Lobby.create({
            source = inviterSource,
            level = profile.level,
            name = server.getPlayerCharacterName(inviterSource),
            progress = 0,
        })
        TriggerClientEvent(_e("client:lobby:setPlayerLobby"), inviterSource, lobby)
    end
    
    local inviterName = server.getPlayerCharacterName(inviterSource)
    TriggerClientEvent(_e("client:lobby:receiveLobbyInvite"), targetSource, lobby.id, inviterName)
    
    return {}
end

function Lobby.incMemberProgress(lobbyId, source, amount)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    if not amount then
        amount = 1
    end
    
    for _, member in pairs(lobby.members) do
        if member.source == source then
            member.progress = member.progress + amount
            return Lobby.updateData(lobbyId)
        end
    end
    
    return false
end

function Lobby.resetMemberProgress(lobbyId, source)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return false
    end
    
    for _, member in pairs(lobby.members) do
        if member.source == source then
            member.progress = 0
            return Lobby.updateData(lobbyId)
        end
    end
    
    return false
end

lib.callback.register(_e("server:lobby:invite"), function(source, lobbyId, targetSource)
    return Lobby.invite(lobbyId, source, targetSource)
end)

lib.callback.register(_e("server:lobby:fireMember"), function(source, lobbyId, targetSource)
    local lobby = Lobby.getLobbyById(lobbyId)
    if not lobby then
        return { error = locale("lobby.lobby_not_found") }
    end
    
    local isSelf = source == targetSource
    local isOwner = lobby.owner == source
    
    if isSelf or isOwner then
        Lobby.leave(lobbyId, targetSource)
        if isSelf then
            TriggerClientEvent(_e("client:lobby:setPlayerLobby"), source, nil)
        else
            Lobby.updateMembers(lobbyId)
            TriggerClientEvent(_e("client:lobby:setPlayerLobby"), targetSource, nil)
        end
        return {}
    end
    
    return { error = locale("lobby.you_are_not_leader") }
end)

lib.callback.register(_e("server:lobby:join"), function(source, lobbyId)
    local profile = Profile.getBySource(source)
    if not profile then
        profile = Profile.create(source)
    end
    
    return Lobby.join(lobbyId, {
        source = source,
        level = profile.level,
        name = server.getPlayerCharacterName(source),
        progress = 0,
    })
end)
