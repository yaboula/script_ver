QBCore.Players = {}
QBCore.Player = {}

-- Compatibility shim for Money config (supports both QBCore.Config.Money and QBConfig.Money)
-- Ensure all required fields are present to prevent 'nil' errors
local MoneyCfg = (QBCore and QBCore.Config and QBCore.Config.Money) or (QBConfig and QBConfig.Money) or {}
MoneyCfg.DontAllowMinus = MoneyCfg.DontAllowMinus or {}
MoneyCfg.MinusLimit = MoneyCfg.MinusLimit or -1000000
MoneyCfg.MoneyTypes = MoneyCfg.MoneyTypes or {}


-- On player login get their data or set defaults
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function QBCore.Player.Login(source, citizenid, newData)
    local src = source
    if src then
        if citizenid then
            local result = exports.oxmysql:executeSync('SELECT * FROM players WHERE citizenid = ?', { citizenid })
            local PlayerData = result[1]
            if PlayerData then
                PlayerData.money = json.decode(PlayerData.money)
                PlayerData.job = json.decode(PlayerData.job)
                PlayerData.position = json.decode(PlayerData.position)
                PlayerData.metadata = json.decode(PlayerData.metadata)
                PlayerData.charinfo = json.decode(PlayerData.charinfo)
                if PlayerData.gang then
                    PlayerData.gang = json.decode(PlayerData.gang)
                else
                    PlayerData.gang = {}
                end
            end
            QBCore.Player.CheckPlayerData(src, PlayerData)
        else
            QBCore.Player.CheckPlayerData(src, newData)
        end
        return true
    else
        QBCore.ShowError(GetCurrentResourceName(), 'ERROR QBCore.PLAYER.LOGIN - NO SOURCE GIVEN!')
        return false
    end
end

