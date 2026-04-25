


-- Initialize Utils namespace
if not Utils then
  Utils = {}
end

if not Utils.Client then
  Utils.Client = {}
end

-- Ensure screen is faded in when script loads
DoScreenFadeIn(0)

---Set vehicle color (supports RGB table or paint index)
---@param vehicle number Vehicle entity
---@param color table|number RGB table {r, g, b} or paint index
---@return boolean Success status
function Utils.Client.SetVehicleColourNew(vehicle, color)
  if not vehicle then
    return false
  end
  
  if type(color) == "table" then
    -- RGB custom color
    local r, g, b = color.r, color.g, color.b
    
    -- Set primary color
    SetVehicleModColor_1(vehicle, 1, 0, 0)
    SetVehicleCustomPrimaryColour(vehicle, r, g, b)
    
    -- Set secondary color
    SetVehicleModColor_2(vehicle, 1, 0)
    SetVehicleCustomSecondaryColour(vehicle, r, g, b)
  elseif type(color) == "number" then
    -- Standard paint index
    ClearVehicleCustomPrimaryColour(vehicle)
    ClearVehicleCustomSecondaryColour(vehicle)
    SetVehicleColours(vehicle, color, color)
  end
  
  -- Reset extras and dirt
  SetVehicleExtraColours(vehicle, 0, nil)
  SetVehicleDirtLevel(vehicle, 0.0)
  
  return true
end
---Calculate the center point of a polygon
---@param points table Array of vector3 points
---@return vector3 Center point
function Utils.Client.GetPolygonCenter(points)
  local sumX, sumY, sumZ = 0, 0, 0
  local count = #points
  
  for _, point in ipairs(points) do
    sumX = sumX + point.x
    sumY = sumY + point.y
    sumZ = sumZ + point.z
  end
  
  return vec3(sumX / count, sumY / count, sumZ / count)
end
---Draw a marker on the current frame
---@param markerType number Marker type ID
---@param pos vector3 Position
---@param scale number|table Scale (uniform or {x,y,z})
---@param color table RGBA color {r, g, b, a}
---@param rotation? vector3 Rotation (default: 0,0,0)
---@param direction? vector3 Direction (default: 0,0,0)
---@param bobUpAndDown? boolean Bob up and down
---@param faceCamera? boolean Face camera
---@param rotate? boolean Rotate marker
---@param drawOnEnts? boolean Draw on entities
function Utils.Client.DrawMarkerOnFrame(markerType, pos, scale, color, rotation, direction, bobUpAndDown, faceCamera, rotate, drawOnEnts)
  -- Set defaults
  rotation = rotation or vec3(0, 0, 0)
  direction = direction or vec3(0, 0, 0)
  bobUpAndDown = bobUpAndDown or false
  faceCamera = faceCamera or false
  rotate = rotate or false
  drawOnEnts = drawOnEnts or false
  
  -- Parse scale (can be number or table)
  local scaleX, scaleY, scaleZ
  if type(scale) == "table" then
    scaleX = scale.x or scale[1] or 1.0
    scaleY = scale.y or scale[2] or 1.0
    scaleZ = scale.z or scale[3] or 1.0
  else
    scaleX = scale
    scaleY = scale
    scaleZ = scale
  end
  
  -- Draw the marker
  DrawMarker(
    markerType,
    pos.x, pos.y, pos.z,
    direction.x, direction.y, direction.z,
    rotation.x, rotation.y, rotation.z,
    scaleX, scaleY, scaleZ,
    color.r, color.g, color.b, math.floor((color.a or 1) * 255),
    bobUpAndDown, faceCamera, 2, rotate, nil, nil, drawOnEnts
  )
end
---Convert table to vector3
---@param coords table Table with x, y, z properties
---@return vector3
function Utils.Client.ConvertToVec3(coords)
  return vector3(coords.x, coords.y, coords.z)
end

---Convert table to vector4
---@param coords table Table with x, y, z, w properties
---@return vector4
function Utils.Client.ConvertToVec4(coords)
  return vector4(coords.x, coords.y, coords.z, coords.w)
end
---Find available spawn coordinates without nearby vehicles

function Utils.Client.FindAvailableSpawnCoords(coords)
  -- Handle array of coordinates
  if type(coords) == "table" and type(coords) ~= "vector4" and type(coords) ~= "vector3" then
    -- Try each coordinate in the array
    for _, coord in pairs(coords) do
      if not lib.getClosestVehicle(coord.xyz, 2.5) then
        return coord
      end
    end
    -- If all occupied, recursively try the first one with adjustments
    return Utils.Client.FindAvailableSpawnCoords(coords[1])
  end
  
  -- Handle single coordinate (vector4 or vector3)
  local currentCoords = coords.xyzw
  
  -- Try up to 10 adjustments
  for attempt = 1, 10 do
    -- Check if position is clear
    if not lib.getClosestVehicle(currentCoords.xyz, 2.5) then
      return currentCoords
    end
    
    -- Adjust position based on heading direction
    local x, y = currentCoords.x, currentCoords.y
    local heading = currentCoords.w
    
    -- North (0-45° or 315-360°)
    if (heading >= 0 and heading <= 45) or (heading >= 315 and heading <= 360) then
      y = y + 5
    end
    
    -- West (46-135°)
    if heading >= 46 and heading <= 135 then
      x = x - 5
    end
    
    -- South (136-225°)
    if heading >= 136 and heading <= 225 then
      y = y - 5
    end
    
    -- East (226-314°)
    if heading >= 226 and heading <= 314 then
      x = x + 5
    end
    
    currentCoords = vector4(x, y, currentCoords.z, currentCoords.w)
  end
  
  -- Return best attempt after 10 tries
  return currentCoords
