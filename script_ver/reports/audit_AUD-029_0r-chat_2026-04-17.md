# Reporte de Auditoria de Seguridad - AUD-029

## 0r-chat

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-029 |
| Recurso | 0r-chat |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\under-review\0r-chat |
| Version declarada | 3.1.0 |
| Manifiesto | fxmanifest.lua |
| Total de archivos (post-limpieza) | 27 |
| Alcance de esta pasada | Protocolo completo (Nivel 1 + Nivel 2 + limpieza + re-auditoria) |

---

## 1) Inventario y hashes SHA-256

Evidencia generada:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-029_0r-chat_2026-04-17_inventory.tsv
- c:\admirales\script_ver\script_ver\reports\audit_AUD-029_0r-chat_2026-04-17_hashes.tsv

Muestra verificada (post-limpieza):
- fxmanifest.lua -> 6ECD64AB2DF13E495873C0F930E0FE444B10ADE4BCBD27A60D1D418679E2A8F1
- server/events.lua -> B049B9A3D1A9A602078A675E18F4047ED1FE74EEE1DC0F0885CE16146ABA7D6C
- server/commands.lua -> D7C52DDD3DF919B6BC4AD860DDCAD90DC4244DF9298A5016DD9A80449A31964D
- client/nui.lua -> 44CA59052577E216488769DA21F63DD16E9639621C79EE21FFE89803CFEDD8C9
- ui/build/index.html -> 2678B3BEE036CE3B494270E8C80170E33D157FF23E6B5F7D69B6C0EEE9411181
- ui/build/assets/index-kauAbiuW.js -> 17C9998A98AD5D63AD1523AE12ABD36E94E3611404E1E8B2DF708A6CADB95920

Verificacion de rechazo automatico R-01:
- Archivos binarios peligrosos (.exe/.dll/.bat/.ps1/.sh/.cmd/.vbs/.msi/.scr): 0

---

## 2) Nivel 1 - Escaneo automatizado (post-limpieza)

Evidencia de escaneo:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-029_0r-chat_2026-04-17_level1_scan.txt

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest / PerformHttpRequestInternal | C-01/C-02 | 0 | OK |
| load/loadstring/assert(load)/RunString | C-03/C-04/C-05/C-06 | 0 | OK |
| string.char / secuencias hex | C-07/C-08 | 0 | OK |
| os.execute/io.popen/io.open | C-09/C-10/C-11 | 0 | OK |
| debug.* | C-12 | 0 | OK |
| IDs hardcodeados / IP hardcodeada | A-01/A-02/A-03/A-04 | 0 | OK |
| RegisterCommand / RegisterNetEvent | A-05/A-06 | multiples | Revisado manualmente |
| GetConvar | A-08 | 0 | OK |
| ExecuteCommand | A-09 | 1 | Revisado (cliente local/NUI) |
| SQL concat / APIs SQL | M-01 | 0 | No aplica |
| innerHTML/eval/dangerouslySetInnerHTML/new Function | M-02/M-03/M-04 | multiples en bundle | Falso positivo (runtime/framework) |
| CreateThread | M-05 | 5 | Revisado, sin loops sin Wait |
| URLs NUI externas | NUI | 0 cargas remotas de script/css | OK |

Resultado Nivel 1:
- Sin indicadores de malware, RAT, exfiltracion ni ejecucion de comandos del sistema operativo.
- Sin criterios de rechazo automatico R-01..R-07.

---

## 3) Nivel 2 - Revision manual profunda (post-limpieza)

### 3.1 Auditoria de manifiesto (fxmanifest.lua)

Estado:
- `shared_script "shared/**/*"` fue reemplazado por declaracion explicita de archivos compartidos.
- `client_scripts` y `server_scripts` permanecen explicitos.
- `ui_page` local en `ui/build/index.html`.
- No hay cargas remotas de JS/CSS en `index.html`.

### 3.2 Hallazgos y remediaciones aplicadas

| ID | Severidad inicial | Estado | Archivo(s) | Remediacion aplicada |
|:---:|:---:|:---|:---|:---|
| H-029-01 | ALTO | MITIGADO | server/events.lua | Se endurecio el entrypoint de callbacks cliente-servidor con allowlist (`CLIENT_CALLBACK_ALLOWLIST`) y validacion de tipo de key para impedir invocacion de callbacks internos no expuestos al cliente. |
| H-029-02 | ALTO | MITIGADO | server/events.lua | `0r-chat:sendJobMessages` ahora exige estructura valida, filtros obligatorios (job/jobs) y validaciones de longitud/tipos para evitar abuso de broadcast no autenticado via callback interno. |
| H-029-03 | MEDIO | MITIGADO | server/events.lua | Se agregaron validaciones/sanitizacion en callbacks expuestos a cliente: `registerRPText`, `RollTheDice`, `RPS`, `updateNameValue`, `updateMeDoPP`. |
| H-029-04 | MEDIO | MITIGADO | fxmanifest.lua | Eliminado wildcard de scripts compartidos (F-06). Ahora listado explicito: `shared/config.lua`, `shared/utils.lua`. |
| H-029-05 | BAJO | MITIGADO | server/events.lua | Corregido cobro de Yellow Pages en rama QBCore para usar cuenta `bank`, consistente con validacion previa de saldo. |
| H-029-06 | BAJO | MITIGADO | server/events.lua | Corregida referencia de variable en `sendBalanceInfoMessage` (uso de `xPlayer.PlayerData` en QBCore). |