function QBCore.Player.CheckPlayerData(source, PlayerData)
    local src = source
    PlayerData = PlayerData or {}
    PlayerData.source = src
    PlayerData.citizenid = PlayerData.citizenid or QBCore.Player.CreateCitizenId()
    PlayerData.license = PlayerData.license or QBCore.Functions.GetIdentifier(src, 'license')
    PlayerData.name = GetPlayerName(src)
    PlayerData.cid = PlayerData.cid or 1
    PlayerData.money = PlayerData.money or {}
    for moneytype, startamount in pairs(MoneyCfg.MoneyTypes) do
        PlayerData.money[moneytype] = PlayerData.money[moneytype] or startamount
    end
    -- Charinfo
    PlayerData.charinfo = PlayerData.charinfo or {}
    PlayerData.charinfo.firstname = PlayerData.charinfo.firstname or 'Firstname'
    PlayerData.charinfo.lastname = PlayerData.charinfo.lastname or 'Lastname'
    PlayerData.charinfo.birthdate = PlayerData.charinfo.birthdate or '00-00-0000'
    PlayerData.charinfo.gender = PlayerData.charinfo.gender or 0
    PlayerData.charinfo.backstory = PlayerData.charinfo.backstory or 'placeholder backstory'
    PlayerData.charinfo.nationality = PlayerData.charinfo.nationality or 'USA'
    PlayerData.charinfo.phone = PlayerData.charinfo.phone ~= nil and PlayerData.charinfo.phone or '1' .. math.random(1111, 9999)
    PlayerData.charinfo.account = PlayerData.charinfo.account ~= nil and PlayerData.charinfo.account or 'NC0' .. math.random(1, 9) .. 'WS' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
    -- Metadata
    PlayerData.metadata = PlayerData.metadata or {}
    PlayerData.metadata['health'] = PlayerData.metadata['health'] or 200
    PlayerData.metadata['hunger'] = PlayerData.metadata['hunger'] or 100
    PlayerData.metadata['thirst'] = PlayerData.metadata['thirst'] or 100
    PlayerData.metadata['stress'] = PlayerData.metadata['stress'] or 0
    PlayerData.metadata['playtime'] = PlayerData.metadata['playtime'] or 0
    PlayerData.metadata['isdead'] = PlayerData.metadata['isdead'] or false
    PlayerData.metadata['inlaststand'] = PlayerData.metadata['inlaststand'] or false
    PlayerData.metadata['armor'] = PlayerData.metadata['armor'] or 0
    PlayerData.metadata['ishandcuffed'] = PlayerData.metadata['ishandcuffed'] or false
    PlayerData.metadata['tracker'] = PlayerData.metadata['tracker'] or false
    PlayerData.metadata['injail'] = PlayerData.metadata['injail'] or 0
    PlayerData.metadata['jailitems'] = PlayerData.metadata['jailitems'] or {}
    PlayerData.metadata['status'] = PlayerData.metadata['status'] or {}
    PlayerData.metadata['phone'] = PlayerData.metadata['phone'] or {}
    PlayerData.metadata['fitbit'] = PlayerData.metadata['fitbit'] or {}
    PlayerData.metadata['commandbinds'] = PlayerData.metadata['commandbinds'] or {}
    PlayerData.metadata['bloodtype'] = PlayerData.metadata['bloodtype'] or QBCore.Config.Player.Bloodtypes[math.random(1, #QBCore.Config.Player.Bloodtypes)]
    PlayerData.metadata['dealerrep'] = PlayerData.metadata['dealerrep'] or 0
    PlayerData.metadata['craftingrep'] = PlayerData.metadata['craftingrep'] or 0
    PlayerData.metadata['garbage'] = PlayerData.metadata['garbage'] or 0
    PlayerData.metadata['attachmentcraftingrep'] = PlayerData.metadata['attachmentcraftingrep'] or 0
    PlayerData.metadata["communityservice"] = PlayerData.metadata["communityservice"] or 0
    PlayerData.metadata['reporep'] = PlayerData.metadata['reporep'] or 0

    PlayerData.metadata['carboostclass'] = PlayerData.metadata['carboostclass'] or 'D'
    PlayerData.metadata['carboostrep'] = PlayerData.metadata['carboostrep'] or 0
    PlayerData.metadata['laptopdata'] = PlayerData.metadata['laptopdata'] or {
        wallpaper = 'default',
        apps = {}
    }

    PlayerData.metadata['currentapartment'] = PlayerData.metadata['currentapartment'] or nil
    PlayerData.metadata['jobrep'] = PlayerData.metadata['jobrep'] or {
        ['tow'] = 0,
        ['trucker'] = 0,
        ['taxi'] = 0,
        ['hotdog'] = 0,
    }
    PlayerData.metadata['callsign'] = PlayerData.metadata['callsign'] or 'NO CALLSIGN'
    PlayerData.metadata['fingerprint'] = PlayerData.metadata['fingerprint'] or QBCore.Player.CreateFingerId()
    PlayerData.metadata['walletid'] = PlayerData.metadata['walletid'] or QBCore.Player.CreateWalletId()
    PlayerData.metadata['criminalrecord'] = PlayerData.metadata['criminalrecord'] or {
        ['hasRecord'] = false,
        ['date'] = nil
    }
    PlayerData.metadata['licences'] = PlayerData.metadata['licences'] or {
        ['driver'] = true,
        ['business'] = false,
        ['weapon'] = false
    }
    PlayerData.metadata['inside'] = PlayerData.metadata['inside'] or {
        house = nil,
        apartment = {
            apartmentType = nil,
            apartmentId = nil,
        }
    }
    PlayerData.metadata['crypto'] = PlayerData.metadata['crypto'] or {
        ["shung"] = 0,
        ["gne"] = 0,
        ["xcoin"] = 0,
        ["lme"] = 0
    }
    
    PlayerData.metadata['phonedata'] = PlayerData.metadata['phonedata'] or {
        SerialNumber = QBCore.Player.CreateSerialNumber(),
        InstalledApps = {},
    }
    PlayerData.metadata['dealers_xp'] = PlayerData.metadata['dealers_xp'] or {global = 0}
    PlayerData.metadata['dealers_pfp'] = PlayerData.metadata['dealers_pfp'] or "https://cdn.discordapp.com/attachments/894580648747102251/1000078487052361768/pfp.png"
    -- Job
    PlayerData.job = PlayerData.job or {}
    PlayerData.job.name = PlayerData.job.name or 'unemployed'
    PlayerData.job.label = PlayerData.job.label or 'Civilian'
    PlayerData.job.payment = PlayerData.job.payment or 10
    if QBCore.Shared.ForceJobDefaultDutyAtLogin or PlayerData.job.onduty == nil then
        PlayerData.job.onduty = QBCore.Shared.Jobs[PlayerData.job.name].defaultDuty
    end
    PlayerData.job.isboss = PlayerData.job.isboss or false
    PlayerData.job.grade = PlayerData.job.grade or {}
    PlayerData.job.grade.name = PlayerData.job.grade.name or 'Freelancer'
    PlayerData.job.grade.level = PlayerData.job.grade.level or 0
    -- Gang
    PlayerData.gang = PlayerData.gang or {}
    PlayerData.gang.name = PlayerData.gang.name or 'none'
    PlayerData.gang.label = PlayerData.gang.label or 'No Gang Affiliaton'
    PlayerData.gang.isboss = PlayerData.gang.isboss or false
    PlayerData.gang.grade = PlayerData.gang.grade or {}
    PlayerData.gang.grade.name = PlayerData.gang.grade.name or 'none'
    PlayerData.gang.grade.level = PlayerData.gang.grade.level or 0
    -- Other
    PlayerData.position = PlayerData.position or QBConfig.DefaultSpawn
    PlayerData.LoggedIn = true
    PlayerData = QBCore.Player.LoadInventory(PlayerData)
    QBCore.Player.CreatePlayer(PlayerData)
end

-- On player logout

function QBCore.Player.Logout(source)
    local src = source
    TriggerClientEvent('QBCore:Client:OnPlayerUnload', src)
    TriggerClientEvent('QBCore:Player:UpdatePlayerData', src)
    Wait(200)
    QBCore.Players[src] = nil
end

-- Create a new character
-- Don't touch any of this unless you know what you are doing
-- Will cause major issues!

function QBCore.Player.CreatePlayer(PlayerData)
    local self = {}
    self.Functions = {}
    self.PlayerData = PlayerData

    self.Functions.UpdatePlayerData = function(dontUpdateChat)
        TriggerClientEvent('QBCore:Player:SetPlayerData', self.PlayerData.source, self.PlayerData)
        if dontUpdateChat == nil then
            QBCore.Commands.Refresh(self.PlayerData.source)
        end
    end

    self.Functions.SetJob = function(job, grade)
        local job = job:lower()
        local grade = tostring(grade) or '0'

        if QBCore.Shared.Jobs[job] then
            self.PlayerData.job.name = job
            self.PlayerData.job.label = QBCore.Shared.Jobs[job].label
            self.PlayerData.job.onduty = QBCore.Shared.Jobs[job].defaultDuty
            self.PlayerData.job.type = QBCore.Shared.Jobs[job].type 
            or self.PlayerData.job.type 
            or nil

            if QBCore.Shared.Jobs[job].grades[grade] then
                local jobgrade = QBCore.Shared.Jobs[job].grades[grade]
                self.PlayerData.job.grade = {}
                self.PlayerData.job.grade.name = jobgrade.name
                self.PlayerData.job.grade.level = tonumber(grade)
                self.PlayerData.job.payment = jobgrade.payment or 30
                self.PlayerData.job.isboss = jobgrade.isboss or false
            else
                self.PlayerData.job.grade = {}
                self.PlayerData.job.grade.name = 'No Grades'
                self.PlayerData.job.grade.level = 0
                self.PlayerData.job.payment = 30
                self.PlayerData.job.isboss = false
            end

            self.Functions.UpdatePlayerData()
            TriggerClientEvent('QBCore:Client:OnJobUpdate', self.PlayerData.source, self.PlayerData.job)
            return true
        end

        return false
    end

    self.Functions.SetGang = function(gang, grade)
        local gang = gang:lower()
        local grade = tostring(grade) or '0'

        if QBCore.Shared.Gangs[gang] then
            self.PlayerData.gang.name = gang
            self.PlayerData.gang.label = QBCore.Shared.Gangs[gang].label
            if QBCore.Shared.Gangs[gang].grades[grade] then
                local ganggrade = QBCore.Shared.Gangs[gang].grades[grade]
                self.PlayerData.gang.grade = {}
                self.PlayerData.gang.grade.name = ganggrade.name
                self.PlayerData.gang.grade.level = tonumber(grade)
                self.PlayerData.gang.isboss = ganggrade.isboss or false
            else
                self.PlayerData.gang.grade = {}
                self.PlayerData.gang.grade.name = 'No Grades'
                self.PlayerData.gang.grade.level = 0
                self.PlayerData.gang.isboss = false
            end

            self.Functions.UpdatePlayerData()
            TriggerClientEvent('QBCore:Client:OnGangUpdate', self.PlayerData.source, self.PlayerData.gang)
            return true
        end
        return false
    end

    self.Functions.SetJobDuty = function(onDuty)
        self.PlayerData.job.onduty = onDuty
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.SetPlayerData(key, val)
        if not key or type(key) ~= 'string' then return end
        self.PlayerData[key] = val
        self.Functions.UpdatePlayerData()
    end

    function self.Functions.AddMethod(methodName, handler)
        self.Functions[methodName] = handler
    end

    function self.Functions.AddField(fieldName, data)
        self[fieldName] = data
    end

    self.Functions.SetMetaData = function(meta, val)
        local meta = meta:lower()
        if val ~= nil then
            self.PlayerData.metadata[meta] = val
            self.Functions.UpdatePlayerData()
        end
    end

    self.Functions.AddJobReputation = function(amount)
        local amount = tonumber(amount)
        self.PlayerData.metadata['jobrep'][self.PlayerData.job.name] = self.PlayerData.metadata['jobrep'][self.PlayerData.job.name] + amount
        self.Functions.UpdatePlayerData()
    end

function self.Functions.AddMoney(moneytype, amount, reason)
    reason = reason or 'unknown'
    moneytype = moneytype:lower()
    amount = tonumber(amount)
    if amount <= 0 then return false end
    if not self.PlayerData.money[moneytype] then return false end
    self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] + amount

    if not self.Offline then
        self.Functions.UpdatePlayerData()
        if amount > 100000 then
            TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true)
        else
            TriggerEvent('qb-log:server:CreateLog', 'playermoney', 'AddMoney', 'lightgreen', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') added, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason)
        end
        --TriggerClientEvent('hud:client:OnMoneyChange', self.PlayerData.source, moneytype, amount, false)
        TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
        TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'add', reason)
    end

    return true
