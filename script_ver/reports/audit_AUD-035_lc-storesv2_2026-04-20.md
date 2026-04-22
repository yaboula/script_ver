# Reporte de Auditoria de Seguridad - Segunda Verificacion

## 1) Encabezado

| Campo | Valor |
|:---|:---|
| ID de Auditoria | AUD-035 |
| Recurso | lc-storesv2 (incluye lc-storesv2 + lc_utils) |
| Fecha | 2026-04-20 |
| Analista | IA (GitHub Copilot) |
| Tipo | Re-auditoria completa (segunda pasada) |
| Origen | Recurso ya ubicado en approved/[qb]/lc-storesv2 |
| Severidad maxima detectada | Alta |
| Estado final segunda verificacion | Limpieza requerida (no apto para despliegue sin remediacion) |

## 2) Inventario de archivos y hashes

Artefactos generados en esta segunda pasada:

- Inventario: reports/audit_AUD-035_lc-storesv2_2026-04-20_inventory.tsv
- Hashes SHA-256: reports/audit_AUD-035_lc-storesv2_2026-04-20_hashes.tsv
- Escaneo Nivel 1: reports/audit_AUD-035_lc-storesv2_2026-04-20_level1_scan.txt

Resultado de rechazo automatico R-01 (binarios ejecutables):

- No se detectaron .exe, .dll, .bat, .ps1, .sh, .cmd, .vbs, .msi, .scr

## 3) Nivel 1 - Escaneo automatizado (C/A/M)

| Categoria | Resultado |
|:---|:---|
| Criticos (C) | Hallazgos tecnicos no confirmados como malware (PerformHttpRequest, load local) |
| Altos (A) | Eventos server extensivos y callback server expuesto sin validacion de permiso |
| Medios (M) | Riesgo XSS por innerHTML/html()/append() con datos dinamicos en NUI |
| Binarios peligrosos | 0 |

Hallazgos principales de Nivel 1:

- PerformHttpRequest en:
  - lc-storesv2/server.lua:147
  - lc_utils/functions/server/version.lua:186
  - lc_utils/functions/server/webhook.lua:126
- load() en lc_utils/functions/loader.lua:152 (carga local con LoadResourceFile)
- RegisterServerEvent/AddEventHandler en server.lua (30 eventos de servidor)
- RegisterNetEvent callback server en lc_utils/functions/server/callback.lua:130
- innerHTML en lc_utils/nui/js/notification.js:168,191,194
- Mismatches manifiesto vs archivos reales en lc-storesv2/fxmanifest.lua (detallado abajo)

## 4) Nivel 2 - Revision manual profunda

### H-01 (ALTA) SQL dinamico con entrada de cliente en nombre de columna

Archivo: lc-storesv2/server.lua

- Linea 1736: SELECT dinamico por concatenacion de data.id
- Linea 1750: UPDATE dinamico por concatenacion de data.id

Evidencia:

- "SELECT " .. data.id .. "_upgrade ..."
- "UPDATE `store_business` SET " .. data.id .. "_upgrade = ..."

Riesgo:

- data.id llega desde evento de cliente (stores:buyUpgrade).
- No hay whitelist previa de columna antes de construir SQL.
- Posible inyeccion SQL o errores de parseo con input malicioso.

### H-02 (ALTA) Callback server expuesto sin control de permisos

Archivos:

- lc_utils/functions/server/callback.lua:130
- lc-storesv2/server.lua:1928

Evidencia:

- Evento callback global: getResourceName():triggerServerCallback
- Callback registrado stores:loadBalanceHistory devuelve SELECT * de store_balance
- No usa Wrapper ni chequeo de owner/rol antes de devolver historico

Riesgo:

- Cualquier cliente que invoque el callback puede intentar leer historial financiero de mercados si conoce market_id y last_balance_id.

### H-03 (ALTA) Referencias fantasma en fxmanifest del recurso principal

Archivo: lc-storesv2/fxmanifest.lua

Declarados pero no existentes (Test-Path = False):

- nui/lang/br.json
- nui/lang/de.json
- nui/lang/en.json
- nui/img/logo.png
- nui/img/bg.png

Riesgo:

- Inconsistencia de paquete, carga incompleta de assets y posibilidad de fallos de UI.
- La primera auditoria previa no dejo este punto correctamente cerrado.

### M-01 (MEDIA) Riesgo XSS en NUI por insercion HTML dinamica

Archivos:

- lc_utils/nui/js/notification.js:168,191,194
- lc-storesv2/nui/panel.js (multiples lineas con .html() y .append())
- lc-storesv2/server.lua:1666-1690 (renameMarket guarda data.name sin sanitizar)

Riesgo:

- Si valores controlables por jugador (ej. market_name u otros campos) llegan a sinks HTML, puede haber inyeccion HTML/JS en NUI.

### M-02 (MEDIA) Dependencias NUI externas

Archivos:

- lc-storesv2/nui/ui.html (Google Fonts, jsDelivr, cdnjs)
- lc_utils/nui/index.html (Google Fonts, jsDelivr)

Riesgo:

- Dominios son CDNs conocidos, pero siguen siendo carga externa en runtime.
- Recomendacion defensiva: alojar localmente para reducir superficie de supply-chain.

