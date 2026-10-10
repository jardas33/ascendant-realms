# Claude lane handoff: performance, world art, lighting, worker

## START HERE: handoff for a fresh session (written 2026-10-10, after plan 187)

Everything below this section is older history. A cold session needs only this section, the memory index, and the top of `CLAUDE_PROGRESS_UPDATE.md` (newest plan first under "World and terrain").

**State.** Branch `claude/perf-placeholders-r1`, pushed. Working tree clean. Nothing is running in the background. Last plan written up: 185 (AI keeps one healer to three soldiers); before it 184 (Wild Careto blunt), 183 (confirmation), 182, 181 and 180 (confirmation run `matrix_p180_*.log`; sylvan Silver Colossus 265/31, 40-30 over 72 focus matches, still 24-11 on old maps). Before it 179 (grimtusk: Chainbreaker deals blunt, health 1.08; 31-36 over 72 focus matches). Before it 178 (armour weight halved with `sqrt`, sylvan no damage bonus and reach +0.5; run F, `matrix_p178f_*.log`: nine peoples 39 to 65%, grimtusk 25%). Before it 177 (AI armour-aware unit choice `enemy_ai.gd` `_dominant_enemy_damage`, heal 11, Bloomdancer 125/1; the state of run C below). Before it 176 (ember and dusk light softened in `CampaignDefs.MOODS`, timber colour, hold-out bounties). Before it 175 (the flinch that squashed units; `unit.gd` `_reaction_settled_scale`, check `claude_flinchdrift.gd`). Plan 186 looked at act one in mid-battle (fords fade at the banks: `_ribbon(..., fade_ends)`). Plan 187 did the same for acts two to four (ashen theme brightened in `map_defs.gd`). The next plan is 188: the twelve side chapters in mid-battle, then the side-seat veins. Balance is settled for now (plan 185: AI healer cap, `matrix_p185_*.log`, all ten 40 to 66%); leave it unless a people is outside 38 to 62% over the last three full runs pooled (`matrix_p180`, `p183`, `p185`). Go back to the game itself: mid-battle pictures of every chapter of act one as a new player meets them, the side-seat veins map by map, and Codex review 9 when they post.

**Where things are.** Game project `D:\ClaudeWork\ar-lane\production\ascendant-realms-godot` (git root `D:\ClaudeWork\ar-lane`). Test copy `D:\ClaudeWork\ar-test\ascendant-realms-godot` (sync with `rm -rf $T/scripts; cp -r scripts $T/scripts`). Probes and scripts `D:\ClaudeWork\ar-review`. Patches, logs, pictures `D:\ClaudeWork\tmp` (pictures in `tmp\mapshot`, traces in `tmp\trace`). Godot `D:\ClaudeWork\godot\Godot_v4.6.3-stable_win64_console.exe` (windowed: `..._win64.exe`). Python `D:\ClaudeWork\pyenv\Scripts\python.exe`. Never write to disk C. Never edit `D:\CodexData` (reading is fine).

**What exists now.** All 44 saga chapters play on hand-built maps: 26 layouts in `scripts/world/map_defs.gd` (one `static func _<name>()` each, assembled by `_assemble_authored`), plus variants that reuse a layout under another theme or seat order (`"saga": true` hides them from the skirmish list). Map features: rivers with fords, bridges (`bridges_turned` for a north-south river), tarns (slag on volcanic), woods, hills (`"shape": "mesa"`), ridges (`"style": "masonry"` for a built wall), ruins, farmsteads, sites (`composed:` models in `capture_point.gd`). Chapter extras in `CampaignDefs.EVENTS`: `allies`, `waves`, `towers`.

