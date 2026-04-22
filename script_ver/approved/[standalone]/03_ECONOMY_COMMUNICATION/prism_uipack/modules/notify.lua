local Utils = {}

local function GetResourceKvpOrDefault(kvpGetter, kvpName, defaultValue)
  local success, result = pcall(kvpGetter, kvpName)
  if not success then
    DeleteResourceKvp(kvpName)
    return defaultValue
  end

  result = result or defaultValue
  if not result then
    result = defaultValue
  end

  return result
end

local Config = {}
Config.default_locale = GetConvar("ox:locale", "en")
Config.notification_position = GetResourceKvpOrDefault(GetResourceKvpString, "notification_position", "top-right")
Config.notification_audio = 1 == GetResourceKvpOrDefault(GetResourceKvpInt, "notification_audio", 1)

local function Notify(notificationData)
  if notificationData then
    if notificationData.type then
      if "inform" == notificationData.type then
        notificationData.type = "info"
      end
    end
  end

  local playSound = Config.notification_audio
  if playSound then
    notificationData.sound = notificationData.sound
  end
  notificationData.sound = nil

  SendNUIMessage({
    action = "notification",
    data = notificationData
  })

  if not playSound then
    return
  end

  local hasAudioBank = notificationData.sound and notificationData.sound.bank ~= nil
  if hasAudioBank then
    Utils.requestAudioBank(notificationData.sound.bank)
  end

  local soundId = GetSoundId()
  PlaySoundFrontend(soundId, notificationData.sound.name, notificationData.sound.set, true)
  ReleaseSoundId(soundId)

  if hasAudioBank then
    ReleaseNamedScriptAudioBank(notificationData.sound.bank)
  end
end

Notify = Notify