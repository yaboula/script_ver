


Config = {}

-- Localization
Config.Locale = "en"
Config.NumberAndDateFormat = "en-US"
Config.Currency = "$%s" -- Format: "$%s" -> "$1,000" or "%s coins" -> "1,000 coins"
Config.SpeedUnit = "kph" -- Options: "mph", "kph"
Config.DistanceUnit = "km" -- Options: "mi", "km"

-- Framework & Integrations
Config.Framework = "auto" -- Options: "auto", "QBCore", "Qbox", "ESX"
Config.FuelSystem = "none" -- Options: "LegacyFuel", "ps-fuel", "lj-fuel", "ox_fuel", "cdn-fuel", "hyon_gas_station", "okokGasStation", "nd_fuel", "myFuel", "ti_fuel", "Renewed-Fuel", "rcore_fuel", "qs-fuelstations", "none"
Config.VehicleKeys = "qb-vehiclekeys" -- Options: "qb-vehiclekeys", "MrNewbVehicleKeys", "jaksam-vehicles-keys", "qs-vehiclekeys", "mk_vehiclekeys", "wasabi_carlock", "cd_garage", "okokGarage", "t1ger_keys", "Renewed", "tgiann-hotwire", "none"
Config.Notifications = "auto" -- Options: "auto", "default", "okokNotify", "ox_lib", "ps-ui"

-- Interaction settings
Config.InteractionMethod = "textui" -- Options: "textui", "target", "3dtextui", "radial"
Config.DrawText = "ox_lib" -- Options: "auto", "jg-textui", "qb-DrawText", "okokTextUI", "ox_lib", "ps-ui"
Config.Target = "auto" -- Options: "auto", "ox_target"
Config.DrawText3d = "auto" -- Options: "auto", "sleepless_interact"
Config.RadialMenu = "ox_lib" -- Options: "auto", "ox_lib"

-- Use framework job system instead of built-in employee system
Config.UseFrameworkJobs = false

-- Text UI prompts
Config.OpenShowroomPrompt = "[E] Open Showroom"
Config.OpenShowroomKeyBind = 38
Config.ViewInShowroomPrompt = "[E] View in Showroom"
Config.ViewInShowroomKeyBind = 38
Config.OpenManagementPrompt = "[E] Dealership Management"
Config.OpenManagementKeyBind = 38
Config.SellVehiclePrompt = "[E] Sell Vehicle"
Config.SellVehicleKeyBind = 38

-- Advanced: Enable server-side vehicle spawning (may have reliability issues on high population servers)
Config.SpawnVehiclesWithServerSetter = false

-- Vehicle financing settings (disable per-location in-game)
Config.FinancePayments = 12 -- Number of payments
Config.FinanceDownPayment = 0.1 -- Down payment percentage (0.1 = 10%)
Config.FinanceInterest = 0.1 -- Interest rate (0.1 = 10%)
Config.FinancePaymentInterval = 12 -- Hours between payments
Config.FinancePaymentFailedHoursUntilRepo = 1 -- Hours until repossession after failed payment
Config.MaxFinancedVehiclesPerPlayer = 5 -- Maximum financed vehicles per player
Config.FinanceProcessOfflinePlayers = true -- Process payments for offline players

-- Show vehicle preview images in UI
Config.ShowVehicleImages = true

-- Vehicle purchase settings
Config.PlateFormat = "1AA111AA" -- Plate format: 1=number, A=letter
Config.HideVehicleStats = false -- Hide vehicle statistics in showroom

-- Test drive settings
Config.TestDrivePlate = "TEST1111" -- Plate seed (generates random plates)
Config.TestDriveTimeSeconds = 120 -- Test drive duration in seconds
Config.TestDriveNotInBucket = false -- Set true to show test drives to all players
Config.DealershipMaxActiveTestDrives = 5 -- Max active test drives per dealership

-- Display vehicles (showroom)
Config.DisplayVehiclesPlate = "DEALER"
Config.DisplayVehiclesHidePurchasePrompt = false

-- Dealership stock and ordering
Config.TruckingMissionForOrderDeliveries = true -- Enable trucking missions for deliveries
Config.DealerPurchasePrice = 0.8 -- Dealer wholesale price (0.8 = 80% of retail)
Config.VehicleOrderTime = 1 -- Order delivery time in minutes
Config.ManagerCanChangePriceOfVehicles = true -- Allow managers to adjust vehicle prices

-- Map blip name format
Config.BlipNameFormat = "Dealership: %s"

Config.Categories = {
  planes = "Planes",
  sportsclassics = "Sports Classics",
  sedans = "Sedans",
  compacts = "Compacts",
  motorcycles = "Motorcycles",
  super = "Super",
  offroad = "Offroad",
  helicopters = "Helicopters",
  coupes = "Coupes",
  muscle = "Muscle",
  boats = "Boats",
  vans = "Vans",
  sports = "Sports",
  suvs = "SUVs",
  commercial = "Commercial",
  cycles = "Cycles",
  industrial = "Industrial"
}

-- Employee permissions (only used if UseFrameworkJobs = false)
-- Available permissions: ADMIN, MANAGE_EMPLOYEES, MANAGE_INVENTORY, MANAGE_FINANCES, SELL, DELIVER, VIEW_RECORDS
Config.EmployeePermissions = {
  ["Manager"] = {
    "ADMIN",
  },
  ["Supervisor"] = {
    "MANAGE_INVENTORY",
    "VIEW_RECORDS",
    "SELL",
    "DELIVER",
  },
  ["Sales"] = {
    "SELL",
    "VIEW_RECORDS",
    "DELIVER",
  },
}

-- Commands
Config.MyFinanceCommand = "myfinance"
Config.DirectSaleCommand = "directsale"
Config.DealerAdminCommand = "dealeradmin"

-- Advanced options
Config.EntityStreamingDistance = 100.0 -- Entity streaming distance in meters
Config.RemoveGeneratorsAroundDealership = true -- Remove generators near dealerships
Config.AutoRunSQL = true -- Automatically run SQL migrations on start
Config.ReturnToPreviousRoutingBucket = false -- Return player to previous routing bucket after test drive
Config.HideWatermark = false -- Hide UI watermark
Config.Debug = false -- Enable debug mode