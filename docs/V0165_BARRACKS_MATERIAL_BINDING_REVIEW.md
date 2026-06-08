# v0.165 Barracks Material Binding Review

Status: `PASS_V0165_BARRACKS_MATERIAL_BINDING_REVIEW`

## Selected Material

- Slot: `barrosan_barracks_material_v0149`
- Approach: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`
- SHA-256: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`
- Source dimensions: 768 x 768
- UV scale: 1.0
- Filter/mipmap posture: linear with mipmaps

## Intended Surfaces

The material is bound only to the friendly Barracks material boxes:

- Barracks base
- Training wing A
- Training wing B
- Roof split left
- Roof split right

## Intentional Procedural Shell

The following structure readability elements remain procedural:

- Weapon rack silhouette
- Drill-yard edge
- Construction scaffold
- Construction progress bar

## Visual Finding

The material is applied, but it is intentionally restrained at normal RTS distance. That made the screenshot effect difficult to notice, but not unbound. No UV-scale or bind-target repair was proven necessary in v0.165.

Evidence:

- `artifacts/desktop-spikes/godot-salto/v0165/audit/v0165-barracks-material-binding-review.json`
