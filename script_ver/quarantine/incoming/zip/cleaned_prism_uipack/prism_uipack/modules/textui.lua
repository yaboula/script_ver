local isTextUIOpen = false
local currentText = nil

function ShowTextUI(text, data)
  if currentText == text then
    return
  end

  if not data then
    data = {}
  end

  data.text = text
  currentText = text

  SendNUIMessage({
    action = "textUi",
    data = data
  })

  isTextUIOpen = true
end

function HideTextUI()
  SendNUIMessage({
    action = "textUiHide"
  })

  isTextUIOpen = false
  currentText = nil
end

function IsTextUIOpen()
  return isTextUIOpen, currentText
end