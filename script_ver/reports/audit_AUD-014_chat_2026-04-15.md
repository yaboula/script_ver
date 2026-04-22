# Reporte de Auditoría de Seguridad — AUD-014

## `chat`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-014` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `chat` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-014_chat_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos ejecutables (R-01): **0**
- Scripts críticos ofuscados/no auditables (R-02): **0**

---

## Nivel 1 — Escaneo automatizado

- `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos**.
- `PerformHttpRequest`: eliminado de rutas críticas (antes se usaba webhook externo y API Discord con credenciales embebidas).
- Eventos server expuestos revisados: `chat:server:*`, `911*`, `001*`, `311*`, `chatt:*`.

---

## Nivel 2 — Hallazgos y remediaciones aplicadas

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🔴 | Webhook de Discord hardcodeado en `server/main.lua` (exfiltración de chat) | Eliminado; se mantiene logging interno por evento (`tg-logs`) |
| H-02 | 🔴 | Token de bot Discord embebido en `server/utils.lua` (secreto comprometido) | Eliminada integración externa y reemplazada por nombre local seguro |
| H-03 | 🔴 | Eventos `911/001/311` confiaban en `source/target` enviados por cliente (suplantación) | Se fuerza `src = source` del servidor, validación de target y sanitización de mensaje |
| H-04 | 🔴 | `chat:server:ServerPSA` sin autorización (broadcast global por cualquier cliente) | Añadido control de permiso admin server-side |
| H-05 | 🟠 | Eventos de staff chat permitían spoof de `name` y mensajes no validados | Nombre derivado del servidor + validación/trim/limit de mensaje + gate de permisos |
| H-06 | 🟡 | `fxmanifest.lua` corrupto con múltiples bloques `server_scripts` concatenados | Limpieza del manifiesto para evitar comportamiento indefinido |

---

## Archivos modificados

- `quarantine/under-review/chat/server/main.lua`
  - Hardening de eventos de emergencia y PSA, eliminación de webhook y normalización de identidad server-side.
- `quarantine/under-review/chat/server/utils.lua`
  - Eliminación de token/llamada Discord API; reemplazo por flujo local sin secretos.
- `quarantine/under-review/chat/server/commands.lua`
  - Hardening de eventos admin chat (permisos + anti-spoof + sanitización).
- `quarantine/under-review/chat/fxmanifest.lua`
  - Limpieza de declaraciones duplicadas/corruptas.

---

## Validación post-cambios

- Revisión de errores de editor en archivos modificados: **sin errores**.
- Re-escaneo de patrones críticos: **sin hallazgos de secretos remotos ni ejecución peligrosa**.
- Comportamiento funcional preservado para chat básico, anuncios y staff chat con validación server-side.

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Se removieron vectores críticos (secreto embebido, exfiltración y suplantación de eventos) con cambios mínimos orientados a mantener la operativa habitual del recurso.
