local currentPromise, promiseCounter

currentPromise = nil
promiseCounter = 0

---@param data table
---@param timeout number?
---@return Promise
local function AlertDialog(data, timeout)
  if currentPromise then
    return
  end

  promiseCounter = promiseCounter + 1

  local promiseObject = promise.new()
  currentPromise = promiseObject

  Utils.setNuiFocus(false)

  SendNUIMessage({
    action = "sendAlert",
    data = data
  })

  if timeout then
    SetTimeout(timeout, function()
      if promiseCounter == promiseCounter then
        CloseAlertDialog("timeout")
      end
    end)
  end

  return Citizen.Await(currentPromise)
end

---@param reason string?
local function CloseAlertDialog(reason)
  if not currentPromise then
    return
  end

  Utils.resetNuiFocus()

  SendNUIMessage({
    action = "closeAlertDialog"
  })

  local promiseObject = currentPromise
  currentPromise = nil

  if reason then
    promiseObject.reject(promiseObject, reason)
  else
    promiseObject.resolve(promiseObject)
  end
end

RegisterNUICallback("closeAlert", function(data, cb)
  cb(1)

  Utils.resetNuiFocus()

  local promiseObject = currentPromise
  currentPromise = nil

  promiseObject.resolve(promiseObject, data)
end)

RegisterNetEvent("ox_lib:alertDialog", AlertDialog)