# Notas de Auditoría — 0r-farming

## Información General

| Campo | Valor |
|:---|:---|
| **ID de Auditoría** | `AUD-040` |
| **Fecha de Auditoría** | 2026-04-20 |
| **Analista** | Antigravity |
| **Estado** | ✅ Aprobado c/ Modificaciones (Limpieza Quirúrgica) |
| **Versión del Recurso** | N/A (Origin: Discord free script / leak) |
| **Origen** | 5M EXCLUSIVE-SCRITPS (rex_1) |
| **Hash SHA-256 Original** | *(Ver archivo `_hashes.tsv` adjunto)* |
| **Severidad Máxima Detectada** | 🔴 Crítica (RAT removido exitosamente) |

---

## Resumen del Escaneo Automatizado (Nivel 1 y 2)

| Categoría | Hallazgos |
|:---|:---:|
| 🔴 Críticos | 1 (RAT custom obfuscatión en sv_main.lua) |
| 🟠 Altos | 17 (Event Injections severos en compras y farmeo) |
| 🟡 Medios | 2 (Wildcards en manifiesto, jQuery externo) |
| Archivos Binarios | 0 |

---

## Hallazgos Detallados & Resolución

### Amenazas Detectadas

| # | Patrón | Archivo | Línea | Descripción | Acción Tomada |
|:---:|:---|:---|:---:|:---|:---|
| 1 | `C-01` | `sv_main.lua` | 137 | **RAT Detectado:** Código ofuscado `LOL!023Q...` que invocaba `PerformHttpRequest` a `fivehub-panel.site`. | ✅ Eliminada toda la sección maliciosa. |
| 2 | `A-06` | `sv_main.lua` | Varios | Compra y venta dependía del precio mandado por el cliente (`data.money`, `data.price`), permitiendo generadores de dinero infinito. | ✅ Eventos reescritos. Ahora calculan el precio *Server-Side* consultando `Config`. |
| 3 | `A-06` | Archivos `sv_*.lua` | Varios | Los eventos para recibir leche, melón y calabaza no tenían *rate-limiting* ni anti-spam. | ✅ Interpuesto cooldown de 2 segundos global por jugador (FIX-04). |
| 4 | `A-09` | `cl_cow.lua` | 228 | Uso de `ExecuteCommand('yenile')` no registrado en el cliente. | ✅ Código comentado. |
| 5 | `F-01` | `index.html` | 10 | Solicitud HTTP a CDN externo de jQuery. | ✅ Reemplazado por `nui://game/ui/jquery.js` local. |
| 6 | `F-06` | `fxmanifest.lua` | Varias | Uso de wildcards (`*.lua`) permitiendo inyecciones. | ✅ Patrones sustituidos por listado explícito de archivos (FIX-05). |

---

## Cambios Realizados Durante Auditoría

- [x] Movido recurso `incoming` -> `under-review`.
- [x] Escaneo Nivel 1 automatizado completado (el RAT inicial evadió el regex local por ofuscación en su formato custom "LOL").
- [x] Revisión Nivel 2 Completada: Fallo severo de seguridad descubierto y solucionado. RAT completamente eliminado del `sv_main.lua`.
- [x] Se añadió *rate-limiting* a todos los eventos y la vulnerabilidad de inyección en tiendas fue solventada.
- [x] El manifiesto fue ajustado y asegurado (`fxmanifest.lua` explícito).

---

> **Firma del Analista:** Antigravity 
> **Fecha de Cierre:** 2026-04-20
> **Resolución:** Limpieza Quirúrgica exitosa. Script movido a la carpeta `approved`.
