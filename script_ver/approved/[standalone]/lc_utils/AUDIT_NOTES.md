# Notas de Auditoría — lc_utils

> Copiar esta plantilla y completar para cada recurso auditado.

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-009` |
| **Fecha de Auditoría** | 2026-04-20 |
| **Analista** | GitHub Copilot |
| **Estado** | 🔧 Limpiado |
| **Versión del Recurso** | Desconocida |
| **Origen** | zip/[housing] |
| **Hash SHA-256 Original** | Referenciado en `audit_AUD-009_lc_utils_2026-04-20_hashes.tsv` |
| **Severidad Máxima Detectada** | 🔴 Crítica (Inicial) -> 🟡 Media (Tras Análisis y Limpieza) |

---

## Resumen del Escaneo Automatizado (Nivel 1)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos | 1 |
| 🟠 Altos | 2 |
| 🟡 Medios | 2 |
| Archivos Binarios | 0 |

---

## Hallazgos Detallados

### Amenazas Detectadas y Vulnerabilidades

| # | Patrón | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | F-06 | `fxmanifest.lua` | N/A | Uso de múltiples wildcards (`*`) en la declaración de recursos compartidos, clientes, servidores y NUI. Riesgo de inyección silenciosa. | **FIX-05 APLICADO**: Se han purgado todos los wildcards y declarado de forma explícita todos los 42 archivos en el manifiesto. |
| 2 | C-02 | `database.lua` | L38, L44 | SQL Injection potencial (uso de tabla y columnas por concatenación). | **DOCUMENTADO Y DESCARTADO (Falso Positivo Explotable)**: Al analizar profundamente la lógica de invocación desde el servidor (`validateOwnedVehicleTableColumns`), las tablas que recibe son variables hardcodeadas a nivel script (nunca entradas pasadas por el cliente o `source`). Por lo tanto, no es explotable remotamente, aunque rompe best-practices. |
| 3 | C-08 | `loader.lua` | L19 | Función dinámica `load()` ejecutando `LoadResourceFile()`. | **DOCUMENTADO**: Solo lee scripts internos explicitamente del mismo resource en base al config framework. Limpio; no hay inyección del usuario. |
| 4 | C-03 | `webhook.lua` | L5 | Disparo a webhook HTTP mediante `PerformHttpRequest`. | **DOCUMENTADO**: Se invoca sólo internamente y la validación proviene del `config.lua`. |

---

## Dependencias Requeridas

| Recurso | Versión Mínima | Verificado |
|:---|:---|:---:|
| `qb-core` | latest | [X] |
| `mysql-async` / `oxmysql` | latest | [X] |

---

## Cambios Realizados Durante Auditoría

- [X] El `fxmanifest.lua` original se reescribió por completo para eliminar todo rastro de declaraciones incompletas o comodines (`*`). Todos los archivos HTML, CSS y JS se declararon literalmente.

---

## Configuración Necesaria para Instalación

- [ ] Editar `config.lua`: Configurar la variable `Config.Framework = 'qbcore'` (o la correspondiente al servidor por defecto de Admirales).
- [ ] Configurar locales/idiomas y webhooks para logs de utilidad general.
- [ ] Añadir al `server.cfg`: `ensure lc_utils` asegurando que preceda a cualquiera que dependa de él (`lc_gas_stations` / `lc_stores`).

---

## Notas para el Equipo de Instalación

- Este script ejerce como LIBRERÍA BASE para el resto de scripts del ecosistema `lc_` (LixeiroCharmoso).
- Al no requerir SQL base para él mismo (se instalan en los scripts hijos), asegúrense únicamente de que su orden sea el correcto en el manifiesto (Justo después de los Core principales, y antes de los resources particulares de este autor).
- El `loader.lua` se ocupará internamente de levantar `frameworks/qbcore/client.lua` y `server.lua` por lo cual aseguren estar limpios.

---

> **Firma del Analista:** GitHub Copilot  
> **Fecha de Cierre:** 2026-04-20