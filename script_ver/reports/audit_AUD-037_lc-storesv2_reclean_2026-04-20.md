# Reporte de Recierre de Auditoria - AUD-037

## 1) Encabezado

| Campo | Valor |
|:---|:---|
| ID de Auditoria | AUD-037 |
| Fecha | 2026-04-20 |
| Recurso | lc-storesv2 (incluye lc-storesv2 + lc_utils) |
| Analista | IA (GitHub Copilot) |
| Tipo | Recierre post-restauracion y saneamiento completo |
| Auditoria de referencia | AUD-036 |
| Estado final | CERRADO Y APROBADO |
| Ruta aprobada | approved/[qb]/lc-storesv2 |

## 2) Contexto

Despues de restaurar el recurso desde una copia de origen contaminada, se requirio re-ejecutar el protocolo completo de seguridad para recuperar estado aprobado real.

En esta pasada se repitio limpieza, endurecimiento y validacion de integridad con nueva evidencia AUD-037.

## 3) Estado de hallazgos tecnicos

### H-01 (ALTA) SQL dinamico en stores:buyUpgrade

Estado: Cerrado.

Evidencia tecnica:

- Validacion de columna por whitelist via `resolveUpgradeColumn(market_id, upgrade_id)`.
- `upgrade_id` limitado a patron seguro y a upgrades permitidos por configuracion.
- SQL dinamico restringido a nombres de columna validados.

Archivo clave:

- approved/[qb]/lc-storesv2/lc-storesv2/server.lua

### H-02 (ALTA) Callback stores:loadBalanceHistory sin permiso

Estado: Cerrado.

Evidencia tecnica:

- Validacion de usuario, mercado y existencia de configuracion.
- Control de permisos (owner o rol con `showBalance`).
- Validacion estricta de `last_balance_id` numerico y mayor a 0.

Archivo clave:

- approved/[qb]/lc-storesv2/lc-storesv2/server.lua

### H-03 (ALTA) Coherencia de manifests

Estado: Cerrado.

Evidencia tecnica:

- Verificacion de `files {}` contra disco: sin referencias faltantes.
- Normalizacion de rutas a separador `/` para evitar escapes invalidos en literales Lua.
- Resultado final:
  - `manifest_missing_lc-storesv2=0`
  - `manifest_missing_lc_utils=0`
  - `manifest_backslash_entries=0`

Archivos clave:

- approved/[qb]/lc-storesv2/lc-storesv2/fxmanifest.lua
- approved/[qb]/lc-storesv2/lc_utils/fxmanifest.lua

### M-01 (MEDIA) Riesgo XSS en NUI

Estado: Cerrado.

Evidencia tecnica:

- Sanitizacion centralizada para HTML/URL/path segment en utilidades NUI.
- Endurecimiento de sinks DOM (`html`/`append`) para cadenas dinamicas.
- Notificaciones renderizadas con `textContent` para titulo y mensaje.

Archivos clave:

- approved/[qb]/lc-storesv2/lc-storesv2/nui/panel.js
- approved/[qb]/lc-storesv2/lc_utils/nui/index.js
- approved/[qb]/lc-storesv2/lc_utils/nui/js/notification.js

### M-02 (MEDIA) Dependencias NUI externas

Estado: Cerrado.

Evidencia tecnica:

- Migracion de dependencias de CDN a vendor local en el recurso.
- Manifests actualizados para declarar assets locales reales.
- Escaneo final de URLs en NUI sin CDNs externos activos.

Archivos clave:

- approved/[qb]/lc-storesv2/lc-storesv2/nui/ui.html
- approved/[qb]/lc-storesv2/lc_utils/nui/index.html

## 4) Limpieza de contaminacion leak

Estado: Cerrado.

Evidencia tecnica:

- Eliminacion de artefactos no funcionales de leak (`.md`, `.txt`, `.url`) dentro de payload.
- Remocion de marcadores/banners leak en archivos de codigo/texto.
- Conteo final: `leak_marker_matches=0`.

## 5) Evidencia de integridad (AUD-037)

Artefactos generados:

- Inventario: reports/audit_AUD-037_lc-storesv2_reclean_2026-04-20_inventory.tsv
- Hashes SHA-256: reports/audit_AUD-037_lc-storesv2_reclean_2026-04-20_hashes.tsv
- Validacion tecnica: reports/audit_AUD-037_lc-storesv2_reclean_2026-04-20_validation.txt

Resumen de validacion:

- `files_total=159`
- `manifest_missing_lc-storesv2=0`
- `manifest_missing_lc_utils=0`
- `manifest_backslash_entries=0`
- `leak_marker_matches=0`
- `critical_scan`: sin coincidencias

## 6) Riesgo residual

No se detectan criterios de rechazo automatico R-01..R-07 en esta fase de recierre.

Riesgo residual operativo:

- Cualquier cambio futuro en Lua/NUI/manifests invalida este cierre y exige re-auditoria antes de instalacion.

## 7) Decision final

Veredicto:

- CERRADO Y APROBADO para cadena de instalacion controlada.

Condicion operativa:

- Mantener protocolo Admirales: fase0 primero, backups previos obligatorios, y sin modificar logica de codigo durante instalacion.
