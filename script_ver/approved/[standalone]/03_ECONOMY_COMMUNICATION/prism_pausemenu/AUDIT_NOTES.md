# Notas de Auditoría — prism_pausemenu

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-031` |
| **Fecha de Auditoría** | 2026-04-17 |
| **Analista** | GitHub Copilot (GPT-5.3-Codex) |
| **Estado** | 🔧 Limpiado y Aprobado |
| **Versión del Recurso** | 1.0.1 |
| **Origen** | [standalone] |
| **Hash SHA-256 Original** | Ver `audit_AUD-031_prism_pausemenu_2026-04-17_hashes.tsv` |
| **Severidad Máxima Detectada** | 🟠 Alta (Mitigada durante auditoría) |

---

## Resumen del Escaneo Automatizado (Nivel 1)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos | 0 |
| 🟠 Altos | 1 |
| 🟡 Medios | 1 |
| Archivos Binarios | 0 |

---

## Hallazgos Detallados y Acciones Tomadas

| # | Patrón / ID | Archivo | Descripción | Acción Tomada |
|:---:|:---|:---|:---|:---|
| 1 | H-031-01 | modules/server/main.lua, modules/client/nui.lua | Evento de desconexión confiaba en playerId enviado por cliente, permitiendo intento de expulsar terceros (Severidad Alta) | **MITIGADO:** Server ahora usa `source` server-side. Cliente dispara evento sin argumentos manipulables. |
| 2 | H-031-02 | web/dist/assets/index.css | Dependencia externa de Google Fonts en CSS de NUI (Severidad Media) | Riesgo aceptado (no bloqueante). |
| 3 | H-031-03 | modules/bridge/*/server.lua | Uso de tabla global mutable `data` en callbacks de bridge (Severidad Baja) | Riesgo aceptado. |

---

## Dependencias Requeridas

| Recurso | Versión Mínima | Verificado |
|:---|:---|:---:|
| `oxmysql` | N/A | [x] |
| `ox_lib` | N/A | [x] |
| `/assetpacks` | N/A | [x] |
| `qb-core` (Opcional) | N/A | [x] |

---

## Configuración Necesaria para Instalación

- [ ] Añadir al `server.cfg`: `ensure prism_pausemenu` tras sus dependencias (`oxmysql`, `ox_lib`, `qb-core`).
- [ ] Ejecutar comprobación: Ejecutar smoke test (abrir/cerrar menú, open map/settings, disconnect, y lectura correcta de playtime).

---

## Notas para el Equipo de Instalación

- **Advertencia:** Identificadores en localizaciones usan el prefijo `^license:` para el selector, es un falso positivo reportado funcional.
- Se recomienda ejecutar el smoke test para corroborar que la conexión con el endpoint NUI interno funciona.

---

> **Firma del Analista:** Equipo de Seguridad AI
> **Fecha de Cierre:** 2026-04-20
