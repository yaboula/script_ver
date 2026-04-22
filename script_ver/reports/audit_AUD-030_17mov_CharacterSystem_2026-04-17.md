# Reporte de Auditoria de Seguridad - AUD-030

## 17mov_CharacterSystem

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-030 |
| Recurso | 17mov_CharacterSystem |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\under-review\17mov_CharacterSystem |
| Version declarada | 1.0.99 |
| Manifiesto | fxmanifest.lua |
| Total de archivos inventariados | 5069 |
| Alcance de esta pasada | Protocolo completo (Nivel 1 + Nivel 2 + cierre) |

---

## 1) Inventario y hashes SHA-256

Evidencia generada:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-030_17mov_CharacterSystem_2026-04-17_inventory.tsv
- c:\admirales\script_ver\script_ver\reports\audit_AUD-030_17mov_CharacterSystem_2026-04-17_hashes.tsv

Muestra verificada:
- fxmanifest.lua -> D77DA1B35CFEE7480F66827008BFC01C0DCE1D29217CB67566855CD690F43772
- server/core.lua -> B970EF6E3A991AED9C9D5E90C9ECE2FC58FA4CED9E0DDB2CBE30AF7BF009C292
- server/functions.lua -> FFCB7241B7C2802120BDB3B99330BB32EC8DBBCAB94C81C3EAA1AEAF87EAAD70
- server/location.lua -> 7F3C9B58C8535C6E14C7C0DCA94A890500F06DA479FBECBD3AD0EBCF5434802F
- server/photos.lua -> 978C2090669570C35F9E4DF8EDFC15551DB97F79E1FAE6D3DADBA680D6131DB5
- server/selector.lua -> ECC2B2055ADE5514D22433D95F9A605A9E58CA6447CF008C015E3A0EBA066C24
- web/assets/index-DnAepNzs.js -> 32362D40248D8FF443C7968C78B38F6F85F70412E017BC131F375B43CFD08BA0
- web/assets/index-DmYTjsZA.css -> 385B16213050D0084ED2C8F7BC8E51C52EF702E5B80AB9D51901840DF22118A3
- web/index.html -> 1F87C5250C463B096CBA8CF6032213BFB6FCE5CEE4BDEB34DE11E4918AD76FF9

Verificacion de rechazo automatico R-01:
- Archivos binarios peligrosos (.exe/.dll/.bat/.ps1/.sh/.cmd/.vbs/.msi/.scr): 0

---

## 2) Nivel 1 - Escaneo automatizado

Evidencia:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-030_17mov_CharacterSystem_2026-04-17_level1_scan.txt

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest / PerformHttpRequestInternal | C-01/C-02 | 1 / 0 | Revisado (uso Discord API, no ejecucion remota) |
| load/loadstring/assert(load)/RunString | C-03/C-04/C-05/C-06 | 3 / 0 / 0 / 0 | Revisado (carga local de config de recursos) |
| string.char / secuencias hex | C-07/C-08 | 0 / 1 | Revisado (funcion base64 utilitaria) |
| os.execute/io.popen/io.open | C-09/C-10/C-11 | 0 / 0 / 3 | Revisado (acceso de archivos local y controlado) |
| debug.* | C-12 | 1 | Bajo impacto (traceback debug cliente) |
| IDs hardcodeados / IP hardcodeada | A-01/A-02/A-03/A-04 | placeholders/comentarios / 0 | Sin hallazgo explotable |
| RegisterCommand / RegisterNetEvent | A-05/A-06 | multiples | Revisado manualmente |
| GetConvar | A-08 | 1 | Revisado (mysql_connection_string para introspeccion) |
| ExecuteCommand | A-09 | 0 | OK |
| SQL concat pattern | M-01 | 1 coincidencia no SQL real | Sin inyeccion confirmada |
| innerHTML/eval/dangerouslySetInnerHTML/new Function | M-02/M-03/M-04 | multiples en bundle | Falso positivo de bundle web ofuscado/minificado |

Resultado Nivel 1:
- Sin indicadores de malware activo, RAT, auto-propagacion ni ejecucion de comandos del sistema operativo.
- Sin criterios de rechazo automatico R-01..R-07.

---

## 3) Nivel 2 - Revision manual profunda

### 3.1 Manifest y superficie de carga

Estado:
- Scripts server/client/shared declarados en manifest.
- server_script incluye @oxmysql/lib/MySQL.lua.
- ui_page apunta a web/index.html local.
- web/index.html carga assets locales (JS/CSS empaquetados).
- Existen referencias externas en frontend (Google Fonts en CSS y URL de YouTube en loadingscreen config), pero no se detecto carga de codigo remoto arbitrario fuera de librerias web conocidas.

### 3.2 Hallazgos y estado

