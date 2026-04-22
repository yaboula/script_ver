local MAX_PHOTOS_PER_BATCH = 250
local MAX_BASE64_LENGTH = 8 * 1024 * 1024

local function HasPhotoUploadPermission(src)
    if type(src) ~= "number" or src <= 0 then
        return false
    end

    if Config.Framework == "QBCore" and Core and Core.Functions and Core.Functions.HasPermission then
        return Core.Functions.HasPermission(src, "admin") or Core.Functions.HasPermission(src, "god")
    end

    if Config.Framework == "ESX" and Core and Core.GetPlayerFromId then
        local xPlayer = Core.GetPlayerFromId(src)
        if xPlayer and xPlayer.getGroup then
            local group = xPlayer.getGroup()
            return group == "admin" or group == "superadmin"
        end
    end

    return false
end

local function SanitizeNamePart(value, maxLen)
    if type(value) == "number" then
        value = tostring(math.floor(value))
    end

    if type(value) ~= "string" then
        return nil
    end

    if #value == 0 or #value > maxLen then
        return nil
    end

    if value:find("[^%w_-]") then
        return nil
    end

    return value
end

local function SanitizeDrawable(value)
    if type(value) ~= "number" or value ~= math.floor(value) then
        return nil
    end

    if value < 0 or value > 1024 then
        return nil
    end

    return tostring(value)
end

local function WriteImage(path, data)
    local file = io.open(path, "wb")
    if not file then
        return false
    end

    file:write(data)
    file:close()
    return true
end

RegisterNetEvent("17mov_CharacterSystem:UploadPhotos", function(photosData)
    local src = source
    if not HasPhotoUploadPermission(src) then
        Functions.Print(string.format("Blocked unauthorized photo upload attempt from source %s", src))
        return
    end

    if type(photosData) ~= "table" then
        return
    end

    local resourcePath = GetResourcePath(Functions.ResourceName)
    if not resourcePath or resourcePath == "" then
        return
    end

    local processed = 0
    for _, photo in pairs(photosData) do
        processed = processed + 1
        if processed > MAX_PHOTOS_PER_BATCH then
            break
        end

        if type(photo) == "table" and type(photo.component) == "table" and type(photo.image) == "string" then
            local model = SanitizeNamePart(photo.model, 64)
            local componentName = SanitizeNamePart(photo.component.name, 64)
            local drawable = SanitizeDrawable(photo.drawable)
            local base64Image = photo.image:gsub("^data:image/.+;base64,", "")

            if model and componentName and drawable and #base64Image > 0 and #base64Image <= MAX_BASE64_LENGTH then
                local success, decodedImage = pcall(Functions.DecodeBase64, base64Image)
                if success and type(decodedImage) == "string" and #decodedImage > 0 then
                    local privatePath = string.format("%s/web/photos/%s-%s-%s.webp", resourcePath, model, componentName, drawable)
                    local publicPath = string.format("%s/web/public/photos/%s-%s-%s.webp", resourcePath, model, componentName, drawable)

                    local privateSaved = WriteImage(privatePath, decodedImage)
                    local publicSaved = WriteImage(publicPath, decodedImage)

                    if privateSaved then
                        print(string.format("^5[INFORMATION]:^0 Saved photo. Model: %s, component: %s, drawable: %s", model, componentName, drawable))
                    else
                        Functions.Error(string.format("Failed to save private photo. Model: %s, component: %s, drawable: %s", model, componentName, drawable))
                    end

                    if not publicSaved then
                        Functions.Error(string.format("Failed to save public photo. Model: %s, component: %s, drawable: %s", model, componentName, drawable))
                    end
                end
            end
        end
    end
end)

if Config.Framework == "QBCore" then
    Core.Commands.Add("photos", "Enter Clothes photo creator", {}, false, function(source)
        TriggerClientEvent("17mov_CharacterSystem:OpenClothesPhotos", source)
    end, "admin")
elseif Config.Framework == "ESX" then
    Core.RegisterCommand("photos", "admin", function(context)
        context.triggerEvent("17mov_CharacterSystem:OpenClothesPhotos")
    end, false, { help = "Enter Clothes Photo creator" })
end