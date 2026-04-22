local ContextMenus = {}
local CurrentContextMenuId = nil

local function CloseContext(callback, shouldCallOnExit, shouldCallOnClose)
  if callback then
    local success = 1
    callback(success)
  end

  Utils.resetNuiFocus()

  if not CurrentContextMenuId then
    return
  end

  if shouldCallOnExit or shouldCallOnClose then
    local currentMenu = ContextMenus[CurrentContextMenuId]
    if currentMenu and currentMenu.onExit then
      currentMenu.onExit()
    end
  end

  if not shouldCallOnExit then
    SendNUIMessage({ action = "hideContext" })
  end

  CurrentContextMenuId = nil
end

local function ShowContext(contextId)
  local contextMenu = ContextMenus[contextId]
  if not contextMenu then
    error("No context menu of such id found.")
  end

  CurrentContextMenuId = contextId

  Utils.setNuiFocus(false)

  SendNUIMessage(json.encode({
    action = "showContext",
    data = {
      title = contextMenu.title,
      subtitle = contextMenu.subtitle,
      titleIcon = contextMenu.titleIcon,
      sectionTitle = contextMenu.sectionTitle,
      sectionIcon = contextMenu.sectionIcon,
      footerLabel = contextMenu.footerLabel,
      canClose = contextMenu.canClose,
      menu = contextMenu.menu,
      options = Utils.sanitizeItems(contextMenu.options),
    },
  }, { sort_keys = true }))
end

ShowContext = ShowContext

local function RegisterContext(contextData)
  for key, value in pairs(contextData) do
    local valueType = type(key)
    if "number" == valueType then
      ContextMenus[value.id] = value
    else
      ContextMenus[contextData.id] = contextData
      break
    end
  end
end

RegisterContext = RegisterContext

local function GetOpenContextMenu()
  return CurrentContextMenuId
end

GetOpenContextMenu = GetOpenContextMenu

local function HideContext(shouldCallOnClose)
  CloseContext(nil, nil, shouldCallOnClose)
end

HideContext = HideContext

RegisterNUICallback("openContext", function(data, callback)
  if data.back then
    local currentMenu = ContextMenus[CurrentContextMenuId]
    if currentMenu and currentMenu.onBack then
      currentMenu.onBack()
    end
  end

  callback(1)
  ShowContext(data.id)
end)

RegisterNUICallback("clickContext", function(optionId, callback)
  callback(1)

  local optionIndex = tonumber(optionId)
  if type(optionIndex) == "number" then
    optionIndex = math.tointeger(optionId)
    optionId = optionIndex
  else
    optionIndex = tonumber(optionId)
    if optionIndex then
      optionId = optionId + 1
    end
  end

  local currentMenu = ContextMenus[CurrentContextMenuId]
  local selectedOption = currentMenu.options[optionId]

  if not selectedOption.event and not selectedOption.serverEvent and not selectedOption.onSelect then
    return
  end

  CurrentContextMenuId = nil

  SendNUIMessage({ action = "hideContext" })
  Utils.resetNuiFocus()

  if selectedOption.onSelect then
    selectedOption.onSelect(selectedOption.args)
  end

  if selectedOption.event then
    TriggerEvent(selectedOption.event, selectedOption.args)
  end

  if selectedOption.serverEvent then
    TriggerServerEvent(selectedOption.serverEvent, selectedOption.args)
  end
end)

RegisterNUICallback("closeContext", CloseContext)