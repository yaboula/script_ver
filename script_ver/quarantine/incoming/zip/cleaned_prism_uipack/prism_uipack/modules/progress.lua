local progressBarActive
local DisableControlActionFunc = DisableControlAction
local DisablePlayerFiringFunc = DisablePlayerFiring
local LocalPlayerState = LocalPlayer.state
local attachedProps = {}

local function AttachPropToPed(ped, propData)
  Utils.requestModel(propData.model)
  local pedCoords = GetEntityCoords(ped)
  local object = CreateObject(
    propData.model,
    pedCoords.x,
    pedCoords.y,
    pedCoords.z + 0.95,
    false,
    false,
    false
  )
  AttachEntityToEntity(
    object,
    ped,
    GetPedBoneIndex(ped, propData.bone or 60309),
    propData.pos.x,
    propData.pos.y,
    propData.pos.z,
    propData.rot.x,
    propData.rot.y,
    propData.rot.z,
    true,
    true,
    false,
    true,
    propData.rotOrder or 0,
    true
  )
  SetModelAsNoLongerNeeded(propData.model)
  return object
end

local function ShouldCancelProgress(options)
  local playerPed = PlayerPedId()

  if not options.useWhileDead and IsEntityDead(playerPed) then
    return true
  end

  if not options.allowRagdoll and IsPedRagdoll(playerPed) then
    return true
  end

  if not options.allowCuffed and IsPedCuffed(playerPed) then
    return true
  end

  if not options.allowFalling and IsPedFalling(playerPed) then
    return true
  end

  if not options.allowSwimming and IsPedSwimming(playerPed) then
    return true
  end
end

local Input = {}
Input.INPUT_LOOK_LR = 1
Input.INPUT_LOOK_UD = 2
Input.INPUT_SPRINT = 21
Input.INPUT_AIM = 25
Input.INPUT_MOVE_LR = 30
Input.INPUT_MOVE_UD = 31
Input.INPUT_DUCK = 36
Input.INPUT_VEH_MOVE_LEFT_ONLY = 63
Input.INPUT_VEH_MOVE_RIGHT_ONLY = 64
Input.INPUT_VEH_ACCELERATE = 71
Input.INPUT_VEH_BRAKE = 72
Input.INPUT_VEH_EXIT = 75
Input.INPUT_VEH_MOUSE_CONTROL_OVERRIDE = 106

local function RunProgressBar(options)
  LocalPlayerState.invBusy = true
  progressBarActive = options

  local animData = options.anim
  if animData then
    if animData.dict then
      Utils.requestAnimDict(animData.dict)
      TaskPlayAnim(
        PlayerPedId(),
        animData.dict,
        animData.clip,
        animData.blendIn or 3.0,
        animData.blendOut or 1.0,
        animData.duration or -1,
        animData.flag or 49,
        animData.playbackRate or 0,
        animData.lockX,
        animData.lockY,
        animData.lockZ
      )
      RemoveAnimDict(animData.dict)
    elseif animData.scenario then
      TaskStartScenarioInPlace(PlayerPedId(), animData.scenario, 0, options.anim.playEnter == nil or options.anim.playEnter)
    end
  end

  if options.prop then
    LocalPlayerState.set("prism:progressProps", options.prop, true)
  end

  local disableControls = options.disable
  local startTime = GetGameTimer()
  local playerId = PlayerId()

  while true do
    if not progressBarActive then
      break
    end

    if disableControls then
      if disableControls.mouse then
        DisableControlActionFunc(0, Input.INPUT_LOOK_LR, true)
        DisableControlActionFunc(0, Input.INPUT_LOOK_UD, true)
        DisableControlActionFunc(0, Input.INPUT_VEH_MOUSE_CONTROL_OVERRIDE, true)
      end

      if disableControls.move then
        DisableControlActionFunc(0, Input.INPUT_SPRINT, true)
        DisableControlActionFunc(0, Input.INPUT_MOVE_LR, true)
        DisableControlActionFunc(0, Input.INPUT_MOVE_UD, true)
        DisableControlActionFunc(0, Input.INPUT_DUCK, true)
      end

      if disableControls.sprint then
        if not disableControls.move then
          DisableControlActionFunc(0, Input.INPUT_SPRINT, true)
        end
      end

      if disableControls.car then
        DisableControlActionFunc(0, Input.INPUT_VEH_MOVE_LEFT_ONLY, true)
        DisableControlActionFunc(0, Input.INPUT_VEH_MOVE_RIGHT_ONLY, true)
        DisableControlActionFunc(0, Input.INPUT_VEH_ACCELERATE, true)
        DisableControlActionFunc(0, Input.INPUT_VEH_BRAKE, true)
        DisableControlActionFunc(0, Input.INPUT_VEH_EXIT, true)
      end

      if disableControls.combat then
        DisableControlActionFunc(0, Input.INPUT_AIM, true)
        DisablePlayerFiringFunc(playerId, true)
      end
    end

    if ShouldCancelProgress(progressBarActive) then
      progressBarActive = false
    end

    Wait(0)
  end

  if options.prop then
    LocalPlayerState.set("prism:progressProps", nil, true)
  end

  if animData then
    if animData.dict then
      StopAnimTask(PlayerPedId(), animData.dict, animData.clip, 1.0)
      Wait(0)
    else
      ClearPedTasks(PlayerPedId())
    end
  end

  LocalPlayerState.invBusy = false

  local elapsedTime = GetGameTimer() - startTime
  local hasTimedOut = false ~= elapsedTime and elapsedTime

  if false ~= progressBarActive then
    if not (elapsedTime <= options.duration) then
      goto continue
    end
  end

  SendNUIMessage({ action = "progressCancel" })
  return false

  ::continue::
  return true
