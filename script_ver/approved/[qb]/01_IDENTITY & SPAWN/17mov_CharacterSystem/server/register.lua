Functions.RegisterServerCallback("17mov_CharacterSystem:CreateCharacter", function(source, characterData)
    if type(characterData) ~= "table" then
        return "invalidData"
    end

    if type(characterData.id) ~= "number" or characterData.id ~= math.floor(characterData.id) or characterData.id <= 0 then
        return "id"
    end

    if type(characterData.firstName) ~= "string" then
        return "firstName"
    end

    if type(characterData.lastName) ~= "string" then
        return "lastName"
    end

    if type(characterData.dateOfBirth) ~= "string" then
        return "dateOfBirth"
    end

    if characterData.height ~= nil and type(characterData.height) ~= "number" then
        return "height"
    end

    local validationError = ""

    if characterData.firstName then
        if #characterData.firstName < Register.Validation.firstName.minLength or #characterData.firstName > Register.Validation.firstName.maxLength then
            validationError = "firstName"
        end

        if Register.Validation.firstName.letters == false and characterData.firstName:match("%a") then
            validationError = "firstName"
        end

        if Register.Validation.firstName.numbers == false and characterData.firstName:match("%d") then
            validationError = "firstName"
        end

        if Register.Validation.firstName.specialCharacters == false and characterData.firstName:match("%W") then
            validationError = "firstName"
        end
    end

    if characterData.lastName then
        if #characterData.lastName < Register.Validation.lastName.minLength or #characterData.lastName > Register.Validation.lastName.maxLength then
            validationError = "lastName"
        end

        if Register.Validation.lastName.letters == false and characterData.lastName:match("%a") then
            validationError = "lastName"
        end

        if Register.Validation.lastName.numbers == false and characterData.lastName:match("%d") then
            validationError = "lastName"
        end

        if Register.Validation.lastName.specialCharacters == false and characterData.lastName:match("%W") then
            validationError = "lastName"
        end
    end

    local isDateValid = true
    if characterData.dateOfBirth then
        local function parseDate(dateStr)
            local day, month, year = dateStr:match("^(%d%d)%.(%d%d)%.(%d%d%d%d)$")
            if not day or not month or not year then
                return nil
            end

            return {
                day = tonumber(day),
                month = tonumber(month),
                year = tonumber(year)
            }
        end

        local function calculateAge(birthDate)
            local currentDate = os.date("*t")
            local age = currentDate.year - birthDate.year
            if currentDate.month < birthDate.month or (currentDate.month == birthDate.month and currentDate.day < birthDate.day) then
                age = age - 1
            end
            return age
        end

        local birthDate = parseDate(characterData.dateOfBirth)
        if not birthDate then
            isDateValid = false
        else
            local age = calculateAge(birthDate)
            local isMinAgeValid = true
            local isMaxAgeValid = true

            if Register.Validation.dateOfBirth.minAge then
                isMinAgeValid = age >= Register.Validation.dateOfBirth.minAge
            end

            if Register.Validation.dateOfBirth.maxAge then
                isMaxAgeValid = age <= Register.Validation.dateOfBirth.maxAge
            end

            isDateValid = isMinAgeValid and isMaxAgeValid
        end
    end

    if not isDateValid then
        validationError = "dateOfBirth"
    end

    if Config.Framework == "QBCore" then
        local isNationalityValid = false
        for i = 1, #Register.Countries do
            if characterData.nationality == Register.Countries[i] then
                isNationalityValid = true
                break
            end
        end
        if not isNationalityValid then
            validationError = "nationality"
        end
    elseif Config.Framework == "ESX" then
        if characterData.height then
            if characterData.height < Register.Validation.height.minValue or characterData.height > Register.Validation.height.maxValue then
                validationError = "height"
            end
        end
    end

    if characterData.isMale ~= true and characterData.isMale ~= false then
        validationError = "isMale"
    end

    if #validationError > 0 then
        return validationError
    end

    if Config.Showcase then
        TriggerClientEvent("17mov_CharacterSystem:CharacterChoosen", source, nil, true, characterData.isMale)
        return true
    end

    if Config.Framework == "QBCore" then
        local charInfo = {
            cid = characterData.id,
            charinfo = {
                cid = characterData.cid,
                firstname = characterData.firstName,
                lastname = characterData.lastName,
                birthdate = characterData.dateOfBirth,
                gender = characterData.isMale and 0 or 1,
                nationality = characterData.nationality
            }
        }

        CreateThread(function()
            local success = Core.Player.Login(source, false, charInfo)
            if success then
                Selector.CharacterChoosen(source, true)
            end
        end)
    elseif Config.Framework == "ESX" then
        local esxData = {
            firstname = characterData.firstName,
            lastname = characterData.lastName,
            dateofbirth = characterData.dateOfBirth,
            sex = characterData.isMale and "m" or "f",
            height = characterData.height
        }

        CreateThread(function()
            local prefix = Config.CustomPrefix or "char"
            local identifier = prefix .. characterData.id
            TriggerEvent("esx:onPlayerJoined", source, identifier, esxData)

            local primaryIdentifier = GetPlayerIdentifierByType(source, Config.PrimaryIdentifier)
            if primaryIdentifier and primaryIdentifier ~= "" then
                local license = primaryIdentifier:match(":(.+)")
                if license then
                    Core.Players[license] = true
                end
            end

            Selector.CharacterChoosen(source, true)
        end)
    end

    TriggerClientEvent("17mov_CharacterSystem:CharacterChoosen", source, nil, true, characterData.isMale)
    return true
end)