end

self.Functions.RemoveMoney = function(moneytype, amount, reason)
    reason = reason or 'unknown'
    local moneytype = tostring(moneytype):lower()
    local amount = tonumber(amount)
    if not amount or amount <= 0 then return false end
    if not self.PlayerData.money[moneytype] then return false end

    -- Verificar si no permite saldo negativo
    for _, mtype in pairs(MoneyCfg.DontAllowMinus) do
        if mtype == moneytype and (self.PlayerData.money[moneytype] - amount) < 0 then
            return false
        end
    end

    -- ✅ Corrección: Usar MoneyCfg.MinusLimit en lugar de QBCore.Config.Money.MinusLimit
    if self.PlayerData.money[moneytype] - amount < MoneyCfg.MinusLimit then
        return false
    end

    self.PlayerData.money[moneytype] = self.PlayerData.money[moneytype] - amount

    if not self.Offline then
        self.Functions.UpdatePlayerData()
        if amount > 100000 then
            TriggerEvent('qb-logs:server:createLog', 'playermoney', 'RemoveMoney', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, true, self.PlayerData.source)
        else
            TriggerEvent('qb-logs:server:createLog', 'playermoney', 'RemoveMoney', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** $' .. amount .. ' (' .. moneytype .. ') removed, new ' .. moneytype .. ' balance: ' .. self.PlayerData.money[moneytype] .. ' reason: ' .. reason, false, self.PlayerData.source)
        end
        if moneytype == 'bank' then
            TriggerClientEvent('qb-phone:client:RemoveBankMoney', self.PlayerData.source, amount)
        end
        TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
        TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, amount, 'remove', reason)
    end
    return true
