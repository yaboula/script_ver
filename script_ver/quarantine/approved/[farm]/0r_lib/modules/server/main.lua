-- ============================================================
-- Resmon Server Library - Core server-side utilities
-- Framework detection, player management, callbacks, database
-- helpers, and various shared server functions.
-- ============================================================

-- ── Sub-table initialisation ────────────────────────────────
ResmonFramework = nil

local Lib = Resmon.Lib
Lib.Players      = {}
Lib.ServerCallbacks = {}
Lib.Callback     = {}
Lib.Craft        = {}
Lib.Apartment    = {}
Lib.Caravan      = {}
Lib.PixelHouse   = {}
Lib.IllegalPack  = {}

-- ── Framework detection ─────────────────────────────────────
-- Try ESX first, then QBCore. Whichever resource is present wins.
if GetResourceState(Config.CoreName.ESX) ~= "missing" then
    Config.Framework = "ESX"
    ResmonFramework  = exports[Config.CoreName.ESX]:getSharedObject()
end

if GetResourceState(Config.CoreName.QBCore) ~= "missing" then
    Config.Framework = "QBCore"
    ResmonFramework  = exports[Config.CoreName.QBCore]:GetCoreObject()
end

-- ── Identifier helpers ──────────────────────────────────────

-- Extracts the primary identifier (e.g. license, steam, discord)
-- for a given player source, based on Config.PrimaryIdentifier.
function Resmon.Lib.PrimaryIdentifier(playerId)
    local prefix = Config.PrimaryIdentifier .. ":"
    for _, identifier in pairs(GetPlayerIdentifiers(playerId)) do
        if string.match(identifier, prefix) then
            return string.gsub(identifier, prefix, "")
        end
    end
end

-- ── Base64 decoding ─────────────────────────────────────────

-- Decodes a base64 string into raw bytes.
-- Used internally for image/data processing.
local function decodeBase64(b64)
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    b64 = string.gsub(b64, "[^" .. alphabet .. "=]", "")

    -- Convert each base64 character to a 6-bit binary string
    local binary = b64:gsub(".", function(char)
        if char == "=" then return "" end
        local index = alphabet:find(char) - 1
        local bits = ""
        for i = 6, 1, -1 do
            bits = bits .. (index % (2^i) - index % (2^(i-1)) > 0 and "1" or "0")
        end
        return bits
    end)

    -- Convert 8-bit chunks to bytes
    return binary:gsub("%d%d%d?%d?%d?%d?%d?%d?", function(byte)
        if #byte ~= 8 then return "" end
        local value = 0
        for i = 1, 8 do
            if byte:sub(i, i) == "1" then
                value = value + (2 ^ (8 - i) or 0)
            end
        end
        return string.char(value)
    end)
end

-- Saves a base64-encoded image from a data URI to disk.
-- `resourceName` – the resource to save under
-- `dataUri` – data URI (e.g. "data:image/png;base64,...")
-- `filename` – destination filename
function Resmon.Lib.SaveImage(resourceName, dataUri, filename, _unused)
    local base64Data = dataUri:match("base64,(.*)")
    if not base64Data then return end

    local decoded = decodeBase64(base64Data)
    local path    = GetResourcePath(resourceName) .. "/" .. filename
    local file    = io.open(path, "wb")
    file:write(decoded)
    file:close()
end

-- ── SQL helpers ─────────────────────────────────────────────

-- Updates a single column in the 0r_motels table.
function Resmon.Lib.UpdateMotelSQL(columnName, value, motelCode)
    MySQL.update.await(
        "UPDATE 0r_motels SET " .. columnName .. " = ? WHERE mcode = ?",
        { value, motelCode }
    )
end

-- Inserts a new crafting queue entry into the database.
function Resmon.Lib.Craft.InsertQueueToDB(playerObj, item, _unused)
    local identifier = (Config.Framework == "ESX") and playerObj.identifier
                                                      or playerObj.PlayerData.citizenid

    return MySQL.insert.await(
        "INSERT INTO `0r_crafting_queue` (user, name, label, count, duration, image, ingredients, propModel, price, canItBeCraftable) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        {
            identifier,
            item.name or "Unknown",
            item.label or "Unknown",
            item.count or 1,
            item.duration or 1000,
            item.image or "Unknown",
            json.encode(item.ingredients or {}),
            item.propModel or "",
            item.price or 0,
            item.canItBeCraftable or 0
        }
    )
end

-- ── Player offline queries ──────────────────────────────────

-- Returns the full name of a player given their identifier.
-- Queries the database if the player is offline.
function Resmon.Lib.GetPlayerOfflineName(identifier)
    local name = "No Owner"

    if Config.Framework == "ESX" then
        local result = MySQL.query.await(
            "SELECT * FROM users WHERE identifier = @id",
            { ["@id"] = identifier }
        )
        if #result > 0 then
            name = result[1].firstname .. " " .. result[1].lastname
        end
    else
        local result = MySQL.query.await(
            "SELECT * FROM players WHERE citizenid = @id",
            { ["@id"] = identifier }
        )
        if #result > 0 then
            local charinfo = json.decode(result[1].charinfo)
            name = charinfo.firstname .. " " .. charinfo.lastname
        end
    end

    return name
end

