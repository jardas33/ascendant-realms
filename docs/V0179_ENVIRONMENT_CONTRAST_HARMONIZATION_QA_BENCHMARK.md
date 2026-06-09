# v0.179 Environment Contrast Harmonization QA And Benchmark

Status: `PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_QA_BENCHMARK`

v0.179 harmonizes procedural road, river, bridge, site-marker, approach-lane, minimap, and restrained lighting treatment over the selected Barrosan foothold ground-material opt-in path. It generates zero images, imports zero new textures, adds zero new slots, preserves the frozen five character slots, and remains opt-in only.

## Visual QA

Primary capture:

- `artifacts/desktop-spikes/godot-salto/v0179/capture/environment-contrast-harmonization-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0179/capture/v0179-environment-contrast-harmonization-contact-sheet.svg`

Captured scenarios:

- `e1-prior-ground-material-opt-in`: before posture using v0.178 ground material.
- `e2-environment-contrast-harmonized`: after posture using v0.179 contrast layers.
- `ground-missing-art-contrast-fallback`: procedural fallback with contrast layers.
- `ground-hash-mismatch-contrast-fallback`: hash-mismatch fallback with contrast layers.

Required views passed in every capture scenario:

- Tactical overview.
- Road intersections.
- River banks.
- Bridge crossing.
- Site-marker hierarchy.
- Mine and Barracks approach lanes.
- Hostile approach lane.
- Five-slot combat posture.
- Camera pan readability.
- Camera min and max zoom.
- Minimap correlation.
- Results path.

Windows-side Computer Use review also passed. The live review reached title, briefing, battle, selection, objective advancement, zoom, and pan states. Roads, bridge, riverbanks, site marker, approach lanes, minimap markers, and character billboards stayed readable over the textured foothold material.

## Benchmark

Benchmark report:

- `artifacts/desktop-spikes/godot-salto/v0179/benchmark/environment-contrast-harmonization-benchmark-scorecard.json`

Result:

| Scenario | FPS average | Frame p95 |
| --- | ---: | ---: |
| E1 prior textured foothold | `75.01` | `13.52 ms` |
| E2 contrast harmonized | `75.17` | `12.99 ms` |

Gate:

- FPS ratio: `1.0021` against required `>= 0.90`.
- p95 worsening: `-3.92%` against allowed `<= 15%`.

Fallback benchmark coverage:

- Missing-art fallback: `75.58 FPS`, `13.35 ms` p95.
- Hash-mismatch fallback: `75.20 FPS`, `12.90 ms` p95.

## Pass Evidence

```text
PASS_V0179_SALTO_ENVIRONMENT_CONTRAST_HARMONIZATION_AUTOMATION_READY
PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_VALIDATION
PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_CAPTURE
PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_BENCHMARK
PASS_V0179_ENVIRONMENT_CONTRAST_HARMONIZATION_BOUNDARY
PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION
```
