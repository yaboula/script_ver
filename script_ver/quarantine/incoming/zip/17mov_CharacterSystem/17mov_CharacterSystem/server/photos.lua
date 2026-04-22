RegisterNetEvent("17mov_CharacterSystem:UploadPhotos", function(photosData)
    for _, photo in pairs(photosData) do
        local resourcePath = GetResourcePath(Functions.ResourceName)
        local privatePath = string.format("%s/web/photos/%s-%s-%s.webp", resourcePath, photo.model, photo.component.name, photo.drawable)
        local publicPath = string.format("%s/web/public/photos/%s-%s-%s.webp", resourcePath, photo.model, photo.component.name, photo.drawable)

        local privateFile = io.open(privatePath, "wb")
        local publicFile = io.open(publicPath, "wb")

        if privateFile then
            print(string.format("^5[INFORMATION]:^0 Saved photo. Model: %s, component: %s, drawable: %s", photo.model, photo.component.name, photo.drawable))
            local base64Image = photo.image:gsub("^data:image/.+;base64,", "")
            local decodedImage = Functions.DecodeBase64(base64Image)
            privateFile:write(decodedImage)
            privateFile:close()
        else
            Functions.Error(string.format("Failed to save photo. Model: %s, %s, drawable: %s", photo.model, photo.component.name, photo.drawable))
        end

        if publicFile then
            local base64Image = photo.image:gsub("^data:image/.+;base64,", "")
            local decodedImage = Functions.DecodeBase64(base64Image)
            publicFile:write(decodedImage)
            publicFile:close()
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