local prop = nil
local particle = nil

function StopAnim()
  if DoesEntityExist(prop) then
    DeleteEntity(prop)
  end
  if DoesParticleFxLoopedExist(particle) then
    StopParticleFxLooped(particle, false)
  end
  ClearPedTasks(PlayerPedId())
end

function FertilizerAnim(duration)
  ClearPedTasksImmediately(PlayerPedId())
  PlayAnim("weapons@misc@jerrycan@", "fire")
  prop = AttachObject(-782390768, 57005, {
    vector3(0.18, 0.13, -0.26),
    vector3(-165.869385, -11.212276, -32.945301)
  })
  CreateThread(function()
    Wait(500)
    local iterations = duration / 3000
    for i = 1, iterations do
      particle = ParticleEffect("scr_fbi3", "scr_fbi3_dirty_water_pour", 2.5, 3000, prop, vector3(0.0, 0.0, 0.0))
    end
  end)
end

function HarvestAnim()
  PlayAnim("mp_arresting", "a_uncuff")
end

function WateringAnim(duration)
  ClearPedTasksImmediately(PlayerPedId())
  PlayAnim("weapons@misc@jerrycan@", "fire")
  prop = AttachObject(-1644950477, 57005, {
    vector3(0.18, 0.13, -0.12),
    vector3(-165.869385, -11.212276, -32.945301)
  })
  CreateThread(function()
    local iterations = duration / 3000
    for i = 1, iterations do
      particle = ParticleEffect("core", "ent_sht_water", 1.0, 3000, prop, vector3(0.34, 0.0, 0.25))
    end
  end)
end

function SprayAnim(duration)
  ClearPedTasksImmediately(PlayerPedId())
  PlayAnim("weapons@first_person@aim_rng@generic@projectile@shared@core", "idlerng_med")
  prop = AttachObject(636509358, 28422, {
    vector3(0.05, -0.1, -0.05),
    vector3(-90.0, 0.0, 0.0)
  })
  CreateThread(function()
    Wait(700)
    local iterations = duration / 1500
    for i = 1, iterations do
      particle = ParticleEffect("core", "ent_dst_gen_water_spray", 1.0, 1500, prop, vector3(0.3, 0.0, 0.0))
    end
  end)
end

function ParticleEffect(assetName, effectName, scale, duration, entity, offset)
  if DoesParticleFxLoopedExist(particle) then
    StopParticleFxLooped(particle, false)
  end
  if not DoesEntityExist(entity) then
    return false
  end
  RequestNamedPtfxAsset(assetName)
  while not HasNamedPtfxAssetLoaded(assetName) do
    Citizen.Wait(0)
  end
  UseParticleFxAssetNextCall(assetName)
  local particleHandle = StartParticleFxLoopedOnEntity(effectName, entity, offset, 0.0, 0.0, 0.0, scale, false, false,
    false)
  SetParticleFxLoopedColour(particleHandle, 0, 255, 0, 0)
  Wait(duration)
  StopParticleFxLooped(particleHandle, false)
  return particleHandle
end

function LoadAnim(animDict)
  RequestAnimDict(animDict)
  while not HasAnimDictLoaded(animDict) do
    Citizen.Wait(1)
  end
end

function PlayAnim(animDict, animName)
  LoadAnim(animDict)
  TaskPlayAnim(PlayerPedId(), animDict, animName, 2.0, 2.0, -1, 1, 0, false, false, false)
end

function LoadModel(modelHash)
  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do
    Wait(0)
  end
end

function AttachObject(modelHash, boneId, offsets)
  local playerPed = PlayerPedId()
  local playerCoords = GetEntityCoords(playerPed)

  if DoesEntityExist(prop) then
    DeleteEntity(prop)
  end

  LoadModel(modelHash)
  local objectHandle = CreateObject(modelHash, playerCoords.x, playerCoords.y, playerCoords.z + 0.2, true, true, true)
  SetEntityCollision(objectHandle, false, false)
  AttachEntityToEntity(
    objectHandle, playerPed, GetPedBoneIndex(playerPed, boneId),
    offsets[1].x, offsets[1].y, offsets[1].z,
    offsets[2].x, offsets[2].y, offsets[2].z,
    true, true, false, true, 1, true
  )
  SetModelAsNoLongerNeeded(modelHash)
  return objectHandle
end

AddEventHandler("onResourceStop", function(resourceName)
  if resourceName == GetCurrentResourceName() then
    StopAnim()
  end
end)
