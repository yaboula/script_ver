# Integracion con 0r-clothing

## Objetivo
Habilitar compatibilidad sin usar el paquete rechazado de imagegenerator.

## Cambios requeridos en 0r-clothing

Archivo: `shared/config.lua`

1. Establecer:

```lua
UseWebServer = true
```

2. Recomendado para mejor UX:

```lua
UseDefaultClothImages = {
    Skin = true,
    Hair = true,
    Makeup = true,
    Clothing = true,
    Accessories = true,
    Body = true
}
```

## Orden de arranque sugerido

- `ensure 0r-imagegenerator`
- `ensure 0r-clothing`

## Criterios de verificacion

1. `0r-clothing` inicia sin error de dependencia.
2. No aparecen errores de callback `getClothingUrl`.
3. Menus de character creation / barber / clothing / tattoo abren correctamente.
4. Guardado y carga de skin funcionan.

## Nota
Este reemplazo prioriza seguridad y estabilidad. La previsualizacion es por placeholder local en lugar de thumbnails generados dinamicamente.
