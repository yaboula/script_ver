--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

local version = "5.3.1"

local subversion = ""

local api_response = {}

local currentVersionStr = "1.1.9"

local is_authenticated = false

local attempts = 3
local has_lc_utils = true

Citizen.CreateThread(function()

    Wait(2000)

    local authenticated = false

    local connection_attempts = 0

    print("^2[" .. GetCurrentResourceName() .. "] Authenticated! Support discord: https://discord.gg/U5YDgbh^7 ^3[v" .. version .. subversion .. "] ^7")

    while not authenticated do

        connection_attempts = connection_attempts + 1

        PerformHttpRequest("http://projetocharmoso.com:3000/api/check-version-v2?script=3&version=" .. version, function(err, text, headers, errorData)

            if err == 200 and text then

                authenticated = true

                is_authenticated = true

                api_response = json.decode(text)

                if api_response.has_update == true then

                    print("^4[" .. GetCurrentResourceName() .. "] An update is available, download it in your keymaster^7 ^3[v" .. api_response.latest_version .. "]^7")

                    if api_response.update_message then

                        print("^4" .. api_response.update_message .. "^7")

                    else

                        print("^4[" .. GetCurrentResourceName() .. "] For the complete changelog, visit our Discord: https://discord.gg/U5YDgbh^7")

                    end

                end

            end

        end, "GET", "", {})

        if authenticated == false and connection_attempts > 5 then

            break

        end

        Wait(10000)

    end

end)

if not Utils then

    Utils = exports.lc_utils:GetUtils()

end

local active_jobs = {}
Citizen.CreateThreadNow(function()

    Citizen.Wait(10000)

    while true do

        if not Config.clear_stores.active then

            break

        end

        local stores = Utils.Database.fetchAll("SELECT market_id, user_id, stock, timer FROM store_business", {})

        for _, store in pairs(stores) do

            if Config.market_locations[store.market_id] then

                local stock = json.decode(store.stock)

                if stock then

                    local variety = Utils.Table.tableLength(stock)

                    local max_variety = getItemsCount(store.market_id)

                    if variety < (max_variety * (Config.clear_stores.min_stock_variety / 100)) then

                        local amount = getStockAmount(store.stock)

                        local capacity = getConfigMarketType(store.market_id).stock_capacity

                        if amount < (capacity * (Config.clear_stores.min_stock_amount / 100)) then

                            local expire_time = store.timer + (Config.clear_stores.cooldown * 60 * 60)

                            if expire_time < os.time() then

                                deleteStore(store.market_id)

                                local message = Utils.translate("logs_lost_low_stock"):format(

                                    store.market_id, 

                                    store.stock, 

                                    os.date("%d/%m/%Y %H:%M:%S", store.timer), 

                                    store.user_id .. "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

                                )

                                Utils.Webhook.sendWebhookMessage(WebhookURL, message)

                            else

                                Utils.Database.execute("UPDATE `store_business` SET timer = @timer WHERE market_id = @market_id", {

                                    ["@timer"] = os.time(),

                                    ["@market_id"] = store.market_id

                                })

                            end

                        end

                    end

                end

            end

            Citizen.Wait(100)

        end

        Citizen.Wait(3600000)

    end

end)

AddEventHandler("playerDropped", function(reason)

    local _source = source

    if active_jobs[_source] and active_jobs[_source].deliveryman_job_data then

        Utils.Database.execute("UPDATE `store_jobs` SET progress = 0 WHERE id = @id", {

            ["@id"] = active_jobs[_source].deliveryman_job_data.id

        })

    end

    active_jobs[_source] = nil

end)

RegisterServerEvent("stores:getData")

AddEventHandler("stores:getData", function(market_id)

    local _source = source

    Wrapper(_source, market_id, "getData", false, function(user_id)

        local categories = {}

        for _, category_name in pairs(getConfigMarketType(market_id).categories) do

            categories[category_name] = getMarketCategory(category_name)

        end

        local categories_copy = Utils.Table.deepCopy(categories)

        local business = Utils.Database.fetchAll("SELECT user_id FROM `store_business` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        if business and business[1] then

            if business[1].user_id == user_id then

                openUI(_source, market_id, false)

            else

                local employee = Utils.Database.fetchAll("SELECT role FROM `store_employees` WHERE market_id = @market_id AND user_id = @user_id", {

                    ["@market_id"] = market_id,

                    ["@user_id"] = user_id

                })

                if employee and employee[1] then

                    openUI(_source, market_id, false)

                else

                    TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("already_has_owner"))

                end

            end

        else

            local owned_businesses = Utils.Database.fetchAll("SELECT market_id FROM `store_business` WHERE user_id = @user_id", {

                ["@user_id"] = user_id

            })

            if owned_businesses and #owned_businesses >= Config.max_stores_per_player then

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("already_has_business"))

            else

                TriggerClientEvent("stores:openRequest", _source, getConfigMarketLocation(market_id).buy_price, categories_copy)

            end

        end

    end)

end)

RegisterServerEvent("stores:buyMarket")

AddEventHandler("stores:buyMarket", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "buyMarket", false, function(user_id)

        local total_price = getConfigMarketLocation(market_id).buy_price + getMarketCategory(data.category).category_buy_price

        if beforeBuyMarket(_source, market_id, total_price) then

            TriggerClientEvent("stores:closeUI", _source)

            local has_money = Utils.Framework.tryRemoveAccountMoney(_source, total_price, getAccount(market_id, "store"))

            if has_money then

                Utils.Database.execute("INSERT INTO `store_business` (user_id,market_id,stock,stock_prices,timer) VALUES (@user_id,@market_id,@stock,@stock_prices,@timer);", {

                    ["@market_id"] = market_id,

                    ["@user_id"] = user_id,

                    ["@stock"] = json.encode({}),

                    ["@stock_prices"] = json.encode({}),

                    ["@timer"] = os.time()

                })

                Utils.Database.execute("INSERT INTO `store_categories` (market_id, category) VALUES (@market_id,@category);", {

                    ["@market_id"] = market_id,

                    ["@category"] = data.category

                })

                TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("businnes_bougth"))

                local current_date = os.date("\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S")

                local log_message = Utils.translate("logs_bought"):format(market_id, Utils.Framework.getPlayerIdLog(_source) .. current_date)

                Utils.Webhook.sendWebhookMessage(WebhookURL, log_message)

                afterBuyMarket(_source, market_id, total_price)

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds_store"):format(total_price))

            end

        end

    end)

end)

RegisterServerEvent("stores:openMarket")

AddEventHandler("stores:openMarket", function(market_id)

    local _source = source

    Wrapper(_source, market_id, "openMarket", false, function(user_id)

        local required_job = getConfigMarketType(market_id).required_job

        if required_job and #required_job ~= 0 then

            if not Utils.Framework.hasJobs(_source, required_job) and not isOwner(market_id, user_id) then

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("no_permission"))

                return

            end

        end

        Utils.Database.execute("UPDATE `store_business` SET total_visits = total_visits + 1 WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        openUI(_source, market_id, false, true)

    end)

end)

RegisterServerEvent("stores:loadJobData")

AddEventHandler("stores:loadJobData", function(market_id)

    local _source = source

    Wrapper(_source, market_id, "loadJobData", false, function(user_id)

        local jobs = Utils.Database.fetchAll("SELECT id,name,reward FROM store_jobs WHERE market_id = @market_id AND progress = 0 ORDER BY id ASC", {

            ["@market_id"] = market_id

        })

        if not jobs or not jobs[1] then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("no_available_jobs"))

            return

        end

        local business = Utils.Database.fetchAll("SELECT user_id FROM store_business WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        if business and business[1] and business[1].user_id == user_id then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("cannot_do_own_job"))

            return

        end

        TriggerClientEvent("stores:setJobData", _source, market_id, jobs[1])

    end)

end)

RegisterServerEvent("stores:startDeliverymanJob")

AddEventHandler("stores:startDeliverymanJob", function(market_id, job_id)

    local _source = source

    Wrapper(_source, market_id, "startDeliverymanJob", false, function(user_id)

        if active_jobs[_source] ~= nil then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("already_has_job"))

            return

        end

        local job = Utils.Database.fetchAll("SELECT * FROM store_jobs WHERE id = @id ORDER BY id ASC", {

            ["@id"] = job_id

        })

        job = job[1]

        if job and job.progress == 0 then

            Utils.Database.execute("UPDATE `store_jobs` SET progress = 1 WHERE id = @id", {

                ["@id"] = job_id

            })

            active_jobs[_source] = {

                deliveryman_job_data = job,

                job_data = {

                    item = job.product,

                    amount = job.amount

                }

            }

            TriggerClientEvent("stores:startJob", _source, 0, true)

        else

            TriggerClientEvent("stores:setJobData", _source, market_id, nil)

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("job_already_in_progress"))

        end

    end)

end)

RegisterServerEvent("stores:failed")

AddEventHandler("stores:failed", function()

    local _source = source

    if active_jobs[_source] and active_jobs[_source].deliveryman_job_data then

        Utils.Database.execute("UPDATE `store_jobs` SET progress = 0 WHERE id = @id", {

            ["@id"] = active_jobs[_source].deliveryman_job_data.id

        })

    end

    active_jobs[_source] = nil

end)

RegisterServerEvent("stores:storeProductFromInventory")

AddEventHandler("stores:storeProductFromInventory", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "storeProductFromInventory", true, function(user_id)

        storeProduct(_source, market_id, data.item_id, data.amount)

    end)

end)

