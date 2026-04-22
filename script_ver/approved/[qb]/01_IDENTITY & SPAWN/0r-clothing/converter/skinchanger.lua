local function exportHandler(exportName, func)
    AddEventHandler(('__cfx_export_skinchanger_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

exportHandler('GetSkin', function()
    local mySkin = nil
    TriggerCallback('0r-clothing:getSkin:server', function(skin)
        mySkin = skin
    end)
    while mySkin == nil do Citizen.Wait(500) end
    return mySkin
end)

AddEventHandler('skinchanger:getSkin', function(cb)
    local mySkin = nil
    TriggerCallback('0r-clothing:getSkin:server', function(skin)
        mySkin = skin
    end)
    while mySkin == nil do Citizen.Wait(500) end
    cb(mySkin)
end)