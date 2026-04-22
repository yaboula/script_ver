# Reporte de Auditoria de Seguridad - AUD-026

## prism_banking

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-026 |
| Recurso | prism_banking |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\quarantine\incoming\[resources]\prism_banking |
| Version declarada | 1.0.5 |
| Manifiesto | fxmanifest.lua |
| Total de archivos | 28 |
| Alcance de esta pasada | Nivel 1 + Nivel 2 + limpieza y revalidacion |

---

## 1) Inventario y hashes SHA-256

Inventario completo:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-026_prism_banking_2026-04-17_hashes.tsv

Muestra verificada:
- fxmanifest.lua -> E7FC55D17979601E4F8173C374C66001B209397B54E1C2EB129A8927793EE7FB
- server/sv_functions.lua -> 6D6F7878AD7973FC838A3CBFB0AEBDCAA3771E3947A0BB595772436516162F91
- server/sv_callbacks.lua -> 5A9EFFEC22F3EC6A6D5E300CEFCFABA355A8FC4209FC4349AE365DB97037CE03

---

## 2) Nivel 1 - Escaneo automatizado

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest | C-01 | 3 | Revisado manualmente (uso funcional: webhooks + perfil steam/discord) |
| PerformHttpRequestInternal | C-02 | 0 | OK |
| load/loadstring/assert(load)/RunString | C-03/C-04/C-05/C-06 | 0 | OK |
| os.execute/io.popen/io.open | C-09/C-10/C-11 | 0 | OK |
| RegisterNetEvent/CreateCallback/RegisterServerCallback | A-05/A-06 | 24 | Requiere revision manual |
| Wildcards en manifiesto | M-04 | 4 | Hardening recomendado |
| Binarios peligrosos (.exe/.dll/.bat/.ps1/.sh/.cmd/.vbs/.msi/.scr) | R-01 | 0 | OK |

Resultado Nivel 1:
- Sin indicadores de malware ni criterios de rechazo automatico R-01..R-07.
- Se requiere Nivel 2 por superficie de callbacks/eventos financieros.

---

## 3) Nivel 2 - Revision manual (antes de limpieza)

### Hallazgos confirmados

| ID | Severidad | Hallazgo | Estado inicial |
|:---:|:---:|:---|:---|
| H-026-01 | CRITICO | Confianza en metadata de cuenta enviada por cliente en transacciones (riesgo de bypass de reglas) | Abierto |
| H-026-02 | ALTO | Flujo ATM con validacion insuficiente de acceso en getAtmAccounts y bug de uso de parametro | Abierto |
| H-026-03 | ALTO | verifyAtmPin sin rate-limit/lockout (riesgo de fuerza bruta de PIN) | Abierto |
| H-026-04 | MEDIO | Wildcards en fxmanifest (shared/client/server/files) | Abierto |

Descripcion tecnica resumida:
- H-026-01: el callback de transacciones aceptaba estructura de cuenta enviada por cliente y tomaba decisiones de negocio con esos campos.
- H-026-02: getAtmAccounts tenia validacion incompleta para cuenta solicitada y defectos en manejo de input.
- H-026-03: no habia limite de intentos PIN por ventana temporal ni bloqueo temporal.

---

## 4) Limpieza aplicada en esta pasada

Archivos corregidos:
- c:\admirales\script_ver\script_ver\quarantine\incoming\[resources]\prism_banking\server\sv_functions.lua
- c:\admirales\script_ver\script_ver\quarantine\incoming\[resources]\prism_banking\server\sv_callbacks.lua

Cambios de seguridad implementados:
1. Endurecimiento server-authoritative de transacciones:
- Rehidratacion de cuenta desde DB por accountNumber en servidor.
- Bloqueo de operaciones que no correspondan a acceso validado.
- Restriccion de sesion de tarjeta verificada a retiro ATM unicamente.

2. Endurecimiento ATM:
- Validacion robusta de acceso en getAtmAccounts.
- Rate-limit de PIN con ventana temporal y lockout.
- Sesion temporal de acceso por tarjeta verificada tras PIN correcto.

3. Proteccion de datos sensibles:
- Sanitizacion de payloads de cuentas hacia cliente para excluir pin.

Validacion tecnica post-fix:
- Sin errores reportados por analisis del workspace en ambos archivos corregidos.

---

## 5) Estado de hallazgos tras limpieza

| ID | Severidad | Estado final |
|:---:|:---:|:---|
| H-026-01 | CRITICO | Remediado |
| H-026-02 | ALTO | Remediado |
| H-026-03 | ALTO | Remediado |
| H-026-04 | MEDIO | Abierto (hardening opcional, no bloqueante) |

Conteo final:
- Criticos abiertos: 0
- Altos abiertos: 0
- Medios abiertos: 1
- Bajos abiertos: 0

---

## 6) Decision final

VEREDICTO: LIMPIADO Y APROBADO

Justificacion:
- Se cerraron los hallazgos bloqueantes de seguridad (critico/altos).
- No se observaron patrones de ejecucion remota maliciosa, binarios peligrosos ni primitivas OS peligrosas.
- Permanece un hallazgo medio de hardening en manifiesto (wildcards), no bloqueante para aprobacion.

Destino recomendado:
- c:\admirales\script_ver\script_ver\approved\[qb]\prism_banking

---

## 7) Recomendaciones operativas

1. Endurecer fxmanifest reemplazando wildcards por listas explicitas de archivos criticos.
2. Configurar credenciales reales en server/sv_customize.lua y webhooks solo via secrets/cvars, no en texto plano.
3. Ejecutar smoke test funcional en servidor de prueba:
   - deposito/retiro/transferencia
   - flujo ATM con tarjeta robada on/off
   - nominees (agregar/quitar/consulta)
