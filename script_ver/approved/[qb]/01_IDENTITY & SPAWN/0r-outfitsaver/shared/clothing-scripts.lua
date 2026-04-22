ClothingScripts = {
    {
        ResourceName = "0r-clothing",
        SetClothing = function(skinData)
            return TriggerEvent('0r-clothing:client:loadPlayerClothing', skinData, PlayerPedId())
        end
    },
    {
        ResourceName = "pa-clothing",
        SetClothing = function(skinData)
            return TriggerEvent('pa-clothing:client:loadPlayerClothing', skinData, PlayerPedId())
        end
    },
    {
        ResourceName = "qb-clothing",
        SetClothing = function(skinData)
            return TriggerEvent('qb-clothing:client:loadPlayerClothing', skinData, PlayerPedId())
        end
    },
    {
        ResourceName = "illenium-appearance",
        SetClothing = function(skinData)
            return exports['illenium-appearance']:setPlayerAppearance(skinData)
        end
    },
    {
        ResourceName = "esx_skin",
        SetClothing = function(skinData)
            return TriggerEvent('skinchanger:loadSkin', skinData)
        end
    },
    {
        ResourceName = "fivem-appearance",
        SetClothing = function(skinData)
            return exports['fivem-appearance']:setPlayerAppearance(skinData)
        end
    },
}