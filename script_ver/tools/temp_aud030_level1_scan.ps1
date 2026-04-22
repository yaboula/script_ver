$ErrorActionPreference = "Stop"
$resource = "quarantine/under-review/17mov_CharacterSystem"
$scan = "reports/audit_AUD-030_17mov_CharacterSystem_2026-04-17_level1_scan.txt"

"AUD-030 | 17mov_CharacterSystem | Level 1 Scan | $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Set-Content -Path $scan -Encoding UTF8
"Resource: $resource" | Add-Content -Path $scan
"" | Add-Content -Path $scan

function Run-Scan {
    param(
        [string]$Id,
        [string]$Desc,
        [string]$Pattern,
        [string[]]$Globs,
        [bool]$Regex = $true,
        [bool]$IgnoreCase = $true
    )

    "=== $Id | $Desc ===" | Add-Content -Path $scan

    $args = @("--no-heading", "--line-number")
    if ($IgnoreCase) { $args += "-i" }
    if ($Regex) {
        $args += "-e"
        $args += $Pattern
    } else {
        $args += "-F"
        $args += "-e"
        $args += $Pattern
    }

    foreach ($g in $Globs) {
        $args += "-g"
        $args += $g
    }

    $args += $resource

    $res = & rg @args 2>$null
    if ([string]::IsNullOrWhiteSpace($res)) {
        "(sin coincidencias)" | Add-Content -Path $scan
    } else {
        $res | Add-Content -Path $scan
    }

    "" | Add-Content -Path $scan
}

Run-Scan "C-01" "PerformHttpRequest" "PerformHttpRequest" @("*.lua", "*.js")
Run-Scan "C-02" "PerformHttpRequestInternal" "PerformHttpRequestInternal" @("*.lua", "*.js")
Run-Scan "C-03/C-04/C-05" "load/loadstring/assert(load" "load\(|loadstring\(|assert\(load" @("*.lua")
Run-Scan "C-06" "RunString" "RunString" @("*.lua", "*.js")
Run-Scan "C-07" "Hex obfuscation" "\\x[0-9a-fA-F]{2}" @("*.lua")
Run-Scan "C-08" "string.char(" "string\.char\(" @("*.lua")
Run-Scan "C-09/C-10/C-11" "os.execute/io.popen/io.open" "os\.execute\(|io\.popen\(|io\.open\(" @("*.lua")
Run-Scan "C-12" "debug.*" "debug\." @("*.lua")

Run-Scan "A-01/A-02/A-03" "steam/discord/license hardcoded" "steam:|discord:|license:" @("*.lua")
Run-Scan "A-04" "Hardcoded IPv4" "\b\d{1,3}(?:\.\d{1,3}){3}\b" @("*.lua", "*.js", "*.json")
Run-Scan "A-05/A-06" "RegisterCommand/RegisterNetEvent" "RegisterCommand|RegisterNetEvent" @("*.lua")
Run-Scan "A-08" "GetConvar/GetConvarInt" "GetConvar|GetConvarInt" @("*.lua")
Run-Scan "A-09" "ExecuteCommand" "ExecuteCommand" @("*.lua")

Run-Scan "M-01" "SQL concat pattern" '\.\.\s*[''"].*(SELECT|INSERT|UPDATE|DELETE)' @("*.lua")
Run-Scan "M-02/M-03/M-04" "innerHTML/eval/dangerouslySetInnerHTML" "innerHTML|eval\(|dangerouslySetInnerHTML" @("*.js", "*.html", "*.tsx", "*.jsx")
Run-Scan "M-05" "CreateThread/Citizen.CreateThread" "CreateThread|Citizen\.CreateThread" @("*.lua")

"LEVEL1_SCAN_FILE=$scan"
"LEVEL1_SCAN_SIZE=$((Get-Item $scan).Length)"
