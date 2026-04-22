# Reporte de Auditoría de Seguridad — AUD-003

## `nc-spawnselector`

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-003` |
| **Recurso** | `nc-spawnselector` |
| **Tipo** | Script QBCore — Selector de spawn con NUI |
| **Autor Declarado** | NCHub (Discord.gg/sgx / Patreon.com/NCHub) |
| **Origen** | Descarga gratuita |
| **Fecha de Auditoría** | 15-Abril-2026 |
| **Analista** | Equipo de Seguridad — Proyecto Admirales |
| **Nivel de Riesgo Inicial** | 🟠 ALTO — Script gratuito con server-side, SQL y NUI |
| **Protocolo Aplicado** | `SECURITY_PROTOCOL.md` v2.0 + `AI_RUNBOOK.md` v1.1 |
| **Veredicto Final** | ✅ **LIMPIADO Y APROBADO** |

---

## 1. Inventario de Archivos

| # | Archivo | Tamaño | Tipo | Contexto |
|:---:|:---|:---:|:---:|:---:|
| 1 | `fxmanifest.lua` | 931 B | Manifiesto | — |
| 2 | `config.lua` | 1,449 B | Shared script | shared |
| 3 | `client.lua` | 9,528 B | Client script | client |
| 4 | `server.lua` | 2,086 B | Server script | **server** |
| 5 | `ReadMe.txt` | 779 B | Documentación | — |
| 6 | `html/index.html` | 4,309 B | NUI | client |
| 7 | `html/script.js` | 9,105 B | NUI JavaScript | client |
| 8 | `html/style.css` | 4,359 B | NUI CSS | client |
| 9 | `html/reset.css` | 1,328 B | NUI CSS | client |
| 10 | `html/Map.png` | 2,875 KB | Asset imagen | client |
| 11 | `html/rhombus.png` | 362 B | Asset imagen | client |

**Total:** 11 archivos | Sin archivos binarios peligrosos ✅

---

## 2. Análisis del Manifiesto

| # | Verificación | Estado | Notas |
|:---:|:---|:---:|:---|
| F-01 | `fx_version 'cerulean'` | ✅ | Actual |
| F-02 | `game 'gta5'` | ✅ | Correcto |
| F-03 | client_scripts existen | ✅ | `client.lua` confirmado |
| F-04 | server_scripts existen | ✅ | `server.lua` confirmado |
| F-05 | Archivos extra no declarados | ✅ | `ReadMe.txt` no se carga |
| F-06 | No usa wildcards | ✅ | Declaraciones explícitas |
| F-07 | files solo assets legítimos | ✅ | HTML, CSS, JS, PNG |
| F-08 | Dependencias | ✅ | Declarado en bloque `dependencies { '/assetpacks' }` |

---

## 3. Escaneo Automatizado — Nivel 1

### 🔴 Críticos: **0/12 — LIMPIO ✅**

Todos los patrones C-01 a C-12: **0 hallazgos**.

### 🟠 Altos: **0 riesgos confirmados ✅**

- Identificadores hardcodeados: **0** ✅
- GetConvar / ExecuteCommand: **0** ✅

### 🟡 Medios:

- SQL: **3 queries — todas parametrizadas** ✅
- innerHTML / eval en NUI: **0** ✅
- URLs externas: **2 — ambas de CDNs confiables** ✅

---

## 4. Revisión Manual — Server-Side

### 4.1 Callback: `qb-spawn:server:getOwnedHouses` (L2-17)

| Aspecto | Evaluación |
|:---|:---|
| ¿Source validado? | ✅ `source` → `GetPlayer(src)` |
| ¿citizenid obtenido server-side? | ✅ `Player.PlayerData.citizenid` |
| ¿SQL parametrizado? | ✅ Usa `?` |
| ¿Expone datos excesivos? | ⚠️ `SELECT *` — Bajo riesgo (datos del propio jugador) |

**Veredicto: ✅ SEGURO**

### 4.2 Evento: `orangutan:spawn:getHouseCoords` (L19-42)

| Aspecto | Evaluación |
|:---|:---|
| ¿Source validado? | ✅ `local src = source` |
| ¿Datos validados (tipo)? | ✅ `type(houseName) ~= 'string'` |
| ¿Datos validados (rango)? | ✅ `#houseName == 0 or #houseName > 64` |
| ¿Ownership verificado? | ✅ Query verifica propiedad antes de teleportar |
| ¿SQL parametrizado? | ✅ Todas las queries usan `?` |
| ¿Coords validados post-decode? | ✅ `type(x) ~= 'number'` |

**Veredicto: ✅ SEGURO — Bien protegido**

### 4.3 Comando: `addloc` (L44-47)

| Aspecto | Evaluación |
|:---|:---|
| ¿Protección? | ✅ `"god"` — Solo accesible con permiso máximo QBCore |
| ¿Acción peligrosa? | NO — Solo abre UI al admin |

**Veredicto: ✅ SEGURO**

### 4.4 Análisis SQL

| # | Query | ¿Parametrizada? |
|:---:|:---|:---:|
| 1 | `SELECT * FROM player_houses WHERE identifier = ?` | ✅ |
| 2 | `SELECT house FROM player_houses WHERE house = ? AND ...` | ✅ |
| 3 | `SELECT * FROM houselocations WHERE name = ?` | ✅ |

**3/3 parametrizadas ✅**

---

## 5. Revisión Manual — NUI

### URLs Externas

