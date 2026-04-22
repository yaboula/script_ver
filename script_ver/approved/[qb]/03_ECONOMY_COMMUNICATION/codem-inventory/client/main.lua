local ClientInventory, fn_L1_1, fn_L2_1
Core = nil
nuiLoaded = false
L0_1 = {}
ClientInventory = ClientInventory
ClientInventory = {}
ClientGround = ClientInventory
ClientInventory = {}
VehicleInventory = ClientInventory
ClientInventory = {}
VehicleGlovebox = ClientInventory
OpenInventory = false
currentDrop = nil
currentVehiclePlate = nil
givecount = nil
curvehicle = nil
InGlovebox = nil
openTrunkVehicle = false
robstatus = false
PedScreen = true
ClientInventory = {}
ClothingInventory = ClientInventory
ClientInventory = {}
HotbarItems = ClientInventory
AccessInv = false
ClientInventory = RegisterNUICallback
L1_1 = "onlinecheck"
function fn_L2_1()
local L0_2, ClientInventory
  AccessInv = true
end
ClientInventory(L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
L1_1 = "offlinecheck"
function fn_L2_1()
local L0_2, ClientInventory, L2_2
  L0_2 = SetNuiFocus
  ClientInventory = false
  L2_2 = false
  L0_2(ClientInventory, L2_2)
  L0_2 = TriggerEvent
  ClientInventory = "codem-inventory:client:closeInventory"
  L0_2(ClientInventory)
  AccessInv = false
end
ClientInventory(L1_1, fn_L2_1)
function ClientInventory(A0_2, A1_2)
local L2_2, L3_2
  while true do
    L2_2 = nuiLoaded
    if L2_2 then
      break
    end
    L2_2 = Wait
    L3_2 = 0
    L2_2(L3_2)
  end
  L2_2 = SendNUIMessage
  L3_2 = {}
  L3_2.action = A0_2
  L3_2.payload = A1_2
  L2_2(L3_2)
end
NuiMessage = ClientInventory
ClientInventory = RegisterNUICallback
L1_1 = "LoadedNUI"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2
  nuiLoaded = true
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(L1_1, fn_L2_1)
ClientInventory = CreateThread
function fn_L1_1()
local L0_2, ClientInventory
  while true do
    L0_2 = Core
    if nil ~= L0_2 then
      break
    end
    L0_2 = Wait
    ClientInventory = 0
    L0_2(ClientInventory)
  end
  while true do
    L0_2 = nuiLoaded
    if L0_2 then
      break
    end
    L0_2 = NetworkIsSessionStarted
    L0_2 = L0_2()
    if L0_2 then
      L0_2 = SendNUIMessage
      ClientInventory = {}
      ClientInventory.action = "CHECK_NUI"
      L0_2(ClientInventory)
    end
    L0_2 = Wait
    ClientInventory = 2000
    L0_2(ClientInventory)
  end
end
ClientInventory(fn_L1_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "DisablePedScreen"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2
  PedScreen = false
  L2_2 = Remove2d
  L2_2()
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "EnablePedScreen"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2
  PedScreen = true
  L2_2 = OpenInventory
  if L2_2 then
    L2_2 = CreatePedScreen
    L3_2 = true
    L2_2(L3_2)
  end
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:loadclothingdata"
function fn_L2_1(A0_2)
local ClientInventory
  ClothingInventory = A0_2
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:setkey"
function fn_L2_1(A0_2)
local ClientInventory
  givecount = A0_2
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:loadClientInventory"
function fn_L2_1(A0_2)
local ClientInventory
  ClientInventory = A0_2 or nil
  if not A0_2 then
    ClientInventory = {}
  end
  ClientInventory = ClientInventory
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:clearinventory"
function fn_L2_1()
local L0_2, ClientInventory, L2_2, L3_2, L4_2, L5_2, l6_2, L7_2, l6_2
  L0_2 = {}
  ClientInventory = pairs
  L2_2 = ClientInventory
  ClientInventory, L2_2, L3_2, L4_2 = ClientInventory(L2_2)
  for L5_2, L6_2 in ClientInventory, L2_2, L3_2, L4_2 do
    L7_2 = Config
    L7_2 = L7_2.NotDeleteItemWhenPlayerDie
    l6_2 = l6_2.name
    L7_2 = L7_2[L8_2]
    if L7_2 then
      L0_2[L5_2] = l6_2
    end
  end
  ClientInventory = L0_2
  ClientInventory = TriggerEvent
  L2_2 = "codem-inventory:client:RemoveWeaponObject"
  ClientInventory(L2_2)
  ClientInventory = NuiMessage
  L2_2 = "UPDATE_INVENTORY"
  L3_2 = ClientInventory
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = CreateThread
function fn_L1_1()
local L0_2, ClientInventory, L2_2, L3_2
  while true do
    L0_2 = Core
    if nil ~= L0_2 then
      break
    end
    L0_2 = nuiLoaded
    if L0_2 then
      break
    end
    L0_2 = Wait
    ClientInventory = 0
    L0_2(ClientInventory)
  end
  L0_2 = NuiMessage
  ClientInventory = "CONFIG_SETTINGS"
  L2_2 = {}
  L3_2 = Config
  L3_2 = L3_2.MaxWeight
  L2_2.playerweight = L3_2
  L3_2 = Config
  L3_2 = L3_2.MaxSlots
  L2_2.maxslot = L3_2
  L3_2 = Config
  L3_2 = L3_2.GroundSlots
  L2_2.groundslot = L3_2
  L3_2 = Config
  L3_2 = L3_2.ItemClothingSystem
  L2_2.configclothing = L3_2
  L3_2 = Config
  L3_2 = L3_2.CashItem
  L2_2.cashitem = L3_2
  L3_2 = Config
  L3_2 = L3_2.ServerLogo
  L2_2.serverlogo = L3_2
  L3_2 = Config
  L3_2 = L3_2.ContextMenuData
  L2_2.context = L3_2
  L3_2 = Config
  L3_2 = L3_2.AdjustmentsData
  L2_2.adjust = L3_2
  L3_2 = Config
  L3_2 = L3_2.Category
  L2_2.category = L3_2
  L3_2 = Config
  L3_2 = L3_2.CraftSystem
  L2_2.configcraft = L3_2
  L3_2 = Config
  L3_2 = L3_2.CraftItems
  L2_2.configcraftitem = L3_2
  L0_2(ClientInventory, L2_2)
  L0_2 = NuiMessage
  ClientInventory = "SET_LOCALES"
  L2_2 = Locales
  L3_2 = Config
  L3_2 = L3_2.Language
  L2_2 = L2_2[L3_2]
  L2_2 = L2_2.frontend
  L0_2(ClientInventory, L2_2)
end
ClientInventory(fn_L1_1)
function ClientInventory(A0_2)
local ClientInventory, L2_2, L3_2, L4_2
  ClientInventory = {}
  L2_2 = ClientInventory
  L2_2 = L2_2["1"]
  if not L2_2 then
    L2_2 = {}
  end
  ClientInventory[1] = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2["2"]
  if not L2_2 then
    L2_2 = {}
  end
  ClientInventory[2] = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2["3"]
  if not L2_2 then
    L2_2 = {}
  end
  ClientInventory[3] = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2["4"]
  if not L2_2 then
    L2_2 = {}
  end
  ClientInventory[4] = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2["5"]
  if not L2_2 then
    L2_2 = {}
  end
  ClientInventory[5] = L2_2
  HotbarItems = ClientInventory
  ClientInventory = NuiMessage
  L2_2 = "TOGGLE_HOTBAR"
  L3_2 = {}
  L3_2.open = A0_2
  L4_2 = HotbarItems
  L3_2.items = L4_2
  ClientInventory(L2_2, L3_2)
end
ToggleHotbar = ClientInventory
ClientInventory = RegisterNUICallback
fn_L1_1 = "SortItem"
function fn_L2_1(A0_2, A1_2)
local L0_2
  L0_2 = TriggerServerEvent
  L0_2("codem-inventory:server:sortItems")
  if A1_2 then A1_2("ok") end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "SortItemStash"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:sortItemsStash"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:sortItems"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  if A0_2 then
    ClientInventory = A0_2
    ClientInventory = OpenInventory
    if ClientInventory then
      ClientInventory = NuiMessage
      L2_2 = "UPDATE_INVENTORY"
      L3_2 = ClientInventory
      ClientInventory(L2_2, L3_2)
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:loadAllGround"
function fn_L2_1(A0_2)
local ClientInventory
  ClientGround = A0_2
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:loadAllVehicleInventory"
function fn_L2_1(A0_2)
local ClientInventory
  VehicleInventory = A0_2
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:loadAllVehicleGlovebox"
function fn_L2_1(A0_2)
local ClientInventory
  VehicleGlovebox = A0_2
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapClothingToMainInventory"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2, L4_2, L5_2
  if A0_2 then
    ClientInventory = GetEntityModel
    L2_2 = PlayerPedId
    L2_2, L3_2, L4_2, L5_2 = L2_2()
    ClientInventory = ClientInventory(L2_2, L3_2, L4_2, L5_2)
    if 1885233650 == ClientInventory then
      L2_2 = TriggerServerEvent
      L3_2 = "codem-inventory:server:swaprClothingToMainInventory"
      L4_2 = A0_2
      L5_2 = "man"
      L2_2(L3_2, L4_2, L5_2)
    else
      L2_2 = TriggerServerEvent
      L3_2 = "codem-inventory:server:swaprClothingToMainInventory"
      L4_2 = A0_2
      L5_2 = "woman"
      L2_2(L3_2, L4_2, L5_2)
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainInventoryToClothingInventory"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  if A0_2 then
    ClientInventory = TriggerServerEvent
    L2_2 = "codem-inventory:server:swapInventoryToClothing"
    L3_2 = A0_2
    ClientInventory(L2_2, L3_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "SwapMainInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:checkPlayerItemForSwap"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "SwapMainInventoryTargetItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:checkPlayerItemForSwapTargetItem"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainInventoryToGround"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:SwapInventoryToGround"
  L4_2 = A0_2
  L5_2 = currentDrop
  L2_2(L3_2, L4_2, L5_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainInventoryToStash"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:SwapInventoryToStash"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainStashToStash"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:swapStashToStash"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapStashToMainInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:swapStashToInventory"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainInventoryToVehicleTrunk"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:SwapInventoryToVehicleTrunk"
  L4_2 = A0_2
  L5_2 = givecount
  L2_2(L3_2, L4_2, L5_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainInventoryToVehicleGlovebox"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:SwapInventoryToVehicleGlovebox"
  L4_2 = A0_2
  L5_2 = givecount
  L2_2(L3_2, L4_2, L5_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapVehicleTrunkToMainInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:swapVehicleTrunkToInventory"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapVehicleGloveboxToMainInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:swapVehicleGloveboxToInventory"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapShopToMainInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:swapShopToInventory"
  L4_2 = A0_2
  L5_2 = jobData
  L2_2(L3_2, L4_2, L5_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainInventoryToBackpack"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:SwapInventoryToBackPack"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "SplitItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:splitItem"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapRobPlayerToMainInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:swaprobplayertomaininventory"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapMainInventoryToRobPlayer"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:swapmaininventorytorobplayer"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:refreshrobplayerinventory"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  ClientInventory = NuiMessage
  L2_2 = "UPDATE_ROB_PLAYER_INVENTORY"
  L3_2 = A0_2
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "ChangePlayerRobStatus"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:ChangePlayerRobStatus"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:updateClothingInventory"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  ClothingInventory = A0_2
  ClientInventory = NuiMessage
  L2_2 = "UPDATE_CLOTHING_INVENTORY"
  L3_2 = A0_2
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:loadClothingInventory"
function fn_L2_1()
local L0_2, ClientInventory, L2_2
  L0_2 = NuiMessage
  ClientInventory = "UPDATE_CLOTHING_INVENTORY"
  L2_2 = ClothingInventory
  L0_2(ClientInventory, L2_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "TakeOffClothes"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, l6_2
  L2_2 = GetEntityModel
  L3_2 = PlayerPedId
  L3_2, L4_2, L5_2, l6_2 = L3_2()
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2)
  if 1885233650 == L2_2 then
    L3_2 = TriggerServerEvent
    L4_2 = "codem-inventory:server:TakeOffClothes"
    L5_2 = A0_2
    l6_2 = "man"
    L3_2(L4_2, L5_2, l6_2)
  else
    L3_2 = TriggerServerEvent
    L4_2 = "codem-inventory:server:TakeOffClothes"
    L5_2 = A0_2
    l6_2 = "woman"
    L3_2(L4_2, L5_2, l6_2)
  end
  L3_2 = A1_2
  L4_2 = "ok"
  L3_2(L4_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "SplitItemStash"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:splitItemStash"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "SplitItemGloveBox"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:splitItemGloveBox"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "SplitItemTrunk"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:splitItemTrunk"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:refreshiteminfo"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = ClientInventory
    L2_2 = L2_2[A0_2]
    L2_2.info = A1_2
    L2_2 = OpenInventory
    if L2_2 then
      L2_2 = NuiMessage
      L3_2 = "UPDATE_INVENTORY"
      L4_2 = ClientInventory
      L2_2(L3_2, L4_2)
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:splitItemGloveboxClient"
function fn_L2_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, l6_2, L7_2
  L5_2 = tostring
  L8_2 = A1_2
  L5_2 = L5_2(L6_2)
  A1_2 = L5_2
  L5_2 = tostring
  L8_2 = A3_2
  L5_2 = L5_2(L6_2)
  A3_2 = L5_2
  L5_2 = VehicleGlovebox
  L5_2 = L5_2[A0_2]
  if L5_2 then
    L5_2 = VehicleGlovebox
    L5_2 = L5_2[A0_2]
    L5_2 = L5_2.glovebox
    L5_2 = L5_2[A1_2]
    L8_2 = tonumber
    L7_2 = A2_2
    L8_2 = L8_2(L7_2)
    L5_2.amount = l6_2
    L5_2 = VehicleGlovebox
    L5_2 = L5_2[A0_2]
    L5_2 = L5_2.glovebox
    L5_2[A3_2] = A4_2
    L5_2 = VehicleGlovebox
    L5_2 = L5_2[A0_2]
    L5_2 = L5_2.glovebox
    L5_2 = L5_2[A3_2]
    L5_2.slot = A3_2
    L5_2 = InGlovebox
    if L5_2 == A0_2 then
      L5_2 = OpenInventory
      if L5_2 then
        L5_2 = NuiMessage
        l6_2 = "UPDATE_GLOVEBOX_INVENTORY"
        L7_2 = VehicleGlovebox
        L7_2 = L7_2[A0_2]
        L5_2(l6_2, L7_2)
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:splitItemTrunkClient"
function fn_L2_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, l6_2, L7_2
  L5_2 = tostring
  L8_2 = A1_2
  L5_2 = L5_2(L6_2)
  A1_2 = L5_2
  L5_2 = tostring
  L8_2 = A3_2
  L5_2 = L5_2(L6_2)
  A3_2 = L5_2
  L5_2 = VehicleInventory
  L5_2 = L5_2[A0_2]
  if L5_2 then
    L5_2 = VehicleInventory
    L5_2 = L5_2[A0_2]
    L5_2 = L5_2.trunk
    L5_2 = L5_2[A1_2]
    L8_2 = tonumber
    L7_2 = A2_2
    L8_2 = L8_2(L7_2)
    L5_2.amount = l6_2
    L5_2 = VehicleInventory
    L5_2 = L5_2[A0_2]
    L5_2 = L5_2.trunk
    L5_2[A3_2] = A4_2
    L5_2 = VehicleInventory
    L5_2 = L5_2[A0_2]
    L5_2 = L5_2.trunk
    L5_2 = L5_2[A3_2]
    L5_2.slot = A3_2
    L5_2 = currentVehiclePlate
    if L5_2 == A0_2 then
      L5_2 = OpenInventory
      if L5_2 then
        L5_2 = NuiMessage
        l6_2 = "UPDATE_VEHICLE_INVENTORY"
        L7_2 = VehicleInventory
        L7_2 = L7_2[A0_2]
        L5_2(l6_2, L7_2)
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:setitemamount"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = tonumber
  L3_2 = A1_2
  L2_2 = L2_2(L3_2)
  A1_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = ClientInventory
    L2_2 = L2_2[A0_2]
    L2_2.amount = A1_2
    L2_2 = OpenInventory
    if L2_2 then
      L2_2 = NuiMessage
      L3_2 = "UPDATE_INVENTORY"
      L4_2 = ClientInventory
      L2_2(L3_2, L4_2)
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:refreshItemsDurability"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = A1_2.name
    L3_2 = ClientInventory
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.name
    if L2_2 == L3_2 then
      L2_2 = ClientInventory
      L2_2 = L2_2[A0_2]
      L3_2 = A1_2.info
      L2_2.info = L3_2
      L2_2 = OpenInventory
      if L2_2 then
        L2_2 = NuiMessage
        L3_2 = "UPDATE_INVENTORY"
        L4_2 = ClientInventory
        L2_2(L3_2, L4_2)
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "GetClosestPlayers"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = GetClosestPlayers
  L2_2 = L2_2()
  L3_2 = TriggerCallback
  L4_2 = "codem-inventory:GetClosestPlayers"
  L5_2 = L2_2
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = A1_2
  L5_2 = L3_2
  L4_2(L5_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:splitItem"
function fn_L2_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, l6_2
  L4_2 = tostring
  L5_2 = A0_2
  L4_2 = L4_2(L5_2)
  A0_2 = L4_2
  L4_2 = tostring
  L5_2 = A2_2
  L4_2 = L4_2(L5_2)
  A2_2 = L4_2
  L4_2 = ClientInventory
  L4_2 = L4_2[A2_2]
  if L4_2 then
    L4_2 = ClientInventory
    L4_2[A0_2] = A1_2
    L4_2 = ClientInventory
    L4_2[A2_2] = A3_2
    L4_2 = NuiMessage
    L5_2 = "UPDATE_INVENTORY"
    L8_2 = ClientInventory
    L4_2(L5_2, l6_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "GiveItemToPlayer"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:giveItemToPlayerNearby"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:setitemmetadata"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = ClientInventory
    L2_2 = L2_2[A0_2]
    L2_2 = L2_2.info
    if L2_2 then
      L2_2 = ClientInventory
      L2_2 = L2_2[A0_2]
      L2_2.info = A1_2
      L2_2 = OpenInventory
      if L2_2 then
        L2_2 = NuiMessage
        L3_2 = "UPDATE_INVENTORY"
        L4_2 = ClientInventory
        L2_2(L3_2, L4_2)
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:openVehicleTrunk"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  ClientInventory = NuiMessage
  L2_2 = "LOAD_VEHICLE_INVENTORY"
  L3_2 = A0_2
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:openVehicleGlovebox"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  ClientInventory = NuiMessage
  L2_2 = "LOAD_VEHICLE_GLOVEBOX"
  L3_2 = A0_2
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNuiCallback
fn_L1_1 = "swapGroundToMainInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = currentDrop
  if not L2_2 then
    return
  end
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:SwapGroundToInventory"
  L4_2 = A0_2
  L5_2 = currentDrop
  L2_2(L3_2, L4_2, L5_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "removeAttachment"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "weapons:server:RemoveAttachment"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "swapBackpackToIventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:SwapBackPackToInventory"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:removeitemtoclientInventory"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, l6_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = ClientInventory
    L2_2 = L2_2[A0_2]
    L3_2 = tonumber
    L4_2 = ClientInventory
    L4_2 = L4_2[A0_2]
    L4_2 = L4_2.amount
    L3_2 = L3_2(L4_2)
    L2_2.amount = L3_2
    L2_2 = tonumber
    L3_2 = A1_2
    L2_2 = L2_2(L3_2)
    A1_2 = L2_2
    L2_2 = ClientInventory
    L2_2 = L2_2[A0_2]
    L2_2 = L2_2.amount
    if A1_2 >= L2_2 then
      L2_2 = currentWeapon
      L3_2 = ClientInventory
      L3_2 = L3_2[A0_2]
      L3_2 = L3_2.name
      if L2_2 == L3_2 then
        L2_2 = TriggerEvent
        L3_2 = "codem-inventory:client:RemoveWeaponObject"
        L2_2(L3_2)
        currentWeapon = nil
      end
      L2_2 = ClientInventory
      L2_2 = L2_2[A0_2]
      L2_2 = L2_2.type
      if "bag" == L2_2 then
        L2_2 = NuiMessage
        L3_2 = "REMOVE_BACKPACK"
        L2_2(L3_2)
      end
      L2_2 = ClientInventory
      L2_2 = L2_2[A0_2]
      L2_2 = L2_2.name
      if "cash" ~= L2_2 then
        L2_2 = NuiMessage
        L3_2 = "SHOW_BOTTOM_MENU"
        L4_2 = {}
        L4_2.value = "itemremoved"
        L5_2 = ClientInventory
        L5_2 = L5_2[A0_2]
        L5_2 = L5_2.image
        L4_2.image = L5_2
        L4_2.amount = A1_2
        L5_2 = Locales
        L8_2 = Config
        L8_2 = L8_2.Language
        L5_2 = L5_2[L6_2]
        L5_2 = L5_2.notification
        L5_2 = L5_2.ITEMREMOVED
        L4_2.text = L5_2
        L2_2(L3_2, L4_2)
      end
      L2_2 = ClientInventory
      L2_2[A0_2] = nil
    else
      L2_2 = ClientInventory
      L2_2 = L2_2[A0_2]
      L3_2 = tonumber
      L4_2 = ClientInventory
      L4_2 = L4_2[A0_2]
      L4_2 = L4_2.amount
      L3_2 = L3_2(L4_2)
      L2_2.amount = L3_2
      L2_2 = tonumber
      L3_2 = A1_2
      L2_2 = L2_2(L3_2)
      A1_2 = L2_2
      L2_2 = ClientInventory
      L2_2 = L2_2[A0_2]
      L3_2 = ClientInventory
      L3_2 = L3_2[A0_2]
      L3_2 = L3_2.amount
      L3_2 = L3_2 - A1_2
      L2_2.amount = L3_2
      L2_2 = ClientInventory
      L2_2 = L2_2[A0_2]
      L2_2 = L2_2.name
      if "cash" ~= L2_2 then
        L2_2 = NuiMessage
        L3_2 = "SHOW_BOTTOM_MENU"
        L4_2 = {}
        L4_2.value = "itemremoved"
        L5_2 = ClientInventory
        L5_2 = L5_2[A0_2]
        L5_2 = L5_2.image
        L4_2.image = L5_2
        L4_2.amount = A1_2
        L5_2 = Locales
        L8_2 = Config
        L8_2 = L8_2.Language
        L5_2 = L5_2[L6_2]
        L5_2 = L5_2.notification
        L5_2 = L5_2.ITEMREMOVED
        L4_2.text = L5_2
        L2_2(L3_2, L4_2)
      end
    end
    L2_2 = NuiMessage
    L3_2 = "UPDATE_INVENTORY"
    L4_2 = ClientInventory
    L2_2(L3_2, L4_2)
  else
    L2_2 = TriggerEvent
    L3_2 = "codem-inventory:client:notification"
    L4_2 = Locales
    L5_2 = Config
    L5_2 = L5_2.Language
    L4_2 = L4_2[L5_2]
    L4_2 = L4_2.notification
    L4_2 = L4_2.ITEMNOTFOUND
    L2_2(L3_2, L4_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:setitembyslot"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = ClientInventory
    L2_2[A0_2] = A1_2
    L2_2 = ClientWeaponData
    L2_2 = L2_2.slot
    if L2_2 == A0_2 then
      ClientWeaponData = A1_2
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:ChangeSwapItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = tostring
  L3_2 = A1_2
  L2_2 = L2_2(L3_2)
  A1_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  if L2_2 then
    L2_2 = ClientWeaponData
    if L2_2 then
      L2_2 = ClientWeaponData
      L2_2 = L2_2.name
      L3_2 = ClientInventory
      L3_2 = L3_2[A0_2]
      L3_2 = L3_2.name
      if L2_2 == L3_2 then
        L2_2 = TriggerEvent
        L3_2 = "codem-inventory:client:RemoveWeaponObject"
        L2_2(L3_2)
        ClientWeaponData = nil
        currentWeapon = nil
      end
    end
    L2_2 = ClientInventory
    L3_2 = ClientInventory
    L3_2 = L3_2[A0_2]
    L2_2[A1_2] = L3_2
    L2_2 = ClientInventory
    L2_2 = L2_2[A1_2]
    L2_2.slot = A1_2
    L2_2 = ClientInventory
    L2_2[A0_2] = nil
    L2_2 = NuiMessage
    L3_2 = "UPDATE_INVENTORY"
    L4_2 = ClientInventory
    L2_2(L3_2, L4_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:ChangeSwapItemTargetItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, l6_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = tostring
  L3_2 = A1_2
  L2_2 = L2_2(L3_2)
  A1_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  L3_2 = ClientInventory
  L3_2 = L3_2[A1_2]
  if L2_2 and L3_2 then
    L4_2 = ClientWeaponData
    if L4_2 then
      L4_2 = ClientWeaponData
      L4_2 = L4_2.name
      L5_2 = ClientInventory
      L5_2 = L5_2[A0_2]
      L5_2 = L5_2.name
      if L4_2 == L5_2 then
        L4_2 = TriggerEvent
        L5_2 = "codem-inventory:client:RemoveWeaponObject"
        L4_2(L5_2)
        ClientWeaponData = nil
        currentWeapon = nil
      end
    end
    L4_2 = ClientWeaponData
    if L4_2 then
      L4_2 = ClientWeaponData
      L4_2 = L4_2.name
      L5_2 = ClientInventory
      L5_2 = L5_2[A1_2]
      L5_2 = L5_2.name
      if L4_2 == L5_2 then
        L4_2 = TriggerEvent
        L5_2 = "codem-inventory:client:RemoveWeaponObject"
        L4_2(L5_2)
        ClientWeaponData = nil
        currentWeapon = nil
      end
    end
    L4_2 = ClientInventory
    L4_2[A0_2] = L3_2
    L4_2 = ClientInventory
    L4_2 = L4_2[A0_2]
    L4_2.slot = A0_2
    L4_2 = ClientInventory
    L4_2[A1_2] = L2_2
    L4_2 = ClientInventory
    L4_2 = L4_2[A1_2]
    L4_2.slot = A1_2
    L4_2 = NuiMessage
    L5_2 = "UPDATE_INVENTORY"
    L8_2 = ClientInventory
    L4_2(L5_2, l6_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:ChangeSwapItemSimilarItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, l6_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = tostring
  L3_2 = A1_2
  L2_2 = L2_2(L3_2)
  A1_2 = L2_2
  L2_2 = ClientInventory
  L2_2 = L2_2[A0_2]
  L3_2 = ClientInventory
  L3_2 = L3_2[A1_2]
  if L2_2 and L3_2 then
    L4_2 = ClientInventory
    L4_2 = L4_2[A1_2]
    L5_2 = ClientInventory
    L5_2 = L5_2[A1_2]
    L5_2 = L5_2.amount
    L8_2 = L2_2.amount
    L5_2 = L5_2 + L6_2
    L4_2.amount = L5_2
    L4_2 = ClientInventory
    L4_2[A0_2] = nil
    L4_2 = NuiMessage
    L5_2 = "UPDATE_INVENTORY"
    L8_2 = ClientInventory
    L4_2(L5_2, l6_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:newVehiclePlateInsert"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = VehicleInventory
  L3_2 = L3_2[A0_2]
  if not L3_2 then
    L3_2 = VehicleInventory
    L4_2 = {}
    L5_2 = {}
    L4_2.glovebox = L5_2
    L4_2.plate = A0_2
    L5_2 = {}
    L4_2.trunk = L5_2
    L4_2.maxweight = A1_2
    L4_2.slot = A2_2
    L3_2[A0_2] = L4_2
  else
    L3_2 = VehicleInventory
    L4_2 = {}
    L5_2 = {}
    L4_2.glovebox = L5_2
    L4_2.plate = A0_2
    L5_2 = {}
    L4_2.trunk = L5_2
    L4_2.maxweight = A1_2
    L4_2.slot = A2_2
    L3_2[A0_2] = L4_2
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:newVehicleGloveboxPlateInsert"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = VehicleGlovebox
  L3_2 = L3_2[A0_2]
  if not L3_2 then
    L3_2 = VehicleGlovebox
    L4_2 = {}
    L5_2 = {}
    L4_2.glovebox = L5_2
    L4_2.plate = A0_2
    L5_2 = {}
    L4_2.trunk = L5_2
    L4_2.maxweight = A1_2
    L4_2.slot = A2_2
    L3_2[A0_2] = L4_2
  else
    L3_2 = VehicleGlovebox
    L4_2 = {}
    L5_2 = {}
    L4_2.glovebox = L5_2
    L4_2.plate = A0_2
    L5_2 = {}
    L4_2.trunk = L5_2
    L4_2.maxweight = A1_2
    L4_2.slot = A2_2
    L3_2[A0_2] = L4_2
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:updateVehiclePlate"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = tostring
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  A1_2 = L3_2
  L3_2 = VehicleGlovebox
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = VehicleGlovebox
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.glovebox
    L3_2[A1_2] = A2_2
    L3_2 = InGlovebox
    if L3_2 == A0_2 then
      L3_2 = OpenInventory
      if L3_2 then
        L3_2 = NuiMessage
        L4_2 = "UPDATE_GLOVEBOX_INVENTORY"
        L5_2 = VehicleGlovebox
        L5_2 = L5_2[A0_2]
        L3_2(L4_2, L5_2)
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:updateVehicleTrunkItem"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = tostring
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  A1_2 = L3_2
  L3_2 = VehicleInventory
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = VehicleInventory
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.trunk
    L3_2[A1_2] = A2_2
    L3_2 = currentVehiclePlate
    if L3_2 == A0_2 then
      L3_2 = OpenInventory
      if L3_2 then
        L3_2 = NuiMessage
        L4_2 = "UPDATE_VEHICLE_INVENTORY"
        L5_2 = VehicleInventory
        L5_2 = L5_2[A0_2]
        L3_2(L4_2, L5_2)
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:updateVehicleGloveBoxItem"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = tostring
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  A1_2 = L3_2
  L3_2 = VehicleGlovebox
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = VehicleGlovebox
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.glovebox
    L3_2[A1_2] = A2_2
    L3_2 = customToLower2
    L4_2 = InGlovebox
    L3_2 = L3_2(L4_2)
    InGlovebox = L3_2
    L3_2 = InGlovebox
    if L3_2 == A0_2 then
      L3_2 = OpenInventory
      if L3_2 then
        L3_2 = NuiMessage
        L4_2 = "UPDATE_GLOVEBOX_INVENTORY"
        L5_2 = VehicleGlovebox
        L5_2 = L5_2[A0_2]
        L3_2(L4_2, L5_2)
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:RemoveVehicleTrunkItem"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = tostring
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  A1_2 = L3_2
  L3_2 = VehicleInventory
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = VehicleInventory
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.trunk
    L3_2 = L3_2[A1_2]
    if L3_2 then
      L3_2 = VehicleInventory
      L3_2 = L3_2[A0_2]
      L3_2 = L3_2.trunk
      L3_2[A1_2] = nil
      L3_2 = currentVehiclePlate
      if L3_2 == A0_2 then
        L3_2 = OpenInventory
        if L3_2 then
          L3_2 = NuiMessage
          L4_2 = "UPDATE_VEHICLE_INVENTORY"
          L5_2 = VehicleInventory
          L5_2 = L5_2[A0_2]
          L3_2(L4_2, L5_2)
        end
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:RemoveVehicleGloveboxItem"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = tostring
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  A1_2 = L3_2
  L3_2 = VehicleGlovebox
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = VehicleGlovebox
    L3_2 = L3_2[A0_2]
    L3_2 = L3_2.glovebox
    L3_2 = L3_2[A1_2]
    if L3_2 then
      L3_2 = VehicleGlovebox
      L3_2 = L3_2[A0_2]
      L3_2 = L3_2.glovebox
      L3_2[A1_2] = nil
      L3_2 = customToLower2
      L4_2 = InGlovebox
      L3_2 = L3_2(L4_2)
      InGlovebox = L3_2
      L3_2 = InGlovebox
      if L3_2 == A0_2 then
        L3_2 = OpenInventory
        if L3_2 then
          L3_2 = NuiMessage
          L4_2 = "UPDATE_GLOVEBOX_INVENTORY"
          L5_2 = VehicleGlovebox
          L5_2 = L5_2[A0_2]
          L3_2(L4_2, L5_2)
        end
      end
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
function ClientInventory(A0_2)
local ClientInventory, L2_2, L3_2, L4_2
  if nil == A0_2 then
    return
  end
  L2_2 = A0_2
  ClientInventory = A0_2.gsub
  L3_2 = "\196\176"
  L4_2 = "i"
  ClientInventory = ClientInventory(L2_2, L3_2, L4_2)
  A0_2 = ClientInventory
  L2_2 = A0_2
  ClientInventory = A0_2.gsub
  L3_2 = "I"
  L4_2 = "i"
  ClientInventory = ClientInventory(L2_2, L3_2, L4_2)
  A0_2 = ClientInventory
  L2_2 = A0_2
  ClientInventory = A0_2.lower
  return ClientInventory(L2_2)
end
customToLower2 = ClientInventory
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:updateitemamount"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, l6_2, L7_2
  L3_2 = tostring
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  A0_2 = L3_2
  L3_2 = ClientInventory
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = ClientInventory
    L3_2 = L3_2[A0_2]
    L3_2.amount = A1_2
    L3_2 = NuiMessage
    L4_2 = "SHOW_BOTTOM_MENU"
    L5_2 = {}
    L5_2.value = "itemadded"
    L8_2 = ClientInventory
    L8_2 = L8_2[A0_2]
    L8_2 = L8_2.image
    L5_2.image = l6_2
    L5_2.amount = A2_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMADDED
    L5_2.text = l6_2
    L3_2(L4_2, L5_2)
    L3_2 = OpenInventory
    if L3_2 then
      L3_2 = NuiMessage
      L4_2 = "UPDATE_INVENTORY"
      L5_2 = ClientInventory
      L3_2(L4_2, L5_2)
    end
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:additem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, l6_2, L7_2
  L2_2 = tostring
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  A0_2 = L2_2
  L2_2 = PlayerPedId
  L2_2 = L2_2()
  L3_2 = ClientInventory
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = ClientInventory
    L3_2[A0_2] = A1_2
    L3_2 = NuiMessage
    L4_2 = "UPDATE_INVENTORY"
    L5_2 = ClientInventory
    L3_2(L4_2, L5_2)
    L3_2 = NuiMessage
    L4_2 = "SHOW_BOTTOM_MENU"
    L5_2 = {}
    L5_2.value = "itemadded"
    L8_2 = ClientInventory
    L8_2 = L8_2[A0_2]
    L8_2 = L8_2.image
    L5_2.image = l6_2
    L8_2 = ClientInventory
    L8_2 = L8_2[A0_2]
    L8_2 = L8_2.amount
    L5_2.amount = l6_2
    L8_2 = Locales
    L7_2 = Config
    L7_2 = L7_2.Language
    L8_2 = L8_2[L7_2]
    L8_2 = L8_2.notification
    L8_2 = L8_2.ITEMADDED
    L5_2.text = l6_2
    L3_2(L4_2, L5_2)
    return
  end
  L3_2 = ClientInventory
  L3_2[A0_2] = A1_2
  L3_2 = NuiMessage
  L4_2 = "UPDATE_INVENTORY"
  L5_2 = ClientInventory
  L3_2(L4_2, L5_2)
  L3_2 = NuiMessage
  L4_2 = "SHOW_BOTTOM_MENU"
  L5_2 = {}
  L5_2.value = "itemadded"
  L8_2 = ClientInventory
  L8_2 = L8_2[A0_2]
  L8_2 = L8_2.image
  L5_2.image = l6_2
  L8_2 = ClientInventory
  L8_2 = L8_2[A0_2]
  L8_2 = L8_2.amount
  L5_2.amount = l6_2
  L8_2 = Locales
  L7_2 = Config
  L7_2 = L7_2.Language
  L8_2 = L8_2[L7_2]
  L8_2 = L8_2.notification
  L8_2 = L8_2.ITEMADDED
  L5_2.text = l6_2
  L3_2(L4_2, L5_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:openstash"
function fn_L2_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, l6_2
  L4_2 = NuiMessage
  L5_2 = "LOAD_INVENTORY"
  L8_2 = ClientInventory
  L4_2(L5_2, l6_2)
  L4_2 = SetNuiFocus
  L5_2 = true
  L8_2 = true
  L4_2(L5_2, l6_2)
  OpenInventory = true
  L4_2 = PedScreen
  if L4_2 then
    L4_2 = CreatePedScreen
    L4_2()
  end
  L4_2 = NuiMessage
  L5_2 = "OPEN_STASH"
  l6_2 = {}
  l6_2.inventory = A0_2
  l6_2.slot = A1_2
  l6_2.maxweight = A2_2
  l6_2.label = A3_2
  L4_2(L5_2, l6_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:OpenPlayerInventory"
function fn_L2_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2
  L3_2 = NuiMessage
  L4_2 = "LOAD_INVENTORY"
  L5_2 = ClientInventory
  L3_2(L4_2, L5_2)
  L3_2 = SetNuiFocus
  L4_2 = true
  L5_2 = true
  L3_2(L4_2, L5_2)
  OpenInventory = true
  L3_2 = PedScreen
  if L3_2 then
    L3_2 = CreatePedScreen
    L3_2()
  end
  L3_2 = NuiMessage
  L4_2 = "OPEN_PLAYER_INVENTORY"
  L5_2 = {}
  L5_2.inventory = A0_2
  L5_2.playerid = A1_2
  L5_2.playername = A2_2
  L3_2(L4_2, L5_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:openplayerinventory"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  ClientInventory = TriggerServerEvent
  L2_2 = "codem-inventory:server:openplayerinventory"
  L3_2 = A0_2
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "tintItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:removeTint"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = "ok"
  L2_2(L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:UpdateStashItems"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = OpenInventory
  if L2_2 then
    L2_2 = NuiMessage
    L3_2 = "UPDATE_STASH"
    L4_2 = {}
    L4_2.stashid = A0_2
    L4_2.inventory = A1_2
    L2_2(L3_2, L4_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:notification"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2, L4_2
  ClientInventory = OpenInventory
  if ClientInventory then
    ClientInventory = NuiMessage
    L2_2 = "NOTIFICATION"
    L3_2 = A0_2
    ClientInventory(L2_2, L3_2)
  else
    ClientInventory = Config
    ClientInventory = ClientInventory.Notification
    L2_2 = A0_2
    L3_2 = "error"
    L4_2 = false
    ClientInventory(L2_2, L3_2, L4_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "craftnotification"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2, L4_2
  ClientInventory = OpenInventory
  if ClientInventory then
    ClientInventory = NuiMessage
    L2_2 = "NOTIFICATION"
    L3_2 = A0_2
    ClientInventory(L2_2, L3_2)
  else
    ClientInventory = Config
    ClientInventory = ClientInventory.Notification
    L2_2 = A0_2
    L3_2 = "error"
    L4_2 = false
    ClientInventory(L2_2, L3_2, L4_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:useBackpackItem"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  ClientInventory = TriggerServerEvent
  L2_2 = "codem-inventory:openbackpack"
  L3_2 = A0_2
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:GetBackPackItem"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  ClientInventory = NuiMessage
  L2_2 = "OPEN_BACKPACK"
  L3_2 = A0_2
  ClientInventory(L2_2, L3_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNetEvent
fn_L1_1 = "codem-inventory:client:loadbackpackinventory"
function fn_L2_1(A0_2)
local ClientInventory, L2_2, L3_2
  if A0_2 then
    ClientInventory = NuiMessage
    L2_2 = "LOAD_BACKPACK"
    L3_2 = A0_2
    ClientInventory(L2_2, L3_2)
  end
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "CraftItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerCallback
  L3_2 = "codem-inventory:CraftItem"
  L4_2 = A0_2
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = A1_2
  L4_2 = L2_2
  L3_2(L4_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
ClientInventory = RegisterNUICallback
fn_L1_1 = "FinishCraftItem"
function fn_L2_1(A0_2, A1_2)
local L2_2, L3_2, L4_2
  L2_2 = TriggerServerEvent
  L3_2 = "codem-inventory:server:FinishCraftItem"
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
end
ClientInventory(fn_L1_1, fn_L2_1)
