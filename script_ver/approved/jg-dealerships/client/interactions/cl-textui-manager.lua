



-- Namespace initialization
Interactions = Interactions or {}
Interactions.Client = Interactions.Client or {}
Interactions.Client.TextUIManager = Interactions.Client.TextUIManager or {}

-- Module reference
local TextUIManager = Interactions.Client.TextUIManager

-- Internal state
local activeEntries   = {}   -- id -> { text, key, callback, priority }
local currentShownId  = nil  -- id of the currently displayed TextUI
local isVisible       = false
local cooldowns       = {}   -- id -> last callback fire timestamp
local COOLDOWN_MS     = 300  -- minimum ms between repeated key callbacks

-- Show a TextUI entry by id
function TextUIManager.Show(id, text, key, callback)
    activeEntries[id] = {
        text     = text,
        key      = key,
        callback = callback,
        priority = GetGameTimer(),
    }
    UpdateDisplay()
end

-- Hide a TextUI entry by id
function TextUIManager.Hide(id)
    if not id then return end
    activeEntries[id] = nil
    cooldowns[id]     = nil
    UpdateDisplay()
end

-- Returns whether any TextUI is currently visible
function TextUIManager.IsActive()
    return isVisible
end

-- Returns whether the given id is the one currently being shown
function TextUIManager.IsShowingId(id)
    return currentShownId == id
end

-- Hides all TextUI entries and resets state
function TextUIManager.ForceHideAll()
    if isVisible then
        Framework.Client.HideTextUI()
    end
    activeEntries  = {}
    currentShownId = nil
    isVisible      = false
    cooldowns      = {}
end

-- Picks the highest-priority (most recently registered) entry and shows it.
-- Hides the UI if no entries remain.
function UpdateDisplay()
    local bestId   = nil
    local bestData = nil

    for id, data in pairs(activeEntries) do
        if bestId == nil or data.priority > bestData.priority then
            bestId   = id
            bestData = data
        end
    end

    if bestId then
        -- Only update if the displayed entry has changed
        if currentShownId ~= bestId then
            if isVisible then
                Framework.Client.HideTextUI()
            end
            Framework.Client.ShowTextUI(bestData.text)
            currentShownId = bestId
            isVisible      = true
        end
    else
        -- Nothing left to show
        if isVisible then
            Framework.Client.HideTextUI()
            currentShownId = nil
            isVisible      = false
        end
    end
end

-- Key-press polling thread
CreateThread(function()
    while true do
        Wait(0)

        if isVisible and currentShownId then
            local entry = activeEntries[currentShownId]

            if entry then
                local now = GetGameTimer()

                if IsControlJustReleased(0, entry.key) then
                    local lastFired = cooldowns[currentShownId] or 0

                    if (now - lastFired) > COOLDOWN_MS then
                        cooldowns[currentShownId] = now

                        local ok, err = pcall(entry.callback)
                        if not ok then
                            print("[TextUIManager] Error in callback:", err)
                        end
                    end
                end
            end
        else
            Wait(100) -- idle wait when nothing is shown
        end
    end
end)

-- Clean up on resource stop
AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Interactions.Client.TextUIManager.ForceHideAll()
    end
end)

-- Export for external resources
exports("ForceHideTextUI", function()
    Interactions.Client.TextUIManager.ForceHideAll()
end)