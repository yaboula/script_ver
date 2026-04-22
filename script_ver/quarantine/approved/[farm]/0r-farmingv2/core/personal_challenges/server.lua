local config = lib.load("core.personal_challenges.config")
local mysqlModule = require("modules.mysql.server")
local inventoryModule = require("modules.inventory.server")

PersonalChallengesServer = {}
PersonalChallengesServer.playerChallenges = {}

function PersonalChallengesServer.loadPlayerChallenges(source)
    local identifier = server.getPlayerIdentifier(source)
    if not identifier then
        return {}
    end
    
    local dbChallenges = mysqlModule.getPersonalChallenges(identifier)
    local challenges = {}
    
    for _, template in pairs(config.challengeTemplates) do
        local dbChallenge = nil
        if dbChallenges then
            for _, db in pairs(dbChallenges) do
                if db.challenge_id == template.id then
                    dbChallenge = db
                    break
                end
            end
        end
        
        local challenge = lib.table.deepclone(template)
        challenge.currentLevel = 1
        if dbChallenge then
            challenge.currentLevel = dbChallenge.current_level
            challenge.objective.target = PersonalChallengesServer.calculateTarget(
                challenge.objective.baseTarget,
                challenge.currentLevel,
                challenge.objective.scalingMultiplier
            )
            challenge.objective.progress = dbChallenge.progress or 0
            challenge.reward.exp = math.floor(challenge.reward.exp * (config.rewardScaling.expMultiplier ^ (challenge.currentLevel - 1)))
            challenge.reward.money = math.floor(challenge.reward.money * (config.rewardScaling.moneyMultiplier ^ (challenge.currentLevel - 1)))
        else
            challenge.objective.target = challenge.objective.baseTarget
            challenge.objective.progress = 0
        end
        challenges[challenge.id] = challenge
    end
    
    PersonalChallengesServer.playerChallenges[source] = challenges
    return challenges
end

function PersonalChallengesServer.calculateTarget(baseTarget, level, multiplier)
    return math.floor(baseTarget * (multiplier ^ (level - 1)))
end

function PersonalChallengesServer.saveChallengeToDatabase(identifier, challenge)
    local progress = 0
    if challenge.objective then
        progress = challenge.objective.progress
    end
    
    if mysqlModule.getPersonalChallenge(identifier, challenge.id) then
        mysqlModule.updatePersonalChallenge(identifier, challenge.id, challenge.currentLevel, progress)
    else
        mysqlModule.insertPersonalChallenge(identifier, challenge.id, challenge.currentLevel, progress)
    end
end

function PersonalChallengesServer.giveReward(source, reward)
    if reward.money > 0 then
        if Config.CleanMoney.isItem then
            inventoryModule.giveItem(source, Config.CleanMoney.itemName, reward.money)
        else
            server.playerAddMoney(source, Config.CleanMoney.accountName, reward.money)
        end
    end
    
    if reward.exp > 0 then
        Profile.giveExp(source, reward.exp)
        Profile.update(source)
    end
end

function PersonalChallengesServer.checkChallengeCompletion(source, challengeId)
    local challenges = PersonalChallengesServer.playerChallenges[source]
    if not challenges then
        return
    end
    
    local challenge = challenges[challengeId]
    if not challenge then
        return
    end
    
    if challenge.objective.progress >= challenge.objective.target then
        PersonalChallengesServer.giveReward(source, challenge.reward)
        TriggerClientEvent(_e("client:personal_challenges:challengeCompleted"), source, {
            challengeId = challengeId,
            reward = challenge.reward,
            newLevel = challenge.currentLevel + 1,
        })
        PersonalChallengesServer.prepareChallengeForNextLevel(source, challengeId)
        shared.debug("Challenge completed:", challengeId, "Level:", challenge.currentLevel)
    end
end

