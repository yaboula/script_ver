# Reporte de Auditoria de Seguridad - AUD-031

## prism_pausemenu

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-031 |
| Recurso | prism_pausemenu |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\under-review\[resources]\prism_pausemenu |
| Version declarada | 1.0.1 |
| Manifiesto | fxmanifest.lua |
| Total de archivos | 33 |
| Alcance de esta pasada | Nivel 1 + Nivel 2 + hardening puntual |

---

## 1) Inventario y hashes SHA-256

Inventario completo:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-031_prism_pausemenu_2026-04-17_inventory.tsv

Hashes completos:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-031_prism_pausemenu_2026-04-17_hashes.tsv

Artefacto de escaneo Nivel 1:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-031_prism_pausemenu_2026-04-17_level1_scan.txt

Muestra verificada:
- fxmanifest.lua -> F41E3D669D7950C18D69D8FB2DE5AFF056AB6FE66578EA6E18A8462DBE79F8AE
- modules/server/main.lua -> 87F1D5FE06D4910A77CA294D23631E5C327EA94A6764AB8CDD9CD230C5754EE7
- modules/client/nui.lua -> 4C3D1CA55C9B18A647B8A462D193A117559FA11D84A93C1F6F2FA99265BF21D6
- modules/bridge/qb/server.lua -> 1595FE03017BA1539C77881557969496F3EF4B9EE897E682BC18941F1817D051
- web/dist/assets/index-CxvIiCcd.js -> 71A5675AA317E6A18F1F55A3269D3D38573143B1C66C3E6A8AD77E422D9108C6

---

## 2) Nivel 1 - Escaneo automatizado

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest | C-01 | 0 | OK |
| PerformHttpRequestInternal | C-02 | 0 | OK |
| load/loadstring/assert(load)/RunString | C-03/C-04/C-05/C-06 | 0 | OK |
| os.execute/io.popen/io.open/ExecuteCommand | C-09/C-10/C-11/A-09 | 0 | OK |
| string.char / hex obfuscation | C-07/C-08 | 0 | OK |
| RegisterCommand | A-05 | 3 | Revisado (comando debug checkplaytime, restricted=true) |
| RegisterNetEvent/CreateCallback | A-06 | 1* | Revisado (la heuristica no capta RegisterServerEvent ofuscado) |
| Hardcoded identifiers | A-01 | 1 | Falso positivo funcional (prefijo ^license: para selector de identificador) |
| NUI innerHTML/dangerouslySetInnerHTML | M-02 | 17 | Coincidencias de runtime React minificado |
| eval/new Function | M-03 | 0 | OK |
| Suspicious binaries | R-01 | 0 | OK |

Nota de cobertura A-06:
- Adicional a la heuristica, en revision manual se confirmo 1 RegisterServerEvent en modules/server/main.lua y callbacks framework en bridges ESX/QB/QBox.

---

## 3) Nivel 2 - Revision manual profunda

### 3.1 Hallazgos confirmados

| ID | Severidad | Hallazgo | Evidencia |
|:---:|:---:|:---|:---|
| H-031-01 | ALTO | Evento de desconexion confiaba en playerId enviado por cliente, permitiendo intento de expulsar terceros | modules/server/main.lua:3, modules/client/nui.lua:129 |
| H-031-02 | MEDIO | Dependencia externa de Google Fonts en CSS de NUI (supply chain no bloqueante) | web/dist/assets/index.css:1 |
| H-031-03 | BAJO | uso de tabla global mutable data en callbacks de bridge (riesgo de mezcla de estado bajo concurrencia extrema) | modules/bridge/esx/server.lua:5, modules/bridge/qb/server.lua:5, modules/bridge/qbox/server.lua:4 |

### 3.2 Mitigaciones aplicadas en esta auditoria

| ID | Estado | Cambio aplicado |
|:---:|:---|:---|
| H-031-01 | MITIGADO | server ahora usa source server-side y no acepta target por payload cliente |
| H-031-01 | MITIGADO | cliente dispara prism_pausemenu:disconnect sin argumentos manipulables |

Archivos modificados:
- quarantine/under-review/[resources]/prism_pausemenu/modules/server/main.lua
- quarantine/under-review/[resources]/prism_pausemenu/modules/client/nui.lua

### 3.3 Verificaciones tecnicas relevantes

- SQL: consultas parametrizadas con @param en bridges; no se observo concatenacion SQL explotable.
- Eventos/callbacks: superficie reducida y enfocada a lectura de datos de jugador + comando de test playtime.
- NUI: build React/Vite minificado; innerHTML/dangerouslySetInnerHTML provienen del runtime del framework.
- Dominios externos detectados en bundle/CSS: fonts.googleapis.com (real), react.dev/www.w3.org (texto de runtime/documentacion), discord.gg (openUrl del usuario), prism_pausemenu (endpoint NUI interno).

---

## 4) Decision final

VEREDICTO: LIMPIADO Y APROBADO (CON OBSERVACION MENOR)

Justificacion:
- Se corrigio el unico hallazgo de severidad ALTA identificado (evento de desconexion con confianza en payload cliente).
- No se detectaron patrones de malware/RAT ni criterios de rechazo automatico R-01..R-07.
- Riesgo residual se limita a hardening no bloqueante (fuente externa Google Fonts).

Ruta final aplicada:
- c:\admirales\script_ver\script_ver\approved\[standalone]\03_ECONOMY_COMMUNICATION\prism_pausemenu

---

## 5) Clasificacion de riesgo residual

- Criticos abiertos: 0
- Altos abiertos: 0
- Medios abiertos: 1
- Bajos abiertos: 1

Conclusión operacional:
- Recurso apto para promocion controlada a approved.

---

## 6) Dependencias requeridas

| Recurso | Requerido | Comentario |
|:---|:---:|:---|
| oxmysql | SI | Persistencia playtime |
| ox_lib | SI | callbacks/bridge QBox y utilidades |
| es_extended | Opcional | Soportado por bridge ESX |
| qb-core | Opcional | Soportado por bridge QB |
| qbx_core | Opcional | Soportado por bridge QBox |
| /assetpacks | SI | Declarado en manifest |

---

## 7) Recomendaciones operativas

1. (Medio no bloqueante) Localizar Google Fonts para evitar dependencia externa de CSS en runtime.
2. (Bajo) Convertir tabla global data a tabla local por request en bridges para aislar estado en callbacks.
3. Ejecutar smoke test: abrir/cerrar menu, open map/settings, disconnect, y lectura correcta de playtime en cada framework activo.
