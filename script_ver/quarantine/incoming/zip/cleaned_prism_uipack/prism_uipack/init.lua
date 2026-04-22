local prismExports = exports
local lib = {}

local function Notify(text)
  prismExports.prism_uipack.Notify(prismExports.prism_uipack, text)
end
lib.notify = Notify

local function ShowTextUI(text, time)
  prismExports.prism_uipack.ShowTextUI(prismExports.prism_uipack, text, time)
end
lib.showTextUI = ShowTextUI

local function HideTextUI()
  prismExports.prism_uipack.HideTextUI(prismExports.prism_uipack)
end
lib.hideTextUI = HideTextUI

local function IsTextUIOpen()
  return prismExports.prism_uipack.IsTextUIOpen(prismExports.prism_uipack)
end
lib.isTextUIOpen = IsTextUIOpen

local function ProgressBar(data)
  return prismExports.prism_uipack.ProgressBar(prismExports.prism_uipack, data)
end
lib.progressBar = ProgressBar

local function ProgressCircle(data)
  data.variant = "secondary"
  return prismExports.prism_uipack.ProgressBar(prismExports.prism_uipack, data)
end
lib.progressCircle = ProgressCircle

local function ProgressActive()
  return prismExports.prism_uipack.ProgressActive(prismExports.prism_uipack)
end
lib.progressActive = ProgressActive

local function CancelProgress()
  prismExports.prism_uipack.CancelProgress(prismExports.prism_uipack)
end
lib.cancelProgress = CancelProgress

local function AddRadialItem(data)
  prismExports.prism_uipack.AddRadialItem(prismExports.prism_uipack, data)
end
lib.addRadialItem = AddRadialItem

local function RemoveRadialItem(id)
  prismExports.prism_uipack.RemoveRadialItem(prismExports.prism_uipack, id)
end
lib.removeRadialItem = RemoveRadialItem

local function ClearRadialItems()
  prismExports.prism_uipack.ClearRadialItems(prismExports.prism_uipack)
end
lib.clearRadialItems = ClearRadialItems

local function RegisterRadial(data)
  prismExports.prism_uipack.RegisterRadial(prismExports.prism_uipack, data)
end
lib.registerRadial = RegisterRadial

local function HideRadial()
  prismExports.prism_uipack.HideRadial(prismExports.prism_uipack)
end
lib.hideRadial = HideRadial

local function DisableRadial(bool)
  prismExports.prism_uipack.DisableRadial(prismExports.prism_uipack, bool)
end
lib.disableRadial = DisableRadial

local function GetCurrentRadialId()
  return prismExports.prism_uipack.GetCurrentRadialId(prismExports.prism_uipack)
end
lib.getCurrentRadialId = GetCurrentRadialId

local function SkillCheck(successChance, speed, size)
  return prismExports.prism_uipack.SkillCheck(prismExports.prism_uipack, successChance, speed, size)
end
lib.skillCheck = SkillCheck

local function SkillCheckActive()
  return prismExports.prism_uipack.SkillCheckActive(prismExports.prism_uipack)
end
lib.skillCheckActive = SkillCheckActive

local function CancelSkillCheck()
  return prismExports.prism_uipack.CancelSkillCheck(prismExports.prism_uipack)
end
lib.cancelSkillCheck = CancelSkillCheck

local function InputDialog(title, inputs, cb)
  return prismExports.prism_uipack.InputDialog(prismExports.prism_uipack, title, inputs, cb)
end
lib.inputDialog = InputDialog

local function CloseInputDialog()
  prismExports.prism_uipack.CloseInputDialog(prismExports.prism_uipack)
end
lib.closeInputDialog = CloseInputDialog

local function RegisterContext(data)
  prismExports.prism_uipack.RegisterContext(prismExports.prism_uipack, data)
end
lib.registerContext = RegisterContext

local function ShowContext(id)
  prismExports.prism_uipack.ShowContext(prismExports.prism_uipack, id)
end
lib.showContext = ShowContext

local function HideContext(id)
  prismExports.prism_uipack.HideContext(prismExports.prism_uipack, id)
end
lib.hideContext = HideContext

local function GetOpenContextMenu()
  return prismExports.prism_uipack.GetOpenContextMenu(prismExports.prism_uipack)
end
lib.getOpenContextMenu = GetOpenContextMenu

local function AlertDialog(data)
  return prismExports.prism_uipack.AlertDialog(prismExports.prism_uipack, data)
end
lib.alertDialog = AlertDialog

local function CloseAlertDialog()
  prismExports.prism_uipack.CloseAlertDialog(prismExports.prism_uipack)
end
lib.closeAlertDialog = CloseAlertDialog

local function RegisterMenu(id, data)
  prismExports.prism_uipack.RegisterMenu(prismExports.prism_uipack, id, data)
end
lib.registerMenu = RegisterMenu

local function ShowMenu(id)
  prismExports.prism_uipack.ShowMenu(prismExports.prism_uipack, id)
end
lib.showMenu = ShowMenu

local function HideMenu(id)
  prismExports.prism_uipack.HideMenu(prismExports.prism_uipack, id)
end
lib.hideMenu = HideMenu

local function GetOpenMenu()
  return prismExports.prism_uipack.GetOpenMenu(prismExports.prism_uipack)
end
lib.getOpenMenu = GetOpenMenu

local function SetMenuOptions(id, index, options)
  prismExports.prism_uipack.SetMenuOptions(prismExports.prism_uipack, id, index, options)
end
lib.setMenuOptions = SetMenuOptions

local overrideCount = 0
for key, value in pairs(lib) do
  local success, err = pcall(function()
    lib[key] = value
    overrideCount = overrideCount + 1
  end)
  if not success then
    print(("[prism_uipack] Failed to override lib.%s: %s"):format(key, err))
  end
end

print(("[prism_uipack] Successfully initialized %d/%d function overrides"):format(overrideCount, #lib))

local newExports = {}
local mt = {}
local callMt = {}

function callMt:__call(name, ...)
  return prismExports(name, ...)
end

mt.__call = callMt

function mt:__index(table, key)
  if "ox_lib" == key then
    local proxy = {}
    local proxyMt = {}
    function proxyMt:__index(tableName, k)
      local libFunc = lib[k]
      if libFunc then
        return function(...)
          return libFunc(...)
        end
      end
      return prismExports.ox_lib[k]
    end
    setmetatable(proxy, proxyMt)
    return proxy
  end
  return prismExports[key]
end

setmetatable(newExports, mt)
exports = newExports