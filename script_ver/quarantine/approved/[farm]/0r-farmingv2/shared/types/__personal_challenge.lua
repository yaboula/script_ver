---@class PersonalChallenge
---@field id string
---@field label string
---@field description string
---@field objective PersonalChallengeObjective
---@field reward ChallengeReward
---@field currentLevel integer

---@class ChallengeReward
---@field exp integer
---@field money integer

---@class PersonalChallengeObjective
---@field label string
---@field targetName string | "any"
---@field type "planted" | "watered" | "harvested" | "harvested_bale"
---@field baseTarget integer -- Base target value
---@field target integer -- Target calculated for the current level
---@field progress integer
---@field scalingMultiplier number -- Increase multiplier for each level (e.g. 1.2 = 20% increase)
