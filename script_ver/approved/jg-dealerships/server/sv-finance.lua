


-- Initialize Finance namespace
if not Finance then
  Finance = {}
end

if not Finance.Server then
  Finance.Server = {}
end
---Get all financed vehicles in the database
---@return table Array of financed vehicle records

function Finance.Server.GetAllFinancedVehicles()
  local vehicles = MySQL.query.await("SELECT * FROM " .. Framework.VehiclesTable .. " WHERE financed = ?", {1})
  return vehicles or {}
end
---Get all financed vehicles for a specific player
---@param identifier string Player identifier
---@return table Array of player's financed vehicle records

function Finance.Server.GetPlayerFinancedVehicles(identifier)
  local query = "SELECT * FROM " .. Framework.VehiclesTable .. " WHERE " .. Framework.PlayerId .. " = ? AND financed = ?"
  local vehicles = MySQL.query.await(query, {identifier, 1})
  return vehicles or {}
end
---Get a specific financed vehicle for a player

function Finance.Server.GetFinancedVehicle(identifier, plate)
  local query = "SELECT * FROM " .. Framework.VehiclesTable .. " WHERE " .. Framework.PlayerId .. " = ? AND plate = ? AND financed = ?"
  return MySQL.single.await(query, {identifier, plate, 1})
end
---Update vehicle finance status in database

local function UpdateVehicleFinanceStatus(plate, isFinanced, financeData)
  local financeDataJson = financeData and json.encode(financeData) or nil
  local financedValue = isFinanced and 1 or 0
  
  MySQL.update.await(
    "UPDATE " .. Framework.VehiclesTable .. " SET financed = ?, finance_data = ? WHERE plate = ?",
    {financedValue, financeDataJson, plate}
  )
end
---Update dealership sales record with payment info

local function UpdateSalesRecord(plate, paid, owed)
  MySQL.update.await(
    "UPDATE dealership_sales SET paid = ?, owed = ? WHERE plate = ?",
    {paid, Round(owed), plate}
  )
end
---Process a recurring finance payment

function Finance.Server.MakePayment(playerId, vehicle, financeData)
  local currency = financeData.currency or "bank"
  local recurringPayment = financeData.recurring_payment
  local paymentAmount = Round(Currencies.Server.ConvertFromBase(recurringPayment, currency))
  local playerBalance = Framework.Server.GetPlayerBalance(playerId, currency)
  
  -- Check if player has enough money
  if paymentAmount > playerBalance then
    Framework.Server.Notify(playerId, Locale.errorNotEnoughMoney, "error")
    DebugPrint(string.format("Player %s tried to make payment but insufficient funds. Balance: %s, Required: %s (currency: %s)", 
      playerId, playerBalance, paymentAmount, currency), "debug")
    return false
  end
  
  -- Process payment
  Framework.Server.PlayerRemoveMoney(playerId, paymentAmount, currency)
  DealershipBalance.Server.Add(financeData.dealership_id, recurringPayment)
  
  -- Update finance data
  financeData.paid = financeData.paid + recurringPayment
  financeData.payment_failed = false
  financeData.payments_complete = financeData.payments_complete + 1
  financeData.seconds_to_next_payment = financeData.payment_interval * 3600
  
  DebugPrint(string.format("Player %s made payment of %s (%s %s) for vehicle %s. Completed: %s/%s",
    playerId, recurringPayment, paymentAmount, currency, vehicle.plate, financeData.payments_complete, financeData.total_payments), "debug")
  
  -- Update sales record
  UpdateSalesRecord(vehicle.plate, financeData.paid, financeData.total - financeData.paid)
  
  -- Notify player
  Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinancePaymentMade, "%%{value}", vehicle.plate), "success")
  
  SendWebhook(playerId, Webhooks.Finance, "Finance: Payment Success", "success", {
    {key = "Plate", value = vehicle.plate},
    {key = "Payment amount", value = recurringPayment},
    {key = "Currency", value = currency}
  })
  
  -- Check if vehicle is fully paid off
  if financeData.payments_complete >= financeData.total_payments then
    UpdateVehicleFinanceStatus(vehicle.plate, false, nil)
    
    DebugPrint(string.format("Player %s paid off vehicle %s", playerId, vehicle.plate), "debug")
    
    Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinancePaidOff, "%%{value}", vehicle.plate), "success")
    
    SendWebhook(playerId, Webhooks.Finance, "Finance: Vehicle paid off", "success", {
      {key = "Plate", value = vehicle.plate}
    })
    
    TriggerEvent("jg-dealerships:server:vehicle-finance-complete", playerId, vehicle.plate)
    
    return true, nil, true  -- success, no finance data (paid off), isPaidOff
  end
  
  -- Update vehicle with new finance data
  UpdateVehicleFinanceStatus(vehicle.plate, true, financeData)
  
  return true, financeData, false  -- success, updated finance data, not paid off
