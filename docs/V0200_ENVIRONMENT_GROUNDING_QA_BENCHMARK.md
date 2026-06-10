# v0.200 Environment Grounding QA And Benchmark

Status: `PASS_V0200_ENVIRONMENT_GROUNDING_QA_BENCHMARK`

Date: 2026-06-10

Scope: harden only the isolated Salto shell-v2 mesh-compositor structure-hierarchy review path with restrained procedural grounding, overcast value balance, contact shadows, sparse rocks, sparse moss/grass accents, small timber/stone edge props, bank-edge accents, and warm hearth cues. No images were generated, no imported art slots were added, no launcher was changed by default, the browser runtime was not touched, and gameplay, pathing, collisions, objectives, AI, saves, stable IDs, production manifests, legacy shell paths, and prior launchers were preserved.

## Visual QA

v0.200 adds procedural-only grounding and lighting behind the explicit grounding-lighting review flag. It keeps the v0.199 structure hierarchy as the comparator, preserves the v0.198 wet-granite bridge and bank material binding, and layers low-density details around routes, banks, structures, and units without changing gameplay geometry.

Windows-side capture evidence was inspected from the manual-review PNG pack. The scene reads less empty than v0.199, roads and the bridge remain visible, the river channel and banks stay aligned, structures retain their hierarchy, and units remain legible against the grounded shell. The additions stay intentionally sparse; the pass does not attempt dense foliage, imported textures, new art slots, or a broad lighting redesign.

## Scenario Summary

| Scenario | Purpose | Result |
| --- | --- | --- |
| `default-procedural` | Prove the default launcher posture remains procedural and shell-v2-free. | PASS |
| `s1-shell-v2-structure-hierarchy` | Preserve the v0.199 structure hierarchy comparator. | PASS |
| `g1-shell-v2-grounding-lighting` | Enable the v0.200 restrained grounding, lighting, and sparse props layer. | PASS |

Validation confirmed:

- Five frozen character slots were still requested and loaded only in the explicit opt-in shell scenarios.
- Three existing environment-material opt-in slots were still requested and loaded only in the explicit opt-in shell scenarios.
- No new character slot, environment-material slot, image source, imported texture, shell-v2 art slot, browser runtime path, gameplay path, pathing path, collision path, objective path, AI path, save path, or stable-ID path was added.
- Route continuity, bridge road continuity, river continuity, coherent terrain base, riverbank alignment, character grounding, structure hierarchy, and wet-granite comparator binding stayed green.
- v0.200 grounding-lighting evidence reported sparse visual nodes only in the explicit grounding-lighting scenario.

## Benchmark

Comparator: v0.199 `s1-shell-v2-structure-hierarchy`.

| Scenario | Average FPS | p95 frame time |
| --- | ---: | ---: |
| `s1-shell-v2-structure-hierarchy` | 75.11 | 13.21 ms |
| `g1-shell-v2-grounding-lighting` | 75.01 | 13.36 ms |

Result: FPS ratio `0.9987`; p95 worsening ratio `0.0114`; threshold was FPS ratio >= `0.90` and p95 worsening <= `0.15`.

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0200/validation/grounding-lighting-validation-report.json`
- `artifacts/desktop-spikes/godot-salto/v0200/benchmark/grounding-lighting-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0200/benchmark/grounding-lighting-scorecard.md`
- `artifacts/desktop-spikes/godot-salto/v0200/capture/grounding-lighting-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0200/boundary/grounding-lighting-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0200/cleanup-dry-run/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0200/cleanup-safe-only/salto-experimental-cleanup-report.json`
- `artifacts/desktop-spikes/godot-salto/v0200/artifact-retention-post-cleanup/salto-experimental-artifact-retention-report.json`
- `artifacts/manual-review/v0200-grounding-lighting/`

Manual-review PNG pack:

- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\01_overview.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\02_ground_roads.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\03_river_bridge.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\04_structures.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\05_units.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\06_combat.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\07_pan_zoom.png`
- `D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0200-grounding-lighting\08_contact_sheet.png`

Recommended review screenshots:

- `01_overview.png`
- `02_ground_roads.png`
- `03_river_bridge.png`
- `08_contact_sheet.png`

PASS gates:

- `PASS_V0200_GROUNDING_LIGHTING_VALIDATION`
- `PASS_V0200_GROUNDING_LIGHTING_BENCHMARK`
- `PASS_V0200_GROUNDING_LIGHTING_BOUNDARY_SCAN`
- `PASS_V0200_GROUNDING_LIGHTING_CAPTURE_PACKET`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0200_GROUNDING_LIGHTING_VALIDATION_READY`
