commands = {}
commandSuggestions = {}

function starts_with(str, start)
    return str:sub(1, #start) == start
end

RegisterServerEvent("chatt:checkPlayer")
AddEventHandler("chatt:checkPlayer", function()
    local src = source
    local displayName = GetPlayerName(src) or ("Player " .. tostring(src))
    TriggerClientEvent("chatt:SavePlayer", src, displayName)
end)