Core = nil
weedData = {}

local avatarCache = {}
local authHeader = "Bot " .. botToken

CreateThread(function()
  local coreObj, framework = GetCore()
  Config.Framework = framework
  Core = coreObj
end)

function RegisterCallback(callbackName, handler)
  while not Core do
    Citizen.Wait(0)
  end
  if Config.Framework == "esx" or Config.Framework == "oldesx" then
    Core.RegisterServerCallback(callbackName, function(source, cb, data)
      handler(source, cb, data)
    end)
  else
    Core.Functions.CreateCallback(callbackName, function(source, cb, data)
      handler(source, cb, data)
    end)
  end
end

function GetPlayer(source)
  while Core == nil do
    Citizen.Wait(0)
  end
  if Config.Framework == "esx" then
    return Core.GetPlayerFromId(source)
  else
    return Core.Functions.GetPlayer(source)
  end
end

function DiscordRequest(method, endpoint, body)
  local response = nil
  local url = "https://discordapp.com/api/" .. endpoint
  local encodedBody = ""
  if #body > 0 then
    encodedBody = json.encode(body) or ""
  end
  PerformHttpRequest(url, function(code, data, headers)
    response = { data = data, code = code, headers = headers }
  end, method, encodedBody, {
    ["Content-Type"] = "application/json",
    ["Authorization"] = authHeader,
  })
  while response == nil do
    Citizen.Wait(0)
  end
  return response
end

function GetDiscordAvatar(source)
  local discordId = nil
  local avatarUrl = nil

  for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
    if string.match(identifier, "discord:") then
      discordId = string.gsub(identifier, "discord:", "")
      break
    end
  end

  if discordId then
    if avatarCache[discordId] == nil then
      local endpoint = string.format("users/%s", discordId)
      local result = DiscordRequest("GET", endpoint, {})
      if result.code == 200 then
        local userData = json.decode(result.data)
        if userData and userData.avatar then
          local firstChar = userData.avatar:sub(1, 1)
          local secondChar = userData.avatar:sub(2, 2)
          if firstChar and secondChar == "_" then
            avatarUrl = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. userData.avatar .. ".gif"
          else
            avatarUrl = "https://media.discordapp.net/avatars/" .. discordId .. "/" .. userData.avatar .. ".png"
          end
        end
      end
      avatarCache[discordId] = avatarUrl
    else
      avatarUrl = avatarCache[discordId]
    end
  end

  if avatarUrl == nil then
    avatarUrl = defaultPhoto
  end
  return avatarUrl
end

CreateThread(function()
  RegisterCallback("mWeed:GetPlayerInformations", function(source, cb)
    cb({
      avatar = GetDiscordAvatar(source),
      name = GetPlayerRoleplayName(source),
    })
  end)

  RegisterCallback("mWeed:GetPlayerInventory", function(source, cb)
    cb(GetPlayerInventory(source))
  end)

  RegisterCallback("mWeed:buyItem", function(source, cb, cart)
    cb(BuyItem(source, cart))
  end)

  RegisterCallback("mWeed:sellItem", function(source, cb, cart)
    cb(SellItem(source, cart))
  end)

  RegisterCallback("mWeed:checkItem", function(source, cb, itemData)
    cb(CheckItem(source, itemData))
  end)
end)

function GetIdentifier(source)
  local player = GetPlayer(source)
  if not player then return false end
  if Config.Framework == "esx" then
    return player.identifier
  else
    return player.PlayerData.citizenid
  end
end

function GetPlayerRoleplayName(source)
  while not Core do
    Citizen.Wait(0)
  end
  local name = GetPlayerName(source)
  if Config.Framework == "esx" or Config.Framework == "oldesx" then
    local player = Core.GetPlayerFromId(source)
    if player then
      name = player.getName()
    end
  else
    local player = Core.Functions.GetPlayer(source)
    if player then
      name = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end
  end
  return name
end

function GetSellableItem(itemName)
  for _, item in pairs(Config.Dealer.sellableItems) do
    if item.name == itemName then
      return item
    end
  end
end

function GetBuyableItem(itemName)
  for _, item in pairs(Config.Dealer.buyableItems) do
    if item.name == itemName then
      return item
    end
  end
end

function GetIncludedItem(itemList, itemName)
  if itemList then
    for _, item in pairs(itemList) do
      if item == itemName or item.name == itemName then
        return item
      end
    end
  end
  return false
end

function GetPlayerInventory(source, filterItems)
  local inventory = {}
  local player = GetPlayer(source)

  if Config.Framework == "esx" or Config.Framework == "oldesx" then
    for _, item in pairs(player.getInventory()) do
      if item then
        local isSellable = GetSellableItem(item.name)
        local isIncluded = not isSellable and GetIncludedItem(filterItems, item.name)
        if isSellable or isIncluded then
          local amount = item.amount or item.count
          table.insert(inventory, {
            name = item.name,
            label = item.label,
            amount = amount,
          })
        end
      end
    end
  else
    for _, item in pairs(player.PlayerData.items) do
      if item then
        local isSellable = GetSellableItem(item.name)
        local isIncluded = not isSellable and GetIncludedItem(filterItems, item.name)
        if isSellable or isIncluded then
          local amount = item.amount or item.count
          table.insert(inventory, {
            name = item.name,
            label = item.label,
            amount = amount,
          })
        end
      end
    end
  end
  return inventory
end

function CheckItem(source, itemData)
  local inventory = GetPlayerInventory(source, { itemData.name })
  for _, item in pairs(inventory) do
    if item.name == itemData.name then
      local required = tonumber(itemData.reqAmount)
      local owned = tonumber(item.amount or item.count)
      if required <= owned then
        return true
      end
    end
  end
  return false
end

function GetQBCoreItemByName(items, itemName)
  for _, item in pairs(items) do
    if item and item.name == itemName then
      return item
    end
  end
  return false
end