**Open items, in priority order.**
1. **Done in plan 173: the multi-enemy chapters were measured again with the fixed probe.** 5-2 Montalto is now a ten-minute hold-out (`"survive": 600`, closing line from the new chapter key `"held"`) with two towers inside each gate; the stand-in holds it 6 of 6 and breaks at 11 to 13 minutes if left to run. The four other hold-outs hold; the fourteen two-enemy chapters are lost at 17 to 27 minutes or undecided at 30. Nothing else needed changing. Plan 174 drew built walls as walls (`"style": "masonry"` on a ridge: Montalto, the Castro rings, the Envoy's Field forts, the dam in the Rabagao Gorge, the fojo funnels; blocking tiles unchanged), made the baked minimap readable (`_bake_overview_texture` lifts a dark picture and calls `paint_minimap_terrain(img, half, 0.5)`), smoothed the skirmish preview, grouped the map picker under two headings (item ids, not row numbers, name the map), styled every drop-down through `assets/ui/tooltip_theme.tres` (the project theme), kept decor off authored roads, and fixed bounties in hold-outs.
2. **Balance, confirmation of the shipped build (plan 180).** The Ironmaw were 9-27 in run F and are fixed (plan 179). Earlier note: running when written: `claude_focusmatrix3.sh` with CLAUDE_FOCUS=grimtusk on both map families in the test copy with `max_hp *= 1.08` for grimtusk (`focus_p179_grim_auth.log`, `_old.log`). Change one or two numbers a run, never five: runs D and E below were wasted that way. Tally several logs with `python D:/ClaudeWork/tmp/pool.py`. Older notes on this item: Run D in the test copy (`matrix_p177d_authored.log`, `_old.log`) = the shipped state plus: sylvan no damage bonus and range +0.5 (was +3% and +1.5), vorthak health 1.02 (1.06), karak damage 1.13 (1.08), grimtusk health 1.06 (none), hollow lifesteal 0.14 (0.11), Bloomdancer 118 health. If D is level, copy those passives from the test copy's `unit.gd` (`_apply_race_passive`) with comments, regression, push. History: Second run (heal 11, Bloomdancer 125 health and 1 armour, AI no longer counts healers as archers; `matrix_p175_authored.log`, `_old.log`): old maps even (6-12 to 12-6), lioraen 6-11 authored and 11-7 old, sylvan 25-10 over both, sunspear 13-23. Third run adds `patch177.py` (AI picks armour against the enemy's commonest damage type; logs `matrix_p176c_*.log`). A traced match showed why the Lioraen lose: all but one of their soldiers wear light armour and a Granitborn AI fielded 22 crossbows in 25. Cause found: healer units healed only while idle, never under attack-move, so four peoples (lioraen, sylvan, sunspear, wyldkin) fought without their healers except at home. Fixed and shipped in plan 174 (`unit.gd` `_heal_in_place_of_attack`; regression check `claude_healmarch.gd`), with the lioraen and sunspear damage bonuses of plan 167 removed. With the fix and no lioraen or sunspear damage bonus: lioraen 22-27 on authored maps over two runs (29% before), 22-32 on old maps over two runs; sunspear, sylvan and wyldkin 13-5 each on old maps. Running when this was written: 180 matches in the test copy with heal 11, Bloomdancer 125 health and 1 armour, and the AI fix (logs `D:/ClaudeWork/tmp/matrix_p175_authored.log`, `_old.log`); the Lioraen AI was fielding 30% healers by head on old maps. To do: settle heal per cast (`"heal"` in `unit_defs.gd`, now 14) and whether the Lioraen need more (their tier-one roster loses equal-cost open fights to three peoples of four: `patch175.py`), fix the AI counting healers as archers (`patch176.py`), then confirm on both map families and apply to the real project. See memory `healers-heal-in-fights`.
3. **Side seats have nearer veins** on 20 of the 26 layouts (19% on the standard skeleton). A blanket move collided with terrain on 17 maps; it needs doing map by map. Low value.
4. **Review Codex each cycle.** Six notes are in `CODEX_REVIEW_FEEDBACK.md`. Codex has put nothing into the game since Review 1; by its own intake notes (`D:\CodexData\evidence\claude-review-intake-*`) its game work waits on Emanuel answering a tool question. Three small changes of mine sit in its UI files and are described there (`hud.gd` MAP_HALF and minimap terrain, `map_preview.gd`).

