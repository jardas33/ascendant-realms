# v0.146 Emmanuel Runtime-Art Pipeline Review Guide

Status: private comparator review guide.

## One-Click Comparator

Run:

```bat
GODOT_ART_PIPELINE_COMPARATOR_WINDOWS.bat
```

Or:

```bash
npm run godot:runtime-art-comparator:benchmark:headed
```

This writes ignored evidence under:

```text
artifacts/desktop-spikes/godot-salto/v0146/
```

Open:

```text
artifacts/desktop-spikes/godot-salto/v0146/contact-sheet.svg
artifacts/desktop-spikes/godot-salto/v0146/benchmark-summary.md
artifacts/desktop-spikes/godot-salto/v0146/scorecard.md
```

## What To Review

1. Does the hybrid 3D world plus billboard-unit lane feel like the right next experiment for Salto?
2. Does full orthographic 3D look worth keeping as a fallback comparator despite production burden?
3. Does pure billboard atlas feel too flat for Salto terrain and Barrosan structure identity?
4. Are the screenshots useful enough as engineering evidence, while still clearly not production art?
5. Should the next milestone stay single-slot and production-oriented, or pause for more review?

## Current Packet Recommendation

- Recommended next single-slot experiment: `HYBRID_3D_WORLD_BILLBOARD_UNITS`.
- Fallback comparator: `ORTHO_3D_MESH`.
- Deferred comparator only: `BILLBOARD_2D_ATLAS`.

## Do Not Treat This As

- Final Godot selection.
- Runtime-art integration approval.
- Protected-IP clearance.
- Final HUD, final unit, final terrain, final model, final sprite, or final atlas approval.
- Human playability proof for the packaged Salto microloop.

No generated reference image was imported, wired, registered, packaged, or loaded.
