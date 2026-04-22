local debugScenes = {
    cocaine_unpacking = {
        export = 'cocaine_job_play_scene',
        name = 'unpacking',
        label = 'Cocaine Unpacking Scene'
    },
    cocaine_cutting = {
        export = 'cocaine_job_play_scene',
        name = 'cutting',
        label = 'Cocaine Cutting Scene'
    },
    cocaine_packing = {
        export = 'cocaine_job_play_scene',
        name = 'packing',
        label = 'Cocaine Packing Scene'
    },
    counterfeit_money_place_paper = {
        export = 'counterfeit_money_play_scene',
        name = 'place_paper',
        label = 'Counterfeit Money Place Paper Scene'
    },
    counterfeit_money_cutting = {
        export = 'counterfeit_money_play_scene',
        name = 'cutting',
        label = 'Counterfeit Money Cutting Scene'
    },
    counterfeit_money_packing = {
        export = 'counterfeit_money_play_scene',
        name = 'packing',
        label = 'Counterfeit Money Packing Scene'
    },
    meth_cook = {
        export = 'meth_job_play_scene',
        name = 'cook',
        label = 'Meth Cook Scene'
    },
    meth_hammer = {
        export = 'meth_job_play_scene',
        name = 'hammer',
        label = 'Meth Hammer Scene'
    },
    meth_packing = {
        export = 'meth_job_play_scene',
        name = 'packing',
        label = 'Meth Packing Scene'
    },
    money_laundering_washing = {
        export = 'money_laundering_play_scene',
        name = 'washing',
        label = 'Money Laundering Wash Scene'
    },
    weed_gathering = {
        export = 'weed_job_play_scene',
        name = 'gathering',
        label = 'Weed Gathering Scene'
    },
    weed_packing = {
        export = 'weed_job_play_scene',
        name = 'packing',
        label = 'Weed Packing Scene'
    },
    weed_rolling = {
        export = 'weed_job_play_scene',
        name = 'rolling',
        label = 'Weed Rolling Scene'
    },
}

local function getSceneOptions()
    local options = {}
    for key, data in pairs(debugScenes) do
        table.insert(options, {
            label = data.label,
            value = key
        })
    end
    return options
end

local function parseVector3(str)
    local x, y, z = str:match('([^,]+),%s*([^,]+),%s*([^,]+)')
    if not x or not y or not z then return nil end
    return vector3(tonumber(x), tonumber(y), tonumber(z))
end

local function playDebugScene(sceneKey, coords, offset, rotation)
    local scene = debugScenes[sceneKey]
    if not scene then
        print('[DEBUG] Unknown scene: ' .. tostring(sceneKey))
        return
    end

    local sceneExport = scene.export
    if not sceneExport then
        print('[DEBUG] No export found for scene: ' .. tostring(sceneKey))
        return
    end

    print('[DEBUG] Scene: ' .. sceneKey)
    print(string.format('[DEBUG] Coords:  vector3(%.2f, %.2f, %.2f)', coords.x, coords.y, coords.z))
    print(string.format('[DEBUG] Offset:  vector3(%.2f, %.2f, %.2f)', offset.x, offset.y, offset.z))
    print(string.format('[DEBUG] Rotation: vector3(%.2f, %.2f, %.2f)', rotation.x, rotation.y, rotation.z))
    print('[DEBUG] Data copied to clipboard')

    local clipboardText = string.format(
        'coords = vector3(%.4f, %.4f, %.4f),\t\n' ..
        'offset = vector3(%.2f, %.2f, %.2f),\t\n' ..
        'rotation = vector3(%.1f, %.1f, %.1f)',
        coords.x, coords.y, coords.z,
        offset.x, offset.y, offset.z,
        rotation.x, rotation.y, rotation.z
    )

    lib.setClipboard(clipboardText)
    lib.notify({
        title = 'Scene Data',
        description = 'Coordinate information copied to clipboard!',
        type = 'success'
    })

    exports[shared.resource][scene.export](nil, scene.name, coords, offset, rotation)
end

local function getAdjustedRotationZ()
    local baseRot = GetEntityRotation(cache.ped, 2).z + 180.0
    if baseRot > 360.0 then baseRot = baseRot - 360.0 end
    return baseRot
end

local function sceneDebug()
    local sceneCoords = GetEntityCoords(cache.ped)

    if lib.progressActive() then
        ClearPedTasksImmediately(cache.ped)
        lib.cancelProgress()
    end

    local input = lib.inputDialog('Illegalpack - Scene Test', {
        {
            type = 'select',
            label = 'Scene',
            options = getSceneOptions(),
            required = true,
            name = 'scene'
        },
        {
            type = 'input',
            label = 'Coords (x, y, z)',
            placeholder = '0.0, 0.0, 0.0',
            required = true,
            name = 'coords',
            default = string.format('%.2f, %.2f, %.2f', sceneCoords.x, sceneCoords.y, sceneCoords.z)
        },
        {
            type = 'input',
            label = 'Offset (x, y, z)',
            placeholder = '0.0, 0.0, 0.0',
            default = '0.0, 0.0, 0.0',
            required = true,
            name = 'offset'
        },
        {
            type = "input",
            label = "Rotation (x, y, z)",
            name = "rotation",
            placeholder = "0.0, 0.0, 180.0",
            default = string.format('%.1f, %.1f, %.1f', 0.0, 0.0, getAdjustedRotationZ()),
            required = true,
        },

    })

    if not input then return end

    local coords = parseVector3(input[2])
    local offset = parseVector3(input[3])
    local rotation = parseVector3(input[4])

    if not coords or not offset or not rotation then
        print('[DEBUG] Format error. Please separate with ","')
        return
    end

    playDebugScene(input[1], coords, offset, rotation)
end

if Config.debug then
    RegisterCommand('scenedebug', sceneDebug)
end