end

function self.Functions.SetMoney(moneytype, amount, reason)
    reason = reason or 'unknown'
    moneytype = tostring(moneytype or ''):lower()
    amount = tonumber(amount or 0)
    if amount < 0 then return false end
    if not self.PlayerData.money then self.PlayerData.money = {} end
    if self.PlayerData.money[moneytype] == nil then self.PlayerData.money[moneytype] = 0 end

    local difference = amount - self.PlayerData.money[moneytype]
    self.PlayerData.money[moneytype] = amount

    if not self.Offline then
        self.Functions.UpdatePlayerData()
        TriggerClientEvent('QBCore:Client:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), (difference < 0) and 'remove' or 'add', reason)
        TriggerEvent('QBCore:Server:OnMoneyChange', self.PlayerData.source, moneytype, math.abs(difference), (difference < 0) and 'remove' or 'add', reason)
    end

    return true
end

    self.Functions.GetMoney = function(moneytype)
        if moneytype then
            local moneytype = moneytype:lower()
            return self.PlayerData.money[moneytype]
        end
        return false
    end

-- self.Functions.AddItem = function(item, amount, slot, info, created)
--     local totalWeight = QBCore.Player.GetTotalWeight(self.PlayerData.items)
--     local itemInfo = QBCore.Shared.Items[item:lower()]
--     local time = os.time()
--     if not created then 
--         itemInfo['created'] = time
--     else 
--         itemInfo['created'] = created
--     end
--     -- itemInfo['created'] = time
--     if itemInfo["type"] == 'item' and info == nil then
--         info = { quality = 100 }
--     end
--     if itemInfo == nil then
--         TriggerClientEvent('QBCore:Notify', self.PlayerData.source, 'error.item_not_exist', 'error')
--         return
--     end
--     local amount = tonumber(amount)
--     local slot = tonumber(slot) or QBCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)
--     if itemInfo['type'] == 'weapon' and info == nil then
--         info = {
--             serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4)),
--         }
--     end
--     if (totalWeight + (itemInfo['weight'] * amount)) <= QBCore.Config.Player.MaxWeight then
--         if (slot and self.PlayerData.items[slot]) and (self.PlayerData.items[slot].name:lower() == item:lower()) and (itemInfo['type'] == 'item' and not itemInfo['unique']) then
--             self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount + amount
--             self.Functions.UpdatePlayerData()
--             TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'AddItem', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. self.PlayerData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[slot].amount, false, self.PlayerData.source) 
--             return true
--         elseif (not itemInfo['unique'] and slot or slot and self.PlayerData.items[slot] == nil) then
--             self.PlayerData.items[slot] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = slot, combinable = itemInfo['combinable'], itemInfo['created'] }
--             self.Functions.UpdatePlayerData()
--             TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'AddItem', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. self.PlayerData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[slot].amount, false, self.PlayerData.source) 
--             return true
--         elseif (itemInfo['unique']) or (not slot or slot == nil) or (itemInfo['type'] == 'weapon') then
--             for i = 1, QBConfig.Player.MaxInvSlots, 1 do
--                 if self.PlayerData.items[i] == nil then
--                     self.PlayerData.items[i] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = i, combinable = itemInfo['combinable'], created = itemInfo['created'] }
--                     self.Functions.UpdatePlayerData()
--                     TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'AddItem', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** got item: [slot:' .. i .. '], itemname: ' .. self.PlayerData.items[i].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[i].amount, false, self.PlayerData.source) 
--                     return true
--                 end
--             end
--         end
--     else
--         TriggerClientEvent('QBCore:Notify', self.PlayerData.source, 'error.too_heavy', 'error')
--     end
--     return false
-- end