end
---Pay off a financed vehicle in full

function Finance.Server.PayInFull(playerId, vehicle, financeData)
  local currency = financeData.currency or "bank"
  local amountOwed = financeData.total - financeData.paid
  local paymentAmount = Round(Currencies.Server.ConvertFromBase(amountOwed, currency))
  local playerBalance = Framework.Server.GetPlayerBalance(playerId, currency)
  
  -- Check if player has enough money
  if paymentAmount > playerBalance then
    Framework.Server.Notify(playerId, Locale.errorNotEnoughMoney, "error")
    DebugPrint(string.format("Player %s tried to pay off vehicle %s but insufficient funds. Balance: %s, Required: %s (currency: %s)",
      playerId, vehicle.plate, playerBalance, paymentAmount, currency), "debug")
    return false
  end
  
  -- Process payment
  Framework.Server.PlayerRemoveMoney(playerId, paymentAmount, currency)
  DealershipBalance.Server.Add(financeData.dealership_id, amountOwed)
  
  -- Clear finance status
  UpdateVehicleFinanceStatus(vehicle.plate, false, nil)
  UpdateSalesRecord(vehicle.plate, financeData.total, 0)
  
  DebugPrint(string.format("Player %s paid off vehicle %s in full. Amount: %s", playerId, vehicle.plate, paymentAmount), "debug")
  
  Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinancePaidOff, "%%{value}", vehicle.plate), "success")
  
  SendWebhook(playerId, Webhooks.Finance, "Finance: Vehicle paid off", "success", {
    {key = "Plate", value = vehicle.plate}
  })
  
  TriggerEvent("jg-dealerships:server:vehicle-finance-complete", playerId, vehicle.plate)
  
  return true
end
---Repossess a financed vehicle due to payment failure

function Finance.Server.RepossessVehicle(playerId, vehicle, financeData)
  DebugPrint(string.format("Repossessing vehicle %s due to payment failure", vehicle.plate), "debug")
  
  -- Delete vehicle from database
  MySQL.query.await("DELETE FROM " .. Framework.VehiclesTable .. " WHERE plate = ?", {vehicle.plate})
  
  -- Return vehicle to dealership stock
  MySQL.update.await("UPDATE dealership_stock SET stock = stock + 1 WHERE vehicle = ? AND dealership = ?", 
    {financeData.vehicle, financeData.dealership_id})
  
  -- Update showroom cache
  Showroom.Server.UpdateVehicleCache(financeData.vehicle, financeData.dealership_id)
  
  -- Delete from advanced garages if available
  if GetResourceState("jg-advancedgarages") == "started" then
    TriggerEvent("jg-advancedgarages:server:DeleteOutsideVehicle", vehicle.plate)
  end
  
  -- Notify player if online
  if playerId then
    Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinanceRepossessed, "%%{value}", vehicle.plate), "error")
  end
  
  local balanceOwed = financeData.total - financeData.paid
  
  SendWebhook(playerId or 0, Webhooks.Finance, "Finance: Vehicle Repossessed!", "danger", {
    {key = "Plate", value = vehicle.plate},
    {key = "Balance owed", value = balanceOwed}
  })
  
  TriggerEvent("jg-dealerships:server:vehicle-finance-defaulted", playerId or 0, vehicle.plate, balanceOwed)
