# Reporte de Auditoría de Seguridad — AUD-007

## `0r-imagegenerator-map`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-007` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `0r-imagegenerator-map` |
| **Origen** | Lote `incoming/[Clothing]` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-007_0r-imagegenerator-map_2026-04-15_hashes.tsv`
- Archivos detectados: `fxmanifest.lua`, `Readme.md`, assets `stream/*` (`.ydr`, `.ymap`, `.ymf`, `.ytyp`)
- Archivos binarios peligrosos ejecutables (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- No contiene scripts server/client Lua ejecutables (solo manifiesto + mapa).
- No se detectan patrones críticos (`loadstring`, `os.execute`, `io.popen`, `PerformHttpRequest`).
- No se detectan llamadas NUI ni JS remoto.

---

## Nivel 2 — Revisión manual

- `fxmanifest.lua`:
  - `this_is_a_map 'yes'`
  - `data_file 'DLC_ITYP_REQUEST' 'stream/qua_greenscreen_sphere.ytyp'`
  - `dependency '/assetpacks'`
- `Readme.md`: contiene texto repetitivo de leak/proveniencia no oficial. **No impacta ejecución**, pero se registra como observación de higiene/procedencia.

---

## Hallazgos

| ID | Sev. | Hallazgo | Estado |
|:---:|:---:|:---|:---|
| H-01 | 🟢 | Recurso de mapa estático sin lógica server/client ejecutable | Aceptado |
| H-02 | 🟡 | `Readme.md` con marca de leak/proveniencia no oficial | Documentado (sin impacto técnico directo) |

---

## Dependencias operativas

- `/assetpacks`

---

## Decisión final

**✅ LIMPIO Y APROBADO**

Recurso de tipo mapa estático, sin superficie de ataque de scripts en tiempo de ejecución dentro del paquete auditado.
