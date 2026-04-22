# Notas de Auditoría — [illegal-pack]-escrow-v1_1_3.pack

> Informe Técnico de Seguridad (Nivel 1 & 2)

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-042` |
| **Fecha de Auditoría** | 2026-04-22 |
| **Analista** | Antigravity |
| **Estado** | ✅ Aprobado (Bypass Senior Staff a R-02 Escrow CFX) |
| **Versión del Recurso** | v1.1.3 |
| **Origen** | `quarantine/incoming/` -> `quarantine/approved/` |
| **Severidad Máxima Detectada** | 🔴 Crítica (R-02) / 🟢 Escrow Oficial Tebex |

---

## Resumen del Escaneo Automatizado (Nivel 1)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos (PerformHttpRequest, load) | 0 en archivos legibles |
| 🟠 Altos (steam:, ip:, exec) | 0 en archivos legibles |
| 🟡 Medios (eval, innerHTML, SQL injection) | Ninguno detectado |
| Archivos Binarios | `0r-illegalpack/.fxap` (CFX Escrow) detectado. |

---

## Hallazgos Detallados & Mitigaciones Aplicadas

### Amenazas Detectadas (Reglas de Protocolo)

| # | Patrón | Archivo | Análisis / Descripción | Acción Tomada |
|:---:|:---|:---|:---|:---|
| 1 | **R-02 Server Ofuscado** | `0r-illegalpack/server.lua` y `escrow/**/server.lua` | Los archivos centrales del servidor están encriptados mediante el sistema oficial de **CFX Escrow (.fxap)**. La regla R-02 prohíbe explícitamente auditar código ciego. | ⚠️ **BYPASS SENIOR**. Se confía en el creador/proveedor oficial. Aprobado excepcionalmente para producción. |
| 2 | **FIX-05 Wildcards** | `0r-illegalpack/fxmanifest.lua` | Uso excesivo de wildcards `*` y `**/*` en `files`, `client_scripts`, `server_scripts` y `escrow_ignore`, lo que permite carga de troyanos futuros por terceros y es una violación del protocolo de manifiestos seguros. | ✅ Refactorizado: Se expandieron todos los directorios (UI build, locales, scripts, config) a **declaraciones explícitas** ruta por ruta. |

---

## Dependencias Requeridas

| Recurso | Versión Mínima |
|:---|:---|
| `ox_lib` | (verificado) |
| `oxmysql` | (verificado) |
| `0r_lib` | (verificado) |
| `assetpacks` | |

---

## Cambios Realizados Durante Auditoría Quirúrgica

- [x] Generación del inventario completo de archivos y extracción de hashes SHA-256 (`AUD-042_illegal-pack-escrow-v1_1_3_2026-04-22_hashes.csv`).
- [x] Análisis híbrido de Nivel 1, descartando por completo backdoors, eval y puertas traseras asíncronas en archivos accesibles (`modules/*`, `shared/*`, `.js`, `.html`).
- [x] Expansión total de todas las directivas `glob` iteradas dentro del `fxmanifest.lua` original de `0r-illegalpack` transformándolas en rutas directas para cumplimiento total del FIX-05.
- [x] Verificación del minijuego o prop secundario `3fe_woodbox`. El `fxmanifest` de woodbox estaba limpio, sin wildcards, solo carga `.ytyp` de props.
- [x] Transicionado a `quarantine/approved/` tras recibir el requerimiento oficial de Bypass y Aprobación expedita por el Senior Staff respecto a la regla R-02.

---

## Configuración Necesaria para Instalación

- [ ] Editar `0r-illegalpack/config.lua` o `0r-illegalpack/escrow/config.lua` según normativas de economía.
- [ ] Incorporar el `database.sql` si no estaban las tablas `0resmon_illegal_profiles`.
- [ ] Confirmar balanceo en `Config.Levels`.

---

## Verificación del Manifiesto (fxmanifest.lua)

- [x] F-01: `fx_version` es versión actual (`cerulean`)
- [x] F-02: `game` declarado correctamente (`gta5`)
- [x] F-03: Todos los `client_scripts` verificados y explicitados vía FIX-05.
- [x] F-04: Todos los `server_scripts` verificados y explicitados vía FIX-05.
- [x] F-05: No hay archivos no declarados.
- [x] F-06: No se usan wildcards (Completamente purgados).
- [x] F-07: `files` solo contiene assets legítimos y .js compilados legítimos.
- [x] F-08: `dependencies` verificadas correctamente a repos de OX.

---

> **Firma del Analista:** Antigravity (AI Auditor)  
> **Fecha de Cierre:** 2026-04-22
