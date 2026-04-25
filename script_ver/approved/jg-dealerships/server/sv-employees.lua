


-- Initialize Employees namespace
if not Employees then
  Employees = {}
end

if not Employees.Server then
  Employees.Server = {}
end
---Check if a permission exists in a permissions table

local function HasPermission(permissions, permission)
  for _, perm in ipairs(permissions) do
    if perm == permission then
      return true
    end
  end
  return false
end
---Set player's framework job based on dealership employment

local function SetPlayerJobForDealership(identifier, dealershipId, role)
  local location = Locations.Server.GetById(dealershipId)
  
  if not location or not location.job_name or location.job_name == "" then
    return false
  end
  
  local job_rank_mapping = location.job_rank_mapping
  
  if not job_rank_mapping or type(job_rank_mapping) ~= "table" or next(job_rank_mapping) == nil then
    return false
  end
  
  local jobName
  local jobGrade
  
  if role then
    jobGrade = GetCaseInsensitive(job_rank_mapping, role)
    if jobGrade == nil then
      return false
    end
    jobName = location.job_name
  else
    jobName = "unemployed"
    jobGrade = 0
  end
  
  local playerId = Framework.Server.GetPlayerFromIdentifier(identifier)
  if playerId then
    DebugPrint("Setting job for " .. identifier .. "(" .. playerId .. ") to " .. jobName .. " with rank " .. jobGrade, "debug")
    Framework.Server.PlayerSetJob(playerId, jobName, jobGrade)
    return true
  else
    Framework.Server.PlayerSetJobOffline(identifier, jobName, jobGrade)
    return false
  end
end
---Notify player client-side that their employee status changed

local function NotifyEmployeeStatusChanged(identifier, dealershipId)
  local playerId = Framework.Server.GetPlayerFromIdentifier(identifier)
  if playerId then
    TriggerClientEvent("jg-dealerships:client:employee-status-changed", playerId, dealershipId)
  end
end
---Get employee permissions and role for a player at a dealership

local function GetEmployeePermissionsAndRole(playerId, dealershipId, checkAdmin)
  if checkAdmin == nil then
    checkAdmin = true
  end
  
  -- Check if player is a server admin
  if checkAdmin then
    if Framework.Server.IsAdmin(playerId) then
      DebugPrint(playerId .. " returned as server admin", "debug")
      return {"ADMIN"}, "serverAdmin"
    end
  end
  
  local identifier = Framework.Server.GetPlayerIdentifier(playerId)
  if not identifier then
    return false, false
  end
  
  -- Use framework jobs if enabled
  if Config.UseFrameworkJobs then
    local location = Locations.Server.GetById(dealershipId)
    
    -- Check if location has valid job configuration
    if not location or not location.job_name or location.job_name == "" then
      DebugPrint("Dealership " .. dealershipId .. " has no job_name configured", "debug")
      return false, false
    end
    
    local playerJob = Framework.Server.GetPlayerJob(playerId)
    
    -- Validate player job
    if not playerJob or not playerJob.name then
      DebugPrint("Could not get job for player " .. playerId, "debug")
      return false, false
    end
    
    -- Check if player's job matches the dealership job
    if playerJob.name ~= location.job_name then
      DebugPrint(identifier .. " job (" .. playerJob.name .. ") does not match dealership job (" .. location.job_name .. ")", "debug")
      return false, false
    end
    
    local job_rank_permissions = location.job_rank_permissions
    
    -- Check if job rank permissions are configured
    if not job_rank_permissions or type(job_rank_permissions) ~= "table" then
      DebugPrint("No job_rank_permissions configured for dealership " .. dealershipId, "warning")
      local gradeLabel = playerJob.gradeLabel or ("Grade " .. tostring(playerJob.grade))
      return {}, gradeLabel
    end
    
    local grade = tonumber(playerJob.grade) or 0
    local permissions = job_rank_permissions[tostring(grade)]
    
    if not permissions then
      DebugPrint("No permissions mapped for grade " .. grade .. " at dealership " .. dealershipId, "debug")
      local gradeLabel = playerJob.gradeLabel or ("Grade " .. tostring(playerJob.grade))
      return {}, gradeLabel
    end
    
    local gradeLabel = playerJob.gradeLabel or ("Grade " .. tostring(playerJob.grade))
    return permissions, gradeLabel
  end
  
  -- Use dealership_employees table
  local employee = MySQL.single.await("SELECT * FROM dealership_employees WHERE identifier = ? AND dealership = ?", {identifier, dealershipId})
  
  if not employee then
    DebugPrint(identifier .. " is not an employee at " .. dealershipId, "debug")
    return false, false
  end
  
  local permissions, roleKey = GetCaseInsensitive(Config.EmployeePermissions, employee.role)
  
  if not permissions then
    DebugPrint("No permissions configured for role: " .. employee.role, "warning")
    return {}, employee.role
  end
  
  DebugPrint(identifier .. " is an employee at " .. dealershipId .. " with role " .. employee.role, "debug")
  return permissions, employee.role
