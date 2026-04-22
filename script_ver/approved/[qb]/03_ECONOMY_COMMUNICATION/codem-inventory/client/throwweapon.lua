local L0_1, fn_L1_1
L0_1 = Config
L0_1 = L0_1.ThrowablesSystem
if false == L0_1 then
  return
end
throwingWeapon = nil
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L1_2 = math
  L1_2 = L1_2.pi
  L1_2 = L1_2 / 180
  L2_2 = vector3
  L3_2 = math
  L3_2 = L3_2.sin
  L4_2 = A0_2.z
  L4_2 = L1_2 * L4_2
  L3_2 = L3_2(L4_2)
  L3_2 = -L3_2
  L4_2 = math
  L4_2 = L4_2.abs
  L5_2 = math
  L5_2 = L5_2.cos
  L6_2 = A0_2.x
  L6_2 = L1_2 * L6_2
  L5_2, L6_2, L7_2 = L5_2(L6_2)
  L4_2 = L4_2(L5_2, L6_2, L7_2)
  L3_2 = L3_2 * L4_2
  L4_2 = math
  L4_2 = L4_2.cos
  L5_2 = A0_2.z
  L5_2 = L1_2 * L5_2
  L4_2 = L4_2(L5_2)
  L5_2 = math
  L5_2 = L5_2.abs
  L6_2 = math
  L6_2 = L6_2.cos
  L7_2 = A0_2.x
  L7_2 = L1_2 * L7_2
  L6_2, L7_2 = L6_2(L7_2)
  L5_2 = L5_2(L6_2, L7_2)
  L4_2 = L4_2 * L5_2
  L5_2 = math
  L5_2 = L5_2.sin
  L6_2 = A0_2.x
  L6_2 = L1_2 * L6_2
  L5_2, L6_2, L7_2 = L5_2(L6_2)
  return L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
end
GetDirectionFromRotation = L0_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = 25
  L2_2 = FreezeEntityPosition
  L3_2 = A0_2
  L4_2 = false
  L2_2(L3_2, L4_2)
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = GetGameplayCamRot
  L4_2 = 2
  L3_2 = L3_2(L4_2)
  L4_2 = GetDirectionFromRotation
  L5_2 = L3_2
  L4_2 = L4_2(L5_2)
  L5_2 = SetEntityHeading
  L6_2 = A0_2
  L7_2 = L3_2.z
  L7_2 = L7_2 + 90.0
  L5_2(L6_2, L7_2)
  L5_2 = SetEntityVelocity
  L6_2 = A0_2
  L7_2 = L4_2.x
  L7_2 = L7_2 * L1_2
  L8_2 = L4_2.y
  L8_2 = L8_2 * L1_2
  L9_2 = L4_2.z
  L9_2 = L1_2 * L9_2
  L5_2(L6_2, L7_2, L8_2, L9_2)
end
PerformPhysics = L0_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = 1
  L2_2 = Config
  L2_2 = L2_2.WeaponsThrow
  L2_2 = #L2_2
  L3_2 = 1
  for L4_2 = L1_2, L2_2, L3_2 do
    L5_2 = GetHashKey
    L6_2 = Config
    L6_2 = L6_2.WeaponsThrow
    L6_2 = L6_2[L4_2]
    L5_2 = L5_2(L6_2)
    if A0_2 == L5_2 then
      L5_2 = Config
      L5_2 = L5_2.WeaponsThrow
      L5_2 = L5_2[L4_2]
      return L5_2
    end
  end
end
GetWeaponString = L0_1
function L0_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, triggerserverevent, l4_2, l7_2, l9_2, l8_2
  L0_2 = throwingWeapon
  if L0_2 then
    return
  end
  L0_2 = PlayerPedId
  L0_2 = L0_2()
  L1_2 = GetCurrentPedWeapon
  L2_2 = L0_2
  L3_2 = 1
  L1_2, L2_2 = L1_2(L2_2, L3_2)
  L3_2 = GetWeaponString
  L4_2 = L2_2
  L3_2 = L3_2(L4_2)
  if not L1_2 or not L3_2 then
    return
  end
  throwingWeapon = true
  L4_2 = CreateThread
  function L5_2()
