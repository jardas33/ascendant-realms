# v0.185 Environment Shell Live QA And Benchmark

Status: `PASS_V0185_ENVIRONMENT_SHELL_LIVE_QA`

Scope: live Windows-side QA and residual-overlay pruning for the explicit Godot Salto environment-shell opt-in path behind `GODOT_REVIEW_SALTO_ENVIRONMENT_SHELL_LIVE_QA_WINDOWS.bat`.

## Visual Diagnosis

v0.184 improved the environment-shell geometry, but the player-facing opt-in scene still carried several residual diagnostic-looking surfaces: broad translucent terrain/value pads, oversized site/ring surfaces, and some terrain masks that competed with units, roads, river, bridge, and structures. v0.185 keeps the v0.184 geometry foundation and prunes only proven residual overlay problems inside the opt-in review path.

The live Windows review confirms the result is cleaner: the mine, Worker assignment, Barracks restore, Militia recruitment, Ashen wave, Lume restore, HUD, minimap, Results, restart, pan, and zoom all remain readable. Remaining roughness is classified as procedural world-shell/structure/bridge/riverbank polish for later queued prompts, not a v0.185 boundary defect.

## Captures

Baseline E3:

- `artifacts/desktop-spikes/godot-salto/v0185/capture/e3-geometry-convergence-baseline/screenshots/03_full_battlefield_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e3-geometry-convergence-baseline/screenshots/08_river_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e3-geometry-convergence-baseline/screenshots/10_bridge_close_view.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e3-geometry-convergence-baseline/screenshots/12_road_intersection.png`

Refined E4:

- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/03_full_battlefield_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/08_river_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/10_bridge_close_view.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/12_road_intersection.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/16_ashen_combat_posture.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/17_pan.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/18_zoom.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/e4-refined-shell-live-qa/screenshots/20_results.png`
- `artifacts/desktop-spikes/godot-salto/v0185/capture/v0185-environment-shell-live-qa-contact-sheet.svg`

Capture gate: `PASS_V0185_ENVIRONMENT_SHELL_LIVE_QA_CAPTURE`.

## Windows Review

Computer Use live review covered:

- Title and briefing with the explicit v0.185 opt-in label.
- Active battlefield overview with HUD and minimap.
- Camera pan and zoom over roads, bridge, riverbank, structures, and terrain transitions.
- Aster move to mine, mine conversion, Worker assignment, Barracks restoration, Militia training, Ashen pressure, attack order, Lume restore, Results, and Restart Slice.

Finding: the residual large-overlay problem is materially reduced. Terrain bands remain intentionally procedural and low-alpha; they do not block objective readability in the v0.185 review path.

## Benchmark

| Scenario | FPS avg | p95 ms |
| --- | ---: | ---: |
| E3 geometry-convergence baseline | 75.37 | 13.71 |
| E4 refined shell live QA | 75.37 | 13.31 |

Result: FPS ratio `1.0000`; p95 worsening `-2.92%`.

Thresholds: E4/E3 FPS ratio `>= 0.90`; E4 p95 worsening `<= 15%`.

Cache posture remained one-time for selected ground and road materials: source load, metadata parse, image decode, texture create, and material create each stayed at `1`.

## Smoke And Cleanup

Passed:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run validate:runtime-art-slots`
- `npm run godot:validate:salto-experimental-artifact-retention`
- `npm run godot:validate:salto-ground-road-material-opt-in`
- `npm run godot:validate:salto-environment-geometry-convergence`
- `npm run godot:validate:salto-environment-shell-live-qa`
- `npm run godot:headed:post-mine-flow-smoke`
- `npm run godot:headed:triple-natural-playthrough`
- Cleanup dry-run: `artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-dry-run/`
- Safe-only cleanup: `artifacts/desktop-spikes/godot-salto/v0185/final-cleanup-safe-only/`
- Retention after cleanup: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`

Safe-only cleanup deleted exactly 18 known Godot-generated comparator sidecars and found no unknown cleanup-scope files.

