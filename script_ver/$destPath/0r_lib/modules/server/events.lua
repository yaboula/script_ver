-- ============================================================
-- Core server-side player lifecycle events
-- Tracks connected players in Resmon.Lib.Players and keeps
-- clients in sync when players join or drop.
-- ============================================================

-- ── Player joined ───────────────────────────────────────────
-- Fired by the client when they are fully loaded in.
-- Builds a normalised info record and caches it, then confirms
-- back to the client with their own server ID.
RegisterNetEvent("0R:Core:NewPlayerJoined")
AddEventHandler("0R:Core:NewPlayerJoined", function()
    local playerId = source
    info = {}   -- global info table reset each join

    -- Only build the record if this player isn't already cached
    if not Resmon.Lib.Players[playerId] then
        local record = {}

        -- #record will be 0 here (freshly created), so this block
        -- always runs – guarded to match original intent exactly.
        if #record == 0 then
            local playerObj = Resmon.Lib.xPlayer(playerId)
            info = playerObj

            if Config.Framework == "ESX" then
                -- ESX: name lives directly on the player object;
                -- lastname comes from the first character record.
                info.firstname = info.name
                info.lastname  = record[1] and record[1].lastname or nil
                info.phone     = nil
            else
                -- QBCore: character info is nested under PlayerData.charinfo
                info.firstname = info.PlayerData.charinfo.firstname
                info.lastname  = info.PlayerData.charinfo.lastname
                info.phone     = info.PlayerData.charinfo.phone
            end

            Resmon.Lib.Players[playerId] = info
        end
    end

    -- Confirm to the client that the server has processed their join
    TriggerClientEvent("0R:Core:NewPlayerJoined", playerId, playerId)
end)

-- ── Player dropped (internal event) ────────────────────────
-- Removes the player's cached record from Resmon.Lib.Players.
RegisterNetEvent("0R:Core:PlayerDropped")
AddEventHandler("0R:Core:PlayerDropped", function(playerId, reason)
    if Resmon.Lib.Players[playerId] then
        Resmon.Lib.Players[playerId] = nil
    end
end)

-- ── Job update ──────────────────────────────────────────────
-- Keeps the server-side player record's job field up to date.
RegisterNetEvent("0R:Core:Server:setJob")
AddEventHandler("0R:Core:Server:setJob", function(newJob)
    local playerId = source
    Resmon.Lib.Players[playerId].job = newJob
end)

-- ── Native playerDropped hook ───────────────────────────────
-- FiveM fires this automatically when a player disconnects.
-- We relay it to both the internal server event and to all clients.
AddEventHandler("playerDropped", function(reason)
    local playerId = source
    TriggerEvent("0R:Core:PlayerDropped", playerId, reason)
    TriggerClientEvent("0R:Core:PlayerDropped", playerId, playerId, reason)
end)