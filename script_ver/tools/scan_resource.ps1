#Requires -Version 5.1
<#
.SYNOPSIS
    Escáner de Seguridad Automatizado para Recursos FiveM/QBCore
    Proyecto Admirales — Protocolo de Seguridad v2.0

.DESCRIPTION
    Ejecuta un análisis estático de Nivel 1 sobre un recurso FiveM,
    buscando patrones conocidos de malware, backdoors y vulnerabilidades.
    Genera un reporte detallado con hallazgos categorizados por severidad.

.PARAMETER ResourcePath
    Ruta al directorio del recurso a escanear.

.PARAMETER OutputDir
    Directorio donde se guardará el reporte. Por defecto: .\reports

.PARAMETER Analyst
    Nombre del analista que ejecuta el escaneo.

.EXAMPLE
    .\scan_resource.ps1 -ResourcePath ".\quarantine\under-review\qb-banking" -Analyst "Admin"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$ResourcePath,

    [string]$OutputDir = "..\reports",

    [string]$Analyst = "No especificado"
)

# ============================================================
# CONFIGURACIÓN
# ============================================================
$ErrorActionPreference = "Continue"

# Verificar que el recurso existe
if (-not (Test-Path $ResourcePath)) {
    Write-Host "❌ ERROR: El directorio '$ResourcePath' no existe." -ForegroundColor Red
    exit 1
}

$resourceName = Split-Path $ResourcePath -Leaf
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportFile = Join-Path $OutputDir "scan_${resourceName}_${timestamp}.txt"

# Crear directorio de reportes
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# ============================================================
# CONTADORES
# ============================================================
$criticalCount = 0
$highCount = 0
$mediumCount = 0
$binaryCount = 0

# ============================================================
# FUNCIONES
# ============================================================
function Write-Section {
    param([string]$Title, [string]$Severity)
    $divider = "=" * 60
    $output = "`n$divider`n[$Severity] $Title`n$divider"
    $output | Out-File -Append -FilePath $reportFile -Encoding UTF8
    Write-Host $output -ForegroundColor $(switch($Severity) {
        "CRÍTICO" { "Red" }
        "ALTO"    { "Yellow" }
        "MEDIO"   { "Cyan" }
        default   { "White" }
    })
}

function Search-Pattern {
    param(
        [string]$PatternId,
        [string]$Pattern,
        [string]$Description,
        [string]$Severity,
        [string[]]$FileTypes = @("*.lua"),
        [switch]$CaseInsensitive
    )

    $header = "  [$PatternId] $Description"
    $header | Out-File -Append -FilePath $reportFile -Encoding UTF8

    $results = @()
    foreach ($ft in $FileTypes) {
        $files = Get-ChildItem -Path $ResourcePath -Recurse -Filter $ft -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            $lines = Get-Content $file.FullName -ErrorAction SilentlyContinue
            for ($i = 0; $i -lt $lines.Count; $i++) {
                $line = $lines[$i]
                $match = if ($CaseInsensitive) {
                    $line -imatch $Pattern
                } else {
                    $line -match $Pattern
                }
                if ($match) {
                    $relativePath = $file.FullName.Replace((Resolve-Path $ResourcePath).Path + "\", "")
                    $results += "    LÍNEA $($i+1) | $relativePath | $($line.Trim())"
                }
            }
        }
    }

    if ($results.Count -gt 0) {
        $statusLine = "  ⚠️  HALLAZGOS: $($results.Count) coincidencia(s)"
        $statusLine | Out-File -Append -FilePath $reportFile -Encoding UTF8
        Write-Host $header -ForegroundColor $(switch($Severity) {
            "CRÍTICO" { "Red" }
            "ALTO"    { "Yellow" }
            "MEDIO"   { "Cyan" }
        })
        Write-Host $statusLine -ForegroundColor Red

        foreach ($r in $results) {
            $r | Out-File -Append -FilePath $reportFile -Encoding UTF8
        }

        switch ($Severity) {
            "CRÍTICO" { $script:criticalCount += $results.Count }
            "ALTO"    { $script:highCount += $results.Count }
            "MEDIO"   { $script:mediumCount += $results.Count }
        }
    } else {
        $cleanLine = "  ✅ Limpio"
        $cleanLine | Out-File -Append -FilePath $reportFile -Encoding UTF8
    }

    "" | Out-File -Append -FilePath $reportFile -Encoding UTF8
}

