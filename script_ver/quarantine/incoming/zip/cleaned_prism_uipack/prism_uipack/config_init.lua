-- shared file used to retrieve config values
-- used by our version of ox_target to retrieve the primary color

RegisterNuiCallback('getConfig', function(data, cb)
    cb({
        primaryColor = GetConvar('prism:primaryColor', 'FFEE1111'),
        notificationDuration = GetConvarInt('prism:notificationDuration', 3000),
        progressCancelKey = GetConvar('prism:progressCancelKey', 'X')
    })
end)

RegisterNuiCallback('getConfigValue', function(property, cb)
    if not property then return end

    local propertyValue = GetConvar(("prism:%s"):format(property), '')
    cb(propertyValue)
end)