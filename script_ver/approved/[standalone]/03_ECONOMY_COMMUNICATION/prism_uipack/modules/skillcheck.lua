local currentSkillCheckPromise

function SkillCheck(difficulty, keys, options)
  if currentSkillCheckPromise then
    return
  end

  currentSkillCheckPromise = promise.new()

  if not options then
    options = {}
  end

  Utils.setNuiFocus(false, true)

  SendNUIMessage({
    action = "startSkillCheck",
    data = {
      difficulty = difficulty or {"easy"},
      keys = keys or {"e"},
      label = options.label,
      instruction = options.instruction,
      type = options.type
    }
  })

  return Citizen.Await(currentSkillCheckPromise)
end

function CancelSkillCheck()
  if not currentSkillCheckPromise then
    error("No skillCheck is active")
  end

  SendNUIMessage({
    action = "skillCheckCancel"
  })
end

function SkillCheckActive()
  return currentSkillCheckPromise ~= nil
end

RegisterNUICallback("skillCheckOver", function(data, cb)
  cb(1)

  if currentSkillCheckPromise then
    Utils.resetNuiFocus()
    local promise = currentSkillCheckPromise
    currentSkillCheckPromise = nil
    promise.resolve(promise, data)
  end
end)