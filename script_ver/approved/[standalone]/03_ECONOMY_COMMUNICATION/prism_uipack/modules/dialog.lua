local currentPromise

function InputDialog(heading, inputs, options)
  if currentPromise then
    return
  end

  local promiseObject = promise.new()
  currentPromise = promiseObject

  for i = 1, #inputs do
    if type(inputs[i]) == "string" then
      inputs[i] = {
        type = "input",
        label = inputs[i]
      }
    end
  end

  Utils.setNuiFocus(false)

  SendNUIMessage({
    action = "openDialog",
    data = {
      heading = heading,
      rows = inputs,
      options = options
    }
  })

  return Citizen.Await(currentPromise)
end

function CloseInputDialog()
  if not currentPromise then
    return
  end

  Utils.resetNuiFocus()

  SendNUIMessage({
    action = "closeInputDialog"
  })

  local promiseToResolve = currentPromise
  currentPromise = nil
  promiseToResolve:resolve(nil)
end

RegisterNUICallback("inputData", function(data, cb)
  cb(true)
  Utils.resetNuiFocus()

  local promiseToResolve = currentPromise
  currentPromise = nil
  promiseToResolve:resolve(data)
end)