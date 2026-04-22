






local VERSION     = "5.0.4"

local SUBVERSION  = ""

local UTILS_MIN   = "1.2.0"
local SCRIPT_ID   = 4
local api_response       = {}

local utils_outdated     = false
local config_valid       = true
local activeSessions = {}

local wrapperLock = {}

if not Utils then

    Utils = exports["lc_utils"]:GetUtils()

end

Citizen.CreateThread(function()

    Wait(2000)

    print(("^2[%s] Authenticated! Support discord: https://discord.gg/U5YDgbh^7 ^3[v%s%s] ^7")

        :format(GetCurrentResourceName(), VERSION, SUBVERSION))

    local attempts    = 0

    local verified    = false

    local apiUrl      = ("http://projetocharmoso.com:3000/api/check-version-v2?script=%d&version=%s")

                        :format(SCRIPT_ID, VERSION)

    while not verified do

        attempts = attempts + 1

        PerformHttpRequest(apiUrl, function(status, body)

            if status == 200 and body then

                verified       = true

                api_response   = json.decode(body)

                if api_response.has_update then

                    print(("^4[%s] An update is available, download it in your keymaster^7 ^3[v%s]^7")

                        :format(GetCurrentResourceName(), api_response.latest_version))

                    if api_response.update_message then

                        print("^4" .. api_response.update_message .. "^7")

                    else

                        print(("^4[%s] For the complete changelog, visit our Discord: https://discord.gg/U5YDgbh^7")

                            :format(GetCurrentResourceName()))

                    end

                end

            end

        end, "GET", "", {})

        if not verified and attempts > 5 then break end

        Wait(10000)

    end

end)

AddEventHandler("playerDropped", function()

    local src = source

    local session = activeSessions[src]

    if session and session.deliveryman_job_data then

        Utils.Database.execute(

            "UPDATE `gas_station_jobs` SET progress = 0 WHERE id = @id",

            { ["@id"] = session.deliveryman_job_data.id }

        )

    end

    activeSessions[src] = nil

end)

local function getFuelColumn(fuelType)

    if fuelType == "regular" then

        return "stock"

    end

    return "stock_" .. fuelType

end

local function resolveUpgradeColumn(upgradeId)

    if type(upgradeId) ~= "string" then return nil end

    if upgradeId == "stock" or upgradeId == "truck" or upgradeId == "relationship" then

        return upgradeId .. "_upgrade"

    end

    return nil

end

function isFuelTypeValid(fuelType)

    return Utils.Table.contains(

        { "regular", "plus", "premium", "diesel", "electricfast", "electricnormal" },

        fuelType

    )

end

function isFuelTypeElectric(fuelType)

    return Utils.Table.contains({ "electricnormal", "electricfast" }, fuelType)

end

function isFuelTypePetrol(fuelType)

    return Utils.Table.contains({ "regular", "plus", "premium", "diesel" }, fuelType)

end

function get_formatted_time()

    local stamp  = os.date("%Y-%m-%d %H:%M:%S", os.time())

    local millis = string.format("%.3f", os.clock()):sub(-3)

    return stamp .. "." .. millis

end

local function buildWebhookTimestamp()

    local dateLbl = Utils.translate("logs_date")

    local hourLbl = Utils.translate("logs_hour")

    local fmt     = "\n\n[" .. dateLbl .. "]: %d/%m/%Y [" .. hourLbl .. "]: %H:%M:%S"

    return os.date(fmt)

end

function giveMarketMoney(stationId, amount)

    Utils.Database.execute(

        "UPDATE `gas_station_business` SET money = money + @amount WHERE gas_station_id = @gas_station_id",

        { ["@amount"] = amount, ["@gas_station_id"] = stationId }

    )

end

function tryGetMarketMoney(stationId, amount)

    local rows    = Utils.Database.fetchAll(

        "SELECT money FROM `gas_station_business` WHERE gas_station_id = @gas_station_id",

        { ["@gas_station_id"] = stationId }

    )

    local current = tonumber(rows[1].money)

    if amount <= current then

        Utils.Database.execute(

            "UPDATE `gas_station_business` SET money = @money, total_money_spent = total_money_spent + @amount WHERE gas_station_id = @gas_station_id",

            {

                ["@money"]          = current - amount,

                ["@amount"]         = amount,

                ["@gas_station_id"] = stationId,

            }

        )

        return true

    end

    return false

end

function insertBalanceHistory(stationId, income, title, amount)

    Utils.Database.execute(

        "INSERT INTO `gas_station_balance` (gas_station_id,income,title,amount,date) VALUES (@gas_station_id,@income,@title,@amount,@date)",

        {

            ["@gas_station_id"] = stationId,

            ["@income"]         = income,

            ["@title"]          = title,

            ["@amount"]         = amount,

            ["@date"]           = os.time(),

        }

    )

end

function isOwner(stationId, userId)

    local rows = Utils.Database.fetchAll(

        "SELECT 1 FROM `gas_station_business` WHERE gas_station_id = @gas_station_id AND user_id = @user_id",

        { ["@gas_station_id"] = stationId, ["@user_id"] = userId }

    )

    return rows and rows[1] ~= nil

end

function hasRole(stationId, userId, functionName)

    local minRole = Config.roles_permissions.functions[functionName]

    if not minRole then

        print(("^8[%s] Role '%s' not found in Config.roles_permissions^7")

            :format(GetCurrentResourceName(), functionName))

        return false

    end

    local rows = Utils.Database.fetchAll(

        "SELECT 1 FROM `gas_station_employees` WHERE gas_station_id = @gas_station_id AND user_id = @user_id AND role >= @role",

        {

            ["@gas_station_id"] = stationId,

            ["@user_id"]        = userId,

            ["@role"]           = minRole,

        }

    )

    return rows and rows[1] ~= nil

end

function Wrapper(src, stationId, eventName, requiresAuth, callback)

    if utils_outdated then

        if utils_outdated then

            TriggerClientEvent("gas_station:Notify", src, "error",

                ("The script requires 'lc_utils' in version %s, but you currently have version %s. "

                 .. "Please update your 'lc_utils' script: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip")

                :format(UTILS_MIN, Utils.Version))

        end

        return

    end

    assert(src,       "Source is nil at Wrapper")

    assert(stationId, "Key is nil at Wrapper")

    assert(eventName, "Event is nil at Wrapper")

    if wrapperLock[src] ~= nil then return end

    wrapperLock[src] = true

    local playerId = Utils.Framework.getPlayerId(src)

    if playerId then

        local permitted = true

        if requiresAuth ~= false then

            permitted = isOwner(stationId, playerId)

            if not permitted then

                permitted = hasRole(stationId, playerId, eventName)

            end

        end

        if permitted then

            callback(playerId)

        else

            TriggerClientEvent("gas_station:Notify", src, "error",

                Utils.translate("insufficient_permission"))

        end

    else

        print(("^8[%s] ^3User not found: ^1%s^7"):format(GetCurrentResourceName(), tostring(src)))

    end

    SetTimeout(100, function()

        wrapperLock[src] = nil

    end)

end

