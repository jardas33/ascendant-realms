# v0.220 Environment Dressing Report

Status: PASS

v0.220 adds sparse deterministic environment dressing to the isolated Godot Salto presentation-reboot path using the selected private prop atlas. It keeps the default stabilized launcher procedural, preserves previous launchers and comparators, and adds no production runtime art slot.

## Runtime Scope

- Launcher: `tools/godot/launchGodotSaltoPresentationRebootWindows.ps1`
- Capture wrapper: `tools/godot/captureGodotSaltoEnvironmentDressingWindows.ps1`
- Validation wrapper: `tools/godot/validateGodotSaltoEnvironmentDressingWindows.ps1`
- Benchmark wrapper: `tools/godot/runGodotSaltoEnvironmentDressingBenchmarkWindows.ps1`
- Review tool: `tools/godot/saltoEnvironmentDressingTool.mjs`

## Dressing Notes

- Added 12 sparse prop sprites from 11 loaded atlas crops.
- Placed only deterministic, visual-only road-shoulder, riverbank, structure-adjacent, bridge-approach and field-edge details.
- Preserved tactical lanes, unit silhouettes, route topology, click targets, collisions and gameplay semantics.
- Resolved crop paths from the validated metadata location so the exported Godot review app can load local ignored evidence reliably.
- Preserved procedural grounding fallback when the prop atlas is missing or hash-mismatched.

## Review Pack

Manual review PNGs:

- `artifacts/manual-review/v0220-environment-dressing/01_source_atlas.png`
- `artifacts/manual-review/v0220-environment-dressing/02_extraction_contact_sheet.png`
- `artifacts/manual-review/v0220-environment-dressing/03_before_after_overview.png`
- `artifacts/manual-review/v0220-environment-dressing/04_road_shoulders.png`
- `artifacts/manual-review/v0220-environment-dressing/05_riverbanks.png`
- `artifacts/manual-review/v0220-environment-dressing/06_structure_adjacent_props.png`
- `artifacts/manual-review/v0220-environment-dressing/07_bridge_approach.png`
- `artifacts/manual-review/v0220-environment-dressing/08_tactical_readability.png`
- `artifacts/manual-review/v0220-environment-dressing/09_fallback.png`
- `artifacts/manual-review/v0220-environment-dressing/10_contact_sheet.png`

## Validation

Fallback validation passed for:

- default procedural launcher with no presentation reboot request;
- v0.219 comparator with v0.220 dressing disabled;
- selected v0.220 environment dressing with approved prop atlas;
- missing prop-atlas fallback;
- hash-mismatch prop-atlas fallback.

Benchmark summary:

| Scenario | Average FPS | p95 frame ms |
| --- | ---: | ---: |
| v0.219 before structure shell | 74.48 | 11.45 |
| selected environment dressing | 73.32 | 12.31 |

Selected p95 frame-time ratio versus the v0.219 comparator: `1.075`.

## Boundaries

- Generated images: exactly one.
- Downloaded assets: zero.
- New art slots: zero.
- New production runtime art slots: zero.
- Browser runtime changes: none.
- Default launcher changes: none.
- Prior launcher removal: none.
- Gameplay, pathing, collisions, objectives, AI, economy, saves, stable IDs and balance changes: none.

Decision: selected. The reboot path reads slightly more inhabited while remaining sparse, tactical and reversible.
