# Reporte de Auditoria de Seguridad - AUD-023

## JustNotify

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-023 |
| Recurso | JustNotify |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Origen declarado | paquete entrante en queue/incoming (sin verificacion de oficialidad por instruccion del usuario) |
| Version declarada | N/D |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\incoming\JustNotify\JustNotify |
| Total de archivos | 16 |

---

## 1) Inventario y hashes SHA-256

- Inventario completo con hash SHA-256:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-023_JustNotify_2026-04-17_hashes.tsv
- Muestra verificada de hashes:
  - fxmanifest.lua -> 77D287925F69FB51DAD4AD2422ABB3A5518E8FEFB1DE56F03DC4847279F57DD7
  - client.lua -> A1CF40D795A09C1A7B75E3CD269F667E489B8D8C3C7B943C23D630CF5402F027
  - web/build/static/js/main.d37c2e56.js -> 63C7AA3D985D8B2F27CAEC3D634087E997FBC8259B85FA6E48A73AAE48856665

---

## 2) Nivel 1 - Escaneo automatizado

| Patron | Resultado |
|:---|:---|
| PerformHttpRequest / PerformHttpRequestInternal | 0 |
| loadstring / assert(load) / RunString | 0 |
| os.execute / io.popen / io.open | 0 |
| debug.* en Lua de recurso | 0 |
| Binarios peligrosos (.exe/.dll/.bat/.ps1/.sh/.cmd/.vbs/.msi/.scr) | 0 |

Veredicto de escaneo automatico: OK.

---

## 3) Nivel 2 - Revision manual

### 3.1 Manifiesto

- fxmanifest.lua valido.
- Escrow detectado (archivo .fxap + escrow_ignore para config/client).
- Dependency declarada: /assetpacks (interna FiveM).

### 3.2 Hallazgos

| ID | Severidad | Hallazgo | Estado |
|:---:|:---:|:---|:---|
| H-023-01 | MEDIO | NUI carga CDNs remotos (font-awesome y animejs) en web/build/index.html | Abierto (hardening recomendado) |
| H-023-02 | BAJO | Config.Debug = true por defecto, habilita comandos de prueba | Abierto (se ajusta en instalacion) |

Detalles H-023-01:
- URLs externas detectadas:
  - https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css
  - https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js

Impacto:
- No implica malware por si mismo.
- Aumenta superficie de dependencia externa en NUI.

Recomendacion:
- Vendor local de librerias o control de version/hash cuando sea posible.

---

## 4) Decision final

VEREDICTO: APROBADO (sin limpieza obligatoria)

Razon:
- Sin indicadores de ejecucion remota server-side ni binarios peligrosos.
- Hallazgos son de hardening/operacion y no bloquean despliegue en sandbox.

Destino recomendado:
- approved/[standalone]/03_ECONOMY_COMMUNICATION/JustNotify

---

## 5) Dependencias declaradas

- /assetpacks (dependency interna de FiveM)

## 6) Recomendaciones para instalacion

1. Configurar `Config.Debug = false` en produccion/sandbox operativo.
2. Desplegar en [standalone] y validar NUI en cliente.
3. Revisar F8 por errores de carga de CDN en runtime.
