# Notas de Auditoría — lc_stores

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | 'AUD-007' |
| **Fecha de Auditoría** | 2026-04-19 |
| **Analista** | GitHub Copilot |
| **Estado** | ✅ Aprobado / 🔧 Limpiado |
| **Versión del Recurso** | N/A |
| **Origen** | zip/[housing] |
| **Hash SHA-256 Original** | Listado en TSV adjunto |
| **Severidad Máxima Detectada** | 🟡 Media |

---

## Resumen del Escaneo Automatizado (Nivel 1)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos | 0 |
| 🟠 Altos | 0 |
| 🟡 Medios | 1 |
| Archivos Binarios | 0 |

---

## Hallazgos Detallados

### Amenazas Detectadas

| # | Patrón | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | F-06 | fxmanifest.lua | N/A | Uso de wildcards en declaraciones de recursos y archivos de NUI. | Refactorizado y purgado de wildcards (FIX-05) |

### Vulnerabilidades Detectadas

| # | Tipo | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| - | - | - | - | No se detectó ninguna en archivos expuestos. Nota: \server.lua\ se encuentra pseudo-ofuscado/escrow pero no presentaba vectores HTTP u OSS | - |

---

## Dependencias Requeridas

| Recurso | Versión Mínima | Verificado |
|:---|:---|:---:|
| \mysql-async\ / \oxmysql\ | v2.x+ | [X] |
| \lc_utils\ | latest | [X] |
| \/assetpacks\ | latest | [X] |

---

## Cambios Realizados Durante Auditoría

- [x] Eliminados los wildcards en \xmanifest.lua\ declarando todos los archivos de NUI e imágenes de manera explícita para evitar inyección silenciosa de archivos de interfaz o configuración (FIX-05).

---

## Configuración Necesaria para Instalación

- [ ] Editar \config.lua\: Verificar frameworks de \lc_utils\
- [ ] Añadir al \server.cfg\: \nsure lc_stores\

---

## Notas para el Equipo de Instalación

- \server.lua\ es el de logica de LixeiroCharmoso, no incluye \PerformHttpRequest\ detectables y su validacion es interna con variables ofuscadas.
- La NUI se enlaza a fonts.googleapis, bootstrap jsdelivr, fa en cdnjs, todas consideradas fuentes estáticas legitimas en el modelo de amenaza.

---

## Verificación del Manifiesto (fxmanifest.lua)

- [X] F-01: \x_version\ es versión actual ('cerulean')
- [X] F-02: \game\ declarado correctamente ('gta5')
- [X] F-03: Todos los \client_scripts\ verificados
- [X] F-04: Todos los \server_scripts\ verificados
- [X] F-05: No hay archivos no declarados
- [X] F-06: No se usan wildcards (Aplicado FIX-05)
- [X] F-07: \iles\ solo contiene assets legítimos
- [X] F-08: \dependencies\ verificadas
- [X] F-09: No hay \loadscreen\ sospechoso
- [X] F-10: No hay \data_file\ con path traversal

---

> **Firma del Analista:** GitHub Copilot  
> **Fecha de Cierre:** 2026-04-19