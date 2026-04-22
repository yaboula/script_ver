# Notas de Auditoría — mWeed

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-043` |
| **Fecha de Auditoría** | 2026-04-23 |
| **Analista** | IA (AI_RUNBOOK v1.1.0) |
| **Estado** | 🔧 Limpiado y Aprobado |
| **Versión del Recurso** | `1.3` |
| **Origen** | No oficial — posible producto CodeM (verificar licencia) |
| **Hash SHA-256 fxmanifest.lua** | `0114ADF15528338E43EC85D80D64BF0CBBE492C9F5E21CA0455BED6C595861D3` |
| **Severidad Máxima Detectada** | 🟡 Media |
| **Reporte Completo** | `reports/audit_AUD-043_mWeed_2026-04-23.md` |

---

## Dependencias Requeridas

| Recurso | Versión | Notas |
|:---|:---|:---|
| `qb-core` | v1.x+ | O ESX equivalente según framework elegido |
| `/assetpacks` | FiveM built-in | Requerido por fxmanifest |
| `ox_inventory` | Opcional | Solo si se usa el export `useJoint` |

---

## Cambios Realizados Durante Auditoría

- [x] `fxmanifest.lua` — `fx_version` actualizado de `'adamant'` a `'cerulean'`
- [x] `fxmanifest.lua` — Bloque `escrow_ignore` eliminado (residuo de versión de marketplace)
- [x] `server/botToken.lua` — Añadido aviso de confidencialidad del token Discord

---

## Configuración Necesaria para Instalación

- [ ] Editar `shared/config.lua` → `Config.Framework`: elegir `'qb'`, `'esx'`, `'oldqb'`, `'oldesx'` o `'autodetect'` *(por defecto: `'qb'`)*
- [ ] Editar `shared/config.lua` → `Config.InteractionHandler`: elegir `'qb-target'`, `'ox_target'` o `'drawtext'` *(por defecto: `'drawtext'`)*
- [ ] Añadir al `server.cfg`: `ensure mWeed`
- [ ] Ejecutar SQL de items según framework:
  - **QBCore** → usar `qbcoreitems.txt` (añadir los items a `qb_items`)
  - **ESX** → ejecutar `esxItems.sql` en la base de datos
  - **ESX sin item water** → ejecutar también `esxItemsWater(...).sql`
- [ ] Copiar imágenes de inventario: `inventory_images/*.png` → directorio de imágenes del inventario usado (`codem-inventory`, `qb-inventory`, etc.)
- [ ] *(Opcional)* Editar `server/botToken.lua` → pegar token del bot de Discord para habilitar avatares en el dealer

---

## Notas para el Equipo de Instalación

- **Persistencia de datos:** Los datos de plantas son **en memoria** (no hay SQL). Se pierden al reiniciar el servidor. Esto es por diseño del script.
- **ox_inventory:** Si se usa este inventario, el script exporta `useJoint`. Enlazarlo en la config de ox_inventory para que fumar joints funcione.
- **botToken:** Completamente opcional. Si se deja vacío (`''`), el dealer mostrará la imagen por defecto `example-pp.png` como avatar.
- **InteractionHandler:** El modo `'drawtext'` funciona sin dependencias extra. Para `'qb-target'` u `'ox_target'` el recurso correspondiente debe estar activo.
- **Conflictos potenciales:** Cualquier recurso que registre los mismos nombres de items (`indica_seed`, `sativa_seed`, `grinder`, etc.).
- **⚠️ Licencia:** Este script puede ser un producto de pago (CodeM). Verificar que se cuenta con licencia válida antes de usar en producción.
