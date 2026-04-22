Resmon = Resmon or {}
Resmon.ServerCallbacks = {}
Resmon.Framework = nil

if GetResourceState(Config.CoreName["ESX"]) ~= 'missing' then
    Config.Framework = 'ESX'
    Resmon.Framework = exports[Config.CoreName["ESX"]]:getSharedObject()
elseif GetResourceState(Config.CoreName["QBCore"]) ~= 'missing' then
    Config.Framework = 'QBCore'
    Resmon.Framework = exports[Config.CoreName["QBCore"]]:GetCoreObject()
end

MySQL.ready(function()
    print("[0Resmon] MySQL Connection established.")
end)

function Resmon.Framework.GetPlayer(source)
    -- [AUDIT AUD-004] Use selected framework object safely in server context
    if Config.Framework == 'QBCore' and Resmon.Framework and Resmon.Framework.Functions then
        return Resmon.Framework.Functions.GetPlayer(source)
    elseif Config.Framework == 'ESX' and Resmon.Framework and Resmon.Framework.GetPlayerFromId then
        return Resmon.Framework.GetPlayerFromId(source)
    end
    return nil
end

local function IsValidTargetSource(src, target)
    if type(src) ~= 'number' then return false end
    if type(target) ~= 'number' then return false end
    if target < 1 then return false end
    if not GetPlayerName(target) then return false end
    -- Allow notifying other players only if ACE permission exists
    if target ~= src and not IsPlayerAceAllowed(src, '0r_lib.notify.others') then
        return false
    end
    return true
end

RegisterServerEvent('0R:Core:NewPlayerJoined')
AddEventHandler('0R:Core:NewPlayerJoined', function()
    local src = source
    local xPlayer = Resmon.Framework.GetPlayer(src)
    if not xPlayer then 
        print("[0Resmon] Failed to get player data for source: " .. src)
        return 
    end
    
    print("[0Resmon] Player joined: " .. xPlayer.identifier)
    TriggerClientEvent("0R:Core:SetPlayerData", src, xPlayer)
end)

RegisterServerEvent('0R:Core:SetPlayerJob')
AddEventHandler('0R:Core:SetPlayerJob', function(job)
    local src = source
    local xPlayer = Resmon.Framework.GetPlayer(src)
    if not xPlayer then return end
    
    xPlayer.setJob(job, xPlayer.job.grade)
    print("[0Resmon] Job updated: " .. xPlayer.identifier .. " -> " .. job.name)
end)

RegisterServerEvent('0R:Core:TriggerCallback')
AddEventHandler('0R:Core:TriggerCallback', function(name, requestId, ...)
    local src = source
    if Resmon.ServerCallbacks[name] then
        Resmon.ServerCallbacks[name](function(...)
            TriggerClientEvent('0R:Core:ServerCallback', src, requestId, ...)
        end, src, ...)
    end
end)

function Resmon.RegisterServerCallback(name, cb)
    Resmon.ServerCallbacks[name] = cb
end

function Resmon.Framework.GetMoney(source, account)
    local xPlayer = Resmon.Framework.GetPlayer(source)
    if not xPlayer then return 0 end
    if Config.Framework == 'QBCore' then
        return xPlayer.Functions.GetMoney(account)
    else
        return xPlayer.getAccount(account).money
    end
end

function Resmon.Framework.SetMoney(source, account, amount)
    local xPlayer = Resmon.Framework.GetPlayer(source)
    if not xPlayer then return end
    if Config.Framework == 'QBCore' then
        xPlayer.Functions.SetMoney(account, amount)
    else
        xPlayer.setAccountMoney(account, amount)
    end
end

RegisterNetEvent(Config.Framework == "QBCore" and "QBCore:PlayerLoaded" or "esx:playerLoaded")
AddEventHandler(Config.Framework == "QBCore" and "QBCore:PlayerLoaded" or "esx:playerLoaded", function(playerId)
    local xPlayer = Resmon.Framework.GetPlayer(playerId)
    if not xPlayer then return end
    print("[0Resmon] Player fully loaded: " .. xPlayer.identifier)
end)

RegisterServerEvent('0R:Lib:Notify')
AddEventHandler('0R:Lib:Notify', function(target, data)
    local src = source
    if not IsValidTargetSource(src, target) then return end
    if type(data) ~= 'table' then return end
    if data.title and type(data.title) ~= 'string' then return end
    if data.text and type(data.text) ~= 'string' then return end
    if data.type and type(data.type) ~= 'string' then return end
    TriggerClientEvent('0R:Lib:Notify', target, data)
end)

RegisterServerEvent('0R:Core:GetVehicleProperties')
AddEventHandler('0R:Core:GetVehicleProperties', function(plate, cb)
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE plate = @plate', {['@plate'] = plate}, function(result)
        if result[1] then
            cb(json.decode(result[1].vehicle))
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('0R:Core:SetVehicleProperties')
AddEventHandler('0R:Core:SetVehicleProperties', function(plate, props)
    MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
        ['@vehicle'] = json.encode(props),
        ['@plate'] = plate
    })
end)

RegisterServerEvent('0R:Core:ShowTextUI')
AddEventHandler('0R:Core:ShowTextUI', function(target, text, icon)
    local src = source
    if not IsValidTargetSource(src, target) then return end
    if type(text) ~= 'string' then return end
    if #text > 120 then return end
    if icon ~= nil and type(icon) ~= 'string' then return end
    TriggerClientEvent('0R:Core:ShowTextUI', target, text, icon)
end)

RegisterServerEvent('0R:Core:HideTextUI')
AddEventHandler('0R:Core:HideTextUI', function(target)
    local src = source
    if not IsValidTargetSource(src, target) then return end
    TriggerClientEvent('0R:Core:HideTextUI', target)
end)