# ============================================================
# INICIO DEL REPORTE
# ============================================================
$header = @"
╔══════════════════════════════════════════════════════════╗
║   REPORTE DE ESCANEO AUTOMATIZADO — Nivel 1             ║
║   Protocolo de Seguridad Admirales v2.0                  ║
╠══════════════════════════════════════════════════════════╣
║ Recurso:    $resourceName
║ Ruta:       $ResourcePath
║ Fecha:      $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
║ Analista:   $Analyst
╚══════════════════════════════════════════════════════════╝

"@

$header | Out-File -FilePath $reportFile -Encoding UTF8
Write-Host $header -ForegroundColor Cyan

# ============================================================
# HASH SHA-256 DEL RECURSO
# ============================================================
"HASHES SHA-256 DE ARCHIVOS:" | Out-File -Append -FilePath $reportFile -Encoding UTF8
Get-ChildItem -Path $ResourcePath -Recurse -File | ForEach-Object {
    $hash = (Get-FileHash $_.FullName -Algorithm SHA256).Hash
    $rel = $_.FullName.Replace((Resolve-Path $ResourcePath).Path + "\", "")
    "  $hash  $rel" | Out-File -Append -FilePath $reportFile -Encoding UTF8
}
"" | Out-File -Append -FilePath $reportFile -Encoding UTF8

# ============================================================
# ESCANEO: CATEGORÍA CRÍTICA (🔴)
# ============================================================
Write-Section -Title "EJECUCIÓN REMOTA Y OFUSCACIÓN" -Severity "CRÍTICO"

Search-Pattern -PatternId "C-01" `
    -Pattern "PerformHttpRequest" `
    -Description "PerformHttpRequest — Comunicación HTTP externa" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua", "*.js") `
    -CaseInsensitive

Search-Pattern -PatternId "C-03/04/05" `
    -Pattern "load\s*\(|loadstring\s*\(|assert\s*\(\s*load" `
    -Description "load/loadstring/assert(load) — Ejecución dinámica" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "C-06" `
    -Pattern "RunString" `
    -Description "RunString — Ejecución de string como código" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua", "*.js") `
    -CaseInsensitive

Search-Pattern -PatternId "C-07" `
    -Pattern '\\x[0-9a-fA-F]{2}' `
    -Description "Secuencias hexadecimales — Ofuscación" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "C-08" `
    -Pattern "string\.char\s*\(" `
    -Description "string.char() — Construcción dinámica de strings" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "C-09/10" `
    -Pattern "os\.execute\s*\(|io\.popen\s*\(" `
    -Description "os.execute/io.popen — Acceso al sistema operativo" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "C-11" `
    -Pattern "io\.open\s*\(" `
    -Description "io.open — Lectura/escritura de archivos" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "C-12" `
    -Pattern "debug\." `
    -Description "debug.* — Introspección del entorno Lua" `
    -Severity "CRÍTICO" `
    -FileTypes @("*.lua")

# ============================================================
# ESCANEO: CATEGORÍA ALTA (🟠)
# ============================================================
Write-Section -Title "BACKDOORS Y PRIVILEGIOS" -Severity "ALTO"

Search-Pattern -PatternId "A-01/02/03" `
    -Pattern 'steam:[\da-f]+|discord:\d+|license:[\da-f]+' `
    -Description "Identificadores hardcodeados (Steam/Discord/License)" `
    -Severity "ALTO" `
    -FileTypes @("*.lua") `
    -CaseInsensitive

Search-Pattern -PatternId "A-04" `
    -Pattern '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' `
    -Description "Direcciones IP hardcodeadas" `
    -Severity "ALTO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "A-05" `
    -Pattern "RegisterCommand" `
    -Description "RegisterCommand — Registro de comandos" `
    -Severity "ALTO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "A-06" `
    -Pattern "RegisterNetEvent" `
    -Description "RegisterNetEvent — Registro de eventos de red" `
    -Severity "ALTO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "A-08" `
    -Pattern "GetConvar" `
    -Description "GetConvar — Lectura de configuración del servidor" `
    -Severity "ALTO" `
    -FileTypes @("*.lua")

Search-Pattern -PatternId "A-09" `
    -Pattern "ExecuteCommand" `
    -Description "ExecuteCommand — Ejecución de comandos del servidor" `
    -Severity "ALTO" `
    -FileTypes @("*.lua")

# ============================================================
# ESCANEO: CATEGORÍA MEDIA (🟡)
# ============================================================
Write-Section -Title "VULNERABILIDADES Y MALAS PRÁCTICAS" -Severity "MEDIO"

Search-Pattern -PatternId "M-01" `
    -Pattern '\.\..*["''].*(?:SELECT|INSERT|UPDATE|DELETE)' `
    -Description "SQL por concatenación — Inyección SQL potencial" `
    -Severity "MEDIO" `
    -FileTypes @("*.lua") `
    -CaseInsensitive

Search-Pattern -PatternId "M-02" `
    -Pattern "innerHTML" `
    -Description "innerHTML — XSS potencial" `
    -Severity "MEDIO" `
    -FileTypes @("*.js", "*.html")

Search-Pattern -PatternId "M-03" `
    -Pattern "eval\s*\(" `
    -Description "eval() — Ejecución dinámica de JavaScript" `
    -Severity "MEDIO" `
    -FileTypes @("*.js", "*.html")

Search-Pattern -PatternId "M-05" `
    -Pattern "CreateThread.*while\s+true" `
    -Description "CreateThread sin Wait — Loop CPU potencial" `
    -Severity "MEDIO" `
    -FileTypes @("*.lua")

# ============================================================
# ESCANEO: ARCHIVOS SOSPECHOSOS
# ============================================================
Write-Section -Title "ARCHIVOS BINARIOS Y SOSPECHOSOS" -Severity "CRÍTICO"

$suspiciousExtensions = @("*.exe", "*.dll", "*.bat", "*.ps1", "*.sh", "*.cmd", "*.vbs", "*.msi", "*.scr")
$suspiciousFiles = @()

foreach ($ext in $suspiciousExtensions) {
    $found = Get-ChildItem -Path $ResourcePath -Recurse -Filter $ext -ErrorAction SilentlyContinue
    $suspiciousFiles += $found
}

if ($suspiciousFiles.Count -gt 0) {
    $binaryCount = $suspiciousFiles.Count
    "  ⚠️  ARCHIVOS SOSPECHOSOS DETECTADOS: $binaryCount" | Out-File -Append -FilePath $reportFile -Encoding UTF8
    Write-Host "  ⚠️  ARCHIVOS SOSPECHOSOS DETECTADOS: $binaryCount" -ForegroundColor Red
    foreach ($sf in $suspiciousFiles) {
        $rel = $sf.FullName.Replace((Resolve-Path $ResourcePath).Path + "\", "")
        "    ❌ $rel ($($sf.Length) bytes)" | Out-File -Append -FilePath $reportFile -Encoding UTF8
    }
    "  🔴 RECHAZO AUTOMÁTICO: Archivos binarios detectados (Criterio R-01)" | Out-File -Append -FilePath $reportFile -Encoding UTF8
} else {
    "  ✅ No se encontraron archivos binarios sospechosos" | Out-File -Append -FilePath $reportFile -Encoding UTF8
}

# ============================================================
# RESUMEN FINAL
# ============================================================
$decision = if ($binaryCount -gt 0 -or $criticalCount -gt 0) {
    "🔴 REQUIERE REVISIÓN MANUAL URGENTE (o RECHAZO)"
} elseif ($highCount -gt 0) {
    "🟠 REQUIERE REVISIÓN MANUAL"
} elseif ($mediumCount -gt 0) {
    "🟡 REVISIÓN RECOMENDADA"
} else {
    "🟢 SIN HALLAZGOS — Proceder con precaución a Nivel 2"
}

$summary = @"

╔══════════════════════════════════════════════════════════╗
║               RESUMEN DEL ESCANEO                        ║
╠══════════════════════════════════════════════════════════╣
║ Hallazgos Críticos (🔴):   $criticalCount
║ Hallazgos Altos    (🟠):   $highCount
║ Hallazgos Medios   (🟡):   $mediumCount
║ Archivos Binarios:         $binaryCount
╠══════════════════════════════════════════════════════════╣
║ DECISIÓN PRELIMINAR:
║ $decision
╚══════════════════════════════════════════════════════════╝

Reporte guardado en: $reportFile
"@

$summary | Out-File -Append -FilePath $reportFile -Encoding UTF8
Write-Host $summary -ForegroundColor $(if ($criticalCount -gt 0) { "Red" } elseif ($highCount -gt 0) { "Yellow" } else { "Green" })