local function AddItem(itemName, item)
    if type(itemName) ~= "string" then
        return false, "invalid_item_name"
    end

    if QBCore.Shared.Items[itemName] then
        return false, "item_exists"
    end

    QBCore.Shared.Items[itemName] = item

    TriggerClientEvent('QBCore:Client:OnSharedUpdate', -1, 'Items', itemName, item)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, "success"
end

QBCore.Functions.AddItem = AddItem
exports('AddItem', AddItem)

local function AddItems(items)
    local shouldContinue = true
    local message = "success"
    local errorItem = nil

    for key, value in pairs(items) do
        if type(key) ~= "string" then
            message = "invalid_item_name"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        if QBCore.Shared.Items[key] then
            message = "item_exists"
            shouldContinue = false
            errorItem = items[key]
            break
        end

        QBCore.Shared.Items[key] = value
    end

    if not shouldContinue then return false, message, errorItem end
    TriggerClientEvent('QBCore:Client:OnSharedUpdateMultiple', -1, 'Items', items)
    TriggerEvent('QBCore:Server:UpdateObject')
    return true, message, nil
end

QBCore.Functions.AddItems = AddItems
exports('AddItems', AddItems)
    
    -- self.Functions.AddItem = function(item, amount, slot, info)
    --     local totalWeight = QBCore.Player.GetTotalWeight(self.PlayerData.items)
    --     local itemInfo = QBCore.Shared.Items[item:lower()]
    --     if itemInfo == nil then
    --         TriggerClientEvent('QBCore:Notify', self.PlayerData.source, 'Item Does Not Exist', 'error')
    --         return
    --     end
    --     local amount = tonumber(amount)
    --     local slot = tonumber(slot) or QBCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)
    --     if itemInfo['type'] == 'weapon' and info == nil then
    --         info = {
    --             serie = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4)),
    --         }
    --     end
    --     if (totalWeight + (itemInfo['weight'] * amount)) <= QBCore.Config.Player.MaxWeight then
    --         if (slot and self.PlayerData.items[slot]) and (self.PlayerData.items[slot].name:lower() == item:lower()) and (itemInfo['type'] == 'item' and not itemInfo['unique']) then
    --             self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount + amount
    --             self.Functions.UpdatePlayerData()
    --             TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. self.PlayerData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[slot].amount)
    --             return true
    --         elseif (not itemInfo['unique'] and slot or slot and self.PlayerData.items[slot] == nil) then
    --             self.PlayerData.items[slot] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = slot, combinable = itemInfo['combinable'] }
    --             self.Functions.UpdatePlayerData()
    --             TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** got item: [slot:' .. slot .. '], itemname: ' .. self.PlayerData.items[slot].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[slot].amount)
    --             return true
    --         elseif (itemInfo['unique']) or (not slot or slot == nil) or (itemInfo['type'] == 'weapon') then
    --             for i = 1, QBConfig.Player.MaxInvSlots, 1 do
    --                 if self.PlayerData.items[i] == nil then
    --                     self.PlayerData.items[i] = { name = itemInfo['name'], amount = amount, info = info or '', label = itemInfo['label'], description = itemInfo['description'] or '', weight = itemInfo['weight'], type = itemInfo['type'], unique = itemInfo['unique'], useable = itemInfo['useable'], image = itemInfo['image'], shouldClose = itemInfo['shouldClose'], slot = i, combinable = itemInfo['combinable'] }
    --                     self.Functions.UpdatePlayerData()
    --                     TriggerEvent('qb-log:server:CreateLog', 'playerinventory', 'AddItem', 'green', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** got item: [slot:' .. i .. '], itemname: ' .. self.PlayerData.items[i].name .. ', added amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[i].amount)
    --                     return true
    --                 end
    --             end
    --         end
    --     else
    --         TriggerClientEvent('QBCore:Notify', self.PlayerData.source, 'Your inventory is too heavy!', 'error')
    --     end
    --     return false
    -- end

    self.Functions.RemoveItem = function(item, amount, slot)
        local amount = tonumber(amount)
        local slot = tonumber(slot)
        if slot then
            if self.PlayerData.items[slot].amount > amount then
                self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amount
                self.Functions.UpdatePlayerData()
                TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'RemoveItem', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. self.PlayerData.items[slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[slot].amount, false, self.PlayerData.source) 
                return true
            else
                self.PlayerData.items[slot] = nil
                self.Functions.UpdatePlayerData()
                TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'RemoveItem', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. item .. ', removed amount: ' .. amount .. ', item removed', false, self.PlayerData.source)
                return true
            end
        else
            local slots = QBCore.Player.GetSlotsByItem(self.PlayerData.items, item)
            local amountToRemove = amount
            if slots then
                for _, slot in pairs(slots) do
                    if self.PlayerData.items[slot].amount > amountToRemove then
                        self.PlayerData.items[slot].amount = self.PlayerData.items[slot].amount - amountToRemove
                        self.Functions.UpdatePlayerData()
                        TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'RemoveItem', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. self.PlayerData.items[slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[slot].amount, false, self.PlayerData.source)
                        return true
                    elseif self.PlayerData.items[slot].amount == amountToRemove then
                        self.PlayerData.items[slot] = nil
                        self.Functions.UpdatePlayerData()
                       -- TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'RemoveItem', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** lost item: [slot:' .. slot .. '], itemname: ' .. self.PlayerData.items[slot].name .. ', removed amount: ' .. amount .. ', new total amount: ' .. self.PlayerData.items[slot].amount, false, self.PlayerData.source)
                        return true
                    end
                end
            end
        end
        return false
    end

    self.Functions.SetInventory = function(items, dontUpdateChat)
        self.PlayerData.items = items
        self.Functions.UpdatePlayerData(dontUpdateChat)
        TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'SetInventory', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** items set: ' .. json.encode(items), false, self.PlayerData.source) 
    end

    self.Functions.ClearInventory = function()
        self.PlayerData.items = {}
        self.Functions.UpdatePlayerData()
        TriggerEvent('qb-logs:server:createLog', 'playerinventory', 'ClearInventory', '**' .. GetPlayerName(self.PlayerData.source) .. ' (citizenid: ' .. self.PlayerData.citizenid .. ' | id: ' .. self.PlayerData.source .. ')** inventory cleared', false, self.PlayerData.source)
    end

    self.Functions.GetItemByName = function(item)
        local item = tostring(item):lower()
        local slot = QBCore.Player.GetFirstSlotByItem(self.PlayerData.items, item)
        if slot then
            return self.PlayerData.items[slot]
        end
        return nil
    end

    self.Functions.GetItemsByName = function(item)
        local item = tostring(item):lower()
        local items = {}
        local slots = QBCore.Player.GetSlotsByItem(self.PlayerData.items, item)
        for _, slot in pairs(slots) do
            if slot then
                items[#items+1] = self.PlayerData.items[slot]
            end
        end
        return items
    end

    self.Functions.SetCreditCard = function(cardNumber)
        self.PlayerData.charinfo.card = cardNumber
        self.Functions.UpdatePlayerData()
    end

    self.Functions.GetCardSlot = function(cardNumber, cardType)
        local item = tostring(cardType):lower()
        local slots = QBCore.Player.GetSlotsByItem(self.PlayerData.items, item)
        for _, slot in pairs(slots) do
            if slot then
                if self.PlayerData.items[slot].info.cardNumber == cardNumber then
                    return slot
                end
            end
        end
        return nil
    end

    self.Functions.GetItemBySlot = function(slot)
        local slot = tonumber(slot)
        if self.PlayerData.items[slot] then
            return self.PlayerData.items[slot]
        end
        return nil
    end

    self.Functions.Save = function()
        QBCore.Player.Save(self.PlayerData.source)
    end

    QBCore.Players[self.PlayerData.source] = self
    QBCore.Player.Save(self.PlayerData.source)

    -- At this point we are safe to emit new instance to third party resource for load handling
    TriggerEvent('QBCore:Server:PlayerLoaded', self)
    self.Functions.UpdatePlayerData()
end

-- Save player info to database (make sure citizenid is the primary key in your database)

function QBCore.Player.Save(source)
    local src = source
    local ped = GetPlayerPed(src)
    local pcoords = GetEntityCoords(ped)
    local PlayerData = QBCore.Players[src].PlayerData
    if PlayerData then
        exports.oxmysql:insert('INSERT INTO players (citizenid, cid, license, name, money, charinfo, job, gang, position, metadata) VALUES (:citizenid, :cid, :license, :name, :money, :charinfo, :job, :gang, :position, :metadata) ON DUPLICATE KEY UPDATE cid = :cid, name = :name, money = :money, charinfo = :charinfo, job = :job, gang = :gang, position = :position, metadata = :metadata', {
            citizenid = PlayerData.citizenid,
            cid = tonumber(PlayerData.cid),
            license = PlayerData.license,
            name = PlayerData.name,
            money = json.encode(PlayerData.money),
            charinfo = json.encode(PlayerData.charinfo),
            job = json.encode(PlayerData.job),
            gang = json.encode(PlayerData.gang),
            position = json.encode(pcoords),
            metadata = json.encode(PlayerData.metadata)
        })
        QBCore.Player.SaveInventory(src)
        QBCore.ShowSuccess(GetCurrentResourceName(), PlayerData.name .. ' PLAYER SAVED!')
    else
        QBCore.ShowError(GetCurrentResourceName(), 'ERROR QBCore.PLAYER.SAVE - PLAYERDATA IS EMPTY!')
    end
end

-- Delete character

local playertables = { -- Add tables as needed
    { table = 'players' },
    { table = 'apartments' },
    { table = 'bank_accounts' },
    { table = 'crypto_transactions' },
    { table = 'phone_invoices' },
    { table = 'phone_messages' },
    { table = 'playerskins' },
    { table = 'player_boats' },
    { table = 'player_contacts' },
    { table = 'player_houses' },
    { table = 'player_mails' },
    { table = 'player_outfits' },
    { table = 'player_vehicles' }
}

function QBCore.Player.DeleteCharacter(source, citizenid)
    local src = source
    local license = QBCore.Functions.GetIdentifier(src, 'license')
    local result = exports.oxmysql:scalarSync('SELECT license FROM players where citizenid = ?', { citizenid })
    if license == result then
        for k, v in pairs(playertables) do
            exports.oxmysql:execute('DELETE FROM ' .. v.table .. ' WHERE citizenid = ?', { citizenid })
        end
        TriggerEvent('qb-logs:server:createLog', 'joinleave', 'Character Deleted', '**' .. GetPlayerName(src) .. '** ' .. license .. ' deleted **' .. citizenid .. '**..', false, src)
    else
        DropPlayer(src, 'You Have Been Kicked For Exploitation')
        TriggerEvent('qb-logs:server:createLog', 'anticheat', 'Anti-Cheat', GetPlayerName(src) .. ' Has Been Dropped For Character Deletion Exploit', false, src)
    end
end

-- Inventory

-- QBCore.Player.LoadInventory = function(PlayerData)
--     PlayerData.items = {}
--     local result = exports.oxmysql:singleSync('SELECT * FROM players WHERE citizenid = ?', { PlayerData.citizenid })
--     if result then
--         if result.inventory then
--             local plyInventory = json.decode(result.inventory)
--             if next(plyInventory) then
--                 for _, item in pairs(plyInventory) do
--                     if item then
--                         local itemInfo = QBCore.Shared.Items[item.name:lower()]
--                         if itemInfo then
--                             PlayerData.items[item.slot] = {
--                                 name = itemInfo['name'],
--                                 amount = item.amount,
--                                 info = item.info or '',
--                                 label = itemInfo['label'],
--                                 description = itemInfo['description'] or '',
--                                 weight = itemInfo['weight'],
--                                 type = itemInfo['type'],
--                                 unique = itemInfo['unique'],
--                                 useable = itemInfo['useable'],
--                                 image = itemInfo['image'],
--                                 shouldClose = itemInfo['shouldClose'],
--                                 slot = item.slot,
--                                 combinable = itemInfo['combinable']
--                             }
--                         end
--                     end
--                 end
--             end
--         end
--     end
--     return PlayerData
-- end

QBCore.Player.LoadInventory = function(PlayerData)
    PlayerData.items = {}
    local inventory = MySQL.Sync.prepare('SELECT inventory FROM players WHERE citizenid = ?', { PlayerData.citizenid })
    if inventory then
        inventory = json.decode(inventory)
        if next(inventory) then
            for _, item in pairs(inventory) do
                if item then
                    local itemInfo = QBCore.Shared.Items[item.name:lower()]
                    if itemInfo then
                        local time = os.time()
                        if item.created == nil then 
                            item.created = time
                        end
                        PlayerData.items[item.slot] = {
                            name = itemInfo['name'],
                            amount = item.amount,
                            info = item.info or '',
                            label = itemInfo['label'],
                            description = itemInfo['description'] or '',
                            weight = itemInfo['weight'],
                            type = itemInfo['type'],
                            unique = itemInfo['unique'],
                            useable = itemInfo['useable'],
                            image = itemInfo['image'],
                            shouldClose = itemInfo['shouldClose'],
                            slot = item.slot,
                            combinable = itemInfo['combinable'],
                            created = item.created
                        }
                    end
                end
            end
        end
    end
    return PlayerData
end

-- QBCore.Player.SaveInventory = function(source)
--     local src = source
--     if QBCore.Players[src] then
--         local PlayerData = QBCore.Players[src].PlayerData
--         local items = PlayerData.items
--         local ItemsJson = {}
--         if items and next(items) then
--             for slot, item in pairs(items) do
--                 if items[slot] then
--                     ItemsJson[#ItemsJson+1] = {
--                         name = item.name,
--                         amount = item.amount,
--                         info = item.info,
--                         type = item.type,
--                         slot = slot,
--                     }
--                 end
--             end
--             exports.oxmysql:execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode(ItemsJson), PlayerData.citizenid })
--         else
--             exports.oxmysql:execute('UPDATE players SET inventory = ? WHERE citizenid = ?', { '[]', PlayerData.citizenid })
--         end
--     end
-- end


