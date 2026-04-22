Locale = {}

CreateThread(function()
    Wait(1000)
    if not Locale[Config.Lang] then
        while true do
            Functions.Print("You set Config.Lang to %s, but there is no such language in the locale directory!")
            Wait(1000)
        end
    end
end)

function _L(key, ...)
    local translation = "Unkown"
    local languageTable = Locale[Config.Lang]

    if languageTable and languageTable[key] then
        translation = languageTable[key]
    elseif Locale.en and Locale.en[key] then
        translation = Locale.en[key]
    end

    local packedArgs = table.pack(...)
    if packedArgs.n > 0 then
        translation = string.format(translation, ...)
    end

    if not translation then
        translation = "Missing Translation"
    end

    return translation
end

if not IsDuplicityVersion() then
    CreateThread(function()
        while not Functions.NuiLoaded do
            Wait(10)
        end

        Functions.SendNuiMessage("SetupLocale", {
            locale = Locale[Config.Lang].Nui
        })
    end)
end