local function notify(src, notifyType, key, ...)

    local msg = Utils.translate(key)

    if type(msg) == "string" then

        msg = msg:format(...)

    end

    TriggerClientEvent("gas_station:Notify", src, notifyType, msg)

end

function openUI(src, stationId, isRefresh)

    local playerId = Utils.Framework.getPlayerId(src)

    if not playerId then return end

    local data = {}

    data.gas_station_business = Utils.Database.fetchAll(

        "SELECT * FROM `gas_station_business` WHERE gas_station_id = @gas_station_id",

        { ["@gas_station_id"] = stationId }

    )[1]

    local themeRows = Utils.Database.fetchAll(

        "SELECT * FROM `gas_station_users_theme` WHERE user_id = @user_id",

        { ["@user_id"] = playerId }

    )

    if themeRows[1] then

        data.gas_station_users_theme = themeRows[1]

    else

        Utils.Database.execute(

            "INSERT INTO `gas_station_users_theme` (user_id,dark_theme) VALUES (@user_id,@dark_theme);",

            { ["@dark_theme"] = 1, ["@user_id"] = playerId }

        )

        data.gas_station_users_theme = { dark_theme = 1 }

    end

    local gsId = data.gas_station_business.gas_station_id

    data.gas_station_jobs = Utils.Database.fetchAll(

        "SELECT * FROM `gas_station_jobs` WHERE gas_station_id = @gas_station_id",

        { ["@gas_station_id"] = gsId }

    )

    data.gas_station_balance = Utils.Database.fetchAll(

        "SELECT * FROM `gas_station_balance` WHERE gas_station_id = @gas_station_id ORDER BY id DESC LIMIT 50",

        { ["@gas_station_id"] = gsId }

    )

    data.gas_station_employees = Utils.Database.fetchAll(

        "SELECT * FROM `gas_station_employees` WHERE gas_station_id = @gas_station_id ORDER BY timer DESC",

        { ["@gas_station_id"] = gsId }

    )

    for _, emp in pairs(data.gas_station_employees) do

        emp.name = Utils.Framework.getPlayerName(emp.user_id)

    end

    local roleRows = Utils.Database.fetchAll(

        "SELECT role FROM `gas_station_employees` WHERE gas_station_id = @gas_station_id AND user_id = @user_id",

        { ["@gas_station_id"] = gsId, ["@user_id"] = playerId }

    )

    if roleRows and roleRows[1] then

        data.role = isOwner(stationId, playerId) and 4 or roleRows[1].role

    else

        data.role = 4

    end

    if not isRefresh then

        data.players = Utils.Framework.getOnlinePlayers()

    end

    local accountType = Config.gas_station_locations[stationId].account or "bank"

    data.available_money = Utils.Framework.getPlayerAccountMoney(src, accountType)

    local stationType = Config.gas_station_locations[stationId].type

    data.config = {

        gas_station_locations   = Utils.Table.deepCopy(Config.gas_station_locations[stationId]),

        gas_station_types       = Utils.Table.deepCopy(Config.gas_station_types[stationType]),

        roles_permissions       = Utils.Table.deepCopy(Config.roles_permissions.ui_pages),

        disable_rename_business = Utils.Table.deepCopy(Config.disable_rename_business),

        enable_different_fuels  = Utils.Table.deepCopy(Config.enable_different_fuels),

        warning                 = 0,

    }

    local biz        = data.gas_station_business

    local fuelDiv    = 1

    local totalStock = biz.stock

    if Config.enable_different_fuels then

        fuelDiv    = 4

        totalStock = biz.stock + biz.stock_plus + biz.stock_premium + biz.stock_diesel

    end

    local stTypeCfg = Config.gas_station_types[stationType]

    local threshold = stTypeCfg.stock_capacity * (Config.clear_gas_stations.min_stock_amount / 100) * fuelDiv

    if totalStock < threshold then

        data.config.warning = 1

    else

        Utils.Database.execute(

            "UPDATE `gas_station_business` SET timer = @timer WHERE gas_station_id = @gas_station_id",

            { timer = os.time(), ["@gas_station_id"] = stationId }

        )

    end

    TriggerClientEvent("gas_station:open", src, data, isRefresh)

end

RegisterServerEvent("gas_station:getData")

