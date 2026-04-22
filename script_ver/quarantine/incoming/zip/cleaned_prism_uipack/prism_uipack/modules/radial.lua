local isRadialOpen = false
local radialMenus = {}
local radialItems = {}
local radialSubMenus = {}
local currentRadialMenu = nil

function OpenRadialMenu(radialId, option)
  local radialMenu = radialId or nil

  if radialId then
    radialMenu = radialMenus
    radialMenu = radialMenu[radialId]
  end

  if radialId and not radialMenu then
    local errorMessage = error
    local errorMessageText = "No radial menu with such id found."
    return errorMessage(errorMessageText)
  end

  currentRadialMenu = radialMenu

  SendNUIMessage({
    action = "openRadialMenu",
    data = false
  })

  Wait(100)

  if not isRadialOpen then
    return
  end

  local items = radialItems
  if radialMenu then
    items = radialMenu.items
    if items then
      goto continueOpening
    end
  end

  ::continueOpening::
  SendNUIMessage({
    action = "openRadialMenu",
    data = {
      items = Utils.sanitizeItems(items),
      sub = radialMenu ~= nil and true or nil,
      option = option
    }
  })
end

function HandleRadialClick(selectedId)
  if not isRadialOpen then
    return
  end

  if currentRadialMenu and selectedId then
    if selectedId == currentRadialMenu.id then
      return OpenRadialMenu(selectedId)
    else
      for i = 1, #radialSubMenus, 1 do
        local subMenu = radialSubMenus[i]
        if subMenu.id == selectedId then
          local radialMenu = radialMenus
          radialMenu = radialMenu[subMenu.id]

          for j = 1, #radialMenu.items, 1 do
            local item = radialMenu.items
            item = item[j]
            if item.menu == currentRadialMenu.id then
              return
            end
          end

          currentRadialMenu = radialMenu

          for k = #radialSubMenus, i, -1 do
            radialSubMenus[k] = nil
          end

          return OpenRadialMenu(currentRadialMenu.id)
        end
      end
    end
    return
  end

  table.wipe(radialSubMenus)
  OpenRadialMenu()
end

function RegisterRadial(radialData)
  local radialId = radialData.id
  radialMenus[radialId] = radialData
  radialData.resource = GetInvokingResource()

  if currentRadialMenu then
    HandleRadialClick(radialData.id)
  end
end

RegisterRadial = RegisterRadial

function GetCurrentRadialId()
  if currentRadialMenu then
    return currentRadialMenu.id
  end
  return nil
end

GetCurrentRadialId = GetCurrentRadialId

function HideRadial()
  if not isRadialOpen then
    return
  end

  SendNUIMessage({
    action = "openRadialMenu",
    data = false
  })

  Utils.resetNuiFocus()
  table.wipe(radialSubMenus)
  isRadialOpen = false
  currentRadialMenu = nil
end

HideRadial = HideRadial

function AddRadialItem(items)
  local itemCount = #radialItems
  local resource = GetInvokingResource()

  if type(items) ~= "table" or not items then
    items = {}
    items[1] = items
  end

  for i = 1, #items, 1 do
    local item = items[i]
    item.resource = resource

    if itemCount == 0 then
      itemCount = itemCount + 1
      radialItems[itemCount] = item
    else
      for j = 1, itemCount, 1 do
        local existingItem = radialItems
        existingItem = existingItem[j]
        if existingItem.id == item.id then
          radialItems[j] = item
          break
        end

        if j == itemCount then
          itemCount = itemCount + 1
          radialItems[itemCount] = item
        end
      end
    end
  end

  if isRadialOpen then
    if not currentRadialMenu then
      HandleRadialClick()
    end
  end
end

AddRadialItem = AddRadialItem

function RemoveRadialItem(itemId)
  local item = nil
  for i = 1, #radialItems, 1 do
    local radialItem = radialItems
    item = radialItem[i]
    if item.id == itemId then
      table.remove(radialItems, i)
      break
    end
  end

  if not isRadialOpen then
    return
  end

  HandleRadialClick(itemId)
end

RemoveRadialItem = RemoveRadialItem

function ClearRadialItems()
  table.wipe(radialItems)

  if isRadialOpen then
    HandleRadialClick()
  end
end

ClearRadialItems = ClearRadialItems

RegisterNUICallback = RegisterNUICallback
local radialClickEvent = "radialClick"

