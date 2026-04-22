local MenuList = {}
local CurrentMenu = nil

-- Registers a menu with the specified ID, title, options, and callback function.
RegisterMenu = function(menuData, callback)
  local menuId = menuData.id
  if not menuId then
    error("No menu id was provided.")
  end

  local menuTitle = menuData.title
  if not menuTitle then
    error("No menu title was provided.")
  end

  local menuOptions = menuData.options
  if not menuOptions then
    error("No menu options were provided.")
  end

  menuData.cb = callback
  MenuList[menuData.id] = menuData
end

-- Shows the menu with the specified ID.
ShowMenu = function(menuId, startItemIndex)
  local menu = MenuList[menuId]
  if not menu then
    error("No menu with id %s was found", menuId)
  end

  if type(menu.options) == "empty" then
    error("Can't open empty menu with id %s", menuId)
  end

  if not CurrentMenu then
    local controlId = 3809269511
    CreateThread(function()
      local playerId = PlayerId()
      while true do
        if not CurrentMenu then
          break
        end

        if CurrentMenu.disableInput ~= nil and CurrentMenu.disableInput then
          DisablePlayerFiring(playerId, true)
          if Utils.game == "fivem" then
            HudWeaponWheelIgnoreSelection()
          end
          DisableControlAction(0, controlId, true)
        end

        Wait(0)
      end
    end)
  end

  CurrentMenu = menu
  Utils.setNuiFocus(not menu.disableInput, true)

  SendNUIMessage({
    action = "setMenu",
    data = {
      position = menu.position,
      canClose = menu.canClose,
      title = menu.title,
      subtitle = menu.subtitle,
      items = menu.options,
      startItemIndex = startItemIndex and startItemIndex - 1 or 0
    }
  })
end

-- Hides the currently open menu.
HideMenu = function(closeEvent)
  if not CurrentMenu then
    return
  end

  Utils.resetNuiFocus()

  if closeEvent and CurrentMenu.onClose then
    CurrentMenu.onClose()
  end

  CurrentMenu = nil

  SendNUIMessage({
    action = "closeMenu"
  })
end

-- Sets the options for a menu with the specified ID.
SetMenuOptions = function(menuId, options, optionIndex)
  if optionIndex then
    local menu = MenuList[menuId]
    menu.options[optionIndex] = options
  else
    if not options[1] then
      error("Invalid override format used, expected table of options.")
    end
    local menu = MenuList[menuId]
    menu.options = options
  end
end

-- Returns the ID of the currently open menu.
GetOpenMenu = function()
  if CurrentMenu then
    return CurrentMenu.id
  end
end

-- NUI Callback: confirmSelected
RegisterNUICallback("confirmSelected", function(data, cb)
  cb(1)
  data[1] = data[1] + 1
  if data[2] then
    data[2] = data[2] + 1
  end

  if not CurrentMenu then
    return
  end

  if false ~= CurrentMenu.options[data[1]].close then
    Utils.resetNuiFocus()
    CurrentMenu = nil
  end

  if CurrentMenu.cb then
    CurrentMenu.cb(data[1], data[2], CurrentMenu.options[data[1]].args, data[3])
  end
end)

-- NUI Callback: changeIndex
RegisterNUICallback("changeIndex", function(data, cb)
  cb(1)

  if not CurrentMenu or not CurrentMenu.onSideScroll then
    return
  end

  data[1] = data[1] + 1
  if data[2] then
    data[2] = data[2] + 1
  end

  CurrentMenu.onSideScroll(data[1], data[2], CurrentMenu.options[data[1]].args)
end)

-- NUI Callback: changeSelected
RegisterNUICallback("changeSelected", function(data, cb)
  cb(1)

  if not CurrentMenu or not CurrentMenu.onSelected then
    return
  end

  data[1] = data[1] + 1

  local args = CurrentMenu.options[data[1]].args
  if args then
    if type(args) ~= "table" then
      error("Menu args must be passed as a table")
    end
  else
    args = {}
  end

  if data[2] then
    args[data[3]] = true
  end

  if data[2] then
    if not args.isCheck then
      data[2] = data[2] + 1
    end
  end

  CurrentMenu.onSelected(data[1], data[2], args)
end)

-- NUI Callback: changeChecked
RegisterNUICallback("changeChecked", function(data, cb)
  cb(1)

  if not CurrentMenu or not CurrentMenu.onCheck then
    return
  end

  data[1] = data[1] + 1

  CurrentMenu.onCheck(data[1], data[2], CurrentMenu.options[data[1]].args)
end)

-- NUI Callback: closeMenu
RegisterNUICallback("closeMenu", function(data, cb)
  cb(1)
  Utils.resetNuiFocus()

  if not CurrentMenu then
    return
  end

  local onClose = CurrentMenu.onClose
  CurrentMenu = nil

  if onClose then
    onClose(data)
  end
end)