AddEventHandler("gas_station:getData", function(stationId)

    local src = source

    Wrapper(src, stationId, "getData", false, function(playerId)

        local ownerRow = Utils.Database.fetchAll(

            "SELECT user_id FROM `gas_station_business` WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1]

        if ownerRow then

            if ownerRow.user_id == playerId then

                openUI(src, stationId, false)

            else

                local empRow = Utils.Database.fetchAll(

                    "SELECT role FROM `gas_station_employees` WHERE gas_station_id = @gas_station_id AND user_id = @user_id",

                    { ["@gas_station_id"] = stationId, ["@user_id"] = playerId }

                )[1]

                if empRow then openUI(src, stationId, false)

                else notify(src, "error", "already_has_owner") end

            end

        else

            local ownedRows = Utils.Database.fetchAll(

                "SELECT gas_station_id FROM `gas_station_business` WHERE user_id = @user_id",

                { ["@user_id"] = playerId }

            )

            if ownedRows and ownedRows[1] then

                if #ownedRows >= Config.max_stations_per_player then

                    notify(src, "error", "already_has_business")

                end

            else

                TriggerClientEvent("gas_station:openRequest", src,

                    Config.gas_station_locations[stationId].buy_price)

            end

        end

    end)

end)

RegisterServerEvent("gas_station:buyMarket")

AddEventHandler("gas_station:buyMarket", function(stationId, permissionKey)

    local src = source

    Wrapper(src, stationId, permissionKey, false, function(playerId)

        local locCfg = Config.gas_station_locations[stationId]

        local price  = locCfg.buy_price

        if not beforeBuyGasStation(src, stationId, price) then return end

        TriggerClientEvent("gas_station:closeUI", src)

        local account = locCfg.account or "bank"

        if Utils.Framework.tryRemoveAccountMoney(src, price, account) then

            Utils.Database.execute(

                "INSERT INTO `gas_station_business` (user_id,gas_station_id,stock,timer) VALUES (@user_id,@gas_station_id,@stock,@timer);",

                { ["@gas_station_id"] = stationId, ["@user_id"] = playerId,

                  ["@stock"] = 0, ["@timer"] = os.time() }

            )

            notify(src, "success", "businnes_bougth")

            Utils.Webhook.sendWebhookMessage(WebhookURL,

                Utils.translate("logs_bought"):format(

                    stationId,

                    Utils.Framework.getPlayerIdLog(src) .. buildWebhookTimestamp()

                )

            )

            afterBuyGasStation(src, stationId, price)

        else

            TriggerClientEvent("gas_station:Notify", src, "error",

                Utils.translate("insufficient_funds_store"):format(price))

        end

    end)

end)

RegisterServerEvent("gas_station:loadJobData")

AddEventHandler("gas_station:loadJobData", function(stationId)

    local src = source

    Wrapper(src, stationId, "loadJobData", false, function(playerId)

        local job = Utils.Database.fetchAll(

            "SELECT id,name,reward FROM gas_station_jobs WHERE gas_station_id = @gas_station_id AND progress = 0 ORDER BY id ASC",

            { ["@gas_station_id"] = stationId }

        )[1]

        if not job then notify(src, "error", "no_available_jobs") end

        local ownerRow = Utils.Database.fetchAll(

            "SELECT user_id FROM gas_station_business WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1]

        if ownerRow and ownerRow.user_id == playerId then

            notify(src, "error", "cannot_do_own_job")

            job = nil

        end

        TriggerClientEvent("gas_station:setJobData", src, stationId, job)

    end)

end)

RegisterServerEvent("gas_station:startDeliverymanJob")

AddEventHandler("gas_station:startDeliverymanJob", function(stationId, jobId)

    local src = source

    Wrapper(src, stationId, "startDeliverymanJob", false, function()

        if activeSessions[src] ~= nil then

            notify(src, "error", "already_has_job"); return

        end

        local jobRow = Utils.Database.fetchAll(

            "SELECT * FROM gas_station_jobs WHERE id = @id ORDER BY id ASC",

            { ["@id"] = jobId }

        )[1]

        if jobRow.progress == 0 then

            Utils.Database.execute(

                "UPDATE `gas_station_jobs` SET progress = 1 WHERE id = @id",

                { ["@id"] = jobId }

            )

            activeSessions[src] = {

                deliveryman_job_data = jobRow,

                job_data = { amount = jobRow.amount, fuel_type = jobRow.fuel_type },

            }

            TriggerClientEvent("gas_station:startContract", src, 0, 1, 1)

        else

            TriggerClientEvent("gas_station:setJobData", src, stationId, nil)

            notify(src, "error", "job_already_in_progress")

        end

    end)

end)

RegisterServerEvent("gas_station:failed")

AddEventHandler("gas_station:failed", function()

    local src     = source

    local session = activeSessions[src]

    if session and session.deliveryman_job_data then

        Utils.Database.execute(

            "UPDATE `gas_station_jobs` SET progress = 0 WHERE id = @id",

            { ["@id"] = session.deliveryman_job_data.id }

        )

    end

    activeSessions[src] = nil

end)

RegisterServerEvent("gas_station:startContract")

AddEventHandler("gas_station:startContract", function(stationId, permKey, contractData)

    local src       = source

    local eventName = (contractData.type == 1) and "startContractImport" or "startContractExport"

    Wrapper(src, stationId, eventName, true, function(playerId)

        local fuelType = contractData.fuel_type

        if not isFuelTypePetrol(fuelType) then

            print("Invalid fuel type to start contract: " .. tostring(fuelType)); return

        end

        if activeSessions[src] ~= nil then

            notify(src, "error", "already_has_job"); return

        end

        local fuelCol   = getFuelColumn(fuelType)

        contractData.ressuply_id = contractData.ressuply_id + 1

        local supplyId  = contractData.ressuply_id

        local stType    = Config.gas_station_locations[stationId].type

        local stTypeCfg = Config.gas_station_types[stType]

        local dbRow = Utils.Database.fetchAll(

            ("SELECT truck_upgrade, relationship_upgrade, %s as stock FROM `gas_station_business` WHERE gas_station_id = @gas_station_id"):format(fuelCol),

            { ["@gas_station_id"] = stationId }

        )[1]

        local supplyData = stTypeCfg.ressuply[supplyId]

        if dbRow.truck_upgrade < supplyData.truck_level then

            notify(src, "error", "upgrade_your_truck"); return

        end

        local baseLiters  = supplyData.liters

        local truckBonus  = math.floor(baseLiters * (stTypeCfg.upgrades.truck.level_reward[dbRow.truck_upgrade] / 100))

        local totalLiters = baseLiters + truckBonus

        if eventName == "startContractImport" then

            local ppl  = supplyData.price_per_liter_to_import[fuelType]

            if not ppl then print("Missing import price for: " .. tostring(fuelType)); return end

            local rawCost     = ppl * totalLiters

            local relDiscount = math.floor(rawCost * stTypeCfg.upgrades.relationship.level_reward[dbRow.relationship_upgrade] / 100)

            local finalCost   = rawCost - relDiscount

            if not beforeStartContractImport(src, stationId, finalCost, totalLiters) then return end

            if tryGetMarketMoney(stationId, finalCost) then

                activeSessions[src] = { job_data = { amount = totalLiters, fuel_type = fuelType } }

                insertBalanceHistory(stationId, 1,

                    Utils.translate("buy_products_expenses"):format(supplyData.name, totalLiters), finalCost)

                TriggerClientEvent("gas_station:startContract", src, dbRow.truck_upgrade, supplyId, contractData.type)

            else

                notify(src, "error", "insufficient_funds")

            end

        else

            if not beforeStartContractExport(src, stationId, totalLiters) then return end

            local currentStock = tonumber(dbRow.stock)

            if totalLiters <= currentStock then

                activeSessions[src] = { job_data = { amount = totalLiters, fuel_type = fuelType } }

                Utils.Database.execute(

                    ("UPDATE `gas_station_business` SET %s = @stock WHERE gas_station_id = @gas_station_id"):format(fuelCol),

                    { ["@gas_station_id"] = stationId, ["@stock"] = currentStock - totalLiters }

                )

                TriggerClientEvent("gas_station:startContract", src, dbRow.truck_upgrade, supplyId, contractData.type)

            else

                notify(src, "error", "not_enought_stock")

            end

        end

    end)

end)

function finishContract(playerSrc, stationId, amount, fuelType, contractType, distance, supplyId, deliveryJobData)

    local playerId = Utils.Framework.getPlayerId(playerSrc)

    if not isFuelTypeValid(fuelType) then print("Invalid fuel type on finishContract: " .. tostring(fuelType)); return end

    local fuelCol = getFuelColumn(fuelType)

    if not stationId then print("Invalid key on finishContract: nil"); return end

    if not amount   then print("Invalid amount on finishContract: nil"); return end

    local locCfg = Config.gas_station_locations[stationId]

    if not locCfg then print("Invalid gas_station_locations key: " .. tostring(stationId)); return end

    if not locCfg.type then print("Type nil in config for: " .. stationId); return end

    local stTypeCfg = Config.gas_station_types[locCfg.type]

    if not stTypeCfg then print("Invalid gas_station_types key: " .. tostring(locCfg.type)); return end

    local dbRow = Utils.Database.fetchAll(

        ("SELECT %s as stock, truck_upgrade, stock_upgrade FROM `gas_station_business` WHERE gas_station_id = @gas_station_id"):format(fuelCol),

        { ["@gas_station_id"] = stationId }

    )[1]

    local currentStock = dbRow.stock

    if deliveryJobData then

        distance = 0

        amount   = tonumber(deliveryJobData.amount) or 0

        local reward = tonumber(deliveryJobData.reward) or 0

        Utils.Framework.giveAccountMoney(playerSrc, reward, locCfg.account or "bank")

        Utils.Database.execute("DELETE FROM `gas_station_jobs` WHERE id = @id;", { ["@id"] = deliveryJobData.id })

    end

    if contractType == 1 then

        local maxCap  = stTypeCfg.stock_capacity + stTypeCfg.upgrades.stock.level_reward[dbRow.stock_upgrade]

        local newTotal = currentStock + amount

        if newTotal > maxCap then

            amount = maxCap - currentStock

            currentStock = maxCap

            notify(playerSrc, "error", "stock_full")

        else

            currentStock = newTotal

        end

        Utils.Database.execute(

            ("UPDATE `gas_station_business` SET %s = @stock, gas_bought = gas_bought + @amount, distance_traveled = distance_traveled + @distance WHERE gas_station_id = @gas_station_id"):format(fuelCol),

            { ["@gas_station_id"] = stationId, ["@stock"] = currentStock, ["@amount"] = amount, ["@distance"] = distance }

        )

        afterFinishContractImport(playerSrc, stationId, amount, currentStock)

    else

        local ppl = stTypeCfg.ressuply[supplyId].price_per_liter_to_export[fuelType]

        if not ppl then print("Missing export price for: " .. tostring(fuelType)); return end

        local earned = ppl * amount

        giveMarketMoney(stationId, earned)

        Utils.Database.execute(

            "UPDATE `gas_station_business` SET distance_traveled = distance_traveled + @distance, total_money_earned = total_money_earned + @price WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId, ["@distance"] = distance, ["@price"] = earned }

        )

        insertBalanceHistory(stationId, 0,

            Utils.translate("exported_income"):format(stTypeCfg.ressuply[supplyId].name, amount), earned)

        afterFinishContractExport(playerSrc, stationId, amount, earned)

    end

    Utils.Database.execute(

        "UPDATE `gas_station_employees` SET jobs_done = jobs_done + 1 WHERE gas_station_id = @gas_station_id and user_id = @user_id",

        { ["@gas_station_id"] = stationId, ["@user_id"] = playerId }

    )

end

RegisterServerEvent("gas_station:finishContract")

AddEventHandler("gas_station:finishContract", function(stationId, amount, fuelType, distance)

    local src     = source

    local session = activeSessions[src]

    if session then

        finishContract(src, stationId,

            session.job_data.amount, session.job_data.fuel_type,

            amount, fuelType, distance, session.deliveryman_job_data)

        activeSessions[src] = nil

    end

end)

function finishTruckerContract(playerSrc, externalData, contractDbId)

    if not externalData then print("Invalid external_data on finishTruckerContract"); return end

    if not playerSrc    then print("Invalid source finishTruckerContract"); return end

    finishContract(playerSrc, externalData.key, externalData.amount,

        externalData.fuel_type or "regular", 1, 0, 1, nil)

    Utils.Database.execute("DELETE FROM `gas_station_jobs` WHERE trucker_contract_id = @id;",

        { ["@id"] = contractDbId })

end

exports("finishTruckerContract", finishTruckerContract)

RegisterServerEvent("gas_station:createJob")

AddEventHandler("gas_station:createJob", function(stationId, permKey, jobData)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        if not isFuelTypePetrol(jobData.fuel_type) then

            print("Invalid fuel type to create job: " .. tostring(jobData.fuel_type)); return

        end

        local jobCount = Utils.Database.fetchAll(

            "SELECT COUNT(id) as qtd FROM gas_station_jobs WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1].qtd

        if jobCount >= Config.max_jobs then return end

        local stType    = Config.gas_station_locations[stationId].type

        local stTypeCfg = Config.gas_station_types[stType]

        local relRow    = Utils.Database.fetchAll(

            "SELECT relationship_upgrade FROM `gas_station_business` WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1]

        local baseCost    = stTypeCfg.ressuply_deliveryman.price_per_liter * jobData.amount

        local relLevel    = stTypeCfg.upgrades.relationship.level_reward[relRow.relationship_upgrade]

        local relDiscount = math.floor(baseCost * relLevel / 100)

        local totalCost   = jobData.reward + baseCost - relDiscount

        if not tryGetMarketMoney(stationId, totalCost) then

            notify(src, "error", "insufficient_funds"); return

        end

        local truckerContractId = nil

        if Config.trucker_logistics.enable then

            local contractType = 1

            local truckModel   = nil

            if Config.trucker_logistics.quick_jobs_page then

                local trucks = Config.trucker_logistics.available_trucks

                truckModel   = trucks[math.random(1, #trucks)]

                contractType = 0

            end

            local trailers     = Config.trucker_logistics.available_trailers

            local trailerModel = trailers[math.random(1, #trailers)]

            local parkLoc      = Config.gas_station_locations[stationId].truck_parking_location

            local extData = {

                x = parkLoc[1], y = parkLoc[2], z = parkLoc[3], h = parkLoc[4],

                key      = stationId,

                reward   = jobData.reward,

                amount   = jobData.amount,

                fuel_type= jobData.fuel_type,

                export   = GetCurrentResourceName(),

            }

            Utils.Database.execute(

                "INSERT INTO `trucker_available_contracts` (contract_type,contract_name,coords_index,price_per_km,cargo_type,fragile,valuable,fast,truck,trailer,external_data) VALUES (@contract_type,@contract_name,0,0,0,0,0,0,@truck,@trailer,@external_data);",

                {

                    ["@contract_type"]  = contractType,

                    ["@contract_name"]  = jobData.name,

                    ["@truck"]          = truckModel,

                    ["@trailer"]        = trailerModel,

                    ["@external_data"]  = json.encode(extData),

                }

            )

            local newContract = Utils.Database.fetchAll(

                "SELECT contract_id FROM `trucker_available_contracts` WHERE progress IS NULL AND contract_name = @name AND coords_index = 0 ORDER BY contract_id DESC LIMIT 1",

                { ["@name"] = jobData.name }

            )[1]

            truckerContractId = newContract and newContract.contract_id or nil

        end

        Utils.Database.execute(

            "INSERT INTO `gas_station_jobs` (gas_station_id,name,reward,amount,fuel_type,trucker_contract_id) VALUES (@gas_station_id,@name,@reward,@amount,@fuel_type,@trucker_contract_id);",

            {

                ["@gas_station_id"]      = stationId,

                ["@name"]               = jobData.name,

                ["@reward"]             = jobData.reward,

                ["@amount"]             = jobData.amount,

                ["@fuel_type"]          = jobData.fuel_type,

                ["@trucker_contract_id"]= truckerContractId,

            }

        )

        insertBalanceHistory(stationId, 1,

            Utils.translate("create_job_expenses"):format(jobData.name), totalCost)

        openUI(src, stationId, true)

    end)

end)

RegisterServerEvent("gas_station:deleteJob")

AddEventHandler("gas_station:deleteJob", function(stationId, permKey, reqData)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        local jobRows = Utils.Database.fetchAll(

            "SELECT name,reward,amount,progress,trucker_contract_id FROM `gas_station_jobs` WHERE id = @id;",

            { ["@id"] = reqData.job_id }

        )

        if not jobRows[1] then return end

        local job = jobRows[1]

        if Config.trucker_logistics.enable then

            local tcRows = Utils.Database.fetchAll(

                "SELECT progress FROM `trucker_available_contracts` WHERE contract_id = @contract_id",

                { ["@contract_id"] = job.trucker_contract_id }

            )

            if tcRows and tcRows[1] and tcRows[1].progress ~= nil then

                notify(src, "error", "cant_delete_job"); return

            end

        end

        if job.progress ~= 0 then

            notify(src, "error", "cant_delete_job"); return

        end

        Utils.Database.execute(

            "DELETE FROM `gas_station_jobs` WHERE id = @id;",

            { ["@id"] = reqData.job_id }

        )

        if Config.trucker_logistics.enable then

            Utils.Database.execute(

                "DELETE FROM `trucker_available_contracts` WHERE contract_id = @contract_id;",

                { ["@contract_id"] = job.trucker_contract_id }

            )

        end

        local stType    = Config.gas_station_locations[stationId].type

        local stTypeCfg = Config.gas_station_types[stType]

        local relRow    = Utils.Database.fetchAll(

            "SELECT relationship_upgrade FROM `gas_station_business` WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1]

        local baseCost    = stTypeCfg.ressuply_deliveryman.price_per_liter * job.amount

        local relDiscount = math.floor(baseCost * stTypeCfg.upgrades.relationship.level_reward[relRow.relationship_upgrade] / 100)

        local refund      = job.reward + baseCost - relDiscount

        Utils.Database.execute(

            "UPDATE `gas_station_business` SET total_money_spent = total_money_spent - @amount WHERE gas_station_id = @gas_station_id",

            { ["@amount"] = refund, ["@gas_station_id"] = stationId }

        )

        giveMarketMoney(stationId, refund)

        insertBalanceHistory(stationId, 0,

            Utils.translate("create_job_income"):format(job.name), refund)

        openUI(src, stationId, true)

    end)

end)

RegisterServerEvent("gas_station:renameMarket")

AddEventHandler("gas_station:renameMarket", function(stationId, permKey, renameData)

    if Config.disable_rename_business then return end

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        if not (renameData and renameData.name and renameData.color and renameData.blip) then return end

        Utils.Database.execute(

            "UPDATE `gas_station_business` SET gas_station_name = @name, gas_station_color = @color, gas_station_blip = @blip WHERE gas_station_id = @gas_station_id",

            { ["@name"] = renameData.name, ["@color"] = renameData.color,

              ["@blip"] = renameData.blip, ["@gas_station_id"] = stationId }

        )

        TriggerClientEvent("gas_station:updateBlip", -1, stationId, renameData.name, renameData.color, renameData.blip)

        openUI(src, stationId, true)

    end)

end)

RegisterServerEvent("gas_station:getBlips")

AddEventHandler("gas_station:getBlips", function()

    local src  = source

    local rows = Utils.Database.fetchAll(

        "SELECT gas_station_id, gas_station_name, gas_station_color, gas_station_blip FROM `gas_station_business`",

        {}

    )

    local blips = {}

    for _, row in pairs(rows) do

        blips[row.gas_station_id] = {

            gas_station_name  = row.gas_station_name,

            gas_station_color = row.gas_station_color,

            gas_station_blip  = row.gas_station_blip,

        }

    end

    TriggerClientEvent("gas_station:setBlips", src, blips)

end)

RegisterServerEvent("gas_station:unlockElectric")

AddEventHandler("gas_station:unlockElectric", function(stationId, permKey, reqData)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        if type(reqData) ~= "table" then return end

        local locCfg = Config.gas_station_locations[stationId]

        if not locCfg or not locCfg.type then return end

        local stType    = locCfg.type

        local stTypeCfg = Config.gas_station_types[stType]

        local price, col

        if reqData.type == "electricnormal" then

            price = stTypeCfg.electric_normal_price

            col   = "stock_electricnormal"

        elseif reqData.type == "electricfast" then

            price = stTypeCfg.electric_fast_price

            col   = "stock_electricfast"

        else

            return

        end

        if tryGetMarketMoney(stationId, price) then

            Utils.Database.execute(

                ("UPDATE `gas_station_business` SET %s = 1 WHERE gas_station_id = @gas_station_id"):format(col),

                { ["@gas_station_id"] = stationId }

            )

            openUI(src, stationId, true)

        else

            notify(src, "error", "insufficient_funds")

        end

    end)

end)

RegisterServerEvent("gas_station:applyPrice")

AddEventHandler("gas_station:applyPrice", function(stationId, permKey, priceData)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        if type(priceData) ~= "table" or type(priceData.column) ~= "string" then return end

        local columnMap = {
            price = "regular",
            price_plus = "plus",
            price_premium = "premium",
            price_diesel = "diesel",
            price_electricfast = "electric",
            price_electricnormal = "electric",
        }

        local fuelType = columnMap[priceData.column]

        if not fuelType then

            print(string.format("Invalid fuel column '%s' for user %s. Data: %s",

                priceData.column, playerId, json.encode(priceData)))

            return

        end

        local locCfg = Config.gas_station_locations[stationId]

        if not locCfg or not locCfg.type then return end

        local stTypeCfg = Config.gas_station_types[locCfg.type]

        local limits = stTypeCfg and stTypeCfg.price_limits and stTypeCfg.price_limits[fuelType]

        if not limits then return end

        local minValue = math.floor((tonumber(limits.min) or 0) * 100)

        local maxValue = math.floor((tonumber(limits.max) or 0) * 100)

        local priceValue = math.floor(tonumber(priceData.value) or -1)

        if priceValue < minValue or priceValue > maxValue then

            notify(src, "error", "invalid_value")

            return

        end

        Utils.Database.execute(

            ("UPDATE `gas_station_business` SET %s = @price WHERE gas_station_id = @gas_station_id"):format(priceData.column),

            { ["@gas_station_id"] = stationId, ["@price"] = priceValue }

        )

    end)

end)

RegisterServerEvent("gas_station:buyUpgrade")

AddEventHandler("gas_station:buyUpgrade", function(stationId, permKey, upgradeData)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        if type(upgradeData) ~= "table" then return end

        local upId = upgradeData.id

        local upCol = resolveUpgradeColumn(upId)

        if not upCol then return end

        local locCfg = Config.gas_station_locations[stationId]

        if not locCfg or not locCfg.type then return end

        local dbRow  = Utils.Database.fetchAll(

            ("SELECT `%s` FROM `gas_station_business` WHERE gas_station_id = @gas_station_id"):format(upCol),

            { ["@gas_station_id"] = stationId }

        )[1]

        if not dbRow then return end

        local curLevel = tonumber(dbRow[upCol]) or 0

        if curLevel >= 5 then

            notify(src, "error", "max_level"); return

        end

        local stType  = locCfg.type

        local price   = Config.gas_station_types[stType].upgrades[upId].price

        if tryGetMarketMoney(stationId, price) then

            Utils.Database.execute(

                ("UPDATE `gas_station_business` SET `%s` = `%s` + 1 WHERE gas_station_id = @gas_station_id"):format(upCol, upCol),

                { ["@gas_station_id"] = stationId }

            )

            insertBalanceHistory(stationId, 1,

                Utils.translate("upgrade_expenses"):format(

                    Utils.translate(upId .. "_upgrade")), price)

            openUI(src, stationId, true)

        else

            notify(src, "error", "insufficient_funds")

        end

    end)

end)

RegisterServerEvent("gas_station:hideBalance")

AddEventHandler("gas_station:hideBalance", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function()

        Utils.Database.execute(

            "UPDATE `gas_station_balance` SET hidden = 1 WHERE gas_station_id = @gas_station_id AND id = @id",

            { ["@gas_station_id"] = stationId, ["@id"] = req.balance_id }

        )

        openUI(src, stationId, true)

    end)

end)

RegisterServerEvent("gas_station:showBalance")

AddEventHandler("gas_station:showBalance", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function()

        Utils.Database.execute(

            "UPDATE `gas_station_balance` SET hidden = 0 WHERE gas_station_id = @gas_station_id AND id = @id",

            { ["@gas_station_id"] = stationId, ["@id"] = req.balance_id }

        )

        openUI(src, stationId, true)

    end)

end)

RegisterServerEvent("gas_station:withdrawMoney")

AddEventHandler("gas_station:withdrawMoney", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        local amount = math.floor(tonumber(req.amount) or 0)

        if not (amount and amount > 0) then return end

        local row = Utils.Database.fetchAll(

            "SELECT money FROM `gas_station_business` WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1]

        if not row then return end

        if amount <= tonumber(row.money) then

            Utils.Database.execute(

                "UPDATE `gas_station_business` SET money = money - @amount WHERE gas_station_id = @gas_station_id",

                { ["@gas_station_id"] = stationId, ["@amount"] = amount }

            )

            local account = Config.gas_station_locations[stationId].account or "bank"

            Utils.Framework.giveAccountMoney(src, amount, account)

            insertBalanceHistory(stationId, 1, Utils.translate("money_withdrawn"), amount)

            notify(src, "success", "money_withdrawn")

            Utils.Webhook.sendWebhookMessage(WebhookURL,

                Utils.translate("logs_money_withdrawn"):format(

                    stationId, amount,

                    Utils.Framework.getPlayerIdLog(src) .. buildWebhookTimestamp()

                )

            )

            openUI(src, stationId, true)

        else

            notify(src, "error", "insufficient_funds")

        end

    end)

end)

RegisterServerEvent("gas_station:depositMoney")

AddEventHandler("gas_station:depositMoney", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        local amount = math.floor(tonumber(req.amount) or 0)

        if not (amount and amount > 0) then

            notify(src, "error", "invalid_value"); return

        end

        local account = Config.gas_station_locations[stationId].account or "bank"

        if Utils.Framework.tryRemoveAccountMoney(src, amount, account) then

            giveMarketMoney(stationId, amount)

            insertBalanceHistory(stationId, 0, Utils.translate("money_deposited"), amount)

            notify(src, "success", "money_deposited")

            Utils.Webhook.sendWebhookMessage(WebhookURL,

                Utils.translate("logs_money_deposited"):format(

                    stationId, amount,

                    Utils.Framework.getPlayerIdLog(src) .. buildWebhookTimestamp()

                )

            )

            openUI(src, stationId, true)

        else

            notify(src, "error", "insufficient_funds")

        end

    end)

end)