end
-- Callback: Get financed vehicles for a player
lib.callback.register("jg-dealerships:server:get-financed-vehicles", function(playerId)
  local identifier = Framework.Server.GetPlayerIdentifier(playerId)
  
  if not identifier then
    return {}
  end
  
  DebugPrint(string.format("Getting financed vehicles for player %s", identifier), "debug")
  
  local vehicles = Finance.Server.GetPlayerFinancedVehicles(identifier)
  
  DebugPrint(string.format("Got %s financed vehicles for player %s", #vehicles, identifier), "debug")
  
  return vehicles
end)
-- Callback: Make a finance payment (recurring or pay in full)
lib.callback.register("jg-dealerships:server:finance-make-payment", function(playerId, plate, paymentType)
  local identifier = Framework.Server.GetPlayerIdentifier(playerId)
  
  if not identifier then
    return {error = true}
  end
  
  local vehicle = Finance.Server.GetFinancedVehicle(identifier, plate)
  
  -- Check if vehicle exists and is financed
  if not vehicle or not vehicle.finance_data then
    DebugPrint(string.format("Player %s (%s) tried to make payment on vehicle %s that doesn't exist or isn't financed",
      identifier, playerId, plate), "debug")
    return {error = true}
  end
  
  local financeData = json.decode(vehicle.finance_data)
  
  if paymentType == "payment" then
    local success, updatedFinanceData, isPaidOff = Finance.Server.MakePayment(playerId, vehicle, financeData)
    
    if not success then
      return {error = true}
    end
    
    return {
      success = true,
      paidOff = isPaidOff,
      plate = vehicle.plate,
      financed = not isPaidOff,
      finance_data = updatedFinanceData
    }
  elseif paymentType == "pay-in-full" then
    local success = Finance.Server.PayInFull(playerId, vehicle, financeData)
    
    if not success then
      return {error = true}
    end
    
    return {
      success = true,
      paidOff = true,
      plate = vehicle.plate,
      financed = false,
      finance_data = nil
    }
  end
  
  return {error = true}
end)
---Get a map of online player identifiers to player IDs
---@return table Map of identifier -> playerId

local function GetOnlinePlayersMap()
  local onlineMap = {}
  local players = Framework.Server.GetPlayers()
  
  for _, playerData in pairs(players) do
    local playerId = playerData.player_id
    local identifier = Framework.Server.GetPlayerIdentifier(playerId)
    
    if identifier then
      onlineMap[identifier] = playerId
    end
  end
  
  return onlineMap
end
---Process auto-payment for a single financed vehicle

local function ProcessSingleVehicleFinance(playerId, identifier, vehicle, elapsedSeconds)
  -- Check if vehicle is financed and has finance data
  if not vehicle.financed or not vehicle.finance_data then
    return
  end
  
  local financeData = json.decode(vehicle.finance_data)
  local isOnline = playerId ~= nil
  local currency = financeData.currency or "bank"
  local currencySupportsOffline = Currencies.Server.SupportsOffline(currency)
  
  -- Handle payment failure countdown to repossession
  if financeData.payment_failed then
    financeData.seconds_to_repo = financeData.seconds_to_repo - elapsedSeconds
    
    local ownerStatus = isOnline and "online" or "offline"
    DebugPrint(string.format("Finance payment failed for vehicle %s. Seconds until repo: %s (owner %s)",
      vehicle.plate, financeData.seconds_to_repo, ownerStatus), "debug")
    
    -- Notify online player
    if isOnline and playerId then
      Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinanceRepossessedSoon, "%%{value}", vehicle.plate), "error")
    end
    
    -- Repossess if time is up
    if financeData.seconds_to_repo <= 0 then
      Finance.Server.RepossessVehicle(playerId, vehicle, financeData)
      return
    end
    
    -- Update finance data
    UpdateVehicleFinanceStatus(vehicle.plate, true, financeData)
    return
  end
  -- Countdown to next payment
  financeData.seconds_to_next_payment = financeData.seconds_to_next_payment - elapsedSeconds
  
  -- Not time for payment yet
  if financeData.seconds_to_next_payment > 0 then
    UpdateVehicleFinanceStatus(vehicle.plate, true, financeData)
    return
  end
  
  -- Payment is due - calculate amount
  local recurringPayment = financeData.recurring_payment
  local paymentAmount = Round(Currencies.Server.ConvertFromBase(recurringPayment, currency))
  local playerBalance = nil
  
  -- Get player balance (online or offline)
  if isOnline and playerId then
    playerBalance = Framework.Server.GetPlayerBalance(playerId, currency)
  elseif currencySupportsOffline then
    playerBalance = Currencies.Server.GetBalanceOffline(identifier, currency)
  else
    DebugPrint(string.format("Skipping offline payment for vehicle %s - currency %s doesn't support offline operations",
      vehicle.plate, currency), "debug")
    UpdateVehicleFinanceStatus(vehicle.plate, true, financeData)
    return
  end
  
  -- Check if player can afford payment
  if paymentAmount > playerBalance then
    DebugPrint(string.format("Finance payment failed for vehicle %s. Player %s insufficient funds. Balance: %s, Required: %s (currency: %s)",
      vehicle.plate, identifier, playerBalance, paymentAmount, currency), "debug")
    
    -- Mark payment as failed and start repossession countdown
    financeData.payment_failed = true
    financeData.seconds_to_repo = Config.FinancePaymentFailedHoursUntilRepo * 3600
    
    -- Notify online player
    if isOnline and playerId then
      Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinancePaymentFailed, "%%{value}", vehicle.plate), "error")
    end
    
    SendWebhook(playerId or 0, Webhooks.Finance, "Finance: Payment Failed", "danger", {
      {key = "Plate", value = vehicle.plate},
      {key = "Payment amount", value = recurringPayment},
      {key = "Currency", value = currency},
      {key = "Owner Status", value = isOnline and "Online" or "Offline"}
    })
    
    UpdateVehicleFinanceStatus(vehicle.plate, true, financeData)
    return
  end
  
  -- Process payment
  if isOnline and playerId then
    Framework.Server.PlayerRemoveMoney(playerId, paymentAmount, currency)
  else
    Currencies.Server.RemoveBalanceOffline(identifier, paymentAmount, currency)
  end
  
  DealershipBalance.Server.Add(financeData.dealership_id, recurringPayment)
  
  -- Update finance data
  financeData.paid = financeData.paid + recurringPayment
  financeData.payments_complete = financeData.payments_complete + 1
  financeData.seconds_to_next_payment = financeData.payment_interval * 3600
  
  DebugPrint(string.format("Auto-payment: Player %s paid %s (%s %s) for vehicle %s. Completed: %s/%s (%s)",
    identifier, recurringPayment, paymentAmount, currency, vehicle.plate, 
    financeData.payments_complete, financeData.total_payments, isOnline and "online" or "offline"), "debug")
  
  -- Update sales record
  UpdateSalesRecord(vehicle.plate, financeData.paid, financeData.total - financeData.paid)
  
  -- Notify online player
  if isOnline and playerId then
    Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinancePaymentMade, "%%{value}", vehicle.plate), "success")
  end
  
  SendWebhook(playerId or 0, Webhooks.Finance, "Finance: Payment Success", "success", {
    {key = "Plate", value = vehicle.plate},
    {key = "Payment amount", value = financeData.recurring_payment},
    {key = "Owner Status", value = isOnline and "Online" or "Offline"}
  })
  
  -- Check if vehicle is fully paid off
  if financeData.payments_complete >= financeData.total_payments then
    DebugPrint(string.format("Player %s paid off vehicle %s via auto-payment (%s)",
      identifier, vehicle.plate, isOnline and "online" or "offline"), "debug")
    
    if isOnline and playerId then
      Framework.Server.Notify(playerId, string.gsub(Locale.vehicleFinancePaidOff, "%%{value}", vehicle.plate), "success")
    end
    
    SendWebhook(playerId or 0, Webhooks.Finance, "Finance: Vehicle paid off", "success", {
      {key = "Plate", value = vehicle.plate},
      {key = "Owner Status", value = isOnline and "Online" or "Offline"}
    })
    
    TriggerEvent("jg-dealerships:server:vehicle-finance-complete", playerId or 0, vehicle.plate)
    
    UpdateVehicleFinanceStatus(vehicle.plate, false, nil)
    return
  end
  
  -- Update vehicle with new finance data
  UpdateVehicleFinanceStatus(vehicle.plate, true, financeData)
