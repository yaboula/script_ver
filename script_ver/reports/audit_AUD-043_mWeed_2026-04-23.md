# Reporte de Auditoría de Seguridad — AUD-043

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-043` |
| **Recurso** | `mWeed` |
| **Fecha de Auditoría** | 2026-04-23 |
| **Analista** | IA (AI_RUNBOOK v1.1.0) |
| **Origen** | No oficial — Script de tercero (posiblemente producto CodeM / filtración) |
| **Autor declarado** | `Lucid#3604` (fxmanifest) / version checker: `Aiakos232` |
| **Versión del Recurso** | `1.3` |
| **Framework** | QBCore / ESX / Multi-framework |
| **Estado** | 🔧 LIMPIADO Y APROBADO |
| **Severidad Máxima Detectada** | 🟡 Media |
| **Hash SHA-256 fxmanifest.lua** | `0114ADF15528338E43EC85D80D64BF0CBBE492C9F5E21CA0455BED6C595861D3` |

---

## ⚠️ Aviso de Origen

> Este recurso contiene un bloque `escrow_ignore` en el manifiesto, lo cual indica que normalmente es un producto de pago con protección de escrow (compatible con CodeM Inventory remake). La versión auditada tiene **todo el código fuente accesible**, lo que puede indicar:
> - Una versión de demostración / anterior al escrow
> - Una filtración (leak) del script original
>
> **Recomendación:** Verificar que se cuenta con licencia válida antes de usar en producción.

---

## Inventario de Archivos

**Total archivos:** 110 | **Archivos .lua:** 12 | **Archivos .js:** 11 | **Archivos .html:** 5 | **Assets (png/mp3/css/sql):** 82

| Archivo | SHA-256 |
|:---|:---|
| `fxmanifest.lua` | `0114ADF15528338E43EC85D80D64BF0CBBE492C9F5E21CA0455BED6C595861D3` |
| `server/botToken.lua` | `89C935BF8DFBE3DA29AEEB5C938C942DE77CF2306247377D5D5391D0B6D01453` |
| `server/dealer.lua` | `DB10AB35B7B80220D51C6052BBD31DCA74127919DB764A896BDE61A7A1AF312F` |
| `server/main.lua` | `43CCF2F5418518235E9C53D238576625D5D208661F3CEE9CDF83AB7AC881AC61` |
| `server/weed.lua` | `9876D2E073D5CEB4965B1E4061A4338C505D4A795F66DA3D4B3E6FE2560ACACF` |
| `shared/config.lua` | `22FEAED29E2D935757C0D755F55EFC947D289FDF2F59FABAD4F5F8F7A6247C47` |
| `shared/GetCore.lua` | `D05F36E4FF2BBB5B3C389635C5E2AD7D56BEC3FB6A3944B6B72C1C2F7E5D323D` |
| `client/animations.lua` | `9DFE04FE81DDDA8EFCB26D5E1A55B9A7DE8C542FD56AA034BD9357BC444AA274` |
| `client/dealer.lua` | `5328E33F06EC081ED7371FD30E8CA091D49BAE143DB430E6452442536E05ACB8` |
| `client/editable.lua` | `8CFC518C0C1EC8C886246CCC8C12090D0A3B6BB0A96233A944D7BE0BA12394CC` |
| `client/interaction.lua` | `FAE4F289CE0AD25D8280E42A7B7E2B322A9B41043BAC3E1362AE272FF4DBE250` |
| `client/main.lua` | `6E62F28DCB90C9A00023883A5E79BEE4F72488881E717CDC9733631650B4F361` |
| `client/PlayerLoaded.lua` | `CB8E8B0EE5AB8EBC08999D62F61F1BC9B57170F14A316791658C7054E4A9E0B7` |
| `client/weed.lua` | `6539D22705FB69EE78BA041C5D56FA7A489C89C300F72892C4D03B9572DB3771` |
| `html/index.html` | `8D888F849F2AC78DD4BAD64FC659AEF9E4B2CC8995A932A6D871CA4DDEF794CC` |
| `html/app/index.js` | `4F5B76B552D9F7E1C32E53EFEB37D422390E675EFCD073E863FE60ECA7BE99A8` |
| `html/app/vue.global.js` | `184C2D79D0BADCF41A6DA9A91F7B5BBE5390254B08099E2DB6C83B5F102CF251` |
| `html/app/vuex.global.js` | `A643DCAC86EFA61D168A3675E91DB616F40C76A558DA5661B9B4F5643FF864E5` |