function OnRadialClick(index, cb)
  local selectedIndex = index + 1
  local selectedItem = nil
  local radialId = nil

  if currentRadialMenu then
    selectedItem = currentRadialMenu.items[selectedIndex]
    radialId = currentRadialMenu.id
  else
    selectedItem = radialItems[selectedIndex]
  end

  local resource = nil
  if currentRadialMenu then
    resource = currentRadialMenu.resource
    if resource then
      goto continueExecution
    end
  end
  resource = selectedItem.resource

  ::continueExecution::
  if selectedItem.menu then
    local subMenuCount = #radialSubMenus
    local newSubMenuIndex = subMenuCount + 1
    radialSubMenus[newSubMenuIndex] = {
      id = currentRadialMenu and currentRadialMenu.id,
      option = selectedItem.menu
    }
    OpenRadialMenu(selectedItem.menu)
  else
    if not selectedItem.keepOpen then
      HideRadial()
    end
  end

  if selectedItem.onSelect then
    if type(selectedItem.onSelect) == "string" then
      return exports[resource][selectedItem.onSelect](0, radialId, selectedIndex)
    end
    selectedItem.onSelect(radialId, selectedIndex)
  end
end

RegisterNUICallback(radialClickEvent, OnRadialClick)

RegisterNUICallback = RegisterNUICallback
local radialBackEvent = "radialBack"

function OnRadialBack(data, cb)
  local subMenuCount = #radialSubMenus
  local hasSubMenus = subMenuCount > 0 and radialSubMenus
  if not hasSubMenus then
    return
  end

  local lastSubMenu = radialSubMenus[subMenuCount]
  radialSubMenus[subMenuCount] = nil

  if lastSubMenu.id then
    return OpenRadialMenu(lastSubMenu.id, lastSubMenu.option)
  end

  currentRadialMenu = nil
  SendNUIMessage({
    action = "openRadialMenu",
    data = false
  })

  Wait(100)

  if not isRadialOpen then
    return
  end

  SendNUIMessage({
    action = "openRadialMenu",
    data = {
      items = Utils.sanitizeItems(radialItems),
      option = lastSubMenu.option
    }
  })
end

RegisterNUICallback(radialBackEvent, OnRadialBack)

RegisterNUICallback = RegisterNUICallback
local radialCloseEvent = "radialClose"

function OnRadialClose(data, cb)
  if not isRadialOpen then
    return
  end

  Utils.resetNuiFocus()
  isRadialOpen = false
  currentRadialMenu = nil
end

RegisterNUICallback(radialCloseEvent, OnRadialClose)

RegisterNUICallback = RegisterNUICallback
local radialTransitionEvent = "radialTransition"

function OnRadialTransition(data, cb)
  Wait(100)

  if not isRadialOpen then
    return cb(false)
  end

  return cb(true)
end

RegisterNUICallback(radialTransitionEvent, OnRadialTransition)

local isRadialDisabled = false

function DisableRadial(isDisabled)
  isRadialDisabled = isDisabled

  if isRadialOpen and isDisabled then
    HideRadial()
  end
end

disableRadial = DisableRadial

function WaitForUtils()
  local timeout = 100
  local elapsedTime = 0

  while not Utils and elapsedTime < timeout do
    Wait(100)
    elapsedTime = elapsedTime + 1
  end

  if not Utils then
    error(("Failed to load Utils dependency after \"%s\" ms."):format(timeout * 100))
  end
end

WaitForUtils()

local radialOpenKeybind = Utils.addKeybind
local keybindData = {}
keybindData.name = "prism-radial"
keybindData.description = "Open radial menu"
local radialOpenKey = GetConvar("prism:radialOpenKey", "z")
keybindData.defaultKey = radialOpenKey

function OnRadialKeyPressed()
  if isRadialDisabled then
    return
  end

  if isRadialOpen then
    return HideRadial()
  end

  if #radialItems ~= 0 then
    local isNuiFocused = IsNuiFocused()
    if not isNuiFocused then
      local isPauseMenuActive = IsPauseMenuActive()
      if not isPauseMenuActive then
        goto continueOpeningRadial
      end
    end
  end
  do return end

  ::continueOpeningRadial::
  isRadialOpen = true
  SendNUIMessage({
    action = "openRadialMenu",
    data = {
      items = Utils.sanitizeItems(radialItems)
    }
  })

  Utils.setNuiFocus(true)
  SetCursorLocation(0.5, 0.5)

  local playerId = PlayerId()
  while true do
    if not isRadialOpen then
      break
    end

    DisablePlayerFiring(playerId, true)
    DisableControlAction(0, 1, true)
    DisableControlAction(0, 2, true)
    DisableControlAction(0, 142, true)
    DisableControlAction(2, 199, true)
    DisableControlAction(2, 200, true)
    Wait(0)
  end
end

keybindData.onPressed = OnRadialKeyPressed
local radialOpenMode = GetConvar("prism:radialOpenMode", "press")

if "hold" == radialOpenMode then
  keybindData.onReleased = HideRadial
else
  keybindData.onReleased = nil
end

radialOpenKeybind(keybindData)

local addEventHandler = AddEventHandler
local onClientResourceStopEvent = "onClientResourceStop"

function OnClientResourceStop(resourceName)
  for i = #radialItems, 1, -1 do
    local item = radialItems
    item = item[i]
    if item.resource == resourceName then
      table.remove(radialItems, i)
    end
  end
end

addEventHandler(onClientResourceStopEvent, OnClientResourceStop)