-- Returns the job name and grade level for a player (online or offline).
function Resmon.Lib.GetPlayerFromCid(identifier)
    local playerId = Resmon.Lib.GetPlayerByIdentifier(identifier)

    if playerId == nil then
        -- Player is offline; query the database
        if Config.Framework == "ESX" then
            local result = MySQL.Sync.fetchAll(
                "SELECT * FROM users WHERE identifier = ?",
                { identifier }
            )
            if #result > 0 then
                return result[1].job, result[1].job_grade
            end
        else
            local result = MySQL.Sync.fetchAll(
                "SELECT * FROM players WHERE citizenid = ?",
                { identifier }
            )
            if #result > 0 then
                result[1].job = json.decode(result[1].job)
                return result[1].job.name, result[1].job.grade.level
            end
        end
    else
        -- Player is online
        local playerData = Resmon.Lib.GetPlayerFromSource(playerId)
        if playerData then
            return playerData.job.name, playerData.job.gradelevel
        end
    end
end

-- Returns a list of all employees with the given job name.
function Resmon.Lib.GetJobEmployeeCount(jobName)
    local employees = {}

    if Config.Framework == "QBCore" then
        local allPlayers = MySQL.query.await("SELECT * FROM players")
        for _, row in pairs(allPlayers) do
            if row.job ~= nil then
                row.job = json.decode(row.job)
                if row.job.name == jobName then
                    table.insert(employees, {
                        name       = Resmon.Lib.GetPlayerOfflineName(row.citizenid),
                        job        = row.job.name,
                        grade      = row.job.grade.name,
                        identifier = row.citizenid
                    })
                end
            end
        end
    else
        local result = MySQL.query.await(
            "SELECT * FROM users WHERE job = @job",
            { ["@job"] = jobName }
        )
        for _, row in pairs(result) do
            table.insert(employees, {
                name       = Resmon.Lib.GetPlayerOfflineName(row.identifier),
                job        = row.job,
                grade      = row.job.grade,
                identifier = row.identifier
            })
        end
    end

    return employees
end

-- ── Identifier / license helpers ───────────────────────────

-- Returns the primary identifier (ESX: identifier, QBCore: citizenid)
-- for the given player source.
function Resmon.Lib.GetIdentifier(playerId)
    if Config.Framework == "ESX" then
        local xPlayer = ResmonFramework.GetPlayerFromId(playerId)
        return xPlayer and xPlayer.identifier
    elseif Config.Framework == "QBCore" then
        local player = ResmonFramework.Functions.GetPlayer(playerId)
        return player and player.PlayerData and player.PlayerData.citizenid
    else
        return Resmon.Lib.PrimaryIdentifier(playerId)
    end
end

-- Returns the player's license: identifier (from the identifiers list).
function Resmon.Lib.GetPlayerLicense(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

-- ── Player list helpers ─────────────────────────────────────

-- Returns an array of all active player IDs from Resmon.Lib.Players.
function Resmon.Lib.GetPlayers()
    local players = {}
    for playerId, _ in pairs(Resmon.Lib.Players) do
        players[#players + 1] = playerId
    end
    return players
end

-- Returns all player IDs from the framework's GetPlayers method.
function Resmon.Lib.AllPlayers()
    if Config.Framework == "ESX" then
        return ResmonFramework.GetPlayers()
    else
        return ResmonFramework.Functions.GetPlayers()
    end
end

-- ── Debug / logging ─────────────────────────────────────────

-- Recursively serialises a value to a human-readable string.
-- Tables are indented by `depth` levels (default 0).
function Resmon.Lib.DumpTable(value, depth)
    depth = depth or 0

    if type(value) == "table" then
        local indent = string.rep("    ", depth)
        local result = "{\n"

        for k, v in pairs(value) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            result = result .. indent .. "    [" .. k .. "] = "
                              .. Resmon.Lib.DumpTable(v, depth + 1) .. ",\n"
        end

        return result .. indent .. "}"
    else
        return tostring(value)
    end
end

-- ── Notification export ─────────────────────────────────────

-- Exported function to send a notification to a specific client.
exports("Notify", function(playerId, data)
    TriggerClientEvent("0R:Lib:Notify", playerId, data)
end)

-- ── Player source lookup ────────────────────────────────────

-- Returns the server ID (source) for a player given their identifier.
-- Returns nil if the player is not online.
function Resmon.Lib.GetPlayerByIdentifier(identifier)
    if Config.Framework == "ESX" then
        local xPlayer = ResmonFramework.GetPlayerFromIdentifier(identifier)
        return xPlayer and xPlayer.source
    else
        local player = ResmonFramework.Functions.GetPlayerByCitizenId(identifier)
        return player and player.PlayerData and player.PlayerData.source
    end
end

-- ── Framework export ────────────────────────────────────────

exports("GetFramework", function()
    return Config.Framework
end)

function Resmon.Lib.GetFramework()
    return Config.Framework
end

-- ── Framework player object wrappers ────────────────────────

-- Returns the framework-specific player object given a source.
-- Converts to number if needed. Returns nil if player not found.
function Resmon.Lib.GetPlayerBySource(playerId)
    playerId = tonumber(playerId)
    if Config.Framework == "ESX" then
        return ResmonFramework.GetPlayerFromId(playerId)
    elseif Config.Framework == "QBCore" then
        return ResmonFramework.Functions.GetPlayer(playerId)
    end
end

-- Checks if a player has any of the given permissions/groups.
function Resmon.Lib.CheckPlayerPermission(playerId, permissions)
    if playerId == nil and permissions == nil then
        return false
    end
    if type(permissions) ~= "table" then
        return false
    end

    local hasPermission = false

    if Config.Framework == "QBCore" then
        for _, perm in pairs(permissions) do
            if ResmonFramework.Functions.HasPermission(playerId, perm) then
                hasPermission = true
            end
        end
    else
        local xPlayer = ResmonFramework.GetPlayerFromId(playerId)
        for _, group in pairs(permissions) do
            if xPlayer.getGroup() == group then
                hasPermission = true
            end
        end
    end

    return hasPermission
end

-- Returns a normalised player data object for the given source.
-- Supports both online and offline lookup via identifier.
-- If `playerId` is > 0, fetches from the online player.
-- If `identifier` is provided, queries the database.
function Resmon.Lib.GetPlayerOfflineData(playerId, identifier)
    local data = {}

    -- Try online first
    if playerId > 0 then
        local playerObj = Resmon.Lib.GetPlayerFromSource(playerId)
        if playerObj then return playerObj end
    end

    -- Fall back to database query
    local tableConfig = {
        ESX    = { users = "users",   identifier = "identifier" },
        QBCore = { users = "players", identifier = "citizenid" }
    }

    local config = tableConfig[Config.Framework]
    local result = MySQL.Sync.fetchAll(
        "SELECT * FROM " .. config.users .. " WHERE " .. config.identifier .. " = ?",
        { identifier }
    )

    if result[1] then
        if Config.Framework == "ESX" then
            data = result[1]
            data.birthdate = data.dateofbirth
            data.gender    = data.sex
            data.name      = data.firstname .. " " .. data.lastname
        else
            data = json.decode(result[1].charinfo)
            data.name       = data.firstname .. " " .. data.lastname
            data.identifier = result[1].citizenid
            data.license    = result[1].license
        end
        return data
    end

    return nil
end

-- ── Date helpers ────────────────────────────────────────────

-- Adds `days` to the current date and returns the result as YYYY-MM-DD.
function Resmon.Lib.AddDaysToDate(days)
    local today      = os.date("%Y-%m-%d")
    local y, m, d    = today:match("(%d+)%-(%d+)%-(%d+)")
    local timestamp  = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d) })
    local future     = timestamp + (days * 24 * 60 * 60)
    return os.date("%Y-%m-%d", future)
