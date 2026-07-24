# v0.378 Authored Barrosan Infrastructure Kit

This delivery contains an original, locally generated Stage 1 infrastructure kit. It is intended to replace Codex's failed procedural v0.377 geometry, not merely serve as another reference.

## Included

- `exports/barrosan_infrastructure_v0378.glb`
- `source/generate_v0378_infrastructure.py`
- `previews/overview.png`
- `previews/bridge_detail.png`

## Design intent

- one continuous authored highland terrain mesh;
- a recessed curved river with terrain-carved banks;
- irregular road geometry split around the crossing;
- a timber bridge with granite abutments, under-beams, piers, deck and rails;
- authored rock and reed dressing;
- muted Barrosan palette;
- no buildings, units, gameplay, HUD or production integration.

## Important

Codex must import this exact GLB and evaluate it. It must not regenerate the terrain, road, river or bridge from scratch during v0.378. It may make bounded camera, lighting, material and placement adjustments in Godot, but source geometry changes must be made by editing the included Python source and regenerating the GLB.

## v0.378 bounded source repair record

The first supplied GLB was preserved as `exports/barrosan_infrastructure_v0378_original_supplied.glb` with SHA-256 `557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078`. The current evaluated GLB is a reproducible source repair: graded four-row road surfaces, a lower bridge deck and rails, and shorter abutment slabs. The repaired GLB SHA-256 is `91cf29f5a964cf6b43f67fd1f9ac98d3bd6d3ea27623bb313479d362deef7e88`; the repaired source SHA-256 is recorded in `docs/SHA256.json`.
