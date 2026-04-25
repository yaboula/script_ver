


-- Initialize Employees namespace
if not Employees then
  Employees = {}
end

if not Employees.Client then
  Employees.Client = {}
end
---Show employment confirmation dialog to player
---@param data table Employment offer data
RegisterNetEvent("jg-dealerships:client:show-confirm-employment", function(data)
  SetNuiFocus(true, true)
  SendNUIMessage({
    type = "showConfirmEmployment",
    data = data,
    config = Config,
    locale = Locale
  })
end)
-- NUI Callback: Player accepts employment offer
RegisterNUICallback("accept-hire-request", function(data, cb)
  TriggerServerEvent("jg-dealerships:server:hire-employee", data)
  cb(true)
end)
-- NUI Callback: Player denies employment offer
RegisterNUICallback("deny-hire-request", function(data, cb)
  TriggerServerEvent("jg-dealerships:server:employee-hire-rejected", data.requesterId, data.playerName)
  cb(true)
end)
---Receive hire response from server
---@param data table Response data (success/failure)
RegisterNetEvent("jg-dealerships:client:employee-hire-response", function(data)
  SendNUIMessage({
    type = "employee-hire-response",
    data = data
  })
end)
-- NUI Callback: Request to hire an employee
RegisterNUICallback("request-hire-employee", function(data, cb)
  TriggerServerEvent("jg-dealerships:server:request-hire-employee", data)
  cb(true)
end)

-- NUI Callback: Fire an employee
RegisterNUICallback("fire-employee", function(data, cb)
  TriggerServerEvent("jg-dealerships:server:fire-employee", data.identifier, data.dealershipId)
  cb(true)
end)

-- NUI Callback: Update employee role
RegisterNUICallback("update-employee-role", function(data, cb)
  TriggerServerEvent("jg-dealerships:server:update-employee-role", data.identifier, data.dealershipId, data.newRole)
  cb(true)
end)
