# Claude lane handoff: performance, world art, lighting, worker

Branch `claude/perf-placeholders-r1`, based on local `codex/current-godot-baseline-next` at `ebef47ae`. It also merges Codex's ornate HUD branch at b6bcbe25.
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

## Second pass (after the handoff above)

| Commit | Change |
| --- | --- |
| d282cd84 | Skirmish setup rebuilt: faction banner cards and dossier, tactical map preview (`scripts/ui/map_preview.gd`), colour-keyed opponents |
| dcb4aae2 | Forge-hero preview plays the idle clip, faces the camera and is framed |
| b615d148 | Barrosan worker replaced by a generated, sculpted model (free FLUX + Hunyuan3D, rigged by `tools/charpipe/fit_character.py`) |
| 49881376 | Ground shader: anti-tiling, painterly colour fields, shading-only rolling relief (highland only) |
| 0642f988 | **Merge of `codex/astra-ui-battle-hud-visual-r1` (b6bcbe25)**. Kept the GPU fog, took Codex hero-preview code, kept the skirmish rebuild |
| f6ebb52f | Hamlet behind the Barrosan start: houses, crofts, `ChimneySmoke`, door lanterns, woodpiles, fences |
| 530a47ec | Fog overlay overhangs the map edge |
| 3d9bd467 | `CombatVfx` (cached sparks, flash, dust, death clouds), new arrow and bolt visuals, softer legacy hit cues |
| 5c952f1d | Skill tree key-art backdrop, campaign inked march routes, War Chest title block and bronze button |
| 3d5e3aa9 | Vorthak holdfast on Vorthak starts (ground-shader scorch zone, charred basalt walls, ash-glass shards, violet `BrazierFire`); perimeter and foothill trees kept 30 m clear of starts |
| 7fd0cf95 | Lioraen grove on Lioraen starts (bloom zone, moonstones, lume blooms, `GroveMotes`) |
| f9e20a09 | No mid-match stalls: building hulls cached and prewarmed at load; unit, building, VFX and projectile pipelines prewarmed behind the ground at match start (worst frame over a 10-minute 4x run: 300 ms, now 33 ms) |
| 213e008c | Enemy AI economy deadlock fixed (gatherer rebalancing, stalled-gatherer reach, abandoned construction); AI now builds an army and attacks on Normal+ |
| 5bbd2ed4 | Unit/building/blocker snapshots per physics frame, blocker distance reject, chase re-plan throttle: 20v20 physics 19 ms to 9 ms |
| 0a707e10 | Route solver: steering detours reused 12 frames, 5 ms per-frame solver budget (battle stalls at 4x from 150-260 ms to mostly under 100 ms) |
| 56231283 | Worker refitted to 6k triangles |
| (latest) | Unit packed-metal cap at 0.3 |
| 7d0618a2 | Team-coloured combat rings (player blue, hostile red), friendly bars stay green until low, thicker bars; smaller hit glow |
| b8b671a8 | All themes get the battlefield grade (haze thinned 45%); every map builds faction start dressing via build_faction_start |
| 41c0d0fe | Tropical grade; bloom zone damped on snow |
| ea52e577 | Entity snapshots invalidated on configure/exit; r730a observation window in physics ticks |
| bc957d53 | Victory/defeat result ledger |
| e983b0a9 | Edge scroll only when focused and cursor inside |
| c0fbcf27 | Placement ghost mirrors Building model prep, keeps textures |
| 3d43e08b | Walkable river ford (ford_water shader + ground-shader riverbed) under bridges on the 6 bridge maps; decor/shelves kept off it |
| 0b8155a9 | Construction rises (multi-part bottom-up reveal, single-mesh upward growth) instead of a 60% transparency fade |
| (latest) | Order markers: soft ring collapses onto the target with inward chevrons for attack/attack-move (CombatVfx.order_marker); ability rings are soft expanding shockwaves (CombatVfx.shockwave) |
| (latest) | Minimap shows the real battlefield: game_world._bake_overview_texture renders one orthographic top-down picture at match start (units, buildings, objectives, FX and fog moved to a skipped layer; skipped headless); hud falls back to the old raster if absent |
| (latest) | Ground/water value-noise hash replaced with an integer hash: the old fract hash lost GPU precision and drew hard 20-50 m square seams across the ground |
| (latest) | Ground cover: instanced wind-blown grass tufts and wildflowers (scripts/world/ground_cover.gd, grass_cover.gdshader), clumped by noise, per-theme colours/density, chunked for culling, kept off roads, water and start yards; buildings, resources and capture points clear it via a mask. About +80k triangles in view, no measurable frame cost on a GTX 1070 |
| (latest) | World03 field shelves use the ground material (no more flat green carpets) |
| (latest) | Occluded units: unit meshes carry a material_overlay (assets/shaders/unit_xray.gdshader) that draws a team-coloured silhouette only where scenery stands 2.5 m+ in front (depth-texture compare), so units under tree canopies or behind buildings stay readable; other units never trigger it |
| (latest) | Trees use assets/shaders/foliage_wind.gdshader (built from the imported material, cached per source/tint/height): travelling wind gusts, crown flutter, shaded-understory-to-sunlit-crown gradient, leaf backlight |
| (latest) | Ford water: downstream current streaks, broken foam line at the banks, clearer shallows over the wet bed, glossier surface |
| (latest) | Construction: building materials swap to assets/shaders/construction_rise.gdshader while under construction; a per-instance cut_y work line rises with progress (no more whole-part reveals showing slab tops), inside faces read as timber decking, a faint warm work line; originals restored on completion; shader prewarmed at match start |
| (latest) | Theme buttons use forged-bronze 9-patch skins (assets/ui/buttons, regenerate with tools/ui/make_forged_buttons.py); pause menu sits on the hero_sheet_plate with readable key rows. Base tracks/yards/lane use ground_wear_soft.gdshader (noisy soft edges) |
| (latest) | Ambient weather (scripts/world/ambient_weather.gd): GPU particles in a box that follows the camera's ground focus; per theme pollen, autumn leaves, snow, blown sand, embers and ash |
| (latest) | Fog of war: drifting domain-warped cloud texture in the shroud and noise-feathered, slowly moving borders (grid stays authoritative) |
| (latest) | Every building flies a waving team banner (building._build_team_banner, assets/shaders/team_banner.gdshader: team colour, gilt border and lozenge, swallowtail hem); the Clanhold red box banners were removed. Ground and grass share drifting cloud shadows |
| (latest) | Hero abilities: CombatVfx.motes on allies touched by Rally/Heal (capped at 14), CombatVfx.slam dust and clods for Slam; game_world.camera_shake signal drives a short lens-offset shake in rts_controller (distance-faded, honours reduce_shake); both prewarmed |
| (latest) | Selection rings (units and buildings) use selection_ring.gdshader via CombatVfx.selection_ring_material: glowing ring with slowly turning brackets. Capture points: capture_zone.gdshader rune circle over the true 7.5 m radius with a progress arc in the contesting colour, capture_beam.gdshader soft light column |
| (latest) | Chapel capture sites are composed (MapDefs.RUIN = "composed:ruin_chapel", CapturePoint._build_ruin_chapel: pillar ring, fallen column, cairn altar with green light; only the altar collides) instead of reusing the Lume Spire. The boundary marker (Z-up GLB) is stood upright and moved out of the chapel ring |
| (latest) | Vision capture sites are composed (MapDefs.WATCH, CapturePoint._build_highland_watch). Health bars also show for 5 s after any hit. Scattered oaks 5-7.5 m, pines 6-9 m (were 6.5-10.5 m; canopies swallowed squads) |
| (latest) | Composition walls/cairns keep their Blender stone texture (the atlas finish had made them near black) |
| (latest) | Grass thins over the ground shader's dirt/rock fields (same noise in grass_cover.gdshader) and clumps tighter |

All nine self-checking tests pass (v0433 economy and identity, v0434 combat, v0435 easy AI, v0436 conquest and navigation, r730a in both modes, r730b1).

The free character pipeline is documented in `tools/charpipe/README.md`. Only the user can run the Hugging Face upload step.

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
- The menus outside battle (skirmish setup, skill tree label truncation, War Chest, campaign map) are untouched.
- 2135 draw calls in the opening. A MultiMesh pass for decor would be the next render-side win.
