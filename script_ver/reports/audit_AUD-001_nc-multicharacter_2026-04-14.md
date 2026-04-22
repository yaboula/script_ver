# Reporte de Auditoría de Seguridad — AUD-001

> **Actualización de estado (2026-04-15):** este reporte corresponde al diagnóstico inicial.
> El cierre final y estado operativo aprobado están documentados en
> `reports/audit_AUD-019_nc-multicharacter_closure_2026-04-15.md`.

## `nc-multicharacter`

---

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-001` |
| **Recurso** | `nc-multicharacter` |
| **Fecha de Auditoría** | 2026-04-14 |
| **Analista** | Antigravity (IA — Equipo de Seguridad) |
| **Origen** | Descarga gratuita — Fuente no oficial (NCHub / Discord.gg/sgx / Patreon) |
| **Clasificación de Origen** | 🟠 **Riesgo Elevado** — Script gratuito de origen no verificado |
| **Versión del Recurso** | v2.0 Beta ("Special Edition") |

---

## Inventario de Archivos

| Archivo | Tamaño | SHA-256 |
|:---|---:|:---|
| `fxmanifest.lua` | 965 B | `A1183549E5FC...` |
| `config.lua` | 1,385 B | `F2CC7B0F4C67...` |
| `ReadMe.txt` | 779 B | `079565A55AA6...` |
| `client/main.lua` | 8,064 B | `C0E4DA081566...` |
| `server/main.lua` | 8,667 B | `578B3CA039F7...` |
| `html/index.html` | 5,017 B | `E51CD0B8322C...` |
| `html/css/reset.css` | 1,059 B | `D43DF0379D4A...` |
| `html/css/style.css` | 30,086 B | `36B62C99...` |
| `html/js/script.js` | 23,194 B | `6ED1641275EC...` |
| `html/image/action_dot.gif` | 131,513 B | `35F62D88B009...` |
| `html/image/action_key.png` | 3,309 B | `A67DFFA68352...` |
| `locales/en.lua` | 2,026 B | `0C0DB6B7785A...` |

**Total:** 12 archivos, 0 archivos binarios sospechosos (.exe, .dll, .bat, etc.)

---

## NIVEL 1 — Escaneo Automatizado de Patrones

### 🔴 Categoría CRÍTICA — Ejecución Remota y Ofuscación

| Patrón | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---:|
| `PerformHttpRequest` | C-01 | **0** | ✅ Limpio |
| `PerformHttpRequestInternal` | C-02 | **0** | ✅ Limpio |
| `load(` / `loadstring(` | C-03/04 | **0** | ✅ Limpio |
| `assert(load(` | C-05 | **0** | ✅ Limpio |
| `RunString(` | C-06 | **0** | ✅ Limpio |
| Secuencias hexadecimales `\x` | C-07 | **0** | ✅ Limpio |
| `string.char(` | C-08 | **0** | ✅ Limpio |
| `os.execute(` | C-09 | **0** | ✅ Limpio |
| `io.popen(` | C-10 | **0** | ✅ Limpio |
| `io.open(` | C-11 | **0** | ✅ Limpio |
| `debug.*` | C-12 | **0** | ✅ Limpio |

> **✅ RESULTADO: SIN HALLAZGOS CRÍTICOS.** No se detectó malware, RATs, ofuscación, ni acceso al sistema operativo.

---

### 🟠 Categoría ALTA — Backdoors y Privilegios

| Patrón | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---:|
| Identificadores hardcodeados (`steam:`, `discord:`, `license:`) | A-01/02/03 | **1** | ⚠️ **Revisar** |
| IPs hardcodeadas | A-04 | **0** | ✅ Limpio |
| `RegisterCommand` | A-05 | **0** (usa `QBCore.Commands.Add`) | ✅ Limpio |
| `RegisterNetEvent` | A-06 | **5** | ⚠️ **Revisar** |
| `GetConvar` | A-08 | **0** | ✅ Limpio |
| `ExecuteCommand` | A-09 | **0** | ✅ Limpio |

#### Detalle A-01: Identificador Hardcodeado

| Archivo | Línea | Código |
|:---|:---:|:---|
| `config.lua` | 11 | `license = "license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"` |

**Análisis:** Es un placeholder/ejemplo dentro de `Config.PlayersNumberOfCharacters`. El formato `xxxxxxx` confirma que es un template, **NO** un backdoor de acceso.

**Veredicto:** 🟢 **Falso positivo** — Es un ejemplo configurable. Sin riesgo.

---

#### Detalle A-06: Eventos de Red Registrados

| # | Evento | Archivo | Línea | ¿Source validado? | ¿Datos validados? |
|:---:|:---|:---|:---:|:---:|:---:|
| 1 | `nc-multicharacter:server:disconnect` | `server/main.lua` | 74 | ✅ Sí | N/A |
| 2 | `nc-multicharacter:server:loadUserData` | `server/main.lua` | 79 | ✅ Sí | ⚠️ **NO** |
| 3 | `nc-multicharacter:server:createCharacter` | `server/main.lua` | 103 | ✅ Sí | ⚠️ **NO** |
| 4 | `nc-multicharacter:server:deleteCharacter` | `server/main.lua` | 142 | ✅ Sí | ⚠️ **NO** |
| 5 | `nc-multicharacter:server:GetServerLogs` (callback) | `server/main.lua` | 175 | — | 🔴 **PROBLEMA** |

---

### 🟡 Categoría MEDIA — Vulnerabilidades y Malas Prácticas

| Patrón | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---:|
| SQL por concatenación | M-01 | **0** | ✅ Limpio |
| `innerHTML` | M-02 | **0** | ✅ (usa jQuery `.html()`) |
| `eval()` | M-03 | **0** | ✅ Limpio |
| `CreateThread` sin `Wait` | M-05 | **1** | ⚠️ Revisar |
| Variables globales | M-06 | **2+** | ⚠️ Revisar |

---

## NIVEL 2 — Revisión Manual Profunda

### 📋 Auditoría del Manifiesto (`fxmanifest.lua`)

| # | Verificación | Estado | Notas |
|:---:|:---|:---:|:---|
| F-01 | `fx_version 'cerulean'` | ✅ | Versión actual |
| F-02 | `game 'gta5'` | ✅ | Correcto |
| F-03 | `client_scripts` verificados | ✅ | Solo `client/main.lua` — existe |
| F-04 | `server_scripts` verificados | ✅ | `server/main.lua` — existe. Incluye `@oxmysql` y `@qb-apartments/config.lua` |
| F-05 | No hay archivos no declarados | ✅ | Todos los `.lua` están declarados |
| F-06 | **No se usan wildcards** | ⚠️ | **SÍ usa wildcards**: `'locales/*.lua'` (línea 18), `'html/image/*.png'`, `'html/image/*.gif'`, `"html/js/*"`, `'html/css/*'` |
| F-07 | `files` solo contiene assets legítimos | ✅ | Solo HTML, CSS, JS, imágenes |
| F-08 | `dependencies` verificadas | ✅ | Solo `qb-core` (recurso conocido) |
| F-09 | No hay `loadscreen` sospechoso | ✅ | No tiene loadscreen |
| F-10 | No hay `data_file` con path traversal | ✅ | No tiene data_file |

> ⚠️ **F-06 NOTA:** El uso de wildcards en `locales/*.lua` permite que cualquier archivo `.lua` insertado en esa carpeta se ejecute automáticamente.

---

### 🔐 Análisis de Seguridad de Eventos

#### Hallazgo 1 — 🟠 ALTA: Falta de validación de datos en eventos server-side

**Evento: `nc-multicharacter:server:loadUserData`** (server/main.lua:79)

```lua
RegisterNetEvent('nc-multicharacter:server:loadUserData', function(cData)
    local src = source
    if QBCore.Player.Login(src, cData.citizenid) then
```

**Problema:** `cData.citizenid` viene directamente del cliente sin validación. QBCore.Player.Login verifica internamente la propiedad, mitigando parcialmente, pero la práctica es incorrecta.

**Evento: `nc-multicharacter:server:createCharacter`** (server/main.lua:103) — Datos del formulario sin validar tipo/rango.

**Evento: `nc-multicharacter:server:deleteCharacter`** (server/main.lua:142) — citizenid sin validar tipo.

---

#### Hallazgo 2 — 🔴 ALTA: Callback expone logs del servidor sin autenticación

**Callback: `nc-multicharacter:server:GetServerLogs`** (server/main.lua:175)

```lua
QBCore.Functions.CreateCallback("nc-multicharacter:server:GetServerLogs", function(_, cb)
    MySQL.query('SELECT * FROM server_logs', {}, function(result)
        cb(result)
    end)
end)
```

**⚠️ HALLAZGO CRÍTICO:** Este callback devuelve **TODOS los logs del servidor** (`SELECT * FROM server_logs`) a **CUALQUIER cliente** que lo solicite, sin verificación de permisos.

**Severidad:** 🔴 **ALTA**
**Acción:** **ELIMINAR** este callback completamente.

---

#### Hallazgo 3 — 🟡 MEDIA: Comando `closeNUI` sin restricción de permisos

```lua
QBCore.Commands.Add("closeNUI", "Close Multi NUI", {}, false, function(source) ...
```

Sin restricción de permisos. Riesgo bajo pero mala práctica.

---

### 🌐 Análisis de Seguridad NUI

#### Hallazgo 4 — 🔴 ALTA: URLs externas cargan JS desde dominio no confiable

| Línea | URL Externa | Riesgo |
|:---:|:---|:---:|
| 5 | `https://pappu-multicharacter.netlify.app/pappudata/fonts/gilroy/stylesheet.css` | 🟠 |
| 10 | `https://kit.fontawesome.com/cfe5583873.js` | 🟡 |
| 12 | `https://code.jquery.com/jquery-3.6.0.min.js` | 🟡 |
| 93 | `https://pappu-multicharacter.netlify.app/javascript/materialize.js` | 🔴 |

**⚠️ CRÍTICO (Línea 93):** JavaScript cargado desde `pappu-multicharacter.netlify.app` — dominio personal controlable por terceros. Cualquier modificación en ese deploy inyecta código en cada cliente.

**Acción:** Descargar, verificar y alojar localmente TODO recurso externo.

---

#### Hallazgo 5 — 🟡 BAJA: Librerías referenciadas pero inexistentes

Líneas 13-14 del HTML referencian `js/tfjs@1.2` y `js/body-pix@2.0` que no existen en el directorio. Son para la función de removeBackGround que no funcionará.

---

### 💉 Análisis SQL

| # | Query | Línea | ¿Parametrizada? |
|:---:|:---|:---:|:---:|
| 1 | `SELECT * FROM houselocations` | 31 | ✅ Estática |
| 2 | `SELECT * FROM players WHERE license = ?` | 170 | ✅ |
| 3 | `SELECT * FROM server_logs` | 176 | ✅ Estática |
| 4 | `SELECT * FROM players WHERE license = ?` | 204 | ✅ |
| 5 | `SELECT * FROM playerskins WHERE citizenid = ? AND active = ?` | 216 | ✅ |

> **✅ SQL LIMPIO.** Todas las queries parametrizadas. Sin concatenación.

---

## Resumen de Hallazgos

| # | Sev. | Hallazgo | Archivo | Acción |
|:---:|:---:|:---|:---|:---|
| H-01 | 🔴 | URLs externas cargan JS desde dominio no confiable | `html/index.html:5,93` | **ELIMINAR** — Alojar localmente |
| H-02 | 🔴 | Callback `GetServerLogs` expone logs sin auth | `server/main.lua:175-178` | **ELIMINAR** |
| H-03 | 🟠 | Eventos server no validan datos del cliente | `server/main.lua:79,103,142` | **REMEDIAR** |
| H-04 | 🟡 | Wildcards en fxmanifest.lua | `fxmanifest.lua:18,31-35` | **REMEDIAR** |
| H-05 | 🟡 | Librerías JS inexistentes referenciadas | `html/index.html:13-14` | **LIMPIAR** |

---

## Decisión Final

```
╔══════════════════════════════════════════════════════════════════╗
║                DECISIÓN DE AUDITORÍA — AUD-001                  ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  VEREDICTO:   🔧 LIMPIEZA REQUERIDA ANTES DE APROBACIÓN        ║
║                                                                  ║
║  El recurso NO contiene malware (RATs, backdoors, ofuscación,   ║
║  exfiltración). Sin embargo, presenta vulnerabilidades que       ║
║  DEBEN remediarse antes de pasar a producción:                   ║
║                                                                  ║
║  • 2 hallazgos de severidad ALTA (H-01, H-02)                   ║
║  • 1 hallazgo de severidad MEDIA-ALTA (H-03)                    ║
║  • 2 hallazgos de severidad MEDIA/BAJA (H-04, H-05)             ║
║                                                                  ║
║  ACCIÓN: Proceder con LIMPIEZA QUIRÚRGICA (Sección 10)          ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

---

### Dependencias Confirmadas

| Recurso | Requerido | Notas |
|:---|:---:|:---|
| `qb-core` | ✅ | Framework base |
| `oxmysql` | ✅ | Driver de base de datos |
| `qb-apartments` | ✅ | Se carga su config.lua server-side |
| `qb-houses` | ⚠️ | Eventos referenciados |
| `qb-garages` | ⚠️ | Eventos referenciados |
| `qb-weathersync` | ⚠️ | Eventos client-side |
| `qb-clothing` | ⚠️ | Referencia para ropa |
| `mh-cashasitem` | ⚠️ | Opcional — Verifica existencia |

---

> **Próximo paso:** Ejecutar LIMPIEZA QUIRÚRGICA sobre los 5 hallazgos, luego RE-AUDITAR.