end

local function StartProgressBar(options)
  while true do
    if nil == progressBarActive then
      break
    end
    Wait(0)
  end

  if not ShouldCancelProgress(options) then
    SendNUIMessage({
      action = "progress",
      data = {
        label = options.label,
        duration = options.duration,
        position = options.position,
        variant = options.variant,
        canCancel = options.canCancel,
      },
    })
    return RunProgressBar(options)
  end
end

ProgressBar = StartProgressBar

local function StartProgressCircle(options)
  ProgressBar(options)
end

ProgressCircle = StartProgressCircle

local function CancelActiveProgress()
  if not progressBarActive then
    error("No progress bar is active")
  end
  progressBarActive = false
end

CancelProgress = CancelActiveProgress

local function IsProgressActive()
  if progressBarActive then
    return true
  end
  return false
end

ProgressActive = IsProgressActive

local RegisterNUICallbackFunc = RegisterNUICallback
local PROGRESS_COMPLETE_EVENT = "progressComplete"

local function OnProgressComplete(data, cb)
  cb(1)
  progressBarActive = nil
end

RegisterNUICallbackFunc(PROGRESS_COMPLETE_EVENT, OnProgressComplete)

local RegisterCommandFunc = RegisterCommand
local CANCEL_PROGRESS_COMMAND = "cancelprogress_prism"

local function CancelProgressCommand()
  if progressBarActive then
    if progressBarActive.canCancel then
      progressBarActive = false
    end
  end
end

local restricted = false
RegisterCommandFunc(CANCEL_PROGRESS_COMMAND, CancelProgressCommand, restricted)

local RegisterKeyMappingFunc = RegisterKeyMapping
local CANCEL_PROGRESS_KEYBIND = "cancelprogress_prism"
local CANCEL_PROGRESS_DESCRIPTION = "Cancel Progressbar"
local INPUT_GROUP = "keyboard"
local GetConvarFunc = GetConvar
local CANCEL_KEY_CONVAR = "prism:progressCancelKey"
local DEFAULT_CANCEL_KEY = "X"
local cancelKey = GetConvarFunc(CANCEL_KEY_CONVAR, DEFAULT_CANCEL_KEY)

RegisterKeyMappingFunc(
  CANCEL_PROGRESS_KEYBIND,
  CANCEL_PROGRESS_DESCRIPTION,
  INPUT_GROUP,
  cancelKey
)

local function ClearAttachedProps(serverId)
  local props = attachedProps[serverId]
  if not props then
    return
  end

  for i = 1, #props do
    local prop = props[i]
    if DoesEntityExist(prop) then
      DeleteEntity(prop)
    end
  end

  attachedProps[serverId] = nil
end

local RegisterNetEventFunc = RegisterNetEvent
local ON_PLAYER_DROPPED_EVENT = "onPlayerDropped"

local function OnPlayerDropped(playerId)
  ClearAttachedProps(playerId)
end

RegisterNetEventFunc(ON_PLAYER_DROPPED_EVENT, OnPlayerDropped)

local AddStateBagChangeHandlerFunc = AddStateBagChangeHandler
local PROGRESS_PROPS_BAG = "prism:progressProps"
local filter = nil

local function OnProgressPropsChanged(bagName, key, oldValue, newValue, isResetted)
  if isResetted then
    return
  end

  local player = GetPlayerFromStateBagName(bagName)
  if 0 == player then
    return
  end

  local ped = GetPlayerPed(player)
  local serverId = GetPlayerServerId(player)

  if not newValue then
    ClearAttachedProps(serverId)
    return
  end

  attachedProps[serverId] = {}
  local propsList = attachedProps[serverId]

  if newValue.model then
    local newProp = AttachPropToPed(ped, newValue)
    propsList[#propsList + 1] = newProp
  else
    for i = 1, #newValue do
      local propData = newValue[i]
      if propData then
        local newProp = AttachPropToPed(ped, propData)
        propsList[#propsList + 1] = newProp
      end
    end
  end
end

AddStateBagChangeHandlerFunc(PROGRESS_PROPS_BAG, filter, OnProgressPropsChanged)