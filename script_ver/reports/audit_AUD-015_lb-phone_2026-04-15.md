# Reporte de Auditoría de Seguridad — AUD-015

## `lb-phone`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-015` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `lb-phone` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ❌ **RECHAZADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-015_lb-phone_2026-04-15_hashes.tsv`
- Revisión de manifiesto y superficie server/client completada.

---

## Nivel 1 — Escaneo automatizado

Hallazgos relevantes:

- Carga dinámica de código mediante `load(...)` en rutas activas:
  - `client/custom/frameworks/vrp2.lua` → `load(utils)()` sobre `vrp/lib/utils.lua`
  - `server/custom/frameworks/vrp2.lua` → `load(utils)()` sobre `vrp/lib/utils.lua`
  - `server/custom/functions/logs.lua` → `load(oxInit)()` sobre `ox_lib/init.lua`
- Uso extensivo de `PerformHttpRequest` para múltiples endpoints externos.
- Archivo de claves con valores sensibles preestablecidos:
  - `server/apiKeys.lua` (`API_KEYS.Video/Image/Audio` con token no vacío).

---

## Nivel 2 — Motivos de rechazo

| ID | Sev. | Motivo | Evidencia |
|:---:|:---:|:---|:---|
| R-02 | 🔴 | Superficie crítica no completamente auditable por carga dinámica de código externo en runtime | `load(utils)()` y `load(oxInit)()` en archivos server/client críticos |
| R-06 | 🔴 | Exposición de credenciales/API keys embebidas en paquete distribuido | `server/apiKeys.lua` contiene API keys no vacías |

---

## Evaluación

Aunque parte del recurso es legible, la ejecución de código cargado dinámicamente desde otros recursos impide cerrar una auditoría determinista del comportamiento final en runtime dentro del alcance del paquete actual. Combinado con credenciales embebidas, el riesgo operacional supera el umbral de aprobación del protocolo.

---

## Decisión final

**❌ RECHAZADO**

Se recomienda solicitar una versión:

1. Sin `load(...)` dinámico en rutas críticas (o con código fuente auditado incluido), y
2. Sin credenciales predefinidas en `server/apiKeys.lua` (deben ser inyectadas por entorno/operador).