function storeProduct(source, market_id, item_id, amount, is_item_not_required)

    amount = math.floor(tonumber(amount) or 0)

    if amount > 0 then

        local store_data = Utils.Database.fetchAll("SELECT stock, truck_upgrade, stock_upgrade FROM `store_business` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        if not store_data or not store_data[1] then return end

        local stock = json.decode(store_data[1].stock)

        if not stock[item_id] then stock[item_id] = 0 end

        local config = getConfigMarketType(market_id)

        local current_stock_amount = getStockAmount(store_data[1].stock) + amount

        local capacity = config.stock_capacity + config.upgrades.stock.level_reward[store_data[1].stock_upgrade]

        if current_stock_amount <= capacity then

            stock[item_id] = stock[item_id] + amount

        else

            local max_can_add = capacity - getStockAmount(store_data[1].stock)

            amount = max_can_add

            stock[item_id] = stock[item_id] + amount

            TriggerClientEvent("stores:Notify", source, "error", Utils.translate("stock_full"))

        end

        if amount > 0 then

            local item_config = getItem(market_id, item_id)

            if not is_item_not_required then

                if item_config.is_weapon == true then

                    if not Utils.Framework.getPlayerWeapon(source, item_id, amount) then

                        TriggerClientEvent("stores:Notify", source, "error", Utils.translate("not_enought_items"):format(amount, item_config.name))

                        return

                    end

                else

                    if not Utils.Framework.getPlayerItem(source, item_id, amount) then

                        TriggerClientEvent("stores:Notify", source, "error", Utils.translate("not_enought_items"):format(amount, item_config.name))

                        return

                    end

                end

            end

            Utils.Database.execute("UPDATE `store_business` SET stock = @stock WHERE market_id = @market_id", {

                ["@market_id"] = market_id,

                ["@stock"] = json.encode(stock)

            })

            if not is_item_not_required then

                openUI(source, market_id, true)

                TriggerClientEvent("stores:Notify", source, "success", Utils.translate("inserted_on_stock"):format(amount, item_config.name))

            end

        end

    else

        TriggerClientEvent("stores:Notify", source, "error", Utils.translate("invalid_value"))

    end

end

function finishTruckerContract(source, data, id)

    storeProduct(source, data.key, data.item, data.amount, true)

    Utils.Database.execute("DELETE FROM `store_jobs` WHERE trucker_contract_id = @id;", {

        ["@id"] = id

    })

end

exports("finishTruckerContract", finishTruckerContract)

RegisterServerEvent("stores:startImportJob")

AddEventHandler("stores:startImportJob", function(market_id, items)

    local _source = source

    Wrapper(_source, market_id, "startImportJob", true, function(user_id)

        if active_jobs[_source] ~= nil then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("already_has_job"))

            return

        end

        if items and Utils.Table.tableLength(items) <= 0 then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_job_amount"))

            return

        end

        local business = Utils.Database.fetchAll("SELECT truck_upgrade, relationship_upgrade, stock_upgrade, stock FROM `store_business` WHERE market_id = @market_id", {["@market_id"] = market_id})

        local categories = Utils.Database.fetchAll("SELECT * FROM `store_categories` WHERE market_id = @market_id", {["@market_id"] = market_id})

        local market_type = getConfigMarketType(market_id)

        local total_price = 0

        local total_capacity_percent = 0

        local total_amount = 0

        for k, v in pairs(items) do

            local item_id = v.item_id

            local amount = math.floor(tonumber(v.amount) or 0)

            local item_config = nil

            if categories and categories[1] then

                for _, cat in ipairs(categories) do

                    local cat_config = getMarketCategory(cat.category).items

                    if cat_config[item_id] then

                        item_config = cat_config[item_id]

                    end

                end

            end

            assert(item_config, string.format("Item %s not found in the store %s category config", item_id, market_id))

            local config_amount = math.floor(item_config.amount_to_owner + (item_config.amount_to_owner * (market_type.upgrades.truck.level_reward[business[1].truck_upgrade] / 100)))

            if amount > 0 and amount <= config_amount then

                local price = item_config.price_to_owner * amount

                local discount = price * (market_type.upgrades.relationship.level_reward[business[1].relationship_upgrade] / 100)

                local final_price = price - discount

                total_price = total_price + final_price

                total_capacity_percent = total_capacity_percent + ((amount / config_amount) * 100)

                total_amount = total_amount + amount

                v.name = item_config.name

                v.price = final_price

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_job_amount"))

                return

            end

        end

        local current_stock = getStockAmount(business[1].stock) + total_amount

        local max_stock = market_type.stock_capacity + market_type.upgrades.stock.level_reward[business[1].stock_upgrade]

        if current_stock > max_stock then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_job_amount"))

            return

        end

        total_price = math.floor(total_price)

        if total_capacity_percent > 100 or total_price <= 0 then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_job_amount"))

            return

        end

        if Config.charge_import_money_before then

            if tryGetMarketMoney(market_id, total_price) then

                insertBalanceHistory(market_id, 1, Utils.translate("buy_products_expenses"):format(formatItemAmounts(items)), total_price)

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

                return

            end

        end

        local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

        Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_start_import"):format(market_id, formatItemAmounts(items), total_price, Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

        active_jobs[_source] = { job_data = items }

        TriggerClientEvent("stores:startJob", _source, business[1].truck_upgrade, true)

    end)

end)

RegisterServerEvent("stores:startExportJob")

AddEventHandler("stores:startExportJob", function(market_id, items)

    local _source = source

    Wrapper(_source, market_id, "startExportJob", true, function(user_id)

        if active_jobs[_source] ~= nil then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("already_has_job"))

            return

        end

        if items and Utils.Table.tableLength(items) <= 0 then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_job_amount"))

            return

        end

        local business = Utils.Database.fetchAll("SELECT truck_upgrade, relationship_upgrade, stock_upgrade, stock FROM `store_business` WHERE market_id = @market_id", {["@market_id"] = market_id})

        local categories = Utils.Database.fetchAll("SELECT * FROM `store_categories` WHERE market_id = @market_id", {["@market_id"] = market_id})

        local market_type = getConfigMarketType(market_id)

        local total_price = 0

        local total_capacity_percent = 0

        local total_amount = 0

        local stock = json.decode(business[1].stock)

        for k, v in pairs(items) do

            local item_id = v.item_id

            local amount = math.floor(tonumber(v.amount) or 0)

            local item_config = nil

            if categories and categories[1] then

                for _, cat in ipairs(categories) do

                    local cat_config = getMarketCategory(cat.category).items

                    if cat_config[item_id] then

                        item_config = cat_config[item_id]

                    end

                end

            end

            assert(item_config, string.format("Item %s not found in the store %s category config", item_id, market_id))

            local config_amount = math.floor(item_config.amount_to_owner + (item_config.amount_to_owner * (market_type.upgrades.truck.level_reward[business[1].truck_upgrade] / 100)))

            if amount > 0 and amount <= config_amount then

                if stock[item_id] and amount <= stock[item_id] then

                    if amount == stock[item_id] then

                        stock[item_id] = nil

                    else

                        stock[item_id] = stock[item_id] - amount

                    end

                    local price = item_config.price_to_export * amount

                    total_price = total_price + price

                    total_capacity_percent = total_capacity_percent + ((amount / config_amount) * 100)

                    total_amount = total_amount + amount

                    v.name = item_config.name

                    v.price = price

                end

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_job_amount"))

                return

            end

        end

        if total_capacity_percent > 100 or total_amount <= 0 then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_job_amount"))

            return

        end

        Utils.Database.execute("UPDATE `store_business` SET stock = @stock WHERE market_id = @market_id", {

            ["@market_id"] = market_id,

            ["@stock"] = json.encode(stock)

        })

        local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

        Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_start_export"):format(market_id, formatItemAmounts(items), Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

        active_jobs[_source] = { job_data = items }

        TriggerClientEvent("stores:startJob", _source, business[1].truck_upgrade, false)

    end)

end)

RegisterServerEvent("stores:finishImportJob")

AddEventHandler("stores:finishImportJob", function(market_id, distance)

    local _source = source

    Wrapper(_source, market_id, "finishImportJob", false, function(user_id)

        if active_jobs[_source] then

            if active_jobs[_source].deliveryman_job_data then

                local item_id = active_jobs[_source].job_data.item

                local amount = active_jobs[_source].job_data.amount

                local business = Utils.Database.fetchAll("SELECT stock, truck_upgrade, stock_upgrade FROM `store_business` WHERE market_id = @market_id", {["@market_id"] = market_id})

                local stock = json.decode(business[1].stock)

                if not stock[item_id] then stock[item_id] = 0 end

                distance = 0

                local job_amount = tonumber(active_jobs[_source].deliveryman_job_data.amount) or amount or 0

                local reward = tonumber(active_jobs[_source].deliveryman_job_data.reward) or 0

                Utils.Framework.giveAccountMoney(_source, reward, getAccount(market_id, "store"))

                Utils.Database.execute("DELETE FROM `store_jobs` WHERE id = @id;", {

                    ["@id"] = active_jobs[_source].deliveryman_job_data.id

                })

                local market_type = getConfigMarketType(market_id)

                local current_stock = getStockAmount(business[1].stock) + job_amount

                local capacity = market_type.stock_capacity + market_type.upgrades.stock.level_reward[business[1].stock_upgrade]

                if current_stock <= capacity then

                    stock[item_id] = stock[item_id] + job_amount

                else

                    local max_can_add = capacity - getStockAmount(business[1].stock)

                    job_amount = max_can_add

                    stock[item_id] = stock[item_id] + job_amount

                    TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("stock_full"))

                end

                Utils.Database.execute("UPDATE `store_employees` SET jobs_done = jobs_done + 1 WHERE market_id = @market_id and user_id = @user_id", {

                    ["@market_id"] = market_id,

                    ["@user_id"] = user_id

                })

                Utils.Database.execute("UPDATE `store_business` SET stock = @stock, goods_bought = goods_bought + @amount, distance_traveled = distance_traveled + @distance WHERE market_id = @market_id", {

                    ["@market_id"] = market_id,

                    ["@stock"] = json.encode(stock),

                    ["@amount"] = job_amount,

                    ["@distance"] = distance

                })

                local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

                Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_finish_import"):format(market_id, item_id .. " x " .. job_amount, json.encode(stock), Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

                active_jobs[_source] = nil

            else

                local total_price = 0

                local total_amount = 0

                for _, v in pairs(active_jobs[_source].job_data) do

                    total_price = total_price + v.price

                    total_amount = total_amount + v.amount

                    storeProduct(_source, market_id, v.item_id, v.amount, true)

                    Wait(1)

                end

                total_price = math.floor(total_price)

                if not Config.charge_import_money_before then

                    if tryGetMarketMoney(market_id, total_price) then

                        insertBalanceHistory(market_id, 1, Utils.translate("buy_products_expenses"):format(formatItemAmounts(active_jobs[_source].job_data)), total_price)

                    else

                        TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

                        active_jobs[_source] = nil

                        return

                    end

                end

                local business = Utils.Database.fetchAll("SELECT stock, truck_upgrade, stock_upgrade FROM `store_business` WHERE market_id = @market_id", {["@market_id"] = market_id})

                local stock = json.decode(business[1].stock)

                Utils.Database.execute("UPDATE `store_employees` SET jobs_done = jobs_done + 1 WHERE market_id = @market_id and user_id = @user_id", {

                    ["@market_id"] = market_id,

                    ["@user_id"] = user_id

                })

                Utils.Database.execute("UPDATE `store_business` SET goods_bought = goods_bought + @amount, distance_traveled = distance_traveled + @distance WHERE market_id = @market_id", {

                    ["@market_id"] = market_id,

                    ["@amount"] = total_amount,

                    ["@distance"] = distance

                })

                local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

                Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_finish_import"):format(market_id, formatItemAmounts(active_jobs[_source].job_data), json.encode(stock), Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

                active_jobs[_source] = nil

            end

        end

    end)