---

## Verificación de Rechazo Automático R-01 a R-07

| Criterio | Resultado |
|:---|:---:|
| R-01: Archivos binarios peligrosos (.exe, .dll, .bat, .ps1...) | ✅ NINGUNO |
| R-02: Código server-side completamente ofuscado | ✅ NO — Código legible |
| R-03: `os.execute()` o `io.popen()` | ✅ NINGUNO |
| R-04: `load()` ejecutando respuesta de `PerformHttpRequest` | ✅ NINGUNO |
| R-05: Más de 3 capas de ofuscación | ✅ NINGUNO |
| R-06: Fuente previamente identificada como maliciosa | ✅ No consta |
| R-07: Modificación de archivos fuera del propio directorio | ✅ NINGUNO |

**→ SIN CAUSAS DE RECHAZO AUTOMÁTICO**

---

## Nivel 1 — Resultados del Escaneo Automatizado

```
╔══════════════════════════════════════════════════════════╗
║       RESULTADO DEL ESCANEO AUTOMATIZADO (Nivel 1)      ║
╠══════════════════════════════════════════════════════════╣
║ Recurso:        mWeed v1.3                              ║
║ Fecha:          2026-04-23                              ║
║ Analista:       IA (AI_RUNBOOK v1.1.0)                  ║
╠══════════════════════════════════════════════════════════╣
║ Hallazgos Críticos (🔴):    0                           ║
║ Hallazgos Altos (🟠):       0                           ║
║ Hallazgos Medios (🟡):      2                           ║
║ Archivos Binarios:          0                           ║
╠══════════════════════════════════════════════════════════╣
║ DECISIÓN PRELIMINAR:                                    ║
║ [x] → Continuar a Nivel 2 (Revisión Manual)             ║
║ [ ] → RECHAZAR (amenaza confirmada en escaneo)          ║
╚══════════════════════════════════════════════════════════╝
```

### Tabla de Patrones — Nivel 1

| Patrón | ID | Hits | Archivos | Veredicto |
|:---|:---:|:---:|:---|:---|
| `PerformHttpRequest` | C-01 | 2 | `server/weed.lua:597`, `server/main.lua:46` | ✅ LEGÍTIMO — Ver análisis Nivel 2 |
| `load(` | C-03 | 0 | — | ✅ LIMPIO |
| `loadstring(` | C-04 | 0 | — | ✅ LIMPIO |
| `assert(load(` | C-05 | 0 | — | ✅ LIMPIO |
| `RunString(` | C-06 | 0 | — | ✅ LIMPIO |
| `\x` hex | C-07 | 0 | — | ✅ LIMPIO |
| `string.char(` | C-08 | 0 | — | ✅ LIMPIO |
| `os.execute(` | C-09 | 0 | — | ✅ LIMPIO |
| `io.popen(` | C-10 | 0 | — | ✅ LIMPIO |
| `io.open(` | C-11 | 0 | — | ✅ LIMPIO |
| `debug.` | C-12 | 0 | — | ✅ LIMPIO |
| `steam:` hardcoded | A-01 | 0 | — | ✅ LIMPIO |
| `discord:` hardcoded | A-02 | 2 | `server/main.lua:63-64` | ✅ LEGÍTIMO — Extracción de ID para avatar |
| `license:` hardcoded | A-03 | 0 | — | ✅ LIMPIO |
| `RegisterCommand` | A-05 | 0 | — | ✅ NINGUNO |
| `RegisterNetEvent` (client) | A-06 | 10 | `client/*` | ✅ LEGÍTIMO — Receptores de eventos del servidor |
| `GetConvar` | A-08 | 0 | — | ✅ LIMPIO |
| `ExecuteCommand` | A-09 | 0 | — | ✅ LIMPIO |
| SQL concatenación | M-01 | 0 | — | ✅ NO USA SQL DIRECTO |
| `innerHTML` en .js | M-02 | 8 | `vue.global.js` | ✅ FALSO POSITIVO — Core de Vue.js |
| `eval(` en .js | M-03 | 0 | — | ✅ LIMPIO |
| Wildcards en manifiesto | F-06 | 13 | `fxmanifest.lua` | 🟡 MEDIO — En `files{}`, no en scripts |