-- new
function QBCore.Functions.AddPlayerMethod(ids, methodName, handler)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(QBCore.Players) do
                v.Functions.AddMethod(methodName, handler)
            end
        else
            if not QBCore.Players[ids] then return end

            QBCore.Players[ids].Functions.AddMethod(methodName, handler)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            QBCore.Functions.AddPlayerMethod(ids[i], methodName, handler)
        end
    end
end

function QBCore.Functions.AddPlayerField(ids, fieldName, data)
    local idType = type(ids)
    if idType == "number" then
        if ids == -1 then
            for _, v in pairs(QBCore.Players) do
                v.Functions.AddField(fieldName, data)
            end
        else
            if not QBCore.Players[ids] then return end

            QBCore.Players[ids].Functions.AddField(fieldName, data)
        end
    elseif idType == "table" and table.type(ids) == "array" then
        for i = 1, #ids do
            QBCore.Functions.AddPlayerField(ids[i], fieldName, data)
        end
    end
end
--------

QBCore.Player.SaveInventory = function(source)
    local src = source
    if QBCore.Players[src] then
        local PlayerData = QBCore.Players[src].PlayerData
        local items = PlayerData.items
        local ItemsJson = {}
        if items and next(items) then
            for slot, item in pairs(items) do
                if items[slot] then
                    ItemsJson[#ItemsJson+1] = {
                        name = item.name,
                        amount = item.amount,
                        info = item.info,
                        type = item.type,
                        created = item.created,
                        slot = slot,
                    }
                end
            end
            MySQL.Async.prepare('UPDATE players SET inventory = ? WHERE citizenid = ?', { json.encode(ItemsJson), PlayerData.citizenid })
        else
            MySQL.Async.prepare('UPDATE players SET inventory = ? WHERE citizenid = ?', { '[]', PlayerData.citizenid })
        end
    end