| URL | CDN | Veredicto |
|:---|:---:|:---:|
| `fonts.googleapis.com/css2?family=Poppins` | ✅ Google Fonts | ✅ Seguro |
| `cdnjs.cloudflare.com/.../font-awesome/5.15.4/css/all.min.css` | ✅ Cloudflare + SRI | ✅ Seguro |
| `https://nc-spawnselector/...` (×5 NUI callbacks) | ✅ FiveM interno | ✅ Seguro |

### JavaScript

- `eval()`: 0 ✅ | `innerHTML`: 0 ✅ | `new Function()`: 0 ✅
- jQuery duplicado: NO ✅
- `.html()` con datos dinámicos: Bajo riesgo (datos del servidor, no input usuario)

---

## 6. Evaluación del Trabajo de la Otra IA

Cambios marcados con `[AUDIT AUD-003]` en `server.lua`:

### ✅ Cambios CORRECTOS

| Línea | Cambio | Evaluación |
|:---:|:---|:---|
| 7-9 | Validación de `cid` server-side + tipo check | ✅ Defensa en profundidad, contexto correcto |
| 21-23 | `type(houseName) ~= 'string'` + límite longitud | ✅ FIX-04 del Runbook aplicado correctamente |
| 25-28 | Verificación ownership con `GetPlayer` server-side | ✅ Contexto correcto (R-00 respetada) |
| 30 | Query con ownership check + `LIMIT 1` | ✅ Previene exploit de spawn en casas ajenas |
| 37-39 | Validación de coords post-decode | ✅ Previene crash por datos corruptos |

**Veredicto: ✅ TRABAJO APROBADO.** Esta IA aplicó correctamente las reglas del protocolo. Todas las funciones server-side se usan en contexto server-side. Las validaciones son apropiadas y no excesivas.

### 🔧 Ajustes post-validación

| Ajuste | Estado |
|:---|:---:|
| Formato de dependencia `assetpacks` normalizado | ✅ |
| `print()` de debug en `client.lua` removidos | ✅ |
| `QB = {}` global en `config.lua` | ℹ️ Se mantiene (convención del recurso) |

---

## 7. Resumen de Hallazgos

| ID | Sev. | Hallazgo | Estado |
|:---:|:---:|:---|:---:|
| H-01 | 🟡 | Formato de dependencia en manifiesto | 🔧 Remediado |
| H-02 | 🟢 | `qb-houses` comentado como dependencia | Sin impacto |
| H-03 | 🟢 | `print()` debug en client.lua (4 instancias) | 🔧 Remediado |
| H-04 | 🟢 | Variable global `QB = {}` en config.lua | Bajo riesgo |

---

## 8. Dependencias

| Recurso | Requerido |
|:---|:---:|
| `qb-core` | ✅ |
| `oxmysql` | ✅ |
| `qb-apartments` | ✅ |
| `assetpacks` | ✅ |
| `qb-houses` | ❌ (comentado) |

### Orden recomendado en `server.cfg` (instalación)

1. `ensure qb-core`
2. `ensure oxmysql`
3. `ensure qb-apartments`
4. `ensure [standalone]/assetpacks` (o carpeta equivalente)
5. `ensure [qb]/nc-spawnselector`

### Checklist rápido de instalación

- Verificar que `@qb-apartments/config.lua` resuelve sin error al iniciar.
- Confirmar que `@oxmysql/lib/MySQL.lua` está disponible.
- Validar que el recurso `assetpacks` esté iniciado antes de `nc-spawnselector`.
- Ajustar spawns en `config.lua` (vienen comentados por defecto).

---

## 9. Notas para el Equipo de Instalación

1. **Configurar spawns:** Todos los spawns en `config.lua` están comentados. Descomentar y ajustar coordenadas según el servidor.
2. **Dependencia qb-apartments:** Requerida. Si no está instalada, el recurso no cargará.
3. **Comando admin:** `/addloc` (permiso `god`) — Generador de coordenadas de spawn.

---

## 10. Decisión Final

```
╔═══════════════════════════════════════════════════════════════════╗
║                    AUDITORÍA AUD-003 — CERRADA                    ║
╠═══════════════════════════════════════════════════════════════════╣
║  Recurso:          nc-spawnselector                               ║
║  Veredicto:        ✅ LIMPIADO Y APROBADO                         ║
║  Ubicación:        approved/[qb]/nc-spawnselector                 ║
║                                                                   ║
║  Malware:          ❌ NO                                          ║
║  Backdoors:        ❌ NO                                          ║
║  SQL Injection:    ❌ 3/3 parametrizadas                          ║
║  URLs externas:    ✅ CDNs confiables                             ║
║  Otra IA:          ✅ Trabajo validado y correcto                 ║
║                                                                   ║
║  Hallazgos:        0 Críticos | 0 Altos | 0 Medios | 1 Bajo       ║
║  Dependencias:     qb-core, oxmysql, qb-apartments, assetpacks   ║
╚═══════════════════════════════════════════════════════════════════╝
```

---

## 11. Cierre de observaciones del revisor

- ✅ Regla R-00 respetada (server/client)
- ✅ `citizenid` obtenido server-side
- ✅ Validación de tipo/longitud en `houseName`
- ✅ Verificación de ownership previa al teleport
- ✅ Validación de coordenadas post-`json.decode`
- ✅ SQL parametrizado conservado
- ✅ Formato de dependencia normalizado
- ✅ `print()` de debug removidos
- ✅ Dependencias documentadas para instalación
