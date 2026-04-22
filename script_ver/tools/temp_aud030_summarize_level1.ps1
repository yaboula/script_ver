$scan = "reports/audit_AUD-030_17mov_CharacterSystem_2026-04-17_level1_scan.txt"

if (-not (Test-Path -LiteralPath $scan)) {
    Write-Error "No existe el archivo de scan: $scan"
    exit 1
}

$sections = [ordered]@{}
$current = $null

Get-Content -LiteralPath $scan | ForEach-Object {
    $line = $_

    if ($line -match '^===\s*(.*?)\s*\|') {
        $current = $matches[1].Trim()
        if (-not $sections.Contains($current)) {
            $sections[$current] = 0
        }
        return
    }

    if ($null -eq $current) { return }
    if ([string]::IsNullOrWhiteSpace($line)) { return }
    if ($line -eq '(sin coincidencias)') { return }

    $sections[$current] = [int]$sections[$current] + 1
}

$sections.GetEnumerator() | ForEach-Object {
    "{0}={1}" -f $_.Key, $_.Value
}
