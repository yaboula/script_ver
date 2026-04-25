



--- NUI Callback: Get coupons for a dealership
RegisterNUICallback("get-coupons", function(data, cb)
    cb(lib.callback.await("jg-dealerships:server:get-coupons", false, data))
end)

--- NUI Callback: Create a new coupon
RegisterNUICallback("create-coupon", function(data, cb)
    cb(lib.callback.await("jg-dealerships:server:create-coupon", false, data))
end)

--- NUI Callback: Update an existing coupon
RegisterNUICallback("update-coupon", function(data, cb)
    cb(lib.callback.await("jg-dealerships:server:update-coupon", false, data))
end)

--- NUI Callback: Delete a coupon
RegisterNUICallback("delete-coupon", function(data, cb)
    cb(lib.callback.await("jg-dealerships:server:delete-coupon", false, data))
end)

--- NUI Callback: Generate a random coupon code
RegisterNUICallback("generate-coupon-code", function(data, cb)
    cb(lib.callback.await("jg-dealerships:server:generate-coupon-code", false, data))
end)

--- NUI Callback: Validate a coupon code
RegisterNUICallback("validate-coupon", function(data, cb)
    cb(lib.callback.await("jg-dealerships:server:validate-coupon", false, data))
end)
