



local RESOURCE_NAME = "jg-dealerships"
local VERSION_URL   = "https://raw.githubusercontent.com/jgscripts/versions/main/" .. RESOURCE_NAME .. ".txt"

--- Compares two dot-separated version strings (e.g. "1.2.3").
--- Returns true if `latest` is strictly newer than `current`.
---@param current string  The installed version string (leading "v" is stripped).
---@param latest  string  The remote version string (leading "v" is stripped).
---@return boolean
local function isNewerVersion(current, latest)
    local currentParts = {}
    for part in string.gmatch(current, "[^.]+") do
        table.insert(currentParts, tonumber(part))
    end

    local latestParts = {}
    for part in string.gmatch(latest, "[^.]+") do
        table.insert(latestParts, tonumber(part))
    end

    local length = math.max(#currentParts, #latestParts)
    for i = 1, length do
        local c = currentParts[i] or 0
        local l = latestParts[i] or 0
        if c < l then
            return true
        elseif c > l then
            return false
        end
    end

    return false
end

--- HTTP callback for the resource version check.
--- Compares the installed version against the latest published version and
--- prints a notice to the console when an update is available.
---@param statusCode  number  HTTP response status code.
---@param body        string  Response body containing the latest version string.
---@param headers     table   HTTP response headers.
---@param errorData   string  Error information if request failed.
local function onVersionCheckResponse(statusCode, body, headers, errorData)
    if statusCode ~= 200 then
        print("^1[" .. RESOURCE_NAME .. "] Unable to perform update check (HTTP " .. tostring(statusCode) .. ")")
        if errorData then
            print("^1[" .. RESOURCE_NAME .. "] Error: " .. tostring(errorData) .. "^0")
        end
        return
    end

    if not body or body == "" then
        print("^1[" .. RESOURCE_NAME .. "] Update check failed: Empty response^0")
        return
    end

    local installedVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    if not installedVersion then
        print("^1[" .. RESOURCE_NAME .. "] Could not retrieve installed version^0")
        return
    end

    -- Skip version check when running a development build.
    if installedVersion == "dev" then
        print("^3[" .. RESOURCE_NAME .. "] Using dev version^0")
        return
    end

    -- Extract the first line of the response body as the latest version.
    local latestVersion = body:match("^[^\n]+")
    if not latestVersion then
        print("^1[" .. RESOURCE_NAME .. "] Could not parse version from response^0")
        return
    end

    -- Strip the leading "v" from both strings before comparing.
    local currentVer = installedVersion:match("^v?(.+)") or installedVersion
    local latestVer = latestVersion:match("^v?(.+)") or latestVersion
    
    if isNewerVersion(currentVer, latestVer) then
        print(
            "^3[" .. RESOURCE_NAME .. "] Update available! " ..
            "(current: ^1" .. installedVersion ..
            "^3, latest: ^2" .. latestVersion .. "^3)^0"
        )
        print("^3[" .. RESOURCE_NAME .. "] Release notes: discord.gg/jgscripts^0")
    else
        print("^2[" .. RESOURCE_NAME .. "] Version up to date (" .. installedVersion .. ")^0")
    end
end

-- Kick off the resource update check immediately at startup.
CreateThread(function()
    PerformHttpRequest(VERSION_URL, onVersionCheckResponse, "GET")
end)

--- Checks whether the running FXServer artifact version has known issues.
--- Prints a prominent warning to the console if a broken artifact is detected.
local function checkArtifactVersion()
    -- Parse the build number from the server's "version" convar (e.g. "v1.2.3.4567").
    local serverVersion = GetConvar("version", "unknown")
    local buildNumber   = string.match(serverVersion, "v%d+%.%d+%.%d+%.(%d+)")

    if not buildNumber then
        print("^3[" .. RESOURCE_NAME .. "] Could not parse server build number from version: " .. serverVersion .. "^0")
        return
    end

    local artifactCheckUrl = "https://artifacts.jgscripts.com/check?artifact=" .. buildNumber

    PerformHttpRequest(artifactCheckUrl, function(statusCode, body, _, errorData)
        if statusCode ~= 200 then
            print("^1[" .. RESOURCE_NAME .. "] Could not check artifact version (HTTP " .. tostring(statusCode) .. ")^0")
            if errorData then
                print("^1[" .. RESOURCE_NAME .. "] Error: " .. tostring(errorData) .. "^0")
            end
            return
        end

        if not body or body == "" then
            print("^1[" .. RESOURCE_NAME .. "] Artifact check failed: Empty response^0")
            return
        end

        local success, data = pcall(json.decode, body)
        if not success then
            print("^1[" .. RESOURCE_NAME .. "] Failed to parse artifact check response^0")
            return
        end

        if not data then
            print("^1[" .. RESOURCE_NAME .. "] Invalid artifact check response^0")
            return
        end

        if data.status == "BROKEN" then
            print(
                "^1WARNING: The current FXServer version you are using (artifacts version) has known issues. " ..
                "Please update to the latest stable artifacts: https://artifacts.jgscripts.com^0"
            )
            print("^0Artifact version:^3", serverVersion, "\n^0Known issues:^3", data.reason or "Unknown", "^0")
        elseif data.status == "OK" then
            print("^2[" .. RESOURCE_NAME .. "] Server artifact version is OK (" .. serverVersion .. ")^0")
        end
    end)
end

-- Run the artifact version check inside a thread so it doesn't block startup.
CreateThread(function()
    Wait(1000) -- Wait 1 second to avoid potential startup race conditions
    checkArtifactVersion()
end)
