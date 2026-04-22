local api_response, L5_2, L2_1, L5_2, L4_1, L2_2, checkLowStockThread, deleteJob, getConfigMarketLocation, fn_L9_1
version = "5.3.1"
subversion = ""
L0_1 = {}
api_response = api_response
api_response = "1.1.9"
L5_2 = false
L2_1 = 3
L5_2 = true
-- Removed external version check and authentication thread
L4_1 = Utils
if not L4_1 then
  L4_1 = exports
  L4_1 = L4_1.lc_utils
  L2_2 = L4_1
  L4_1 = L4_1.GetUtils
  L4_1 = L4_1(L5_1)
end
Utils = L4_1
L4_1 = {}
L2_2 = {}
function checkLowStockThread()
local L0_2, L3_2
  L0_2 = Citizen
  L0_2 = L0_2.CreateThreadNow
  function L3_2()
local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3
    L0_3 = Citizen
    L0_3 = L0_3.Wait
    L1_3 = 10000
    L0_3(L1_3)
    while true do
      L0_3 = Config
      L0_3 = L0_3.clear_stores
      L0_3 = L0_3.active
      if not L0_3 then
        break
      end
      L0_3 = "SELECT market_id, user_id, stock, timer FROM store_business"
      L1_3 = Utils
      L1_3 = L1_3.Database
      L1_3 = L1_3.fetchAll
      L2_3 = L0_3
      L3_3 = {}
      L1_3 = L1_3(L2_3, L3_3)
      L2_3 = pairs
      L3_3 = L1_3
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
      for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
        L8_3 = Config
        L8_3 = L8_3.market_locations
        L9_3 = L7_3.market_id
        L8_3 = L8_3[L9_3]
        if L8_3 then
          L8_3 = json
          L8_3 = L8_3.decode
          L9_3 = L7_3.stock
          L8_3 = L8_3(L9_3)
          if L8_3 then
            L9_3 = Utils
            L9_3 = L9_3.Table
            L9_3 = L9_3.tableLength
            L10_3 = L8_3
            L9_3 = L9_3(L10_3)
            L10_3 = getItemsCount
            L11_3 = L7_3.market_id
            L10_3 = L10_3(L11_3)
            L11_3 = Config
            L11_3 = L11_3.clear_stores
            L11_3 = L11_3.min_stock_variety
            L11_3 = L11_3 / 100
            L11_3 = L10_3 * L11_3
            if not (L9_3 < L11_3) then
              L11_3 = getStockAmount
              L12_3 = L7_3.stock
              L11_3 = L11_3(L12_3)
              L12_3 = getConfigMarketType
              L13_3 = L7_3.market_id
              L12_3 = L12_3(L13_3)
              L12_3 = L12_3.stock_capacity
              L13_3 = Config
              L13_3 = L13_3.clear_stores
              L13_3 = L13_3.min_stock_amount
              L13_3 = L13_3 / 100
              L12_3 = L12_3 * L13_3
              if not (L11_3 < L12_3) then
                goto lbl_121
              end
            end
            L11_3 = L7_3.timer
            L12_3 = Config
            L12_3 = L12_3.clear_stores
            L12_3 = L12_3.cooldown
            L12_3 = L12_3 * 60
            L12_3 = L12_3 * 60
            L11_3 = L11_3 + L12_3
            L12_3 = os
            L12_3 = L12_3.time
            L12_3 = L12_3()
            if L11_3 < L12_3 then
              L11_3 = deleteStore
              L12_3 = L7_3.market_id
              L11_3(L12_3)
              L11_3 = Utils
              L11_3 = L11_3.Webhook
              L11_3 = L11_3.sendWebhookMessage
              L12_3 = WebhookURL
              L13_3 = Utils
              L13_3 = L13_3.translate
              L14_3 = "logs_lost_low_stock"
              L13_3 = L13_3(L14_3)
              L14_3 = L13_3
              L13_3 = L13_3.format
              L15_3 = L7_3.market_id
              L16_3 = L7_3.stock
              L17_3 = os
              L17_3 = L17_3.date
              L18_3 = "%d/%m/%Y %H:%M:%S"
              L19_3 = L7_3.timer
              L17_3 = L17_3(L18_3, L19_3)
              L18_3 = L7_3.user_id
              L19_3 = os
              L19_3 = L19_3.date
              L20_3 = [[

[]]
              L21_3 = Utils
              L21_3 = L21_3.translate
              L22_3 = "logs_date"
              L21_3 = L21_3(L22_3)
              L22_3 = "]: %d/%m/%Y ["
              L23_3 = Utils
              L23_3 = L23_3.translate
              L24_3 = "logs_hour"
              L23_3 = L23_3(L24_3)
              L24_3 = "]: %H:%M:%S"
              L20_3 = L20_3 .. L21_3 .. L22_3 .. L23_3 .. L24_3
              L19_3 = L19_3(L20_3)
              L18_3 = L18_3 .. L19_3
              L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3 = L13_3(L14_3, L15_3, L16_3, L17_3, L18_3)
              L11_3(L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3)
              goto lbl_135
            end
            ::lbl_121::
            L11_3 = "UPDATE `store_business` SET timer = @timer WHERE market_id = @market_id"
            L12_3 = Utils
            L12_3 = L12_3.Database
            L12_3 = L12_3.execute
            L13_3 = L11_3
            L14_3 = {}
            L15_3 = os
            L15_3 = L15_3.time
            L15_3 = L15_3()
            L14_3.timer = L15_3
            L15_3 = L7_3.market_id
            L14_3["@market_id"] = L15_3
            L12_3(L13_3, L14_3)
            ::lbl_135::
            L11_3 = Citizen
            L11_3 = L11_3.Wait
            L12_3 = 100
            L11_3(L12_3)
          end
        end
      end
      L2_3 = Citizen
      L2_3 = L2_3.Wait
      L3_3 = 3600000
      L2_3(L3_3)
    end
  end
  L0_2(L3_2)
end
checkLowStockThread = checkLowStockThread
checkLowStockThread = AddEventHandler
L7_1 = "playerDropped"
function getConfigMarketLocation(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L3_2 = source
  L2_2 = L5_1
  L2_2 = L2_2[L1_2]
  if L2_2 then
    L2_2 = L5_1
    L2_2 = L2_2[L1_2]
    L2_2 = L2_2.deliveryman_job_data
    if L2_2 then
      L2_2 = "UPDATE `store_jobs` SET progress = 0 WHERE id = @id"
      L3_2 = Utils
      L3_2 = L3_2.Database
      L3_2 = L3_2.execute
      L4_2 = L2_2
      L5_2 = {}
      L6_2 = L5_1
      L6_2 = L6_2[L1_2]
      L6_2 = L6_2.deliveryman_job_data
      L6_2 = L6_2.id
      L5_2["@id"] = L6_2
      L3_2(L4_2, L5_2)
    end
  end
  L2_2 = L5_1
  L2_2[L3_2] = nil
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:getData"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:getData"
function getConfigMarketLocation(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = source
  print("[lc_stores] server: stores:getData received from", L3_2, "market_id=", A0_2)
  L2_2 = Wrapper
  L3_2 = L1_2
  L4_2 = A0_2
  L5_2 = "getData"
  L6_2 = false
  function L7_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3
    L1_3 = {}
    L2_3 = pairs
    L3_3 = getConfigMarketType
    L4_3 = A0_2
    L3_3 = L3_3(L4_3)
    L3_3 = L3_3.categories
    L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
    for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
      L8_3 = getMarketCategory
      L9_3 = L7_3
      L8_3 = L8_3(L9_3)
      L1_3[L7_3] = L8_3
    end
    L2_3 = Utils
    L2_3 = L2_3.Table
    L2_3 = L2_3.deepCopy
    L3_3 = L1_3
    L2_3 = L2_3(L3_3)
    L3_3 = "SELECT user_id FROM `store_business` WHERE market_id = @market_id"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.fetchAll
    L5_3 = L3_3
    L6_3 = {}
    L9_3 = A0_2
    L6_3["@market_id"] = L9_3
    L4_3 = L4_3(L5_3, L6_3)
    if L4_3 then
      L5_3 = L4_3[1]
      if L5_3 then
        L5_3 = L4_3[1]
        L5_3 = L5_3.user_id
        if L5_3 == A0_3 then
          L5_3 = openUI
          L6_3 = L1_2
          L9_3 = A0_2
          L8_3 = false
          L5_3(L6_3, L9_3, L8_3)
        else
          L5_3 = "SELECT role FROM `store_employees` WHERE market_id = @market_id AND user_id = @user_id"
          L6_3 = Utils
          L6_3 = L6_3.Database
          L6_3 = L6_3.fetchAll
          L9_3 = L5_3
          L8_3 = {}
          L9_3 = A0_2
          L8_3["@market_id"] = L9_3
          L8_3["@user_id"] = A0_3
          L6_3 = L6_3(L7_3, L8_3)
          if L6_3 then
            L9_3 = L6_3[1]
            if L9_3 then
              L9_3 = openUI
              L8_3 = L1_2
              L9_3 = A0_2
              L10_3 = false
              L9_3(L8_3, L9_3, L10_3)
          end
          else
            L9_3 = TriggerClientEvent
            L8_3 = "stores:Notify"
            L9_3 = L1_2
            L10_3 = "error"
            L11_3 = Utils
            L11_3 = L11_3.translate
            L12_3 = "already_has_owner"
            L11_3, L12_3 = L11_3(L12_3)
            L9_3(L8_3, L9_3, L10_3, L11_3, L12_3)
          end
        end
    end
    else
      L5_3 = "SELECT market_id FROM `store_business` WHERE user_id = @user_id"
      L6_3 = Utils
      L6_3 = L6_3.Database
      L6_3 = L6_3.fetchAll
      L9_3 = L5_3
      L8_3 = {}
      L8_3["@user_id"] = A0_3
      L6_3 = L6_3(L7_3, L8_3)
      if L6_3 then
        L9_3 = L6_3[1]
        if L9_3 then
          L9_3 = #L6_3
          L8_3 = Config
          L8_3 = L8_3.max_stores_per_player
          if L9_3 >= L8_3 then
            L9_3 = TriggerClientEvent
            L8_3 = "stores:Notify"
            L9_3 = L1_2
            L10_3 = "error"
            L11_3 = Utils
            L11_3 = L11_3.translate
            L12_3 = "already_has_business"
            L11_3, L12_3 = L11_3(L12_3)
            L9_3(L8_3, L9_3, L10_3, L11_3, L12_3)
        end
      end
      else
        L9_3 = TriggerClientEvent
        L8_3 = "stores:openRequest"
        L9_3 = L1_2
        L10_3 = getConfigMarketLocation
        L11_3 = A0_2
        L10_3 = L10_3(L11_3)
        L10_3 = L10_3.buy_price
        L11_3 = L2_3
        print("[lc_stores] server: opening buy modal for", L3_2, "market=", A0_2, "price=", L10_3)
        L9_3(L8_3, L9_3, L10_3, L11_3)
      end
    end
  end
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:buyMarket"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:buyMarket"
function getConfigMarketLocation(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = false
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3
    L1_3 = getConfigMarketLocation
    L2_3 = A0_2
    L1_3 = L1_3(L2_3)
    L1_3 = L1_3.buy_price
    L2_3 = getMarketCategory
    L3_3 = A2_2.category
    L2_3 = L2_3(L3_3)
    L2_3 = L2_3.category_buy_price
    L1_3 = L1_3 + L2_3
    L2_3 = beforeBuyMarket
    L3_3 = L3_2
    L4_3 = A0_2
    L5_3 = L1_3
    L2_3 = L2_3(L3_3, L4_3, L5_3)
    if L2_3 then
      L2_3 = TriggerClientEvent
      L3_3 = "stores:closeUI"
      L4_3 = L3_2
      L2_3(L3_3, L4_3)
      L2_3 = Utils
      L2_3 = L2_3.Framework
      L2_3 = L2_3.tryRemoveAccountMoney
      L3_3 = L3_2
      L4_3 = L1_3
      L5_3 = getAccount
      L6_3 = A0_2
      L9_3 = "store"
      L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L5_3(L6_3, L9_3)
      L2_3 = L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
      if L2_3 then
        L2_3 = "INSERT INTO `store_business` (user_id,market_id,stock,stock_prices,timer) VALUES (@user_id,@market_id,@stock,@stock_prices,@timer);"
        L3_3 = Utils
        L3_3 = L3_3.Database
        L3_3 = L3_3.execute
        L4_3 = L2_3
        L5_3 = {}
        L6_3 = A0_2
        L5_3["@market_id"] = L6_3
        L5_3["@user_id"] = A0_3
        L6_3 = json
        L6_3 = L6_3.encode
        L9_3 = {}
        L6_3 = L6_3(L7_3)
        L5_3["@stock"] = L6_3
        L6_3 = json
        L6_3 = L6_3.encode
        L9_3 = {}
        L6_3 = L6_3(L7_3)
        L5_3["@stock_prices"] = L6_3
        L6_3 = os
        L6_3 = L6_3.time
        L6_3 = L6_3()
        L5_3["@timer"] = L6_3
        L3_3(L4_3, L5_3)
        L3_3 = "INSERT INTO `store_categories` (market_id, category) VALUES (@market_id,@category);"
        L4_3 = Utils
        L4_3 = L4_3.Database
        L4_3 = L4_3.execute
        L5_3 = L3_3
        L6_3 = {}
        L9_3 = A0_2
        L6_3["@market_id"] = L9_3
        L9_3 = A2_2.category
        L6_3["@category"] = L9_3
        L4_3(L5_3, L6_3)
        L4_3 = TriggerClientEvent
        L5_3 = "stores:Notify"
        L6_3 = L3_2
        L9_3 = "success"
        L8_3 = Utils
        L8_3 = L8_3.translate
        L9_3 = "businnes_bougth"
        L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L8_3(L9_3)
        L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
        L4_3 = Utils
        L4_3 = L4_3.Webhook
        L4_3 = L4_3.sendWebhookMessage
        L5_3 = WebhookURL
        L6_3 = Utils
        L6_3 = L6_3.translate
        L9_3 = "logs_bought"
        L6_3 = L6_3(L7_3)
        L9_3 = L6_3
        L6_3 = L6_3.format
        L8_3 = A0_2
        L9_3 = Utils
        L9_3 = L9_3.Framework
        L9_3 = L9_3.getPlayerIdLog
        L10_3 = L3_2
        L9_3 = L9_3(L10_3)
        L10_3 = os
        L10_3 = L10_3.date
        L11_3 = [[

[]]
        L12_3 = Utils
        L12_3 = L12_3.translate
        L13_3 = "logs_date"
        L12_3 = L12_3(L13_3)
        L13_3 = "]: %d/%m/%Y ["
        L14_3 = Utils
        L14_3 = L14_3.translate
        L15_3 = "logs_hour"
        L14_3 = L14_3(L15_3)
        L15_3 = "]: %H:%M:%S"
        L11_3 = L11_3 .. L12_3 .. L13_3 .. L14_3 .. L15_3
        L10_3 = L10_3(L11_3)
        L9_3 = L9_3 .. L10_3
        L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L6_3(L9_3, L8_3, L9_3)
        L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
        L4_3 = afterBuyMarket
        L5_3 = L3_2
        L6_3 = A0_2
        L9_3 = L1_3
        L4_3(L5_3, L6_3, L9_3)
      else
        L2_3 = TriggerClientEvent
        L3_3 = "stores:Notify"
        L4_3 = L3_2
        L5_3 = "error"
        L6_3 = Utils
        L6_3 = L6_3.translate
        L9_3 = "insufficient_funds_store"
        L6_3 = L6_3(L7_3)
        L9_3 = L6_3
        L6_3 = L6_3.format
        L8_3 = L1_3
        L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L6_3(L9_3, L8_3)
        L2_3(L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
      end
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:openMarket"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:openMarket"
function getConfigMarketLocation(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = source
  L2_2 = Wrapper
  L3_2 = L1_2
  L4_2 = A0_2
  L5_2 = "openMarket"
  L6_2 = false
  function L7_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3
    L1_3 = getConfigMarketType
    L2_3 = A0_2
    L1_3 = L1_3(L2_3)
    L1_3 = L1_3.required_job
    if L1_3 then
      L2_3 = #L1_3
      if 0 ~= L2_3 then
        L2_3 = Utils
        L2_3 = L2_3.Framework
        L2_3 = L2_3.hasJobs
        L3_3 = L1_2
        L4_3 = L1_3
        L2_3 = L2_3(L3_3, L4_3)
        if not L2_3 then
          L2_3 = isOwner
          L3_3 = A0_2
          L4_3 = A0_3
          L2_3 = L2_3(L3_3, L4_3)
          if not L2_3 then
            goto lbl_41
          end
        end
      end
    end
    L2_3 = "UPDATE `store_business` SET total_visits = total_visits + 1 WHERE market_id = @market_id"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.execute
    L4_3 = L2_3
    L5_3 = {}
    L6_3 = A0_2
    L5_3["@market_id"] = L6_3
    L3_3(L4_3, L5_3)
    L3_3 = openUI
    L4_3 = L1_2
    L5_3 = A0_2
    L6_3 = false
    L9_3 = true
    L3_3(L4_3, L5_3, L6_3, L9_3)
    goto lbl_50
    ::lbl_41::
    L2_3 = TriggerClientEvent
    L3_3 = "stores:Notify"
    L4_3 = L1_2
    L5_3 = "error"
    L6_3 = Utils
    L6_3 = L6_3.translate
    L9_3 = "no_permission"
    L6_3, L9_3 = L6_3(L9_3)
    L2_3(L3_3, L4_3, L5_3, L6_3, L9_3)
    ::lbl_50::
  end
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:loadJobData"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:loadJobData"
function getConfigMarketLocation(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = source
  L2_2 = Wrapper
  L3_2 = L1_2
  L4_2 = A0_2
  L5_2 = "loadJobData"
  L6_2 = false
  function L7_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3
    L1_3 = "SELECT id,name,reward FROM store_jobs WHERE market_id = @market_id AND progress = 0 ORDER BY id ASC"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if nil == L2_3 then
      L3_3 = TriggerClientEvent
      L4_3 = "stores:Notify"
      L5_3 = L1_2
      L6_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "no_available_jobs"
      L9_3, L8_3, L9_3, L10_3 = L9_3(L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3)
      return
    end
    L3_3 = "SELECT user_id FROM store_business WHERE market_id = @market_id"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.fetchAll
    L5_3 = L3_3
    L6_3 = {}
    L9_3 = A0_2
    L6_3["@market_id"] = L9_3
    L4_3 = L4_3(L5_3, L6_3)
    L4_3 = L4_3[1]
    if nil ~= L4_3 then
      L5_3 = L4_3.user_id
      if L5_3 == A0_3 then
        L5_3 = TriggerClientEvent
        L6_3 = "stores:Notify"
        L9_3 = L1_2
        L8_3 = "error"
        L9_3 = Utils
        L9_3 = L9_3.translate
        L10_3 = "cannot_do_own_job"
        L9_3, L10_3 = L9_3(L10_3)
        L5_3(L6_3, L9_3, L8_3, L9_3, L10_3)
        return
      end
    end
    L5_3 = TriggerClientEvent
    L6_3 = "stores:setJobData"
    L9_3 = L1_2
    L8_3 = A0_2
    L9_3 = L2_3
    L5_3(L6_3, L9_3, L8_3, L9_3)
  end
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:startDeliverymanJob"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:startDeliverymanJob"
function getConfigMarketLocation(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  L5_2 = A0_2
  L6_2 = "startDeliverymanJob"
  L7_2 = false
  function L8_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3
    L2_3 = L2_2
    L1_3 = L5_1
    L1_3 = L1_3[L2_3]
    if nil ~= L1_3 then
      L1_3 = TriggerClientEvent
      L2_3 = "stores:Notify"
      L3_3 = L2_2
      L4_3 = "error"
      L5_3 = Utils
      L5_3 = L5_3.translate
      L6_3 = "already_has_job"
      L5_3, L6_3, L9_3, L8_3 = L5_3(L6_3)
      L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3)
      return
    end
    L1_3 = "SELECT * FROM store_jobs WHERE id = @id ORDER BY id ASC"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A1_2
    L4_3["@id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    L3_3 = L2_3.progress
    if 0 == L3_3 then
      L3_3 = "UPDATE `store_jobs` SET progress = 1 WHERE id = @id"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L6_3 = {}
      L9_3 = A1_2
      L6_3["@id"] = L9_3
      L4_3(L5_3, L6_3)
      L5_3 = L2_2
      L4_3 = L5_1
      L6_3 = {}
      L6_3.deliveryman_job_data = L2_3
      L9_3 = {}
      L8_3 = L2_3.product
      L9_3.item = L8_3
      L8_3 = L2_3.amount
      L9_3.amount = L8_3
      L6_3.job_data = L9_3
      L4_3[L5_3] = L6_3
      L4_3 = TriggerClientEvent
      L5_3 = "stores:startJob"
      L6_3 = L2_2
      L9_3 = 0
      L8_3 = true
      L4_3(L5_3, L6_3, L9_3, L8_3)
    else
      L3_3 = TriggerClientEvent
      L4_3 = "stores:setJobData"
      L5_3 = L2_2
      L6_3 = A0_2
      L9_3 = nil
      L3_3(L4_3, L5_3, L6_3, L9_3)
      L3_3 = TriggerClientEvent
      L4_3 = "stores:Notify"
      L5_3 = L2_2
      L6_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "job_already_in_progress"
      L9_3, L8_3 = L9_3(L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3)
    end
  end
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:failed"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:failed"
function getConfigMarketLocation()
local L0_2, L3_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = source
  L3_2 = L5_1
  L3_2 = L3_2[L0_2]
  if L3_2 then
    L3_2 = L5_1
    L3_2 = L3_2[L0_2]
    L3_2 = L3_2.deliveryman_job_data
    if L3_2 then
      L3_2 = "UPDATE `store_jobs` SET progress = 0 WHERE id = @id"
      L2_2 = Utils
      L2_2 = L2_2.Database
      L2_2 = L2_2.execute
      L3_2 = L1_2
      L4_2 = {}
      L5_2 = L5_1
      L5_2 = L5_2[L0_2]
      L5_2 = L5_2.deliveryman_job_data
      L5_2 = L5_2.id
      L4_2["@id"] = L5_2
      L2_2(L3_2, L4_2)
    end
  end
  L3_2 = L5_1
  L3_2[L0_2] = nil
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:storeProductFromInventory"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:storeProductFromInventory"
function getConfigMarketLocation(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3
    L1_3 = storeProduct
    L2_3 = L3_2
    L3_3 = A0_2
    L4_3 = A2_2.item_id
    L5_3 = A2_2.amount
    L1_3(L2_3, L3_3, L4_3, L5_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
function checkLowStockThread(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l23_2, L19_2
  L5_2 = math
  L5_2 = L5_2.floor
  L6_2 = tonumber
  L7_2 = A3_2
  L6_2 = L6_2(L7_2)
  if not L6_2 then
    L6_2 = 0
  end
  L5_2 = L5_2(L6_2)
  A3_2 = L5_2
  L5_2 = A0_2
  if A3_2 > 0 then
    L6_2 = "SELECT stock, truck_upgrade, stock_upgrade FROM `store_business` WHERE market_id = @market_id"
    L7_2 = Utils
    L7_2 = L7_2.Database
    L7_2 = L7_2.fetchAll
    L8_2 = L6_2
    L9_2 = {}
    L9_2["@market_id"] = A1_2
    L7_2 = L7_2(L8_2, L9_2)
    if not L7_2 then
      goto lbl_180
    end
    L8_2 = L7_2[1]
    if not L8_2 then
      goto lbl_180
    end
    L8_2 = json
    L8_2 = L8_2.decode
    L9_2 = L7_2[1]
    L9_2 = L9_2.stock
    L8_2 = L8_2(L9_2)
    L9_2 = L8_2[A2_2]
    if not L9_2 then
      L8_2[A2_2] = 0
    end
    L9_2 = getConfigMarketType
    L10_2 = A1_2
    L9_2 = L9_2(L10_2)
    L10_2 = getStockAmount
    L11_2 = L7_2[1]
    L11_2 = L11_2.stock
    L10_2 = L10_2(L11_2)
    L10_2 = L10_2 + A3_2
    L11_2 = L9_2.stock_capacity
    L12_2 = L9_2.upgrades
    L12_2 = L12_2.stock
    L12_2 = L12_2.level_reward
    L13_2 = L7_2[1]
    L13_2 = L13_2.stock_upgrade
    L12_2 = L12_2[L13_2]
    L11_2 = L11_2 + L12_2
    if L10_2 <= L11_2 then
      L10_2 = L8_2[A2_2]
      L10_2 = L10_2 + A3_2
      L8_2[A2_2] = L10_2
    else
      L10_2 = L9_2.stock_capacity
      L11_2 = L9_2.upgrades
      L11_2 = L11_2.stock
      L11_2 = L11_2.level_reward
      L12_2 = L7_2[1]
      L12_2 = L12_2.stock_upgrade
      L11_2 = L11_2[L12_2]
      L10_2 = L10_2 + L11_2
      L11_2 = getStockAmount
      L12_2 = L7_2[1]
      L12_2 = L12_2.stock
      L11_2 = L11_2(L12_2)
      A3_2 = L10_2 - L11_2
      L10_2 = L8_2[A2_2]
      L10_2 = L10_2 + A3_2
      L8_2[A2_2] = L10_2
      L10_2 = TriggerClientEvent
      L11_2 = "stores:Notify"
      L12_2 = L5_2
      L13_2 = "error"
      L14_2 = Utils
      L14_2 = L14_2.translate
      L15_2 = "stock_full"
      L14_2, L15_2, L16_2, L17_2, L18_2, L19_2 = L14_2(L15_2)
      L10_2(L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
    end
    if not (A3_2 > 0) then
      goto lbl_180
    end
    L10_2 = getItem
    L11_2 = A1_2
    L12_2 = A2_2
    L10_2 = L10_2(L11_2, L12_2)
    if not A4_2 then
      L11_2 = L10_2.is_weapon
      if true == L11_2 then
        L11_2 = Utils
        L11_2 = L11_2.Framework
        L11_2 = L11_2.getPlayerWeapon
        L12_2 = L5_2
        L13_2 = A2_2
        L14_2 = A3_2
        L11_2 = L11_2(L12_2, L13_2, L14_2)
        if L11_2 then
          goto lbl_122
        end
      end
      L11_2 = L10_2.is_weapon
      if true == L11_2 then
        goto lbl_157
      end
      L11_2 = Utils
      L11_2 = L11_2.Framework
      L11_2 = L11_2.getPlayerItem
      L12_2 = L5_2
      L13_2 = A2_2
      L14_2 = A3_2
      L11_2 = L11_2(L12_2, L13_2, L14_2)
      if not L11_2 then
        goto lbl_157
      end
    end
    ::lbl_122::
    L11_2 = "UPDATE `store_business` SET stock = @stock WHERE market_id = @market_id"
    L12_2 = Utils
    L12_2 = L12_2.Database
    L12_2 = L12_2.execute
    L13_2 = L11_2
    L14_2 = {}
    L14_2["@market_id"] = A1_2
    L15_2 = json
    L15_2 = L15_2.encode
    L16_2 = L8_2
    L15_2 = L15_2(L16_2)
    L14_2["@stock"] = L15_2
    L12_2(L13_2, L14_2)
    if not A4_2 then
      L12_2 = openUI
      L13_2 = L5_2
      L14_2 = A1_2
      L15_2 = true
      L12_2(L13_2, L14_2, L15_2)
      L12_2 = TriggerClientEvent
      L13_2 = "stores:Notify"
      L14_2 = L5_2
      L15_2 = "success"
      L16_2 = Utils
      L16_2 = L16_2.translate
      L17_2 = "inserted_on_stock"
      L16_2 = L16_2(L17_2)
      L17_2 = L16_2
      L16_2 = L16_2.format
      a3_2 = A3_2
      L19_2 = L10_2.name
      L16_2, L17_2, a3_2, L19_2 = L16_2(L17_2, a3_2, L19_2)
      L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, a3_2, L19_2)
      goto lbl_180
    end
    ::lbl_157::
    L11_2 = TriggerClientEvent
    L12_2 = "stores:Notify"
    L13_2 = L5_2
    L14_2 = "error"
    L15_2 = Utils
    L15_2 = L15_2.translate
    L16_2 = "not_enought_items"
    L15_2 = L15_2(L16_2)
    L16_2 = L15_2
    L15_2 = L15_2.format
    L17_2 = A3_2
    l10_2 = L10_2.name
    L15_2, L16_2, L17_2, l10_2, L19_2 = L15_2(L16_2, L17_2, l10_2)
    L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l10_2, L19_2)
  else
    L6_2 = TriggerClientEvent
    L7_2 = "stores:Notify"
    L8_2 = L5_2
    L9_2 = "error"
    L10_2 = Utils
    L10_2 = L10_2.translate
    L11_2 = "invalid_value"
    L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l10_2, L19_2 = L10_2(L11_2)
    L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l10_2, L19_2)
  end
  ::lbl_180::
end
storeProduct = checkLowStockThread
function checkLowStockThread(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L3_2 = storeProduct
  L4_2 = A0_2
  L5_2 = A1_2.key
  L6_2 = A1_2.item
  L7_2 = A1_2.amount
  L8_2 = true
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
  L3_2 = "DELETE FROM `store_jobs` WHERE trucker_contract_id = @id;"
  L4_2 = Utils
  L4_2 = L4_2.Database
  L4_2 = L4_2.execute
  L5_2 = L3_2
  L6_2 = {}
  L6_2["@id"] = A2_2
  L4_2(L5_2, L6_2)
end
finishTruckerContract = checkLowStockThread
checkLowStockThread = exports
L7_1 = "finishTruckerContract"
getConfigMarketLocation = finishTruckerContract
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:startImportJob"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:startImportJob"
function getConfigMarketLocation(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3
    L2_3 = L3_2
    L1_3 = L5_1
    L1_3 = L1_3[L2_3]
    if nil ~= L1_3 then
      L1_3 = TriggerClientEvent
      L2_3 = "stores:Notify"
      L3_3 = L3_2
      L4_3 = "error"
      L5_3 = Utils
      L5_3 = L5_3.translate
      L6_3 = "already_has_job"
      L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L5_3(L6_3)
      L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
      return
    end
    L1_3 = A2_2
    if L1_3 then
      L1_3 = Utils
      L1_3 = L1_3.Table
      L1_3 = L1_3.tableLength
      L2_3 = A2_2
      L1_3 = L1_3(L2_3)
      if not (L1_3 <= 0) then
        goto lbl_36
      end
    end
    L1_3 = TriggerClientEvent
    L2_3 = "stores:Notify"
    L3_3 = L3_2
    L4_3 = "error"
    L5_3 = Utils
    L5_3 = L5_3.translate
    L6_3 = "max_job_amount"
    L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L5_3(L6_3)
    L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
    do return end
    ::lbl_36::
    L1_3 = "SELECT truck_upgrade, relationship_upgrade, stock_upgrade, stock FROM `store_business` WHERE market_id = @market_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L3_3 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.fetchAll
    L5_3 = L3_3
    L6_3 = {}
    L9_3 = A0_2
    L6_3["@market_id"] = L9_3
    L4_3 = L4_3(L5_3, L6_3)
    L5_3 = getConfigMarketType
    L6_3 = A0_2
    L5_3 = L5_3(L6_3)
    L6_3 = 0
    L9_3 = 0
    L8_3 = 0
    L9_3 = pairs
    L10_3 = A2_2
    L9_3, L10_3, L11_3, L12_3 = L9_3(L10_3)
    for L13_3, L14_3 in L9_3, L10_3, L11_3, L12_3 do
      L15_3 = L14_3.item_id
      L16_3 = math
      L16_3 = L16_3.floor
      L17_3 = tonumber
      L18_3 = L14_3.amount
      L17_3 = L17_3(L18_3)
      if not L17_3 then
        L17_3 = 0
      end
      L16_3 = L16_3(L17_3)
      L17_3 = nil
      if L4_3 then
        L18_3 = L4_3[1]
        if L18_3 then
          L18_3 = ipairs
          L19_3 = L4_3
          L18_3, L19_3, L20_3, L21_3 = L18_3(L19_3)
          for L22_3, L23_3 in L18_3, L19_3, L20_3, L21_3 do
            L24_3 = getMarketCategory
            L25_3 = L23_3.category
            L24_3 = L24_3(L25_3)
            L24_3 = L24_3.items
            L25_3 = L24_3[L15_3]
            if L25_3 then
              L17_3 = L24_3[L15_3]
            end
          end
        end
      end
      L18_3 = assert
      L19_3 = L17_3
      L20_3 = "Item %s not found in the store %s category config"
      L21_3 = L20_3
      L20_3 = L20_3.format
      L22_3 = L15_3
      L23_3 = A0_2
      L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L20_3(L21_3, L22_3, L23_3)
      L18_3(L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
      L18_3 = math
      L18_3 = L18_3.floor
      L19_3 = L17_3.amount_to_owner
      L20_3 = L17_3.amount_to_owner
      L21_3 = L5_3.upgrades
      L21_3 = L21_3.truck
      L21_3 = L21_3.level_reward
      L22_3 = L2_3[1]
      L22_3 = L22_3.truck_upgrade
      L21_3 = L21_3[L22_3]
      L21_3 = L21_3 / 100
      L20_3 = L20_3 * L21_3
      L19_3 = L19_3 + L20_3
      L18_3 = L18_3(L19_3)
      if L16_3 > 0 and L16_3 <= L18_3 then
        L19_3 = L17_3.price_to_owner
        L19_3 = L19_3 * L16_3
        L20_3 = L5_3.upgrades
        L20_3 = L20_3.relationship
        L20_3 = L20_3.level_reward
        L21_3 = L2_3[1]
        L21_3 = L21_3.relationship_upgrade
        L20_3 = L20_3[L21_3]
        L21_3 = L19_3 * L20_3
        L20_3 = L21_3 / 100
        L21_3 = L19_3 - L20_3
        L6_3 = L6_3 + L21_3
        L21_3 = L16_3 / L18_3
        L21_3 = L21_3 * 100
        L9_3 = L9_3 + L21_3
        L8_3 = L8_3 + L16_3
        L21_3 = L17_3.name
        L14_3.name = L21_3
        L21_3 = L19_3 - L20_3
        L14_3.price = L21_3
      else
        L19_3 = TriggerClientEvent
        L20_3 = "stores:Notify"
        L21_3 = L3_2
        L22_3 = "error"
        L23_3 = Utils
        L23_3 = L23_3.translate
        L24_3 = "max_job_amount"
        L23_3, L24_3, L25_3 = L23_3(L24_3)
        L19_3(L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
        return
      end
    end
    L9_3 = getStockAmount
    L10_3 = L2_3[1]
    L10_3 = L10_3.stock
    L9_3 = L9_3(L10_3)
    L9_3 = L9_3 + L8_3
    L10_3 = L5_3.stock_capacity
    L11_3 = L5_3.upgrades
    L11_3 = L11_3.stock
    L11_3 = L11_3.level_reward
    L12_3 = L2_3[1]
    L12_3 = L12_3.stock_upgrade
    L11_3 = L11_3[L12_3]
    L10_3 = L10_3 + L11_3
    if L9_3 > L10_3 then
      L9_3 = TriggerClientEvent
      L10_3 = "stores:Notify"
      L11_3 = L3_2
      L12_3 = "error"
      L13_3 = Utils
      L13_3 = L13_3.translate
      L14_3 = "max_job_amount"
      L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L13_3(L14_3)
      L9_3(L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
      return
    end
    L9_3 = math
    L9_3 = L9_3.floor
    L10_3 = L6_3
    L9_3 = L9_3(L10_3)
    L6_3 = L9_3
    if L9_3 > 100 or L6_3 <= 0 then
      L9_3 = TriggerClientEvent
      L10_3 = "stores:Notify"
      L11_3 = L3_2
      L12_3 = "error"
      L13_3 = Utils
      L13_3 = L13_3.translate
      L14_3 = "max_job_amount"
      L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L13_3(L14_3)
      L9_3(L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
      return
    end
    L9_3 = Config
    L9_3 = L9_3.charge_import_money_before
    if L9_3 then
      L9_3 = tryGetMarketMoney
      L10_3 = A0_2
      L11_3 = L6_3
      L9_3 = L9_3(L10_3, L11_3)
      if L9_3 then
        L9_3 = insertBalanceHistory
        L10_3 = A0_2
        L11_3 = 1
        L12_3 = Utils
        L12_3 = L12_3.translate
        L13_3 = "buy_products_expenses"
        L12_3 = L12_3(L13_3)
        L13_3 = L12_3
        L12_3 = L12_3.format
        L14_3 = formatItemAmounts
        L15_3 = A2_2
        L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L14_3(L15_3)
        L12_3 = L12_3(L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
        L13_3 = L6_3
        L9_3(L10_3, L11_3, L12_3, L13_3)
      else
        L9_3 = TriggerClientEvent
        L10_3 = "stores:Notify"
        L11_3 = L3_2
        L12_3 = "error"
        L13_3 = Utils
        L13_3 = L13_3.translate
        L14_3 = "insufficient_funds"
        L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L13_3(L14_3)
        L9_3(L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
        return
      end
    end
    L9_3 = Utils
    L9_3 = L9_3.Webhook
    L9_3 = L9_3.sendWebhookMessage
    L10_3 = WebhookURL
    L11_3 = Utils
    L11_3 = L11_3.translate
    L12_3 = "logs_start_import"
    L11_3 = L11_3(L12_3)
    L12_3 = L11_3
    L11_3 = L11_3.format
    L13_3 = A0_2
    L14_3 = formatItemAmounts
    L15_3 = A2_2
    L14_3 = L14_3(L15_3)
    L15_3 = L6_3
    L16_3 = Utils
    L16_3 = L16_3.Framework
    L16_3 = L16_3.getPlayerIdLog
    L17_3 = L3_2
    L16_3 = L16_3(L17_3)
    L17_3 = os
    L17_3 = L17_3.date
    L18_3 = [[

[]]
    L19_3 = Utils
    L19_3 = L19_3.translate
    L20_3 = "logs_date"
    L19_3 = L19_3(L20_3)
    L20_3 = "]: %d/%m/%Y ["
    L21_3 = Utils
    L21_3 = L21_3.translate
    L22_3 = "logs_hour"
    L21_3 = L21_3(L22_3)
    L22_3 = "]: %H:%M:%S"
    L18_3 = L18_3 .. L19_3 .. L20_3 .. L21_3 .. L22_3
    L17_3 = L17_3(L18_3)
    L16_3 = L16_3 .. L17_3
    L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L11_3(L12_3, L13_3, L14_3, L15_3, L16_3)
    L9_3(L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
    L10_3 = L3_2
    L9_3 = L5_1
    L11_3 = {}
    L12_3 = A2_2
    L11_3.job_data = L12_3
    L9_3[L10_3] = L11_3
    L9_3 = TriggerClientEvent
    L10_3 = "stores:startJob"
    L11_3 = L3_2
    L12_3 = L2_3[1]
    L12_3 = L12_3.truck_upgrade
    L13_3 = true
    L9_3(L10_3, L11_3, L12_3, L13_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:startExportJob"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:startExportJob"
function getConfigMarketLocation(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, l25_3
    L2_3 = L3_2
    L1_3 = L5_1
    L1_3 = L1_3[L2_3]
    if nil ~= L1_3 then
      L1_3 = TriggerClientEvent
      L2_3 = "stores:Notify"
      L3_3 = L3_2
      L4_3 = "error"
      L5_3 = Utils
      L5_3 = L5_3.translate
      L6_3 = "already_has_job"
      L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L5_3(L6_3)
      L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
      return
    end
    L1_3 = A2_2
    if L1_3 then
      L1_3 = Utils
      L1_3 = L1_3.Table
      L1_3 = L1_3.tableLength
      L2_3 = A2_2
      L1_3 = L1_3(L2_3)
      if not (L1_3 <= 0) then
        goto lbl_36
      end
    end
    L1_3 = TriggerClientEvent
    L2_3 = "stores:Notify"
    L3_3 = L3_2
    L4_3 = "error"
    L5_3 = Utils
    L5_3 = L5_3.translate
    L6_3 = "max_job_amount"
    L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L5_3(L6_3)
    L1_3(L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
    do return end
    ::lbl_36::
    L1_3 = "SELECT truck_upgrade, relationship_upgrade, stock_upgrade, stock FROM `store_business` WHERE market_id = @market_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L3_3 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.fetchAll
    L5_3 = L3_3
    L6_3 = {}
    L9_3 = A0_2
    L6_3["@market_id"] = L9_3
    L4_3 = L4_3(L5_3, L6_3)
    L5_3 = getConfigMarketType
    L6_3 = A0_2
    L5_3 = L5_3(L6_3)
    L6_3 = 0
    L9_3 = 0
    L8_3 = 0
    L9_3 = json
    L9_3 = L9_3.decode
    L10_3 = L2_3[1]
    L10_3 = L10_3.stock
    L9_3 = L9_3(L10_3)
    L10_3 = pairs
    L11_3 = A2_2
    L10_3, L11_3, L12_3, L13_3 = L10_3(L11_3)
    for L14_3, L15_3 in L10_3, L11_3, L12_3, L13_3 do
      L16_3 = L15_3.item_id
      L17_3 = math
      L17_3 = L17_3.floor
      L18_3 = tonumber
      L19_3 = L15_3.amount
      L18_3 = L18_3(L19_3)
      if not L18_3 then
        L18_3 = 0
      end
      L17_3 = L17_3(L18_3)
      L18_3 = nil
      if L4_3 then
        L19_3 = L4_3[1]
        if L19_3 then
          L19_3 = ipairs
          L20_3 = L4_3
          L19_3, L20_3, L21_3, L22_3 = L19_3(L20_3)
          for L23_3, L24_3 in L19_3, L20_3, L21_3, L22_3 do
            L25_3 = getMarketCategory
            l24_3 = L24_3.category
            L25_3 = L25_3(L26_3)
            L25_3 = L25_3.items
            l25_3 = L25_3[L16_3]
            if l25_3 then
              L18_3 = L25_3[L16_3]
            end
          end
        end
      end
      L19_3 = assert
      L20_3 = L18_3
      L21_3 = "Item %s not found in the store %s category config"
      L22_3 = L21_3
      L21_3 = L21_3.format
      L23_3 = L16_3
      L24_3 = A0_2
      L21_3, L22_3, L23_3, L24_3, L25_3, l25_3 = L21_3(L22_3, L23_3, L24_3)
      L19_3(L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, l25_3)
      L19_3 = math
      L19_3 = L19_3.floor
      L20_3 = L18_3.amount_to_owner
      L21_3 = L18_3.amount_to_owner
      L22_3 = L5_3.upgrades
      L22_3 = L22_3.truck
      L22_3 = L22_3.level_reward
      L23_3 = L2_3[1]
      L23_3 = L23_3.truck_upgrade
      L22_3 = L22_3[L23_3]
      L22_3 = L22_3 / 100
      L21_3 = L21_3 * L22_3
      L20_3 = L20_3 + L21_3
      L19_3 = L19_3(L20_3)
      if L17_3 > 0 and L17_3 <= L19_3 then
        L20_3 = L9_3[L16_3]
        if L17_3 <= L20_3 then
          L20_3 = L9_3[L16_3]
          if L17_3 == L20_3 then
            L9_3[L16_3] = nil
          else
            L20_3 = L9_3[L16_3]
            L20_3 = L20_3 - L17_3
            L9_3[L16_3] = L20_3
          end
          L20_3 = L18_3.price_to_export
          L20_3 = L20_3 * L17_3
          L6_3 = L6_3 + L20_3
          L21_3 = L17_3 / L19_3
          L21_3 = L21_3 * 100
          L8_3 = L8_3 + L21_3
          L9_3 = L9_3 + L17_3
          L21_3 = L18_3.name
          L15_3.name = L21_3
          L15_3.price = L20_3
      end
      else
        L20_3 = TriggerClientEvent
        L21_3 = "stores:Notify"
        L22_3 = L3_2
        L23_3 = "error"
        L24_3 = Utils
        L24_3 = L24_3.translate
        L25_3 = "max_job_amount"
        L24_3, L25_3, l25_3 = L24_3(L25_3)
        L20_3(L21_3, L22_3, L23_3, L24_3, L25_3, l25_3)
        return
      end
    end
    if L8_3 > 100 or L9_3 <= 0 then
      L10_3 = TriggerClientEvent
      L11_3 = "stores:Notify"
      L12_3 = L3_2
      L13_3 = "error"
      L14_3 = Utils
      L14_3 = L14_3.translate
      L15_3 = "max_job_amount"
      L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, l25_3 = L14_3(L15_3)
      L10_3(L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, l25_3)
      return
    end
    L10_3 = "UPDATE `store_business` SET stock = @stock WHERE market_id = @market_id"
    L11_3 = Utils
    L11_3 = L11_3.Database
    L11_3 = L11_3.execute
    L12_3 = L10_3
    L13_3 = {}
    L14_3 = A0_2
    L13_3["@market_id"] = L14_3
    L14_3 = json
    L14_3 = L14_3.encode
    L15_3 = L9_3
    L14_3 = L14_3(L15_3)
    L13_3["@stock"] = L14_3
    L11_3(L12_3, L13_3)
    L11_3 = Utils
    L11_3 = L11_3.Webhook
    L11_3 = L11_3.sendWebhookMessage
    L12_3 = WebhookURL
    L13_3 = Utils
    L13_3 = L13_3.translate
    L14_3 = "logs_start_export"
    L13_3 = L13_3(L14_3)
    L14_3 = L13_3
    L13_3 = L13_3.format
    L15_3 = A0_2
    L16_3 = formatItemAmounts
    L17_3 = A2_2
    L16_3 = L16_3(L17_3)
    L17_3 = Utils
    L17_3 = L17_3.Framework
    L17_3 = L17_3.getPlayerIdLog
    L18_3 = L3_2
    L17_3 = L17_3(L18_3)
    L18_3 = os
    L18_3 = L18_3.date
    L19_3 = [[

[]]
    L20_3 = Utils
    L20_3 = L20_3.translate
    L21_3 = "logs_date"
    L20_3 = L20_3(L21_3)
    L21_3 = "]: %d/%m/%Y ["
    L22_3 = Utils
    L22_3 = L22_3.translate
    L23_3 = "logs_hour"
    L22_3 = L22_3(L23_3)
    L23_3 = "]: %H:%M:%S"
    L19_3 = L19_3 .. L20_3 .. L21_3 .. L22_3 .. L23_3
    L18_3 = L18_3(L19_3)
    L17_3 = L17_3 .. L18_3
    L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, l25_3 = L13_3(L14_3, L15_3, L16_3, L17_3)
    L11_3(L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, l25_3)
    L12_3 = L3_2
    L11_3 = L5_1
    L13_3 = {}
    L14_3 = A2_2
    L13_3.job_data = L14_3
    L11_3[L12_3] = L13_3
    L11_3 = TriggerClientEvent
    L12_3 = "stores:startJob"
    L13_3 = L3_2
    L14_3 = L2_3[1]
    L14_3 = L14_3.truck_upgrade
    L15_3 = false
    L11_3(L12_3, L13_3, L14_3, L15_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:finishImportJob"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:finishImportJob"
function getConfigMarketLocation(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  L5_2 = A0_2
  L6_2 = "finishImportJob"
  L7_2 = false
  function L8_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3
    L2_3 = L2_2
    L1_3 = L5_1
    L1_3 = L1_3[L2_3]
    if L1_3 then
      L2_3 = L2_2
      L1_3 = L5_1
      L1_3 = L1_3[L2_3]
      L1_3 = L1_3.deliveryman_job_data
      if L1_3 then
        L2_3 = L2_2
        L1_3 = L5_1
        L1_3 = L1_3[L2_3]
        L1_3 = L1_3.job_data
        L1_3 = L1_3.item
        L3_3 = L2_2
        L2_3 = L5_1
        L2_3 = L2_3[L3_3]
        L2_3 = L2_3.job_data
        L2_3 = L2_3.amount
        L3_3 = "SELECT stock, truck_upgrade, stock_upgrade FROM `store_business` WHERE market_id = @market_id"
        L4_3 = Utils
        L4_3 = L4_3.Database
        L4_3 = L4_3.fetchAll
        L5_3 = L3_3
        L6_3 = {}
        L9_3 = A0_2
        L6_3["@market_id"] = L9_3
        L4_3 = L4_3(L5_3, L6_3)
        L5_3 = json
        L5_3 = L5_3.decode
        L6_3 = L4_3[1]
        L6_3 = L6_3.stock
        L5_3 = L5_3(L6_3)
        L6_3 = L5_3[L1_3]
        if not L6_3 then
          L5_3[L1_3] = 0
        end
        L9_3 = L2_2
        L6_3 = L5_1
        L6_3 = L6_3[L7_3]
        L6_3 = L6_3.deliveryman_job_data
        if L6_3 then
          L6_3 = 0
          A1_2 = L6_3
          L6_3 = tonumber
          L8_3 = L2_2
          L9_3 = L5_1
          L9_3 = L9_3[L8_3]
          L9_3 = L9_3.deliveryman_job_data
          L9_3 = L9_3.amount
          L6_3 = L6_3(L7_3)
          L2_3 = L6_3 or L2_3
          if not L6_3 then
            L2_3 = 0
          end
          L6_3 = tonumber
          L8_3 = L2_2
          L9_3 = L5_1
          L9_3 = L9_3[L8_3]
          L9_3 = L9_3.deliveryman_job_data
          L9_3 = L9_3.reward
          L6_3 = L6_3(L7_3)
          if not L6_3 then
            L6_3 = 0
          end
          L9_3 = Utils
          L9_3 = L9_3.Framework
          L9_3 = L9_3.giveAccountMoney
          L8_3 = L2_2
          L9_3 = L6_3
          L10_3 = getAccount
          L11_3 = A0_2
          L12_3 = "store"
          L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3 = L10_3(L11_3, L12_3)
          L9_3(L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3)
          L9_3 = "DELETE FROM `store_jobs` WHERE id = @id;"
          L8_3 = Utils
          L8_3 = L8_3.Database
          L8_3 = L8_3.execute
          L9_3 = L7_3
          L10_3 = {}
          L12_3 = L2_2
          L11_3 = L5_1
          L11_3 = L11_3[L12_3]
          L11_3 = L11_3.deliveryman_job_data
          L11_3 = L11_3.id
          L10_3["@id"] = L11_3
          L8_3(L9_3, L10_3)
        end
        L6_3 = getConfigMarketType
        L9_3 = A0_2
        L6_3 = L6_3(L7_3)
        L9_3 = getStockAmount
        L8_3 = L4_3[1]
        L8_3 = L8_3.stock
        L9_3 = L9_3(L8_3)
        L9_3 = L9_3 + L2_3
        L8_3 = L6_3.stock_capacity
        L9_3 = L6_3.upgrades
        L9_3 = L9_3.stock
        L9_3 = L9_3.level_reward
        L10_3 = L4_3[1]
        L10_3 = L10_3.stock_upgrade
        L9_3 = L9_3[L10_3]
        L8_3 = L8_3 + L9_3
        if L9_3 <= L8_3 then
          L9_3 = L5_3[L1_3]
          L9_3 = L9_3 + L2_3
          L5_3[L1_3] = L9_3
        else
          L9_3 = L6_3.stock_capacity
          L8_3 = L6_3.upgrades
          L8_3 = L8_3.stock
          L8_3 = L8_3.level_reward
          L9_3 = L4_3[1]
          L9_3 = L9_3.stock_upgrade
          L8_3 = L8_3[L9_3]
          L9_3 = L9_3 + L8_3
          L8_3 = getStockAmount
          L9_3 = L4_3[1]
          L9_3 = L9_3.stock
          L8_3 = L8_3(L9_3)
          L2_3 = L7_3 - L8_3
          L9_3 = L5_3[L1_3]
          L9_3 = L9_3 + L2_3
          L5_3[L1_3] = L9_3
          L9_3 = TriggerClientEvent
          L8_3 = "stores:Notify"
          L9_3 = L2_2
          L10_3 = "error"
          L11_3 = Utils
          L11_3 = L11_3.translate
          L12_3 = "stock_full"
          L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3 = L11_3(L12_3)
          L9_3(L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3)
        end
        L9_3 = "UPDATE `store_employees` SET jobs_done = jobs_done + 1 WHERE market_id = @market_id and user_id = @user_id"
        L8_3 = Utils
        L8_3 = L8_3.Database
        L8_3 = L8_3.execute
        L9_3 = L7_3
        L10_3 = {}
        L11_3 = A0_2
        L10_3["@market_id"] = L11_3
        L10_3["@user_id"] = A0_3
        L8_3(L9_3, L10_3)
        L8_3 = "UPDATE `store_business` SET stock = @stock, goods_bought = goods_bought + @amount, distance_traveled = distance_traveled + @distance WHERE market_id = @market_id"
        L9_3 = Utils
        L9_3 = L9_3.Database
        L9_3 = L9_3.execute
        L10_3 = L8_3
        L11_3 = {}
        L12_3 = A0_2
        L11_3["@market_id"] = L12_3
        L12_3 = json
        L12_3 = L12_3.encode
        L13_3 = L5_3
        L12_3 = L12_3(L13_3)
        L11_3["@stock"] = L12_3
        L11_3["@amount"] = L2_3
        L12_3 = A1_2
        L11_3["@distance"] = L12_3
        L9_3(L10_3, L11_3)
        L9_3 = Utils
        L9_3 = L9_3.Webhook
        L9_3 = L9_3.sendWebhookMessage
        L10_3 = WebhookURL
        L11_3 = Utils
        L11_3 = L11_3.translate
        L12_3 = "logs_finish_import"
        L11_3 = L11_3(L12_3)
        L12_3 = L11_3
        L11_3 = L11_3.format
        L13_3 = A0_2
        L14_3 = L1_3
        L15_3 = L2_3
        L16_3 = json
        L16_3 = L16_3.encode
        L17_3 = L5_3
        L16_3 = L16_3(L17_3)
        L17_3 = Utils
        L17_3 = L17_3.Framework
        L17_3 = L17_3.getPlayerIdLog
        L18_3 = L2_2
        L17_3 = L17_3(L18_3)
        L18_3 = os
        L18_3 = L18_3.date
        L19_3 = [[

[]]
        L20_3 = Utils
        L20_3 = L20_3.translate
        L21_3 = "logs_date"
        L20_3 = L20_3(L21_3)
        L21_3 = "]: %d/%m/%Y ["
        L22_3 = Utils
        L22_3 = L22_3.translate
        L23_3 = "logs_hour"
        L22_3 = L22_3(L23_3)
        L23_3 = "]: %H:%M:%S"
        L19_3 = L19_3 .. L20_3 .. L21_3 .. L22_3 .. L23_3
        L18_3 = L18_3(L19_3)
        L17_3 = L17_3 .. L18_3
        L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3 = L11_3(L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
        L9_3(L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3)
        L10_3 = L2_2
        L9_3 = L5_1
        L9_3[L10_3] = nil
      else
        L1_3 = 0
        L2_3 = 0
        L3_3 = pairs
        L5_3 = L2_2
        L4_3 = L5_1
        L4_3 = L4_3[L5_3]
        L4_3 = L4_3.job_data
        L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3)
        for L9_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
          L9_3 = L8_3.item_id
          L10_3 = L8_3.price
          L11_3 = L8_3.amount
          L1_3 = L1_3 + L10_3
          L2_3 = L2_3 + L11_3
          L12_3 = storeProduct
          L13_3 = L2_2
          L14_3 = A0_2
          L15_3 = L9_3
          L16_3 = L11_3
          L17_3 = true
          L12_3(L13_3, L14_3, L15_3, L16_3, L17_3)
          L12_3 = Wait
          L13_3 = 1
          L12_3(L13_3)
        end
        L3_3 = math
        L3_3 = L3_3.floor
        L4_3 = L1_3
        L3_3 = L3_3(L4_3)
        L1_3 = L3_3
        L3_3 = Config
        L3_3 = L3_3.charge_import_money_before
        if not L3_3 then
          L3_3 = tryGetMarketMoney
          L4_3 = A0_2
          L5_3 = L1_3
          L3_3 = L3_3(L4_3, L5_3)
          if L3_3 then
            L3_3 = insertBalanceHistory
            L4_3 = A0_2
            L5_3 = 1
            L6_3 = Utils
            L6_3 = L6_3.translate
            L9_3 = "buy_products_expenses"
            L6_3 = L6_3(L7_3)
            L9_3 = L6_3
            L6_3 = L6_3.format
            L8_3 = formatItemAmounts
            L10_3 = L2_2
            L9_3 = L5_1
            L9_3 = L9_3[L10_3]
            L9_3 = L9_3.job_data
            L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3 = L8_3(L9_3)
            L6_3 = L6_3(L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3)
            L9_3 = L1_3
            L3_3(L4_3, L5_3, L6_3, L9_3)
          else
            L3_3 = TriggerClientEvent
            L4_3 = "stores:Notify"
            L5_3 = L2_2
            L6_3 = "error"
            L9_3 = Utils
            L9_3 = L9_3.translate
            L8_3 = "insufficient_funds"
            L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3 = L9_3(L8_3)
            L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3)
            L4_3 = L2_2
            L3_3 = L5_1
            L3_3[L4_3] = nil
            return
          end
        end
        L3_3 = "SELECT stock, truck_upgrade, stock_upgrade FROM `store_business` WHERE market_id = @market_id"
        L4_3 = Utils
        L4_3 = L4_3.Database
        L4_3 = L4_3.fetchAll
        L5_3 = L3_3
        L6_3 = {}
        L9_3 = A0_2
        L6_3["@market_id"] = L9_3
        L4_3 = L4_3(L5_3, L6_3)
        L5_3 = json
        L5_3 = L5_3.decode
        L6_3 = L4_3[1]
        L6_3 = L6_3.stock
        L5_3 = L5_3(L6_3)
        L6_3 = "UPDATE `store_employees` SET jobs_done = jobs_done + 1 WHERE market_id = @market_id and user_id = @user_id"
        L9_3 = Utils
        L9_3 = L9_3.Database
        L9_3 = L9_3.execute
        L8_3 = L6_3
        L9_3 = {}
        L10_3 = A0_2
        L9_3["@market_id"] = L10_3
        L9_3["@user_id"] = A0_3
        L9_3(L8_3, L9_3)
        L9_3 = "UPDATE `store_business` SET goods_bought = goods_bought + @amount, distance_traveled = distance_traveled + @distance WHERE market_id = @market_id"
        L8_3 = Utils
        L8_3 = L8_3.Database
        L8_3 = L8_3.execute
        L9_3 = L7_3
        L10_3 = {}
        L11_3 = A0_2
        L10_3["@market_id"] = L11_3
        L10_3["@amount"] = L2_3
        L11_3 = A1_2
        L10_3["@distance"] = L11_3
        L8_3(L9_3, L10_3)
        L8_3 = Utils
        L8_3 = L8_3.Webhook
        L8_3 = L8_3.sendWebhookMessage
        L9_3 = WebhookURL
        L10_3 = Utils
        L10_3 = L10_3.translate
        L11_3 = "logs_finish_import"
        L10_3 = L10_3(L11_3)
        L11_3 = L10_3
        L10_3 = L10_3.format
        L12_3 = A0_2
        L13_3 = formatItemAmounts
        L15_3 = L2_2
        L14_3 = L5_1
        L14_3 = L14_3[L15_3]
        L14_3 = L14_3.job_data
        L13_3 = L13_3(L14_3)
        L14_3 = json
        L14_3 = L14_3.encode
        L15_3 = L5_3
        L14_3 = L14_3(L15_3)
        L15_3 = Utils
        L15_3 = L15_3.Framework
        L15_3 = L15_3.getPlayerIdLog
        L16_3 = L2_2
        L15_3 = L15_3(L16_3)
        L16_3 = os
        L16_3 = L16_3.date
        L17_3 = [[

[]]
        L18_3 = Utils
        L18_3 = L18_3.translate
        L19_3 = "logs_date"
        L18_3 = L18_3(L19_3)
        L19_3 = "]: %d/%m/%Y ["
        L20_3 = Utils
        L20_3 = L20_3.translate
        L21_3 = "logs_hour"
        L20_3 = L20_3(L21_3)
        L21_3 = "]: %H:%M:%S"
        L17_3 = L17_3 .. L18_3 .. L19_3 .. L20_3 .. L21_3
        L16_3 = L16_3(L17_3)
        L15_3 = L15_3 .. L16_3
        L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3 = L10_3(L11_3, L12_3, L13_3, L14_3, L15_3)
        L8_3(L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3)
        L9_3 = L2_2
        L8_3 = L5_1
        L8_3[L9_3] = nil
      end
    end
  end
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:finishExportJob"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:finishExportJob"
function getConfigMarketLocation(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  L5_2 = A0_2
  L6_2 = "finishExportJob"
  L7_2 = false
  function L8_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3
    L2_3 = L2_2
    L1_3 = L5_1
    L1_3 = L1_3[L2_3]
    if L1_3 then
      L1_3 = 0
      L2_3 = 0
      L3_3 = pairs
      L5_3 = L2_2
      L4_3 = L5_1
      L4_3 = L4_3[L5_3]
      L4_3 = L4_3.job_data
      L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3)
      for L9_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
        L9_3 = L8_3.price
        L10_3 = L8_3.amount
        L1_3 = L1_3 + L9_3
        L2_3 = L2_3 + L10_3
      end
      L3_3 = giveMarketMoney
      L4_3 = A0_2
      L5_3 = L1_3
      L3_3(L4_3, L5_3)
      L3_3 = insertBalanceHistory
      L4_3 = A0_2
      L5_3 = 0
      L6_3 = Utils
      L6_3 = L6_3.translate
      L9_3 = "exported_income"
      L6_3 = L6_3(L7_3)
      L9_3 = L6_3
      L6_3 = L6_3.format
      L8_3 = formatItemAmounts
      L10_3 = L2_2
      L9_3 = L5_1
      L9_3 = L9_3[L10_3]
      L9_3 = L9_3.job_data
      L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3 = L8_3(L9_3)
      L6_3 = L6_3(L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3)
      L9_3 = L1_3
      L3_3(L4_3, L5_3, L6_3, L9_3)
      L3_3 = "UPDATE `store_employees` SET jobs_done = jobs_done + 1 WHERE market_id = @market_id and user_id = @user_id"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L6_3 = {}
      L9_3 = A0_2
      L6_3["@market_id"] = L9_3
      L6_3["@user_id"] = A0_3
      L4_3(L5_3, L6_3)
      L4_3 = "UPDATE `store_business` SET total_money_earned = total_money_earned + @money, distance_traveled = distance_traveled + @distance WHERE market_id = @market_id"
      L5_3 = Utils
      L5_3 = L5_3.Database
      L5_3 = L5_3.execute
      L6_3 = L4_3
      L9_3 = {}
      L8_3 = A0_2
      L9_3["@market_id"] = L8_3
      L9_3["@money"] = L1_3
      L8_3 = A1_2
      L9_3["@distance"] = L8_3
      L5_3(L6_3, L9_3)
      L5_3 = Utils
      L5_3 = L5_3.Webhook
      L5_3 = L5_3.sendWebhookMessage
      L6_3 = WebhookURL
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "logs_finish_export"
      L9_3 = L9_3(L8_3)
      L8_3 = L7_3
      L9_3 = L9_3.format
      L9_3 = A0_2
      L10_3 = formatItemAmounts
      L12_3 = L2_2
      L11_3 = L5_1
      L11_3 = L11_3[L12_3]
      L11_3 = L11_3.job_data
      L10_3 = L10_3(L11_3)
      L11_3 = L1_3
      L12_3 = Utils
      L12_3 = L12_3.Framework
      L12_3 = L12_3.getPlayerIdLog
      L13_3 = L2_2
      L12_3 = L12_3(L13_3)
      L13_3 = os
      L13_3 = L13_3.date
      L14_3 = [[

[]]
      L15_3 = Utils
      L15_3 = L15_3.translate
      L16_3 = "logs_date"
      L15_3 = L15_3(L16_3)
      L16_3 = "]: %d/%m/%Y ["
      L17_3 = Utils
      L17_3 = L17_3.translate
      L18_3 = "logs_hour"
      L17_3 = L17_3(L18_3)
      L18_3 = "]: %H:%M:%S"
      L14_3 = L14_3 .. L15_3 .. L16_3 .. L17_3 .. L18_3
      L13_3 = L13_3(L14_3)
      L12_3 = L12_3 .. L13_3
      L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3 = L9_3(L8_3, L9_3, L10_3, L11_3, L12_3)
      L5_3(L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3)
      L6_3 = L2_2
      L5_3 = L5_1
      L5_3[L6_3] = nil
    end
  end
  L3_2(L4_2, L5_2, L6_2, L7_2, L8_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = RegisterServerEvent
L7_1 = "stores:setPrice"
checkLowStockThread(L7_1)
checkLowStockThread = AddEventHandler
L7_1 = "stores:setPrice"
function getConfigMarketLocation(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3
    L1_3 = A2_2.item_id
    L2_3 = math
    L2_3 = L2_3.floor
    L3_3 = tonumber
    L4_3 = A2_2.price
    L3_3 = L3_3(L4_3)
    if not L3_3 then
      L3_3 = 0
    end
    L2_3 = L2_3(L3_3)
    L3_3 = getItem
    L4_3 = A0_2
    L5_3 = L1_3
    L3_3 = L3_3(L4_3, L5_3)
    L4_3 = L3_3.price_to_customer_min
    if not L4_3 then
      L3_3.price_to_customer_min = 0
    end
    L4_3 = L3_3.price_to_customer_max
    if not L4_3 then
      L3_3.price_to_customer_max = 999999
    end
    L4_3 = L3_3.price_to_customer_min
    if L2_3 >= L4_3 then
      L4_3 = L3_3.price_to_customer_max
      if L2_3 <= L4_3 then
        L4_3 = "SELECT stock_prices FROM `store_business` WHERE market_id = @market_id"
        L5_3 = Utils
        L5_3 = L5_3.Database
        L5_3 = L5_3.fetchAll
        L6_3 = L4_3
        L9_3 = {}
        L8_3 = A0_2
        L9_3["@market_id"] = L8_3
        L5_3 = L5_3(L6_3, L7_3)
        L6_3 = json
        L6_3 = L6_3.decode
        L9_3 = L5_3[1]
        L9_3 = L9_3.stock_prices
        L6_3 = L6_3(L7_3)
        L6_3[L1_3] = L2_3
        L9_3 = "UPDATE `store_business` SET stock_prices = @stock_prices WHERE market_id = @market_id"
        L8_3 = Utils
        L8_3 = L8_3.Database
        L8_3 = L8_3.execute
        L9_3 = L7_3
        L10_3 = {}
        L11_3 = A0_2
        L10_3["@market_id"] = L11_3
        L11_3 = json
        L11_3 = L11_3.encode
        L12_3 = L6_3
        L11_3 = L11_3(L12_3)
        L10_3["@stock_prices"] = L11_3
        L8_3(L9_3, L10_3)
        L8_3 = openUI
        L9_3 = L3_2
        L10_3 = A0_2
        L11_3 = true
        L8_3(L9_3, L10_3, L11_3)
    end
    else
      L4_3 = TriggerClientEvent
      L5_3 = "stores:Notify"
      L6_3 = L3_2
      L9_3 = "error"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L9_3 = "invalid_price"
      L8_3 = L8_3(L9_3)
      L9_3 = L8_3
      L8_3 = L8_3.format
      L10_3 = L3_3.price_to_customer_min
      L11_3 = L3_3.price_to_customer_max
      L8_3, L9_3, L10_3, L11_3, L12_3 = L8_3(L9_3, L10_3, L11_3)
      L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
checkLowStockThread(L7_1, getConfigMarketLocation)
checkLowStockThread = {}
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:buyItem"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:buyItem"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = false
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3
    L2_3 = A0_2
    L1_3 = L6_1
    L1_3 = L1_3[L2_3]
    if nil == L1_3 then
      L2_3 = A0_2
      L1_3 = L6_1
      L1_3[L2_3] = true
      L1_3 = "SELECT stock, stock_prices FROM `store_business` WHERE market_id = @market_id"
      L2_3 = Utils
      L2_3 = L2_3.Database
      L2_3 = L2_3.fetchAllAsync
      L3_3 = L1_3
      L4_3 = {}
      L5_3 = A0_2
      L4_3["@market_id"] = L5_3
      function L5_3(A0_4)
local L1_4, L2_4, L4_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4, L10_4, L11_4, l4_4, l5_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4
        L1_4 = math
        L1_4 = L1_4.floor
        L2_4 = tonumber
        L4_4 = A2_2.amount
        L2_4 = L2_4(L3_4)
        if not L2_4 then
          L2_4 = 0
        end
        L1_4 = L1_4(L2_4)
        A2_2.amount = L1_4
        L1_4 = A2_2.amount
        if L1_4 > 0 then
          L1_4 = {}
          L2_4 = {}
          L4_4 = nil
          if A0_4 then
            L4_4 = A0_4[1]
            if L4_4 then
              L4_4 = json
              L4_4 = L4_4.decode
              L5_4 = A0_4[1]
              L5_4 = L5_4.stock
              L4_4 = L4_4(L5_4)
              L1_4 = L4_4
              L4_4 = A2_2.item_id
              L4_4 = L1_4[L4_4]
              if not L4_4 then
                L4_4 = A2_2.item_id
                L1_4[L4_4] = 0
              end
              L4_4 = json
              L4_4 = L4_4.decode
              L5_4 = A0_4[1]
              L5_4 = L5_4.stock_prices
              L4_4 = L4_4(L5_4)
              L2_4 = L4_4
              L4_4 = getItem
              L5_4 = A0_2
              L6_4 = A2_2.item_id
              L4_4 = L4_4(L5_4, L6_4)
              L4_4 = L4_4
            else
              L4_4 = getItemNoKey
              L5_4 = A2_2.item_id
              L4_4 = L4_4(L5_4)
              L4_4 = L4_4
              L4_4 = Config
              L4_4 = L4_4.has_stock_when_unowed
              if L4_4 then
                L4_4 = A2_2.item_id
                L1_4[L4_4] = 999
              else
                L4_4 = A2_2.item_id
                L1_4[L4_4] = 0
              end
              L2_4 = {}
            end
          else
            L4_4 = getItemNoKey
            L5_4 = A2_2.item_id
            L4_4 = L4_4(L5_4)
            L4_4 = L4_4
            L4_4 = Config
            L4_4 = L4_4.has_stock_when_unowed
            if L4_4 then
              L4_4 = A2_2.item_id
              L1_4[L4_4] = 999
            else
              L4_4 = A2_2.item_id
              L1_4[L4_4] = 0
            end
          end
          L4_4 = A2_2.item_id
          L4_4 = L1_4[L4_4]
          L4_4 = tonumber(L4_4) or 0
          L5_4 = tonumber(A2_2.amount) or 0
          A2_2.amount = L5_4
          if L4_4 >= L5_4 then
            L4_4 = A2_2.item_id
            L4_4 = L2_4[L4_4]
            if not L4_4 then
              L4_4 = L3_4.price_to_customer
            end
            L4_4 = tonumber(L4_4) or 0
            L5_4 = A2_2.amount
            L4_4 = L4_4 * L5_4
            L5_4 = beforeBuyItem
            L6_4 = L3_2
            L7_4 = A0_2
            L8_4 = A2_2.item_id
            L9_4 = A2_2.amount
            L10_4 = L4_4
            L11_4 = L3_4.metadata
            L5_4 = L5_4(L6_4, L7_4, L8_4, L9_4, L10_4, L11_4)
            if not L5_4 then
              goto lbl_318
            end
            L5_4 = L3_4.max_amount_to_purchase
            if L5_4 then
              L5_4 = A2_2.amount
              L6_4 = L3_4.max_amount_to_purchase
              if not (L5_4 <= L6_4) then
                goto lbl_296
              end
            end
            L5_4 = getConfigMarketLocation
            L6_4 = A0_2
            L5_4 = L5_4(L6_4)
            L5_4 = L5_4.account
            L5_4 = L5_4.item
            L6_4 = tonumber
            L7_4 = A2_2.paymentMethod
            L6_4 = L6_4(L7_4)
            L5_4 = L5_4[L6_4]
            L5_4 = L5_4.account
            L6_4 = Utils
            L6_4 = L6_4.Framework
            L6_4 = L6_4.getPlayerAccountMoney
            L7_4 = L3_2
            L8_4 = L5_4
            L6_4 = L6_4(L7_4, L8_4)
            L6_4 = tonumber(L6_4) or 0
            if L4_4 <= L6_4 then
              L7_4 = L3_4.requires_license
              if true == L7_4 then
                L7_4 = Utils
                L7_4 = L7_4.Framework
                L7_4 = L7_4.hasWeaponLicense
                L8_4 = L3_2
                L7_4 = L7_4(L8_4)
                if not L7_4 then
                  goto lbl_276
                end
              end
              L7_4 = L3_4.is_weapon
              if true == L7_4 then
                L7_4 = Utils
                L7_4 = L7_4.Framework
                L7_4 = L7_4.givePlayerWeapon
                L8_4 = L3_2
                L9_4 = A2_2.item_id
                L10_4 = A2_2.amount
                L11_4 = L3_4.metadata
                L7_4 = L7_4(L8_4, L9_4, L10_4, L11_4)
                if L7_4 then
                  goto lbl_145
                end
              end
              L7_4 = L3_4.is_weapon
              if true ~= L7_4 then
                L7_4 = Utils
                L7_4 = L7_4.Framework
                L7_4 = L7_4.givePlayerItem
                L8_4 = L3_2
                L9_4 = A2_2.item_id
                L10_4 = A2_2.amount
                L11_4 = L3_4.metadata
                L7_4 = L7_4(L8_4, L9_4, L10_4, L11_4)
                if L7_4 then
                  goto lbl_145
                end
              else
                L7_4 = TriggerClientEvent
                L8_4 = "stores:Notify"
                L9_4 = L3_2
                L10_4 = "error"
                L11_4 = Utils
                L11_4 = L11_4.translate
                L12_4 = "cant_carry_item"
                L11_4, L12_4, L13_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4 = L11_4(L12_4)
                L7_4(L8_4, L9_4, L10_4, L11_4, L12_4, L13_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4)
                goto lbl_318
              end
            else
              L7_4 = TriggerClientEvent
              L8_4 = "stores:Notify"
              L9_4 = L3_2
              L10_4 = "error"
              L11_4 = Utils
              L11_4 = L11_4.translate
              L12_4 = "insufficient_funds"
              L11_4, L12_4, L13_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4 = L11_4(L12_4)
              L7_4(L8_4, L9_4, L10_4, L11_4, L12_4, L13_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4)
              goto lbl_318
            end
            ::lbl_145::
            L7_4 = Utils
            L7_4 = L7_4.Framework
            L7_4 = L7_4.tryRemoveAccountMoney
            L8_4 = L3_2
            L9_4 = L4_4
            L10_4 = L5_4
            L7_4(L8_4, L9_4, L10_4)
            if A0_4 then
              L7_4 = A0_4[1]
              if L7_4 then
                L7_4 = giveMarketMoney
                L8_4 = A0_2
                L9_4 = L4_4
                L7_4(L8_4, L9_4)
                L7_4 = A2_2.item_id
                L8_4 = A2_2.item_id
                L8_4 = L1_4[L8_4]
                L9_4 = A2_2.amount
                L8_4 = L8_4 - L9_4
                L1_4[L7_4] = L8_4
                L7_4 = A2_2.item_id
                L7_4 = L1_4[L7_4]
                if 0 == L7_4 then
                  L7_4 = A2_2.item_id
                  L1_4[L7_4] = nil
                end
                L7_4 = insertBalanceHistory
                L8_4 = A0_2
                L9_4 = 0
                L10_4 = Utils
                L10_4 = L10_4.translate
                L11_4 = "bought_item"
                L10_4 = L10_4(L11_4)
                L11_4 = L10_4
                L10_4 = L10_4.format
                a2_2 = A2_2.amount
                l3_4 = L4_4.name
                L10_4 = L10_4(L11_4, L12_4, L13_4)
                L11_4 = L4_4
                L7_4(L8_4, L9_4, L10_4, L11_4)
                L7_4 = "UPDATE `store_business` SET stock = @stock, customers = customers + 1, total_money_earned = total_money_earned + @money WHERE market_id = @market_id"
                L8_4 = Utils
                L8_4 = L8_4.Database
                L8_4 = L8_4.execute
                L9_4 = L7_4
                L10_4 = {}
                L11_4 = A0_2
                L10_4["@market_id"] = L11_4
                L10_4["@money"] = L4_4
                L11_4 = json
                L11_4 = L11_4.encode
                l1_4 = L1_4
                L11_4 = L11_4(L12_4)
                L10_4["@stock"] = L11_4
                L8_4(L9_4, L10_4)
              end
            end
            L7_4 = openUI
            L8_4 = L3_2
            L9_4 = A0_2
            L10_4 = true
            L11_4 = true
            L7_4(L8_4, L9_4, L10_4, L11_4)
            L7_4 = Utils
            L7_4 = L7_4.Webhook
            L7_4 = L7_4.sendWebhookMessage
            L8_4 = WebhookURL
            L9_4 = Utils
            L9_4 = L9_4.translate
            L10_4 = "logs_item_bought"
            L9_4 = L9_4(L10_4)
            L10_4 = L9_4
            L9_4 = L9_4.format
            L11_4 = A0_2
            a2_2 = A2_2.item_id
            a2_2 = A2_2.amount
            L14_4 = Utils
            L14_4 = L14_4.Framework
            L14_4 = L14_4.getPlayerIdLog
            L15_4 = L3_2
            L14_4 = L14_4(L15_4)
            L15_4 = os
            L15_4 = L15_4.date
            L16_4 = [[

[]]
            L17_4 = Utils
            L17_4 = L17_4.translate
            L18_4 = "logs_date"
            L17_4 = L17_4(L18_4)
            L18_4 = "]: %d/%m/%Y ["
            L19_4 = Utils
            L19_4 = L19_4.translate
            L20_4 = "logs_hour"
            L19_4 = L19_4(L20_4)
            L20_4 = "]: %H:%M:%S"
            L16_4 = L16_4 .. L17_4 .. L18_4 .. L19_4 .. L20_4
            L15_4 = L15_4(L16_4)
            L14_4 = L14_4 .. L15_4
            L9_4, L10_4, L11_4, a2_2, a2_2, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4 = L9_4(L10_4, L11_4, a2_2, a2_2, L14_4)
            L7_4(L8_4, L9_4, L10_4, L11_4, a2_2, a2_2, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4)
            L7_4 = TriggerClientEvent
            L8_4 = "stores:Notify"
            L9_4 = L3_2
            L10_4 = "success"
            L11_4 = Utils
            L11_4 = L11_4.translate
            a2_2 = "bought_item_2"
            L11_4 = L11_4(L12_4)
            l11_4 = L11_4
            L11_4 = L11_4.format
            a2_2 = A2_2.amount
            L14_4 = L3_4.name
            L11_4, l11_4, a2_2, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4 = L11_4(l11_4, a2_2, L14_4)
            L7_4(L8_4, L9_4, L10_4, L11_4, l11_4, a2_2, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4)
            L7_4 = afterBuyItem
            L8_4 = L3_2
            L9_4 = A0_2
            L10_4 = A2_2.item_id
            L11_4 = A2_2.amount
            l4_4 = L4_4
            l5_4 = L5_4
            L7_4(L8_4, L9_4, L10_4, L11_4, l4_4, l5_4)
            goto lbl_318
            ::lbl_276::
            L7_4 = TriggerClientEvent
            L8_4 = "stores:Notify"
            L9_4 = L3_2
            L10_4 = "error"
            L11_4 = Utils
            L11_4 = L11_4.translate
            l4_4 = "dont_have_weapon_license"
            L11_4, l4_4, l5_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4 = L11_4(l4_4)
            L7_4(L8_4, L9_4, L10_4, L11_4, l4_4, l5_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4)
            goto lbl_318
            ::lbl_296::
            L5_4 = TriggerClientEvent
            L6_4 = "stores:Notify"
            L7_4 = L3_2
            L8_4 = "error"
            L9_4 = Utils
            L9_4 = L9_4.translate
            L10_4 = "cant_buy_that_amount"
            L9_4 = L9_4(L10_4)
            L10_4 = L9_4
            L9_4 = L9_4.format
            L11_4 = L3_4.max_amount_to_purchase
            L9_4, L10_4, L11_4, l4_4, l5_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4 = L9_4(L10_4, L11_4)
            L5_4(L6_4, L7_4, L8_4, L9_4, L10_4, L11_4, l4_4, l5_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4)
            goto lbl_318
          else
            L4_4 = TriggerClientEvent
            L5_4 = "stores:Notify"
            L6_4 = L3_2
            L7_4 = "error"
            L8_4 = Utils
            L8_4 = L8_4.translate
            L9_4 = "stock_empty"
            L8_4, L9_4, L10_4, L11_4, l4_4, l5_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4 = L8_4(L9_4)
            L4_4(L5_4, L6_4, L7_4, L8_4, L9_4, L10_4, L11_4, l4_4, l5_4, L14_4, L15_4, L16_4, L17_4, L18_4, L19_4, L20_4)
          end
        end
        ::lbl_318::
        L1_4 = SetTimeout
        L2_4 = 500
        function L4_4()
local l6_1, a0_2
          a0_2 = A0_2
          l6_1 = L1_3
          l6_1[a0_2] = nil
        end
        L1_4(L2_4, L4_4)
      end
      L2_3(L3_3, L4_3, L5_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:createJob"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:createJob"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3
    L1_3 = "SELECT COUNT(id) as qtd FROM store_jobs WHERE market_id = @market_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    L2_3 = L2_3.qtd
    L3_3 = tonumber
    L4_3 = L2_3
    L3_3 = L3_3(L4_3)
    L4_3 = Config
    L4_3 = L4_3.max_jobs
    if L3_3 < L4_3 then
      L3_3 = "SELECT relationship_upgrade FROM `store_business` WHERE market_id = @market_id"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.fetchAll
      L5_3 = L3_3
      L6_3 = {}
      L9_3 = A0_2
      L6_3["@market_id"] = L9_3
      L4_3 = L4_3(L5_3, L6_3)
      L5_3 = getItem
      L6_3 = A0_2
      L9_3 = A2_2.product
      L5_3 = L5_3(L6_3, L7_3)
      L5_3 = L5_3.price_to_owner
      L6_3 = A2_2.amount
      L5_3 = L5_3 * L6_3
      L6_3 = getConfigMarketType
      L9_3 = A0_2
      L6_3 = L6_3(L7_3)
      L6_3 = L6_3.upgrades
      L6_3 = L6_3.relationship
      L6_3 = L6_3.level_reward
      L9_3 = L4_3[1]
      L9_3 = L9_3.relationship_upgrade
      L6_3 = L6_3[L7_3]
      L9_3 = math
      L9_3 = L9_3.floor
      L8_3 = L5_3 * L6_3
      L8_3 = L8_3 / 100
      L9_3 = L9_3(L8_3)
      L6_3 = L7_3
      L9_3 = A2_2.reward
      L9_3 = L9_3 + L5_3
      L9_3 = L9_3 - L6_3
      L8_3 = tryGetMarketMoney
      L9_3 = A0_2
      L10_3 = L7_3
      L8_3 = L8_3(L9_3, L10_3)
      if L8_3 then
        L8_3 = nil
        L9_3 = Config
        L9_3 = L9_3.trucker_logistics
        L9_3 = L9_3.enable
        if L9_3 then
          L9_3 = nil
          L10_3 = 1
          L11_3 = Config
          L11_3 = L11_3.trucker_logistics
          L11_3 = L11_3.quick_jobs_page
          if true == L11_3 then
            L11_3 = Config
            L11_3 = L11_3.trucker_logistics
            L11_3 = L11_3.available_trucks
            L12_3 = math
            L12_3 = L12_3.random
            L13_3 = 1
            L14_3 = Config
            L14_3 = L14_3.trucker_logistics
            L14_3 = L14_3.available_trucks
            L14_3 = #L14_3
            L12_3 = L12_3(L13_3, L14_3)
            L9_3 = L11_3[L12_3]
            L10_3 = 0
          end
          L11_3 = Config
          L11_3 = L11_3.trucker_logistics
          L11_3 = L11_3.available_trailers
          L12_3 = math
          L12_3 = L12_3.random
          L13_3 = 1
          L14_3 = Config
          L14_3 = L14_3.trucker_logistics
          L14_3 = L14_3.available_trailers
          L14_3 = #L14_3
          L12_3 = L12_3(L13_3, L14_3)
          L11_3 = L11_3[L12_3]
          L12_3 = getConfigMarketLocation
          L13_3 = A0_2
          L12_3 = L12_3(L13_3)
          L12_3 = L12_3.truck_parking_location
          L13_3 = {}
          L14_3 = L12_3[1]
          L13_3.x = L14_3
          L14_3 = L12_3[2]
          L13_3.y = L14_3
          L14_3 = L12_3[3]
          L13_3.z = L14_3
          L14_3 = L12_3[4]
          L13_3.h = L14_3
          L14_3 = A0_2
          L13_3.key = L14_3
          L14_3 = A2_2.reward
          L13_3.reward = L14_3
          L14_3 = A2_2.product
          L13_3.item = L14_3
          L14_3 = A2_2.amount
          L13_3.amount = L14_3
          L14_3 = GetCurrentResourceName
          L14_3 = L14_3()
          L13_3.export = L14_3
          L14_3 = "INSERT INTO `trucker_available_contracts` (contract_type, contract_name, coords_index, price_per_km, cargo_type, fragile, valuable, fast, truck, trailer, external_data) VALUES (@contract_type, @contract_name, @coords_index, @price_per_km, @cargo_type, @fragile, @valuable, @fast, @truck, @trailer, @external_data);"
          L15_3 = Utils
          L15_3 = L15_3.Database
          L15_3 = L15_3.execute
          L16_3 = L14_3
          L17_3 = {}
          L17_3["@contract_type"] = L10_3
          L18_3 = A2_2.name
          L17_3["@contract_name"] = L18_3
          L17_3["@coords_index"] = 0
          L17_3["@price_per_km"] = 0
          L17_3["@cargo_type"] = 0
          L17_3["@fragile"] = 0
          L17_3["@valuable"] = 0
          L17_3["@fast"] = 0
          L17_3["@truck"] = L9_3
          L17_3["@trailer"] = L11_3
          L18_3 = json
          L18_3 = L18_3.encode
          L19_3 = L13_3
          L18_3 = L18_3(L19_3)
          L17_3["@external_data"] = L18_3
          L15_3(L16_3, L17_3)
          L15_3 = "SELECT contract_id FROM `trucker_available_contracts` WHERE progress IS NULL AND contract_name = @name AND coords_index = 0 ORDER BY contract_id DESC LIMIT 1"
          L16_3 = Utils
          L16_3 = L16_3.Database
          L16_3 = L16_3.fetchAll
          L17_3 = L15_3
          L18_3 = {}
          L19_3 = A2_2.name
          L18_3["@name"] = L19_3
          L16_3 = L16_3(L17_3, L18_3)
          L16_3 = L16_3[1]
          L8_3 = L16_3.contract_id
        end
        L9_3 = "INSERT INTO `store_jobs` (market_id,name,reward,product,amount,trucker_contract_id) VALUES (@market_id,@name,@reward,@product,@amount,@trucker_contract_id);"
        L10_3 = Utils
        L10_3 = L10_3.Database
        L10_3 = L10_3.execute
        L11_3 = L9_3
        L12_3 = {}
        L13_3 = A0_2
        L12_3["@market_id"] = L13_3
        L13_3 = A2_2.name
        L12_3["@name"] = L13_3
        L13_3 = A2_2.reward
        L12_3["@reward"] = L13_3
        L13_3 = A2_2.product
        L12_3["@product"] = L13_3
        L13_3 = A2_2.amount
        L12_3["@amount"] = L13_3
        L12_3["@trucker_contract_id"] = L8_3
        L10_3(L11_3, L12_3)
        L10_3 = insertBalanceHistory
        L11_3 = A0_2
        L12_3 = 1
        L13_3 = Utils
        L13_3 = L13_3.translate
        L14_3 = "create_job_expenses"
        L13_3 = L13_3(L14_3)
        L14_3 = L13_3
        L13_3 = L13_3.format
        L15_3 = A2_2.name
        L13_3 = L13_3(L14_3, L15_3)
        L14_3 = L7_3
        L10_3(L11_3, L12_3, L13_3, L14_3)
        L10_3 = openUI
        L11_3 = L3_2
        L12_3 = A0_2
        L13_3 = true
        L10_3(L11_3, L12_3, L13_3)
      else
        L8_3 = TriggerClientEvent
        L9_3 = "stores:Notify"
        L10_3 = L3_2
        L11_3 = "error"
        L12_3 = Utils
        L12_3 = L12_3.translate
        L13_3 = "insufficient_funds"
        L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3 = L12_3(L13_3)
        L8_3(L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
      end
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:deleteJob"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:deleteJob"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3
    L1_3 = deleteJob
    L2_3 = A0_2
    L3_3 = A2_2.job_id
    L1_3 = L1_3(L2_3, L3_3)
    if L1_3 then
      L1_3 = openUI
      L2_3 = L3_2
      L3_3 = A0_2
      L4_3 = true
      L1_3(L2_3, L3_3, L4_3)
    else
      L1_3 = TriggerClientEvent
      L2_3 = "stores:Notify"
      L3_3 = L3_2
      L4_3 = "error"
      L5_3 = Utils
      L5_3 = L5_3.translate
      L6_3 = "cant_delete_job"
      L5_3, L6_3 = L5_3(L6_3)
      L1_3(L2_3, L3_3, L4_3, L5_3, L6_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
function deleteJob(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2
  L2_2 = "SELECT name,reward,product,amount,progress,trucker_contract_id FROM `store_jobs` WHERE id = @id;"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.fetchAll
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@id"] = A1_2
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = L3_2[1]
  if L4_2 then
    L4_2 = Config
    L4_2 = L4_2.trucker_logistics
    L4_2 = L4_2.enable
    if L4_2 then
      L4_2 = "SELECT progress FROM `trucker_available_contracts` WHERE contract_id = @contract_id"
      L5_2 = Utils
      L5_2 = L5_2.Database
      L5_2 = L5_2.fetchAll
      L6_2 = L4_2
      L7_2 = {}
      L8_2 = L3_2[1]
      L8_2 = L8_2.trucker_contract_id
      L7_2["@contract_id"] = L8_2
      L5_2 = L5_2(L6_2, L7_2)
      if L5_2 then
        L6_2 = L5_2[1]
        if L6_2 then
          L6_2 = L5_2[1]
          L6_2 = L6_2.progress
          if nil ~= L6_2 then
            L6_2 = false
            return L6_2
          end
        end
      end
    end
    L4_2 = L3_2[1]
    L4_2 = L4_2.progress
    if 0 == L4_2 then
      L4_2 = "SELECT relationship_upgrade FROM `store_business` WHERE market_id = @market_id"
      L5_2 = Utils
      L5_2 = L5_2.Database
      L5_2 = L5_2.fetchAll
      L6_2 = L4_2
      L7_2 = {}
      L7_2["@market_id"] = A0_2
      L5_2 = L5_2(L6_2, L7_2)
      L6_2 = getItem
      L7_2 = A0_2
      L8_2 = L3_2[1]
      L8_2 = L8_2.product
      L6_2 = L6_2(L7_2, L8_2)
      L6_2 = L6_2.price_to_owner
      L7_2 = L3_2[1]
      L7_2 = L7_2.amount
      L6_2 = L6_2 * L7_2
      L7_2 = getConfigMarketType
      L8_2 = A0_2
      L7_2 = L7_2(L8_2)
      L7_2 = L7_2.upgrades
      L7_2 = L7_2.relationship
      L7_2 = L7_2.level_reward
      L8_2 = L5_2[1]
      L8_2 = L8_2.relationship_upgrade
      L7_2 = L7_2[L8_2]
      L8_2 = math
      L8_2 = L8_2.floor
      L9_2 = L6_2 * L7_2
      L9_2 = L9_2 / 100
      L8_2 = L8_2(L9_2)
      L7_2 = L8_2
      L8_2 = L3_2[1]
      L8_2 = L8_2.reward
      L8_2 = L8_2 + L6_2
      L8_2 = L8_2 - L7_2
      L9_2 = "UPDATE `store_business` SET total_money_spent = total_money_spent - @amount WHERE market_id = @market_id"
      L10_2 = Utils
      L10_2 = L10_2.Database
      L10_2 = L10_2.execute
      L11_2 = L9_2
      L12_2 = {}
      L12_2["@amount"] = L8_2
      L12_2["@market_id"] = A0_2
      L10_2(L11_2, L12_2)
      L10_2 = "DELETE FROM `store_jobs` WHERE id = @id;"
      L11_2 = Utils
      L11_2 = L11_2.Database
      L11_2 = L11_2.execute
      L12_2 = L10_2
      L13_2 = {}
      L13_2["@id"] = A1_2
      L11_2(L12_2, L13_2)
      L11_2 = Config
      L11_2 = L11_2.trucker_logistics
      L11_2 = L11_2.enable
      if L11_2 then
        L11_2 = "DELETE FROM `trucker_available_contracts` WHERE contract_id = @contract_id;"
        L12_2 = Utils
        L12_2 = L12_2.Database
        L12_2 = L12_2.execute
        L13_2 = L11_2
        L14_2 = {}
        L15_2 = L3_2[1]
        L15_2 = L15_2.trucker_contract_id
        L14_2["@contract_id"] = L15_2
        L12_2(L13_2, L14_2)
      end
      L11_2 = giveMarketMoney
      L12_2 = A0_2
      L13_2 = L8_2
      L11_2(L12_2, L13_2)
      L11_2 = insertBalanceHistory
      L12_2 = A0_2
      L13_2 = 0
      L14_2 = Utils
      L14_2 = L14_2.translate
      L15_2 = "create_job_income"
      L14_2 = L14_2(L15_2)
      L15_2 = L14_2
      L14_2 = L14_2.format
      L16_2 = L3_2[1]
      L16_2 = L16_2.name
      L14_2 = L14_2(L15_2, L16_2)
      L15_2 = L8_2
      L11_2(L12_2, L13_2, L14_2, L15_2)
      L11_2 = true
      return L11_2
    else
      L4_2 = false
      return L4_2
    end
  end
end
deleteJob = deleteJob
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:renameMarket"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:renameMarket"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = Config
  L3_2 = L3_2.disable_rename_business
  if not L3_2 then
    L3_2 = source
    L4_2 = Wrapper
    L5_2 = L3_2
    L6_2 = A0_2
    L7_2 = A1_2
    L8_2 = true
    function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3
      L1_3 = A2_2
      if L1_3 then
        L1_3 = A2_2.name
        if L1_3 then
          L1_3 = A2_2.color
          if L1_3 then
            L1_3 = A2_2.blip
            if L1_3 then
              L1_3 = "UPDATE `store_business` SET market_name = @name, market_color = @color, market_blip = @blip WHERE market_id = @market_id"
              L2_3 = Utils
              L2_3 = L2_3.Database
              L2_3 = L2_3.execute
              L3_3 = L1_3
              L4_3 = {}
              L5_3 = A2_2.name
              L4_3["@name"] = L5_3
              L5_3 = A2_2.color
              L4_3["@color"] = L5_3
              L5_3 = A2_2.blip
              L4_3["@blip"] = L5_3
              L5_3 = A0_2
              L4_3["@market_id"] = L5_3
              L2_3(L3_3, L4_3)
              L2_3 = TriggerClientEvent
              L3_3 = "stores:updateBlip"
              L4_3 = -1
              L5_3 = A0_2
              L6_3 = A2_2.name
              L9_3 = A2_2.color
              L8_3 = A2_2.blip
              L2_3(L3_3, L4_3, L5_3, L6_3, L9_3, L8_3)
              L2_3 = openUI
              L3_3 = L3_2
              L4_3 = A0_2
              L5_3 = true
              L2_3(L3_3, L4_3, L5_3)
            end
          end
        end
      end
    end
    L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
  end
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:getBlips"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:getBlips"
function fn_L9_1()
local L0_2, L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L0_2 = source
  L3_2 = "SELECT market_id, market_name, market_color, market_blip FROM `store_business`"
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.fetchAll
  L3_2 = L1_2
  L4_2 = {}
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = {}
  L4_2 = pairs
  L5_2 = L2_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = L9_2.market_id
    L11_2 = {}
    L12_2 = L9_2.market_name
    L11_2.market_name = L12_2
    L12_2 = L9_2.market_color
    L11_2.market_color = L12_2
    L12_2 = L9_2.market_blip
    L11_2.market_blip = L12_2
    L3_2[L10_2] = L11_2
  end
  L4_2 = TriggerClientEvent
  L5_2 = "stores:setBlips"
  L6_2 = L0_2
  L7_2 = L3_2
  L4_2(L5_2, L6_2, L7_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:buyUpgrade"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:buyUpgrade"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3
    L1_3 = "SELECT "
    L2_3 = A2_2.id
    L3_3 = "_upgrade FROM `store_business` WHERE market_id = @market_id"
    L1_3 = L1_3 .. L2_3 .. L3_3
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    L3_3 = A2_2.id
    L4_3 = "_upgrade"
    L3_3 = L3_3 .. L4_3
    L3_3 = L2_3[L3_3]
    if L3_3 < 5 then
      L3_3 = getConfigMarketType
      L4_3 = A0_2
      L3_3 = L3_3(L4_3)
      L3_3 = L3_3.upgrades
      L4_3 = A2_2.id
      L3_3 = L3_3[L4_3]
      L3_3 = L3_3.price
      L4_3 = tryGetMarketMoney
      L5_3 = A0_2
      L6_3 = L3_3
      L4_3 = L4_3(L5_3, L6_3)
      if L4_3 then
        L4_3 = "UPDATE `store_business` SET "
        L5_3 = A2_2.id
        L6_3 = "_upgrade = "
        L9_3 = A2_2.id
        L8_3 = "_upgrade + 1 WHERE market_id = @market_id"
        L4_3 = L4_3 .. L5_3 .. L6_3 .. L7_3 .. L8_3
        L5_3 = Utils
        L5_3 = L5_3.Database
        L5_3 = L5_3.execute
        L6_3 = L4_3
        L9_3 = {}
        L8_3 = A0_2
        L9_3["@market_id"] = L8_3
        L5_3(L6_3, L9_3)
        L5_3 = insertBalanceHistory
        L6_3 = A0_2
        L9_3 = 1
        L8_3 = Utils
        L8_3 = L8_3.translate
        L9_3 = "upgrade_expenses"
        L8_3 = L8_3(L9_3)
        L9_3 = L8_3
        L8_3 = L8_3.format
        L10_3 = Utils
        L10_3 = L10_3.translate
        L11_3 = A2_2.id
        L12_3 = "_upgrade"
        L11_3 = L11_3 .. L12_3
        L10_3, L11_3, L12_3 = L10_3(L11_3)
        L8_3 = L8_3(L9_3, L10_3, L11_3, L12_3)
        L9_3 = L3_3
        L5_3(L6_3, L9_3, L8_3, L9_3)
        L5_3 = openUI
        L6_3 = L3_2
        L9_3 = A0_2
        L8_3 = true
        L5_3(L6_3, L9_3, L8_3)
      else
        L4_3 = TriggerClientEvent
        L5_3 = "stores:Notify"
        L6_3 = L3_2
        L9_3 = "error"
        L8_3 = Utils
        L8_3 = L8_3.translate
        L9_3 = "insufficient_funds"
        L8_3, L9_3, L10_3, L11_3, L12_3 = L8_3(L9_3)
        L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3)
      end
    else
      L3_3 = TriggerClientEvent
      L4_3 = "stores:Notify"
      L5_3 = L3_2
      L6_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "max_level"
      L9_3, L8_3, L9_3, L10_3, L11_3, L12_3 = L9_3(L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:hideBalance"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:hideBalance"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3
    L1_3 = "UPDATE `store_balance` SET hidden = 1 WHERE market_id = @market_id AND id = @id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.execute
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L5_3 = A2_2.balance_id
    L4_3["@id"] = L5_3
    L2_3(L3_3, L4_3)
    L2_3 = openUI
    L3_3 = L3_2
    L4_3 = A0_2
    L5_3 = true
    L2_3(L3_3, L4_3, L5_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:showBalance"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:showBalance"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3
    L1_3 = "UPDATE `store_balance` SET hidden = 0 WHERE market_id = @market_id AND id = @id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.execute
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L5_3 = A2_2.balance_id
    L4_3["@id"] = L5_3
    L2_3(L3_3, L4_3)
    L2_3 = openUI
    L3_3 = L3_2
    L4_3 = A0_2
    L5_3 = true
    L2_3(L3_3, L4_3, L5_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:withdrawMoney"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:withdrawMoney"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3
    L1_3 = math
    L1_3 = L1_3.floor
    L2_3 = tonumber
    L3_3 = A2_2.amount
    L2_3 = L2_3(L3_3)
    if not L2_3 then
      L2_3 = 0
    end
    L1_3 = L1_3(L2_3)
    if L1_3 and L1_3 > 0 then
      L2_3 = "SELECT money FROM `store_business` WHERE market_id = @market_id"
      L3_3 = Utils
      L3_3 = L3_3.Database
      L3_3 = L3_3.fetchAll
      L4_3 = L2_3
      L5_3 = {}
      L6_3 = A0_2
      L5_3["@market_id"] = L6_3
      L3_3 = L3_3(L4_3, L5_3)
      L3_3 = L3_3[1]
      if L3_3 then
        L4_3 = tonumber
        L5_3 = L3_3.money
        L4_3 = L4_3(L5_3)
        if L1_3 <= L4_3 then
          L4_3 = "UPDATE `store_business` SET money = money - @amount WHERE market_id = @market_id"
          L5_3 = Utils
          L5_3 = L5_3.Database
          L5_3 = L5_3.execute
          L6_3 = L4_3
          L9_3 = {}
          L8_3 = A0_2
          L9_3["@market_id"] = L8_3
          L9_3["@amount"] = L1_3
          L5_3(L6_3, L9_3)
          L5_3 = Utils
          L5_3 = L5_3.Framework
          L5_3 = L5_3.giveAccountMoney
          L6_3 = L3_2
          L9_3 = L1_3
          L8_3 = getAccount
          L9_3 = A0_2
          L10_3 = "store"
          L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L8_3(L9_3, L10_3)
          L5_3(L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L5_3 = insertBalanceHistory
          L6_3 = A0_2
          L9_3 = 1
          L8_3 = Utils
          L8_3 = L8_3.translate
          L9_3 = "money_withdrawn"
          L8_3 = L8_3(L9_3)
          L9_3 = L1_3
          L5_3(L6_3, L9_3, L8_3, L9_3)
          L5_3 = TriggerClientEvent
          L6_3 = "stores:Notify"
          L9_3 = L3_2
          L8_3 = "success"
          L9_3 = Utils
          L9_3 = L9_3.translate
          L10_3 = "money_withdrawn"
          L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L9_3(L10_3)
          L5_3(L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L5_3 = Utils
          L5_3 = L5_3.Webhook
          L5_3 = L5_3.sendWebhookMessage
          L6_3 = WebhookURL
          L9_3 = Utils
          L9_3 = L9_3.translate
          L8_3 = "logs_money_withdrawn"
          L9_3 = L9_3(L8_3)
          L8_3 = L7_3
          L9_3 = L9_3.format
          L9_3 = A0_2
          L10_3 = L1_3
          L11_3 = Utils
          L11_3 = L11_3.Framework
          L11_3 = L11_3.getPlayerIdLog
          L12_3 = L3_2
          L11_3 = L11_3(L12_3)
          L12_3 = os
          L12_3 = L12_3.date
          L13_3 = [[

[]]
          L14_3 = Utils
          L14_3 = L14_3.translate
          L15_3 = "logs_date"
          L14_3 = L14_3(L15_3)
          L15_3 = "]: %d/%m/%Y ["
          L16_3 = Utils
          L16_3 = L16_3.translate
          L17_3 = "logs_hour"
          L16_3 = L16_3(L17_3)
          L17_3 = "]: %H:%M:%S"
          L13_3 = L13_3 .. L14_3 .. L15_3 .. L16_3 .. L17_3
          L12_3 = L12_3(L13_3)
          L11_3 = L11_3 .. L12_3
          L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L9_3(L8_3, L9_3, L10_3, L11_3)
          L5_3(L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L5_3 = openUI
          L6_3 = L3_2
          L9_3 = A0_2
          L8_3 = true
          L5_3(L6_3, L9_3, L8_3)
      end
      else
        L4_3 = TriggerClientEvent
        L5_3 = "stores:Notify"
        L6_3 = L3_2
        L9_3 = "error"
        L8_3 = Utils
        L8_3 = L8_3.translate
        L9_3 = "insufficient_funds"
        L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L8_3(L9_3)
        L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
      end
    else
      L2_3 = TriggerClientEvent
      L3_3 = "stores:Notify"
      L4_3 = L3_2
      L5_3 = "error"
      L6_3 = Utils
      L6_3 = L6_3.translate
      L9_3 = "invalid_value"
      L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L6_3(L9_3)
      L2_3(L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:depositMoney"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:depositMoney"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3
    L1_3 = math
    L1_3 = L1_3.floor
    L2_3 = tonumber
    L3_3 = A2_2.amount
    L2_3 = L2_3(L3_3)
    if not L2_3 then
      L2_3 = 0
    end
    L1_3 = L1_3(L2_3)
    if L1_3 and L1_3 > 0 then
      L2_3 = Utils
      L2_3 = L2_3.Framework
      L2_3 = L2_3.tryRemoveAccountMoney
      L3_3 = L3_2
      L4_3 = L1_3
      L5_3 = getAccount
      L6_3 = A0_2
      L9_3 = "store"
      L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3 = L5_3(L6_3, L9_3)
      L2_3 = L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3)
      if L2_3 then
        L2_3 = giveMarketMoney
        L3_3 = A0_2
        L4_3 = L1_3
        L2_3(L3_3, L4_3)
        L2_3 = insertBalanceHistory
        L3_3 = A0_2
        L4_3 = 0
        L5_3 = Utils
        L5_3 = L5_3.translate
        L6_3 = "money_deposited"
        L5_3 = L5_3(L6_3)
        L6_3 = L1_3
        L2_3(L3_3, L4_3, L5_3, L6_3)
        L2_3 = TriggerClientEvent
        L3_3 = "stores:Notify"
        L4_3 = L3_2
        L5_3 = "success"
        L6_3 = Utils
        L6_3 = L6_3.translate
        L9_3 = "money_deposited"
        L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3 = L6_3(L9_3)
        L2_3(L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3)
        L2_3 = Utils
        L2_3 = L2_3.Webhook
        L2_3 = L2_3.sendWebhookMessage
        L3_3 = WebhookURL
        L4_3 = Utils
        L4_3 = L4_3.translate
        L5_3 = "logs_money_deposited"
        L4_3 = L4_3(L5_3)
        L5_3 = L4_3
        L4_3 = L4_3.format
        L6_3 = A0_2
        L9_3 = L1_3
        L8_3 = Utils
        L8_3 = L8_3.Framework
        L8_3 = L8_3.getPlayerIdLog
        L9_3 = L3_2
        L8_3 = L8_3(L9_3)
        L9_3 = os
        L9_3 = L9_3.date
        L10_3 = [[

[]]
        L11_3 = Utils
        L11_3 = L11_3.translate
        L12_3 = "logs_date"
        L11_3 = L11_3(L12_3)
        L12_3 = "]: %d/%m/%Y ["
        L13_3 = Utils
        L13_3 = L13_3.translate
        L14_3 = "logs_hour"
        L13_3 = L13_3(L14_3)
        L14_3 = "]: %H:%M:%S"
        L10_3 = L10_3 .. L11_3 .. L12_3 .. L13_3 .. L14_3
        L9_3 = L9_3(L10_3)
        L8_3 = L8_3 .. L9_3
        L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3 = L4_3(L5_3, L6_3, L9_3, L8_3)
        L2_3(L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3)
        L2_3 = openUI
        L3_3 = L3_2
        L4_3 = A0_2
        L5_3 = true
        L2_3(L3_3, L4_3, L5_3)
      else
        L2_3 = TriggerClientEvent
        L3_3 = "stores:Notify"
        L4_3 = L3_2
        L5_3 = "error"
        L6_3 = Utils
        L6_3 = L6_3.translate
        L9_3 = "insufficient_funds"
        L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3 = L6_3(L9_3)
        L2_3(L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3)
      end
    else
      L2_3 = TriggerClientEvent
      L3_3 = "stores:Notify"
      L4_3 = L3_2
      L5_3 = "error"
      L6_3 = Utils
      L6_3 = L6_3.translate
      L9_3 = "invalid_value"
      L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3 = L6_3(L9_3)
      L2_3(L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = Utils
deleteJob = deleteJob.Callback
deleteJob = deleteJob.RegisterServerCallback
getConfigMarketLocation = "stores:loadBalanceHistory"
function fn_L9_1(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2
  L4_2 = "SELECT * FROM `store_balance` WHERE market_id = @market_id AND id < @last_balance_id ORDER BY id DESC LIMIT 50"
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.fetchAll
  L6_2 = L4_2
  L7_2 = {}
  L7_2["@market_id"] = A2_2
  L8_2 = A3_2.last_balance_id
  L7_2["@last_balance_id"] = L8_2
  L5_2 = L5_2(L6_2, L7_2)
  L6_2 = A1_2
  L7_2 = L5_2
  L6_2(L7_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:hirePlayer"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:hirePlayer"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3
    L1_3 = A2_2.user
    L2_3 = "SELECT COUNT(user_id) as qtd FROM `store_employees` WHERE market_id = @market_id"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.fetchAll
    L4_3 = L2_3
    L5_3 = {}
    L6_3 = A0_2
    L5_3["@market_id"] = L6_3
    L3_3 = L3_3(L4_3, L5_3)
    L4_3 = getConfigMarketType
    L5_3 = A0_2
    L4_3 = L4_3(L5_3)
    L4_3 = L4_3.max_employees
    if not L4_3 then
      L4_3 = 0
    end
    L5_3 = L3_3[1]
    L5_3 = L5_3.qtd
    if L4_3 > L5_3 then
      L5_3 = Utils
      L5_3 = L5_3.Framework
      L5_3 = L5_3.getPlayerName
      L6_3 = L1_3
      L5_3 = L5_3(L6_3)
      if L5_3 then
        L6_3 = "SELECT market_id, user_id FROM `store_employees` WHERE user_id = @user_id"
        L9_3 = Utils
        L9_3 = L9_3.Database
        L9_3 = L9_3.fetchAll
        L8_3 = L6_3
        L9_3 = {}
        L9_3["@user_id"] = L1_3
        L9_3 = L9_3(L8_3, L9_3)
        L8_3 = pairs
        L9_3 = L7_3
        L8_3, L9_3, L10_3, L11_3 = L8_3(L9_3)
        for L12_3, L13_3 in L8_3, L9_3, L10_3, L11_3 do
          L14_3 = L13_3.user_id
          if L14_3 == L1_3 then
            L14_3 = L13_3.market_id
            L15_3 = A0_2
            if L14_3 == L15_3 then
              L14_3 = TriggerClientEvent
              L15_3 = "stores:Notify"
              L16_3 = L3_2
              L17_3 = "error"
              L18_3 = Utils
              L18_3 = L18_3.translate
              L19_3 = "user_employed"
              L18_3, L19_3 = L18_3(L19_3)
              L14_3(L15_3, L16_3, L17_3, L18_3, L19_3)
              return
            end
          end
        end
        L8_3 = beforeHireEmployee
        L9_3 = L3_2
        L10_3 = A0_2
        L11_3 = L1_3
        L8_3 = L8_3(L9_3, L10_3, L11_3)
        if not L8_3 then
          return
        end
        L8_3 = #L9_3
        L9_3 = Config
        L9_3 = L9_3.max_stores_employed
        if L8_3 < L9_3 then
          L8_3 = "INSERT INTO `store_employees` (`user_id`, `market_id`, `role`, `timer`) VALUES (@user_id, @market_id, @role, @timer);"
          L9_3 = Utils
          L9_3 = L9_3.Database
          L9_3 = L9_3.execute
          L10_3 = L8_3
          L11_3 = {}
          L11_3["@user_id"] = L1_3
          L12_3 = A0_2
          L11_3["@market_id"] = L12_3
          L11_3["@role"] = 1
          L12_3 = os
          L12_3 = L12_3.time
          L12_3 = L12_3()
          L11_3["@timer"] = L12_3
          L9_3(L10_3, L11_3)
          L9_3 = openUI
          L10_3 = L3_2
          L11_3 = A0_2
          L12_3 = true
          L9_3(L10_3, L11_3, L12_3)
          L9_3 = TriggerClientEvent
          L10_3 = "stores:Notify"
          L11_3 = L3_2
          L12_3 = "success"
          L13_3 = Utils
          L13_3 = L13_3.translate
          L14_3 = "hired_user"
          L13_3 = L13_3(L14_3)
          L14_3 = L13_3
          L13_3 = L13_3.format
          L15_3 = L5_3
          L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3 = L13_3(L14_3, L15_3)
          L9_3(L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
          L9_3 = afterHireEmployee
          L10_3 = L3_2
          L11_3 = A0_2
          L12_3 = L1_3
          L9_3(L10_3, L11_3, L12_3)
        else
          L8_3 = TriggerClientEvent
          L9_3 = "stores:Notify"
          L10_3 = L3_2
          L11_3 = "error"
          L12_3 = Utils
          L12_3 = L12_3.translate
          L13_3 = "user_employed"
          L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3 = L12_3(L13_3)
          L8_3(L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
        end
      else
        L6_3 = TriggerClientEvent
        L9_3 = "stores:Notify"
        L8_3 = L3_2
        L9_3 = "error"
        L10_3 = Utils
        L10_3 = L10_3.translate
        L11_3 = "user_not_found"
        L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3 = L10_3(L11_3)
        L6_3(L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
      end
    else
      L5_3 = TriggerClientEvent
      L6_3 = "stores:Notify"
      L9_3 = L3_2
      L8_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L10_3 = "max_employees"
      L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3 = L9_3(L10_3)
      L5_3(L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:firePlayer"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:firePlayer"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3
    L1_3 = "DELETE FROM `store_employees` WHERE user_id = @user_id AND market_id = @market_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.execute
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A2_2.user
    L4_3["@user_id"] = L5_3
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3(L3_3, L4_3)
    L2_3 = TriggerClientEvent
    L3_3 = "stores:Notify"
    L4_3 = L3_2
    L5_3 = "success"
    L6_3 = Utils
    L6_3 = L6_3.translate
    L9_3 = "fired_user"
    L6_3, L9_3 = L6_3(L9_3)
    L2_3(L3_3, L4_3, L5_3, L6_3, L9_3)
    L2_3 = openUI
    L3_3 = L3_2
    L4_3 = A0_2
    L5_3 = true
    L2_3(L3_3, L4_3, L5_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:changeRole"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:changeRole"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3
    L1_3 = "UPDATE `store_employees` SET role = @role WHERE market_id = @market_id AND user_id = @user_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.execute
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L5_3 = A2_2.user_id
    L4_3["@user_id"] = L5_3
    L5_3 = A2_2.role
    L4_3["@role"] = L5_3
    L2_3(L3_3, L4_3)
    L2_3 = TriggerClientEvent
    L3_3 = "stores:Notify"
    L4_3 = L3_2
    L5_3 = "success"
    L6_3 = Utils
    L6_3 = L6_3.translate
    L9_3 = "role_changed"
    L6_3, L9_3 = L6_3(L9_3)
    L2_3(L3_3, L4_3, L5_3, L6_3, L9_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:giveComission"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:giveComission"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3
    L1_3 = A2_2.user
    L2_3 = math
    L2_3 = L2_3.floor
    L3_3 = tonumber
    L4_3 = A2_2.amount
    L3_3 = L3_3(L4_3)
    if not L3_3 then
      L3_3 = 0
    end
    L2_3 = L2_3(L3_3)
    if L2_3 > 0 then
      L3_3 = Utils
      L3_3 = L3_3.Framework
      L3_3 = L3_3.getPlayerSource
      L4_3 = L1_3
      L3_3 = L3_3(L4_3)
      if L3_3 then
        L4_3 = tryGetMarketMoney
        L5_3 = A0_2
        L6_3 = L2_3
        L4_3 = L4_3(L5_3, L6_3)
        if L4_3 then
          L4_3 = Utils
          L4_3 = L4_3.Framework
          L4_3 = L4_3.giveAccountMoney
          L5_3 = L3_3
          L6_3 = L2_3
          L9_3 = getAccount
          L8_3 = A0_2
          L9_3 = "store"
          L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L9_3(L8_3, L9_3)
          L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L4_3 = TriggerClientEvent
          L5_3 = "stores:Notify"
          L6_3 = L3_3
          L9_3 = "success"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L9_3 = "comission_received"
          L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L8_3(L9_3)
          L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L4_3 = TriggerClientEvent
          L5_3 = "stores:Notify"
          L6_3 = L3_2
          L9_3 = "success"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L9_3 = "comission_sent"
          L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L8_3(L9_3)
          L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L4_3 = insertBalanceHistory
          L5_3 = A0_2
          L6_3 = 1
          L9_3 = Utils
          L9_3 = L9_3.translate
          L8_3 = "give_comission_expenses"
          L9_3 = L9_3(L8_3)
          L8_3 = L7_3
          L9_3 = L9_3.format
          L9_3 = Utils
          L9_3 = L9_3.Framework
          L9_3 = L9_3.getPlayerName
          L10_3 = L1_3
          L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L9_3(L10_3)
          L9_3 = L9_3(L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L8_3 = L2_3
          L4_3(L5_3, L6_3, L9_3, L8_3)
          L4_3 = Utils
          L4_3 = L4_3.Webhook
          L4_3 = L4_3.sendWebhookMessage
          L5_3 = WebhookURL
          L6_3 = Utils
          L6_3 = L6_3.translate
          L9_3 = "logs_comission"
          L6_3 = L6_3(L7_3)
          L9_3 = L6_3
          L6_3 = L6_3.format
          L8_3 = A0_2
          L9_3 = L2_3
          L10_3 = Utils
          L10_3 = L10_3.Framework
          L10_3 = L10_3.getPlayerIdLog
          L11_3 = L3_3
          L10_3 = L10_3(L11_3)
          L11_3 = Utils
          L11_3 = L11_3.Framework
          L11_3 = L11_3.getPlayerIdLog
          L12_3 = L3_2
          L11_3 = L11_3(L12_3)
          L12_3 = os
          L12_3 = L12_3.date
          L13_3 = [[[]]
          L14_3 = Utils
          L14_3 = L14_3.translate
          L15_3 = "logs_date"
          L14_3 = L14_3(L15_3)
          L15_3 = "]: %d/%m/%Y ["
          L16_3 = Utils
          L16_3 = L16_3.translate
          L17_3 = "logs_hour"
          L16_3 = L16_3(L17_3)
          L17_3 = "]: %H:%M:%S"
          L13_3 = L13_3 .. L14_3 .. L15_3 .. L16_3 .. L17_3
          L12_3 = L12_3(L13_3)
          L11_3 = L11_3 .. L12_3
          L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L6_3(L9_3, L8_3, L9_3, L10_3, L11_3)
          L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
          L4_3 = openUI
          L5_3 = L3_2
          L6_3 = A0_2
          L9_3 = true
          L4_3(L5_3, L6_3, L9_3)
        else
          L4_3 = TriggerClientEvent
          L5_3 = "stores:Notify"
          L6_3 = L3_2
          L9_3 = "error"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L9_3 = "insufficient_funds"
          L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L8_3(L9_3)
          L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
        end
      else
        L4_3 = TriggerClientEvent
        L5_3 = "stores:Notify"
        L6_3 = L3_2
        L9_3 = "error"
        L8_3 = Utils
        L8_3 = L8_3.translate
        L9_3 = "cant_find_user"
        L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L8_3(L9_3)
        L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
      end
    else
      L3_3 = TriggerClientEvent
      L4_3 = "stores:Notify"
      L5_3 = L3_2
      L6_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "invalid_value"
      L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3 = L9_3(L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:buyCategory"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:buyCategory"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3
    L1_3 = "SELECT COUNT(*) as category_count FROM store_categories WHERE market_id = @market_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    L3_3 = L2_3.category_count
    L4_3 = getConfigMarketType
    L5_3 = A0_2
    L4_3 = L4_3(L5_3)
    L4_3 = L4_3.max_purchasable_categories
    if L3_3 >= L4_3 then
      L3_3 = TriggerClientEvent
      L4_3 = "stores:Notify"
      L5_3 = L3_2
      L6_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "category_max_amount"
      L9_3, L8_3, L9_3, L10_3 = L9_3(L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3)
      return
    end
    L3_3 = getMarketCategory
    L4_3 = A2_2.category
    L3_3 = L3_3(L4_3)
    L4_3 = tryGetMarketMoney
    L5_3 = A0_2
    L6_3 = L3_3.category_buy_price
    L4_3 = L4_3(L5_3, L6_3)
    if not L4_3 then
      L4_3 = TriggerClientEvent
      L5_3 = "stores:Notify"
      L6_3 = L3_2
      L9_3 = "error"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L9_3 = "insufficient_funds"
      L8_3, L9_3, L10_3 = L8_3(L9_3)
      L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3)
      return
    end
    L4_3 = "INSERT INTO store_categories (market_id, category) VALUES (@market_id,@category)"
    L5_3 = Utils
    L5_3 = L5_3.Database
    L5_3 = L5_3.execute
    L6_3 = L4_3
    L9_3 = {}
    L8_3 = A0_2
    L9_3["@market_id"] = L8_3
    L8_3 = A2_2.category
    L9_3["@category"] = L8_3
    L5_3(L6_3, L9_3)
    L5_3 = TriggerClientEvent
    L6_3 = "stores:Notify"
    L9_3 = L3_2
    L8_3 = "success"
    L9_3 = Utils
    L9_3 = L9_3.translate
    L10_3 = "category_bought"
    L9_3, L10_3 = L9_3(L10_3)
    L5_3(L6_3, L9_3, L8_3, L9_3, L10_3)
    L5_3 = insertBalanceHistory
    L6_3 = A0_2
    L9_3 = 1
    L8_3 = Utils
    L8_3 = L8_3.translate
    L9_3 = "category_bought_balance"
    L8_3 = L8_3(L9_3)
    L9_3 = L8_3
    L8_3 = L8_3.format
    L10_3 = L3_3.page_name
    L8_3 = L8_3(L9_3, L10_3)
    L9_3 = L3_3.category_buy_price
    L5_3(L6_3, L9_3, L8_3, L9_3)
    L5_3 = openUI
    L6_3 = L3_2
    L9_3 = A0_2
    L8_3 = true
    L5_3(L6_3, L9_3, L8_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:sellCategory"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:sellCategory"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3
    L1_3 = getMarketCategory
    L2_3 = A2_2.category
    L1_3 = L1_3(L2_3)
    L2_3 = L1_3.category_sell_price
    L3_3 = "SELECT id FROM store_categories WHERE market_id = @market_id AND category = @category"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.fetchAll
    L5_3 = L3_3
    L6_3 = {}
    L9_3 = A0_2
    L6_3["@market_id"] = L9_3
    L9_3 = A2_2.category
    L6_3["@category"] = L9_3
    L4_3 = L4_3(L5_3, L6_3)
    L5_3 = #L4_3
    if 0 == L5_3 then
      L5_3 = TriggerClientEvent
      L6_3 = "stores:Notify"
      L9_3 = L3_2
      L8_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L10_3 = "category_not_found"
      L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3 = L9_3(L10_3)
      L5_3(L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3)
      return
    end
    L5_3 = "SELECT COUNT(*) as category_count FROM store_categories WHERE market_id = @market_id"
    L6_3 = Utils
    L6_3 = L6_3.Database
    L6_3 = L6_3.fetchAll
    L9_3 = L5_3
    L8_3 = {}
    L9_3 = A0_2
    L8_3["@market_id"] = L9_3
    L6_3 = L6_3(L7_3, L8_3)
    L6_3 = L6_3[1]
    L9_3 = L6_3.category_count
    if 1 == L9_3 then
      L9_3 = TriggerClientEvent
      L8_3 = "stores:Notify"
      L9_3 = L3_2
      L10_3 = "error"
      L11_3 = Utils
      L11_3 = L11_3.translate
      L12_3 = "cannot_sell_last_category"
      L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3 = L11_3(L12_3)
      L9_3(L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3)
      return
    end
    L9_3 = "SELECT * FROM `store_jobs` WHERE market_id = @market_id"
    L8_3 = Utils
    L8_3 = L8_3.Database
    L8_3 = L8_3.fetchAll
    L9_3 = L7_3
    L10_3 = {}
    L11_3 = A0_2
    L10_3["@market_id"] = L11_3
    L8_3 = L8_3(L9_3, L10_3)
    L9_3 = pairs
    L10_3 = L8_3
    L9_3, L10_3, L11_3, L12_3 = L9_3(L10_3)
    for L13_3, L14_3 in L9_3, L10_3, L11_3, L12_3 do
      L15_3 = L1_3.items
      L16_3 = L14_3.product
      L15_3 = L15_3[L16_3]
      if L15_3 then
        L15_3 = deleteJob
        L16_3 = A0_2
        L17_3 = L14_3.id
        L15_3 = L15_3(L16_3, L17_3)
        if not L15_3 then
          L15_3 = TriggerClientEvent
          L16_3 = "stores:Notify"
          L17_3 = L3_2
          L18_3 = "error"
          L19_3 = Utils
          L19_3 = L19_3.translate
          L20_3 = "cant_delete_category"
          L19_3, L20_3 = L19_3(L20_3)
          L15_3(L16_3, L17_3, L18_3, L19_3, L20_3)
          return
        end
      end
    end
    L9_3 = "SELECT stock, stock_prices FROM `store_business` WHERE market_id = @market_id"
    L10_3 = Utils
    L10_3 = L10_3.Database
    L10_3 = L10_3.fetchAll
    L11_3 = L9_3
    L12_3 = {}
    L13_3 = A0_2
    L12_3["@market_id"] = L13_3
    L10_3 = L10_3(L11_3, L12_3)
    L11_3 = json
    L11_3 = L11_3.decode
    L12_3 = L10_3[1]
    L12_3 = L12_3.stock
    L11_3 = L11_3(L12_3)
    L12_3 = json
    L12_3 = L12_3.decode
    L13_3 = L10_3[1]
    L13_3 = L13_3.stock_prices
    L12_3 = L12_3(L13_3)
    L13_3 = pairs
    L14_3 = L1_3.items
    L13_3, L14_3, L15_3, L16_3 = L13_3(L14_3)
    for L17_3, L18_3 in L13_3, L14_3, L15_3, L16_3 do
      L11_3[L17_3] = nil
      L12_3[L17_3] = nil
    end
    L13_3 = "UPDATE `store_business` SET stock = @stock, stock_prices = @stock_prices WHERE market_id = @market_id"
    L14_3 = Utils
    L14_3 = L14_3.Database
    L14_3 = L14_3.execute
    L15_3 = L13_3
    L16_3 = {}
    L17_3 = A0_2
    L16_3["@market_id"] = L17_3
    L17_3 = json
    L17_3 = L17_3.encode
    L18_3 = L11_3
    L17_3 = L17_3(L18_3)
    L16_3["@stock"] = L17_3
    L17_3 = json
    L17_3 = L17_3.encode
    L18_3 = L12_3
    L17_3 = L17_3(L18_3)
    L16_3["@stock_prices"] = L17_3
    L14_3(L15_3, L16_3)
    L14_3 = "DELETE FROM store_categories WHERE market_id = @market_id AND category = @category"
    L15_3 = Utils
    L15_3 = L15_3.Database
    L15_3 = L15_3.execute
    L16_3 = L14_3
    L17_3 = {}
    L18_3 = A0_2
    L17_3["@market_id"] = L18_3
    L18_3 = A2_2.category
    L17_3["@category"] = L18_3
    L15_3(L16_3, L17_3)
    L15_3 = giveMarketMoney
    L16_3 = A0_2
    L17_3 = L2_3
    L15_3(L16_3, L17_3)
    L15_3 = insertBalanceHistory
    L16_3 = A0_2
    L17_3 = 0
    L18_3 = Utils
    L18_3 = L18_3.translate
    L19_3 = "category_sold_balance"
    L18_3 = L18_3(L19_3)
    L19_3 = L18_3
    L18_3 = L18_3.format
    L20_3 = L1_3.page_name
    L18_3 = L18_3(L19_3, L20_3)
    L19_3 = L2_3
    L15_3(L16_3, L17_3, L18_3, L19_3)
    L15_3 = TriggerClientEvent
    L16_3 = "stores:Notify"
    L17_3 = L3_2
    L18_3 = "success"
    L19_3 = Utils
    L19_3 = L19_3.translate
    L20_3 = "category_sold"
    L19_3, L20_3 = L19_3(L20_3)
    L15_3(L16_3, L17_3, L18_3, L19_3, L20_3)
    L15_3 = openUI
    L16_3 = L3_2
    L17_3 = A0_2
    L18_3 = true
    L15_3(L16_3, L17_3, L18_3)
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:changeTheme"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:changeTheme"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = L4_1
  L4_2[L3_2] = nil
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = false
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3
    L1_3 = "SELECT * FROM `store_users_theme` WHERE user_id = @user_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L4_3["@user_id"] = A0_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if nil == L2_3 then
      L3_3 = "INSERT INTO `store_users_theme` (user_id,dark_theme) VALUES (@user_id,@dark_theme);"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L6_3 = {}
      L9_3 = A2_2.dark_theme
      L6_3["@dark_theme"] = L9_3
      L6_3["@user_id"] = A0_3
      L4_3(L5_3, L6_3)
    else
      L3_3 = "UPDATE `store_users_theme` SET dark_theme = @dark_theme WHERE user_id = @user_id"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L6_3 = {}
      L9_3 = A2_2.dark_theme
      L6_3["@dark_theme"] = L9_3
      L6_3["@user_id"] = A0_3
      L4_3(L5_3, L6_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
deleteJob = RegisterServerEvent
getConfigMarketLocation = "stores:sellMarket"
deleteJob(getConfigMarketLocation)
deleteJob = AddEventHandler
getConfigMarketLocation = "stores:sellMarket"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = source
  L4_2 = Wrapper
  L5_2 = L3_2
  L6_2 = A0_2
  L7_2 = A1_2
  L8_2 = true
  function L9_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3
    L1_3 = "SELECT user_id FROM `store_business` WHERE market_id = @market_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A0_2
    L4_3["@market_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    L3_3 = L2_3.user_id
    if L3_3 == A0_3 then
      L3_3 = TriggerClientEvent
      L4_3 = "stores:closeUI"
      L5_3 = L3_2
      L3_3(L4_3, L5_3)
      L3_3 = deleteStore
      L4_3 = A0_2
      L3_3(L4_3)
      L3_3 = Utils
      L3_3 = L3_3.Framework
      L3_3 = L3_3.giveAccountMoney
      L4_3 = L3_2
      L5_3 = getConfigMarketLocation
      L6_3 = A0_2
      L5_3 = L5_3(L6_3)
      L5_3 = L5_3.sell_price
      L6_3 = getAccount
      L9_3 = A0_2
      L8_3 = "store"
      L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L6_3(L9_3, L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
      L3_3 = TriggerClientEvent
      L4_3 = "stores:Notify"
      L5_3 = L3_2
      L6_3 = "success"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "store_sold"
      L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L9_3(L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
      L3_3 = getConfigMarketType
      L4_3 = A0_2
      L3_3 = L3_3(L4_3)
      L3_3 = L3_3.blips
      L4_3 = TriggerClientEvent
      L5_3 = "stores:updateBlip"
      L6_3 = -1
      L9_3 = A0_2
      L8_3 = L3_3.name
      L9_3 = L3_3.color
      L10_3 = L3_3.id
      L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3)
      L4_3 = Utils
      L4_3 = L4_3.Webhook
      L4_3 = L4_3.sendWebhookMessage
      L5_3 = WebhookURL
      L6_3 = Utils
      L6_3 = L6_3.translate
      L9_3 = "logs_close"
      L6_3 = L6_3(L7_3)
      L9_3 = L6_3
      L6_3 = L6_3.format
      L8_3 = A0_2
      L9_3 = Utils
      L9_3 = L9_3.Framework
      L9_3 = L9_3.getPlayerIdLog
      L10_3 = L3_2
      L9_3 = L9_3(L10_3)
      L10_3 = os
      L10_3 = L10_3.date
      L11_3 = [[

[]]
      L12_3 = Utils
      L12_3 = L12_3.translate
      L13_3 = "logs_date"
      L12_3 = L12_3(L13_3)
      L13_3 = "]: %d/%m/%Y ["
      L14_3 = Utils
      L14_3 = L14_3.translate
      L15_3 = "logs_hour"
      L14_3 = L14_3(L15_3)
      L15_3 = "]: %H:%M:%S"
      L11_3 = L11_3 .. L12_3 .. L13_3 .. L14_3 .. L15_3
      L10_3 = L10_3(L11_3)
      L9_3 = L9_3 .. L10_3
      L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L6_3(L9_3, L8_3, L9_3)
      L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
    else
      L3_3 = TriggerClientEvent
      L4_3 = "stores:Notify"
      L5_3 = L3_2
      L6_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L8_3 = "sell_error"
      L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3 = L9_3(L8_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3)
    end
  end
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2)
end
deleteJob(getConfigMarketLocation, fn_L9_1)
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L3_2 = Config
  L3_2 = L3_2.trucker_logistics
  L3_2 = L3_2.enable
  if L3_2 then
    L3_2 = "SELECT * FROM `store_jobs` WHERE market_id = @market_id"
    L2_2 = Utils
    L2_2 = L2_2.Database
    L2_2 = L2_2.fetchAll
    L3_2 = L1_2
    L4_2 = {}
    L4_2["@market_id"] = A0_2
    L2_2 = L2_2(L3_2, L4_2)
    L3_2 = pairs
    L4_2 = L2_2
    L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
    for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
      L9_2 = deleteJob
      L10_2 = A0_2
      L11_2 = L8_2.id
      L9_2(L10_2, L11_2)
    end
  end
  L3_2 = "DELETE FROM `store_business` WHERE market_id = @market_id;"
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.execute
  L3_2 = L1_2
  L4_2 = {}
  L4_2["@market_id"] = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = "DELETE FROM `store_balance` WHERE market_id = @market_id;"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.execute
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@market_id"] = A0_2
  L3_2(L4_2, L5_2)
  L3_2 = "DELETE FROM `store_jobs` WHERE market_id = @market_id;"
  L4_2 = Utils
  L4_2 = L4_2.Database
  L4_2 = L4_2.execute
  L5_2 = L3_2
  L6_2 = {}
  L6_2["@market_id"] = A0_2
  L4_2(L5_2, L6_2)
  L4_2 = "DELETE FROM `store_employees` WHERE market_id = @market_id;"
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.execute
  L6_2 = L4_2
  L7_2 = {}
  L7_2["@market_id"] = A0_2
  L5_2(L6_2, L7_2)
  L5_2 = "DELETE FROM `store_categories` WHERE market_id = @market_id;"
  L6_2 = Utils
  L6_2 = L6_2.Database
  L6_2 = L6_2.execute
  L7_2 = L5_2
  L8_2 = {}
  L8_2["@market_id"] = A0_2
  L6_2(L7_2, L8_2)
end
deleteStore = deleteJob
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L3_2 = {}
  L2_2 = pairs
  L3_2 = getConfigMarketType
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L3_2 = L3_2.default_categories
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = pairs
    L9_2 = Config
    L9_2 = L9_2.market_categories
    L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
    for L12_2, L13_2 in L8_2, L9_2, L10_2, L11_2 do
      if L12_2 == L7_2 then
        L3_2[L12_2] = L13_2
      end
    end
  end
  return L3_2
end
getDefaultCategories = deleteJob
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L3_2 = {}
  L2_2 = pairs
  L3_2 = getConfigMarketType
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L3_2 = L3_2.default_categories
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = pairs
    L9_2 = getMarketCategory
    L10_2 = L7_2
    L9_2 = L9_2(L10_2)
    L9_2 = L9_2.items
    L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
    for L12_2, L13_2 in L8_2, L9_2, L10_2, L11_2 do
      L3_2[L12_2] = L13_2
    end
  end
  return L3_2
end
getDefaultItems = deleteJob
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L3_2 = 0
  L2_2 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.fetchAll
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@market_id"] = A0_2
  L3_2 = L3_2(L4_2, L5_2)
  if L3_2 then
    L4_2 = L3_2[1]
    if L4_2 then
      L4_2 = pairs
      L5_2 = L3_2
      L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
      for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
        L10_2 = Utils
        L10_2 = L10_2.Table
        L10_2 = L10_2.tableLength
        L11_2 = getMarketCategory
        L12_2 = L9_2.category
        L11_2 = L11_2(L12_2)
        L11_2 = L11_2.items
        L10_2 = L10_2(L11_2)
        L3_2 = L3_2 + L10_2
      end
    end
  end
  return L3_2
end
getItemsCount = deleteJob
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L3_2 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.fetchAll
  L3_2 = L1_2
  L4_2 = {}
  L4_2["@market_id"] = A0_2
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = {}
  if L2_2 then
    L4_2 = L2_2[1]
    if L4_2 then
      L4_2 = ipairs
      L5_2 = L2_2
      L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
      for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
        L10_2 = getMarketCategory
        L11_2 = L9_2.category
        L10_2 = L10_2(L11_2)
        L10_2 = L10_2.items
        L11_2 = pairs
        L12_2 = L10_2
        L11_2, L12_2, L13_2, L14_2 = L11_2(L12_2)
        for L15_2, L16_2 in L11_2, L12_2, L13_2, L14_2 do
          L3_2[L15_2] = L16_2
        end
      end
    end
  end
  return L3_2
end
getItems = deleteJob
function deleteJob(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.fetchAll
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@market_id"] = A0_2
  L3_2 = L3_2(L4_2, L5_2)
  if L3_2 then
    L4_2 = L3_2[1]
    if L4_2 then
      L4_2 = ipairs
      L5_2 = L3_2
      L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
      for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
        L10_2 = getMarketCategory
        L11_2 = L9_2.category
        L10_2 = L10_2(L11_2)
        L10_2 = L10_2.items
        L11_2 = L10_2[A1_2]
        if L11_2 then
          L11_2 = L10_2[A1_2]
          return L11_2
        end
      end
    end
  end
  L4_2 = error
  L5_2 = "Item %s not found in the store %s category config"
  L6_2 = L5_2
  L5_2 = L5_2.format
  L7_2 = A1_2
  L8_2 = A0_2
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L5_2(L6_2, L7_2, L8_2)
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
end
getItem = deleteJob
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = pairs
  L2_2 = Config
  L2_2 = L2_2.market_categories
  L3_2, L2_2, L3_2, L4_2 = L3_2(L2_2)
  for L5_2, L6_2 in L3_2, L2_2, L3_2, L4_2 do
    L7_2 = L6_2.items
    L7_2 = L7_2[A0_2]
    if L7_2 then
      L7_2 = L6_2.items
      L7_2 = L7_2[A0_2]
      return L7_2
    end
  end
  L3_2 = error
  L2_2 = "Item %s not found in config"
  L3_2 = L2_2
  L2_2 = L2_2.format
  L4_2 = A0_2
  L2_2, L3_2, L4_2, L5_2, L6_2, L7_2 = L2_2(L3_2, L4_2)
  L3_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2)
end
getItemNoKey = deleteJob
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L3_2 = ""
  L2_2 = pairs
  L3_2 = A0_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = tonumber
    L9_2 = L7_2.amount
    L8_2 = L8_2(L9_2)
    if not L8_2 then
      L8_2 = 0
    end
    L9_2 = L7_2.name
    L10_2 = L1_2
    L11_2 = L8_2
    L12_2 = "x "
    L13_2 = L9_2
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2
    L3_2 = L10_2
    L10_2 = #A0_2
    if L6_2 < L10_2 then
      L10_2 = L1_2
      L11_2 = ", "
      L10_2 = L10_2 .. L11_2
      L3_2 = L10_2
    end
  end
  return L3_2
end
formatItemAmounts = deleteJob
function deleteJob(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = "SELECT 1 FROM `store_business` WHERE market_id = @market_id AND user_id = @user_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.fetchAll
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@market_id"] = A0_2
  L5_2["@user_id"] = A1_2
  L3_2 = L3_2(L4_2, L5_2)
  if L3_2 then
    L4_2 = L3_2[1]
    if L4_2 then
      L4_2 = true
      return L4_2
  end
  else
    L4_2 = false
    return L4_2
  end
end
isOwner = deleteJob
function deleteJob(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = Config
  L3_2 = L3_2.roles_permissions
  L3_2 = L3_2.functions
  L3_2 = L3_2[A2_2]
  if not L3_2 then
    L4_2 = print
    L5_2 = "^8["
    L6_2 = GetCurrentResourceName
    L6_2 = L6_2()
    L7_2 = "] Role '"
    L8_2 = A2_2
    L9_2 = "' not found in Config.roles_permissions^7"
    L5_2 = L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2
    L4_2(L5_2)
    L4_2 = false
    return L4_2
  end
  L4_2 = "SELECT 1 FROM `store_employees` WHERE market_id = @market_id AND user_id = @user_id AND role >= @role"
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.fetchAll
  L6_2 = L4_2
  L7_2 = {}
  L7_2["@market_id"] = A0_2
  L7_2["@user_id"] = A1_2
  L7_2["@role"] = L3_2
  L5_2 = L5_2(L6_2, L7_2)
  if L5_2 then
    L6_2 = L5_2[1]
    if L6_2 then
      L6_2 = true
      return L6_2
  end
  else
    L6_2 = false
    return L6_2
  end
end
hasRole = deleteJob
function deleteJob(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = "UPDATE `store_business` SET money = money + @amount WHERE market_id = @market_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.execute
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@amount"] = A1_2
  L5_2["@market_id"] = A0_2
  L3_2(L4_2, L5_2)
end
giveMarketMoney = deleteJob
function deleteJob(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L2_2 = "SELECT money FROM `store_business` WHERE market_id = @market_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.fetchAll
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@market_id"] = A0_2
  L3_2 = L3_2(L4_2, L5_2)
  L3_2 = L3_2[1]
  L4_2 = tonumber
  L5_2 = L3_2.money
  L4_2 = L4_2(L5_2)
  if A1_2 <= L4_2 then
    L4_2 = "UPDATE `store_business` SET money = @money, total_money_spent = total_money_spent + @amount WHERE market_id = @market_id"
    L5_2 = Utils
    L5_2 = L5_2.Database
    L5_2 = L5_2.execute
    L6_2 = L4_2
    L7_2 = {}
    L8_2 = tonumber
    L9_2 = L3_2.money
    L8_2 = L8_2(L9_2)
    L8_2 = L8_2 - A1_2
    L7_2["@money"] = L8_2
    L7_2["@amount"] = A1_2
    L7_2["@market_id"] = A0_2
    L5_2(L6_2, L7_2)
    L5_2 = true
    return L5_2
  else
    L4_2 = false
    return L4_2
  end
end
tryGetMarketMoney = deleteJob
function deleteJob(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = json
  L3_2 = L3_2.decode
  L2_2 = A0_2
  L3_2 = L3_2(L2_2)
  L2_2 = 0
  L3_2 = pairs
  L4_2 = L1_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L2_2 = L2_2 + L8_2
  end
  return L2_2
end
getStockAmount = deleteJob
function deleteJob(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2
  L4_2 = #A2_2
  L5_2 = 200
  if L4_2 > L5_2 then
    L4_2 = string
    L4_2 = L4_2.sub
    L5_2 = A2_2
    L6_2 = 1
    L7_2 = 200
    L4_2 = L4_2(L5_2, L6_2, L7_2)
    A2_2 = L4_2
  end
  L4_2 = "INSERT INTO `store_balance` (market_id,income,title,amount,date) VALUES (@market_id,@income,@title,@amount,@date)"
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.executeAsync
  L6_2 = L4_2
  L7_2 = {}
  L7_2["@market_id"] = A0_2
  L7_2["@income"] = A1_2
  L7_2["@title"] = A2_2
  L7_2["@amount"] = A3_2
  L8_2 = os
  L8_2 = L8_2.time
  L8_2 = L8_2()
  L7_2["@date"] = L8_2
  L5_2(L6_2, L7_2)
end
insertBalanceHistory = deleteJob
function deleteJob(A0_2, A1_2)
local L2_2, L3_2
  L2_2 = getConfigMarketLocation
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if "item" == A1_2 then
    L3_2 = L2_2.account
    if L3_2 then
      L3_2 = L2_2.account
      L3_2 = L3_2.item
      return L3_2
    else
      L3_2 = "bank"
      return L3_2
    end
  elseif "store" == A1_2 then
    L3_2 = L2_2.account
    if L3_2 then
      L3_2 = L2_2.account
      L3_2 = L3_2.store
      return L3_2
    else
      L3_2 = "bank"
      return L3_2
    end
  end
end
getAccount = deleteJob
deleteJob = {}
getConfigMarketLocation = {}
deleteJob.market_locations = getConfigMarketLocation
getConfigMarketLocation = {}
deleteJob.market_categories = getConfigMarketLocation
getConfigMarketLocation = {}
deleteJob.market_types = getConfigMarketLocation
function getConfigMarketLocation(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L3_2 = L7_1.market_locations
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = Config
    L3_2 = L3_2.market_locations
    L3_2 = L3_2[A0_2]
    return L3_2
  end
  L3_2 = assert
  L2_2 = Config
  L2_2 = L2_2.market_locations
  L3_2 = "^3The config '^1Config.market_locations^3' entry is missing. Please re-add it in the config"
  L3_2(L2_2, L3_2)
  L3_2 = assert
  L2_2 = A0_2
  L3_2 = "^3The parameter '^1market_id^3' is missing. Please provide a valid market ID"
  L3_2(L2_2, L3_2)
  L3_2 = assert
  L2_2 = Config
  L2_2 = L2_2.market_locations
  L2_2 = L2_2[A0_2]
  L3_2 = "^3The market ID '^1"
  L4_2 = tostring
  L5_2 = A0_2
  L4_2 = L4_2(L5_2)
  L5_2 = "^3' does not exist in ^1Config.market_locations^3. Please provide a valid market ID"
  L3_2 = L3_2 .. L4_2 .. L5_2
  L3_2(L2_2, L3_2)
  L3_2 = Config
  L3_2 = L3_2.market_locations
  L3_2 = L3_2[A0_2]
  L2_2 = assert
  L3_2 = L1_2.buy_price
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1buy_price^3' field. Please ensure each market location has a '^1buy_price^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.sell_price
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1sell_price^3' field. Please ensure each market location has a '^1sell_price^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.coord
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1coord^3' field. Please ensure each market location has a '^1coord^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.coord
  L3_2 = #L3_2
  L3_2 = 3 == L3_2
  L4_2 = "^3The '^1coord^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must contain three values (x, y, z). Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.garage_coord
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1garage_coord^3' field. Please ensure each market location has a '^1garage_coord^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.garage_coord
  L3_2 = #L3_2
  L3_2 = 4 == L3_2
  L4_2 = "^3The '^1garage_coord^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must contain four values (x, y, z, heading). Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.truck_parking_location
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1truck_parking_location^3' field. Please ensure each market location has a '^1truck_parking_location^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.truck_parking_location
  L3_2 = #L3_2
  L3_2 = 4 == L3_2
  L4_2 = "^3The '^1truck_parking_location^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must contain four values (x, y, z, heading). Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.map_blip_coord
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1map_blip_coord^3' field. Please ensure each market location has a '^1map_blip_coord^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.map_blip_coord
  L3_2 = #L3_2
  L3_2 = 3 == L3_2
  L4_2 = "^3The '^1map_blip_coord^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must contain three values (x, y, z). Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.sell_blip_coords
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1sell_blip_coords^3' field. Please ensure each market location has a '^1sell_blip_coords^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = type
  L4_2 = L1_2.sell_blip_coords
  L3_2 = L3_2(L4_2)
  L3_2 = "table" == L3_2
  L4_2 = "^3The '^1sell_blip_coords^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must be a table. Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = ipairs
  L3_2 = L1_2.sell_blip_coords
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = assert
    L9_2 = #L7_2
    L9_2 = 3 == L9_2
    L10_2 = "^3Each coordinate in '^1sell_blip_coords^3' for market location ID '^1"
    L11_2 = tostring
    L12_2 = A0_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' must contain three values (x, y, z). Review your config file to correct it"
    L10_2 = L10_2 .. L11_2 .. L12_2
    L8_2(L9_2, L10_2)
  end
  L2_2 = assert
  L3_2 = L1_2.deliveryman_coord
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1deliveryman_coord^3' field. Please ensure each market location has a '^1deliveryman_coord^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.deliveryman_coord
  L3_2 = #L3_2
  L3_2 = 3 == L3_2
  L4_2 = "^3The '^1deliveryman_coord^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must contain three values (x, y, z). Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.type
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1type^3' field. Please ensure each market location has a '^1type^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.account
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have an '^1account^3' field. Please ensure each market location has an '^1account^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.account
  L3_2 = L3_2.item
  L4_2 = "^3The '^1account^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have an '^1item^3' field. Please ensure each account field has an '^1item^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = type
  L4_2 = L1_2.account
  L4_2 = L4_2.item
  L3_2 = L3_2(L4_2)
  L3_2 = "table" == L3_2
  L4_2 = "^3The '^1item^3' field in '^1account^3' for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must be a table. Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = ipairs
  L3_2 = L1_2.account
  L3_2 = L3_2.item
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = assert
    L9_2 = L7_2.icon
    L10_2 = "^3Each '^1item^3' in '^1account^3' for market location ID '^1"
    L11_2 = tostring
    L12_2 = A0_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' must have an '^1icon^3' field. Review your config file to correct it"
    L10_2 = L10_2 .. L11_2 .. L12_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.account
    L10_2 = "^3Each '^1item^3' in '^1account^3' for market location ID '^1"
    L11_2 = tostring
    L12_2 = A0_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' must have an '^1account^3' field. Review your config file to correct it"
    L10_2 = L10_2 .. L11_2 .. L12_2
    L8_2(L9_2, L10_2)
  end
  L2_2 = assert
  L3_2 = L1_2.account
  L3_2 = L3_2.store
  L4_2 = "^3The '^1account^3' field for market location ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1store^3' field. Please ensure each account field has a '^1store^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = L7_1.market_locations
  L2_2[A0_2] = true
  return L3_2
end
getConfigMarketLocation = getConfigMarketLocation
function getConfigMarketLocation(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L3_2 = L7_1.market_categories
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = Config
    L3_2 = L3_2.market_categories
    L3_2 = L3_2[A0_2]
    return L3_2
  end
  L3_2 = assert
  L2_2 = Config
  L2_2 = L2_2.market_categories
  L3_2 = "^3The config '^1Config.market_categories^3' entry is missing. Please re-add it in the config"
  L3_2(L2_2, L3_2)
  L3_2 = assert
  L2_2 = A0_2
  L3_2 = "^3The parameter '^1category_id^3' is missing. Please provide a valid category ID"
  L3_2(L2_2, L3_2)
  L3_2 = assert
  L2_2 = Config
  L2_2 = L2_2.market_categories
  L2_2 = L2_2[A0_2]
  L3_2 = "^3The category ID '^1"
  L4_2 = tostring
  L5_2 = A0_2
  L4_2 = L4_2(L5_2)
  L5_2 = "^3' does not exist in ^1Config.market_categories^3. Please provide a valid category ID"
  L3_2 = L3_2 .. L4_2 .. L5_2
  L3_2(L2_2, L3_2)
  L3_2 = Config
  L3_2 = L3_2.market_categories
  L3_2 = L3_2[A0_2]
  L2_2 = assert
  L3_2 = L1_2.category_buy_price
  L4_2 = "^3The category ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not contain a valid '^1category_buy_price^3'. Review your config file to add it back"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.category_sell_price
  L4_2 = "^3The category ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not contain a valid '^1category_sell_price^3'. Review your config file to add it back"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = L1_2.items
  L4_2 = "^3The category ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not contain a valid '^1items^3' field. Review your config file to add it back"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = type
  L4_2 = L1_2.items
  L3_2 = L3_2(L4_2)
  L3_2 = "table" == L3_2
  L4_2 = "^3The '^1items^3' field for category ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' must be a table. Review your config file to correct it"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = pairs
  L3_2 = L1_2.items
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = assert
    L9_2 = L7_2.name
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have a '^1name^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.price_to_customer
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have a '^1price_to_customer^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.price_to_customer_min
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have a '^1price_to_customer_min^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.price_to_customer_max
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have a '^1price_to_customer_max^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.price_to_export
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have a '^1price_to_export^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.price_to_owner
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have a '^1price_to_owner^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.amount_to_owner
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have an '^1amount_to_owner^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
    L8_2 = assert
    L9_2 = L7_2.amount_to_delivery
    L10_2 = "^3The item ID '^1"
    L11_2 = tostring
    L12_2 = L6_2
    L11_2 = L11_2(L12_2)
    L12_2 = "^3' in category ID '^1"
    L13_2 = tostring
    L14_2 = A0_2
    L13_2 = L13_2(L14_2)
    L14_2 = "^3' does not have an '^1amount_to_delivery^3' field. Review your config file to add it back"
    L10_2 = L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2
    L8_2(L9_2, L10_2)
  end
  L2_2 = L7_1.market_categories
  L2_2[A0_2] = true
  return L3_2
end
getMarketCategory = getConfigMarketLocation
function getConfigMarketLocation(A0_2)
local L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L3_2 = L7_1.market_types
  L3_2 = L3_2[A0_2]
  if L3_2 then
    L3_2 = Config
    L3_2 = L3_2.market_types
    L2_2 = Config
    L2_2 = L2_2.market_locations
    L2_2 = L2_2[A0_2]
    L2_2 = L2_2.type
    L3_2 = L3_2[L2_2]
    return L3_2
  end
  L3_2 = assert
  L2_2 = Config
  L2_2 = L2_2.market_locations
  L3_2 = "^3The config '^1Config.market_locations^3' entry is missing. Please re-add it in the config"
  L3_2(L2_2, L3_2)
  L3_2 = assert
  L2_2 = Config
  L2_2 = L2_2.market_types
  L3_2 = "^3The config '^1Config.market_types^3' entry is missing. Please re-add it in the config"
  L3_2(L2_2, L3_2)
  L3_2 = assert
  L2_2 = A0_2
  L3_2 = "^3The parameter '^1market_id^3' is missing. Please provide a valid market ID"
  L3_2(L2_2, L3_2)
  L3_2 = assert
  L2_2 = Config
  L2_2 = L2_2.market_locations
  L2_2 = L2_2[A0_2]
  L3_2 = "^3The market ID '^1"
  L4_2 = tostring
  L5_2 = A0_2
  L4_2 = L4_2(L5_2)
  L5_2 = "^3' does not exist in ^1Config.market_locations^3. Please provide a valid market ID"
  L3_2 = L3_2 .. L4_2 .. L5_2
  L3_2(L2_2, L3_2)
  L3_2 = Config
  L3_2 = L3_2.market_locations
  L3_2 = L3_2[A0_2]
  L2_2 = assert
  L3_2 = L1_2.type
  L4_2 = "^3The market location for ID '^1"
  L5_2 = tostring
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  L6_2 = "^3' does not have a '^1type^3' field. Please ensure each market location has a '^1type^3' field"
  L4_2 = L4_2 .. L5_2 .. L6_2
  L2_2(L3_2, L4_2)
  L2_2 = Config
  L2_2 = L2_2.market_types
  L3_2 = L1_2.type
  L2_2 = L2_2[L3_2]
  L3_2 = assert
  L4_2 = L2_2
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not exist in ^1Config.market_types^3. Please provide a valid market type"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = L2_2.stock_capacity
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not have a '^1stock_capacity^3' field. Please ensure each market type has a '^1stock_capacity^3' field"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = L2_2.upgrades
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not have an '^1upgrades^3' field. Please ensure each market type has an '^1upgrades^3' field"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = type
  L5_2 = L2_2.upgrades
  L4_2 = L4_2(L5_2)
  L4_2 = "table" == L4_2
  L5_2 = "^3The '^1upgrades^3' field for market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' must be a table. Review your config file to correct it"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = L2_2.max_employees
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not have a '^1max_employees^3' field. Please ensure each market type has a '^1max_employees^3' field"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = L2_2.trucks
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not have a '^1trucks^3' field. Please ensure each market type has a '^1trucks^3' field"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = type
  L5_2 = L2_2.trucks
  L4_2 = L4_2(L5_2)
  L4_2 = "table" == L4_2
  L5_2 = "^3The '^1trucks^3' field for market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' must be a table. Review your config file to correct it"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = L2_2.max_purchasable_categories
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not have a '^1max_purchasable_categories^3' field. Please ensure each market type has a '^1max_purchasable_categories^3' field"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = L2_2.categories
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not have a '^1categories^3' field. Please ensure each market type has a '^1categories^3' field"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = type
  L5_2 = L2_2.categories
  L4_2 = L4_2(L5_2)
  L4_2 = "table" == L4_2
  L5_2 = "^3The '^1categories^3' field for market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' must be a table. Review your config file to correct it"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = L2_2.default_categories
  L5_2 = "^3The market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' does not have a '^1default_categories^3' field. Please ensure each market type has a '^1default_categories^3' field"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = assert
  L4_2 = type
  L5_2 = L2_2.default_categories
  L4_2 = L4_2(L5_2)
  L4_2 = "table" == L4_2
  L5_2 = "^3The '^1default_categories^3' field for market type '^1"
  L6_2 = tostring
  L7_2 = L1_2.type
  L6_2 = L6_2(L7_2)
  L7_2 = "^3' must be a table. Review your config file to correct it"
  L5_2 = L5_2 .. L6_2 .. L7_2
  L3_2(L4_2, L5_2)
  L3_2 = L7_1.market_types
  L3_2[A0_2] = true
  return L2_2
end
getConfigMarketType = getConfigMarketLocation
function getConfigMarketLocation(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L5_2 = L3_1
  if L5_2 then
    L5_2 = L1_1
    if not L5_2 then
      goto lbl_23
    end
  end
  L5_2 = L1_1
  if L5_2 then
    L5_2 = TriggerClientEvent
    L6_2 = "stores:Notify"
    L7_2 = A0_2
    L8_2 = "error"
    L9_2 = "The script requires 'lc_utils' in version "
    L10_2 = L0_1
    L11_2 = ", but you currently have version "
    L12_2 = Utils
    L12_2 = L12_2.Version
    L13_2 = ". Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip"
    L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2
    L5_2(L6_2, L7_2, L8_2, L9_2)
  end
  do return end
  ::lbl_23::
  L5_2 = assert
  L6_2 = A0_2
  L7_2 = "Source is nil at Wrapper"
  L5_2(L6_2, L7_2)
  L5_2 = assert
  L6_2 = A1_2
  L7_2 = "Key is nil at Wrapper"
  L5_2(L6_2, L7_2)
  L5_2 = assert
  L6_2 = A2_2
  L7_2 = "Event is nil at Wrapper"
  L5_2(L6_2, L7_2)
  L5_2 = L4_1
  L5_2 = L5_2[A0_2]
  if nil == L5_2 then
    L5_2 = L4_1
    L5_2[A0_2] = true
    L5_2 = Utils
    L5_2 = L5_2.Framework
    L5_2 = L5_2.getPlayerId
    L6_2 = A0_2
    L5_2 = L5_2(L6_2)
    if L5_2 then
      if false ~= A3_2 then
        L6_2 = isOwner
        L7_2 = A1_2
        L8_2 = L5_2
        L6_2 = L6_2(L7_2, L8_2)
        if not L6_2 then
          L6_2 = hasRole
          L7_2 = A1_2
          L8_2 = L5_2
          L9_2 = A2_2
          L6_2 = L6_2(L7_2, L8_2, L9_2)
          if not L6_2 then
            goto lbl_67
          end
        end
      end
      L6_2 = A4_2
      L7_2 = L5_2
      L6_2(L7_2)
      goto lbl_88
      ::lbl_67::
      L6_2 = TriggerClientEvent
      L7_2 = "stores:Notify"
      L8_2 = A0_2
      L9_2 = "error"
      L10_2 = Utils
      L10_2 = L10_2.translate
      L11_2 = "insufficient_permission"
      L10_2, L11_2, L12_2, L13_2 = L10_2(L11_2)
      L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
    else
      L6_2 = print
      L7_2 = "^8["
      L8_2 = GetCurrentResourceName
      L8_2 = L8_2()
      L9_2 = "] ^3User not found: ^1"
      L10_2 = A0_2 or L10_2
      if not A0_2 then
        L10_2 = "nil"
      end
      L11_2 = "^7"
      L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2
      L6_2(L7_2)
    end
    ::lbl_88::
    L6_2 = SetTimeout
    L7_2 = 100
    function L8_2()
local L0_3, L1_3
      L1_3 = A0_2
      L0_3 = L4_1
      L0_3[L1_3] = nil
    end
    L6_2(L7_2, L8_2)
  end
end
Wrapper = getConfigMarketLocation
function getConfigMarketLocation(A0_2, A1_2, A2_2, A3_2)
local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l23_2
  L4_2 = {}
  L5_2 = {}
  L4_2.config = L5_2
  L5_2 = Utils
  L5_2 = L5_2.Framework
  L5_2 = L5_2.getPlayerId
  L6_2 = A0_2
  L5_2 = L5_2(L6_2)
  if L5_2 then
    L6_2 = "SELECT * FROM `store_business` WHERE market_id = @market_id"
    L7_2 = Utils
    L7_2 = L7_2.Database
    L7_2 = L7_2.fetchAll
    L8_2 = L6_2
    L9_2 = {}
    L9_2["@market_id"] = A1_2
    L7_2 = L7_2(L8_2, L9_2)
    L7_2 = L7_2[1]
    L4_2.store_business = L7_2
    L7_2 = "SELECT * FROM `store_users_theme` WHERE user_id = @user_id"
    L8_2 = Utils
    L8_2 = L8_2.Database
    L8_2 = L8_2.fetchAll
    L9_2 = L7_2
    L10_2 = {}
    L10_2["@user_id"] = L5_2
    L8_2 = L8_2(L9_2, L10_2)
    L8_2 = L8_2[1]
    L4_2.store_users_theme = L8_2
    L8_2 = L4_2.store_users_theme
    if nil == L8_2 then
      L8_2 = "INSERT INTO `store_users_theme` (user_id,dark_theme) VALUES (@user_id,@dark_theme);"
      L9_2 = Utils
      L9_2 = L9_2.Database
      L9_2 = L9_2.execute
      L10_2 = L8_2
      L11_2 = {}
      L11_2["@dark_theme"] = 1
      L11_2["@user_id"] = L5_2
      L9_2(L10_2, L11_2)
      L9_2 = {}
      L9_2.dark_theme = 1
      L4_2.store_users_theme = L9_2
    end
    if A3_2 then
      L8_2 = L4_2.store_business
      if nil == L8_2 then
        L8_2 = {}
        L4_2.store_business = L8_2
        L8_2 = L4_2.store_business
        L9_2 = Config
        L9_2 = L9_2.has_stock_when_unowed
        L9_2 = not L9_2
        L8_2.stock = L9_2
        L8_2 = getDefaultItems
        L9_2 = A1_2
        L8_2 = L8_2(L9_2)
        L4_2.market_items = L8_2
        L8_2 = L4_2.config
        L9_2 = getDefaultCategories
        L10_2 = A1_2
        L9_2 = L9_2(L10_2)
        L8_2.market_categories = L9_2
        L8_2 = L4_2.store_business
        L8_2.stock_prices = false
        L8_2 = {}
        L4_2.store_categories = L8_2
        L8_2 = pairs
        L9_2 = getConfigMarketType
        L10_2 = A1_2
        L9_2 = L9_2(L10_2)
        L9_2 = L9_2.default_categories
        L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
        for L12_2, L13_2 in L8_2, L9_2, L10_2, L11_2 do
          L14_2 = table
          L14_2 = L14_2.insert
          L15_2 = L4_2.store_categories
          L16_2 = {}
          L16_2.category = L13_2
          L14_2(L15_2, L16_2)
        end
      else
        -- Owned store, market view: load categories and items from database
        L8_2 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
        L9_2 = Utils
        L9_2 = L9_2.Database
        L9_2 = L9_2.fetchAll
        L10_2 = L8_2
        L11_2 = {}
        L12_2 = L4_2.store_business
        L12_2 = L12_2.market_id
        L11_2["@market_id"] = L12_2
        L9_2 = L9_2(L10_2, L11_2)
        L4_2.store_categories = L9_2
        L8_2 = getItems
        L9_2 = A1_2
        L8_2 = L8_2(L9_2)
        L4_2.market_items = L8_2
      end
    else
      L8_2 = getItems
      L9_2 = A1_2
      L8_2 = L8_2(L9_2)
      L4_2.market_items = L8_2
      L8_2 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
      L9_2 = Utils
      L9_2 = L9_2.Database
      L9_2 = L9_2.fetchAll
      L10_2 = L8_2
      L11_2 = {}
      L12_2 = L4_2.store_business
      L12_2 = L12_2.market_id
      L11_2["@market_id"] = L12_2
      L9_2 = L9_2(L10_2, L11_2)
      L4_2.store_categories = L9_2
      L9_2 = Utils
      L9_2 = L9_2.Table
      L9_2 = L9_2.tableLength
      L10_2 = json
      L10_2 = L10_2.decode
      L11_2 = L4_2.store_business
      L11_2 = L11_2.stock
      L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l10_2 = L10_2(L11_2)
      L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
      L10_2 = getItemsCount
      L11_2 = A1_2
      L10_2 = L10_2(L11_2)
      if 0 == L10_2 then
        L11_2 = L4_2.store_business
        L11_2.stock_variety = 0
      else
        L11_2 = L4_2.store_business
        L12_2 = 100 * L9_2
        L12_2 = L12_2 / L10_2
        L11_2.stock_variety = L12_2
      end
    end
    if not A3_2 then
      L8_2 = "SELECT * FROM `store_jobs` WHERE market_id = @market_id"
      L9_2 = Utils
      L9_2 = L9_2.Database
      L9_2 = L9_2.fetchAll
      L10_2 = L8_2
      L11_2 = {}
      L12_2 = L4_2.store_business
      L12_2 = L12_2.market_id
      L11_2["@market_id"] = L12_2
      L9_2 = L9_2(L10_2, L11_2)
      L4_2.store_jobs = L9_2
      L9_2 = "SELECT * FROM `store_balance` WHERE market_id = @market_id ORDER BY id DESC LIMIT 50"
      L10_2 = Utils
      L10_2 = L10_2.Database
      L10_2 = L10_2.fetchAll
      L11_2 = L9_2
      L12_2 = {}
      L13_2 = L4_2.store_business
      L13_2 = L13_2.market_id
      L12_2["@market_id"] = L13_2
      L10_2 = L10_2(L11_2, L12_2)
      L4_2.store_balance = L10_2
      L10_2 = "SELECT * FROM `store_employees` WHERE market_id = @market_id ORDER BY timer DESC"
      L11_2 = Utils
      L11_2 = L11_2.Database
      L11_2 = L11_2.fetchAll
      L12_2 = L10_2
      L13_2 = {}
      L14_2 = L4_2.store_business
      L14_2 = L14_2.market_id
      L13_2["@market_id"] = L14_2
      L11_2 = L11_2(L12_2, L13_2)
      L4_2.store_employees = L11_2
      L11_2 = pairs
      L12_2 = L4_2.store_employees
      L11_2, L12_2, L13_2, L14_2 = L11_2(L12_2)
      for L15_2, L16_2 in L11_2, L12_2, L13_2, L14_2 do
        L17_2 = Utils
        L17_2 = L17_2.Framework
        L17_2 = L17_2.getPlayerName
        l16_2 = L16_2.user_id
        L17_2 = L17_2(L18_2)
        L16_2.name = L17_2
      end
      L11_2 = "SELECT * FROM `store_categories` WHERE market_id = @market_id"
      L12_2 = Utils
      L12_2 = L12_2.Database
      L12_2 = L12_2.fetchAll
      L13_2 = L11_2
      L14_2 = {}
      L15_2 = L4_2.store_business
      L15_2 = L15_2.market_id
      L14_2["@market_id"] = L15_2
      L12_2 = L12_2(L13_2, L14_2)
      L4_2.store_categories = L12_2
      L12_2 = getItems
      L13_2 = L4_2.store_business
      L13_2 = L13_2.market_id
      L12_2 = L12_2(L13_2)
      L4_2.market_items = L12_2
      L12_2 = "SELECT role FROM `store_employees` WHERE market_id = @market_id AND user_id = @user_id"
      L13_2 = Utils
      L13_2 = L13_2.Database
      L13_2 = L13_2.fetchAll
      L14_2 = L12_2
      L15_2 = {}
      L16_2 = L4_2.store_business
      L16_2 = L16_2.market_id
      L15_2["@market_id"] = L16_2
      L15_2["@user_id"] = L5_2
      L13_2 = L13_2(L14_2, L15_2)
      if L13_2 then
        L14_2 = L13_2[1]
        if L14_2 then
          L14_2 = isOwner
          L15_2 = A1_2
          L16_2 = L5_2
          L14_2 = L14_2(L15_2, L16_2)
          if L14_2 then
            L4_2.role = 4
          else
            L14_2 = L13_2[1]
            L14_2 = L14_2.role
            L4_2.role = L14_2
          end
      end
      else
        L4_2.role = 4
      end
      if not A2_2 then
        L14_2 = Utils
        L14_2 = L14_2.Framework
        L14_2 = L14_2.getOnlinePlayers
        L14_2 = L14_2()
        L4_2.players = L14_2
      end
      L14_2 = L4_2.store_business
      L15_2 = getStockAmount
      L16_2 = L4_2.store_business
      L16_2 = L16_2.stock
      L15_2 = L15_2(L16_2)
      L14_2.stock_amount = L15_2
    end
    L8_2 = Utils
    L8_2 = L8_2.Framework
    L8_2 = L8_2.getPlayerAccountMoney
    L9_2 = A0_2
    L10_2 = getAccount
    L11_2 = A1_2
    L12_2 = "store"
    L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l16_2 = L10_2(L11_2, L12_2)
    L8_2 = L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
    L4_2.available_money = L8_2
    L8_2 = L4_2.config
    L9_2 = Utils
    L9_2 = L9_2.Table
    L9_2 = L9_2.deepCopy
    L10_2 = getConfigMarketLocation
    L11_2 = A1_2
    L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l16_2 = L10_2(L11_2)
    L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
    L8_2.market_locations = L9_2
    L8_2 = L4_2.config
    L9_2 = Utils
    L9_2 = L9_2.Table
    L9_2 = L9_2.deepCopy
    L10_2 = getConfigMarketType
    L11_2 = A1_2
    L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l16_2 = L10_2(L11_2)
    L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
    L8_2.market_types = L9_2
    L8_2 = L4_2.config
    L9_2 = Utils
    L9_2 = L9_2.Table
    L9_2 = L9_2.deepCopy
    L10_2 = Config
    L10_2 = L10_2.market_categories
    L9_2 = L9_2(L10_2)
    L8_2.market_categories = L9_2
    L8_2 = L4_2.config
    L9_2 = Utils
    L9_2 = L9_2.Table
    L9_2 = L9_2.deepCopy
    L10_2 = Config
    L10_2 = L10_2.roles_permissions
    L10_2 = L10_2.ui_pages
    L9_2 = L9_2(L10_2)
    L8_2.roles_permissions = L9_2
    L8_2 = L4_2.config
    L9_2 = Utils
    L9_2 = L9_2.Table
    L9_2 = L9_2.deepCopy
    L10_2 = Config
    L10_2 = L10_2.disable_rename_business
    L9_2 = L9_2(L10_2)
    L8_2.disable_rename_business = L9_2
    L8_2 = L4_2.config
    L8_2.warning = 0
    if not A3_2 then
      L8_2 = Config
      L8_2 = L8_2.clear_stores
      L8_2 = L8_2.active
      if L8_2 then
        L8_2 = json
        L8_2 = L8_2.decode
        L9_2 = L4_2.store_business
        L9_2 = L9_2.stock
        L8_2 = L8_2(L9_2)
        L9_2 = Utils
        L9_2 = L9_2.Table
        L9_2 = L9_2.tableLength
        L10_2 = L8_2
        L9_2 = L9_2(L10_2)
        L10_2 = getItemsCount
        L11_2 = A1_2
        L10_2 = L10_2(L11_2)
        L11_2 = L4_2.store_business
        L11_2 = L11_2.stock_amount
        L12_2 = getConfigMarketType
        L13_2 = A1_2
        L12_2 = L12_2(L13_2)
        L12_2 = L12_2.stock_capacity
        L13_2 = Config
        L13_2 = L13_2.clear_stores
        L13_2 = L13_2.min_stock_amount
        L13_2 = L13_2 / 100
        L12_2 = L12_2 * L13_2
        if L11_2 < L12_2 then
          L11_2 = L4_2.config
          L11_2.warning = 1
        else
          L11_2 = Config
          L11_2 = L11_2.clear_stores
          L11_2 = L11_2.min_stock_variety
          L11_2 = L11_2 / 100
          L11_2 = L10_2 * L11_2
          if L9_2 < L11_2 then
            L11_2 = L4_2.config
            L11_2.warning = 2
          else
            L11_2 = "UPDATE `store_business` SET timer = @timer WHERE market_id = @market_id"
            L12_2 = Utils
            L12_2 = L12_2.Database
            L12_2 = L12_2.execute
            L13_2 = L11_2
            L14_2 = {}
            L15_2 = os
            L15_2 = L15_2.time
            L15_2 = L15_2()
            L14_2.timer = L15_2
            L14_2["@market_id"] = A1_2
            L12_2(L13_2, L14_2)
          end
        end
      end
    end
    -- Ensure role is numeric for client-side gating
    if L4_2 and type(L4_2.role) ~= "number" then
      L4_2.role = tonumber(L4_2.role) or 0
    end
    -- Debug logging for role and permissions when opening UI
local _rp = L4_2 and L4_2.config and L4_2.config.roles_permissions
local _rp_json = _rp and json.encode(_rp) or "nil"
    print("[lc_stores] openUI sending. role=", tostring(L4_2 and L4_2.role), "update=", tostring(A2_2), "isMarket=", tostring(A3_2), "ui_pages_permissions=", _rp_json)
    L8_2 = TriggerClientEvent
    L9_2 = "stores:open"
    L10_2 = A0_2
    L11_2 = L4_2
    L12_2 = A2_2
    L13_2 = A3_2 or L13_2
    if not A3_2 then
      L13_2 = false
    end
    L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
  end
end
openUI = getConfigMarketLocation
getConfigMarketLocation = Citizen
getConfigMarketLocation = getConfigMarketLocation.CreateThread
function fn_L9_1()
local L0_2, L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l23_2, L19_2, l14_2
  L0_2 = Wait
  L3_2 = 1000
  L0_2(L3_2)
  while true do
    L0_2 = L3_1
    if L0_2 then
      break
    end
    L0_2 = Wait
    L3_2 = 100
    L0_2(L3_2)
  end
  L0_2 = assert
  L3_2 = Config
  L3_2 = L3_2.market_locations
  L2_2 = "^3You have errors in your config file, consider fixing it or redownload the original config.^7"
  L0_2(L3_2, L2_2)
  L0_2 = assert
  L3_2 = GetResourceState
  L2_2 = "lc_utils"
  L3_2 = L3_2(L2_2)
  L3_2 = "started" == L3_2
  L2_2 = "^3The '^1lc_utils^3' file is missing. Please refer to the documentation for installation instructions: ^7https://docs.lixeirocharmoso.com/owned_stores/installation^7"
  L0_2(L3_2, L2_2)
  L0_2 = Utils
  L0_2 = L0_2.Math
  L0_2 = L0_2.checkIfCurrentVersionisOutdated
  L3_2 = L0_1
  L2_2 = Utils
  L2_2 = L2_2.Version
  L0_2 = L0_2(L1_2, L2_2)
  if L0_2 then
    L0_2 = true
    L5_2 = L0_2
    L0_2 = error
    L3_2 = "^3The script requires 'lc_utils' in version ^1"
    L2_2 = L0_1
    L3_2 = "^3, but you currently have version ^1"
    L4_2 = Utils
    L4_2 = L4_2.Version
    L5_2 = "^3. Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip^7"
    L3_2 = L3_2 .. L2_2 .. L3_2 .. L4_2 .. L5_2
    L0_2(L3_2)
  end
  L0_2 = Utils
  L0_2 = L0_2.loadLanguageFile
  L3_2 = Lang
  L0_2(L3_2)
  L0_2 = runCreateTableQueries
  L0_2()
  L0_2 = Utils
  L0_2 = L0_2.Database
  L0_2 = L0_2.execute
  L3_2 = "UPDATE `store_jobs` SET progress = 0"
  L2_2 = {}
  L0_2(L3_2, L2_2)
  L0_2 = {}
  L3_2 = {}
  L2_2 = {}
  L3_2 = "group_map_blips"
  L2_2[1] = L3_2
  L3_2.config_path = L2_2
  L3_2.default_value = true
  L2_2 = {}
  L3_2 = {}
  L4_2 = "charge_import_money_before"
  L3_2[1] = L4_2
  L2_2.config_path = L3_2
  L2_2.default_value = true
  L0_2[1] = L3_2
  L0_2[2] = L2_2
  L3_2 = Utils
  L3_2 = L3_2.validateConfig
  L2_2 = Config
  L3_2 = L0_2
  L3_2 = L3_2(L2_2, L3_2)
  Config = L3_2
  L3_2 = Wait
  L2_2 = 1000
  L3_2(L2_2)
  L3_2 = {}
  L2_2 = {}
  L3_2 = "market_id"
  L4_2 = "user_id"
  L5_2 = "stock"
  L6_2 = "stock_prices"
  L7_2 = "stock_upgrade"
  L8_2 = "truck_upgrade"
  L9_2 = "relationship_upgrade"
  L10_2 = "money"
  L11_2 = "total_money_earned"
  L12_2 = "total_money_spent"
  L13_2 = "goods_bought"
  L14_2 = "distance_traveled"
  L15_2 = "total_visits"
  L16_2 = "customers"
  L17_2 = "market_name"
  l16_2 = "market_color"
  L19_2 = "market_blip"
  L20_2 = "timer"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L2_2[8] = L10_2
  L2_2[9] = L11_2
  L2_2[10] = L12_2
  L2_2[11] = L13_2
  L2_2[12] = L14_2
  L2_2[13] = L15_2
  L2_2[14] = L16_2
  L2_2[15] = L17_2
  L2_2[16] = l16_2
  L2_2[17] = L19_2
  L2_2[18] = L20_2
  L3_2.store_business = L2_2
  L2_2 = {}
  L3_2 = "id"
  L4_2 = "market_id"
  L5_2 = "income"
  L6_2 = "title"
  L7_2 = "amount"
  L8_2 = "date"
  L9_2 = "hidden"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L3_2.store_balance = L2_2
  L2_2 = {}
  L3_2 = "id"
  L4_2 = "market_id"
  L5_2 = "name"
  L6_2 = "reward"
  L7_2 = "product"
  L8_2 = "amount"
  L9_2 = "progress"
  L10_2 = "trucker_contract_id"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L2_2[8] = L10_2
  L3_2.store_jobs = L2_2
  L2_2 = {}
  L3_2 = "market_id"
  L4_2 = "user_id"
  L5_2 = "jobs_done"
  L6_2 = "role"
  L7_2 = "timer"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L3_2.store_employees = L2_2
  L2_2 = {}
  L3_2 = "id"
  L4_2 = "market_id"
  L5_2 = "category"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L3_2.store_categories = L2_2
  L2_2 = {}
  L3_2 = "user_id"
  L4_2 = "dark_theme"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L3_2.store_users_theme = L2_2
  L2_2 = {}
  L3_2 = {}
  L3_2.trucker_contract_id = "ALTER TABLE `store_jobs` ADD COLUMN `trucker_contract_id` INT UNSIGNED NULL DEFAULT NULL AFTER `progress`;"
  L2_2.store_jobs = L3_2
  L3_2 = {}
  L4_2 = Utils
  L4_2 = L4_2.Database
  L4_2 = L4_2.validateTableColumns
  L5_2 = L1_2
  L6_2 = L2_2
  L7_2 = L3_2
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = {}
  L5_2 = "beforeHireEmployee"
  L6_2 = "afterHireEmployee"
  L4_2[1] = L5_2
  L4_2[2] = L6_2
  L5_2 = Utils
  L5_2 = L5_2.validateFunctions
  L6_2 = L4_2
  L7_2 = "server_utils.lua"
  L5_2(L6_2, L7_2)
  L5_2 = checkIfFrameworkWasLoaded
  L5_2()
  L5_2 = checkScriptName
  L5_2()
  L5_2 = searchForErrorsInConfig
  L5_2()
  L5_2 = searchForDataIssuesInDatabase
  L5_2()
  L5_2 = checkLowStockThread
  L5_2()
end
getConfigMarketLocation(fn_L9_1)
function getConfigMarketLocation()
local L0_2, L3_2, L2_2
  L0_2 = assert
  L3_2 = Utils
  L3_2 = L3_2.Framework
  L3_2 = L3_2.getPlayerId
  L2_2 = "^3The framework wasn't loaded in the '^1lc_utils^3' resource. Please check if the '^1Config.framework^3' is correctly set to your framework, and make sure there are no errors in your file. For more information, refer to the documentation at '^7https://docs.lixeirocharmoso.com/^3'.^7"
  L0_2(L3_2, L2_2)
end
checkIfFrameworkWasLoaded = getConfigMarketLocation
function getConfigMarketLocation()
local L0_2, L3_2, L2_2
  L0_2 = assert
  L3_2 = GetCurrentResourceName
  L3_2 = L3_2()
  L3_2 = "lc_stores" == L3_2
  L2_2 = "^3The script name does not match the expected resource name. Please ensure that the current resource name is set to '^1lc_stores^7'."
  L0_2(L3_2, L2_2)
end
checkScriptName = getConfigMarketLocation
function getConfigMarketLocation()
local L0_2, L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L0_2 = pairs
  L3_2 = Config
  L3_2 = L3_2.market_locations
  L0_2, L3_2, L2_2, L3_2 = L0_2(L3_2)
  for L4_2, L5_2 in L0_2, L3_2, L2_2, L3_2 do
    L6_2 = Config
    L6_2 = L6_2.market_types
    L7_2 = L5_2.type
    L6_2 = L6_2[L7_2]
    if not L6_2 then
      L6_2 = print
      L7_2 = "^1Error in your config:^3 Type '^1"
      L8_2 = L5_2.type
      L9_2 = "^3' is not registered in Config.market_types^7"
      L7_2 = L7_2 .. L8_2 .. L9_2
      L6_2(L7_2)
    end
  end
  L0_2 = pairs
  L3_2 = Config
  L3_2 = L3_2.market_locations
  L0_2, L3_2, L2_2, L3_2 = L0_2(L3_2)
  for L4_2, L5_2 in L0_2, L3_2, L2_2, L3_2 do
    L6_2 = getConfigMarketLocation
    L7_2 = L4_2
    L6_2(L7_2)
  end
  L0_2 = pairs
  L3_2 = Config
  L3_2 = L3_2.market_categories
  L0_2, L3_2, L2_2, L3_2 = L0_2(L3_2)
  for L4_2, L5_2 in L0_2, L3_2, L2_2, L3_2 do
    L6_2 = getMarketCategory
    L7_2 = L4_2
    L6_2(L7_2)
  end
  L0_2 = pairs
  L3_2 = Config
  L3_2 = L3_2.market_locations
  L0_2, L3_2, L2_2, L3_2 = L0_2(L3_2)
  for L4_2, L5_2 in L0_2, L3_2, L2_2, L3_2 do
    L6_2 = getConfigMarketType
    L7_2 = L4_2
    L6_2(L7_2)
  end
end
searchForErrorsInConfig = getConfigMarketLocation
function getConfigMarketLocation()
local L0_2, L3_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l23_2, L19_2, l14_2, l21_2, L22_2, l23_2, L24_2, l23_2, L26_2, L34_2, l19_2, print, L30_2, L31_2, l8_2, l14_2, l27_2
  L0_2 = Config
  L0_2 = L0_2.trucker_logistics
  L0_2 = L0_2.enable
  if L0_2 then
    L0_2 = [[
			UPDATE trucker_available_contracts
			SET external_data = REPLACE(external_data, 'qb_stores', 'lc_stores')
			WHERE external_data LIKE '%qb_stores%';]]
    L3_2 = Utils
    L3_2 = L3_2.Database
    L3_2 = L3_2.execute
    L2_2 = L0_2
    L3_2(L2_2)
    L3_2 = [[
			UPDATE trucker_available_contracts
			SET external_data = REPLACE(external_data, 'esx_stores', 'lc_stores')
			WHERE external_data LIKE '%esx_stores%';]]
    L2_2 = Utils
    L2_2 = L2_2.Database
    L2_2 = L2_2.execute
    L3_2 = L1_2
    L2_2(L3_2)
  end
  L0_2 = {}
  L3_2 = pairs
  L2_2 = Config
  L2_2 = L2_2.market_locations
  L3_2, L2_2, L3_2, L4_2 = L3_2(L2_2)
  for L5_2, L6_2 in L3_2, L2_2, L3_2, L4_2 do
    L7_2 = table
    L7_2 = L7_2.insert
    L8_2 = L0_2
    L9_2 = L5_2
    L7_2(L8_2, L9_2)
  end
  L3_2 = string
  L3_2 = L3_2.format
  L2_2 = "SELECT market_id FROM `store_business` WHERE market_id NOT IN ('%s')"
  L3_2 = table
  L3_2 = L3_2.concat
  L4_2 = L0_2
  L5_2 = "','"
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l16_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, l16_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2 = L3_2(L4_2, L5_2)
  L3_2 = L3_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2)
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.fetchAll
  L3_2 = L1_2
  L4_2 = {}
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = {}
  L4_2 = pairs
  L5_2 = Config
  L5_2 = L5_2.market_categories
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = table
    L10_2 = L10_2.insert
    L11_2 = L3_2
    L12_2 = L8_2
    L10_2(L11_2, L12_2)
  end
  L4_2 = string
  L4_2 = L4_2.format
  L5_2 = "SELECT id, category FROM `store_categories` WHERE category NOT IN ('%s')"
  L6_2 = table
  L6_2 = L6_2.concat
  L7_2 = L3_2
  L8_2 = "','"
  L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, l16_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, l16_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2 = L6_2(L7_2, L8_2)
  L4_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2)
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.fetchAll
  L6_2 = L4_2
  L7_2 = {}
  L5_2 = L5_2(L6_2, L7_2)
  L6_2 = "SELECT market_id, stock, stock_prices FROM `store_business`"
  L7_2 = Utils
  L7_2 = L7_2.Database
  L7_2 = L7_2.fetchAll
  L8_2 = L6_2
  L9_2 = {}
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = GetCurrentResourceName
  L8_2 = L8_2()
  L9_2 = #L2_2
  if not (L9_2 > 0) then
    L9_2 = #L5_2
    if not (L9_2 > 0) then
      goto lbl_102
    end
  end
  L9_2 = print
  L10_2 = "^8["
  L11_2 = L8_2
  L12_2 = "] DATABASE ISSUES:^3 The following issues were found in your database:^7"
  L10_2 = L10_2 .. L11_2 .. L12_2
  L9_2(L10_2)
  ::lbl_102::
  L9_2 = pairs
  L10_2 = L2_2
  L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
  for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
    L15_2 = print
    L16_2 = string
    L16_2 = L16_2.format
    L17_2 = "^8[%s]^3 Store ^1%s^3 is in your ^1store^3 tables but not in your config.^7"
    l8_2 = L8_2
    L19_2 = L14_2.market_id
    L16_2, L17_2, l8_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, l8_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2 = L16_2(L17_2, l8_2, L19_2)
    L15_2(L16_2, L17_2, l8_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, l8_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2)
  end
  L9_2 = pairs
  L10_2 = L5_2
  L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
  for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
    L15_2 = print
    L16_2 = string
    L16_2 = L16_2.format
    L17_2 = "^8[%s]^3 Category ^1%s^3 (ID %d) is in your ^1store_categories^3 table but not in your config.^7"
    l8_2 = L8_2
    L19_2 = L14_2.category
    l14_2 = L14_2.id
    L16_2, L17_2, l8_2, L19_2, l14_2, L21_2, L22_2, L23_2, L24_2, l8_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2 = L16_2(L17_2, l8_2, L19_2, l14_2)
    L15_2(L16_2, L17_2, l8_2, L19_2, l14_2, L21_2, L22_2, L23_2, L24_2, l8_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2)
  end
  L9_2 = pairs
  L10_2 = L7_2
  L9_2, L10_2, L11_2, L12_2 = L9_2(L10_2)
  for L13_2, L14_2 in L9_2, L10_2, L11_2, L12_2 do
    function L15_2(A0_3, A1_3, A2_3)
local L3_3, L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3
      L3_3 = print
      L4_3 = string
      L4_3 = L4_3.format
      L5_3 = "^8[%s]^3 The %s ^1%s^3 has the following error '^1%s^3'. The %s of this store will be automatically reset.^7"
      L6_3 = L8_2
      L9_3 = A0_3
      L8_3 = L14_2.market_id
      L9_3 = A2_3
      L10_3 = A1_3
      L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3 = L4_3(L5_3, L6_3, L9_3, L8_3, L9_3, L10_3)
      L3_3(L4_3, L5_3, L6_3, L9_3, L8_3, L9_3, L10_3)
      L3_3 = string
      L3_3 = L3_3.format
      L4_3 = "UPDATE `%s` SET %s = '[]' WHERE market_id = @market_id"
      L5_3 = A0_3
      L6_3 = A1_3
      L3_3 = L3_3(L4_3, L5_3, L6_3)
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L6_3 = {}
      L9_3 = L14_2.market_id
      L6_3["@market_id"] = L9_3
      L4_3(L5_3, L6_3)
    end
    L16_2 = json
    L16_2 = L16_2.decode
    L17_2 = L14_2.stock
    L16_2, L17_2, l8_2 = L16_2(L17_2)
    L19_2 = json
    L19_2 = L19_2.decode
    l14_2 = L14_2.stock_prices
    L19_2, l14_2, L21_2 = L19_2(l14_2)
    if not L16_2 then
      L22_2 = L15_2
      L23_2 = "store_business"
      L24_2 = "stock"
      l18_2 = l18_2
      L22_2(L23_2, L24_2, l18_2)
    else
      L22_2 = getItems
      l14_2 = L14_2.market_id
      L22_2 = L22_2(L23_2)
      pairs = pairs
      L24_2 = L16_2
      l18_2, L24_2, l18_2, L26_2 = l18_2(L24_2)
      for L27_2, L28_2 in l18_2, L24_2, l18_2, L26_2 do
        l22_2 = L22_2[L27_2]
        if not l22_2 then
          print = print
          L30_2 = string
          L30_2 = L30_2.format
          L31_2 = "^8[%s]^3 The store stock ^1%s^3 has the item '^1%s^3' that is not part of any of its categories. This item will be automatically removed from the stock.^7"
          l8_2 = L8_2
          l14_2 = L14_2.market_id
          l27_2 = l27_2
          L30_2, L31_2, l8_2, l14_2, l27_2 = L30_2(L31_2, l8_2, l14_2, l27_2)
          print(L30_2, L31_2, l8_2, l14_2, l27_2)
          L16_2[l27_2] = nil
        end
      end
      l18_2 = "UPDATE `store_business` SET stock = @stock WHERE market_id = @market_id"
      L24_2 = Utils
      L24_2 = L24_2.Database
      L24_2 = L24_2.execute
      l23_2 = l23_2
      L26_2 = {}
      L34_2 = json
      L34_2 = L34_2.encode
      l16_2 = L16_2
      L34_2 = L34_2(L28_2)
      L26_2["@stock"] = L34_2
      L34_2 = L14_2.market_id
      L26_2["@market_id"] = L34_2
      L24_2(l23_2, L26_2)
    end
    if not L19_2 then
      L22_2 = L15_2
      l23_2 = "store_business"
      L24_2 = "stock_prices"
      l21_2 = l21_2
      L22_2(l21_2, L24_2, l21_2)
    else
      L22_2 = getItems
      l14_2 = L14_2.market_id
      L22_2 = L22_2(L23_2)
      pairs = pairs
      L24_2 = L19_2
      l21_2, L24_2, l21_2, L26_2 = l21_2(L24_2)
      for L34_2, l16_2 in l21_2, L24_2, l21_2, L26_2 do
        l22_2 = L22_2[L27_2]
        if not l22_2 then
          print = print
          L30_2 = string
          L30_2 = L30_2.format
          L31_2 = "^8[%s]^3 The store stock prices ^1%s^3 has the item '^1%s^3' that is not part of any of its categories. This item will be automatically removed from the stock prices.^7"
          l8_2 = L8_2
          l14_2 = L14_2.market_id
          l27_2 = l27_2
          L30_2, L31_2, l8_2, l14_2, l27_2 = L30_2(L31_2, l8_2, l14_2, l27_2)
          print(L30_2, L31_2, l8_2, l14_2, l27_2)
          L19_2[L34_2] = nil
        end
      end
      l21_2 = "UPDATE `store_business` SET stock_prices = @stock WHERE market_id = @market_id"
      L24_2 = Utils
      L24_2 = L24_2.Database
      L24_2 = L24_2.execute
      l23_2 = l23_2
      L26_2 = {}
      L34_2 = json
      L34_2 = L34_2.encode
      l19_2 = L19_2
      L34_2 = L34_2(L28_2)
      L26_2["@stock"] = L34_2
      L34_2 = L14_2.market_id
      L26_2["@market_id"] = L34_2
      L24_2(l23_2, L26_2)
    end
  end
  L9_2 = #L2_2
  if not (L9_2 > 0) then
    L9_2 = #L5_2
    if not (L9_2 > 0) then
      goto lbl_254
    end
  end
  L9_2 = print
  L10_2 = "^8["
  L11_2 = L8_2
  L12_2 = "] HOW TO RESOLVE ISSUES:^3 You can add missing data to the config or manually remove them from your database.^7"
  L10_2 = L10_2 .. L11_2 .. L12_2
  L9_2(L10_2)
  ::lbl_254::
end
searchForDataIssuesInDatabase = getConfigMarketLocation
function getConfigMarketLocation()
local L0_2, L3_2
  L0_2 = Config
  L0_2 = L0_2.create_table
  if false ~= L0_2 then
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L3_2 = [[
			CREATE TABLE IF NOT EXISTS `store_business` (
				`market_id` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`user_id` VARCHAR(50) NOT NULL,
				`stock` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
				`stock_prices` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
				`stock_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`truck_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`relationship_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`money` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`total_money_earned` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`total_money_spent` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`goods_bought` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`distance_traveled` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
				`total_visits` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`customers` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`market_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`market_color` INT(10) UNSIGNED NULL DEFAULT NULL,
				`market_blip` INT(10) UNSIGNED NULL DEFAULT NULL,
				`timer` INT(10) UNSIGNED NOT NULL,
				PRIMARY KEY (`market_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L3_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L3_2 = [[
			CREATE TABLE IF NOT EXISTS `store_balance` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`market_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`income` TINYINT(3) UNSIGNED NOT NULL,
				`title` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`amount` INT(10) UNSIGNED NOT NULL,
				`date` INT(10) UNSIGNED NOT NULL,
				`hidden` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L3_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L3_2 = [[
			CREATE TABLE IF NOT EXISTS `store_categories` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`market_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`category` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L3_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L3_2 = [[
			CREATE TABLE IF NOT EXISTS `store_jobs` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`market_id` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`reward` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`product` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8mb4_general_ci',
				`amount` INT(11) NOT NULL DEFAULT '0',
				`progress` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`trucker_contract_id` INT(10) UNSIGNED NULL DEFAULT NULL,
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L3_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L3_2 = [[
			CREATE TABLE IF NOT EXISTS `store_employees` (
				`market_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`jobs_done` INT(11) UNSIGNED NOT NULL DEFAULT '0',
				`role` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`timer` INT(11) UNSIGNED NOT NULL,
				PRIMARY KEY (`market_id`, `user_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L3_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L3_2 = [[
			CREATE TABLE IF NOT EXISTS `store_users_theme` (
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
				`dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				PRIMARY KEY (`user_id`) USING BTREE
			)
			COLLATE='utf8_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L3_2)
  end
end
runCreateTableQueries = getConfigMarketLocation