### 3.3 Analisis de eventos server-side

| # | Evento | Source validado | Datos validados (type check) | Permisos verificados | Rate-limited | Veredicto |
|:---:|:---|:---:|:---:|:---:|:---:|:---|
| 1 | chat:init / chat:addTemplate / chat:addMessage / chat:addSuggestion / chat:removeSuggestion / _chat:messageEntered / chat:clear / __cfx_internal:commandFallback | N/A (declaracion) | N/A | N/A | N/A | Informativo |
| 2 | 0r-chat:Server:SyncIsWriting | SI | NO (sin check explicito de `state`) | N/A | NO | Riesgo bajo residual (spam visual posible) |
| 3 | 0r-chat:Server:HandleCallback | SI | SI (allowlist + key type check) | Parcial (segun callback) | NO | Mitigado |

### 3.4 Analisis de callbacks server-side (Koci.Server:RegisterServerCallback)

Resumen:
- Callbacks de uso cliente ahora restringidos por allowlist y validaciones de payload.
- Callbacks de uso interno del servidor (mensajeria de trabajo/admin) ya no son invocables directamente desde cliente via router.
- No se detectaron callbacks que devuelvan datos de DB sensibles fuera del jugador solicitante.

### 3.5 Analisis SQL

| # | Query | Archivo:Linea | Parametrizada |
|:---:|:---|:---:|:---:|
| 1 | No se detectaron queries SQL en el recurso auditado | N/A | N/A |

### 3.6 Analisis NUI

Estado:
- `ui/build/index.html` solo referencia assets locales (`./assets/index-kauAbiuW.js`, `./assets/index-2DBoaqkO.css`).
- No hay `<script src="https://...">` externos en HTML.
- Hallazgos de `dangerouslySetInnerHTML`/`innerHTML` en `index-kauAbiuW.js` corresponden a codigo minificado de framework/runtime y no a inyeccion activa del recurso auditado.
- Existe solicitud saliente a `https://noembed.com/embed` para metadata de musica (riesgo operacional bajo; no implica carga remota de codigo ejecutable).

---

## 4) Resumen de hallazgos

| ID | Severidad | Categoria | Estado final |
|:---:|:---:|:---|:---|
| H-029-01 | ALTO | Callback ingress sin control de exposicion | MITIGADO |
| H-029-02 | ALTO | Callback interno de broadcast sin filtros obligatorios | MITIGADO |
| H-029-03 | MEDIO | Falta de validacion en payloads de callbacks cliente | MITIGADO |
| H-029-04 | MEDIO | Wildcard en scripts compartidos (`fxmanifest`) | MITIGADO |
| H-029-05 | BAJO | Inconsistencia de cuenta en cobro Yellow Pages (QBCore) | MITIGADO |
| H-029-06 | BAJO | Referencia invalida en callback de balance (QBCore) | MITIGADO |

Riesgo residual abierto:
- BAJO: evento `0r-chat:Server:SyncIsWriting` no tiene rate limit explicito.

---

## 5) Decision final

VEREDICTO: LIMPIADO Y APROBADO

Justificacion:
- No hay hallazgos criticos ni criterios R-01..R-07.
- Los hallazgos ALTO/MEDIO detectados fueron mitigados en codigo y re-auditados.
- El recurso queda apto para promocion con observacion menor de rate limiting opcional.

Ruta final recomendada:
- c:\admirales\script_ver\script_ver\approved\[standalone]\03_ECONOMY_COMMUNICATION\0r-chat

---

## 6) Cambios aplicados durante auditoria

1. Endurecimiento del router de callbacks server-side con allowlist.
2. Validaciones y sanitizacion de payloads en callbacks expuestos al cliente.
3. Endurecimiento de `sendJobMessages` (filtros obligatorios y validacion de estructura).
4. Eliminacion de wildcard en scripts compartidos del `fxmanifest.lua`.
5. Correcciones de consistencia/estabilidad en rama QBCore (`YellowPages` y `sendBalanceInfoMessage`).

---

## 7) Dependencias requeridas

| Recurso | Requerido | Comentario |
|:---|:---:|:---|
| qb-core | Opcional | Soportado por deteccion de framework |
| es_extended | Opcional | Soportado por deteccion de framework |
| xsound | SI | Utilizado para reproduccion de audio |
| /assetpacks | SI | Declarado en manifiesto |

---

## 8) Notas operativas

- Recomendado smoke test in-game de: `ooc`, `me`, `do`, `darkchat`, `img`, `playmusic`, `yellowpages`, `whisper`.
- Verificar permisos ACE para comandos administrativos (`announce`, `adminwhisper`, `clearall`).
- Si se desea hardening adicional, agregar rate limit en `0r-chat:Server:SyncIsWriting`.
