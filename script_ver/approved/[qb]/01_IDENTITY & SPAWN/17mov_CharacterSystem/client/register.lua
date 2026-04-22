Register.ActiveSlot = nil
Register.LastEnteredGender = "male"

function Register.Enter()
  if Selector.Active then
    Functions.SendNuiMessage("ToggleSelector", { state = false })
    if Selector.ActiveCharacter ~= nil then
      DoScreenFadeOut(100)
      Wait(100)
      Selector.ActiveCharacter = nil
      Wait(100)
      DoScreenFadeIn(100)
    end
  end

  SetNuiFocus(true, true)

  local countriesData = nil
  if Config.Framework == "QBCore" then
    countriesData = Register.Countries
  end

  Functions.SendNuiMessage("ToggleRegister", {
    state = true,
    countries = countriesData,
    validation = Register.Validation
  })
end

function Register.Exit()
  Functions.SendNuiMessage("ToggleRegister", { state = false })
  if Selector.Active then
    Functions.SendNuiMessage("ToggleSelector", {
      state = true,
      characters = Selector.Characters
    })
  else
    SetNuiFocus(false, false)
  end
end

RegisterNUICallback("OpenRegister", function(data, cb)
  if Register.Enable then
    Register.ActiveSlot = data.id
    Register.Enter()
  else
    if Register.OpenCustom then
      Register.OpenCustom(data.id)
    end
  end
  cb({})
end)

RegisterNUICallback("CloseRegister", function(data, cb)
  Register.Exit()
  cb({})
end)

RegisterNUICallback("CreateCharacter", function(data, cb)
  data.id = Register.ActiveSlot
  Register.LastEnteredGender = data.isMale and "male" or "female"

  Functions.TriggerServerCallback("17mov_CharacterSystem:CreateCharacter", function(response)
    if response == true then
      cb({})
      DoScreenFadeOut(100)
      Selector.Exit()
      Register.Exit()
    else
      cb({ message = response })
    end
  end, data)
end)