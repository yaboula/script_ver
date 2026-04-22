# Notas de Auditoría — lc_stores

> Copiado desde reporte `audit_AUD-007_lc_stores_2026-04-19.md` tras re-verificación obligatoria.

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-007` |
| **Fecha de Auditoría** | 2026-04-19 (Re-verificado hoy) |
| **Analista** | Equipo de Seguridad / GitHub Copilot |
| **Estado** | ✅ Aprobado / 🔧 Limpiado |
| **Origen** | zip/[housing] |
| **Severidad Máxima Detectada** | 🟡 Media |

---

## Hallazgos Detallados

### Amenazas Detectadas

| # | Patrón | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | F-06 | `fxmanifest.lua` | N/A | Uso de wildcards en declaraciones de recursos y archivos de NUI. | Refactorizado y purgado de wildcards (FIX-05). Confirmado en re-verificación. |

---

## Dependencias Requeridas

| Recurso | Verificado |
|:---|:---:|
| `mysql-async` / `oxmysql` | [X] |
| `lc_utils` | [X] |
| `/assetpacks` | [X] |

---

## Cambios Realizados Durante Auditoría

- [X] Eliminados los wildcards en `fxmanifest.lua` declarando todos los archivos de NUI e imágenes de manera explícita para evitar inyección silenciosa de archivos de interfaz o configuración (FIX-05).

---

## Configuración Necesaria para Instalación

- [ ] Editar `config.lua`: Verificar frameworks de `lc_utils`
- [ ] Añadir al `server.cfg`: `ensure lc_stores`

---

## Notas para el Equipo de Instalación

- `server.lua` es el de lógica de LixeiroCharmoso, no incluye `PerformHttpRequest` detectables y su validación es interna.
- La NUI enlaza a recursos CDN externos legítimos (`fonts.googleapis`, `bootstrapcdn`, etc.).

---

> **Firma del Analista:** GitHub Copilot  
> **Fecha de Cierre (Re-verificación):** 2026-04-20
