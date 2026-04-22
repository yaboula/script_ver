local function IsSocietySyncEnabled()
    return Config.SocietySync and Config.SocietySync.enabled
end

local function GetFrameworkAccountName(jobName)
    if Config.SocietySync.frameworkType == "esx_society" then
        return "society_" .. jobName
    else
        return jobName
    end
end

-- Get society balance from ESX addon account
local function GetESXSocietyBalance(jobName)
    if not IsSocietySyncEnabled() then return nil end
    local accountName = GetFrameworkAccountName(jobName)
    local promise = promise.new()
    exports.oxmysql:execute(
        "SELECT money FROM addon_account_data WHERE account_name = ?",
        { accountName },
        function(result)
            if result and #result > 0 then
                promise:resolve(result[1].money or 0)
            else
                promise:resolve(0)
            end
        end
    )
    return Citizen.Await(promise)
end

-- Set ESX society balance
local function SetESXSocietyBalance(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    local accountName = GetFrameworkAccountName(jobName)

    local exists = exports.oxmysql:executeSync(
        "SELECT account_name FROM addon_account_data WHERE account_name = ?",
        { accountName }
    )
    if exists and #exists > 0 then
        exports.oxmysql:execute(
            "UPDATE addon_account_data SET money = ? WHERE account_name = ?",
            { amount, accountName }
        )
    else
        exports.oxmysql:execute(
            "INSERT INTO addon_account_data (account_name, money) VALUES (?, ?)",
            { accountName, amount }
        )
    end
    return true
end

-- Add money to ESX society
local function AddESXSocietyMoney(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    local current = GetESXSocietyBalance(jobName) or 0
    return SetESXSocietyBalance(jobName, current + amount)
end

-- Remove money from ESX society
local function RemoveESXSocietyMoney(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    local current = GetESXSocietyBalance(jobName) or 0
    return SetESXSocietyBalance(jobName, math.max(0, current - amount))
end

-- Get society balance from qb-management
local function GetQbManagementBalance(jobName)
    if not IsSocietySyncEnabled() then return nil end
    local promise = promise.new()
    exports.oxmysql:execute(
        "SELECT amount FROM management_funds WHERE job_name = ?",
        { jobName },
        function(result)
            if result and #result > 0 then
                promise:resolve(result[1].amount or 0)
            else
                promise:resolve(0)
            end
        end
    )
    return Citizen.Await(promise)
end

-- Set qb-management balance
local function SetQbManagementBalance(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    local exists = exports.oxmysql:executeSync(
        "SELECT job_name FROM management_funds WHERE job_name = ?",
        { jobName }
    )
    if exists and #exists > 0 then
        exports.oxmysql:execute(
            "UPDATE management_funds SET amount = ? WHERE job_name = ?",
            { amount, jobName }
        )
    else
        exports.oxmysql:execute(
            "INSERT INTO management_funds (job_name, amount, type) VALUES (?, ?, ?)",
            { jobName, amount, "boss" }
        )
    end
    return true
end

-- Add money to qb-management
local function AddQbManagementMoney(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    local current = GetQbManagementBalance(jobName) or 0
    return SetQbManagementBalance(jobName, current + amount)
end

-- Remove money from qb-management
local function RemoveQbManagementMoney(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    local current = GetQbManagementBalance(jobName) or 0
    return SetQbManagementBalance(jobName, math.max(0, current - amount))
end

-- Public: get framework society balance (auto-detects type)
function GetFrameworkSocietyBalance(jobName)
    if not IsSocietySyncEnabled() then return nil end
    if Config.SocietySync.frameworkType == "esx_society" then
        return GetESXSocietyBalance(jobName)
    elseif Config.SocietySync.frameworkType == "qb-management" then
        return GetQbManagementBalance(jobName)
    else
        return nil
    end
end

-- Public: set framework society balance
function SetFrameworkSocietyBalance(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    if Config.SocietySync.frameworkType == "esx_society" then
        return SetESXSocietyBalance(jobName, amount)
    elseif Config.SocietySync.frameworkType == "qb-management" then
        return SetQbManagementBalance(jobName, amount)
    else
        return false
    end
end

-- Public: add money to framework society
function AddFrameworkSocietyMoney(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    if Config.SocietySync.frameworkType == "esx_society" then
        return AddESXSocietyMoney(jobName, amount)
    elseif Config.SocietySync.frameworkType == "qb-management" then
        return AddQbManagementMoney(jobName, amount)
    else
        return false
    end
end

-- Public: remove money from framework society
function RemoveFrameworkSocietyMoney(jobName, amount)
    if not IsSocietySyncEnabled() then return false end
    if Config.SocietySync.frameworkType == "esx_society" then
        return RemoveESXSocietyMoney(jobName, amount)
    elseif Config.SocietySync.frameworkType == "qb-management" then
        return RemoveQbManagementMoney(jobName, amount)
    else
        return false
    end
end

-- Sync from banking to framework (one-way)
function SyncBankingToFrameworkSociety(jobName, amount)
    if not IsSocietySyncEnabled() then return end
    SetFrameworkSocietyBalance(jobName, amount)
    DebugPrint("[SOCIETY SYNC] Synced banking → framework: " .. jobName .. " = $" .. amount)
end

-- Sync from framework to banking (two-way)
function SyncFrameworkToBankingSociety(jobName)
    if not IsSocietySyncEnabled() or not Config.SocietySync.twoWaySync then
        return nil
    end
    local balance = GetFrameworkSocietyBalance(jobName)
    if balance then
        DebugPrint("[SOCIETY SYNC] Synced framework → banking: " .. jobName .. " = $" .. balance)
        return balance
    end
    return nil
end

-- Exported function: get society balance from banking DB (with fallback to framework)
exports("GetSocietyBalance", function(jobName)
    local result = exports.oxmysql:executeSync(
        "SELECT balance FROM prism_banking_accounts WHERE is_society = 1 AND society_job = ?",
        { jobName }
    )
    if result and #result > 0 then
        return result[1].balance or 0
    end
    if IsSocietySyncEnabled() and Config.SocietySync.twoWaySync then
        local frameworkBalance = GetFrameworkSocietyBalance(jobName)
        return frameworkBalance or 0
    end
    return 0
end)

-- Exported function: add money to society account (banking + framework sync)
exports("AddSocietyMoney", function(jobName, amount)
    if not jobName or type(jobName) ~= "string" then return false end
    if not amount or type(amount) ~= "number" or amount <= 0 or amount ~= math.floor(amount) or amount > 999999999 then
        return false
    end

    local rows = exports.oxmysql:executeSync(
        "SELECT accno, balance FROM prism_banking_accounts WHERE is_society = 1 AND society_job = ?",
        { jobName }
    )
    if rows and #rows > 0 then
        local newBalance = rows[1].balance + amount
        exports.oxmysql:execute(
            "UPDATE prism_banking_accounts SET balance = ? WHERE accno = ?",
            { newBalance, rows[1].accno }
        )
        if IsSocietySyncEnabled() then
            AddFrameworkSocietyMoney(jobName, amount)
        end
        return true
    end
    return false
end)

-- Exported function: remove money from society account (banking + framework sync)
exports("RemoveSocietyMoney", function(jobName, amount)
    if not jobName or type(jobName) ~= "string" then return false end
    if not amount or type(amount) ~= "number" or amount <= 0 or amount ~= math.floor(amount) or amount > 999999999 then
        return false
    end

    local rows = exports.oxmysql:executeSync(
        "SELECT accno, balance FROM prism_banking_accounts WHERE is_society = 1 AND society_job = ?",
        { jobName }
    )
    if rows and #rows > 0 then
        local newBalance = math.max(0, rows[1].balance - amount)
        exports.oxmysql:execute(
            "UPDATE prism_banking_accounts SET balance = ? WHERE accno = ?",
            { newBalance, rows[1].accno }
        )
        if IsSocietySyncEnabled() then
            RemoveFrameworkSocietyMoney(jobName, amount)
        end
        return true
    end
    return false
end)

local status = IsSocietySyncEnabled() and "^2ENABLED^0" or "^3DISABLED^0"
local fwType = Config.SocietySync.frameworkType or "standalone"
print("^2[Prism Banking]^0 Society sync system loaded. Status: " .. status .. " | Framework Type: ^5" .. fwType .. "^0")