local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function SetupItems(shop)
    local products = Config.Locations[shop].products
    local playerJob = QBCore.Functions.GetPlayerData().job.name
    local items = {}
    for i = 1, #products do
        if not products[i].requiredJob then
            items[#items+1] = products[i]
        else
            for i2 = 1, #products[i].requiredJob do
                if playerJob == products[i].requiredJob[i2] then
                    items[#items+1] = products[i]
                end
            end
        end
    end
    return items
end

local function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Events

RegisterNetEvent('qb-shops:client:UpdateShop', function(shop, itemData, amount)
    TriggerServerEvent('qb-shops:server:UpdateShopItems', shop, itemData, amount)
end)

RegisterNetEvent('qb-shops:client:SetShopItems', function(shop, shopProducts)
    Config.Locations[shop]["products"] = shopProducts
end)

RegisterNetEvent('qb-shops:client:RestockShopItems', function(shop, amount)
    if Config.Locations[shop]["products"] ~= nil then
        for k, v in pairs(Config.Locations[shop]["products"]) do
            Config.Locations[shop]["products"][k].amount = Config.Locations[shop]["products"][k].amount + amount
        end
    end
end)

RegisterNetEvent('qb-shops:client:tequila')
AddEventHandler('qb-shops:client:tequila', function()
    local tequila = {}
    tequila.label = "tequila Market"
    tequila.items = {
        [1] = { name = "vodka", price = 175, amount = 2500, info = {}, type = "item", slot = 1 },
        [2] = { name = "burger-mshake", price = 25, amount = 2500, info = {}, type = "item", slot = 2 },
        [3] = { name = "beer", price = 25, amount = 2500, info = {}, type = "item", slot = 3 },
        [4] = { name = "ecola", price = 25, amount = 2500, info = {}, type = "item", slot = 4 },
        [5] = { name = "ecolalight", price = 15, amount = 2500, info = {}, type = "item", slot = 5 },
        [6] = { name = "pisswasser", price = 25, amount = 2500, info = {}, type = "item", slot = 6 },
        [7] = { name = "logger", price = 25, amount = 2500, info = {}, type = "item", slot = 7 },
        [8] = { name = "dusche", price = 25, amount = 2500, info = {}, type = "item", slot = 8 },
        [9] = { name = "ambeer", price = 25, amount = 2500, info = {}, type = "item", slot = 9 },
        [10] = { name = "amarone", price = 25, amount = 2500, info = {}, type = "item", slot = 10 },
        [11] = { name = "dolceto", price = 25, amount = 2500, info = {}, type = "item", slot = 11 },
        [12] = { name = "pisswasser2", price = 25, amount = 2500, info = {}, type = "item", slot = 12 },
        [13] = { name = "pisswasser3", price = 25, amount = 2500, info = {}, type = "item", slot = 13 },
        [14] = { name = "bellini", price = 25, amount = 2500, info = {}, type = "item", slot = 14 },
        [15] = { name = "strawmargarita", price = 25, amount = 2500, info = {}, type = "item", slot = 15 },
        [16] = { name = "margarita", price = 25, amount = 2500, info = {}, type = "item", slot = 16 },
        [17] = { name = "pinacolada", price = 25, amount = 2500, info = {}, type = "item", slot = 17 },
        [18] = { name = "margarita", price = 25, amount = 2500, info = {}, type = "item", slot = 18 },
        [19] = { name = "longisland", price = 25, amount = 2500, info = {}, type = "item", slot = 19 },

    }
    tequila.slots = #tequila.items
    TriggerServerEvent("inventory:server:OpenInventory", "shop", "tequilashop", tequila)
end)

-- Threads
RegisterNetEvent('qb-shops:marketshop', function()
    for shop, data in pairs(Config.Locations) do
        local position = data["coords"]
        local products = data["products"]
        for _, loc in pairs(position) do
            local dist = #(GetEntityCoords(PlayerPedId()) - vector3(loc["x"], loc["y"], loc["z"]))
            if dist < 3 then
                local ShopItems = {}
                ShopItems.items = {}
                local callback = promise.new()
                QBCore.Functions.TriggerCallback('qb-shops:server:getLicenseStatus', function(result)
                    ShopItems.label = Config.Locations[shop]["label"]
                    if Config.Locations[shop].type == "weapon" then
                        if result then
                            ShopItems.items = SetupItems(shop)
                        else
                            for i = 1, #products do
                                if not products[i].requiredJob then
                                    if not products[i].requiresLicense then
                                        table.insert(ShopItems.items, products[i])
                                    end
                                else
                                    for i2 = 1, #products[i].requiredJob do
                                        if QBCore.Functions.GetPlayerData().job.name == products[i].requiredJob[i2] and not products[i].requiresLicense then
                                            table.insert(ShopItems.items, products[i])
                                        end
                                    end
                                end
                            end
                        end
                    else
                        ShopItems.items = SetupItems(shop)
                    end
                    for k, v in pairs(ShopItems.items) do
                        ShopItems.items[k].slot = k
                    end
                    ShopItems.slots = 30
                    TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_"..shop, ShopItems)
                    callback:resolve(true)
                end)

                Citizen.Await(callback)
                break
            end
        end
    end
end)

--[[ CreateThread(function()
    while true do
        local InRange = false
        local PlayerPed = PlayerPedId()
        local PlayerPos = GetEntityCoords(PlayerPed)

        for shop, _ in pairs(Config.Locations) do
            local position = Config.Locations[shop]["coords"]
            local products = Config.Locations[shop].products
            for _, loc in pairs(position) do
                local dist = #(PlayerPos - vector3(loc["x"], loc["y"], loc["z"]))
                if dist < 10 then
                    InRange = true
                    DrawMarker(2, loc["x"], loc["y"], loc["z"], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.2, 0.1, 255, 255, 255, 155, 0, 0, 0, 1, 0, 0, 0)
                    if dist < 1 then
                        DrawText3Ds(loc["x"], loc["y"], loc["z"] + 0.15, '~g~[E]~w~ - Shop')
                        if IsControlJustPressed(0, 38) then -- E
                            local ShopItems = {}
                            ShopItems.items = {}
                            QBCore.Functions.TriggerCallback('qb-shops:server:getLicenseStatus', function(hasLicense, hasLicenseItem)
                                ShopItems.label = Config.Locations[shop]["label"]
                                if Config.Locations[shop].type == "weapon" then
                                    if hasLicense and hasLicenseItem then
                                        ShopItems.items = SetupItems(shop)
                                        QBCore.Functions.Notify("The dealer verifies your license", "success")
                                        Wait(500)
                                    else
                                        for i = 1, #products do
                                            if not products[i].requiredJob then
                                                if not products[i].requiresLicense then
                                                    ShopItems.items[#ShopItems.items+1] = products[i]
                                                end
                                            else
                                                for i2 = 1, #products[i].requiredJob do
                                                    if QBCore.Functions.GetPlayerData().job.name == products[i].requiredJob[i2] and not products[i].requiresLicense then
                                                        ShopItems.items[#ShopItems.items+1] = products[i]
                                                    end
                                                end
                                            end
                                        end
                                        QBCore.Functions.Notify("The dealer declines to show you firearms", "error")
                                        Wait(500)
                                        QBCore.Functions.Notify("Speak with law enforcement to get a firearms license", "error")
                                        Wait(1000)
                                    end
                                else
                                    ShopItems.items = SetupItems(shop)
                                end
                                for k, v in pairs(ShopItems.items) do
                                    ShopItems.items[k].slot = k
                                end
                                ShopItems.slots = 30
                                TriggerServerEvent("inventory:server:OpenInventory", "shop", "Itemshop_"..shop, ShopItems)
                            end)
                        end
                    end
                end
            end
        end

        if not InRange then
            Wait(5000)
        end
        Wait(5)
    end
end) ]]

CreateThread(function()
	for store, _ in pairs(Config.Locations) do
		if Config.Locations[store]["showblip"] then
			StoreBlip = AddBlipForCoord(Config.Locations[store]["coords"][1]["x"], Config.Locations[store]["coords"][1]["y"], Config.Locations[store]["coords"][1]["z"])
			SetBlipColour(StoreBlip, 0)
            SetBlipScale(StoreBlip, 0.65)

			if Config.Locations[store]["products"] == Config.Products["normal"] then
				SetBlipSprite(StoreBlip, 52)
				SetBlipScale(StoreBlip, 0.65)
			elseif Config.Locations[store]["products"] == Config.Products["coffeeplace"] then
				SetBlipSprite(StoreBlip, 52)
				SetBlipScale(StoreBlip, 0.65)
			elseif Config.Locations[store]["products"] == Config.Products["gearshop"] then
				SetBlipSprite(StoreBlip, 52)
				SetBlipScale(StoreBlip, 0.65)
			elseif Config.Locations[store]["products"] == Config.Products["hardware"] then
				SetBlipSprite(StoreBlip, 402)
				SetBlipScale(StoreBlip, 0.8)
			elseif Config.Locations[store]["products"] == Config.Products["weapons"] then
				SetBlipSprite(StoreBlip, 110)
				SetBlipScale(StoreBlip, 0.8)
			elseif Config.Locations[store]["products"] == Config.Products["leisureshop"] then
				SetBlipSprite(StoreBlip, 52)
				SetBlipScale(StoreBlip, 0.65)
				SetBlipColour(StoreBlip, 3)
			elseif Config.Locations[store]["products"] == Config.Products["mustapha"] then
				SetBlipSprite(StoreBlip, 225)
				SetBlipScale(StoreBlip, 0.65)
				SetBlipColour(StoreBlip, 3)
			elseif Config.Locations[store]["products"] == Config.Products["coffeeshop"] then
				SetBlipSprite(StoreBlip, 140)
				SetBlipScale(StoreBlip, 0.55)
			elseif Config.Locations[store]["products"] == Config.Products["casino"] then
				SetBlipSprite(StoreBlip, 617)
				SetBlipScale(StoreBlip, 0.70)
            elseif Config.Locations[store]["products"] == Config.Products["digitalden"] then
                SetBlipSprite(StoreBlip, 521)
                SetBlipScale(StoreBlip, 0.65)
            elseif Config.Locations[store]["products"] == Config.Products["electricshop"] then
                SetBlipSprite(StoreBlip, 233)
                SetBlipScale(StoreBlip, 0.75)
                SetBlipColour(StoreBlip, 18)
			end

			SetBlipDisplay(StoreBlip, 4)
			SetBlipAsShortRange(StoreBlip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(Config.Locations[store]["label"])
			EndTextCommandSetBlipName(StoreBlip)
		end
	end
end)