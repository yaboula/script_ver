# Reporte de Auditoría de Seguridad — AUD-013

## `qb-core`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-013` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `qb-core` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-013_qb-core_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos ejecutables (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- `PerformHttpRequest`, `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos críticos**.
- Superficie crítica principal detectada en eventos server de `server/events.lua` y funciones base de `server/functions.lua`.

---

## Nivel 2 — Hallazgos y remediaciones aplicadas

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🔴 | `QBCore:Server:SetMetaData` permitía mutar metadata arbitraria desde cliente | Se restringió a `hunger`, `thirst`, `stress` + coerción numérica y clamp 0..100 |
| H-02 | 🟠 | `QBCore:Server:UseItem` aceptaba payload item sin shape-check robusto | Se validó tipo tabla, `name` string y `amount > 0` |
| H-03 | 🟠 | `QBCore:Server:RemoveItem` sin validación de `Player` y parámetros de entrada | Se añadieron guardas de `Player`, `itemName` string y `amount` numérico positivo |
| H-04 | 🟠 | Doble handler de `QBCore:UpdatePlayer` (doble degradación hambre/sed + doble save) | Se eliminó el handler duplicado y se dejó el flujo con `playtime` |
| H-05 | 🟡 | `PaycheckLoop` iteraba `QBCore.Players` con `#` (tabla no secuencial) | Se corrigió a `pairs(Players)` |
| H-06 | 🟡 | `ToggleOptin` usaba variable `Player` no definida (riesgo runtime error) | Se inicializa `Player` y se validan permisos/registro antes de mutar |
| H-07 | 🟡 | `IsPlayerBanned` referenciaba `result.expire` (índice erróneo) | Se corrigió a `result[1].expire` |
| H-08 | 🟡 | `removepermission` tenía variable `permission` no definida en log | Se reemplazó por mensaje estático seguro |
| H-09 | 🟡 | `clearinv` usaba fallback con `src` no inicializado | Se inicializó `src = source` antes del fallback |
| H-10 | 🟢 | `GetPlayerByPhone` incluía variable local huérfana (`cid`) | Limpieza de código muerto |

---

## Archivos modificados

- `quarantine/under-review/qb-core/server/events.lua`
  - Hardening de `SetMetaData`, `UseItem`, `RemoveItem` y eliminación de handler duplicado de update.
- `quarantine/under-review/qb-core/server/functions.lua`
  - Correcciones de estabilidad en bucles y utilidades core.
- `quarantine/under-review/qb-core/server/commands.lua`
  - Correcciones de runtime en comandos administrativos.

---

## Validación post-cambios

- Revisión de errores de editor en archivos modificados: **sin errores**.
- Integridad sintáctica validada sobre archivos críticos modificados.

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Se aplicaron cambios mínimos y de alto impacto para proteger el núcleo del framework, priorizando compatibilidad y estabilidad operativa.
