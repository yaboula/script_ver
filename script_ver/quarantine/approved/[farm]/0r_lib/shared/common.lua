-- ============================================================
-- Resmon Core - Library initialization and utility functions
-- Provides the core Resmon object, deep copy utility, and
-- framework exports for other resources to interact with.
-- ============================================================

-- ── Core object initialization ──────────────────────────────

Resmon = {}
Resmon.Lib = {}

-- ── Deep copy utility ───────────────────────────────────────

-- Recursively copies a table (including metatables).
-- Non-table values are returned as-is.
function Resmon.Lib._deepCopy(value)
    local copy

    if type(value) == "table" then
        copy = {}

        -- Recursively copy all keys and values
        for key, val in next, value, nil do
            copy[Resmon.Lib._deepCopy(key)] = Resmon.Lib._deepCopy(val)
        end

        -- Copy the metatable as well
        setmetatable(copy, Resmon.Lib._deepCopy(getmetatable(value)))
    else
        -- Primitive types (strings, numbers, booleans, etc.)
        copy = value
    end

    return copy
end

-- ── Table utility ──────────────────────────────────────────

-- Checks if a table contains a specific value.
-- Returns true if found, false otherwise.
function Resmon.Lib.Contains(tbl, searchValue)
    if not tbl then
        return true
    end

    for _, value in pairs(tbl) do
        if value == searchValue then
            return true
        end
    end

    return false
end

-- ── Core object export ──────────────────────────────────────

-- Returns the Resmon core object.
-- Used by other resources to access the framework.
function Get0Resmon()
    return Resmon
end

exports("GetCoreObject", Get0Resmon)

-- ── Framework export ────────────────────────────────────────

-- Returns the name of the active framework (ESX or QBCore).
-- This is determined during server startup and stored in Config.
exports("Framework", function()
    return Config.Framework
end)