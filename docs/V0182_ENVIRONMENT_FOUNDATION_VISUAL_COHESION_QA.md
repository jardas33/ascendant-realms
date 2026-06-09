# v0.182 Environment-Foundation Visual-Cohesion QA

Status: `PASS_V0182_ENVIRONMENT_FOUNDATION_VISUAL_COHESION_QA`

Scope: Windows-side cohesion review for the frozen five character/material slots, Barrosan foothold ground material, Barrosan foothold road material, procedural river/banks/bridge/site markers, HUD, minimap, objectives, title, briefing, results, and fallback posture. This checkpoint generated zero images, added zero slots, changed no runtime wiring, and left the default launcher procedural.

## Visual Review

Reviewed:

- Default packaged executable with no opt-in arguments.
- Explicit `GODOT_REVIEW_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_WINDOWS.bat` posture.
- Static capture evidence under `artifacts/desktop-spikes/godot-salto/v0181/capture/e2-ground-road-material-opt-in/`.
- Live Computer Use review of title, briefing, battle start, Aster selection, move order, pan/zoom, HUD, minimap, road/river/bridge hierarchy, and conversion onset.

Findings:

- The default launcher remains procedural and does not show the experimental opt-in label or imported material posture.
- The explicit ground+road launcher clearly labels `Experimental opt-in art: 5 slots + Barrosan foothold ground + roads`.
- Road material is tactically clearer than the raw procedural road, and it remains distinct from the darker ground texture, river, bridge, and site markers.
- Character billboards remain readable over the materialized ground and roads at normal RTS distance and during the Aster move-order smoke.
- HUD, objective tracker, command buttons, minimap, briefing, title, and results capture remain unobscured.
- The world shell still reads as prototype/blocky. That is honest presentation debt, but not a v0.182-scoped defect because fixing it would require broader art/environment changes outside this freeze packet.

## Runtime Gates

Fresh v0.182 rerun of the current ground+road validation stack produced:

```text
PASS: npm run godot:validate:salto-ground-road-material-opt-in
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_VALIDATION
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_CAPTURE
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BENCHMARK
PASS: PASS_V0181_ROAD_MATERIAL_OPT_IN_BOUNDARY
PASS: PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION
```

The tool remains named v0.181 because v0.182 intentionally adds no executable tooling. The rerun was performed from the v0.182 starting checkpoint and validates the current `main` posture.

## Performance

| Scenario | FPS average | p95 frame ms |
| --- | ---: | ---: |
| Ground-only opt-in | 75.26 | 13.02 |
| Ground + road opt-in | 75.50 | 12.64 |

Result:

- FPS ratio: `1.0032`.
- p95 worsening: `-2.92%`.
- Required threshold: FPS ratio `>= 0.90`, p95 worsening `<= 15%`.

Fallbacks:

- Missing road source: `missing source file`.
- Hash mismatch: `metadata hash mismatch`.
- Both fallbacks preserved the selected ground material and returned the road path to procedural fallback.

## Decision

The frozen environment-foundation posture is acceptable for human review. Do not add further environment-material slots until Emmanuel reviews this packet.