Utils.Callback.RegisterServerCallback("gas_station:loadBalanceHistory",

    function(src, cb, stationId, req)

        local playerId = Utils.Framework.getPlayerId(src)

        if not playerId then

            cb({})

            return

        end

        stationId = tonumber(stationId)

        if not stationId or not Config.gas_station_locations[stationId] then

            cb({})

            return

        end

        if not isOwner(stationId, playerId) and not hasRole(stationId, playerId, "showBalance") then

            cb({})

            return

        end

        local lastBalanceId = tonumber(req and req.last_balance_id)

        if not lastBalanceId or lastBalanceId <= 0 then

            lastBalanceId = 2147483647

        end

        local rows = Utils.Database.fetchAll(

            "SELECT * FROM `gas_station_balance` WHERE gas_station_id = @gas_station_id AND id < @last_balance_id ORDER BY id DESC LIMIT 50",

            { ["@gas_station_id"] = stationId, ["@last_balance_id"] = lastBalanceId }

        )

        cb(rows)

    end

)

RegisterServerEvent("gas_station:hirePlayer")

AddEventHandler("gas_station:hirePlayer", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        local targetId = req.user

        local stType   = Config.gas_station_locations[stationId].type

        local maxEmp   = Config.gas_station_types[stType].max_employees or 0

        local curEmp   = Utils.Database.fetchAll(

            "SELECT COUNT(user_id) as qtd FROM `gas_station_employees` WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1].qtd

        if maxEmp <= curEmp then notify(src, "error", "max_employees"); return end

        local playerName = Utils.Framework.getPlayerName(targetId)

        if not playerName then notify(src, "error", "user_not_found"); return end

        local existing = Utils.Database.fetchAll(

            "SELECT gas_station_id FROM `gas_station_employees` WHERE user_id = @user_id",

            { ["@user_id"] = targetId }

        )

        for _, emp in pairs(existing) do

            if emp.gas_station_id == stationId then

                notify(src, "error", "user_employed"); return

            end

        end

        if not beforeHireEmployee(src, stationId, targetId) then return end

        if #existing >= Config.max_stations_employed then

            notify(src, "error", "user_employed"); return

        end

        Utils.Database.execute(

            "INSERT INTO `gas_station_employees` (`user_id`,`gas_station_id`,`role`,`timer`) VALUES (@user_id,@gas_station_id,@role,@timer);",

            { ["@user_id"] = targetId, ["@gas_station_id"] = stationId,

              ["@role"] = 1, ["@timer"] = os.time() }

        )

        openUI(src, stationId, true)

        notify(src, "success", "hired_user", playerName)

        afterHireEmployee(src, stationId, targetId)

    end)

end)

