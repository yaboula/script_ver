# Reporte de Auditoria de Seguridad - AUD-024

## mythic_notify

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-024 |
| Recurso | mythic_notify |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\under-review\mythic_notify |
| Manifiesto | __resource.lua (legacy) |
| Version declarada | v1.0.3 |
| Total de archivos | 9 |

---

## 1) Inventario y hashes

Inventario SHA-256 completo:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-024_mythic_notify_2026-04-17_hashes.tsv

Muestra:
- __resource.lua -> E8C4554E009D024A09FC729A3351782DEBB2DADF35445B3DC939D8BE3A26D6F4
- client/main.lua -> EC8E3C46BABAF23788552B7B020C4BE18F44A30DB803AC7C3C68D528F7363FC2
- html/js/app.js -> 0C1035FE08E17DA5FFAE95A8D5BD08BEB80DA22C452379365E28178051F86B6C

---

## 2) Nivel 1 - Escaneo automatizado

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest / PerformHttpRequestInternal | C-01/C-02 | 0 | OK |
| load/loadstring/assert(load)/RunString | C-03/C-04/C-05/C-06 | 0 | OK |
| Obfuscacion hex/string.char/debug | C-07/C-08/C-12 | 0 | OK |
| os.execute/io.popen/io.open | C-09/C-10/C-11 | 0 | OK |
| IDs hardcodeados/IP/ExecuteCommand/GetConvar | A-01..A-04/A-08/A-09 | 0 | OK |
| RegisterNetEvent (lua) | A-06 | 2 | Revisado manualmente |
| eval/new Function/document.write | M-03 | 0 | OK |
| Insercion HTML en frontend | M-02 | 3 | Mitigado en limpieza |
| Binarios peligrosos (R-01) | R-01 | 0 | OK |

---

## 3) Nivel 2 - Revision manual profunda

### 3.1 Manifiesto y estructura

- Recurso usa __resource.lua (legacy) y declara:
  - ui_page: html/ui.html
  - files: html/ui.html, html/js/app.js, html/css/style.css, config.js
  - client_scripts: client/main.lua
- No hay server_script ni shared_script.
- No hay wildcards en files{}.
- No hay referencias a archivos fantasma.

### 3.2 Analisis de eventos

Eventos detectados (cliente):
- mythic_notify:client:SendAlert
- mythic_notify:client:PersistentHudText

Observacion:
- No existen eventos server-side en este recurso; por lo tanto no hay superficie de money/items/permisos/SQL en servidor.

### 3.3 SQL y backend

- Sin uso de MySQL/oxmysql/mysql-async.
- Sin consultas SQL.

### 3.4 NUI / dependencias web

- html/ui.html carga:
  - jquery interno de FiveM: nui://game/ui/jquery.js (permitido)
  - Google Fonts: fonts.googleapis.com (CDN conocido/permitido)
- No se detectaron scripts remotos desconocidos.

Hallazgo original:
- html/js/app.js insertaba data.text/data.caption con html(), potencial XSS en NUI si la fuente de texto no es confiable.

Limpieza aplicada (quirurgica):
- Se reemplazo html() por text() para evitar inyeccion HTML/JS:
  - $notification.html(data.text) -> $notification.text(data.text)
  - $caption.html(data.caption) -> $caption.text(data.caption)
  - actualizacion persistente: $notification.html(data.text) -> $notification.text(data.text)

Archivo modificado en limpieza:
- c:\admirales\script_ver\script_ver\quarantine\under-review\mythic_notify\html\js\app.js

---

## 4) Resumen de hallazgos

| ID | Severidad | Tipo | Estado |
|:---:|:---:|:---|:---|
| H-024-01 | MEDIO | Potencial XSS por insercion HTML directa en NUI | Remediado |

Conteo final tras limpieza:
- Criticos: 0
- Altos: 0
- Medios: 0 abiertos
- Bajos: 0

---

## 5) Decision final

VEREDICTO: LIMPIADO Y APROBADO

Motivo:
- No hay criterios de rechazo automatico (R-01..R-07).
- No hay indicadores de RAT/exfiltracion/ejecucion remota.
- Hallazgo medio de frontend fue mitigado sin alterar la logica central del recurso.

Destino aprobado:
- c:\admirales\script_ver\script_ver\approved\[standalone]\03_ECONOMY_COMMUNICATION\mythic_notify

---

## 6) Dependencias

- Requerida: jQuery interno de FiveM (nui://game/ui/jquery.js)
- Externa permitida: fonts.googleapis.com (Google Fonts)

No requiere ox_lib ni backend SQL.
