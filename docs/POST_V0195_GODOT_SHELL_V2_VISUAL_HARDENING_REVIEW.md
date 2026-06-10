# Post-v0.195 Godot Shell-V2 Visual Hardening Review

Status: `PASS_POST_V0195_GODOT_SHELL_V2_CONTINUED_VISUAL_HARDENING_REVIEW`

Date: 2026-06-10

Scope: continued ad hoc visual-only review and hardening after the v0.195 human-quality concern. This is not v0.196. It keeps the work inside the existing isolated Godot Salto shell-v2 scoped-material recovery path and changes no gameplay, pathing, collisions, objectives, AI, saves, stable IDs, browser runtime, production manifests, default launcher, prior launcher, imported art slot, or generated image.

## Repairs

- Lowered only the shell-v2 review camera angle to reduce the flat map-board read while preserving tactical legibility.
- Muted the ground-material tint and raised the road-material visibility enough for road hierarchy to read at review distance.
- Added small route-following road skins, ruts, crowns, approach gravel, and shoulders so the friendly road, bridge feed, and hostile road read as one connected route.
- Broke up the large rectangular terrain-field read with narrow terrain value strips, edge feathering, and small mottle cues.
- Added restrained river depth variation, broken bank lips, bank pebble runs, bridge plank lines, parapet shadows, ramp shadows, and structure contact shadows.
- Continued pass: reduced the largest shell-v2 scoped ground material slabs so they read as local terrain zones over the coherent base instead of broad diagnostic pads.
- Continued pass: added bridge cutwater shadows, abutment caps, bank foot stones, and eddy reads around the crossing.
- Continued pass: flattened the shell-v2-only duplicate full-height structure base into a low foundation, letting the richer shell-v2 structure masses define the silhouette.
- Continued pass: added command hall, enemy stronghold, ford toll, and generic site shell-v2 silhouette details without changing legacy/default structure rendering.
- Continued 2026-06-10 pass: changed the six scoped ground-material bind targets from broad rectangular surfaces into smaller shell-v2-only oval material zones so the selected ground texture remains visible without reading as giant diagnostic pads.
- Continued 2026-06-10 pass: added shell-v2-only terrain contour, road-dust, and riverbank-shelf ovals around the road, bridge approaches, and river corridor to reduce hard construction geometry while preserving route readability.
- Continued 2026-06-10 pass: preserved the shell-v2 review pitch for focused v0.195 road-network, road-to-bridge, and bridge-close captures so close review shots no longer revert to the flatter default posture.
- Continued 2026-06-10 value pass: rebalanced only the shell-v2 palette, scoped road overlay, river surface, and bridge deck values so roads no longer read as raw yellow strips and the crossing has stronger material hierarchy.
- Continued 2026-06-10 value pass: added small terrain-value, verge, road-middle, river-glint, bridge-landing, and bridge-shoulder cues while keeping the v0.189 wet-granite source unintegrated.
- Continued 2026-06-10 framing pass: recentered only the shell-v2 review camera and focused v0.195 road/bridge capture presets within the existing safe zoom bounds to reduce empty presentation padding in review screenshots.

## Boundary

- Zero images generated.
- Zero art slots added.
- The v0.189 wet-granite bridge-riverbank material remains unintegrated and private-comparator-only.
- Default procedural launcher remains unchanged.
- All prior opt-in launchers remain unchanged.
- Browser runtime remains untouched.
- Character-slot integration remains frozen.
- Gameplay, pathing, collisions, objectives, AI, saves, stable IDs, and production manifests remain unchanged.

## Evidence

- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_CAPTURE_PACKET`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_VALIDATION`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BENCHMARK`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BOUNDARY_SCAN`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0195_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_VALIDATION_READY`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npx vitest run src/game/desktop-spike/GodotSaltoSpikeScaffold.test.ts`
- `npm run build`
- `git diff --check`
- Computer Use note: the desktop helper timed out after the required retry/reset sequence in this run, so Windows-side review evidence was gathered through the deterministic Godot capture harness and direct screenshot inspection.

Recommended screenshots for review:

- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/03_tactical_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/08_connected_road_network.png`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/10_road_to_bridge_transition.png`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/12_bridge_close_view.png`

## Human Review Note

The result is still intentionally procedural and conservative, but it now reads less like stacked translucent rectangles and blunt placeholder blocks: roads connect, the bridge has stronger local grounding, the river/banks are less ruler-flat, the selected terrain material is contained to local shaped zones, the road value is calmer, and structure silhouettes no longer fight a duplicate full-height base primitive in shell v2. Further work should remain explicitly bounded and should not start v0.196 without a clean, synced, pushed, remote-green checkpoint and a new prompt.
