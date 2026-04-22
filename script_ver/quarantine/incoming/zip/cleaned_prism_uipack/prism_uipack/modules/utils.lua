local Utils = {}

Utils.game = GetGameName()

function Utils.waitFor(callback, errorMessage, timeout)
  local result = callback()
  if result then
    return result
  end

  if timeout == nil or type(timeout) ~= "number" then
    timeout = 1000
  end

  local startTime = timeout and GetGameTimer()

  while result == nil do
    Wait(0)

    local elapsedTime = timeout and (GetGameTimer() - startTime)

    if timeout and elapsedTime and timeout < elapsedTime then
      local errorFunc = error
      local errorMessageFormat = "%s (waited %.1fms)"
      local formattedErrorMessage = errorMessageFormat:format(errorMessage or "failed to resolve callback", elapsedTime)
      local level = 2
      return errorFunc(formattedErrorMessage, level)
    end

    result = callback()
  end

  return result
end

function Utils.requestAudioBank(audioBank, timeout)
  return Utils.waitFor(function()
    if RequestScriptAudioBank(audioBank, false) then
      return audioBank
    end
  end, string.format([[
failed to load audiobank '%s' - this may be caused by
- too many loaded assets
- oversized, invalid, or corrupted assets]], audioBank), timeout or 30000)
end

function Utils.streamingRequest(requestFunc, hasLoadedFunc, assetType, assetName, timeout, ...)
  if hasLoadedFunc(assetName) then
    return assetName
  end

  requestFunc(assetName, ...)

  return Utils.waitFor(function()
    if hasLoadedFunc(assetName) then
      return assetName
    end
  end, string.format([[
failed to load %s '%s' - this may be caused by
- too many loaded assets
- oversized, invalid, or corrupted assets]], assetType, assetName), timeout or 30000)
end

function Utils.requestAnimDict(animDict, timeout)
  if HasAnimDictLoaded(animDict) then
    return animDict
  end

  if type(animDict) ~= "string" then
    error("expected animDict to have type 'string' (received " .. type(animDict) .. ")")
  end

  if not DoesAnimDictExist(animDict) then
    error("attempted to load invalid animDict '" .. animDict .. "'")
  end

  return Utils.streamingRequest(RequestAnimDict, HasAnimDictLoaded, "animDict", animDict, timeout)
end

function Utils.requestModel(model, timeout)
  if type(model) ~= "number" then
    model = joaat(model)
  end

  if HasModelLoaded(model) then
    return model
  end

  if not IsModelValid(model) then
    if not IsModelInCdimage(model) then
      error("attempted to load invalid model '" .. model .. "'")
    end
  end

  return Utils.streamingRequest(RequestModel, HasModelLoaded, "model", model, timeout)
end

local nuiFocus = IsNuiFocusKeepingInput()

function Utils.setNuiFocus(keepInput, disablePauseMenu)
  nuiFocus = IsNuiFocusKeepingInput()
  SetNuiFocus(true, not disablePauseMenu)
  SetNuiFocusKeepInput(keepInput)
end

function Utils.resetNuiFocus()
  SetNuiFocus(false, false)
  SetNuiFocusKeepInput(nuiFocus)
end

local Keybinds = {}

local KeybindDefaults = {
  disabled = false,
  isPressed = false,
  defaultKey = "",
  defaultMapper = "keyboard"
}

function KeybindDefaults:__index(key)
  if key == "currentKey" then
    local currentKey = self:getCurrentKey()
    if currentKey then
      return currentKey
    end
  end
  return KeybindDefaults[key]
end

function KeybindDefaults:getCurrentKey()
  return GetControlInstructionalButton(0, self.hash, true):sub(3)
end

function KeybindDefaults:isControlPressed()
  return self.isPressed
end

function KeybindDefaults:disable(isDisabled)
  self.disabled = isDisabled
end

function Utils.addKeybind(keybind)
  local hashString = "+" .. keybind.name
  keybind.hash = joaat(hashString) | 2147483648

  Keybinds[keybind.name] = setmetatable(keybind, KeybindDefaults)

  RegisterCommand("+" .. keybind.name, function()
    if not keybind.disabled and not IsPauseMenuActive() then
      keybind.isPressed = true
      if keybind.onPressed then
        keybind.onPressed(keybind)
      end
    end
  end)

  RegisterCommand("-" .. keybind.name, function()
    if not keybind.disabled and not IsPauseMenuActive() then
      keybind.isPressed = false
      if keybind.onReleased then
        keybind.onReleased(keybind)
      end
    end
  end)

  RegisterKeyMapping("+" .. keybind.name, keybind.description, keybind.defaultMapper, keybind.defaultKey)

  if keybind.secondaryKey then
    local secondaryMapper = keybind.secondaryMapper or keybind.defaultMapper
    RegisterKeyMapping("~!+" .. keybind.name, keybind.description, secondaryMapper, keybind.secondaryKey)
  end

  SetTimeout(500, function()
    TriggerEvent("chat:removeSuggestion", "/+" .. keybind.name)
    TriggerEvent("chat:removeSuggestion", "/-" .. keybind.name)
  end)

  return keybind
end

function Utils.sanitizeItems(items)
  local sanitizedItems = {}
  for i = 1, #items do
    local item = items[i]
    local sanitizedItem = {}
    for k, v in pairs(item) do
      if type(v) ~= "function" and k ~= "onSelect" then
        sanitizedItem[k] = v
      end
    end
    sanitizedItems[#sanitizedItems + 1] = sanitizedItem
  end
  return sanitizedItems
end