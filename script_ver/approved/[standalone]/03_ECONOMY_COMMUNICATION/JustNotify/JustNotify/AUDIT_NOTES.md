# Notas de Auditoria - JustNotify

## Informacion General

| Campo | Valor |
|:---|:---|
| Fecha de Auditoria | 2026-04-17 |
| Analista | GitHub Copilot (GPT-5.3-Codex) |
| Estado | APROBADO |
| ID Auditoria | AUD-023 |
| Version del recurso | N/D |
| Origen | paquete entrante en queue/incoming |

## Dependencias Requeridas

- /assetpacks (dependency interna FiveM)

## Dependencias Opcionales

- Ninguna declarada.

## Cambios Realizados Durante Auditoria

- No se aplicaron cambios de codigo al recurso.
- Se genero inventario SHA-256 en:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-023_JustNotify_2026-04-17_hashes.tsv
- Se genero reporte de auditoria en:
  - c:\admirales\script_ver\script_ver\reports\audit_AUD-023_JustNotify_2026-04-17.md

## Hallazgos Relevantes

- H-023-01 (MEDIO): NUI con CDNs remotos en index.html.
- H-023-02 (BAJO): Config.Debug = true por defecto.

## Configuracion Necesaria

- Cambiar en config.lua:
  - Config.Debug = false

## Notas para Instalacion

- Categoria recomendada: [standalone].
- Validar notificaciones NUI y F8 tras arranque.
