# Reporte de Auditoría de Seguridad — AUD-008

## `0r-outfitsaver`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-008` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `0r-outfitsaver` |
| **Origen** | Lote `incoming/[Clothing]` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-008_0r-outfitsaver_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- `PerformHttpRequest`, `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos críticos**.
- SQL detectado con placeholders parametrizados.
- NUI con dependencia externa de Font Awesome en host no confiable (remediado).

---

## Nivel 2 — Hallazgos y remediaciones aplicadas

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🟠 | IDOR en callback `getSavedOutfitSkinById`: consultaba por `id` sin validar ownership | Query reforzada con `id + identifier` server-side |
| H-02 | 🟠 | Falta de validación de entrada en `saveOutfit`, `deleteOutfit`, `editOutfit`, `saveSkin` | Type/range checks + sanitización de `tags` y límites de longitud |
| H-03 | 🟡 | `print()` debug en rutas de error server | Eliminado (retorno silencioso seguro) |
| H-04 | 🟠 | NUI cargaba Font Awesome desde `site-assets.fontawesome.com` | Reemplazado por `cdnjs.cloudflare.com` en `html/index.html` |

---

## Eventos/callbacks revisados

| Evento/Callback | Control aplicado | Estado |
|:---|:---|:---:|
| `0r-outfitsaver:getSavedOutfitSkinById:server` | validación `id` + ownership por identifier | ✅ |
| `0r-outfitsaver:saveOutfit:server` | validación `outfitName`, `model`, `tags`, `skin` | ✅ |
| `0r-outfitsaver:deleteOutfit:server` | validación `outfitId` + `outfitName` | ✅ |
| `0r-outfitsaver:editOutfit:server` | validación `id`, `name`, `tags` + ownership | ✅ |
| `0r-outfitsaver:saveSkin:server` | validación `model`/`skin` y `player` | ✅ |

---

## SQL

- Consultas con placeholders (`?`, `@param`) mantenidas.
- No se detectó concatenación SQL vulnerable.

---

## Dependencias operativas

- `oxmysql`
- `/assetpacks`
- Framework: `qb-core` o `es_extended` (autodetección)

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Remediaciones aplicadas de forma quirúrgica para elevar seguridad sin alterar la lógica funcional de guardar/cargar/editar outfits.
