local Target = {}

---@param key string
---@param parameters OxTargetBoxZone
---@return number
function Target.addBoxZone(key, parameters)
    if shared.isResourceStart('ox_target') then
        parameters.name = key
        parameters.drawSprite = false
        return exports.ox_target:addBoxZone(parameters)
    elseif shared.isResourceStart('qb-target') then
        for _, option in pairs(parameters.options) do
            option.action = option.onSelect
        end
        local heading = 0.0
        if parameters.rotation then
            heading = type(parameters.rotation) == "number" and parameters.rotation or parameters.rotation.z or 0.0
        end

        exports['qb-target']:AddBoxZone(key, parameters.coords, parameters.size.y, parameters.size.x,
            {
                name = key,
                heading = heading,
                debugPoly = parameters.debug,
                minZ = parameters.coords.z - parameters.size.z,
                maxZ = parameters.coords.z + parameters.size.z,
            }, { options = parameters.options, distance = 2.5, })
        return key
    else
        -- ? Use your target script export
        return key
    end
end

---@param id string|number
---@return boolean
function Target.removeZone(id)
    if shared.isResourceStart('ox_target') then
        exports.ox_target:removeZone(id)
    elseif shared.isResourceStart('qb-target') then
        exports['qb-target']:RemoveZone(id)
    else
        -- ? Use your target script export
    end
    return true
end

---@param entities number|number[]
---@param options OxTargetEntity|OxTargetEntity[]
---@return boolean
function Target.addLocalEntity(entities, options)
    if shared.isResourceStart('ox_target') then
        exports.ox_target:addLocalEntity(entities, options)
    elseif shared.isResourceStart('qb-target') then
        for _, option in pairs(options) do
            option.job = option.groups
            option.action = option.onSelect
        end
        exports['qb-target']:AddTargetEntity(entities, {
            options = options,
        })
    else
        -- ? Use your target script export
    end
    return true
end

---@param entities number|number[]
---@return boolean
function Target.removeLocalEntity(entities)
    if shared.isResourceStart('ox_target') then
        exports.ox_target:removeLocalEntity(entities)
    elseif shared.isResourceStart('qb-target') then
        exports['qb-target']:RemoveTargetEntity(entities)
    else
        -- ? Use your target script export
    end
    return true
end

---@param entities number|number[]
---@param options OxTargetEntity[]
---@param network boolean
---@return boolean
function Target.addBone(entities, options, network)
    if shared.isResourceStart('ox_target') then
        if not network then
            exports.ox_target:addLocalEntity(entities, options)
        else
            exports.ox_target:addEntity(entities, options)
        end
    elseif shared.isResourceStart('qb-target') then
        for _, option in pairs(options) do
            option.job = option.groups
            option.action = option.onSelect
        end
        exports['qb-target']:AddTargetEntity(entities, {
            options = options,
        })
    else
        -- ? Use your target script export
    end
    return true
end

---@param entities number|number[]
---@param network boolean
---@return boolean
function Target.removeBone(entities, network)
    if shared.isResourceStart('ox_target') then
        if not network then
            exports.ox_target:removeLocalEntity(entities)
        else
            exports.ox_target:removeEntity(entities)
        end
    elseif shared.isResourceStart('qb-target') then
        exports['qb-target']:RemoveTargetEntity(entities)
    else
        -- ? Use your target script export
    end
    return true
end

return Target