**How to check a map or a change.**
- Compile: `timeout 300 $G --headless --path . -s res://tests/claude_compileall.gd | grep COMPILEALL` must print `bad=[]`.
- Regression: `sh /d/ClaudeWork/ar-review/claude_regress_fast.sh > log 2>&1; grep -v "exit=0" log` (92 checks, about 10 minutes; run it in the background). Afterwards `git checkout -- '*.import' artifacts`. Known flake: `claude_clickable`.
- One map: `sh /d/ClaudeWork/ar-review/claude_mapbattery.sh <map> <chapter>` (soundness, walks, vein build, three matches, the chapter).
- Matches: `sh claude_batch.sh m:<map>:<a>:<b> c:<chapter> ...` (nine at a time, traced). Balance: `CLAUDE_MAPS="..." CLAUDE_MINUTES=30 CLAUDE_JOBS=7 sh claude_matrix3.sh > log` (90 matches, about 55 minutes), `claude_focusmatrix3.sh` with `CLAUDE_FOCUS=<people>` (36 matches, about 22 minutes); tally with `python D:/ClaudeWork/tmp/tally.py log`. The probe also prints `GEO` (where each side's soldiers die: near home, between, near the enemy; before and after minute ten) and `COMP` (army make-up by role at minutes 8, 12 and 16); `claude_focusgeo.sh` is the focus matrix that collects them into `CLAUDE_GEOLOG`. A chapter many times over: `sh claude_chaprun.sh <tag> <n>` with `CH=<chapter>` (runs in the test copy). A balance change must be checked on both the hand-built and the old maps.
- What the player sees: `claude_minimapdump.gd` (CLAUDE_MAP), `claude_previewshot.gd` (CLAUDE_MAPS), `claude_skirmishshot.gd`, `claude_startshot.gd` (CLAUDE_CHAPTER), `claude_terrainshot.gd` (CLAUDE_MAP or CLAUDE_CHAPTER, CLAUDE_SPOTS). Look at the pictures: soundness and matches do not see what a player sees.
- A chapter in mid-battle as a player sees it: `claude_midbattle.gd` (windowed; CLAUDE_CHAPTER, CLAUDE_SPOT, CLAUDE_TIMES; CLAUDE_BIG=1 lists any unit or building part drawn over 30 m long). Look at a battle in progress after any change to units or effects: start pictures and match results never showed heroes drawn hundreds of metres wide.
- Copy a probe into `tests/`, run it with `-s`, delete it and its `.uid`. Do not edit the real project's scripts while a matrix runs there; use the test copy with `CLAUDE_PROJECT`.

**Working conventions.** Write patches as Python files with the Write tool (count-asserted replacements, CRLF-aware); bash heredocs mangle backslashes and apostrophes. Commit with `git -c user.name="Jardas33" -c user.email=...`, the Claude co-author trailer, and push with `timeout 100 git push -q https://github.com/jardas33/ascendant-realms.git claude/perf-placeholders-r1`; verify with `git ls-remote`. After each pushed plan: add the plan at the top of the list in `CLAUDE_PROGRESS_UPDATE.md`, copy that file to `D:\Code for projects\WB game like\tmp\` and send it, and reply briefly in the thread. State only what was measured; when a later result contradicts an earlier claim, say so in the write-up and in the thread.

**Emanuel's standing directions.** Decide design questions without asking; he has no time to test builds. Keep going, plan after plan. Spend no money. Review Codex's work each cycle and leave written feedback. Maps must be big, varied and tied to the story. Use the cheaper model for routine runs.


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
| (latest) | Food resource nodes use assets/props/misc/resource_harvest_grain.glb (tools/blender/generateHarvestFoodNode.py: tilled soil, grain tufts, stook, loose sheaves, sacks), height 1.5; previously the timber pile |
| (latest) | Deaths leave CombatVfx.battle_scar (battle_scar.gdshader churned dark earth, fades after 18+8 s, max 40 live) and trample the grass (clear_ground_cover r=0.9). Food GLB colours are sRGB converted to linear in the Blender script |
| (latest) | Timber and gold resource sites: resource_timber_stack.glb and resource_gold_vein.glb (tools/blender/generateTimberAndGoldNodes.py; heights 1.6 and 2.6), added to the loading-screen preload list; the old timber pile and gold-mine models are no longer used for resources |
| (latest) | Damaged buildings: building._update_damage_fires adds sooty ChimneySmoke below 70% health (2 below 40%) and BrazierFire flames below 40% (2 below 20%), removed on repair. Scorch zones get cellular cracked-basalt plates with ember seams (ground_blend crack_dist). Minimap unexplored shroud alpha 0.54 to 0.44 |
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

## Character part joins (2026-09-28)

Six character GLBs were re-exported from Blender with every mesh driven by the armature joined into one object (one draw per material instead of one per part). The rig, bone names, node names of the skeleton and the external animation libraries are unchanged; walk animation was verified on each. Originals are kept outside the repo at `D:\ClaudeWork\tmp\glb_backup\`.

| Model | Mesh parts before | After |
|---|---|---|
| grimtusk_ogre_r709b | 146 | 1 |
| vorthak_rift_blade | 43 | 1 |
| barrosan_stoneward_spears_r696_compat | 32 | 1 |
| barrosan_clan_levy | 6 | 1 |
| vorthak_ash_thrall | 8 | 1 |
| vorthak_bondservant_worker | 5 | 1 |

`grimtusk_bowcrusha_r704c` (119 rigid parts) was not joined: its parts are not parented to bones directly and need a closer look. Accessory GLBs in `visual_convergence/` were not changed; unit.gd now merges the chosen pieces of each attachment at runtime (cached per accessory and prefix).

Follow-up: `grimtusk_bowcrusha_r704c` joined too (120 free-standing pieces to 1 static mesh). Note for Codex: this model never animated. Its pieces are not skinned or parented to the 52-bone armature, so it moves as a rigid statue (verified before and after the join). Skinning it to the rig would bring it to life.

## Building collision hulls (plan 22)

`ModelUtils.add_cached_per_part_convex_collision` wraps each model part in one convex hull. On the Barrosan War Hall (`barrosan_war_hall_a02.glb`) a yard wall part turned into a solid block reaching 11.7 m from the centre against a 5 m footprint, and the Clan Croft's reached 8.9 m against 3.6 m. Troops trained inside those blocks could never leave, and routes planned around the footprint ran into them. `building.gd` now drops any part hull that reaches past `footprint * 1.25 + 0.5` (`_drop_oversized_part_hulls`); the footprint blocker covers the rest. For Codex: if a building model should really block a wider yard, give the wall its own thin collision parts (or split it into segments) so each hull stays small.

`GameWorld` now also prewarms each building's hulls through the real model path (`Building.prewarm_model`), because the raw-scene prewarm cached different parts and the first Clan Croft of a match stalled for about 0.25 s.

The old single-live-transaction guard on the Clan Croft (`place_building`) refused every Croft while another was under construction. It now only rejects a repeated confirmation of the same spot in the same frame.
