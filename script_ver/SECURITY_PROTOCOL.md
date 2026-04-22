# Protocolo de Auditoría de Seguridad y Sanitización de Scripts

## FiveM / QBCore — Proyecto Admirales

| Campo | Valor |
|:---|:---|
| **Versión del Documento** | `2.0.0` |
| **Estado** | 🟢 Activo — En vigor |
| **Fase del Proyecto** | Fase 0 — Preparación y Sandbox |
| **Clasificación** | 🔒 Documento Interno — Equipo de Seguridad |
| **Última Revisión** | 14-Abril-2026 |
| **Autor** | Equipo de Seguridad — Proyecto Admirales |
| **Documentos Complementarios** | [`AI_RUNBOOK.md`](AI_RUNBOOK.md) — Guía paso a paso para ejecución por IA |

---

> **Principio Rector:**  
> *"La ciberseguridad es un proceso continuo, no un producto final.  
> Ningún recurso externo se considera seguro hasta que se demuestre lo contrario."*

---

## Índice

| # | Sección | Prioridad |
|:---:|:---|:---:|
| 1 | [Política de Tolerancia Cero y Cuarentena](#-1-política-de-tolerancia-cero-y-cuarentena) | 🔴 CRÍTICA |
| 2 | [Taxonomía de Amenazas](#-2-taxonomía-de-amenazas-en-fivemqbcore) | 🔴 CRÍTICA |
| 3 | [Infraestructura del Entorno de Auditoría](#-3-infraestructura-del-entorno-de-auditoría) | 🔴 CRÍTICA |
| 4 | [Análisis Estático — Nivel 1: Detección Automatizada](#-4-análisis-estático--nivel-1-detección-automatizada) | 🔴 CRÍTICA |
| 5 | [Análisis Estático — Nivel 2: Revisión Manual Profunda](#-5-análisis-estático--nivel-2-revisión-manual-profunda) | 🔴 CRÍTICA |
| 6 | [Auditoría del Manifiesto (`fxmanifest.lua`)](#-6-auditoría-del-manifiesto-fxmanifestlua) | 🟠 ALTA |
| 7 | [Seguridad de Eventos y Lógica del Servidor](#-7-seguridad-de-eventos-y-lógica-del-servidor) | 🟠 ALTA |
| 8 | [Prevención de Inyección SQL](#-8-prevención-de-inyección-sql) | 🟠 ALTA |
| 9 | [Seguridad NUI / Interfaz Web](#-9-seguridad-nui--interfaz-web) | 🟡 MEDIA |
| 10 | [Procedimiento de Limpieza Quirúrgica y Respuesta a Incidentes](#-10-procedimiento-de-limpieza-quirúrgica-y-respuesta-a-incidentes) | 🔴 CRÍTICA |
| 11 | [Traspaso al Equipo de Instalación (Handoff)](#-11-traspaso-al-equipo-de-instalación-handoff) | 🟡 MEDIA |
| 12 | [Registro de Auditoría (Audit Log)](#-12-registro-de-auditoría-audit-log) | 🟡 MEDIA |
| A | [Apéndice A: Patrones de Búsqueda (Grep/Regex)](#apéndice-a-patrones-de-búsqueda-grepregex) | — |
| B | [Apéndice B: Clasificación de Severidad](#apéndice-b-clasificación-de-severidad) | — |
| C | [Apéndice C: Glosario de Términos](#apéndice-c-glosario-de-términos) | — |

---
---

## 🛡️ 1. Política de Tolerancia Cero y Cuarentena

### 1.1 Regla de Oro

> **Ningún recurso de origen externo** (descargado, comprado, filtrado, donado o compartido) **se ejecuta directamente** en el entorno principal sin una auditoría de seguridad completa y documentada.

Esta regla **no tiene excepciones**. Incluye:
- Scripts de Lua (`.lua`)
- Scripts de JavaScript (`.js`, `.ts`)
- Interfaces HTML/CSS
- Mapas (`.ymap`, `.ytyp`)
- Vehículos, peds y props
- Cualquier recurso que contenga código ejecutable

### 1.2 Flujo de Cuarentena

El ciclo de vida de todo recurso externo sigue el siguiente flujo obligatorio:

```
┌─────────────┐    ┌──────────────────┐    ┌─────────────────┐    ┌──────────────┐    ┌───────────────┐
│  INGRESO    │───▶│   CUARENTENA     │───▶│   AUDITORÍA     │───▶│  LIMPIEZA    │───▶│   APROBADO    │
│  (Nuevo     │    │  /quarantine/    │    │  Estática +     │    │  Quirúrgica  │    │  Promovido a  │
│   recurso)  │    │  rama: audit/*   │    │  Manual         │    │  (si aplica) │    │  /resources/  │
└─────────────┘    └──────────────────┘    └─────────────────┘    └──────────────┘    └───────────────┘
                          │                        │                      │
                          │                   ┌────▼────┐           ┌─────▼─────┐
                          │                   │RECHAZADO│           │ RE-AUDIT  │
                          │                   │(Eliminar│           │ (Requiere │
                          │                   │ recurso)│           │  2ª pasada│
                          │                   └─────────┘           │  de verif)│
                          │                                         └───────────┘
                          ▼
                   Si contiene archivos
                   binarios (.exe, .dll,
                   .bat, .ps1) → RECHAZO
                   INMEDIATO sin análisis
```

### 1.3 Estructura de Carpetas en el Repositorio

```
script_ver/
├── /quarantine/                  # Recursos en espera de auditoría
│   ├── /incoming/                # Recursos recién recibidos (sin tocar)
│   └── /under-review/            # Recursos actualmente en análisis
├── /approved/                    # Recursos que pasaron la auditoría
│   ├── /[qb]/                    # Recursos core de QBCore
│   ├── /[standalone]/            # Recursos independientes
│   └── /[maps]/                  # Mapas y entornos
├── /rejected/                    # Recursos rechazados (conservar para referencia)
│   └── /YYYY-MM-DD_nombre/       # Carpeta con fecha de rechazo
├── /reports/                     # Reportes de auditoría generados
│   └── /audit_YYYY-MM-DD/        # Reportes agrupados por fecha
├── /tools/                       # Scripts de escaneo y herramientas
│   ├── scan_backdoors.lua
│   └── patterns.txt
└── SECURITY_PROTOCOL.md          # Este documento
```

### 1.4 Reglas de la Rama Git

| Rama | Propósito | Protección |
|:---|:---|:---|
| `main` | Código aprobado y en producción | Push directo **prohibido** |
| `audit/*` | Recursos en proceso de auditoría | Solo equipo de seguridad |
| `quarantine/*` | Recursos sin revisar | Solo ingreso inicial |
| `hotfix/*` | Parches urgentes post-producción | Requiere 2ª aprobación |

---
---

## 🔬 2. Taxonomía de Amenazas en FiveM/QBCore

Antes de auditar, el analista **debe** conocer las categorías de amenazas existentes. A continuación se catalogan por nivel de peligrosidad descendente.

### 2.1 🔴 Amenazas Críticas (Compromiso total del servidor)

#### 2.1.1 RAT — Remote Access Trojan (Troyano de Acceso Remoto)

| Aspecto | Detalle |
|:---|:---|
| **Descripción** | Código que usa `PerformHttpRequest` para descargar y ejecutar código remoto desde un servidor controlado por el atacante. |
| **Mecanismo** | `PerformHttpRequest(url, function(code) load(code)() end)` |
| **Impacto** | Control total del servidor: robo de credenciales, manipulación de base de datos, destrucción total. |
| **Frecuencia** | MUY ALTA — Es la amenaza #1 en scripts filtrados. |
| **Ubicación típica** | Final de `server.lua`, dentro de bloques ofuscados, o en archivos auxiliares poco evidentes. |

#### 2.1.2 Auto-Propagación (Self-Propagating Malware)

| Aspecto | Detalle |
|:---|:---|
| **Descripción** | Malware avanzado que inyecta su código en otros recursos "limpios" del servidor. |
| **Mecanismo** | Lectura/escritura de archivos mediante `io.open()`, `io.popen()`, o `os.execute()` para modificar otros scripts existentes. |
| **Impacto** | Infección persistente. Incluso después de eliminar el recurso original, el código malicioso persiste en otros recursos. |
| **Frecuencia** | ALTA — Familia de malware "Cipher" y variantes. |
| **Indicador** | Modificaciones inesperadas en archivos de otros recursos; timestamps de archivos alterados. |

#### 2.1.3 Exfiltración de Datos Sensibles

| Aspecto | Detalle |
|:---|:---|
| **Descripción** | Envío silencioso de `server.cfg`, credenciales de base de datos, licencia CFX y tokens a servidores externos. |
| **Mecanismo** | Lectura de archivos de configuración + `PerformHttpRequest` POST a webhook externo. |
| **Impacto** | Robo completo de identidad del servidor, acceso a la base de datos, suplantación de licencia. |
| **Frecuencia** | ALTA |

### 2.2 🟠 Amenazas Altas (Compromiso parcial / explotación)

#### 2.2.1 Backdoors de Privilegios

| Aspecto | Detalle |
|:---|:---|
| **Descripción** | Comandos ocultos que otorgan permisos de administrador, dinero, ítems o "God Mode" a identificadores específicos (SteamID, Discord ID, License). |
| **Mecanismo** | `RegisterCommand` o `RegisterNetEvent` condicionados a un ID específico hardcodeado. |
| **Impacto** | Acceso administrativo no autorizado, manipulación de economía del servidor. |
| **Indicadores** | Comparaciones hardcodeadas: `if identifier == "steam:xxxx"`, `if discordId == "123456"`. |

#### 2.2.2 Inyección SQL

| Aspecto | Detalle |
|:---|:---|
| **Descripción** | Consultas SQL construidas por concatenación de strings con datos del cliente sin sanitizar. |
| **Mecanismo** | `MySQL.query("SELECT * FROM users WHERE name = '" .. name .. "'")` |
| **Impacto** | Lectura, modificación o destrucción de toda la base de datos. |

#### 2.2.3 Explotación de Eventos (Event Injection)

| Aspecto | Detalle |
|:---|:---|
| **Descripción** | Eventos del servidor (`RegisterNetEvent`) que no validan el origen, tipo o rango de los datos recibidos del cliente. |
| **Mecanismo** | Un ejecutor (executor/injector) en el cliente dispara `TriggerServerEvent` con datos manipulados. |
| **Impacto** | Generación ilícita de dinero, duplicación de ítems, escalación de privilegios. |

### 2.3 🟡 Amenazas Medias (Impacto localizado)

| Amenaza | Descripción | Impacto |
|:---|:---|:---|
| **Memory Leaks** | Variables globales sin limpiar, threads sin destruir, listeners acumulados. | Degradación progresiva del rendimiento, crashes del servidor. |
| **XSS en NUI** | Uso de `innerHTML` con datos no sanitizados en interfaces web del recurso. | Ejecución de scripts maliciosos en el cliente del jugador. |
| **Dependencias Fantasma** | Recursos que dependen de librerías no declaradas o versiones específicas no verificadas. | Errores silenciosos, comportamiento impredecible. |
| **Archivos Huérfanos** | Archivos `.exe`, `.dll`, `.bat`, `.ps1`, `.sh` dentro del recurso que no corresponden a FiveM. | Ejecución de código nativo no controlado. |

---
---

## 🏗️ 3. Infraestructura del Entorno de Auditoría

### 3.1 Requisitos del Entorno Sandbox

La auditoría **NUNCA** se realiza en el servidor de producción. Se utiliza el entorno aislado previamente establecido:

| Componente | Configuración |
|:---|:---|
| **Instancia del Servidor** | `admirales_fase0` (puertos 30124/40124) |
| **Base de Datos** | `admirales_dev` — Aislada de producción |
| **Conectividad Externa** | Monitorizada — Registrar toda petición HTTP saliente |
| **Acceso** | Solo equipo de seguridad (ACL restringido) |
| **Backups** | Snapshot antes de cada prueba de recurso |
| **Git** | Rama `audit/*` dedicada por cada recurso bajo análisis |

### 3.2 Herramientas Requeridas

| Herramienta | Propósito | Prioridad |
|:---|:---|:---:|
| **VS Code** + extensión de Lua | Editor principal con "Find in Files" recursivo | 🔴 |
| **grep / ripgrep (rg)** | Búsqueda de patrones en masa por línea de comandos | 🔴 |
| **Git** | Control de versiones, diffing antes/después de limpieza | 🔴 |
| **Wireshark / Monitor de Red** | Captura de tráfico HTTP saliente durante pruebas dinámicas | 🟠 |
| **CipherScanner** (GitHub) | Escáner comunitario de firmas de malware FiveM conocidas | 🟠 |
| **Desobfuscador Lua** | Herramienta para revertir ofuscaciones comunes (`\x`, Base64, `string.char`) | 🟠 |
| **txAdmin** | Monitoreo del servidor sandbox, gestión de recursos | 🟡 |

### 3.3 Preparación Antes de Cada Auditoría

Antes de iniciar el análisis de un recurso nuevo:

1. **Crear snapshot/backup** del estado actual del sandbox.
2. **Crear rama Git** dedicada: `git checkout -b audit/nombre-recurso-YYYY-MM-DD`.
3. **Copiar recurso** a `/quarantine/under-review/`.
4. **Registrar entrada** en el Audit Log (Sección 12).
5. **Documentar origen**: URL de descarga, autor declarado, marketplace, y hash SHA-256 del archivo recibido.

```powershell
# Generar hash SHA-256 del recurso recibido (PowerShell)
Get-FileHash -Path ".\recurso.zip" -Algorithm SHA256 | Format-List
```

---
---

## 🤖 4. Análisis Estático — Nivel 1: Detección Automatizada

Esta es la **primera línea de defensa**. Se ejecutan búsquedas automatizadas de patrones conocidos de código malicioso. Cada hallazgo se marca con un nivel de severidad.

> ⚠️ **IMPORTANTE:** Un resultado positivo en la búsqueda automatizada **NO** confirma automáticamente una amenaza. Cada hallazgo debe ser verificado manualmente en la Sección 5. Sin embargo, un resultado positivo **SÍ** eleva la prioridad de revisión.

### 4.1 Checklist de Escaneo Automatizado

#### 🔴 CATEGORÍA CRÍTICA — Ejecución Remota y Ofuscación

| # | Patrón de Búsqueda | Motivo | Acción al Detectar |
|:---:|:---|:---|:---|
| C-01 | `PerformHttpRequest` | Método principal de comunicación externa. Usado para RATs y exfiltración. | Verificar CADA instancia. Solo permitir webhooks autorizados y configurables desde `config.lua`. |
| C-02 | `PerformHttpRequestInternal` | Variante interna del mismo método. | Mismo tratamiento que C-01. |
| C-03 | `load(` | Ejecución dinámica de código. Combinado con datos remotos = backdoor. | ALERTA MÁXIMA si recibe datos de `PerformHttpRequest` o variables no locales. |
| C-04 | `loadstring(` | Equivalente a `load()` en Lua 5.1. | Mismo tratamiento que C-03. |
| C-05 | `assert(load(` | Patrón clásico de ejecución ofuscada con manejo de errores. | RECHAZAR el recurso si no se puede justificar su uso legítimo. |
| C-06 | `RunString(` | Ejecución de strings como código nativo de FiveM. | ALERTA MÁXIMA. Raramente legítimo en scripts convencionales. |
| C-07 | `\x[0-9a-fA-F]{2}` | Cadenas hexadecimales usadas para ocultar nombres de funciones peligrosas. | Desobfuscar y verificar qué string real representan. |
| C-08 | `string.char(` | Construcción dinámica de strings. Usado para evadir detección de keywords. | Evaluar el contexto. Sospechoso si construye nombres de funciones. |
| C-09 | `os.execute(` | Ejecución de comandos del sistema operativo. | RECHAZO INMEDIATO salvo justificación excepcional documentada. |
| C-10 | `io.popen(` | Apertura de procesos del sistema con lectura de salida. | RECHAZO INMEDIATO. |
| C-11 | `io.open(` | Lectura/escritura de archivos del sistema. Vector de auto-propagación. | Verificar qué archivos accede. Solo aceptar si lee archivos propios del recurso. |
| C-12 | `debug.getinfo` | Introspección del entorno Lua. Usado para evadir sandboxes. | Sospechoso en recursos convencionales. Revisar contexto. |

#### 🟠 CATEGORÍA ALTA — Backdoors y Privilegios

| # | Patrón de Búsqueda | Motivo | Acción al Detectar |
|:---:|:---|:---|:---|
| A-01 | `steam:` (hardcodeado) | Identificador de Steam en código. Posible backdoor de permisos. | Verificar si es configurable desde `config.lua` o está hardcodeado como privilegio oculto. |
| A-02 | `discord:` (hardcodeado) | Identificador de Discord en código. | Mismo tratamiento que A-01. |
| A-03 | `license:` (hardcodeado) | Identificador de licencia FiveM. | Mismo tratamiento que A-01. |
| A-04 | `ip:` (hardcodeado) | Dirección IP en código. | Verificar propósito. Posible whitelist oculta o exfiltración. |
| A-05 | `RegisterCommand` | Registro de comandos. | Verificar que todos los comandos estén documentados y protegidos por ACL/permisos. |
| A-06 | `RegisterNetEvent` | Registro de eventos de red. | Cross-reference con la documentación del recurso. Buscar eventos no documentados. |
| A-07 | `SetRoutingBucketEntityLockdownMode` | Manipulación de buckets de routing. | Sospechoso si no es un recurso de instancias. |
| A-08 | `GetConvar` / `GetConvarInt` | Lectura de variables de configuración del servidor. | Verificar que no lea `sv_licenseKey`, `mysql_connection_string` u otros sensibles. |
| A-09 | `ExecuteCommand` | Ejecución de comandos del servidor desde script. | ALERTA ALTA. Verificar que no ejecute `restart`, `stop`, o comandos de ACL. |

#### 🟡 CATEGORÍA MEDIA — Vulnerabilidades y Malas Prácticas

| # | Patrón de Búsqueda | Motivo | Acción al Detectar |
|:---:|:---|:---|:---|
| M-01 | Concatenación SQL (`.. "` + variable) | Potencial inyección SQL por concatenación directa. | Refactorizar a consultas parametrizadas. |
| M-02 | `innerHTML` (en archivos `.html`/`.js`) | Potencial XSS si se inyectan datos no sanitizados. | Reemplazar por `textContent` o usar DOMPurify. |
| M-03 | `eval(` (en archivos `.js`) | Ejecución dinámica de JavaScript. | RECHAZAR en contexto de NUI. |
| M-04 | `dangerouslySetInnerHTML` | React: inserción no segura de HTML. | Requerir sanitización con DOMPurify. |
| M-05 | `Citizen.CreateThread` sin `Wait` | Loop infinito sin pausa. Causa 100% uso de CPU. | Añadir `Citizen.Wait(ms)` apropiado. |
| M-06 | Variables globales excesivas | Variables no declaradas como `local`. Memory leak potencial. | Refactorizar a `local`. |
| M-07 | `TriggerClientEvent(-1,` | Broadcast a todos los clientes. | Verificar que no envíe payloads excesivos o datos sensibles. |

### 4.2 Comandos de Escaneo Rápido

Ejecutar estos comandos desde la raíz del recurso bajo análisis:

```powershell
# ========================================================
# ESCANEO CRÍTICO — Ejecutar PRIMERO
# ========================================================

# C-01/C-02: Comunicación HTTP externa
rg -n -i "PerformHttpRequest" --type lua --type js

# C-03/C-04/C-05: Ejecución dinámica de código
rg -n -i "load\(|loadstring\(|assert\(load" --type lua

# C-06: RunString
rg -n -i "RunString" --type lua --type js

# C-07: Hexadecimales ofuscados
rg -n "\\\\x[0-9a-fA-F]{2}" --type lua

# C-08: Construcción dinámica de strings
rg -n "string\.char\(" --type lua

# C-09/C-10/C-11: Acceso al sistema operativo
rg -n -i "os\.execute\(|io\.popen\(|io\.open\(" --type lua

# C-12: Debug/introspección
rg -n "debug\." --type lua

# ========================================================
# ESCANEO ALTO — Ejecutar SEGUNDO
# ========================================================

# A-01 a A-04: Identificadores hardcodeados
rg -n -i "steam:|discord:|license:|ip:" --type lua

# A-05/A-06: Comandos y eventos
rg -n "RegisterCommand\|RegisterNetEvent" --type lua

# A-08: Lectura de convars
rg -n "GetConvar" --type lua

# A-09: Ejecución de comandos del servidor
rg -n "ExecuteCommand" --type lua

# ========================================================
# ESCANEO MEDIO — Ejecutar TERCERO
# ========================================================

# M-01: SQL por concatenación
rg -n "\.\.\s*['\"].*SELECT|INSERT|UPDATE|DELETE" --type lua -i

# M-02/M-03: Vulnerabilidades web
rg -n "innerHTML|eval\(" --type js --type html

# Archivos binarios sospechosos
Get-ChildItem -Recurse -Include *.exe,*.dll,*.bat,*.ps1,*.sh,*.cmd,*.vbs | Select-Object FullName
```

### 4.3 Resultado Esperado del Nivel 1

Al finalizar el escaneo automatizado, generar un resumen con este formato:

```
╔══════════════════════════════════════════════════════════╗
║       RESULTADO DEL ESCANEO AUTOMATIZADO (Nivel 1)      ║
╠══════════════════════════════════════════════════════════╣
║ Recurso:        [nombre-del-recurso]                    ║
║ Fecha:          [YYYY-MM-DD HH:MM]                      ║
║ Analista:       [nombre]                                 ║
╠══════════════════════════════════════════════════════════╣
║ Hallazgos Críticos (🔴):    [N]                         ║
║ Hallazgos Altos (🟠):       [N]                         ║
║ Hallazgos Medios (🟡):      [N]                         ║
║ Archivos Binarios:          [N]                         ║
╠══════════════════════════════════════════════════════════╣
║ DECISIÓN PRELIMINAR:                                    ║
║ [ ] → Continuar a Nivel 2 (Revisión Manual)             ║
║ [ ] → RECHAZAR (amenaza confirmada en escaneo)          ║
╚══════════════════════════════════════════════════════════╝
```

---
---

## 🔍 5. Análisis Estático — Nivel 2: Revisión Manual Profunda

Todo recurso que pase el Nivel 1 (o que tenga hallazgos que requieran verificación manual) **debe** ser revisado archivo por archivo.

### 5.1 Orden de Revisión (por prioridad de riesgo)

| Orden | Archivo/Área | Razón |
|:---:|:---|:---|
| 1º | `fxmanifest.lua` / `__resource.lua` | Define qué se carga. Un archivo extra aquí = código oculto ejecutándose. |
| 2º | `server.lua` / `server/*.lua` | Archivos server-side tienen acceso completo a la BD y al sistema. |
| 3º | `config.lua` / `shared/*.lua` | Configuración compartida. Puede contener identificadores hardcodeados. |
| 4º | `client.lua` / `client/*.lua` | Archivos client-side. Menor riesgo directo pero pueden facilitar exploits. |
| 5º | Archivos `.js` / `.html` / `.css` | Interfaces NUI. Riesgo de XSS e inyección. |
| 6º | Archivos auxiliares / subdirectorios | `lib/`, `modules/`, `utils/`. A menudo contienen código ofuscado. |
| 7º | Archivos de datos (`.json`, `.sql`) | Verificar integridad de esquemas y datos iniciales. |

### 5.2 Checklist de Revisión Manual

#### Revisión del `fxmanifest.lua`

- [ ] **Verificar `fx_version`:** Debe ser `cerulean` u otra versión actual soportada.
- [ ] **Verificar `game`:** Debe ser `'gta5'` (o el juego correcto del proyecto).
- [ ] **Listar TODOS los archivos en `client_scripts` y `server_scripts`:** Confirmar que cada archivo listado existe físicamente en el recurso y que no hay archivos extra no listados pero presentes en el directorio.
- [ ] **Buscar carga con wildcard:** Patrones como `server_scripts { '**/*.lua' }` son un riesgo: cargan cualquier `.lua` que se coloque en el directorio, incluido malware inyectado.
- [ ] **Verificar `files`:** Solo deben incluirse assets necesarios (HTML, CSS, imágenes). No archivos `.lua` adicionales ni ejecutables.
- [ ] **Buscar `loadscreen`:** Si existe, verificar que el HTML no contenga scripts maliciosos.
- [ ] **Verificar dependencias (`dependencies`):** Asegurar que sean recursos oficiales/conocidos.

#### Revisión del Código Lua

- [ ] **Leer el final de cada archivo `.lua`:** Los backdoors se insertan frecuentemente al final del archivo, después de muchas líneas en blanco.
- [ ] **Buscar bloques de código claramente diferentes:** Un bloque de código con estilo, indentación o nomenclatura diferente al resto del recurso es altamente sospechoso.
- [ ] **Verificar TODAS las llamadas `PerformHttpRequest`:** Para cada una, documentar:
  - URL de destino (o variable que la contiene)
  - Método HTTP (`GET`, `POST`, etc.)
  - Datos enviados en el body
  - Qué se hace con la respuesta (`load()` = ❌ RECHAZO)
- [ ] **Desobfuscar TODO código ofuscado:** Si existen secuencias hexadecimales, Base64, o `string.char()`:
  1. Copiar la cadena ofuscada a un entorno aislado
  2. Decodificar manualmente o con herramienta
  3. Documentar el resultado en el reporte
  4. Si el código desobfuscado contiene `PerformHttpRequest`, `load`, `os.execute`, u otra función crítica → **RECHAZAR**
- [ ] **Verificar que NO haya código después de `return`:** Un `return` seguido de más código (después de líneas en blanco) puede ocultar un payload que se ejecuta en contextos específicos.
- [ ] **Buscar timers sospechosos:** `SetTimeout`, `Citizen.Wait(math.random(...))`, o timers que ejecutan código después de un delay largo (diseñados para activarse después de que el administrador deje de monitorear).

#### Revisión de Identificadores y Permisos

- [ ] **Buscar TODOS los identificadores hardcodeados** (Steam, Discord, License, IP).
- [ ] **Verificar TODOS los `RegisterCommand`:** Cada comando debe:
  - Estar documentado
  - Tener restricción de permisos (`restricted = true` + ACE correcta)
  - No otorgar dinero, ítems o privilegios sin validación
- [ ] **Verificar TODOS los `RegisterNetEvent` + `AddEventHandler`:** Cada evento debe:
  - Validar el `source` (origen del jugador)
  - Validar tipos de datos de los argumentos
  - Verificar permisos antes de ejecutar la acción
  - No confiar en datos del cliente para decisiones críticas

### 5.3 Guía de Desobfuscación

Cuando se detecte código ofuscado, seguir este proceso:

```
 Código Ofuscado Detectado
          │
          ▼
 ¿Es hexadecimal (\x61\x62...)?
     ├── SÍ → Convertir cada \xHH a carácter ASCII
     │        Ejemplo: \x6c\x6f\x61\x64 = "load"
     │        Herramienta: print() en consola Lua aislada
     │
     ▼
 ¿Es string.char(n, n, n...)?
     ├── SÍ → Convertir cada número a carácter ASCII
     │        Ejemplo: string.char(108,111,97,100) = "load"
     │
     ▼
 ¿Es Base64?
     ├── SÍ → Decodificar con herramienta Base64
     │        Verificar si el resultado contiene código ejecutable
     │
     ▼
 ¿Es ofuscación multicapa?
     ├── SÍ → Repetir el proceso hasta obtener texto legible
     │        Si > 3 capas de ofuscación → RECHAZAR el recurso
     │        (Nivel de ofuscación excesivo indica intención maliciosa)
     │
     ▼
 Documentar el código resultante en el reporte de auditoría
```

> ⚠️ **REGLA DE SEGURIDAD:** NUNCA ejecutar código ofuscado directamente para "ver qué hace". Siempre desobfuscar manualmente o en un entorno completamente aislado sin conexión de red.

---
---

## 📋 6. Auditoría del Manifiesto (`fxmanifest.lua`)

El `fxmanifest.lua` es el punto de entrada de todo recurso. Un manifiesto manipulado puede cargar código malicioso de forma silenciosa.

### 6.1 Checklist Específica del Manifiesto

| # | Verificación | Estado | Notas |
|:---:|:---|:---:|:---|
| F-01 | `fx_version` es `cerulean` o versión actual | `[ ]` | Versiones antiguas pueden tener vulnerabilidades conocidas |
| F-02 | `game 'gta5'` está declarado correctamente | `[ ]` | |
| F-03 | Todos los archivos en `client_scripts` existen en el directorio | `[ ]` | |
| F-04 | Todos los archivos en `server_scripts` existen en el directorio | `[ ]` | |
| F-05 | No hay archivos `.lua` en el directorio que NO estén en el manifiesto | `[ ]` | Archivo presente pero no declarado = sospechoso (puede ser cargado por otro medio) |
| F-06 | No se usan wildcards (`*.lua`, `**/*.lua`) en scripts | `[ ]` | Wildcards permiten que archivos inyectados se carguen automáticamente |
| F-07 | `files` solo contiene assets legítimos (HTML, CSS, imágenes, JSON) | `[ ]` | No `.lua`, `.exe`, `.dll` en files |
| F-08 | `dependencies` solo lista recursos conocidos y verificados | `[ ]` | |
| F-09 | No hay `loadscreen` con HTML sospechoso | `[ ]` | |
| F-10 | No hay entradas de `data_file` apuntando fuera del recurso | `[ ]` | Previene path traversal |
| F-11 | No se declara `this_is_a_map 'yes'` en un recurso que no es mapa | `[ ]` | |
| F-12 | `lua54 'yes'` — Verificar compatibilidad si está declarado | `[ ]` | Algunas funciones cambian entre Lua 5.1 y 5.4 |

### 6.2 Ejemplo de Manifiesto Seguro (Referencia)

```lua
fx_version 'cerulean'
game 'gta5'

description 'Nombre del Recurso - Descripción breve'
author 'Autor Verificado'
version '1.0.0'

-- Declaración EXPLÍCITA de cada archivo (NO wildcards)
shared_scripts {
    '@ox_lib/init.lua',         -- Dependencia conocida y verificada
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/events.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',   -- Dependencia de BD verificada
    'server/main.lua',
    'server/events.lua',
}

-- Solo assets necesarios para NUI
files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

ui_page 'html/index.html'

-- Dependencias explícitas
dependencies {
    'qb-core',
    'oxmysql',
}

-- ✅ BUENAS PRÁCTICAS INCLUIDAS:
-- lua54 'yes'                  -- Solo si el código es compatible
-- Ni wildcards, ni archivos extra, ni URLs remotas
```

---
---

## 🔐 7. Seguridad de Eventos y Lógica del Servidor

La explotación de eventos (`TriggerServerEvent`) es el **segundo vector de ataque más común** después de los backdoors. Un evento mal protegido permite a cualquier jugador con un ejecutor (injector) manipular la economía, duplicar ítems, o escalar privilegios.

### 7.1 Principio Fundamental

> **"Nunca confiar en el cliente."**  
> Todo dato que llega vía `TriggerServerEvent` es potencialmente malicioso. El servidor DEBE validar todo antes de actuar.

### 7.2 Checklist de Seguridad de Eventos

Para CADA `RegisterNetEvent` + `AddEventHandler` en archivos server-side:

- [ ] **¿Se valida el `source`?** — El servidor debe usar `source` (asignado por FiveM) y NUNCA aceptar un `playerId` enviado por el cliente.
- [ ] **¿Se validan los tipos de datos?** — `if type(data) ~= 'table' then return end`
- [ ] **¿Se validan los rangos?** — `if amount <= 0 or amount > MAX_ALLOWED then return end`
- [ ] **¿Se verifican los permisos?** — `if Player.PlayerData.job.name ~= 'police' then return end`
- [ ] **¿Se usa rate-limiting (throttle)?** — Prevenir spam de eventos.
- [ ] **¿La lógica crítica está en el servidor?** — Cálculos de dinero, inventario y permisos NUNCA en el cliente.

### 7.3 Patrones de Código Seguro (Referencia)

#### ✅ Patrón 1: Validación Completa de Entrada

```lua
-- server.lua — PATRÓN SEGURO
RegisterNetEvent('recurso:server:comprarItem', function(data)
    local src = source  -- SIEMPRE usar source del servidor, NUNCA data.playerId

    -- 1. Validar tipo de la estructura
    if type(data) ~= 'table' then
        print('[SECURITY] Tipo de dato inválido de source: ' .. src)
        return
    end

    -- 2. Validar cada campo esperado
    if type(data.itemId) ~= 'string' or type(data.amount) ~= 'number' then
        print('[SECURITY] Campos inválidos de source: ' .. src)
        return
    end

    -- 3. Validar rangos
    if data.amount <= 0 or data.amount > 10 or data.amount ~= math.floor(data.amount) then
        print('[SECURITY] Cantidad fuera de rango de source: ' .. src)
        return
    end

    -- 4. Obtener datos del jugador DESDE EL SERVIDOR
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    -- 5. Verificar que el jugador puede realmente hacer esta acción
    -- (saldo, ubicación, estado, etc.) — Todo server-side
    local price = Config.Items[data.itemId] and Config.Items[data.itemId].price
    if not price then return end

    if Player.Functions.GetMoney('cash') < (price * data.amount) then
        return -- No tiene suficiente dinero (verificado server-side)
    end

    -- 6. Ejecutar la acción
    Player.Functions.RemoveMoney('cash', price * data.amount)
    Player.Functions.AddItem(data.itemId, data.amount)
end)
```

#### ✅ Patrón 2: Rate-Limiting (Anti-Spam)

```lua
-- server.lua — PATRÓN DE RATE-LIMITING
local eventCooldowns = {}

local function isThrottled(playerId, eventName, cooldownSeconds)
    local key = playerId .. ':' .. eventName
    local now = os.time()
    if eventCooldowns[key] and (now - eventCooldowns[key]) < cooldownSeconds then
        print('[SECURITY] Rate-limit: source ' .. playerId .. ' en evento ' .. eventName)
        return true
    end
    eventCooldowns[key] = now
    return false
end

RegisterNetEvent('recurso:server:accionSensible', function()
    local src = source
    if isThrottled(src, 'accionSensible', 3) then return end  -- 3 segundos de cooldown

    -- Proceder con la lógica...
end)

-- Limpieza periódica para evitar memory leak
CreateThread(function()
    while true do
        Wait(300000)  -- Cada 5 minutos
        local now = os.time()
        for key, timestamp in pairs(eventCooldowns) do
            if (now - timestamp) > 60 then
                eventCooldowns[key] = nil
            end
        end
    end
end)
```

#### ❌ Patrón Inseguro (Lo que se debe RECHAZAR)

```lua
-- ❌ INSEGURO — NO ACEPTAR este patrón
RegisterNetEvent('recurso:server:darDinero', function(playerId, amount)
    -- ❌ Usa playerId del cliente (puede ser falsificado)
    -- ❌ No valida tipo ni rango de amount
    -- ❌ No verifica permisos
    -- ❌ No tiene rate-limiting
    local Player = QBCore.Functions.GetPlayer(playerId)
    Player.Functions.AddMoney('cash', amount)
end)
```

---
---

## 💉 8. Prevención de Inyección SQL

### 8.1 Regla Absoluta

> **TODA consulta SQL DEBE usar variables parametrizadas.** La concatenación directa de strings en consultas SQL está **PROHIBIDA** sin excepción.

### 8.2 Ejemplos Comparativos

| | Código | Veredicto |
|:---:|:---|:---:|
| ❌ | `MySQL.query("SELECT * FROM users WHERE name = '" .. name .. "'")` | **VULNERABLE** |
| ❌ | `MySQL.query("DELETE FROM players WHERE id = " .. id)` | **VULNERABLE** |
| ❌ | `MySQL.query(string.format("UPDATE bank SET money = %d WHERE id = '%s'", money, id))` | **VULNERABLE** |
| ✅ | `MySQL.query("SELECT * FROM users WHERE name = ?", {name})` | **SEGURO** |
| ✅ | `MySQL.query("DELETE FROM players WHERE id = ?", {id})` | **SEGURO** |
| ✅ | `MySQL.query("UPDATE bank SET money = ? WHERE id = ?", {money, id})` | **SEGURO** |

### 8.3 Checklist de SQL

- [ ] Buscar TODAS las llamadas a `MySQL.query`, `MySQL.insert`, `MySQL.update`, `MySQL.scalar`, `MySQL.single`, `exports.oxmysql`, `exports['mysql-async']`.
- [ ] Verificar que NINGUNA use concatenación de strings (`..`) para construir la query.
- [ ] Verificar que TODAS usen `?` o `@parametro` para variables.
- [ ] Si el recurso usa `string.format` para queries SQL → **REFACTORIZAR** a parametrizado.
- [ ] Verificar que el usuario de base de datos del servidor tenga **permisos mínimos** (no root, no GRANT, no DROP en producción).

### 8.4 Permiso de Base de Datos Recomendado

```sql
-- Crear usuario dedicado con permisos mínimos para el servidor FiveM
CREATE USER 'fivem_app'@'localhost' IDENTIFIED BY 'contraseña_fuerte_aqui';

-- Solo permisos necesarios, NO dar ALL PRIVILEGES
GRANT SELECT, INSERT, UPDATE, DELETE ON admirales_dev.* TO 'fivem_app'@'localhost';

-- Explícitamente NO otorgar:
-- DROP, ALTER, CREATE, GRANT, EXECUTE, FILE, PROCESS, SUPER
FLUSH PRIVILEGES;
```

---
---

## 🌐 9. Seguridad NUI / Interfaz Web

Los recursos que incluyen interfaz NUI (HTML/CSS/JS) tienen un **surface de ataque adicional** por operar en un entorno de navegador embebido (CEF — Chromium Embedded Framework).

### 9.1 Checklist NUI

- [ ] **No usar `innerHTML` con datos dinámicos.** Reemplazar por `textContent` o `innerText`.
- [ ] **No usar `eval()` ni `new Function()` en JavaScript.** Nunca ejecutar strings como código.
- [ ] **Si usa React:** Verificar que no exista `dangerouslySetInnerHTML` sin sanitización con DOMPurify.
- [ ] **Si usa Vue:** Verificar que no exista `v-html` con datos no sanitizados.
- [ ] **Habilitar NUI Callback Strict Mode** en `fxmanifest.lua` si está soportado — Previene que otros recursos accedan a los callbacks.
- [ ] **Verificar que las respuestas de callbacks NUI no expongan datos sensibles** (tokens, IDs internos, rutas del servidor).
- [ ] **Verificar que los archivos JS no incluyan URLs hardcodeadas** a CDNs o servicios externos desconocidos.
- [ ] **Si se cargan fuentes o librerías externas:** Verificar que sean de fuentes confiables (Google Fonts, cdnjs, unpkg).

### 9.2 Ejemplo de NUI Seguro vs. Inseguro

```javascript
// ❌ INSEGURO — XSS potencial
document.getElementById('player-name').innerHTML = playerName;
// Si playerName = "<img src=x onerror=alert('XSS')>", se ejecuta código.

// ✅ SEGURO
document.getElementById('player-name').textContent = playerName;
// El contenido se trata como texto plano, sin interpretar HTML.
```

---
---

## 🚨 10. Procedimiento de Limpieza Quirúrgica y Respuesta a Incidentes

### 10.1 Protocolo de Limpieza (Si se detecta código malicioso remediable)

```
 AMENAZA DETECTADA
       │
       ▼
 ¿Es código ofuscado que encubre la funcionalidad base del recurso?
       │
   ┌───┴───┐
   │  SÍ   │────▶ RECHAZAR el recurso COMPLETO
   │       │      No se puede garantizar la integridad.
   └───────┘      Buscar alternativa del recurso.
       │
      NO (el código malicioso es un añadido identificable)
       │
       ▼
 PROCEDIMIENTO DE LIMPIEZA:
       │
       ├── 1. NO ejecutar el recurso bajo ninguna circunstancia.
       │
       ├── 2. Crear backup del estado original (evidencia):
       │      git add . && git commit -m "PRE-LIMPIEZA: estado original con malware"
       │
       ├── 3. Eliminar quirúrgicamente las líneas maliciosas.
       │      Documentar cada cambio con comentarios inline:
       │      -- [AUDIT] Líneas XX-YY eliminadas: backdoor PerformHttpRequest
       │
       ├── 4. Verificar integridad post-limpieza:
       │      - ¿El recurso sigue funcionando correctamente?
       │      - ¿No quedaron referencias a las funciones eliminadas?
       │      - ¿No hay timers o threads que re-inyecten el código?
       │
       ├── 5. Commit post-limpieza:
       │      git commit -m "POST-LIMPIEZA: eliminado [descripción del malware]"
       │
       ├── 6. RE-AUDITAR (segunda pasada completa, Niveles 1 y 2)
       │      La limpieza puede haber dejado residuos o activado fallbacks.
       │
       └── 7. Documentar en el reporte de auditoría (Sección 12).
```

### 10.2 Protocolo de Respuesta a Incidentes (Si se ejecutó código malicioso)

Si se descubre que un recurso malicioso **ya fue ejecutado** en algún entorno (incluso el sandbox):

| Paso | Acción | Responsable |
|:---:|:---|:---|
| 1 | **APAGAR** el servidor inmediatamente | Administrador |
| 2 | **Aislar** el entorno: desconectar de red si es posible | Administrador |
| 3 | **Cambiar TODAS las contraseñas**: Base de datos, RCON, panel txAdmin, CFX license, hosting | Equipo de Seguridad |
| 4 | **Verificar integridad** de TODOS los recursos: buscar auto-propagación | Equipo de Seguridad |
| 5 | **Revisar logs**: Servidor, base de datos, acceso al sistema | Equipo de Seguridad |
| 6 | **Restaurar** desde backup limpio conocido (pre-infección) | Administrador |
| 7 | **Escanear** toda la carpeta de recursos con las herramientas del Nivel 1 | Equipo de Seguridad |
| 8 | **Documentar** el incidente completo: vector de entrada, impacto estimado, acciones tomadas | Equipo de Seguridad |
| 9 | **Comunicar** al equipo sobre el incidente y lecciones aprendidas | Todo el equipo |

### 10.3 Criterios de Rechazo Automático

Un recurso se **RECHAZA AUTOMÁTICAMENTE** (sin análisis adicional) si:

| # | Criterio | Motivo |
|:---:|:---|:---|
| R-01 | Contiene archivos `.exe`, `.dll`, `.bat`, `.ps1`, `.sh`, `.cmd`, `.vbs` | Ejecución de código nativo no controlable |
| R-02 | Todo el código server-side está ofuscado sin versión legible disponible | Imposible auditar |
| R-03 | Contiene `os.execute()` o `io.popen()` sin justificación técnica clara | Acceso al sistema operativo |
| R-04 | La desobfuscación revela `load()` ejecutando datos de `PerformHttpRequest` | RAT confirmado |
| R-05 | Contiene más de 3 capas de ofuscación anidada | Intención maliciosa confirmada por complejidad excesiva |
| R-06 | El recurso proviene de una fuente previamente identificada como maliciosa | Historial de compromiso |
| R-07 | El recurso modifica archivos fuera de su propio directorio | Comportamiento de auto-propagación |

---
---

## 📦 11. Traspaso al Equipo de Instalación (Handoff)

Una vez que un recurso ha completado la auditoría y está clasificado como **✅ APROBADO** o **🔧 LIMPIADO Y APROBADO**:

### 11.1 Proceso de Traspaso

```
 RECURSO APROBADO
       │
       ├── 1. Mover a /approved/[categoría]/nombre-recurso/
       │
       ├── 2. Añadir archivo AUDIT_NOTES.md al recurso:
       │      - Fecha de auditoría
       │      - Estado (Aprobado / Limpiado)
       │      - Cambios realizados durante limpieza (si aplica)
       │      - Dependencias requeridas
       │      - Configuraciones necesarias en config.lua
       │      - Notas especiales para el equipo de instalación
       │
       ├── 3. Enriquecer config.lua con comentarios explicativos:
       │      -- Cada variable debe tener un comentario que explique:
       │      -- ¿Qué hace? ¿Cuáles son los valores válidos?
       │      -- ¿Necesita adaptarse al servidor?
       │
       ├── 4. Crear/actualizar entrada en el Audit Log (Sección 12)
       │
       ├── 5. Merge de la rama audit/* a main:
       │      git checkout main
       │      git merge audit/nombre-recurso --no-ff
       │
       └── 6. Notificar al Equipo de Instalación y Debugging:
              - Nombre del recurso
              - Dependencias
              - Instrucciones especiales
              - El equipo toma control para pruebas In-Game
              (físicas, traducciones, posicionamiento, UX)
```

### 11.2 Plantilla de `AUDIT_NOTES.md`

```markdown
# Notas de Auditoría — [nombre-del-recurso]

## Información General
| Campo | Valor |
|:---|:---|
| Fecha de Auditoría | YYYY-MM-DD |
| Analista | [nombre] |
| Estado | ✅ Aprobado / 🔧 Limpiado y Aprobado |
| Versión del Recurso | [versión] |
| Origen | [marketplace/autor/URL] |
| Hash SHA-256 Original | [hash] |

## Dependencias Requeridas
- `qb-core` (v1.x+)
- `oxmysql` (v2.x+)
- [otras dependencias]

## Cambios Realizados Durante Auditoría
- [Descripción de cada cambio, si aplica]
- [Líneas eliminadas, refactorizadas, etc.]

## Configuración Necesaria
- [ ] Editar `config.lua`: [instrucciones específicas]
- [ ] Añadir al `server.cfg`: `ensure nombre-recurso`
- [ ] Ejecutar SQL: `sql/install.sql` en la base de datos

## Notas para el Equipo de Instalación
- [Cualquier información relevante]
- [Advertencias o consideraciones especiales]
```

### 11.3 Responsabilidades Post-Traspaso

| Responsabilidad | Equipo de Seguridad | Equipo de Instalación |
|:---|:---:|:---:|
| Verificar que el código es seguro | ✅ | — |
| Instalar y configurar en el servidor | — | ✅ |
| Depurar errores funcionales (in-game) | — | ✅ |
| Traducciones y localización | — | ✅ |
| Posicionamiento de objetos/NPCs | — | ✅ |
| Reportar comportamiento sospechoso post-deploy | — | ✅ |
| Investigar reportes de comportamiento sospechoso | ✅ | — |
| Aprobar hotfixes que modifiquen código | ✅ | — |

---
---

## 📊 12. Registro de Auditoría (Audit Log)

### 12.1 Registro Maestro de Recursos

Mantener este registro actualizado en el repositorio Git y en el sistema de gestión de proyecto (GitHub Projects / Issues).

| ID | Recurso | Fecha Ingreso | Fecha Auditoría | Analista | Estado | Severidad Máxima | Amenazas Detectadas | Hash SHA-256 |
|:---:|:---|:---:|:---:|:---|:---:|:---:|:---|:---|
| `AUD-001` | *Ejemplo: qb-weathersync* | *14-Abr-2026* | *14-Abr-2026* | *[Analista]* | ✅ Aprobado | 🟢 Ninguna | *Ninguna* | `a1b2c3...` |
| `AUD-002` | *Ejemplo: hud-custom* | *14-Abr-2026* | *14-Abr-2026* | *[Analista]* | 🔧 Limpiado | 🔴 Crítica | *Webhook exfiltración detectado y eliminado* | `d4e5f6...` |
| `AUD-003` | *Ejemplo: vehicle-pack-leaked* | *14-Abr-2026* | *14-Abr-2026* | *[Analista]* | ❌ Rechazado | 🔴 Crítica | *RAT: load() + PerformHttpRequest. Auto-propagación detectada.* | `g7h8i9...` |

### 12.2 Estados Posibles

| Estado | Icono | Significado |
|:---|:---:|:---|
| En Cola | ⏳ | Recurso recibido, pendiente de asignación |
| En Revisión | 🔍 | Auditoría en progreso |
| Aprobado | ✅ | Seguro, listo para instalación |
| Limpiado y Aprobado | 🔧 | Tenía amenazas, fueron removidas y verificadas |
| Rechazado | ❌ | Inseguro, no apto para uso |
| Suspendido | ⚠️ | Requiere información adicional o segunda opinión |

### 12.3 Métricas Clave a Monitorear

| Métrica | Fórmula | Meta |
|:---|:---|:---|
| **Tasa de Rechazo** | Rechazados / Total Analizados × 100 | Informativa (sin meta fija) |
| **Tiempo Medio de Auditoría** | Suma de tiempos / Total Analizados | < 2 horas por recurso simple |
| **Recursos Pendientes** | Total en cola sin asignar | 0 (ideal) |
| **Re-auditorías** | Recursos que requirieron 2ª pasada | < 10% |

---
---

## Apéndice A: Patrones de Búsqueda (Grep/Regex)

### A.1 Comando Maestro de Escaneo Completo

Ejecutar desde la raíz del recurso. Este comando unificado busca TODOS los patrones críticos:

```powershell
# === ESCANEO COMPLETO UNIFICADO ===
# Guardar resultado en archivo de reporte

$recurso = "nombre-del-recurso"
$fecha = Get-Date -Format "yyyy-MM-dd_HH-mm"
$reporte = ".\reports\scan_${recurso}_${fecha}.txt"

# Crear directorio de reportes si no existe
New-Item -ItemType Directory -Force -Path ".\reports" | Out-Null

# Encabezado del reporte
@"
================================================================
REPORTE DE ESCANEO AUTOMATIZADO — Nivel 1
================================================================
Recurso:    $recurso
Fecha:      $fecha
Analista:   [COMPLETAR]
================================================================

"@ | Out-File -FilePath $reporte -Encoding UTF8

# Escaneo CRÍTICO
"=== CATEGORÍA CRÍTICA ===" | Out-File -Append $reporte
"--- PerformHttpRequest ---" | Out-File -Append $reporte
rg -n -i "PerformHttpRequest" --type lua --type js 2>&1 | Out-File -Append $reporte

"--- load/loadstring/assert(load) ---" | Out-File -Append $reporte
rg -n "load\(|loadstring\(|assert\(load" --type lua 2>&1 | Out-File -Append $reporte

"--- RunString ---" | Out-File -Append $reporte
rg -n -i "RunString" --type lua --type js 2>&1 | Out-File -Append $reporte

"--- Hexadecimales ---" | Out-File -Append $reporte
rg -n "\\\\x[0-9a-fA-F]{2}" --type lua 2>&1 | Out-File -Append $reporte

"--- string.char ---" | Out-File -Append $reporte
rg -n "string\.char\(" --type lua 2>&1 | Out-File -Append $reporte

"--- os.execute / io.popen / io.open ---" | Out-File -Append $reporte
rg -n "os\.execute\(|io\.popen\(|io\.open\(" --type lua 2>&1 | Out-File -Append $reporte

"--- debug ---" | Out-File -Append $reporte
rg -n "debug\." --type lua 2>&1 | Out-File -Append $reporte

# Escaneo ALTO
"`n=== CATEGORÍA ALTA ===" | Out-File -Append $reporte
"--- Identificadores hardcodeados ---" | Out-File -Append $reporte
rg -n "steam:|discord:|license:|ip:" --type lua 2>&1 | Out-File -Append $reporte

"--- RegisterCommand / RegisterNetEvent ---" | Out-File -Append $reporte
rg -n "RegisterCommand|RegisterNetEvent" --type lua 2>&1 | Out-File -Append $reporte

"--- ExecuteCommand ---" | Out-File -Append $reporte
rg -n "ExecuteCommand" --type lua 2>&1 | Out-File -Append $reporte

"--- GetConvar ---" | Out-File -Append $reporte
rg -n "GetConvar" --type lua 2>&1 | Out-File -Append $reporte

# Escaneo MEDIO
"`n=== CATEGORÍA MEDIA ===" | Out-File -Append $reporte
"--- SQL por concatenación ---" | Out-File -Append $reporte
rg -n -i "\.\.\s*[`"'].*SELECT|INSERT|UPDATE|DELETE" --type lua 2>&1 | Out-File -Append $reporte

"--- innerHTML / eval ---" | Out-File -Append $reporte
rg -n "innerHTML|eval\(" --type js --type html 2>&1 | Out-File -Append $reporte

# Archivos sospechosos
"`n=== ARCHIVOS SOSPECHOSOS ===" | Out-File -Append $reporte
Get-ChildItem -Recurse -Include *.exe,*.dll,*.bat,*.ps1,*.sh,*.cmd,*.vbs 2>&1 | Out-File -Append $reporte

Write-Host "Reporte generado: $reporte"
```

### A.2 Tabla Rápida de Patrones

| Patrón (Regex) | Busca | Archivo | Sev. |
|:---|:---|:---|:---:|
| `PerformHttpRequest` | Comunicación HTTP | `.lua`, `.js` | 🔴 |
| `load\(\|loadstring\(` | Ejecución dinámica | `.lua` | 🔴 |
| `assert\(load` | Ofuscación clásica | `.lua` | 🔴 |
| `RunString` | Ejecución de string como código | `.lua` | 🔴 |
| `\\x[0-9a-fA-F]{2}` | Hex ofuscación | `.lua` | 🔴 |
| `string\.char\(` | Construcción dinámica | `.lua` | 🔴 |
| `os\.execute\|io\.popen\|io\.open` | Acceso al SO | `.lua` | 🔴 |
| `debug\.` | Introspección Lua | `.lua` | 🟠 |
| `steam:\|discord:\|license:` | IDs hardcodeados | `.lua` | 🟠 |
| `ExecuteCommand` | Ejecución de comandos server | `.lua` | 🟠 |
| `GetConvar` | Lectura de config | `.lua` | 🟠 |
| `innerHTML\|eval\(` | XSS / ejecución JS | `.js`, `.html` | 🟡 |
| `\.\..*SELECT\|INSERT\|UPDATE` | SQL injection | `.lua` | 🟡 |

---

## Apéndice B: Clasificación de Severidad

| Nivel | Icono | Nombre | Descripción | Acción Requerida |
|:---:|:---:|:---|:---|:---|
| S0 | 🔴 | **Crítica** | Compromiso total del servidor. RAT, exfiltración, auto-propagación. | **RECHAZO INMEDIATO** o limpieza quirúrgica obligatoria + re-auditoría completa. |
| S1 | 🟠 | **Alta** | Backdoor de privilegios, inyección SQL, eventos sin validación. | **Limpieza obligatoria** antes de aprobación. No se despliega sin remediar. |
| S2 | 🟡 | **Media** | XSS en NUI, memory leaks, malas prácticas de código. | **Remediación recomendada** pero no bloquea aprobación si el riesgo se documenta. |
| S3 | 🟢 | **Baja / Informativa** | Mejoras de rendimiento, mejores prácticas, optimizaciones sugeridas. | **Opcional.** Se documenta como recomendación para el equipo de instalación. |

---

## Apéndice C: Glosario de Términos

| Término | Definición |
|:---|:---|
| **RAT** | Remote Access Trojan — Troyano que permite control remoto del servidor. |
| **Exfiltración** | Extracción no autorizada de datos sensibles hacia un servidor externo. |
| **Auto-propagación** | Malware que se copia e inyecta en otros recursos limpios del servidor. |
| **Ofuscación** | Técnica para hacer el código ilegible y dificultar su análisis. |
| **Desobfuscación** | Proceso inverso de revertir la ofuscación a código legible. |
| **NUI** | New UI — Sistema de interfaz web embebida en FiveM (basado en CEF/Chromium). |
| **XSS** | Cross-Site Scripting — Inyección de código JavaScript malicioso en interfaces web. |
| **SQL Injection** | Inserción de código SQL malicioso a través de entradas no sanitizadas. |
| **Event Injection** | Explotación de eventos del servidor enviando datos manipulados desde el cliente. |
| **ACE/ACL** | Access Control Entry/List — Sistema de permisos de FiveM. |
| **Sandbox** | Entorno aislado para pruebas seguras sin riesgo al servidor de producción. |
| **Rate-Limiting** | Limitación de la frecuencia con la que se puede disparar una acción. |
| **Payload** | Carga útil maliciosa — El código que ejecuta la acción del atacante. |
| **Ejecutor / Injector** | Herramienta de trampas que permite a jugadores ejecutar código Lua en el cliente. |
| **CEF** | Chromium Embedded Framework — Motor de navegador usado por FiveM para NUI. |
| **Wildcard** | Patrones como `*.lua` que coinciden con múltiples archivos. |
| **Hash SHA-256** | Huella digital criptográfica de un archivo para verificar su integridad. |

---
---

> **Documento del Proyecto Admirales — Fase 0**  
> **Clasificación:** Documento Interno — Equipo de Seguridad  
> **Versión:** 2.0.0 — Revisión profesional completa  
>  
> *La seguridad no es un destino, es un viaje continuo.*  
> *Cada recurso no auditado es una puerta abierta al atacante.*
