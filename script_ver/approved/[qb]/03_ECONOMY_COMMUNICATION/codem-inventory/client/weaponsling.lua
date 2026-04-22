local L0_1, pairs, L15_2, L3_1, L4_1, fn_L5_1
L0_1 = Config
L0_1 = L0_1.SlingWeapon
if not L0_1 then
  return
end
L0_1 = {}
L1_1 = {}
L2_1 = "Back"
L3_1 = Citizen
L3_1 = L3_1.CreateThread
function L4_1()
local L0_2, L1_2, pairs, pairs, l0_1, L7_2, L7_2, L7_2, L9_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, l2_1
  while true do
    L0_2 = PlayerPedId
    L0_2 = L0_2()
    L1_2 = false
    clientinventory = ClientInventory
    if nil ~= clientinventory then
      L3_2 = {}
      l2_2 = l2_2["1"]
      L7_2 = L2_2["2"]
      L7_2 = L2_2["3"]
      L7_2 = L2_2["4"]
      L9_2 = L2_2["5"]
      L3_2[1] = l2_2
      L3_2[2] = L7_2
      L3_2[3] = L7_2
      L3_2[4] = L7_2
      L3_2[5] = L9_2
      l3_2 = L3_2
      l1_1 = pairs
      l1_1 = l1_1
      l1_1, l1_1, L7_2, L7_2 = l1_1(l1_1)
      for L7_2, L9_2 in l1_1, l1_1, L7_2, L7_2 do
        if nil ~= L9_2 then
          L9_2 = L8_2.type
          if "weapon" == L9_2 then
            L9_2 = Config
            L9_2 = L9_2.WeaponSling
            L9_2 = L9_2.compatable_weapon_hashes
            L10_2 = L8_2.name
            L9_2 = L9_2[L10_2]
            if nil ~= L9_2 then
              L9_2 = pairs
              L10_2 = L0_1
              L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
              for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
                if L14_2 then
                  L1_2 = true
                end
              end
              if not L1_2 then
                L9_2 = Config
                L9_2 = L9_2.WeaponSling
                L9_2 = L9_2.compatable_weapon_hashes
                L10_2 = L8_2.name
                L9_2 = L9_2[L10_2]
                L9_2 = L9_2.model
                L10_2 = Config
                L10_2 = L10_2.WeaponSling
                L10_2 = L10_2.compatable_weapon_hashes
                L11_2 = L8_2.name
                L10_2 = L10_2[L11_2]
                L10_2 = L10_2.hash
                L11_2 = L0_1
                L11_2 = L11_2[L9_2]
                if not L11_2 then
                  L11_2 = GetSelectedPedWeapon
                  L12_2 = L0_2
                  L11_2 = L11_2(L12_2)
                  if L11_2 ~= L10_2 then
                    L11_2 = AttachWeapon
                    L12_2 = L9_2
                    L13_2 = L10_2
                    L14_2 = Config
                    L14_2 = L14_2.WeaponSling
                    L14_2 = L14_2.Positions
                    L15_2 = L2_1
                    L14_2 = L14_2[L15_2]
                    L14_2 = L14_2.bone
                    L15_2 = Config
                    L15_2 = L15_2.WeaponSling
                    L15_2 = L15_2.Positions
                    L16_2 = L2_1
                    L15_2 = L15_2[L16_2]
                    L15_2 = L15_2.x
                    L16_2 = Config
                    L16_2 = L16_2.WeaponSling
                    L16_2 = L16_2.Positions
                    L17_2 = L2_1
                    L16_2 = L16_2[L17_2]
                    L16_2 = L16_2.y
                    L17_2 = Config
                    L17_2 = L17_2.WeaponSling
                    L17_2 = L17_2.Positions
                    L18_2 = L2_1
                    L17_2 = L17_2[L18_2]
                    L17_2 = L17_2.z
                    L18_2 = Config
                    L18_2 = L18_2.WeaponSling
                    L18_2 = L18_2.Positions
                    L19_2 = L2_1
                    L18_2 = L18_2[L19_2]
                    L18_2 = L18_2.x_rotation
                    L19_2 = Config
                    L19_2 = L19_2.WeaponSling
                    L19_2 = L19_2.Positions
                    L20_2 = L2_1
                    L19_2 = L19_2[L20_2]
                    L19_2 = L19_2.y_rotation
                    L20_2 = Config
                    L20_2 = L20_2.WeaponSling
                    L20_2 = L20_2.Positions
                    l2_1 = L15_2
                    L20_2 = L20_2[L21_2]
                    L20_2 = L20_2.z_rotation
                    L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2)
                  end
                end
              end
            end
          end
        end
      end
      l1_1 = pairs
      l0_1 = L0_1
      l3_2, l0_1, L7_2, L7_2 = l3_2(l0_1)
      for L7_2, L9_2 in l3_2, l0_1, L7_2, L7_2 do
        L9_2 = GetSelectedPedWeapon
        L10_2 = L0_2
        L9_2 = L9_2(L10_2)
        L10_2 = L8_2.hash
        if L9_2 ~= L10_2 then
          L9_2 = inHotbar
          L10_2 = L8_2.hash
          L9_2 = L9_2(L10_2)
          if L9_2 then
            goto lbl_134
          end
        end
        L9_2 = DeleteObject
        L10_2 = L8_2.handle
        L9_2(L10_2)
        L9_2 = L0_1
        L9_2[L7_2] = nil
        ::lbl_134::
      end
    end
    l1_1 = Wait
    l0_1 = 1500
    l3_2(l0_1)
  end