RegisterServerEvent("gas_station:firePlayer")

AddEventHandler("gas_station:firePlayer", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function()

        Utils.Database.execute(

            "DELETE FROM `gas_station_employees` WHERE user_id = @user_id AND gas_station_id = @gas_station_id",

            { ["@user_id"] = req.user, ["@gas_station_id"] = stationId }

        )

        notify(src, "success", "fired_user")

        openUI(src, stationId, true)

    end)

end)

RegisterServerEvent("gas_station:changeRole")

AddEventHandler("gas_station:changeRole", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function()

        Utils.Database.execute(

            "UPDATE `gas_station_employees` SET role = @role WHERE gas_station_id = @gas_station_id AND user_id = @user_id",

            { ["@gas_station_id"] = stationId, ["@user_id"] = req.user_id, ["@role"] = req.role }

        )

        notify(src, "success", "role_changed")

    end)

end)

RegisterServerEvent("gas_station:giveComission")

AddEventHandler("gas_station:giveComission", function(stationId, permKey, req)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        local targetUserId = req.user

        local amount       = math.floor(tonumber(req.amount) or 0)

        if amount <= 0 then notify(src, "error", "invalid_value"); return end

        local targetSrc = Utils.Framework.getPlayerSource(targetUserId)

        if not targetSrc then notify(src, "error", "cant_find_user"); return end

        if not tryGetMarketMoney(stationId, amount) then

            notify(src, "error", "insufficient_funds"); return

        end

        local account = Config.gas_station_locations[stationId].account or "bank"

        Utils.Framework.giveAccountMoney(targetSrc, amount, account)

        notify(targetSrc, "success", "comission_received")

        notify(src,       "success", "comission_sent")

        insertBalanceHistory(stationId, 1,

            Utils.translate("give_comission_expenses"):format(

                Utils.Framework.getPlayerName(targetUserId)), amount)

        Utils.Webhook.sendWebhookMessage(WebhookURL,

            Utils.translate("logs_comission"):format(

                stationId, amount,

                Utils.Framework.getPlayerIdLog(targetSrc),

                Utils.Framework.getPlayerIdLog(src) .. buildWebhookTimestamp()

            )

        )

        openUI(src, stationId, true)

    end)