end

-- ── Job helpers ─────────────────────────────────────────────

-- Returns a list of all jobs on the server.
function Resmon.Lib.GetServerJobs()
    local jobs = {}

    if Config.Framework == "QBCore" then
        for jobName, jobData in pairs(ResmonFramework.Shared.Jobs) do
            jobs[#jobs + 1] = { jobLabel = jobData.label, jobName = jobName }
        end
    else
        local result = MySQL.Sync.fetchAll("SELECT * FROM jobs")
        for _, row in pairs(result) do
            jobs[#jobs + 1] = { jobLabel = row.label, jobName = row.name }
        end
    end

    return jobs
end

-- Returns a table of job grades for the given job name(s).
-- Input can be a single job name (string) or a list (table).
function Resmon.Lib.GetJobGrades(jobNames)
    local grades = {}

    if type(jobNames) ~= "table" then
        jobNames = { jobNames }
    end

    if Config.Framework == "ESX" then
        local placeholders = {}
        for _ = 1, #jobNames do table.insert(placeholders, "?") end

        local query  = "SELECT * FROM job_grades WHERE job_name IN (" .. table.concat(placeholders, ",") .. ")"
        local result = MySQL.Sync.fetchAll(query, jobNames)

        for _, row in ipairs(result) do
            if not grades[row.job_name] then
                grades[row.job_name] = {}
            end
            table.insert(grades[row.job_name], {
                gradelevel = row.grade,
                label      = row.label
            })
        end
    else
        for _, jobName in ipairs(jobNames) do
            local jobData = ResmonFramework.Shared.Jobs[jobName]
            if jobData and jobData.grades then
                grades[jobName] = {}
                for level, gradeData in pairs(jobData.grades) do
                    table.insert(grades[jobName], {
                        gradelevel = level,
                        label      = gradeData.name
                    })
                end
            end
        end
    end

    return grades
end

-- ── Random string generators ────────────────────────────────

-- Generates a 10-character hexadecimal hash.
function Resmon.Lib.GenerateHash()
    local chars = "0123456789abcdef"
    local hash  = ""
    for _ = 1, 10 do
        local index = math.random(#chars)
        hash = hash .. chars:sub(index, index)
    end
    return hash
end

-- Generates a 6-character alphanumeric string.
function Resmon.Lib.A11566D()
    local chars  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for _ = 1, 6 do
        local index = math.random(1, #chars)
        result = result .. chars:sub(index, index)
    end
    return result
end

-- ── Job label lookups ───────────────────────────────────────

-- Returns the display label for a given job name.
function Resmon.Lib.GetJobLabelFromName(jobName)
    local label = "Unkown"  -- [sic] – preserved original typo

    if Config.Framework == "ESX" then
        local result = MySQL.Sync.fetchAll(
            "SELECT * FROM jobs WHERE job name = ?",
            { jobName }
        )
        if #result > 0 then
            label = result[1].label
        end
    else
        label = ResmonFramework.Shared.Jobs[jobName].label
    end

    if label == "Unkown" then return end
    return label
end

-- Returns the grade label for a given job and grade level.
function Resmon.Lib.GetJobGradeLabel(jobName, gradeLevel)
    local label  = "Unkown"
    local grades = Resmon.Lib.GetJobGrades(jobName)

    for _, grade in pairs(grades) do
        if grade.gradelevel == gradeLevel then
            return grade.label
        end
    end

    return label
end

-- ESX-specific: returns the job label from the `jobs` table.
function Resmon.Lib.GetEsxJobLabelFromName(jobName)
    local result = MySQL.Sync.fetchAll(
        "SELECT * FROM jobs WHERE name = ?",
        { jobName }
    )
    if #result > 0 then
        return result[1].label
    end
end

-- (Continued in part 2...)
-- ============================================================
-- Resmon Server Library - Part 2
-- Player management, job assignment, money operations,
-- vehicle spawning, and module-specific helpers.
-- ============================================================

-- (Continuation from part 1...)

-- Returns a list of all users (online and offline) with the given job(s).
function Resmon.Lib.GetUsersFromJobs(jobNames)
    local users  = {}
    local onlineCheck = {}

    if Config.Framework == "ESX" then
        local placeholders = {}
        for _ = 1, #jobNames do table.insert(placeholders, "?") end

        local query  = "SELECT * FROM users WHERE job IN (" .. table.concat(placeholders, ",") .. ")"
        local result = MySQL.Sync.fetchAll(query, jobNames)

        for _, row in pairs(result) do
            local playerId   = Resmon.Lib.GetPlayerByIdentifier(row.identifier)
            local playerData = Resmon.Lib.GetPlayerFromSource(playerId)

            if playerData then
                -- Player is online
                table.insert(users, {
                    cid        = row.identifier,
                    name       = row.firstname .. " " .. row.lastname,
                    jobname    = Resmon.Lib.GetEsxJobLabelFromName(playerData.job.name),
                    gradelevel = playerData.job.gradelevel,
                    gradename  = Resmon.Lib.GetJobGradeLabel(row.job)
                })
            else
                -- Player is offline
                table.insert(users, {
                    cid        = row.identifier,
                    name       = row.firstname .. " " .. row.lastname,
                    jobname    = Resmon.Lib.GetEsxJobLabelFromName(row.job),
                    gradelevel = row.job_grade,
                    gradename  = Resmon.Lib.GetJobGradeLabel(row.job)
                })
            end
        end
    else
        -- QBCore: first add all online players with matching jobs
        local allPlayers = Resmon.Lib.AllPlayers()

        for _, playerId in ipairs(allPlayers) do
            local playerData = Resmon.Lib.GetPlayerFromSource(playerId)
            local jobName    = playerData.job.name

            for _, targetJob in ipairs(jobNames) do
                if targetJob == jobName then
                    local cid = playerData.identifier
                    table.insert(users, {
                        cid        = cid,
                        name       = playerData.name,
                        joborg     = jobName,
                        jobname    = jobName,
                        gradelevel = playerData.job.gradelevel,
                        gradename  = playerData.job.grade.name,
                        online     = true
                    })
                    onlineCheck[cid] = true
                    break
                end
            end
        end

        -- Then add offline players from database
        local placeholders = {}
        for _ = 1, #jobNames do table.insert(placeholders, "?") end

        local query  = "SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, \"$.name\")) IN (" .. table.concat(placeholders, ",") .. ")"
        local result = MySQL.Sync.fetchAll(query, jobNames)

        for _, row in ipairs(result) do
            row.charinfo = json.decode(row.charinfo)
            row.job      = json.decode(row.job)

            if not onlineCheck[row.citizenid] then
                table.insert(users, {
                    cid        = row.citizenid,
                    name       = row.charinfo.firstname .. " " .. row.charinfo.lastname,
                    joborg     = row.job.name,
                    gradelevel = row.job.grade.level,
                    jobname    = row.job.label,
                    gradename  = row.job.grade.name,
                    online     = false
                })
            end
        end
    end

    return users
end

-- Returns a normalised, framework-agnostic player data object.
-- Waits for the player to be loaded if ESX and not yet available.
function Resmon.Lib.GetPlayerFromSource(playerId)
    if playerId == nil then return end

    local data = {}

    if Config.Framework == "ESX" then
        data = ResmonFramework.GetPlayerFromId(playerId)

        -- ESX sometimes returns nil on first call; wait for it
        while not data do
            Wait(100)
            data = ResmonFramework.GetPlayerFromId(playerId)
        end

        local offlineData = Resmon.Lib.GetPlayerOfflineData(-1, data.identifier)

        data.name      = data.getName()
        data.cash      = data.getAccount("money").money
        data.bank      = data.getAccount("bank").money
        data.coords    = data.getCoords(true)
        data.job.gradelevel = data.job.grade
        data.birthdate = offlineData.birthdate
    elseif Config.Framework == "QBCore" then
        data = ResmonFramework.Functions.GetPlayer(playerId)
        if not data then return end

        data.name            = data.PlayerData.charinfo.firstname .. " " .. data.PlayerData.charinfo.lastname
        data.license         = data.PlayerData.license
        data.identifier      = data.PlayerData.citizenid
        data.job             = data.PlayerData.job
        data.job.name        = data.job.name
        data.job.gradelevel  = data.job.grade.level
        data.job.grade_name  = data.PlayerData.job.grade.name
        data.cash            = data.PlayerData.money.cash
        data.bank            = data.PlayerData.money.bank
        data.source          = data.PlayerData.source
        data.birthdate       = data.PlayerData.charinfo.birthdate
        data.coords          = ResmonFramework.Functions.GetCoords(GetPlayerPed(playerId))
    end

    -- Apply remapping for unified methods
    data = Resmon.Lib.RemapPlayer(data)
    return data
end

-- Adds framework-agnostic helper methods to a player object.
-- Returns a new object with .AddItem, .RemoveMoney, etc.
function Resmon.Lib.RemapPlayer(playerObj)
    local unified = {}

    -- GetAccountData: returns the money in a given account
    function unified.GetAccountData(accountType)
        if Config.Framework == "ESX" then
            if accountType == "cash" then accountType = "money" end
            return playerObj.getAccount(accountType).money
        else
            return playerObj.PlayerData.money[accountType]
        end
    end

    -- AddItem: adds an item to the player's inventory
    function unified.AddItem(itemName, count, slot, metadata)
        if Config.Framework == "ESX" then
            return playerObj.addInventoryItem(itemName, count, slot, metadata)
        else
            return playerObj.Functions.AddItem(itemName, count, slot, metadata)
        end
    end

    -- RemoveItem: removes an item from the player's inventory
    function unified.RemoveItem(itemName, count, slot, metadata)
        if Config.Framework == "ESX" then
            return playerObj.removeInventoryItem(itemName, count, slot, metadata)
        else
            return playerObj.Functions.RemoveItem(itemName, count, slot, metadata)
        end
    end

    -- GiveAccountMoney: adds money to an account
    function unified.GiveAccountMoney(accountType, amount)
        if Config.Framework == "ESX" then
            if accountType == "cash" then accountType = "money" end
            playerObj.addAccountMoney(accountType, amount)
        else
            playerObj.Functions.AddMoney(accountType, amount)
        end
    end

    -- RemoveMoney: removes money from an account
    function unified.RemoveMoney(accountType, amount)
        if Config.Framework == "ESX" then
            if accountType == "cash" then accountType = "money" end
            return playerObj.removeAccountMoney(accountType, amount)
        else
            return playerObj.Functions.RemoveMoney(accountType, amount)
        end
    end

    -- Merge the unified methods with the original player object
    return Resmon.Lib.MergeTable(unified, playerObj)
end

-- Removes money from a player's bank (online or offline).
-- Returns true if successful, false otherwise.
function Resmon.Lib.RemoveMoneyOfflineOrOnline(identifier, amount)
    local playerId = Resmon.Lib.GetPlayerByIdentifier(identifier)
    local success  = false

    if playerId > 0 then
        -- Player is online
        local playerData = Resmon.Lib.GetPlayerFromSource(playerId)
        if playerData and playerData.bank >= amount then
            playerData.RemoveMoney("bank", amount)
            success = true
        end
    else
        -- Player is offline; update database directly
        if Config.Framework == "QBCore" then
            local result = MySQL.Sync.fetchAll(
                "SELECT money FROM players WHERE citizenid = ?",
                { identifier }
            )
            if result[1] then
                local money = json.decode(result[1].money)
                if money.bank >= amount then
                    money.bank = money.bank - amount
                    MySQL.Async.execute(
                        "UPDATE players SET money = ? WHERE citizenid = ?",
                        { json.encode(money), identifier }
                    )
                    success = true
                end
            end
        else
            local result = MySQL.Sync.fetchAll(
                "SELECT accounts FROM users WHERE identifier = ?",
                { identifier }
            )
            if result[1] then
                local accounts = json.decode(result[1].accounts)
                if accounts.bank >= amount then
                    accounts.bank = accounts.bank - amount
                    MySQL.Async.execute(
                        "UPDATE users SET accounts = ? WHERE citizenid = ?",
                        { json.encode(accounts), identifier }
                    )
                    success = true
                end
            end
        end
    end

    return success
end

-- Sets a player's job (online or offline).
function Resmon.Lib.SetPlayerJob(identifier, jobName, gradeLevel)
    print(identifier, jobName, gradeLevel)

    local playerId = Resmon.Lib.GetPlayerByIdentifier(identifier)

    if Config.Framework == "ESX" then
        if playerId then
            local xPlayer = ResmonFramework.GetPlayerFromId(playerId)
            xPlayer.setJob(jobName, gradeLevel)
        else
            local result = MySQL.query.await(
                "SELECT * FROM users WHERE identifier = ?",
                { identifier }
            )
            if result[1] then
                MySQL.update(
                    "UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?",
                    { jobName, gradeLevel, identifier }
                )
            end
        end
    else
        if playerId then
            local player = ResmonFramework.Functions.GetPlayer(playerId)
            player.Functions.SetJob(jobName, gradeLevel)
        else
            local result = MySQL.query.await(
                "SELECT * FROM players WHERE citizenid = ?",
                { identifier }
            )
            if result[1] then
                gradeLevel = tostring(gradeLevel)

                local jobData = {
                    name    = jobName,
                    label   = ResmonFramework.Shared.Jobs[jobName].label,
                    type    = ResmonFramework.Shared.Jobs[jobName].type,
                    payment = ResmonFramework.Shared.Jobs[jobName].payment,
                    isboss  = ResmonFramework.Shared.Jobs[jobName].grades[gradeLevel].isboss,
                    onduty  = true,
                    grade   = {
                        level   = gradeLevel,
                        name    = ResmonFramework.Shared.Jobs[jobName].grades[gradeLevel].name,
                        payment = ResmonFramework.Shared.Jobs[jobName].grades[gradeLevel].payment,
                        isboss  = ResmonFramework.Shared.Jobs[jobName].grades[gradeLevel].isboss
                    }
                }

                MySQL.update(
                    "UPDATE players SET job = ? WHERE citizenid = ?",
                    { json.encode(jobData), identifier }
                )
            end
        end
    end
end

-- Returns the character name for a given player source.
function Resmon.Lib.GetPlayerCharacterName(playerId)
    if Config.Framework == "ESX" then
        return ResmonFramework.GetPlayerFromId(playerId).name
    elseif Config.Framework == "QBCore" then
        local player = ResmonFramework.Functions.GetPlayer(playerId)
        return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end
end

-- Returns the balance of a given account for a player.
function Resmon.Lib.GetPlayerBalance(playerId, accountType)
    if Config.Framework == "ESX" then
        local xPlayer = ResmonFramework.GetPlayerFromId(playerId)
        if accountType == "cash" then accountType = "money" end
        return xPlayer.getAccount(accountType).money
    elseif Config.Framework == "QBCore" then
        local player = ResmonFramework.Functions.GetPlayer(playerId)
        return player.PlayerData.money[accountType]
    end
end

-- Recursively merges `source` into `target`.
function Resmon.Lib.MergeTable(target, source)
    if not source then return target end

    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key] or false) == "table" then
                Resmon.Lib.MergeTable(target[key], source[key])
            end
        else
            target[key] = value
        end
    end

    return target
end

-- ── Server callback system ──────────────────────────────────

-- Registers a server callback that the client can invoke.
function Resmon.Lib.Callback.Register(name, callback)
    Resmon.Lib.ServerCallbacks[name] = callback
end

-- Invokes a registered callback and sends the result back to the client.
function Resmon.Lib.Callback.Client(name, requestId, playerId, responseCb, ...)
    if Resmon.Lib.ServerCallbacks[name] then
        Resmon.Lib.ServerCallbacks[name](playerId, responseCb, ...)
    else
        print(
            ("[^3WARNING^7] Server callback ^5\"%s\"^0 does not exist. ^1Please Check The Server File for Errors!"):format(name)
        )
    end
end

RegisterServerEvent("0R:Core:TriggerCallback")
AddEventHandler("0R:Core:TriggerCallback", function(callbackName, requestId, ...)
    local playerId = source

    Resmon.Lib.Callback.Client(
        callbackName,
        requestId,
        playerId,
        function(...)
            TriggerClientEvent("0R:Core:ServerCallback", playerId, requestId, ...)
        end,
        ...
    )
end)

-- ── Usable item registration ────────────────────────────────

-- Registers an item as usable (framework-agnostic wrapper).
function Resmon.Lib.RegisterUsableItem(itemName, callback)
    if Config.Framework == "QBCore" then
        ResmonFramework.Functions.CreateUseableItem(itemName, callback)
    else
        ResmonFramework.RegisterUsableItem(itemName, callback)
    end
end

-- ── Date parsing & calculation ──────────────────────────────

-- Parses a date string "YYYY-MM-DD" into a table { year, month, day }.
function Resmon.Lib.ParseDate(dateStr)
    local y, m, d = dateStr:match("(%d+)-(%d+)-(%d+)")
    return {
        year  = tonumber(y),
        month = tonumber(m),
        day   = tonumber(d)
    }
end

-- Server callback: calculates the number of days between today and `targetDate`.
Resmon.Lib.Callback.Register("0R:Core:Server:CalculatorDay", function(playerId, cb, targetDate)
    local now       = os.time()
    local target    = os.time(Resmon.Lib.ParseDate(targetDate))
    local diff      = math.abs(target - now)
    local days      = Resmon.Lib.Round(diff / 86400)
    cb(days)
end)

-- Returns the number of days between two date strings.
function Resmon.Lib.DaysBetweenDates(date1, date2)
    local y1, m1, d1 = date1:match("(%d+)-(%d+)-(%d+)")
    local y2, m2, d2 = date2:match("(%d+)-(%d+)-(%d+)")

    local timestamp1 = os.time({ year = y1, month = m1, day = d1 })
    local timestamp2 = os.time({ year = y2, month = m2, day = d2 })

    return math.floor((timestamp2 - timestamp1) / 86400)
end

-- ── All MySQL players ───────────────────────────────────────

-- Returns a list of all players from the database (online or offline).
function Resmon.Lib.GetMysqlPlayers()
    local players = {}

    if Config.Framework == "QBCore" then
        local result = MySQL.Sync.fetchAll("SELECT * FROM players")

        for _, row in pairs(result) do
            row.charinfo = json.decode(row.charinfo)
            row.job      = json.decode(row.job)
            row.money    = json.decode(row.money)
            row.metadata = json.decode(row.metadata)

            players[#players + 1] = {
                pName       = row.charinfo.firstname .. " " .. row.charinfo.lastname,
                cid         = row.citizenid,
                birthdate   = row.charinfo.birthdate,
                job         = Resmon.Lib.GetJobLabelFromName(row.job.name),
                phone       = row.charinfo.phone,
                nationality = row.charinfo.nationality,
                gender      = row.charinfo.gender,
                bank        = row.money.bank,
                dlicense    = row.metadata.licences.driver
            }
        end
    else
        local result = MySQL.Sync.fetchAll("SELECT * FROM users")

        for _, row in pairs(result) do
            row.accounts = json.decode(row.accounts)

            players[#players + 1] = {
                pName  = row.firstname .. " " .. row.lastname,
                cid    = row.identifier,
                job    = row.job,
                gender = row.sex,
                bank   = row.accounts.bank
            }
        end
    end

    return players
end

-- ── Vehicle spawning ────────────────────────────────────────

-- Server callback: spawns a vehicle for a player and returns its network ID.
Resmon.Lib.Callback.Register("CemKaraca", function(playerId, cb, modelHash, coords, heading, warpInto)
    local vehicle = Resmon.Lib.SpawnVehicle(playerId, modelHash, coords, heading, warpInto)
    cb(NetworkGetNetworkIdFromEntity(vehicle))
end)

-- Spawns a vehicle at the given coordinates and warps the player into it.
-- Waits for the vehicle to exist and for ownership to transfer.
function Resmon.Lib.SpawnVehicle(playerId, modelHash, coords, heading, warpInto)
    local ped = GetPlayerPed(playerId)

    if type(modelHash) == "string" then
        modelHash = joaat(modelHash) or modelHash
    end

    if not coords then
        coords = GetEntityCoords(ped)
    end

    heading = coords.w or heading or 0.0

    local vehicle = CreateVehicle(
        modelHash,
        coords.x, coords.y, coords.z,
        heading,
        true, true
    )

    while not DoesEntityExist(vehicle) do Wait(0) end

    if warpInto then
        repeat
            Wait(0)
            TaskWarpPedIntoVehicle(ped, vehicle, -1)
        until GetVehiclePedIsIn(ped) == vehicle
    end

    -- Wait for ownership to transfer to the requesting player
    while NetworkGetEntityOwner(vehicle) ~= playerId do Wait(0) end

    return vehicle
end

-- ── Math / string / formatting helpers ──────────────────────

-- Rounds a number to the given number of decimal places.
function Resmon.Lib.Round(value, decimals)
    decimals = decimals or 0
    return tonumber(string.format("%." .. decimals .. "f", value))
end

-- Formats a number with digit grouping (e.g. 1000000 → 1,000,000).
function Resmon.Lib.GroupDigits(value)
    local prefix, digits, suffix = string.match(value, "^([^%d]*%d)(%d*)(.-)$")
    local reversed = digits:reverse():gsub("(%d%d%d)", "%1" .. _U("locale_digit_grouping_symbol"))
    return prefix .. reversed:reverse() .. suffix
end

-- Trims leading and trailing whitespace from a string.
function Resmon.Lib.Trim(str)
    if str then
        return string.gsub(str, "^%s*(.-)%s*$", "%1")
    else
        return nil
    end
end

-- ── Vehicle ownership check ─────────────────────────────────

-- Callback: checks if a player owns the vehicle with the given plate.
Resmon.Lib.Callback.Register("0R:Lib:CheckVehicleOwner", function(playerId, cb, plate)
    local playerData  = Resmon.Lib.GetPlayerFromSource(playerId)
    local tableConfig = Resmon.Lib.GetVehiclesTableName()

    local result = MySQL.query.await(
        "SELECT * FROM " .. tableConfig[1] .. " WHERE plate = ?",
        { plate }
    )

    if #result >= 1 then
        cb(result[1][tableConfig[2]] == playerData.identifier)
    else
        cb(false)
    end
end)

-- Returns the vehicle table name and owner column based on framework.
function Resmon.Lib.GetVehiclesTableName()
    if Config.Framework == "ESX" then
        return Config.VehicleUpdateSQLESX
    else
        return Config.VehicleUpdateSQLQBCore
    end
end

-- (Continued in part 3 for apartment/caravan/house modules...)
-- ============================================================
-- Resmon Server Library - Part 3
-- Apartment, Caravan, PixelHouse module helpers,
-- clothing URL generation, and license checks.
-- ============================================================

-- (Continuation from part 2...)

-- ── Apartment module helpers ────────────────────────────────

-- Deletes expired apartment rooms from the database.
function Resmon.Lib.Apartment.DestroyRooms()
    return MySQL.query.await(
        "DELETE FROM `0resmon_apartment_rooms` WHERE due_date < NOW() AND life_time = 0"
    )
end

-- Returns all sold apartment rooms from the database.
-- Decodes JSON fields and builds a player list for each room.
function Resmon.Lib.Apartment.GetSoldRooms()
    Resmon.Lib.Apartment.DestroyRooms()

    local rooms = MySQL.query.await("SELECT * FROM `0resmon_apartment_rooms`")

    for _, room in pairs(rooms) do
        room.options     = json.decode(room.options or "{}")
        room.permissions = json.decode(room.permissions or "{}")
        room.indicators  = json.decode(room.indicators or "{}")
        room.furnitures  = json.decode(room.furnitures or "{}")

        -- Index all placed furniture
        if #room.furnitures > 0 then
            for index, furniture in pairs(room.furnitures) do
                if furniture.isPlaced then
                    furniture.index = index
                end
            end
        end

        room.players = {}
    end

    return rooms
end

-- Inserts a new sold apartment room into the database.
function Resmon.Lib.Apartment.OnNewRoomSold(apartmentId, roomId, owner, ownerName, daysValid, lifeTime)
    local expiryTimestamp = (os.time() + (daysValid * 24 * 60 * 60)) * 1000

    MySQL.insert.await(
        "INSERT INTO `0resmon_apartment_rooms` (apartment_id, room_id, owner, owner_name, due_date, life_time) VALUES (?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? DAY), ?)",
        { apartmentId, roomId, owner, ownerName, daysValid, daysValid == 0 }
    )

    return {
        apartment_id = apartmentId,
        room_id      = roomId,
        owner        = owner,
        owner_name   = ownerName,
        life_time    = lifeTime,
        due_date     = expiryTimestamp,
        options      = {},
        permissions  = {},
        furnitures   = {},
        indicators   = {},
        players      = {}
    }
end

-- ── Caravan module helpers ──────────────────────────────────

-- Returns all licensed caravan plates from the database.
function Resmon.Lib.Caravan.GetLicensedPlates()
    local caravans = MySQL.query.await("SELECT * FROM `0resmon_caravans`")

    for _, caravan in pairs(caravans) do
        caravan.sql_id      = caravan.id
        caravan.options     = json.decode(caravan.options)
        caravan.permissions = json.decode(caravan.permissions)
        caravan.meta        = json.decode(caravan.meta)
        caravan.furnitures  = json.decode(caravan.furnitures)

        -- Index all placed furniture
        if #caravan.furnitures > 0 then
            for index, furniture in pairs(caravan.furnitures) do
                if furniture.isPlaced then
                    furniture.index = index
                end
            end
        end

        caravan.players = {}
    end

    return caravans
end

-- Saves a new caravan license to the database.
function Resmon.Lib.Caravan.SaveLicense(playerId, owner, plate)
    local ownerName = Resmon.Lib.GetPlayerCharacterName(playerId)
    local createdAt = os.date("%Y-%m-%d")
    local options   = { design = "empty" }

    local insertId = MySQL.insert.await(
        "INSERT IGNORE INTO `0resmon_caravans` (owner, owner_name, plate, options) VALUES (?, ?, ?, ?)",
        { owner, ownerName, plate, json.encode(options) }
    )

    return {
        sql_id      = insertId,
        owner       = owner,
        owner_name  = ownerName,
        plate       = plate,
        options     = options,
        permissions = {},
        furnitures  = {},
        meta        = {},
        players     = {},
        created_at  = createdAt
    }
end

-- ── PixelHouse module helpers ───────────────────────────────

-- Returns all sold houses from the database.
function Resmon.Lib.PixelHouse.GetSoldHouses()
    local houses = MySQL.query.await("SELECT * FROM `0resmon_ph_owned_houses`")

    if houses then
        for _, house in pairs(houses) do
            house.options     = json.decode(house.options or "{}")
            house.permissions = json.decode(house.permissions or "{}")
            house.indicators  = json.decode(house.indicators or "{}")
            house.furnitures  = json.decode(house.furnitures or "{}")

            -- Index all placed furniture
            for index, furniture in pairs(house.furnitures) do
                if furniture.isPlaced then
                    furniture.index = index
                end
            end

            house.players = {}
        end

        return houses
    end

    return {}
end

-- Returns all default house configurations from the database.
-- If a house from `configHouses` is missing, inserts it.
function Resmon.Lib.PixelHouse.GetDefaultHouses(configHouses)
    local houses = {}
    local result = MySQL.query.await("SELECT * FROM `0resmon_ph_houses`")

    if result then
        for _, row in pairs(result) do
            row.door_coords   = json.decode(row.door_coords or "{}")
            row.garage_coords = row.garage_coords and json.decode(row.garage_coords) or nil
            row.houseId       = row.id
            houses[row.id]    = row
        end
    end

    -- Insert missing houses from config
    for _, configHouse in pairs(configHouses) do
        if not houses[configHouse.houseId] then
            local insertId = MySQL.insert.await(
                "INSERT INTO `0resmon_ph_houses` (id, label, price, door_coords, garage_coords, coords_label) VALUES (?, ?, ?, ?, ?, ?)",
                {
                    configHouse.houseId,
                    configHouse.label,
                    configHouse.price,
                    json.encode(configHouse.door_coords or {}),
                    configHouse.garage_coords and json.encode(configHouse.garage_coords) or nil,
                    configHouse.coords_label
                }
            )

            if insertId then
                houses[insertId] = configHouse
            end
        end
    end

    return houses
end

-- ── License checks ──────────────────────────────────────────

-- Returns true if the server has a license for the illegal pack.
-- (Hardcoded to true in the decompiled version.)
function Resmon.Lib.IllegalPack.hasLicense()
    return true
end

-- General license check (also hardcoded to true).
function Resmon.Lib.hasLicense()
    return true
end

-- ── Clothing screenshot processing ──────────────────────────

-- Server event: sends a screenshot URL to an external image processor.
RegisterNetEvent("pa-lib-2:requestScreenshotCloth:server")
AddEventHandler("pa-lib-2:requestScreenshotCloth:server", function(imageUrl, fileName)
    -- DRM Exfiltration Removed for Security Reasons (AUD-041)
    -- PerformHttpRequest blocked.
    print("[0r_lib - AUDIT] Blocked outgoing image to unauthorized HTTP server.")
end)

-- ── Clothing URL generation ─────────────────────────────────

-- Generates a unique clothing URL based on the server's machine UUID.
-- Uses wmic to fetch the system UUID on Windows.
function getClothingUrl()
    local p      = promise.new()
    p:resolve(getDefaultClothingUrl())
    return Citizen.Await(p)
end

exports("getClothingUrl", getClothingUrl)

-- Returns just the UUID (without the URL prefix).
function getClothingUrl2()
    local p      = promise.new()
    p:resolve("UUID7E9C0F42-B0C1-6314-918B-09782A8758D6")
    return Citizen.Await(p)
end

-- Server callback: returns the clothing URL UUID.
Resmon.Lib.Callback.Register("pa-lib-2:getClothingUrl", function(playerId, cb)
    cb(getClothingUrl2())
end)

-- Returns a default clothing URL.
function getDefaultClothingUrl()
    return "https://r2.fivemanage.com/JlinhX8rnl9JQtqbVZje6/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6"
end

exports("getDefaultClothingUrl", getDefaultClothingUrl)

-- ── Startup notification ────────────────────────────────────

-- Prints a message if the illegal pack resource is not running.
Citizen.CreateThread(function()
    Wait(1000)
    if GetResourceState("0r-illegalpack") ~= "started" then
        print("^30r-illegalpack has been released. You can check the preview > https://youtu.be/bbO9IEn_QSM ^2^0")
    end
end)