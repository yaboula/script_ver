local function safeToBool(v)
    if v == nil then return false end
    if type(v) == 'boolean' then return v end
    if type(v) == 'number' then return v ~= 0 end
    if type(v) == 'string' then
        v = v:lower()
        return (v == 'true' or v == '1' or v == 'yes')
    end
    return false
end

local function countTable(t)
local c = 0
    for _ in pairs(t or {}) do c = c + 1 end
    return c
end

local function rebuildSharedWeapons()
    if type(Config.Itemlist) ~= 'table' then return end
    SharedWeapons = {}
    for _, item in pairs(Config.Itemlist) do
        if item.type == 'weapon' then
            SharedWeapons[GetHashKey(item.name)] = {
                name = item.name,
                ammotype = item.ammotype or nil
            }
        end
    end
end

local function fetchQBItemsFromCore()
    if not Core then return nil end
local ok, items = pcall(function()
        return Core.Shared and Core.Shared.Items or nil
    end)
    if ok and items and type(items) == 'table' then
        return items
    end
    return nil
end

local function fetchQBItemsFromFile()
local fileContent = LoadResourceFile('qb-core', 'shared/items.lua')
    if not fileContent then return nil end
    -- sandbox env to capture QBCore.Shared.Items
local env = {
        QBCore = { Shared = {} },
        vector3 = vector3,
        vector4 = vector4,
        pairs = pairs,
        ipairs = ipairs,
        type = type,
        tonumber = tonumber,
        tostring = tostring,
        math = math,
        table = table,
        string = string,
        GetHashKey = GetHashKey,
    }
local fn, err = load(fileContent, '@qb_items', 't', env)
    if not fn then
        print(('codem-inventory: failed to compile qb-core/shared/items.lua: %s'):format(err))
        return nil
    end
local ok2, err2 = pcall(fn)
    if not ok2 then
        print(('codem-inventory: error executing qb-core/shared/items.lua: %s'):format(err2))
        return nil
    end
local items = env.QBCore and env.QBCore.Shared and env.QBCore.Shared.Items
    if type(items) ~= 'table' then return nil end
    return items
end

local function normalizeQBItem(key, src)
local name = src.name or key
local label = src.label or name
local weight = src.weight or 0
local itype = src.type or 'item'
local image = src.image or (name .. '.png')
local unique = safeToBool(src.unique)
local useable = safeToBool(src.useable)
local shouldClose = safeToBool(src.shouldClose)
local description = src.description or ''
local ammotype = src.ammotype -- may be nil; we merge from existing list if present
local normalized = {
        name = name,
        label = label,
        weight = weight,
        type = itype,
        image = image,
        unique = unique,
        useable = useable,
        shouldClose = shouldClose,
        description = description,
        ammotype = ammotype,
    }
    return normalized
end

local function mergeQBItemsIntoConfig(qbItems)
local incoming = {}
    for key, value in pairs(qbItems) do
        incoming[key] = normalizeQBItem(key, value)
    end

local existing = Config.Itemlist or {}
local merged = {}
local newlyAdded = {}

    -- First, take all QB items
    for k, v in pairs(incoming) do
        merged[k] = v
        if existing[k] == nil then
            newlyAdded[k] = v
        end
    end

    -- Preserve existing custom items, prefer existing on duplicate keys
    for k, v in pairs(existing) do
        if merged[k] == nil then
            merged[k] = v
        else
            -- prefer existing values where present
local m = merged[k]
            for field, val in pairs(v) do
                if val ~= nil then m[field] = val end
            end
            -- ensure ammotype is kept if existing defines it
            if not m.ammotype and v.ammotype then
                m.ammotype = v.ammotype
            end
        end
    end

    Config.Itemlist = merged
    return newlyAdded
end

local function registerNewUsables(newItems)
    if not newItems or type(newItems) ~= 'table' then return end
    -- Only QB frameworks reach here
    for name, item in pairs(newItems) do
        if item.type == 'weapon' then
            Core.Functions.CreateUseableItem(name, function(source, itm)
                if (itm and itm.info) then
                    if Config.DurabilitySystem then
                        if (itm.info.quality and itm.info.quality <= 0) then
                            TriggerClientEvent('codem-inventory:client:notification', source,
                                Locales[Config.Language].notification['CANTUSEITEM'])
                            return
                        end
                    end

                    if not itm.ammotype then
local cfg = Config.Itemlist and Config.Itemlist[itm.name]
                        itm.ammotype = (cfg and cfg.ammotype) or nil
                    end
                    TriggerClientEvent('codem-inventory:client:UseWeapon', source, itm)
                    if type(CheckDupliceteItems) == 'function' then
                        CheckDupliceteItems(source)
                    end
                else
                    TriggerClientEvent('codem-inventory:client:notification', source,
                        Locales[Config.Language].notification['ITEMINFONOTFOUND'])
                end
            end)
        elseif item.type == 'bag' then
            Core.Functions.CreateUseableItem(name, function(source, itm)
                if (itm and itm.info and itm.info.series) then
                    TriggerClientEvent('codem-inventory:useBackpackItem', source, itm)
                else
                    TriggerClientEvent('codem-inventory:client:notification', source,
                        Locales[Config.Language].notification['ITEMINFONOTFOUND'])
                end
            end)
        end
    end
end

local function importQBSharedItems()
    -- only for QB frameworks and when enabled
    if not (Config.Framework == 'qb' or Config.Framework == 'oldqb') then return end
    if not Config.ImportQBSharedItems then return end

    -- wait for core
    while Core == nil do Citizen.Wait(0) end

local qbItems = fetchQBItemsFromCore()
    if not qbItems then
        qbItems = fetchQBItemsFromFile()
    end

    if not qbItems then
        print('codem-inventory: QB shared items not found; skipping import')
        return
    end

local before = countTable(Config.Itemlist)
local newlyAdded = mergeQBItemsIntoConfig(qbItems)
local after = countTable(Config.Itemlist)
    print(('codem-inventory: imported QB shared items (before: %d, after: %d)'):format(before, after))

    rebuildSharedWeapons()
    registerNewUsables(newlyAdded)

    -- Also push any custom/missing items into QBCore.Shared.Items so other
    -- resources using QBCore APIs can spawn them successfully.
    if Core and Core.Shared then
local shared = Core.Shared.Items or {}
local addedToQB = 0
        for name, item in pairs(Config.Itemlist or {}) do
            if shared[name] == nil then
                shared[name] = {
                    name = item.name or name,
                    label = item.label or (item.name or name),
                    weight = item.weight or 0,
                    type = item.type or 'item',
                    image = item.image or ((item.name or name) .. '.png'),
                    unique = safeToBool(item.unique),
                    useable = safeToBool(item.useable),
                    shouldClose = safeToBool(item.shouldClose),
                    description = item.description or '',
                    ammotype = item.ammotype,
                }
                addedToQB = addedToQB + 1
            end
        end
        if addedToQB > 0 then
            print(('codem-inventory: pushed %d custom items into QBCore.Shared.Items'):format(addedToQB))
        end
    end
end

Citizen.CreateThread(function()
    -- Give other scripts a moment to initialize
    Citizen.Wait(1000)
    importQBSharedItems()
end)
