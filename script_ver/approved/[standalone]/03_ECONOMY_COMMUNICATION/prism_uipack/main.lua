local RegisterNuiCallback = RegisterNuiCallback

RegisterNuiCallback("getConfig", function(data, cb)
  local callbackData = {}
  local GetConvar = GetConvar
  local primaryColorConvar = "prism:primaryColor"
  local primaryColorDefault = GetConvar("ox:primaryColor", "#BEEE11")
  local primaryColor = GetConvar(primaryColorConvar, primaryColorDefault)
  callbackData.primaryColor = primaryColor
  local GetConvarInt = GetConvarInt
  local primaryShadeConvar = "prism:primaryShade"
  local primaryShadeDefault = GetConvarInt("ox:primaryShade", 8)
  local primaryShade = GetConvarInt(primaryShadeConvar, primaryShadeDefault)
  callbackData.primaryShade = primaryShade
  local notificationDurationConvar = "prism:notificationDuration"
  local notificationDurationDefault = 3000
  local notificationDuration = GetConvarInt(notificationDurationConvar, notificationDurationDefault)
  callbackData.notificationDuration = notificationDuration
  local progressCancelKeyConvar = "prism:progressCancelKey"
  local progressCancelKeyDefault = "X"
  local progressCancelKey = GetConvar(progressCancelKeyConvar, progressCancelKeyDefault)
  callbackData.progressCancelKey = progressCancelKey
  local notificationPositionConvar = "prism:notificationPosition"
  local notificationPositionDefault = "top-right"
  local notifyPosition = GetConvar(notificationPositionConvar, notificationPositionDefault)
  callbackData.notifyPosition = notifyPosition
  local textUIPositionConvar = "prism:textUIPosition"
  local textUIPositionDefault = "center-left"
  local textUIPosition = GetConvar(textUIPositionConvar, textUIPositionDefault)
  callbackData.textUIPosition = textUIPosition
  local progressBarConvar = "prism:progressBar"
  local progressBarDefault = "primary"
  local progressVariant = GetConvar(progressBarConvar, progressBarDefault)
  callbackData.progressVariant = progressVariant
  cb(callbackData)
end)

exports("Notify", Notify)
exports("ShowTextUI", ShowTextUI)
exports("HideTextUI", HideTextUI)
exports("IsTextUIOpen", IsTextUIOpen)
exports("ProgressBar", ProgressBar)
exports("ProgressActive", ProgressActive)
exports("CancelProgress", CancelProgress)
exports("AddRadialItem", AddRadialItem)
exports("RemoveRadialItem", RemoveRadialItem)
exports("ClearRadialItems", ClearRadialItems)
exports("RegisterRadial", RegisterRadial)
exports("HideRadial", HideRadial)
exports("DisableRadial", disableRadial)
exports("GetCurrentRadialId", GetCurrentRadialId)
exports("SkillCheck", SkillCheck)
exports("SkillCheckActive", SkillCheckActive)
exports("CancelSkillCheck", CancelSkillCheck)
exports("InputDialog", InputDialog)
exports("CloseInputDialog", CloseInputDialog)
exports("RegisterContext", RegisterContext)
exports("ShowContext", ShowContext)
exports("HideContext", HideContext)
exports("GetOpenContextMenu", GetOpenContextMenu)
exports("AlertDialog", AlertDialog)
exports("CloseAlertDialog", CloseAlertDialog)
exports("RegisterMenu", RegisterMenu)
exports("ShowMenu", ShowMenu)
exports("HideMenu", HideMenu)
exports("GetOpenMenu", GetOpenMenu)
exports("SetMenuOptions", SetMenuOptions)