end)

RegisterServerEvent("stores:finishExportJob")

AddEventHandler("stores:finishExportJob", function(market_id, distance)

    local _source = source

    Wrapper(_source, market_id, "finishExportJob", false, function(user_id)

        if active_jobs[_source] then

            local total_price = 0

            local total_amount = 0

            for _, v in pairs(active_jobs[_source].job_data) do

                total_price = total_price + v.price

                total_amount = total_amount + v.amount

            end

            giveMarketMoney(market_id, total_price)

            insertBalanceHistory(market_id, 0, Utils.translate("exported_income"):format(formatItemAmounts(active_jobs[_source].job_data)), total_price)

            Utils.Database.execute("UPDATE `store_employees` SET jobs_done = jobs_done + 1 WHERE market_id = @market_id and user_id = @user_id", {

                ["@market_id"] = market_id,

                ["@user_id"] = user_id

            })

            Utils.Database.execute("UPDATE `store_business` SET total_money_earned = total_money_earned + @money, distance_traveled = distance_traveled + @distance WHERE market_id = @market_id", {

                ["@market_id"] = market_id,

                ["@money"] = total_price,

                ["@distance"] = distance

            })

            local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

            Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_finish_export"):format(market_id, formatItemAmounts(active_jobs[_source].job_data), total_price, Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

            active_jobs[_source] = nil

        end

    end)

end)

RegisterServerEvent("stores:setPrice")

AddEventHandler("stores:setPrice", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "setPrice", true, function(user_id)

        local item_id = data.item_id

        local price = math.floor(tonumber(data.price) or 0)

        local item_config = getItem(market_id, item_id)

        item_config.price_to_customer_min = item_config.price_to_customer_min or 0

        item_config.price_to_customer_max = item_config.price_to_customer_max or 999999

        if price >= item_config.price_to_customer_min and price <= item_config.price_to_customer_max then

            local business = Utils.Database.fetchAll("SELECT stock_prices FROM `store_business` WHERE market_id = @market_id", {

                ["@market_id"] = market_id

            })

            local stock_prices = json.decode(business[1].stock_prices)

            stock_prices[item_id] = price

            Utils.Database.execute("UPDATE `store_business` SET stock_prices = @stock_prices WHERE market_id = @market_id", {

                ["@market_id"] = market_id,

                ["@stock_prices"] = json.encode(stock_prices)

            })

            openUI(_source, market_id, true)

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("invalid_price"):format(item_config.price_to_customer_min, item_config.price_to_customer_max))

        end

    end)

end)

local lock_buy_item = {}

RegisterServerEvent("stores:buyItem")

AddEventHandler("stores:buyItem", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "buyItem", false, function(user_id)

        if lock_buy_item[market_id] == nil then

            lock_buy_item[market_id] = true

            Utils.Database.fetchAllAsync("SELECT stock, stock_prices FROM `store_business` WHERE market_id = @market_id", {

                ["@market_id"] = market_id

            }, function(business)

                data.amount = math.floor(tonumber(data.amount) or 0)

                if data.amount > 0 then

                    local stock = {}

                    local stock_prices = {}

                    local item_config = nil

                    if business and business[1] then

                        stock = json.decode(business[1].stock)

                        if not stock[data.item_id] then stock[data.item_id] = 0 end

                        stock_prices = json.decode(business[1].stock_prices)

                        item_config = getItem(market_id, data.item_id)

                    else

                        item_config = getItemNoKey(data.item_id)

                        if Config.has_stock_when_unowed then

                            stock[data.item_id] = 999

                        else

                            stock[data.item_id] = 0

                        end

                    end

                    if stock[data.item_id] >= data.amount then

                        local price_per_item = stock_prices[data.item_id] or item_config.price_to_customer

                        local total_price = price_per_item * data.amount

                        if beforeBuyItem(_source, market_id, data.item_id, data.amount, total_price, item_config.metadata) then

                            if item_config.max_amount_to_purchase and data.amount > item_config.max_amount_to_purchase then

                                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("cant_buy_that_amount"):format(item_config.max_amount_to_purchase))

                            else

                                local payment_method = tonumber(data.paymentMethod)

                                local account = getConfigMarketLocation(market_id).account.item[payment_method].account

                                if total_price <= Utils.Framework.getPlayerAccountMoney(_source, account) then

                                    if item_config.requires_license == true and not Utils.Framework.hasWeaponLicense(_source) then

                                        TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("dont_have_weapon_license"))

                                    else

                                        local given_item = false

                                        if item_config.is_weapon == true then

                                            given_item = Utils.Framework.givePlayerWeapon(_source, data.item_id, data.amount, item_config.metadata)

                                        else

                                            given_item = Utils.Framework.givePlayerItem(_source, data.item_id, data.amount, item_config.metadata)

                                        end

                                        if given_item then

                                            Utils.Framework.tryRemoveAccountMoney(_source, total_price, account)

                                            if business and business[1] then

                                                giveMarketMoney(market_id, total_price)

                                                stock[data.item_id] = stock[data.item_id] - data.amount

                                                if stock[data.item_id] == 0 then

                                                    stock[data.item_id] = nil

                                                end

                                                insertBalanceHistory(market_id, 0, Utils.translate("bought_item"):format(data.amount, item_config.name), total_price)

                                                Utils.Database.execute("UPDATE `store_business` SET stock = @stock, customers = customers + 1, total_money_earned = total_money_earned + @money WHERE market_id = @market_id", {

                                                    ["@market_id"] = market_id,

                                                    ["@money"] = total_price,

                                                    ["@stock"] = json.encode(stock)

                                                })

                                            end

                                            openUI(_source, market_id, true, true)

                                            local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

                                            Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_item_bought"):format(market_id, data.item_id, data.amount, Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

                                            TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("bought_item_2"):format(data.amount, item_config.name))

                                            afterBuyItem(_source, market_id, data.item_id, data.amount, total_price, account)

                                        else

                                            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("cant_carry_item"))

                                        end

                                    end

                                else

                                    TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

                                end

                            end

                        end

                    else

                        TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("stock_empty"))

                    end

                end

                SetTimeout(500, function()

                    lock_buy_item[market_id] = nil

                end)

            end)

        end

    end)

end)

RegisterServerEvent("stores:createJob")

