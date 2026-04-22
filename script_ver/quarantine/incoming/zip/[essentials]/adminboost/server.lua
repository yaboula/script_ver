local QBCore = exports['qb-core']:GetCoreObject()

-- ?? Whitelisted FiveM License IDs
local AllowedLicenses = {
    ["license:572742c547dd2321109173aba5266f61b1c4585b"] = true,
    ["license:a6e980a19a24579e0d70543a7f7104e657bacfe8"] = true,
    ["license:7514ce658ae7a6da4774fdebbe032a6dca047270"] = true,
    ["license:e1a21848df4e1525b60b736af25c8ea3dd720b62"] = true,
  --[""] = true,
}

-- Function to get player's license
local function GetLicense(source)
    for _, id in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(id, 1, 8) == "license:" then
            return id
        end
    end
    return nil
end

QBCore.Functions.CreateUseableItem("admin_boost", function(source, item)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local license = GetLicense(source)

    if license and AllowedLicenses[license] then

        -- Remove item
        Player.Functions.RemoveItem("admin_boost", 1)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items["admin_boost"], "remove")

        -- ?? MAX EVERYTHING
        Player.Functions.SetMetaData("hunger", 100)
        Player.Functions.SetMetaData("thirst", 100)
        Player.Functions.SetMetaData("stress", 0)
        Player.Functions.SetMetaData("armor", 100)

        TriggerClientEvent('hud:client:UpdateNeeds', source, 100, 100)
        TriggerClientEvent('QBCore:Notify', source, "Admin Boost Activated!", "success")

        print("[ADMIN BOOST] Used by:", Player.PlayerData.name, "License:", license)
    else
        TriggerClientEvent('QBCore:Notify', source, "You are not whitelisted for this item.", "error")
        print("[ADMIN BOOST BLOCKED] License:", license)
    end
end)