| ID | Severidad | Estado | Archivo(s) | Detalle |
|:---:|:---:|:---|:---|:---|
| H-030-01 | ALTO | MITIGADO | server/photos.lua | Upload de fotos endurecido: control de permiso por framework, validacion de tipos, sanitizacion de nombre/modelo/drawable, limite por lote y limite de base64. |
| H-030-02 | MEDIO | MITIGADO | server/core.lua | Ingreso de callbacks endurecido con validacion de callbackName y responseIdentifier antes de ejecutar handlers registrados. |
| H-030-03 | MEDIO | MITIGADO | server/register.lua, server/selector.lua, server/skin.lua | Validacion de payloads en creacion/seleccion de personaje y cobro de tienda; ids, tipos y rangos validados en los puntos mas sensibles. |
| H-030-04 | BAJO | RESIDUAL | server/location.lua, client/functions.lua | Uso de load() para cargar configuraciones de recursos confiados (qb-apartments, ps-housing, ox_lib). Riesgo residual si recursos dependientes son comprometidos. |
| H-030-05 | BAJO | RESIDUAL | bridge/qb/server.lua, bridge/esx/server.lua | Eventos de guardar/borrar outfits sin rate limit ni tope de tamano de payload (riesgo de abuso/DB bloat por spam). |
| H-030-06 | BAJO | RESIDUAL | web/assets/index-DmYTjsZA.css, web/loadingscreen/config.json | Dependencias web externas operativas (fuentes y URL YouTube opcional). No se observo ejecucion remota de Lua ni vector directo de RCE. |

### 3.3 Analisis de eventos/callbacks server-side (resumen)

| Entrada | Source validado | Datos validados | Permisos | Veredicto |
|:---|:---:|:---:|:---:|:---|
| 17mov_Callbacks:GetResponse<ResourceName> | SI | SI (tipo/longitud basica) | N/A | Mitigado |
| 17mov_CharacterSystem:UploadPhotos | SI | SI | SI (admin/god o admin/superadmin) | Mitigado |
| 17mov_CharacterSystem:SelectCharacter | SI | SI | N/A | Mitigado |
| 17mov_CharacterSystem:CreateCharacter (callback) | SI | SI (nombre, fecha, sexo, altura, nacionalidad) | N/A | Mitigado |
| qb-clothes:saveOutfit / 17mov_CharacterSystem:SaveOutfit | SI | Parcial | N/A | Riesgo bajo residual (abuso por spam) |

### 3.4 Analisis SQL

Resultado:
- Predomina SQL parametrizado con placeholders.
- No se confirmo inyeccion SQL explotable en server/*.lua ni bridge/*/server.lua.
- El armado dinamico de consulta en selector.lua para INFORMATION_SCHEMA limita el nombre de BD a [A-Za-z0-9_] antes de interpolar.

### 3.5 Analisis NUI

Resultado:
- HTML principal sin script remoto directo.
- Hallazgos de innerHTML/dangerouslySetInnerHTML en web/assets/index-DnAepNzs.js corresponden a bundle frontend ofuscado/minificado.
- No se detecto vector de ejecucion de codigo Lua por NUI.

---

## 4) Resumen de hallazgos

| ID | Severidad | Categoria | Estado final |
|:---:|:---:|:---|:---|
| H-030-01 | ALTO | Upload endpoint sin controles fuertes | MITIGADO |
| H-030-02 | MEDIO | Validacion de ingreso de callbacks | MITIGADO |
| H-030-03 | MEDIO | Validacion de payloads criticos | MITIGADO |
| H-030-04 | BAJO | load() de configuraciones en recursos dependientes | RESIDUAL ACEPTADO |
| H-030-05 | BAJO | Sin rate limit/size cap en outfits bridge | RESIDUAL ACEPTADO |
| H-030-06 | BAJO | Dependencias web externas de baja criticidad | RESIDUAL ACEPTADO |

Riesgo residual abierto:
- BAJO: abuso por spam en endpoints de outfits.
- BAJO: superficie indirecta por load() sobre recursos dependientes.

---

## 5) Decision final

VEREDICTO: LIMPIADO Y APROBADO (CON OBSERVACIONES MENORES)

Justificacion:
- No se detectaron criterios de rechazo automatico.
- No se detecto ejecucion remota de codigo malicioso ni exfiltracion activa en el estado auditado.
- Los puntos de mayor riesgo en server ingress y upload quedaron endurecidos.
- Riesgos residuales son de severidad BAJA y aceptables para promocion controlada.

Ruta final aplicada:
- c:\admirales\script_ver\script_ver\approved\[qb]\01_IDENTITY & SPAWN\17mov_CharacterSystem

---

## 6) Dependencias requeridas

| Recurso | Requerido | Comentario |
|:---|:---:|:---|
| oxmysql | SI | Requerido por server scripts |
| qb-core | Opcional | Soportado por autodeteccion |
| es_extended | Opcional | Soportado por autodeteccion |
| qbx_core + ox_lib | Opcional | Ruta QBCore/QBX usa carga de ox_lib |
| qb-apartments o ps-housing | Opcional | Dependiendo de configuracion de apartamentos |
| /assetpacks | SI | Declarado en manifest |

---

## 7) Notas operativas

- Recomendado agregar rate limit en eventos de guardado de outfits para mitigar spam de escritura.
- Mantener configs/Discord.lua con token fuera de repositorios publicos y con rotacion periodica.
- Si se desactiva YouTube en loadingscreen, mantener YouTube.Enable en false (estado actual).
- Ejecutar smoke test de flujo completo: selector, creacion personaje, spawn, tienda de ropa, guardado de outfit, comando relog.
