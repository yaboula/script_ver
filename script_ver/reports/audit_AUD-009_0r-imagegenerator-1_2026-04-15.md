# Reporte de Auditoría de Seguridad — AUD-009

## `0r-imagegenerator 1`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-009` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `0r-imagegenerator 1` |
| **Origen** | Lote `incoming/[Clothing]` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ❌ **RECHAZADO (R-02)** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-009_0r-imagegenerator-1_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- `PerformHttpRequest`, `load`, `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos críticos directos**.
- NUI detectó dependencia externa: `https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js` (además de `nui://game/ui/jquery.js`).
- `fxmanifest.lua` usa wildcards en scripts (`client/*.lua`, `server/*.lua`).

---

## Nivel 2 — Revisión manual y bloqueo de auditoría

Se intentó inspección manual de archivos críticos server/client/shared:

- `server/main.lua`
- `server/core.lua`
- `client/main.lua`
- `client/core.lua`
- `shared/config_sv.lua`

Todos se encuentran en formato **binario** (encabezado `FXAP` + bytes nulos), no legibles como texto fuente Lua para análisis estático/manual de seguridad.

Evidencia técnica (muestra):

- `server/main.lua` → `Head=46 58 41 50 01 00 ...`, `HasNUL=True`
- `server/core.lua` → `Head=46 58 41 50 01 00 ...`, `HasNUL=True`
- `client/main.lua` → `Head=46 58 41 50 01 00 ...`, `HasNUL=True`
- `client/core.lua` → `Head=46 58 41 50 01 00 ...`, `HasNUL=True`
- `shared/config_sv.lua` → `Head=46 58 41 50 01 00 ...`, `HasNUL=True`

---

## Regla aplicada

- **R-02 (Rechazo automático):** recurso con código ofuscado/compilado en componentes críticos (especialmente server-side) sin versión fuente auditable.

---

## Decisión final

**❌ RECHAZADO (R-02)**

El recurso no puede aprobarse mientras no se entregue versión auditable (fuente Lua legible) de los módulos críticos.