end
---Check if a player is an employee at a dealership with optional permission check

function Employees.Server.IsEmployee(playerId, dealershipId, requiredPermission, checkAdmin)
  local permissions, role = GetEmployeePermissionsAndRole(playerId, dealershipId, checkAdmin)
  
  if not permissions then
    return false
  end
  
  -- Admin has all permissions
  if HasPermission(permissions, "ADMIN") then
    return role
  end
  
  -- No specific permission required
  if not requiredPermission then
    return role
  end
  
  -- Check single permission
  if type(requiredPermission) == "string" then
    if not HasPermission(permissions, requiredPermission) then
      return false
    end
  -- Check multiple permissions (any match)
  elseif type(requiredPermission) == "table" then
    local hasAnyPermission = false
    for _, perm in ipairs(requiredPermission) do
      if HasPermission(permissions, perm) then
        hasAnyPermission = true
        break
      end
    end
    if not hasAnyPermission then
      return false
    end
  end
  
  return role
end
---Check if a player has a specific permission at a dealership

local function HasEmployeePermission(playerId, dealershipId, permission)
  local permissions = GetEmployeePermissionsAndRole(playerId, dealershipId)
  
  if not permissions then
    return false
  end
  
  -- Admin has all permissions
  if HasPermission(permissions, "ADMIN") then
    return true
  end
  
  return HasPermission(permissions, permission)
end
---Get all permissions for a player at a dealership

function Employees.Server.GetPermissions(playerId, dealershipId)
  local permissions = GetEmployeePermissionsAndRole(playerId, dealershipId, true)
  
  if not permissions then
    return {}
  end
  
  -- If admin, return all possible permissions
  if HasPermission(permissions, "ADMIN") then
    return {"ADMIN", "MANAGE_EMPLOYEES", "MANAGE_INVENTORY", "MANAGE_FINANCES", "SELL", "DELIVER", "VIEW_RECORDS"}
  end
  
  return permissions
end
---Get all employees for a dealership
---@param dealershipId string Dealership ID
---@return table Array of employee records

function Employees.Server.GetEmployees(dealershipId)
  local employees = MySQL.query.await("SELECT * FROM dealership_employees WHERE dealership = ? ORDER BY joined DESC", {dealershipId})
  return employees or {}
end
---Hire an employee at a dealership

function Employees.Server.HireEmployee(identifier, dealershipId, role)
  -- Check if already employed
  local existing = MySQL.single.await("SELECT id FROM dealership_employees WHERE identifier = ? AND dealership = ?", {identifier, dealershipId})
  
  if existing then
    return false
  end
  
  -- Insert new employee
  MySQL.insert.await("INSERT INTO dealership_employees (identifier, dealership, role) VALUES (?, ?, ?)", {identifier, dealershipId, role})
  
  -- Set framework job if enabled
  local isOnline = SetPlayerJobForDealership(identifier, dealershipId, role)
  
  -- Notify player if online
  if not isOnline then
    NotifyEmployeeStatusChanged(identifier, dealershipId)
  end
  
  return true
end
---Fire an employee from a dealership

function Employees.Server.FireEmployee(identifier, dealershipId)
  -- Check if employee exists
  local existing = MySQL.single.await("SELECT id FROM dealership_employees WHERE identifier = ? AND dealership = ?", {identifier, dealershipId})
  
  if not existing then
    return false
  end
  
  -- Delete employee record
  MySQL.query.await("DELETE FROM dealership_employees WHERE identifier = ? AND dealership = ?", {identifier, dealershipId})
  
  -- Remove framework job if enabled (set to unemployed)
  local isOnline = SetPlayerJobForDealership(identifier, dealershipId, nil)
  
  -- Notify player if online
  if not isOnline then
    NotifyEmployeeStatusChanged(identifier, dealershipId)
  end
  
  return true
end
---Update an employee's role at a dealership