end
---Process all financed vehicles for a specific player

function Finance.Server.ProcessPlayerFinances(playerId, identifier, elapsedSeconds)
  local vehicles = Finance.Server.GetPlayerFinancedVehicles(identifier)
  
  if #vehicles == 0 then
    return
  end
  
  DebugPrint(string.format("Processing %s financed vehicles for player %s", #vehicles, identifier), "debug")
  
  for _, vehicle in ipairs(vehicles) do
    ProcessSingleVehicleFinance(playerId, identifier, vehicle, elapsedSeconds)
    Wait(500)
  end
end
-- Finance processing interval in minutes
local FINANCE_CHECK_INTERVAL_MINUTES = 10
local isFirstRun = true

-- Set up cron job to process finance payments
lib.cron.new(string.format("*/%s * * * *", FINANCE_CHECK_INTERVAL_MINUTES), function()
  -- Calculate elapsed seconds since last run
  local elapsedSeconds = isFirstRun and 0 or (FINANCE_CHECK_INTERVAL_MINUTES * 60)
  isFirstRun = false
  
  DebugPrint(string.format("Finance cron job running. Elapsed seconds: %s", elapsedSeconds), "debug")
  
  -- Get online players map
  local onlinePlayersMap = GetOnlinePlayersMap()
  local onlinePlayerCount = 0
  for _ in pairs(onlinePlayersMap) do
    onlinePlayerCount = onlinePlayerCount + 1
  end
  
  -- Get all financed vehicles
  local financedVehicles = Finance.Server.GetAllFinancedVehicles()
  
  if #financedVehicles == 0 then
    DebugPrint("No financed vehicles to process", "debug")
    return
  end
  
  DebugPrint(string.format("Processing %s financed vehicles (%s players online)", #financedVehicles, onlinePlayerCount), "debug")
  
  local processOfflinePlayers = Config.FinanceProcessOfflinePlayers
  
  -- Process each financed vehicle
  for _, vehicle in ipairs(financedVehicles) do
    local identifier = vehicle[Framework.PlayerId]
    local playerId = onlinePlayersMap[identifier]
    local isOnline = playerId ~= nil
    
    -- Process if player is online or offline processing is enabled
    if isOnline or processOfflinePlayers then
      ProcessSingleVehicleFinance(playerId, identifier, vehicle, elapsedSeconds)
    end
    
    Wait(500)
  end
end)
