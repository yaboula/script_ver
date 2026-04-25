


-- Initialize Utils namespace
if not Utils then
  Utils = {}
end

if not Utils.Server then
  Utils.Server = {}
end

-- Seed random number generator for UUID generation
math.randomseed(os.time())

---Generate a random UUID (Version 4)
---@return string UUID in format xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
function Utils.Server.GenerateUuid()
  local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  
  return string.gsub(template, "[xy]", function(char)
    -- For 'x': random hex digit (0-15)
    -- For 'y': random hex digit (8-11) for UUID v4 variant bits
    local value = (char == "x") and math.random(0, 15) or math.random(8, 11)
    return string.format("%x", value)
  end)
end

---Get nearby players with their information
---@param sourcePlayerId number The source player ID to exclude (or nil to include all)
---@param coords vector3 The coordinates to search from
---@param radius number The search radius
---@param includeSelf boolean Whether to include the source player
---@return table Array of player data {id, identifier, name}
function Utils.Server.GetNearbyPlayers(sourcePlayerId, coords, radius, includeSelf)
  local nearbyPlayers = lib.getNearbyPlayers(coords, radius)
  local result = {}
  
  for _, player in ipairs(nearbyPlayers) do
    if includeSelf or sourcePlayerId ~= player.id then
      local playerInfo = Framework.Server.GetPlayerInfo(player.id)
      
      table.insert(result, {
        id = player.id,
        identifier = Framework.Server.GetPlayerIdentifier(player.id),
        name = playerInfo and playerInfo.name or nil
      })
    end
  end
  
  DebugPrint(string.format("Found %s nearby players", #result), "debug", result)
  return result
end

---Get nearby players for a dealership (used when selling vehicles to find potential customers)
---@param source number The player requesting nearby players
---@param dealershipId string|nil The dealership ID (admins can see themselves if not employee)
---@return table Array of nearby players
lib.callback.register("jg-dealerships:server:get-nearby-players", function(source, dealershipId)
  local playerCoords = GetEntityCoords(GetPlayerPed(source))
  local nearbyPlayers = Utils.Server.GetNearbyPlayers(source, playerCoords, 10.0, false)
  
  -- Allow admins to sell to themselves even if not an employee
  if dealershipId then
    local isAdmin = Framework.Server.IsAdmin(source)
    if isAdmin then
      local identifier = Framework.Server.GetPlayerIdentifier(source)
      
      local isEmployee = MySQL.single.await(
        "SELECT identifier FROM dealership_employees WHERE identifier = ? AND dealership = ?",
        {identifier, dealershipId}
      )
      
      if not isEmployee then
        local playerInfo = Framework.Server.GetPlayerInfo(source)
        
        table.insert(nearbyPlayers, 1, {
          id = source,
          identifier = identifier,
          name = (playerInfo and playerInfo.name) or "Unknown",
          isSelf = true
        })
      end
    end
  end
  
  return nearbyPlayers
end)

---Send notification to another player
RegisterNetEvent("jg-dealerships:server:notify-other-player", function(targetPlayerId, ...)
  local src = source
  if type(src) ~= "number" or src <= 0 then return end
  if type(targetPlayerId) ~= "number" or targetPlayerId <= 0 then return end
  TriggerClientEvent("jg-dealerships:client:notify", targetPlayerId, ...)
end)

---Initialize the database when the resource starts
AddEventHandler("onResourceStart", function(resourceName)
  if GetCurrentResourceName() ~= resourceName then
    return
  end
  
  InitSQL()
end)
