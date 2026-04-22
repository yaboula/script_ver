local api_response, L2_2, L2_1, L2_2, L4_1, L2_2, L6_1, generateTruckerAvailableContractsThread, L8_1, fn_L9_1, fn_L10_1
version = "4.7.3"
subversion = ""
L0_1 = {}
api_response = api_response
api_response = "1.2.4"
L2_2 = false
L2_1 = 2
L2_2 = true
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
L6_1 = {}
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "playerDropped"
function fn_L9_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = source
  L2_2 = L6_1
  L2_2 = L2_2[L1_2]
  if L2_2 then
    L2_2 = "UPDATE `trucker_available_contracts` SET progress = NULL WHERE contract_id = @id;"
    L3_2 = Utils
    L3_2 = L3_2.Database
    L3_2 = L3_2.execute
    L4_2 = L2_2
    L5_2 = {}
    L6_2 = L6_1
    L6_2 = L6_2[L1_2]
    L6_2 = L6_2.contract_data
    L6_2 = L6_2.contract_id
    L5_2["@id"] = L6_2
    L3_2(L4_2, L5_2)
    L3_2 = L6_1
    L3_2[L1_2] = nil
  end
  L2_2 = L4_1
  L2_2[L1_2] = nil
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
function generateTruckerAvailableContractsThread()
local L0_2, L1_2
  L0_2 = Citizen
  L0_2 = L0_2.CreateThreadNow
  function L1_2()
local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3
    L0_3 = Citizen
    L0_3 = L0_3.Wait
    L1_3 = 10000
    L0_3(L1_3)
    while true do
      L0_3 = 1
      L1_3 = Config
      L1_3 = L1_3.jobs
      L1_3 = L1_3.contract_generation
      L1_3 = L1_3.contracts_per_interval
      L2_3 = 1
      for L3_3 = L0_3, L1_3, L2_3 do
        L4_3 = generateContract
        L5_3 = 0
        L4_3(L5_3)
        L4_3 = generateContract
        L5_3 = 1
        L4_3(L5_3)
        L4_3 = Wait
        L5_3 = 10
        L4_3(L5_3)
      end
      L0_3 = Utils
      L0_3 = L0_3.Framework
      L0_3 = L0_3.getPlayers
      L0_3 = L0_3()
      if not L0_3 then
        L0_3 = {}
      end
      L1_3 = pairs
      L2_3 = L0_3
      L1_3, L2_3, L3_3, L4_3 = L1_3(L2_3)
      for L5_3, L6_3 in L1_3, L2_3, L3_3, L4_3 do
        L7_3 = L4_1
        L7_3 = L7_3[L6_3]
        if L7_3 then
          L7_3 = openUI
          L8_3 = L6_3
          L9_3 = true
          L7_3(L8_3, L9_3)
          L7_3 = Citizen
          L7_3 = L7_3.Wait
          L8_3 = 100
          L7_3(L8_3)
        end
      end
      L1_3 = Citizen
      L1_3 = L1_3.Wait
      L2_3 = Config
      L2_3 = L2_3.jobs
      L2_3 = L2_3.contract_generation
      L2_3 = L2_3.cooldown
      L2_3 = L2_3 * 1000
      L2_3 = L2_3 * 60
      L1_3(L2_3)
    end
  end
  L0_2(L1_2)
