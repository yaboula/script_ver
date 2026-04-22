local function GetStorePrice(index)
    if type(index) ~= "number" or index ~= math.floor(index) then
        return nil
    end

    local store = Config.Stores[index]
    if type(store) ~= "table" or type(store.price) ~= "number" or store.price < 0 then
        return nil
    end

    return store.price
end

Functions.RegisterServerCallback("17mov_CharacterSystem:CheckIfHaveEnoughMoney", function(source, index)
    Functions.Debug("CHECKING MONEY")
    local price = GetStorePrice(index)
    if not price then
        return false
    end

    local playerBank, playerMoney = 0, 0

    if Config.Framework == "QBCore" then
        local Player = Core.Functions.GetPlayer(source)
        if not Player then
            return false
        end
        playerBank, playerMoney = Player?.PlayerData?.money?.bank, Player?.PlayerData?.money?.cash
    elseif Config.Framework == "ESX" then
        local Player = Core.GetPlayerFromId(source)
        if not Player or type(Player.accounts) ~= "table" then
            return false
        end
        for k,v in pairs(Player.accounts) do
            if v.name == "bank" then
                playerBank = v.money
            elseif v.name == "money" then
                playerMoney = v.money
            end
        end
    end

    playerBank = tonumber(playerBank) or 0
    playerMoney = tonumber(playerMoney) or 0

    Functions.Debug("Price: ", price)
    Functions.Debug("Player Cash: ", playerMoney)
    Functions.Debug("Player Bank: ", playerBank)
    Functions.Debug("RETURNING : ", (playerMoney >= price or playerBank >= price))

    return (playerMoney >= price or playerBank >= price)
end)

Functions.RegisterServerCallback("17mov_CharacterSystem:TryToCharge", function(source, index)
    local price = GetStorePrice(index)
    if not price then
        return false
    end

    local playerBank, playerMoney = 0, 0
    if Config.Framework == "QBCore" then
        local Player = Core.Functions.GetPlayer(source)
        if not Player then
            return false
        end
        playerBank, playerMoney = Player?.PlayerData?.money?.bank, Player?.PlayerData?.money?.cash
        playerBank = tonumber(playerBank) or 0
        playerMoney = tonumber(playerMoney) or 0

        if playerMoney >= price then
            Player.Functions.RemoveMoney("cash", price)
            return true
        end

        if playerBank >= price then
            Player.Functions.RemoveMoney("bank", price)
            return true
        end
    elseif Config.Framework == "ESX" then
        local Player = Core.GetPlayerFromId(source)
        if not Player or type(Player.accounts) ~= "table" then
            return false
        end
        for k,v in pairs(Player.accounts) do
            if v.name == "bank" then
                playerBank = v.money
            elseif v.name == "money" then
                playerMoney = v.money
            end
        end

        playerBank = tonumber(playerBank) or 0
        playerMoney = tonumber(playerMoney) or 0

        if playerMoney >= price then
            Player.removeAccountMoney("money", price)
            return true
        end

        if playerBank >= price then
            Player.removeAccountMoney("bank", price)
            return true
        end
    end

    return false
end)