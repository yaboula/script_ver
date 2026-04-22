# Notas de Auditoría — lc_gas_stations

> Copiar esta plantilla y completar para cada recurso auditado.

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | \AUD-034\ |
| **Fecha de Auditoría** | 2026-04-20 |
| **Analista** | IA (GitHub Copilot) |
| **Estado** | 🔧 Limpiado / ✅ Aprobado |
| **Versión del Recurso** | - |
| **Origen** | TC HUB Team (Leaked) |
| **Hash SHA-256 Original** | Registrado en Fase 1 |
| **Severidad Máxima Detectada** | 🟠 Alta |

---

## Resumen del Escaneo Automatizado (Nivel 1)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos | 0 |
| 🟠 Altos | 1 (H-04) |
| 🟡 Medios | 0 |
| Archivos Binarios | 0 |

---

## Hallazgos Detallados

### Amenazas Detectadas

| # | Patrón | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | \H-04\ | \xmanifest.lua\ | Múltiples | Uso de wildcards (\*.lua\, \*.*\, \**\) en \scrow_ignore\, \shared_scripts\ y \iles\. Peligro de carga de scripts ocultos o maliciosos. | Identificado como Alto. Requiere remoción de wildcards listando archivos individualmente. |    
| 2 | \C-01\ | \server.lua\ | 160 | Uso de \PerformHttpRequest\ hacia \projetocharmoso.com:3000\. Check de versión legítimo. | Ninguna (Es legítimo). |

### Vulnerabilidades Detectadas

| # | Tipo | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| - | - | - | - | No se observan inyecciones ni puertas traseras directas (\load\, etc.). | - |

---

## Resolución y Acciones Realizadas

**Resolución**: 
- El script ha sido limpiado estructuralmente para cumplir el protocolo de Tolerancia Cero.
- Se removió toda la propaganda "TC HUB Team".
- Se modificaron los manifiestos para listar las rutas de forma absoluta (resolviendo el H-04).
- Se borró la basura inyectada en NUI y el directorio raíz.

---

## Configuración Necesaria para Instalación

- [ ] Añadir al \server.cfg\: \nsure lc_utils\ antes de \nsure lc_gas_stations\.    
- [ ] Opcional: Revisar las dependencias de \LegacyFuel\, \cdn-fuel\, o \sx-sna-fuel\ provistas en el pack según el entorno exacto.

---

## Notas para el Equipo de Instalación

- El script ya fue purgado de la propaganda de TC HUB Team, y los \*.lua\ se reemplazaron para evitar inyecciones. Está seguro para entrar a \script_inst\.

---

## Verificación del Manifiesto (fxmanifest.lua)

- [x] F-01: \x_version\ es versión actual ('cerulean')
- [x] F-02: \game\ declarado correctamente ('gta5')
- [x] F-03: Todos los \client_scripts\ verificados
- [x] F-04: Todos los \server_scripts\ verificados
- [x] F-05: No hay archivos no declarados
- [x] F-06: No se usan wildcards (✅ REMOVIDOS)
- [x] F-07: \iles\ solo contiene assets legítimos
- [x] F-08: \dependencies\ verificadas
- [x] F-09: No hay \loadscreen\ sospechoso
- [x] F-10: No hay \data_file\ con path traversal

---

> **Firma del Analista:** GitHub Copilot
> **Fecha de Cierre:** 2026-04-20
