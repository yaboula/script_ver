# AI Runbook — Auditoría de Seguridad FiveM/QBCore

## Guía de Ejecución para Asistentes IA

| Campo | Valor |
|:---|:---|
| **Versión** | `1.1.0` |
| **Complementa** | `SECURITY_PROTOCOL.md` v2.0.0 |
| **Propósito** | Instrucciones paso a paso para que cualquier IA avanzada ejecute auditorías de seguridad de forma idéntica y reproducible. |
| **Última Revisión** | 15-Abril-2026 |
| **Auditorías de Referencia** | `reports/audit_AUD-001_nc-multicharacter_2026-04-14.md`, `reports/audit_AUD-002_qua_nmotel_corridor_2026-04-15.md` |

---

> **Para la IA:** Este documento es tu guía operativa. Sigue cada paso EN ORDEN.
> No saltes pasos. Documenta cada hallazgo. Cuando tengas dudas, elige la opción más conservadora (rechazar antes que aprobar un riesgo).

---

## ⛔ REGLA R-00 — Contexto Client vs Server (LEER PRIMERO)

**Esta es la regla más importante de todo el runbook.** Antes de aplicar CUALQUIER fix, debes determinar si el archivo es un `client_script` o un `server_script`.

### Las APIs de QBCore tienen contextos separados:

| Función | ¿Disponible en SERVER? | ¿Disponible en CLIENT? |
|:---|:---:|:---:|
| `QBCore.Functions.GetPlayer(src)` | ✅ SÍ | ❌ NO (nil error) |
| `QBCore.Functions.HasPermission(src, perm)` | ✅ SÍ | ❌ NO (nil error) |
| `QBCore.Functions.CreateCallback(...)` | ✅ SÍ | ❌ NO |
| `QBCore.Player.Login(src, cid)` | ✅ SÍ | ❌ NO |
| `QBCore.Functions.GetPlayerData()` | ❌ NO | ✅ SÍ |
| `QBCore.Functions.TriggerCallback(...)` | ❌ NO | ✅ SÍ |

### `RegisterCommand` funciona diferente en cada lado:

| Aspecto | Server-side | Client-side |
|:---|:---|:---|
| `source` | ID del jugador que ejecutó | Siempre `0` |
| Protección ACE (`true`) | Funciona ✅ | Funciona ✅ |
| `QBCore.Functions.GetPlayer(source)` | Funciona ✅ | **CRASH** ❌ |

### Cómo determinar el contexto:

1. Leer `fxmanifest.lua`
2. Si el archivo está en `client_script` / `client_scripts` → **Es CLIENT-SIDE**
3. Si el archivo está en `server_script` / `server_scripts` → **Es SERVER-SIDE**
4. Si el archivo está en `shared_scripts` → Se ejecuta en AMBOS contextos

**REGLA:** NUNCA usar funciones server-side en archivos client-side. Si un `RegisterCommand` en client necesita protección, usar `RegisterCommand(name, handler, true)` que activa la restricción ACE nativa de FiveM. Esto es SUFICIENTE.

> Esta regla fue añadida tras la auditoría AUD-002 donde otra IA introdujo un bug al usar `QBCore.Functions.GetPlayer()` y `QBCore.Functions.HasPermission()` en un `client_script`, causando un crash.

## Índice

