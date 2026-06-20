# v0.243 Barrosan Build Validation Bridge + Sim-Safe Role Shells

Verdict: `PARTIAL`

## Exact facts

- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Published implementation commit: `af4b52914cec260b6517f16021cf502774ea2ddd`.
- Exact-SHA GitHub Actions run: https://github.com/jardas33/ascendant-realms/actions/runs/27884349103.
- Blender used: no.
- New GLB exported: no.
- v0.239 GLB reused unchanged: yes.
- GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.
- Placement authority: `res://data/generated/content-subset.json`, exported from existing browser content.

## Runtime coverage

- Fully live: `main_base`, `barracks`, `mine`.
- Sim-safe shells: `house`, `farm`, `lumber`, `blacksmith`, `watchtower`, `market`.
- Each shell has a stable runtime ID, role ID, selection state, footprint, 500/500 shell health, empty production queue and explicit no-economy/no-AI/no-combat/no-save posture.
- All nine roles are present in the runtime registry, click hit testing, minimap and evidence manifest with no duplicate IDs.

## Build validation integration

- Godot cannot execute the browser TypeScript function directly. A read-only GDScript adapter mirrors its exact check order against the generated Broken Ford map, Barracks definition, resources, building spawns and capture-site data.
- Valid preview result: real generated authority returned valid.
- Blocked preview result: `blocked-terrain` / `Blocked terrain.`.
- No gameplay rule was changed and the adapter does not place buildings or spend resources.

## Selection and HUD

- Selecting live buildings shows their live entity type and available runtime state.
- Selecting shell buildings shows `Sim-safe role shell` and `Shell / opt-in / 500 HP / no production yet`.
- Unselected structures remain free of persistent debug labels.

## Terrain and pathing honesty

- Shell footprints are inserted into the existing Godot runtime structure array and therefore affect its current rectangular destination-nudge obstacle avoidance.
- This is not browser PathfindingGrid parity. Visual roads remain partially decorative, and the visual river/bridge does not fully derive from the generated Broken Ford navigation grid.
- Unit movement near shells is probed, but this remains a review-grade pathing check rather than gameplay certification.

## Runtime systems touched

- Opt-in Barrosan runtime subclass, generated-authority placement adapter, shell structure records, selection/HUD presentation, minimap evidence and capture tooling.
- Untouched: browser gameplay rules, economy, production, AI, saves, combat, objectives, commands, default launchers and source content definitions.

## Validation results

- `npm run godot:test`: pass.
- v0.243 capture and dedicated validator: pass.
- `npm test`: pass, 122 files / 887 tests.
- `npm run build`: pass.
- `npm run validate:content`: pass.
- `npm run validate:art-intake`: pass.
- `npm run validate:runtime-art-slots`: pass, 52 slots.
- `npm run godot:validate:salto-experimental-artifact-retention`: pass.
- `npm run godot:all`: pass.
- `git diff --check`: pass.

## Exact source files changed

- `desktop-spikes/godot-salto/scripts/adapters/build_placement_validation_adapter.gd`
- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0243BarrosanBuildValidationRoleShellsReviewPack.py`
- `tools/godot/captureGodotV0243BarrosanBuildValidationRoleShellsWindows.ps1`
- `tools/godot/saltoV0243BarrosanBuildValidationRoleShellsTool.mjs`
- `tools/godot/validateGodotV0243BarrosanBuildValidationRoleShellsWindows.ps1`
- `package.json`
- `docs/V0243_BARROSAN_BUILD_VALIDATION_ROLE_SHELLS_REPORT.md`

## Assessment

The lane is materially safer: placement feedback is sourced from real exported rules data and the six missing roles now exist in the runtime simulation structure collection. It remains PARTIAL because the bridge mirrors TypeScript semantics rather than invoking TypeScript, shell obstacle avoidance is coarse, and visual roads/river/bridge are not full navigation parity.

v0.244 limited opt-in gameplay testing may proceed only as a constrained technical playtest if the complete validation matrix and exact-SHA CI remain green; it must not be treated as default-runtime or full-building gameplay approval.

Stop after v0.243. Do not begin v0.244.
