



-- Initialize namespace
DealershipBalance = DealershipBalance or {}
DealershipBalance.Server = DealershipBalance.Server or {}

---Get the current balance for a dealership

function DealershipBalance.Server.GetBalance(dealershipId)
  local location, balance
  
  if Config.UseFrameworkJobs then
    location = Locations.Server.GetById(dealershipId)
    
    -- Check if location exists and has a job configured
    if not location or not location.job_name or location.job_name == "" then
      return nil
    end
    
    -- Get society balance for the job
    return Framework.Server.GetSocietyBalance(location.job_name, "job")
  else
    -- Get balance directly from database
    balance = MySQL.scalar.await(
      "SELECT balance FROM dealership_locations WHERE id = ?",
      {dealershipId}
    )
    return balance
  end
end

---Callback: Get dealership balance (with employee permission check)

lib.callback.register("jg-dealerships:server:dealership-balance:get", function(source, dealershipId)
  -- Check if player is an employee of this dealership
  local isEmployee = Employees.Server.IsEmployee(source, dealershipId)
  
  if not isEmployee then
    return false
  end
  
  -- Return the current balance
  return DealershipBalance.Server.GetBalance(dealershipId)
end)

---Add funds to a dealership's balance

function DealershipBalance.Server.Add(dealershipId, amount)
  local location
  
  -- Validate amount
  if amount < 0 then
    return false, "Amount must be positive"
  end
  
  if Config.UseFrameworkJobs then
    location = Locations.Server.GetById(dealershipId)
    
    if not location or not location.job_name or location.job_name == "" then
      return false, "Dealership has no job configured"
    end
    
    -- Add to society fund
    Framework.Server.AddToSocietyFund(location.job_name, "job", amount)
  else
    -- Update database directly
    MySQL.update.await(
      "UPDATE dealership_locations SET balance = balance + ? WHERE id = ?",
      {amount, dealershipId}
    )
  end
  
  return true
end

---Remove funds from a dealership's balance

function DealershipBalance.Server.Remove(dealershipId, amount)
  local location
  
  -- Validate amount
  if amount < 0 then
    return false, "Amount must be positive"
  end
  
  if Config.UseFrameworkJobs then
    location = Locations.Server.GetById(dealershipId)
    
    if not location or not location.job_name or location.job_name == "" then
      return false, "Dealership has no job configured"
    end
    
    -- Remove from society fund
    Framework.Server.RemoveFromSocietyFund(location.job_name, "job", amount)
  else
    -- Update database directly
    MySQL.update.await(
      "UPDATE dealership_locations SET balance = balance - ? WHERE id = ?",
      {amount, dealershipId}
    )
  end
  
  return true
end

---Check if a dealership has sufficient funds

function DealershipBalance.Server.HasFunds(dealershipId, amount)
  -- Get current balance
  local balance = DealershipBalance.Server.GetBalance(dealershipId)
  
  -- If balance is nil, dealership doesn't exist or has no balance configured
  if balance == nil then
    return false, nil
  end
  
  -- Check if dealership has enough funds
  local hasFunds = amount <= balance
  return hasFunds, balance
end