end

-- Util Functions

function QBCore.Player.GetTotalWeight(items)
    local weight = 0
    if items then
        for slot, item in pairs(items) do
            weight = weight + (item.weight * item.amount)
        end
    end
    return tonumber(weight)
end

function QBCore.Player.GetSlotsByItem(items, itemName)
    local slotsFound = {}
    if items then
        for slot, item in pairs(items) do
            if item.name:lower() == itemName:lower() then
                slotsFound[#slotsFound+1] = slot
            end
        end
    end
    return slotsFound
end

function QBCore.Player.GetFirstSlotByItem(items, itemName)
    if items then
        for slot, item in pairs(items) do
            if item.name:lower() == itemName:lower() then
                return tonumber(slot)
            end
        end
    end
    return nil
end

function QBCore.Player.CreateCitizenId()
    local UniqueFound = false
    local CitizenId = nil
    while not UniqueFound do
        CitizenId = tostring(QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(5)):upper()
        local result = exports.oxmysql:executeSync('SELECT COUNT(*) as count FROM players WHERE citizenid = ?', { CitizenId })
        if result[1].count == 0 then
            UniqueFound = true
        end
    end
    return CitizenId
end

function QBCore.Player.CreateFingerId()
    local UniqueFound = false
    local FingerId = nil
    while not UniqueFound do
        FingerId = tostring(QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(1) .. QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(4))
        local query = '%' .. FingerId .. '%'
        local result = exports.oxmysql:executeSync('SELECT COUNT(*) as count FROM `players` WHERE `metadata` LIKE ?', { query })
        if result[1].count == 0 then
            UniqueFound = true
        end
    end
    return FingerId
end

function QBCore.Player.CreateWalletId()
    local UniqueFound = false
    local WalletId = nil
    while not UniqueFound do
        WalletId = 'qb-' .. math.random(11111111, 99999999)
        local query = '%' .. WalletId .. '%'
        local result = exports.oxmysql:executeSync('SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?', { query })
        if result[1].count == 0 then
            UniqueFound = true
        end
    end
    return WalletId
end

function QBCore.Player.CreateSerialNumber()
    local UniqueFound = false
    local SerialNumber = nil
    while not UniqueFound do
        SerialNumber = math.random(11111111, 99999999)
        local query = '%' .. SerialNumber .. '%'
        local result = exports.oxmysql:executeSync('SELECT COUNT(*) as count FROM players WHERE metadata LIKE ?', { query })
        if result[1].count == 0 then
            UniqueFound = true
        end
    end
    return SerialNumber
end

AddEventHandler('QBCore:Server:OnPlayerUnload', function(Player)
    local src = Player.PlayerData.source
    local ped = GetPlayerPed(src)
    if DoesEntityExist(ped) then
        -- Save Health
        local health = GetEntityHealth(ped)
        Player.Functions.SetMetaData("health", health)

        -- Save Armor
        local armor = GetPedArmour(ped)
        Player.Functions.SetMetaData("armor", armor)

        -- Hunger / Thirst / Stress are already managed, but we force save anyway
        local hunger = Player.PlayerData.metadata["hunger"] or 100
        local thirst = Player.PlayerData.metadata["thirst"] or 100
        local stress = Player.PlayerData.metadata["stress"] or 0

        Player.Functions.SetMetaData("hunger", hunger)
        Player.Functions.SetMetaData("thirst", thirst)
        Player.Functions.SetMetaData("stress", stress)
    end
end)

-- Ensure defaults on load
AddEventHandler('QBCore:Server:OnPlayerLoaded', function(Player)
    if Player.PlayerData.metadata["health"] == nil then Player.Functions.SetMetaData("health", 200) end
    if Player.PlayerData.metadata["armor"] == nil then Player.Functions.SetMetaData("armor", 0) end
    if Player.PlayerData.metadata["hunger"] == nil then Player.Functions.SetMetaData("hunger", 100) end
    if Player.PlayerData.metadata["thirst"] == nil then Player.Functions.SetMetaData("thirst", 100) end
    if Player.PlayerData.metadata["stress"] == nil then Player.Functions.SetMetaData("stress", 0) end
end)

--PaycheckLoop() -- This just starts the paycheck system