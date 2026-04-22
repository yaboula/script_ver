# Reporte de Auditoría de Seguridad — AUD-010

## `qb-inventory`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-010` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `qb-inventory` |
| **Origen** | Lote `03_ECONOMY_COMMUNICATION` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-010_qb-inventory_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos ejecutables (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- `PerformHttpRequest`, `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos críticos**.
- Se detectó NUI con CDNs externos (Bootstrap, Vue/Quasar, jQuery UI, Google Fonts), usados para UI; no se detectó carga dinámica remota de código Lua.
- Se detectaron múltiples eventos server-side de alto impacto económico (inventario, crafting, stash/trunk sync), por lo que pasó a revisión manual profunda.

---

## Nivel 2 — Hallazgos y remediaciones aplicadas

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🔴 | `qb-inventory:server:SetStashItems` permitía sobrescribir stash desde cliente sin validar sesión abierta del stash | Se agregó validación de `stashId`, tipo de `items` y control `Stashes[stashId].isOpen == source` |
| H-02 | 🔴 | `qb-inventory:server:SaveStashItems` escribía stash por evento con parámetros cliente sin ownership check | Se agregó gate idéntico de ownership por `source` + shape checks |
| H-03 | 🟠 | `inventory:server:addTrunkItems` aceptaba escritura directa de `Trunks[plate].items` sin validación contextual | Se agregaron checks de `plate`, `items` y sesión abierta del trunk por jugador |
| H-04 | 🔴 | `inventory:server:CraftItems` confiaba en `itemCosts/points/amount` enviados por cliente (riesgo free craft / craft manipulation) | Se validó `amount`, `slot`, item destino, receta canónica desde `Config.CraftingItems`, costos exactos y existencia real de materiales antes de consumir |
| H-05 | 🔴 | `inventory:server:CraftAttachment` con misma superficie de abuso que crafting normal | Se aplicó la misma verificación estricta contra `Config.AttachmentCrafting.items` |
| H-06 | 🟡 | `print()` debug en callback NUI `RemoveAttachment` | Removido de `client/main.lua` |

---

## Archivos modificados

- `quarantine/under-review/qb-inventory/server/main.lua`
  - Hardening de eventos `SetStashItems`, `SaveStashItems`, `addTrunkItems`, `CraftItems`, `CraftAttachment`.
- `quarantine/under-review/qb-inventory/client/main.lua`
  - Eliminación de salida debug en `RemoveAttachment`.

---

## Validación post-cambios

- Revisión de errores de editor en archivos modificados: **sin errores**.
- Reescaneo rápido de patrones críticos de ejecución remota: **sin hallazgos críticos**.

---

## Dependencias operativas

- `qb-core`
- `oxmysql`
- `@qb-weapons/config.lua`
- UI: dependencias CDN (Bootstrap/Vue/Quasar/jQuery UI/Fonts)

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Se aplicaron controles server-side sobre rutas críticas de sincronización y crafting sin alterar la lógica funcional principal del inventario.
