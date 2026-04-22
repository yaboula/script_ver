# Notas de Auditoria - 0r-hud-v3

## Informacion General

| Campo | Valor |
|:---|:---|
| Fecha de Auditoria | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Estado | APROBADO |
| ID Auditoria | AUD-021 |
| Version del recurso | 1.0.5 |
| Origen | readme.md (0Resmon / aliko) |

## Dependencias Requeridas

- ox_lib
- xsound

## Dependencias Opcionales

- stress
- hrsgears
- edit_mini_map
- pma-voice o SaltyChat (integracion de voz)

## Cambios Realizados Durante Auditoria

- No se aplicaron cambios de codigo al recurso.
- Se genero inventario SHA-256 en:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-021_0r-hud-v3_2026-04-17_hashes.tsv
- Se genero reporte de auditoria en:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-021_0r-hud-v3_2026-04-17.md

## Hallazgos Relevantes

- H-021-01 (MEDIO): wildcards en files{} del fxmanifest (hardening recomendado).
- H-021-02 (BAJO): eventos bridge sin type-check estricto de state.
- H-021-03 (BAJO): URL de musica sin allowlist (cliente).

## Configuracion Necesaria

- Revisar config.lua:
  - Config.DefaultHudSettings.client_info.server_info.name
  - Config.DefaultHudSettings.client_info.server_info.image
  - Config.ToggleSettingsMenu / ToggleSeatBelt / ToggleVehicleEngine
- Añadir en server.cfg:
  - ensure 0r-hud-v3

## Notas para Instalacion

- El recurso trae build UI local (sin script remoto externo en index.html).
- Si se desea endurecimiento extra:
  - Reemplazar wildcards del manifiesto por lista explicita.
  - Agregar allowlist de dominios para musica URL.
