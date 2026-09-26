# Claude lane handoff: performance, world art, lighting, worker

Branch `claude/perf-placeholders-r1`, based on local `codex/current-godot-baseline-next` at `ebef47ae`.
Worked in an isolated clone at `D:\ClaudeWork\ar-lane`, so no Codex worktree was touched. It's not merged or promoted.

## What changed

| Commit | Change | Files |
| --- | --- | --- |
| 4920f5fd | The fog of war is drawn from an R8 texture plus a shader instead of rebuilding an 18k-vertex mesh every 0.2 s. It was 54 ms per rebuild and is now ~0 ms, and 4x speed goes from 6 to 75 FPS. | `scripts/world/game_world.gd`, `assets/shaders/fog_of_war.gdshader` |
| 138d1861 | The white cube "wall" is replaced by a Blender dry-stone wall, and its height changes from 4.2 to 1.9 m. | `assets/environment/visual_convergence/highland_dry_stone_wall_module.glb`, `hollowspan_environment_composition.gd` |
| f5b703e6 | Golden-hour grade for the highland theme: sun, ambient, haze, SSAO, glow and contrast. These use optional theme keys, so other themes are unchanged. | `scripts/world/map_defs.gd`, `game_world.gd` |
| 22297e3d | Three watch braziers now carry a `BrazierFire` (flickering OmniLight plus an additive flame). | `scripts/world/brazier_fire.gd`, composition |
| 3cdd4e66 | The Barrosan settlement kit only builds for a Barrosan player start, so Lioraen starts no longer get the Barrosan fort. | composition, `game_world.gd` |
| cf885c4d | The stone resource is now a granite quarry outcrop. | `assets/props/misc/resource_stone_quarry_chunk.glb` |
| dd73e450 | Textured cairns and heather/gorse brush. | `small_stone_cairn.glb`, `highland_brush_cluster.glb` |
| e557cc8f | Decor materials are made dielectric and cached. The Tripo exports were metallic 1.0, which made the oaks look pale teal. There is also a foliage tint per tree. | `game_world.gd` |
| 64b5545b | The Barrosan worker body is rebuilt on the same armature. Bones, the six actions and the import retarget are unchanged. | `assets/characters/barrosan_highlander_worker/*.glb` |

## Regenerating assets (Blender 4.5, headless)

Every generated asset has a script in `tools/blender/`:
`generateHighlandDryStoneWall.py`, `generateStoneQuarryOutcrop.py`, `generateHighlandCairnAndBrush.py`, `generateBarrosanHighlandWorker.py`.
Each one documents its command line in its docstring. The worker script takes the current worker GLB as input and replaces only the skinned mesh.

## Validation done

- Godot 4.6.3 import is clean. `tests/asset_load_scan.gd` loads 371/371 assets. Its one compile error comes from the pre-existing `tests/barrosan_iron_forge_b01_r1_runtime.gd`.
- Real-window Hollowspan captures (Barrosan 1080p, Lioraen 1080p and 1366x768) were inspected after each change.
- Frame timing on a GTX 1070: 13.3 ms average and 16-20 ms worst at 1x and 4x. The 75 FPS reading is the vsync cap.

## Not done / next

- Only the Barrosan worker was rebuilt. The Lioraen and Vorthak workers and the military units still need the same pass.
- Lioraen has no faction settlement kit yet, and the Groveheart still reads as toy-like.
- The minimap is still a grid with no terrain.
- The menus outside battle (skirmish setup, skill tree label truncation, War Chest, campaign map) are untouched.
- 2135 draw calls in the opening. A MultiMesh pass for decor would be the next render-side win.
