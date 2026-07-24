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
