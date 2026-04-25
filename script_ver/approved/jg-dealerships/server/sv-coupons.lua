



Coupons = Coupons or {}
Coupons.Server = Coupons.Server or {}

--- Generate a random coupon code (format: XXXX-XXXX)
--- @return string The generated coupon code
local function GenerateCouponCode()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local code = ""
    
    -- First part (4 characters)
    for i = 1, 4 do
        local randomIndex = math.random(1, #charset)
        code = code .. charset:sub(randomIndex, randomIndex)
    end
    
    code = code .. "-"
    
    -- Second part (4 characters)
    for i = 1, 4 do
        local randomIndex = math.random(1, #charset)
        code = code .. charset:sub(randomIndex, randomIndex)
    end
    
    return code
end

--- Check if a coupon code is unique
--- @param code string The coupon code to check
--- @param dealershipId string The dealership ID
--- @return boolean True if the code is unique
local function IsCouponCodeUnique(code, dealershipId)
    local existingId = MySQL.scalar.await(
        "SELECT id FROM dealership_coupons WHERE code = ? AND dealership_id = ?",
        {code, dealershipId}
    )
    return not existingId
end

--- Callback: Get all coupons for a dealership (with pagination and search)
lib.callback.register("jg-dealerships:server:get-coupons", function(playerId, data)
    -- Check employee permissions
    if not Employees.Server.IsEmployee(playerId, data.dealershipId, "MANAGE_INVENTORY") then
        DebugPrint("[DEBUG] IsEmployee check failed")
        Framework.Server.Notify(playerId, Locale.employeePermissionsError, "error")
        return {error = true}
    end
    
    -- Parse pagination parameters
    local page = data.page or 1
    local limit = data.limit or 10
    local search = data.search or ""
    local offset = (page - 1) * limit
    local searchPattern = "%" .. search .. "%"
    
    -- Get coupons with pagination
    local coupons = MySQL.query.await([[
        SELECT * FROM dealership_coupons 
        WHERE dealership_id = ? AND code LIKE ?
        ORDER BY created_at DESC
        LIMIT ? OFFSET ?
    ]], {data.dealershipId, searchPattern, limit, offset})
    
    DebugPrint(("[COUPONS] Coupons query returned: %s rows"):format(coupons and #coupons or "nil"))
    
    -- Get total count
    local totalCount = MySQL.scalar.await([[
        SELECT COUNT(*) FROM dealership_coupons 
        WHERE dealership_id = ? AND code LIKE ?
    ]], {data.dealershipId, searchPattern})
    
    DebugPrint(("[COUPONS] Total count: %s"):format(totalCount))
    
    -- Decode JSON restrictions
    if coupons then
        for i = 1, #coupons do
            if coupons[i].vehicle_restrictions then
                coupons[i].vehicle_restrictions = json.decode(coupons[i].vehicle_restrictions)
            end
            if coupons[i].category_restrictions then
                coupons[i].category_restrictions = json.decode(coupons[i].category_restrictions)
            end
        end
    end
    
    local result = {
        coupons = coupons or {},
        total = totalCount or 0
    }
    
    DebugPrint(("[COUPONS] Returning result: %s"):format(json.encode(result)))
    
    return result
end)

--- Callback: Create a new coupon
lib.callback.register("jg-dealerships:server:create-coupon", function(playerId, data)
    -- Check employee permissions
    if not Employees.Server.IsEmployee(playerId, data.dealershipId, "MANAGE_INVENTORY") then
        Framework.Server.Notify(playerId, Locale.employeePermissionsError, "error")
        return {error = true}
    end
    
    -- Get player identifier
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(playerId)
    if not playerIdentifier then
        return {error = true, message = "Failed to get player info"}
    end
    
    -- Check if coupon code is unique
    if not IsCouponCodeUnique(data.code, data.dealershipId) then
        Framework.Server.Notify(playerId, Locale.couponCodeAlreadyExists, "error")
        return {error = true, message = "Coupon code already exists"}
    end
    
    -- Encode restrictions as JSON
    local vehicleRestrictions = data.vehicle_restrictions and json.encode(data.vehicle_restrictions) or nil
    local categoryRestrictions = data.category_restrictions and json.encode(data.category_restrictions) or nil
    
    -- Insert new coupon
    local insertId = MySQL.insert.await([[
        INSERT INTO dealership_coupons 
        (code, dealership_id, discount_type, discount_value, max_uses, per_player_limit, 
         expiry_date, vehicle_restrictions, category_restrictions, allow_finance, created_at, created_by)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        data.code,
        data.dealershipId,
        data.discount_type,
        data.discount_value,
        data.max_uses,
        data.per_player_limit,
        data.expiry_date,
        vehicleRestrictions,
        categoryRestrictions,
        data.allow_finance and 1 or 0,
        os.time() * 1000,
        playerIdentifier
    })
    
    if not insertId then
        Framework.Server.Notify(playerId, Locale.failedToCreateCoupon, "error")
        return {error = true}
    end
    
    Framework.Server.Notify(playerId, Locale.couponCreatedSuccessfully, "success")
    
    -- Return created coupon data
    return {
        id = insertId,
        code = data.code,
        dealership_id = data.dealershipId,
        discount_type = data.discount_type,
        discount_value = data.discount_value,
        max_uses = data.max_uses,
        current_uses = 0,
        per_player_limit = data.per_player_limit,
        expiry_date = data.expiry_date,
        vehicle_restrictions = data.vehicle_restrictions,
        category_restrictions = data.category_restrictions,
        allow_finance = data.allow_finance,
        active = true,
        created_at = os.time() * 1000,
        created_by = playerIdentifier
    }
end)

--- Callback: Update an existing coupon
lib.callback.register("jg-dealerships:server:update-coupon", function(playerId, data)
    -- Check employee permissions
    if not Employees.Server.IsEmployee(playerId, data.dealershipId, "MANAGE_INVENTORY") then
        Framework.Server.Notify(playerId, Locale.employeePermissionsError, "error")
        return {error = true}
    end
    
    -- Get existing coupon
    local existingCoupon = MySQL.single.await(
        "SELECT * FROM dealership_coupons WHERE id = ? AND dealership_id = ?",
        {data.id, data.dealershipId}
    )
    
    if not existingCoupon then
        Framework.Server.Notify(playerId, Locale.couponNotFound, "error")
        return {error = true}
    end
    
    -- Check if code is being changed and if new code is unique
    if data.code ~= existingCoupon.code then
        if not IsCouponCodeUnique(data.code, data.dealershipId) then
            Framework.Server.Notify(playerId, Locale.couponCodeAlreadyExists, "error")
            return {error = true, message = "Coupon code already exists"}
        end
    end
    
    -- Encode restrictions as JSON
    local vehicleRestrictions = data.vehicle_restrictions and json.encode(data.vehicle_restrictions) or nil
    local categoryRestrictions = data.category_restrictions and json.encode(data.category_restrictions) or nil
    
    -- Update coupon
    MySQL.update.await([[
        UPDATE dealership_coupons 
        SET code = ?, discount_type = ?, discount_value = ?, max_uses = ?, 
            per_player_limit = ?, expiry_date = ?, vehicle_restrictions = ?, 
            category_restrictions = ?, allow_finance = ?, active = ?
        WHERE id = ? AND dealership_id = ?
    ]], {
        data.code,
        data.discount_type,
        data.discount_value,
        data.max_uses,
        data.per_player_limit,
        data.expiry_date,
        vehicleRestrictions,
        categoryRestrictions,
        data.allow_finance and 1 or 0,
        data.active and 1 or 0,
        data.id,
        data.dealershipId
    })
    
    Framework.Server.Notify(playerId, Locale.couponUpdatedSuccessfully, "success")
    
    -- Return updated coupon data
    return {
        id = data.id,
        code = data.code,
        dealership_id = data.dealershipId,
        discount_type = data.discount_type,
        discount_value = data.discount_value,
        max_uses = data.max_uses,
        current_uses = existingCoupon.current_uses,
        per_player_limit = data.per_player_limit,
        expiry_date = data.expiry_date,
        vehicle_restrictions = data.vehicle_restrictions,
        category_restrictions = data.category_restrictions,
        allow_finance = data.allow_finance,
        active = data.active,
        created_at = existingCoupon.created_at,
        created_by = existingCoupon.created_by
    }
end)

--- Callback: Delete a coupon
lib.callback.register("jg-dealerships:server:delete-coupon", function(playerId, data)
    -- Check employee permissions
    if not Employees.Server.IsEmployee(playerId, data.dealershipId, "MANAGE_INVENTORY") then
        Framework.Server.Notify(playerId, Locale.employeePermissionsError, "error")
        return {error = true}
    end
    
    -- Delete coupon
    local result = MySQL.query.await(
        "DELETE FROM dealership_coupons WHERE id = ? AND dealership_id = ?",
        {data.id, data.dealershipId}
    )
    
    if not result then
        Framework.Server.Notify(playerId, Locale.failedToDeleteCoupon, "error")
        return {error = true}
    end
    
    Framework.Server.Notify(playerId, Locale.couponDeletedSuccessfully, "success")
    return {success = true}
end)

--- Callback: Generate a unique coupon code
lib.callback.register("jg-dealerships:server:generate-coupon-code", function(playerId, data)
    -- Check employee permissions
    if not Employees.Server.IsEmployee(playerId, data.dealershipId, "MANAGE_INVENTORY") then
        return {error = true}
    end
    
    local generatedCode = nil
    local attempts = 0
    
    -- Try to generate unique code (max 100 attempts)
    repeat
        generatedCode = GenerateCouponCode()
        attempts = attempts + 1
    until IsCouponCodeUnique(generatedCode, data.dealershipId) or attempts >= 100
    
    if attempts >= 100 then
        return {error = true, message = "Failed to generate unique code"}
    end
    
    return {code = generatedCode}
end)

--- Validate and apply a coupon
--- @param playerId number The player's server ID
--- @param dealershipId string The dealership ID
--- @param couponCode string The coupon code to validate
--- @param vehicleModel string The vehicle model/spawn code
--- @param vehicleCategory string The vehicle category
--- @param isFinanced boolean Whether the purchase is financed
--- @param vehiclePrice number The vehicle price
--- @param targetPlayerId number Optional - The player to validate for (for gifting)
--- @return table Validation result with valid status, discount amount, and coupon data
function Coupons.Server.ValidateAndApplyCoupon(playerId, dealershipId, couponCode, vehicleModel, vehicleCategory, isFinanced, vehiclePrice, targetPlayerId)
    -- Check if coupon code is provided
    if not couponCode or couponCode == "" then
        return {valid = false, message = "No coupon code provided"}
    end
    
    -- Get coupon from database
    local coupon = MySQL.single.await([[
        SELECT * FROM dealership_coupons 
        WHERE code = ? AND dealership_id = ? AND active = 1
    ]], {couponCode, dealershipId})
    
    if not coupon then
        return {valid = false, message = "Invalid coupon code"}
    end
    
    -- Check expiry date
    if coupon.expiry_date and coupon.expiry_date < (os.time() * 1000) then
        return {valid = false, message = "Coupon has expired"}
    end
    
    -- Check max uses
    if coupon.max_uses and coupon.current_uses >= coupon.max_uses then
        return {valid = false, message = "Coupon has reached maximum uses"}
    end
    
    -- Check if coupon allows financed purchases
    if not coupon.allow_finance and isFinanced then
        return {valid = false, message = "This coupon cannot be used with financed purchases"}
    end
    
    -- Determine which player to validate for
    local validationPlayerId = targetPlayerId or playerId
    local playerIdentifier = Framework.Server.GetPlayerIdentifier(validationPlayerId)
    
    if not playerIdentifier then
        return {valid = false, message = "Failed to get player info"}
    end
    
    -- Check per-player usage limit
    if coupon.per_player_limit then
        local playerUsageCount = MySQL.scalar.await([[
            SELECT COUNT(*) FROM dealership_coupon_usage 
            WHERE coupon_id = ? AND player_identifier = ?
        ]], {coupon.id, playerIdentifier})
        
        if playerUsageCount >= coupon.per_player_limit then
            return {valid = false, message = "You have reached the usage limit for this coupon"}
        end
    end
    
    -- Check vehicle restrictions
    if coupon.vehicle_restrictions then
        local vehicleRestrictions = json.decode(coupon.vehicle_restrictions)
        local vehicleAllowed = false
        
        for _, allowedVehicle in ipairs(vehicleRestrictions) do
            if allowedVehicle:lower() == vehicleModel:lower() then
                vehicleAllowed = true
                break
            end
        end
        
        if not vehicleAllowed then
            return {valid = false, message = "This coupon is not valid for this vehicle"}
        end
    end
    
    -- Check category restrictions
    if coupon.category_restrictions then
        local categoryRestrictions = json.decode(coupon.category_restrictions)
        local categoryAllowed = false
        
        for _, allowedCategory in ipairs(categoryRestrictions) do
            if allowedCategory == vehicleCategory then
                categoryAllowed = true
                break
            end
        end
        
        if not categoryAllowed then
            return {valid = false, message = "This coupon is not valid for this vehicle category"}
        end
    end
    
    -- Calculate discount
    local discount = 0
    if coupon.discount_type == "percent" then
        discount = vehiclePrice * (coupon.discount_value / 100)
    else
        discount = coupon.discount_value
    end
    
    -- Ensure discount doesn't exceed vehicle price
    discount = math.min(discount, vehiclePrice)
    
    return {
        valid = true,
        discount = discount,
        coupon = coupon
    }
end

--- Record coupon usage after a successful purchase
--- @param couponId number The coupon ID
--- @param playerIdentifier string The player identifier
--- @param vehicleModel string The vehicle model/spawn code
--- @param purchaseType string The purchase type (e.g., "buy", "gift")
--- @param isFinanced boolean Whether the purchase was financed
--- @param discountApplied number The discount amount applied
function Coupons.Server.RecordCouponUsage(couponId, playerIdentifier, vehicleModel, purchaseType, isFinanced, discountApplied)
    -- Insert usage record
    MySQL.insert.await([[
        INSERT INTO dealership_coupon_usage 
        (coupon_id, player_identifier, vehicle_spawn_code, purchase_type, was_financed, discount_applied, used_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]], {
        couponId,
        playerIdentifier,
        vehicleModel,
        purchaseType,
        isFinanced and 1 or 0,
        discountApplied,
        os.time() * 1000
    })
    
    -- Increment coupon usage count
    MySQL.update.await([[
        UPDATE dealership_coupons 
        SET current_uses = current_uses + 1
        WHERE id = ?
    ]], {couponId})
    
    DebugPrint("Coupon usage recorded", "debug", {
        couponId = couponId,
        player = playerIdentifier,
        vehicle = vehicleModel,
        discount = discountApplied
    })
end
