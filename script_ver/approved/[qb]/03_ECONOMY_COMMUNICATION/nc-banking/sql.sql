-- =========================================
-- DW BANKING - SQL INSTALLATION FILE
-- =========================================
-- Version: 1.0
-- Compatible with: QBCore, ESX
-- 
-- INSTALLATION INSTRUCTIONS:
-- 1. Run this entire SQL file in your database
-- 2. Restart your server
-- 3. Enjoy DW Banking!
-- =========================================

-- Create banking transactions table
CREATE TABLE IF NOT EXISTS `banking_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_name` varchar(50) DEFAULT NULL,
  `receiver_name` varchar(50) DEFAULT NULL,
  `society` varchar(50) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `type` int(11) NOT NULL DEFAULT 1,
  `note` varchar(255) DEFAULT 'None',
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_sender` (`sender_name`),
  KEY `idx_receiver` (`receiver_name`),
  KEY `idx_society` (`society`),
  KEY `idx_timestamp` (`timestamp`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create player credit scores table
CREATE TABLE IF NOT EXISTS `player_credit_scores` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `credit_score` int(11) NOT NULL DEFAULT 580,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_citizenid` (`citizenid`),
  KEY `idx_credit_score` (`credit_score`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create player bank cards table
CREATE TABLE IF NOT EXISTS `player_bank_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `pin_hash` varchar(255) NOT NULL,
  `failed_attempts` int(11) NOT NULL DEFAULT 0,
  `blocked_until` timestamp NULL DEFAULT NULL,
  `last_used` timestamp NULL DEFAULT NULL,
  `status` enum('active','blocked','cancelled') NOT NULL DEFAULT 'active',
  `issued_date` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_active_card` (`citizenid`,`status`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create shared accounts table
CREATE TABLE IF NOT EXISTS `shared_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `code` varchar(5) NOT NULL,
  `owner_citizenid` varchar(50) NOT NULL,
  `balance` bigint(20) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_code` (`code`),
  KEY `idx_owner` (`owner_citizenid`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create shared account members table
CREATE TABLE IF NOT EXISTS `shared_account_members` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `permission_level` int(11) NOT NULL DEFAULT 1 COMMENT '1=Member, 2=Manager/Owner',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_member` (`account_id`,`citizenid`),
  KEY `idx_account_id` (`account_id`),
  KEY `idx_citizenid` (`citizenid`),
  CONSTRAINT `fk_member_account` FOREIGN KEY (`account_id`) REFERENCES `shared_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create shared account requests table
CREATE TABLE IF NOT EXISTS `shared_account_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `account_id` int(11) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `status` enum('pending','approved','denied') NOT NULL DEFAULT 'pending',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_pending_request` (`account_id`,`citizenid`,`status`),
  KEY `idx_account_id` (`account_id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_status` (`status`),
  CONSTRAINT `fk_request_account` FOREIGN KEY (`account_id`) REFERENCES `shared_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create society table (if it doesn't exist)
CREATE TABLE IF NOT EXISTS `society` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `money` bigint(20) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_name` (`name`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `banking_transactions` (`id`, `sender_name`, `receiver_name`, `society`, `amount`, `type`, `note`, `timestamp`) VALUES
(1, 'SYSTEM', 'SYSTEM', NULL, 0, 1, 'Deposit Transaction Type', '2024-01-01 00:00:00'),
(2, 'SYSTEM', 'SYSTEM', NULL, 0, 2, 'Withdraw Transaction Type', '2024-01-01 00:00:00'),
(3, 'SYSTEM', 'SYSTEM', 'SYSTEM', 0, 3, 'Society Deposit Transaction Type', '2024-01-01 00:00:00'),
(4, 'SYSTEM', 'SYSTEM', 'SYSTEM', 0, 4, 'Society Withdraw Transaction Type', '2024-01-01 00:00:00'),
(5, 'SYSTEM', 'SYSTEM', NULL, 0, 5, 'Transfer Transaction Type', '2024-01-01 00:00:00'),
(6, 'SYSTEM', 'SYSTEM', 'shared_example', 0, 6, 'Shared Deposit Transaction Type', '2024-01-01 00:00:00'),
(7, 'SYSTEM', 'SYSTEM', 'shared_example', 0, 7, 'Shared Withdraw Transaction Type', '2024-01-01 00:00:00'),
(8, 'SYSTEM', 'SYSTEM', 'shared_example', 0, 8, 'Shared Transfer Transaction Type', '2024-01-01 00:00:00');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS `idx_banking_transactions_compound` ON `banking_transactions` (`sender_name`, `timestamp`, `society`);
CREATE INDEX IF NOT EXISTS `idx_shared_accounts_owner_code` ON `shared_accounts` (`owner_citizenid`, `code`);
CREATE INDEX IF NOT EXISTS `idx_shared_members_compound` ON `shared_account_members` (`citizenid`, `permission_level`);

-- Success message
SELECT 'DW Banking database installation completed successfully!' as 'INSTALLATION_STATUS';

-- Show created tables
SHOW TABLES LIKE '%banking%';
SHOW TABLES LIKE '%shared_account%';
SHOW TABLES LIKE '%credit_score%';
SHOW TABLES LIKE '%society%';