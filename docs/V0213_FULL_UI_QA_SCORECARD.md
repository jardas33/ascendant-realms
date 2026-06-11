# v0.213 Full UI QA Scorecard

Status: PASS

Manual review pack:
`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0213-full-ui-qa\`

Reference target:
`C:\Users\barro\AppData\Local\Temp\REFERENCE_UI_TARGET.png`

The reference image was used only as a hierarchy, polish, and cohesion benchmark. It was not copied into the repository or used as art input. The current Godot slice is not at reference parity; it is a clearer fantasy RTS prototype pass with more coherent HUD grouping, minimap readability, opt-in art fallback proof, and shell-v2 presentation evidence.

## Windows Review Coverage

| Area | Result | Evidence |
| --- | --- | --- |
| Initial overview | PASS | `02_initial.png` |
| Aster selection | PASS | `03_aster.png` |
| Worker and Barracks state | PASS | `04_worker_barracks.png` |
| Production state | PASS | `05_production.png` |
| Objective and event log | PASS | `06_objective_log.png` |
| Minimap and alert posture | PASS | `07_minimap.png` |
| Ashen pressure readability | PASS | `08_ashen_pressure.png` |
| Portrait and procedural fallbacks | PASS | `09_fallbacks.png` |
| Restart and replay path | PASS | `10_replay.png` |
| Resolution matrix | PASS | `11_resolution_matrix.png` |
| Contact sheet | PASS | `12_contact_sheet.png` |

## Visual Findings

- HUD zoning, resource/objective/event/minimap grouping, selection affordance, and production panels remain readable across the required captures.
- The shell-v2 battlefield presentation is coherent enough for the current isolated review path: roads, river, bridge, structures, props, billboards, markers, and minimap correlation are all legible in the review pack.
- No scoped v0.213 visual defect was found that justified new visual feature work. The remaining gap is overall art direction richness and production finish, which is outside this QA/freeze scope.
- No clipping, broken fallback, detached HUD panel, unreadable minimap, missing portrait fallback, or default-launcher regression was observed in the generated evidence.

## Boundary Scorecard

| Boundary | Result |
| --- | --- |
| No generated images | PASS |
| No downloaded assets | PASS |
| No new art slots | PASS |
| Browser runtime untouched | PASS |
| Default launcher unchanged | PASS |
| Prior launchers preserved | PASS |
| No gameplay, pathing, collision, objective, AI, economy, save, stable ID, or balance edits | PASS |
| No production-slot leakage | PASS |
| Active art, metadata, fallbacks, and historical evidence preserved | PASS |

## Benchmark

Benchmark report:
`artifacts/desktop-spikes/godot-salto/v0213/benchmark/v0213-full-ui-qa-benchmark-summary.md`

| Scenario | Average FPS | p95 frame ms | Entity count | Draw/node count | UI nodes | MultiMesh |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| pre-v0203-shell-v2-comparator | 74.94 | 13.35 | 0 | 0 | 0 | not-reported |
| full-ui-opt-in | 75.24 | 6.81 | 0 | 0 | 0 | not-reported |
| procedural-fallback | 75.33 | 13.41 | 0 | 0 | 0 | not-reported |

Opt-in FPS ratio vs comparator: 1.004.

Opt-in p95 frame-time ratio vs comparator: 0.51.

The benchmark runtime does not expose entity, draw-node, UI-node, or MultiMesh counters for these scenarios, so those fields are recorded as zero or `not-reported` rather than inferred.

## Decision

PASS. The final v0.213 review path is coherent for this freeze checkpoint, the hard boundaries hold, and no narrowly scoped QA defect remained unrepaired.
