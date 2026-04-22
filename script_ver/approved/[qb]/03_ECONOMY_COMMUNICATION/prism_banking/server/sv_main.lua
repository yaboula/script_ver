local restartImminent = false

function DebugPrint(message)
    if Config.Debug then
        print(message)
    end
end

AddEventHandler("txAdmin:events:scheduledRestart", function(eventData)
    if eventData.secondsRemaining == 60 then
        restartImminent = true
    end
end)

AddEventHandler("txAdmin:events:scheduledRestartSkipped", function(eventData)
    restartImminent = false
end)

function IsRestartImminent()
    return restartImminent
end

RegisterNetEvent("prism-banking:server:onPlayerLoaded", function()
    local source = source
    local player = GetPlayer(source)
    
    if not player then return end
    
    if Config.InterestSystem and Config.InterestSystem.enabled then
        local interestApplied, interestAmount = CalculateInterest(source)
        
        if interestApplied and interestAmount > 0 then
            TriggerClientEvent("prism-bannking:client:notify", tonumber(source), Locale.server.bank_interest, string.format(Locale.server.bank_interest_earned, interestAmount))
        end
    end
end)

CreateThread(function()
    Wait(1000)
    
    local createAccountsTable = [[
        CREATE TABLE IF NOT EXISTS `prism_banking_accounts` (
            `accno` BIGINT(20) NOT NULL,
            `identifier` VARCHAR(255) DEFAULT NULL,
            `balance` BIGINT(20) DEFAULT NULL,
            `type` VARCHAR(100) DEFAULT NULL,
            `pin` INT(11) DEFAULT NULL,
            `primary` INT(11) DEFAULT NULL,
            `last_interest_date` BIGINT(20) DEFAULT NULL COMMENT 'Unix timestamp of last interest calculation for this account',
            `is_society` INT(11) DEFAULT 0 COMMENT '1 if society account, 0 if personal',
            `society_job` VARCHAR(50) DEFAULT NULL COMMENT 'Job name for society accounts',
            PRIMARY KEY (`accno`),
            KEY `idx_identifier` (`identifier`),
            KEY `idx_society` (`is_society`, `society_job`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]]
    
    local createSettingsTable = [[
        CREATE TABLE IF NOT EXISTS `prism_banking_settings` (
            `identifier` VARCHAR(255) NOT NULL,
            `creditscore` INT(11) DEFAULT NULL,
            `allow_transfer` INT(11) DEFAULT 1,
            `is_optimized` INT(11) DEFAULT 1,
            `wit_level` INT(11) DEFAULT 1,
            `mcard_level` INT(11) DEFAULT 1,
            `last_interest_date` BIGINT(20) DEFAULT NULL COMMENT 'Unix timestamp of last interest calculation',
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
    ]]
    
    local createNomineesTable = [[
        CREATE TABLE IF NOT EXISTS `prism_banking_nominees` (
            `id` INT(11) NOT NULL AUTO_INCREMENT,
            `account_number` BIGINT(20) NOT NULL COMMENT 'Account number from prism_banking_accounts',
            `owner_identifier` VARCHAR(50) NOT NULL COMMENT 'Owner/creator identifier',
            `nominee_identifier` VARCHAR(50) NOT NULL COMMENT 'Nominee identifier who has access',
            `added_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `added_by` VARCHAR(50) NOT NULL COMMENT 'Who added this nominee',
            PRIMARY KEY (`id`),
            UNIQUE KEY `unique_nominee` (`account_number`, `nominee_identifier`),
            KEY `account_number` (`account_number`),
            KEY `nominee_identifier` (`nominee_identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]
    
    exports.oxmysql:query(createAccountsTable, {}, function()
        print("^2[Prism Banking]^0 ✓  ensured prism_banking_accounts table .")
        -- Migration: upgrade existing installs with correct column types and indexes
        exports.oxmysql:query("SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'prism_banking_accounts' AND COLUMN_NAME = 'identifier'", {}, function(r)
            if r and r[1] and string.find(string.lower(tostring(r[1].COLUMN_TYPE)), "longtext") then
                exports.oxmysql:query("ALTER TABLE `prism_banking_accounts` MODIFY COLUMN `identifier` VARCHAR(255) DEFAULT NULL", {}, function()
                    print("^2[Prism Banking]^0 ✓  Migrated: identifier LONGTEXT → VARCHAR(255)")
                end)
            end
        end)
        exports.oxmysql:query("SELECT COLUMN_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'prism_banking_accounts' AND COLUMN_NAME = 'type'", {}, function(r)
            if r and r[1] and string.find(string.lower(tostring(r[1].COLUMN_TYPE)), "longtext") then
                exports.oxmysql:query("ALTER TABLE `prism_banking_accounts` MODIFY COLUMN `type` VARCHAR(100) DEFAULT NULL", {}, function()
                    print("^2[Prism Banking]^0 ✓  Migrated: type LONGTEXT → VARCHAR(100)")
                end)
            end
        end)
        exports.oxmysql:query("SELECT CONSTRAINT_TYPE FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'prism_banking_accounts' AND CONSTRAINT_TYPE = 'PRIMARY KEY'", {}, function(r)
            if not r or #r == 0 then
                exports.oxmysql:query("ALTER TABLE `prism_banking_accounts` MODIFY COLUMN `accno` BIGINT(20) NOT NULL, ADD PRIMARY KEY (`accno`)", {}, function()
                    print("^2[Prism Banking]^0 ✓  Migrated: added PRIMARY KEY on accno")
                end)
            end
        end)
        exports.oxmysql:query("SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'prism_banking_accounts' AND INDEX_NAME = 'idx_identifier'", {}, function(r)
            if not r or #r == 0 then
                exports.oxmysql:query("ALTER TABLE `prism_banking_accounts` ADD INDEX idx_identifier (`identifier`)", {}, function()
                    print("^2[Prism Banking]^0 ✓  Migrated: added INDEX on identifier")
                end)
            end
        end)
        exports.oxmysql:query("SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'prism_banking_accounts' AND INDEX_NAME = 'idx_society'", {}, function(r)
            if not r or #r == 0 then
                exports.oxmysql:query("ALTER TABLE `prism_banking_accounts` ADD INDEX idx_society (`is_society`, `society_job`)", {}, function()
                    print("^2[Prism Banking]^0 ✓  Migrated: added INDEX on is_society/society_job")
                end)
            end
        end)
    end)
    
    exports.oxmysql:query(createSettingsTable, {}, function()
        print("^2[Prism Banking]^0 ✓  ensured prism_banking_settings table .")
    end)
    
    exports.oxmysql:query(createNomineesTable, {}, function()
        print("^2[Prism Banking]^0 ✓  ensured prism_banking_nominees table .")
    end)
end)