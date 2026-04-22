EntityFreeAim = false
ToggleEntityFreeView = function()
    EntityFreeAim = not EntityFreeAim
     NuiMessage('toggleLaser', EntityFreeAim)
    if EntityFreeAim then
        RunEntityViewThread()
    end
end

local RotationToDirection = function(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end
local DrawEntityBoundingBox = function(entity, color)
    local model = GetEntityModel(entity)
    local min, max = GetModelDimensions(model)
    local rightVector, forwardVector, upVector, position = GetEntityMatrix(entity)

    -- Calculate size
    local dim = {
        x = 0.5 * (max.x - min.x),
        y = 0.5 * (max.y - min.y),
        z = 0.5 * (max.z - min.z)
    }

    local FUR = {
        x = position.x + dim.y * rightVector.x + dim.x * forwardVector.x + dim.z * upVector.x,
        y = position.y + dim.y * rightVector.y + dim.x * forwardVector.y + dim.z * upVector.y,
        z = 0
    }

    local _, FUR_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    FUR.z = FUR_z
    FUR.z = FUR.z + 2 * dim.z

    local BLL = {
        x = position.x - dim.y * rightVector.x - dim.x * forwardVector.x - dim.z * upVector.x,
        y = position.y - dim.y * rightVector.y - dim.x * forwardVector.y - dim.z * upVector.y,
        z = 0
    }
    local _, BLL_z = GetGroundZFor_3dCoord(FUR.x, FUR.y, 1000.0, 0)
    BLL.z = BLL_z

    -- DEBUG
    local edge1 = BLL
    local edge5 = FUR

    local edge2 = {
        x = edge1.x + 2 * dim.y * rightVector.x,
        y = edge1.y + 2 * dim.y * rightVector.y,
        z = edge1.z + 2 * dim.y * rightVector.z
    }

    local edge3 = {
        x = edge2.x + 2 * dim.z * upVector.x,
        y = edge2.y + 2 * dim.z * upVector.y,
        z = edge2.z + 2 * dim.z * upVector.z
    }

    local edge4 = {
        x = edge1.x + 2 * dim.z * upVector.x,
        y = edge1.y + 2 * dim.z * upVector.y,
        z = edge1.z + 2 * dim.z * upVector.z
    }

    local edge6 = {
        x = edge5.x - 2 * dim.y * rightVector.x,
        y = edge5.y - 2 * dim.y * rightVector.y,
        z = edge5.z - 2 * dim.y * rightVector.z
    }

    local edge7 = {
        x = edge6.x - 2 * dim.z * upVector.x,
        y = edge6.y - 2 * dim.z * upVector.y,
        z = edge6.z - 2 * dim.z * upVector.z
    }

    local edge8 = {
        x = edge5.x - 2 * dim.z * upVector.x,
        y = edge5.y - 2 * dim.z * upVector.y,
        z = edge5.z - 2 * dim.z * upVector.z
    }
    color = (color == nil and { r = 255, g = 255, b = 255, a = 255 } or color)
    DrawLine(edge1.x, edge1.y, edge1.z, edge2.x, edge2.y, edge2.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge3.x, edge3.y, edge3.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge4.x, edge4.y, edge4.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
    DrawLine(edge5.x, edge5.y, edge5.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge6.x, edge6.y, edge6.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge7.x, edge7.y, edge7.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge1.x, edge1.y, edge1.z, edge7.x, edge7.y, edge7.z, color.r, color.g, color.b, color.a)
    DrawLine(edge2.x, edge2.y, edge2.z, edge8.x, edge8.y, edge8.z, color.r, color.g, color.b, color.a)
    DrawLine(edge3.x, edge3.y, edge3.z, edge5.x, edge5.y, edge5.z, color.r, color.g, color.b, color.a)
    DrawLine(edge4.x, edge4.y, edge4.z, edge6.x, edge6.y, edge6.z, color.r, color.g, color.b, color.a)
end

local RelationshipTypes = { ['0'] = 'Companion', ['1'] = 'Respect', ['2'] = 'Like', ['3'] = 'Neutral', ['4'] = 'Dislike', ['5'] = 'Hate', ['255'] = 'Pedestrians' }
local GetPedRelationshipType = function(value)
    value = tostring(value)
    return RelationshipTypes[value] or 'Unknown'
end

valueof = function (this)
        if type(this) == "number" then
            return this
        else
            return getmetatable(this)._primitive
        end
    end
toFixed = function(this, digits)
        local value = valueof(this)
        digits = digits or 0
        return string.format("%." .. tonumber(digits) .. "f", value)
    end
local RayCastGamePlayCamera = function(distance)
    -- Checks to see if the Gameplay Cam is Rendering or another is rendering (no clip functionality)
    local currentRenderingCam = false
    if not IsGameplayCamRendering() then
        currentRenderingCam = GetRenderingCam()
    end

    local cameraRotation = not currentRenderingCam and GetGameplayCamRot() or GetCamRot(currentRenderingCam, 2)
    local cameraCoord = not currentRenderingCam and GetGameplayCamCoord() or GetCamCoord(currentRenderingCam)
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end


local DrawTitle = function(text)
    SetTextScale(0.50, 0.50)
    SetTextFont(4)
    SetTextDropshadow(1.0, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 215)
    SetTextJustification(0)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.5, 0.02)
end
RunEntityViewThread = function()
    Citizen.CreateThread(function()
        while EntityFreeAim do
            Citizen.Wait(0)
            local playerPed    = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

      

            if EntityFreeAim then
        
                local color = { r = 255, g = 255, b = 255, a = 200 }
                local position = GetEntityCoords(playerPed)
                local hit, coords, entity = RayCastGamePlayCamera(1000.0)
               
                if hit and (IsEntityAVehicle(entity) or IsEntityAPed(entity) or IsEntityAnObject(entity)) then
                    color = { r = 0, g = 255, b = 0, a = 200 }
                    FreeAimEntity = entity
                    DrawEntityBoundingBox(entity, color)
                    if IsEntityAPed(entity) then
                        local rotation = GetEntityRotation(entity)
                        local velocity = GetEntityVelocity(entity)
                        local pedRelationshipGroup = GetPedRelationshipGroupHash(entity)
                        NuiMessage('setEntityViewModeType', 'ped')
                        NuiMessage('setEntityViewModeInfo', {
                          type = 'ped',
                          elements = {
                            {
                              name = 'modelhash',
                              value = GetEntityModel(entity)
                            },
                            {
                              name = 'entityid',
                              value = entity
                            },
                            {
                              name = 'objectname',
                              value = Entities[GetEntityModel(entity)] or 'Unkown'
                            },
                            {
                              name = 'netid',
                              value = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or 'Not Registered'
                            },
                            {
                              name = 'entityowner',
                              value =  GetPlayerServerId(NetworkGetEntityOwner(entity))
                            },    
                            {
                              name = 'currenthealth',
                              value =  GetEntityHealth(entity),
                            },                       
                            {
                              name = 'distance',
                              value =  toFixed(#(playerCoords - coords), 1),
                            },                          
                            {
                              name = 'heading',
                              value = toFixed(GetEntityHeading(entity), 2),
                            },                                                    
                            {
                              name = 'coords',
                              value = 'vector3('..toFixed(coords.x, 1)..', '..toFixed(coords.y, 1)..', '..toFixed(coords.z, 1)..')',
                            },                              
                            {
                              name = 'rotation',
                              value = 'vector3('..toFixed(rotation.x, 1)..', '..toFixed(rotation.y, 1)..', '..toFixed(rotation.z, 1)..')',
                            }, 
                            {
                              name = 'velocity',
                              value = 'vector3('..toFixed(velocity.x, 1)..', '..toFixed(velocity.y, 1)..', '..toFixed(velocity.z, 1)..')',
                            }, 
                            {
                              name = 'currenthealth',
                              value = GetEntityHealth(entity),
                            },  
                            {
                              name = 'maxhealth',
                              value = GetEntityMaxHealth(entity),
                            },                            
                            {
                              name = 'armour',
                              value = GetPedArmour(entity),
                            },     
                            {
                              name = 'relationgroup',
                              value = Entities[pedRelationshipGroup] or "Unkown",
                            },         
                            {
                              name = 'relationtoplayer',
                              value =  GetPedRelationshipType(GetRelationshipBetweenPeds(entity, PlayerPedId())),
                            },         
                                                                                                                         
                          }
                                                
                        })
                    end
                    if IsEntityAVehicle(entity) then
                        local rotation = GetEntityRotation(entity)
                        local velocity = GetEntityVelocity(entity)
                        NuiMessage('setEntityViewModeType', 'vehicle')
                        NuiMessage('setEntityViewModeInfo', {
                          type = 'vehicle',
                          elements = {
                            {
                              name = 'modelhash',
                              value = GetEntityModel(entity)
                            },
                            {
                              name = 'entityid',
                              value = entity
                            },
                            {
                              name = 'objectname',
                              value = Entities[GetEntityModel(entity)] or 'Unkown'
                            },
                            {
                              name = 'netid',
                              value = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or 'Not Registered'
                            },
                            {
                              name = 'entityowner',
                              value =  GetPlayerServerId(NetworkGetEntityOwner(entity))
                            },    
                            {
                              name = 'currenthealth',
                              value =  GetEntityHealth(entity),
                            },                       
                            {
                              name = 'distance',
                              value =  toFixed(#(playerCoords - coords), 1),
                            },                          
                         
                            
                               {
                              name = 'heading',
                              value = toFixed(GetEntityHeading(entity), 2),
                            },  
                            {
                              name = 'coords',
                              value = 'vector3('..toFixed(coords.x, 1)..', '..toFixed(coords.y, 1)..', '..toFixed(coords.z, 1)..')',
                            },                              
                            {
                              name = 'rotation',
                              value = 'vector3('..toFixed(rotation.x, 1)..', '..toFixed(rotation.y, 1)..', '..toFixed(rotation.z, 1)..')',
                            }, 
                            {
                              name = 'velocity',
                              value = 'vector3('..toFixed(velocity.x, 1)..', '..toFixed(velocity.y, 1)..', '..toFixed(velocity.z, 1)..')',
                            }, 
                            
                            {
                              name = 'rpm',
                              value = toFixed(GetVehicleCurrentRpm(entity), 1),
                            },  
                            {
                              name = 'kmh',
                              value = toFixed(GetEntitySpeed(entity) * 3.6, 0),
                            }, 
                            {
                              name = 'gear',
                              value = GetVehicleCurrentGear(entity) ,
                            },   
                            {
                              name = 'acceleration',
                              value = toFixed(GetVehicleAcceleration(entity), 2) ,
                            },   
                            {
                              name = 'bodyhealth',
                              value = GetVehicleBodyHealth(entity),
                            },
                            {
                              name = 'enginehealth',
                              value = GetVehicleEngineHealth(entity),
                            },                            
                          }
                                                
                        })

                    end
                    if IsEntityAnObject(entity) then
                        local rotation = GetEntityRotation(entity)
                        local velocity = GetEntityVelocity(entity)
                        NuiMessage('setEntityViewModeType', 'object')
                        NuiMessage('setEntityViewModeInfo', {
                          type = 'object',
                          elements = {
                            {
                              name = 'modelhash',
                              value = GetEntityModel(entity)
                            },
                            {
                              name = 'entityid',
                              value = entity
                            },
                            {
                              name = 'objectname',
                              value = Entities[GetEntityModel(entity)] or 'Unkown'
                            },
                            {
                              name = 'netid',
                              value = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or 'Not Registered'
                            },
                            {
                              name = 'entityowner',
                              value =  GetPlayerServerId(NetworkGetEntityOwner(entity))
                            },    
                            {
                              name = 'currenthealth',
                              value =  GetEntityHealth(entity),
                            },                       
                            {
                              name = 'distance',
                              value =  toFixed(#(playerCoords - coords), 1),
                            },                          
                            {
                              name = 'heading',
                              value = toFixed(GetEntityHeading(entity), 2),
                            },                                                    
                            {
                              name = 'coords',
                              value = 'vector3('..toFixed(coords.x, 1)..', '..toFixed(coords.y, 1)..', '..toFixed(coords.z, 1)..')',
                            },                              
                            {
                              name = 'rotation',
                              value = 'vector3('..toFixed(rotation.x, 1)..', '..toFixed(rotation.y, 1)..', '..toFixed(rotation.z, 1)..')',
                            }, 
                            {
                              name = 'velocity',
                              value = 'vector3('..toFixed(velocity.x, 1)..', '..toFixed(velocity.y, 1)..', '..toFixed(velocity.z, 1)..')',
                            },    
                          }
                                                
                        })

                    end
                    if IsControlJustPressed(0, 47) then -- copy coords
                          local vector = 'vector3('..coords.x..', '..coords.y..', '..coords.z..')'
                          NuiMessage('copy', vector)
                          TriggerEvent('codem-adminmenu:notfication', 'Coordinates copied to clipboard')

                    end
                    if IsControlJustPressed(0, 104) then -- delete entity
                        SetEntityAsMissionEntity(entity, true, true)
                        DeleteEntity(entity)
                        TriggerEvent('codem-adminmenu:notfication', 'Entity is deleted')

                    end
                else
                    FreeAimEntity = nil
                end

                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                DrawMarker(28, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, color.r, color.g, color.b, color.a, false, true, 2, nil, nil, false, false)
            end
        end
    end)
end