---

## Nivel 2 — Revisión Manual Profunda

### 2.1 Auditoría del Manifiesto (`fxmanifest.lua`)

| # | Verificación | Estado | Notas |
|:---:|:---|:---:|:---|
| F-01 | `fx_version` es `cerulean` | ❌ FALLA | Usa `'adamant'` — versión antigua. **REMEDIADO** |
| F-02 | `game 'gta5'` declarado | ✅ OK | |
| F-03 | Todos los `client_scripts` existen físicamente | ✅ OK | 7 archivos declarados, todos presentes |
| F-04 | Todos los `server_scripts` existen físicamente | ✅ OK | 4 archivos declarados, todos presentes |
| F-05 | No hay .lua sin declarar en manifiesto | ✅ OK | Todos los .lua están declarados |
| F-06 | No se usan wildcards en `scripts` | ✅ OK | Wildcards solo en `files{}` (assets NUI) — riesgo bajo |
| F-07 | `files{}` solo contiene assets legítimos | ✅ OK | Solo .js, .html, .css, .otf, .ttf, .MP3, .wav, .png |
| F-08 | `dependencies` son recursos conocidos | ✅ OK | Solo `'/assetpacks'` (dependencia FiveM) |
| F-09 | No hay `loadscreen` sospechoso | ✅ OK | No existe |
| F-10 | No hay `data_file` con path traversal | ✅ OK | No existe |
| F-11 | `escrow_ignore` documenta código expuesto | ⚠️ NOTA | Script normalmente bajo escrow — ver aviso de origen |

**Hallazgo H-01** (🟡 MEDIO): `fx_version 'adamant'` debe actualizarse a `'cerulean'`.
**Hallazgo H-02** (🟢 INFO): Wildcards en `files{}` — riesgo bajo (no afectan scripts ejecutables).

### 2.2 Análisis de Eventos Server-Side (`server/weed.lua`)

Todos los eventos server-side usan `RegisterServerEvent` + `AddEventHandler` correctamente. La variable `source` se captura con `local src = source` en todos los handlers.

| # | Evento | `src = source` ✅ | Datos validados ✅ | Permisos ✅ | Veredicto |
|:---:|:---|:---:|:---:|:---:|:---:|
| 1 | `mWeed:AddPlayerWeedData` | ✅ | ✅ `ResolvePlantRefs()` | N/A (datos propios) | ✅ SEGURO |
| 2 | `mWeed:AddProgress` | ✅ | ✅ `ResolvePlantRefs()` + tipo `deleteItem` | `CheckItem` server-side | ✅ SEGURO |
| 3 | `mWeed:SetSeedType` | ✅ | ✅ `ResolvePlantRefs()` + `ALLOWED_SEEDS` whitelist | N/A | ✅ SEGURO |
| 4 | `mWeed:SetIsQualityFertilizer` | ✅ | ✅ `ResolvePlantRefs()` + `type(val) ~= 'boolean'` | N/A | ✅ SEGURO |
| 5 | `mWeed:harvest` | ✅ | ✅ `ResolvePlantRefs()` + `data.growth >= 4` | `GetPlayer` server | ✅ SEGURO |
| 6 | `mWeed:water` | ✅ | ✅ `ResolvePlantRefs()` + `CheckItem` | `CheckItem` server-side | ✅ SEGURO |
| 7 | `mWeed:flounder` | ✅ | ✅ `ResolvePlantRefs()` + `CheckItem` | `CheckItem` server-side | ✅ SEGURO |
| 8 | `mWeed:trash` | ✅ | ✅ `ResolvePlantRefs()` | N/A | ✅ SEGURO |
| 9 | `mWeed:removeStatus` | ✅ | ✅ `ResolvePlantRefs()` | N/A | ✅ SEGURO |
| 10 | `mWeed:RequestData` | ✅ | N/A — No recibe datos | N/A | ✅ SEGURO |
| 11 | `mWeed:rollWeed` | ✅ | ✅ `ALLOWED_ROLL_INPUT` whitelist + tipo | `CheckItem` weed + paper | ✅ SEGURO |
| 12 | `mWeed:grindWeed` | ✅ | ✅ `ALLOWED_GRIND_INPUT` whitelist + tipo | `CheckItem` weed + grinder | ✅ SEGURO |

