# Notas de Auditoria - codem-inventory

## Informacion General

| Campo | Valor |
|:---|:---|
| Fecha de Auditoria | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Estado | APROBADO (Cierre completo) |
| ID Auditoria | AUD-027 |
| Version del recurso | 2.5 |
| Ruta auditada | c:\admirales\script_ver\script_ver\approved\[qb]\03_ECONOMY_COMMUNICATION\codem-inventory |

## Dependencias Requeridas

- oxmysql
- qb-core
- progressbar
- /onesync (entorno)
- /server:4752 (build minima)
- /assetpacks

## Cambios Realizados Durante Auditoria

- Mitigaciones aplicadas y verificadas en servidor:
  - editable/editableserver.lua
  - server/weapon_server.lua
  - fxmanifest.lua
  - html/index.html
- Recertificacion final completada en AUD-027.
- Hashes SHA-256 consolidados en:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-027_codem-inventory_2026-04-17_hashes.tsv
- Reporte de auditoria consolidado en:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-027_codem-inventory_2026-04-17.md

## Hallazgos Relevantes (Estado Final)

- H-027-01 CRITICO -> MITIGADO
- H-027-02 ALTO -> MITIGADO
- H-027-03 ALTO -> MITIGADO
- H-027-04 MEDIO -> MITIGADO
- H-027-05 MEDIO -> MITIGADO
- H-027-06 BAJO -> APLICADO

## SQL Requerido

- Ejecutar insert-me.sql en la base activa del servidor.
- Tablas a crear:
  - codem_new_inventory
  - codem_new_stash
  - codem_new_vehicleandglovebox
  - codem_new_clothingsitem

## Configuracion Necesaria para Instalacion

- Verificar Config.Framework = "qb".
- Verificar Config.SQL = "oxmysql".
- Revisar Config.ImportQBSharedItems segun estrategia de items.
- Asegurar carga de dependencias antes del recurso.

## Notas para Instalacion

- Smoke test obligatorio tras despliegue:
  - inventario
  - craft
  - throw weapon
  - municion
  - stash/trunk
  - NUI
- Recurso de alto impacto: planificar ventana de mantenimiento.
- Si el servidor mantiene qb-inventory activo, validar estrategia de coexistencia/reemplazo para evitar conflictos funcionales.
