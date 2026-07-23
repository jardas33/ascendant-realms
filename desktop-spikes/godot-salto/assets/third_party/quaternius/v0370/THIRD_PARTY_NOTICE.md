# v0.370 Quaternius Third-Party Notice

This directory contains a deliberately small, non-production proof subset.
The original intake remains at `external-art-intake/quaternius/` and was not
modified.

## Creator and packs

- Creator: Quaternius
- `medieval-village-megakit`
- `fantasy-props-megakit`
- `stylized-nature-megakit`
- `ultimate-modular-men`
- License: CC0 1.0 Universal, as recorded by each source pack license file
- Source license copies: `licenses/`

## Imported files

Selected glTF/bin files and their referenced textures are listed in
`docs/V0370_QUATERNIUS_SELECTED_ASSET_MANIFEST.md`. The subset provides:

- modular walls, floors, roofs, stairs and fences for composed buildings and
  bridge rails/supports;
- settlement and resource props;
- trees, bushes, grass, flowers and rocks;
- Worker, Farmer and Adventurer characters.

## Conversion

No destructive conversion was performed. The selected source `.gltf`, `.bin`,
and referenced image files were copied into versioned proof folders. Godot
imports the copied glTF files at runtime. The sandbox's terrain, stream,
lighting and water are authored engine geometry/materials; they are not
presented as Quaternius assets.
