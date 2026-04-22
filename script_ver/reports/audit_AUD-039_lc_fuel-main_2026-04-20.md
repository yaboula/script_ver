# Notas de Auditoría — lc_fuel-main

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-039` |
| **Fecha de Auditoría** | 2026-04-20 |
| **Analista** | GitHub Copilot |
| **Estado** | 🔧 Limpiado y Aprobado |
| **Versión del Recurso** | `lc_fuel` |
| **Origen** | `c:\admirales\script_ver\script_ver\quarantine\incoming\lc_fuel-main\lc_fuel-main` |
| **Hash SHA-256 Original** | Ver `audit_AUD-039_lc_fuel-main_2026-04-20_hashes.tsv` |
| **Severidad Máxima Detectada** | 🟠 Alta |

## Resumen del Escaneo Automatizado (Nivel 1)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos | 0 |
| 🟠 Altos | 2 |
| 🟡 Medios | 1 |
| Archivos Binarios | 0 |

## Hallazgos Detallados

### Amenazas Detectadas

| # | Patrón | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | `PerformHttpRequest` | `server/server.lua` | 19 | Chequeo de versión contra GitHub. No ejecuta código remoto. | Documentado |
| 2 | `RegisterNetEvent` / NUI dispatch abierto | `client/client.lua` | 264 | El callback NUI podía reenviar eventos del recurso de forma dinámica. | Endurecido con lista blanca |
| 3 | `fxmanifest` wildcard | `fxmanifest.lua` | 29, 36, 39-41 | Uso de comodines en scripts, locales y assets. | Reemplazado por listas explícitas |
| 4 | `innerHTML` | `nui/panel.js` | 34 | Uso de HTML dinámico para construir una línea de UI. | Reemplazado por DOM seguro |

### Vulnerabilidades Detectadas

| # | Tipo | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | Event injection | `server/server.lua` | 461-482 | `setVehicleFuelType` aceptaba parámetros sin ligar el cambio al vehículo abierto por ese jugador. | Protegido con `activeVehiclePlate` por `source` |
| 2 | Superficie NUI | `client/client.lua` | 264-285 | Dispatcher NUI permitía reenviar eventos no previstos. | Se limitó a eventos permitidos |

## Dependencias Requeridas

| Recurso | Versión Mínima | Verificado |
|:---|:---|:---:|
| `lc_utils` | v1.2.1+ | [x] |
| `mysql-async` | compatible con el manifiesto | [x] |

## Cambios Realizados Durante Auditoría

- [x] `fxmanifest.lua` actualizado con listas explícitas para `lang`, `nui/lang`, `nui/scripts`, `nui/css` y `nui/images`.
- [x] `client/client.lua` endurecido con lista blanca para el dispatch NUI.
- [x] `server/server.lua` reforzado para asociar `setVehicleFuelType` al vehículo abierto por el mismo `source`.
- [x] `nui/panel.js` reemplazó `html()` por composición segura con DOM.

## Configuración Necesaria para Instalación

- [x] Mantener `ensure` de `lc_utils` antes de `lc_fuel`.
- [x] Mantener `@mysql-async/lib/MySQL.lua` disponible en el entorno.
- [x] No se requiere SQL adicional para esta limpieza.

## Notas para el Equipo de Instalación

- El recurso ya no depende de comodines en el manifiesto.
- El flujo de UI funciona igual, pero ahora el canal NUI está restringido a eventos esperados.
- La comprobación de versión sigue haciendo una llamada HTTP de solo lectura a GitHub; no ejecuta contenido remoto.

## Verificación del Manifiesto (fxmanifest.lua)

- [x] F-01: `fx_version` es versión actual
- [x] F-02: `game` declarado correctamente
- [x] F-03: Todos los `client_scripts` verificados
- [x] F-04: Todos los `server_scripts` verificados
- [x] F-05: No hay archivos no declarados
- [x] F-06: No se usan wildcards
- [x] F-07: `files` solo contiene assets legítimos
- [x] F-08: `dependencies` verificadas
- [x] F-09: No hay `loadscreen` sospechoso
- [x] F-10: No hay `data_file` con path traversal

## Decisión Final

**Veredicto:** LIMPIADO Y APROBADO

**Resumen:** Se detectaron riesgos de superficie NUI y de control de eventos del servidor, pero fueron remediados sin alterar la lógica funcional principal del recurso. No se detectaron binarios, RAT, auto-propagación ni ejecución remota de código.

**Dependencias:** `lc_utils`, `mysql-async`

> **Firma del Analista:** GitHub Copilot
> **Fecha de Cierre:** 2026-04-20
