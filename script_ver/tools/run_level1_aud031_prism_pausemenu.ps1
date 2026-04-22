$ErrorActionPreference = 'Stop'

Set-Location 'c:/admirales/script_ver/script_ver'
$res = 'c:/admirales/script_ver/script_ver/quarantine/under-review/[resources]/prism_pausemenu'
$out = 'reports/audit_AUD-031_prism_pausemenu_2026-04-17_level1_scan.txt'
$all = Get-ChildItem -LiteralPath $res -Recurse -File

function Find-Matches {
    param(
        [string]$Regex,
        [string[]]$Exts
    )

    $set = $all | Where-Object { $Exts -contains $_.Extension.ToLower() }
    if (-not $set) {
        return @()
    }

    return $set | Select-String -Pattern $Regex -AllMatches -CaseSensitive:$false
}

$patterns = @(
    @{ Id = 'C-01'; Name = 'PerformHttpRequest'; Regex = 'PerformHttpRequest'; Exts = @('.lua', '.js') },
    @{ Id = 'C-02'; Name = 'PerformHttpRequestInternal'; Regex = 'PerformHttpRequestInternal'; Exts = @('.lua', '.js') },
    @{ Id = 'C-03'; Name = 'load/loadstring/assert(load)/RunString'; Regex = 'loadstring\s*\(|\bload\s*\(|assert\s*\(\s*load\s*\(|RunString\s*\('; Exts = @('.lua', '.js') },
    @{ Id = 'C-07'; Name = 'hex obfuscation'; Regex = '\\x[0-9a-fA-F]{2}'; Exts = @('.lua', '.js') },
    @{ Id = 'C-08'; Name = 'string.char'; Regex = 'string\.char\s*\('; Exts = @('.lua', '.js') },
    @{ Id = 'C-09'; Name = 'os.execute/io.popen/io.open/ExecuteCommand'; Regex = 'os\.execute\s*\(|io\.popen\s*\(|io\.open\s*\(|ExecuteCommand\s*\('; Exts = @('.lua', '.js') },
    @{ Id = 'A-01'; Name = 'hardcoded identifiers'; Regex = 'steam:|discord:|license:'; Exts = @('.lua', '.js') },
    @{ Id = 'A-04'; Name = 'hardcoded IPv4'; Regex = '\b\d{1,3}(?:\.\d{1,3}){3}\b'; Exts = @('.lua', '.js') },
    @{ Id = 'A-05'; Name = 'RegisterCommand'; Regex = 'RegisterCommand\s*\('; Exts = @('.lua') },
    @{ Id = 'A-06'; Name = 'RegisterNetEvent/CreateCallback'; Regex = 'RegisterNetEvent\s*\(|CreateCallback\s*\(|RegisterCallback\s*\('; Exts = @('.lua') },
    @{ Id = 'A-08'; Name = 'GetConvar'; Regex = 'GetConvar\s*\(|GetConvarInt\s*\('; Exts = @('.lua') },
    @{ Id = 'A-09'; Name = 'ExecuteCommand'; Regex = 'ExecuteCommand\s*\('; Exts = @('.lua') },
    @{ Id = 'M-01'; Name = 'possible SQL concatenation'; Regex = 'SELECT|INSERT|UPDATE|DELETE'; Exts = @('.lua') },
    @{ Id = 'M-02'; Name = 'innerHTML'; Regex = 'innerHTML'; Exts = @('.js', '.html') },
    @{ Id = 'M-03'; Name = 'eval/new Function'; Regex = 'eval\s*\(|new\s+Function\s*\('; Exts = @('.js', '.html') },
    @{ Id = 'M-05'; Name = 'CreateThread'; Regex = 'CreateThread\s*\(|Citizen\.CreateThread\s*\('; Exts = @('.lua') }
)

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('Reporte Nivel 1 - AUD-031 prism_pausemenu')
$lines.Add('Fecha: 2026-04-17')
$lines.Add("Ruta: $res")
$lines.Add("Total archivos: $($all.Count)")
$lines.Add('')

foreach ($p in $patterns) {
    $matches = Find-Matches -Regex $p.Regex -Exts $p.Exts
    $lines.Add(("[{0}] {1} -> {2}" -f $p.Id, $p.Name, $matches.Count))

    if ($matches.Count -gt 0) {
        foreach ($hit in ($matches | Select-Object -First 100)) {
            $rel = $hit.Path.Substring($res.Length + 1).Replace('\\', '/')
            $txt = ($hit.Line.Trim() -replace "`t", ' ')
            $lines.Add(("  - {0}:{1}: {2}" -f $rel, $hit.LineNumber, $txt))
        }
    }

    $lines.Add('')
}

$webFiles = $all | Where-Object { $_.Extension.ToLower() -in @('.html', '.js', '.css') }
$webHits = @()
if ($webFiles.Count -gt 0) {
    $webHits = $webFiles | Select-String -Pattern 'https?://' -AllMatches -CaseSensitive:$false
}
$lines.Add('[NUI-URL] External URL references')
$lines.Add(("Count -> {0}" -f $webHits.Count))
foreach ($hit in ($webHits | Select-Object -First 120)) {
    $rel = $hit.Path.Substring($res.Length + 1).Replace('\\', '/')
    $txt = ($hit.Line.Trim() -replace "`t", ' ')
    $lines.Add(("  - {0}:{1}: {2}" -f $rel, $hit.LineNumber, $txt))
}
$lines.Add('')

$badBins = Get-ChildItem -LiteralPath $res -Recurse -File | Where-Object { $_.Extension.ToLower() -in @('.exe', '.dll', '.bat', '.ps1', '.sh', '.cmd', '.vbs', '.msi', '.scr') }
$lines.Add('[R-01] Suspicious binaries')
$lines.Add(("Count -> {0}" -f $badBins.Count))
foreach ($b in $badBins) {
    $rel = $b.FullName.Substring($res.Length + 1).Replace('\\', '/')
    $lines.Add(("  - {0}" -f $rel))
}

$lines | Set-Content -LiteralPath $out -Encoding UTF8

Write-Output "LEVEL1_REPORT=$out"
Write-Output "LINE_COUNT=$($lines.Count)"
Get-Content -LiteralPath $out -TotalCount 120