AddEventHandler("stores:createJob", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "createJob", true, function(user_id)

        local count_res = Utils.Database.fetchAll("SELECT COUNT(id) as qtd FROM store_jobs WHERE market_id = @market_id", {["@market_id"] = market_id})

        local job_amount = tonumber(count_res[1].qtd)

        if job_amount < Config.max_jobs then

            local business = Utils.Database.fetchAll("SELECT relationship_upgrade FROM `store_business` WHERE market_id = @market_id", {["@market_id"] = market_id})

            local price_to_owner = getItem(market_id, data.product).price_to_owner * data.amount

            local discount = math.floor((price_to_owner * getConfigMarketType(market_id).upgrades.relationship.level_reward[business[1].relationship_upgrade]) / 100)

            local final_expense = (data.reward + price_to_owner) - discount

            if tryGetMarketMoney(market_id, final_expense) then

                local trucker_contract_id = nil

                if Config.trucker_logistics.enable then

                    local contract_type = 1

                    local truck = nil

                    if Config.trucker_logistics.quick_jobs_page == true then

                        truck = Config.trucker_logistics.available_trucks[math.random(1, #Config.trucker_logistics.available_trucks)]

                        contract_type = 0

                    end

                    local trailer = Config.trucker_logistics.available_trailers[math.random(1, #Config.trucker_logistics.available_trailers)]

                    local parking_loc = getConfigMarketLocation(market_id).truck_parking_location

                    local external_data = {

                        x = parking_loc[1],

                        y = parking_loc[2],

                        z = parking_loc[3],

                        h = parking_loc[4],

                        key = market_id,

                        reward = data.reward,

                        item = data.product,

                        amount = data.amount,

                        export = GetCurrentResourceName()

                    }

                    Utils.Database.execute("INSERT INTO `trucker_available_contracts` (contract_type, contract_name, coords_index, price_per_km, cargo_type, fragile, valuable, fast, truck, trailer, external_data) VALUES (@contract_type, @contract_name, @coords_index, @price_per_km, @cargo_type, @fragile, @valuable, @fast, @truck, @trailer, @external_data);", {

                        ["@contract_type"] = contract_type,

                        ["@contract_name"] = data.name,

                        ["@coords_index"] = 0,

                        ["@price_per_km"] = 0,

                        ["@cargo_type"] = 0,

                        ["@fragile"] = 0,

                        ["@valuable"] = 0,

                        ["@fast"] = 0,

                        ["@truck"] = truck,

                        ["@trailer"] = trailer,

                        ["@external_data"] = json.encode(external_data)

                    })

                    local contract = Utils.Database.fetchAll("SELECT contract_id FROM `trucker_available_contracts` WHERE progress IS NULL AND contract_name = @name AND coords_index = 0 ORDER BY contract_id DESC LIMIT 1", {

                        ["@name"] = data.name

                    })

                    trucker_contract_id = contract[1].contract_id

                end

                Utils.Database.execute("INSERT INTO `store_jobs` (market_id,name,reward,product,amount,trucker_contract_id) VALUES (@market_id,@name,@reward,@product,@amount,@trucker_contract_id);", {

                    ["@market_id"] = market_id,

                    ["@name"] = data.name,

                    ["@reward"] = data.reward,

                    ["@product"] = data.product,

                    ["@amount"] = data.amount,

                    ["@trucker_contract_id"] = trucker_contract_id

                })

                insertBalanceHistory(market_id, 1, Utils.translate("create_job_expenses"):format(data.name), final_expense)

                openUI(_source, market_id, true)

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

            end

        end

    end)

end)

RegisterServerEvent("stores:deleteJob")

AddEventHandler("stores:deleteJob", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "deleteJob", true, function(user_id)

        if deleteJob(market_id, data.job_id) then

            openUI(_source, market_id, true)

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("cant_delete_job"))

        end

    end)

end)

function deleteJob(market_id, job_id)

    local jobs = Utils.Database.fetchAll("SELECT name,reward,product,amount,progress,trucker_contract_id FROM `store_jobs` WHERE id = @id;", {

        ["@id"] = job_id

    })

    if jobs and jobs[1] then

        if Config.trucker_logistics.enable then

            local contract = Utils.Database.fetchAll("SELECT progress FROM `trucker_available_contracts` WHERE contract_id = @contract_id", {

                ["@contract_id"] = jobs[1].trucker_contract_id

            })

            if contract and contract[1] and contract[1].progress ~= nil then

                return false

            end

        end

        if jobs[1].progress == 0 then

            local business = Utils.Database.fetchAll("SELECT relationship_upgrade FROM `store_business` WHERE market_id = @market_id", {

                ["@market_id"] = market_id

            })

            local price_to_owner = getItem(market_id, jobs[1].product).price_to_owner * jobs[1].amount

            local discount = math.floor((price_to_owner * getConfigMarketType(market_id).upgrades.relationship.level_reward[business[1].relationship_upgrade]) / 100)

            local refund = (jobs[1].reward + price_to_owner) - discount

            Utils.Database.execute("UPDATE `store_business` SET total_money_spent = total_money_spent - @amount WHERE market_id = @market_id", {

                ["@amount"] = refund,

                ["@market_id"] = market_id

            })

            Utils.Database.execute("DELETE FROM `store_jobs` WHERE id = @id;", {

                ["@id"] = job_id

            })

            if Config.trucker_logistics.enable then

                Utils.Database.execute("DELETE FROM `trucker_available_contracts` WHERE contract_id = @contract_id;", {

                    ["@contract_id"] = jobs[1].trucker_contract_id

                })

            end

            giveMarketMoney(market_id, refund)

            insertBalanceHistory(market_id, 0, Utils.translate("create_job_income"):format(jobs[1].name), refund)

            return true

        else

            return false

        end

    end

end

RegisterServerEvent("stores:renameMarket")

AddEventHandler("stores:renameMarket", function(market_id, data)

    if not Config.disable_rename_business then

        local _source = source

        Wrapper(_source, market_id, "renameMarket", true, function(user_id)

            if data and data.name and data.color and data.blip then

                Utils.Database.execute("UPDATE `store_business` SET market_name = @name, market_color = @color, market_blip = @blip WHERE market_id = @market_id", {

                    ["@name"] = data.name,

                    ["@color"] = data.color,

                    ["@blip"] = data.blip,

                    ["@market_id"] = market_id

                })

                TriggerClientEvent("stores:updateBlip", -1, market_id, data.name, data.color, data.blip)

                openUI(_source, market_id, true)

            end

        end)

    end

end)

RegisterServerEvent("stores:getBlips")

AddEventHandler("stores:getBlips", function()

    local _source = source

    local markets = Utils.Database.fetchAll("SELECT market_id, market_name, market_color, market_blip FROM `store_business`", {})

    local blips = {}

    for _, market in pairs(markets) do

        blips[market.market_id] = {

            market_name = market.market_name,

            market_color = market.market_color,

            market_blip = market.market_blip

        }

    end

    TriggerClientEvent("stores:setBlips", _source, blips)

end)

RegisterServerEvent("stores:buyUpgrade")

local function resolveUpgradeColumn(market_id, upgrade_id)

    if type(upgrade_id) ~= "string" then

        return nil

    end

    if not upgrade_id:match("^[%w_]+$") then

        return nil

    end

    local market_type = getConfigMarketType(market_id)

    if not market_type or not market_type.upgrades or not market_type.upgrades[upgrade_id] then

        return nil

    end

    return upgrade_id .. "_upgrade"

end

AddEventHandler("stores:buyUpgrade", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "buyUpgrade", true, function(user_id)

        local upgrade_id = type(data) == "table" and data.id or nil

        local upgrade_column = resolveUpgradeColumn(market_id, upgrade_id)

        if not upgrade_column then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("invalid_value"))

            return

        end

        local upgrade = Utils.Database.fetchAll("SELECT `" .. upgrade_column .. "` FROM `store_business` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        local current_level = upgrade and upgrade[1] and tonumber(upgrade[1][upgrade_column])

        if not current_level then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("invalid_value"))

            return

        end

        if current_level < 5 then

            local price = getConfigMarketType(market_id).upgrades[upgrade_id].price

            if tryGetMarketMoney(market_id, price) then

                Utils.Database.execute("UPDATE `store_business` SET `" .. upgrade_column .. "` = `" .. upgrade_column .. "` + 1 WHERE market_id = @market_id", {

                    ["@market_id"] = market_id

                })

                insertBalanceHistory(market_id, 1, Utils.translate("upgrade_expenses"):format(Utils.translate(upgrade_id .. "_upgrade")), price)

                openUI(_source, market_id, true)

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

            end

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_level"))

        end

    end)

end)

RegisterServerEvent("stores:hideBalance")

AddEventHandler("stores:hideBalance", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "hideBalance", true, function(user_id)

        Utils.Database.execute("UPDATE `store_balance` SET hidden = 1 WHERE market_id = @market_id AND id = @id", {

            ["@market_id"] = market_id,

            ["@id"] = data.balance_id

        })

        openUI(_source, market_id, true)

    end)

end)

RegisterServerEvent("stores:showBalance")

AddEventHandler("stores:showBalance", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "showBalance", true, function(user_id)

        Utils.Database.execute("UPDATE `store_balance` SET hidden = 0 WHERE market_id = @market_id AND id = @id", {

            ["@market_id"] = market_id,

            ["@id"] = data.balance_id

        })

        openUI(_source, market_id, true)

    end)

end)

RegisterServerEvent("stores:withdrawMoney")

AddEventHandler("stores:withdrawMoney", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "withdrawMoney", true, function(user_id)

        local amount = math.floor(tonumber(data.amount) or 0)

        if amount and amount > 0 then

            local business = Utils.Database.fetchAll("SELECT money FROM `store_business` WHERE market_id = @market_id", {

                ["@market_id"] = market_id

            })

            business = business[1]

            if business then

                if amount <= tonumber(business.money) then

                    Utils.Database.execute("UPDATE `store_business` SET money = money - @amount WHERE market_id = @market_id", {

                        ["@market_id"] = market_id,

                        ["@amount"] = amount

                    })

                    Utils.Framework.giveAccountMoney(_source, amount, getAccount(market_id, "store"))

                    insertBalanceHistory(market_id, 1, Utils.translate("money_withdrawn"), amount)

                    TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("money_withdrawn"))

                    local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

                    Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_money_withdrawn"):format(market_id, amount, Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

                    openUI(_source, market_id, true)

                else

                    TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

                end

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("invalid_value"))

            end

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("invalid_value"))

        end

    end)

end)

RegisterServerEvent("stores:depositMoney")

AddEventHandler("stores:depositMoney", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "depositMoney", true, function(user_id)

        local amount = math.floor(tonumber(data.amount) or 0)

        if amount and amount > 0 then

            if Utils.Framework.tryRemoveAccountMoney(_source, amount, getAccount(market_id, "store")) then

                giveMarketMoney(market_id, amount)

                insertBalanceHistory(market_id, 0, Utils.translate("money_deposited"), amount)

                TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("money_deposited"))

                local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

                Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_money_deposited"):format(market_id, amount, Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

                openUI(_source, market_id, true)

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

            end

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("invalid_value"))

        end

    end)

end)

