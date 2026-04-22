exports("Open", function()
    NUI:Open()
end)

RegisterNetEvent('qb-cityhall:client:open', function ()
    NUI:Open()
end)

exports["qb-target"]:AddCircleZone("btray3", vector3(-530.9622, -193.5702, 43.265419), 0.6,
    {
        name = "btray3",
        debugPoly = false,
        useZ = true
    },
    {
        options = {
            {
                event = "qb-judge:interact:stash",
                icon = "fas fa-circle",
                label = "Open Personal Locker",
                job = "judge",
            },
        },
        distance = 1.5
    }
)

exports["qb-target"]:AddCircleZone("btray13", vector3(-529.5663, -191.2635, 43.004779), 0.6,
    {
        name = "btray13",
        debugPoly = false,
        useZ = true
    },
    {
        options = {
            {
                event = "qb-bossmenu:client:OpenMenu",
                icon = "fas fa-circle",
                label = "Open Boss Menu",
                job = "judge",
            },
        },
        distance = 1.5
    }
)