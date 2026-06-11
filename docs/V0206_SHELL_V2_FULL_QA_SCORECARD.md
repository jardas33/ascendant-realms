# v0.206 Shell V2 Full QA Scorecard

Status: PASS

Manual review pack:

- `artifacts/manual-review/v0206-final-shell-v2-qa/01_legacy_vs_final.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/02_final_overview.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/03_ground_roads.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/04_river_banks_bridge.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/05_structures.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/06_units_grounding.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/07_ashen_combat_readability.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/08_minimap_pan_zoom.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/09_fallbacks.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/10_restart_replay.png`
- `artifacts/manual-review/v0206-final-shell-v2-qa/11_contact_sheet.png`

## Windows Visual QA

The final isolated shell-v2 review path is coherent enough to freeze for human review. It no longer reads as one flat slab: ground variation, embedded roads, bridge landings, riverbank treatment, structure grounding, and sparse props are all visible without cluttering tactical lanes.

Visual audit notes:

- Terrain: coherent base surface; no detached islands or broad translucent pads in primary frames.
- Roads: connected through the playable slice and embedded into the ground material.
- River and banks: continuous vertical channel with visible wet-edge/bank framing; bridge reads as a crossing.
- Structures: Command Hall, mine, and Barracks remain distinguishable through mine conversion, restoration, restored, and training states.
- Props: sparse and useful; no collision/pathing implication beyond the visual shell.
- Units: Worker, Aster, Militia, and Ashen billboards remain grounded and readable.
- Markers and rings: visible but not giant debug circles in primary captures.
- Framing: normal, zoomed-out, pan, and minimap frames remain correlated; zoomed-out framing keeps some unused margin but does not block acceptance.
- Fallbacks: missing and hash-mismatch structure material captures fail closed to the prior shell-v2 visual presentation.

No visual defect was found that justified a v0.206 feature repair inside the authorized QA-only scope.

## Scenario Validation

Source: `artifacts/desktop-spikes/godot-salto/v0206/validation/shell-v2-full-qa-validation-report.json`

| Scenario | Status | Shell | Character slots | Environment slots | Structure material | Grounding props |
| --- | --- | --- | --- | --- | --- | --- |
| default-procedural | PASS | v0.195 | 0/0 | 0/0 | fallback active | disabled |
| legacy-pre-v0203-shell-v2 | PASS | v0.200 | 5/5 | 3/3 | fallback active | disabled |
| final-shell-v2-grounding-props | PASS | v0.205 | 5/5 | 3/3 | active | enabled, 43 nodes |
| missing-structure-material-fallback | PASS | v0.205 | 5/5 | 3/3 | fallback active | enabled, 43 nodes |
| hash-mismatch-structure-material-fallback | PASS | v0.205 | 5/5 | 3/3 | fallback active | enabled, 43 nodes |

Progression-state proof:

- Post-mine flow: `PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE`
- Restart/replay path: `PASS_V0134_RESTART_INTEGRITY`

## Performance

Source: `artifacts/desktop-spikes/godot-salto/v0206/benchmark/shell-v2-full-qa-benchmark-report.json`

| Path | Average FPS | p95 frame time |
| --- | ---: | ---: |
| legacy-pre-v0203-shell-v2 | 75.06 | 13.28 ms |
| final-shell-v2-grounding-props | 75.76 | 13.23 ms |

Ratios:

- FPS ratio: 1.0093
- p95 frame-time worsening ratio: -0.0038

Counts:

- Entities: 43
- Environmental cohesion visual nodes: 32
- Grounding prop visual nodes: 42
- MultiMesh usage: not used; sparse prop count does not justify batching

## Boundary Audit

Source: `artifacts/desktop-spikes/godot-salto/v0206/boundary/shell-v2-full-qa-boundary-scan.json`

- Default launcher changed: false
- Browser runtime changed: false
- Gameplay/pathing/collision files changed: false
- Generated images: 0
- Downloaded assets: 0
- New slots added: 0
- Production runtime art slot added: false