Utils.Callback.RegisterServerCallback("stores:loadBalanceHistory", function(source, cb, market_id, data)

    local user_id = Utils.Framework.getPlayerId(source)

    if not user_id or not market_id or not Config.market_locations[market_id] then

        cb({})

        return

    end

    if not isOwner(market_id, user_id) and not hasRole(market_id, user_id, "showBalance") then

        TriggerClientEvent("stores:Notify", source, "error", Utils.translate("insufficient_permission"))

        cb({})

        return

    end

    local last_balance_id = math.floor(tonumber(data and data.last_balance_id) or 0)

    if last_balance_id <= 0 then

        cb({})

        return

    end

    local balance = Utils.Database.fetchAll("SELECT * FROM `store_balance` WHERE market_id = @market_id AND id < @last_balance_id ORDER BY id DESC LIMIT 50", {

        ["@market_id"] = market_id,

        ["@last_balance_id"] = last_balance_id

    })

    cb(balance)

end)

RegisterServerEvent("stores:hirePlayer")

AddEventHandler("stores:hirePlayer", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "hirePlayer", true, function(user_id)

        local count_res = Utils.Database.fetchAll("SELECT COUNT(user_id) as qtd FROM `store_employees` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        local max_employees = getConfigMarketType(market_id).max_employees or 0

        if max_employees > count_res[1].qtd then

            local employee_name = Utils.Framework.getPlayerName(data.user)

            if employee_name then

                local active_jobs = Utils.Database.fetchAll("SELECT market_id, user_id FROM `store_employees` WHERE user_id = @user_id", {

                    ["@user_id"] = data.user

                })

                for _, job in pairs(active_jobs) do

                    if job.user_id == data.user and job.market_id == market_id then

                        TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("user_employed"))

                        return

                    end

                end

                if not beforeHireEmployee(_source, market_id, data.user) then return end

                if #active_jobs < Config.max_stores_employed then

                    Utils.Database.execute("INSERT INTO `store_employees` (`user_id`, `market_id`, `role`, `timer`) VALUES (@user_id, @market_id, @role, @timer);", {

                        ["@user_id"] = data.user,

                        ["@market_id"] = market_id,

                        ["@role"] = 1,

                        ["@timer"] = os.time()

                    })

                    openUI(_source, market_id, true)

                    TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("hired_user"):format(employee_name))

                    afterHireEmployee(_source, market_id, data.user)

                else

                    TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("user_employed"))

                end

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("user_not_found"))

            end

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("max_employees"))

        end

    end)

end)

RegisterServerEvent("stores:firePlayer")

AddEventHandler("stores:firePlayer", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "firePlayer", true, function(user_id)

        Utils.Database.execute("DELETE FROM `store_employees` WHERE user_id = @user_id AND market_id = @market_id", {

            ["@user_id"] = data.user,

            ["@market_id"] = market_id

        })

        TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("fired_user"))

        openUI(_source, market_id, true)

    end)

end)

RegisterServerEvent("stores:changeRole")

AddEventHandler("stores:changeRole", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "changeRole", true, function(user_id)

        Utils.Database.execute("UPDATE `store_employees` SET role = @role WHERE market_id = @market_id AND user_id = @user_id", {

            ["@market_id"] = market_id,

            ["@user_id"] = data.user_id,

            ["@role"] = data.role

        })

        TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("role_changed"))

    end)

end)

RegisterServerEvent("stores:giveComission")

AddEventHandler("stores:giveComission", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "giveComission", true, function(user_id)

        local target_user = data.user

        local amount = math.floor(tonumber(data.amount) or 0)

        if amount > 0 then

            local target_source = Utils.Framework.getPlayerSource(target_user)

            if target_source then

                if tryGetMarketMoney(market_id, amount) then

                    Utils.Framework.giveAccountMoney(target_source, amount, getAccount(market_id, "store"))

                    TriggerClientEvent("stores:Notify", target_source, "success", Utils.translate("comission_received"))

                    TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("comission_sent"))

                    insertBalanceHistory(market_id, 1, Utils.translate("give_comission_expenses"):format(Utils.Framework.getPlayerName(target_user)), amount)

                    local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

                    Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_comission"):format(market_id, amount, Utils.Framework.getPlayerIdLog(target_source), Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

                    openUI(_source, market_id, true)

                else

                    TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

                end

            else

                TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("cant_find_user"))

            end

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("invalid_value"))

        end

    end)

end)

RegisterServerEvent("stores:buyCategory")

AddEventHandler("stores:buyCategory", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "buyCategory", true, function(user_id)

        local count_res = Utils.Database.fetchAll("SELECT COUNT(*) as category_count FROM store_categories WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        if count_res[1].category_count >= getConfigMarketType(market_id).max_purchasable_categories then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("category_max_amount"))

            return

        end

        local category_config = getMarketCategory(data.category)

        if not tryGetMarketMoney(market_id, category_config.category_buy_price) then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("insufficient_funds"))

            return

        end

        Utils.Database.execute("INSERT INTO store_categories (market_id, category) VALUES (@market_id,@category)", {

            ["@market_id"] = market_id,

            ["@category"] = data.category

        })

        TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("category_bought"))

        insertBalanceHistory(market_id, 1, Utils.translate("category_bought_balance"):format(category_config.page_name), category_config.category_buy_price)

        openUI(_source, market_id, true)

    end)

end)

RegisterServerEvent("stores:sellCategory")

AddEventHandler("stores:sellCategory", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "sellCategory", true, function(user_id)

        local category_config = getMarketCategory(data.category)

        local sell_price = category_config.category_sell_price

        local current_category = Utils.Database.fetchAll("SELECT id FROM store_categories WHERE market_id = @market_id AND category = @category", {

            ["@market_id"] = market_id,

            ["@category"] = data.category

        })

        if #current_category == 0 then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("category_not_found"))

            return

        end

        local count_res = Utils.Database.fetchAll("SELECT COUNT(*) as category_count FROM store_categories WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        if count_res[1].category_count == 1 then

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("cannot_sell_last_category"))

            return

        end

        local jobs = Utils.Database.fetchAll("SELECT * FROM `store_jobs` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        for _, job in pairs(jobs) do

            if category_config.items[job.product] then

                if not deleteJob(market_id, job.id) then

                    TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("cant_delete_category"))

                    return

                end

            end

        end

        local business = Utils.Database.fetchAll("SELECT stock, stock_prices FROM `store_business` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        local stock = json.decode(business[1].stock)

        local stock_prices = json.decode(business[1].stock_prices)

        for item_key, _ in pairs(category_config.items) do

            stock[item_key] = nil

            stock_prices[item_key] = nil

        end

        Utils.Database.execute("UPDATE `store_business` SET stock = @stock, stock_prices = @stock_prices WHERE market_id = @market_id", {

            ["@market_id"] = market_id,

            ["@stock"] = json.encode(stock),

            ["@stock_prices"] = json.encode(stock_prices)

        })

        Utils.Database.execute("DELETE FROM store_categories WHERE market_id = @market_id AND category = @category", {

            ["@market_id"] = market_id,

            ["@category"] = data.category

        })

        giveMarketMoney(market_id, sell_price)

        insertBalanceHistory(market_id, 0, Utils.translate("category_sold_balance"):format(category_config.page_name), sell_price)

        TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("category_sold"))

        openUI(_source, market_id, true)

    end)

end)

local user_theme_cache = {}

RegisterServerEvent("stores:changeTheme")

AddEventHandler("stores:changeTheme", function(market_id, data)

    local _source = source

    user_theme_cache[_source] = nil

    Wrapper(_source, market_id, "changeTheme", false, function(user_id)

        local theme_res = Utils.Database.fetchAll("SELECT * FROM `store_users_theme` WHERE user_id = @user_id", {

            ["@user_id"] = user_id

        })

        if theme_res[1] == nil then

            Utils.Database.execute("INSERT INTO `store_users_theme` (user_id,dark_theme) VALUES (@user_id,@dark_theme);", {

                ["@dark_theme"] = data.dark_theme,

                ["@user_id"] = user_id

            })

        else

            Utils.Database.execute("UPDATE `store_users_theme` SET dark_theme = @dark_theme WHERE user_id = @user_id", {

                ["@dark_theme"] = data.dark_theme,

                ["@user_id"] = user_id

            })

        end

    end)

end)

RegisterServerEvent("stores:sellMarket")

