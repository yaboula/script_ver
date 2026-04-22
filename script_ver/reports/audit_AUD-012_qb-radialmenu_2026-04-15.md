# Reporte de Auditoría de Seguridad — AUD-012

## `qb-radialmenu`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-012` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `qb-radialmenu` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-012_qb-radialmenu_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos ejecutables (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- `PerformHttpRequest`, `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos críticos**.
- Se detectó fuente externa en NUI (`fonts.googleapis.com`) de bajo riesgo operativo.
- Revisión manual enfocada en eventos server activos de `sv_main.lua`.

---

## Nivel 2 — Hallazgos y remediaciones aplicadas

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🟠 | `qb-trunk:server:setTrunkBusy` aceptaba `plate` y `busy` sin validar | Se agregó validación de `plate` (`string`, largo) y `busy` boolean |
| H-02 | 🟠 | Callback `qb-trunk:server:getTrunkBusy` llamaba `cb(true)` y luego `cb(false)` (estado inconsistente) | Se corrigió a retorno único `cb(trunkBusy[plate] == true)` |
| H-03 | 🔴 | `qb-trunk:server:KidnapTrunk` permitía redirección de target sin validación robusta | Se agregaron checks de `targetId`, self-target, existencia de peds y distancia <= 5.0 |
| H-04 | 🟡 | Evento server `AnimSet:Brave` ejecutaba nativas client-side en server (comportamiento inválido) | Se removió del servidor activo para evitar abuso/errores |
| H-05 | 🟡 | Logs debug en `client_menu.lua` | Removidos prints en evento `expressions` |

---

## Archivos modificados

- `quarantine/under-review/qb-radialmenu/sv_main.lua`
  - Validación de inputs + hardening de eventos server y callback trunk.
- `quarantine/under-review/qb-radialmenu/client_menu.lua`
  - Limpieza de prints debug.

---

## Validación post-cambios

- Revisión de errores de editor en archivos modificados: **sin errores**.
- Reescaneo rápido de patrones críticos: **sin hallazgos críticos**.

---

## Dependencias operativas

- `qb-core`
- `qb-polyzone`
- `qb-garages`

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Remediaciones acotadas al servidor activo (`sv_main.lua`) para mantener funcionalidad del menú radial y reducir superficie de abuso en eventos.
