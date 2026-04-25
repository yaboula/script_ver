



Interactions = Interactions or {}
Interactions.Client = Interactions.Client or {}
Interactions.Client.InstrPrmt = Interactions.Client.InstrPrmt or {}

-- Store the last prompt text to detect changes
local lastPromptText = nil

--- Build prompt text with keybinds
--- @param text string The main prompt text
--- @param keybinds table Optional array of keybind objects with {key, desc} fields
--- @param wasd string Optional WASD movement hint
--- @return string The formatted prompt text
local function BuildPromptText(text, keybinds, wasd)
    local promptText = text .. tostring(wasd or "")
    
    if keybinds then
        for _, keybind in ipairs(keybinds) do
            promptText = promptText .. keybind.key .. keybind.desc
        end
    end
    
    return promptText
end

--- Show an instructional prompt
--- @param text string The main prompt text to display
--- @param keybinds table Optional array of keybind objects with {key, desc} fields
--- @param wasd string Optional WASD movement hint
--- @param error boolean Optional flag to show error styling
function Interactions.Client.InstrPrmt.Show(text, keybinds, wasd, error)
    local promptText = BuildPromptText(text, keybinds, wasd)
    
    -- Play sound only if the prompt text has changed
    if promptText ~= lastPromptText then
        PlaySoundFrontend(-1, "OTHER_TEXT", "HUD_AWARDS", false)
        lastPromptText = promptText
    end
    
    -- Send to NUI
    SendNUIMessage({
        type = "showInstrPrmt",
        text = text,
        keybinds = keybinds,
        wasd = wasd,
        error = error
    })
end

--- Hide the instructional prompt
function Interactions.Client.InstrPrmt.Hide()
    lastPromptText = nil
    
    SendNUIMessage({
        type = "hideInstrPrmt"
    })
end