local L0_3, getcurrentpedweapon, l0_3, L3_3, throwcurrentweapon, L5_3, L6_3, L7_3
    L0_3 = PlayAnim
    l0_2 = L0_2
    L2_3 = "weapons@projectile@grenade_str"
    L3_3 = "throw_h_fb_backward"
    L4_3 = 8.0
    L5_3 = -8.0
    L6_3 = -1
    L7_3 = 0
    L0_3(l0_2, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3)
    L0_3 = Wait
    l0_2 = 600
    L0_3(l0_2)
    L0_3 = ClearPedTasks
    l0_2 = L0_2
    L0_3(l0_2)
  end
  L4_2(L5_2)
  L4_2 = Wait
  L5_2 = 550
  L4_2(L5_2)
  L4_2 = GetOffsetFromEntityInWorldCoords
  L5_2 = L0_2
  L6_2 = 0.0
  L7_2 = 0.0
  L8_2 = 1.0
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2)
  L5_2 = GetWeaponObjectFromPed
  L6_2 = L0_2
  L7_2 = true
  L5_2 = L5_2(L6_2, L7_2)
  L6_2 = GetEntityModel
  L7_2 = L5_2
  L6_2 = L6_2(L7_2)
  L7_2 = RemoveWeaponFromPed
  L8_2 = L0_2
  L9_2 = L2_2
  L7_2(L8_2, L9_2)
  L7_2 = SetCurrentPedWeapon
  L8_2 = L0_2
  L9_2 = -1569615261
  true = true
  L7_2(L8_2, L9_2, true)
  L7_2 = DeleteEntity
  L8_2 = L5_2
  L7_2(L8_2)
  L7_2 = CreateProp
  L8_2 = L6_2
  L9_2 = L4_2.x
  l4_2 = L4_2.y
  l4_2 = L4_2.z
  true = true
  false = false
  true = true
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  L5_2 = L7_2
  L7_2 = SetEntityCoords
  L8_2 = L5_2
  L9_2 = L4_2.x
  l4_2 = L4_2.y
  l4_2 = L4_2.z
  L7_2(L8_2, L9_2, l4_2, l4_2)
  L7_2 = SetEntityHeading
  L8_2 = L5_2
  L9_2 = GetEntityHeading
  l0_2 = L0_2
  L9_2 = L9_2(L10_2)
  L9_2 = L9_2 + 90.0
  L7_2(L8_2, L9_2)
  L7_2 = PerformPhysics
  L8_2 = L5_2
  L7_2(L8_2)
  L7_2 = ClientWeaponData
  L8_2 = TriggerServerEvent
  L9_2 = "codem-inventory:removeWeaponItem"
  l7_2 = L7_2
  L8_2(L9_2, l7_2)
  ClientWeaponData = nil
  L8_2 = Citizen
  L8_2 = L8_2.Wait
  L9_2 = 4000
  L8_2(L9_2)
  L8_2 = L5_2
  L9_2 = GetEntityCoords
  l8_2 = L8_2
  L9_2 = L9_2(L10_2)
  triggerserverevent = TriggerServerEvent
  l4_2 = "codem-inventory:server:throwweapon"
  l7_2 = L7_2
  l9_2 = L9_2
  l8_2 = L8_2
  triggerserverevent(l4_2, l7_2, l9_2, l8_2)
  throwingWeapon = nil
end
ThrowCurrentWeapon = L0_1
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function fn_L1_1()
local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = RegisterKeyMapping
  L1_2 = "throwweapon"
  L2_2 = "Throw Weapon"
  L3_2 = "keyboard"
  L4_2 = Config
  L4_2 = L4_2.KeyBinds
  L4_2 = L4_2.ThrowWeapon
  L0_2(L1_2, L2_2, L3_2, L4_2)
  L0_2 = RegisterCommand
  L1_2 = "throwweapon"
  function L2_2()
local L0_3, l0_2, l0_3, L3_3, throwcurrentweapon
    L0_3 = PlayerPedId
    L0_3 = L0_3()
    getcurrentpedweapon = GetCurrentPedWeapon
    l0_3 = L0_3
    L3_3 = 1
    getcurrentpedweapon, l0_3 = getcurrentpedweapon(l0_3, L3_3)
    L3_3 = GetWeaponString
    l2_3 = l2_3
    L3_3 = L3_3(L4_3)
    if not getcurrentpedweapon or not L3_3 then
      return
    end
    throwcurrentweapon = ThrowCurrentWeapon
    throwcurrentweapon()
  end
  L0_2(L1_2, L2_2)
end
L0_1(fn_L1_1)
function L0_1(A0_2, ...)
local L1_2, L2_2, L3_2
  L1_2 = RequestModel
  L2_2 = A0_2
  L1_2(L2_2)
  while true do
    L1_2 = HasModelLoaded
    L2_2 = A0_2
    L1_2 = L1_2(L2_2)
    if L1_2 then
      break
    end
    L1_2 = Wait
    L2_2 = 0
    L1_2(L2_2)
  end
  L1_2 = CreateObject
  L2_2 = A0_2
  L3_2 = ...
  L1_2 = L1_2(L2_2, L3_2)
  L2_2 = SetModelAsNoLongerNeeded
  L3_2 = A0_2
  L2_2(L3_2)
  return L1_2
end
CreateProp = L0_1
function L0_1(A0_2, A1_2, ...)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = RequestAnimDict
  L3_2 = A1_2
  L2_2(L3_2)
  while true do
    L2_2 = HasAnimDictLoaded
    L3_2 = A1_2
    L2_2 = L2_2(L3_2)
    if L2_2 then
      break
    end
    L2_2 = Wait
    L3_2 = 0
    L2_2(L3_2)
  end
  L2_2 = TaskPlayAnim
  L3_2 = A0_2
  L4_2 = A1_2
  L5_2 = ...
  L2_2(L3_2, L4_2, L5_2)
end
PlayAnim = L0_1
