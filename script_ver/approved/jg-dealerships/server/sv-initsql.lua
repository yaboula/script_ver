



--- Split a string by a delimiter
--- @param text string The text to split
--- @param delimiter string The delimiter to split by
--- @return table Array of split strings
local function SplitString(text, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    
    for match in string.gmatch(text, pattern) do
        -- Trim whitespace from each part
        local trimmed = string.gsub(match, "^%s*(.-)%s*$", "%1")
        table.insert(result, trimmed)
    end
    
    return result
end

--- Initialize SQL tables for the dealerships script
function InitSQL()
    if not Config.AutoRunSQL then
        return
    end
    
    local success = pcall(function()
        -- Determine which SQL file to run based on framework
        local sqlFile
        if Config.Framework == "QBCore" or Config.Framework == "Qbox" then
            sqlFile = "run-qb.sql"
        else
            sqlFile = "run-esx.sql"
        end
        
        -- Read SQL file
        local resourcePath = GetResourcePath(GetCurrentResourceName())
        local filePath = resourcePath .. "/install/" .. sqlFile
        local file = assert(io.open(filePath, "rb"))
        local sqlContent = file:read("*all")
        file:close()
        
        -- Split SQL by semicolons and execute as transaction
        local sqlStatements = SplitString(sqlContent, ";")
        MySQL.transaction.await(sqlStatements)
    end)
    
    if not success then
        print("^1[SQL ERROR] There was an error while automatically running the required SQL. Don't worry, you just need to run the SQL file for your framework, found in the 'install' folder manually. If you've already ran the SQL code previously, and this error is annoying you, set Config.AutoRunSQL = false^0")
    end
end
