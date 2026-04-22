local L0_1, CheckDupliceteItems, L2_1, fn_L3_1
Core = nil
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function CheckDupliceteItems()
local L0_2, L1_2
  L0_2 = GetCore
  L0_2 = L0_2()
  Core = L0_2
end
L0_1(CheckDupliceteItems)
L0_1 = {}
PlayerServerInventory = L0_1
L0_1 = {}
ServerGround = L0_1
L0_1 = {}
ServerStash = L0_1
L0_1 = {}
VehicleInventory = L0_1
L0_1 = {}
GloveBoxInventory = L0_1
L0_1 = {}
Identifier = L0_1
L0_1 = {}
ServerPlayerKey = L0_1
L0_1 = {}
cooldown = L0_1
L0_1 = {}
ClothingInventory = L0_1
function L0_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2
  while true do
    L1_2 = Core
    if nil ~= L1_2 then
      break
    end
    L1_2 = Wait
    L2_2 = 0
    L1_2(L2_2)
  end
  L1_2 = Config
  L1_2 = L1_2.Framework
  if L1_2 == "qb" or L1_2 == "oldqb" then
    L2_2 = GetPlayer
    L3_2 = tonumber
    L4_2 = A0_2
    L3_2, L4_2, L5_2 = L3_2(L4_2)
    L2_2 = L2_2(L3_2, L4_2, L5_2)
    if L2_2 then
      L3_2 = GetIdentifier
      L4_2 = tonumber
      L5_2 = A0_2
      L4_2, L5_2 = L4_2(L5_2)
      L3_2 = L3_2(L4_2, L5_2)
      if not L3_2 then
        return
      end
      L4_2 = L2_2.Functions
      L4_2 = L4_2.SetPlayerData
      L5_2 = "items"
      L4_2(L5_2, PlayerServerInventory[L3_2].inventory)
    end
  elseif L1_2 == "esx" then
    L2_2 = Core
    L2_2 = L2_2.GetPlayerFromId
    L3_2 = A0_2
    L2_2 = L2_2(L3_2)
    if L2_2 then
      L3_2 = GetIdentifier
      L4_2 = tonumber
      L5_2 = A0_2
      L4_2, L5_2 = L4_2(L5_2)
      L3_2 = L3_2(L4_2, L5_2)
      if not L3_2 then
        return
      end
      L4_2 = L2_2.set
      L5_2 = "inv"
      L4_2(L5_2, PlayerServerInventory[L3_2].inventory)
    end
  end
end
SetInventory = L0_1
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function CheckDupliceteItems()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = Citizen
  L0_2 = L0_2.Wait
  L1_2 = 15000
  L0_2(L1_2)
  L0_2 = GetResourceState
  L1_2 = "qb-weapons"
  L0_2 = L0_2(L1_2)
  if "started" == L0_2 then
    L0_2 = 1
    L1_2 = 20
    L2_2 = 1
    for L3_2 = L0_2, L1_2, L2_2 do
      L4_2 = print
      L5_2 = "PLS DELETE QB-WEAPONS RESOURCE"
      L4_2(L5_2)
    end
  end
end
L0_1(CheckDupliceteItems)
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function CheckDupliceteItems()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2
  L0_2 = Citizen
  L0_2 = L0_2.Wait
  L1_2 = 5000
  L0_2(L1_2)
  L0_2 = GetResourceState
  L1_2 = "qb-smallresources"
  L0_2 = L0_2(L1_2)
  if "started" == L0_2 then
    L0_2 = "client/weapdraw.lua"
    L1_2 = LoadResourceFile
    L2_2 = "qb-smallresources"
    L3_2 = L0_2
    L1_2 = L1_2(L2_2, L3_2)
    if not L1_2 then
      return
    end
    L2_2 = 1
    L3_2 = 20
    L4_2 = 1
    for L5_2 = L2_2, L3_2, L4_2 do
      L8_2 = print
      L7_2 = "PLS DELETE QB-SMALLRESOURCES/CLIENT/WEAPDRAW.LUA"
      L8_2(L7_2)
    end
  end
end
L0_1(CheckDupliceteItems)
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function CheckDupliceteItems()
local L0_2, L1_2
end
L0_1(CheckDupliceteItems)
L0_1 = AddEventHandler
CheckDupliceteItems = "onResourceStart"
function L2_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2
  while true do
    L1_2 = Core
    if nil ~= L1_2 then
      break
    end
    L1_2 = Wait
    L2_2 = 0
    L1_2(L2_2)
  end
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if A0_2 ~= L1_2 then
    return
  end
  L1_2 = Config
  L1_2 = L1_2.Framework
  if "qb" ~= L1_2 then
    L1_2 = Config
    L1_2 = L1_2.Framework
    if "oldqb" ~= L1_2 then
      goto lbl_35
    end
  end
  L1_2 = Core
  L1_2 = L1_2.Functions
  L1_2 = L1_2.GetQBPlayers
  L1_2 = L1_2()
  L2_2 = pairs
  L3_2 = L1_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L8_2 in L2_2, L3_2, L4_2, L5_2 do
    L7_2 = SetMethods
    L8_2 = L6_2
    L7_2(L8_2)
  end
  ::lbl_35::
end
L0_1(CheckDupliceteItems, L2_1)
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function CheckDupliceteItems()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L0_2 = ExecuteSql
  L1_2 = "SELECT * FROM `codem_new_stash`"
  L0_2 = L0_2(L1_2)
  L1_2 = 0
  L2_2 = 1
  L3_2 = #L0_2
  L4_2 = 1
  for L5_2 = L2_2, L3_2, L4_2 do
    L8_2 = L0_2[L5_2]
    L7_2 = json
    L7_2 = L7_2.decode
    L8_2 = L6_2.inventory
    if not L8_2 then
      L8_2 = "{}"
    end
    L7_2 = L7_2(L8_2)
    L8_2 = next
    L9_2 = L7_2
    L8_2 = L8_2(L9_2)
    if nil == L8_2 then
      L8_2 = ExecuteSql
      L9_2 = "DELETE FROM `codem_new_stash` WHERE `stashname` = @stashname"
      L10_2 = {}
      L11_2 = L6_2.stashname
      L10_2["@stashname"] = L11_2
      L8_2(L9_2, L10_2)
      L1_2 = L1_2 + 1
    else
      L8_2 = ServerStash
      L9_2 = L6_2.stashname
      L10_2 = {}
      L11_2 = L6_2.stashname
      L10_2.stashname = L11_2
      L10_2.inventory = L7_2
      L8_2[L9_2] = L10_2
    end
  end
  if L1_2 > 0 then
    L2_2 = print
    L3_2 = "^2 Deleted empty stash records, count: "
    L4_2 = L1_2
    L5_2 = " ^0"
    L3_2 = L3_2 .. L4_2 .. L5_2
    L2_2(L3_2)
  end
end
L0_1(CheckDupliceteItems)
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function CheckDupliceteItems()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L0_2 = Config
  L0_2 = L0_2.ItemClothingSystem
  if L0_2 then
    L0_2 = ExecuteSql
    L1_2 = "SELECT * FROM `codem_new_clothingsitem`"
    L0_2 = L0_2(L1_2)
    L1_2 = 0
    L2_2 = 1
    L3_2 = #L0_2
    L4_2 = 1
    for L5_2 = L2_2, L3_2, L4_2 do
      L8_2 = L0_2[L5_2]
      L7_2 = json
      L7_2 = L7_2.decode
      L8_2 = L6_2.inventory
      if not L8_2 then
        L8_2 = "{}"
      end
      L7_2 = L7_2(L8_2)
      L8_2 = next
      L9_2 = L7_2
      L8_2 = L8_2(L9_2)
      if nil == L8_2 then
        L8_2 = ExecuteSql
        L9_2 = "DELETE FROM `codem_new_clothingsitem` WHERE `identifier` = @identifier"
        L10_2 = {}
        L11_2 = L6_2.identifier
        L10_2["@identifier"] = L11_2
        L8_2(L9_2, L10_2)
        L1_2 = L1_2 + 1
      else
        L8_2 = ClothingInventory
        L9_2 = L6_2.identifier
        L10_2 = {}
        L11_2 = L6_2.identifier
        L10_2.identifier = L11_2
        L10_2.inventory = L7_2
        L8_2[L9_2] = L10_2
      end
    end
    if L1_2 > 0 then
      L2_2 = print
      L3_2 = "^2Deleted empty clothing data records, count: "
      L4_2 = L1_2
      L5_2 = "^0"
      L3_2 = L3_2 .. L4_2 .. L5_2
      L2_2(L3_2)
    end
    L2_2 = pairs
    L3_2 = GetPlayers
    L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = L3_2()
    L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
    for L8_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
      L8_2 = tonumber
      L9_2 = L7_2
      L8_2 = L8_2(L9_2)
      L9_2 = GetIdentifier
      L10_2 = L8_2
      L9_2 = L9_2(L10_2)
      L10_2 = ClothingInventory
      L10_2 = L10_2[L9_2]
      if L10_2 then
        L10_2 = TriggerClientEvent
        L11_2 = "codem-inventory:loadclothingdata"
        L12_2 = tonumber
        L13_2 = L8_2
        L12_2 = L12_2(L13_2)
        L13_2 = ClothingInventory
        L13_2 = L13_2[L9_2]
        L13_2 = L13_2.inventory
        L10_2(L11_2, L12_2, L13_2)
      end
    end
  end
end
L0_1(CheckDupliceteItems)
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function CheckDupliceteItems()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L0_2 = ExecuteSql
  L1_2 = "SELECT * FROM `codem_new_vehicleandglovebox`"
  L0_2 = L0_2(L1_2)
  L1_2 = 0
  L2_2 = 1
  L3_2 = #L0_2
  L4_2 = 1
  for L5_2 = L2_2, L3_2, L4_2 do
    L8_2 = L0_2[L5_2]
    L7_2 = string
    L7_2 = L7_2.lower
    L8_2 = string
    L8_2 = L8_2.gsub
    L9_2 = L6_2.plate
    L10_2 = "%s+"
    L11_2 = ""
    L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = L8_2(L9_2, L10_2, L11_2)
    L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
    L8_2 = L6_2.plate
    if L7_2 ~= L8_2 then
      L8_2 = ExecuteSql
      L9_2 = "UPDATE `codem_new_vehicleandglovebox` SET `plate` = @correctedPlate WHERE `plate` = @originalPlate"
      L10_2 = {}
      L10_2["@correctedPlate"] = L7_2
      L11_2 = L6_2.plate
      L10_2["@originalPlate"] = L11_2
      L8_2(L9_2, L10_2)
    end
    L8_2 = json
    L8_2 = L8_2.decode
    L9_2 = L6_2.trunk
    if not L9_2 then
      L9_2 = "{}"
    end
    L8_2 = L8_2(L9_2)
    L9_2 = json
    L9_2 = L9_2.decode
    L10_2 = L6_2.glovebox
    if not L10_2 then
      L10_2 = "{}"
    end
    L9_2 = L9_2(L10_2)
    L10_2 = next
    L11_2 = L8_2
    L10_2 = L10_2(L11_2)
    if nil == L10_2 then
      L10_2 = next
      L11_2 = L9_2
      L10_2 = L10_2(L11_2)
      if nil == L10_2 then
        L10_2 = ExecuteSql
        L11_2 = "DELETE FROM `codem_new_vehicleandglovebox` WHERE `plate` = @plate"
        L12_2 = {}
        L13_2 = L6_2.plate
        L12_2["@plate"] = L13_2
        L10_2(L11_2, L12_2)
        L1_2 = L1_2 + 1
    end
    else
      L10_2 = next
      L11_2 = L8_2
      L10_2 = L10_2(L11_2)
      if nil ~= L10_2 then
        L10_2 = VehicleInventory
        L11_2 = {}
        L11_2.plate = L7_2
        L11_2.trunk = L8_2
        L10_2[L7_2] = L11_2
      end
      L10_2 = next
      L11_2 = L9_2
      L10_2 = L10_2(L11_2)
      if nil ~= L10_2 then
        L10_2 = GloveBoxInventory
        L11_2 = {}
        L11_2.plate = L7_2
        L11_2.glovebox = L9_2
        L10_2[L7_2] = L11_2
      end
    end
  end
  if L1_2 > 0 then
    L2_2 = print
    L3_2 = "^2 DELETED EMPTY VEHICLE SQL, COUNT : "
    L4_2 = L1_2
    L5_2 = "^0"
    L3_2 = L3_2 .. L4_2 .. L5_2
    L2_2(L3_2)
  end
end
L0_1(CheckDupliceteItems)
L0_1 = {}
function CheckDupliceteItems(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L1_2 = tonumber
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    return
  end
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    return
  end
  if L2_2 then
    L4_2 = L0_1
    L4_2 = L4_2[L1_2]
    if not L4_2 then
      goto lbl_36
    end
    L4_2 = os
    L4_2 = L4_2.time
    L4_2 = L4_2()
    L5_2 = L0_1
    L5_2 = L5_2[L1_2]
    L4_2 = L4_2 - L5_2
    L5_2 = 600
    if not (L4_2 < L5_2) then
      goto lbl_36
    end
  end
  do return end
  ::lbl_36::
  L4_2 = L0_1
  L5_2 = os
  L5_2 = L5_2.time
  L5_2 = L5_2()
  L4_2[L1_2] = L5_2
  L4_2 = {}
  L5_2 = pairs
  L8_2 = L3_2
  L5_2, L8_2, L7_2, L8_2 = L5_2(L8_2)
  for L9_2, L10_2 in L5_2, L8_2, L7_2, L8_2 do
    L11_2 = L10_2.info
    if L11_2 then
      L11_2 = L10_2.info
      L11_2 = L11_2.series
      if L11_2 then
        L11_2 = L10_2.info
        L11_2 = L11_2.series
        L11_2 = L4_2[L11_2]
        if not L11_2 then
          L11_2 = L10_2.info
          L11_2 = L11_2.series
          L12_2 = {}
          L4_2[L11_2] = L12_2
        end
        L11_2 = table
        L11_2 = L11_2.insert
        L12_2 = L10_2.info
        L12_2 = L12_2.series
        L12_2 = L4_2[L12_2]
        L13_2 = L10_2
        L11_2(L12_2, L13_2)
      end
    end
  end
  L5_2 = pairs
  L8_2 = L4_2
  L5_2, L8_2, L7_2, L8_2 = L5_2(L8_2)
  for L9_2, L10_2 in L5_2, L8_2, L7_2, L8_2 do
    L11_2 = #L10_2
    if L11_2 > 1 then
      L11_2 = print
      L12_2 = "Duplicate items detected for series: "
      L13_2 = L9_2
      L14_2 = ". Count: "
      L15_2 = #L10_2
      L16_2 = " Player: "
      L17_2 = GetName
      L18_2 = L1_2
      L17_2 = L17_2(L18_2)
      L12_2 = L12_2 .. L13_2 .. L14_2 .. L15_2 .. L16_2 .. L17_2
      L11_2(L12_2)
      L11_2 = Config
      L11_2 = L11_2.UseDiscordWebhooks
      if L11_2 then
        L11_2 = {}
        L12_2 = GetName
        L13_2 = L1_2
        L12_2 = L12_2(L13_2)
        L13_2 = "-"
        L14_2 = L1_2
        L12_2 = L12_2 .. L13_2 .. L14_2
        L11_2.playername = L12_2
        L11_2.reason = "DUPLICATE ITEMS DETECTED"
        L12_2 = L10_2[1]
        L12_2 = L12_2.name
        L11_2.itemname = L12_2
        L12_2 = L10_2[1]
        L12_2 = L12_2.info
        if not L12_2 then
          L12_2 = nil
        end
        L11_2.info = L12_2
        L11_2.amount = 1
        L12_2 = TriggerEvent
        L13_2 = "codem-inventory:CreateLog"
        L14_2 = "DUPLICATE ITEMS"
        L15_2 = "green"
        L16_2 = L11_2
        L17_2 = L1_2
        L18_2 = "cheater"
        L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
        L12_2 = DropPlayer
        L13_2 = L1_2
        L14_2 = "Duplicate Player Inventory"
        L12_2(L13_2, L14_2)
      end
    end
  end
end
CheckDupliceteItems = CheckDupliceteItems
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:loadPlayerInventory"
function fn_L3_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2
  L0_2 = tonumber
  L1_2 = source
  L0_2 = L0_2(L1_2)
  L1_2 = GetIdentifier
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  L2_2 = GetPlayer
  L3_2 = L0_2
  L2_2 = L2_2(L3_2)
  if not L1_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L0_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = Config
  L3_2 = L3_2.Framework
  if "qb" ~= L3_2 then
    L3_2 = Config
    L3_2 = L3_2.Framework
    if "oldqb" ~= L3_2 then
      goto lbl_113
    end
  end
  L3_2 = L2_2.PlayerData
  L3_2 = L3_2.items
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L1_2]
  if L4_2 then
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L1_2]
    L4_2 = L4_2.inventory
    if L4_2 then
      L4_2 = Identifier
      L5_2 = tonumber
      L8_2 = L0_2
      L5_2 = L5_2(L6_2)
      L4_2[L5_2] = L1_2
      L4_2 = PlayerServerInventory
      L4_2 = L4_2[L1_2]
      L4_2.inventory = L3_2
  end
  else
    L4_2 = Identifier
    L5_2 = tonumber
    L8_2 = L0_2
    L5_2 = L5_2(L6_2)
    L4_2 = L4_2[L5_2]
    if L4_2 then
      L4_2 = Identifier
      L5_2 = tonumber
      L8_2 = L0_2
      L5_2 = L5_2(L6_2)
      L4_2[L5_2] = nil
    end
    L4_2 = Identifier
    L5_2 = tonumber
    L8_2 = L0_2
    L5_2 = L5_2(L6_2)
    L4_2[L5_2] = L1_2
    L4_2 = PlayerServerInventory
    L5_2 = {}
    L5_2.identifier = L1_2
    L5_2.inventory = L3_2
    L4_2[L1_2] = L5_2
  end
  L4_2 = Config
  L4_2 = L4_2.ItemClothingSystem
  if L4_2 then
    L4_2 = ClothingInventory
    L4_2 = L4_2[L1_2]
    if not L4_2 then
      L4_2 = ClothingInventory
      L5_2 = {}
      L5_2.identifier = L1_2
      L8_2 = {}
      L5_2.inventory = L8_2
      L4_2[L1_2] = L5_2
    end
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:loadclothingdata"
    L8_2 = L0_2
    L7_2 = ClothingInventory
    L7_2 = L7_2[L1_2]
    L7_2 = L7_2.inventory
    L4_2(L5_2, L8_2, L7_2)
  end
  L4_2 = Config
  L4_2 = L4_2.CashItem
  if L4_2 then
    L4_2 = GetPlayerMoney
    L5_2 = L0_2
    L7_2 = "cash"
    L4_2 = L4_2(L5_2, L7_2)
    L5_2 = SetInventoryItems
    L7_2 = L0_2
    L8_2 = "cash"
    L9_2 = L4_2
    L5_2(L7_2, L8_2, L9_2)
  end
  L4_2 = CheckDupliceteItems
  L5_2 = type
  L7_2 = L4_2
  L5_2 = L5_2(L7_2)
  if "function" == L5_2 then
    L5_2 = pcall
    L8_2 = L4_2
    L9_2 = L0_2
    L5_2(L8_2, L9_2)
  end
  ::lbl_113::
  L3_2 = Config
  L3_2 = L3_2.Framework
  if "esx" ~= L3_2 then
    L3_2 = Config
    L3_2 = L3_2.Framework
    if "oldesx" ~= L3_2 then
      goto lbl_187
    end
  end
  L3_2 = L2_2.get
  L4_2 = "inv"
  L3_2 = L3_2(L4_2)
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L1_2]
  if L4_2 then
    L4_2 = Identifier
    L5_2 = tonumber
    L8_2 = L0_2
    L5_2 = L5_2(L6_2)
    L4_2[L5_2] = L1_2
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L1_2]
    L4_2.inventory = L3_2
  else
    L4_2 = Identifier
    L5_2 = tonumber
    L8_2 = L0_2
    L5_2 = L5_2(L6_2)
    L4_2[L5_2] = L1_2
    L4_2 = PlayerServerInventory
    L5_2 = {}
    L5_2.identifier = L1_2
    L5_2.inventory = L3_2
    L4_2[L1_2] = L5_2
  end
  L4_2 = Config
  L4_2 = L4_2.ItemClothingSystem
  if L4_2 then
    L4_2 = ClothingInventory
    L4_2 = L4_2[L1_2]
    if not L4_2 then
      L4_2 = ClothingInventory
      L5_2 = {}
      L5_2.identifier = L1_2
      L8_2 = {}
      L5_2.inventory = L8_2
      L4_2[L1_2] = L5_2
    end
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:loadclothingdata"
    L8_2 = L0_2
    L7_2 = ClothingInventory
    L7_2 = L7_2[L1_2]
    L7_2 = L7_2.inventory
    L4_2(L5_2, L8_2, L7_2)
  end
  L4_2 = Config
  L4_2 = L4_2.CashItem
  if L4_2 then
    L4_2 = GetPlayerMoney
    L5_2 = L0_2
    L7_2 = "cash"
    L4_2 = L4_2(L5_2, L7_2)
    L5_2 = SetInventoryItems
    L7_2 = L0_2
    L8_2 = "cash"
    L9_2 = L4_2
    L5_2(L7_2, L8_2, L9_2)
  end
  L4_2 = CheckDupliceteItems
  L5_2 = type
  L7_2 = L4_2
  L5_2 = L5_2(L7_2)
  if "function" == L5_2 then
    L5_2 = pcall
    L8_2 = L4_2
    L9_2 = L0_2
    L5_2(L8_2, L9_2)
  end
  ::lbl_187::
  L3_2 = TriggerClientEvent
  L4_2 = "codem-inventory:client:loadClientInventory"
  L5_2 = L0_2
  L8_2 = PlayerServerInventory
  L8_2 = L8_2[L1_2]
  L8_2 = L8_2.inventory
  L3_2(L4_2, L5_2, L8_2)
  L3_2 = TriggerClientEvent
  L4_2 = "codem-inventory:client:loadAllVehicleInventory"
  L5_2 = L0_2
  L8_2 = VehicleInventory
  L3_2(L4_2, L5_2, L8_2)
  L3_2 = TriggerClientEvent
  L4_2 = "codem-inventory:client:loadAllGround"
  L5_2 = L0_2
  L8_2 = ServerGround
  L3_2(L4_2, L5_2, L8_2)
  L3_2 = TriggerClientEvent
  L4_2 = "codem-inventory:client:loadAllVehicleGlovebox"
  L5_2 = L0_2
  L8_2 = GloveBoxInventory
  L3_2(L4_2, L5_2, L8_2)
  L3_2 = ServerPlayerKey
  L4_2 = "CODEM"
  L5_2 = math
  L5_2 = L5_2.random
  L8_2 = 10000
  L7_2 = 999999999
  L5_2 = L5_2(L6_2, L7_2)
  L8_2 = "saas"
  L7_2 = math
  L7_2 = L7_2.random
  L8_2 = 10000
  L9_2 = 999999999
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = "KEY"
  L4_2 = L4_2 .. L5_2 .. L6_2 .. L7_2 .. L8_2
  L3_2[L0_2] = L4_2
  L3_2 = TriggerClientEvent
  L4_2 = "codem-inventory:client:setkey"
  L5_2 = L0_2
  L8_2 = ServerPlayerKey
  L8_2 = L8_2[L0_2]
  L3_2(L4_2, L5_2, L8_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:checkPlayerItemForSwap"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L1_2 = source
  L2_2 = tonumber
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  L3_2 = Identifier
  L3_2 = L3_2[L2_2]
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.IDENTIFIERNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = cooldown
  L4_2 = L4_2[L2_2]
  if L4_2 then
    return
  else
    L4_2 = cooldown
    L4_2[L2_2] = true
    L4_2 = SetTimeout
    L5_2 = 600
    function L8_2()
local cooldown, L1_3
      cooldown = cooldown
      L1_3 = L2_2
      cooldown[L1_3] = nil
    end
    L4_2(L5_2, L8_2)
  end
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L3_2]
  if L4_2 then
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L3_2]
    L4_2 = L4_2.inventory
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERINVENTORYNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    L5_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 245 SATIR"
    L5_2(L8_2)
    return
  end
  L5_2 = tostring
  L8_2 = A0_2.oldSlot
  L5_2 = L5_2(L6_2)
  L8_2 = tostring
  L7_2 = A0_2.newSlot
  L8_2 = L8_2(L7_2)
  L7_2 = L4_2[L5_2]
  if L7_2 then
    L4_2[L8_2] = L7_2
    L8_2 = L4_2[L6_2]
    L8_2.slot = L8_2
    L4_2[L5_2] = nil
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:ChangeSwapItem"
    L10_2 = L1_2
    L11_2 = A0_2.oldSlot
    L12_2 = A0_2.newSlot
    L8_2(L9_2, L10_2, L11_2, L12_2)
    L8_2 = SetInventory
    L9_2 = L1_2
    L8_2(L9_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:checkPlayerItemForSwapTargetItem"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2
  L1_2 = tonumber
  L2_2 = source
  L1_2 = L1_2(L2_2)
  L2_2 = Identifier
  L3_2 = tonumber
  L4_2 = L1_2
  L3_2 = L3_2(L4_2)
  L2_2 = L2_2[L3_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = cooldown
  L4_2 = tonumber
  L5_2 = L1_2
  L4_2 = L4_2(L5_2)
  L3_2 = L3_2[L4_2]
  if L3_2 then
    return
  else
    L3_2 = cooldown
    L4_2 = tonumber
    L5_2 = L1_2
    L4_2 = L4_2(L5_2)
    L3_2[L4_2] = true
    L3_2 = SetTimeout
    L4_2 = 1000
    function L5_2()
local cooldown, L1_3, L2_3
      cooldown = cooldown
      L1_3 = tonumber
      L2_3 = L1_2
      L1_3 = L1_3(L2_3)
      cooldown[L1_3] = nil
    end
    L3_2(L4_2, L5_2)
  end
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    L4_2 = debugprint
    L5_2 = "D\196\176KKAT ENVANTER BULUNAMADI 319 SATIR"
    L4_2(L5_2)
    return
  end
  if L3_2 then
    L4_2 = tostring
    L5_2 = A0_2.oldSlot
    L4_2 = L4_2(L5_2)
    L4_2 = L3_2[L4_2]
    L5_2 = tostring
    L8_2 = A0_2.newSlot
    L5_2 = L5_2(L6_2)
    L5_2 = L3_2[L5_2]
    if L4_2 and L5_2 then
      L8_2 = L4_2.name
      L7_2 = L5_2.name
      if L8_2 == L7_2 then
        L8_2 = L4_2.unique
        if not L8_2 then
          L8_2 = L5_2.unique
          if not L8_2 then
            goto lbl_111
          end
        end
        L8_2 = tostring
        L7_2 = A0_2.oldSlot
        L8_2 = L8_2(L7_2)
        L3_2[L8_2] = L5_2
        L8_2 = tostring
        L7_2 = A0_2.oldSlot
        L8_2 = L8_2(L7_2)
        L8_2 = L3_2[L8_2]
        L7_2 = tostring
        L8_2 = A0_2.oldSlot
        L7_2 = L7_2(L8_2)
        L8_2.slot = L7_2
        L8_2 = tostring
        L7_2 = A0_2.newSlot
        L8_2 = L8_2(L7_2)
        L3_2[L8_2] = L4_2
        L8_2 = tostring
        L7_2 = A0_2.newSlot
        L8_2 = L8_2(L7_2)
        L8_2 = L3_2[L8_2]
        L7_2 = tostring
        L8_2 = A0_2.newSlot
        L7_2 = L7_2(L8_2)
        L8_2.slot = L7_2
        L8_2 = TriggerClientEvent
        L7_2 = "codem-inventory:client:ChangeSwapItemTargetItem"
        L8_2 = L1_2
        L9_2 = A0_2.oldSlot
        L10_2 = A0_2.newSlot
        L8_2(L7_2, L8_2, L9_2, L10_2)
        L8_2 = SetInventory
        L7_2 = L1_2
        L8_2(L7_2)
        goto lbl_171
        ::lbl_111::
        L8_2 = tostring
        L7_2 = A0_2.newSlot
        L8_2 = L8_2(L7_2)
        L8_2 = L3_2[L8_2]
        L7_2 = tostring
        L8_2 = A0_2.newSlot
        L7_2 = L7_2(L8_2)
        L7_2 = L3_2[L7_2]
        L7_2 = L7_2.amount
        L8_2 = L4_2.amount
        L7_2 = L7_2 + L8_2
        L8_2.amount = L7_2
        L8_2 = tostring
        L7_2 = A0_2.oldSlot
        L8_2 = L8_2(L7_2)
        L3_2[L8_2] = nil
        L8_2 = TriggerClientEvent
        L7_2 = "codem-inventory:client:ChangeSwapItemSimilarItem"
        L8_2 = L1_2
        L9_2 = A0_2.oldSlot
        L10_2 = A0_2.newSlot
        L8_2(L7_2, L8_2, L9_2, L10_2)
        L8_2 = SetInventory
        L7_2 = L1_2
        L8_2(L7_2)
      else
        L8_2 = tostring
        L7_2 = A0_2.oldSlot
        L8_2 = L8_2(L7_2)
        L3_2[L8_2] = L5_2
        L8_2 = tostring
        L7_2 = A0_2.oldSlot
        L8_2 = L8_2(L7_2)
        L8_2 = L3_2[L8_2]
        L7_2 = tostring
        L8_2 = A0_2.oldSlot
        L7_2 = L7_2(L8_2)
        L8_2.slot = L7_2
        L8_2 = tostring
        L7_2 = A0_2.newSlot
        L8_2 = L8_2(L7_2)
        L3_2[L8_2] = L4_2
        L8_2 = tostring
        L7_2 = A0_2.newSlot
        L8_2 = L8_2(L7_2)
        L8_2 = L3_2[L8_2]
        L7_2 = tostring
        L8_2 = A0_2.newSlot
        L7_2 = L7_2(L8_2)
        L8_2.slot = L7_2
        L8_2 = TriggerClientEvent
        L7_2 = "codem-inventory:client:ChangeSwapItemTargetItem"
        L8_2 = L1_2
        L9_2 = A0_2.oldSlot
        L10_2 = A0_2.newSlot
        L8_2(L7_2, L8_2, L9_2, L10_2)
        L8_2 = SetInventory
        L7_2 = L1_2
        L8_2(L7_2)
      end
      ::lbl_171::
      L8_2 = Citizen
      L8_2 = L8_2.Wait
      L7_2 = 1000
      L8_2(L7_2)
    else
      L8_2 = Citizen
      L8_2 = L8_2.Wait
      L7_2 = 1000
      L8_2(L7_2)
      L8_2 = TriggerClientEvent
      L7_2 = "codem-inventory:client:notification"
      L8_2 = L1_2
      L9_2 = Locales
      L10_2 = Config
      L10_2 = L10_2.Language
      L9_2 = L9_2[L10_2]
      L9_2 = L9_2.notification
      L9_2 = L9_2.ITEMNOTFOUND
      L8_2(L7_2, L8_2, L9_2)
    end
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:SwapGroundToInventory"
function fn_L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = source
  L3_2 = Identifier
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L4_2 = ServerGround
    L4_2 = L4_2[A1_2]
    if L4_2 then
      goto lbl_21
    end
  end
  L4_2 = TriggerClientEvent
  L5_2 = "codem-inventory:client:notification"
  L8_2 = L2_2
  L7_2 = Locales
  L8_2 = Config
  L8_2 = L8_2.Language
  L7_2 = L7_2[L8_2]
  L7_2 = L7_2.notification
  L7_2 = L7_2.IDENTIFIERNOTFOUND
  L4_2(L5_2, L8_2, L7_2)
  do return end
  ::lbl_21::
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L3_2]
  if L4_2 then
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L3_2]
    L4_2 = L4_2.inventory
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L2_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERINVENTORYNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    L5_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 376 SATIR"
    L5_2(L8_2)
    return
  end
  L5_2 = ServerGround
  L5_2 = L5_2[A1_2]
  L5_2 = L5_2.inventory
  L8_2 = tostring
  L7_2 = A0_2.oldSlot
  L8_2 = L8_2(L7_2)
  L5_2 = L5_2[L6_2]
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L2_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.ITEMNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = CheckInventoryWeight
  L7_2 = L4_2
  L8_2 = L5_2.weight
  L9_2 = L5_2.amount
  L8_2 = L8_2 * L9_2
  L9_2 = Config
  L9_2 = L9_2.MaxWeight
  L8_2 = L8_2(L7_2, L8_2, L9_2)
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L2_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.INVENTORYISFULL
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  if L5_2 then
    L8_2 = L5_2.type
    if "bag" == L8_2 then
      L8_2 = CheckBagItem
      L7_2 = L2_2
      L8_2 = L8_2(L7_2)
      L7_2 = tonumber
      L8_2 = L6_2
      L7_2 = L7_2(L8_2)
      L8_2 = tonumber
      L9_2 = Config
      L9_2 = L9_2.MaxBackPackItem
      L8_2 = L8_2(L9_2)
      if L7_2 > L8_2 then
        L7_2 = TriggerClientEvent
        L8_2 = "codem-inventory:client:notification"
        L9_2 = L2_2
        L10_2 = Locales
        L11_2 = Config
        L11_2 = L11_2.Language
        L10_2 = L10_2[L11_2]
        L10_2 = L10_2.notification
        L10_2 = L10_2.MAXBAGPACKITEM
        L7_2(L8_2, L9_2, L10_2)
        return
      end
    end
  end
  function L8_2(A0_3, A1_3)