end
---Get vehicle type category from vehicle class
---@param vehicleClass number The vehicle class ID
---@return string "sea", "air", or "car"

function GetVehicleTypeFromClass(vehicleClass)
  if vehicleClass == 14 then
    return "sea"
  elseif vehicleClass == 15 or vehicleClass == 16 then
    return "air"
  else
    return "car"
  end
end
---Play the tablet holding animation

function PlayTabletAnim()
  local animDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
  local animName = "base"
  local tabletModel = -1585232418
  local boneIndex = 60309
  local attachOffset = vector3(0.03, 0.002, 0.0)
  local attachRotation = vector3(10.0, 160.0, 0.0)
  
  Citizen.CreateThread(function()
    -- Load animation and model
    lib.requestAnimDict(animDict)
    lib.requestModel(tabletModel)
    
    local ped = cache.ped
    
    -- Create tablet object
    Globals.HoldingTablet = CreateObject(tabletModel, 0.0, 0.0, 0.0, true, true, false)
    
    -- Get hand bone index
    local handBone = GetPedBoneIndex(ped, boneIndex)
    
    -- Unequip weapon
    SetCurrentPedWeapon(ped, -1569615261, true)
    
    -- Attach tablet to hand
    AttachEntityToEntity(
      Globals.HoldingTablet, ped, handBone,
      attachOffset.x, attachOffset.y, attachOffset.z,
      attachRotation.x, attachRotation.y, attachRotation.z,
      true, false, false, false, 2, true
    )
    
    -- Clean up model
    SetModelAsNoLongerNeeded(tabletModel)
    
    -- Play animation if not already playing (loop continuously)
    if not IsEntityPlayingAnim(ped, animDict, animName, 3) then
      TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 50, 0, false, false, false)
    end
    
    -- Keep animation playing while tablet is held
    while Globals.HoldingTablet do
      ped = cache.ped
      if not IsEntityPlayingAnim(ped, animDict, animName, 3) then
        TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 50, 0, false, false, false)
      end
      Wait(1000)
    end
    
    -- Clean up animation dict after loop ends
    if HasAnimDictLoaded(animDict) then
      RemoveAnimDict(animDict)
    end
  end)
end
---Stop the tablet holding animation

function StopTabletAnim()
  if not Globals.HoldingTablet then
    return
  end
  
  -- Store tablet reference before clearing
  local tablet = Globals.HoldingTablet
  
  -- Clear reference (this will stop the animation loop in PlayTabletAnim)
  Globals.HoldingTablet = nil
  
  -- Clear ped tasks (stops animation)
  ClearPedTasks(cache.ped)
  
  -- Detach and delete tablet
  if tablet and DoesEntityExist(tablet) then
    DetachEntity(tablet, true, false)
    DeleteEntity(tablet)
  end
end
---Get player balances from server
---@return table Player balance information or empty table

function GetPlayerBalances()
  local balances = lib.callback.await("jg-dealerships:server:get-player-balances", false)
  return balances or {}
end
-- NUI Callback: Get player balances
RegisterNUICallback("get-player-balances", function(data, cb)
  cb(GetPlayerBalances())
end)

-- NUI Callback: Close UI
RegisterNUICallback("close", function(data, cb)
  SetNuiFocus(false, false)
  StopTabletAnim()
  cb(true)
end)

-- NUI Callback: Get nearby players
RegisterNUICallback("get-nearby-players", function(data, cb)
  local players = lib.callback.await("jg-dealerships:server:get-nearby-players", false, data.dealershipId)
  cb(players or {})
end)

-- Callback for opening direct sale tablet
lib.callback.register("jg-dealerships:client:open-direct-sale-tablet", function()
  -- Check if player is in a dealership zone
  local currentZone = DealershipZones.Client.GetCurrentZone()
  
  if not currentZone then
    Framework.Client.Notify("You must be at a dealership to use this command", "error")
    return false
  end
  
  -- Check if player is an employee at this dealership
  local isEmployee = Locations.Client.IsEmployeeAtLocation(currentZone)
  
  if not isEmployee then
    Framework.Client.Notify("You are not an employee of this dealership", "error")
    return false
  end
  
  -- Open the direct sales tablet
  return DirectSales.Client.ShowDirectSaleTablet(currentZone)
end)