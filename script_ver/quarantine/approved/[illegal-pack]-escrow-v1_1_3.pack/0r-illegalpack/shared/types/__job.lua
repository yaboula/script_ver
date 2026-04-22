---@class Job
---@field active boolean -- if the job is currently active
---@field label string -- the label of the job
---@field description string -- the description of the job
---@field reward JobReward -- the reward for completing the job
---@field image string -- the image of the job
---@field information string -- additional information about the job
---@field level number -- the level required to start the job
---@field steps JobStep[] -- the steps required to complete the job
---@field requiredItems RequiredItem[] -- the items required to start the job
---@field name string -- the key name of the job
---@field game table
---@field blips table
---@field cooldown number -- the cooldown time for the job in seconds
---@field requiredJobName string -- the name of the job required to start this job
---@field requiredGangName string -- the name of the gang required to start this job
---@field teamSize TeamSize -- the size of the team required to start the job
---@field requiredMinCopCount number -- the minimum number of police officers required to start the job

---@class TeamSize
---@field min number -- minimum number of players required to start the job
---@field max number -- maximum number of players allowed to start the job

---@class JobReward
---@field exp number -- the experience points rewarded for completing the job
---@field money number -- the money rewarded for completing the job
---@field unshared_amount number -- the amount of unshared money rewarded for completing the job
---@field items RewardItem[] -- the items rewarded for completing the job

---@class JobStepProgress
---@field target number -- the target progress for the step
---@field current number -- the current progress made in the step

---@class JobStep
---@field index number -- the index of the step in the job
---@field label string -- the label of the step
---@field progress JobStepProgress -- the progress of the step
---@field done boolean -- if the step is completed
---@field timeLimit number -- the time limit for completing the step in seconds
---@field endTime number -- the end time for the step in seconds since epoch

---@class RequiredItem
---@field label string -- the label of the required item
---@field itemName string -- the name of the required item
---@field count number -- the number of required items

---@class RewardItem
---@field itemName string -- the name of the rewarded item
---@field count number -- the number of rewarded items
