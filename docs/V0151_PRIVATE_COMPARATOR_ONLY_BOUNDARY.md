# v0.151 Private Comparator-Only Boundary

Hard boundaries:

- No normal Salto player-slice mutation.
- No browser runtime wiring.
- No production package inclusion.
- No save, stable-ID, content manifest, or runtime art-slot manifest mutation.
- No generated reference image import.
- No existing reference candidate import.
- No downloaded asset.
- No fourth runtime-art slot.
- No v0.152 work.

Allowed:

- One ignored original Aster source image.
- One ignored deterministic matte-to-alpha cutout.
- One tracked diagnostic fallback image and contract.
- One private Godot comparator dispatch flag: `--aster-billboard-single-slot`.
- Local ignored benchmark, scorecard, screenshot, and audit evidence under `artifacts/desktop-spikes/godot-salto/v0151/`.

The normal player launchers must not contain `aster-billboard-single-slot` or `ASTER_BILLBOARD_SINGLE_SLOT`.
