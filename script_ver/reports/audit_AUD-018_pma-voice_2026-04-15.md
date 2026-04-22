# Reporte de Auditoría de Seguridad — AUD-018

## `pma-voice`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-018` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `pma-voice` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **AUDITADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-018_pma-voice_2026-04-15_hashes.tsv`
- Binarios ejecutables críticos (R-01): **0**
- Scripts críticos no auditables (R-02): **0**

---

## Nivel 1 — Escaneo automatizado

- `loadstring`, `load(...)`, `os.execute`, `io.popen`, `io.open`, `PerformHttpRequest`: **sin hallazgos**.
- Superficie principal: eventos de sincronización de radio/llamada (`pma-voice:setPlayerRadio`, `pma-voice:setPlayerCall`, `setTalkingOn*`).

---

## Nivel 2 — Revisión manual

| ID | Sev. | Observación | Resultado |
|:---:|:---:|:---|:---|
| A-01 | 🟢 | Conversión y validación básica de tipo en `setPlayerRadio` y `setPlayerCall` (`tonumber` + guards) | Adecuado para el modelo del recurso |
| A-02 | 🟢 | Limpieza de estado en `playerDropped` y sincronización de membresías en canales | Consistente |
| A-03 | 🟢 | Sin endpoints remotos ni ejecución de comandos/shell | Riesgo bajo |
| A-04 | 🟢 | Recurso de infraestructura VOIP; controles de autorización por canal se delegan mediante `addChannelCheck` export | Diseño esperado |

---

## Archivos revisados clave

- `quarantine/under-review/pma-voice/fxmanifest.lua`
- `quarantine/under-review/pma-voice/server/main.lua`
- `quarantine/under-review/pma-voice/server/module/radio.lua`
- `quarantine/under-review/pma-voice/server/module/phone.lua`
- `quarantine/under-review/pma-voice/shared.lua`

---

## Cambios aplicados

- **Sin cambios de código** (no se detectaron vulnerabilidades críticas dentro del alcance auditado).

---

## Validación post-revisión

- Revisión de errores de editor sobre archivos críticos revisados: **sin errores**.
- Integridad estructural del recurso: **correcta**.

---

## Decisión final

**✅ AUDITADO Y APROBADO**

`pma-voice` se considera seguro en este contexto de integración, con superficie coherente para su rol base de VOIP y sin patrones críticos explotables detectados.