AddEventHandler("stores:sellMarket", function(market_id, data)

    local _source = source

    Wrapper(_source, market_id, "sellMarket", true, function(user_id)

        local business = Utils.Database.fetchAll("SELECT user_id FROM `store_business` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        if business[1].user_id == user_id then

            TriggerClientEvent("stores:closeUI", _source)

            deleteStore(market_id)

            Utils.Framework.giveAccountMoney(_source, getConfigMarketLocation(market_id).sell_price, getAccount(market_id, "store"))

            TriggerClientEvent("stores:Notify", _source, "success", Utils.translate("store_sold"))

            local blip = getConfigMarketType(market_id).blips

            TriggerClientEvent("stores:updateBlip", -1, market_id, blip.name, blip.color, blip.id)

            local date_str = "\n\n[" .. Utils.translate("logs_date") .. "]: %d/%m/%Y [" .. Utils.translate("logs_hour") .. "]: %H:%M:%S"

            Utils.Webhook.sendWebhookMessage(WebhookURL, Utils.translate("logs_close"):format(market_id, Utils.Framework.getPlayerIdLog(_source) .. os.date(date_str)))

        else

            TriggerClientEvent("stores:Notify", _source, "error", Utils.translate("sell_error"))

        end

    end)

end)

function deleteStore(market_id)

    if Config.trucker_logistics.enable then

        local jobs = Utils.Database.fetchAll("SELECT * FROM `store_jobs` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        for _, job in pairs(jobs) do

            deleteJob(market_id, job.id)

        end

    end

    Utils.Database.execute("DELETE FROM `store_business` WHERE market_id = @market_id;", {["@market_id"] = market_id})

    Utils.Database.execute("DELETE FROM `store_balance` WHERE market_id = @market_id;", {["@market_id"] = market_id})

    Utils.Database.execute("DELETE FROM `store_jobs` WHERE market_id = @market_id;", {["@market_id"] = market_id})

    Utils.Database.execute("DELETE FROM `store_employees` WHERE market_id = @market_id;", {["@market_id"] = market_id})

    Utils.Database.execute("DELETE FROM `store_categories` WHERE market_id = @market_id;", {["@market_id"] = market_id})

end

function getDefaultCategories(market_id)

    local categories = {}

    for _, def_cat in pairs(getConfigMarketType(market_id).default_categories) do

        for cat_key, cat_data in pairs(Config.market_categories) do

            if cat_key == def_cat then

                categories[cat_key] = cat_data

            end

        end

    end

    return categories

end

function getDefaultItems(market_id)

    local items = {}

    for _, def_cat in pairs(getConfigMarketType(market_id).default_categories) do

        for item_key, item_data in pairs(getMarketCategory(def_cat).items) do

            items[item_key] = item_data

        end

    end

    return items

end

function getItemsCount(market_id)

    local count = 0

    local categories = Utils.Database.fetchAll("SELECT * FROM `store_categories` WHERE market_id = @market_id", {

        ["@market_id"] = market_id

    })

    if categories and categories[1] then

        for _, cat in pairs(categories) do

            count = count + Utils.Table.tableLength(getMarketCategory(cat.category).items)

        end

    end

    return count

end

function getItems(market_id)

    local categories = Utils.Database.fetchAll("SELECT * FROM `store_categories` WHERE market_id = @market_id", {

        ["@market_id"] = market_id

    })

    local items = {}

    if categories and categories[1] then

        for _, cat in ipairs(categories) do

            for item_key, item_data in pairs(getMarketCategory(cat.category).items) do

                items[item_key] = item_data

            end

        end

    end

    return items

end

function getItem(market_id, item_id)

    local categories = Utils.Database.fetchAll("SELECT * FROM `store_categories` WHERE market_id = @market_id", {

        ["@market_id"] = market_id

    })

    if categories and categories[1] then

        for _, cat in ipairs(categories) do

            local cat_items = getMarketCategory(cat.category).items

            if cat_items[item_id] then

                return cat_items[item_id]

            end

        end

    end

    error(string.format("Item %s not found in the store %s category config", item_id, market_id))

end

function getItemNoKey(item_id)

    for _, cat_data in pairs(Config.market_categories) do

        if cat_data.items[item_id] then

            return cat_data.items[item_id]

        end

    end

    error(string.format("Item %s not found in config", item_id))

end

function formatItemAmounts(items)

    local formatted = ""

    for idx, item in pairs(items) do

        local amount = tonumber(item.amount) or 0

        formatted = formatted .. amount .. "x " .. item.name

        if idx < #items then

            formatted = formatted .. ", "

        end

    end

    return formatted

end

function isOwner(market_id, user_id)

    local business = Utils.Database.fetchAll("SELECT 1 FROM `store_business` WHERE market_id = @market_id AND user_id = @user_id", {

        ["@market_id"] = market_id,

        ["@user_id"] = user_id

    })

    return business and business[1] and true or false

end

function hasRole(market_id, user_id, action)

    local role_level = Config.roles_permissions.functions[action]

    if not role_level then

        print("^8[" .. GetCurrentResourceName() .. "] Role '" .. action .. "' not found in Config.roles_permissions^7")

        return false

    end

    local has_perm = Utils.Database.fetchAll("SELECT 1 FROM `store_employees` WHERE market_id = @market_id AND user_id = @user_id AND role >= @role", {

        ["@market_id"] = market_id,

        ["@user_id"] = user_id,

        ["@role"] = role_level

    })

    return has_perm and has_perm[1] and true or false

end

function giveMarketMoney(market_id, amount)

    Utils.Database.execute("UPDATE `store_business` SET money = money + @amount WHERE market_id = @market_id", {

        ["@amount"] = amount,

        ["@market_id"] = market_id

    })

end

function tryGetMarketMoney(market_id, amount)

    local business = Utils.Database.fetchAll("SELECT money FROM `store_business` WHERE market_id = @market_id", {

        ["@market_id"] = market_id

    })

    if tonumber(business[1].money) >= amount then

        Utils.Database.execute("UPDATE `store_business` SET money = @money, total_money_spent = total_money_spent + @amount WHERE market_id = @market_id", {

            ["@money"] = tonumber(business[1].money) - amount,

            ["@amount"] = amount,

            ["@market_id"] = market_id

        })

        return true

    else

        return false

    end

end

function getStockAmount(stock_json)

    local stock = json.decode(stock_json)

    local total = 0

    for _, amount in pairs(stock) do

        total = total + amount

    end

    return total

end

function insertBalanceHistory(market_id, income, title, amount)

    if #title > 200 then

        title = string.sub(title, 1, 200)

    end

    Utils.Database.executeAsync("INSERT INTO `store_balance` (market_id,income,title,amount,date) VALUES (@market_id,@income,@title,@amount,@date)", {

        ["@market_id"] = market_id,

        ["@income"] = income,

        ["@title"] = title,

        ["@amount"] = amount,

        ["@date"] = os.time()

    })

end

function getAccount(market_id, account_type)

    local market_location = getConfigMarketLocation(market_id)

    if account_type == "item" then

        if market_location.account then

            return market_location.account.item

        else

            return "bank"

        end

    elseif account_type == "store" then

        if market_location.account then

            return market_location.account.store

        else

            return "bank"

        end

    end

end

local CachedConfig = {

    market_locations = {},

    market_categories = {},

    market_types = {}

}

function getConfigMarketLocation(market_id)

    if CachedConfig.market_locations[market_id] then

        return Config.market_locations[market_id]

    end

    assert(Config.market_locations, "^3The config '^1Config.market_locations^3' entry is missing. Please re-add it in the config")

    assert(market_id, "^3The parameter '^1market_id^3' is missing. Please provide a valid market ID")

    assert(Config.market_locations[market_id], "^3The market ID '^1" .. tostring(market_id) .. "^3' does not exist in ^1Config.market_locations^3. Please provide a valid market ID")

    local loc = Config.market_locations[market_id]

    assert(loc.buy_price, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1buy_price^3' field. Please ensure each market location has a '^1buy_price^3' field")

    assert(loc.sell_price, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1sell_price^3' field. Please ensure each market location has a '^1sell_price^3' field")

    assert(loc.coord, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1coord^3' field. Please ensure each market location has a '^1coord^3' field")

    assert(#loc.coord == 3, "^3The '^1coord^3' field for market location ID '^1" .. tostring(market_id) .. "^3' must contain three values (x, y, z). Review your config file to correct it")

    assert(loc.garage_coord, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1garage_coord^3' field. Please ensure each market location has a '^1garage_coord^3' field")

    assert(#loc.garage_coord == 4, "^3The '^1garage_coord^3' field for market location ID '^1" .. tostring(market_id) .. "^3' must contain four values (x, y, z, heading). Review your config file to correct it")

    assert(loc.truck_parking_location, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1truck_parking_location^3' field. Please ensure each market location has a '^1truck_parking_location^3' field")

    assert(#loc.truck_parking_location == 4, "^3The '^1truck_parking_location^3' field for market location ID '^1" .. tostring(market_id) .. "^3' must contain four values (x, y, z, heading). Review your config file to correct it")

    assert(loc.map_blip_coord, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1map_blip_coord^3' field. Please ensure each market location has a '^1map_blip_coord^3' field")

    assert(#loc.map_blip_coord == 3, "^3The '^1map_blip_coord^3' field for market location ID '^1" .. tostring(market_id) .. "^3' must contain three values (x, y, z). Review your config file to correct it")

    assert(loc.sell_blip_coords, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1sell_blip_coords^3' field. Please ensure each market location has a '^1sell_blip_coords^3' field")

    assert(type(loc.sell_blip_coords) == "table", "^3The '^1sell_blip_coords^3' field for market location ID '^1" .. tostring(market_id) .. "^3' must be a table. Review your config file to correct it")

    for _, coord in ipairs(loc.sell_blip_coords) do

        assert(#coord == 3, "^3Each coordinate in '^1sell_blip_coords^3' for market location ID '^1" .. tostring(market_id) .. "^3' must contain three values (x, y, z). Review your config file to correct it")

    end

    assert(loc.deliveryman_coord, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1deliveryman_coord^3' field. Please ensure each market location has a '^1deliveryman_coord^3' field")

    assert(#loc.deliveryman_coord == 3, "^3The '^1deliveryman_coord^3' field for market location ID '^1" .. tostring(market_id) .. "^3' must contain three values (x, y, z). Review your config file to correct it")

    assert(loc.type, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1type^3' field. Please ensure each market location has a '^1type^3' field")

    assert(loc.account, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have an '^1account^3' field. Please ensure each market location has an '^1account^3' field")

    assert(loc.account.item, "^3The '^1account^3' field for market location ID '^1" .. tostring(market_id) .. "^3' does not have an '^1item^3' field. Please ensure each account field has an '^1item^3' field")

    assert(type(loc.account.item) == "table", "^3The '^1item^3' field in '^1account^3' for market location ID '^1" .. tostring(market_id) .. "^3' must be a table. Review your config file to correct it")

    for _, item in ipairs(loc.account.item) do

        assert(item.icon, "^3Each '^1item^3' in '^1account^3' for market location ID '^1" .. tostring(market_id) .. "^3' must have an '^1icon^3' field. Review your config file to correct it")

        assert(item.account, "^3Each '^1item^3' in '^1account^3' for market location ID '^1" .. tostring(market_id) .. "^3' must have an '^1account^3' field. Review your config file to correct it")

    end

    assert(loc.account.store, "^3The '^1account^3' field for market location ID '^1" .. tostring(market_id) .. "^3' does not have a '^1store^3' field. Please ensure each account field has a '^1store^3' field")

    CachedConfig.market_locations[market_id] = true

    return loc

end

function getMarketCategory(category_id)

    if CachedConfig.market_categories[category_id] then

        return Config.market_categories[category_id]

    end

    assert(Config.market_categories, "^3The config '^1Config.market_categories^3' entry is missing. Please re-add it in the config")

    assert(category_id, "^3The parameter '^1category_id^3' is missing. Please provide a valid category ID")

    assert(Config.market_categories[category_id], "^3The category ID '^1" .. tostring(category_id) .. "^3' does not exist in ^1Config.market_categories^3. Please provide a valid category ID")

    local cat = Config.market_categories[category_id]

    assert(cat.category_buy_price, "^3The category ID '^1" .. tostring(category_id) .. "^3' does not contain a valid '^1category_buy_price^3'. Review your config file to add it back")

    assert(cat.category_sell_price, "^3The category ID '^1" .. tostring(category_id) .. "^3' does not contain a valid '^1category_sell_price^3'. Review your config file to add it back")

    assert(cat.items, "^3The category ID '^1" .. tostring(category_id) .. "^3' does not contain a valid '^1items^3' field. Review your config file to add it back")

    assert(type(cat.items) == "table", "^3The '^1items^3' field for category ID '^1" .. tostring(category_id) .. "^3' must be a table. Review your config file to correct it")

    for item_id, item_data in pairs(cat.items) do

        assert(item_data.name, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have a '^1name^3' field. Review your config file to add it back")

        assert(item_data.price_to_customer, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have a '^1price_to_customer^3' field. Review your config file to add it back")

        assert(item_data.price_to_customer_min, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have a '^1price_to_customer_min^3' field. Review your config file to add it back")

        assert(item_data.price_to_customer_max, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have a '^1price_to_customer_max^3' field. Review your config file to add it back")

        assert(item_data.price_to_export, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have a '^1price_to_export^3' field. Review your config file to add it back")

        assert(item_data.price_to_owner, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have a '^1price_to_owner^3' field. Review your config file to add it back")

        assert(item_data.amount_to_owner, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have an '^1amount_to_owner^3' field. Review your config file to add it back")

        assert(item_data.amount_to_delivery, "^3The item ID '^1" .. tostring(item_id) .. "^3' in category ID '^1" .. tostring(category_id) .. "^3' does not have an '^1amount_to_delivery^3' field. Review your config file to add it back")

    end

    CachedConfig.market_categories[category_id] = true

    return cat

end

function getConfigMarketType(market_id)

    if CachedConfig.market_types[market_id] then

        return Config.market_types[Config.market_locations[market_id].type]

    end

    assert(Config.market_locations, "^3The config '^1Config.market_locations^3' entry is missing. Please re-add it in the config")

    assert(Config.market_types, "^3The config '^1Config.market_types^3' entry is missing. Please re-add it in the config")

    assert(market_id, "^3The parameter '^1market_id^3' is missing. Please provide a valid market ID")

    assert(Config.market_locations[market_id], "^3The market ID '^1" .. tostring(market_id) .. "^3' does not exist in ^1Config.market_locations^3. Please provide a valid market ID")

    local loc = Config.market_locations[market_id]

    assert(loc.type, "^3The market location for ID '^1" .. tostring(market_id) .. "^3' does not have a '^1type^3' field. Please ensure each market location has a '^1type^3' field")

    local market_type = Config.market_types[loc.type]

    assert(market_type, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not exist in ^1Config.market_types^3. Please provide a valid market type")

    assert(market_type.stock_capacity, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not have a '^1stock_capacity^3' field. Please ensure each market type has a '^1stock_capacity^3' field")

    assert(market_type.upgrades, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not have an '^1upgrades^3' field. Please ensure each market type has an '^1upgrades^3' field")

    assert(type(market_type.upgrades) == "table", "^3The '^1upgrades^3' field for market type '^1" .. tostring(loc.type) .. "^3' must be a table. Review your config file to correct it")

    assert(market_type.max_employees, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not have a '^1max_employees^3' field. Please ensure each market type has a '^1max_employees^3' field")

    assert(market_type.trucks, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not have a '^1trucks^3' field. Please ensure each market type has a '^1trucks^3' field")

    assert(type(market_type.trucks) == "table", "^3The '^1trucks^3' field for market type '^1" .. tostring(loc.type) .. "^3' must be a table. Review your config file to correct it")

    assert(market_type.max_purchasable_categories, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not have a '^1max_purchasable_categories^3' field. Please ensure each market type has a '^1max_purchasable_categories^3' field")

    assert(market_type.categories, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not have a '^1categories^3' field. Please ensure each market type has a '^1categories^3' field")

    assert(type(market_type.categories) == "table", "^3The '^1categories^3' field for market type '^1" .. tostring(loc.type) .. "^3' must be a table. Review your config file to correct it")

    assert(market_type.default_categories, "^3The market type '^1" .. tostring(loc.type) .. "^3' does not have a '^1default_categories^3' field. Please ensure each market type has a '^1default_categories^3' field")

    assert(type(market_type.default_categories) == "table", "^3The '^1default_categories^3' field for market type '^1" .. tostring(loc.type) .. "^3' must be a table. Review your config file to correct it")

    CachedConfig.market_types[market_id] = true

    return market_type

end

local is_player_busy = {}

function Wrapper(source, market_id, event, requires_permission, callback)

    if not has_lc_utils then return end

    assert(source, "Source is nil at Wrapper")

    assert(market_id, "Market ID is nil at Wrapper")

    assert(event, "Event is nil at Wrapper")

    if is_player_busy[source] == nil then

        is_player_busy[source] = true

        local user_id = Utils.Framework.getPlayerId(source)

        if user_id then

            if requires_permission ~= false then

                if not isOwner(market_id, user_id) then

                    if not hasRole(market_id, user_id, event) then

                        TriggerClientEvent("stores:Notify", source, "error", Utils.translate("insufficient_permission"))

                        SetTimeout(100, function() is_player_busy[source] = nil end)

                        return

                    end

                end

            end

            callback(user_id)

        else

            print("^8[" .. GetCurrentResourceName() .. "] ^3User not found: ^1" .. (source or "nil") .. "^7")

        end

        SetTimeout(100, function()

            is_player_busy[source] = nil

        end)

    end

end

function openUI(source, market_id, update, isMarket)

    local data = { config = {} }

    local user_id = Utils.Framework.getPlayerId(source)

    if user_id then

        local business = Utils.Database.fetchAll("SELECT * FROM `store_business` WHERE market_id = @market_id", {

            ["@market_id"] = market_id

        })

        data.store_business = business[1]

        local user_theme = Utils.Database.fetchAll("SELECT * FROM `store_users_theme` WHERE user_id = @user_id", {

            ["@user_id"] = user_id

        })

        data.store_users_theme = user_theme[1]

        if data.store_users_theme == nil then

            Utils.Database.execute("INSERT INTO `store_users_theme` (user_id,dark_theme) VALUES (@user_id,@dark_theme);", {

                ["@dark_theme"] = 1,

                ["@user_id"] = user_id

            })

            data.store_users_theme = { dark_theme = 1 }

        end

        if data.store_business == nil then

            data.store_business = {

                stock = not Config.has_stock_when_unowed,

                stock_prices = false

            }

            data.market_items = getDefaultItems(market_id)

            data.config.market_categories = getDefaultCategories(market_id)

            data.store_categories = {}

            for _, default_category in pairs(getConfigMarketType(market_id).default_categories) do

                table.insert(data.store_categories, { category = default_category })

            end

        else

            data.market_items = getItems(market_id)

            local store_categories = Utils.Database.fetchAll("SELECT * FROM `store_categories` WHERE market_id = @market_id", {

                ["@market_id"] = data.store_business.market_id

            })

            data.store_categories = store_categories

            local variety = Utils.Table.tableLength(json.decode(data.store_business.stock))

            local max_variety = getItemsCount(market_id)

            if max_variety == 0 then

                data.store_business.stock_variety = 0

            else

                data.store_business.stock_variety = (100 * variety) / max_variety

            end

            data.store_business.stock_amount = getStockAmount(data.store_business.stock)

        end

        if not isMarket then

            if data.store_business and data.store_business.market_id then

                local jobs = Utils.Database.fetchAll("SELECT * FROM `store_jobs` WHERE market_id = @market_id", {

                    ["@market_id"] = data.store_business.market_id

                })

                data.store_jobs = jobs

                local balance = Utils.Database.fetchAll("SELECT * FROM `store_balance` WHERE market_id = @market_id ORDER BY id DESC LIMIT 50", {

                    ["@market_id"] = data.store_business.market_id

                })

                data.store_balance = balance

                local employees = Utils.Database.fetchAll("SELECT * FROM `store_employees` WHERE market_id = @market_id ORDER BY timer DESC", {

                    ["@market_id"] = data.store_business.market_id

                })

                data.store_employees = employees

                for _, employee in pairs(data.store_employees) do

                    employee.name = Utils.Framework.getPlayerName(employee.user_id)

                end

                local current_role = Utils.Database.fetchAll("SELECT role FROM `store_employees` WHERE market_id = @market_id AND user_id = @user_id", {

                    ["@market_id"] = data.store_business.market_id,

                    ["@user_id"] = user_id

                })

                if current_role and current_role[1] then

                    if isOwner(market_id, user_id) then

                        data.role = 4

                    else

                        data.role = current_role[1].role

                    end

                else

                    data.role = 4
                end

                if not update then

                    data.players = Utils.Framework.getOnlinePlayers()

                end

            end

        end

        data.available_money = Utils.Framework.getPlayerAccountMoney(source, getAccount(market_id, "store"))

        data.config.market_locations = Utils.Table.deepCopy(getConfigMarketLocation(market_id))

        data.config.market_types = Utils.Table.deepCopy(getConfigMarketType(market_id))

        data.config.market_categories = Utils.Table.deepCopy(Config.market_categories)

        data.config.roles_permissions = Utils.Table.deepCopy(Config.roles_permissions.ui_pages)

        data.config.disable_rename_business = Utils.Table.deepCopy(Config.disable_rename_business)

        data.config.warning = 0

        if not isMarket and data.store_business and data.store_business.market_id then

            if Config.clear_stores.active then

                local stock = json.decode(data.store_business.stock)

                local variety = Utils.Table.tableLength(stock)

                local max_variety = getItemsCount(market_id)

                local current_stock_amt = data.store_business.stock_amount

                local capacity = getConfigMarketType(market_id).stock_capacity * (Config.clear_stores.min_stock_amount / 100)

                if current_stock_amt < capacity then

                    data.config.warning = 1

                elseif variety < (max_variety * (Config.clear_stores.min_stock_variety / 100)) then

                    data.config.warning = 2

                else

                    Utils.Database.execute("UPDATE `store_business` SET timer = @timer WHERE market_id = @market_id", {

                        ["@timer"] = os.time(),

                        ["@market_id"] = market_id

                    })

                end

            end

        end

        TriggerClientEvent("stores:open", source, data, update or false, isMarket or false)

    end

end

Citizen.CreateThread(function()

    Wait(1000)

    assert(Config.market_locations, "^3You have errors in your config file, consider fixing it or redownload the original config.^7")

    assert(GetResourceState("lc_utils") == "started", "^3The '^1lc_utils^3' file is missing. Please refer to the documentation for installation instructions: ^7https://docs.lixeirocharmoso.com/owned_stores/installation^7")

    if Utils.Math.checkIfCurrentVersionisOutdated(currentVersionStr, Utils.Version) then

        has_lc_utils = false

        error("^3The script requires 'lc_utils' in version ^1" .. currentVersionStr .. "^3, but you currently have version ^1" .. Utils.Version .. "^3. Please update your 'lc_utils' script to the latest version: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip^7")

    end

    Utils.loadLanguageFile(Lang)

    runCreateTableQueries()

    Utils.Database.execute("UPDATE `store_jobs` SET progress = 0", {})

    local checks = {

        { config_path = { "group_map_blips" }, default_value = true },

        { config_path = { "charge_import_money_before" }, default_value = true }

    }

    Config = Utils.validateConfig(Config, checks)

    Wait(1000)

    local validation_tables = {

        store_business = { "market_id", "user_id", "stock", "stock_prices", "stock_upgrade", "truck_upgrade", "relationship_upgrade", "money", "total_money_earned", "total_money_spent", "goods_bought", "distance_traveled", "total_visits", "customers", "market_name", "market_color", "market_blip", "timer" },

        store_balance = { "id", "market_id", "income", "title", "amount", "date", "hidden" },

        store_jobs = { "id", "market_id", "name", "reward", "product", "amount", "progress", "trucker_contract_id" },

        store_employees = { "market_id", "user_id", "jobs_done", "role", "timer" },

        store_categories = { "id", "market_id", "category" },

        store_users_theme = { "user_id", "dark_theme" }

    }

    local query_fixes = {

        store_jobs = { trucker_contract_id = "ALTER TABLE `store_jobs` ADD COLUMN `trucker_contract_id` INT UNSIGNED NULL DEFAULT NULL AFTER `progress`;" }

    }

    Utils.Database.validateTableColumns(validation_tables, query_fixes, {})

    Utils.validateFunctions({ "beforeHireEmployee", "afterHireEmployee" }, "server_utils.lua")

    checkIfFrameworkWasLoaded()

    checkScriptName()

    searchForErrorsInConfig()

    searchForDataIssuesInDatabase()

end)

function checkIfFrameworkWasLoaded()

    assert(Utils.Framework.getPlayerId, "^3The framework wasn't loaded in the '^1lc_utils^3' resource. Please check if the '^1Config.framework^3' is correctly set to your framework, and make sure there are no errors in your file. For more information, refer to the documentation at '^7https://docs.lixeirocharmoso.com/^3'.^7")

end

function checkScriptName()

    assert(GetCurrentResourceName() == "lc_stores", "^3The script name does not match the expected resource name. Please ensure that the current resource name is set to '^1lc_stores^7'.")

end

function searchForErrorsInConfig()

    for _, location in pairs(Config.market_locations) do

        if not Config.market_types[location.type] then

            print("^1Error in your config:^3 Type '^1" .. location.type .. "^3' is not registered in Config.market_types^7")

        end

    end

end

function searchForDataIssuesInDatabase()

    if Config.trucker_logistics.enable then

        Utils.Database.execute("UPDATE trucker_available_contracts SET external_data = REPLACE(external_data, 'qb_stores', 'lc_stores') WHERE external_data LIKE '%qb_stores%';")

        Utils.Database.execute("UPDATE trucker_available_contracts SET external_data = REPLACE(external_data, 'esx_stores', 'lc_stores') WHERE external_data LIKE '%esx_stores%';")

    end

    local config_markets = {}

    for market_id, _ in pairs(Config.market_locations) do

        table.insert(config_markets, market_id)

    end

    local missing_markets = Utils.Database.fetchAll(string.format("SELECT market_id FROM `store_business` WHERE market_id NOT IN ('%s')", table.concat(config_markets, "','")), {})

    if #missing_markets > 0 then

        print("^8[" .. GetCurrentResourceName() .. "] DATABASE ISSUES:^3 The following issues were found in your database:^7")

        for _, market in pairs(missing_markets) do

            print(string.format("^8[%s]^3 Store ^1%s^3 is in your ^1store_business^3 table but not in your config.^7", GetCurrentResourceName(), market.market_id))

        end

        print("^8[" .. GetCurrentResourceName() .. "] HOW TO RESOLVE ISSUES:^3 You can add missing data to the config or manually remove them from your database.^7")

    end

end

function runCreateTableQueries()

    if Config.create_table ~= false then

        Utils.Database.execute([[

            CREATE TABLE IF NOT EXISTS `store_business` (

                `market_id` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',

                `user_id` VARCHAR(50) NOT NULL,

                `stock` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',

                `stock_prices` LONGTEXT NOT NULL COLLATE 'utf8mb4_general_ci',

                `stock_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

                `truck_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

                `relationship_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

                `money` INT(10) UNSIGNED NOT NULL DEFAULT '0',

                `total_money_earned` INT(10) UNSIGNED NOT NULL DEFAULT '0',

                `total_money_spent` INT(10) UNSIGNED NOT NULL DEFAULT '0',

                `goods_bought` INT(10) UNSIGNED NOT NULL DEFAULT '0',

                `distance_traveled` DOUBLE UNSIGNED NOT NULL DEFAULT '0',

                `total_visits` INT(10) UNSIGNED NOT NULL DEFAULT '0',

                `customers` INT(10) UNSIGNED NOT NULL DEFAULT '0',

                `market_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',

                `market_color` INT(10) UNSIGNED NULL DEFAULT NULL,

                `market_blip` INT(10) UNSIGNED NULL DEFAULT NULL,

                `timer` INT(10) UNSIGNED NOT NULL,

                PRIMARY KEY (`market_id`) USING BTREE

            )

            COLLATE='utf8mb4_general_ci'

            ENGINE=InnoDB

            ;

        ]])

        Utils.Database.execute([[

            CREATE TABLE IF NOT EXISTS `store_balance` (

                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,

                `market_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

                `income` TINYINT(3) UNSIGNED NOT NULL,

                `title` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',

                `amount` INT(10) UNSIGNED NOT NULL,

                `date` INT(10) UNSIGNED NOT NULL,

                `hidden` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

                PRIMARY KEY (`id`) USING BTREE

            )

            COLLATE='utf8mb4_general_ci'

            ENGINE=InnoDB

            ;

        ]])

        Utils.Database.execute([[

            CREATE TABLE IF NOT EXISTS `store_categories` (

                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,

                `market_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

                `category` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

                PRIMARY KEY (`id`) USING BTREE

            )

            COLLATE='utf8mb4_general_ci'

            ENGINE=InnoDB

            ;

        ]])

        Utils.Database.execute([[

            CREATE TABLE IF NOT EXISTS `store_jobs` (

                `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,

                `market_id` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',

                `name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

                `reward` INT(10) UNSIGNED NOT NULL DEFAULT '0',

                `product` VARCHAR(50) NOT NULL DEFAULT '0' COLLATE 'utf8mb4_general_ci',

                `amount` INT(11) NOT NULL DEFAULT '0',

                `progress` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

                `trucker_contract_id` INT(10) UNSIGNED NULL DEFAULT NULL,

                PRIMARY KEY (`id`) USING BTREE

            )

            COLLATE='utf8mb4_general_ci'

            ENGINE=InnoDB

            ;

        ]])

        Utils.Database.execute([[

            CREATE TABLE IF NOT EXISTS `store_employees` (

                `market_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

                `user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

                `jobs_done` INT(11) UNSIGNED NOT NULL DEFAULT '0',

                `role` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

                `timer` INT(11) UNSIGNED NOT NULL,

                PRIMARY KEY (`market_id`, `user_id`) USING BTREE

            )

            COLLATE='utf8mb4_general_ci'

            ENGINE=InnoDB

            ;

        ]])

        Utils.Database.execute([[

            CREATE TABLE IF NOT EXISTS `store_users_theme` (

                `user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',

                `dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',

                PRIMARY KEY (`user_id`) USING BTREE

            )

            COLLATE='utf8_general_ci'

            ENGINE=InnoDB

            ;

        ]])

    end

end


--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

--             
-- 
-- 
--                                                                          
--                                                                          
-- 
--             

