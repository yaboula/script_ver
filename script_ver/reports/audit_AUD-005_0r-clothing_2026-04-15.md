# Reporte de Auditoría de Seguridad — AUD-005

## `0r-clothing`

| Campo | Valor |
|:---|:---|
| **ID** | `AUD-005` |
| **Fecha** | 2026-04-15 |
| **Recurso** | `0r-clothing` |
| **Origen** | Lote `incoming/[Clothing]` |
| **Protocolo** | `SECURITY_PROTOCOL.md` + `AI_RUNBOOK.md` |
| **Veredicto** | ✅ **LIMPIADO Y APROBADO** |

---

## Inventario y hashes

- Inventario completo con SHA-256: `reports/audit_AUD-005_0r-clothing_2026-04-15_hashes.tsv`
- Archivos binarios peligrosos (R-01): **0**

---

## Nivel 1 — Escaneo automatizado

- `PerformHttpRequest`, `load`, `loadstring`, `os.execute`, `io.popen`, `io.open`: **sin hallazgos críticos**.
- SQL: consultas parametrizadas detectadas (`?`, `@param`).
- NUI: se detectaron dependencias externas no confiables (remediado).
- Eventos server-side numerosos: pasó a revisión manual profunda.

---

## Nivel 2 — Hallazgos y remediaciones

| ID | Sev. | Hallazgo | Remediación |
|:---:|:---:|:---|:---|
| H-01 | 🟠 | NUI cargaba FontAwesome desde host no confiable (`site-assets.fontawesome.com`) | Reemplazado por CDN confiable `cdnjs.cloudflare.com` en `html/index.html` |
| H-02 | 🟠 | Defaults apuntaban a host externo de imágenes (`i.fmfile.com`) | Defaults seguros en `shared/config.lua`: `UseWebServer=false` y `UseDefaultClothImages` en `false` |
| H-03 | 🟠 | Eventos sensibles de administración sin control (`disable*DefaultImages`) | Guardas de permiso ACE (`0r-clothing.admin`) en `server/main.lua` |
| H-04 | 🟠 | Falta de validación de entrada en `buyClothing` y `saveSkin` | Type/range checks para `amount`, `paymentType`, `model`, `skin` |
| H-05 | 🟡 | Ruta ESX con `identifier` no definido en callbacks | Corregido usando `GetPlayer(source).identifier` |
| H-06 | 🟡 | Wildcards de scripts en manifiesto | Reemplazados por listas explícitas (`client_scripts`, `server_scripts`, `shared_scripts`) |

---

## Eventos server-side revisados (resumen)

| Evento/Callback | Validación aplicada | Estado |
|:---|:---|:---:|
| `0r-clothing:saveSkin:server` | tipos de `model` y `skin` | ✅ |
| `0r-clothing:buyClothing:server` | tipo/rango `amount` + whitelist `paymentType` | ✅ |
| `disableAll/Face/Body/Clothing/AccessoriesDefaultImages` | ACE admin check | ✅ |
| `0r-clothing:updateTattooList:server` | `tattooList` debe ser tabla | ✅ |
| ESX `getSkin/getPlayerSkin` callbacks | `identifier` derivado de player server-side | ✅ |

---

## SQL

- `playerskins`, `users`, `player_outfits`, `0r_clothing_tattoos`: uso parametrizado.
- No se detectó concatenación SQL vulnerable.

---

## NUI

- Activo: `html/index.html` (limpio tras remediación).
- `html-old/` contiene referencias externas legacy, pero **no está cargado por `ui_page` ni `files` activos**.

---

## Dependencias operativas

- `oxmysql`
- `0r-imagegenerator`
- `/assetpacks`
- Framework: `qb-core` o `es_extended` (autodetección)

---

## Decisión final

**✅ LIMPIADO Y APROBADO**

Remediaciones aplicadas sin alterar la lógica funcional principal de creación/edición de personaje y tiendas de ropa/barber/tattoos.
