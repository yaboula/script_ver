# Notas de Auditoria - mythic_notify

## Informacion General

| Campo | Valor |
|:---|:---|
| Fecha de Auditoria | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Estado | LIMPIADO Y APROBADO |
| ID Auditoria | AUD-024 |
| Version | v1.0.3 |

## Dependencias

- jQuery interno de FiveM: nui://game/ui/jquery.js
- Google Fonts: fonts.googleapis.com (permitido)

## Cambios aplicados durante limpieza

- Archivo: html/js/app.js
- Cambio de hardening XSS:
  - .html(data.text) -> .text(data.text)
  - .html(data.caption) -> .text(data.caption)
  - En bloque persistente: .html(data.text) -> .text(data.text)

## Riesgo mitigado

- Se elimino insercion HTML directa en notificaciones para evitar inyeccion de contenido en NUI.

## Artefactos de auditoria

- Reporte:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-024_mythic_notify_2026-04-17.md
- Hashes:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-024_mythic_notify_2026-04-17_hashes.tsv

## Instrucciones para instalacion

- Añadir en server.cfg:
  - ensure mythic_notify
- No requiere SQL.
- Si se usa QBCore, revisar el reemplazo de QBCore.Functions.Notify indicado en README.md.
