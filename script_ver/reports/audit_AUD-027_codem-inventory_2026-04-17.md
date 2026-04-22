# Reporte de Auditoria de Seguridad - AUD-027

## codem-inventory

| Campo | Valor |
|:---|:---|
| ID Auditoria | AUD-027 |
| Recurso | codem-inventory |
| Fecha | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Ruta auditada | c:\admirales\script_ver\script_ver\approved\[qb]\03_ECONOMY_COMMUNICATION\codem-inventory |
| Version declarada | 2.5 |
| Manifiesto | fxmanifest.lua |
| Total de archivos | 172 |
| Alcance de esta pasada | Nivel 1 + Nivel 2 + hardening final + recertificacion |

---

## 1) Inventario y hashes SHA-256

Inventario completo:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-027_codem-inventory_2026-04-17_hashes.tsv

Muestra verificada:
- fxmanifest.lua -> 5E5F6CF625C1A3270E11685B3A61FF4884AD38F8822B79727971595F15D8709C
- editable/editableserver.lua -> B95EE5B6507F928CCE4C6A6FF956C387892E566639848668324E4B7F0D903E1A
- server/weapon_server.lua -> DD3C3A8FF84DB3FA0957EADBB4B5B1EDE9C1401360C06CFEE3E6BC366D78E9A8
- client/main.lua -> 0BE60F31F9B43D821FB4D3B62442C80D9E99FECC1C06779BAC055A83DA437485
- html/index.html -> 710783EF72781E3F3D574AD391F6C12CDEA7E8E7FC0AC80AB2DDCE5507650297

---

## 2) Nivel 1 - Escaneo automatizado

| Patron | ID | Hallazgos | Veredicto |
|:---|:---:|:---:|:---|
| PerformHttpRequest | C-01 | 6 | Revisado manualmente (version check + webhooks + comandos admin internos) |
| PerformHttpRequestInternal | C-02 | 0 | OK |
| load/loadstring/assert(load)/RunString | C-03/C-04/C-05/C-06 | 4 | Revisado manualmente (load local controlado y script de migracion) |
| os.execute/io.popen/io.open/ExecuteCommand | C-09/C-10/C-11/A-09 | 0 | OK |
| string.char ofuscacion | C-08 | 0 | OK |
| RegisterNetEvent/RegisterServerEvent/CreateCallback | A-05/A-06 | 154 | Superficie alta, revisada en Nivel 2 |
| Binarios peligrosos (.exe/.dll/.bat/.ps1/.sh/.cmd/.vbs/.msi/.scr) | R-01 | 0 | OK |

Resultado Nivel 1:
- Sin indicadores de malware/RAT ni criterios de rechazo automatico R-01..R-07.
- Superficie alta de eventos validada en Nivel 2 con hardening aplicado.

---

## 3) Nivel 2 - Revision manual profunda

### 3.1 Estado final de hallazgos

| ID | Severidad inicial | Estado final | Evidencia |
|:---:|:---:|:---|:---|
| H-027-01 | CRITICO | MITIGADO | editable/editableserver.lua:158, editable/editableserver.lua:218, editable/editableserver.lua:226, editable/editableserver.lua:251 |
| H-027-02 | ALTO | MITIGADO | editable/editableserver.lua:445, editable/editableserver.lua:493, editable/editableserver.lua:499, editable/editableserver.lua:519 |
| H-027-03 | ALTO | MITIGADO | server/weapon_server.lua:17, server/weapon_server.lua:75, server/weapon_server.lua:120 |
| H-027-04 | MEDIO | MITIGADO | html/index.html:10, html/index.html:11, html/index.html:1457, html/index.html:1458, fxmanifest.lua:46 |
| H-027-05 | MEDIO | MITIGADO | fxmanifest.lua (unico manifiesto activo; copia anidada removida) |
| H-027-06 | BAJO (defensivo) | APLICADO | editable/editableserver.lua:463 |

### 3.2 Observaciones de contexto

- El uso de load en server/qb_items_import.lua:60 ejecuta contenido local de qb-core/shared/items.lua en entorno controlado para import de items; no es ejecucion remota.
- PerformHttpRequest detectado corresponde a:
  - chequeo de version (editable/utilityserver.lua)
  - webhooks (editable/discordlog.lua)
- En migrate/itemconvert.lua existe logica de migracion con loadstring/load y SQL concatenado para comando administrativo puntual; no forma parte del flujo normal de gameplay.
- No se encontraron primitivas OS peligrosas ni binarios ejecutables bloqueados.

---

## 4) Decision final

VEREDICTO: COMPLETO, SEGURO PARA OPERACION Y DOCUMENTADO

Justificacion:
- Mitigaciones criticas y altas aplicadas y verificadas en codigo server-side.
- No aplica rechazo por malware (R-01..R-07 no activados).
- Hallazgos medios cerrados (CDNs externos localizados y duplicado anidado removido).
- Documentacion y hashes actualizados al estado final consolidado.

Estado recomendado de flujo:
- Mantener en approved (estado cerrado).

Ruta final aplicada:
- c:\admirales\script_ver\script_ver\approved\[qb]\03_ECONOMY_COMMUNICATION\codem-inventory

Artefactos actualizados:
- c:\admirales\script_ver\script_ver\reports\audit_AUD-027_codem-inventory_2026-04-17.md
- c:\admirales\script_ver\script_ver\reports\audit_AUD-027_codem-inventory_2026-04-17_hashes.tsv

## 5) Clasificacion de riesgo residual

- Criticos abiertos: 0
- Altos abiertos: 0
- Medios abiertos: 0
- Bajos abiertos: 0

---

Conclusion operacional:
- Cierre completo de AUD-027. Recurso listo para operacion y con documentacion actualizada al estado final.

## 6) Recomendaciones operativas no bloqueantes

1. Mantener rotacion y proteccion de webhooks de Discord en editable/discordlog.lua.
2. Si no se usa version checker, desactivar Config.VersionChecker para reducir salida HTTP no esencial.
3. Ejecutar smoke test funcional tras reinicio: inventario, craft, throw weapon, municion, stash/trunk y NUI.
