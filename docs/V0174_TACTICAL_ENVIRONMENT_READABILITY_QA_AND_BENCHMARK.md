# v0.174 Tactical Environment Readability QA And Benchmark

Status: `PASS_V0174_ENVIRONMENT_READABILITY_QA_AND_BENCHMARK`

v0.174 hardens only the opt-in procedural environment-foundation path with a second E2 readability layer for roads, river, bridge, approach lanes, site-marker hierarchy, minimap correlation, and camera pan/zoom review. It generates zero images, adds zero runtime-art slots, imports no terrain material, and preserves the five selected Worker, Barracks material, Militia, Aster, and Ashen opt-in slots.

## Findings

- Automated validation passed for all three scenarios: default procedural with zero slots, E1 environment-foundation baseline with five selected opt-in slots, and E2 road/river/bridge/site-marker hardening with the same five selected slots.
- E2 reports `environmentReadabilityHardeningEnabled=true`, zero environment art slots, zero AI images, no terrain material import, no gameplay/pathing/navigation mutation, no browser runtime mutation, no save writes, and no stable-ID mutation.
- The E2 status records the intended readability layers: road continuity/intersections, mine and Barracks approach lanes, hostile approach lane, friendly foothold boundary, river-bank contrast, bridge crossing guards, site-marker hierarchy, minimap markers, and pan/zoom anchors.
- Windows-side app review confirmed the live title, briefing, and battle views. The first review pass found the E2 top review label was too long and clipped at the right edge; the label was shortened to `Experimental opt-in art: 5 slots + E2 environment`, then validation and Windows review were rerun.
- Final Windows battle review confirmed improved road continuity, clearer bridge/river separation, visible site-marker hierarchy, readable approach lanes, and minimap correlation while keeping the five selected opt-in slots coherent.
- Cleanup and retention checks passed. The final cleanup used only the approved safe-only path for known Godot-generated comparator sidecars; no broad deletion or archive movement was performed.

## Benchmark

- Status: `PASS_V0174_ENVIRONMENT_READABILITY_BENCHMARK`
- E1 baseline FPS: `75.17`; E2 hardened FPS: `75.46`; ratio: `1.0039`
- E1 p95 frame time: `13.12ms`; E2 p95 frame time: `13.45ms`; worsening: `2.52%`
- Thresholds: FPS ratio >= `0.90`; p95 worsening <= `15%`

## Evidence

- Validation report: `artifacts/desktop-spikes/godot-salto/v0174/validation/environment-readability-validation-report.json`
- Capture report: `artifacts/desktop-spikes/godot-salto/v0174/capture/environment-readability-capture-report.json`
- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0174/capture/v0174-environment-readability-contact-sheet.svg`
- Benchmark scorecard: `artifacts/desktop-spikes/godot-salto/v0174/benchmark/environment-readability-benchmark-scorecard.json`
- Cleanup dry-run: `artifacts/desktop-spikes/godot-salto/v0174/cleanup-dry-run/salto-experimental-cleanup-report.json`
- Artifact retention: `artifacts/desktop-spikes/godot-salto/v0174/artifact-retention/salto-experimental-artifact-retention-report.json`
- Final safe-only cleanup: `artifacts/desktop-spikes/godot-salto/v0174/final-safe-only/salto-experimental-cleanup-report.json`
- Final retention: `artifacts/desktop-spikes/godot-salto/v0174/final-retention/salto-experimental-artifact-retention-report.json`

`PASS_V0174_ENVIRONMENT_READABILITY_QA_AND_BENCHMARK`
