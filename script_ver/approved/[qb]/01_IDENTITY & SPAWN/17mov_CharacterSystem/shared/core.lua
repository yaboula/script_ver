Functions = {}
Functions.ResourceName = GetCurrentResourceName()

function Functions.Print(...)
    local args = table.pack(...)
    local message = ""
    for i = 1, args.n do
        if i > 1 then
            message = message .. " "
        end
        message = message .. tostring(args[i])
    end
    print("^5[" .. Functions.ResourceName .. "]:^7 " .. message .. "^0")
end

function Functions.Debug(...)
    if not Config.Debug then
        return
    end
    local args = table.pack(...)
    local message = ""
    for i = 1, args.n do
        if i > 1 then
            message = message .. " "
        end
        message = message .. tostring(args[i])
    end
    print("^5[" .. Functions.ResourceName .. "] (DEBUG MODE):^5 " .. message .. "^0")
end

function Functions.Error(...)
    local args = table.pack(...)
    local message = ""
    for i = 1, args.n do
        if i > 1 then
            message = message .. " "
        end
        message = message .. tostring(args[i])
    end
    print("^5[ERROR]:^1 " .. message .. "^0")
end

function Functions.Lerp(start, finish, amount)
    return start + (finish - start) * amount
end

function Functions.RandomFloat(min, max)
    return min + math.random() * (max - min)
end

function Functions.DeepCopy(original)
    if type(original) ~= "table" then
        return original
    end

    local newTable = {}
    for key, value in pairs(original) do
        newTable[Functions.DeepCopy(key)] = Functions.DeepCopy(value)
    end

    local metatable = getmetatable(original)
    if metatable then
        setmetatable(newTable, Functions.DeepCopy(metatable))
    end

    return newTable
end

function Functions.DecodeBase64(data)
    local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    data = string.gsub(data, "[^" .. base64Chars .. "=]", "")

    local binaryStream = string.gsub(data, ".", function(char)
        if char == "=" then
            return ""
        end
        local binaryString = ""
        local value = base64Chars:find(char) - 1
        for i = 6, 1, -1 do
            local bitValue = (value % (2 ^ i)) - (value % (2 ^ (i - 1)))
            if bitValue > 0 then
                binaryString = binaryString .. "1"
            else
                binaryString = binaryString .. "0"
            end
        end
        return binaryString
    end)

    local decodedString = string.gsub(binaryStream, "%d%d%d?%d?%d?%d?%d?%d?", function(byte)
        if #byte ~= 8 then
            return ""
        end
        local decimalValue = 0
        for i = 1, 8 do
            if byte:sub(i, i) == "1" then
                decimalValue = decimalValue + (2 ^ (8 - i))
            end
        end
        return string.char(decimalValue)
    end)

    return decodedString
end

function Functions.EncodeBase64(data)
    local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    local binaryStream = string.gsub(data, ".", function(char)
        local binaryString = ""
        local byteValue = char:byte()
        for i = 8, 1, -1 do
            local bitValue = (byteValue % (2 ^ i)) - (byteValue % (2 ^ (i - 1)))
            if bitValue > 0 then
                binaryString = binaryString .. "1"
            else
                binaryString = binaryString .. "0"
            end
        end
        return binaryString
    end)

    binaryStream = binaryStream .. "0000"

    local encodedStream = string.gsub(binaryStream, "%d%d%d?%d?%d?%d?", function(bits)
        if #bits < 6 then
            return ""
        end
        local decimalValue = 0
        for i = 1, 6 do
            if bits:sub(i, i) == "1" then
                decimalValue = decimalValue + (2 ^ (6 - i))
            end
        end
        return base64Chars:sub(decimalValue + 1, decimalValue + 1)
    end)

    local paddingTable = { "", "==", "=" }
    local padding = paddingTable[(#data % 3) + 1]

    return encodedStream .. padding
end