function Employees.Server.UpdateRole(identifier, dealershipId, newRole)
  -- Check if employee exists
  local existing = MySQL.single.await("SELECT id FROM dealership_employees WHERE identifier = ? AND dealership = ?", {identifier, dealershipId})
  
  if not existing then
    return false
  end
  
  -- Update employee role
  MySQL.query.await("UPDATE dealership_employees SET role = ? WHERE identifier = ? AND dealership = ?", {newRole, identifier, dealershipId})
  
  -- Update framework job if enabled
  local isOnline = SetPlayerJobForDealership(identifier, dealershipId, newRole)
  
  -- Notify player if online
  if not isOnline then
    NotifyEmployeeStatusChanged(identifier, dealershipId)
  end
  
  return true
end
---Get employees with enriched info (name, isMe flag) for a dealership

function Employees.Server.GetEmployeesWithInfo(playerId, dealershipId)
  -- Check permission
  if not HasEmployeePermission(playerId, dealershipId, "MANAGE_EMPLOYEES") then
    Framework.Server.Notify(playerId, Locale.employeePermissionsError, "error")
    return {error = true}
  end
  
  -- Get all employees
  local employees = Employees.Server.GetEmployees(dealershipId)
  
  -- Get requester's identifier
  local requesterIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
  
  -- Enrich employee data
  for _, employee in ipairs(employees) do
    local playerInfo = Framework.Server.GetPlayerInfoFromIdentifier(employee.identifier)
    
    -- Set employee name (use playerInfo name or identifier as fallback)
    employee.name = (playerInfo and playerInfo.name) or employee.identifier
    
    -- Mark if this is the requester
    employee.me = (employee.identifier == requesterIdentifier)
  end
  
  return employees
