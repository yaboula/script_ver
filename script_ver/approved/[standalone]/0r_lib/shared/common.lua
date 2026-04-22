Resmon = {}
Resmon.Lib = {}

function Resmon.Lib._deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[Resmon.Lib._deepCopy(orig_key)] = Resmon.Lib._deepCopy(orig_value)
        end
        setmetatable(copy, Resmon.Lib._deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Get0Resmon()
    return Resmon
end

exports('GetCoreObject', Get0Resmon)

exports('Framework', function()
    return Config.Framework
end)