end
L3_1(L4_1)
function L3_1(A0_2)
local L1_2, l0_1, l0_1, l0_1, L7_2, L7_2, L7_2, L9_2
  L1_2 = pairs
  l1_1 = L1_1
  L1_2, l1_1, l1_1, l0_1 = L1_2(l1_1)
  for L7_2, L7_2 in L1_2, l1_1, l1_1, l0_1 do
    if nil ~= L7_2 then
      L7_2 = L6_2.type
      if "weapon" == L7_2 then
        L7_2 = Config
        L7_2 = L7_2.WeaponSling
        L7_2 = L7_2.compatable_weapon_hashes
        L9_2 = L6_2.name
        L7_2 = L7_2[L8_2]
        if nil ~= L7_2 then
          L7_2 = GetHashKey
          L9_2 = L6_2.name
          L7_2 = L7_2(L8_2)
          if A0_2 == L7_2 then
            L7_2 = true
            return L7_2
          end
        end
      end
    end
  end
  L1_2 = false
  return L1_2
end
inHotbar = L3_1
function L3_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2, A8_2)
local L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, l2_1, L22_2, L23_2, L24_2, L25_2
  L9_2 = GetPedBoneIndex
  L10_2 = PlayerPedId
  L10_2 = L10_2()
  L11_2 = A2_2
  L9_2 = L9_2(L10_2, L11_2)
  L10_2 = RequestModel
  L11_2 = A0_2
  L10_2(L11_2)
  while true do
    L10_2 = HasModelLoaded
    L11_2 = A0_2
    L10_2 = L10_2(L11_2)
    if L10_2 then
      break
    end
    L10_2 = Wait
    L11_2 = 100
    L10_2(L11_2)
  end
  L10_2 = L0_1
  L11_2 = {}
  L11_2.hash = A1_2
  L12_2 = CreateObject
  L13_2 = GetHashKey
  L14_2 = A0_2
  L13_2 = L13_2(L14_2)
  L14_2 = 1.0
  L15_2 = 1.0
  L16_2 = 1.0
  L17_2 = true
  L18_2 = true
  L19_2 = false
  L12_2 = L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
  L11_2.handle = L12_2
  L10_2[A0_2] = L11_2
  L10_2 = AttachEntityToEntity
  L11_2 = L0_1
  L11_2 = L11_2[A0_2]
  L11_2 = L11_2.handle
  L12_2 = PlayerPedId
  L12_2 = L12_2()
  L13_2 = L9_2
  L14_2 = A3_2
  L15_2 = A4_2
  L16_2 = A5_2
  L17_2 = A6_2
  L18_2 = A7_2
  L19_2 = A8_2
  L20_2 = 1
  l2_1 = 1
  L22_2 = 0
  L23_2 = 0
  L24_2 = 2
  L25_2 = 1
  L10_2(L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, l2_1, L22_2, L23_2, L24_2, L25_2)
end
AttachWeapon = L3_1
L3_1 = RegisterCommand
L4_1 = Config
L4_1 = L4_1.Commands
L4_1 = L4_1.slingweapon
function fn_L5_1()
local L0_2, L1_2, l0_1, l0_1, l0_1, L7_2, L7_2, L7_2
  L0_2 = L2_1
  if "Back" == L0_2 then
    L0_2 = "Front"
    L15_2 = L0_2
    L0_2 = pairs
    L1_2 = L0_1
    L0_2, L1_2, l1_1, l1_1 = L0_2(L1_2)
    for l0_1, L7_2 in L0_2, L1_2, l1_1, l1_1 do
      L7_2 = DeleteObject
      L7_2 = L5_2.handle
      L7_2(L7_2)
      L7_2 = L0_1
      L7_2[l0_1] = nil
    end
  else
    L0_2 = "Back"
    L15_2 = L0_2
    L0_2 = pairs
    L1_2 = L0_1
    L0_2, L1_2, l1_1, l1_1 = L0_2(L1_2)
    for l0_1, L7_2 in L0_2, L1_2, l1_1, l1_1 do
      L7_2 = DeleteObject
      L7_2 = L5_2.handle
      L7_2(L7_2)
      L7_2 = L0_1
      L7_2[l0_1] = nil
    end
  end
end
L3_1(L4_1, fn_L5_1)
L3_1 = AddEventHandler
L4_1 = "onResourceStop"
function fn_L5_1(A0_2)
local L1_2, l0_1, l0_1, l0_1, L7_2, L7_2, L7_2, L9_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if L1_2 == A0_2 then
    L1_2 = PlayerPedId
    L1_2 = L1_2()
    pairs = pairs
    l1_1 = L0_1
    pairs, pairs, l0_1, L7_2 = pairs(pairs)
    for L7_2, L7_2 in pairs, pairs, l0_1, L7_2 do
      L9_2 = DeleteObject
      L9_2 = L7_2.handle
      L9_2(L9_2)
      L9_2 = L0_1
      L9_2[L7_2] = nil
    end
    pairs = pairs
    l1_1 = ClientGround
    pairs, pairs, l0_1, L7_2 = pairs(pairs)
    for L7_2, L7_2 in pairs, pairs, l0_1, L7_2 do
      L9_2 = L7_2.inventory
      if L9_2 then
        L9_2 = pairs
        L9_2 = L7_2.inventory
        L9_2, L9_2, L10_2, L11_2 = L9_2(L9_2)
        for L12_2, L13_2 in L9_2, L9_2, L10_2, L11_2 do
          L14_2 = L13_2.object
          if L14_2 then
            L14_2 = DeleteObject
            L15_2 = L13_2.object
            L14_2(L15_2)
          end
        end
      end
    end
  end
end
L3_1(L4_1, fn_L5_1)
