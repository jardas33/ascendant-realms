# v0.199 Structure Hierarchy QA And Benchmark

Status: `PASS_V0199_STRUCTURE_HIERARCHY_QA_BENCHMARK`

Date: 2026-06-10

Scope: harden only the isolated Salto shell-v2 mesh-compositor procedural structure hierarchy. No images were generated, no imported art slots were added, no launcher was changed by default, the browser runtime was not touched, and gameplay, pathing, collisions, objectives, AI, saves, stable IDs, production manifests, legacy shell paths, and prior launchers were preserved.

## Visual QA

v0.199 adds procedural-only structure massing behind the explicit structure-hierarchy review flag. It keeps the v0.198 wet-granite bridge and bank material binding intact, then layers restrained foundations, timber frames, low roof slabs, scaffolding, mine machinery cues, warm functional accents, and compact site-marker props on top of the existing mesh-compositor layout.

Windows-side capture evidence was inspected from the manual-review PNG pack. The command hall and barracks now read more as grounded structures instead of generic boxes. The mine remains intentionally understated, but now has a darker mouth, retaining-wall cues, tailings, and a small hoist/crane silhouette. The large yellow selection and site markers remain visible existing review/readability elements; changing them is outside v0.199 structure-massing scope.

## Scenario Summary

| Scenario | Purpose | Result |
| --- | --- | --- |
| `default-procedural` | Prove the default launcher posture remains procedural and shell-v2-free. | PASS |
| `w1-shell-v2-mesh-wet-granite` | Preserve the v0.198 wet-granite mesh-compositor comparator. | PASS |
| `s1-shell-v2-structure-hierarchy` | Enable the v0.199 structure hierarchy while keeping the v0.198 context. | PASS |

Validation confirmed:

- Five frozen character slots were still requested and loaded only in the explicit opt-in shell scenarios.
- Three existing environment-material opt-in slots were still requested and loaded only in the explicit opt-in shell scenarios.
- No new character slot, environment-material slot, image source, imported texture, shell-v2 art slot, browser runtime path, gameplay path, pathing path, collision path, objective path, AI path, save path, or stable-ID path was added.
- Route continuity, bridge road continuity, river continuity, coherent terrain base, riverbank alignment, and character grounding stayed green.
- v0.198 wet-granite material remained scoped to bridge abutments, bridge landing aprons, and short retaining edges.

## Benchmark

Comparator: v0.198 `w1-shell-v2-mesh-wet-granite`.

| Scenario | Average FPS | p95 frame time |
| --- | ---: | ---: |
| `w1-shell-v2-mesh-wet-granite` | 75.22 | 13.18 ms |
| `s1-shell-v2-structure-hierarchy` | 75.24 | 13.25 ms |

Result: FPS ratio `1.0003`; p95 worsening ratio `0.0053`; threshold was FPS ratio >= `0.90` and p95 worsening <= `0.15`.

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0199/validation/structure-hierarchy-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0199/benchmark/structure-hierarchy-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0199/benchmark/structure-hierarchy-scorecard.md`
- `artifacts/desktop-spikes/godot-salto/v0199/capture/structure-hierarchy-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0199/boundary/structure-hierarchy-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0199/cleanup-dry-run/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0199/cleanup-safe-only/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0199/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`
- `artifacts/manual-review/v0199-structure-hierarchy/`

Manual-review PNG pack:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\01_overview.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\02_command_hall.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\03_mine.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\04_barracks_restoring.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\05_barracks_restored.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\06_worker_barracks.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\07_combat_posture.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0199-structure-hierarchy\08_contact_sheet.png`

Recommended review screenshots:

- `01_overview.png`
- `02_command_hall.png`
- `04_barracks_restoring.png`
- `08_contact_sheet.png`

PASS gates:

- `PASS_V0199_STRUCTURE_HIERARCHY_VALIDATION`
- `PASS_V0199_STRUCTURE_HIERARCHY_BENCHMARK`
- `PASS_V0199_STRUCTURE_HIERARCHY_BOUNDARY_SCAN`
- `PASS_V0199_STRUCTURE_HIERARCHY_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0199_STRUCTURE_HIERARCHY_VALIDATION_READY`