**Veredicto global de eventos:** ✅ EXCELENTE — Todos los eventos validan correctamente el `source` del servidor, tipos de datos y permisos de items. Se usa whitelist explícita para seeds/grind/roll.

### 2.3 Análisis de Callbacks Server-Side

| # | Callback | Datos devueltos | Permisos | Veredicto |
|:---:|:---|:---|:---:|:---:|
| `mWeed:GetPlayerInformations` | Avatar URL + nombre RP | `GetPlayer(source)` | ✅ SEGURO |
| `mWeed:GetPlayerInventory` | Items vendibles del jugador | `GetPlayer(source)` | ✅ SEGURO |
| `mWeed:buyItem` | `true/false` | `NormalizeCart` + money check | ✅ SEGURO |
| `mWeed:sellItem` | `true/false` | `NormalizeCart` + item count check | ✅ SEGURO |
| `mWeed:checkItem` | `true/false` | `CheckItem` server-side | ✅ SEGURO |
| `mWeed:GetPlayerCash` | Saldo del jugador | `GetPlayer(source)` | ✅ SEGURO |

**Función destacada — `NormalizeCart()`** (`server/dealer.lua:32-59`): Valida el carrito de compra/venta con:
- Tipo de datos (`type(cart) ~= 'table'`, `type(entry.name) ~= 'string'`)
- Cantidades positivas enteras ≤ 100 (`IsPositiveInteger`)
- Nombres de items contra whitelist de configuración (no acepta items no configurados)

### 2.4 Análisis de `PerformHttpRequest` (C-01)

#### Hit 1 — `server/weed.lua:597` — Version Checker
```lua
PerformHttpRequest('https://raw.githubusercontent.com/Aiakos232/versionchecker/main/version.json',
    function(error, result, headers)
        local result = json.decode(result)
        -- Solo compara versiones numéricas con print()
    end, 'GET')
```
**Veredicto: ✅ LEGÍTIMO** — GET a GitHub raw. Respuesta solo se decodifica como JSON y se compara numéricamente. No se ejecuta. Patrón estándar de version-checker en FiveM.

#### Hit 2 — `server/main.lua:46` — Discord Avatar API
```lua
PerformHttpRequest(url, function(code, data, headers)
    response = { data = data, code = code, headers = headers }
end, method, encodedBody, { ["Authorization"] = authHeader })
```
URL construida: `"https://discordapp.com/api/" .. endpoint` donde `endpoint = "users/{discordId}"`.

**Veredicto: ✅ LEGÍTIMO** — Llama a la API oficial de Discord para obtener el avatar del jugador. La respuesta se decodifica como JSON y solo se extrae `userData.avatar` (string de hash de imagen). No se ejecuta ningún código de la respuesta.

**Riesgo residual (🟢 INFO):** El `botToken` variable (declarado en `server/botToken.lua`) debe mantenerse privado. Si el servidor se filtra, el token queda expuesto. Documentado en H-03.

### 2.5 Análisis de la Frontera Client/Server (Regla R-00)

| Verificación | Resultado |
|:---|:---:|
| `RegisterServerEvent` en archivos `client_scripts` | ✅ NINGUNO |
| Funciones QBCore server-side (`GetPlayer`, `HasPermission`) en client | ✅ NINGUNO |
| `TriggerServerEvent` en client envia solo índices numéricos/strings | ✅ OK — Validados en servidor con `ResolvePlantRefs()` |
| `RegisterNetEvent` en client son solo receptores de eventos del servidor | ✅ OK |

### 2.6 Análisis NUI

| Verificación | Estado | Notas |
|:---|:---:|:---|
| Scripts JS externos (CDN) | ✅ NINGUNO | `vue.global.js` y `vuex.global.js` son locales |
| `eval()` en código personalizado | ✅ NINGUNO | |
| `innerHTML` con datos dinámicos | ✅ OK | Solo en core de Vue.js (librería legítima) |
| `fetch()` a URLs externas | ✅ OK | `fetch(`https://${resourceName}/...`)` — patrón NUI estándar FiveM |
| Fuentes externas (.otf) | ✅ LOCAL | `Proxima-Nova.otf` incluida localmente |
| Script tags externos en HTML | ✅ NINGUNO | |

