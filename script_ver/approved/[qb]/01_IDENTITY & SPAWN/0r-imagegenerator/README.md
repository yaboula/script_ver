# 0r-imagegenerator (safe replacement)

Auditable compatibility replacement used to satisfy `0r-clothing` image URL flow without using the rejected binary package.

## What it does
- Exposes exports:
  - `getClothingUrl()`
  - `getDefaultClothingUrl()`
- Bridges `0r-clothing:getClothingUrl:server` callback without touching vendor source.
- Returns a safe local NUI base URL that always resolves to a local placeholder image.

## Integration notes
1. In `0r-clothing/shared/config.lua`, set `UseWebServer = true`.
2. Keep this resource name exactly: `0r-imagegenerator`.
3. Ensure this resource starts before `0r-clothing`.

## Security posture
- No external HTTP requests.
- No compiled/obfuscated binaries.
- No command execution or file system writes.
- Minimal server event surface (single callback bridge).

## Limitation
This replacement intentionally serves placeholder previews instead of generated clothing thumbnails.
Gameplay and skin save/load flows remain functional.