end
-- Callback: Check if player is an employee and return info
lib.callback.register("jg-dealerships:server:is-employee", function(playerId, dealershipId, checkAdmin)
  local role = Employees.Server.IsEmployee(playerId, dealershipId, nil, checkAdmin)
  
  if not role then
    return {isEmployee = false}
  end
  
  local playerInfo = Framework.Server.GetPlayerInfo(playerId)
  local permissions = Employees.Server.GetPermissions(playerId, dealershipId)
  
  return {
    isEmployee = true,
    employeeName = (playerInfo and playerInfo.name) or "",
    employeeRole = role,
    permissions = permissions
  }
end)
-- Callback: Get dealership employees with info
lib.callback.register("jg-dealerships:server:get-dealership-employees", function(playerId, data)
  return Employees.Server.GetEmployeesWithInfo(playerId, data.dealershipId)
end)
-- Event: Request to hire an employee
RegisterNetEvent("jg-dealerships:server:request-hire-employee", function(data)
  local requesterId = source
  
  -- Check if requester has permission to manage employees
  if not HasEmployeePermission(requesterId, data.dealershipId, "MANAGE_EMPLOYEES") then
    Framework.Server.Notify(requesterId, Locale.employeePermissionsError, "error")
    return
  end
  
  -- Handle self-hire (admin only)
  if data.selfHire and data.playerId == requesterId then
    if not Framework.Server.IsAdmin(requesterId) then
      Framework.Server.Notify(requesterId, Locale.onlyServerAdminsCanSelfHire, "error")
      return
    end
    
    local identifier = Framework.Server.GetPlayerIdentifier(requesterId)
    if not identifier then
      Framework.Server.Notify(requesterId, Locale.playerNotFound, "error")
      return
    end
    
    -- Hire self
    if not Employees.Server.HireEmployee(identifier, data.dealershipId, data.role) then
      Framework.Server.Notify(requesterId, Locale.failedToHireEmployee, "error")
      return
    end
    
    local playerInfo = Framework.Server.GetPlayerInfo(requesterId)
    local playerName = (playerInfo and playerInfo.name) or identifier
    
    SendWebhook(requesterId, Webhooks.Dealership, "Dealership: Employee Self-Hired", "success", {
      {key = "Dealership", value = data.dealershipId},
      {key = "Employee", value = playerName},
      {key = "Role", value = data.role}
    })
    
    Framework.Server.Notify(requesterId, Locale.employeeHiredMsg, "success")
    TriggerClientEvent("jg-dealerships:client:employee-hire-response", requesterId, {
      accepted = true,
      playerName = data.playerName,
      identifier = identifier,
      role = data.role
    })
    return
  end
  
  -- Send hire request to target player
  data.requesterId = requesterId
  TriggerClientEvent("jg-dealerships:client:show-confirm-employment", data.playerId, data)
end)
-- Event: Employee hire request rejected
RegisterNetEvent("jg-dealerships:server:employee-hire-rejected", function(requesterId, playerName)
  Framework.Server.Notify(requesterId, Locale.employeeRejectedMsg, "error")
  TriggerClientEvent("jg-dealerships:client:employee-hire-response", requesterId, {
    accepted = false,
    playerName = playerName
  })
end)
-- Event: Hire employee (player accepted)
RegisterNetEvent("jg-dealerships:server:hire-employee", function(data)
  local identifier = Framework.Server.GetPlayerIdentifier(data.playerId)
  
  if not identifier then
    Framework.Server.Notify(data.requesterId, Locale.playerNotFound, "error")
    TriggerClientEvent("jg-dealerships:client:employee-hire-response", data.requesterId, {
      accepted = false,
      playerName = data.playerName
    })
    return
  end
  
  DebugPrint("Hiring employee " .. identifier .. "(" .. data.playerId .. ") at " .. data.dealershipId .. " with role " .. data.role, "debug")
  
  if not Employees.Server.HireEmployee(identifier, data.dealershipId, data.role) then
    Framework.Server.Notify(data.requesterId, Locale.failedToHireEmployee, "error")
    TriggerClientEvent("jg-dealerships:client:employee-hire-response", data.requesterId, {
      accepted = false,
      playerName = data.playerName
    })
    return
  end
  
  local playerInfo = Framework.Server.GetPlayerInfo(data.playerId)
  local playerName = (playerInfo and playerInfo.name) or identifier
  
  SendWebhook(source, Webhooks.Dealership, "Dealership: Employee Hired", "success", {
    {key = "Dealership", value = data.dealershipId},
    {key = "Employee", value = playerName},
    {key = "Role", value = data.role}
  })
  
  Framework.Server.Notify(data.requesterId, Locale.employeeHiredMsg, "success")
  TriggerClientEvent("jg-dealerships:client:employee-hire-response", data.requesterId, {
    accepted = true,
    playerName = data.playerName,
    identifier = identifier,
    role = data.role
  })
end)
-- Event: Fire an employee
RegisterNetEvent("jg-dealerships:server:fire-employee", function(identifier, dealershipId)
  local requesterId = source
  
  -- Check permission
  if not HasEmployeePermission(requesterId, dealershipId, "MANAGE_EMPLOYEES") then
    Framework.Server.Notify(requesterId, Locale.employeePermissionsError, "error")
    return
  end
  
  local employeeInfo = Framework.Server.GetPlayerInfoFromIdentifier(identifier)
  local employeePlayerId = Framework.Server.GetPlayerFromIdentifier(identifier)
  
  if not Employees.Server.FireEmployee(identifier, dealershipId) then
    Framework.Server.Notify(requesterId, Locale.failedToFireEmployee, "error")
    return
  end
  
  -- Notify fired employee if online
  if employeePlayerId then
    local message = string.gsub(Locale.firedNotification, "%%{value}", dealershipId)
    Framework.Server.Notify(employeePlayerId, message, "error")
  end
  
  local employeeName = (employeeInfo and employeeInfo.name) or identifier
  
  SendWebhook(requesterId, Webhooks.Dealership, "Dealership: Employee Fired", "danger", {
    {key = "Dealership", value = dealershipId},
    {key = "Employee", value = employeeName}
  })
end)
-- Event: Update employee role
RegisterNetEvent("jg-dealerships:server:update-employee-role", function(identifier, dealershipId, newRole)
  local requesterId = source
  
  -- Check permission
  if not HasEmployeePermission(requesterId, dealershipId, "MANAGE_EMPLOYEES") then
    Framework.Server.Notify(requesterId, Locale.employeePermissionsError, "error")
    return
  end
  
  if not Employees.Server.UpdateRole(identifier, dealershipId, newRole) then
    Framework.Server.Notify(requesterId, Locale.failedToUpdateEmployeeRole, "error")
    return
  end
  
  local employeeInfo = Framework.Server.GetPlayerInfoFromIdentifier(identifier)
  local employeeName = (employeeInfo and employeeInfo.name) or identifier
  
  SendWebhook(requesterId, Webhooks.Dealership, "Dealership: Employee Updated", nil, {
    {key = "Dealership", value = dealershipId},
    {key = "Employee", value = employeeName},
    {key = "New role", value = newRole}
  })
end)