end
generateTruckerAvailableContractsThread = generateTruckerAvailableContractsThread
function generateTruckerAvailableContractsThread(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L3_2 = Config
  L3_2 = L3_2.jobs
  L3_2 = L3_2.economy
  L3_2 = L3_2.multipliers
  L3_2 = L3_2.freight
  if 0 == A1_2 then
    L3_2 = 1.0
  end
  if 1 == A2_2 then
    L4_2 = Config
    L4_2 = L4_2.jobs
    L4_2 = L4_2.economy
    L4_2 = L4_2.multipliers
    L4_2 = L4_2.illegal
    L4_2 = L3_2 + L4_2
    L3_2 = L4_2 - 1.0
  end
  L4_2 = math
  L4_2 = L4_2.max
  L5_2 = L3_2
  L6_2 = 0.0
  L4_2 = L4_2(L5_2, L6_2)
  L3_2 = L4_2
  if 0 == L3_2 then
    L4_2 = print
    L5_2 = "Creating a contract with 0 value, is this expected? 'freight job mutiplier': "
    L6_2 = Config
    L6_2 = L6_2.jobs
    L6_2 = L6_2.economy
    L6_2 = L6_2.multipliers
    L6_2 = L6_2.freight
    if not L6_2 then
      L6_2 = "nil"
    end
    L7_2 = " 'illegal mutiplier': "
    L8_2 = Config
    L8_2 = L8_2.jobs
    L8_2 = L8_2.economy
    L8_2 = L8_2.multipliers
    L8_2 = L8_2.illegal
    if not L8_2 then
      L8_2 = "nil"
    end
    L9_2 = "."
    L5_2 = L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2
    L4_2(L5_2)
  end
  L4_2 = A0_2 * L3_2
  return L4_2
end
getFinalPricePerKm = generateTruckerAvailableContractsThread
function generateTruckerAvailableContractsThread(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2, A8_2, A9_2, A10_2)
local L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2, L20_2, a6_2, L22_2, a6_2, l17_2
  L11_2 = "SELECT contract_id FROM trucker_available_contracts WHERE contract_type = @contract_type AND coords_index <> 0 AND (progress IS NULL OR progress = 0) ORDER BY contract_id ASC"
  L12_2 = Utils
  L12_2 = L12_2.Database
  L12_2 = L12_2.fetchAll
  L13_2 = L11_2
  L14_2 = {}
  L14_2["@contract_type"] = A0_2
  L12_2 = L12_2(L13_2, L14_2)
  L13_2 = #L12_2
  L14_2 = Config
  L14_2 = L14_2.jobs
  L14_2 = L14_2.contract_generation
  L14_2 = L14_2.max_active_contracts
  if L13_2 >= L14_2 then
    L13_2 = #L12_2
    L14_2 = Config
    L14_2 = L14_2.jobs
    L14_2 = L14_2.contract_generation
    L14_2 = L14_2.max_active_contracts
    L13_2 = L13_2 - L14_2
    L13_2 = L13_2 + 1
    L14_2 = 1
    L15_2 = L13_2
    L16_2 = 1
    for L17_2 = L14_2, L15_2, L16_2 do
      L18_2 = L12_2[L17_2]
      L18_2 = L18_2.contract_id
      L19_2 = "DELETE FROM `trucker_available_contracts` WHERE contract_id = @contract_id;"
      L20_2 = Utils
      L20_2 = L20_2.Database
      L20_2 = L20_2.execute
      l19_2 = L19_2
      L22_2 = {}
      L22_2["@contract_id"] = L18_2
      L20_2(l19_2, L22_2)
      L20_2 = Wait
      l19_2 = 10
      L20_2(l19_2)
    end
  end
  if 1 == A7_2 then
    L13_2 = "SELECT contract_id FROM trucker_available_contracts WHERE contract_type = @contract_type AND illegal = 1 AND (progress IS NULL OR progress = 0) ORDER BY contract_id ASC"
    L14_2 = Utils
    L14_2 = L14_2.Database
    L14_2 = L14_2.fetchAll
    L15_2 = L13_2
    L16_2 = {}
    L16_2["@contract_type"] = A0_2
    L14_2 = L14_2(L15_2, L16_2)
    L15_2 = #L14_2
    L16_2 = Config
    L16_2 = L16_2.jobs
    L16_2 = L16_2.contract_generation
    L16_2 = L16_2.max_illegal_contracts
    L15_2 = L15_2 - L16_2
    L15_2 = L15_2 + 1
    if L15_2 > 0 then
      L16_2 = 1
      L17_2 = L15_2
      L18_2 = 1
      for L19_2 = L16_2, L17_2, L18_2 do
        L20_2 = L14_2[L19_2]
        L20_2 = L20_2.contract_id
        l19_2 = "DELETE FROM `trucker_available_contracts` WHERE contract_id = @contract_id;"
        L22_2 = Utils
        L22_2 = L22_2.Database
        L22_2 = L22_2.execute
        l21_2 = l21_2
        L24_2 = {}
        L24_2["@contract_id"] = L20_2
        L22_2(l21_2, L24_2)
        L22_2 = Wait
        l21_2 = 10
        L22_2(l21_2)
      end
    end
  end
  L13_2 = "INSERT INTO `trucker_available_contracts` (contract_type, contract_name, coords_index, price_per_km, cargo_type, fragile, valuable, illegal, fast, truck, trailer) VALUES (@contract_type, @contract_name, @coords_index, @price_per_km, @cargo_type, @fragile, @valuable, @illegal, @fast, @truck, @trailer);"
  L14_2 = Utils
  L14_2 = L14_2.Database
  L14_2 = L14_2.fetchAll
  L15_2 = L13_2
  L16_2 = {}
  L16_2["@contract_type"] = A0_2
  L16_2["@contract_name"] = A1_2
  L16_2["@coords_index"] = A2_2
  L16_2["@price_per_km"] = A3_2
  L16_2["@cargo_type"] = A4_2
  L16_2["@fragile"] = A5_2
  L16_2["@valuable"] = A6_2
  L16_2["@illegal"] = A7_2
  L16_2["@fast"] = A8_2
  L16_2["@truck"] = A9_2
  L16_2["@trailer"] = A10_2
  L14_2 = L14_2(L15_2, L16_2)
  return L14_2
end
insertContractInDatabase = generateTruckerAvailableContractsThread
function generateTruckerAvailableContractsThread(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2, L20_2, l21_2, L22_2, l21_2, l17_2, l6_2
  L1_2 = assert
  L2_2 = type
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L2_2 = "number" == L2_2 and 0 == A0_2 or 1 == A0_2
  L3_2 = "contract_type must be 0 or 1"
  L1_2(L2_2, L3_2)
  L1_2 = math
  L1_2 = L1_2.random
  L2_2 = 1
  L3_2 = Config
  L3_2 = L3_2.delivery_locations
  L3_2 = #L3_2
  L1_2 = L1_2(L2_2, L3_2)
  L2_2 = math
  L2_2 = L2_2.random
  L3_2 = Config
  L3_2 = L3_2.jobs
  L3_2 = L3_2.economy
  L3_2 = L3_2.price_per_km
  L3_2 = L3_2.min
  L4_2 = Config
  L4_2 = L4_2.jobs
  L4_2 = L4_2.economy
  L4_2 = L4_2.price_per_km
  L4_2 = L4_2.max
  L2_2 = L2_2(L3_2, L4_2)
  L3_2 = nil
  if 1 ~= A0_2 then
    L4_2 = Config
    L4_2 = L4_2.jobs
    L4_2 = L4_2.truck_rental
    L4_2 = L4_2.available_trucks
    L5_2 = math
    L5_2 = L5_2.random
    L6_2 = 1
    L7_2 = Config
    L7_2 = L7_2.jobs
    L7_2 = L7_2.truck_rental
    L7_2 = L7_2.available_trucks
    L7_2 = #L7_2
    L5_2 = L5_2(L6_2, L7_2)
    L3_2 = L4_2[L5_2]
  end
  L4_2 = Config
  L4_2 = L4_2.jobs
  L4_2 = L4_2.available_loads
  L5_2 = math
  L5_2 = L5_2.random
  L6_2 = 1
  L7_2 = Config
  L7_2 = L7_2.jobs
  L7_2 = L7_2.available_loads
  L7_2 = #L7_2
  L5_2 = L5_2(L6_2, L7_2)
  L4_2 = L4_2[L5_2]
  L5_2 = L4_2.name
  L6_2 = L4_2.trailer
  L7_2 = L4_2.def
  L7_2 = L7_2[1]
  L8_2 = L4_2.def
  L8_2 = L8_2[2]
  L9_2 = L4_2.def
  L9_2 = L9_2[3]
  L10_2 = L4_2.def
  L10_2 = L10_2[4]
  if not L10_2 then
    L10_2 = 0
  end
  L13_2 = math
  L13_2 = L13_2.random
  L12_2 = 0
  L13_2 = 100
  L13_2 = L13_2(L12_2, L13_2)
  L12_2 = 0
  L13_2 = Config
  L13_2 = L13_2.jobs
  L13_2 = L13_2.special_cargo
  L13_2 = L13_2.urgent
  L13_2 = L13_2.chance_percent
  if L13_2 <= L13_2 then
    L12_2 = 1
  end
  L13_2 = getFinalPricePerKm
  L14_2 = L2_2
  L15_2 = A0_2
  L16_2 = L10_2
  L13_2 = L13_2(L14_2, L15_2, L16_2)
  L14_2 = insertContractInDatabase
  L15_2 = A0_2
  L16_2 = L5_2
  L17_2 = L1_2
  L18_2 = L13_2
  l21_2 = L7_2
  L20_2 = L8_2
  l9_2 = L9_2
  L22_2 = L10_2
  l12_2 = L12_2
  l3_2 = L3_2
  l6_2 = L6_2
  return L14_2(L15_2, L16_2, L17_2, L18_2, l21_2, L20_2, l12_2, L22_2, l12_2, l3_2, l6_2)
end
generateContract = generateTruckerAvailableContractsThread
generateTruckerAvailableContractsThread = exports
L8_1 = "generateContract"
generatecontract = generateContract
generateTruckerAvailableContractsThread(L8_1, generatecontract)
function generateTruckerAvailableContractsThread(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
local L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, a6_2, L20_2, l12_2, L22_2, l12_2
  L7_2 = assert
  L8_2 = type
  L9_2 = A0_2
  L8_2 = L8_2(L9_2)
  L8_2 = "number" == L8_2 and 0 == A0_2 or 1 == A0_2
  L9_2 = "contract_type must be 0 or 1"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A1_2
  L8_2 = L8_2(L9_2)
  L8_2 = "string" == L8_2
  L9_2 = "contract_name must be a string"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A2_2
  L8_2 = L8_2(L9_2)
  L8_2 = "number" == L8_2 and A2_2 > 0
  L9_2 = "coords_index must be a index of the Config.delivery_locations table"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A3_2
  L8_2 = L8_2(L9_2)
  L8_2 = "number" == L8_2 and A3_2 > 0
  L9_2 = "price_per_km must be a valid number"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A4_2
  L8_2 = L8_2(L9_2)
  L8_2 = "table" == L8_2
  L9_2 = "cargo_data must be a table"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A4_2.cargo_type
  L8_2 = L8_2(L9_2)
  L8_2 = "number" == L8_2
  L9_2 = "cargo_data.cargo_type must be a number between 0 and 6"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A4_2.is_fragile
  L8_2 = L8_2(L9_2)
  L8_2 = "boolean" == L8_2
  L9_2 = "cargo_data.is_fragile must be true or false"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A4_2.is_valuable
  L8_2 = L8_2(L9_2)
  L8_2 = "boolean" == L8_2
  L9_2 = "cargo_data.is_valuable must be true or false"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A4_2.is_urgent
  L8_2 = L8_2(L9_2)
  L8_2 = "boolean" == L8_2
  L9_2 = "cargo_data.is_urgent must be true or false"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A4_2.is_illegal
  L8_2 = L8_2(L9_2)
  L8_2 = "boolean" == L8_2
  L9_2 = "cargo_data.is_illegal must be true or false"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A5_2
  L8_2 = L8_2(L9_2)
  L8_2 = "string" == L8_2
  L9_2 = "truck must be a string"
  L7_2(L8_2, L9_2)
  L7_2 = assert
  L8_2 = type
  L9_2 = A6_2
  L8_2 = L8_2(L9_2)
  L8_2 = "string" == L8_2
  L9_2 = "trailer must be a string"
  L7_2(L8_2, L9_2)
  L7_2 = 0
  L8_2 = A4_2.is_fragile
  if L8_2 then
    L7_2 = 1
  end
  L8_2 = 0
  L9_2 = A4_2.is_valuable
  if L9_2 then
    L8_2 = 1
  end
  L9_2 = 0
  L10_2 = A4_2.is_urgent
  if L10_2 then
    L9_2 = 1
  end
  L10_2 = 0
  L13_2 = A4_2.is_illegal
  if L13_2 then
    L10_2 = 1
  end
  L13_2 = getFinalPricePerKm
  L12_2 = A3_2
  L13_2 = A0_2
  L14_2 = L10_2
  L13_2 = L13_2(L12_2, L13_2, L14_2)
  L12_2 = insertContractInDatabase
  L13_2 = A0_2
  L14_2 = A1_2
  L15_2 = A2_2
  L16_2 = L11_2
  L17_2 = A4_2.cargo_type
  L18_2 = L7_2
  l21_2 = L8_2
  L20_2 = L10_2
  l9_2 = L9_2
  L22_2 = A5_2
  a6_2 = A6_2
  return L12_2(L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2, L20_2, a6_2, L22_2, a6_2)
end
generateContractDetailed = generateTruckerAvailableContractsThread
generateTruckerAvailableContractsThread = exports
L8_1 = "generateContractDetailed"
generatecontractdetailed = generateContractDetailed
generateTruckerAvailableContractsThread(L8_1, generatecontractdetailed)
function generateTruckerAvailableContractsThread(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2, A7_2)
local L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2
  L8_2 = assert
  L9_2 = type
  L10_2 = A0_2
  L9_2 = L9_2(L10_2)
  L9_2 = "number" == L9_2 and 0 == A0_2 or 1 == A0_2
  L10_2 = "contract_type must be 0 or 1"
  L8_2(L9_2, L10_2)
  L8_2 = assert
  L9_2 = type
  L10_2 = A1_2
  L9_2 = L9_2(L10_2)
  L9_2 = "string" == L9_2
  L10_2 = "contract_name must be a string"
  L8_2(L9_2, L10_2)
  L8_2 = assert
  L9_2 = type
  L10_2 = A2_2
  L9_2 = L9_2(L10_2)
  L9_2 = "string" == L9_2
  L10_2 = "truck must be a string"
  L8_2(L9_2, L10_2)
  L8_2 = assert
  L9_2 = type
  L10_2 = A3_2
  L9_2 = L9_2(L10_2)
  L9_2 = "string" == L9_2
  L10_2 = "trailer must be a string"
  L8_2(L9_2, L10_2)
  L8_2 = assert
  L9_2 = type
  L10_2 = A4_2
  L9_2 = L9_2(L10_2)
  L9_2 = "vector4" == L9_2
  L10_2 = "vector_parking_location must be a vector4"
  L8_2(L9_2, L10_2)
  L8_2 = assert
  L9_2 = type
  L10_2 = A5_2
  L9_2 = L9_2(L10_2)
  L9_2 = "number" == L9_2 and A5_2 > 0
  L10_2 = "reward must be a valid number"
  L8_2(L9_2, L10_2)
  L8_2 = assert
  L9_2 = type
  L10_2 = A6_2
  L9_2 = L9_2(L10_2)
  L9_2 = "string" == L9_2
  L10_2 = "resource_name must be a string"
  L8_2(L9_2, L10_2)
  L8_2 = "SELECT COUNT(contract_id) as qtd FROM trucker_available_contracts WHERE contract_type = @contract_type AND coords_index <> 0 AND (progress IS NULL OR progress = 0)"
  L9_2 = Utils
  L9_2 = L9_2.Database
  L9_2 = L9_2.fetchAll
  L10_2 = L8_2
  L13_2 = {}
  L13_2["@contract_type"] = A0_2
  L9_2 = L9_2(L10_2, L11_2)
  L9_2 = L9_2[1]
  L9_2 = L9_2.qtd
  L10_2 = tonumber
  L13_2 = L9_2
  L10_2 = L10_2(L11_2)
  L13_2 = Config
  L13_2 = L13_2.jobs
  L13_2 = L13_2.contract_generation
  L13_2 = L13_2.max_active_contracts
  if L10_2 >= L13_2 then
    L10_2 = "SELECT MIN(contract_id) as min FROM trucker_available_contracts WHERE contract_type = @contract_type AND coords_index <> 0 AND (progress IS NULL OR progress = 0)"
    L13_2 = Utils
    L13_2 = L13_2.Database
    L13_2 = L13_2.fetchAll
    L12_2 = L10_2
    L13_2 = {}
    L13_2["@contract_type"] = A0_2
    L13_2 = L13_2(L12_2, L13_2)
    L13_2 = L13_2[1]
    L13_2 = L13_2.min
    L12_2 = "DELETE FROM `trucker_available_contracts` WHERE contract_id = @contract_id;"
    L13_2 = Utils
    L13_2 = L13_2.Database
    L13_2 = L13_2.execute
    L14_2 = L12_2
    L15_2 = {}
    L15_2["@contract_id"] = L13_2
    L13_2(L14_2, L15_2)
  end
  if nil == A7_2 then
    L10_2 = {}
    A7_2 = L10_2
  end
  L10_2 = A4_2.x
  A7_2.x = L10_2
  L10_2 = A4_2.y
  A7_2.y = L10_2
  L10_2 = A4_2.z
  A7_2.z = L10_2
  L10_2 = A4_2.w
  A7_2.h = L10_2
  A7_2.reward = A5_2
  A7_2.export = A6_2
  L10_2 = "INSERT INTO `trucker_available_contracts` (contract_type, contract_name, coords_index, price_per_km, cargo_type, fragile, valuable, fast, illegal, truck, trailer, external_data) VALUES (@contract_type, @contract_name, @coords_index, @price_per_km, @cargo_type, @fragile, @valuable, @fast, @illegal, @truck, @trailer, @external_data);"
  L13_2 = Utils
  L13_2 = L13_2.Database
  L13_2 = L13_2.fetchAll
  L12_2 = L10_2
  L13_2 = {}
  L13_2["@contract_type"] = A0_2
  L13_2["@contract_name"] = A1_2
  L13_2["@coords_index"] = 0
  L13_2["@price_per_km"] = 0
  L13_2["@cargo_type"] = 0
  L13_2["@fragile"] = 0
  L13_2["@valuable"] = 0
  L13_2["@fast"] = 0
  L13_2["@illegal"] = 0
  L13_2["@truck"] = A2_2
  L13_2["@trailer"] = A3_2
  L14_2 = json
  L14_2 = L14_2.encode
  L15_2 = A7_2
  L14_2 = L14_2(L15_2)
  L13_2["@external_data"] = L14_2
  L13_2 = L13_2(L12_2, L13_2)
  return L13_2
end
generateContractWithCallback = generateTruckerAvailableContractsThread
generateTruckerAvailableContractsThread = exports
L8_1 = "generateContractWithCallback"
generatecontractwithcallback = generateContractWithCallback
generateTruckerAvailableContractsThread(L8_1, generatecontractwithcallback)
function generateTruckerAvailableContractsThread()
local L0_2, L1_2
  L0_2 = Citizen
  L0_2 = L0_2.CreateThreadNow
  function L1_2()
local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3
    L0_3 = Citizen
    L0_3 = L0_3.Wait
    L1_3 = 10000
    L0_3(L1_3)
    while true do
      L0_3 = math
      L0_3 = L0_3.random
      L1_3 = 0
      L2_3 = 6
      L0_3 = L0_3(L1_3, L2_3)
      L1_3 = math
      L1_3 = L1_3.random
      L2_3 = 0
      L3_3 = 6
      L1_3 = L1_3(L2_3, L3_3)
      L2_3 = math
      L2_3 = L2_3.random
      L3_3 = 0
      L4_3 = 6
      L2_3 = L2_3(L3_3, L4_3)
      L3_3 = math
      L3_3 = L3_3.random
      L4_3 = 0
      L5_3 = 6
      L3_3 = L3_3(L4_3, L5_3)
      L4_3 = math
      L4_3 = L4_3.random
      L5_3 = 0
      L6_3 = 6
      L4_3 = L4_3(L5_3, L6_3)
      L5_3 = L0_3 + L1_3
      L5_3 = L5_3 + L2_3
      L5_3 = L5_3 + L3_3
      L5_3 = L5_3 + L4_3
      if L5_3 > 15 then
        L5_3 = math
        L5_3 = L5_3.random
        L6_3 = 0
        L7_3 = 6
        L5_3 = L5_3(L6_3, L7_3)
        L0_3 = L5_3
        L5_3 = math
        L5_3 = L5_3.random
        L6_3 = 0
        L7_3 = 6
        L5_3 = L5_3(L6_3, L7_3)
        L1_3 = L5_3
        L5_3 = math
        L5_3 = L5_3.random
        L6_3 = 0
        L7_3 = 6
        L5_3 = L5_3(L6_3, L7_3)
        L2_3 = L5_3
        L5_3 = math
        L5_3 = L5_3.random
        L6_3 = 0
        L7_3 = 6
        L5_3 = L5_3(L6_3, L7_3)
        L3_3 = L5_3
        L5_3 = math
        L5_3 = L5_3.random
        L6_3 = 0
        L7_3 = 6
        L5_3 = L5_3(L6_3, L7_3)
        L4_3 = L5_3
        L5_3 = L0_3 + L1_3
        L5_3 = L5_3 + L2_3
        L5_3 = L5_3 + L3_3
        L5_3 = L5_3 + L4_3
        if L5_3 > 20 then
          L5_3 = math
          L5_3 = L5_3.random
          L6_3 = 0
          L7_3 = 6
          L5_3 = L5_3(L6_3, L7_3)
          L0_3 = L5_3
          L5_3 = math
          L5_3 = L5_3.random
          L6_3 = 0
          L7_3 = 6
          L5_3 = L5_3(L6_3, L7_3)
          L1_3 = L5_3
          L5_3 = math
          L5_3 = L5_3.random
          L6_3 = 0
          L7_3 = 6
          L5_3 = L5_3(L6_3, L7_3)
          L2_3 = L5_3
          L5_3 = math
          L5_3 = L5_3.random
          L6_3 = 0
          L7_3 = 6
          L5_3 = L5_3(L6_3, L7_3)
          L3_3 = L5_3
          L5_3 = math
          L5_3 = L5_3.random
          L6_3 = 0
          L7_3 = 6
          L5_3 = L5_3(L6_3, L7_3)
          L4_3 = L5_3
        end
      end
      L5_3 = math
      L5_3 = L5_3.random
      L8_3 = Config
      L8_3 = L8_3.drivers
      L8_3 = L8_3.hiring_costs
      L8_3 = L8_3.min
      L7_3 = Config
      L7_3 = L7_3.drivers
      L7_3 = L7_3.hiring_costs
      L7_3 = L7_3.max
      L5_3 = L5_3(L6_3, L7_3)
      L8_3 = L0_3 + L1_3
      L8_3 = L8_3 + L2_3
      L8_3 = L8_3 + L3_3
      L8_3 = L8_3 + L4_3
      L7_3 = Config
      L7_3 = L7_3.drivers
      L7_3 = L7_3.hiring_costs
      L7_3 = L7_3.percentage_skills
      L7_3 = L7_3 / 100
      L7_3 = L5_3 * L7_3
      L8_3 = L8_3 * L7_3
      L5_3 = L5_3 + L6_3
      L8_3 = Config
      L8_3 = L8_3.drivers
      L8_3 = L8_3.available_drivers
      L7_3 = math
      L7_3 = L7_3.random
      L8_3 = 1
      L9_3 = Config
      L9_3 = L9_3.drivers
      L9_3 = L9_3.available_drivers
      L9_3 = #L9_3
      L7_3 = L7_3(L8_3, L9_3)
      L8_3 = L8_3[L7_3]
      L7_3 = L6_3.names
      L8_3 = math
      L8_3 = L8_3.random
      L9_3 = 1
      L10_3 = L6_3.names
      L10_3 = #L10_3
      L8_3 = L8_3(L9_3, L10_3)
      L7_3 = L7_3[L8_3]
      L8_3 = "SELECT COUNT(driver_id) as qtd FROM trucker_drivers WHERE user_id IS NULL"
      L9_3 = Utils
      L9_3 = L9_3.Database
      L9_3 = L9_3.fetchAll
      L10_3 = L8_3
      L11_3 = {}
      L9_3 = L9_3(L10_3, L11_3)
      L9_3 = L9_3[1]
      L9_3 = L9_3.qtd
      L10_3 = tonumber
      L11_3 = L9_3
      L10_3 = L10_3(L11_3)
      L11_3 = Config
      L11_3 = L11_3.drivers
      L11_3 = L11_3.max_active_drivers
      if L10_3 >= L11_3 then
        L10_3 = "SELECT MIN(driver_id) as min FROM trucker_drivers WHERE user_id IS NULL"
        L11_3 = Utils
        L11_3 = L11_3.Database
        L11_3 = L11_3.fetchAll
        L14_3 = L10_3
        L13_3 = {}
        L11_3 = L11_3(L12_3, L13_3)
        L11_3 = L11_3[1]
        L11_3 = L11_3.min
        L14_3 = "DELETE FROM `trucker_drivers` WHERE driver_id = @driver_id;"
        L13_3 = Utils
        L13_3 = L13_3.Database
        L13_3 = L13_3.execute
        L14_3 = L12_3
        L15_3 = {}
        L15_3["@driver_id"] = L11_3
        L13_3(L14_3, L15_3)
      end
      L10_3 = "INSERT INTO `trucker_drivers` (user_id, name, product_type, distance, fragile, valuable, fast, price, img) VALUES (NULL, @name, @product_type, @distance, @fragile, @valuable, @fast, @price, @img);"
      L11_3 = Utils
      L11_3 = L11_3.Database
      L11_3 = L11_3.execute
      L14_3 = L10_3
      L13_3 = {}
      L13_3["@name"] = L7_3
      L13_3["@product_type"] = L0_3
      L13_3["@distance"] = L1_3
      L13_3["@fragile"] = L2_3
      L13_3["@valuable"] = L3_3
      L13_3["@fast"] = L4_3
      L13_3["@price"] = L5_3
      L14_3 = L6_3.img
      L13_3["@img"] = L14_3
      L11_3(L14_3, L13_3)
      L11_3 = Utils
      L11_3 = L11_3.Framework
      L11_3 = L11_3.getPlayers
      L11_3 = L11_3()
      if not L11_3 then
        L11_3 = {}
      end
      L14_3 = pairs
      L13_3 = L11_3
      L14_3, L13_3, L14_3, L15_3 = L14_3(L13_3)
      for L16_3, L17_3 in L14_3, L13_3, L14_3, L15_3 do
        L18_3 = L4_1
        L18_3 = L18_3[L17_3]
        if L18_3 then
          L18_3 = openUI
          L19_3 = L17_3
          L20_3 = true
          L18_3(L19_3, L20_3)
          L18_3 = Citizen
          L18_3 = L18_3.Wait
          L19_3 = 100
          L18_3(L19_3)
        end
      end
      L14_3 = Citizen
      L14_3 = L14_3.Wait
      L13_3 = Config
      L13_3 = L13_3.drivers
      L13_3 = L13_3.cooldown
      L13_3 = L13_3 * 1000
      L13_3 = L13_3 * 60
      L14_3(L13_3)
    end
  end
  L0_2(L1_2)
end
generateTruckerDriversThread = generateTruckerAvailableContractsThread
function generateTruckerAvailableContractsThread()
local L0_2, L1_2
  L0_2 = Citizen
  L0_2 = L0_2.CreateThreadNow
  function L1_2()
local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3
    L0_3 = Citizen
    L0_3 = L0_3.Wait
    L1_3 = 10000
    L0_3(L1_3)
    while true do
      L0_3 = [[
SELECT d.driver_id, d.user_id, d.name, d.product_type, d.distance, d.valuable, d.fragile, d.fast, d.price,
							t.truck_name, t.fuel, t.truck_id
						FROM trucker_trucks t
							INNER JOIN trucker_drivers d ON (t.driver = d.driver_id)
						WHERE t.driver <> 0 AND t.driver IS NOT NULL]]
      L1_3 = Utils
      L1_3 = L1_3.Database
      L1_3 = L1_3.fetchAll
      L2_3 = L0_3
      L3_3 = {}
      L1_3 = L1_3(L2_3, L3_3)
      L2_3 = pairs
      L3_3 = L1_3
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
      for L8_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
        L8_3 = Utils
        L8_3 = L8_3.Framework
        L8_3 = L8_3.getPlayerSource
        L9_3 = L7_3.user_id
        L8_3 = L8_3(L9_3)
        L9_3 = Config
        L9_3 = L9_3.driver_jobs
        L9_3 = L9_3.generate_money_offline
        if L9_3 or L8_3 then
          L9_3 = assert
          L10_3 = Config
          L10_3 = L10_3.driver_jobs
          L10_3 = L10_3.fuel_consumption
          L11_3 = "Missing Config.driver_jobs.fuel_consumption config"
          L9_3(L10_3, L11_3)
          L9_3 = Config
          L9_3 = L9_3.dealership
          L10_3 = L7_3.truck_name
          L9_3 = L9_3[L10_3]
          if L9_3 then
            L9_3 = math
            L9_3 = L9_3.random
            L10_3 = Config
            L10_3 = L10_3.driver_jobs
            L10_3 = L10_3.fuel_consumption
            L10_3 = L10_3.min
            L11_3 = Config
            L11_3 = L11_3.driver_jobs
            L11_3 = L11_3.fuel_consumption
            L11_3 = L11_3.max
            L9_3 = L9_3(L10_3, L11_3)
            L10_3 = L7_3.fuel
            if L9_3 <= L10_3 then
              L10_3 = math
              L10_3 = L10_3.random
              L11_3 = Config
              L11_3 = L11_3.driver_jobs
              L11_3 = L11_3.profit
              L11_3 = L11_3.min
              L14_3 = Config
              L14_3 = L14_3.driver_jobs
              L14_3 = L14_3.profit
              L14_3 = L14_3.max
              L10_3 = L10_3(L11_3, L12_3)
              L11_3 = L7_3.product_type
              L14_3 = L7_3.distance
              L11_3 = L11_3 + L12_3
              L14_3 = L7_3.fragile
              L11_3 = L11_3 + L12_3
              L14_3 = L7_3.valuable
              L11_3 = L11_3 + L12_3
              L14_3 = L7_3.fast
              L11_3 = L11_3 + L12_3
              L14_3 = Config
              L14_3 = L14_3.driver_jobs
              L14_3 = L14_3.profit
              L14_3 = L14_3.percentage_skills
              L14_3 = L14_3 / 100
              L14_3 = L10_3 * L14_3
              L11_3 = L11_3 * L12_3
              L10_3 = L10_3 + L11_3
              L11_3 = Config
              L11_3 = L11_3.dealership
              L14_3 = L7_3.truck_name
              L11_3 = L11_3[L12_3]
              L11_3 = L11_3.driver_bonus
              L11_3 = L11_3 / 100
              L11_3 = L10_3 * L11_3
              L10_3 = L10_3 + L11_3
              L11_3 = math
              L11_3 = L11_3.floor
              L14_3 = L10_3
              L11_3 = L11_3(L12_3)
              L10_3 = L11_3
              L11_3 = giveTruckerMoney
              L14_3 = L7_3.user_id
              L13_3 = L10_3
              L11_3(L14_3, L13_3)
              L11_3 = "UPDATE `trucker_trucks` SET fuel = @fuel WHERE truck_id = @truck_id"
              L14_3 = Utils
              L14_3 = L14_3.Database
              L14_3 = L14_3.execute
              L13_3 = L11_3
              L14_3 = {}
              L15_3 = L7_3.fuel
              L15_3 = L15_3 - L9_3
              L14_3.fuel = L15_3
              L15_3 = L7_3.truck_id
              L14_3["@truck_id"] = L15_3
              L14_3(L13_3, L14_3)
              if L8_3 then
                L14_3 = TriggerClientEvent
                L13_3 = "truck_logistics:Notify"
                L14_3 = L8_3
                L15_3 = "success"
                L16_3 = Utils
                L16_3 = L16_3.translate
                L17_3 = "driver_done"
                L16_3 = L16_3(L17_3)
                L19_3 = L16_3
                L16_3 = L16_3.format
                L18_3 = L7_3.name
                L19_3 = L10_3
                L16_3, L19_3, L18_3, L19_3 = L16_3(L19_3, L18_3, L19_3)
                L14_3(L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3)
              end
              if L8_3 then
                L14_3 = L4_1
                L14_3 = L14_3[L8_3]
                if L14_3 then
                  L14_3 = openUI
                  L13_3 = L8_3
                  L14_3 = true
                  L14_3(L13_3, L14_3)
                  L14_3 = Citizen
                  L14_3 = L14_3.Wait
                  L13_3 = 100
                  L14_3(L13_3)
                end
              end
            end
          end
        end
        L9_3 = Citizen
        L9_3 = L9_3.Wait
        L10_3 = 100
        L9_3(L10_3)
      end
      L2_3 = Citizen
      L2_3 = L2_3.Wait
      L3_3 = Config
      L3_3 = L3_3.driver_jobs
      L3_3 = L3_3.cooldown
      L3_3 = L3_3 * 1000
      L3_3 = L3_3 * 60
      L2_3(L3_3)
    end
  end
  L0_2(L1_2)
end
generateTruckerDriversJobsThread = generateTruckerAvailableContractsThread
function generateTruckerAvailableContractsThread()
local L0_2, L1_2
  L0_2 = Citizen
  L0_2 = L0_2.CreateThreadNow
  function L1_2()
local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3
    L0_3 = Config
    L0_3 = L0_3.loans
    L0_3 = L0_3.payment_interval_hours
    L0_3 = L0_3 * 3600
    while true do
      L1_3 = "SELECT * FROM trucker_loans"
      L2_3 = Utils
      L2_3 = L2_3.Database
      L2_3 = L2_3.fetchAll
      L3_3 = L1_3
      L4_3 = {}
      L2_3 = L2_3(L3_3, L4_3)
      L3_3 = pairs
      L4_3 = L2_3
      L3_3, L4_3, L5_3, L8_3 = L3_3(L4_3)
      for L7_3, L8_3 in L3_3, L4_3, L5_3, L8_3 do
        L9_3 = L8_3.timer
        L9_3 = L9_3 + L0_3
        L10_3 = os
        L10_3 = L10_3.time
        L10_3 = L10_3()
        if L9_3 < L10_3 then
          L9_3 = Utils
          L9_3 = L9_3.Framework
          L9_3 = L9_3.getPlayerSource
          L10_3 = L8_3.user_id
          L9_3 = L9_3(L10_3)
          L10_3 = tryGetTruckerMoney
          L11_3 = L8_3.user_id
          L14_3 = L8_3.day_cost
          L10_3 = L10_3(L11_3, L12_3)
          if L10_3 then
            L10_3 = L8_3.remaining_amount
            L11_3 = L8_3.taxes_on_day
            L10_3 = L10_3 - L11_3
            if L10_3 > 0 then
              L11_3 = "UPDATE `trucker_loans` SET remaining_amount = @remaining_amount, timer = @timer WHERE id = @id"
              L14_3 = Utils
              L14_3 = L14_3.Database
              L14_3 = L14_3.execute
              L13_3 = L11_3
              L14_3 = {}
              L14_3.remaining_amount = L10_3
              L15_3 = os
              L15_3 = L15_3.time
              L15_3 = L15_3()
              L14_3.timer = L15_3
              L15_3 = L8_3.id
              L14_3["@id"] = L15_3
              L14_3(L13_3, L14_3)
            else
              L11_3 = "DELETE FROM `trucker_loans` WHERE id = @id;"
              L14_3 = Utils
              L14_3 = L14_3.Database
              L14_3 = L14_3.execute
              L13_3 = L11_3
              L14_3 = {}
              L15_3 = L8_3.id
              L14_3["@id"] = L15_3
              L14_3(L13_3, L14_3)
            end
          elseif L9_3 then
            L10_3 = TriggerClientEvent
            L11_3 = "truck_logistics:Notify"
            L14_3 = L9_3
            L13_3 = "info"
            L14_3 = Utils
            L14_3 = L14_3.translate
            L15_3 = "no_loan_money"
            L14_3, L15_3 = L14_3(L15_3)
            L10_3(L11_3, L14_3, L13_3, L14_3, L15_3)
            L10_3 = deleteAllUserData
            L11_3 = L8_3.user_id
            L10_3(L11_3)
          else
            L10_3 = "UPDATE `trucker_users` SET loan_notify = 1 WHERE user_id = @user_id"
            L11_3 = Utils
            L11_3 = L11_3.Database
            L11_3 = L11_3.execute
            L14_3 = L10_3
            L13_3 = {}
            L14_3 = L8_3.user_id
            L13_3["@user_id"] = L14_3
            L11_3(L14_3, L13_3)
          end
          if L9_3 then
            L10_3 = L4_1
            L10_3 = L10_3[L9_3]
            if L10_3 then
              L10_3 = openUI
              L11_3 = L9_3
              L14_3 = true
              L10_3(L11_3, L14_3)
            end
          end
          L10_3 = Citizen
          L10_3 = L10_3.Wait
          L11_3 = 100
          L10_3(L11_3)
        end
      end
      L3_3 = Citizen
      L3_3 = L3_3.Wait
      L4_3 = 300000
      L3_3(L4_3)
    end
  end
  L0_2(L1_2)
end
updateLoansThread = generateTruckerAvailableContractsThread
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:getData"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:getData"
function fn_L9_1()
local L0_2, L1_2, L2_2
  L0_2 = Wrapper
  L1_2 = source
  function L2_2(A0_3)
local L1_3, L2_3, L3_3
    L1_3 = openUI
    L2_3 = source
    L3_3 = false
    L1_3(L2_3, L3_3)
  end
  L0_2(L1_2, L2_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:closeUI"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:closeUI"
function fn_L9_1()
local L0_2, L1_2
  L1_2 = source
  L0_2 = L4_1
  L0_2[L1_2] = nil
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:startContract"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:startContract"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = A1_2.id
  L3_2 = A1_2.party
  L4_2 = source
  L5_2 = Wrapper
  L6_2 = L4_2
  function L7_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3
    L1_3 = "SELECT * FROM `trucker_available_contracts` WHERE contract_id = @id AND progress IS NULL"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = L2_2
    L4_3["@id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    if L2_3 then
      L3_3 = L2_3[1]
      if L3_3 then
        goto lbl_17
      end
    end
    do return end
    ::lbl_17::
    L3_3 = beforeStartContract
    L4_3 = L4_2
    L5_3 = L2_2
    L3_3 = L3_3(L4_3, L5_3)
    if L3_3 then
      L3_3 = {}
      L4_3 = L3_2
      if L4_3 then
        L4_3 = Config
        L4_3 = L4_3.party
        L4_3 = L4_3.only_leader_can_start
        if L4_3 then
          L4_3 = "SELECT 1 FROM `trucker_party_members` WHERE user_id = @user_id and owner = 1"
          L5_3 = Utils
          L5_3 = L5_3.Database
          L5_3 = L5_3.fetchAll
          L8_3 = L4_3
          L7_3 = {}
          L7_3["@user_id"] = A0_3
          L5_3 = L5_3(L6_3, L7_3)
          L5_3 = L5_3[1]
          if not L5_3 then
            L8_3 = TriggerClientEvent
            L7_3 = "truck_logistics:Notify"
            L8_3 = L4_2
            L9_3 = "error"
            L10_3 = Utils
            L10_3 = L10_3.translate
            L11_3 = "not_owner"
            L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3 = L10_3(L11_3)
            L8_3(L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3)
            return
          end
        else
          L4_3 = "SELECT 1 FROM `trucker_party_members` WHERE user_id = @user_id"
          L5_3 = Utils
          L5_3 = L5_3.Database
          L5_3 = L5_3.fetchAll
          L8_3 = L4_3
          L7_3 = {}
          L7_3["@user_id"] = A0_3
          L5_3 = L5_3(L6_3, L7_3)
          L5_3 = L5_3[1]
          if not L5_3 then
            L8_3 = TriggerClientEvent
            L7_3 = "truck_logistics:Notify"
            L8_3 = L4_2
            L9_3 = "error"
            L10_3 = Utils
            L10_3 = L10_3.translate
            L11_3 = "not_in_party"
            L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3 = L10_3(L11_3)
            L8_3(L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3)
            return
          end
        end
        L4_3 = "SELECT * FROM `trucker_party_members` WHERE party_id = (SELECT party_id FROM `trucker_party_members` WHERE user_id = @user_id)"
        L5_3 = Utils
        L5_3 = L5_3.Database
        L5_3 = L5_3.fetchAll
        L8_3 = L4_3
        L7_3 = {}
        L7_3["@user_id"] = A0_3
        L5_3 = L5_3(L6_3, L7_3)
        L8_3 = pairs
        L7_3 = L5_3
        L8_3, L7_3, L8_3, L9_3 = L8_3(L7_3)
        for L10_3, L11_3 in L8_3, L7_3, L8_3, L9_3 do
          L14_3 = Utils
          L14_3 = L14_3.Framework
          L14_3 = L14_3.getPlayerSource
          L13_3 = L11_3.user_id
          L14_3 = L14_3(L13_3)
          if L14_3 then
            L13_3 = GetPlayerPed
            L14_3 = L12_3
            L13_3 = L13_3(L14_3)
            L14_3 = GetEntityCoords
            L15_3 = L13_3
            L14_3 = L14_3(L15_3)
            L15_3 = vector3
            L16_3 = table
            L16_3 = L16_3.unpack
            L19_3 = Config
            L19_3 = L19_3.trucker_locations
            L18_3 = A0_2
            L19_3 = L19_3[L18_3]
            L19_3 = L19_3.menu_location
            L16_3, L19_3, L18_3, L19_3, L20_3, L21_3 = L16_3(L19_3)
            L15_3 = L15_3(L16_3, L17_3, L18_3, L19_3, L20_3, L21_3)
            L15_3 = L14_3 - L15_3
            L15_3 = #L15_3
            if L15_3 < 40.0 then
              L16_3 = table
              L16_3 = L16_3.insert
              L19_3 = L3_3
              L18_3 = {}
              L19_3 = L11_3.user_id
              L18_3.user_id = L19_3
              L18_3.source = L14_3
              L16_3(L19_3, L18_3)
              L16_3 = TriggerClientEvent
              L19_3 = "truck_logistics:Notify"
              L18_3 = L12_3
              L19_3 = "info"
              L20_3 = Utils
              L20_3 = L20_3.translate
              L21_3 = "party_starting_contract"
              L20_3, L21_3 = L20_3(L21_3)
              L16_3(L19_3, L18_3, L19_3, L20_3, L21_3)
              L16_3 = TriggerClientEvent
              L19_3 = "truck_logistics:closeUIToStartContract"
              L18_3 = L12_3
              L16_3(L19_3, L18_3)
            end
          end
        end
        L8_3 = #L3_3
        L7_3 = Config
        L7_3 = L7_3.trucker_locations
        L8_3 = A0_2
        L7_3 = L7_3[L8_3]
        L7_3 = L7_3.garage_location
        L7_3 = #L7_3
        if not (L8_3 > L7_3) then
          L8_3 = #L3_3
          L7_3 = Config
          L7_3 = L7_3.trucker_locations
          L8_3 = A0_2
          L7_3 = L7_3[L8_3]
          L7_3 = L7_3.trailer_location
          L7_3 = #L7_3
        end
        if L8_3 > L7_3 then
          L8_3 = TriggerClientEvent
          L7_3 = "truck_logistics:Notify"
          L8_3 = L4_2
          L9_3 = "error"
          L10_3 = Utils
          L10_3 = L10_3.translate
          L11_3 = "not_enough_slots"
          L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3 = L10_3(L11_3)
          L8_3(L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3)
          return
        end
      else
        L4_3 = table
        L4_3 = L4_3.insert
        L5_3 = L3_3
        L8_3 = {}
        L8_3.user_id = A0_3
        L7_3 = L4_2
        L8_3.source = L7_3
        L4_3(L5_3, L8_3)
      end
      L4_3 = true
      L5_3 = updateContractsRewardAndDistance
      L8_3 = L4_2
      L7_3 = L2_3
      L5_3(L8_3, L7_3)
      L5_3 = pairs
      L8_3 = L3_3
      L5_3, L8_3, L7_3, L8_3 = L5_3(L8_3)
      for L9_3, L10_3 in L5_3, L8_3, L7_3, L8_3 do
        L14_3 = L10_3.source
        L11_3 = L6_1
        L11_3 = L11_3[L12_3]
        if L11_3 then
          L4_3 = false
          L11_3 = TriggerClientEvent
          L14_3 = "truck_logistics:Notify"
          L13_3 = L10_3.source
          L14_3 = "error"
          L15_3 = Utils
          L15_3 = L15_3.translate
          L16_3 = "already_has_cargo"
          L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3 = L15_3(L16_3)
          L11_3(L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3)
        end
        L11_3 = checkMemberSkills
        L14_3 = L10_3.source
        L13_3 = L2_3
        L11_3 = L11_3(L12_3, L13_3)
        if not L11_3 then
          L4_3 = false
        end
        L11_3 = Wait
        L14_3 = 10
        L11_3(L14_3)
      end
      if L4_3 then
        L5_3 = pairs
        L8_3 = L3_3
        L5_3, L8_3, L7_3, L8_3 = L5_3(L8_3)
        for L9_3, L10_3 in L5_3, L8_3, L7_3, L8_3 do
          L11_3 = tonumber
          L14_3 = L2_3[1]
          L14_3 = L14_3.contract_type
          L11_3 = L11_3(L12_3)
          if 0 == L11_3 then
            L14_3 = L10_3.source
            L11_3 = L6_1
            L13_3 = {}
            L14_3 = L2_3[1]
            L13_3.contract_data = L14_3
            L14_3 = L3_2
            L13_3.is_party = L14_3
            L14_3 = os
            L14_3 = L14_3.time
            L14_3 = L14_3()
            L13_3.start_time = L14_3
            L11_3[L14_3] = L13_3
            L11_3 = TriggerClientEvent
            L14_3 = "truck_logistics:startContract"
            L13_3 = L10_3.source
            L14_3 = A0_2
            L15_3 = L2_3[1]
            L16_3 = L9_3
            L11_3(L14_3, L13_3, L14_3, L15_3, L16_3)
          else
            L14_3 = L10_3.source
            L11_3 = L6_1
            L13_3 = {}
            L14_3 = L2_3[1]
            L13_3.contract_data = L14_3
            L14_3 = L3_2
            L13_3.is_party = L14_3
            L14_3 = os
            L14_3 = L14_3.time
            L14_3 = L14_3()
            L13_3.start_time = L14_3
            L11_3[L14_3] = L13_3
            L11_3 = TriggerClientEvent
            L14_3 = "truck_logistics:startContract"
            L13_3 = L10_3.source
            L14_3 = A0_2
            L15_3 = L2_3[1]
            L16_3 = L9_3
            L11_3(L14_3, L13_3, L14_3, L15_3, L16_3)
          end
          L11_3 = Wait
          L14_3 = 1000
          L11_3(L14_3)
        end
      else
        L5_3 = L3_2
        if L5_3 then
          L5_3 = TriggerClientEvent
          L8_3 = "truck_logistics:Notify"
          L7_3 = L4_2
          L8_3 = "error"
          L9_3 = Utils
          L9_3 = L9_3.translate
          L10_3 = "party_cannot_start_job"
          L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3 = L9_3(L10_3)
          L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3)
        end
      end
    end
  end
  L5_2(L6_2, L7_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
function generateTruckerAvailableContractsThread(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = Utils
  L2_2 = L2_2.Framework
  L2_2 = L2_2.getPlayerId
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  if A1_2 then
    L3_2 = A1_2[1]
    if L3_2 then
      L3_2 = "SELECT * FROM `trucker_users` WHERE user_id = @user_id"
      L4_2 = Utils
      L4_2 = L4_2.Database
      L4_2 = L4_2.fetchAll
      L5_2 = L3_2
      L6_2 = {}
      L6_2["@user_id"] = L2_2
      L4_2 = L4_2(L5_2, L6_2)
      if L4_2 then
        L5_2 = L4_2[1]
        if L5_2 then
          L5_2 = tonumber
          L6_2 = L4_2[1]
          L6_2 = L6_2.product_type
          L5_2 = L5_2(L6_2)
          L6_2 = tonumber
          L7_2 = A1_2[1]
          L7_2 = L7_2.cargo_type
          L6_2 = L6_2(L7_2)
          if L5_2 >= L6_2 then
            L5_2 = tonumber
            L6_2 = L4_2[1]
            L6_2 = L6_2.fragile
            L5_2 = L5_2(L6_2)
            L6_2 = tonumber
            L7_2 = A1_2[1]
            L7_2 = L7_2.fragile
            L6_2 = L6_2(L7_2)
            if L5_2 >= L6_2 then
              L5_2 = tonumber
              L6_2 = L4_2[1]
              L6_2 = L6_2.valuable
              L5_2 = L5_2(L6_2)
              L6_2 = tonumber
              L7_2 = A1_2[1]
              L7_2 = L7_2.valuable
              L6_2 = L6_2(L7_2)
              if L5_2 >= L6_2 then
                L5_2 = tonumber
                L6_2 = L4_2[1]
                L6_2 = L6_2.fast
                L5_2 = L5_2(L6_2)
                L6_2 = tonumber
                L7_2 = A1_2[1]
                L7_2 = L7_2.fast
                L6_2 = L6_2(L7_2)
                if L5_2 >= L6_2 then
                  L5_2 = Config
                  L5_2 = L5_2.distance_skill
                  L6_2 = tonumber
                  L7_2 = L4_2[1]
                  L7_2 = L7_2.distance
                  L6_2 = L6_2(L7_2)
                  L5_2 = L5_2[L6_2]
                  L6_2 = tonumber
                  L7_2 = A1_2[1]
                  L7_2 = L7_2.distance
                  L6_2 = L6_2(L7_2)
                  if L5_2 >= L6_2 then
                    L5_2 = tonumber
                    L6_2 = L4_2[1]
                    L6_2 = L6_2.illegal
                    L5_2 = L5_2(L6_2)
                    L6_2 = tonumber
                    L7_2 = A1_2[1]
                    L7_2 = L7_2.illegal
                    L6_2 = L6_2(L7_2)
                    if L5_2 >= L6_2 then
                      L5_2 = true
                      return L5_2
                    end
                  else
                    L5_2 = TriggerClientEvent
                    L6_2 = "truck_logistics:Notify"
                    L7_2 = A0_2
                    L8_2 = "error"
                    L9_2 = Utils
                    L9_2 = L9_2.translate
                    L10_2 = "no_skill_1"
                    L9_2, L10_2 = L9_2(L10_2)
                    L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
                  end
                else
                  L5_2 = TriggerClientEvent
                  L6_2 = "truck_logistics:Notify"
                  L7_2 = A0_2
                  L8_2 = "error"
                  L9_2 = Utils
                  L9_2 = L9_2.translate
                  L10_2 = "no_skill_2"
                  L9_2, L10_2 = L9_2(L10_2)
                  L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
                end
              else
                L5_2 = TriggerClientEvent
                L6_2 = "truck_logistics:Notify"
                L7_2 = A0_2
                L8_2 = "error"
                L9_2 = Utils
                L9_2 = L9_2.translate
                L10_2 = "no_skill_3"
                L9_2, L10_2 = L9_2(L10_2)
                L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
              end
            else
              L5_2 = TriggerClientEvent
              L6_2 = "truck_logistics:Notify"
              L7_2 = A0_2
              L8_2 = "error"
              L9_2 = Utils
              L9_2 = L9_2.translate
              L10_2 = "no_skill_4"
              L9_2, L10_2 = L9_2(L10_2)
              L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
            end
          else
            L5_2 = TriggerClientEvent
            L6_2 = "truck_logistics:Notify"
            L7_2 = A0_2
            L8_2 = "error"
            L9_2 = Utils
            L9_2 = L9_2.translate
            L10_2 = "no_skill_5"
            L9_2, L10_2 = L9_2(L10_2)
            L5_2(L6_2, L7_2, L8_2, L9_2, L10_2)
          end
        end
      end
  end
  else
    L3_2 = TriggerClientEvent
    L4_2 = "truck_logistics:Notify"
    L5_2 = A0_2
    L6_2 = "error"
    L7_2 = Utils
    L7_2 = L7_2.translate
    L8_2 = "job_already_started"
    L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
    L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  end
end
checkMemberSkills = generateTruckerAvailableContractsThread
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:spawnTruck"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:spawnTruck"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3
    L1_3 = A1_2.truck_id
    L2_3 = "SELECT * FROM `trucker_trucks` WHERE truck_id = @truck_id"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.fetchAll
    L4_3 = L2_3
    L5_3 = {}
    L8_3 = tonumber
    L7_3 = L1_3
    L8_3 = L8_3(L7_3)
    L5_3["@truck_id"] = L8_3
    L3_3 = L3_3(L4_3, L5_3)
    if L3_3 then
      L4_3 = L3_3[1]
      if L4_3 then
        L4_3 = TriggerClientEvent
        L5_3 = "truck_logistics:spawnTruck"
        L8_3 = L2_2
        L7_3 = L3_3[1]
        L4_3(L5_3, L8_3, L7_3)
      end
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:upgradeSkill"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:upgradeSkill"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3
    L1_3 = "SELECT * FROM `trucker_users` WHERE user_id = @user_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L4_3["@user_id"] = A0_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    L3_3 = L2_3.skill_points
    L4_3 = A1_2.value
    L5_3 = A1_2.id
    L5_3 = L2_3[L5_3]
    L4_3 = L4_3 - L5_3
    if L3_3 >= L4_3 then
      L3_3 = "UPDATE `trucker_users` SET "
      L4_3 = A1_2.id
      L5_3 = " = @value, skill_points = @skill_points WHERE user_id = @user_id"
      L3_3 = L3_3 .. L4_3 .. L5_3
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L8_3 = {}
      L8_3["@user_id"] = A0_3
      L7_3 = A1_2.value
      L8_3["@value"] = L7_3
      L7_3 = L2_3.skill_points
      L8_3 = A1_2.value
      L9_3 = A1_2.id
      L9_3 = L2_3[L9_3]
      L8_3 = L8_3 - L9_3
      L7_3 = L7_3 - L8_3
      L8_3["@skill_points"] = L7_3
      L4_3(L5_3, L8_3)
      L4_3 = TriggerClientEvent
      L5_3 = "truck_logistics:Notify"
      L8_3 = L2_2
      L7_3 = "success"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L9_3 = "upgraded_skill"
      L8_3, L9_3 = L8_3(L9_3)
      L4_3(L5_3, L8_3, L7_3, L8_3, L9_3)
      L4_3 = openUI
      L5_3 = L2_2
      L8_3 = true
      L4_3(L5_3, L8_3)
    else
      L3_3 = TriggerClientEvent
      L4_3 = "truck_logistics:Notify"
      L5_3 = L2_2
      L8_3 = "error"
      L7_3 = Utils
      L7_3 = L7_3.translate
      L8_3 = "insufficient_skill_points"
      L7_3, L8_3, L9_3 = L7_3(L8_3)
      L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3)
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:repairTruck"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:repairTruck"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3
    L1_3 = "SELECT * FROM `trucker_trucks` WHERE user_id = @user_id AND driver = 0"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L4_3["@user_id"] = A0_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if L2_3 then
      L3_3 = math
      L3_3 = L3_3.floor
      L4_3 = tonumber
      L5_3 = A1_2.id
      L5_3 = L2_3[L5_3]
      L4_3 = L4_3(L5_3)
      L4_3 = L4_3 / 10
      L5_3 = 100
      L4_3 = L5_3 - L4_3
      L5_3 = Config
      L5_3 = L5_3.repair_price
      L8_3 = A1_2.id
      L5_3 = L5_3[L6_3]
      L4_3 = L4_3 * L5_3
      L3_3 = L3_3(L4_3)
      if L3_3 > 0 then
        L4_3 = tryGetTruckerMoney
        L5_3 = A0_3
        L8_3 = L3_3
        L4_3 = L4_3(L5_3, L6_3)
        if L4_3 then
          L4_3 = A1_2.id
          if "wheels" == L4_3 then
            L4_3 = json
            L4_3 = L4_3.decode
            L5_3 = L2_3.properties
            L4_3 = L4_3(L5_3)
            if not L4_3 then
              L4_3 = {}
            end
            L5_3 = {}
            L4_3.tyres = L5_3
            L5_3 = "UPDATE `trucker_trucks` SET wheels = 1000, properties = @properties WHERE user_id = @user_id AND driver = 0"
            L8_3 = Utils
            L8_3 = L8_3.Database
            L8_3 = L8_3.execute
            L7_3 = L5_3
            L8_3 = {}
            L9_3 = json
            L9_3 = L9_3.encode
            L10_3 = L4_3
            L9_3 = L9_3(L10_3)
            L8_3["@properties"] = L9_3
            L8_3["@user_id"] = A0_3
            L8_3(L7_3, L8_3)
          else
            L4_3 = "UPDATE `trucker_trucks` SET "
            L5_3 = A1_2.id
            L8_3 = " = 1000 WHERE user_id = @user_id AND driver = 0"
            L4_3 = L4_3 .. L5_3 .. L6_3
            L5_3 = Utils
            L5_3 = L5_3.Database
            L5_3 = L5_3.execute
            L8_3 = L4_3
            L7_3 = {}
            L7_3["@user_id"] = A0_3
            L5_3(L8_3, L7_3)
          end
          L4_3 = TriggerClientEvent
          L5_3 = "truck_logistics:Notify"
          L8_3 = L2_2
          L7_3 = "success"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L9_3 = "repaired"
          L8_3, L9_3, L10_3 = L8_3(L9_3)
          L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3)
          L4_3 = openUI
          L5_3 = L2_2
          L8_3 = true
          L4_3(L5_3, L8_3)
        else
          L4_3 = TriggerClientEvent
          L5_3 = "truck_logistics:Notify"
          L8_3 = L2_2
          L7_3 = "error"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L9_3 = "insufficiente_funds"
          L8_3, L9_3, L10_3 = L8_3(L9_3)
          L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3)
        end
      else
        L4_3 = TriggerClientEvent
        L5_3 = "truck_logistics:Notify"
        L8_3 = L2_2
        L7_3 = "error"
        L8_3 = Utils
        L8_3 = L8_3.translate
        L9_3 = "not_repaired"
        L8_3, L9_3, L10_3 = L8_3(L9_3)
        L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3)
      end
    else
      L3_3 = TriggerClientEvent
      L4_3 = "truck_logistics:Notify"
      L5_3 = L2_2
      L8_3 = "error"
      L7_3 = Utils
      L7_3 = L7_3.translate
      L8_3 = "have_no_truck"
      L7_3, L8_3, L9_3, L10_3 = L7_3(L8_3)
      L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3)
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:buyTruck"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:buyTruck"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3
    L1_3 = Config
    L1_3 = L1_3.dealership
    L2_3 = A1_2.truck_name
    L1_3 = L1_3[L2_3]
    L1_3 = L1_3.price
    L2_3 = Config
    L2_3 = L2_3.dealership
    L3_3 = A1_2.truck_name
    L2_3 = L2_3[L3_3]
    L2_3 = L2_3.required_level
    L3_3 = beforeBuyTruck
    L4_3 = L2_2
    L5_3 = A1_2.truck_name
    L8_3 = L1_3
    L7_3 = A0_3
    L3_3 = L3_3(L4_3, L5_3, L6_3, L7_3)
    if L3_3 then
      L3_3 = getPlayerLevel
      L4_3 = A0_3
      L3_3 = L3_3(L4_3)
      if L2_3 <= L3_3 then
        L3_3 = tryGetTruckerMoney
        L4_3 = A0_3
        L5_3 = L1_3
        L3_3 = L3_3(L4_3, L5_3)
        if L3_3 then
          L3_3 = "INSERT INTO `trucker_trucks` (user_id, truck_name, driver, properties) VALUES (@user_id, @name, NULL, @properties);"
          L4_3 = Utils
          L4_3 = L4_3.Database
          L4_3 = L4_3.execute
          L5_3 = L3_3
          L8_3 = {}
          L8_3["@user_id"] = A0_3
          L7_3 = A1_2.truck_name
          L8_3["@name"] = L7_3
          L7_3 = json
          L7_3 = L7_3.encode
          L8_3 = {}
          L7_3 = L7_3(L8_3)
          L8_3["@properties"] = L7_3
          L4_3(L5_3, L8_3)
          L4_3 = TriggerClientEvent
          L5_3 = "truck_logistics:Notify"
          L8_3 = L2_2
          L7_3 = "success"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L9_3 = "bought"
          L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3 = L8_3(L9_3)
          L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3)
          L4_3 = Utils
          L4_3 = L4_3.Webhook
          L4_3 = L4_3.sendWebhookMessage
          L5_3 = WebhookURL
          L8_3 = Utils
          L8_3 = L8_3.translate
          L7_3 = "logs_buytruck"
          L8_3 = L8_3(L7_3)
          L7_3 = L6_3
          L8_3 = L8_3.format
          L8_3 = A1_2.truck_name
          L9_3 = L1_3
          L10_3 = Utils
          L10_3 = L10_3.Framework
          L10_3 = L10_3.getPlayerIdLog
          L11_3 = L2_2
          L10_3 = L10_3(L11_3)
          L11_3 = os
          L11_3 = L11_3.date
          L14_3 = [[

[]]
          L13_3 = Utils
          L13_3 = L13_3.translate
          L14_3 = "logs_date"
          L13_3 = L13_3(L14_3)
          L14_3 = "]: %d/%m/%Y ["
          L15_3 = Utils
          L15_3 = L15_3.translate
          L16_3 = "logs_hour"
          L15_3 = L15_3(L16_3)
          L16_3 = "]: %H:%M:%S"
          L14_3 = L14_3 .. L13_3 .. L14_3 .. L15_3 .. L16_3
          L11_3 = L11_3(L12_3)
          L10_3 = L10_3 .. L11_3
          L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3 = L8_3(L7_3, L8_3, L9_3, L10_3)
          L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3)
          L4_3 = afterBuyTruck
          L5_3 = L2_2
          L8_3 = A1_2.truck_name
          L7_3 = L1_3
          L8_3 = A0_3
          L4_3(L5_3, L8_3, L7_3, L8_3)
          L4_3 = openUI
          L5_3 = L2_2
          L8_3 = true
          L4_3(L5_3, L8_3)
        else
          L3_3 = TriggerClientEvent
          L4_3 = "truck_logistics:Notify"
          L5_3 = L2_2
          L8_3 = "error"
          L7_3 = Utils
          L7_3 = L7_3.translate
          L8_3 = "insufficiente_funds"
          L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3 = L7_3(L8_3)
          L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3)
        end
      end
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:sellTruck"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:sellTruck"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3
    L1_3 = "SELECT * FROM `trucker_trucks` WHERE truck_id = @truck_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A1_2.truck_id
    L4_3["@truck_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if L2_3 then
      L3_3 = math
      L3_3 = L3_3.floor
      L4_3 = tonumber
      L5_3 = Config
      L5_3 = L5_3.dealership
      L8_3 = A1_2.truck_name
      L5_3 = L5_3[L6_3]
      L5_3 = L5_3.price
      L8_3 = Config
      L8_3 = L8_3.sell_price_multiplier
      L5_3 = L5_3 * L6_3
      L4_3 = L4_3(L5_3)
      if not L4_3 then
        L4_3 = 0
      end
      L3_3 = L3_3(L4_3)
      L4_3 = beforeSellTruck
      L5_3 = L2_2
      L8_3 = A1_2.truck_name
      L7_3 = L3_3
      L8_3 = A0_3
      L4_3 = L4_3(L5_3, L6_3, L7_3, L8_3)
      if L4_3 then
        L4_3 = "DELETE FROM `trucker_trucks` WHERE truck_id = @truck_id;"
        L5_3 = Utils
        L5_3 = L5_3.Database
        L5_3 = L5_3.execute
        L8_3 = L4_3
        L7_3 = {}
        L8_3 = A1_2.truck_id
        L7_3["@truck_id"] = L8_3
        L5_3(L8_3, L7_3)
        L5_3 = giveTruckerMoney
        L8_3 = A0_3
        L7_3 = L3_3
        L5_3(L8_3, L7_3)
        L5_3 = TriggerClientEvent
        L8_3 = "truck_logistics:Notify"
        L7_3 = L2_2
        L8_3 = "success"
        L9_3 = Utils
        L9_3 = L9_3.translate
        L10_3 = "sold"
        L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3 = L9_3(L10_3)
        L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3)
        L5_3 = Utils
        L5_3 = L5_3.Webhook
        L5_3 = L5_3.sendWebhookMessage
        L8_3 = WebhookURL
        L7_3 = Utils
        L7_3 = L7_3.translate
        L8_3 = "logs_selltruck"
        L7_3 = L7_3(L8_3)
        L8_3 = L7_3
        L7_3 = L7_3.format
        L9_3 = A1_2.truck_name
        L10_3 = L3_3
        L11_3 = Utils
        L11_3 = L11_3.Framework
        L11_3 = L11_3.getPlayerIdLog
        L14_3 = L2_2
        L11_3 = L11_3(L12_3)
        L14_3 = os
        L14_3 = L14_3.date
        L13_3 = [[

[]]
        L14_3 = Utils
        L14_3 = L14_3.translate
        L15_3 = "logs_date"
        L14_3 = L14_3(L15_3)
        L15_3 = "]: %d/%m/%Y ["
        L16_3 = Utils
        L16_3 = L16_3.translate
        L19_3 = "logs_hour"
        L16_3 = L16_3(L17_3)
        L19_3 = "]: %H:%M:%S"
        L13_3 = L13_3 .. L14_3 .. L15_3 .. L16_3 .. L17_3
        L14_3 = L14_3(L13_3)
        L11_3 = L11_3 .. L12_3
        L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3 = L7_3(L8_3, L9_3, L10_3, L11_3)
        L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3)
        L5_3 = afterSellTruck
        L8_3 = L2_2
        L7_3 = A1_2.truck_name
        L8_3 = L3_3
        L9_3 = A0_3
        L5_3(L8_3, L7_3, L8_3, L9_3)
        L5_3 = openUI
        L8_3 = L2_2
        L7_3 = true
        L5_3(L8_3, L7_3)
      end
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:refuelTruck"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:refuelTruck"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3
    L1_3 = A1_2.truck_id
    L2_3 = "SELECT fuel FROM trucker_trucks WHERE truck_id = @truck_id"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.fetchAll
    L4_3 = L2_3
    L5_3 = {}
    L5_3["@truck_id"] = L1_3
    L3_3 = L3_3(L4_3, L5_3)
    L3_3 = L3_3[1]
    if L3_3 then
      L4_3 = tonumber
      L5_3 = L3_3.fuel
      L4_3 = L4_3(L5_3)
      L5_3 = 100
      L4_3 = L5_3 - L4_3
      if L4_3 > 0 then
        L5_3 = assert
        L8_3 = Config
        L8_3 = L8_3.repair_price
        L8_3 = L8_3.fuel
        L7_3 = "Missing Config.repair_price.fuel config"
        L5_3(L8_3, L7_3)
        L5_3 = tryGetTruckerMoney
        L8_3 = A0_3
        L7_3 = Config
        L7_3 = L7_3.repair_price
        L7_3 = L7_3.fuel
        L7_3 = L4_3 * L7_3
        L5_3 = L5_3(L6_3, L7_3)
        if L5_3 then
          L5_3 = "UPDATE `trucker_trucks` SET fuel = 100 WHERE truck_id = @truck_id"
          L8_3 = Utils
          L8_3 = L8_3.Database
          L8_3 = L8_3.execute
          L7_3 = L5_3
          L8_3 = {}
          L8_3["@truck_id"] = L1_3
          L8_3(L7_3, L8_3)
          L8_3 = TriggerClientEvent
          L7_3 = "truck_logistics:Notify"
          L8_3 = L2_2
          L9_3 = "success"
          L10_3 = Utils
          L10_3 = L10_3.translate
          L11_3 = "refueled"
          L10_3, L11_3 = L10_3(L11_3)
          L8_3(L7_3, L8_3, L9_3, L10_3, L11_3)
          L8_3 = openUI
          L7_3 = L2_2
          L8_3 = true
          L8_3(L7_3, L8_3)
        else
          L5_3 = TriggerClientEvent
          L8_3 = "truck_logistics:Notify"
          L7_3 = L2_2
          L8_3 = "error"
          L9_3 = Utils
          L9_3 = L9_3.translate
          L10_3 = "insufficient_money"
          L9_3, L10_3, L11_3 = L9_3(L10_3)
          L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3)
        end
      else
        L5_3 = TriggerClientEvent
        L8_3 = "truck_logistics:Notify"
        L7_3 = L2_2
        L8_3 = "error"
        L9_3 = Utils
        L9_3 = L9_3.translate
        L10_3 = "not_repaired"
        L9_3, L10_3, L11_3 = L9_3(L10_3)
        L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3)
      end
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:hireDriver"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:hireDriver"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3
    L1_3 = A1_2.driver_id
    L2_3 = "SELECT COUNT(driver_id) as qtd FROM trucker_drivers WHERE user_id = @user_id"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.fetchAll
    L4_3 = L2_3
    L5_3 = {}
    L5_3["@user_id"] = A0_3
    L3_3 = L3_3(L4_3, L5_3)
    L3_3 = L3_3[1]
    L3_3 = L3_3.qtd
    L4_3 = tonumber
    L5_3 = L3_3
    L4_3 = L4_3(L5_3)
    L5_3 = getMaxDrivers
    L8_3 = A0_3
    L5_3 = L5_3(L6_3)
    if L4_3 < L5_3 then
      L4_3 = "SELECT price FROM trucker_drivers WHERE driver_id = @driver_id"
      L5_3 = Utils
      L5_3 = L5_3.Database
      L5_3 = L5_3.fetchAll
      L8_3 = L4_3
      L7_3 = {}
      L7_3["@driver_id"] = L1_3
      L5_3 = L5_3(L6_3, L7_3)
      L5_3 = L5_3[1]
      L8_3 = beforeHireDriver
      L7_3 = L2_2
      L8_3 = L5_3.price
      L9_3 = A0_3
      L8_3 = L8_3(L7_3, L8_3, L9_3)
      if L8_3 then
        L8_3 = tryGetTruckerMoney
        L7_3 = A0_3
        L8_3 = L5_3.price
        L8_3 = L8_3(L7_3, L8_3)
        if L8_3 then
          L8_3 = "UPDATE `trucker_drivers` SET user_id = @user_id WHERE driver_id = @driver_id"
          L7_3 = Utils
          L7_3 = L7_3.Database
          L7_3 = L7_3.execute
          L8_3 = L6_3
          L9_3 = {}
          L9_3["@user_id"] = A0_3
          L9_3["@driver_id"] = L1_3
          L7_3(L8_3, L9_3)
          L7_3 = TriggerClientEvent
          L8_3 = "truck_logistics:Notify"
          L9_3 = L2_2
          L10_3 = "success"
          L11_3 = Utils
          L11_3 = L11_3.translate
          L14_3 = "hired"
          L11_3, L14_3 = L11_3(L14_3)
          L7_3(L8_3, L9_3, L10_3, L11_3, L14_3)
          L7_3 = afterHireDriver
          L8_3 = L2_2
          L9_3 = L5_3.price
          L10_3 = A0_3
          L7_3(L8_3, L9_3, L10_3)
          L7_3 = openUI
          L8_3 = L2_2
          L9_3 = true
          L7_3(L8_3, L9_3)
        else
          L8_3 = TriggerClientEvent
          L7_3 = "truck_logistics:Notify"
          L8_3 = L2_2
          L9_3 = "error"
          L10_3 = Utils
          L10_3 = L10_3.translate
          L11_3 = "insufficient_money"
          L10_3, L11_3, L14_3 = L10_3(L11_3)
          L8_3(L7_3, L8_3, L9_3, L10_3, L11_3, L14_3)
        end
      end
    else
      L4_3 = TriggerClientEvent
      L5_3 = "truck_logistics:Notify"
      L8_3 = L2_2
      L7_3 = "error"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L9_3 = "max_drivers"
      L8_3, L9_3, L10_3, L11_3, L14_3 = L8_3(L9_3)
      L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3)
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:fireDriver"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:fireDriver"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3
    L1_3 = A1_2.driver_id
    L2_3 = "UPDATE `trucker_drivers` SET user_id = NULL WHERE driver_id = @driver_id"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.execute
    L4_3 = L2_3
    L5_3 = {}
    L5_3["@driver_id"] = L1_3
    L3_3(L4_3, L5_3)
    L3_3 = "UPDATE `trucker_trucks` SET driver = NULL WHERE driver = @driver_id"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.execute
    L5_3 = L3_3
    L8_3 = {}
    L8_3["@driver_id"] = L1_3
    L4_3(L5_3, L8_3)
    L4_3 = TriggerClientEvent
    L5_3 = "truck_logistics:Notify"
    L8_3 = L2_2
    L7_3 = "success"
    L8_3 = Utils
    L8_3 = L8_3.translate
    L9_3 = "fired"
    L8_3, L9_3 = L8_3(L9_3)
    L4_3(L5_3, L8_3, L7_3, L8_3, L9_3)
    L4_3 = openUI
    L5_3 = L2_2
    L8_3 = true
    L4_3(L5_3, L8_3)
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:setDriver"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:setDriver"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3
    L1_3 = tonumber
    L2_3 = A1_2.driver_id
    L1_3 = L1_3(L2_3)
    A1_2.driver_id = L1_3
    L1_3 = tonumber
    L2_3 = A1_2.truck_id
    L1_3 = L1_3(L2_3)
    A1_2.truck_id = L1_3
    L1_3 = "SELECT 1 FROM `trucker_trucks` WHERE truck_id = @truck_id AND body > 700 AND engine > 700 AND transmission > 700 AND wheels > 700 AND fuel > 20"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A1_2.truck_id
    L4_3["@truck_id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L3_3 = A1_2.driver_id
    if 0 ~= L3_3 then
      L3_3 = A1_2.driver_id
      if nil ~= L3_3 then
        L3_3 = A1_2.truck_id
        if nil ~= L3_3 then
          if not L2_3 then
            goto lbl_60
          end
          L3_3 = L2_3[1]
          if not L3_3 then
            goto lbl_60
          end
        end
      end
    end
    L3_3 = "UPDATE `trucker_trucks` SET driver = NULL WHERE driver = @driver_id"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.execute
    L5_3 = L3_3
    L8_3 = {}
    L7_3 = A1_2.driver_id
    L8_3["@driver_id"] = L7_3
    L4_3(L5_3, L8_3)
    L4_3 = "UPDATE `trucker_trucks` SET driver = @driver_id WHERE truck_id = @truck_id"
    L5_3 = Utils
    L5_3 = L5_3.Database
    L5_3 = L5_3.execute
    L8_3 = L4_3
    L7_3 = {}
    L8_3 = A1_2.driver_id
    L7_3["@driver_id"] = L8_3
    L8_3 = A1_2.truck_id
    L7_3["@truck_id"] = L8_3
    L5_3(L8_3, L7_3)
    L5_3 = openUI
    L8_3 = L2_2
    L7_3 = true
    L5_3(L8_3, L7_3)
    goto lbl_69
    ::lbl_60::
    L3_3 = TriggerClientEvent
    L4_3 = "truck_logistics:Notify"
    L5_3 = L2_2
    L8_3 = "error"
    L7_3 = Utils
    L7_3 = L7_3.translate
    L8_3 = "too_damaged"
    L7_3, L8_3 = L7_3(L8_3)
    L3_3(L4_3, L5_3, L8_3, L7_3, L8_3)
    ::lbl_69::
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:changeTheme"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:changeTheme"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3
    L1_3 = "UPDATE `trucker_users` SET dark_theme = @dark_theme WHERE user_id = @user_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.execute
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A1_2.dark_theme
    L4_3["@dark_theme"] = L5_3
    L4_3["@user_id"] = A0_3
    L2_3(L3_3, L4_3)
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:withdrawMoney"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:withdrawMoney"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3
    L1_3 = "SELECT * FROM `trucker_loans` WHERE user_id = @user_id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L4_3["@user_id"] = A0_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if L2_3 then
      L3_3 = L2_3.remaining_amount
      if L3_3 then
        L3_3 = L2_3.remaining_amount
        if not (L3_3 <= 0) then
          goto lbl_133
        end
      end
    end
    L3_3 = "SELECT money FROM `trucker_users` WHERE user_id = @user_id"
    L4_3 = Utils
    L4_3 = L4_3.Database
    L4_3 = L4_3.fetchAll
    L5_3 = L3_3
    L8_3 = {}
    L8_3["@user_id"] = A0_3
    L4_3 = L4_3(L5_3, L6_3)
    L4_3 = L4_3[1]
    L5_3 = math
    L5_3 = L5_3.floor
    L8_3 = tonumber
    L7_3 = A1_2.amount
    L8_3 = L8_3(L7_3)
    if not L8_3 then
      L8_3 = 0
    end
    L5_3 = L5_3(L6_3)
    L8_3 = tonumber
    L7_3 = L4_3.money
    L8_3 = L8_3(L7_3)
    if not L8_3 then
      L8_3 = 0
    end
    if L5_3 and L5_3 > 0 and L5_3 <= L8_3 then
      L7_3 = beforeWithdrawMoney
      L8_3 = L2_2
      L9_3 = L5_3
      L10_3 = getAccount
      L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3 = L10_3()
      L7_3 = L7_3(L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3)
      if L7_3 then
        L7_3 = "UPDATE `trucker_users` SET money = money - @amount WHERE user_id = @user_id"
        L8_3 = Utils
        L8_3 = L8_3.Database
        L8_3 = L8_3.execute
        L9_3 = L7_3
        L10_3 = {}
        L10_3["@user_id"] = A0_3
        L10_3["@amount"] = L5_3
        L8_3(L9_3, L10_3)
        L8_3 = Utils
        L8_3 = L8_3.Framework
        L8_3 = L8_3.giveAccountMoney
        L9_3 = L2_2
        L10_3 = L5_3
        L11_3 = getAccount
        L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3 = L11_3()
        L8_3(L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3)
        L8_3 = TriggerClientEvent
        L9_3 = "truck_logistics:Notify"
        L10_3 = L2_2
        L11_3 = "success"
        L14_3 = Utils
        L14_3 = L14_3.translate
        L13_3 = "money_withdrawn"
        L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3 = L14_3(L13_3)
        L8_3(L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3)
        L8_3 = Utils
        L8_3 = L8_3.Webhook
        L8_3 = L8_3.sendWebhookMessage
        L9_3 = WebhookURL
        L10_3 = Utils
        L10_3 = L10_3.translate
        L11_3 = "logs_withdraw"
        L10_3 = L10_3(L11_3)
        L11_3 = L10_3
        L10_3 = L10_3.format
        L14_3 = L5_3
        L13_3 = Utils
        L13_3 = L13_3.Framework
        L13_3 = L13_3.getPlayerIdLog
        L14_3 = L2_2
        L13_3 = L13_3(L14_3)
        L14_3 = os
        L14_3 = L14_3.date
        L15_3 = [[

[]]
        L16_3 = Utils
        L16_3 = L16_3.translate
        L19_3 = "logs_date"
        L16_3 = L16_3(L17_3)
        L19_3 = "]: %d/%m/%Y ["
        L18_3 = Utils
        L18_3 = L18_3.translate
        L19_3 = "logs_hour"
        L18_3 = L18_3(L19_3)
        L19_3 = "]: %H:%M:%S"
        L15_3 = L15_3 .. L16_3 .. L17_3 .. L18_3 .. L19_3
        L14_3 = L14_3(L15_3)
        L13_3 = L13_3 .. L14_3
        L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3 = L10_3(L11_3, L14_3, L13_3)
        L8_3(L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3)
        L8_3 = openUI
        L9_3 = L2_2
        L10_3 = true
        L8_3(L9_3, L10_3)
      end
    else
      L7_3 = TriggerClientEvent
      L8_3 = "truck_logistics:Notify"
      L9_3 = L2_2
      L10_3 = "error"
      L11_3 = Utils
      L11_3 = L11_3.translate
      L14_3 = "insufficient_money"
      L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3 = L11_3(L14_3)
      L7_3(L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3)
      goto lbl_142
    end
    ::lbl_133::
    L3_3 = TriggerClientEvent
    L4_3 = "truck_logistics:Notify"
    L5_3 = L2_2
    L8_3 = "error"
    L7_3 = Utils
    L7_3 = L7_3.translate
    L8_3 = "pay_loans"
    L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3 = L7_3(L8_3)
    L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3)
    ::lbl_142::
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:depositMoney"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:depositMoney"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3
    L1_3 = math
    L1_3 = L1_3.floor
    L2_3 = tonumber
    L3_3 = A1_2.amount
    L2_3 = L2_3(L3_3)
    if not L2_3 then
      L2_3 = 0
    end
    L1_3 = L1_3(L2_3)
    if L1_3 and L1_3 > 0 then
      L2_3 = beforeDepositMoney
      L3_3 = L2_2
      L4_3 = L1_3
      L5_3 = getAccount
      L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3 = L5_3()
      L2_3 = L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3)
      if L2_3 then
        L2_3 = Utils
        L2_3 = L2_3.Framework
        L2_3 = L2_3.tryRemoveAccountMoney
        L3_3 = L2_2
        L4_3 = L1_3
        L5_3 = getAccount
        L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3 = L5_3()
        L2_3 = L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3)
        if L2_3 then
          L2_3 = giveTruckerMoney
          L3_3 = A0_3
          L4_3 = L1_3
          L2_3(L3_3, L4_3)
          L2_3 = TriggerClientEvent
          L3_3 = "truck_logistics:Notify"
          L4_3 = L2_2
          L5_3 = "success"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L7_3 = "money_deposited"
          L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3 = L8_3(L7_3)
          L2_3(L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
          L2_3 = Utils
          L2_3 = L2_3.Webhook
          L2_3 = L2_3.sendWebhookMessage
          L3_3 = WebhookURL
          L4_3 = Utils
          L4_3 = L4_3.translate
          L5_3 = "logs_deposit"
          L4_3 = L4_3(L5_3)
          L5_3 = L4_3
          L4_3 = L4_3.format
          L8_3 = L1_3
          L7_3 = Utils
          L7_3 = L7_3.Framework
          L7_3 = L7_3.getPlayerIdLog
          L8_3 = L2_2
          L7_3 = L7_3(L8_3)
          L8_3 = os
          L8_3 = L8_3.date
          L9_3 = [[

[]]
          L10_3 = Utils
          L10_3 = L10_3.translate
          L11_3 = "logs_date"
          L10_3 = L10_3(L11_3)
          L11_3 = "]: %d/%m/%Y ["
          L14_3 = Utils
          L14_3 = L14_3.translate
          L13_3 = "logs_hour"
          L14_3 = L14_3(L13_3)
          L13_3 = "]: %H:%M:%S"
          L9_3 = L9_3 .. L10_3 .. L11_3 .. L12_3 .. L13_3
          L8_3 = L8_3(L9_3)
          L7_3 = L7_3 .. L8_3
          L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3 = L4_3(L5_3, L8_3, L7_3)
          L2_3(L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
          L2_3 = openUI
          L3_3 = L2_2
          L4_3 = true
          L2_3(L3_3, L4_3)
        else
          L2_3 = TriggerClientEvent
          L3_3 = "truck_logistics:Notify"
          L4_3 = L2_2
          L5_3 = "error"
          L8_3 = Utils
          L8_3 = L8_3.translate
          L7_3 = "insufficient_money"
          L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3 = L8_3(L7_3)
          L2_3(L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
        end
      end
    else
      L2_3 = TriggerClientEvent
      L3_3 = "truck_logistics:Notify"
      L4_3 = L2_2
      L5_3 = "error"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L7_3 = "invalid_value"
      L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3 = L8_3(L7_3)
      L2_3(L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:loan"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:loan"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3
    L1_3 = Config
    L1_3 = L1_3.loans
    L1_3 = L1_3.plans
    L2_3 = A1_2.loan_id
    L2_3 = L2_3 + 1
    L1_3 = L1_3[L2_3]
    L2_3 = "SELECT * FROM `trucker_loans` WHERE user_id = @user_id"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.fetchAll
    L4_3 = L2_3
    L5_3 = {}
    L5_3["@user_id"] = A0_3
    L3_3 = L3_3(L4_3, L5_3)
    L4_3 = 0
    L5_3 = pairs
    L8_3 = L3_3
    L5_3, L8_3, L7_3, L8_3 = L5_3(L8_3)
    for L9_3, L10_3 in L5_3, L8_3, L7_3, L8_3 do
      L11_3 = tonumber
      L14_3 = L10_3.loan
      L11_3 = L11_3(L12_3)
      L4_3 = L4_3 + L11_3
    end
    L5_3 = tonumber
    L8_3 = A1_2.loan_id
    L5_3 = L5_3(L6_3)
    if not L5_3 then
      L5_3 = 0
    end
    A1_2.loan_id = L5_3
    L5_3 = L1_3.loan_amount
    L5_3 = L4_3 + L5_3
    L8_3 = getMaxEmprestimo
    L7_3 = A0_3
    L8_3 = L8_3(L7_3)
    if L5_3 <= L8_3 then
      L5_3 = "INSERT INTO `trucker_loans` (user_id,loan,remaining_amount,day_cost,taxes_on_day,timer) VALUES (@user_id,@loan,@remaining_amount,@day_cost,@taxes_on_day,@timer);"
      L8_3 = Utils
      L8_3 = L8_3.Database
      L8_3 = L8_3.execute
      L7_3 = L5_3
      L8_3 = {}
      L8_3["@user_id"] = A0_3
      L9_3 = L1_3.loan_amount
      L8_3["@loan"] = L9_3
      L9_3 = L1_3.loan_amount
      L8_3["@remaining_amount"] = L9_3
      L9_3 = calculateDailyPayment
      L10_3 = L1_3
      L9_3 = L9_3(L10_3)
      L8_3["@day_cost"] = L9_3
      L9_3 = math
      L9_3 = L9_3.ceil
      L10_3 = L1_3.loan_amount
      L11_3 = L1_3.repayment_days
      L10_3 = L10_3 / L11_3
      L9_3 = L9_3(L10_3)
      L8_3["@taxes_on_day"] = L9_3
      L9_3 = os
      L9_3 = L9_3.time
      L9_3 = L9_3()
      L8_3["@timer"] = L9_3
      L8_3(L7_3, L8_3)
      L8_3 = giveTruckerMoney
      L7_3 = A0_3
      L8_3 = L1_3.loan_amount
      L8_3(L7_3, L8_3)
      L8_3 = TriggerClientEvent
      L7_3 = "truck_logistics:Notify"
      L8_3 = L2_2
      L9_3 = "success"
      L10_3 = Utils
      L10_3 = L10_3.translate
      L11_3 = "loan"
      L10_3, L11_3, L14_3 = L10_3(L11_3)
      L8_3(L7_3, L8_3, L9_3, L10_3, L11_3, L14_3)
      L8_3 = openUI
      L7_3 = L2_2
      L8_3 = true
      L8_3(L7_3, L8_3)
    else
      L5_3 = TriggerClientEvent
      L8_3 = "truck_logistics:Notify"
      L7_3 = L2_2
      L8_3 = "error"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L10_3 = "no_loan"
      L9_3, L10_3, L11_3, L14_3 = L9_3(L10_3)
      L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3)
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
function generateTruckerAvailableContractsThread(A0_2)
local L1_2, L2_2, L3_2
  L1_2 = A0_2.loan_amount
  L2_2 = A0_2.interest_rate
  L2_2 = L2_2 / 100
  L1_2 = L1_2 * L2_2
  L2_2 = A0_2.loan_amount
  L2_2 = L2_2 + L1_2
  L3_2 = A0_2.repayment_days
  L3_2 = L2_2 / L3_2
  return L3_2
end
calculateDailyPayment = generateTruckerAvailableContractsThread
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:payLoan"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:payLoan"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3
    L1_3 = "SELECT * FROM `trucker_loans` WHERE id = @id"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A1_2.loan_id
    L4_3["@id"] = L5_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if not L2_3 then
      return
    end
    L3_3 = tryGetTruckerMoney
    L4_3 = A0_3
    L5_3 = L2_3.remaining_amount
    L3_3 = L3_3(L4_3, L5_3)
    if L3_3 then
      L3_3 = "DELETE FROM `trucker_loans` WHERE id = @id;"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L8_3 = {}
      L7_3 = A1_2.loan_id
      L8_3["@id"] = L7_3
      L4_3(L5_3, L8_3)
      L4_3 = TriggerClientEvent
      L5_3 = "truck_logistics:Notify"
      L8_3 = L2_2
      L7_3 = "success"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L9_3 = "loan_paid"
      L8_3, L9_3 = L8_3(L9_3)
      L4_3(L5_3, L8_3, L7_3, L8_3, L9_3)
      L4_3 = openUI
      L5_3 = L2_2
      L8_3 = true
      L4_3(L5_3, L8_3)
    else
      L3_3 = TriggerClientEvent
      L4_3 = "truck_logistics:Notify"
      L5_3 = L2_2
      L8_3 = "error"
      L7_3 = Utils
      L7_3 = L7_3.translate
      L8_3 = "insufficiente_funds"
      L7_3, L8_3, L9_3 = L7_3(L8_3)
      L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3)
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:deliveredCargo"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:deliveredCargo"
function fn_L9_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, a6_2, L20_2
  L0_2 = source
  L1_2 = GetPlayerPed
  L2_2 = L0_2
  L1_2 = L1_2(L2_2)
  L2_2 = Utils
  L2_2 = L2_2.Framework
  L2_2 = L2_2.getPlayerId
  L3_2 = L0_2
  L2_2 = L2_2(L3_2)
  if not L1_2 then
    L3_2 = print
    L4_2 = "^8["
    L5_2 = GetCurrentResourceName
    L5_2 = L5_2()
    L6_2 = "] Source ped from user "
    L7_2 = L2_2
    L8_2 = " ("
    L9_2 = GetPlayerName
    L10_2 = L0_2
    L9_2 = L9_2(L10_2)
    L10_2 = ") not found.^7"
    L4_2 = L4_2 .. L5_2 .. L6_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2
    L3_2(L4_2)
    return
  end
  L3_2 = L6_1
  L3_2 = L3_2[L0_2]
  if L3_2 then
    L3_2 = nil
    L4_2 = nil
    L5_2 = nil
    L6_2 = L6_1
    L6_2 = L6_2[L0_2]
    L6_2 = L6_2.contract_data
    L6_2 = L6_2.coords_index
    if 0 == L6_2 then
      L6_2 = L6_1
      L6_2 = L6_2[L0_2]
      L6_2 = L6_2.contract_data
      L6_2 = L6_2.external_data
      L6_2 = L6_2.x
      L7_2 = L6_1
      L7_2 = L7_2[L0_2]
      L7_2 = L7_2.contract_data
      L7_2 = L7_2.external_data
      L7_2 = L7_2.y
      L8_2 = L6_1
      L8_2 = L8_2[L0_2]
      L8_2 = L8_2.contract_data
      L8_2 = L8_2.external_data
      L5_2 = L8_2.z
      L4_2 = L7_2
      L3_2 = L6_2
    else
      L6_2 = table
      L6_2 = L6_2.unpack
      L7_2 = Config
      L7_2 = L7_2.delivery_locations
      L8_2 = L6_1
      L8_2 = L8_2[L0_2]
      L8_2 = L8_2.contract_data
      L8_2 = L8_2.coords_index
      L7_2 = L7_2[L8_2]
      L6_2, L7_2, L8_2 = L6_2(L7_2)
      L5_2 = L8_2
      L4_2 = L7_2
      L3_2 = L6_2
    end
    L6_2 = GetEntityCoords
    L7_2 = L1_2
    L6_2 = L6_2(L7_2)
    L7_2 = vector3
    L8_2 = L3_2
    L9_2 = L4_2
    L10_2 = L5_2
    L7_2 = L7_2(L8_2, L9_2, L10_2)
    L7_2 = L6_2 - L7_2
    L7_2 = #L7_2
    if L7_2 > 30.0 then
      L8_2 = print
      L9_2 = "^8["
      L10_2 = GetCurrentResourceName
      L10_2 = L10_2()
      L13_2 = "] [#1] Potential money exploit detected by user: "
      L12_2 = L2_2
      L13_2 = " ("
      L14_2 = GetPlayerName
      L15_2 = L0_2
      L14_2 = L14_2(L15_2)
      L15_2 = "). More details sent to the configured webhook."
      L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2 .. L13_2 .. L14_2 .. L15_2
      L8_2(L9_2)
      L8_2 = Utils
      L8_2 = L8_2.Webhook
      L8_2 = L8_2.sendWebhookMessage
      L9_2 = WebhookURL
      L10_2 = Utils
      L10_2 = L10_2.translate
      L13_2 = "logs_exploit"
      L10_2 = L10_2(L11_2)
      L13_2 = L10_2
      L10_2 = L10_2.format
      L12_2 = json
      L12_2 = L12_2.encode
      L13_2 = L6_2
      L12_2 = L12_2(L13_2)
      L13_2 = json
      L13_2 = L13_2.encode
      L14_2 = L6_1
      L14_2 = L14_2[L0_2]
      L13_2 = L13_2(L14_2)
      L14_2 = Utils
      L14_2 = L14_2.Framework
      L14_2 = L14_2.getPlayerIdLog
      L15_2 = L0_2
      L14_2 = L14_2(L15_2)
      L15_2 = os
      L15_2 = L15_2.date
      L16_2 = [[

[]]
      L17_2 = Utils
      L17_2 = L17_2.translate
      L18_2 = "logs_date"
      L17_2 = L17_2(L18_2)
      L18_2 = "]: %d/%m/%Y ["
      l21_2 = Utils
      l21_2 = l21_2.translate
      L20_2 = "logs_hour"
      l21_2 = l21_2(L20_2)
      L20_2 = "]: %H:%M:%S"
      L16_2 = L16_2 .. L17_2 .. L18_2 .. L19_2 .. L20_2
      L15_2 = L15_2(L16_2)
      L14_2 = L14_2 .. L15_2
      L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2, L20_2 = L10_2(L13_2, L12_2, L13_2, L14_2)
      L8_2(L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2, L20_2)
      return
    end
    L8_2 = L6_1
    L8_2 = L8_2[L0_2]
    L8_2.delivered = true
    L8_2 = L6_1
    L8_2 = L8_2[L0_2]
    L9_2 = os
    L9_2 = L9_2.time
    L9_2 = L9_2()
    L8_2.delivered_time = L9_2
  end
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:finishContract"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:finishContract"
function fn_L9_1(A0_2, A1_2, A2_2)
local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L3_2 = source
  L4_2 = GetPlayerPed
  L5_2 = L3_2
  L4_2 = L4_2(L5_2)
  L5_2 = L6_1
  L6_2 = Wrapper
  L7_2 = L3_2
  function L8_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3
    L2_3 = L3_2
    L1_3 = L5_2
    L1_3 = L1_3[L2_3]
    if L1_3 then
      L2_3 = L3_2
      L1_3 = L5_2
      L1_3 = L1_3[L2_3]
      L1_3 = L1_3.delivered
      if L1_3 then
        L2_3 = L3_2
        L1_3 = L5_2
        L1_3 = L1_3[L2_3]
        L1_3 = L1_3.is_party
        L3_3 = L3_2
        L2_3 = L5_2
        L2_3 = L2_3[L3_3]
        L2_3 = L2_3.contract_data
        L3_3 = A2_2
        L4_3 = 1001.0
        if L3_3 > L4_3 then
          L3_3 = GetEntityCoords
          L4_3 = L4_2
          L3_3 = L3_3(L4_3)
          L4_3 = print
          L5_3 = "^8["
          L8_3 = GetCurrentResourceName
          L8_3 = L8_3()
          L7_3 = "] [#2] Potential money exploit detected by user: "
          L8_3 = A0_3
          L9_3 = " ("
          L10_3 = GetPlayerName
          L11_3 = L3_2
          L10_3 = L10_3(L11_3)
          L11_3 = "). Suspicious Variable: trailer_body = "
          L14_3 = A2_2
          L13_3 = ". More details sent to the configured webhook."
          L5_3 = L5_3 .. L6_3 .. L7_3 .. L8_3 .. L9_3 .. L10_3 .. L11_3 .. L12_3 .. L13_3
          L4_3(L5_3)
          L4_3 = Utils
          L4_3 = L4_3.Webhook
          L4_3 = L4_3.sendWebhookMessage
          L5_3 = WebhookURL
          L8_3 = Utils
          L8_3 = L8_3.translate
          L7_3 = "logs_exploit"
          L8_3 = L8_3(L7_3)
          L7_3 = L6_3
          L8_3 = L8_3.format
          L8_3 = json
          L8_3 = L8_3.encode
          L9_3 = L3_3
          L8_3 = L8_3(L9_3)
          L9_3 = json
          L9_3 = L9_3.encode
          L11_3 = L3_2
          L10_3 = L5_2
          L10_3 = L10_3[L11_3]
          L9_3 = L9_3(L10_3)
          L10_3 = Utils
          L10_3 = L10_3.Framework
          L10_3 = L10_3.getPlayerIdLog
          L11_3 = L3_2
          L10_3 = L10_3(L11_3)
          L11_3 = os
          L11_3 = L11_3.date
          L14_3 = [[

[]]
          L13_3 = Utils
          L13_3 = L13_3.translate
          L14_3 = "logs_date"
          L13_3 = L13_3(L14_3)
          L14_3 = "]: %d/%m/%Y ["
          L15_3 = Utils
          L15_3 = L15_3.translate
          L16_3 = "logs_hour"
          L15_3 = L15_3(L16_3)
          L16_3 = "]: %H:%M:%S"
          L14_3 = L14_3 .. L13_3 .. L14_3 .. L15_3 .. L16_3
          L11_3 = L11_3(L12_3)
          L10_3 = L10_3 .. L11_3
          L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L8_3(L7_3, L8_3, L9_3, L10_3)
          L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
          return
        end
        L3_3 = math
        L3_3 = L3_3.floor
        L4_3 = A2_2
        L3_3 = L3_3(L4_3)
        L3_3 = L3_3 / 1000
        A2_2 = L3_3
        L3_3 = L2_3.distance
        L3_3 = L3_3 * 1000
        L4_3 = Config
        L4_3 = L4_3.exp_gain
        L4_3 = L4_3 / 100
        L3_3 = L3_3 * L4_3
        L4_3 = 0
        L5_3 = 0
        L8_3 = getPlayerLevel
        L7_3 = A0_3
        L8_3 = L8_3(L7_3)
        L7_3 = "SELECT * FROM `trucker_users` WHERE user_id = @user_id"
        L8_3 = Utils
        L8_3 = L8_3.Database
        L8_3 = L8_3.fetchAll
        L9_3 = L7_3
        L10_3 = {}
        L10_3["@user_id"] = A0_3
        L8_3 = L8_3(L9_3, L10_3)
        L8_3 = L8_3[1]
        L9_3 = L2_3.fragile
        if L9_3 > 0 then
          L9_3 = L2_3.reward
          L10_3 = Config
          L10_3 = L10_3.bonus
          L10_3 = L10_3.fragile
          L10_3 = L10_3.money_bonus_percentage
          L11_3 = L8_3.fragile
          L10_3 = L10_3[L11_3]
          L10_3 = L10_3 / 100
          L9_3 = L9_3 * L10_3
          L4_3 = L4_3 + L9_3
          L9_3 = Config
          L9_3 = L9_3.bonus
          L9_3 = L9_3.fragile
          L9_3 = L9_3.exp_bonus_percentage
          L10_3 = L8_3.fragile
          L9_3 = L9_3[L10_3]
          L9_3 = L9_3 / 100
          L9_3 = L3_3 * L9_3
          L5_3 = L5_3 + L9_3
          L9_3 = A2_2
          L10_3 = Config
          L10_3 = L10_3.jobs
          L10_3 = L10_3.special_cargo
          L10_3 = L10_3.fragile
          L10_3 = L10_3.min_health_percent
          L10_3 = L10_3 / 100
          if L9_3 < L10_3 then
            L9_3 = Config
            L9_3 = L9_3.jobs
            L9_3 = L9_3.special_cargo
            L9_3 = L9_3.fragile
            L9_3 = L9_3.reward_penalty_percent
            L9_3 = L4_3 * L9_3
            L9_3 = L9_3 / 100
            L4_3 = L4_3 - L9_3
            L9_3 = Config
            L9_3 = L9_3.jobs
            L9_3 = L9_3.special_cargo
            L9_3 = L9_3.fragile
            L9_3 = L9_3.reward_penalty_percent
            L9_3 = L5_3 * L9_3
            L9_3 = L9_3 / 100
            L5_3 = L5_3 - L9_3
            L9_3 = TriggerClientEvent
            L10_3 = "truck_logistics:Notify"
            L11_3 = L3_2
            L14_3 = "error"
            L13_3 = Utils
            L13_3 = L13_3.translate
            L14_3 = "failed_fragile_health"
            L13_3 = L13_3(L14_3)
            L14_3 = L13_3
            L13_3 = L13_3.format
            L15_3 = Config
            L15_3 = L15_3.jobs
            L15_3 = L15_3.special_cargo
            L15_3 = L15_3.fragile
            L15_3 = L15_3.min_health_percent
            L16_3 = Config
            L16_3 = L16_3.jobs
            L16_3 = L16_3.special_cargo
            L16_3 = L16_3.fragile
            L16_3 = L16_3.reward_penalty_percent
            L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L13_3(L14_3, L15_3, L16_3)
            L9_3(L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
          end
        end
        L9_3 = L2_3.valuable
        if L9_3 > 0 then
          L9_3 = L2_3.reward
          L10_3 = Config
          L10_3 = L10_3.bonus
          L10_3 = L10_3.valuable
          L10_3 = L10_3.money_bonus_percentage
          L11_3 = L8_3.valuable
          L10_3 = L10_3[L11_3]
          L10_3 = L10_3 / 100
          L9_3 = L9_3 * L10_3
          L4_3 = L4_3 + L9_3
          L9_3 = Config
          L9_3 = L9_3.bonus
          L9_3 = L9_3.valuable
          L9_3 = L9_3.exp_bonus_percentage
          L10_3 = L8_3.valuable
          L9_3 = L9_3[L10_3]
          L9_3 = L9_3 / 100
          L9_3 = L3_3 * L9_3
          L5_3 = L5_3 + L9_3
        end
        L9_3 = L2_3.fast
        if L9_3 > 0 then
          L9_3 = L2_3.reward
          L10_3 = Config
          L10_3 = L10_3.bonus
          L10_3 = L10_3.fast
          L10_3 = L10_3.money_bonus_percentage
          L11_3 = L8_3.fast
          L10_3 = L10_3[L11_3]
          L10_3 = L10_3 / 100
          L9_3 = L9_3 * L10_3
          L4_3 = L4_3 + L9_3
          L9_3 = Config
          L9_3 = L9_3.bonus
          L9_3 = L9_3.fast
          L9_3 = L9_3.exp_bonus_percentage
          L10_3 = L8_3.fast
          L9_3 = L9_3[L10_3]
          L9_3 = L9_3 / 100
          L9_3 = L3_3 * L9_3
          L5_3 = L5_3 + L9_3
          L10_3 = L3_2
          L9_3 = L5_2
          L9_3 = L9_3[L10_3]
          L9_3 = L9_3.delivered_time
          L11_3 = L3_2
          L10_3 = L5_2
          L10_3 = L10_3[L11_3]
          L10_3 = L10_3.start_time
          L9_3 = L9_3 - L10_3
          L10_3 = Config
          L10_3 = L10_3.jobs
          L10_3 = L10_3.special_cargo
          L10_3 = L10_3.urgent
          L10_3 = L10_3.seconds_per_km
          L11_3 = L2_3.distance
          L10_3 = L10_3 * L11_3
          if L9_3 > L10_3 then
            L11_3 = Config
            L11_3 = L11_3.jobs
            L11_3 = L11_3.special_cargo
            L11_3 = L11_3.urgent
            L11_3 = L11_3.reward_penalty_percent
            L11_3 = L4_3 * L11_3
            L11_3 = L11_3 / 100
            L4_3 = L4_3 - L11_3
            L11_3 = Config
            L11_3 = L11_3.jobs
            L11_3 = L11_3.special_cargo
            L11_3 = L11_3.urgent
            L11_3 = L11_3.reward_penalty_percent
            L11_3 = L5_3 * L11_3
            L11_3 = L11_3 / 100
            L5_3 = L5_3 - L11_3
            L11_3 = TriggerClientEvent
            L14_3 = "truck_logistics:Notify"
            L13_3 = L3_2
            L14_3 = "error"
            L15_3 = Utils
            L15_3 = L15_3.translate
            L16_3 = "failed_urgent_time"
            L15_3 = L15_3(L16_3)
            L16_3 = L15_3
            L15_3 = L15_3.format
            L19_3 = Config
            L19_3 = L19_3.jobs
            L19_3 = L19_3.special_cargo
            L19_3 = L19_3.urgent
            L19_3 = L19_3.reward_penalty_percent
            L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L15_3(L16_3, L19_3)
            L11_3(L14_3, L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
          end
        end
        L9_3 = L2_3.illegal
        if L9_3 > 0 then
          L9_3 = L2_3.reward
          L10_3 = Config
          L10_3 = L10_3.bonus
          L10_3 = L10_3.illegal
          L10_3 = L10_3.money_bonus_percentage
          L11_3 = L8_3.illegal
          L10_3 = L10_3[L11_3]
          L10_3 = L10_3 / 100
          L9_3 = L9_3 * L10_3
          L4_3 = L4_3 + L9_3
          L9_3 = Config
          L9_3 = L9_3.bonus
          L9_3 = L9_3.illegal
          L9_3 = L9_3.exp_bonus_percentage
          L10_3 = L8_3.illegal
          L9_3 = L9_3[L10_3]
          L9_3 = L9_3 / 100
          L9_3 = L3_3 * L9_3
          L5_3 = L5_3 + L9_3
        end
        L9_3 = L2_3.distance
        L10_3 = Config
        L10_3 = L10_3.distance_skill
        L10_3 = L10_3[0]
        if L9_3 > L10_3 then
          L9_3 = Config
          L9_3 = L9_3.bonus
          L9_3 = L9_3.distance
          L9_3 = L9_3.money_bonus_percentage
          L10_3 = L8_3.distance
          L9_3 = L9_3[L10_3]
          if L9_3 then
            L9_3 = L2_3.reward
            L10_3 = Config
            L10_3 = L10_3.bonus
            L10_3 = L10_3.distance
            L10_3 = L10_3.money_bonus_percentage
            L11_3 = L8_3.distance
            L10_3 = L10_3[L11_3]
            L10_3 = L10_3 / 100
            L9_3 = L9_3 * L10_3
            L4_3 = L4_3 + L9_3
            L9_3 = Config
            L9_3 = L9_3.bonus
            L9_3 = L9_3.distance
            L9_3 = L9_3.exp_bonus_percentage
            L10_3 = L8_3.distance
            L9_3 = L9_3[L10_3]
            L9_3 = L9_3 / 100
            L9_3 = L3_3 * L9_3
            L5_3 = L5_3 + L9_3
          end
        end
        if L1_3 then
          L9_3 = L2_3.reward
          L10_3 = Config
          L10_3 = L10_3.party
          L10_3 = L10_3.party_money_bonus
          L10_3 = L10_3 / 100
          L9_3 = L9_3 * L10_3
          L4_3 = L4_3 + L9_3
          L9_3 = Config
          L9_3 = L9_3.party
          L9_3 = L9_3.party_exp_bonus
          L9_3 = L9_3 / 100
          L9_3 = L3_3 * L9_3
          L5_3 = L5_3 + L9_3
          L9_3 = "UPDATE `trucker_party_members` SET finished_deliveries = finished_deliveries + 1 WHERE user_id = @user_id"
          L10_3 = Utils
          L10_3 = L10_3.Database
          L10_3 = L10_3.execute
          L11_3 = L9_3
          L14_3 = {}
          L14_3["@user_id"] = A0_3
          L10_3(L11_3, L14_3)
        end
        L9_3 = math
        L9_3 = L9_3.floor
        L10_3 = L2_3.reward
        L10_3 = L10_3 + L4_3
        L11_3 = A2_2
        L10_3 = L10_3 * L11_3
        L9_3 = L9_3(L10_3)
        L10_3 = math
        L10_3 = L10_3.floor
        L11_3 = L3_3 + L5_3
        L14_3 = A2_2
        L11_3 = L11_3 * L12_3
        L10_3 = L10_3(L11_3)
        L11_3 = "UPDATE `trucker_users` SET total_earned = total_earned + @reward, finished_deliveries = finished_deliveries + 1, traveled_distance = traveled_distance + @distance, exp = exp + @exp_amount WHERE user_id = @user_id"
        L14_3 = Utils
        L14_3 = L14_3.Database
        L14_3 = L14_3.execute
        L13_3 = L11_3
        L14_3 = {}
        L14_3["@reward"] = L9_3
        L15_3 = tonumber
        L16_3 = string
        L16_3 = L16_3.format
        L19_3 = "%.2f"
        L18_3 = L2_3.distance
        L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L16_3(L19_3, L18_3)
        L15_3 = L15_3(L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
        L14_3["@distance"] = L15_3
        L14_3["@exp_amount"] = L10_3
        L14_3["@user_id"] = A0_3
        L14_3(L13_3, L14_3)
        L14_3 = giveTruckerMoney
        L13_3 = A0_3
        L14_3 = L9_3
        L14_3(L13_3, L14_3)
        L14_3 = TriggerClientEvent
        L13_3 = "truck_logistics:Notify"
        L14_3 = L3_2
        L15_3 = "success"
        L16_3 = Utils
        L16_3 = L16_3.translate
        L19_3 = "reward"
        L16_3 = L16_3(L17_3)
        L19_3 = L16_3
        L16_3 = L16_3.format
        L18_3 = tostring
        L19_3 = L9_3
        L18_3 = L18_3(L19_3)
        L19_3 = tostring
        L20_3 = A2_2
        L20_3 = L20_3 * 100
        L19_3 = L19_3(L20_3)
        L20_3 = tostring
        L21_3 = L10_3
        L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L20_3(L21_3)
        L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L16_3(L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
        L14_3(L13_3, L14_3, L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
        L14_3 = getPlayerLevel
        L13_3 = A0_3
        L14_3 = L14_3(L13_3)
        L13_3 = L12_3 - L6_3
        if L13_3 > 0 then
          L13_3 = "UPDATE `trucker_users` SET skill_points = skill_points + @skill WHERE user_id = @user_id"
          L14_3 = Utils
          L14_3 = L14_3.Database
          L14_3 = L14_3.execute
          L15_3 = L13_3
          L16_3 = {}
          L19_3 = L12_3 - L6_3
          L16_3["@skill"] = L19_3
          L16_3["@user_id"] = A0_3
          L14_3(L15_3, L16_3)
          L14_3 = Utils
          L14_3 = L14_3.Webhook
          L14_3 = L14_3.sendWebhookMessage
          L15_3 = WebhookURL
          L16_3 = Utils
          L16_3 = L16_3.translate
          L19_3 = "logs_skill"
          L16_3 = L16_3(L17_3)
          L19_3 = L16_3
          L16_3 = L16_3.format
          L18_3 = L12_3 - L6_3
          L19_3 = Utils
          L19_3 = L19_3.Framework
          L19_3 = L19_3.getPlayerIdLog
          L20_3 = L3_2
          L19_3 = L19_3(L20_3)
          L20_3 = os
          L20_3 = L20_3.date
          L21_3 = [[

[]]
          L22_3 = Utils
          L22_3 = L22_3.translate
          L23_3 = "logs_date"
          L22_3 = L22_3(L23_3)
          L23_3 = "]: %d/%m/%Y ["
          L24_3 = Utils
          L24_3 = L24_3.translate
          L25_3 = "logs_hour"
          L24_3 = L24_3(L25_3)
          L25_3 = "]: %H:%M:%S"
          L21_3 = L21_3 .. L22_3 .. L23_3 .. L24_3 .. L25_3
          L20_3 = L20_3(L21_3)
          L19_3 = L19_3 .. L20_3
          L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L16_3(L19_3, L18_3, L19_3)
          L14_3(L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
        end
        L13_3 = L2_3.external_data
        if L13_3 then
          L13_3 = exports
          L14_3 = L2_3.external_data
          L14_3 = L14_3.export
          L13_3 = L13_3[L14_3]
          L14_3 = L13_3
          L13_3 = L13_3.finishTruckerContract
          L15_3 = L3_2
          L16_3 = L2_3.external_data
          L19_3 = L2_3.contract_id
          L13_3(L14_3, L15_3, L16_3, L19_3)
        end
        L13_3 = "DELETE FROM `trucker_available_contracts` WHERE contract_id = @id;"
        L14_3 = Utils
        L14_3 = L14_3.Database
        L14_3 = L14_3.execute
        L15_3 = L13_3
        L16_3 = {}
        L19_3 = L2_3.contract_id
        L16_3["@id"] = L19_3
        L14_3(L15_3, L16_3)
        L14_3 = afterfinishContract
        L15_3 = L3_2
        L16_3 = L9_3
        L19_3 = L10_3
        L18_3 = L2_3.distance
        L19_3 = L2_3
        L14_3(L15_3, L16_3, L19_3, L18_3, L19_3)
        L14_3 = Utils
        L14_3 = L14_3.Webhook
        L14_3 = L14_3.sendWebhookMessage
        L15_3 = WebhookURL
        L16_3 = Utils
        L16_3 = L16_3.translate
        L19_3 = "logs_finish"
        L16_3 = L16_3(L17_3)
        L19_3 = L16_3
        L16_3 = L16_3.format
        L18_3 = tostring
        L19_3 = L9_3
        L18_3 = L18_3(L19_3)
        L19_3 = tostring
        L20_3 = L10_3
        L19_3 = L19_3(L20_3)
        L20_3 = Utils
        L20_3 = L20_3.Framework
        L20_3 = L20_3.getPlayerIdLog
        L21_3 = L3_2
        L20_3 = L20_3(L21_3)
        L21_3 = os
        L21_3 = L21_3.date
        L22_3 = [[

[]]
        L23_3 = Utils
        L23_3 = L23_3.translate
        L24_3 = "logs_date"
        L23_3 = L23_3(L24_3)
        L24_3 = "]: %d/%m/%Y ["
        L25_3 = Utils
        L25_3 = L25_3.translate
        L26_3 = "logs_hour"
        L25_3 = L25_3(L26_3)
        L26_3 = "]: %H:%M:%S"
        L22_3 = L22_3 .. L23_3 .. L24_3 .. L25_3 .. L26_3
        L21_3 = L21_3(L22_3)
        L20_3 = L20_3 .. L21_3
        L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3 = L16_3(L19_3, L18_3, L19_3, L20_3)
        L14_3(L15_3, L16_3, L19_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3, L26_3)
      end
    end
    L2_3 = L3_2
    L1_3 = L6_1
    L1_3[L2_3] = nil
  end
  L6_2(L7_2, L8_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:updateTruckStatus"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:updateTruckStatus"
function fn_L9_1(A0_2, A1_2, A2_2, A3_2, A4_2)
local L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2
  L5_2 = source
  L6_2 = A0_2.truck_id
  if L6_2 then
    if A1_2 < 0 then
      A1_2 = 0
    end
    if A2_2 < 0 then
      A2_2 = 0
    end
    L6_2 = calculateWheelsHealth
    L7_2 = A4_2.tyres
    L8_2 = A0_2.truck_id
    L6_2 = L6_2(L7_2, L8_2)
    if A4_2 then
      L7_2 = "UPDATE `trucker_trucks` SET engine = @engine, transmission = @transmission, body = @body, fuel = @fuel, wheels = @wheels, properties = @properties WHERE truck_id = @truck_id"
      L8_2 = Utils
      L8_2 = L8_2.Database
      L8_2 = L8_2.execute
      L9_2 = L7_2
      L10_2 = {}
      L10_2["@engine"] = A1_2
      L10_2["@body"] = A2_2
      L10_2["@fuel"] = A3_2
      L10_2["@wheels"] = L6_2
      L13_2 = math
      L13_2 = L13_2.floor
      L12_2 = A1_2 + A2_2
      L12_2 = L12_2 / 2
      L13_2 = L13_2(L12_2)
      L10_2["@transmission"] = L13_2
      L13_2 = json
      L13_2 = L13_2.encode
      L12_2 = A4_2
      L13_2 = L13_2(L12_2)
      L10_2.properties = L13_2
      L13_2 = A0_2.truck_id
      L10_2["@truck_id"] = L13_2
      L8_2(L9_2, L10_2)
    else
      L7_2 = "UPDATE `trucker_trucks` SET engine = @engine, transmission = @transmission, body = @body, fuel = @fuel WHERE truck_id = @truck_id"
      L8_2 = Utils
      L8_2 = L8_2.Database
      L8_2 = L8_2.execute
      L9_2 = L7_2
      L10_2 = {}
      L10_2["@engine"] = A1_2
      L10_2["@body"] = A2_2
      L10_2["@fuel"] = A3_2
      L10_2["@wheels"] = L6_2
      L13_2 = math
      L13_2 = L13_2.floor
      L12_2 = A1_2 + A2_2
      L12_2 = L12_2 / 2
      L13_2 = L13_2(L12_2)
      L10_2["@transmission"] = L13_2
      L13_2 = A0_2.truck_id
      L10_2["@truck_id"] = L13_2
      L8_2(L9_2, L10_2)
    end
  end
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
function generateTruckerAvailableContractsThread(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2
  L2_2 = "SELECT wheels FROM `trucker_trucks` WHERE truck_id = @truck_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.fetchAll
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@truck_id"] = A1_2
  L3_2 = L3_2(L4_2, L5_2)
  L3_2 = L3_2[1]
  L4_2 = L3_2.wheels
  if A0_2 then
    L5_2 = {}
    if A0_2 ~= L5_2 then
      goto lbl_19
    end
  end
  do return L4_2 end
  ::lbl_19::
  L5_2 = 1000
  L6_2 = pairs
  L7_2 = A0_2
  L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
  for L10_2, L13_2 in L6_2, L7_2, L8_2, L9_2 do
    L5_2 = L5_2 - 100
  end
  if L4_2 > L5_2 then
    if L5_2 < 0 then
      L5_2 = 0
    end
    return L5_2
  end
  return L4_2
end
calculateWheelsHealth = generateTruckerAvailableContractsThread
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:updateContract"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:updateContract"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2
  L2_2 = source
  L3_2 = nil
  if true == A1_2 then
    L4_2 = Utils
    L4_2 = L4_2.Framework
    L4_2 = L4_2.getPlayerId
    L5_2 = L2_2
    L4_2 = L4_2(L5_2)
    L3_2 = L4_2
  else
    L3_2 = nil
    L4_2 = L6_1
    L4_2[L2_2] = nil
  end
  L4_2 = "UPDATE `trucker_available_contracts` SET progress = @progress WHERE contract_id = @id;"
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.execute
  L6_2 = L4_2
  L7_2 = {}
  L7_2["@id"] = A0_2
  L7_2["@progress"] = L3_2
  L5_2(L6_2, L7_2)
  L5_2 = Utils
  L5_2 = L5_2.Framework
  L5_2 = L5_2.getPlayers
  L5_2 = L5_2()
  if not L5_2 then
    L5_2 = {}
  end
  L6_2 = pairs
  L7_2 = L5_2
  L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
  for L10_2, L13_2 in L6_2, L7_2, L8_2, L9_2 do
    L12_2 = L4_1
    L12_2 = L12_2[L11_2]
    if L12_2 then
      L12_2 = openUI
      L13_2 = L11_2
      L14_2 = true
      L12_2(L13_2, L14_2)
    end
  end
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:cancelContract"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:cancelContract"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3
    L1_3 = "UPDATE `trucker_available_contracts` SET progress = NULL WHERE contract_id = @id;"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.execute
    L3_3 = L1_3
    L4_3 = {}
    L5_3 = A1_2.id
    L4_3["@id"] = L5_3
    L2_3(L3_3, L4_3)
    L2_3 = TriggerClientEvent
    L3_3 = "truck_logistics:cancelContract"
    L4_3 = L2_2
    L8_3 = L2_2
    L5_3 = L6_1
    L5_3 = L5_3[L6_3]
    L5_3 = L5_3.contract_data
    L2_3(L3_3, L4_3, L5_3)
    L3_3 = L2_2
    L2_3 = L6_1
    L2_3[L3_3] = nil
    L2_3 = openUI
    L3_3 = L2_2
    L4_3 = true
    L2_3(L3_3, L4_3)
    L2_3 = Wait
    L3_3 = 1
    L2_3(L3_3)
    L2_3 = Utils
    L2_3 = L2_3.Framework
    L2_3 = L2_3.getPlayers
    L2_3 = L2_3()
    if not L2_3 then
      L2_3 = {}
    end
    L3_3 = pairs
    L4_3 = L2_3
    L3_3, L4_3, L5_3, L8_3 = L3_3(L4_3)
    for L7_3, L8_3 in L3_3, L4_3, L5_3, L8_3 do
      L9_3 = L4_1
      L9_3 = L9_3[L8_3]
      if L9_3 then
        L9_3 = openUI
        L10_3 = L8_3
        L11_3 = true
        L9_3(L10_3, L11_3)
      end
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:createParty"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:createParty"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3
    L1_3 = math
    L1_3 = L1_3.floor
    L2_3 = tonumber
    L3_3 = A1_2.members
    L2_3 = L2_3(L3_3)
    if not L2_3 then
      L2_3 = 0
    end
    L1_3 = L1_3(L2_3)
    A1_2.members = L1_3
    L1_3 = A1_2.pass
    if "" == L1_3 then
      A1_2.pass = nil
    end
    L1_3 = A1_2.name
    if L1_3 then
      L1_3 = A1_2.desc
      if L1_3 then
        L1_3 = A1_2.members
        if L1_3 > 0 then
          L1_3 = "SELECT 1 FROM `trucker_party` WHERE name = @name"
          L2_3 = Utils
          L2_3 = L2_3.Database
          L2_3 = L2_3.fetchAll
          L3_3 = L1_3
          L4_3 = {}
          L5_3 = A1_2.name
          L4_3["@name"] = L5_3
          L2_3 = L2_3(L3_3, L4_3)
          L2_3 = L2_3[1]
          if not L2_3 then
            L3_3 = "SELECT 1 FROM `trucker_party_members` WHERE user_id = @user_id"
            L4_3 = Utils
            L4_3 = L4_3.Database
            L4_3 = L4_3.fetchAll
            L5_3 = L3_3
            L8_3 = {}
            L8_3["@user_id"] = A0_3
            L4_3 = L4_3(L5_3, L6_3)
            L4_3 = L4_3[1]
            if not L4_3 then
              L5_3 = tryGetTruckerMoney
              L8_3 = A0_3
              L7_3 = A1_2.members
              L8_3 = Config
              L8_3 = L8_3.party
              L8_3 = L8_3.price_per_member
              L7_3 = L7_3 * L8_3
              L8_3 = Config
              L8_3 = L8_3.party
              L8_3 = L8_3.price_to_create
              L7_3 = L7_3 + L8_3
              L5_3 = L5_3(L6_3, L7_3)
              if L5_3 then
                L5_3 = "INSERT INTO `trucker_party` (name,description,pass,members) VALUES (@name,@description,@pass,@members);"
                L8_3 = Utils
                L8_3 = L8_3.Database
                L8_3 = L8_3.execute
                L7_3 = L5_3
                L8_3 = {}
                L9_3 = A1_2.name
                L8_3["@name"] = L9_3
                L9_3 = A1_2.desc
                L8_3["@description"] = L9_3
                L9_3 = A1_2.pass
                L8_3["@pass"] = L9_3
                L9_3 = A1_2.members
                L8_3["@members"] = L9_3
                L8_3(L7_3, L8_3)
                L8_3 = "SELECT id FROM `trucker_party` WHERE name = @name"
                L7_3 = Utils
                L7_3 = L7_3.Database
                L7_3 = L7_3.fetchAll
                L8_3 = L6_3
                L9_3 = {}
                L10_3 = A1_2.name
                L9_3["@name"] = L10_3
                L7_3 = L7_3(L8_3, L9_3)
                L7_3 = L7_3[1]
                if L7_3 then
                  L8_3 = "INSERT INTO `trucker_party_members` (party_id,user_id,owner,joined_at) VALUES (@party_id,@user_id,1,@joined_at);"
                  L9_3 = Utils
                  L9_3 = L9_3.Database
                  L9_3 = L9_3.execute
                  L10_3 = L8_3
                  L11_3 = {}
                  L14_3 = L7_3.id
                  L11_3["@party_id"] = L14_3
                  L11_3["@user_id"] = A0_3
                  L14_3 = os
                  L14_3 = L14_3.time
                  L14_3 = L14_3()
                  L11_3["@joined_at"] = L14_3
                  L9_3(L10_3, L11_3)
                  L9_3 = TriggerClientEvent
                  L10_3 = "truck_logistics:Notify"
                  L11_3 = L2_2
                  L14_3 = "success"
                  L13_3 = Utils
                  L13_3 = L13_3.translate
                  L14_3 = "party_created"
                  L13_3, L14_3 = L13_3(L14_3)
                  L9_3(L10_3, L11_3, L14_3, L13_3, L14_3)
                  L9_3 = openUI
                  L10_3 = L2_2
                  L11_3 = true
                  L9_3(L10_3, L11_3)
                else
                  L8_3 = TriggerClientEvent
                  L9_3 = "truck_logistics:Notify"
                  L10_3 = L2_2
                  L11_3 = "error"
                  L14_3 = Utils
                  L14_3 = L14_3.translate
                  L13_3 = "party_not_created"
                  L14_3, L13_3, L14_3 = L14_3(L13_3)
                  L8_3(L9_3, L10_3, L11_3, L14_3, L13_3, L14_3)
                end
              else
                L5_3 = TriggerClientEvent
                L8_3 = "truck_logistics:Notify"
                L7_3 = L2_2
                L8_3 = "error"
                L9_3 = Utils
                L9_3 = L9_3.translate
                L10_3 = "insufficiente_funds"
                L9_3, L10_3, L11_3, L14_3, L13_3, L14_3 = L9_3(L10_3)
                L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3)
              end
            else
              L5_3 = TriggerClientEvent
              L8_3 = "truck_logistics:Notify"
              L7_3 = L2_2
              L8_3 = "error"
              L9_3 = Utils
              L9_3 = L9_3.translate
              L10_3 = "already_in_party"
              L9_3, L10_3, L11_3, L14_3, L13_3, L14_3 = L9_3(L10_3)
              L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3)
            end
          else
            L3_3 = TriggerClientEvent
            L4_3 = "truck_logistics:Notify"
            L5_3 = L2_2
            L8_3 = "error"
            L7_3 = Utils
            L7_3 = L7_3.translate
            L8_3 = "party_exists"
            L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3 = L7_3(L8_3)
            L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3)
          end
        end
      end
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:joinParty"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:joinParty"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3
    L1_3 = A1_2.pass
    if "" == L1_3 then
      A1_2.pass = nil
    end
    L1_3 = A1_2.name
    if L1_3 then
      L1_3 = "SELECT 1 FROM `trucker_party` WHERE name = @name"
      L2_3 = Utils
      L2_3 = L2_3.Database
      L2_3 = L2_3.fetchAll
      L3_3 = L1_3
      L4_3 = {}
      L5_3 = A1_2.name
      L4_3["@name"] = L5_3
      L2_3 = L2_3(L3_3, L4_3)
      L2_3 = L2_3[1]
      if L2_3 then
        L3_3 = "SELECT 1 FROM `trucker_party_members` WHERE user_id = @user_id"
        L4_3 = Utils
        L4_3 = L4_3.Database
        L4_3 = L4_3.fetchAll
        L5_3 = L3_3
        L8_3 = {}
        L8_3["@user_id"] = A0_3
        L4_3 = L4_3(L5_3, L6_3)
        L4_3 = L4_3[1]
        if not L4_3 then
          L5_3 = "SELECT id, pass, members FROM `trucker_party` WHERE name = @name"
          L8_3 = Utils
          L8_3 = L8_3.Database
          L8_3 = L8_3.fetchAll
          L7_3 = L5_3
          L8_3 = {}
          L9_3 = A1_2.name
          L8_3["@name"] = L9_3
          L8_3 = L8_3(L7_3, L8_3)
          L8_3 = L8_3[1]
          if L8_3 then
            L7_3 = countGroupMembers
            L8_3 = L6_3.id
            L7_3 = L7_3(L8_3)
            L8_3 = tonumber
            L9_3 = L6_3.members
            L8_3 = L8_3(L9_3)
            if L7_3 < L8_3 then
              L7_3 = A1_2.pass
              L8_3 = L6_3.pass
              if L7_3 == L8_3 then
                L7_3 = "INSERT INTO `trucker_party_members` (party_id,user_id,owner,joined_at) VALUES (@party_id,@user_id,0,@joined_at);"
                L8_3 = Utils
                L8_3 = L8_3.Database
                L8_3 = L8_3.execute
                L9_3 = L7_3
                L10_3 = {}
                L11_3 = L6_3.id
                L10_3["@party_id"] = L11_3
                L10_3["@user_id"] = A0_3
                L11_3 = os
                L11_3 = L11_3.time
                L11_3 = L11_3()
                L10_3["@joined_at"] = L11_3
                L8_3(L9_3, L10_3)
                L8_3 = TriggerClientEvent
                L9_3 = "truck_logistics:Notify"
                L10_3 = L2_2
                L11_3 = "success"
                L14_3 = Utils
                L14_3 = L14_3.translate
                L13_3 = "party_joined"
                L14_3, L13_3 = L14_3(L13_3)
                L8_3(L9_3, L10_3, L11_3, L14_3, L13_3)
                L8_3 = openUI
                L9_3 = L2_2
                L10_3 = true
                L8_3(L9_3, L10_3)
              else
                L7_3 = TriggerClientEvent
                L8_3 = "truck_logistics:Notify"
                L9_3 = L2_2
                L10_3 = "error"
                L11_3 = Utils
                L11_3 = L11_3.translate
                L14_3 = "incorrect_pass"
                L11_3, L14_3, L13_3 = L11_3(L14_3)
                L7_3(L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
              end
            else
              L7_3 = TriggerClientEvent
              L8_3 = "truck_logistics:Notify"
              L9_3 = L2_2
              L10_3 = "error"
              L11_3 = Utils
              L11_3 = L11_3.translate
              L14_3 = "party_full"
              L11_3, L14_3, L13_3 = L11_3(L14_3)
              L7_3(L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
            end
          else
            L7_3 = TriggerClientEvent
            L8_3 = "truck_logistics:Notify"
            L9_3 = L2_2
            L10_3 = "error"
            L11_3 = Utils
            L11_3 = L11_3.translate
            L14_3 = "party_not_joined"
            L11_3, L14_3, L13_3 = L11_3(L14_3)
            L7_3(L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
          end
        else
          L5_3 = TriggerClientEvent
          L8_3 = "truck_logistics:Notify"
          L7_3 = L2_2
          L8_3 = "error"
          L9_3 = Utils
          L9_3 = L9_3.translate
          L10_3 = "already_in_party"
          L9_3, L10_3, L11_3, L14_3, L13_3 = L9_3(L10_3)
          L5_3(L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
        end
      else
        L3_3 = TriggerClientEvent
        L4_3 = "truck_logistics:Notify"
        L5_3 = L2_2
        L8_3 = "error"
        L7_3 = Utils
        L7_3 = L7_3.translate
        L8_3 = "party_not_exists"
        L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3 = L7_3(L8_3)
        L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3)
      end
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:kickParty"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:kickParty"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = source
  L3_2 = Wrapper
  L4_2 = L2_2
  function L5_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3
    L1_3 = A1_2.nuser_id
    L2_3 = "SELECT 1 FROM `trucker_party_members` WHERE user_id = @user_id AND owner = 1"
    L3_3 = Utils
    L3_3 = L3_3.Database
    L3_3 = L3_3.fetchAll
    L4_3 = L2_3
    L5_3 = {}
    L5_3["@user_id"] = A0_3
    L3_3 = L3_3(L4_3, L5_3)
    L3_3 = L3_3[1]
    if L3_3 then
      L4_3 = "SELECT party_id FROM `trucker_party_members` WHERE user_id = @user_id"
      L5_3 = Utils
      L5_3 = L5_3.Database
      L5_3 = L5_3.fetchAll
      L8_3 = L4_3
      L7_3 = {}
      L7_3["@user_id"] = L1_3
      L5_3 = L5_3(L6_3, L7_3)
      L5_3 = L5_3[1]
      if L5_3 then
        L8_3 = "DELETE FROM `trucker_party_members` WHERE user_id = @user_id"
        L7_3 = Utils
        L7_3 = L7_3.Database
        L7_3 = L7_3.execute
        L8_3 = L6_3
        L9_3 = {}
        L9_3["@user_id"] = L1_3
        L7_3(L8_3, L9_3)
        L7_3 = Utils
        L7_3 = L7_3.Framework
        L7_3 = L7_3.getPlayerSource
        L8_3 = L1_3
        L7_3 = L7_3(L8_3)
        if L7_3 then
          L8_3 = "SELECT name FROM `trucker_party` WHERE id = @id"
          L9_3 = Utils
          L9_3 = L9_3.Database
          L9_3 = L9_3.fetchAll
          L10_3 = L8_3
          L11_3 = {}
          L14_3 = L5_3.party_id
          L11_3["@id"] = L14_3
          L9_3 = L9_3(L10_3, L11_3)
          L9_3 = L9_3[1]
          L10_3 = TriggerClientEvent
          L11_3 = "truck_logistics:Notify"
          L14_3 = L7_3
          L13_3 = "error"
          L14_3 = Utils
          L14_3 = L14_3.translate
          L15_3 = "party_kicked_2"
          L14_3 = L14_3(L15_3)
          L15_3 = L14_3
          L14_3 = L14_3.format
          L16_3 = L9_3.name
          L14_3, L15_3, L16_3 = L14_3(L15_3, L16_3)
          L10_3(L11_3, L14_3, L13_3, L14_3, L15_3, L16_3)
          L10_3 = L4_1
          L10_3 = L10_3[L7_3]
          if L10_3 then
            L10_3 = openUI
            L11_3 = L7_3
            L14_3 = true
            L10_3(L11_3, L14_3)
          end
        end
        L8_3 = TriggerClientEvent
        L9_3 = "truck_logistics:Notify"
        L10_3 = L2_2
        L11_3 = "success"
        L14_3 = Utils
        L14_3 = L14_3.translate
        L13_3 = "party_kicked"
        L14_3, L13_3, L14_3, L15_3, L16_3 = L14_3(L13_3)
        L8_3(L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3)
        L8_3 = openUI
        L9_3 = L2_2
        L10_3 = true
        L8_3(L9_3, L10_3)
      else
        L8_3 = TriggerClientEvent
        L7_3 = "truck_logistics:Notify"
        L8_3 = L2_2
        L9_3 = "error"
        L10_3 = Utils
        L10_3 = L10_3.translate
        L11_3 = "kick_not_in_party"
        L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3 = L10_3(L11_3)
        L8_3(L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3)
      end
    else
      L4_3 = TriggerClientEvent
      L5_3 = "truck_logistics:Notify"
      L8_3 = L2_2
      L7_3 = "error"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L9_3 = "not_owner"
      L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3 = L8_3(L9_3)
      L4_3(L5_3, L8_3, L7_3, L8_3, L9_3, L10_3, L11_3, L14_3, L13_3, L14_3, L15_3, L16_3)
    end
  end
  L3_2(L4_2, L5_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:deleteParty"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:deleteParty"
function fn_L9_1()
local L0_2, L1_2, L2_2, L3_2
  L0_2 = source
  L1_2 = Wrapper
  L2_2 = L0_2
  function L3_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3
    L1_3 = "SELECT party_id FROM `trucker_party_members` WHERE user_id = @user_id AND owner = 1"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L4_3["@user_id"] = A0_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if L2_3 then
      L3_3 = "DELETE FROM `trucker_party_members` WHERE party_id = @party_id"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L8_3 = {}
      L7_3 = L2_3.party_id
      L8_3["@party_id"] = L7_3
      L4_3(L5_3, L8_3)
      L4_3 = "DELETE FROM `trucker_party` WHERE id = @id"
      L5_3 = Utils
      L5_3 = L5_3.Database
      L5_3 = L5_3.execute
      L8_3 = L4_3
      L7_3 = {}
      L8_3 = L2_3.party_id
      L7_3["@id"] = L8_3
      L5_3(L8_3, L7_3)
      L5_3 = TriggerClientEvent
      L8_3 = "truck_logistics:Notify"
      L7_3 = L0_2
      L8_3 = "success"
      L9_3 = Utils
      L9_3 = L9_3.translate
      L10_3 = "party_disbanded"
      L9_3, L10_3 = L9_3(L10_3)
      L5_3(L8_3, L7_3, L8_3, L9_3, L10_3)
      L5_3 = openUI
      L8_3 = L0_2
      L7_3 = true
      L5_3(L8_3, L7_3)
    else
      L3_3 = TriggerClientEvent
      L4_3 = "truck_logistics:Notify"
      L5_3 = L0_2
      L8_3 = "error"
      L7_3 = Utils
      L7_3 = L7_3.translate
      L8_3 = "not_owner"
      L7_3, L8_3, L9_3, L10_3 = L7_3(L8_3)
      L3_3(L4_3, L5_3, L8_3, L7_3, L8_3, L9_3, L10_3)
    end
  end
  L1_2(L2_2, L3_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:quitParty"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:quitParty"
function fn_L9_1()
local L0_2, L1_2, L2_2, L3_2
  L0_2 = source
  L1_2 = Wrapper
  L2_2 = L0_2
  function L3_2(A0_3)
local L1_3, L2_3, L3_3, L4_3, L5_3, L8_3, L7_3, L8_3, L9_3
    L1_3 = "SELECT party_id FROM `trucker_party_members` WHERE user_id = @user_id AND owner = 1"
    L2_3 = Utils
    L2_3 = L2_3.Database
    L2_3 = L2_3.fetchAll
    L3_3 = L1_3
    L4_3 = {}
    L4_3["@user_id"] = A0_3
    L2_3 = L2_3(L3_3, L4_3)
    L2_3 = L2_3[1]
    if not L2_3 then
      L3_3 = "DELETE FROM `trucker_party_members` WHERE user_id = @user_id"
      L4_3 = Utils
      L4_3 = L4_3.Database
      L4_3 = L4_3.execute
      L5_3 = L3_3
      L8_3 = {}
      L8_3["@user_id"] = A0_3
      L4_3(L5_3, L8_3)
      L4_3 = TriggerClientEvent
      L5_3 = "truck_logistics:Notify"
      L8_3 = L0_2
      L7_3 = "success"
      L8_3 = Utils
      L8_3 = L8_3.translate
      L9_3 = "party_left"
      L8_3, L9_3 = L8_3(L9_3)
      L4_3(L5_3, L8_3, L7_3, L8_3, L9_3)
      L4_3 = openUI
      L5_3 = L0_2
      L8_3 = true
      L4_3(L5_3, L8_3)
    end
  end
  L1_2(L2_2, L3_2)
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = RegisterServerEvent
L8_1 = "truck_logistics:server:createInspectVehicleThread"
generateTruckerAvailableContractsThread(L8_1)
generateTruckerAvailableContractsThread = AddEventHandler
L8_1 = "truck_logistics:server:createInspectVehicleThread"
function fn_L9_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2
  L2_2 = source
  L3_2 = Wait
  L4_2 = 1000
  L3_2(L4_2)
  L3_2 = nil
  L4_2 = 1
  L5_2 = 15
  L6_2 = 1
  for L7_2 = L4_2, L5_2, L6_2 do
    L8_2 = NetworkGetEntityFromNetworkId
    L9_2 = A1_2
    L8_2 = L8_2(L9_2)
    L3_2 = L8_2
    L8_2 = DoesEntityExist
    L9_2 = L3_2
    L8_2 = L8_2(L9_2)
    if L8_2 then
      break
    end
    L8_2 = Wait
    L9_2 = 1000
    L8_2(L9_2)
  end
  L4_2 = DoesEntityExist
  L5_2 = L3_2
  L4_2 = L4_2(L5_2)
  if not L4_2 then
    L4_2 = print
    L5_2 = "^3WARNING: Trailer entity not found for net ID '^1"
    L6_2 = A1_2
    L7_2 = "^3'^7"
    L5_2 = L5_2 .. L6_2 .. L7_2
    L4_2(L5_2)
    return
  end
  while true do
    L4_2 = DoesEntityExist
    L5_2 = L3_2
    L4_2 = L4_2(L5_2)
    if not L4_2 then
      break
    end
    L4_2 = ipairs
    L5_2 = GetPlayers
    L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2 = L5_2()
    L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2)
    for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
      L10_2 = GetPlayerPed
      L13_2 = L9_2
      L10_2 = L10_2(L11_2)
      if L10_2 then
        L13_2 = DoesEntityExist
        L12_2 = L10_2
        L13_2 = L13_2(L12_2)
        if L13_2 then
          L13_2 = GetEntityCoords
          L12_2 = L10_2
          L13_2 = L13_2(L12_2)
          L12_2 = GetEntityCoords
          L13_2 = L3_2
          L12_2 = L12_2(L13_2)
          L13_2 = L11_2 - L12_2
          L13_2 = #L13_2
          if L13_2 < 50.0 then
            L14_2 = TriggerClientEvent
            L15_2 = "truck_logistics:client:createInspectVehicleThread"
            L16_2 = L9_2
            L17_2 = A0_2
            L18_2 = A1_2
            L14_2(L15_2, L16_2, L17_2, L18_2)
          end
        end
      end
    end
    L4_2 = Wait
    L5_2 = 5000
    L4_2(L5_2)
  end
end
generateTruckerAvailableContractsThread(L8_1, fn_L9_1)
generateTruckerAvailableContractsThread = {}
L8_1 = RegisterServerEvent
fn_L9_1 = "truck_logistics:server:registerNetVehicleId"
L8_1(fn_L9_1)
L8_1 = AddEventHandler
fn_L9_1 = "truck_logistics:server:registerNetVehicleId"
function fn_L10_1(A0_2, A1_2)
local L2_2
  L2_2 = L7_1
  L2_2[A1_2] = A0_2
end
L8_1(fn_L9_1, fn_L10_1)
L8_1 = Utils
L8_1 = L8_1.Callback
L8_1 = L8_1.RegisterServerCallback
fn_L9_1 = "truck_logistics:getTrailerContent"
function fn_L10_1(A0_2, A1_2, A2_2)
local L3_2, L4_2
  L3_2 = A1_2
  L4_2 = L7_1
  L4_2 = L4_2[A2_2]
  L3_2(L4_2)
end
L8_1(fn_L9_1, fn_L10_1)
function L8_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
  L1_2 = "SELECT count(user_id) as count FROM `trucker_party_members` WHERE party_id = @party_id"
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.fetchAll
  L3_2 = L1_2
  L4_2 = {}
  L4_2["@party_id"] = A0_2
  L2_2 = L2_2(L3_2, L4_2)
  L2_2 = L2_2[1]
  L3_2 = L2_2.count
  return L3_2
end
countGroupMembers = L8_1
function L8_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = "UPDATE `trucker_users` SET money = money + @amount WHERE user_id = @user_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.execute
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@amount"] = A1_2
  L5_2["@user_id"] = A0_2
  L3_2(L4_2, L5_2)
end
giveTruckerMoney = L8_1
function L8_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L2_2 = "SELECT money FROM `trucker_users` WHERE user_id = @user_id"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.fetchAll
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@user_id"] = A0_2
  L3_2 = L3_2(L4_2, L5_2)
  L3_2 = L3_2[1]
  if L3_2 then
    L4_2 = tonumber
    L5_2 = L3_2.money
    L4_2 = L4_2(L5_2)
    if A1_2 <= L4_2 then
      L4_2 = "UPDATE `trucker_users` SET money = @amount WHERE user_id = @user_id"
      L5_2 = Utils
      L5_2 = L5_2.Database
      L5_2 = L5_2.execute
      L6_2 = L4_2
      L7_2 = {}
      L8_2 = tonumber
      L9_2 = L3_2.money
      L8_2 = L8_2(L9_2)
      L8_2 = L8_2 - A1_2
      L7_2["@amount"] = L8_2
      L7_2["@user_id"] = A0_2
      L5_2(L6_2, L7_2)
      L5_2 = true
      return L5_2
  end
  else
    L4_2 = false
    return L4_2
  end
end
tryGetTruckerMoney = L8_1
function L8_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L1_2 = 0
  L2_2 = getPlayerLevel
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L3_2 = pairs
  L4_2 = Config
  L4_2 = L4_2.max_loan_per_level
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    if L7_2 <= L2_2 then
      L1_2 = L8_2
    end
  end
  return L1_2
end
getMaxEmprestimo = L8_1
function L8_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L1_2 = type
  L2_2 = Config
  L2_2 = L2_2.drivers
  L2_2 = L2_2.max_drivers_per_player
  L1_2 = L1_2(L2_2)
  if "number" == L1_2 then
    L1_2 = Config
    L1_2 = L1_2.drivers
    L1_2 = L1_2.max_drivers_per_player
    return L1_2
  end
  L1_2 = getPlayerLevel
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = {}
  L3_2 = pairs
  L4_2 = Config
  L4_2 = L4_2.drivers
  L4_2 = L4_2.max_drivers_per_player
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2 in L3_2, L4_2, L5_2, L6_2 do
    L8_2 = table
    L8_2 = L8_2.insert
    L9_2 = L2_2
    L10_2 = L7_2
    L8_2(L9_2, L10_2)
  end
  L3_2 = table
  L3_2 = L3_2.sort
  L4_2 = L2_2
  L3_2(L4_2)
  L3_2 = 0
  L4_2 = ipairs
  L5_2 = L2_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    if L1_2 >= L9_2 then
      L10_2 = Config
      L10_2 = L10_2.drivers
      L10_2 = L10_2.max_drivers_per_player
      L3_2 = L10_2[L9_2]
    else
      break
    end
  end
  return L3_2
end
getMaxDrivers = L8_1
function L8_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L2_2 = assert
  L3_2 = type
  L4_2 = A1_2
  L3_2 = L3_2(L4_2)
  L3_2 = "number" == L3_2 and A1_2 > 0
  L4_2 = "received_xp must be a number higher than 0"
  L2_2(L3_2, L4_2)
  L2_2 = assert
  L3_2 = type
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  L3_2 = "string" == L3_2
  L4_2 = "user_id must be a string similar to this 'CDZ75654' or this 'char1:236e32154439662cbaa4f85f115149b4fd278cf'"
  L2_2(L3_2, L4_2)
  L2_2 = getPlayerLevel
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L3_2 = "UPDATE `trucker_users` SET exp = exp + @exp_amount WHERE user_id = @user_id"
  L4_2 = Utils
  L4_2 = L4_2.Database
  L4_2 = L4_2.execute
  L5_2 = L3_2
  L6_2 = {}
  L6_2["@exp_amount"] = A1_2
  L6_2["@user_id"] = A0_2
  L4_2(L5_2, L6_2)
  L4_2 = getPlayerLevel
  L5_2 = A0_2
  L4_2 = L4_2(L5_2)
  L5_2 = L4_2 - L2_2
  if L5_2 > 0 then
    L5_2 = "UPDATE `trucker_users` SET skill_points = skill_points + @skill WHERE user_id = @user_id"
    L6_2 = Utils
    L6_2 = L6_2.Database
    L6_2 = L6_2.execute
    L7_2 = L5_2
    L8_2 = {}
    L9_2 = L4_2 - L2_2
    L8_2["@skill"] = L9_2
    L8_2["@user_id"] = A0_2
    L6_2(L7_2, L8_2)
    L6_2 = Utils
    L6_2 = L6_2.Webhook
    L6_2 = L6_2.sendWebhookMessage
    L7_2 = WebhookURL
    L8_2 = Utils
    L8_2 = L8_2.translate
    L9_2 = "logs_skill"
    L8_2 = L8_2(L9_2)
    L9_2 = L8_2
    L8_2 = L8_2.format
    L10_2 = L4_2 - L2_2
    L13_2 = Utils
    L13_2 = L13_2.Framework
    L13_2 = L13_2.getPlayerIdLog
    L12_2 = source
    L13_2 = L13_2(L12_2)
    L12_2 = os
    L12_2 = L12_2.date
    L13_2 = [[

[]]
    L14_2 = Utils
    L14_2 = L14_2.translate
    L15_2 = "logs_date"
    L14_2 = L14_2(L15_2)
    L15_2 = "]: %d/%m/%Y ["
    L16_2 = Utils
    L16_2 = L16_2.translate
    L17_2 = "logs_hour"
    L16_2 = L16_2(L17_2)
    L17_2 = "]: %H:%M:%S"
    L13_2 = L13_2 .. L14_2 .. L15_2 .. L16_2 .. L17_2
    L12_2 = L12_2(L13_2)
    L13_2 = L13_2 .. L12_2
    L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L8_2(L9_2, L10_2, L13_2)
    L6_2(L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  end
end
givePlayerXp = L8_1
L8_1 = exports
fn_L9_1 = "givePlayerXp"
giveplayerxp = givePlayerXp
L8_1(fn_L9_1, giveplayerxp)
function L8_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2
  L1_2 = assert
  L2_2 = type
  L3_2 = A0_2
  L2_2 = L2_2(L3_2)
  L2_2 = "string" == L2_2
  L3_2 = "user_id must be a string similar to this 'CDZ75654' or this 'char1:236e32154439662cbaa4f85f115149b4fd278cf'"
  L1_2(L2_2, L3_2)
  L1_2 = "SELECT exp FROM `trucker_users` WHERE user_id = @user_id"
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.fetchAll
  L3_2 = L1_2
  L4_2 = {}
  L4_2["@user_id"] = A0_2
  L2_2 = L2_2(L3_2, L4_2)
  L2_2 = L2_2[1]
  L3_2 = 0
  if L2_2 then
    L4_2 = pairs
    L5_2 = Config
    L5_2 = L5_2.required_xp_to_levelup
    L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
    for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
      L10_2 = tonumber
      L13_2 = L2_2.exp
      L10_2 = L10_2(L11_2)
      if L9_2 <= L10_2 then
        L3_2 = L8_2
      else
        return L3_2
      end
    end
  end
  return L3_2
end
getPlayerLevel = L8_1
L8_1 = exports
fn_L9_1 = "getPlayerLevel"
getplayerlevel = getPlayerLevel
L8_1(fn_L9_1, getplayerlevel)
function L8_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L2_2 = GetEntityCoords
  L3_2 = GetPlayerPed
  L4_2 = A0_2
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L3_2(L4_2)
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  L3_2 = pairs
  L4_2 = A1_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = L8_2.coords_index
    if 0 == L9_2 then
      L9_2 = json
      L9_2 = L9_2.decode
      L10_2 = L8_2.external_data
      L9_2 = L9_2(L10_2)
      if L9_2 then
        L10_2 = vector3
        L13_2 = L9_2.x
        L12_2 = L9_2.y
        L13_2 = L9_2.z
        L10_2 = L10_2(L11_2, L12_2, L13_2)
        L10_2 = L2_2 - L10_2
        L10_2 = #L10_2
        L13_2 = tonumber
        L12_2 = string
        L12_2 = L12_2.format
        L13_2 = "%.2f"
        L14_2 = L10_2 / 1000
        L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L12_2(L13_2, L14_2)
        L13_2 = L13_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
        L8_2.distance = L13_2
        L13_2 = tonumber
        L12_2 = string
        L12_2 = L12_2.format
        L13_2 = "%.f"
        L14_2 = L9_2.reward
        L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L12_2(L13_2, L14_2)
        L13_2 = L13_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
        L8_2.reward = L13_2
        L8_2.external_data = L9_2
      end
    else
      L9_2 = Config
      L9_2 = L9_2.delivery_locations
      L10_2 = L8_2.coords_index
      L9_2 = L9_2[L10_2]
      if L9_2 then
        L9_2 = table
        L9_2 = L9_2.unpack
        L10_2 = Config
        L10_2 = L10_2.delivery_locations
        L13_2 = L8_2.coords_index
        L10_2 = L10_2[L11_2]
        L9_2, L10_2, L13_2 = L9_2(L10_2)
        L12_2 = vector3
        L13_2 = L9_2
        L14_2 = L10_2
        L15_2 = L11_2
        L12_2 = L12_2(L13_2, L14_2, L15_2)
        L12_2 = L2_2 - L12_2
        L12_2 = #L12_2
        L13_2 = tonumber
        L14_2 = string
        L14_2 = L14_2.format
        L15_2 = "%.2f"
        L16_2 = L12_2 / 1000
        L14_2, L15_2, L16_2, L17_2 = L14_2(L15_2, L16_2)
        L13_2 = L13_2(L14_2, L15_2, L16_2, L17_2)
        L8_2.distance = L13_2
        L13_2 = tonumber
        L14_2 = string
        L14_2 = L14_2.format
        L15_2 = "%.f"
        L16_2 = L8_2.distance
        L17_2 = L8_2.price_per_km
        L16_2 = L16_2 * L17_2
        L14_2, L15_2, L16_2, L17_2 = L14_2(L15_2, L16_2)
        L13_2 = L13_2(L14_2, L15_2, L16_2, L17_2)
        L8_2.reward = L13_2
      end
    end
  end
  return A1_2
end
updateContractsRewardAndDistance = L8_1
function L8_1()
local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.account
  if L0_2 then
    L0_2 = Config
    L0_2 = L0_2.account
    L0_2 = L0_2.trucker
    return L0_2
  else
    L0_2 = "bank"
    return L0_2
  end
end
getAccount = L8_1
function L8_1(A0_2)
local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L1_2 = "DELETE FROM `trucker_drivers` WHERE user_id = @user_id;"
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.execute
  L3_2 = L1_2
  L4_2 = {}
  L4_2["@user_id"] = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = "DELETE FROM `trucker_loans` WHERE user_id = @user_id;"
  L3_2 = Utils
  L3_2 = L3_2.Database
  L3_2 = L3_2.execute
  L4_2 = L2_2
  L5_2 = {}
  L5_2["@user_id"] = A0_2
  L3_2(L4_2, L5_2)
  L3_2 = "DELETE FROM `trucker_party_members` WHERE user_id = @user_id;"
  L4_2 = Utils
  L4_2 = L4_2.Database
  L4_2 = L4_2.execute
  L5_2 = L3_2
  L6_2 = {}
  L6_2["@user_id"] = A0_2
  L4_2(L5_2, L6_2)
  L4_2 = "DELETE FROM `trucker_trucks` WHERE user_id = @user_id;"
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.execute
  L6_2 = L4_2
  L7_2 = {}
  L7_2["@user_id"] = A0_2
  L5_2(L6_2, L7_2)
  L5_2 = "DELETE FROM `trucker_users` WHERE user_id = @user_id;"
  L6_2 = Utils
  L6_2 = L6_2.Database
  L6_2 = L6_2.execute
  L7_2 = L5_2
  L8_2 = {}
  L8_2["@user_id"] = A0_2
  L6_2(L7_2, L8_2)
end
deleteAllUserData = L8_1
L8_1 = Utils
L8_1 = L8_1.Callback
L8_1 = L8_1.RegisterServerCallback
fn_L9_1 = "truck_logistics:hasPoliceJob"
function fn_L10_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2
  L2_2 = A0_2
  L3_2 = A1_2
  L4_2 = hasPoliceJob
  L5_2 = L2_2
  L4_2, L5_2 = L4_2(L5_2)
  L3_2(L4_2, L5_2)
end
L8_1(fn_L9_1, fn_L10_1)
function L8_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
  L1_2 = Config
  L1_2 = L1_2.job
  L1_2 = Config
  L1_2 = L1_2.job
  L1_2 = type
  L2_2 = Config
  L2_2 = L2_2.job
  L1_2 = L1_2(L2_2)
  if "table" == L1_2 then
    L1_2 = Config
    L1_2 = L1_2.job
    L1_2 = #L1_2
  end
  L1_2 = Config
  L1_2 = L1_2.job
  L1_2 = type
  L2_2 = Config
  L2_2 = L2_2.job
  L1_2 = L1_2(L2_2)
  if "string" == L1_2 then
    L1_2 = Utils
    L1_2 = L1_2.Framework
    L1_2 = L1_2.hasJobs
    L2_2 = A0_2
    L3_2 = {}
    L4_2 = Config
    L4_2 = L4_2.job
    L3_2[1] = L4_2
    L1_2 = L1_2(L2_2, L3_2)
    if L1_2 then
      goto lbl_58
    end
  end
  L1_2 = type
  L2_2 = Config
  L2_2 = L2_2.job
  L1_2 = L1_2(L2_2)
  L1_2 = Utils
  L1_2 = L1_2.Framework
  L1_2 = L1_2.hasJobs
  L2_2 = A0_2
  L3_2 = Config
  L3_2 = L3_2.job
  L1_2 = nil == L1_2 or L1_2
  ::lbl_58::
  return L1_2
end
hasTruckerJob = L8_1
function L8_1(A0_2)
local L1_2, L2_2, L3_2, L4_2
  L1_2 = Config
  L1_2 = L1_2.police_job
  L1_2 = Config
  L1_2 = L1_2.police_job
  L1_2 = type
  L2_2 = Config
  L2_2 = L2_2.police_job
  L1_2 = L1_2(L2_2)
  if "table" == L1_2 then
    L1_2 = Config
    L1_2 = L1_2.police_job
    L1_2 = #L1_2
  end
  L1_2 = Config
  L1_2 = L1_2.police_job
  L1_2 = type
  L2_2 = Config
  L2_2 = L2_2.police_job
  L1_2 = L1_2(L2_2)
  if "string" == L1_2 then
    L1_2 = Utils
    L1_2 = L1_2.Framework
    L1_2 = L1_2.hasJobs
    L2_2 = A0_2
    L3_2 = {}
    L4_2 = Config
    L4_2 = L4_2.police_job
    L3_2[1] = L4_2
    L1_2 = L1_2(L2_2, L3_2)
    if L1_2 then
      goto lbl_58
    end
  end
  L1_2 = type
  L2_2 = Config
  L2_2 = L2_2.police_job
  L1_2 = L1_2(L2_2)
  L1_2 = Utils
  L1_2 = L1_2.Framework
  L1_2 = L1_2.hasJobs
  L2_2 = A0_2
  L3_2 = Config
  L3_2 = L3_2.police_job
  L1_2 = nil == L1_2 or L1_2
  ::lbl_58::
  return L1_2
end
hasPoliceJob = L8_1
function L8_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = L3_1
  if L2_2 then
    L2_2 = L1_1
    if not L2_2 then
      goto lbl_23
    end
  end
  L2_2 = L1_1
  if L2_2 then
    L2_2 = TriggerClientEvent
    L3_2 = "truck_logistics:Notify"
    L4_2 = A0_2
    L5_2 = "error"
    L6_2 = "The script requires 'lc_utils' in version "
    L7_2 = L0_1
    L8_2 = ", but you currently have version "
    L9_2 = Utils
    L9_2 = L9_2.Version
    L10_2 = ". Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip"
    L6_2 = L6_2 .. L7_2 .. L8_2 .. L9_2 .. L10_2
    L2_2(L3_2, L4_2, L5_2, L6_2)
  end
  do return end
  ::lbl_23::
  L2_2 = L5_1
  L2_2 = L2_2[A0_2]
  if nil == L2_2 then
    L2_2 = L5_1
    L2_2[A0_2] = true
    L2_2 = Utils
    L2_2 = L2_2.Framework
    L2_2 = L2_2.getPlayerId
    L3_2 = A0_2
    L2_2 = L2_2(L3_2)
    if L2_2 then
      L3_2 = A1_2
      L4_2 = L2_2
      L3_2(L4_2)
    else
      L3_2 = print
      L4_2 = "User not found: "
      L5_2 = A0_2
      L4_2 = L4_2 .. L5_2
      L3_2(L4_2)
    end
    L3_2 = SetTimeout
    L4_2 = 100
    function L5_2()
local L0_3, L1_3
      L1_3 = A0_2
      L0_3 = L5_1
      L0_3[L1_3] = nil
    end
    L3_2(L4_2, L5_2)
  end
end
Wrapper = L8_1
function L8_1(A0_2, A1_2)
local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, a6_2
  L2_2 = {}
  L3_2 = Utils
  L3_2 = L3_2.Framework
  L3_2 = L3_2.getPlayerId
  L4_2 = A0_2
  L3_2 = L3_2(L4_2)
  if L3_2 then
    L4_2 = hasTruckerJob
    L5_2 = A0_2
    L4_2 = L4_2(L5_2)
    if L4_2 then
      L4_2 = "SELECT * FROM `trucker_available_contracts` WHERE (progress IS NULL OR progress = @user_id) ORDER BY contract_id DESC"
      L5_2 = Utils
      L5_2 = L5_2.Database
      L5_2 = L5_2.fetchAll
      L6_2 = L4_2
      L7_2 = {}
      L7_2["@user_id"] = L3_2
      L5_2 = L5_2(L6_2, L7_2)
      L2_2.trucker_available_contracts = L5_2
      L5_2 = updateContractsRewardAndDistance
      L6_2 = A0_2
      L7_2 = L2_2.trucker_available_contracts
      L5_2(L6_2, L7_2)
      L5_2 = "SELECT * FROM `trucker_users` WHERE user_id = @user_id"
      L6_2 = Utils
      L6_2 = L6_2.Database
      L6_2 = L6_2.fetchAll
      L7_2 = L5_2
      L8_2 = {}
      L8_2["@user_id"] = L3_2
      L6_2 = L6_2(L7_2, L8_2)
      L6_2 = L6_2[1]
      L2_2.trucker_users = L6_2
      L6_2 = L2_2.trucker_users
      if nil == L6_2 then
        L6_2 = beforeBuyLocation
        L7_2 = A0_2
        L8_2 = L3_2
        L6_2 = L6_2(L7_2, L8_2)
        if L6_2 then
          L6_2 = "INSERT INTO `trucker_users` (user_id) VALUES (@user_id);"
          L7_2 = Utils
          L7_2 = L7_2.Database
          L7_2 = L7_2.execute
          L8_2 = L6_2
          L9_2 = {}
          L9_2["@user_id"] = L3_2
          L7_2(L8_2, L9_2)
          L7_2 = "SELECT * FROM `trucker_users` WHERE user_id = @user_id"
          L8_2 = Utils
          L8_2 = L8_2.Database
          L8_2 = L8_2.fetchAll
          L9_2 = L7_2
          L10_2 = {}
          L10_2["@user_id"] = L3_2
          L8_2 = L8_2(L9_2, L10_2)
          L8_2 = L8_2[1]
          L2_2.trucker_users = L8_2
        else
          return
        end
      else
        L6_2 = L2_2.trucker_users
        L6_2 = L6_2.loan_notify
        if 1 == L6_2 then
          L6_2 = TriggerClientEvent
          L7_2 = "truck_logistics:Notify"
          L8_2 = A0_2
          L9_2 = "info"
          L10_2 = Utils
          L10_2 = L10_2.translate
          L13_2 = "no_loan_money"
          L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2 = L10_2(L13_2)
          L6_2(L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2)
          L6_2 = deleteAllUserData
          L7_2 = L3_2
          L6_2(L7_2)
          L6_2 = "INSERT INTO `trucker_users` (user_id) VALUES (@user_id);"
          L7_2 = Utils
          L7_2 = L7_2.Database
          L7_2 = L7_2.execute
          L8_2 = L6_2
          L9_2 = {}
          L9_2["@user_id"] = L3_2
          L7_2(L8_2, L9_2)
          L7_2 = "SELECT * FROM `trucker_users` WHERE user_id = @user_id"
          L8_2 = Utils
          L8_2 = L8_2.Database
          L8_2 = L8_2.fetchAll
          L9_2 = L7_2
          L10_2 = {}
          L10_2["@user_id"] = L3_2
          L8_2 = L8_2(L9_2, L10_2)
          L8_2 = L8_2[1]
          L2_2.trucker_users = L8_2
        end
      end
      L6_2 = "SELECT * FROM `trucker_trucks` WHERE user_id = @user_id"
      L7_2 = Utils
      L7_2 = L7_2.Database
      L7_2 = L7_2.fetchAll
      L8_2 = L6_2
      L9_2 = {}
      L9_2["@user_id"] = L3_2
      L7_2 = L7_2(L8_2, L9_2)
      L2_2.trucker_trucks = L7_2
      L7_2 = "SELECT * FROM `trucker_drivers` WHERE user_id = @user_id OR user_id IS NULL"
      L8_2 = Utils
      L8_2 = L8_2.Database
      L8_2 = L8_2.fetchAll
      L9_2 = L7_2
      L10_2 = {}
      L10_2["@user_id"] = L3_2
      L8_2 = L8_2(L9_2, L10_2)
      L2_2.trucker_drivers = L8_2
      L8_2 = "SELECT * FROM `trucker_loans` WHERE user_id = @user_id"
      L9_2 = Utils
      L9_2 = L9_2.Database
      L9_2 = L9_2.fetchAll
      L10_2 = L8_2
      L13_2 = {}
      L13_2["@user_id"] = L3_2
      L9_2 = L9_2(L10_2, L11_2)
      L2_2.trucker_loans = L9_2
      L9_2 = "SELECT party_id, owner FROM `trucker_party_members` WHERE user_id = @user_id"
      L10_2 = Utils
      L10_2 = L10_2.Database
      L10_2 = L10_2.fetchAll
      L13_2 = L9_2
      L12_2 = {}
      L12_2["@user_id"] = L3_2
      L10_2 = L10_2(L11_2, L12_2)
      L10_2 = L10_2[1]
      if L10_2 then
        L13_2 = "SELECT * FROM `trucker_party_members` WHERE user_id = @party_id"
        L12_2 = Utils
        L12_2 = L12_2.Framework
        L12_2 = L12_2.getpartyMembers
        L13_2 = L10_2.party_id
        L12_2 = L12_2(L13_2)
        L2_2.trucker_party_members = L12_2
        L12_2 = pairs
        L13_2 = L2_2.trucker_party_members
        L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
        for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
          L18_2 = Utils
          L18_2 = L18_2.Framework
          L18_2 = L18_2.getPlayerSource
          l21_2 = L17_2.user_id
          L18_2 = L18_2(L19_2)
          if L18_2 then
            L18_2 = L2_2.trucker_party_members
            L18_2 = L18_2[L16_2]
            L18_2.online = true
          end
        end
        L12_2 = "SELECT * from `trucker_party` WHERE id = @party_id"
        L13_2 = Utils
        L13_2 = L13_2.Database
        L13_2 = L13_2.fetchAll
        L14_2 = L12_2
        L15_2 = {}
        L16_2 = L10_2.party_id
        L15_2["@party_id"] = L16_2
        L13_2 = L13_2(L14_2, L15_2)
        L13_2 = L13_2[1]
        L2_2.trucker_party = L13_2
        L13_2 = L2_2.trucker_party
        L14_2 = L10_2.owner
        L13_2.owner = L14_2
        L13_2 = L2_2.trucker_party
        L13_2.user_id = L3_2
        L13_2 = L2_2.trucker_party
        L14_2 = countGroupMembers
        L15_2 = L10_2.party_id
        L14_2 = L14_2(L15_2)
        L13_2.members_count = L14_2
      end
      L13_2 = Utils
      L13_2 = L13_2.Framework
      L13_2 = L13_2.getTopTruckers
      L13_2 = L13_2()
      L2_2.top_truckers = L13_2
      L13_2 = Utils
      L13_2 = L13_2.Framework
      L13_2 = L13_2.getPlayerAccountMoney
      L12_2 = A0_2
      L13_2 = getAccount
      L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2 = L13_2()
      L13_2 = L13_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2)
      L2_2.available_money = L13_2
      L13_2 = {}
      L2_2.config = L13_2
      L13_2 = L2_2.config
      L12_2 = Utils
      L12_2 = L12_2.Table
      L12_2 = L12_2.deepCopy
      L13_2 = Config
      L13_2 = L13_2.dealership
      L12_2 = L12_2(L13_2)
      L13_2.dealership = L12_2
      L13_2 = L2_2.config
      L12_2 = Utils
      L12_2 = L12_2.Table
      L12_2 = L12_2.deepCopy
      L13_2 = Config
      L13_2 = L13_2.repair_price
      L12_2 = L12_2(L13_2)
      L13_2.repair_price = L12_2
      L13_2 = L2_2.config
      L12_2 = Utils
      L12_2 = L12_2.Table
      L12_2 = L12_2.deepCopy
      L13_2 = Config
      L13_2 = L13_2.required_xp_to_levelup
      L12_2 = L12_2(L13_2)
      L13_2.required_xp_to_levelup = L12_2
      L13_2 = L2_2.config
      L12_2 = Utils
      L12_2 = L12_2.Table
      L12_2 = L12_2.deepCopy
      L13_2 = Config
      L13_2 = L13_2.max_loan_per_level
      L12_2 = L12_2(L13_2)
      L13_2.max_loan_per_level = L12_2
      L13_2 = L2_2.config
      L12_2 = Utils
      L12_2 = L12_2.Table
      L12_2 = L12_2.deepCopy
      L13_2 = Config
      L13_2 = L13_2.loans
      L12_2 = L12_2(L13_2)
      L13_2.loans = L12_2
      L13_2 = L2_2.config
      L12_2 = Utils
      L12_2 = L12_2.Table
      L12_2 = L12_2.deepCopy
      L13_2 = Config
      L13_2 = L13_2.repair_price
      L12_2 = L12_2(L13_2)
      L13_2.repair_price = L12_2
      L13_2 = L2_2.config
      L12_2 = Config
      L12_2 = L12_2.jobs
      L12_2 = L12_2.contract_generation
      L12_2 = L12_2.cooldown
      L13_2.cooldown = L12_2
      L13_2 = L2_2.config
      L12_2 = Config
      L12_2 = L12_2.party
      L13_2.party = L12_2
      L13_2 = L2_2.config
      L12_2 = Config
      L12_2 = L12_2.disable_loans
      L13_2.disable_loans = L12_2
      L13_2 = L2_2.config
      L12_2 = Config
      L12_2 = L12_2.disable_drivers
      L13_2.disable_drivers = L12_2
      L13_2 = L2_2.config
      L12_2 = getMaxEmprestimo
      L13_2 = L3_2
      L12_2 = L12_2(L13_2)
      L13_2.max_emprestimo = L12_2
      L13_2 = L2_2.config
      L12_2 = getPlayerLevel
      L13_2 = L3_2
      L12_2 = L12_2(L13_2)
      L13_2.player_level = L12_2
      L13_2 = TriggerClientEvent
      L12_2 = "truck_logistics:open"
      L13_2 = A0_2
      L14_2 = L2_2
      L15_2 = A1_2
      L13_2(L12_2, L13_2, L14_2, L15_2)
      L13_2 = L4_1
      L13_2[A0_2] = true
    else
      L4_2 = TriggerClientEvent
      L5_2 = "truck_logistics:Notify"
      L6_2 = A0_2
      L7_2 = "error"
      L8_2 = Utils
      L8_2 = L8_2.translate
      L9_2 = "no_permission"
      L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2 = L8_2(L9_2)
      L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, l21_2)
    end
  end
end
openUI = L8_1
L8_1 = Citizen
L8_1 = L8_1.CreateThread
function fn_L9_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L0_2 = Wait
  L1_2 = 1000
  L0_2(L1_2)
  while true do
    L0_2 = L3_1
    if L0_2 then
      break
    end
    L0_2 = Wait
    L1_2 = 100
    L0_2(L1_2)
  end
  L0_2 = assert
  L1_2 = Config
  L1_2 = L1_2.trucker_locations
  L2_2 = "^3You have errors in your config file, consider fixing it or redownload the original config.^7"
  L0_2(L1_2, L2_2)
  L0_2 = assert
  L1_2 = GetResourceState
  L2_2 = "lc_utils"
  L1_2 = L1_2(L2_2)
  L1_2 = "started" == L1_2
  L2_2 = "^3The '^1lc_utils^3' file is missing. Please refer to the documentation for installation instructions: ^7https://docs.lixeirocharmoso.com/trucker_simulator/installation^7"
  L0_2(L1_2, L2_2)
  L0_2 = Utils
  L0_2 = L0_2.Math
  L0_2 = L0_2.checkIfCurrentVersionisOutdated
  L1_2 = L0_1
  L2_2 = Utils
  L2_2 = L2_2.Version
  L0_2 = L0_2(L1_2, L2_2)
  if L0_2 then
    L0_2 = true
    L2_2 = L0_2
    L0_2 = error
    L1_2 = "^3The script requires 'lc_utils' in version ^1"
    L2_2 = L0_1
    L3_2 = "^3, but you currently have version ^1"
    L4_2 = Utils
    L4_2 = L4_2.Version
    L5_2 = "^3. Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip^7"
    L1_2 = L1_2 .. L2_2 .. L3_2 .. L4_2 .. L5_2
    L0_2(L1_2)
  end
  L0_2 = checkIfFrameworkWasLoaded
  L0_2()
  L0_2 = checkScriptName
  L0_2()
  L0_2 = Utils
  L0_2 = L0_2.loadLanguageFile
  L1_2 = Lang
  L0_2(L1_2)
  L0_2 = runCreateTableQueries
  L0_2()
  L0_2 = Utils
  L0_2 = L0_2.Database
  L0_2 = L0_2.execute
  L1_2 = "UPDATE `trucker_available_contracts` SET progress = NULL"
  L2_2 = {}
  L0_2(L1_2, L2_2)
  L0_2 = {}
  L1_2 = {}
  L2_2 = {}
  L3_2 = "driver_jobs"
  L4_2 = "fuel_consumption"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L1_2.config_path = L2_2
  L2_2 = {}
  L2_2.min = 2
  L2_2.max = 6
  L1_2.default_value = L2_2
  L2_2 = {}
  L3_2 = {}
  L4_2 = "loans"
  L5_2 = "payment_interval_hours"
  L3_2[1] = L4_2
  L3_2[2] = L5_2
  L2_2.config_path = L3_2
  L2_2.default_value = 24
  L3_2 = {}
  L4_2 = {}
  L5_2 = "loans"
  L6_2 = "plans"
  L4_2[1] = L5_2
  L4_2[2] = L6_2
  L3_2.config_path = L4_2
  L4_2 = {}
  L5_2 = {}
  L5_2.loan_amount = 20000
  L5_2.interest_rate = 20
  L5_2.repayment_days = 15
  L4_2[1] = L5_2
  L3_2.default_value = L4_2
  L4_2 = {}
  L5_2 = {}
  L6_2 = "repair_price"
  L7_2 = "fuel"
  L5_2[1] = L6_2
  L5_2[2] = L7_2
  L4_2.config_path = L5_2
  L4_2.default_value = 10
  L5_2 = {}
  L6_2 = {}
  L7_2 = "jobs"
  L8_2 = "cancel_job_key"
  L6_2[1] = L7_2
  L6_2[2] = L8_2
  L5_2.config_path = L6_2
  L5_2.default_value = 167
  L6_2 = {}
  L7_2 = {}
  L8_2 = "jobs"
  L9_2 = "contract_generation"
  L7_2[1] = L8_2
  L7_2[2] = L9_2
  L6_2.config_path = L7_2
  L7_2 = {}
  L7_2.cooldown = 5
  L7_2.contracts_per_interval = 5
  L7_2.max_active_contracts = 30
  L7_2.max_illegal_contracts = 5
  L6_2.default_value = L7_2
  L7_2 = {}
  L8_2 = {}
  L9_2 = "jobs"
  L10_2 = "economy"
  L8_2[1] = L9_2
  L8_2[2] = L10_2
  L7_2.config_path = L8_2
  L8_2 = {}
  L9_2 = {}
  L9_2.min = 1000
  L9_2.max = 1600
  L8_2.price_per_km = L9_2
  L9_2 = {}
  L9_2.freight = 1.2
  L9_2.illegal = 1.8
  L8_2.multipliers = L9_2
  L7_2.default_value = L8_2
  L8_2 = {}
  L9_2 = {}
  L10_2 = "jobs"
  L13_2 = "special_cargo"
  L9_2[1] = L10_2
  L9_2[2] = L13_2
  L8_2.config_path = L9_2
  L9_2 = {}
  L10_2 = {}
  L10_2.chance_percent = 10
  L10_2.seconds_per_km = 90
  L10_2.reward_penalty_percent = 20
  L9_2.urgent = L10_2
  L10_2 = {}
  L10_2.min_health_percent = 70
  L10_2.reward_penalty_percent = 20
  L9_2.fragile = L10_2
  L8_2.default_value = L9_2
  L9_2 = {}
  L10_2 = {}
  L13_2 = "jobs"
  L12_2 = "truck_rental"
  L10_2[1] = L13_2
  L10_2[2] = L12_2
  L9_2.config_path = L10_2
  L10_2 = {}
  L13_2 = {}
  L12_2 = "hauler"
  L13_2 = "packer"
  L14_2 = "blacktop"
  L15_2 = "brickades"
  L16_2 = "vetirs"
  L13_2[1] = L12_2
  L13_2[2] = L13_2
  L13_2[3] = L14_2
  L13_2[4] = L15_2
  L13_2[5] = L16_2
  L10_2.available_trucks = L13_2
  L10_2.must_return_truck = true
  L9_2.default_value = L10_2
  L0_2[1] = L1_2
  L0_2[2] = L2_2
  L0_2[3] = L3_2
  L0_2[4] = L4_2
  L0_2[5] = L5_2
  L0_2[6] = L6_2
  L0_2[7] = L7_2
  L0_2[8] = L8_2
  L0_2[9] = L9_2
  L1_2 = Utils
  L1_2 = L1_2.validateConfig
  L2_2 = Config
  L3_2 = L0_2
  L1_2 = L1_2(L2_2, L3_2)
  Config = L1_2
  L1_2 = Wait
  L2_2 = 1000
  L1_2(L2_2)
  L1_2 = {}
  L2_2 = {}
  L3_2 = "contract_id"
  L4_2 = "contract_type"
  L5_2 = "contract_name"
  L6_2 = "coords_index"
  L7_2 = "price_per_km"
  L8_2 = "cargo_type"
  L9_2 = "fragile"
  L10_2 = "valuable"
  L13_2 = "illegal"
  L12_2 = "fast"
  L13_2 = "truck"
  L14_2 = "trailer"
  L15_2 = "external_data"
  L16_2 = "progress"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L2_2[8] = L10_2
  L2_2[9] = L13_2
  L2_2[10] = L12_2
  L2_2[11] = L13_2
  L2_2[12] = L14_2
  L2_2[13] = L15_2
  L2_2[14] = L16_2
  L1_2.trucker_available_contracts = L2_2
  L2_2 = {}
  L3_2 = "driver_id"
  L4_2 = "user_id"
  L5_2 = "name"
  L6_2 = "product_type"
  L7_2 = "distance"
  L8_2 = "valuable"
  L9_2 = "fragile"
  L10_2 = "fast"
  L13_2 = "price"
  L12_2 = "img"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L2_2[8] = L10_2
  L2_2[9] = L13_2
  L2_2[10] = L12_2
  L1_2.trucker_drivers = L2_2
  L2_2 = {}
  L3_2 = "id"
  L4_2 = "user_id"
  L5_2 = "loan"
  L6_2 = "remaining_amount"
  L7_2 = "day_cost"
  L8_2 = "taxes_on_day"
  L9_2 = "timer"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L1_2.trucker_loans = L2_2
  L2_2 = {}
  L3_2 = "truck_id"
  L4_2 = "user_id"
  L5_2 = "truck_name"
  L6_2 = "driver"
  L7_2 = "body"
  L8_2 = "engine"
  L9_2 = "transmission"
  L10_2 = "wheels"
  L13_2 = "fuel"
  L12_2 = "properties"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L2_2[8] = L10_2
  L2_2[9] = L13_2
  L2_2[10] = L12_2
  L1_2.trucker_trucks = L2_2
  L2_2 = {}
  L3_2 = "user_id"
  L4_2 = "money"
  L5_2 = "total_earned"
  L6_2 = "finished_deliveries"
  L7_2 = "exp"
  L8_2 = "traveled_distance"
  L9_2 = "skill_points"
  L10_2 = "product_type"
  L13_2 = "distance"
  L12_2 = "valuable"
  L13_2 = "fragile"
  L14_2 = "fast"
  L15_2 = "illegal"
  L16_2 = "loan_notify"
  L17_2 = "dark_theme"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L2_2[6] = L8_2
  L2_2[7] = L9_2
  L2_2[8] = L10_2
  L2_2[9] = L13_2
  L2_2[10] = L12_2
  L2_2[11] = L13_2
  L2_2[12] = L14_2
  L2_2[13] = L15_2
  L2_2[14] = L16_2
  L2_2[15] = L17_2
  L1_2.trucker_users = L2_2
  L2_2 = {}
  L3_2 = "id"
  L4_2 = "name"
  L5_2 = "description"
  L6_2 = "pass"
  L7_2 = "members"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L1_2.trucker_party = L2_2
  L2_2 = {}
  L3_2 = "party_id"
  L4_2 = "user_id"
  L5_2 = "owner"
  L6_2 = "finished_deliveries"
  L7_2 = "joined_at"
  L2_2[1] = L3_2
  L2_2[2] = L4_2
  L2_2[3] = L5_2
  L2_2[4] = L6_2
  L2_2[5] = L7_2
  L1_2.trucker_party_members = L2_2
  L2_2 = {}
  L3_2 = {}
  L3_2.dark_theme = "ALTER TABLE `trucker_users` ADD COLUMN `dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1' AFTER `loan_notify`;"
  L3_2.external_data = "ALTER TABLE `trucker_available_contracts` ADD COLUMN `external_data` TEXT NULL DEFAULT NULL AFTER `trailer`;"
  L3_2.progress = "ALTER TABLE `trucker_available_contracts` ADD COLUMN `progress` TINYINT(2) NOT NULL DEFAULT '0';"
  L3_2.illegal = "ALTER TABLE `trucker_users` ADD COLUMN `illegal` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' AFTER `fast`;"
  L2_2.trucker_users = L3_2
  L3_2 = {}
  L3_2.fuel = "ALTER TABLE `trucker_trucks` ADD COLUMN `fuel` INT UNSIGNED NOT NULL DEFAULT '100' AFTER `wheels`;"
  L2_2.trucker_trucks = L3_2
  L3_2 = {}
  L3_2.illegal = "ALTER TABLE `trucker_available_contracts` ADD COLUMN `illegal` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0' AFTER `valuable`;"
  L2_2.trucker_available_contracts = L3_2
  L3_2 = {}
  L4_2 = {}
  L5_2 = {}
  L5_2.sql = "ALTER TABLE `trucker_available_contracts` CHANGE COLUMN `progress` `progress` VARCHAR(50) NULL DEFAULT NULL AFTER `external_data`;"
  L5_2.DATA_TYPE = "varchar"
  L5_2.COLUMN_TYPE = "varchar(50)"
  L5_2.COLUMN_DEFAULT = "NULL"
  L5_2.IS_NULLABLE = "YES"
  L5_2.COLUMN_NAME = "progress"
  L4_2.progress = L5_2
  L3_2.trucker_available_contracts = L4_2
  L4_2 = Utils
  L4_2 = L4_2.Database
  L4_2 = L4_2.validateTableColumns
  L5_2 = L1_2
  L6_2 = L2_2
  L7_2 = L3_2
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = {}
  L5_2 = "ALTER TABLE `trucker_users` CHANGE `user_id` `user_id` VARCHAR(50) CHARACTER SET %s COLLATE %s NOT NULL"
  L6_2 = "ALTER TABLE `trucker_party_members` CHANGE `user_id` `user_id` VARCHAR(50) CHARACTER SET %s COLLATE %s NOT NULL"
  L7_2 = "ALTER TABLE `trucker_trucks` CHANGE `user_id` `user_id` VARCHAR(50) CHARACTER SET %s COLLATE %s NOT NULL"
  L8_2 = "ALTER TABLE `trucker_loans` CHANGE `user_id` `user_id` VARCHAR(50) CHARACTER SET %s COLLATE %s NOT NULL"
  L9_2 = "ALTER TABLE `trucker_drivers` CHANGE `user_id` `user_id` VARCHAR(50) CHARACTER SET %s COLLATE %s NULL DEFAULT NULL"
  L4_2[1] = L5_2
  L4_2[2] = L6_2
  L4_2[3] = L7_2
  L4_2[4] = L8_2
  L4_2[5] = L9_2
  L5_2 = Utils
  L5_2 = L5_2.Framework
  L5_2 = L5_2.validateTableCollations
  L6_2 = "trucker_users"
  L7_2 = "user_id"
  L8_2 = L4_2
  L5_2(L6_2, L7_2, L8_2)
  L5_2 = searchForDataIssuesInDatabase
  L5_2()
  L5_2 = searchForErrorsInConfig
  L5_2()
  L5_2 = generateTruckerAvailableContractsThread
  L5_2()
  L5_2 = generateTruckerDriversThread
  L5_2()
  L5_2 = generateTruckerDriversJobsThread
  L5_2()
  L5_2 = updateLoansThread
  L5_2()
end
L8_1(fn_L9_1)
function L8_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2
  L0_2 = pairs
  L1_2 = Config
  L1_2 = L1_2.dealership
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    L6_2 = L5_2.required_level
    if nil == L6_2 then
      L6_2 = print
      L7_2 = "^3WARNING: Missing '^1required_level^3' setting in config '^1Config.dealership[\""
      L8_2 = L4_2
      L9_2 = "\"]^3' in resource '^1"
      L10_2 = GetCurrentResourceName
      L10_2 = L10_2()
      L13_2 = "^3'. The value will be set to its default. Consider redownloading the original config to obtain the correct config.^7"
      L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2
      L6_2(L7_2)
      L5_2.required_level = 0
    end
  end
  L0_2 = pairs
  L1_2 = Config
  L1_2 = L1_2.dealership
  L0_2, L1_2, L2_2, L3_2 = L0_2(L1_2)
  for L4_2, L5_2 in L0_2, L1_2, L2_2, L3_2 do
    L6_2 = L5_2.driver_bonus
    if nil == L6_2 then
      L6_2 = print
      L7_2 = "^3WARNING: Missing '^1driver_bonus^3' setting in config '^1Config.dealership[\""
      L8_2 = L4_2
      L9_2 = "\"]^3' in resource '^1"
      L10_2 = GetCurrentResourceName
      L10_2 = L10_2()
      L13_2 = "^3'. The value will be set to its default. Consider redownloading the original config to obtain the correct config.^7"
      L7_2 = L7_2 .. L8_2 .. L9_2 .. L10_2 .. L11_2
      L6_2(L7_2)
      L5_2.driver_bonus = 0
    end
  end
end
searchForErrorsInConfig = L8_1
function L8_1()
local L0_2, L1_2, L2_2
  L0_2 = assert
  L1_2 = Utils
  L1_2 = L1_2.Framework
  L1_2 = L1_2.getPlayerId
  L2_2 = "^3The framework wasn't loaded in the '^1lc_utils^3' resource. Please check if the '^1Config.framework^3' is correctly set to your framework, and make sure there are no errors in your file. For more information, refer to the documentation at '^7https://docs.lixeirocharmoso.com/^3'.^7"
  L0_2(L1_2, L2_2)
end
checkIfFrameworkWasLoaded = L8_1
function L8_1()
local L0_2, L1_2, L2_2
  L0_2 = assert
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  L1_2 = "lc_truck_logistics" == L1_2
  L2_2 = "^3The script name does not match the expected resource name. Please ensure that the current resource name is set to '^1lc_truck_logistics^7'."
  L0_2(L1_2, L2_2)
end
checkScriptName = L8_1
function L8_1()
local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L13_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, a6_2, L20_2, a6_2, L22_2, a6_2, l3_2, l6_2
  L0_2 = Config
  L0_2 = L0_2.delivery_locations
  L0_2 = #L0_2
  L1_2 = "DELETE FROM `trucker_available_contracts` WHERE coords_index >= @max_contract"
  L2_2 = Utils
  L2_2 = L2_2.Database
  L2_2 = L2_2.execute
  L3_2 = L1_2
  L4_2 = {}
  L4_2["@max_contract"] = L0_2
  L2_2(L3_2, L4_2)
  L2_2 = ""
  L3_2 = pairs
  L4_2 = Config
  L4_2 = L4_2.dealership
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = L2_2
    L10_2 = "'"
    L13_2 = L7_2
    L12_2 = "',"
    L9_2 = L9_2 .. L10_2 .. L11_2 .. L12_2
    L2_2 = L9_2
  end
  L3_2 = {}
  if "" ~= L2_2 then
    L4_2 = "SELECT truck_id, truck_name FROM `trucker_trucks` WHERE truck_name NOT IN("
    L6_2 = L2_2
    L5_2 = L2_2.sub
    L7_2 = 1
    L8_2 = -2
    L5_2 = L5_2(L6_2, L7_2, L8_2)
    L6_2 = ")"
    L4_2 = L4_2 .. L5_2 .. L6_2
    L5_2 = Utils
    L5_2 = L5_2.Database
    L5_2 = L5_2.fetchAll
    L6_2 = L4_2
    L7_2 = {}
    L5_2 = L5_2(L6_2, L7_2)
    L3_2 = L5_2
  end
  L4_2 = [[
SELECT t.user_id
				FROM trucker_trucks t
					LEFT JOIN trucker_users u ON (t.user_id = u.user_id)
					WHERE u.user_id IS NULL]]
  L5_2 = Utils
  L5_2 = L5_2.Database
  L5_2 = L5_2.fetchAll
  L6_2 = L4_2
  L7_2 = {}
  L5_2 = L5_2(L6_2, L7_2)
  L6_2 = [[
SELECT t.user_id
				FROM trucker_loans t
					LEFT JOIN trucker_users u ON (t.user_id = u.user_id)
					WHERE u.user_id IS NULL]]
  L7_2 = Utils
  L7_2 = L7_2.Database
  L7_2 = L7_2.fetchAll
  L8_2 = L6_2
  L9_2 = {}
  L7_2 = L7_2(L8_2, L9_2)
  L8_2 = [[
SELECT t.user_id
				FROM trucker_party_members t
					LEFT JOIN trucker_users u ON (t.user_id = u.user_id)
					WHERE u.user_id IS NULL]]
  L9_2 = Utils
  L9_2 = L9_2.Database
  L9_2 = L9_2.fetchAll
  L10_2 = L8_2
  L13_2 = {}
  L9_2 = L9_2(L10_2, L11_2)
  L10_2 = [[
SELECT t.user_id
				FROM trucker_drivers t
					LEFT JOIN trucker_users u ON (t.user_id = u.user_id)
					WHERE u.user_id IS NULL AND t.user_id IS NOT NULL]]
  L13_2 = Utils
  L13_2 = L13_2.Database
  L13_2 = L13_2.fetchAll
  L12_2 = L10_2
  L13_2 = {}
  L13_2 = L13_2(L12_2, L13_2)
  L12_2 = #L3_2
  if not (L12_2 > 0) then
    L12_2 = #L5_2
    if not (L12_2 > 0) then
      L12_2 = #L7_2
      if not (L12_2 > 0) then
        L12_2 = #L9_2
        if not (L12_2 > 0) then
          L12_2 = #L13_2
          if not (L12_2 > 0) then
            goto lbl_101
          end
        end
      end
    end
  end
  L12_2 = print
  L13_2 = "^8["
  L14_2 = GetCurrentResourceName
  L14_2 = L14_2()
  L15_2 = "] DATABASE ISSUES:^3 The following issues were found in your database:^7"
  L13_2 = L13_2 .. L14_2 .. L15_2
  L12_2(L13_2)
  ::lbl_101::
  L12_2 = pairs
  L13_2 = L3_2
  L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
  for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
    L18_2 = print
    l21_2 = "^8["
    L20_2 = GetCurrentResourceName
    L20_2 = L20_2()
    a6_2 = "]^3 Vehicle ^1"
    L22_2 = L17_2.truck_name
    a6_2 = "^3 (ID "
    l17_2 = L17_2.truck_id
    l6_2 = ") is in your ^1trucker_trucks^3 table but not in your config.^7"
    l21_2 = l21_2 .. L20_2 .. l21_2 .. L22_2 .. L23_2 .. L24_2 .. L25_2
    L18_2(l21_2)
  end
  L12_2 = pairs
  L13_2 = L5_2
  L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
  for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
    L18_2 = print
    l21_2 = "^8["
    L20_2 = GetCurrentResourceName
    L20_2 = L20_2()
    a6_2 = "]^3 User ^1"
    L22_2 = L17_2.user_id
    a6_2 = "^3 is in your ^1trucker_trucks^3 table but this user does not exist in trucker_users table.^7"
    l21_2 = l21_2 .. L20_2 .. l21_2 .. L22_2 .. L23_2
    L18_2(l21_2)
  end
  L12_2 = pairs
  L13_2 = L7_2
  L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
  for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
    L18_2 = print
    l21_2 = "^8["
    L20_2 = GetCurrentResourceName
    L20_2 = L20_2()
    a6_2 = "]^3 User ^1"
    L22_2 = L17_2.user_id
    a6_2 = "^3 is in your ^1trucker_loans^3 table but this user does not exist in trucker_users table.^7"
    l21_2 = l21_2 .. L20_2 .. l21_2 .. L22_2 .. L23_2
    L18_2(l21_2)
  end
  L12_2 = pairs
  L13_2 = L9_2
  L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
  for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
    L18_2 = print
    l21_2 = "^8["
    L20_2 = GetCurrentResourceName
    L20_2 = L20_2()
    a6_2 = "]^3 User ^1"
    L22_2 = L17_2.user_id
    a6_2 = "^3 is in your ^1trucker_party_members^3 table but this user does not exist in trucker_users table.^7"
    l21_2 = l21_2 .. L20_2 .. l21_2 .. L22_2 .. L23_2
    L18_2(l21_2)
  end
  L12_2 = pairs
  L13_2 = L11_2
  L12_2, L13_2, L14_2, L15_2 = L12_2(L13_2)
  for L16_2, L17_2 in L12_2, L13_2, L14_2, L15_2 do
    L18_2 = print
    l21_2 = "^8["
    L20_2 = GetCurrentResourceName
    L20_2 = L20_2()
    a6_2 = "]^3 User ^1"
    L22_2 = L17_2.user_id
    a6_2 = "^3 is in your ^1trucker_drivers^3 table but this user does not exist in trucker_users table.^7"
    l21_2 = l21_2 .. L20_2 .. l21_2 .. L22_2 .. L23_2
    L18_2(l21_2)
  end
  L12_2 = #L3_2
  if not (L12_2 > 0) then
    L12_2 = #L5_2
    if not (L12_2 > 0) then
      L12_2 = #L7_2
      if not (L12_2 > 0) then
        L12_2 = #L9_2
        if not (L12_2 > 0) then
          L12_2 = #L13_2
          if not (L12_2 > 0) then
            goto lbl_205
          end
        end
      end
    end
  end
  L12_2 = print
  L13_2 = "^8["
  L14_2 = GetCurrentResourceName
  L14_2 = L14_2()
  L15_2 = "] HOW TO RESOLVE ISSUES:^3 You can add missing data to the config or manually remove them from your database.^7"
  L13_2 = L13_2 .. L14_2 .. L15_2
  L12_2(L13_2)
  ::lbl_205::
end
searchForDataIssuesInDatabase = L8_1
function L8_1()
local L0_2, L1_2
  L0_2 = Config
  L0_2 = L0_2.create_table
  if false ~= L0_2 then
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L1_2 = [[
			CREATE TABLE IF NOT EXISTS `trucker_available_contracts` (
				`contract_id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`contract_type` TINYINT(3) NOT NULL DEFAULT '0',
				`contract_name` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`coords_index` SMALLINT(6) UNSIGNED NOT NULL DEFAULT '0',
				`price_per_km` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`cargo_type` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`fragile` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`valuable` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`fast` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`illegal` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`truck` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`trailer` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`external_data` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`progress` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`contract_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L1_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L1_2 = [[
			CREATE TABLE IF NOT EXISTS `trucker_drivers` (
				`driver_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`name` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
				`product_type` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`distance` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`valuable` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`fragile` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`fast` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`price` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`img` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`driver_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L1_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L1_2 = [[
			CREATE TABLE IF NOT EXISTS `trucker_loans` (
				`id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`loan` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`remaining_amount` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`day_cost` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`taxes_on_day` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`timer` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				PRIMARY KEY (`id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L1_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L1_2 = [[
			CREATE TABLE IF NOT EXISTS `trucker_trucks` (
				`truck_id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`truck_name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`driver` INT(10) UNSIGNED NULL DEFAULT NULL,
				`body` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '1000',
				`engine` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '1000',
				`transmission` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '1000',
				`wheels` SMALLINT(5) UNSIGNED NOT NULL DEFAULT '1000',
				`fuel` INT(11) UNSIGNED NOT NULL DEFAULT '100',
				`properties` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',
				PRIMARY KEY (`truck_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L1_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L1_2 = [[
			CREATE TABLE IF NOT EXISTS `trucker_users` (
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`money` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`total_earned` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`finished_deliveries` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`exp` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`traveled_distance` DOUBLE UNSIGNED NOT NULL DEFAULT '0',
				`skill_points` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`product_type` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`distance` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`valuable` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`fragile` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`fast` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`illegal` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`loan_notify` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',
				`dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',
				PRIMARY KEY (`user_id`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L1_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L1_2 = [[
			CREATE TABLE IF NOT EXISTS `trucker_party` (
				`id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
				`name` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`description` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
				`pass` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',
				`members` INT(10) UNSIGNED NOT NULL,
				PRIMARY KEY (`id`) USING BTREE,
				UNIQUE INDEX `name` (`name`) USING BTREE
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L1_2)
    L0_2 = Utils
    L0_2 = L0_2.Database
    L0_2 = L0_2.execute
    L1_2 = [[
			CREATE TABLE IF NOT EXISTS `trucker_party_members` (
				`party_id` INT(11) UNSIGNED NOT NULL,
				`user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
				`owner` TINYINT(3) NOT NULL DEFAULT '0',
				`finished_deliveries` INT(10) UNSIGNED NOT NULL DEFAULT '0',
				`joined_at` INT(11) NOT NULL DEFAULT '0',
				PRIMARY KEY (`party_id`, `user_id`) USING BTREE,
				CONSTRAINT `party_fk1` FOREIGN KEY (`party_id`) REFERENCES `trucker_party` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION
			)
			COLLATE='utf8mb4_general_ci'
			ENGINE=InnoDB
			;
		]]
    L0_2(L1_2)
  end
end
runCreateTableQueries = L8_1
