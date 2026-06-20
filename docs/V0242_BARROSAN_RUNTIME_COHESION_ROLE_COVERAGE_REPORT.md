# v0.242 Barrosan Runtime Cohesion + Full Role Entity Coverage

Verdict: `PARTIAL`

## Exact facts

- Blender used: no.
- New GLB exported: no.
- v0.239 GLB reused unchanged: yes.
- GLB SHA-256: `B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB`.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Mapping reused unchanged: `res://data/v0240_barrosan_playable_art_mapping.json`.
- Default runtime unchanged: proven by a separate unflagged packaged capture.

## Exact source files changed

- `desktop-spikes/godot-salto/scripts/salto_barrosan_playable_runtime_skin.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `tools/godot/buildV0242BarrosanRuntimeCohesionRoleCoverageReviewPack.py`
- `tools/godot/captureGodotV0242BarrosanRuntimeCohesionRoleCoverageWindows.ps1`
- `tools/godot/saltoV0242BarrosanRuntimeCohesionRoleCoverageTool.mjs`
- `tools/godot/validateGodotV0242BarrosanRuntimeCohesionRoleCoverageWindows.ps1`
- `package.json`
- `docs/V0242_BARROSAN_RUNTIME_COHESION_ROLE_COVERAGE_REPORT.md`

## Runtime coverage

- Live gameplay entities: `main_base`, `barracks`, `mine`.
- Inert opt-in structures: `house`, `farm`, `lumber`, `blacksmith`, `watchtower`, `market`.
- All nine roles have stable `barrosan_role_*` addresses, runtime presence, click selection, restrained selected indicators, completed footprint bounds and minimap/review markers.
- The six inert roles do not affect economy, production, combat, pathing, saves, AI, objectives or commands.

## Selection and scale assessment

- All nine structures are runtime click-selectable through the opt-in scene; the selected-market capture proves an inert role can be addressed without persistent labels or debug clutter.
- Main base, barracks and mine preserve their live entity mappings. The nine-role roster has differentiated silhouettes and remains legible beside Worker, Militia and Aster scale probes.
- Scale is improved and usable for this review lane, but remains stylized rather than final production calibration.

## Cohesion and placement

- The opt-in subclass replaces only the visual terrain foundation with Barrosan-colored terraces, connected roads, yards, riverbanks and bridge landings.
- Terrain collision and pathing are unchanged; the cohesion layer is visual-only.
- Placement previews remain evidence-only. They do not call or modify build-rule validation.

## Runtime systems touched

- Opt-in scene visual foundation, runtime structure registry, structure click hit-testing, selection presentation, minimap evidence markers and player-slice capture actions.
- Untouched gameplay systems: simulation, economy, production, combat, AI, saves, pathing, collision, commands, objectives, stable IDs and default launcher.

## Validation results

- `npm run godot:test`: pass.
- `npm run godot:capture:salto-barrosan-runtime-cohesion-role-coverage`: pass.
- `npm run godot:validate:salto-barrosan-runtime-cohesion-role-coverage`: pass.
- `npm test`: pass, 122 files and 887 tests.
- `npm run build`: pass.
- `npm run validate:content`: pass.
- `npm run validate:art-intake`: pass.
- `npm run validate:runtime-art-slots`: pass, 52 slots.
- `npm run godot:validate:salto-experimental-artifact-retention`: pass.
- `npm run godot:all`: pass, including export and package.
- `git diff --check`: pass.

## Assessment

The runtime lane is materially more coherent and all nine roles are selectable, but the terrain remains transitional proxy art and placement feedback is still evidence-only. The six additional structures are honest inert entities, not gameplay buildings.

Ready for v0.243 opt-in gameplay testing: no.

Stop after v0.242. Do not begin v0.243.
