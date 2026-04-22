# Notas de Auditoría — [NOMBRE DEL RECURSO]

> Copiar esta plantilla y completar para cada recurso auditado.

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-XXX` |
| **Fecha de Auditoría** | YYYY-MM-DD |
| **Analista** | [nombre] |
| **Estado** | ⏳ En Cola / 🔍 En Revisión / ✅ Aprobado / 🔧 Limpiado / ❌ Rechazado |
| **Versión del Recurso** | [versión] |
| **Origen** | [marketplace / autor / URL de descarga] |
| **Hash SHA-256 Original** | `[hash del archivo recibido]` |
| **Severidad Máxima Detectada** | 🟢 Ninguna / 🟡 Media / 🟠 Alta / 🔴 Crítica |

---

## Resumen del Escaneo Automatizado (Nivel 1)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos | [N] |
| 🟠 Altos | [N] |
| 🟡 Medios | [N] |
| Archivos Binarios | [N] |

---

## Hallazgos Detallados

### Amenazas Detectadas

| # | Patrón | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | [ID del patrón] | [archivo] | [N] | [Descripción] | [Eliminado / Refactorizado / Documentado] |

### Vulnerabilidades Detectadas

| # | Tipo | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | [SQL Injection / XSS / etc.] | [archivo] | [N] | [Descripción] | [Refactorizado / Documentado] |

---

## Dependencias Requeridas

| Recurso | Versión Mínima | Verificado |
|:---|:---|:---:|
| `qb-core` | v1.x+ | [ ] |
| `oxmysql` | v2.x+ | [ ] |
| [otros] | [versión] | [ ] |

---

## Cambios Realizados Durante Auditoría

- [ ] [Descripción del cambio 1]
- [ ] [Descripción del cambio 2]

---

## Configuración Necesaria para Instalación

- [ ] Editar `config.lua`: [instrucciones específicas]
- [ ] Añadir al `server.cfg`: `ensure [nombre-recurso]`
- [ ] Ejecutar SQL: `sql/[archivo].sql` en la base de datos
- [ ] [Otras configuraciones]

---

## Notas para el Equipo de Instalación

- [Cualquier información relevante para pruebas in-game]
- [Advertencias o consideraciones especiales]
- [Conflictos conocidos con otros recursos]

---

## Verificación del Manifiesto (fxmanifest.lua)

- [ ] F-01: `fx_version` es versión actual
- [ ] F-02: `game` declarado correctamente
- [ ] F-03: Todos los `client_scripts` verificados
- [ ] F-04: Todos los `server_scripts` verificados
- [ ] F-05: No hay archivos no declarados
- [ ] F-06: No se usan wildcards
- [ ] F-07: `files` solo contiene assets legítimos
- [ ] F-08: `dependencies` verificadas
- [ ] F-09: No hay `loadscreen` sospechoso
- [ ] F-10: No hay `data_file` con path traversal

---

> **Firma del Analista:** ___________________________  
> **Fecha de Cierre:** YYYY-MM-DD
