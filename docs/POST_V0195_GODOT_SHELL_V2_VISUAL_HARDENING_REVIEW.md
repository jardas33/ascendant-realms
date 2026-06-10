# Post-v0.195 Godot Shell-V2 Visual Hardening Review

Status: `PASS_POST_V0195_GODOT_SHELL_V2_VISUAL_HARDENING_REVIEW`

Date: 2026-06-09

Scope: ad hoc visual-only review and hardening after the v0.195 human-quality concern. This is not v0.196. It keeps the work inside the existing isolated Godot Salto shell-v2 scoped-material recovery path and changes no gameplay, pathing, collisions, objectives, AI, saves, stable IDs, browser runtime, production manifests, default launcher, prior launcher, imported art slot, or generated image.

## Repairs

- Lowered only the shell-v2 review camera angle to reduce the flat map-board read while preserving tactical legibility.
- Muted the ground-material tint and raised the road-material visibility enough for road hierarchy to read at review distance.
- Added small route-following road skins, ruts, crowns, approach gravel, and shoulders so the friendly road, bridge feed, and hostile road read as one connected route.
- Broke up the large rectangular terrain-field read with narrow terrain value strips, edge feathering, and small mottle cues.
- Added restrained river depth variation, broken bank lips, bank pebble runs, bridge plank lines, parapet shadows, ramp shadows, and structure contact shadows.

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

Recommended screenshots for review:

- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/03_tactical_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/08_connected_road_network.png`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/10_road_to_bridge_transition.png`
- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/12_bridge_close_view.png`

## Human Review Note

The result is still intentionally procedural and conservative, but it should now read less like stacked translucent rectangles and more like a coherent tactical shell: roads connect, the bridge has more grounding, the river/banks are less ruler-flat, and the character/structure framing has a little more depth. Further work should remain explicitly bounded and should not start v0.196 without a clean, synced, pushed, remote-green checkpoint and a new prompt.