local L2_3, L3_3, L4_3, L5_3, L6_3, l2_3, L8_3
    L2_3 = L4_2
    L2_3 = L2_3[A0_3]
    if L2_3 then
      L2_3 = L4_2
      L2_3 = L2_3[A0_3]
      L2_3 = L2_3.name
      L3_3 = A1_3.name
      if L2_3 == L3_3 then
        L2_3 = A1_3.unique
        if not L2_3 then
          L2_3 = L4_2
          L2_3 = L2_3[A0_3]
          L3_3 = L4_2
          L3_3 = L3_3[A0_3]
          L3_3 = L3_3.amount
          L4_3 = A1_3.amount
          L3_3 = L3_3 + L4_3
          L2_3.amount = L3_3
      end
    end
    else
      L2_3 = A1_3.unique
      if L2_3 then
        L2_3 = FindFirstEmptySlot
        L3_3 = L4_2
        L4_3 = Config
        L4_3 = L4_3.MaxSlots
        L2_3 = L2_3(L3_3, L4_3)
        A0_3 = L2_3
        if not A0_3 then
          L2_3 = TriggerClientEvent
          L3_3 = "codem-inventory:client:notification"
          L4_3 = L2_2
          L5_3 = Locales
          L6_3 = Config
          L6_3 = L6_3.Language
          L5_3 = L5_3[L6_3]
          L5_3 = L5_3.notification
          L5_3 = L5_3.NOEMPTYSLOTAVILABLEYOUR
          L2_3(L3_3, L4_3, L5_3)
          return
        end
        L2_3 = tostring
        L3_3 = A0_3
        L2_3 = L2_3(L3_3)
        A0_3 = L2_3
        A1_3.slot = A0_3
        L2_3 = L4_2
        L2_3[A0_3] = A1_3
        L2_3 = L4_2
        L2_3 = L2_3[A0_3]
        L2_3.slot = A0_3
      else
        L2_3 = FindFirstEmptySlot
        L3_3 = L4_2
        L4_3 = Config
        L4_3 = L4_3.MaxSlots
        L2_3 = L2_3(L3_3, L4_3)
        A0_3 = L2_3
        L2_3 = tostring
        L3_3 = A0_3
        L2_3 = L2_3(L3_3)
        A0_3 = L2_3
        if not A0_3 then
          L2_3 = TriggerClientEvent
          L3_3 = "codem-inventory:client:notification"
          L4_3 = L2_2
          L5_3 = Locales
          L6_3 = Config
          L6_3 = L6_3.Language
          L5_3 = L5_3[L6_3]
          L5_3 = L5_3.notification
          L5_3 = L5_3.NOEMPTYSLOTAVILABLEYOUR
          L2_3(L3_3, L4_3, L5_3)
          return
        end
        A1_3.slot = A0_3
        L2_3 = L4_2
        L2_3[A0_3] = A1_3
        L2_3 = L4_2
        L2_3 = L2_3[A0_3]
        L2_3.slot = A0_3
      end
    end
    L2_3 = TriggerClientEvent
    L3_3 = "codem-inventory:client:additem"
    L4_3 = L2_2
    L5_3 = A0_3
    L6_3 = L4_2
    L6_3 = L6_3[A0_3]
    L2_3(L3_3, L4_3, L5_3, L6_3)
    L2_3 = Config
    L2_3 = L2_3.UseDiscordWebhooks
    if L2_3 then
      L2_3 = {}
      L3_3 = GetName
      L4_3 = L2_2
      L3_3 = L3_3(L4_3)
      L4_3 = "-"
      L5_3 = L2_2
      L3_3 = L3_3 .. L4_3 .. L5_3
      L2_3.playername = L3_3
      L3_3 = L5_2.label
      L2_3.itemname = L3_3
      L3_3 = L5_2.info
      if not L3_3 then
        L3_3 = nil
      end
      L2_3.info = L3_3
      L3_3 = L5_2.amount
      L2_3.amount = L3_3
      L3_3 = Locales
      L4_3 = Config
      L4_3 = L4_3.Language
      L3_3 = L3_3[L4_3]
      L3_3 = L3_3.notification
      L3_3 = L3_3.GROUNDTOINVENTORY
      L2_3.reason = L3_3
      L3_3 = TriggerEvent
      L4_3 = "codem-inventory:CreateLog"
      L5_3 = Locales
      L6_3 = Config
      L6_3 = L6_3.Language
      L5_3 = L5_3[L6_3]
      L5_3 = L5_3.notification
      L5_3 = L5_3.ADDITEMS
      L6_3 = "green"
      l2_3 = L2_3
      L8_3 = L2_2
      L3_3(L4_3, L5_3, L6_3, l2_3, L8_3)
    end
  end
  L7_2 = L6_2
  L8_2 = tostring
  L9_2 = A0_2.newSlot
  L8_2 = L8_2(L9_2)
  L9_2 = L5_2
  L7_2(L8_2, L9_2)
  L7_2 = ServerGround
  L7_2 = L7_2[A1_2]
  L7_2 = L7_2.inventory
  L8_2 = A0_2.oldSlot
  L7_2[L8_2] = nil
  L7_2 = next
  L8_2 = ServerGround
  L8_2 = L8_2[A1_2]
  L8_2 = L8_2.inventory
  L7_2 = L7_2(L8_2)
  if not L7_2 then
    L7_2 = ServerGround
    L7_2[A1_2] = nil
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:removeGroundTable"
    L9_2 = -1
    L10_2 = A1_2
    L7_2(L8_2, L9_2, L10_2)
  else
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:SetGroundTable"
    L9_2 = -1
    L10_2 = A1_2
    L11_2 = ServerGround
    L11_2 = L11_2[A1_2]
    L11_2 = L11_2.coord
    L12_2 = ServerGround
    L12_2 = L12_2[A1_2]
    L12_2 = L12_2.inventory
    L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
  end
  L7_2 = Config
  L7_2 = L7_2.CashItem
  if L7_2 then
    L7_2 = L5_2.name
    if "cash" == L7_2 then
      L7_2 = AddMoney
      L8_2 = L2_2
      L9_2 = "cash"
      L10_2 = L5_2.amount
      L7_2(L8_2, L9_2, L10_2)
  end
  else
    L7_2 = SetInventory
    L8_2 = L2_2
    L7_2(L8_2)
  end
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:dropanim"
  L9_2 = L2_2
  L7_2(L8_2, L9_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:SwapInventoryToGround"
function fn_L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L2_2 = tonumber
  L3_2 = source
  L2_2 = L2_2(L3_2)
  L3_2 = Identifier
  L3_2 = L3_2[L2_2]
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L2_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.IDENTIFIERNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = tostring
  L5_2 = A0_2.oldSlot
  L4_2 = L4_2(L5_2)
  A0_2.oldSlot = L4_2
  L4_2 = tostring
  L5_2 = A0_2.newSlot
  L4_2 = L4_2(L5_2)
  A0_2.newSlot = L4_2
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L3_2]
  if L4_2 then
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L3_2]
    L4_2 = L4_2.inventory
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L2_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERINVENTORYNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    L5_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 459 SATIR"
    L5_2(L8_2)
    return
  end
  L5_2 = ServerGround
  L5_2 = L5_2[A1_2]
  if L5_2 then
    L5_2 = ServerGround
    L5_2 = L5_2[A1_2]
    L5_2 = L5_2.inventory
    if L5_2 then
      goto lbl_61
    end
  end
  L5_2 = {}
  ::lbl_61::
  L8_2 = A0_2.oldSlot
  L8_2 = L4_2[L8_2]
  L7_2 = A0_2.newSlot
  L7_2 = L5_2[L7_2]
  L8_2 = A0_2.newSlot
  if not L8_2 then
    L8_2 = FindFirstEmptySlot
    L9_2 = L5_2
    L10_2 = Config
    L10_2 = L10_2.GroundSlots
    L8_2 = L8_2(L9_2, L10_2)
    if not L8_2 then
      L9_2 = TriggerClientEvent
      L10_2 = "codem-inventory:client:notification"
      L11_2 = L2_2
      L12_2 = Locales
      L13_2 = Config
      L13_2 = L13_2.Language
      L12_2 = L12_2[L13_2]
      L12_2 = L12_2.notification
      L12_2 = L12_2.NOEMPTYSLOTAVILABLEGROUND
      L9_2(L10_2, L11_2, L12_2)
      return
    end
    L9_2 = tostring
    L10_2 = L8_2
    L9_2 = L9_2(L10_2)
    A0_2.newSlot = L9_2
  end
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L2_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  if not A1_2 then
    L8_2 = GenerateGroundId
    L8_2 = L8_2()
    L9_2 = GetEntityCoords
    L10_2 = GetPlayerPed
    L11_2 = L2_2
    L10_2, L11_2, L12_2, L13_2, L14_2, L15_2 = L10_2(L11_2)
    L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
    L8_2.object = nil
    L10_2 = ServerGround
    L11_2 = {}
    L12_2 = {}
    L12_2["1"] = L8_2
    L11_2.inventory = L12_2
    L11_2.coord = L9_2
    L11_2.id = L8_2
    L10_2[L8_2] = L11_2
    L8_2.slot = "1"
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:SetGroundTable"
    L12_2 = -1
    L13_2 = L8_2
    L14_2 = L9_2
    L15_2 = ServerGround
    L15_2 = L15_2[L8_2]
    L15_2 = L15_2.inventory
    L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
  elseif L7_2 then
    L8_2 = FindFirstEmptySlot
    L9_2 = L5_2
    L10_2 = Config
    L10_2 = L10_2.GroundSlots
    L8_2 = L8_2(L9_2, L10_2)
    if not L8_2 then
      L9_2 = TriggerClientEvent
      L10_2 = "codem-inventory:client:notification"
      L11_2 = L2_2
      L12_2 = Locales
      L13_2 = Config
      L13_2 = L13_2.Language
      L12_2 = L12_2[L13_2]
      L12_2 = L12_2.notification
      L12_2 = L12_2.NOEMPTYSLOTAVILABLEGROUND
      L9_2(L10_2, L11_2, L12_2)
      return
    end
    L9_2 = tostring
    L10_2 = L8_2
    L9_2 = L9_2(L10_2)
    L8_2 = L9_2
    L8_2.slot = L8_2
    L5_2[L8_2] = L8_2
    L9_2 = ServerGround
    L9_2 = L9_2[A1_2]
    L9_2.inventory = L5_2
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:SetGroundTable"
    L11_2 = -1
    L12_2 = A1_2
    L13_2 = ServerGround
    L13_2 = L13_2[A1_2]
    L13_2 = L13_2.coord
    L14_2 = L5_2
    L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
  else
    L8_2 = FindFirstEmptySlot
    L9_2 = L5_2
    L10_2 = Config
    L10_2 = L10_2.GroundSlots
    L8_2 = L8_2(L9_2, L10_2)
    if not L8_2 then
      L9_2 = TriggerClientEvent
      L10_2 = "codem-inventory:client:notification"
      L11_2 = L2_2
      L12_2 = "No empty slot available in ground inventory"
      L9_2(L10_2, L11_2, L12_2)
      return
    end
    L9_2 = tostring
    L10_2 = L8_2
    L9_2 = L9_2(L10_2)
    L8_2 = L9_2
    L8_2.slot = L8_2
    L5_2[L8_2] = L8_2
    L9_2 = ServerGround
    L9_2 = L9_2[A1_2]
    L9_2.inventory = L5_2
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:SetGroundTable"
    L11_2 = -1
    L12_2 = A1_2
    L13_2 = ServerGround
    L13_2 = L13_2[A1_2]
    L13_2 = L13_2.coord
    L14_2 = L5_2
    L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
  end
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:removeitemtoclientInventory"
  L10_2 = L2_2
  L11_2 = A0_2.oldSlot
  L12_2 = A0_2.oldSlot
  L12_2 = L4_2[L12_2]
  L12_2 = L12_2.amount
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = A0_2.oldSlot
  L4_2[L8_2] = nil
  L8_2 = Config
  L8_2 = L8_2.CashItem
  if L8_2 then
    L8_2 = L6_2.name
    if "cash" == L8_2 then
      L8_2 = GetItemsTotalAmount
      L9_2 = L2_2
      L10_2 = "cash"
      L8_2 = L8_2(L9_2, L10_2)
      L9_2 = GetPlayer
      L10_2 = L2_2
      L9_2 = L9_2(L10_2)
      L10_2 = Config
      L10_2 = L10_2.Framework
      if "qb" ~= L10_2 then
        L10_2 = Config
        L10_2 = L10_2.Framework
        if "oldqb" ~= L10_2 then
          goto lbl_242
        end
      end
      L10_2 = L9_2.Functions
      L10_2 = L10_2.SetMoney
      L11_2 = "cash"
      L12_2 = L8_2
      L10_2(L11_2, L12_2)
      goto lbl_251
      ::lbl_242::
      L10_2 = L9_2.setMoney
      L11_2 = tonumber
      L12_2 = L8_2
      L11_2, L12_2, L13_2, L14_2, L15_2 = L11_2(L12_2)
      L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
  end
  else
    L8_2 = SetInventory
    L9_2 = L2_2
    L8_2(L9_2)
  end
  ::lbl_251::
  L8_2 = Config
  L8_2 = L8_2.UseDiscordWebhooks
  if L8_2 then
    L8_2 = {}
    L9_2 = GetName
    L10_2 = L2_2
    L9_2 = L9_2(L10_2)
    L10_2 = "-"
    L11_2 = L2_2
    L9_2 = L9_2 .. L10_2 .. L11_2
    L8_2.playername = L9_2
    L9_2 = L6_2.label
    L8_2.itemname = L9_2
    L9_2 = L6_2.info
    if not L9_2 then
      L9_2 = nil
    end
    L8_2.info = L9_2
    L9_2 = L6_2.amount
    L8_2.amount = L9_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.INVENTORYTOGROUND
    L8_2.reason = L9_2
    L9_2 = TriggerEvent
    L10_2 = "codem-inventory:CreateLog"
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ADDITEMGROUND
    L12_2 = "green"
    L13_2 = L8_2
    L14_2 = L2_2
    L15_2 = "drop"
    L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  end
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:dropanim"
  L10_2 = L2_2
  L8_2(L9_2, L10_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
function CheckDupliceteItems()
local L0_2, L1_2, L2_2, L3_2
  L0_2 = math
  L0_2 = L0_2.random
  L1_2 = 111111
  L2_2 = 999999
  L0_2 = L0_2(L1_2, L2_2)
  while true do
    L1_2 = ServerGround
    L1_2 = L1_2[L0_2]
    if not L1_2 then
      break
    end
    L1_2 = math
    L1_2 = L1_2.random
    L2_2 = 111111
    L3_2 = 999999
    L1_2 = L1_2(L2_2, L3_2)
    L0_2 = L1_2
  end
  return L0_2
end
GenerateGroundId = CheckDupliceteItems
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:openserverstash"
function fn_L3_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2
  if A2_2 then
    L5_2 = 500
    if not (A2_2 > L5_2) then
      goto lbl_7
    end
  end
  A2_2 = 500
  ::lbl_7::
  if not A3_2 then
    A3_2 = 150000
  end
  L5_2 = ServerStash
  L5_2 = L5_2[A1_2]
  L5_2 = nil ~= L5_2
  if L5_2 then
    L8_2 = ServerStash
    L8_2 = L8_2[A1_2]
    L8_2 = L8_2.inventory
    if L8_2 then
      goto lbl_25
    end
  end
  L8_2 = {}
  ::lbl_25::
  L7_2 = {}
  L7_2.inventory = L8_2
  L7_2.slot = A2_2
  L7_2.maxweight = A3_2
  L7_2.stashId = A1_2
  L7_2.label = A4_2
  if not L5_2 then
    L8_2 = ServerStash
    L9_2 = {}
    L10_2 = {}
    L9_2.inventory = L10_2
    L9_2.stashname = A1_2
    L8_2[A1_2] = L9_2
  end
  L8_2 = UpdateStashDatabase
  L9_2 = A1_2
  L10_2 = L6_2
  L8_2(L9_2, L10_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:openstash"
  L10_2 = A0_2
  L11_2 = L7_2
  L8_2(L9_2, L10_2, L11_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "inventory:server:OpenInventory"
CheckDupliceteItems(L2_1)
CheckDupliceteItems = AddEventHandler
L2_1 = "inventory:server:OpenInventory"
function fn_L3_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  if "traphouse" == A0_2 then
    L3_2 = source
    L4_2 = "STASH"
    L5_2 = A2_2.weight
    if not L5_2 then
      L5_2 = 150000
    end
    L8_2 = A2_2.slots
    if not L8_2 then
      L8_2 = 5
    end
    L7_2 = ServerStash
    L7_2 = L7_2[A1_2]
    L7_2 = nil ~= L7_2
    if L7_2 then
      L8_2 = ServerStash
      L8_2 = L8_2[A1_2]
      L8_2 = L8_2.inventory
      if L8_2 then
        goto lbl_28
      end
    end
    L8_2 = {}
    ::lbl_28::
    L9_2 = {}
    L9_2.inventory = L8_2
    L9_2.slot = L8_2
    L9_2.maxweight = L5_2
    L9_2.stashId = A1_2
    L9_2.label = L4_2
    if not L7_2 then
      L10_2 = ServerStash
      L11_2 = {}
      L12_2 = {}
      L11_2.inventory = L12_2
      L11_2.stashname = A1_2
      L10_2[A1_2] = L11_2
    end
    L10_2 = UpdateStashDatabase
    L11_2 = A1_2
    L12_2 = L8_2
    L10_2(L11_2, L12_2)
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:openstash"
    L12_2 = L3_2
    L13_2 = L9_2
    L10_2(L11_2, L12_2, L13_2)
  elseif "stash" == A0_2 then
    L3_2 = source
    L4_2 = "STASH"
    L5_2 = 60000
    L8_2 = 50
    if A2_2 then
      L7_2 = next
      L8_2 = A2_2
      L7_2 = L7_2(L8_2)
      if nil ~= L7_2 then
        L7_2 = A2_2.maxweight
        L5_2 = L7_2 or L5_2
        if not L7_2 then
          L5_2 = 60000
        end
        L7_2 = A2_2.slots
        L8_2 = L7_2 or L8_2
        if not L7_2 then
          L8_2 = 50
        end
      end
    end
    if "personelstash" == A1_2 then
      L7_2 = GetIdentifier
      L8_2 = L3_2
      L7_2 = L7_2(L8_2)
      A1_2 = L7_2
    end
    L7_2 = ServerStash
    L7_2 = L7_2[A1_2]
    L7_2 = nil ~= L7_2
    if L7_2 then
      L8_2 = ServerStash
      L8_2 = L8_2[A1_2]
      L8_2 = L8_2.inventory
      if L8_2 then
        goto lbl_97
      end
    end
    L8_2 = {}
    ::lbl_97::
    L9_2 = {}
    L9_2.inventory = L8_2
    L9_2.slot = L8_2
    L9_2.maxweight = L5_2
    L9_2.stashId = A1_2
    L9_2.label = L4_2
    if not L7_2 then
      L10_2 = ServerStash
      L11_2 = {}
      L12_2 = {}
      L11_2.inventory = L12_2
      L11_2.stashname = A1_2
      L10_2[A1_2] = L11_2
    end
    L10_2 = UpdateStashDatabase
    L11_2 = A1_2
    L12_2 = L8_2
    L10_2(L11_2, L12_2)
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:openstash"
    L12_2 = L3_2
    L13_2 = L9_2
    L10_2(L11_2, L12_2, L13_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:openstash"
function fn_L3_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  if A1_2 then
    L5_2 = 500
    if not (A1_2 > L5_2) then
      goto lbl_7
    end
  end
  A1_2 = 500
  ::lbl_7::
  if not A2_2 then
    A2_2 = 150000
  end
  L5_2 = tonumber
  L8_2 = source
  L5_2 = L5_2(L6_2)
  L8_2 = ServerPlayerKey
  L7_2 = "CODEM"
  L8_2 = math
  L8_2 = L8_2.random
  L9_2 = 10000
  L10_2 = 999999999
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = "saas"
  L10_2 = math
  L10_2 = L10_2.random
  L11_2 = 10000
  L12_2 = 999999999
  L10_2 = L10_2(L11_2, L12_2)
  L11_2 = "KEY"
  L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2
  L8_2[L5_2] = L7_2
  L8_2 = TriggerClientEvent
  L7_2 = "codem-inventory:client:setkey"
  L8_2 = L5_2
  L9_2 = ServerPlayerKey
  L9_2 = L9_2[L5_2]
  L8_2(L7_2, L8_2, L9_2)
  if "personelstash" == A0_2 then
    L8_2 = GetIdentifier
    L7_2 = L5_2
    L8_2 = L8_2(L7_2)
    A0_2 = L8_2
  end
  L8_2 = ServerStash
  L8_2 = L8_2[A0_2]
  L8_2 = nil ~= L8_2
  if L8_2 then
    L7_2 = ServerStash
    L7_2 = L7_2[A0_2]
    L7_2 = L7_2.inventory
    if L7_2 then
      goto lbl_56
    end
  end
  L7_2 = {}
  ::lbl_56::
  L8_2 = {}
  L8_2.inventory = L7_2
  L8_2.slot = A1_2
  L8_2.maxweight = A2_2
  L8_2.stashId = A0_2
  L8_2.label = A3_2
  if not L8_2 then
    L9_2 = ServerStash
    L10_2 = {}
    L11_2 = {}
    L10_2.inventory = L11_2
    L10_2.stashname = A0_2
    L9_2[A0_2] = L10_2
  end
  L9_2 = UpdateStashDatabase
  L10_2 = A0_2
  L11_2 = L7_2
  L9_2(L10_2, L11_2)
  L9_2 = TriggerClientEvent
  L10_2 = "codem-inventory:client:openstash"
  L11_2 = L5_2
  L12_2 = L8_2
  L9_2(L10_2, L11_2, L12_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:SwapInventoryToStash"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L1_2 = tonumber
  L2_2 = source
  L1_2 = L1_2(L2_2)
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERINVENTORYNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    L4_2 = debugprint
    L5_2 = "D\196\176KKAT ENVANTER BULUNAMADI 614 SATIR"
    L4_2(L5_2)
    return
  end
  L4_2 = tostring
  L5_2 = A0_2.oldSlot
  L4_2 = L4_2(L5_2)
  L4_2 = L3_2[L4_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMNOTFOUNDINGIVENSLOT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = ServerStash
  L8_2 = A0_2.stashId
  L5_2 = L5_2[L6_2]
  L5_2 = L5_2.inventory
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.STASHINVENTORYNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = CheckInventoryWeight
  L7_2 = L5_2
  L8_2 = L4_2.weight
  L9_2 = L4_2.amount
  L8_2 = L8_2 * L9_2
  L9_2 = A0_2.weight
  L8_2 = L8_2(L7_2, L8_2, L9_2)
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.NOEMPTYSLOTAVILABLESTASH
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = L4_2.type
  if "bag" == L8_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.YOUCANNOTPUTABAG
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = FindFirstEmptySlot
  L7_2 = L5_2
  L8_2 = tonumber
  L9_2 = A0_2.maxslot
  L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L8_2(L9_2)
  L8_2 = L8_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.NOEMPTYSLOTAVILABLESTASH
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  if "nil" == L8_2 or nil == L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.NOEMPTYSLOTAVILABLESTASH
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = L4_2.unique
  if not L7_2 then
    L7_2 = tostring
    L8_2 = A0_2.newSlot
    L7_2 = L7_2(L8_2)
    L7_2 = L5_2[L7_2]
    if L7_2 then
      goto lbl_167
    end
  end
  L7_2 = tostring
  L8_2 = L6_2
  L7_2 = L7_2(L8_2)
  L5_2[L7_2] = L4_2
  L7_2 = tostring
  L8_2 = L6_2
  L7_2 = L7_2(L8_2)
  L7_2 = L5_2[L7_2]
  L8_2 = tostring
  L9_2 = L6_2
  L8_2 = L8_2(L9_2)
  L7_2.slot = L8_2
  goto lbl_195
  ::lbl_167::
  L7_2 = FindExistingItemSlot
  L8_2 = L5_2
  L9_2 = L4_2.name
  L7_2 = L7_2(L8_2, L9_2)
  if L7_2 then
    L8_2 = tostring
    L9_2 = L7_2
    L8_2 = L8_2(L9_2)
    L8_2 = L5_2[L8_2]
    L9_2 = L8_2.amount
    L10_2 = L4_2.amount
    L9_2 = L9_2 + L10_2
    L8_2.amount = L9_2
  else
    L8_2 = tostring
    L9_2 = L6_2
    L8_2 = L8_2(L9_2)
    L5_2[L8_2] = L4_2
    L8_2 = tostring
    L9_2 = L6_2
    L8_2 = L8_2(L9_2)
    L8_2 = L5_2[L8_2]
    L9_2 = tostring
    L10_2 = L6_2
    L9_2 = L9_2(L10_2)
    L8_2.slot = L9_2
  end
  ::lbl_195::
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:removeitemtoclientInventory"
  L9_2 = L1_2
  L10_2 = A0_2.oldSlot
  L11_2 = tostring
  L12_2 = A0_2.oldSlot
  L11_2 = L11_2(L12_2)
  L11_2 = L3_2[L11_2]
  L11_2 = L11_2.amount
  L7_2(L8_2, L9_2, L10_2, L11_2)
  L7_2 = tostring
  L8_2 = A0_2.oldSlot
  L7_2 = L7_2(L8_2)
  L3_2[L7_2] = nil
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:UpdateStashItems"
  L9_2 = L1_2
  L10_2 = A0_2.stashId
  L11_2 = L5_2
  L7_2(L8_2, L9_2, L10_2, L11_2)
  L7_2 = Config
  L7_2 = L7_2.CashItem
  if L7_2 then
    L7_2 = L4_2.name
    if "cash" == L7_2 then
      L7_2 = GetItemsTotalAmount
      L8_2 = L1_2
      L9_2 = "cash"
      L7_2 = L7_2(L8_2, L9_2)
      L8_2 = GetPlayer
      L9_2 = L1_2
      L8_2 = L8_2(L9_2)
      L9_2 = Config
      L9_2 = L9_2.Framework
      if "qb" ~= L9_2 then
        L9_2 = Config
        L9_2 = L9_2.Framework
        if "oldqb" ~= L9_2 then
          goto lbl_243
        end
      end
      L9_2 = L8_2.Functions
      L9_2 = L9_2.SetMoney
      L10_2 = "cash"
      L11_2 = L7_2
      L9_2(L10_2, L11_2)
      goto lbl_252
      ::lbl_243::
      L9_2 = L8_2.setMoney
      L10_2 = tonumber
      L11_2 = L7_2
      L10_2, L11_2, L12_2, L13_2, L14_2 = L10_2(L11_2)
      L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
  end
  else
    L7_2 = SetInventory
    L8_2 = L1_2
    L7_2(L8_2)
  end
  ::lbl_252::
  L7_2 = UpdateStashDatabase
  L8_2 = A0_2.stashId
  L9_2 = L5_2
  L7_2(L8_2, L9_2)
  L7_2 = Config
  L7_2 = L7_2.UseDiscordWebhooks
  if L7_2 then
    L7_2 = {}
    L8_2 = GetName
    L9_2 = L1_2
    L8_2 = L8_2(L9_2)
    L9_2 = "-"
    L10_2 = L1_2
    L8_2 = L8_2 .. L9_2 .. L10_2
    L7_2.playername = L8_2
    L8_2 = L4_2.label
    L7_2.itemname = L8_2
    L8_2 = L4_2.amount
    L7_2.amount = L8_2
    L8_2 = L4_2.info
    if not L8_2 then
      L8_2 = nil
    end
    L7_2.info = L8_2
    L8_2 = "Stash Name: "
    L9_2 = A0_2.stashId
    L10_2 = " "
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.INVENTORYTOSTASH
    L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2
    L7_2.reason = L8_2
    L8_2 = TriggerEvent
    L9_2 = "codem-inventory:CreateLog"
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.ADDITEMSTASH
    L11_2 = "green"
    L12_2 = L7_2
    L13_2 = L1_2
    L14_2 = "stash"
    L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:swapStashToInventory"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = ServerStash
  L4_2 = A0_2.stashId
  L3_2 = L3_2[L4_2]
  L3_2 = L3_2.inventory
  L4_2 = A0_2.oldSlot
  L4_2 = L3_2[L4_2]
  L5_2 = PlayerServerInventory
  L5_2 = L5_2[L2_2]
  if L5_2 then
    L5_2 = PlayerServerInventory
    L5_2 = L5_2[L2_2]
    L5_2 = L5_2.inventory
  end
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.PLAYERINVENTORYNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    L8_2 = debugprint
    L7_2 = "D\196\176KKAT ENVANTER BULUNAMADI 700 SATIR"
    L8_2(L7_2)
    return
  end
  if not L4_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = CheckInventoryWeight
  L7_2 = L5_2
  L8_2 = L4_2.weight
  L9_2 = L4_2.amount
  L8_2 = L8_2 * L9_2
  L9_2 = Config
  L9_2 = L9_2.MaxWeight
  L8_2 = L8_2(L7_2, L8_2, L9_2)
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.INVENTORYISFULL
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  function L8_2(A0_3, A1_3)
local L2_3, L3_3, L4_3, L5_3, L6_3
    L2_3 = L5_2
    L2_3 = L2_3[A0_3]
    if L2_3 then
      L2_3 = L5_2
      L2_3 = L2_3[A0_3]
      L2_3 = L2_3.name
      L3_3 = A1_3.name
      if L2_3 == L3_3 then
        L2_3 = A1_3.unique
        if not L2_3 then
          L2_3 = L5_2
          L2_3 = L2_3[A0_3]
          L3_3 = L5_2
          L3_3 = L3_3[A0_3]
          L3_3 = L3_3.amount
          L4_3 = A1_3.amount
          L3_3 = L3_3 + L4_3
          L2_3.amount = L3_3
      end
    end
    else
      L2_3 = A1_3.unique
      if L2_3 then
        L2_3 = FindFirstEmptySlot
        L3_3 = L5_2
        L4_3 = Config
        L4_3 = L4_3.MaxSlots
        L2_3 = L2_3(L3_3, L4_3)
        A0_3 = L2_3
        if not A0_3 then
          L2_3 = TriggerClientEvent
          L3_3 = "codem-inventory:client:notification"
          L4_3 = L1_2
          L5_3 = Locales
          L6_3 = Config
          L6_3 = L6_3.Language
          L5_3 = L5_3[L6_3]
          L5_3 = L5_3.notification
          L5_3 = L5_3.NOEMPTYSLOTAVILABLEYOUR
          L2_3(L3_3, L4_3, L5_3)
          L2_3 = false
          return L2_3
        end
        L2_3 = tostring
        L3_3 = A0_3
        L2_3 = L2_3(L3_3)
        A0_3 = L2_3
        A1_3.slot = A0_3
        L2_3 = L5_2
        L2_3[A0_3] = A1_3
        L2_3 = L5_2
        L2_3 = L2_3[A0_3]
        L2_3.slot = A0_3
      else
        L2_3 = FindFirstEmptySlot
        L3_3 = L5_2
        L4_3 = Config
        L4_3 = L4_3.MaxSlots
        L2_3 = L2_3(L3_3, L4_3)
        A0_3 = L2_3
        if not A0_3 then
          L2_3 = TriggerClientEvent
          L3_3 = "codem-inventory:client:notification"
          L4_3 = L1_2
          L5_3 = Locales
          L6_3 = Config
          L6_3 = L6_3.Language
          L5_3 = L5_3[L6_3]
          L5_3 = L5_3.notification
          L5_3 = L5_3.NOEMPTYSLOTAVILABLEYOUR
          L2_3(L3_3, L4_3, L5_3)
          L2_3 = false
          return L2_3
        end
        L2_3 = tostring
        L3_3 = A0_3
        L2_3 = L2_3(L3_3)
        A0_3 = L2_3
        A1_3.slot = A0_3
        L2_3 = L5_2
        L2_3[A0_3] = A1_3
        L2_3 = L5_2
        L2_3 = L2_3[A0_3]
        L2_3.slot = A0_3
      end
    end
    return A0_3
  end
  L7_2 = L6_2
  L8_2 = A0_2.newSlot
  L9_2 = L4_2
  L7_2 = L7_2(L8_2, L9_2)
  if not L7_2 then
    return
  end
  L8_2 = tostring
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L7_2 = L8_2
  L8_2 = A0_2.oldSlot
  L3_2[L8_2] = nil
  L8_2 = Config
  L8_2 = L8_2.CashItem
  if L8_2 then
    L8_2 = L4_2.name
    if "cash" == L8_2 then
      L8_2 = AddMoney
      L9_2 = L1_2
      L10_2 = "cash"
      L11_2 = L4_2.amount
      L8_2(L9_2, L10_2, L11_2)
  end
  else
    L8_2 = SetInventory
    L9_2 = L1_2
    L8_2(L9_2)
  end
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:additem"
  L10_2 = L1_2
  L11_2 = L7_2
  L12_2 = L5_2[L7_2]
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:UpdateStashItems"
  L10_2 = L1_2
  L11_2 = A0_2.stashId
  L12_2 = L3_2
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = UpdateStashDatabase
  L9_2 = A0_2.stashId
  L10_2 = L3_2
  L8_2(L9_2, L10_2)
  L8_2 = SetInventory
  L9_2 = L1_2
  L8_2(L9_2)
  L8_2 = Config
  L8_2 = L8_2.UseDiscordWebhooks
  if L8_2 then
    L8_2 = {}
    L9_2 = GetName
    L10_2 = L1_2
    L9_2 = L9_2(L10_2)
    L10_2 = "-"
    L11_2 = L1_2
    L9_2 = L9_2 .. L10_2 .. L11_2
    L8_2.playername = L9_2
    L9_2 = L4_2.label
    L8_2.itemname = L9_2
    L9_2 = L4_2.amount
    L8_2.amount = L9_2
    L9_2 = L4_2.info
    if not L9_2 then
      L9_2 = nil
    end
    L8_2.info = L9_2
    L9_2 = "Stash Name: "
    L10_2 = A0_2.stashId
    L11_2 = " "
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.STASHTOINVENTORY
    L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2
    L8_2.reason = L9_2
    L9_2 = TriggerEvent
    L10_2 = "codem-inventory:CreateLog"
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ADDITEMS
    L12_2 = "green"
    L13_2 = L8_2
    L14_2 = L1_2
    L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:swapStashToStash"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L1_2 = source
  L2_2 = cooldown
  L2_2 = L2_2[L1_2]
  if L2_2 then
    return
  else
    L2_2 = cooldown
    L2_2[L1_2] = true
    L2_2 = SetTimeout
    L3_2 = 400
    function L4_2()
local cooldown, L1_3
      cooldown = cooldown
      L1_3 = L1_2
      cooldown[L1_3] = nil
    end
    L2_2(L3_2, L4_2)
  end
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = A0_2.stashId
  L4_2 = tostring
  L5_2 = A0_2.oldSlot
  L4_2 = L4_2(L5_2)
  L5_2 = tostring
  L8_2 = A0_2.newSlot
  L5_2 = L5_2(L6_2)
  L8_2 = ServerStash
  L8_2 = L8_2[L3_2]
  if L8_2 then
    L8_2 = ServerStash
    L8_2 = L8_2[L3_2]
    L8_2 = L8_2.inventory
  end
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.STASHINVENTORYNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = L6_2[L4_2]
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = L6_2[L5_2]
  if L8_2 then
    L9_2 = L7_2.name
    L10_2 = L8_2.name
    if L9_2 ~= L10_2 then
      goto lbl_99
    end
    L9_2 = L7_2.unique
    if L9_2 then
      goto lbl_99
    end
  end
  if L8_2 then
    L9_2 = L7_2.name
    L10_2 = L8_2.name
    if L9_2 == L10_2 then
      L9_2 = L6_2[L5_2]
      L10_2 = L6_2[L5_2]
      L10_2 = L10_2.amount
      L11_2 = L7_2.amount
      L10_2 = L10_2 + L11_2
      L9_2.amount = L10_2
  end
  else
    L8_2[L5_2] = L7_2
    L9_2 = L6_2[L5_2]
    L9_2.slot = L5_2
  end
  L8_2[L4_2] = nil
  goto lbl_107
  ::lbl_99::
  L9_2 = L6_2[L5_2]
  L10_2 = L6_2[L4_2]
  L8_2[L5_2] = L10_2
  L8_2[L4_2] = L9_2
  L9_2 = L6_2[L4_2]
  L9_2.slot = L4_2
  L9_2 = L6_2[L5_2]
  L9_2.slot = L5_2
  ::lbl_107::
  L9_2 = UpdateStashDatabase
  L10_2 = L3_2
  L11_2 = L6_2
  L9_2(L10_2, L11_2)
  L9_2 = TriggerClientEvent
  L10_2 = "codem-inventory:UpdateStashItems"
  L11_2 = L1_2
  L12_2 = L3_2
  L13_2 = L6_2
  L9_2(L10_2, L11_2, L12_2, L13_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
function CheckDupliceteItems(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2
  L2_2 = [[
            INSERT INTO codem_new_stash (stashname, inventory) VALUES (@stashname, @inventory) ON DUPLICATE KEY UPDATE inventory = @inventory
    ]]
  L3_2 = {}
  L3_2["@stashname"] = A0_2
  L4_2 = json
  L4_2 = L4_2.encode
  L5_2 = A1_2
  L4_2 = L4_2(L5_2)
  L3_2["@inventory"] = L4_2
  L4_2 = pcall
  function L5_2()
local cooldown, L1_3, L2_3
    updateinventorysql = UpdateInventorySql
    L1_3 = L2_2
    L2_3 = L3_2
    updateinventorysql(L1_3, L2_3)
  end
  L4_2, L5_2 = L4_2(L5_2)
  if not L4_2 then
    L8_2 = print
    L7_2 = "Error updating stash database: "
    L8_2 = L5_2
    L7_2 = L7_2 .. L8_2
    L8_2(L7_2)
  end
end
UpdateStashDatabase = CheckDupliceteItems
function CheckDupliceteItems(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2
  L2_2 = pairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L8_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L7_2.name
    if L8_2 == A1_2 then
      return L8_2
    end
  end
  L2_2 = nil
  return L2_2
end
FindExistingItemSlot = CheckDupliceteItems
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:openVehicleGlovebox"
function fn_L3_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L4_2 = source
  L5_2 = ServerPlayerKey
  L8_2 = "CODEM"
  L7_2 = math
  L7_2 = L7_2.random
  L8_2 = 10000
  L9_2 = 999999999
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = "saas"
  L9_2 = math
  L9_2 = L9_2.random
  L10_2 = 10000
  L11_2 = 999999999
  L9_2 = L9_2(L10_2, L11_2)
  L10_2 = "KEY"
  L8_2 = L8_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2
  L5_2[L4_2] = L8_2
  L5_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:setkey"
  L7_2 = L4_2
  L8_2 = ServerPlayerKey
  L8_2 = L8_2[L4_2]
  L5_2(L8_2, L7_2, L8_2)
  if not A0_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L4_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.VEHICLEPLATENOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = customToLower
  L8_2 = A0_2
  L5_2 = L5_2(L6_2)
  A0_2 = L5_2
  L5_2 = GloveBoxInventory
  L5_2 = L5_2[A0_2]
  if not L5_2 then
    L5_2 = GloveBoxInventory
    L8_2 = {}
    L7_2 = {}
    L8_2.glovebox = L7_2
    L8_2.plate = A0_2
    L7_2 = A1_2 or L7_2
    if not A1_2 then
      L7_2 = 0
    end
    L8_2.maxweight = L7_2
    L7_2 = A2_2 or L7_2
    if not A2_2 then
      L7_2 = 0
    end
    L8_2.slot = L7_2
    L5_2[A0_2] = L8_2
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:newVehicleGloveboxPlateInsert"
    L7_2 = -1
    L8_2 = A0_2
    L9_2 = A1_2
    L10_2 = A2_2
    L5_2(L8_2, L7_2, L8_2, L9_2, L10_2)
  end
  L5_2 = {}
  L8_2 = GloveBoxInventory
  L8_2 = L8_2[A0_2]
  L8_2 = L8_2.glovebox
  L5_2.glovebox = L8_2
  L8_2 = GloveBoxInventory
  L8_2 = L8_2[A0_2]
  L8_2 = L8_2.slot
  L5_2.slot = L8_2
  L8_2 = GloveBoxInventory
  L8_2 = L8_2[A0_2]
  L8_2 = L8_2.maxweight
  L5_2.maxweight = L8_2
  L5_2.plate = A0_2
  L8_2 = TriggerClientEvent
  L7_2 = "codem-inventory:client:openVehicleGlovebox"
  L8_2 = L4_2
  L9_2 = L5_2
  L8_2(L7_2, L8_2, L9_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:SwapInventoryToVehicleGlovebox"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tostring
  L4_2 = A0_2.newSlot
  L3_2 = L3_2(L4_2)
  A0_2.newSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.oldSlot
  L3_2 = L3_2(L4_2)
  A0_2.oldSlot = L3_2
  L3_2 = customToLower
  L4_2 = A0_2.plate
  L3_2 = L3_2(L4_2)
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L2_2]
  if L4_2 then
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L2_2]
    L4_2 = L4_2.inventory
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERINVENTORYNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    L5_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 880 SATIR"
    L5_2(L8_2)
    return
  end
  L5_2 = A0_2.oldSlot
  L5_2 = L4_2[L5_2]
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = GloveBoxInventory
  L8_2 = L8_2[L3_2]
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.VEHICLEPLATENOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = GloveBoxInventory
  L8_2 = L8_2[L3_2]
  L8_2 = L8_2.glovebox
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.NOEMPTYSLOTAVILABLEVEHICLE
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = FindFirstEmptySlot
  L8_2 = L6_2
  L9_2 = tonumber
  L10_2 = A0_2.maxslot
  L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L9_2(L10_2)
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = "No empty slot available in the glovebox inventory"
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = tostring
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L7_2 = L8_2
  L8_2 = A0_2.oldSlot
  L8_2 = L4_2[L8_2]
  L8_2 = L8_2.amount
  if not L8_2 then
    L8_2 = 1
  end
  L9_2 = A0_2.newSlot
  L9_2 = L6_2[L9_2]
  L10_2 = CheckInventoryWeight
  L11_2 = L6_2
  L12_2 = L5_2.weight
  L13_2 = L5_2.amount
  L12_2 = L12_2 * L13_2
  L13_2 = A0_2.weight
  L10_2 = L10_2(L11_2, L12_2, L13_2)
  if not L10_2 then
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:notification"
    L12_2 = L1_2
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.NOEMPTYSLOTAVILABLEVEHICLEINVENTORY
    L10_2(L11_2, L12_2, L13_2)
    return
  end
  if L9_2 then
    L10_2 = L5_2.unique
    if not L10_2 then
      L10_2 = L9_2.unique
      if not L10_2 then
        goto lbl_164
      end
    end
    L5_2.slot = L7_2
    L8_2[L7_2] = L5_2
    L10_2 = A0_2.oldSlot
    L4_2[L10_2] = nil
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:updateVehicleGloveBoxItem"
    L12_2 = -1
    L13_2 = L3_2
    L14_2 = L7_2
    L15_2 = L6_2[L7_2]
    L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
    goto lbl_196
    ::lbl_164::
    L10_2 = L5_2.name
    L11_2 = L9_2.name
    if L10_2 == L11_2 then
      L10_2 = L9_2.amount
      L11_2 = L5_2.amount
      L10_2 = L10_2 + L11_2
      L9_2.amount = L10_2
      L10_2 = A0_2.oldSlot
      L4_2[L10_2] = nil
      L10_2 = TriggerClientEvent
      L11_2 = "codem-inventory:client:updateVehicleGloveBoxItem"
      L12_2 = -1
      L13_2 = L3_2
      L14_2 = A0_2.newSlot
      L15_2 = A0_2.newSlot
      L15_2 = L6_2[L15_2]
      L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
    else
      L5_2.slot = L7_2
      L8_2[L7_2] = L5_2
      L10_2 = A0_2.oldSlot
      L4_2[L10_2] = nil
      A0_2.newSlot = L7_2
    end
  else
    L10_2 = A0_2.newSlot
    L5_2.slot = L10_2
    L10_2 = A0_2.newSlot
    L8_2[L10_2] = L5_2
    L10_2 = A0_2.oldSlot
    L4_2[L10_2] = nil
  end
  ::lbl_196::
  L10_2 = Config
  L10_2 = L10_2.CashItem
  if L10_2 then
    L10_2 = L5_2.name
    if "cash" == L10_2 then
      L10_2 = GetItemsTotalAmount
      L11_2 = L1_2
      L12_2 = "cash"
      L10_2 = L10_2(L11_2, L12_2)
      L11_2 = GetPlayer
      L12_2 = L1_2
      L11_2 = L11_2(L12_2)
      L12_2 = Config
      L12_2 = L12_2.Framework
      if "qb" ~= L12_2 then
        L12_2 = Config
        L12_2 = L12_2.Framework
        if "oldqb" ~= L12_2 then
          goto lbl_224
        end
      end
      L12_2 = L11_2.Functions
      L12_2 = L12_2.SetMoney
      L13_2 = "cash"
      L14_2 = L10_2
      L12_2(L13_2, L14_2)
      goto lbl_233
      ::lbl_224::
      L12_2 = L11_2.setMoney
      L13_2 = tonumber
      L14_2 = L10_2
      L13_2, L14_2, L15_2, L16_2, L17_2 = L13_2(L14_2)
      L12_2(L13_2, L14_2, L15_2, L16_2, L17_2)
  end
  else
    L10_2 = SetInventory
    L11_2 = L1_2
    L10_2(L11_2)
  end
  ::lbl_233::
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:notification"
  L12_2 = L1_2
  L13_2 = "Item moved successfully."
  L10_2(L11_2, L12_2, L13_2)
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:updateVehicleGloveBoxItem"
  L12_2 = -1
  L13_2 = L3_2
  L14_2 = A0_2.newSlot
  L15_2 = tostring
  L16_2 = A0_2.newSlot
  L15_2 = L15_2(L16_2)
  L15_2 = L6_2[L15_2]
  L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:removeitemtoclientInventory"
  L12_2 = L1_2
  L13_2 = A0_2.oldSlot
  L14_2 = L8_2
  L10_2(L11_2, L12_2, L13_2, L14_2)
  L10_2 = UpdateVehicleGlovebox
  L11_2 = L3_2
  L12_2 = L6_2
  L10_2(L11_2, L12_2)
  L10_2 = Config
  L10_2 = L10_2.UseDiscordWebhooks
  if L10_2 then
    L10_2 = {}
    L11_2 = GetName
    L12_2 = L1_2
    L11_2 = L11_2(L12_2)
    L12_2 = "-"
    L13_2 = L1_2
    L11_2 = L11_2 .. L12_2 .. L13_2
    L10_2.playername = L11_2
    L11_2 = L5_2.label
    L10_2.itemname = L11_2
    L11_2 = L5_2.amount
    L10_2.amount = L11_2
    L11_2 = L5_2.info
    if not L11_2 then
      L11_2 = nil
    end
    L10_2.info = L11_2
    L11_2 = "Plate : "
    L12_2 = A0_2.plate
    L13_2 = " "
    L14_2 = Locales
    L15_2 = Config
    L15_2 = L15_2.Language
    L14_2 = L14_2[L15_2]
    L14_2 = L14_2.notification
    L14_2 = L14_2.INVENTORYTOGLOVEBOX
    L11_2 = L11_2 .. L12_2 .. L13_2 .. L14_2
    L10_2.reason = L11_2
    L11_2 = TriggerEvent
    L12_2 = "codem-inventory:CreateLog"
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.ADDITEMGLOVEBOX
    L14_2 = "green"
    L15_2 = L10_2
    L16_2 = L1_2
    L17_2 = "glovebox"
    L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:openVehicleTrunk"
function fn_L3_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L4_2 = source
  L5_2 = ServerPlayerKey
  L8_2 = "CODEM"
  L7_2 = math
  L7_2 = L7_2.random
  L8_2 = 10000
  L9_2 = 999999999
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = "saas"
  L9_2 = math
  L9_2 = L9_2.random
  L10_2 = 10000
  L11_2 = 999999999
  L9_2 = L9_2(L10_2, L11_2)
  L10_2 = "KEY"
  L8_2 = L8_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2
  L5_2[L4_2] = L8_2
  L5_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:setkey"
  L7_2 = L4_2
  L8_2 = ServerPlayerKey
  L8_2 = L8_2[L4_2]
  L5_2(L8_2, L7_2, L8_2)
  if not A0_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L4_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.VEHICLEPLATENOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = customToLower
  L8_2 = A0_2
  L5_2 = L5_2(L6_2)
  A0_2 = L5_2
  L5_2 = string
  L5_2 = L5_2.lower
  L8_2 = string
  L8_2 = L8_2.gsub
  L7_2 = A0_2
  L8_2 = "%s+"
  L9_2 = ""
  L8_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L8_2(L7_2, L8_2, L9_2)
  L5_2 = L5_2(L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  L8_2 = VehicleInventory
  L8_2 = L8_2[L5_2]
  if not L8_2 then
    L8_2 = VehicleInventory
    L7_2 = {}
    L8_2 = {}
    L7_2.glovebox = L8_2
    L8_2 = {}
    L7_2.trunk = L8_2
    L7_2.plate = L5_2
    L8_2 = A1_2 or L8_2
    if not A1_2 then
      L8_2 = 0
    end
    L7_2.maxweight = L8_2
    L8_2 = A2_2 or L8_2
    if not A2_2 then
      L8_2 = 0
    end
    L7_2.slot = L8_2
    L8_2[L5_2] = L7_2
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:newVehiclePlateInsert"
    L8_2 = -1
    L9_2 = L5_2
    L10_2 = A1_2
    L11_2 = A2_2
    L8_2(L7_2, L8_2, L9_2, L10_2, L11_2)
  end
  L8_2 = {}
  L7_2 = VehicleInventory
  L7_2 = L7_2[L5_2]
  L7_2 = L7_2.trunk
  L8_2.trunk = L7_2
  L7_2 = VehicleInventory
  L7_2 = L7_2[L5_2]
  L7_2 = L7_2.slot
  L8_2.slot = L7_2
  L7_2 = VehicleInventory
  L7_2 = L7_2[L5_2]
  L7_2 = L7_2.maxweight
  L8_2.maxweight = L7_2
  L8_2.plate = L5_2
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:openVehicleTrunk"
  L9_2 = L4_2
  L10_2 = L6_2
  L7_2(L8_2, L9_2, L10_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:SwapInventoryToVehicleTrunk"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tostring
  L4_2 = A0_2.newSlot
  L3_2 = L3_2(L4_2)
  A0_2.newSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.oldSlot
  L3_2 = L3_2(L4_2)
  A0_2.oldSlot = L3_2
  L3_2 = customToLower
  L4_2 = A0_2.plate
  L3_2 = L3_2(L4_2)
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L2_2]
  if L4_2 then
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L2_2]
    L4_2 = L4_2.inventory
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERINVENTORYNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    L5_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1006 SATIR"
    L5_2(L8_2)
    return
  end
  L5_2 = A0_2.oldSlot
  L5_2 = L4_2[L5_2]
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = VehicleInventory
  L8_2 = L8_2[L3_2]
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.VEHICLEPLATENOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = VehicleInventory
  L8_2 = L8_2[L3_2]
  L8_2 = L8_2.trunk
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.NOEMPTYSLOTAVILABLEVEHICLE
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = FindFirstEmptySlot
  L8_2 = L6_2
  L9_2 = tonumber
  L10_2 = A0_2.maxslot
  L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L9_2(L10_2)
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.NOEMPTYSLOTAVILABLEVEHICLEINVENTORY
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = tostring
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L7_2 = L8_2
  L8_2 = A0_2.oldSlot
  L8_2 = L4_2[L8_2]
  L8_2 = L8_2.amount
  if not L8_2 then
    L8_2 = 1
  end
  L9_2 = A0_2.newSlot
  L9_2 = L6_2[L9_2]
  L10_2 = CheckInventoryWeight
  L11_2 = L6_2
  L12_2 = L5_2.weight
  L13_2 = L5_2.amount
  L12_2 = L12_2 * L13_2
  L13_2 = A0_2.weight
  L10_2 = L10_2(L11_2, L12_2, L13_2)
  if not L10_2 then
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:notification"
    L12_2 = L1_2
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.NOEMPTYSLOTAVILABLEVEHICLEINVENTORY
    L10_2(L11_2, L12_2, L13_2)
    return
  end
  if L9_2 then
    L10_2 = L5_2.unique
    if not L10_2 then
      L10_2 = L9_2.unique
      if not L10_2 then
        goto lbl_169
      end
    end
    L5_2.slot = L7_2
    L8_2[L7_2] = L5_2
    L10_2 = A0_2.oldSlot
    L4_2[L10_2] = nil
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:updateVehicleTrunkItem"
    L12_2 = -1
    L13_2 = L3_2
    L14_2 = L7_2
    L15_2 = L6_2[L7_2]
    L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
    goto lbl_201
    ::lbl_169::
    L10_2 = L9_2.name
    L11_2 = L5_2.name
    if L10_2 == L11_2 then
      L10_2 = L9_2.amount
      L11_2 = L5_2.amount
      L10_2 = L10_2 + L11_2
      L9_2.amount = L10_2
      L10_2 = A0_2.oldSlot
      L4_2[L10_2] = nil
      L10_2 = TriggerClientEvent
      L11_2 = "codem-inventory:client:updateVehicleTrunkItem"
      L12_2 = -1
      L13_2 = L3_2
      L14_2 = A0_2.newSlot
      L15_2 = A0_2.newSlot
      L15_2 = L6_2[L15_2]
      L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
    else
      L5_2.slot = L7_2
      L8_2[L7_2] = L5_2
      L10_2 = A0_2.oldSlot
      L4_2[L10_2] = nil
      A0_2.newSlot = L7_2
    end
  else
    L10_2 = A0_2.newSlot
    L5_2.slot = L10_2
    L10_2 = A0_2.newSlot
    L8_2[L10_2] = L5_2
    L10_2 = A0_2.oldSlot
    L4_2[L10_2] = nil
  end
  ::lbl_201::
  L10_2 = UpdateVehicleInventory
  L11_2 = L3_2
  L12_2 = L6_2
  L10_2(L11_2, L12_2)
  L10_2 = Config
  L10_2 = L10_2.CashItem
  if L10_2 then
    L10_2 = L5_2.name
    if "cash" == L10_2 then
      L10_2 = GetItemsTotalAmount
      L11_2 = L1_2
      L12_2 = "cash"
      L10_2 = L10_2(L11_2, L12_2)
      L11_2 = GetPlayer
      L12_2 = L1_2
      L11_2 = L11_2(L12_2)
      L12_2 = Config
      L12_2 = L12_2.Framework
      if "qb" ~= L12_2 then
        L12_2 = Config
        L12_2 = L12_2.Framework
        if "oldqb" ~= L12_2 then
          goto lbl_233
        end
      end
      L12_2 = L11_2.Functions
      L12_2 = L12_2.SetMoney
      L13_2 = "cash"
      L14_2 = L10_2
      L12_2(L13_2, L14_2)
      goto lbl_242
      ::lbl_233::
      L12_2 = L11_2.setMoney
      L13_2 = tonumber
      L14_2 = L10_2
      L13_2, L14_2, L15_2, L16_2, L17_2 = L13_2(L14_2)
      L12_2(L13_2, L14_2, L15_2, L16_2, L17_2)
  end
  else
    L10_2 = SetInventory
    L11_2 = L1_2
    L10_2(L11_2)
  end
  ::lbl_242::
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:updateVehicleTrunkItem"
  L12_2 = -1
  L13_2 = L3_2
  L14_2 = A0_2.newSlot
  L15_2 = tostring
  L16_2 = A0_2.newSlot
  L15_2 = L15_2(L16_2)
  L15_2 = L6_2[L15_2]
  L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:removeitemtoclientInventory"
  L12_2 = L1_2
  L13_2 = A0_2.oldSlot
  L14_2 = L8_2
  L10_2(L11_2, L12_2, L13_2, L14_2)
  L10_2 = Config
  L10_2 = L10_2.UseDiscordWebhooks
  if L10_2 then
    L10_2 = {}
    L11_2 = GetName
    L12_2 = L1_2
    L11_2 = L11_2(L12_2)
    L12_2 = "-"
    L13_2 = L1_2
    L11_2 = L11_2 .. L12_2 .. L13_2
    L10_2.playername = L11_2
    L11_2 = L5_2.label
    L10_2.itemname = L11_2
    L11_2 = L5_2.amount
    L10_2.amount = L11_2
    L11_2 = L5_2.info
    if not L11_2 then
      L11_2 = nil
    end
    L10_2.info = L11_2
    L11_2 = "Plate : "
    L12_2 = L3_2
    L13_2 = " "
    L14_2 = Locales
    L15_2 = Config
    L15_2 = L15_2.Language
    L14_2 = L14_2[L15_2]
    L14_2 = L14_2.notification
    L14_2 = L14_2.INVENTORYTOTRUNK
    L11_2 = L11_2 .. L12_2 .. L13_2 .. L14_2
    L10_2.reason = L11_2
    L11_2 = TriggerEvent
    L12_2 = "codem-inventory:CreateLog"
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.ADDITEMTRUNK
    L14_2 = "green"
    L15_2 = L10_2
    L16_2 = L1_2
    L17_2 = "trunk"
    L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
function CheckDupliceteItems(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2
  L2_2 = string
  L2_2 = L2_2.lower
  L3_2 = string
  L3_2 = L3_2.gsub
  L4_2 = A0_2
  L5_2 = "%s+"
  L8_2 = ""
  L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2 = L3_2(L4_2, L5_2, L8_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  L3_2 = [[
        INSERT INTO codem_new_vehicleandglovebox (plate, trunk) VALUES (@plate, @trunk) ON DUPLICATE KEY UPDATE plate = @plate, trunk = @trunk
    ]]
  L4_2 = {}
  L4_2["@plate"] = L2_2
  L5_2 = json
  L5_2 = L5_2.encode
  L8_2 = A1_2
  L5_2 = L5_2(L6_2)
  L4_2["@trunk"] = L5_2
  L5_2 = pcall
  function L8_2()
local updateinventorysql, L1_3, L2_3
    updateinventorysql = UpdateInventorySql
    L1_3 = L3_2
    L2_3 = L4_2
    updateinventorysql(L1_3, L2_3)
  end
  L5_2, L8_2 = L5_2(L8_2)
  if not L5_2 then
    L7_2 = print
    L8_2 = "UpdateVehicleInventory Error: "
    L9_2 = L6_2
    L8_2 = L8_2 .. L9_2
    L7_2(L8_2)
  end
end
UpdateVehicleInventory = CheckDupliceteItems
function CheckDupliceteItems(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2
  L2_2 = string
  L2_2 = L2_2.lower
  L3_2 = string
  L3_2 = L3_2.gsub
  L4_2 = A0_2
  L5_2 = "%s+"
  L8_2 = ""
  L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2 = L3_2(L4_2, L5_2, L8_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2)
  L3_2 = [[
        INSERT INTO codem_new_vehicleandglovebox (plate, glovebox) VALUES (@plate, @glovebox) ON DUPLICATE KEY UPDATE plate = @plate, glovebox = @glovebox
    ]]
  L4_2 = {}
  L4_2["@plate"] = L2_2
  L5_2 = json
  L5_2 = L5_2.encode
  L8_2 = A1_2
  L5_2 = L5_2(L6_2)
  L4_2["@glovebox"] = L5_2
  L5_2 = pcall
  function L8_2()
local updateinventorysql, L1_3, L2_3
    updateinventorysql = UpdateInventorySql
    L1_3 = L3_2
    L2_3 = L4_2
    updateinventorysql(L1_3, L2_3)
  end
  L5_2, L8_2 = L5_2(L8_2)
  if not L5_2 then
    L7_2 = print
    L8_2 = "UpdateVehicleGlovebox Error: "
    L9_2 = L6_2
    L8_2 = L8_2 .. L9_2
    L7_2(L8_2)
  end
end
UpdateVehicleGlovebox = CheckDupliceteItems
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:swapVehicleTrunkToInventory"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tostring
  L4_2 = A0_2.newSlot
  L3_2 = L3_2(L4_2)
  A0_2.newSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.oldSlot
  L3_2 = L3_2(L4_2)
  A0_2.oldSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.plate
  L3_2 = L3_2(L4_2)
  L4_2 = VehicleInventory
  L4_2 = L4_2[L3_2]
  if L4_2 then
    L4_2 = VehicleInventory
    L4_2 = L4_2[L3_2]
    L4_2 = L4_2.trunk
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.NOEMPTYSLOTAVILABLEVEHICLE
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = A0_2.oldSlot
  L5_2 = L4_2[L5_2]
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  if L5_2 then
    L8_2 = L5_2.type
    if "bag" == L8_2 then
      L8_2 = CheckBagItem
      L7_2 = L1_2
      L8_2 = L8_2(L7_2)
      L7_2 = tonumber
      L8_2 = L6_2
      L7_2 = L7_2(L8_2)
      L8_2 = tonumber
      L9_2 = Config
      L9_2 = L9_2.MaxBackPackItem
      L8_2 = L8_2(L9_2)
      if L7_2 > L8_2 then
        L7_2 = TriggerClientEvent
        L8_2 = "codem-inventory:client:notification"
        L9_2 = L1_2
        L10_2 = Locales
        L11_2 = Config
        L11_2 = L11_2.Language
        L10_2 = L10_2[L11_2]
        L10_2 = L10_2.notification
        L10_2 = L10_2.MAXBAGPACKITEM
        L7_2(L8_2, L9_2, L10_2)
        return
      end
    end
  end
  L8_2 = PlayerServerInventory
  L8_2 = L8_2[L2_2]
  if L8_2 then
    L8_2 = PlayerServerInventory
    L8_2 = L8_2[L2_2]
    L8_2 = L8_2.inventory
  end
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.PLAYERINVENTORYNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    L7_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1132 SATIR"
    L7_2(L8_2)
    return
  end
  L7_2 = FindFirstEmptySlot
  L8_2 = L6_2
  L9_2 = Config
  L9_2 = L9_2.MaxSlots
  L7_2 = L7_2(L8_2, L9_2)
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.NOEMPTYSLOTAVILABLEYOUR
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = CheckInventoryWeight
  L9_2 = L6_2
  L10_2 = L5_2.weight
  L11_2 = L5_2.amount
  L10_2 = L10_2 * L11_2
  L11_2 = Config
  L11_2 = L11_2.MaxWeight
  L8_2 = L8_2(L9_2, L10_2, L11_2)
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.INVENTORYISFULL
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = tostring
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L7_2 = L8_2
  L8_2 = A0_2.newSlot
  L8_2 = L6_2[L8_2]
  if not L8_2 then
    L8_2 = A0_2.newSlot
    L5_2.slot = L8_2
    L8_2 = A0_2.newSlot
    L8_2[L8_2] = L5_2
  else
    L8_2 = A0_2.newSlot
    L8_2 = L6_2[L8_2]
    L8_2 = L8_2.name
    L9_2 = L5_2.name
    if L8_2 == L9_2 then
      L8_2 = L5_2.unique
      if not L8_2 then
        L8_2 = A0_2.oldSlot
        L8_2 = L6_2[L8_2]
        if not L8_2 then
          goto lbl_189
        end
        L8_2 = A0_2.oldSlot
        L8_2 = L6_2[L8_2]
        L8_2 = L8_2.unique
        if not L8_2 then
          goto lbl_189
        end
      end
      L5_2.slot = L7_2
      L8_2[L7_2] = L5_2
      A0_2.newSlot = L7_2
      goto lbl_224
      ::lbl_189::
      L8_2 = A0_2.newSlot
      L8_2 = L6_2[L8_2]
      L9_2 = A0_2.newSlot
      L9_2 = L6_2[L9_2]
      L9_2 = L9_2.amount
      L10_2 = L5_2.amount
      L9_2 = L9_2 + L10_2
      L8_2.amount = L9_2
    else
      L8_2 = FindFirstEmptySlot
      L9_2 = L6_2
      L10_2 = Config
      L10_2 = L10_2.MaxSlots
      L8_2 = L8_2(L9_2, L10_2)
      if not L8_2 then
        L9_2 = TriggerClientEvent
        L10_2 = "codem-inventory:client:notification"
        L11_2 = L1_2
        L12_2 = Locales
        L13_2 = Config
        L13_2 = L13_2.Language
        L12_2 = L12_2[L13_2]
        L12_2 = L12_2.notification
        L12_2 = L12_2.FAILEDANEWSLOT
        L9_2(L10_2, L11_2, L12_2)
        return
      end
      L9_2 = tostring
      L10_2 = L8_2
      L9_2 = L9_2(L10_2)
      L8_2 = L9_2
      L5_2.slot = L8_2
      L8_2[L8_2] = L5_2
      A0_2.newSlot = L8_2
    end
  end
  ::lbl_224::
  L8_2 = Config
  L8_2 = L8_2.CashItem
  if L8_2 then
    L8_2 = L5_2.name
    if "cash" == L8_2 then
      L8_2 = AddMoney
      L9_2 = L1_2
      L10_2 = "cash"
      L11_2 = L5_2.amount
      L8_2(L9_2, L10_2, L11_2)
  end
  else
    L8_2 = SetInventory
    L9_2 = L1_2
    L8_2(L9_2)
  end
  L8_2 = A0_2.oldSlot
  L4_2[L8_2] = nil
  L8_2 = UpdateVehicleInventory
  L9_2 = A0_2.plate
  L10_2 = L4_2
  L8_2(L9_2, L10_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:RemoveVehicleTrunkItem"
  L10_2 = -1
  L11_2 = A0_2.plate
  L12_2 = A0_2.oldSlot
  L13_2 = tostring
  L14_2 = A0_2.oldSlot
  L13_2 = L13_2(L14_2)
  L13_2 = L4_2[L13_2]
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:additem"
  L10_2 = L1_2
  L11_2 = tostring
  L12_2 = A0_2.newSlot
  L11_2 = L11_2(L12_2)
  L12_2 = tostring
  L13_2 = A0_2.newSlot
  L12_2 = L12_2(L13_2)
  L12_2 = L6_2[L12_2]
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = Config
  L8_2 = L8_2.UseDiscordWebhooks
  if L8_2 then
    L8_2 = {}
    L9_2 = GetName
    L10_2 = L1_2
    L9_2 = L9_2(L10_2)
    L10_2 = " - "
    L11_2 = L1_2
    L9_2 = L9_2 .. L10_2 .. L11_2
    L8_2.playername = L9_2
    L9_2 = L5_2.label
    L8_2.itemname = L9_2
    L9_2 = L5_2.amount
    L8_2.amount = L9_2
    L9_2 = L5_2.info
    if not L9_2 then
      L9_2 = nil
    end
    L8_2.info = L9_2
    L9_2 = "Plate : "
    L10_2 = A0_2.plate
    L11_2 = " "
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.TRUNKTOINVENTORY
    L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2
    L8_2.reason = L9_2
    L9_2 = TriggerEvent
    L10_2 = "codem-inventory:CreateLog"
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ADDITEMS
    L12_2 = "green"
    L13_2 = L8_2
    L14_2 = L1_2
    L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:swapVehicleGloveboxToInventory"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tostring
  L4_2 = A0_2.newSlot
  L3_2 = L3_2(L4_2)
  A0_2.newSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.oldSlot
  L3_2 = L3_2(L4_2)
  A0_2.oldSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.plate
  L3_2 = L3_2(L4_2)
  L4_2 = GloveBoxInventory
  L4_2 = L4_2[L3_2]
  if L4_2 then
    L4_2 = GloveBoxInventory
    L4_2 = L4_2[L3_2]
    L4_2 = L4_2.glovebox
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.GLOVEBOXINVENTORYNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = A0_2.oldSlot
  L5_2 = L4_2[L5_2]
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  if L5_2 then
    L8_2 = L5_2.type
    if "bag" == L8_2 then
      L8_2 = CheckBagItem
      L7_2 = L1_2
      L8_2 = L8_2(L7_2)
      L7_2 = tonumber
      L8_2 = L6_2
      L7_2 = L7_2(L8_2)
      L8_2 = tonumber
      L9_2 = Config
      L9_2 = L9_2.MaxBackPackItem
      L8_2 = L8_2(L9_2)
      if L7_2 > L8_2 then
        L7_2 = TriggerClientEvent
        L8_2 = "codem-inventory:client:notification"
        L9_2 = L1_2
        L10_2 = Locales
        L11_2 = Config
        L11_2 = L11_2.Language
        L10_2 = L10_2[L11_2]
        L10_2 = L10_2.notification
        L10_2 = L10_2.MAXBAGPACKITEM
        L7_2(L8_2, L9_2, L10_2)
        return
      end
    end
  end
  L8_2 = PlayerServerInventory
  L8_2 = L8_2[L2_2]
  if L8_2 then
    L8_2 = PlayerServerInventory
    L8_2 = L8_2[L2_2]
    L8_2 = L8_2.inventory
  end
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.PLAYERINVENTORYNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    L7_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1214 SATIR"
    L7_2(L8_2)
    return
  end
  L7_2 = FindFirstEmptySlot
  L8_2 = L6_2
  L9_2 = Config
  L9_2 = L9_2.MaxSlots
  L7_2 = L7_2(L8_2, L9_2)
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.NOEMPTYSLOTAVILABLEYOUR
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = CheckInventoryWeight
  L9_2 = L6_2
  L10_2 = L5_2.weight
  L11_2 = L5_2.amount
  L10_2 = L10_2 * L11_2
  L11_2 = Config
  L11_2 = L11_2.MaxWeight
  L8_2 = L8_2(L9_2, L10_2, L11_2)
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.INVENTORYISFULL
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = tostring
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L7_2 = L8_2
  L8_2 = A0_2.newSlot
  L8_2 = L6_2[L8_2]
  if not L8_2 then
    L8_2 = A0_2.newSlot
    L5_2.slot = L8_2
    L8_2 = A0_2.newSlot
    L8_2[L8_2] = L5_2
  else
    L8_2 = A0_2.newSlot
    L8_2 = L6_2[L8_2]
    L8_2 = L8_2.name
    L9_2 = L5_2.name
    if L8_2 == L9_2 then
      L8_2 = L5_2.unique
      if not L8_2 then
        L8_2 = A0_2.oldSlot
        L8_2 = L6_2[L8_2]
        if not L8_2 then
          goto lbl_189
        end
        L8_2 = A0_2.oldSlot
        L8_2 = L6_2[L8_2]
        L8_2 = L8_2.unique
        if not L8_2 then
          goto lbl_189
        end
      end
      L5_2.slot = L7_2
      L8_2[L7_2] = L5_2
      A0_2.newSlot = L7_2
      goto lbl_224
      ::lbl_189::
      L8_2 = A0_2.newSlot
      L8_2 = L6_2[L8_2]
      L9_2 = A0_2.newSlot
      L9_2 = L6_2[L9_2]
      L9_2 = L9_2.amount
      L10_2 = L5_2.amount
      L9_2 = L9_2 + L10_2
      L8_2.amount = L9_2
    else
      L8_2 = FindFirstEmptySlot
      L9_2 = L6_2
      L10_2 = Config
      L10_2 = L10_2.MaxSlots
      L8_2 = L8_2(L9_2, L10_2)
      if not L8_2 then
        L9_2 = TriggerClientEvent
        L10_2 = "codem-inventory:client:notification"
        L11_2 = L1_2
        L12_2 = Locales
        L13_2 = Config
        L13_2 = L13_2.Language
        L12_2 = L12_2[L13_2]
        L12_2 = L12_2.notification
        L12_2 = L12_2.FAILEDANEWSLOT
        L9_2(L10_2, L11_2, L12_2)
        return
      end
      L9_2 = tostring
      L10_2 = L8_2
      L9_2 = L9_2(L10_2)
      L8_2 = L9_2
      L5_2.slot = L8_2
      L8_2[L8_2] = L5_2
      A0_2.newSlot = L8_2
    end
  end
  ::lbl_224::
  L8_2 = A0_2.oldSlot
  L4_2[L8_2] = nil
  L8_2 = Config
  L8_2 = L8_2.CashItem
  if L8_2 then
    L8_2 = L5_2.name
    if "cash" == L8_2 then
      L8_2 = AddMoney
      L9_2 = L1_2
      L10_2 = "cash"
      L11_2 = L5_2.amount
      L8_2(L9_2, L10_2, L11_2)
  end
  else
    L8_2 = SetInventory
    L9_2 = L1_2
    L8_2(L9_2)
  end
  L8_2 = UpdateVehicleGlovebox
  L9_2 = A0_2.plate
  L10_2 = L4_2
  L8_2(L9_2, L10_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:RemoveVehicleGloveboxItem"
  L10_2 = -1
  L11_2 = A0_2.plate
  L12_2 = A0_2.oldSlot
  L13_2 = tostring
  L14_2 = A0_2.oldSlot
  L13_2 = L13_2(L14_2)
  L13_2 = L4_2[L13_2]
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:additem"
  L10_2 = L1_2
  L11_2 = tostring
  L12_2 = A0_2.newSlot
  L11_2 = L11_2(L12_2)
  L12_2 = tostring
  L13_2 = A0_2.newSlot
  L12_2 = L12_2(L13_2)
  L12_2 = L6_2[L12_2]
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = Config
  L8_2 = L8_2.UseDiscordWebhooks
  if L8_2 then
    L8_2 = {}
    L9_2 = GetName
    L10_2 = L1_2
    L9_2 = L9_2(L10_2)
    L10_2 = " - "
    L11_2 = L1_2
    L9_2 = L9_2 .. L10_2 .. L11_2
    L8_2.playername = L9_2
    L9_2 = L5_2.label
    L8_2.itemname = L9_2
    L9_2 = L5_2.amount
    L8_2.amount = L9_2
    L9_2 = L5_2.info
    if not L9_2 then
      L9_2 = nil
    end
    L8_2.info = L9_2
    L9_2 = "Plate : "
    L10_2 = A0_2.plate
    L11_2 = " "
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.GLOVEBOXTOINVENTORY
    L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2
    L8_2.reason = L9_2
    L9_2 = TriggerEvent
    L10_2 = "codem-inventory:CreateLog"
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ADDITEMS
    L12_2 = "green"
    L13_2 = L8_2
    L14_2 = L1_2
    L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:swapShopToInventory"
function fn_L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
  L2_2 = tonumber
  L3_2 = source
  L2_2 = L2_2(L3_2)
  L3_2 = Identifier
  L4_2 = tonumber
  L5_2 = L2_2
  L4_2 = L4_2(L5_2)
  L3_2 = L3_2[L4_2]
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L2_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.IDENTIFIERNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = PlayerServerInventory
  L4_2 = L4_2[L3_2]
  if L4_2 then
    L4_2 = PlayerServerInventory
    L4_2 = L4_2[L3_2]
    L4_2 = L4_2.inventory
  end
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L2_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERINVENTORYNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    L5_2 = debugprint
    L8_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1293 SATIR"
    L5_2(L8_2)
    return
  end
  L5_2 = A0_2.itemname
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L2_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.ITEMNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = Config
  L8_2 = L8_2.Shops
  L7_2 = A0_2.shopname
  L8_2 = L8_2[L7_2]
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L2_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.SHOPNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = A0_2.amount
  L7_2 = #L7_2
  if L7_2 <= 0 then
    L7_2 = A0_2.itemname
    L7_2.count = 1
  else
    L7_2 = A0_2.itemname
    L8_2 = A0_2.amount
    L7_2.count = L8_2
  end
  L7_2 = A0_2.itemname
  L8_2 = tonumber
  L9_2 = A0_2.itemname
  L9_2 = L9_2.count
  L8_2 = L8_2(L9_2)
  L7_2.count = L8_2
  L7_2 = A0_2.itemname
  L8_2 = tonumber
  L9_2 = A0_2.itemname
  L9_2 = L9_2.price
  L8_2 = L8_2(L9_2)
  L7_2.price = L8_2
  L7_2 = FindFirstEmptySlot
  L8_2 = L4_2
  L9_2 = Config
  L9_2 = L9_2.MaxSlots
  L7_2 = L7_2(L8_2, L9_2)
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L2_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.NOEMPTYSLOTAVILABLEYOUR
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = Config
  L8_2 = L8_2.Itemlist
  L9_2 = L5_2.name
  L8_2 = L8_2[L9_2]
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L2_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ITEMNOTFOUNDITEMLIST
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  if L5_2 then
    L8_2 = L5_2.grade
    if L8_2 then
      if A1_2 then
        L8_2 = A1_2.grade
        if L8_2 then
          L8_2 = A1_2.name
          if L8_2 then
            L8_2 = pairs
            L9_2 = L6_2.job
            L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
            for L12_2, L13_2 in L8_2, L9_2, L10_2, L11_2 do
              L14_2 = A1_2.name
              if L14_2 == L12_2 then
                L14_2 = tonumber
                L15_2 = A1_2.grade
                L14_2 = L14_2(L15_2)
                L15_2 = tonumber
                L16_2 = L5_2.grade
                L15_2 = L15_2(L16_2)
                if L14_2 >= L15_2 then
                  L14_2 = Config
                  L14_2 = L14_2.Itemlist
                  L15_2 = L5_2.name
                  L14_2 = L14_2[L15_2]
                  L15_2 = L14_2.unique
                  if L15_2 then
                    L15_2 = A0_2.itemname
                    L15_2.count = 1
                  end
                  L15_2 = A0_2.itemname
                  L15_2 = L15_2.price
                  L16_2 = A0_2.itemname
                  L16_2 = L16_2.count
                  L15_2 = L15_2 * L16_2
                  L16_2 = GetPlayerMoney
                  L17_2 = L2_2
                  L18_2 = A0_2.paymentMethod
                  L16_2 = L16_2(L17_2, L18_2)
                  L17_2 = tonumber
                  L18_2 = L16_2
                  L17_2 = L17_2(L18_2)
                  L18_2 = tonumber
                  L19_2 = L15_2
                  L18_2 = L18_2(L19_2)
                  if L17_2 < L18_2 then
                    L17_2 = TriggerClientEvent
                    L18_2 = "codem-inventory:client:notification"
                    L19_2 = L2_2
                    L20_2 = Locales
                    L21_2 = Config
                    L21_2 = L21_2.Language
                    L20_2 = L20_2[L21_2]
                    L20_2 = L20_2.notification
                    L20_2 = L20_2.ENOUGHMONEY
                    L17_2(L18_2, L19_2, L20_2)
                    return
                  end
                  L17_2 = AddItem
                  L18_2 = L2_2
                  L19_2 = L14_2.name
                  L20_2 = A0_2.itemname
                  L20_2 = L20_2.count
                  L17_2 = L17_2(L18_2, L19_2, L20_2)
                  if L17_2 then
                    L17_2 = RemoveMoney
                    L18_2 = L2_2
                    L19_2 = A0_2.paymentMethod
                    L20_2 = L15_2
                    L17_2(L18_2, L19_2, L20_2)
                  end
                else
                  L14_2 = TriggerClientEvent
                  L15_2 = "codem-inventory:client:notification"
                  L16_2 = L2_2
                  L17_2 = Locales
                  L18_2 = Config
                  L18_2 = L18_2.Language
                  L17_2 = L17_2[L18_2]
                  L17_2 = L17_2.notification
                  L17_2 = L17_2.NOTGRADE
                  L14_2(L15_2, L16_2, L17_2)
                  return
                end
              end
            end
        end
      end
      else
        L8_2 = TriggerClientEvent
        L9_2 = "codem-inventory:client:notification"
        L10_2 = L2_2
        L11_2 = Locales
        L12_2 = Config
        L12_2 = L12_2.Language
        L11_2 = L11_2[L12_2]
        L11_2 = L11_2.notification
        L11_2 = L11_2.JOBNOTFOUND
        L8_2(L9_2, L10_2, L11_2)
        return
      end
  end
  else
    L8_2 = Config
    L8_2 = L8_2.Itemlist
    L9_2 = L5_2.name
    L8_2 = L8_2[L9_2]
    L9_2 = L8_2.unique
    if L9_2 then
      L9_2 = A0_2.itemname
      L9_2.count = 1
    end
    L9_2 = A0_2.itemname
    L9_2 = L9_2.price
    L10_2 = A0_2.itemname
    L10_2 = L10_2.count
    L9_2 = L9_2 * L10_2
    L10_2 = GetPlayerMoney
    L11_2 = L2_2
    L12_2 = A0_2.paymentMethod
    L10_2 = L10_2(L11_2, L12_2)
    L11_2 = tonumber
    L12_2 = L10_2
    L11_2 = L11_2(L12_2)
    L12_2 = tonumber
    L13_2 = L9_2
    L12_2 = L12_2(L13_2)
    if L11_2 < L12_2 then
      L11_2 = TriggerClientEvent
      L12_2 = "codem-inventory:client:notification"
      L13_2 = L2_2
      L14_2 = Locales
      L15_2 = Config
      L15_2 = L15_2.Language
      L14_2 = L14_2[L15_2]
      L14_2 = L14_2.notification
      L14_2 = L14_2.ENOUGHMONEY
      L11_2(L12_2, L13_2, L14_2)
      return
    end
    L11_2 = AddItem
    L12_2 = L2_2
    L13_2 = L8_2.name
    L14_2 = A0_2.itemname
    L14_2 = L14_2.count
    L11_2 = L11_2(L12_2, L13_2, L14_2)
    if L11_2 then
      L11_2 = RemoveMoney
      L12_2 = L2_2
      L13_2 = A0_2.paymentMethod
      L14_2 = L9_2
      L11_2(L12_2, L13_2, L14_2)
      L11_2 = Config
      L11_2 = L11_2.UseDiscordWebhooks
      if L11_2 then
        L11_2 = {}
        L12_2 = GetName
        L13_2 = L2_2
        L12_2 = L12_2(L13_2)
        L13_2 = "-"
        L14_2 = L2_2
        L12_2 = L12_2 .. L13_2 .. L14_2
        L11_2.playername = L12_2
        L12_2 = A0_2.itemname
        L12_2 = L12_2.label
        L11_2.itemname = L12_2
        L12_2 = A0_2.info
        if not L12_2 then
          L12_2 = nil
        end
        L11_2.info = L12_2
        L12_2 = A0_2.itemname
        L12_2 = L12_2.count
        if not L12_2 then
          L12_2 = A0_2.itemname
          L12_2 = L12_2.amount
        end
        L11_2.amount = L12_2
        L12_2 = Locales
        L13_2 = Config
        L13_2 = L13_2.Language
        L12_2 = L12_2[L13_2]
        L12_2 = L12_2.notification
        L12_2 = L12_2.SHOPTOINVENTORY
        L11_2.reason = L12_2
        L12_2 = TriggerEvent
        L13_2 = "codem-inventory:CreateLog"
        L14_2 = Locales
        L15_2 = Config
        L15_2 = L15_2.Language
        L14_2 = L14_2[L15_2]
        L14_2 = L14_2.notification
        L14_2 = L14_2.BUYITEM
        L15_2 = "green"
        L16_2 = L11_2
        L17_2 = L2_2
        L18_2 = "shop"
        L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
      end
    end
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:openbackpack"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  if A0_2 then
    L3_2 = A0_2.info
    if L3_2 then
      goto lbl_33
    end
  end
  L3_2 = TriggerClientEvent
  L4_2 = "codem-inventory:client:notification"
  L5_2 = L1_2
  L8_2 = Locales
  L7_2 = Config
  L7_2 = L7_2.Language
  L8_2 = L8_2[L7_2]
  L8_2 = L8_2.notification
  L8_2 = L8_2.ITEMINFONOTFOUND
  L3_2(L4_2, L5_2, L8_2)
  do return end
  ::lbl_33::
  L3_2 = A0_2.info
  L4_2 = {}
  L5_2 = {}
  L4_2.inventory = L5_2
  L5_2 = L3_2.slot
  if not L5_2 then
    L5_2 = 0
  end
  L4_2.slot = L5_2
  L5_2 = L3_2.weight
  if not L5_2 then
    L5_2 = 0
  end
  L4_2.maxweight = L5_2
  L5_2 = L3_2.series
  L4_2.backpackname = L5_2
  L5_2 = ServerStash
  L8_2 = L3_2.series
  L5_2 = L5_2[L6_2]
  if L5_2 then
    L5_2 = ServerStash
    L8_2 = L3_2.series
    L5_2 = L5_2[L6_2]
    L5_2 = L5_2.inventory
    L4_2.inventory = L5_2
    L5_2 = L4_2.inventory
    if not L5_2 then
      L5_2 = TriggerClientEvent
      L8_2 = "codem-inventory:client:notification"
      L7_2 = L1_2
      L8_2 = Locales
      L9_2 = Config
      L9_2 = L9_2.Language
      L8_2 = L8_2[L9_2]
      L8_2 = L8_2.notification
      L8_2 = L8_2.BACKPACKINVNOTFOUND
      L5_2(L8_2, L7_2, L8_2)
      return
    end
  else
    L5_2 = ExecuteSql
    L8_2 = "INSERT INTO codem_new_stash (stashname, inventory) VALUES (@stashname, @inventory) ON DUPLICATE KEY UPDATE stashname = @stashname, inventory = @inventory"
    L7_2 = {}
    L8_2 = L3_2.series
    L7_2.stashname = L8_2
    L8_2 = json
    L8_2 = L8_2.encode
    L9_2 = {}
    L8_2 = L8_2(L9_2)
    L7_2.inventory = L8_2
    L5_2(L8_2, L7_2)
    L5_2 = ServerStash
    L8_2 = L3_2.series
    L7_2 = {}
    L8_2 = {}
    L7_2.inventory = L8_2
    L5_2[L8_2] = L7_2
  end
  L5_2 = TriggerClientEvent
  L8_2 = "codem-inventory:GetBackPackItem"
  L7_2 = L1_2
  L8_2 = L4_2
  L5_2(L8_2, L7_2, L8_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:SwapInventoryToBackPack"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tostring
  L4_2 = A0_2.newSlot
  L3_2 = L3_2(L4_2)
  A0_2.newSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.oldSlot
  L3_2 = L3_2(L4_2)
  A0_2.oldSlot = L3_2
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERINVENTORYNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = A0_2.oldSlot
  L4_2 = L3_2[L4_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMNOTFOUNDINGIVENSLOT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = L4_2.type
  if "bag" == L5_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.YOUCANNOTPUTABAG
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = ServerStash
  L8_2 = A0_2.backpackname
  L5_2 = L5_2[L6_2]
  if not L5_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.BACKPACKNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = ServerStash
  L8_2 = A0_2.backpackname
  L5_2 = L5_2[L6_2]
  L5_2 = L5_2.inventory
  L8_2 = A0_2.oldSlot
  L8_2 = L3_2[L8_2]
  L8_2 = L8_2.amount
  if not L8_2 then
    L8_2 = 1
  end
  if not L5_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.BACKPACKINVNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = CheckInventoryWeight
  L8_2 = L5_2
  L9_2 = L4_2.weight
  L10_2 = L4_2.amount
  L9_2 = L9_2 * L10_2
  L10_2 = A0_2.weight
  L7_2 = L7_2(L8_2, L9_2, L10_2)
  if not L7_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.STASHFULL
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = FindFirstEmptySlot
  L8_2 = L5_2
  L9_2 = A0_2.maxslot
  L7_2 = L7_2(L8_2, L9_2)
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.FAILEDANEWSLOT
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = tostring
  L9_2 = L7_2
  L8_2 = L8_2(L9_2)
  L7_2 = L8_2
  L8_2 = A0_2.newSlot
  L8_2 = L5_2[L8_2]
  if not L8_2 then
    L8_2 = A0_2.newSlot
    L5_2[L8_2] = L4_2
    L8_2 = A0_2.newSlot
    L8_2 = L5_2[L8_2]
    L9_2 = A0_2.newSlot
    L8_2.slot = L9_2
  else
    L8_2 = A0_2.newSlot
    L8_2 = L5_2[L8_2]
    L8_2 = L8_2.name
    L9_2 = L4_2.name
    if L8_2 == L9_2 then
      L8_2 = L4_2.unique
      if not L8_2 then
        L8_2 = A0_2.newSlot
        L8_2 = L5_2[L8_2]
        L8_2 = L8_2.unique
        if not L8_2 then
          goto lbl_184
        end
      end
      L4_2.slot = L7_2
      L5_2[L7_2] = L4_2
      A0_2.newSlot = L7_2
      goto lbl_201
      ::lbl_184::
      L8_2 = A0_2.newSlot
      L8_2 = L5_2[L8_2]
      L9_2 = A0_2.newSlot
      L9_2 = L5_2[L9_2]
      L9_2 = L9_2.amount
      L10_2 = L4_2.amount
      L9_2 = L9_2 + L10_2
      L8_2.amount = L9_2
    else
      L8_2 = tostring
      L9_2 = L7_2
      L8_2 = L8_2(L9_2)
      L7_2 = L8_2
      L5_2[L7_2] = L4_2
      L8_2 = L5_2[L7_2]
      L8_2.slot = L7_2
    end
  end
  ::lbl_201::
  L8_2 = A0_2.oldSlot
  L3_2[L8_2] = nil
  L8_2 = ExecuteSql
  L9_2 = "INSERT INTO codem_new_stash (stashname, inventory) VALUES (@stashname, @inventory) ON DUPLICATE KEY UPDATE stashname = @stashname, inventory = @inventory"
  L10_2 = {}
  L11_2 = A0_2.backpackname
  L10_2.stashname = L11_2
  L11_2 = json
  L11_2 = L11_2.encode
  L12_2 = L5_2
  L11_2 = L11_2(L12_2)
  L10_2.inventory = L11_2
  L8_2(L9_2, L10_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:removeitemtoclientInventory"
  L10_2 = L1_2
  L11_2 = A0_2.oldSlot
  L12_2 = L6_2
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:loadbackpackinventory"
  L10_2 = L1_2
  L11_2 = L5_2
  L8_2(L9_2, L10_2, L11_2)
  L8_2 = Config
  L8_2 = L8_2.CashItem
  if L8_2 then
    L8_2 = L4_2.name
    if "cash" == L8_2 then
      L8_2 = GetItemsTotalAmount
      L9_2 = L1_2
      L10_2 = "cash"
      L8_2 = L8_2(L9_2, L10_2)
      L9_2 = GetPlayer
      L10_2 = L1_2
      L9_2 = L9_2(L10_2)
      L10_2 = Config
      L10_2 = L10_2.Framework
      if "qb" ~= L10_2 then
        L10_2 = Config
        L10_2 = L10_2.Framework
        if "oldqb" ~= L10_2 then
          goto lbl_254
        end
      end
      L10_2 = L9_2.Functions
      L10_2 = L10_2.SetMoney
      L11_2 = "cash"
      L12_2 = L8_2
      L10_2(L11_2, L12_2)
      goto lbl_263
      ::lbl_254::
      L10_2 = L9_2.setMoney
      L11_2 = tonumber
      L12_2 = L8_2
      L11_2, L12_2, L13_2, L14_2, L15_2 = L11_2(L12_2)
      L10_2(L11_2, L12_2, L13_2, L14_2, L15_2)
  end
  else
    L8_2 = SetInventory
    L9_2 = L1_2
    L8_2(L9_2)
  end
  ::lbl_263::
  L8_2 = Config
  L8_2 = L8_2.UseDiscordWebhooks
  if L8_2 then
    L8_2 = {}
    L9_2 = GetName
    L10_2 = L1_2
    L9_2 = L9_2(L10_2)
    L10_2 = "-"
    L11_2 = L1_2
    L9_2 = L9_2 .. L10_2 .. L11_2
    L8_2.playername = L9_2
    L9_2 = L4_2.label
    L8_2.itemname = L9_2
    L9_2 = L4_2.amount
    L8_2.amount = L9_2
    L9_2 = L4_2.info
    if not L9_2 then
      L9_2 = nil
    end
    L8_2.info = L9_2
    L9_2 = "Canta Name :"
    L10_2 = A0_2.backpackname
    L11_2 = " "
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.INVENTORYTOBACKPACK
    L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2
    L8_2.reason = L9_2
    L9_2 = TriggerEvent
    L10_2 = "codem-inventory:CreateLog"
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ADDITEMS
    L12_2 = "green"
    L13_2 = L8_2
    L14_2 = L1_2
    L15_2 = "stash"
    L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:SwapBackPackToInventory"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tostring
  L4_2 = A0_2.newSlot
  L3_2 = L3_2(L4_2)
  A0_2.newSlot = L3_2
  L3_2 = tostring
  L4_2 = A0_2.itemname
  L4_2 = L4_2.slot
  L3_2 = L3_2(L4_2)
  L4_2 = A0_2.backpackname
  L5_2 = ServerStash
  L5_2 = L5_2[L4_2]
  L5_2 = L5_2.inventory
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.BACKPACKINVNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = L5_2[L3_2]
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.NOEMPTYSLOTAVILABLEYOUR
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = PlayerServerInventory
  L7_2 = L7_2[L2_2]
  if L7_2 then
    L7_2 = PlayerServerInventory
    L7_2 = L7_2[L2_2]
    L7_2 = L7_2.inventory
  end
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.PLAYERINVENTORYNOTFOUND
    L8_2(L9_2, L10_2, L11_2)
    L8_2 = debugprint
    L9_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1589 SATIR"
    L8_2(L9_2)
    return
  end
  L8_2 = CheckInventoryWeight
  L9_2 = L7_2
  L10_2 = L6_2.weight
  L11_2 = L6_2.amount
  L10_2 = L10_2 * L11_2
  L11_2 = Config
  L11_2 = L11_2.MaxWeight
  L8_2 = L8_2(L9_2, L10_2, L11_2)
  if not L8_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.INVENTORYISFULL
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = FindFirstEmptySlot
  L9_2 = L7_2
  L10_2 = Config
  L10_2 = L10_2.MaxSlots
  L8_2 = L8_2(L9_2, L10_2)
  if not L8_2 then
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:notification"
    L11_2 = L1_2
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.NOEMPTYSLOTAVILABLEYOUR
    L9_2(L10_2, L11_2, L12_2)
    return
  end
  L9_2 = tostring
  L10_2 = L8_2
  L9_2 = L9_2(L10_2)
  L8_2 = L9_2
  L9_2 = A0_2.newSlot
  L9_2 = L7_2[L9_2]
  if not L9_2 then
    L9_2 = A0_2.newSlot
    L7_2[L9_2] = L8_2
    L9_2 = A0_2.newSlot
    L9_2 = L7_2[L9_2]
    L10_2 = A0_2.newSlot
    L9_2.slot = L10_2
  else
    L9_2 = A0_2.newSlot
    L9_2 = L7_2[L9_2]
    L9_2 = L9_2.name
    L10_2 = L6_2.name
    if L9_2 == L10_2 then
      L9_2 = L6_2.unique
      if not L9_2 then
        L9_2 = A0_2.newSlot
        L9_2 = L7_2[L9_2]
        L9_2 = L9_2.unique
        if not L9_2 then
          goto lbl_152
        end
      end
      L8_2.slot = L8_2
      L7_2[L8_2] = L8_2
      A0_2.newSlot = L8_2
      goto lbl_165
      ::lbl_152::
      L9_2 = A0_2.newSlot
      L9_2 = L7_2[L9_2]
      L10_2 = A0_2.newSlot
      L10_2 = L7_2[L10_2]
      L10_2 = L10_2.amount
      L11_2 = L6_2.amount
      L10_2 = L10_2 + L11_2
      L9_2.amount = L10_2
    else
      L8_2.slot = L8_2
      L7_2[L8_2] = L8_2
      A0_2.newSlot = L8_2
    end
  end
  ::lbl_165::
  L5_2[L3_2] = nil
  L9_2 = ExecuteSql
  L10_2 = "INSERT INTO codem_new_stash (stashname, inventory) VALUES (@stashname, @inventory) ON DUPLICATE KEY UPDATE stashname = @stashname, inventory = @inventory"
  L11_2 = {}
  L11_2.stashname = L4_2
  L12_2 = json
  L12_2 = L12_2.encode
  L13_2 = L5_2
  L12_2 = L12_2(L13_2)
  L11_2.inventory = L12_2
  L9_2(L10_2, L11_2)
  L9_2 = TriggerClientEvent
  L10_2 = "codem-inventory:client:additem"
  L11_2 = L1_2
  L12_2 = tostring
  L13_2 = A0_2.newSlot
  L12_2 = L12_2(L13_2)
  L13_2 = tostring
  L14_2 = A0_2.newSlot
  L13_2 = L13_2(L14_2)
  L13_2 = L7_2[L13_2]
  L9_2(L10_2, L11_2, L12_2, L13_2)
  L9_2 = TriggerClientEvent
  L10_2 = "codem-inventory:client:loadbackpackinventory"
  L11_2 = L1_2
  L12_2 = L5_2
  L9_2(L10_2, L11_2, L12_2)
  L9_2 = Config
  L9_2 = L9_2.CashItem
  if L9_2 then
    L9_2 = L6_2.name
    if "cash" == L9_2 then
      L9_2 = AddMoney
      L10_2 = L1_2
      L11_2 = "cash"
      L12_2 = L6_2.amount
      L9_2(L10_2, L11_2, L12_2)
  end
  else
    L9_2 = SetInventory
    L10_2 = L1_2
    L9_2(L10_2)
  end
  L9_2 = Config
  L9_2 = L9_2.UseDiscordWebhooks
  if L9_2 then
    L9_2 = {}
    L10_2 = GetName
    L11_2 = L1_2
    L10_2 = L10_2(L11_2)
    L11_2 = "-"
    L12_2 = L1_2
    L10_2 = L10_2 .. L11_2 .. L12_2
    L9_2.playername = L10_2
    L10_2 = L6_2.label
    L9_2.itemname = L10_2
    L10_2 = L6_2.amount
    L9_2.amount = L10_2
    L10_2 = L6_2.info
    if not L10_2 then
      L10_2 = nil
    end
    L9_2.info = L10_2
    L10_2 = "Canta Name :"
    L11_2 = A0_2.backpackname
    L12_2 = " "
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.BACKPACKTOINVENTORY
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2
    L9_2.reason = L10_2
    L10_2 = TriggerEvent
    L11_2 = "codem-inventory:CreateLog"
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.ADDITEMS
    L13_2 = "green"
    L14_2 = L9_2
    L15_2 = L1_2
    L16_2 = "stash"
    L10_2(L11_2, L12_2, L13_2, L14_2, L15_2, L16_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:splitItemTrunk"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = tonumber
  L2_2 = source
  L1_2 = L1_2(L2_2)
  L2_2 = cooldown
  L2_2 = L2_2[L1_2]
  if L2_2 then
    return
  else
    L2_2 = cooldown
    L2_2[L1_2] = true
    L2_2 = SetTimeout
    L3_2 = 400
    function L4_2()
local updateinventorysql, L1_3
      cooldown = cooldown
      L1_3 = L1_2
      cooldown[L1_3] = nil
    end
    L2_2(L3_2, L4_2)
  end
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = VehicleInventory
  L4_2 = A0_2.plate
  L3_2 = L3_2[L4_2]
  if L3_2 then
    L3_2 = VehicleInventory
    L4_2 = A0_2.plate
    L3_2 = L3_2[L4_2]
    L3_2 = L3_2.trunk
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.VEHICLEPLATENOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = tostring
  L5_2 = A0_2.item
  L5_2 = L5_2.slot
  L4_2 = L4_2(L5_2)
  L4_2 = L3_2[L4_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMNOTFOUNDINGIVENSLOT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = tonumber
  L8_2 = L4_2.amount
  L5_2 = L5_2(L6_2)
  if L5_2 <= 1 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.CANNOTSPLIT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = FindFirstEmptySlot
  L8_2 = L3_2
  L7_2 = A0_2.maxslot
  L5_2 = L5_2(L6_2, L7_2)
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.NOEMPTYSLOTAVILABLEYOUR
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = tostring
  L7_2 = L5_2
  L8_2 = L8_2(L7_2)
  L5_2 = L6_2
  L8_2 = tonumber
  L7_2 = A0_2.amount
  L8_2 = L8_2(L7_2)
  if not (L8_2 < 1) then
    L7_2 = tonumber
    L8_2 = L4_2.amount
    L7_2 = L7_2(L8_2)
    if not (L8_2 >= L7_2) then
      goto lbl_129
    end
  end
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:notification"
  L9_2 = L1_2
  L10_2 = Locales
  L11_2 = Config
  L11_2 = L11_2.Language
  L10_2 = L10_2[L11_2]
  L10_2 = L10_2.notification
  L10_2 = L10_2.INVALODAMOUNTSPLIT
  L7_2(L8_2, L9_2, L10_2)
  do return end
  ::lbl_129::
  L7_2 = {}
  L8_2 = L4_2.name
  L7_2.name = L8_2
  L8_2 = L4_2.label
  if not L8_2 then
    L8_2 = L4_2.name
  end
  L7_2.label = L8_2
  L8_2 = L4_2.weight
  if not L8_2 then
    L8_2 = 0
  end
  L7_2.weight = L8_2
  L8_2 = L4_2.type
  if not L8_2 then
    L8_2 = "item"
  end
  L7_2.type = L8_2
  L7_2.amount = L8_2
  L8_2 = L4_2.usable
  if not L8_2 then
    L8_2 = false
  end
  L7_2.usable = L8_2
  L8_2 = L4_2.shouldClose
  if not L8_2 then
    L8_2 = false
  end
  L7_2.shouldClose = L8_2
  L8_2 = L4_2.description
  if not L8_2 then
    L8_2 = ""
  end
  L7_2.description = L8_2
  L7_2.slot = L5_2
  L8_2 = L4_2.image
  if not L8_2 then
    L8_2 = L4_2.name
    L9_2 = ".png"
    L8_2 = L8_2 .. L9_2
  end
  L7_2.image = L8_2
  L8_2 = L4_2.unique
  if not L8_2 then
    L8_2 = false
  end
  L7_2.unique = L8_2
  L8_2 = L4_2.info
  if not L8_2 then
    L8_2 = nil
  end
  L7_2.info = L8_2
  L3_2[L5_2] = L7_2
  L8_2 = tostring
  L9_2 = A0_2.item
  L9_2 = L9_2.slot
  L8_2 = L8_2(L9_2)
  L8_2 = L3_2[L8_2]
  L9_2 = tonumber
  L10_2 = L4_2.amount
  L9_2 = L9_2(L10_2)
  L10_2 = tonumber
  L11_2 = L6_2
  L10_2 = L10_2(L11_2)
  L9_2 = L9_2 - L10_2
  L8_2.amount = L9_2
  L8_2 = UpdateVehicleInventory
  L9_2 = A0_2.plate
  L10_2 = L3_2
  L8_2(L9_2, L10_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:splitItemTrunkClient"
  L10_2 = -1
  L11_2 = A0_2.plate
  L12_2 = A0_2.item
  L12_2 = L12_2.slot
  L13_2 = tostring
  L14_2 = A0_2.item
  L14_2 = L14_2.slot
  L13_2 = L13_2(L14_2)
  L13_2 = L3_2[L13_2]
  L13_2 = L13_2.amount
  L14_2 = L5_2
  L15_2 = L7_2
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterNetEvent
L2_1 = "codem-inventory:server:splitItemGloveBox"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = tonumber
  L2_2 = source
  L1_2 = L1_2(L2_2)
  L2_2 = cooldown
  L2_2 = L2_2[L1_2]
  if L2_2 then
    return
  else
    L2_2 = cooldown
    L2_2[L1_2] = true
    L2_2 = SetTimeout
    L3_2 = 400
    function L4_2()
local cooldown, L1_3
      cooldown = cooldown
      L1_3 = L1_2
      cooldown[L1_3] = nil
    end
    L2_2(L3_2, L4_2)
  end
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = GloveBoxInventory
  L4_2 = A0_2.plate
  L3_2 = L3_2[L4_2]
  if L3_2 then
    L3_2 = GloveBoxInventory
    L4_2 = A0_2.plate
    L3_2 = L3_2[L4_2]
    L3_2 = L3_2.glovebox
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.GLOVEBOXINVENTORYNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = tostring
  L5_2 = A0_2.item
  L5_2 = L5_2.slot
  L4_2 = L4_2(L5_2)
  L4_2 = L3_2[L4_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMNOTFOUNDINGIVENSLOT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = tonumber
  L8_2 = L4_2.amount
  L5_2 = L5_2(L6_2)
  if L5_2 <= 1 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.CANNOTSPLIT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = FindFirstEmptySlot
  L8_2 = L3_2
  L7_2 = A0_2.maxslot
  L5_2 = L5_2(L6_2, L7_2)
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.NOEMPTYSLOTAVILABLEYOUR
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = tostring
  L7_2 = L5_2
  L8_2 = L8_2(L7_2)
  L5_2 = L6_2
  L8_2 = tonumber
  L7_2 = A0_2.amount
  L8_2 = L8_2(L7_2)
  if not (L8_2 < 1) then
    L7_2 = tonumber
    L8_2 = L4_2.amount
    L7_2 = L7_2(L8_2)
    if not (L8_2 >= L7_2) then
      goto lbl_129
    end
  end
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:notification"
  L9_2 = L1_2
  L10_2 = Locales
  L11_2 = Config
  L11_2 = L11_2.Language
  L10_2 = L10_2[L11_2]
  L10_2 = L10_2.notification
  L10_2 = L10_2.INVALODAMOUNTSPLIT
  L7_2(L8_2, L9_2, L10_2)
  do return end
  ::lbl_129::
  L7_2 = {}
  L8_2 = L4_2.name
  L7_2.name = L8_2
  L8_2 = L4_2.label
  if not L8_2 then
    L8_2 = L4_2.name
  end
  L7_2.label = L8_2
  L8_2 = L4_2.weight
  if not L8_2 then
    L8_2 = 0
  end
  L7_2.weight = L8_2
  L8_2 = L4_2.type
  if not L8_2 then
    L8_2 = "item"
  end
  L7_2.type = L8_2
  L7_2.amount = L8_2
  L8_2 = L4_2.usable
  if not L8_2 then
    L8_2 = false
  end
  L7_2.usable = L8_2
  L8_2 = L4_2.shouldClose
  if not L8_2 then
    L8_2 = false
  end
  L7_2.shouldClose = L8_2
  L8_2 = L4_2.description
  if not L8_2 then
    L8_2 = ""
  end
  L7_2.description = L8_2
  L7_2.slot = L5_2
  L8_2 = L4_2.image
  if not L8_2 then
    L8_2 = L4_2.name
    L9_2 = ".png"
    L8_2 = L8_2 .. L9_2
  end
  L7_2.image = L8_2
  L8_2 = L4_2.unique
  if not L8_2 then
    L8_2 = false
  end
  L7_2.unique = L8_2
  L8_2 = L4_2.info
  if not L8_2 then
    L8_2 = nil
  end
  L7_2.info = L8_2
  L3_2[L5_2] = L7_2
  L8_2 = tostring
  L9_2 = A0_2.item
  L9_2 = L9_2.slot
  L8_2 = L8_2(L9_2)
  L8_2 = L3_2[L8_2]
  L9_2 = tonumber
  L10_2 = L4_2.amount
  L9_2 = L9_2(L10_2)
  L10_2 = tonumber
  L11_2 = L6_2
  L10_2 = L10_2(L11_2)
  L9_2 = L9_2 - L10_2
  L8_2.amount = L9_2
  L8_2 = UpdateVehicleGlovebox
  L9_2 = A0_2.plate
  L10_2 = L3_2
  L8_2(L9_2, L10_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:splitItemGloveboxClient"
  L10_2 = -1
  L11_2 = A0_2.plate
  L12_2 = A0_2.item
  L12_2 = L12_2.slot
  L13_2 = tostring
  L14_2 = A0_2.item
  L14_2 = L14_2.slot
  L13_2 = L13_2(L14_2)
  L13_2 = L3_2[L13_2]
  L13_2 = L13_2.amount
  L14_2 = L5_2
  L15_2 = L7_2
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:splitItemStash"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L1_2 = tonumber
  L2_2 = source
  L1_2 = L1_2(L2_2)
  L2_2 = cooldown
  L2_2 = L2_2[L1_2]
  if L2_2 then
    return
  else
    L2_2 = cooldown
    L2_2[L1_2] = true
    L2_2 = SetTimeout
    L3_2 = 400
    function L4_2()
local cooldown, L1_3
      cooldown = cooldown
      L1_3 = L1_2
      cooldown[L1_3] = nil
    end
    L2_2(L3_2, L4_2)
  end
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = ServerStash
  L4_2 = A0_2.stashId
  L3_2 = L3_2[L4_2]
  L3_2 = L3_2.inventory
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.BACKPACKINVNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = tostring
  L5_2 = A0_2.item
  L5_2 = L5_2.slot
  L4_2 = L4_2(L5_2)
  L4_2 = L3_2[L4_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMNOTFOUNDINGIVENSLOT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = L4_2.amount
  if L5_2 <= 1 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.CANNOTSPLIT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = FindFirstEmptySlot
  L8_2 = L3_2
  L7_2 = A0_2.maxslot
  L5_2 = L5_2(L6_2, L7_2)
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.NOEMPTYSLOTAVILABLEYOUR
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = tostring
  L7_2 = L5_2
  L8_2 = L8_2(L7_2)
  L5_2 = L6_2
  L8_2 = tonumber
  L7_2 = A0_2.amount
  L8_2 = L8_2(L7_2)
  if not (L8_2 < 1) then
    L7_2 = L4_2.amount
    if not (L8_2 >= L7_2) then
      goto lbl_120
    end
  end
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:notification"
  L9_2 = L1_2
  L10_2 = Locales
  L11_2 = Config
  L11_2 = L11_2.Language
  L10_2 = L10_2[L11_2]
  L10_2 = L10_2.notification
  L10_2 = L10_2.INVALODAMOUNTSPLIT
  L7_2(L8_2, L9_2, L10_2)
  do return end
  ::lbl_120::
  L7_2 = {}
  L8_2 = L4_2.name
  L7_2.name = L8_2
  L8_2 = L4_2.label
  if not L8_2 then
    L8_2 = L4_2.name
  end
  L7_2.label = L8_2
  L8_2 = L4_2.weight
  if not L8_2 then
    L8_2 = 0
  end
  L7_2.weight = L8_2
  L8_2 = L4_2.type
  if not L8_2 then
    L8_2 = "item"
  end
  L7_2.type = L8_2
  L7_2.amount = L8_2
  L8_2 = L4_2.usable
  if not L8_2 then
    L8_2 = false
  end
  L7_2.usable = L8_2
  L8_2 = L4_2.shouldClose
  if not L8_2 then
    L8_2 = false
  end
  L7_2.shouldClose = L8_2
  L8_2 = L4_2.description
  if not L8_2 then
    L8_2 = ""
  end
  L7_2.description = L8_2
  L7_2.slot = L5_2
  L8_2 = L4_2.image
  if not L8_2 then
    L8_2 = L4_2.name
    L9_2 = ".png"
    L8_2 = L8_2 .. L9_2
  end
  L7_2.image = L8_2
  L8_2 = L4_2.unique
  if not L8_2 then
    L8_2 = false
  end
  L7_2.unique = L8_2
  L8_2 = L4_2.info
  if not L8_2 then
    L8_2 = nil
  end
  L7_2.info = L8_2
  L3_2[L5_2] = L7_2
  L8_2 = tostring
  L9_2 = A0_2.item
  L9_2 = L9_2.slot
  L8_2 = L8_2(L9_2)
  L8_2 = L3_2[L8_2]
  L9_2 = tonumber
  L10_2 = L4_2.amount
  L9_2 = L9_2(L10_2)
  L10_2 = tonumber
  L11_2 = L6_2
  L10_2 = L10_2(L11_2)
  L9_2 = L9_2 - L10_2
  L8_2.amount = L9_2
  L8_2 = UpdateStashDatabase
  L9_2 = A0_2.stashId
  L10_2 = L3_2
  L8_2(L9_2, L10_2)
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:UpdateStashItems"
  L10_2 = L1_2
  L11_2 = A0_2.stashId
  L12_2 = L3_2
  L8_2(L9_2, L10_2, L11_2, L12_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:splitItem"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = tonumber
  L2_2 = source
  L1_2 = L1_2(L2_2)
  L2_2 = cooldown
  L2_2 = L2_2[L1_2]
  if L2_2 then
    return
  else
    L2_2 = cooldown
    L2_2[L1_2] = true
    L2_2 = SetTimeout
    L3_2 = 400
    function L4_2()
local cooldown, L1_3
      cooldown = cooldown
      L1_3 = L1_2
      cooldown[L1_3] = nil
    end
    L2_2(L3_2, L4_2)
  end
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERINVENTORYNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    L4_2 = debugprint
    L5_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1589 SATIR"
    L4_2(L5_2)
    return
  end
  L4_2 = tostring
  L5_2 = A0_2.item
  L5_2 = L5_2.slot
  L4_2 = L4_2(L5_2)
  L4_2 = L3_2[L4_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMNOTFOUNDINGIVENSLOT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = tonumber
  L8_2 = L4_2.amount
  L5_2 = L5_2(L6_2)
  if L5_2 <= 1 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.CANNOTSPLIT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = FindFirstEmptySlot
  L8_2 = L3_2
  L7_2 = Config
  L7_2 = L7_2.MaxSlots
  L5_2 = L5_2(L6_2, L7_2)
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.NOEMPTYSLOTAVILABLEYOUR
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = tostring
  L7_2 = L5_2
  L8_2 = L8_2(L7_2)
  L5_2 = L6_2
  L8_2 = tonumber
  L7_2 = A0_2.amount
  L8_2 = L8_2(L7_2)
  if not (L8_2 < 1) then
    L7_2 = tonumber
    L8_2 = L4_2.amount
    L7_2 = L7_2(L8_2)
    if not (L8_2 >= L7_2) then
      goto lbl_131
    end
  end
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:notification"
  L9_2 = L1_2
  L10_2 = Locales
  L11_2 = Config
  L11_2 = L11_2.Language
  L10_2 = L10_2[L11_2]
  L10_2 = L10_2.notification
  L10_2 = L10_2.INVALODAMOUNTSPLIT
  L7_2(L8_2, L9_2, L10_2)
  do return end
  ::lbl_131::
  L7_2 = {}
  L8_2 = L4_2.name
  L7_2.name = L8_2
  L8_2 = L4_2.label
  if not L8_2 then
    L8_2 = L4_2.name
  end
  L7_2.label = L8_2
  L8_2 = L4_2.weight
  if not L8_2 then
    L8_2 = 0
  end
  L7_2.weight = L8_2
  L8_2 = L4_2.type
  if not L8_2 then
    L8_2 = "item"
  end
  L7_2.type = L8_2
  L7_2.amount = L8_2
  L8_2 = L4_2.usable
  if not L8_2 then
    L8_2 = false
  end
  L7_2.usable = L8_2
  L8_2 = L4_2.shouldClose
  if not L8_2 then
    L8_2 = false
  end
  L7_2.shouldClose = L8_2
  L8_2 = L4_2.description
  if not L8_2 then
    L8_2 = ""
  end
  L7_2.description = L8_2
  L8_2 = tonumber
  L9_2 = L5_2
  L8_2 = L8_2(L9_2)
  L7_2.slot = L8_2
  L8_2 = L4_2.image
  if not L8_2 then
    L8_2 = L4_2.name
    L9_2 = ".png"
    L8_2 = L8_2 .. L9_2
  end
  L7_2.image = L8_2
  L8_2 = L4_2.unique
  if not L8_2 then
    L8_2 = false
  end
  L7_2.unique = L8_2
  L8_2 = L4_2.info
  if not L8_2 then
    L8_2 = nil
  end
  L7_2.info = L8_2
  L3_2[L5_2] = L7_2
  L8_2 = tostring
  L9_2 = A0_2.item
  L9_2 = L9_2.slot
  L8_2 = L8_2(L9_2)
  L8_2 = L3_2[L8_2]
  L9_2 = tonumber
  L10_2 = L4_2.amount
  L9_2 = L9_2(L10_2)
  L9_2 = L9_2 - L6_2
  L8_2.amount = L9_2
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:client:splitItem"
  L10_2 = L1_2
  L11_2 = L5_2
  L12_2 = L3_2[L5_2]
  L13_2 = A0_2.item
  L13_2 = L13_2.slot
  L14_2 = tostring
  L15_2 = A0_2.item
  L15_2 = L15_2.slot
  L14_2 = L14_2(L15_2)
  L14_2 = L3_2[L14_2]
  L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  L8_2 = SetInventory
  L9_2 = L1_2
  L8_2(L9_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:giveItemToPlayerNearby"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERINVENTORYNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    L4_2 = debugprint
    L5_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1791 SATIR"
    L4_2(L5_2)
    return
  end
  L4_2 = tostring
  L5_2 = A0_2.item
  L5_2 = L5_2.slot
  L4_2 = L4_2(L5_2)
  L4_2 = L3_2[L4_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMNOTFOUNDINGIVENSLOT
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = tonumber
  L8_2 = A0_2.player
  L5_2 = L5_2(L6_2)
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.PLAYERNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = GetPlayer
  L7_2 = L5_2
  L8_2 = L8_2(L7_2)
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.PLAYERNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  if L4_2 then
    L7_2 = L4_2.type
    if "bag" == L7_2 then
      L7_2 = CheckBagItem
      L8_2 = L5_2
      L7_2 = L7_2(L8_2)
      L8_2 = tonumber
      L9_2 = L7_2
      L8_2 = L8_2(L9_2)
      L9_2 = tonumber
      L10_2 = Config
      L10_2 = L10_2.MaxBackPackItem
      L9_2 = L9_2(L10_2)
      if L8_2 > L9_2 then
        L8_2 = TriggerClientEvent
        L9_2 = "codem-inventory:client:notification"
        L10_2 = L1_2
        L11_2 = Locales
        L12_2 = Config
        L12_2 = L12_2.Language
        L11_2 = L11_2[L12_2]
        L11_2 = L11_2.notification
        L11_2 = L11_2.MAXBAGPACKITEM
        L8_2(L9_2, L10_2, L11_2)
        return
      end
    end
  end
  L7_2 = GetEntityCoords
  L8_2 = GetPlayerPed
  L9_2 = L1_2
  L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2 = L8_2(L9_2)
  L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2)
  L8_2 = GetEntityCoords
  L9_2 = GetPlayerPed
  L10_2 = L5_2
  L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2 = L9_2(L10_2)
  L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2)
  L9_2 = L7_2 - L8_2
  L9_2 = #L9_2
  if L9_2 > 5.0 then
    L10_2 = TriggerClientEvent
    L11_2 = "codem-inventory:client:notification"
    L12_2 = L1_2
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.NEARBYPLAYERNOTFOUND
    L10_2(L11_2, L12_2, L13_2)
    return
  end
  L10_2 = Identifier
  L10_2 = L10_2[L5_2]
  if not L10_2 then
    L11_2 = TriggerClientEvent
    L12_2 = "codem-inventory:client:notification"
    L13_2 = L1_2
    L14_2 = Locales
    L15_2 = Config
    L15_2 = L15_2.Language
    L14_2 = L14_2[L15_2]
    L14_2 = L14_2.notification
    L14_2 = L14_2.PLAYERNOTFOUND
    L11_2(L12_2, L13_2, L14_2)
    return
  end
  L11_2 = PlayerServerInventory
  L11_2 = L11_2[L10_2]
  L11_2 = L11_2.inventory
  -- Handle cash specially: delegate inventory sync to QB money change
  L12_2 = Config
  L12_2 = L12_2.CashItem
  if L12_2 and L4_2 and L4_2.name == "cash" then
    -- determine give amount (prefer the given item's amount)
    L13_2 = tostring
    L14_2 = A0_2.item
    L14_2 = L14_2.slot
    L13_2 = L13_2(L14_2)
    L14_2 = L3_2[L13_2]
    L15_2 = L4_2.amount
    if not L15_2 and L14_2 then
      L15_2 = L14_2.amount
    end
    if not L15_2 then
      L15_2 = 1
    end
    -- add/remove money; let OnMoneyChange sync cash items to new balances
    L16_2 = AddMoney
    L17_2 = L5_2
    L18_2 = "cash"
    L19_2 = L15_2
    L16_2(L17_2, L18_2, L19_2)
    L16_2 = RemoveMoney
    L17_2 = L1_2
    L18_2 = "cash"
    L19_2 = L15_2
    L16_2(L17_2, L18_2, L19_2)
    -- do not remove source item or insert target item; inventory will be reconciled
  else
    -- regular item transfer flow
    L12_2 = CheckInventoryWeight
    L13_2 = L11_2
    L14_2 = L4_2.weight
    L15_2 = L4_2.amount
    L14_2 = L14_2 * L15_2
    L15_2 = Config
    L15_2 = L15_2.MaxWeight
    L12_2 = L12_2(L13_2, L14_2, L15_2)
    if not L12_2 then
      L12_2 = TriggerClientEvent
      L13_2 = "codem-inventory:client:notification"
      L14_2 = L1_2
      L15_2 = Locales
      L16_2 = Config
      L16_2 = L16_2.Language
      L15_2 = L15_2[L16_2]
      L15_2 = L15_2.notification
      L15_2 = L15_2.NOEMPTYSLOTAVILABLETARGET
      L12_2(L13_2, L14_2, L15_2)
      return
    end
    L12_2 = FindFirstEmptySlot
    L13_2 = L11_2
    L14_2 = Config
    L14_2 = L14_2.MaxSlots
    L12_2 = L12_2(L13_2, L14_2)
    if not L12_2 then
      L13_2 = TriggerClientEvent
      L14_2 = "codem-inventory:client:notification"
      L15_2 = L1_2
      L16_2 = Locales
      L17_2 = Config
      L17_2 = L17_2.Language
      L16_2 = L16_2[L17_2]
      L16_2 = L16_2.notification
      L16_2 = L16_2.NOEMPTYSLOTAVILABLETARGET
      L13_2(L14_2, L15_2, L16_2)
      return
    end
    L13_2 = tostring
    L14_2 = L12_2
    L13_2 = L13_2(L14_2)
    L12_2 = L13_2
    L11_2[L12_2] = L4_2
    L13_2 = L11_2[L12_2]
    L13_2.slot = L12_2
    L13_2 = tostring
    L14_2 = A0_2.item
    L14_2 = L14_2.slot
    L13_2 = L13_2(L14_2)
    L13_2 = L3_2[L13_2]
    L13_2 = L13_2.amount
    if not L13_2 then
      L13_2 = 1
    end
    L14_2 = tostring
    L15_2 = A0_2.item
    L15_2 = L15_2.slot
    L14_2 = L14_2(L15_2)
    L3_2[L14_2] = nil
    L14_2 = TriggerClientEvent
    L15_2 = "codem-inventory:client:removeitemtoclientInventory"
    L16_2 = L1_2
    L17_2 = A0_2.item
    L17_2 = L17_2.slot
    L18_2 = L13_2
    L14_2(L15_2, L16_2, L17_2, L18_2)
    L14_2 = TriggerClientEvent
    L15_2 = "codem-inventory:client:additem"
    L16_2 = L5_2
    L17_2 = L12_2
    L18_2 = L11_2[L12_2]
    L14_2(L15_2, L16_2, L17_2, L18_2)
    L14_2 = SetInventory
    L15_2 = L1_2
    L14_2(L15_2)
    L14_2 = SetInventory
    L15_2 = L5_2
    L14_2(L15_2)
  end  L14_2 = Config
  L14_2 = L14_2.UseDiscordWebhooks
  if L14_2 then
    L14_2 = {}
    L15_2 = GetName
    L16_2 = L1_2
    L15_2 = L15_2(L16_2)
    L16_2 = "-"
    L17_2 = L1_2
    L15_2 = L15_2 .. L16_2 .. L17_2
    L14_2.playername = L15_2
    L15_2 = L4_2.label
    L14_2.itemname = L15_2
    L15_2 = L4_2.amount
    L14_2.amount = L15_2
    L15_2 = L4_2.info
    if not L15_2 then
      L15_2 = nil
    end
    L14_2.info = L15_2
    L15_2 = "Target ID : "
    L16_2 = L5_2
    L17_2 = " "
    L18_2 = "Target Name : "
    L19_2 = GetName
    L20_2 = L5_2
    L19_2 = L19_2(L20_2)
    L20_2 = " "
    L21_2 = Locales
    L22_2 = Config
    L22_2 = L22_2.Language
    L21_2 = L21_2[L22_2]
    L21_2 = L21_2.notification
    L21_2 = L21_2.GIVEITEMTOPLAYER
    L15_2 = L15_2 .. L16_2 .. L17_2 .. L18_2 .. L19_2 .. L20_2 .. L21_2
    L14_2.reason = L15_2
    L15_2 = TriggerEvent
    L16_2 = "codem-inventory:CreateLog"
    L17_2 = Locales
    L18_2 = Config
    L18_2 = L18_2.Language
    L17_2 = L17_2[L18_2]
    L17_2 = L17_2.notification
    L17_2 = L17_2.GIVEITEMTOPLAYER
    L18_2 = "green"
    L19_2 = L14_2
    L20_2 = L1_2
    L21_2 = "give"
    L15_2(L16_2, L17_2, L18_2, L19_2, L20_2, L21_2)
  end
  L14_2 = TriggerClientEvent
  L15_2 = "codem-inventory:giveanim"
  L16_2 = L1_2
  L14_2(L15_2, L16_2)
  L14_2 = TriggerClientEvent
  L15_2 = "codem-inventory:giveanim"
  L16_2 = L5_2
  L14_2(L15_2, L16_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:robplayer"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tonumber
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = Identifier
  L4_2 = L4_2[L3_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = PlayerServerInventory
  L5_2 = L5_2[L4_2]
  L5_2 = L5_2.inventory
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.PLAYERINVENTORYNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = GetJob
  L7_2 = L3_2
  L8_2 = L8_2(L7_2)
  L7_2 = Config
  L7_2 = L7_2.NotRobJob
  L7_2 = L7_2[L6_2]
  if L7_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.NOTROBJOB
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = Config
  L7_2 = L7_2.Cheaterlogs
  if L7_2 then
    L7_2 = GetEntityCoords
    L8_2 = GetPlayerPed
    L9_2 = L1_2
    L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2 = L8_2(L9_2)
    L7_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
    L8_2 = GetEntityCoords
    L9_2 = GetPlayerPed
    L10_2 = L3_2
    L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2 = L9_2(L10_2)
    L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
    L9_2 = L7_2 - L8_2
    L9_2 = #L9_2
    if L9_2 > 5.0 then
      L10_2 = Config
      L10_2 = L10_2.UseDiscordWebhooks
      if L10_2 then
        L10_2 = {}
        L11_2 = GetName
        L12_2 = L1_2
        L11_2 = L11_2(L12_2)
        L12_2 = "-"
        L13_2 = L1_2
        L14_2 = ", Identifier : "
        L15_2 = L2_2
        L11_2 = L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2
        L10_2.playername = L11_2
        L11_2 = "Rob Player Distance : "
        L12_2 = L9_2
        L11_2 = L11_2 .. L12_2
        L10_2.event = L11_2
        L11_2 = TriggerEvent
        L12_2 = "codem-inventory:cheaterlogs"
        L13_2 = L10_2
        L11_2(L12_2, L13_2)
      end
      return
    end
  end
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:OpenPlayerInventory"
  L9_2 = L1_2
  L10_2 = L5_2
  L11_2 = L3_2
  L12_2 = GetName
  L13_2 = L3_2
  L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2)
  L7_2 = TriggerClientEvent
  L8_2 = "codem-inventory:client:robstatus"
  L9_2 = L3_2
  L10_2 = true
  L7_2(L8_2, L9_2, L10_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:openplayerinventory"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = tonumber
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = Identifier
  L4_2 = L4_2[L3_2]
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = PlayerServerInventory
  L5_2 = L5_2[L4_2]
  L5_2 = L5_2.inventory
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.PLAYERINVENTORYNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = Config
  L8_2 = L8_2.Cheaterlogs
  if L8_2 then
    L8_2 = Config
    L8_2 = L8_2.Framework
    if "qb" ~= L8_2 then
      L8_2 = Config
      L8_2 = L8_2.Framework
      if "oldqb" ~= L8_2 then
        goto lbl_105
      end
    end
    L8_2 = Core
    L8_2 = L8_2.Functions
    L8_2 = L8_2.HasPermission
    L7_2 = L1_2
    L8_2 = "user"
    L8_2 = L8_2(L7_2, L8_2)
    if L8_2 then
      L7_2 = Config
      L7_2 = L7_2.UseDiscordWebhooks
      if L7_2 then
        L7_2 = {}
        L8_2 = GetName
        L9_2 = L1_2
        L8_2 = L8_2(L9_2)
        L9_2 = "-"
        L10_2 = L1_2
        L11_2 = ", Identifier : "
        L12_2 = L2_2
        L8_2 = L8_2 .. L9_2 .. L10_2 .. L11_2 .. L12_2
        L7_2.playername = L8_2
        L7_2.event = "Open Player Inventory Event : "
        L8_2 = TriggerEvent
        L9_2 = "codem-inventory:cheaterlogs"
        L10_2 = L7_2
        L8_2(L9_2, L10_2)
        return
      end
    end
    ::lbl_105::
    L8_2 = Config
    L8_2 = L8_2.Framework
    if "esx" ~= L8_2 then
      L8_2 = Config
      L8_2 = L8_2.Framework
      if "oldesx" ~= L8_2 then
        goto lbl_139
      end
    end
    L8_2 = CheckIfAdmin
    L7_2 = L1_2
    L8_2 = L8_2(L7_2)
    if not L8_2 then
      L8_2 = Config
      L8_2 = L8_2.UseDiscordWebhooks
      if L8_2 then
        L8_2 = {}
        L7_2 = GetName
        L8_2 = L1_2
        L7_2 = L7_2(L8_2)
        L8_2 = "-"
        L9_2 = L1_2
        L10_2 = ", Identifier : "
        L11_2 = L2_2
        L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2
        L8_2.playername = L7_2
        L8_2.event = "Open Player Inventory Event "
        L7_2 = TriggerEvent
        L8_2 = "codem-inventory:cheaterlogs"
        L9_2 = L6_2
        L7_2(L8_2, L9_2)
        return
      end
    end
  end
  ::lbl_139::
  L8_2 = TriggerClientEvent
  L7_2 = "codem-inventory:client:OpenPlayerInventory"
  L8_2 = L1_2
  L9_2 = L5_2
  L10_2 = L3_2
  L11_2 = GetName
  L12_2 = L3_2
  L11_2, L12_2 = L11_2(L12_2)
  L8_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2)
  L8_2 = TriggerClientEvent
  L7_2 = "codem-inventory:client:robstatus"
  L8_2 = L3_2
  L9_2 = true
  L8_2(L7_2, L8_2, L9_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:swaprobplayertomaininventory"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L1_2 = tonumber
  L2_2 = source
  L1_2 = L1_2(L2_2)
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERINVENTORYNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    L4_2 = debugprint
    L5_2 = "D\196\176KKAT ENVANTER BULUNAMADI 1942 SATIR"
    L4_2(L5_2)
    return
  end
  L4_2 = tonumber
  L5_2 = A0_2.playerid
  L4_2 = L4_2(L5_2)
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = Identifier
  L5_2 = L5_2[L4_2]
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.PLAYERNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = PlayerServerInventory
  L8_2 = L8_2[L5_2]
  L8_2 = L8_2.inventory
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.PLAYERINVENTORYNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = A0_2.itemname
  L8_2 = tostring
  L9_2 = A0_2.itemname
  L9_2 = L9_2.slot
  L8_2 = L8_2(L9_2)
  L7_2.slot = L8_2
  L7_2 = A0_2.itemname
  L7_2 = L7_2.slot
  L7_2 = L6_2[L7_2]
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = FindFirstEmptySlot
  L9_2 = L3_2
  L10_2 = Config
  L10_2 = L10_2.MaxSlots
  L8_2 = L8_2(L9_2, L10_2)
  if not L8_2 then
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:notification"
    L11_2 = L1_2
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.NOEMPTYSLOTAVILABLEYOUR
    L9_2(L10_2, L11_2, L12_2)
    return
  end
  L9_2 = Config
  L9_2 = L9_2.NotRobItem
  L10_2 = L7_2.name
  L9_2 = L9_2[L10_2]
  if L9_2 then
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:notification"
    L11_2 = L1_2
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.NOTSWAPITEM
    L9_2(L10_2, L11_2, L12_2)
    return
  end
  if L7_2 then
    L9_2 = L7_2.type
    if "bag" == L9_2 then
      L9_2 = CheckBagItem
      L10_2 = L1_2
      L9_2 = L9_2(L10_2)
      L10_2 = tonumber
      L11_2 = L9_2
      L10_2 = L10_2(L11_2)
      L11_2 = tonumber
      L12_2 = Config
      L12_2 = L12_2.MaxBackPackItem
      L11_2 = L11_2(L12_2)
      if L10_2 > L11_2 then
        L10_2 = TriggerClientEvent
        L11_2 = "codem-inventory:client:notification"
        L12_2 = L1_2
        L13_2 = Locales
        L14_2 = Config
        L14_2 = L14_2.Language
        L13_2 = L13_2[L14_2]
        L13_2 = L13_2.notification
        L13_2 = L13_2.MAXBAGPACKITEM
        L10_2(L11_2, L12_2, L13_2)
        return
      end
    end
  end
  L9_2 = CheckInventoryWeight
  L10_2 = L3_2
  L11_2 = L7_2.weight
  L12_2 = L7_2.amount
  L11_2 = L11_2 * L12_2
  L12_2 = Config
  L12_2 = L12_2.MaxWeight
  L9_2 = L9_2(L10_2, L11_2, L12_2)
  if not L9_2 then
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:notification"
    L11_2 = L1_2
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.INVENTORYISFULL
    L9_2(L10_2, L11_2, L12_2)
    return
  end
  L9_2 = tostring
  L10_2 = L8_2
  L9_2 = L9_2(L10_2)
  L8_2 = L9_2
  L3_2[L8_2] = L7_2
  L9_2 = L3_2[L8_2]
  L9_2.slot = L8_2
  L9_2 = A0_2.itemname
  L9_2 = L9_2.slot
  L9_2 = L6_2[L9_2]
  L9_2 = L9_2.amount
  if not L9_2 then
    L9_2 = 1
  end
  L10_2 = A0_2.itemname
  L10_2 = L10_2.slot
  L8_2[L10_2] = nil
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:removeitemtoclientInventory"
  L12_2 = L4_2
  L13_2 = A0_2.itemname
  L13_2 = L13_2.slot
  L14_2 = L9_2
  L10_2(L11_2, L12_2, L13_2, L14_2)
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:additem"
  L12_2 = L1_2
  L13_2 = L8_2
  L14_2 = L3_2[L8_2]
  L10_2(L11_2, L12_2, L13_2, L14_2)
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:refreshrobplayerinventory"
  L12_2 = L1_2
  L13_2 = L6_2
  L10_2(L11_2, L12_2, L13_2)
  L10_2 = Config
  L10_2 = L10_2.CashItem
  if L10_2 then
    L10_2 = L7_2.name
    if "cash" == L10_2 then
      L10_2 = AddMoney
      L11_2 = L1_2
      L12_2 = "cash"
      L13_2 = L7_2.amount
      L10_2(L11_2, L12_2, L13_2)
      L10_2 = GetItemsTotalAmount
      L11_2 = L4_2
      L12_2 = "cash"
      L10_2 = L10_2(L11_2, L12_2)
      L11_2 = GetPlayer
      L12_2 = L4_2
      L11_2 = L11_2(L12_2)
      L12_2 = Config
      L12_2 = L12_2.Framework
      if "qb" ~= L12_2 then
        L12_2 = Config
        L12_2 = L12_2.Framework
        if "oldqb" ~= L12_2 then
          goto lbl_264
        end
      end
      L12_2 = L11_2.Functions
      L12_2 = L12_2.SetMoney
      L13_2 = "cash"
      L14_2 = L10_2
      L12_2(L13_2, L14_2)
      goto lbl_273
      ::lbl_264::
      L12_2 = L11_2.setMoney
      L13_2 = tonumber
      L14_2 = L10_2
      L13_2, L14_2, L15_2, L16_2, L17_2, L18_2 = L13_2(L14_2)
      L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
  end
  else
    L10_2 = SetInventory
    L11_2 = L1_2
    L10_2(L11_2)
  end
  ::lbl_273::
  L10_2 = SetInventory
  L11_2 = L4_2
  L10_2(L11_2)
  L10_2 = Config
  L10_2 = L10_2.UseDiscordWebhooks
  if L10_2 then
    L10_2 = {}
    L11_2 = GetName
    L12_2 = L1_2
    L11_2 = L11_2(L12_2)
    L12_2 = "-"
    L13_2 = L1_2
    L11_2 = L11_2 .. L12_2 .. L13_2
    L10_2.playername = L11_2
    L11_2 = L7_2.label
    L10_2.itemname = L11_2
    L11_2 = L7_2.amount
    L10_2.amount = L11_2
    L11_2 = L7_2.info
    if not L11_2 then
      L11_2 = nil
    end
    L10_2.info = L11_2
    L11_2 = "Target ID : "
    L12_2 = L4_2
    L13_2 = " "
    L14_2 = "Target Name : "
    L15_2 = GetName
    L16_2 = L4_2
    L15_2 = L15_2(L16_2)
    L16_2 = " "
    L17_2 = Locales
    L18_2 = Config
    L18_2 = L18_2.Language
    L17_2 = L17_2[L18_2]
    L17_2 = L17_2.notification
    L17_2 = L17_2.ROBPLAYER
    L11_2 = L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2 .. L16_2 .. L17_2
    L10_2.reason = L11_2
    L11_2 = TriggerEvent
    L12_2 = "codem-inventory:CreateLog"
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.ROBPLAYER
    L14_2 = "green"
    L15_2 = L10_2
    L16_2 = L1_2
    L17_2 = "player"
    L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:swapmaininventorytorobplayer"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L1_2 = source
  L2_2 = Identifier
  L2_2 = L2_2[L1_2]
  if not L2_2 then
    L3_2 = TriggerClientEvent
    L4_2 = "codem-inventory:client:notification"
    L5_2 = L1_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.IDENTIFIERNOTFOUND
    L3_2(L4_2, L5_2, L8_2)
    return
  end
  L3_2 = PlayerServerInventory
  L3_2 = L3_2[L2_2]
  if L3_2 then
    L3_2 = PlayerServerInventory
    L3_2 = L3_2[L2_2]
    L3_2 = L3_2.inventory
  end
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.PLAYERINVENTORYNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    L4_2 = debugprint
    L5_2 = "D\196\176KKAT ENVANTER BULUNAMADI 2013 SATIR"
    L4_2(L5_2)
    return
  end
  L4_2 = tonumber
  L5_2 = A0_2.playerid
  L4_2 = L4_2(L5_2)
  if not L4_2 then
    L5_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L7_2 = L1_2
    L8_2 = Locales
    L9_2 = Config
    L9_2 = L9_2.Language
    L8_2 = L8_2[L9_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.PLAYERNOTFOUND
    L5_2(L8_2, L7_2, L8_2)
    return
  end
  L5_2 = Identifier
  L5_2 = L5_2[L4_2]
  if not L5_2 then
    L8_2 = TriggerClientEvent
    L7_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L9_2 = Locales
    L10_2 = Config
    L10_2 = L10_2.Language
    L9_2 = L9_2[L10_2]
    L9_2 = L9_2.notification
    L9_2 = L9_2.PLAYERNOTFOUND
    L8_2(L7_2, L8_2, L9_2)
    return
  end
  L8_2 = PlayerServerInventory
  L8_2 = L8_2[L5_2]
  L8_2 = L8_2.inventory
  if not L8_2 then
    L7_2 = TriggerClientEvent
    L8_2 = "codem-inventory:client:notification"
    L9_2 = L1_2
    L10_2 = Locales
    L11_2 = Config
    L11_2 = L11_2.Language
    L10_2 = L10_2[L11_2]
    L10_2 = L10_2.notification
    L10_2 = L10_2.PLAYERINVENTORYNOTFOUND
    L7_2(L8_2, L9_2, L10_2)
    return
  end
  L7_2 = tostring
  L8_2 = A0_2.oldSlot
  L7_2 = L7_2(L8_2)
  A0_2.oldSlot = L7_2
  L7_2 = A0_2.oldSlot
  L7_2 = L3_2[L7_2]
  if not L7_2 then
    L8_2 = TriggerClientEvent
    L9_2 = "codem-inventory:client:notification"
    L10_2 = L1_2
    L11_2 = Locales
    L12_2 = Config
    L12_2 = L12_2.Language
    L11_2 = L11_2[L12_2]
    L11_2 = L11_2.notification
    L11_2 = L11_2.ITEMNOTFOUNDINGIVENSLOT
    L8_2(L9_2, L10_2, L11_2)
    return
  end
  L8_2 = FindFirstEmptySlot
  L9_2 = L6_2
  L10_2 = Config
  L10_2 = L10_2.MaxSlots
  L8_2 = L8_2(L9_2, L10_2)
  if not L8_2 then
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:notification"
    L11_2 = L1_2
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.NOEMPTYSLOTAVILABLETARGET
    L9_2(L10_2, L11_2, L12_2)
    return
  end
  L9_2 = Config
  L9_2 = L9_2.NotRobItem
  L10_2 = L7_2.name
  L9_2 = L9_2[L10_2]
  if L9_2 then
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:notification"
    L11_2 = L1_2
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.NOTSWAPITEM
    L9_2(L10_2, L11_2, L12_2)
    return
  end
  if L7_2 then
    L9_2 = L7_2.type
    if "bag" == L9_2 then
      L9_2 = CheckBagItem
      L10_2 = L1_2
      L9_2 = L9_2(L10_2)
      L10_2 = tonumber
      L11_2 = L9_2
      L10_2 = L10_2(L11_2)
      L11_2 = tonumber
      L12_2 = Config
      L12_2 = L12_2.MaxBackPackItem
      L11_2 = L11_2(L12_2)
      if L10_2 > L11_2 then
        L10_2 = TriggerClientEvent
        L11_2 = "codem-inventory:client:notification"
        L12_2 = L1_2
        L13_2 = Locales
        L14_2 = Config
        L14_2 = L14_2.Language
        L13_2 = L13_2[L14_2]
        L13_2 = L13_2.notification
        L13_2 = L13_2.MAXBAGPACKITEM
        L10_2(L11_2, L12_2, L13_2)
        return
      end
    end
  end
  L9_2 = CheckInventoryWeight
  L10_2 = L6_2
  L11_2 = L7_2.weight
  L12_2 = L7_2.amount
  L11_2 = L11_2 * L12_2
  L12_2 = Config
  L12_2 = L12_2.MaxWeight
  L9_2 = L9_2(L10_2, L11_2, L12_2)
  if not L9_2 then
    L9_2 = TriggerClientEvent
    L10_2 = "codem-inventory:client:notification"
    L11_2 = L1_2
    L12_2 = Locales
    L13_2 = Config
    L13_2 = L13_2.Language
    L12_2 = L12_2[L13_2]
    L12_2 = L12_2.notification
    L12_2 = L12_2.INVENTORYISFULL
    L9_2(L10_2, L11_2, L12_2)
    return
  end
  L9_2 = tostring
  L10_2 = L8_2
  L9_2 = L9_2(L10_2)
  L8_2 = L9_2
  L8_2[L8_2] = L7_2
  L9_2 = L6_2[L8_2]
  L9_2.slot = L8_2
  L9_2 = A0_2.oldSlot
  L9_2 = L3_2[L9_2]
  L9_2 = L9_2.amount
  if not L9_2 then
    L9_2 = 1
  end
  L10_2 = A0_2.oldSlot
  L3_2[L10_2] = nil
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:removeitemtoclientInventory"
  L12_2 = L1_2
  L13_2 = A0_2.oldSlot
  L14_2 = L9_2
  L10_2(L11_2, L12_2, L13_2, L14_2)
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:client:additem"
  L12_2 = L4_2
  L13_2 = L8_2
  L14_2 = L6_2[L8_2]
  L10_2(L11_2, L12_2, L13_2, L14_2)
  L10_2 = TriggerClientEvent
  L11_2 = "codem-inventory:refreshrobplayerinventory"
  L12_2 = L1_2
  L13_2 = L6_2
  L10_2(L11_2, L12_2, L13_2)
  L10_2 = Config
  L10_2 = L10_2.CashItem
  if L10_2 then
    L10_2 = L7_2.name
    if "cash" == L10_2 then
      L10_2 = AddMoney
      L11_2 = L4_2
      L12_2 = "cash"
      L13_2 = L7_2.amount
      L10_2(L11_2, L12_2, L13_2)
      L10_2 = GetItemsTotalAmount
      L11_2 = L1_2
      L12_2 = "cash"
      L10_2 = L10_2(L11_2, L12_2)
      L11_2 = GetPlayer
      L12_2 = L1_2
      L11_2 = L11_2(L12_2)
      L12_2 = Config
      L12_2 = L12_2.Framework
      if "qb" ~= L12_2 then
        L12_2 = Config
        L12_2 = L12_2.Framework
        if "oldqb" ~= L12_2 then
          goto lbl_256
        end
      end
      L12_2 = L11_2.Functions
      L12_2 = L12_2.SetMoney
      L13_2 = "cash"
      L14_2 = L10_2
      L12_2(L13_2, L14_2)
      goto lbl_265
      ::lbl_256::
      L12_2 = L11_2.setMoney
      L13_2 = tonumber
      L14_2 = L10_2
      L13_2, L14_2, L15_2, L16_2, L17_2, L18_2 = L13_2(L14_2)
      L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
  end
  else
    L10_2 = SetInventory
    L11_2 = L1_2
    L10_2(L11_2)
  end
  ::lbl_265::
  L10_2 = SetInventory
  L11_2 = L4_2
  L10_2(L11_2)
  L10_2 = Config
  L10_2 = L10_2.UseDiscordWebhooks
  if L10_2 then
    L10_2 = {}
    L11_2 = GetName
    L12_2 = L1_2
    L11_2 = L11_2(L12_2)
    L12_2 = "-"
    L13_2 = L1_2
    L11_2 = L11_2 .. L12_2 .. L13_2
    L10_2.playername = L11_2
    L11_2 = L7_2.label
    L10_2.itemname = L11_2
    L11_2 = L7_2.info
    if not L11_2 then
      L11_2 = nil
    end
    L10_2.info = L11_2
    L11_2 = L7_2.amount
    L10_2.amount = L11_2
    L11_2 = "Target ID : "
    L12_2 = L4_2
    L13_2 = " "
    L14_2 = "Target Name : "
    L15_2 = GetName
    L16_2 = L4_2
    L15_2 = L15_2(L16_2)
    L16_2 = " "
    L17_2 = Locales
    L18_2 = Config
    L18_2 = L18_2.Language
    L17_2 = L17_2[L18_2]
    L17_2 = L17_2.notification
    L17_2 = L17_2.ROBPLAYERADD
    L11_2 = L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2 .. L16_2 .. L17_2
    L10_2.reason = L11_2
    L11_2 = TriggerEvent
    L12_2 = "codem-inventory:CreateLog"
    L13_2 = Locales
    L14_2 = Config
    L14_2 = L14_2.Language
    L13_2 = L13_2[L14_2]
    L13_2 = L13_2.notification
    L13_2 = L13_2.ROBPLAYERADD
    L14_2 = "green"
    L15_2 = L10_2
    L16_2 = L1_2
    L17_2 = "player"
    L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:ChangePlayerRobStatus"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
  L1_2 = A0_2.playerid
  if L1_2 then
    L1_2 = TriggerClientEvent
    L2_2 = "codem-inventory:client:robstatus"
    L3_2 = tonumber
    L4_2 = A0_2.playerid
    L3_2 = L3_2(L4_2)
    L4_2 = false
    L1_2(L2_2, L3_2, L4_2)
  end
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:sortItems"
function fn_L3_1()
  -- Normalize and aggregate player inventory without dropping items
local src = source
local playerId = tonumber(src)
  if cooldown[playerId] then return end
  cooldown[playerId] = true
  SetTimeout(600, function() cooldown[playerId] = nil end)

local identifier = Identifier[src]
  if not identifier then
    TriggerClientEvent('codem-inventory:client:notification', src,
      Locales[Config.Language].notification.IDENTIFIERNOTFOUND)
    return
  end

local inv = PlayerServerInventory[identifier] and PlayerServerInventory[identifier].inventory
  if not inv then
    TriggerClientEvent('codem-inventory:client:notification', src,
      Locales[Config.Language].notification.PLAYERINVENTORYNOTFOUND)
    debugprint("Inventory not found in sortItems")
    return
  end

  -- Aggregate non-unique items by name, preserve unique items by slot
local combined = {}
  for slot, item in pairs(inv) do
    if item.unique then
local k = tostring(slot)
      combined[k] = item
      combined[k].slot = k
    else
      if combined[item.name] then
        combined[item.name].amount = combined[item.name].amount + item.amount
      else
        combined[item.name] = item
        -- slot will be reassigned below
      end
    end
  end

  -- Reassign slots sequentially
local sorted = {}
local i = 1
  for _, it in pairs(combined) do
local s = tostring(i)
    it.slot = s
    sorted[s] = it
    i = i + 1
  end

  PlayerServerInventory[identifier].inventory = sorted
  TriggerClientEvent('codem-inventory:client:sortItems', src, PlayerServerInventory[identifier].inventory)
  SetInventory(src)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterServerEvent
L2_1 = "codem-inventory:server:sortItemsStash"
function fn_L3_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L1_2 = source
  L2_2 = tonumber
  L3_2 = L1_2
  L2_2 = L2_2(L3_2)
  L3_2 = cooldown
  L3_2 = L3_2[L2_2]
  if L3_2 then
    return
  else
    L3_2 = cooldown
    L3_2[L2_2] = true
    L3_2 = SetTimeout
    L4_2 = 600
    function L5_2()
local cooldown, L1_3
      cooldown = cooldown
      L1_3 = L2_2
      cooldown[L1_3] = nil
    end
    L3_2(L4_2, L5_2)
  end
  L3_2 = Identifier
  L3_2 = L3_2[L1_2]
  if not L3_2 then
    L4_2 = TriggerClientEvent
    L5_2 = "codem-inventory:client:notification"
    L8_2 = L1_2
    L7_2 = Locales
    L8_2 = Config
    L8_2 = L8_2.Language
    L7_2 = L7_2[L8_2]
    L7_2 = L7_2.notification
    L7_2 = L7_2.IDENTIFIERNOTFOUND
    L4_2(L5_2, L8_2, L7_2)
    return
  end
  L4_2 = ServerStash
  L4_2 = L4_2[A0_2]
  if L4_2 then
    L4_2 = ServerStash
    L4_2 = L4_2[A0_2]
    L4_2 = L4_2.inventory
  end
  if not L4_2 then
    L5_2 = debugprint
    L8_2 = "Stash Bulunamad\196\177"
    L5_2(L8_2)
    return
  end
  L5_2 = {}
  L8_2 = pairs
  L7_2 = L4_2
  L8_2, L7_2, L8_2, L9_2 = L8_2(L7_2)
  for L10_2, L11_2 in L8_2, L7_2, L8_2, L9_2 do
    L12_2 = L11_2.unique
    if not L12_2 then
      L12_2 = L11_2.name
      L12_2 = L5_2[L12_2]
      if L12_2 then
        L12_2 = L11_2.name
        L12_2 = L5_2[L12_2]
        L13_2 = L11_2.name
        L13_2 = L5_2[L13_2]
        L13_2 = L13_2.amount
        L14_2 = L11_2.amount
        L13_2 = L13_2 + L14_2
        L12_2.amount = L13_2
    end
    else
      L12_2 = L11_2.unique
      if not L12_2 then
        L12_2 = L11_2.name
        L5_2[L12_2] = L11_2
      else
        L12_2 = tostring
        L13_2 = L10_2
        L12_2 = L12_2(L13_2)
        L5_2[L12_2] = L11_2
        L12_2 = tostring
        L13_2 = L10_2
        L12_2 = L12_2(L13_2)
        L12_2 = L5_2[L12_2]
        L13_2 = tostring
        L14_2 = L10_2
        L13_2 = L13_2(L14_2)
        L12_2.slot = L13_2
      end
    end
  end
  L8_2 = {}
  L7_2 = 1
  L8_2 = pairs
  L9_2 = L5_2
  L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
  for L12_2, L13_2 in L8_2, L9_2, L10_2, L11_2 do
    L14_2 = tostring
    L15_2 = L7_2
    L14_2 = L14_2(L15_2)
    L8_2[L14_2] = L13_2
    L14_2 = tostring
    L15_2 = L7_2
    L14_2 = L14_2(L15_2)
    L14_2 = L6_2[L14_2]
    L15_2 = tostring
    L16_2 = L7_2
    L15_2 = L15_2(L16_2)
    L14_2.slot = L15_2
    L7_2 = L7_2 + 1
  end
  L8_2 = ServerStash
  L8_2 = L8_2[A0_2]
  L8_2.inventory = L8_2
  L8_2 = TriggerClientEvent
  L9_2 = "codem-inventory:UpdateStashItems"
  L10_2 = L1_2
  L11_2 = A0_2
  L12_2 = L6_2
  L8_2(L9_2, L10_2, L11_2, L12_2)
  L8_2 = UpdateStashDatabase
  L9_2 = A0_2
  L10_2 = L6_2
  L8_2(L9_2, L10_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterCommand
L2_1 = Config
L2_1 = L2_1.Commands
L2_1 = L2_1.checkserveronlineitems
function fn_L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  if A0_2 > 0 then
    return
  end
  L2_2 = A1_2[1]
  L3_2 = {}
  L4_2 = pairs
  L5_2 = PlayerServerInventory
  L4_2, L5_2, L8_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L8_2, L7_2 do
    L10_2 = L9_2.inventory
    L11_2 = 0
    L12_2 = pairs
    L13_2 = L10_2
    L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
    for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
      L18_2 = L17_2.name
      if L18_2 == L2_2 then
        L18_2 = L17_2.amount
        L11_2 = L11_2 + L18_2
      end
    end
    if L11_2 > 0 then
      L12_2 = L3_2[L8_2]
      if not L12_2 then
        L12_2 = 0
      end
      L12_2 = L12_2 + L11_2
      L3_2[L8_2] = L12_2
    end
  end
  L4_2 = {}
  L5_2 = pairs
  L8_2 = L3_2
  L5_2, L8_2, L7_2, L8_2 = L5_2(L8_2)
  for L9_2, L10_2 in L5_2, L8_2, L7_2, L8_2 do
    L11_2 = table
    L11_2 = L11_2.insert
    L12_2 = L4_2
    L13_2 = {}
    L13_2.identifier = L9_2
    L13_2.totalAmount = L10_2
    L11_2(L12_2, L13_2)
  end
  L5_2 = table
  L5_2 = L5_2.sort
  L8_2 = L4_2
  function L7_2(A0_3, A1_3)
local L2_3, L3_3
    L2_3 = A0_3.totalAmount
    L3_3 = A1_3.totalAmount
    L2_3 = L2_3 > L3_3
    return L2_3
  end
  L5_2(L8_2, L7_2)
  L5_2 = "Offline items report for `"
  L8_2 = L2_2
  L7_2 = "`:\n"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L8_2 = math
  L8_2 = L8_2.min
  L7_2 = #L4_2
  L8_2 = 100
  L8_2 = L8_2(L7_2, L8_2)
  if L8_2 > 0 then
    L7_2 = 1
    L8_2 = L6_2
    L9_2 = 1
    for L10_2 = L7_2, L8_2, L9_2 do
      L11_2 = L4_2[L10_2]
      L12_2 = L5_2
      L13_2 = "Identifier: "
      L14_2 = L11_2.identifier
      L15_2 = ", Total Amount: "
      L16_2 = L11_2.totalAmount
      L17_2 = "\n"
      L12_2 = L12_2 .. L13_2 .. L14_2 .. L15_2 .. L16_2 .. L17_2
      L5_2 = L12_2
    end
  else
    L7_2 = "No offline items found for `"
    L8_2 = L2_2
    L9_2 = "`."
    L7_2 = L7_2 .. L8_2 .. L9_2
    L5_2 = L7_2
  end
  L7_2 = PerformHttpRequest
  L8_2 = DiscordWebhook
  L8_2 = L8_2.checkserveritems
  function L9_2(A0_3, A1_3, A2_3)
  end
  L10_2 = "POST"
  L11_2 = json
  L11_2 = L11_2.encode
  L12_2 = {}
  L12_2.username = "Server Item Checker"
  L13_2 = {}
  L14_2 = {}
  L14_2.title = "Server Online Items Check"
  L14_2.description = L5_2
  L14_2.color = 65280
  L13_2[1] = L14_2
  L12_2.embeds = L13_2
  L11_2 = L11_2(L12_2)
  L12_2 = {}
  L12_2["Content-Type"] = "application/json"
  L7_2(L8_2, L9_2, L10_2, L11_2, L12_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = RegisterCommand
L2_1 = Config
L2_1 = L2_1.Commands
L2_1 = L2_1.checkserverofflineitems
function fn_L3_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
  if A0_2 > 0 then
    return
  end
  L2_2 = A1_2[1]
  if not L2_2 then
    return
  end
  L3_2 = {}
  L4_2 = {}
  L5_2 = DiscordWebhook
  L5_2 = L5_2.checkserveritems
  L8_2 = ExecuteSql
  L7_2 = "SELECT identifier, inventory FROM `codem_new_inventory`"
  L8_2 = L8_2(L7_2)
  L7_2 = ipairs
  L8_2 = L6_2
  L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
  for L11_2, L12_2 in L7_2, L8_2, L9_2, L10_2 do
    L13_2 = json
    L13_2 = L13_2.decode
    L14_2 = L12_2.inventory
    if not L14_2 then
      L14_2 = "{}"
    end
    L13_2 = L13_2(L14_2)
    L14_2 = 0
    L15_2 = pairs
    L16_2 = L13_2
    L15_2, L16_2, L17_2, L18_2 = L15_2(L16_2)
    for L19_2, L20_2 in L15_2, L16_2, L17_2, L18_2 do
      L21_2 = L20_2.name
      if L21_2 == L2_2 then
        L21_2 = L20_2.amount
        L14_2 = L14_2 + L21_2
      end
    end
    if L14_2 > 0 then
      L15_2 = L12_2.identifier
      L16_2 = L12_2.identifier
      L16_2 = L3_2[L16_2]
      if not L16_2 then
        L16_2 = 0
      end
      L16_2 = L16_2 + L14_2
      L3_2[L15_2] = L16_2
    end
  end
  L7_2 = pairs
  L8_2 = L3_2
  L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
  for L11_2, L12_2 in L7_2, L8_2, L9_2, L10_2 do
    L13_2 = table
    L13_2 = L13_2.insert
    L14_2 = L4_2
    L15_2 = {}
    L15_2.identifier = L11_2
    L15_2.totalAmount = L12_2
    L13_2(L14_2, L15_2)
  end
  L7_2 = table
  L7_2 = L7_2.sort
  L8_2 = L4_2
  function L9_2(A0_3, A1_3)
local L2_3, L3_3
    L2_3 = A0_3.totalAmount
    L3_3 = A1_3.totalAmount
    L2_3 = L2_3 > L3_3
    return L2_3
  end
  L7_2(L8_2, L9_2)
  L7_2 = "Offline items report for `"
  L8_2 = L2_2
  L9_2 = "`:\n"
  L7_2 = L7_2 .. L8_2 .. L9_2
  L8_2 = math
  L8_2 = L8_2.min
  L9_2 = #L4_2
  L10_2 = 100
  L8_2 = L8_2(L9_2, L10_2)
  if L8_2 > 0 then
    L9_2 = 1
    L10_2 = L8_2
    L11_2 = 1
    for L12_2 = L9_2, L10_2, L11_2 do
      L13_2 = L4_2[L12_2]
      L14_2 = L7_2
      L15_2 = "Identifier: "
      L16_2 = L13_2.identifier
      L17_2 = ", Total Amount: "
      L18_2 = L13_2.totalAmount
      L19_2 = "\n"
      L14_2 = L14_2 .. L15_2 .. L16_2 .. L17_2 .. L18_2 .. L19_2
      L7_2 = L14_2
    end
  else
    L9_2 = "No offline items found for `"
    L10_2 = L2_2
    L11_2 = "`."
    L9_2 = L9_2 .. L10_2 .. L11_2
    L7_2 = L9_2
  end
  L9_2 = PerformHttpRequest
  L10_2 = L5_2
  function L11_2(A0_3, A1_3, A2_3)
  end
  L12_2 = "POST"
  L13_2 = json
  L13_2 = L13_2.encode
  L14_2 = {}
  L14_2.username = "Server Item Checker"
  L15_2 = {}
  L16_2 = {}
  L16_2.title = "Server Offline Items Check"
  L16_2.description = L7_2
  L16_2.color = 65280
  L15_2[1] = L16_2
  L14_2.embeds = L15_2
  L13_2 = L13_2(L14_2)
  L14_2 = {}
  L14_2["Content-Type"] = "application/json"
  L9_2(L10_2, L11_2, L12_2, L13_2, L14_2)
end
CheckDupliceteItems(L2_1, fn_L3_1)
CheckDupliceteItems = {}
function L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2
  L2_2 = ipairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L8_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = json
    L8_2 = L8_2.decode
    L9_2 = L7_2.inventory
    if not L9_2 then
      L9_2 = "{}"
    end
    L8_2 = L8_2(L9_2)
    L9_2 = pairs
    L10_2 = L8_2
    L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
    for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
      L15_2 = L14_2.info
      if L15_2 then
        L15_2 = L14_2.info
        L15_2 = L15_2.series
        if L15_2 then
          L15_2 = L14_2.info
          L15_2 = L15_2.series
          L16_2 = L1_1
          L17_2 = L1_1
          L17_2 = L17_2[L15_2]
          if not L17_2 then
            L17_2 = {}
            L18_2 = L14_2.name
            L17_2.name = L18_2
            L17_2.count = 0
            L18_2 = {}
            L17_2.sources = L18_2
          end
          L16_2[L15_2] = L17_2
          L16_2 = L7_2.identifier
          if not L16_2 then
            L16_2 = L7_2.stashname
            if not L16_2 then
              L16_2 = L7_2.plate
            end
          end
          L17_2 = string
          L17_2 = L17_2.format
          L18_2 = "%s:%s"
          L19_2 = A1_2
          L20_2 = L16_2
          L17_2 = L17_2(L18_2, L19_2, L20_2)
          L18_2 = L1_1
          L18_2 = L18_2[L15_2]
          L19_2 = L1_1
          L19_2 = L19_2[L15_2]
          L19_2 = L19_2.count
          L19_2 = L19_2 + 1
          L18_2.count = L19_2
          L18_2 = table
          L18_2 = L18_2.insert
          L19_2 = L1_1
          L19_2 = L19_2[L15_2]
          L19_2 = L19_2.sources
          L20_2 = {}
          L20_2.source = L17_2
          L21_2 = L13_2 or L21_2
          if not L13_2 then
            L21_2 = L14_2.slot
          end
          L20_2.slot = L21_2
          L21_2 = L14_2.info
          L21_2 = L21_2.series
          L20_2.serial = L21_2
          L18_2(L19_2, L20_2)
        end
      end
    end
  end
end
processInventoryData = L2_1
function L2_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L26_2, L24_2, l5_2, L26_2, L27_2, L28_2, l22_2, l19_2, l23_2
  L0_2 = false
  L1_2 = ipairs
  L2_2 = GetPlayers
  L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2 = L2_2()
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L8_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2)
  for L5_2, L8_2 in L1_2, L2_2, L3_2, L4_2 do
    L0_2 = true
  end
  if L0_2 then
    L1_2 = print
    L2_2 = "^2 Duplicate check failed because there is a player on the server ^0"
    L1_2(L2_2)
    return
  end
  L1_2 = DiscordWebhook
  L1_2 = L1_2.duplicateitems
  L2_2 = ExecuteSql
  L3_2 = "SELECT identifier, inventory FROM `codem_new_inventory`"
  L2_2 = L2_2(L3_2)
  L3_2 = ExecuteSql
  L4_2 = "SELECT stashname, inventory FROM `codem_new_stash`"
  L3_2 = L3_2(L4_2)
  L4_2 = ExecuteSql
  L5_2 = "SELECT plate, trunk, glovebox FROM `codem_new_vehicleandglovebox`"
  L4_2 = L4_2(L5_2)
  L5_2 = processInventoryData
  L8_2 = L2_2
  L7_2 = "Player"
  L5_2(L8_2, L7_2)
  L5_2 = processInventoryData
  L8_2 = L3_2
  L7_2 = "Stash"
  L5_2(L8_2, L7_2)
  L5_2 = ipairs
  L8_2 = L4_2
  L5_2, L8_2, L7_2, L8_2 = L5_2(L8_2)
  for L9_2, L10_2 in L5_2, L8_2, L7_2, L8_2 do
    L11_2 = json
    L11_2 = L11_2.decode
    L12_2 = L10_2.trunk
    if not L12_2 then
      L12_2 = "{}"
    end
    L11_2 = L11_2(L12_2)
    L12_2 = json
    L12_2 = L12_2.decode
    L13_2 = L10_2.glovebox
    if not L13_2 then
      L13_2 = "{}"
    end
    L12_2 = L12_2(L13_2)
    L13_2 = processInventoryData
    L14_2 = {}
    L15_2 = {}
    L16_2 = L10_2.plate
    L15_2.plate = L16_2
    L16_2 = json
    L16_2 = L16_2.encode
    L17_2 = L11_2
    L16_2 = L16_2(L17_2)
    L15_2.inventory = L16_2
    L14_2[1] = L15_2
    L15_2 = "Trunk"
    L13_2(L14_2, L15_2)
    L13_2 = processInventoryData
    L14_2 = {}
    L15_2 = {}
    L16_2 = L10_2.plate
    L15_2.plate = L16_2
    L16_2 = json
    L16_2 = L16_2.encode
    L17_2 = L12_2
    L16_2 = L16_2(L17_2)
    L15_2.inventory = L16_2
    L14_2[1] = L15_2
    L15_2 = "Glovebox"
    L13_2(L14_2, L15_2)
  end
  L5_2 = {}
  L8_2 = pairs
  L7_2 = L1_1
  L8_2, L7_2, L8_2, L9_2 = L8_2(L7_2)
  for L10_2, L11_2 in L8_2, L7_2, L8_2, L9_2 do
    L12_2 = L11_2.count
    if L12_2 > 1 then
      L12_2 = ipairs
      L13_2 = L11_2.sources
      L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
      for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
        L18_2 = {}
        L19_2 = L17_2.source
        L20_2 = L19_2
        L19_2 = L19_2.gmatch
        L21_2 = "[^:]+"
        L19_2, L20_2, L21_2, L22_2 = L19_2(L20_2, L21_2)
        for L23_2 in L19_2, L20_2, L21_2, L22_2 do
          L24_2 = table
          L24_2 = L24_2.insert
          l18_2 = L18_2
          L26_2 = L23_2
          L24_2(l18_2, L26_2)
        end
        L19_2 = L18_2[2]
        L20_2 = nil
        L21_2 = string
        L21_2 = L21_2.find
        L22_2 = L17_2.source
        L23_2 = "Trunk"
        L21_2 = L21_2(L22_2, L23_2)
        if L21_2 then
          L20_2 = "Trunk"
        else
          L21_2 = string
          L21_2 = L21_2.find
          L22_2 = L17_2.source
          L23_2 = "Glovebox"
          L21_2 = L21_2(L22_2, L23_2)
          if L21_2 then
            L20_2 = "Glovebox"
          else
            L21_2 = string
            L21_2 = L21_2.find
            L22_2 = L17_2.source
            L23_2 = "Stash"
            L21_2 = L21_2(L22_2, L23_2)
            if L21_2 then
              L20_2 = "Stash"
            else
              L21_2 = string
              L21_2 = L21_2.find
              L22_2 = L17_2.source
              L23_2 = "Player"
              L21_2 = L21_2(L22_2, L23_2)
              if L21_2 then
                L20_2 = "Player"
              end
            end
          end
        end
        if "Trunk" == L20_2 then
          L21_2 = VehicleInventory
          L21_2 = L21_2[L19_2]
          if L21_2 then
            L21_2 = VehicleInventory
            L21_2 = L21_2[L19_2]
            L21_2 = L21_2.trunk
            L22_2 = L17_2.slot
            L21_2 = L21_2[L22_2]
            if L21_2 then
              L21_2 = VehicleInventory
              L21_2 = L21_2[L19_2]
              L21_2 = L21_2.trunk
              L22_2 = L17_2.slot
              L21_2[L22_2] = nil
              L21_2 = UpdateVehicleInventory
              L22_2 = L19_2
              L26_2 = VehicleInventory
              L26_2 = L26_2[L19_2]
              L26_2 = L26_2.trunk
              L21_2(L22_2, L26_2)
              L21_2 = print
              L22_2 = "^2 DELETE DUPLICATED ITEM FROM TRUNK INVENTORY ^0"
              L21_2(L22_2)
          end
        end
        else
          if "Glovebox" == L20_2 then
            L21_2 = GloveBoxInventory
            L21_2 = L21_2[L19_2]
            if L21_2 then
              L21_2 = GloveBoxInventory
              L21_2 = L21_2[L19_2]
              L21_2 = L21_2.glovebox
              L22_2 = L17_2.slot
              L21_2 = L21_2[L22_2]
              if L21_2 then
                L21_2 = GloveBoxInventory
                L21_2 = L21_2[L19_2]
                L21_2 = L21_2.glovebox
                L22_2 = L17_2.slot
                L21_2[L22_2] = nil
                L21_2 = UpdateVehicleGlovebox
                L22_2 = L19_2
                L26_2 = GloveBoxInventory
                L26_2 = L26_2[L19_2]
                L26_2 = L26_2.glovebox
                L21_2(L22_2, L26_2)
                L21_2 = print
                L22_2 = "^2 DELETE DUPLICATED ITEM FROM GLOVEBOX INVENTORY ^0"
                L21_2(L22_2)
            end
          end
          elseif "Stash" == L20_2 then
            L21_2 = ExecuteSql
            L22_2 = "SELECT inventory FROM `codem_new_stash` WHERE stashname = @stashname"
            L26_2 = {}
            L26_2["@stashname"] = L19_2
            L21_2 = L21_2(L22_2, L23_2)
            L22_2 = nil
            L26_2 = #L21_2
            if L26_2 > 0 then
              L26_2 = json
              L26_2 = L26_2.decode
              L24_2 = L21_2[1]
              L24_2 = L24_2.inventory
              if not L24_2 then
                L24_2 = "{}"
              end
              L26_2 = L26_2(L24_2)
              L22_2 = L23_2
            else
              L26_2 = {}
              L22_2 = L23_2
            end
            L26_2 = tostring
            L24_2 = L17_2.slot
            L26_2 = L26_2(L24_2)
            L26_2 = L22_2[L26_2]
            if L26_2 then
              L26_2 = tostring
              L24_2 = L17_2.slot
              L26_2 = L26_2(L24_2)
              L22_2[L26_2] = nil
              L26_2 = ExecuteSql
              L24_2 = "UPDATE codem_new_stash SET inventory = @inventory WHERE stashname = @stashname"
              l18_2 = {}
              l18_2["@stashname"] = L19_2
              L26_2 = json
              L26_2 = L26_2.encode
              L27_2 = L22_2
              L26_2 = L26_2(L27_2)
              l18_2["@inventory"] = L26_2
              L26_2(L24_2, l18_2)
            end
            L26_2 = print
            L24_2 = "^2 DELETE DUPLICATED ITEM FROM STASH INVENTORY ^0"
            L26_2(L24_2)
          elseif "Player" == L20_2 then
            L21_2 = ExecuteSql
            L22_2 = "SELECT inventory FROM `codem_new_inventory` WHERE identifier = @identifier"
            L26_2 = {}
            L26_2["@identifier"] = L19_2
            L21_2 = L21_2(L22_2, L23_2)
            L22_2 = nil
            L26_2 = #L21_2
            if L26_2 > 0 then
              L26_2 = json
              L26_2 = L26_2.decode
              L24_2 = L21_2[1]
              L24_2 = L24_2.inventory
              if not L24_2 then
                L24_2 = "{}"
              end
              L26_2 = L26_2(L24_2)
              L22_2 = L23_2
            else
              L26_2 = {}
              L22_2 = L23_2
            end
            L26_2 = tostring
            L24_2 = L17_2.slot
            L26_2 = L26_2(L24_2)
            L26_2 = L22_2[L26_2]
            if L26_2 then
              L26_2 = tostring
              L24_2 = L17_2.slot
              L26_2 = L26_2(L24_2)
              L22_2[L26_2] = nil
              L26_2 = ExecuteSql
              L24_2 = "UPDATE codem_new_inventory SET inventory = @inventory WHERE identifier = @identifier"
              l18_2 = {}
              l18_2["@identifier"] = L19_2
              L26_2 = json
              L26_2 = L26_2.encode
              L27_2 = L22_2
              L26_2 = L26_2(L27_2)
              l18_2["@inventory"] = L26_2
              L26_2(L24_2, l18_2)
            end
            L26_2 = print
            L24_2 = "^2 DELETE DUPLICATED ITEM FROM PLAYER INVENTORY ^0"
            L26_2(L24_2)
            goto lbl_309
            goto lbl_337
            ::lbl_309::
            L21_2 = L11_2.name
            L22_2 = L17_2.serial
            if not L22_2 then
              L22_2 = "unkown"
            end
            L26_2 = L17_2.slot
            L24_2 = table
            L24_2 = L24_2.insert
            l5_2 = L5_2
            L26_2 = {}
            L27_2 = string
            L27_2 = L27_2.format
            L28_2 = "**%s** (in %s)"
            l21_2 = L21_2
            l20_2 = L20_2
            L27_2 = L27_2(L28_2, L29_2, L30_2)
            L26_2.name = L27_2
            L27_2 = string
            L27_2 = L27_2.format
            L28_2 = [[
Serial: `%s`
 Name: `%s`
Slot: `%s`]]
            l22_2 = L22_2
            l19_2 = L19_2
            l23_2 = L26_2
            L27_2 = L27_2(L28_2, L29_2, L30_2, L31_2)
            L26_2.value = L27_2
            L26_2.inline = true
            L24_2(l5_2, L26_2)
          end
        end
        ::lbl_337::
      end
    end
  end
  function L8_2(A0_3, A1_3)
local L2_3, L3_3, L4_3, L5_3, L6_3, l7_3, L8_3, L9_3, L10_3, L11_3, L12_3, l7_3, a0_3
    L2_3 = {}
    L3_3 = 1
    L4_3 = #A0_3
    L5_3 = A1_3
    for L6_3 = L3_3, L4_3, L5_3 do
      l2_3 = {}
      L8_3 = L6_3
      L9_3 = math
      L9_3 = L9_3.min
      L10_3 = L6_3 + A1_3
      L10_3 = L10_3 - 1
      L11_3 = #A0_3
      L9_3 = L9_3(L10_3, L11_3)
      L10_3 = 1
      for L11_3 = L8_3, L9_3, L10_3 do
        L12_3 = table
        L12_3 = L12_3.insert
        l7_3 = l7_3
        a0_3 = A0_3[L11_3]
        L12_3(l7_3, a0_3)
      end
      L8_3 = table
      L8_3 = L8_3.insert
      L9_3 = L2_3
      L10_3 = L7_3
      L8_3(L9_3, L10_3)
    end
    return L2_3
  end
  function L7_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, l7_3, L8_3
    L1_3 = PerformHttpRequest
    L2_3 = L1_2
    function L3_3(A0_4, A1_4, A2_4)
    end
    L4_3 = "POST"
    L5_3 = json
    L5_3 = L5_3.encode
    L6_3 = {}
    L6_3.username = "Inventory Cleaner"
    l2_3 = {}
    L8_3 = {}
    L8_3.title = "Deleted Duplicate Items"
    L8_3.description = "The following duplicate items have been deleted from vehicle inventories:"
    L8_3.color = 16711680
    L8_3.fields = A0_3
    l2_3[1] = L8_3
    L6_3.embeds = l2_3
    L5_3 = L5_3(L6_3)
    L6_3 = {}
    L6_3["Content-Type"] = "application/json"
    L1_3(L2_3, L3_3, L4_3, L5_3, L6_3)
  end
  L8_2 = L6_2
  L9_2 = L5_2
  L10_2 = 10
  L8_2 = L8_2(L9_2, L10_2)
  L9_2 = #L5_2
  if L9_2 > 0 then
    L9_2 = ipairs
    L10_2 = L8_2
    L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
    for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
      L15_2 = L7_2
      L16_2 = L14_2
      L15_2(L16_2)
    end
  end
end
DuplicateServerItems = L2_1
L2_1 = Citizen
L2_1 = L2_1.CreateThread
function fn_L3_1()
local L0_2, L1_2
  L0_2 = Citizen
  L0_2 = L0_2.Wait
  L1_2 = 15000
  L0_2(L1_2)
  L0_2 = DuplicateServerItems
  L0_2()
end
L2_1(fn_L3_1)
