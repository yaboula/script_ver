# Reporte de Auditoria y Recierre - AUD-038

## 1) Encabezado

| Campo | Valor |
|:---|:---|
| ID de Auditoria | AUD-038 |
| Fecha | 2026-04-20 |
| Recurso | lc-gasstationsv2 (lc-gasstationsv2 + LegacyFuel + cdn-fuel + esx-sna-fuel) |
| Analista | IA (GitHub Copilot) |
| Tipo | Reaplicacion completa de protocolo + recierre |
| Auditoria previa | AUD-034 |
| Estado final | CERRADO Y APROBADO |
| Ruta auditada | approved/[qb]/lc-gasstationsv2 |

## 2) Contexto

Se aplico protocolo completo de seguridad sobre una copia que volvio a mostrar contaminacion leak y regresiones de hardening.

Se ejecuto analisis de inventario, escaneo C/A/M, revision manual de server/NUI/manifests, limpieza quirurgica y validacion final con evidencia reproducible.

## 3) Hallazgos y remediaciones

### H-01 (ALTA) SQL dinamico en compra de upgrades

Estado: Cerrado.

Evidencia tecnica:

- Se agrego `resolveUpgradeColumn(upgradeId)` para whitelisting estricto de columnas de upgrade.
- `gas_station:buyUpgrade` valida tipo de entrada y usa columna resuelta segura en SELECT/UPDATE.
- Se evita interpolacion de columna no permitida.

Archivo clave:

- approved/[qb]/lc-gasstationsv2/lc-gasstationsv2/server.lua

### H-02 (ALTA) Callback de historial sin autorizacion robusta

Estado: Cerrado.

Evidencia tecnica:

- `gas_station:loadBalanceHistory` ahora valida usuario, `stationId`, permiso owner/role `showBalance` y rango de `last_balance_id`.
- En entradas invalidas responde `cb({})` sin consultar datos sensibles.

Archivo clave:

- approved/[qb]/lc-gasstationsv2/lc-gasstationsv2/server.lua

### H-03 (ALTA) Wildcards y coherencia de manifests

Estado: Cerrado.

Evidencia tecnica:

- Remocion de wildcards en:
  - `cdn-fuel/fxmanifest.lua` (`escrow_ignore`)
  - `esx-sna-fuel/fxmanifest.lua` (`shared_scripts` locales + `escrow_ignore`)
  - `LegacyFuel/fxmanifest.lua` (`escrow_ignore`)
- `lc-gasstationsv2/fxmanifest.lua` actualizado con assets vendor locales requeridos por NUI.
- Verificacion final de manifests sin faltantes ni wildcards.

Archivos clave:

- approved/[qb]/lc-gasstationsv2/lc-gasstationsv2/fxmanifest.lua
- approved/[qb]/lc-gasstationsv2/LegacyFuel/fxmanifest.lua
- approved/[qb]/lc-gasstationsv2/cdn-fuel/fxmanifest.lua
- approved/[qb]/lc-gasstationsv2/esx-sna-fuel/fxmanifest.lua

### M-01 (MEDIA) Riesgo de inyeccion en NUI

Estado: Cerrado.

Evidencia tecnica:

- Endurecimiento de sinks DOM en `panel.js` para `.html()` y `.append()` con sanitizacion central (`Utils.sanitizeHtml`) cuando recibe strings.
- Sanitizacion de segmentos de path para imagenes dinamicas.
- Se mantiene `innerHTML = ""` solo para limpieza de contenedor canvas (uso no inyectable).

Archivo clave:

- approved/[qb]/lc-gasstationsv2/lc-gasstationsv2/nui/panel.js

### M-02 (MEDIA) Dependencias externas en NUI (CDN)

Estado: Cerrado.

Evidencia tecnica:

- Migracion de `lc-gasstationsv2/nui/ui.html` a vendor local: jQuery, Bootstrap, Select2, Font Awesome.
- Migracion de `LegacyFuel/html/ui.html` a jQuery local y remocion de imports externos de fuentes.
- Assets locales declarados en manifests.

Archivos clave:

- approved/[qb]/lc-gasstationsv2/lc-gasstationsv2/nui/ui.html
- approved/[qb]/lc-gasstationsv2/LegacyFuel/html/ui.html
- approved/[qb]/lc-gasstationsv2/LegacyFuel/html/ui.css
- approved/[qb]/lc-gasstationsv2/lc-gasstationsv2/fxmanifest.lua
- approved/[qb]/lc-gasstationsv2/LegacyFuel/fxmanifest.lua

## 4) Limpieza de contaminacion leak

Estado: Cerrado.

Evidencia tecnica:

- Eliminados artefactos no funcionales de leak (`.md`, `.txt`, `.url`) dentro de payload.
- Eliminados banners y marcadores leak inyectados en archivos de codigo/texto.
- Conteo final:
  - `leak_marker_matches=0`
  - `leftover_docs_in_payload=0`

## 5) Evidencia de integridad (AUD-038)

Artefactos generados:

- Inventario: reports/audit_AUD-038_lc-gasstationsv2_2026-04-20_inventory.tsv
- Hashes SHA-256: reports/audit_AUD-038_lc-gasstationsv2_2026-04-20_hashes.tsv
- Validacion tecnica: reports/audit_AUD-038_lc-gasstationsv2_2026-04-20_validation.txt
- Resumen de escaneo: reports/audit_AUD-038_lc-gasstationsv2_2026-04-20_scan_summary.txt

Resumen final de validacion:

- `files_total=90`
- `manifest_main_missing=0`
- `manifest_legacy_missing=0`
- `manifest_cdn_missing=0`
- `manifest_esx_missing=0`
- `manifest_main_wildcards=0`
- `manifest_legacy_wildcards=0`
- `manifest_cdn_wildcards=0`
- `manifest_esx_wildcards=0`
- `leak_marker_matches=0`
- `leftover_docs_in_payload=0`
- `critical_scan`: sin coincidencias

## 6) Riesgo residual

No se detectan criterios de rechazo automatico R-01..R-07 en esta pasada.

Riesgos residuales aceptables y documentados:

- Permanecen llamadas `PerformHttpRequest` para chequeo de version (sin ejecucion dinamica de payload remoto):
  - `lc-gasstationsv2/server.lua`
  - `cdn-fuel/server/fuel_sv.lua`
- URLs restantes en NUI corresponden a:
  - `https://cfx-nui-lc_utils/...` (interna de FiveM)
  - comentario documental de blips

## 7) Decision final

Veredicto:

- CERRADO Y APROBADO para flujo de instalacion controlada.

Condicion operativa:

- Cualquier cambio futuro en Lua/NUI/manifests invalida este cierre y exige re-auditoria antes de instalar en fase0/produccion.
