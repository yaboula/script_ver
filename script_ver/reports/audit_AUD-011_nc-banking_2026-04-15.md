# Reporte de Auditoría de Seguridad — AUD-011

## `nc-banking`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-011` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `nc-banking` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-011_nc-banking_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos ejecutables (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- `PerformHttpRequest`, `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos críticos**.
- NUI con Font Awesome desde CDN confiable (`cdnjs.cloudflare.com`).
- Se detectó alta superficie server-side en operaciones económicas; se ejecutó revisión manual profunda.

---

## Nivel 2 — Hallazgos y remediaciones aplicadas

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🔴 | `IsPlayerOnCooldown` devolvía siempre `false` (anti-spam inactivo) | Se implementó cooldown real por `playerId:operation` usando `GetGameTimer()` |
| H-02 | 🔴 | `IsPlayerNearABank` devolvía `true` por defecto (bypass total de proximidad) | Se restauró validación real por coordenadas de banco + estado ATM reportado por cliente |
| H-03 | 🟠 | Evento `ATMCheckResult` no persistía estado | Ahora sincroniza `playerNearATM[source]`; se limpia en `playerDropped` |
| H-04 | 🟠 | Eventos monetarios aceptaban `amount <= 0` o tipos no normalizados en varios flujos | Se añadió saneo con `tonumber` y límites (`> 0`) en depósitos/retiros/transferencias/shared ops |
| H-05 | 🟠 | Fees (`requestPhysicalCard`, `requestReplacementCard`, `changeCardPin`) confiaban en payload cliente sin normalizar | Se validó `fee = tonumber(fee) or 0` y bloqueo de valores negativos |
| H-06 | 🟡 | Logs debug exponían datos sensibles de PIN/hash y ruido de depuración en flujo ATM | Eliminados prints sensibles en server/client (`HashPin`, `VerifyCardPin`, callbacks ATM) |

---

## Archivos modificados

- `quarantine/under-review/nc-banking/server/main.lua`
  - Rehabilitación de controles `IsPlayerOnCooldown` y `IsPlayerNearABank`.
  - Gestión de `ATMCheckResult` + limpieza por desconexión.
  - Eliminación de logging sensible de PIN/hash.
- `quarantine/under-review/nc-banking/server/events.lua`
  - Validaciones de montos/fees/targets en eventos económicos críticos.
  - Eliminación de prints de debugging en verificación ATM PIN.
- `quarantine/under-review/nc-banking/client/main.lua`
  - Eliminación de prints debug en flujo ATM/PIN.

---

## Validación post-cambios

- Revisión de errores de editor en archivos modificados: **sin errores**.
- Reescaneo rápido de patrones críticos de ejecución remota: **sin hallazgos críticos**.

---

## Dependencias operativas

- `qb-core`
- `oxmysql`

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Se corrigieron bypasses de seguridad que afectaban operaciones económicas sin alterar el flujo funcional principal de banca/NUI.
