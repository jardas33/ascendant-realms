# v0.187 Riverbank Bridge Approach QA And Benchmark

Status: `PASS`

## Scope

v0.187 hardens only the visual-only procedural riverbank, bridge crossing, and approach-lane presentation in the explicit Godot Salto opt-in environment review path. It uses zero generated images, adds zero art slots, preserves the five-slot character freeze, keeps the selected ground and road materials opt-in only, keeps the default launcher procedural, and leaves browser runtime, gameplay, pathing, collisions, objectives, AI, saves, and stable IDs unchanged.

The R1 review path builds on the v0.186 S1 structure-shell baseline and improves the tactical crossing area: continuous river-channel silhouette, bank shaping, restrained water values, bridge deck and abutment read, approach-lane contrast, site-marker hierarchy, minimap correlation, z-order, and review framing.

## Visual QA Findings

Riverbank and bridge readability improved in the scoped R1 path:

- The river now reads as one coherent vertical channel with layered bank shelves instead of disconnected blue fragments.
- The bridge now has stronger deck, rail, abutment, landing-shadow, and road-contact cues so it reads as the crossing point.
- Friendly and hostile approach lanes remain visible without becoming gameplay pathing or collision changes.
- Road-to-bridge transitions are more legible against the selected road material and the procedural bank values.
- Site markers, selection rings, character billboards, combat posture, and minimap correlation remain readable over the crossing.

## Repaired During QA

Windows-side review found the initial R1 title label clipped on the right edge. The repair shortened the visible title/review label while preserving the explicit opt-in path. A prior validation attempt also exposed a GDScript variable declaration defect in capture/benchmark reporting; that was repaired before the final gate.

One benchmark attempt produced a transient p95 outlier. A clean rerun after the label/reporting repairs produced the final passing scorecard below.

## Evidence

- Validation report: `artifacts/desktop-spikes/godot-salto/v0187/validation/riverbank-bridge-approach-validation-report.json`
- Capture report: `artifacts/desktop-spikes/godot-salto/v0187/capture/riverbank-bridge-approach-capture-report.json`
- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0187/capture/v0187-riverbank-bridge-approach-contact-sheet.svg`
- Benchmark scorecard: `artifacts/desktop-spikes/godot-salto/v0187/benchmark/riverbank-bridge-approach-benchmark-scorecard.md`
- Boundary report: `artifacts/desktop-spikes/godot-salto/v0187/boundary/riverbank-bridge-approach-boundary-report.json`

Representative R1 captures:

- `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/03_full_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/04_river_overview.png`
- `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/06_banks_close.png`
- `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/08_bridge_close.png`
- `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/09_road_to_bridge_transition.png`
- `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/12_combat_crossing_posture.png`

## Computer Use Review

Windows-side packaged app review covered:

- Title screen with the repaired v0.187 opt-in label visible and not clipped.
- Briefing screen readability.
- Battle start with the bridge deck and abutments centered.
- Aster selection, Move command, and right-click order near the bridge approach using real input.
- Camera pan and zoom smoke over the crossing.

Result: live review matched the automated captures; the crossing read as a coherent visual route, and no tactical obstruction, duplicate rendering, fallback visibility defect, or gameplay-path mutation was observed.

## Traversal Proof

The bounded functional proof passed:

- `npm run godot:headed:post-mine-flow-smoke`
- `npm run godot:headed:triple-natural-playthrough`

The smoke/playthrough evidence retained the expected objective flow, bridge-adjacent movement/selection behavior, browser-runtime unchanged status, save-writes disabled status, and stable-ID unchanged status.

## Benchmark

S1 structure-shell hardening baseline versus R1 riverbank/bridge approach hardening:

- S1 average FPS: `75.6`
- R1 average FPS: `75.78`
- FPS ratio: `1.0024`
- S1 p95: `13.39`
- R1 p95: `13.43`
- p95 worsening: `0.3%`

Result: `PASS_V0187_RIVERBANK_BRIDGE_APPROACH_BENCHMARK`.

## Limitations

The R1 crossing remains procedural primitive presentation. This checkpoint does not authorize a bridge/riverbank material, water shader pipeline, generated images, new slots, gameplay navigation, collision, pathing, objective, AI, save, stable-ID, browser-runtime, or default-launcher change.
