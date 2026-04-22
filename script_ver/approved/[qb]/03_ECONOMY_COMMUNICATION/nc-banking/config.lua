Config = {}

-- Target System (options: 'qb-target', 'ox_target')
Config.TargetSystem = 'qb_target'  -- Choose which target system to use

-- Bank Locations with headings
Config.BankLocations = {
    vector4(149.46, -1042.09, 29.37, 335.43),    -- Legion Square Bank
    vector4(313.84, -280.58, 54.16, 338.31),  -- Pacific Standard Bank
    vector4(-351.23, -51.28, 49.04, 341.73),  -- Hawick Ave Bank
    vector4(-1211.9, -331.9, 37.78, 20.07), -- Rockford Hills Bank
    vector4(-2961.14, 483.09, 15.7, 83.84),  -- Great Ocean Highway Bank
    vector4(1174.8, 2708.2, 38.09, 178.52), -- Sandy Shores Bank
    vector4(242.82017, 226.6354, 107.2873, 159.48873),     -- Pacific Standard Bank
    vector4(-112.22, 6471.01, 31.63, 134.18),     -- Pluto Standard Bank
}

-- Bank Ped Settings
Config.UseBankPeds = true -- Set to false if you don"t want to use bank peds
Config.BankPed = "ig_bankman" -- Default bank ped model

-- Shared Account Settings
Config.SharedAccounts = {
    EnableFeature = true,     -- Set to false to disable shared accounts
    MaxMembersPerAccount = 5, -- Maximum number of members in a shared account
    CreationFee = 1000,       -- Fee to create a shared account (set to 0 for free)
    CodeLength = 3            -- Length of the join code (3 digits instead of 5)
}
Config.LogTypes = {
    ["deposit"] = 1,
    ["withdraw"] = 2,
    ["society_deposit"] = 3,
    ["society_withdraw"] = 4,
    ["transfer"] = 5,
    ["shared_deposit"] = 6,
    ["shared_withdraw"] = 7,
    ["shared_transfer"] = 8,
}

Config.ATMProps = {
	'prop_atm_01',
	'prop_atm_02',
	'prop_atm_03',
	'prop_fleeca_atm',
	'v_5_b_atm1',
	'v_5_b_atm'
}

for key, value in pairs(Config.LogTypes) do
    Config.LogTypes[value] = key;
end