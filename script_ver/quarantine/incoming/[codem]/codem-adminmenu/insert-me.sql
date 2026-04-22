CREATE TABLE IF NOT EXISTS `codem_adminmenu` (
  `identifier` varchar(50) DEFAULT NULL,
  `permissiondata` longtext DEFAULT NULL,
  `historydata` longtext DEFAULT NULL,
  `bandata` longtext DEFAULT NULL,
  `profiledata` longtext DEFAULT NULL,
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;