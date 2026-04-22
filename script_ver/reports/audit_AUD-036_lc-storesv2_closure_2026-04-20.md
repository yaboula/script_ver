# Reporte de Cierre de Auditoria - AUD-036

## 1) Encabezado

| Campo | Valor |
|:---|:---|
| ID de Auditoria | AUD-036 |
| Fecha | 2026-04-20 |
| Recurso | lc-storesv2 (incluye lc-storesv2 + lc_utils) |
| Analista | IA (GitHub Copilot) |
| Tipo | Cierre post-remediacion |
| Auditoria base | AUD-035 |
| Estado final | CERRADO Y APROBADO |
| Ruta aprobada | approved/[qb]/lc-storesv2 |

## 2) Contexto

AUD-035 dejo hallazgos abiertos de severidad Alta (H-01, H-02, H-03) y Media (M-01, M-02), por lo que el recurso quedo bloqueado para despliegue.

En esta pasada de cierre se verifico la remediacion tecnica completa y se ejecuto una validacion final de integridad sobre la copia en approved.

## 3) Remediaciones verificadas

### H-01 (ALTA) SQL dinamico en stores:buyUpgrade

Estado: Cerrado.

Evidencia tecnica:

- Se agrego validacion de columna mediante `resolveUpgradeColumn(market_id, upgrade_id)`.
- `upgrade_id` debe ser string y cumplir patron `^[%w_]+$`.
- Solo se permite upgrade presente en `market_type.upgrades`.
- El nombre de columna SQL queda acotado a valores validos de configuracion.

Archivo clave:

- approved/[qb]/lc-storesv2/lc-storesv2/server.lua

### H-02 (ALTA) Callback stores:loadBalanceHistory sin permiso

Estado: Cerrado.

Evidencia tecnica:

- Se valida `user_id`, `market_id` y existencia en `Config.market_locations`.
- Se exige propiedad o rol `showBalance` antes de consultar historico.
- Se valida `last_balance_id` numerico y mayor a 0.
- Query parametrizada mantenida.

Archivo clave:

- approved/[qb]/lc-storesv2/lc-storesv2/server.lua

### H-03 (ALTA) Referencias inexistentes en fxmanifest

Estado: Cerrado.

Evidencia tecnica:

- Verificacion automatizada `files {}` contra disco: sin faltantes.
- Resultado final:
  - lc-storesv2 manifest missing: 0
  - lc_utils manifest missing: 0

Archivos clave:

- approved/[qb]/lc-storesv2/lc-storesv2/fxmanifest.lua
- approved/[qb]/lc-storesv2/lc_utils/fxmanifest.lua

### M-01 (MEDIA) Riesgo XSS en NUI

Estado: Cerrado.

Evidencia tecnica:

- Endurecimiento de sinks en panel principal (intercepcion de html/append para strings sanitizadas).
- Uso de helpers de sanitizacion (`sanitizeHtml`, `sanitizeUrl`, `sanitizePathSegment`) en utilidades NUI.
- Notificaciones actualizadas para renderizar titulo/mensaje con `textContent` en lugar de `innerHTML`.

Archivos clave:

- approved/[qb]/lc-storesv2/lc-storesv2/nui/panel.js
- approved/[qb]/lc-storesv2/lc_utils/nui/index.js
- approved/[qb]/lc-storesv2/lc_utils/nui/js/notification.js

### M-02 (MEDIA) Dependencias NUI externas (CDN)

Estado: Cerrado.

Evidencia tecnica:

- Sustitucion de CDN por assets locales vendorizados.
- Declaracion explicita de vendor assets en manifest.
- Escaneo final de URLs solo detecta:
  - `https://cfx-nui-lc_utils/...` (URL interna de FiveM)
  - comentario de referencia documental de blips
  - helper interno de construccion de URL en lc_utils

Archivos clave:

- approved/[qb]/lc-storesv2/lc-storesv2/nui/ui.html
- approved/[qb]/lc-storesv2/lc_utils/nui/index.html
- approved/[qb]/lc-storesv2/lc-storesv2/fxmanifest.lua
- approved/[qb]/lc-storesv2/lc_utils/fxmanifest.lua

## 4) Limpieza de artefactos leak

Estado: Cerrado.

Evidencia tecnica:

- Se removieron bloques/banner leak incrustados en archivos de codigo.
- Se removieron artefactos de leak no funcionales (.md/.txt/.url) dentro del paquete.
- Conteo final de marcadores leak: 0 archivos.

## 5) Evidencia de integridad (AUD-036)

Artefactos generados en esta fase de cierre:

- Inventario: reports/audit_AUD-036_lc-storesv2_closure_2026-04-20_inventory.tsv
- Hashes SHA-256: reports/audit_AUD-036_lc-storesv2_closure_2026-04-20_hashes.tsv
- Validacion tecnica: reports/audit_AUD-036_lc-storesv2_closure_2026-04-20_validation.txt

Resumen de validacion:

- files_total: 161
- manifest_missing_lc-storesv2: 0
- manifest_missing_lc_utils: 0
- leak_marker_files_remaining: 0

## 6) Riesgo residual

No se detectan criterios de rechazo automatico R-01..R-07 en esta fase de cierre.

Riesgos residuales aceptables (operativos):

- Existen llamadas `PerformHttpRequest` para chequeo de version/webhook en el recurso; no se observo ejecucion de payload remoto.
- Cualquier cambio futuro en scripts/NUI/manifests requiere re-auditoria antes de instalacion.

## 7) Decision final

Veredicto:

- CERRADO Y APROBADO para flujo de instalacion controlada.

Condicion operativa:

- Mantener el protocolo Admirales: instalacion inicial en fase0, backups previos y sin modificar logica de codigo durante instalacion.