end)

RegisterServerEvent("gas_station:changeTheme")

AddEventHandler("gas_station:changeTheme", function(stationId, permKey, req)

    local src = source

    wrapperLock[src] = nil
    Wrapper(src, stationId, permKey, false, function(playerId)

        local existing = Utils.Database.fetchAll(

            "SELECT 1 FROM `gas_station_users_theme` WHERE user_id = @user_id",

            { ["@user_id"] = playerId }

        )[1]

        if not existing then

            Utils.Database.execute(

                "INSERT INTO `gas_station_users_theme` (user_id,dark_theme) VALUES (@user_id,@dark_theme);",

                { ["@dark_theme"] = req.dark_theme, ["@user_id"] = playerId }

            )

        else

            Utils.Database.execute(

                "UPDATE `gas_station_users_theme` SET dark_theme = @dark_theme WHERE user_id = @user_id",

                { ["@dark_theme"] = req.dark_theme, ["@user_id"] = playerId }

            )

        end

    end)

end)

RegisterServerEvent("gas_station:sellMarket")

AddEventHandler("gas_station:sellMarket", function(stationId, permKey)

    local src = source

    Wrapper(src, stationId, permKey, true, function(playerId)

        local ownerRow = Utils.Database.fetchAll(

            "SELECT user_id FROM `gas_station_business` WHERE gas_station_id = @gas_station_id",

            { ["@gas_station_id"] = stationId }

        )[1]

        if ownerRow.user_id ~= playerId then

            notify(src, "error", "sell_error"); return

        end

        TriggerClientEvent("gas_station:closeUI", src)

        for _, tbl in ipairs({ "gas_station_business", "gas_station_balance",

                                "gas_station_jobs",    "gas_station_employees" }) do

            Utils.Database.execute(

                ("DELETE FROM `%s` WHERE gas_station_id = @gas_station_id;"):format(tbl),

                { ["@gas_station_id"] = stationId }

            )

        end

        local locCfg  = Config.gas_station_locations[stationId]

        local account = locCfg.account or "bank"

        Utils.Framework.giveAccountMoney(src, locCfg.sell_price, account)

        notify(src, "success", "store_sold")

        local defaultBlip = Config.gas_station_types[locCfg.type].blips

        TriggerClientEvent("gas_station:updateBlip", -1, stationId,

            defaultBlip.name, defaultBlip.color, defaultBlip.id)

        Utils.Webhook.sendWebhookMessage(WebhookURL,

            Utils.translate("logs_close"):format(

                stationId,

                Utils.Framework.getPlayerIdLog(src) .. buildWebhookTimestamp()

            )

        )

    end)

end)