### 2.7 Análisis SQL

Este recurso **no utiliza consultas SQL directas**. La persistencia de datos de plantas se realiza en memoria (`weedData` tabla Lua en el servidor). No hay conexión a base de datos. Los datos se pierden al reiniciar el servidor (diseño intencional según la funcionalidad del recurso).

---

## Resumen de Hallazgos

| # | ID | Severidad | Descripción | Acción |
|:---:|:---|:---:|:---|:---|
| H-01 | F-01 | 🟡 MEDIO | `fx_version 'adamant'` — versión antigua del manifiesto | **REMEDIADO** — Actualizado a `'cerulean'` |
| H-02 | F-06 | 🟢 INFO | 13 wildcards en `files{}` (assets NUI, no scripts) | Documentado — Riesgo bajo |
| H-03 | A-02 | 🟢 INFO | Variable `botToken` global en server — Discord avatar feature | Documentado — Por diseño, vacío por defecto |
| H-04 | C-01 | 🟢 INFO | `PerformHttpRequest` a `discordapp.com/api` — Discord avatars | Legítimo, no ejecuta respuesta |
| H-05 | C-01 | 🟢 INFO | `PerformHttpRequest` a GitHub raw — version checker | Legítimo, solo compara versión |
| H-06 | — | 🟡 MEDIO | Posible filtración de script de pago (CodeM) — `escrow_ignore` | Verificar licencia antes de usar |

---

## Decisión Final

> ## 🔧 LIMPIADO Y APROBADO
>
> **Veredicto:** El recurso `mWeed v1.3` no contiene amenazas de seguridad.
> La lógica de servidor está bien protegida con whitelists, validación de tipos y uso correcto de `source`.
> Se aplicó únicamente FIX-F01 (actualizar `fx_version`).
>
> **Condición para uso:** Verificar licencia del script (posible producto CodeM).

### Cambios Aplicados Durante Auditoría

- [x] **FIX-F01:** `fx_version` actualizado de `'adamant'` a `'cerulean'` en `fxmanifest.lua`
- [x] **DOC:** Comentario de aviso añadido en `server/botToken.lua` sobre confidencialidad del token

---

## Dependencias Requeridas

| Recurso | Versión | Verificado |
|:---|:---|:---:|
| `qb-core` | v1.x+ (o ESX equivalente) | [ ] |
| `/assetpacks` | FiveM built-in | [ ] |
| `ox_inventory` | Opcional (para `exports('useJoint')`) | [ ] |
| `oxmysql` o `mysql-async` | No requerido (sin SQL) | N/A |

---

## Configuración Necesaria para Instalación

- [ ] Editar `shared/config.lua`: Configurar `Config.Framework` ('qb', 'esx', etc.)
- [ ] Editar `shared/config.lua`: Ajustar `Config.InteractionHandler` ('qb-target', 'ox_target', 'drawtext')
- [ ] Editar `server/botToken.lua`: Pegar token del bot de Discord (opcional — solo para avatares)
- [ ] Añadir al `server.cfg`: `ensure mWeed`
- [ ] Ejecutar SQL: `esxItems.sql` (para ESX) o usar `qbcoreitems.txt` (para QBCore) para añadir los items
- [ ] Añadir imágenes de inventario: copiar `inventory_images/*.png` al directorio de imágenes del inventario

## Notas para el Equipo de Instalación

- Los datos de plantas **no son persistentes** (se pierden al reiniciar el servidor). Esto es por diseño.
- Si se usa `ox_inventory`, el script exporta `useJoint` que debe enlazarse en la config de ox_inventory.
- El `botToken` en `server/botToken.lua` es **opcional**. Si se deja vacío, el avatar del dealer usa la imagen por defecto `example-pp.png`.
- El script soporta múltiples frameworks: `qb`, `esx`, `oldqb`, `oldesx`, `autodetect`.
- Conflictos potenciales: cualquier recurso que use los mismos nombres de items (indica_seed, sativa_seed, etc.).

---

> **Firma del Analista:** IA — AI_RUNBOOK v1.1.0
> **Fecha de Cierre:** 2026-04-23
