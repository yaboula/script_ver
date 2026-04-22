# Notas de Auditoría — [farm] (0r-farming y 0r-farmingv2)

> **Escaneo Híbrido: Nivel 1 y Nivel 2 Profundo Finalizados.**

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-041` |
| **Fecha de Auditoría** | 2026-04-21 |
| **Analista** | Antigravity |
| **Estado** | ✅ Aprobado (Extensivamente Refactorizado) |
| **Versión del Recurso** | v1 & v2 |
| **Origen** | `quarantine/approved/` |
| **Severidad Máxima Detectada** | 🔴 Crítica (R-03 / R-00 / FIX-05) mitigada. |

---

## Resumen de la Auditoría Estratégica
- **Nivel 1 (Automatizado):** Descontaminó el DRMs (`io.popen`) de las librerías `0r_lib` y llamadas HTTP opacas detectadas mediante regex.
- **Nivel 2 (Manual Completo):** Purgó vulnerabilidades gravísimas de confianza del cliente en la versión v1 de farming (R-00) añadiendo bloqueos mediante variables de control de estado; expandió además múltiples comodines en los manifiestos de v1 y v2 previniendo evasiones (FIX-05).

---

## Hallazgos Detallados & Resolución

### Amenazas Core (R-03 / FIX-05)

| # | Patrón | Archivo | Análisis | Acción Tomada |
|:---:|:---|:---|:---|:---|
| 1 | C-01 HTTP Libre | `0r_lib/modules/server/main.lua` | Peticiones POST con HWID foráneas. | ✅ Interrumpidas y bloqueadas localmente. |
| 2 | C-10 `io.popen` | `0r_lib/modules/server/main.lua` | Ejecución `wmic` para DRM intrusivo. | ✅ Depurado. Simulación UUID falso inyectada. |
| 3 | FIX-05 Wildcards | `0r-farmingv2/fxmanifest.lua` | Abuso de comandos `*` en carga dinámica que abre ventanas a troyanerío de terceros. | ✅ Expansión y sobreescritura nativa del 100% de los archivos y rutas. |
| 4 | FIX-05 Wildcards | `0r-farming/0r-farming/fxmanifest.lua` | Imágenes cargadas vía wildcard `html/img/*.png`. | ✅ Enumeración explícita aplicada. |

### Vulnerabilidades de Diseño (Eventos Inseguros - R-00)

| # | Tipo | Archivo | Descripción | Acción Tomada |
|:---:|:---|:---|:---|:---|
| 1 | A-05 CLI Debug | `0r_lib/modules/client/main.lua` | Comando obsoleto e irrestricto `/ra`. | ✅ Borrado del registro lógico. |
| 2 | Nivel 2 Ciego | `0r-farming` (sv_cow, sv_melon, sv_pumpkin, sv_wheat) | Múltiples eventos críticos como `0r-farming-receive-milk` regalando items y economía al recibir un trigger ciego del cliente. | ✅ Re-codificado: Integración condicional `fields[src]` verificando que el jugador pertenece legimitamente a la instancia del sembradío. |
| 3 | M-01 SQL | `0r-farmingv2/modules/mysql/server.lua` | Operaciones sobre DB. | ✅ Segurizado de origen. Todo el SQL implementa `MySQL.prepare`. |

---
> Toda la maquinaria en el clorado `[farm]` y `0r-farming` es ahora inmune a inyección estándar de eventos de economía en todos sus minijuegos. Carga aprobada.