### Observaciones sin hallazgo critico confirmado

- PerformHttpRequest en checks de version y webhook: no ejecutan payload remoto con loadstring.
- load() en loader.lua consume chunk local via LoadResourceFile (no remoto).
- No se detecto os.execute, io.popen, ni binarios de rechazo automatico.

## 5) Analisis de eventos de servidor

Cobertura de eventos server en lc-storesv2/server.lua:

- Total RegisterServerEvent + AddEventHandler: 30
- Patrón general:
  - source: si (local _source = source)
  - permisos: centralizados via Wrapper (true/false segun evento)
  - rate-limit: basico (is_player_busy + SetTimeout 100ms)
  - validacion de tipos: parcial/no sistematica

Resumen por evento (permiso Wrapper):

| Evento | Permiso Wrapper |
|:---|:---:|
| stores:getData | false |
| stores:buyMarket | false |
| stores:openMarket | false |
| stores:loadJobData | false |
| stores:startDeliverymanJob | false |
| stores:storeProductFromInventory | true |
| stores:startImportJob | true |
| stores:startExportJob | true |
| stores:finishImportJob | false |
| stores:finishExportJob | false |
| stores:setPrice | true |
| stores:buyItem | false |
| stores:createJob | true |
| stores:deleteJob | true |
| stores:renameMarket | true |
| stores:getBlips | (sin Wrapper; consulta global) |
| stores:buyUpgrade | true |
| stores:hideBalance | true |
| stores:showBalance | true |
| stores:withdrawMoney | true |
| stores:depositMoney | true |
| stores:hirePlayer | true |
| stores:firePlayer | true |
| stores:changeRole | true |
| stores:giveComission | true |
| stores:buyCategory | true |
| stores:sellCategory | true |
| stores:changeTheme | false |
| stores:sellMarket | true |
| playerDropped | n/a |
| stores:failed | n/a |

Nota: el callback stores:loadBalanceHistory no usa Wrapper y queda como hallazgo H-02.

## 6) Analisis SQL

| Query / patron | Archivo:linea | Parametrizada | Veredicto |
|:---|:---|:---:|:---|
| SELECT stock_prices ... WHERE market_id=@market_id | lc-storesv2/server.lua:1224 | Si | Seguro |
| UPDATE store_business SET stock_prices=@stock_prices ... | lc-storesv2/server.lua:1234 | Si | Seguro |
| SELECT " .. data.id .. "_upgrade ... | lc-storesv2/server.lua:1736 | No | Vulnerable (H-01) |
| UPDATE store_business SET " .. data.id .. "_upgrade ... | lc-storesv2/server.lua:1750 | No | Vulnerable (H-01) |
| SELECT market_id NOT IN (...) con string.format y table.concat(config_markets) | lc-storesv2/server.lua:3293 | Dinamica (origen interno config) | Riesgo bajo (no input cliente directo) |

## 7) Analisis NUI

- ui_page detectada en ambos recursos:
  - lc-storesv2/nui/ui.html
  - lc_utils/nui/index.html
- URLs externas encontradas: CDNs conocidos (Google Fonts, jsDelivr, cdnjs).
- Riesgo de XSS:
  - notification.js usa innerHTML para title/message.
  - panel.js usa html()/append() en gran volumen, incluyendo valores de negocio renderizados en DOM.

## 8) Resumen de hallazgos

| ID | Severidad | Tipo | Estado |
|:---|:---:|:---|:---|
| H-01 | Alta | SQL dinamico con data.id (posible inyeccion) | Abierto |
| H-02 | Alta | Callback server sin permiso (exposicion de datos) | Abierto |
| H-03 | Alta | Referencias fantasma en fxmanifest de lc-storesv2 | Abierto |
| M-01 | Media | Riesgo XSS por sinks HTML dinamicos | Abierto |
| M-02 | Media | Dependencias NUI externas (CDN) | Abierto (recomendacion) |

## 9) Decision final de segunda verificacion

Veredicto:

- LIMPIEZA REQUERIDA (segunda verificacion no aprobada)

Justificacion:

- Se detectaron hallazgos de severidad Alta que requieren remediacion previa.
- No hay evidencia de RAT/auto-propagacion ni criterios de rechazo automatico R-01..R-07 confirmados en esta pasada.

Remediaciones minimas obligatorias antes de considerar aprobado:

1. BuyUpgrade: reemplazar SQL dinamico por whitelist estricta de columnas permitidas (ej. stock/truck/relationship) y consultas seguras.
2. stores:loadBalanceHistory: aplicar Wrapper + chequeo owner/rol + validacion tipo/rango de market_id y last_balance_id.
3. fxmanifest de lc-storesv2: eliminar rutas inexistentes o restaurar assets realmente usados.
4. NUI: evitar innerHTML/html()/append() con contenido no sanitizado; usar textContent/escape en campos dinamicos.

## 10) Dependencias

- mysql-async
- lc_utils
- framework qbcore o esx (segun configuracion)

## Nota de trazabilidad

Esta auditoria corresponde a una segunda pasada completa sobre un recurso ya ubicado en approved. El estado de seguridad derivado de AUD-035 debe prevalecer sobre la conclusion previa hasta completar limpieza y re-auditoria.
