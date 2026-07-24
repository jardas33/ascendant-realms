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

The original supplied GLB is preserved as `exports/barrosan_infrastructure_v0378_original_supplied.glb` with SHA-256 `557653dbda28a350046ef9ac08ec41d0a5b1eaf496238fde3c2a5784a321b078`. The current evaluated GLB is a reproducible bounded source repair: a four-row graded road surface, lower bridge deck and rails, shorter abutments, thinner deck profile, separated deck edge course, and clearer weathered-timber value hierarchy. The current GLB SHA-256 is `5d27feaabd61f4ab05063b860d19405b45a9ef2219ee27ee256972275ade40e9`; the current generator source SHA-256 is recorded in `docs/SHA256.json`.
