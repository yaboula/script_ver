function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function InitDealerInteraction()
    local npcPos = vector3(Config.Dealer.position.x, Config.Dealer.position.y, Config.Dealer.position.z)
    if Config.InteractionHandler == 'drawtext' then
        while true do
            local time = 1500
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            local dist = #(npcPos - coords)
            if dist < 15.0 then
                time = 0
                if dist < 2.0 then
                    DrawText3D(npcPos.x, npcPos.y, npcPos.z+1.0, Config.Dealer.npc.drawTextLabel)
                    if IsControlJustPressed(0, 38) then
                        OpenDealerMenu()
                    end
                end
            end
            Wait(time)
        end
    elseif Config.InteractionHandler == 'qb-target' then 
        local models = {Config.Dealer.npc.model}
        exports['qb-target']:AddTargetModel(models, { 
            options = {   
                {
                    type = "client", 
                    event = 'mWeed:OpenDealerMenu',
                    icon = 'fa-solid fa-cannabis',
                    label = 'Open Dealer Menu',
                    distance = 3.0,
                
                    canInteract = function(entity, distance, data)
                      local coords = GetEntityCoords(entity)
                      local dist = #(npcPos - coords)
                      if dist < 3.0 then
                          return true                        
                      end
                      return false
                    end,
                }

            },
        })          
    elseif Config.InteractionHandler == 'ox_target' then 
        local models = {Config.Dealer.npc.model}
        local options = {
            {
                name = 'mWeedDealer',
                event = 'mWeed:OpenDealerMenu',
                icon = 'fa-solid fa-cannabis',
                label = 'Open Dealer Menu',
                canInteract = function(entity, distance, coords, name, bone)
                    local dist = #(npcPos - coords)
                    if dist < 3.0 then
                        return true                        
                    end
                    return false
                end
            }
        }
        exports.ox_target:addModel(models, options)        
    elseif Config.InteractionHandler == 'custom' then 
      
    end
end

function InitGrinderInteraction()
    for _,v in pairs(Config.GrinderLocations.positions) do
        local npcPos = vector3(v.x, v.y, v.z)
        if Config.InteractionHandler == 'drawtext' then
            CreateThread(function()           
                while true do
                    local time = 1500
                    local player = PlayerPedId()
                    local coords = GetEntityCoords(player)
                    local dist = #(npcPos - coords)
                    if dist < 15.0 then
                        time = 0
                        if dist < 2.0 then
                            DrawText3D(npcPos.x, npcPos.y, npcPos.z+1.0, Config.GrinderLocations.object.drawTextLabel)
                            if IsControlJustPressed(0, 38) then
                                OpenGrinderMenu()
                            end
                        end
                    end
                    Wait(time)
                end
            end)
        elseif Config.InteractionHandler == 'qb-target' then 
            local models = {Config.GrinderLocations.object.model}
            exports['qb-target']:AddTargetModel(models, { 
                options = { 
                    { 
                        type = "client", 
                        event = 'mWeed:OpenGrinderMenu',
                        icon = 'fa-solid fa-cannabis',
                        label = 'Open Grinder Menu',
                        distance = 3.0,
                        canInteract = function(entity, distance, data)
                          local coords = GetEntityCoords(entity)
                          local dist = #(npcPos - coords)
                          if dist < 3.0 then
                              return true                        
                          end
                          return false
                        end,
                    }
                },
            })          
        elseif Config.InteractionHandler == 'ox_target' then 
            local models = {Config.GrinderLocations.object.model}
            local options = {
                {
                    name = 'mWeedDealer',
                    event = 'mWeed:OpenGrinderMenu',
                    icon = 'fa-solid fa-cannabis',
                    label = 'Open Grinder Menu',
                    canInteract = function(entity, distance, coords, name, bone)
                        local dist = #(npcPos - coords)
                        if dist < 3.0 then
                            return true                        
                        end
                        return false
                    end
                }
            }
            exports.ox_target:addModel(models, options)        
        elseif Config.InteractionHandler == 'custom' then 
          
        end
    end
end

CreateThread(function()
    InitDealerInteraction()
end)

CreateThread(function()
    InitGrinderInteraction()
end)