function checkLowStockThread()

    Citizen.CreateThreadNow(function()

        Citizen.Wait(10000)

        while true do

            if not Config.clear_gas_stations.active then break end

            local rows = Utils.Database.fetchAll(

                "SELECT gas_station_id, user_id, stock, stock_plus, stock_premium, stock_diesel, timer FROM gas_station_business",

                {}

            )

            for _, row in pairs(rows) do

                local locCfg = Config.gas_station_locations[row.gas_station_id]

                if locCfg then

                    local stType    = locCfg.type

                    local stTypeCfg = Config.gas_station_types[stType]

                    local fuelDiv   = Config.enable_different_fuels and 4 or 1

                    local total = Config.enable_different_fuels

                        and (row.stock + row.stock_plus + row.stock_premium + row.stock_diesel)

                        or row.stock

                    local minPct   = Config.clear_gas_stations.min_stock_amount / 100

                    local threshold = stTypeCfg.stock_capacity * minPct * fuelDiv

                    if total < threshold then

                        local cooldownSecs = Config.clear_gas_stations.cooldown * 60 * 60

                        if (row.timer + cooldownSecs) < os.time() then

                            for _, tbl in ipairs({ "gas_station_balance", "gas_station_jobs",

                                                    "gas_station_business", "gas_station_employees" }) do

                                Utils.Database.execute(

                                    ("DELETE FROM `%s` WHERE gas_station_id = @gas_station_id;"):format(tbl),

                                    { ["@gas_station_id"] = row.gas_station_id }

                                )

                            end

                            Utils.Webhook.sendWebhookMessage(WebhookURL,

                                Utils.translate("logs_lost_low_stock"):format(

                                    row.gas_station_id, total,

                                    os.date("%d/%m/%Y %H:%M:%S", row.timer),

                                    row.user_id .. buildWebhookTimestamp()

                                )

                            )

                        else

                            Utils.Database.execute(

                                "UPDATE `gas_station_business` SET timer = @timer WHERE gas_station_id = @gas_station_id",

                                { timer = os.time(), ["@gas_station_id"] = row.gas_station_id }

                            )

                        end

                    end

                end

                Citizen.Wait(100)

            end

            Citizen.Wait(3600000)
        end

    end)

end