| Fase | Descripción | Tiempo Estimado |
|:---:|:---|:---:|
| 0 | [Preparación y Contexto](#fase-0--preparación-y-contexto) | 2 min |
| 1 | [Inventario y Clasificación Inicial](#fase-1--inventario-y-clasificación-inicial) | 5 min |
| 2 | [Escaneo Automatizado (Nivel 1)](#fase-2--escaneo-automatizado-nivel-1) | 5 min |
| 3 | [Revisión Manual Profunda (Nivel 2)](#fase-3--revisión-manual-profunda-nivel-2) | 20 min |
| 4 | [Generación del Reporte](#fase-4--generación-del-reporte) | 5 min |
| 5 | [Decisión y Limpieza](#fase-5--decisión-y-limpieza) | 10 min |
| 6 | [Cierre y Movimiento](#fase-6--cierre-y-movimiento) | 2 min |

---
---

## Fase 0 — Preparación y Contexto

### Paso 0.1: Leer documentación del proyecto

Antes de auditar, LEE estos archivos en este orden:

1. `SECURITY_PROTOCOL.md` — Secciones 1 (cuarentena), 2 (taxonomía de amenazas) y Apéndice B (severidades).
2. `tools/AUDIT_NOTES_TEMPLATE.md` — Para saber cómo documentar.
3. `reports/audit_AUD-001_nc-multicharacter_2026-04-14.md` — **EJEMPLO DE REFERENCIA** de una auditoría completada.

### Paso 0.2: Confirmar ubicación del recurso

```
El recurso DEBE estar en: c:\admirales\script_ver\script_ver\quarantine\incoming\[nombre-recurso]
```

Si el recurso NO está en `incoming/`, preguntar al usuario dónde está.

### Paso 0.3: Mover a under-review

```powershell
Move-Item -Path "c:\admirales\script_ver\script_ver\quarantine\incoming\[nombre-recurso]" -Destination "c:\admirales\script_ver\script_ver\quarantine\under-review\[nombre-recurso]"
```

### Paso 0.4: Asignar ID de auditoría

- Consultar `reports/` para ver el último ID usado.
- Asignar el siguiente: `AUD-002`, `AUD-003`, etc.

---
---

## Fase 1 — Inventario y Clasificación Inicial

### Paso 1.1: Listar TODOS los archivos

Ejecuta:
```powershell
Get-ChildItem -Path "c:\admirales\script_ver\script_ver\quarantine\under-review\[nombre]" -Recurse -File | Select-Object FullName, Length, Extension
```

### Paso 1.2: Verificación de rechazo automático

Busca archivos binarios peligrosos **INMEDIATAMENTE**:

```powershell
Get-ChildItem -Path "[ruta]" -Recurse -Include *.exe,*.dll,*.bat,*.ps1,*.sh,*.cmd,*.vbs,*.msi,*.scr
```

**Regla:** Si encuentra CUALQUIERA de estos → **RECHAZO AUTOMÁTICO** (R-01). No continuar.

### Paso 1.3: Generar hashes SHA-256

```powershell
Get-ChildItem -Path "[ruta]" -Recurse -File | ForEach-Object { Get-FileHash $_.FullName -Algorithm SHA256 } | Select-Object Hash, Path
```

Guardar en el reporte.

### Paso 1.4: Leer fxmanifest.lua

**Este es el primer archivo que SIEMPRE debes leer.** Extraer:

- [ ] `fx_version` — ¿Es `cerulean`?
- [ ] `game` — ¿Es `'gta5'`?
- [ ] `client_scripts` — Lista TODOS los archivos declarados
- [ ] `server_scripts` — Lista TODOS los archivos declarados
- [ ] `shared_scripts` — Lista TODOS los archivos declarados
- [ ] `files` — Lista TODOS los assets declarados
- [ ] `dependencies` — Lista TODAS las dependencias
- [ ] `ui_page` — ¿Existe interfaz NUI?
- [ ] ¿Hay wildcards (`*.lua`, `**/*.lua`)? → Marcar como H-04 (wildcard finding)

### Paso 1.5: Verificar correspondencia archivos ↔ manifiesto

Para cada archivo `.lua` en el directorio:
- ¿Está declarado en el manifiesto? Si NO → **sospechoso**, investigar.

Para cada archivo en el manifiesto:
- ¿Existe físicamente? Si NO → **archivo fantasma**, documentar.

### Paso 1.6: Leer config.lua y README

- Buscar identificadores hardcodeados (steam:, discord:, license:, ip:)
- Buscar URLs hardcodeadas
- Buscar información sobre el autor/origen

---
---

## Fase 2 — Escaneo Automatizado (Nivel 1)

### Paso 2.1: Ejecutar búsquedas de patrones

Para CADA patrón de la tabla siguiente, buscar en TODOS los archivos `.lua` del recurso.
Usa `grep_search` o equivalente con `MatchPerLine: true`.

#### 🔴 CRÍTICOS — Si hay hits, es ALTA PRIORIDAD

| ID | Patrón a buscar | Si encuentra |
|:---:|:---|:---|
| C-01 | `PerformHttpRequest` | Leer el código completo. ¿Qué URL usa? ¿Ejecuta la respuesta con `load()`? |
| C-02 | `PerformHttpRequestInternal` | Igual que C-01 |
| C-03 | `load(` | ¿Recibe datos externos? Si `load(respuesta_http)` → RECHAZO |
| C-04 | `loadstring(` | Igual que C-03 |
| C-05 | `assert(load(` | Patrón clásico de RAT. ALTA sospecha. |
| C-06 | `RunString(` | ALTA sospecha |
| C-07 | `\x` (secuencias hex) | Desobfuscar. ¿Qué string forman? |
| C-08 | `string.char(` | ¿Construye nombres de funciones peligrosas? |
| C-09 | `os.execute(` | RECHAZO AUTOMÁTICO (R-03) |
| C-10 | `io.popen(` | RECHAZO AUTOMÁTICO (R-03) |
| C-11 | `io.open(` | ¿Qué archivos accede? ¿Fuera de su directorio? |
| C-12 | `debug.` | Sospechoso. Revisar contexto. |

#### 🟠 ALTOS

| ID | Patrón | Si encuentra |
|:---:|:---|:---|
| A-01 | `steam:` hardcodeado | ¿Es un placeholder (`xxx`)? ¿O un ID real? |
| A-02 | `discord:` hardcodeado | Igual |
| A-03 | `license:` hardcodeado | Igual |
| A-04 | IP hardcodeada (`\d+\.\d+\.\d+\.\d+`) | ¿Qué hace con la IP? |
| A-05 | `RegisterCommand` | ¿Es client o server? ¿Tiene `true` como 3er arg (ACE)? Si es client, NO añadir QBCore server functions. |
| A-06 | `RegisterNetEvent` | CONTAR TODOS. Analizar cada uno en Fase 3. |
| A-08 | `GetConvar` | ¿Lee `sv_licenseKey` o `mysql_connection_string`? → RECHAZO |
| A-09 | `ExecuteCommand` | ¿Qué comando ejecuta? |

#### 🟡 MEDIOS

| ID | Patrón | Si encuentra |
|:---:|:---|:---|
| M-01 | `.. "` + SQL keywords | SQL por concatenación. Necesita refactorizar. |
| M-02 | `innerHTML` (en .js/.html) | Potencial XSS |
| M-03 | `eval(` (en .js) | RECHAZAR en NUI |
| M-05 | `CreateThread` sin `Wait` | Loop infinito, 100% CPU |

### Paso 2.2: Buscar en archivos NUI (.html, .js)

Patrones adicionales SOLO para archivos HTML/JS:

| Patrón | Riesgo |
|:---|:---|
| URLs `http://` o `https://` que NO sean CDNs conocidos | **ALTO** — Posible carga de código externo |
| `<script src="http` | **ALTO** — JS externo |
| `eval(` | **ALTO** |
| `new Function(` | **ALTO** |
| `document.write(` | **MEDIO** |

**CDNs conocidos (confiables):**
- `cdnjs.cloudflare.com`
- `cdn.jsdelivr.net`
- `unpkg.com`
- `fonts.googleapis.com`
- `kit.fontawesome.com`
- `code.jquery.com`
- `nui://game/ui/` (FiveM interno)

**CDNs NO conocidos (SOSPECHOSOS):**
- Dominios `.netlify.app`, `.vercel.app`, `.herokuapp.com` personales
- Cualquier dominio que parezca personal o de propósito único
- URLs acortadas (bit.ly, etc.)

### Paso 2.3: Registrar resultados del Nivel 1

Crear tabla resumen con formato:

```
| Patrón | ID | Hallazgos | Veredicto |
```

---
---

## Fase 3 — Revisión Manual Profunda (Nivel 2)

### Paso 3.1: Orden de lectura de archivos

Leer los archivos en ESTE orden de prioridad:

1. **`server/*.lua`** — Máximo riesgo. Acceso a BD, permisos, lógica de negocio.
2. **`client/*.lua`** — Riesgo medio. NUI callbacks, eventos al servidor.
3. **`html/js/*.js`** — Riesgo NUI. URLs externas, XSS.
4. **`html/*.html`** — Script tags, URLs externas.
5. **`config.lua`** — Backdoors de configuración.
6. **`locales/*.lua`** — Bajo riesgo pero verificar que solo son strings.

### Paso 3.2: Análisis de eventos server-side

Para CADA `RegisterNetEvent` encontrado en archivos server-side, crear una fila en esta tabla:

| # | Evento | ¿Source validado? | ¿Datos validados (type check)? | ¿Permisos verificados? | ¿Rate-limited? | Veredicto |
|:---:|:---|:---:|:---:|:---:|:---:|:---:|

**Reglas de evaluación:**
- `source` se valida si se usa `local src = source` al inicio del handler.
- Los datos se validan si hay checks `type()` antes de usarlos.
- Si un evento modifica dinero/items/permisos sin validación → Severidad ALTA.
- Si un evento solo lee datos → Severidad BAJA.

### Paso 3.3: Análisis de callbacks server-side

Para CADA `QBCore.Functions.CreateCallback` en archivos server-side:

- ¿Qué datos devuelve al cliente?
- ¿Verifica permisos antes de devolver?
- ¿Podría un jugador normal acceder a datos que no debería?

**Patrón peligroso:** Callbacks que devuelven `SELECT *` de tablas sensibles sin filtrar por el jugador actual.

### Paso 3.4: Análisis SQL

Para CADA query SQL encontrada:

| # | Query | Archivo:Línea | ¿Parametrizada? |
|:---:|:---|:---:|:---:|

**Regla:** Si usa `?` o `@param` → ✅. Si usa `..` concatenando variables → ❌ VULNERABLE.

### Paso 3.5: Análisis NUI (si aplica)

Si el recurso tiene `ui_page` declarada:

1. Leer `index.html` — Listar TODAS las URLs externas (`<script src=`, `<link href=`, etc.)
2. Para cada URL externa:
   - ¿Es un CDN conocido? → OK con nota
   - ¿Es un dominio desconocido/personal? → **HALLAZGO ALTO**
   - Si es JS externo desconocido: **DESCARGAR** el archivo y verificar su contenido
3. Leer archivos JS — Buscar `eval()`, `innerHTML` con datos dinámicos, `fetch()` a URLs externas
4. Verificar si jQuery se carga duplicado (FiveM ya provee `nui://game/ui/jquery.js`)

### Paso 3.6: Verificación de dependencias externas

Si el HTML carga JS/CSS desde dominios externos:

1. **Descargar** el archivo con `Invoke-WebRequest` o `read_url_content`
2. **Leer** el contenido descargado
3. **Determinar** si es una librería legítima conocida (jQuery, Bootstrap, Materialize, Font Awesome, TensorFlow.js, etc.)
4. **Buscar** dentro del archivo descargado: `eval(`, `fetch(`, `XMLHttpRequest`, `WebSocket`, `document.cookie`
5. Si es legítimo → Alojar localmente como remediación
6. Si NO es legítimo o contiene código sospechoso → **HALLAZGO CRÍTICO**

---
---

## Fase 4 — Generación del Reporte

### Paso 4.1: Estructura obligatoria del reporte

El reporte DEBE guardarse en:
```
c:\admirales\script_ver\script_ver\reports\audit_AUD-[NNN]_[nombre-recurso]_[YYYY-MM-DD].md
```

**Secciones obligatorias** (usa `reports/audit_AUD-001_nc-multicharacter_2026-04-14.md` como plantilla):

1. **Encabezado** — ID, recurso, fecha, analista, origen, versión
2. **Inventario de archivos** — Con hashes SHA-256
3. **Nivel 1 — Resultados del escaneo** — Tabla por categoría (C, A, M)
4. **Nivel 2 — Revisión manual** — Hallazgos detallados con código
5. **Análisis de eventos** — Tabla de RegisterNetEvent
6. **Análisis SQL** — Tabla de queries
7. **Análisis NUI** — URLs externas, XSS
8. **Resumen de hallazgos** — Tabla con todos los H-xx
9. **Decisión final** — APROBADO / LIMPIEZA / RECHAZADO
10. **Dependencias** — Lista de recursos requeridos

---
---

## Fase 5 — Decisión y Limpieza

### Paso 5.1: Árbol de decisión

```
¿Hay hallazgos de rechazo automático (R-01 a R-07)?
├── SÍ → RECHAZAR. Mover a /rejected/. FIN.
│
├── NO → ¿Hay hallazgos CRÍTICOS (🔴)?
│         ├── SÍ → ¿Es malware confirmado (RAT, exfiltración)?
│         │         ├── SÍ → RECHAZAR. FIN.
│         │         └── NO (es vulnerabilidad remediable)
│         │               → LIMPIEZA REQUERIDA. Ir a 5.2.
│         │
│         └── NO → ¿Hay hallazgos ALTOS (🟠)?
│                   ├── SÍ → LIMPIEZA REQUERIDA. Ir a 5.2.
│                   │
│                   └── NO → ¿Hay hallazgos MEDIOS (🟡)?
│                             ├── SÍ → LIMPIEZA RECOMENDADA.
│                             │         Puede aprobarse documentando riesgos.
│                             │
│                             └── NO → APROBADO DIRECTO. Ir a Fase 6.
```

### Paso 5.2: Catálogo de remediaciones

**IMPORTANTE:** Al aplicar cualquier fix, NUNCA cambies la lógica funcional del script. Solo añade guardas de seguridad.

---

#### FIX-01: URLs externas en HTML → Alojar localmente

**Cuándo aplicar:** Cuando `index.html` carga JS/CSS desde dominios no confiables.

**Procedimiento:**
1. Descargar el archivo externo al directorio `html/js/` o `html/css/` del recurso
2. Verificar que el contenido es legítimo (ver Paso 3.6)
3. Cambiar la referencia en HTML de URL externa a ruta local
4. Si es jQuery CDN y ya existe `nui://game/ui/jquery.js` → Eliminar la duplicación
5. Actualizar `fxmanifest.lua` → `files {}` con el nuevo archivo

**Impacto funcional:** ✅ NINGUNO. El mismo código se carga, solo desde local.

**Ejemplo:**
```html
<!-- ANTES (inseguro) -->
<script src="https://dominio-desconocido.netlify.app/script.js"></script>

<!-- DESPUÉS (seguro) -->
<!-- [AUDIT AUD-XXX] script.js alojado localmente -->
<script src="js/script.js"></script>
```

---

#### FIX-02: Font externa → Font-stack seguro con fallback

**Cuándo aplicar:** Cuando un CSS carga fuentes desde un CDN no confiable.

**Procedimiento:**
1. Identificar qué font-family usa el CSS (buscar en `style.css`)
2. Si la fuente es de Google Fonts → Mantener (CDN confiable)
3. Si la fuente es de dominio desconocido:
   - Si hay archivos woff/woff2 disponibles → Descargar y alojar localmente
   - Si NO hay archivos (solo URL al CDN) → Crear `@font-face` fallback:

```css
/* Ejemplo: Reemplazar "FontExterna" con Inter como fallback */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@100;200;300;400;500;600;700;800;900&display=swap');

@font-face {
    font-family: 'FontExterna';
    src: local('Inter'), local('Arial');
    font-weight: 100 900;
    font-style: normal;
}
```

**Impacto funcional:** ✅ MÍNIMO. La fuente cambia ligeramente pero la UI sigue funcional.

---

#### FIX-03: Callback sin autenticación → Eliminar o proteger

**Cuándo aplicar:** Cuando un `CreateCallback` devuelve datos sensibles sin verificar permisos.

**Opción A — Eliminar** (si no es necesario para la funcionalidad principal):
```lua
-- [AUDIT AUD-XXX] Callback [nombre] ELIMINADO: exponía [datos] sin autenticación
```

**Opción B — Proteger** (si la funcionalidad lo necesita):
```lua
QBCore.Functions.CreateCallback("recurso:server:callback", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then cb({}) return end
    -- Añadir verificación de permisos según el caso:
    -- if not QBCore.Functions.HasPermission(src, 'admin') then cb({}) return end
    -- Lógica original aquí...
end)
```

**Cómo determinar impacto funcional:**
- Buscar en `client/*.lua` y `html/js/*.js` si el callback se usa
- Si se llama en el flujo principal → Proteger (Opción B)
- Si NO se llama desde ningún archivo del recurso → Eliminar (Opción A)

---

#### FIX-04: Evento server sin validación → Añadir guards

**Cuándo aplicar:** Cuando `RegisterNetEvent` no valida los datos recibidos del cliente.

**Plantilla de fix:**
```lua
RegisterNetEvent('recurso:server:evento', function(data)
    local src = source
    -- [AUDIT AUD-XXX] Validación de datos del cliente
    if type(data) ~= 'table' then return end
    if type(data.campo1) ~= 'string' then return end
    if type(data.campo2) ~= 'number' then return end
    -- Para strings que van a BD: limitar longitud
    if #data.campo1 > 50 then return end
    -- Para números: validar rango
    if data.campo2 < 0 or data.campo2 > 1000 then return end

    -- ... código original sin modificar ...
end)
```

**Impacto funcional:** ✅ NINGUNO si los guards solo validan tipos correctos. El flujo legítimo siempre envía datos del tipo esperado.

**Cómo determinar los tipos esperados:**
1. Buscar en `client/*.lua` el `TriggerServerEvent` correspondiente
2. O buscar en `html/js/*.js` el `$.post('https://[recurso]/...')` correspondiente
3. Ver qué datos envía el cliente → Esos son los tipos válidos

---

#### FIX-05: Wildcards en fxmanifest → Declaraciones explícitas

**Cuándo aplicar:** Cuando `fxmanifest.lua` usa `*.lua`, `**/*.lua`, `*` en scripts o files.

**Procedimiento:**
1. Listar archivos reales en cada directorio afectado
2. Reemplazar el wildcard por declaraciones explícitas

**Ejemplo:**
```lua
-- ANTES
shared_scripts { 'locales/*.lua' }
files { 'html/js/*', 'html/css/*' }

-- DESPUÉS
shared_scripts { 'locales/en.lua' }
files {
    'html/js/script.js',
    'html/js/materialize.js',
    'html/css/reset.css',
    'html/css/style.css',
}
```

**Impacto funcional:** ✅ NINGUNO si todos los archivos existentes están listados.

---

#### FIX-06: Referencias a archivos inexistentes → Eliminar

**Cuándo aplicar:** Cuando HTML o manifiesto referencia archivos que no existen.

**Procedimiento:**
1. Verificar que los archivos no existen (`list_dir`)
2. Eliminar la referencia
3. Verificar si algún código JS depende de ellos
   - Si sí → La función ya estaba rota de todas formas. Documentar.
   - Si no → Limpieza simple.

**Impacto funcional:** ✅ NINGUNO. Los archivos ya no existían, la carga ya fallaba silenciosamente.

---

#### FIX-07: SQL por concatenación → Parametrizar

**Cuándo aplicar:** Cuando una query SQL usa `..` para concatenar variables.

```lua
-- ANTES (vulnerable)
MySQL.query("SELECT * FROM users WHERE name = '" .. name .. "'")

-- DESPUÉS (seguro)
MySQL.query("SELECT * FROM users WHERE name = ?", {name})
```

**Impacto funcional:** ✅ NINGUNO. La query produce el mismo resultado.

---

#### FIX-08: RegisterCommand en client_script → Solo ACE nativo

**Cuándo aplicar:** Cuando un `RegisterCommand` en un `client_script` necesita protección de permisos.

**NUNCA hacer esto en client_script:**
```lua
-- ❌ INCORRECTO — QBCore server functions en client = CRASH
RegisterCommand('micomando', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)  -- ❌ nil
    if not QBCore.Functions.HasPermission(source, 'admin') then return end  -- ❌ nil
end)
```

**Hacer esto en su lugar:**
```lua
-- ✅ CORRECTO — ACE nativo funciona en client Y server
RegisterCommand('micomando', function(source, args)
    -- Lógica del comando...
end, true)  -- 'true' = requiere permiso ACE 'command.micomando'
```

**Configuración requerida en `server.cfg`:**
```cfg
add_ace group.admin command.micomando allow
```

**Impacto funcional:** ✅ NINGUNO. La protección ACE es la forma nativa y correcta de FiveM.

> Origen: Auditoría AUD-002 — Otra IA añadió `QBCore.Functions.GetPlayer()` en un client_script, causando crash.

---
---

## Fase 6 — Cierre y Movimiento

### Paso 6.1: Mover recurso según decisión

```powershell
# Si APROBADO (limpio o limpiado):
Move-Item -Path "c:\admirales\script_ver\script_ver\quarantine\under-review\[nombre]" -Destination "c:\admirales\script_ver\script_ver\approved\[nombre]"

# Si RECHAZADO:
Move-Item -Path "c:\admirales\script_ver\script_ver\quarantine\under-review\[nombre]" -Destination "c:\admirales\script_ver\script_ver\rejected\[nombre]"
```

### Paso 6.2: Actualizar decisión en el reporte

Añadir bloque de decisión final al reporte con:
- Veredicto: APROBADO / LIMPIADO Y APROBADO / RECHAZADO
- Resumen de cambios aplicados (si hubo limpieza)
- Lista de dependencias necesarias

### Paso 6.3: Confirmar al usuario

Presentar resumen al usuario con:
1. Número de hallazgos por severidad
2. Qué se hizo (limpieza, eliminación, etc.)
3. Ubicación final del recurso
4. Próximos pasos recomendados

---
---

## Apéndice: Conocimiento FiveM/QBCore para Remediación

### Funciones QBCore que validan internamente

Estas funciones de QBCore tienen validaciones internas que mitigan parcialmente los riesgos, pero NO remplazan la validación en el propio evento:

| Función | Qué valida internamente |
|:---|:---|
| `QBCore.Player.Login(src, citizenid)` | Verifica que el citizenid pertenezca a la licencia del `src` |
| `QBCore.Player.DeleteCharacter(src, citizenid)` | Verifica propiedad del personaje |
| `QBCore.Functions.GetPlayer(src)` | Devuelve `nil` si el source no es válido |
| `QBCore.Functions.HasPermission(src, perm)` | Verifica permisos ACE |

**Regla:** Aunque QBCore valide internamente, SIEMPRE añadir validación de tipo en el evento. Es defensa en profundidad.

### Eventos que NUNCA deben eliminarse

| Evento | Por qué es necesario |
|:---|:---|
| `server:loadUserData` | Carga del personaje seleccionado — flujo principal |
| `server:createCharacter` | Creación de personaje — flujo principal |
| `server:deleteCharacter` | Borrado de personaje — flujo principal |
| `server:disconnect` | Desconexión del jugador |
| Callbacks `GetUserCharacters`, `setupCharacters`, `getSkin` | Alimentan la UI del selector |

### Eventos/Callbacks que SÍ pueden eliminarse (si son innecesarios)

| Patrón | Razón para eliminar |
|:---|:---|
| Callbacks que hacen `SELECT *` de tablas no relacionadas | Exposición de datos innecesaria |
| Eventos sin referencia desde ningún archivo del recurso | Código muerto/debug |
| Comandos sin restricción de permisos que otorgan privilegios | Posible backdoor |

### Dependencia de jQuery en FiveM

FiveM provee jQuery internamente en `nui://game/ui/jquery.js`. Si un recurso también carga jQuery desde un CDN externo, es **duplicación** y se puede eliminar la carga CDN sin afectar funcionalidad.

### Variables `source` en FiveM

En eventos server-side de FiveM:
- `source` es asignado automáticamente por el framework al jugador que disparó el evento.
- NUNCA debe venir como argumento del evento (un ejecutor puede falsificarlo).
- El patrón correcto es siempre `local src = source` al inicio del handler.

### ⚠️ Frontera Client / Server (Regla aprendida en AUD-002)

**Error común de IAs:** Aplicar patrones de validación server-side en archivos client-side.

**Resumen de la regla:**
- `QBCore.Functions.GetPlayer()` → Solo SERVER
- `QBCore.Functions.HasPermission()` → Solo SERVER
- `QBCore.Functions.CreateCallback()` → Solo SERVER
- `RegisterCommand(name, handler, true)` → Funciona en AMBOS (usa ACE nativo)
- `source` en RegisterCommand client = siempre `0` (consola local)
- `source` en RegisterCommand server = ID del jugador

**Antes de aplicar un FIX, SIEMPRE verificar:**
1. ¿El archivo está declarado como `client_script` o `server_script` en `fxmanifest.lua`?
2. ¿Las funciones que estoy usando existen en ese contexto?
3. ¿El `source` significa lo que creo que significa en este contexto?

---

> **Nota final:** Este runbook se actualiza con cada auditoría completada.
> Los patrones de remediación (FIX-01 a FIX-08) se expanden conforme se encuentren nuevos tipos de hallazgos.
> 
> **Changelog:**
> - v1.1.0 (15-Abr-2026): Regla R-00 (client/server), FIX-08, Apéndice expandido. Origen: AUD-002.
> - v1.0.0 (14-Abr-2026): Versión inicial. Origen: AUD-001.
