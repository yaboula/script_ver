


-- Initialize Finance namespace
if not Finance then
  Finance = {}
end

if not Finance.Client then
  Finance.Client = {}
end
---Get all financed vehicles for the current player
---@return table NUI message data with financed vehicles
function Finance.Client.GetFinancedVehicles()
  local vehicles = lib.callback.await("jg-dealerships:server:get-financed-vehicles", false)
  
  for index, vehicle in pairs(vehicles) do
    if vehicle.financed and vehicle.finance_data then
      local model = Framework.Client.GetModelColumn(vehicle)
      local vehicleLabel = model and Framework.Client.GetVehicleLabel(model) or model
      
      vehicles[index].vehicleLabel = vehicleLabel
      vehicles[index].finance_data = json.decode(vehicle.finance_data)
    end
  end
  
  return {
    type = "manageFinance",
    vehicles = vehicles,
    config = Config,
    locale = Locale
  }
end
---Open the finance management menu
function Finance.Client.OpenFinanceMenu()
  SetNuiFocus(true, true)
  SendNUIMessage(Finance.Client.GetFinancedVehicles())
end
-- Callback: Open finance menu (called from server/other scripts)
lib.callback.register("jg-dealerships:client:open-finance-menu", function()
  Finance.Client.OpenFinanceMenu()
  return true
end)

-- NUI Callback: Make a payment on financed vehicle
RegisterNUICallback("finance-make-payment", function(data, cb)
  cb(lib.callback.await("jg-dealerships:server:finance-make-payment", false, data.plate, data.type))
end)