Citizen.CreateThread(function()

    Wait(1000)

    while not config_valid do Wait(100) end

    assert(Config.gas_station_locations,

        "^3You have errors in your config file, consider fixing it or redownload the original config.^7")

    assert(GetResourceState("lc_utils") == "started",

        "^3The 'lc_utils' file is missing. Please refer to the documentation: ^7https://docs.lixeirocharmoso.com/gas_stations/installation^7")

    if Utils.Math.checkIfCurrentVersionisOutdated(UTILS_MIN, Utils.Version) then

        utils_outdated = true

        error(("^3The script requires 'lc_utils' in version ^1%s^3, but you currently have version ^1%s^3. "

               .. "Please update: https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip^7")

               :format(UTILS_MIN, Utils.Version))

    end

    checkIfFrameworkWasLoaded()

    checkScriptName()

    Utils.loadLanguageFile(Lang)

    runCreateTableQueries()

    Utils.Database.execute("UPDATE `gas_station_jobs` SET progress = 0", {})

    Config = Utils.validateConfig(Config, {

        { config_path = { "group_map_blips" },       default_value = true },

        { config_path = { "enable_different_fuels" }, default_value = true },

    })

    Wait(1000)

    Utils.Database.validateTableColumns(

        {

            gas_station_business = {

                "gas_station_id", "user_id", "stock", "price",

                "stock_plus", "price_plus", "stock_premium", "price_premium",

                "stock_diesel", "price_diesel",

                "stock_electricnormal", "price_electricnormal",

                "stock_electricfast",   "price_electricfast",

                "stock_upgrade", "truck_upgrade", "relationship_upgrade",

                "money", "total_money_earned", "total_money_spent",

                "gas_bought", "gas_sold", "distance_traveled",

                "total_visits", "customers",

                "gas_station_name", "gas_station_color", "gas_station_blip", "timer",

            },

            gas_station_balance   = { "id", "gas_station_id", "income", "title", "amount", "date", "hidden" },

            gas_station_jobs      = { "id", "gas_station_id", "name", "reward", "amount", "fuel_type", "progress", "trucker_contract_id" },

            gas_station_employees = { "gas_station_id", "user_id", "jobs_done", "role", "timer" },

            gas_station_users_theme = { "user_id", "dark_theme" },

        },

        {

            gas_station_business = {

                stock_plus           = "ALTER TABLE `gas_station_business` ADD COLUMN `stock_plus` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                price_plus           = "ALTER TABLE `gas_station_business` ADD COLUMN `price_plus` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                stock_premium        = "ALTER TABLE `gas_station_business` ADD COLUMN `stock_premium` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                price_premium        = "ALTER TABLE `gas_station_business` ADD COLUMN `price_premium` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                stock_diesel         = "ALTER TABLE `gas_station_business` ADD COLUMN `stock_diesel` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                price_diesel         = "ALTER TABLE `gas_station_business` ADD COLUMN `price_diesel` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                stock_electricfast   = "ALTER TABLE `gas_station_business` ADD COLUMN `stock_electricfast` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                price_electricfast   = "ALTER TABLE `gas_station_business` ADD COLUMN `price_electricfast` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                stock_electricnormal = "ALTER TABLE `gas_station_business` ADD COLUMN `stock_electricnormal` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

                price_electricnormal = "ALTER TABLE `gas_station_business` ADD COLUMN `price_electricnormal` INT(10) UNSIGNED NOT NULL DEFAULT '0' AFTER `price`;",

            },

            gas_station_jobs = {

                fuel_type = "ALTER TABLE `gas_station_jobs` ADD COLUMN `fuel_type` VARCHAR(50) NOT NULL DEFAULT 'regular' AFTER `amount`;",

            },

        },

        {}

    )

    Utils.validateFunctions({ "afterHireEmployee", "beforeHireEmployee" }, "server_utils.lua")

    searchForErrorsInConfig()

    searchForDataIssuesInDatabase()

    checkLowStockThread()

end)

function checkScriptName()

    assert(GetCurrentResourceName() == "lc_gas_stations",

        "^3The script name does not match. Please ensure the resource name is '^1lc_gas_stations^7'.")

end

function checkIfFrameworkWasLoaded()

    assert(Utils.Framework.getPlayerId,

        "^3The framework wasn't loaded in 'lc_utils'. Check 'Config.framework' and the docs: ^7https://docs.lixeirocharmoso.com/^3'.^7")

end

function searchForErrorsInConfig()

    for _, locData in pairs(Config.gas_station_locations) do

        if not Config.gas_station_types[locData.type] then

            print(("^1Error in your config:^3 Type '^1%s^3' is not registered in Config.gas_station_types^7"):format(locData.type))

        end

    end

end

function searchForDataIssuesInDatabase()

    if Config.trucker_logistics.enable then

        for _, old in ipairs({ "qb_gas_station", "esx_gas_station" }) do

            Utils.Database.execute(

                ("UPDATE trucker_available_contracts SET external_data = REPLACE(external_data,'%s','lc_gas_stations') WHERE external_data LIKE '%%%s%%';"):format(old, old)

            )

        end

    end

    local validIds = {}

    for id in pairs(Config.gas_station_locations) do

        table.insert(validIds, id)

    end

    local orphans = Utils.Database.fetchAll(

        string.format("SELECT gas_station_id FROM `gas_station_business` WHERE gas_station_id NOT IN ('%s')",

            table.concat(validIds, "','"))

    , {})

    if #orphans > 0 then

        local rn = GetCurrentResourceName()

        print(("^8[%s] DATABASE ISSUES:^3 The following issues were found in your database:^7"):format(rn))

        for _, row in pairs(orphans) do

            print(string.format("^8[%s]^3 Gas station ^1%s^3 is in your ^1gas_station^3 tables but not in your config.^7",

                rn, row.gas_station_id))

        end

        print(("^8[%s] HOW TO RESOLVE: Add missing data to the config or remove them from the database.^7"):format(rn))

    end

end

function runCreateTableQueries()

    if Config.create_table == false then return end

    local queries = {

        [[

        CREATE TABLE IF NOT EXISTS `gas_station_business` (

            `gas_station_id` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',

            `user_id` VARCHAR(50) NOT NULL,

            `stock` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `price` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `stock_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

            `truck_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

            `relationship_upgrade` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

            `money` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `total_money_earned` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `total_money_spent` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `gas_bought` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `gas_sold` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `distance_traveled` DOUBLE UNSIGNED NOT NULL DEFAULT '0',

            `total_visits` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `customers` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `gas_station_name` VARCHAR(50) NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci',

            `gas_station_color` INT(10) UNSIGNED NULL DEFAULT NULL,

            `gas_station_blip` INT(10) UNSIGNED NULL DEFAULT NULL,

            `timer` INT(10) UNSIGNED NOT NULL,

            PRIMARY KEY (`gas_station_id`) USING BTREE

        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

        ]],

        [[

        CREATE TABLE IF NOT EXISTS `gas_station_balance` (

            `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,

            `gas_station_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

            `income` TINYINT(3) UNSIGNED NOT NULL,

            `title` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',

            `amount` INT(10) UNSIGNED NOT NULL,

            `date` INT(10) UNSIGNED NOT NULL,

            `hidden` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

            PRIMARY KEY (`id`) USING BTREE

        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

        ]],

        [[

        CREATE TABLE IF NOT EXISTS `gas_station_jobs` (

            `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,

            `gas_station_id` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',

            `name` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

            `reward` INT(10) UNSIGNED NOT NULL DEFAULT '0',

            `amount` INT(11) NOT NULL DEFAULT '0',

            `progress` TINYINT(3) UNSIGNED NOT NULL DEFAULT '0',

            `trucker_contract_id` INT(10) UNSIGNED NULL DEFAULT NULL,

            PRIMARY KEY (`id`) USING BTREE

        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

        ]],

        [[

        CREATE TABLE IF NOT EXISTS `gas_station_employees` (

            `gas_station_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

            `user_id` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',

            `jobs_done` INT(11) UNSIGNED NOT NULL DEFAULT '0',

            `role` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',

            `timer` INT(11) UNSIGNED NOT NULL,

            PRIMARY KEY (`gas_station_id`, `user_id`) USING BTREE

        ) COLLATE='utf8mb4_general_ci' ENGINE=InnoDB;

        ]],

        [[

        CREATE TABLE IF NOT EXISTS `gas_station_users_theme` (

            `user_id` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',

            `dark_theme` TINYINT(3) UNSIGNED NOT NULL DEFAULT '1',

            PRIMARY KEY (`user_id`) USING BTREE

        ) COLLATE='utf8_general_ci' ENGINE=InnoDB;

        ]],

    }

    for _, q in ipairs(queries) do

        Utils.Database.execute(q)

    end

end








