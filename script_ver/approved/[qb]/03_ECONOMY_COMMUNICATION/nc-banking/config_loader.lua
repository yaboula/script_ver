-- Configuration loader for nc-Banking
-- This file loads the config.json file and makes it available globally

local loadConfigFromJson = function()
    local configFile = LoadResourceFile(GetCurrentResourceName(), 'config.json')
    if configFile then
        local configData = json.decode(configFile)
        if configData then
            -- Convert bank locations from JSON objects to vector4
            for i, location in ipairs(configData.BankLocations) do
                configData.BankLocations[i] = vector4(location.x, location.y, location.z, location.w)
            end
            
            -- Remove description fields to keep the config clean
            for k, v in pairs(configData) do
                if k:match("_description$") or k:match("_options$") or k == "_notes" then
                    configData[k] = nil
                end
            end
            
            -- Clean up SharedAccounts fields too
            if configData.SharedAccounts then
                for k, v in pairs(configData.SharedAccounts) do
                    if k:match("_description$") then
                        configData.SharedAccounts[k] = nil
                    end
                end
            end
            
            return configData
        else
            print("^1[nc-BANKING ERROR]^7 Failed to decode config.json")
        end
    else
        print("^1[nc-BANKING ERROR]^7 Could not load config.json")
    end
    return {}
end

-- Define Config as a global variable
Config = loadConfigFromJson()

-- Still provide an export for compatibility
function GetConfig()
    return Config
end

exports('GetConfig', GetConfig)