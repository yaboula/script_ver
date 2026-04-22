# Reporte de Auditoria de Seguridad - AUD-022

## xsound

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-022 |
| Recurso | xsound |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Origen declarado | github.com/Xogy/xsound |
| Version declarada | 1.5.1 |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\incoming\xsound\xsound |
| Total de archivos | 26 |

---

## 1) Inventario y hashes SHA-256

- Inventario completo con hash SHA-256:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-022_xsound_2026-04-17_hashes.tsv
- Muestra verificada de hashes:
  - fxmanifest.lua -> 2CAF0097CB7593C9BC26E371905CA3EB456937FF6E4AE70D7A672C60772B5ED9
  - client/main.lua -> 2B0F5B749CA2ED29695F25FE87837A94CBAA3A85B644D82373037569D685B13C
  - server/exports/play.lua -> EB7B01BC70E4768F642226E94277CFAF29A03CE07218616F84342E865AEBF74A

---

## 2) Nivel 1 - Escaneo automatizado

| Patron | Resultado |
|:---|:---|
| PerformHttpRequest / PerformHttpRequestInternal | 0 matches |
| loadstring / assert(load) / RunString | 0 matches |
| os.execute / io.popen / io.open | 0 matches |
| debug.* | 0 matches |
| Binarios peligrosos (.exe/.dll/.bat/.ps1/.sh/.cmd/.vbs/.msi/.scr) | 0 archivos |

Veredicto de escaneo automatico: OK (sin indicadores de ejecucion remota o binarios peligrosos).

---

## 3) Nivel 2 - Revision manual

### 3.1 Licencia

- license.txt indica licencia MIT.
- Recurso abierto y gratuito para uso/modificacion bajo terminos MIT.

### 3.2 Manifiesto

- fxmanifest.lua valido.
- Sin dependencias obligatorias adicionales declaradas.

### 3.3 Hallazgos de hardening

| ID | Severidad | Hallazgo | Estado |
|:---:|:---:|:---|:---|
| H-022-01 | MEDIO | html/index.html carga JS remoto desde CDNs y YouTube iframe API | Abierto (hardening recomendado) |
| H-022-02 | BAJO | Referencia a ./scripts/config.js en html/index.html sin archivo presente en paquete | Abierto (validacion funcional recomendada) |

Detalle H-022-01:
- Scripts remotos detectados:
  - https://cdnjs.cloudflare.com/ajax/libs/howler/2.1.1/howler.min.js
  - https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js
  - https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.2.3/purify.js
  - https://s.ytimg.com/yts/jsbin/www-widgetapi-vflJJaNgk/www-widgetapi.js
  - https://www.youtube.com/iframe_api

Impacto:
- No es malware por si mismo.
- Incrementa superficie de supply-chain en NUI por carga de terceros en runtime.

Recomendacion:
- Hardening opcional: vendor local y pinning de versiones/hash.

---

## 4) Decision final

VEREDICTO: APROBADO (sin limpieza obligatoria)

Razon:
- Licencia MIT valida (open source/free).
- Sin patrones de ejecucion remota server-side ni binarios peligrosos.
- Hallazgos presentes son de hardening y no bloquean despliegue en sandbox.

Destino recomendado:
- approved/[standalone]/03_ECONOMY_COMMUNICATION/xsound

---

## 5) Dependencias declaradas

- Ninguna en fxmanifest.

## 6) Recomendaciones de instalacion

1. Instalar xsound antes de 0r-hud-v3.
2. Asegurar orden en server.cfg: ensure xsound antes de cargar 0r-hud-v3.
3. Probar NUI/sonido in-game y revisar F8 por 404 de config.js.
