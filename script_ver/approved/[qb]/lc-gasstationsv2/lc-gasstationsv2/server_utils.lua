






WebhookURL = "WEBHOOK"
function beforeBuyGasStation(source,gas_station_id,price)

	return true

end

function afterBuyGasStation(source,gas_station_id,price)

end

function beforeStartContractImport(source,gas_station_id,total_price,amount)

	return true

end

function afterFinishContractImport(source,gas_station_id,amount,new_stock_amount)

end

function beforeStartContractExport(source,gas_station_id,amount)

	return true

end

function afterFinishContractExport(source,gas_station_id,amount,money_received)

end

function beforeHireEmployee(source,gas_station_id,employee_id)

	return true

end

function afterHireEmployee(source,gas_station_id,employee_id)

end







