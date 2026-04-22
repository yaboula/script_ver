# Reporte de Auditoría de Seguridad — AUD-016

## `mm_radio`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-016` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `mm_radio` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-016_mm_radio_2026-04-15_hashes.tsv`
- Binarios ejecutables críticos (R-01): **0**
- Código ofuscado/no auditable crítico (R-02): **0**

---

## Nivel 1 — Escaneo automatizado

- `loadstring`, `os.execute`, `io.popen`, `io.open`, `PerformHttpRequest`: **sin hallazgos críticos** en la lógica principal.
- Superficie crítica detectada en eventos server de jammer/canales/batería (entrada cliente no validada originalmente).

---

## Nivel 2 — Hallazgos y remediaciones aplicadas

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🔴 | Eventos de jammer (`spawn/toggle/remove/change/add/remove allowed`) aceptaban parámetros cliente sin validación/permiso | Se añadieron validaciones server-side: tipos/rangos, permiso, proximidad, ownership y sanitización de canales |
| H-02 | 🔴 | `addToRadioChannel` permitía spoof de nombre y canal fuera de controles server-side | Canal validado en servidor + control de acceso a canales restringidos + nombre derivado del servidor |
| H-03 | 🟠 | `consumeBattery` aceptaba IDs arbitrarios enviados por cliente | Se limita a `radioId` realmente poseídos por el jugador |
| H-04 | 🟠 | `rechargeBattery` no verificaba explícitamente disponibilidad de `radiocell` antes de recarga | Se agregó verificación de item antes de aplicar carga |
| H-05 | 🟡 | `getradiodata` retornaba `id` no inicializado de forma explícita | Se inicializó `id` para retorno consistente |

---

## Archivos modificados

- `quarantine/under-review/mm_radio/server/main.lua`
  - Hardening integral de eventos server y validaciones de seguridad en superficie de red.

---

## Validación post-cambios

- Revisión de errores de editor en archivo modificado: **sin errores**.
- Smoke de integridad lógica (flujo esperado):
  - conexión/desconexión de radio preservada,
  - configuración de jammer preservada para operadores con permiso,
  - inicialización de jammers por defecto preservada.

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Se aplicaron cambios mínimos y focalizados para cerrar vectores de abuso cliente→servidor manteniendo funcionalidad operativa del recurso.