function PersonalChallengesServer.prepareChallengeForNextLevel(source, challengeId)
    local challenges = PersonalChallengesServer.playerChallenges[source]
    if not challenges then
        return
    end
    
    local challenge = challenges[challengeId]
    if not challenge then
        return
    end
    
    challenge.currentLevel = challenge.currentLevel + 1
    challenge.objective.target = PersonalChallengesServer.calculateTarget(
        challenge.objective.baseTarget,
        challenge.currentLevel,
        challenge.objective.scalingMultiplier
    )
    challenge.objective.progress = 0
    
    local template = nil
    for _, t in pairs(config.challengeTemplates) do
        if t.id == challengeId then
            template = t
            break
        end
    end
    
    if template then
        challenge.reward.exp = math.floor(template.reward.exp * (config.rewardScaling.expMultiplier ^ (challenge.currentLevel - 1)))
        challenge.reward.money = math.floor(template.reward.money * (config.rewardScaling.moneyMultiplier ^ (challenge.currentLevel - 1)))
    end
    
    TriggerClientEvent(_e("client:personal_challenges:challengeUpdated"), source, challenge)
end

function PersonalChallengesServer.updateChallengeProgress(source, challengeId, targetName, actionType)
    local challenges = PersonalChallengesServer.playerChallenges[source]
    if not challenges then
        return
    end
    
    local challenge = challenges[challengeId]
    if not challenge then
        return
    end
    
    local amount = 1
    local oldProgress = challenge.objective.progress
    challenge.objective.progress = math.min(challenge.objective.progress + amount, challenge.objective.target)
    
    if oldProgress < challenge.objective.progress then
        TriggerClientEvent(_e("client:personal_challenges:progressUpdate"), source, {
            challengeId = challengeId,
            progress = challenge.objective.progress,
        })
        shared.debug("Challenge progress updated:", challengeId, challenge.objective.progress, "/", challenge.objective.target)
    end
    
    if challenge.objective.progress >= challenge.objective.target then
        PersonalChallengesServer.checkChallengeCompletion(source, challengeId)
    end
end

function PersonalChallengesServer.onFarmingActionTriggered(source, targetName, actionType)
    Citizen.CreateThread(function()
        local challenges = PersonalChallengesServer.playerChallenges[source]
        if not challenges then
            return
        end
        
        for challengeId, challenge in pairs(challenges) do
            if challenge.objective.type == actionType then
                if challenge.objective.targetName == "any" or challenge.objective.targetName == targetName then
                    PersonalChallengesServer.updateChallengeProgress(source, challengeId, targetName, actionType)
                end
            end
        end
    end)
end

function PersonalChallengesServer.onPlayerUnloaded(source)
    local challenges = PersonalChallengesServer.playerChallenges[source]
    if challenges then
        local identifier = server.getPlayerIdentifier(source)
        if identifier then
            for _, challenge in pairs(challenges) do
                if challenge.objective and challenge.objective.progress and challenge.objective.progress > 0 then
                    PersonalChallengesServer.saveChallengeToDatabase(identifier, challenge)
                end
            end
        end
    end
    PersonalChallengesServer.playerChallenges[source] = nil
end

function PersonalChallengesServer.saveAllChallenges()
    for source, challenges in pairs(PersonalChallengesServer.playerChallenges) do
        local identifier = server.getPlayerIdentifier(source)
        if identifier then
            for _, challenge in pairs(challenges) do
                if challenge.objective and challenge.objective.progress and challenge.objective.progress > 0 then
                    PersonalChallengesServer.saveChallengeToDatabase(identifier, challenge)
                end
            end
        end
    end
    shared.debug("All personal challenges saved to database.")
end

lib.callback.register(_e("server:personal_challenges:getPlayerChallenges"), function(source)
    return PersonalChallengesServer.loadPlayerChallenges(source)
end)

lib.cron.new("*/5 * * * *", function()
    PersonalChallengesServer.saveAllChallenges()
end, {
    debug = Config.debug,
})
