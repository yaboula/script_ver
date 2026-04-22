local mysqlModule = require("modules.mysql.server")
local profiles = {}

local function getLevelByExp(exp)
    local level = 1
    for index, requiredExp in pairs(Config.Levels) do
        if exp < requiredExp then
            return math.max(1, index - 1)
        end
        level = math.max(level, index)
    end
    return level
end

local function getNextLevelExp(exp)
    local nextExp = nil
    local maxExp = 0
    for _, requiredExp in pairs(Config.Levels) do
        if exp < requiredExp and (not nextExp or requiredExp < nextExp) then
            nextExp = requiredExp
        end
        maxExp = math.max(maxExp, requiredExp)
    end
    return nextExp or maxExp
end

local function getProfileByIdentifier(identifier)
    return profiles[identifier]
end

local function getPlayerIdentifier(source)
    return server.getPlayerIdentifier(source)
end

local function getProfileBySource(source)
    local identifier = getPlayerIdentifier(source)
    return getProfileByIdentifier(identifier)
end

Profile = {}

function Profile.loadDatabase()
    for identifier, profile in pairs(mysqlModule.loadProfiles()) do
        profile.level = getLevelByExp(profile.exp)
        profile.nextLevelExp = getNextLevelExp(profile.exp)
        profiles[identifier] = profile
    end
    return true
end

function Profile.getByIdentifier(identifier)
    return getProfileByIdentifier(identifier)
end

function Profile.getBySource(source)
    return getProfileBySource(source)
end

function Profile.create(source)
    local identifier = getPlayerIdentifier(source)
    if profiles[identifier] then
        lib.print.error(("Profile for %s already exists!"):format(identifier))
        return false
    end
    
    local name = server.getPlayerCharacterName(source)
    local profile = {
        level = 1,
        exp = 0,
        nextLevelExp = getNextLevelExp(0),
        name = name,
        source = source,
    }
    profiles[identifier] = profile
    mysqlModule.createPlayer(identifier, name)
    return profile
end

function Profile.giveExp(sourceOrIdentifier, exp)
    local profile
    if type(sourceOrIdentifier) == "number" then
        profile = getProfileBySource(sourceOrIdentifier)
    end
    
    if not profile then
        profile = getProfileByIdentifier(sourceOrIdentifier)
    end
    
    if not profile then
        return 0
    end
    
    profile.exp = profile.exp + exp
    profile.level = getLevelByExp(profile.exp)
    profile.nextLevelExp = getNextLevelExp(profile.exp)
    return profile.exp
end

function Profile.getLevel(sourceOrIdentifier)
    local profile
    if type(sourceOrIdentifier) == "number" then
        profile = getProfileBySource(sourceOrIdentifier)
    end
    
    if not profile then
        profile = getProfileByIdentifier(sourceOrIdentifier)
    end
    
    if profile and profile.level then
        return profile.level
    end
    return false
end

function Profile.update(source)
    local identifier = getPlayerIdentifier(source)
    local profile = profiles[identifier]
    if not profile then
        return false
    end
    profile.source = source
    TriggerClientEvent(_e("client:profile:onUpdate"), source, profile)
    mysqlModule.updateProfile(identifier, profile)
    return true
end

lib.callback.register(_e("server:profile:get"), function(source)
    if not server.load then
        while not server.load do
            Citizen.Wait(500)
        end
    end
    
    local profile = getProfileBySource(source)
    if not profile then
        profile = Profile.create(source)
    else
        if not profile.name then
            profile.name = server.getPlayerCharacterName(source)
        end
        profile.source = source
    end
    return profile
end)
