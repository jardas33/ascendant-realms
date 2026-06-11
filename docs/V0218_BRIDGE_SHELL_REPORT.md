# v0.218 Bridge Shell Report

Status: PASS

v0.218 replaces the flat placeholder bridge read in the isolated Salto presentation-reboot shell-v2 path with a restrained procedural bridge shell. The legacy bridge remains available as a comparator/fallback, and the default stabilized launcher remains procedural.

## Runtime Scope

- Launcher: `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- Capture wrapper: `tools/godot/captureGodotSaltoBridgeShellWindows.ps1`
- Validation wrapper: `tools/godot/validateGodotSaltoBridgeShellWindows.ps1`
- Benchmark wrapper: `tools/godot/runGodotSaltoBridgeShellBenchmarkWindows.ps1`
- Review tool: `tools/godot/saltoBridgeShellTool.mjs`

## Bridge Notes

- The selected path adds 39 low-cost procedural bridge-shell nodes, under the 48-node review budget.
- The bridge uses stone abutments, bank seating, approach shoulders, a readable deck surface, low guard rails, rail posts, deck ties, contact shadows and shallow depth cues.
- The crossing reuses the approved v0.217 road, riverbank, water and wet-edge material hierarchy; no new image or downloaded asset was introduced.
- The west and east road approaches remain connected to the bridge, and the river, banks and crossing stay aligned at normal RTS distance.
- The selected capture pack shows no unit, marker, selection-state or click-target occlusion regression.

## Comparator And Fallbacks

Fallback validation passed for:

- default procedural path with no presentation reboot bridge request;
- selected v0.218 bridge shell;
- legacy bridge comparator through `--salto-bridge-shell-legacy-comparator`.

The selected benchmark averaged `75.57` FPS with p95 frame time `13.35` ms. The legacy bridge comparator averaged `75.65` FPS with p95 frame time `13.72` ms. The selected p95 frame-time ratio was `0.973`.

## Review Pack

Manual review PNGs:

- `artifacts/manual-review/v0218-bridge-shell/01_old_bridge.png`
- `artifacts/manual-review/v0218-bridge-shell/02_new_bridge_normal_rts.png`
- `artifacts/manual-review/v0218-bridge-shell/03_close_bridge.png`
- `artifacts/manual-review/v0218-bridge-shell/04_road_to_bridge_west.png`
- `artifacts/manual-review/v0218-bridge-shell/05_road_to_bridge_east.png`
- `artifacts/manual-review/v0218-bridge-shell/06_riverbank_seats.png`
- `artifacts/manual-review/v0218-bridge-shell/07_units_crossing.png`
- `artifacts/manual-review/v0218-bridge-shell/08_fallback.png`
- `artifacts/manual-review/v0218-bridge-shell/09_contact_sheet.png`

## Boundaries

- Generated images: zero.
- Downloaded assets: zero.
- New art slots: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance changes: none.

Decision: selected. The bridge now reads more clearly as a grounded crossing inside the presentation-reboot path without production-slot leakage or gameplay mutation.
