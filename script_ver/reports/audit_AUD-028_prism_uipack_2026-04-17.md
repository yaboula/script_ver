# Reporte de Auditoria de Seguridad - AUD-028

## prism_uipack

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-028 |
| Recurso | prism_uipack |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\under-review\prism_uipack |
| Version declarada | 1.2.1 |
| Manifiesto | fxmanifest.lua |
| Total de archivos (post-limpieza) | 49 |
| Alcance de esta pasada | Protocolo completo (Nivel 1 + Nivel 2 + limpieza + re-auditoria) |

---

## 1) Inventario y hashes SHA-256

Inventario completo:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-028_prism_uipack_2026-04-17_hashes.tsv

Muestra verificada (post-limpieza):
- fxmanifest.lua -> 812AABB59E2798229CC537683791EBC9193BF14A3F8B322E18ACB43B2251F8A4
- main.lua -> 99CCD1AC0903E8520897BE2606041142F1426806FE581B849379D1473FDB9245
- config_init.lua -> 884EBE1BC09CCBF52253CA58B059BAE6475469A8947092E27D1319D61CAE6B0C
- web/build/index.html -> 0F2140C939D58C590885A545ADEE1C6CAF10DC8124BCE79258AA8BEC949D4253
- web/build/assets/index-Dk9MkoH6.js -> C3AA75A3881809515273F9AE52AF534635E4CA06BD3F06FF7873CD9739CC4864
- web/build/assets/index-BgkLwDpx.css -> 798E959AB22245A7020344E687251B9E38B88354E9825DE47FA57410C0E42AC3

Verificacion de rechazo automatico R-01:
- Archivos binarios peligrosos (.exe/.dll/.bat/.ps1/.sh/.cmd/.vbs/.msi/.scr): 0

---

## 2) Nivel 1 - Escaneo automatizado (post-limpieza)

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest / PerformHttpRequestInternal | C-01/C-02 | 0 | OK |
| load/loadstring/assert(load)/RunString | C-03/C-04/C-05/C-06 | 0 | OK |
| string.char / secuencias hex | C-07/C-08 | 0 | OK |
| os.execute/io.popen/io.open | C-09/C-10/C-11 | 0 | OK |
| debug.* | C-12 | 0 | OK |
| IDs hardcodeados (steam/discord/license/ip) | A-01/A-02/A-03/A-04 | 0 | OK |
| RegisterCommand | A-05 | 2 | Revisado (keybind client-side) |
| RegisterNetEvent/AddEventHandler | A-06 | 2 | Revisado (client-side) |
| GetConvar/GetConvarInt | A-08 | 15 | Revisado (config visual/UI) |
| ExecuteCommand | A-09 | 0 | OK |
| SQL (MySQL/oxmysql/queries) | M-01 | 0 | No aplica |
| innerHTML/eval/new Function/document.write | M-02/M-03 | 0 | OK |
| URLs externas en index/css NUI | NUI | 0 | OK |

Resultado Nivel 1:
- Sin indicadores de malware, RAT, exfiltracion ni ejecucion de comandos OS.
- Sin dependencias NUI remotas activas en index/css post-limpieza.

---

## 3) Nivel 2 - Revision manual profunda (post-limpieza)

### 3.1 Auditoria de manifiesto (fxmanifest.lua)

Estado:
- `client_scripts` ahora declarados de forma explicita (sin wildcard).
- `files` ahora declarados de forma explicita (sin wildcard).
- `ui_page` local y autocontenida en `web/build/index.html`.
- No hay `server_scripts` en este recurso (superficie server-side no aplica).

### 3.2 Hallazgos iniciales y estado tras remediacion

| ID | Severidad inicial | Estado | Remediacion aplicada |
|:---:|:---:|:---|:---|
| H-028-01 | ALTO | MITIGADO | Eliminada carga remota no confiable en NUI; `index.html` ahora usa solo assets locales. |
| H-028-02 | ALTO | MITIGADO | Build NUI reconstruido con artefactos completos y coherentes (JS/CSS locales existentes). |
| H-028-03 | MEDIO | MITIGADO | Wildcards removidos en `fxmanifest.lua`, reemplazados por listado explicito. |
| H-028-04 | MEDIO | MITIGADO | Referencias invalidas de manifest/iconos desaparecen con build limpio; `index.html` saneado. |

### 3.3 Analisis de eventos/callbacks server-side

- `server_scripts` declarados: 0
- `RegisterNetEvent` server-side: 0
- `CreateCallback` server-side: 0

Conclusion:
- No hay superficie server-side en este recurso.
- El riesgo principal estaba en NUI/build y fue mitigado.

### 3.4 Analisis SQL

- Consultas SQL detectadas en el recurso: 0
- Riesgo SQL injection dentro del recurso: no aplica

### 3.5 Analisis NUI

Estado post-limpieza:
- `web/build/index.html` referencia solo:
  - `./assets/index-Dk9MkoH6.js`
  - `./assets/index-BgkLwDpx.css`
- Sin `<script src="https://...">` externos en index.
- Artefactos core del build presentes y hasheados.

---

## 4) Decision final

VEREDICTO: APROBADO CON OBSERVACIONES

Justificacion:
- Los hallazgos ALTOS y MEDIOS detectados en la pasada inicial fueron mitigados.
- El recurso queda autocontenido (sin dependencia remota NUI en index/css) y con manifiesto endurecido.
- No hay indicadores de malware ni criterios de rechazo automatico R-01..R-07.

Observaciones operativas:
- Se recomienda smoke test in-game de todos los componentes UI (menu, radial, progress, dialog, notify) tras promocion.

Estado recomendado de flujo:
- Promovido a `approved/[standalone]/03_ECONOMY_COMMUNICATION/prism_uipack`.

---

## 5) Cambios de limpieza aplicados

1. Build NUI reemplazado por build local confiable y completo (origen interno verificado de recurso aprobado).
2. `web/build/index.html` saneado para evitar referencias residuales a assets inexistentes.
3. `fxmanifest.lua` endurecido con declaraciones explicitas (sin wildcards).
4. `main.lua` y `config_init.lua` ajustados para compatibilidad de configuracion (`primaryShade` + fallback `ox:*`).
5. Backup forense del build previo movido fuera del recurso a:
   - c:\admirales\script_ver\script_ver\reports\AUD-028_artifacts\prism_uipack_build_backup_2026-04-17

---

## 6) Clasificacion de riesgo residual

- Criticos abiertos: 0
- Altos abiertos: 0
- Medios abiertos: 0
- Bajos abiertos: 1 (observacion de QA funcional post-promocion)

Conclusion operacional:
- Apto para promocion a approved con observacion de validacion funcional en entorno de juego.
