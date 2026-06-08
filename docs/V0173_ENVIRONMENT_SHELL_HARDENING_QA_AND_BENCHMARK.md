# v0.173 Environment Shell Hardening QA And Benchmark

Status: `PASS_V0173_ENVIRONMENT_SHELL_HARDENING_QA_AND_BENCHMARK`

v0.173 adds a review-only procedural environment-foundation posture behind `GODOT_REVIEW_SALTO_ENVIRONMENT_FOUNDATION_WINDOWS.bat`. It preserves the existing five selected Worker, Barracks, Militia, Aster, and Ashen opt-in slots and adds zero images, zero terrain imports, and zero runtime-art slots.

## Visual Findings

Baseline evidence used the retained v0.170/v0.171 five-slot screenshots, including `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/03_battle_default.png` and `09_squad_crowding.png`.

The v0.173 E1 review path materially improves the weak procedural world shell:

- Main road width, shoulders, and wet-granite ticks now read as a deliberate tactical lane instead of a thin placeholder strip.
- River water, banks, ford, and bridge deck are more separated by value and silhouette.
- Mine, Barracks, and Command Hall have clearer ground plates and contact shadows, reducing the floating-unit feeling.
- Site markers have an outer claim collar and state ticks, improving readability without changing objective semantics.
- The five-slot character/material posture remains visible and functional alongside the environment layers.

Remaining honest limitation: this is still a procedural blockout shell. The next bounded pass should refine road/river/bridge/site-marker tactical readability rather than start terrain-material integration.

## Windows-Side Review

Computer Use review launched the packaged `AscendantRealmsGodotSalto-v0173.exe` through the v0.173 review posture and inspected title, briefing, and live battle states.

Result:

- Title and briefing clearly label `Experimental opt-in art: Worker + Barracks + Militia + Aster + Ashen + environment`.
- Live battle renders the five selected character/material slots with the review-only procedural environment layers.
- Roads, river banks, bridge, structure plates, site collars, minimap, HUD, and selection feedback remain visible at review distance.
- No default procedural launcher or prior opt-in launcher was used or mutated during this review.

`PASS_V0173_ENVIRONMENT_FOUNDATION_COMPUTER_USE_REVIEW`

## Captures

Capture report: `artifacts/desktop-spikes/godot-salto/v0173/capture/environment-foundation-capture-report.json`

Contact sheet: `artifacts/desktop-spikes/godot-salto/v0173/capture/v0173-environment-foundation-contact-sheet.svg`

Required capture IDs were emitted for both M5 baseline and E1 environment foundation: full battlefield, roads, river/banks, bridge, mine before/after conversion, Barracks restoration/restored, Command Hall, site markers, five-slot coexistence, combat posture, minimap, pan camera, zoom camera, min zoom, and max zoom.

Representative after captures:

- `artifacts/desktop-spikes/godot-salto/v0173/capture/e1-environment-foundation/screenshots/03_battle_default_full_battlefield.png`
- `artifacts/desktop-spikes/godot-salto/v0173/capture/e1-environment-foundation/screenshots/04_road_network.png`
- `artifacts/desktop-spikes/godot-salto/v0173/capture/e1-environment-foundation/screenshots/06_bridge_crossing.png`
- `artifacts/desktop-spikes/godot-salto/v0173/capture/e1-environment-foundation/screenshots/13_five_slot_coexistence.png`
- `artifacts/desktop-spikes/godot-salto/v0173/capture/e1-environment-foundation/screenshots/14_combat_posture.png`

## Benchmark

Benchmark scorecard: `artifacts/desktop-spikes/godot-salto/v0173/benchmark/environment-foundation-benchmark-scorecard.json`

| Scenario | FPS avg | p95 frame ms |
| --- | ---: | ---: |
| M5 five-slot baseline | `75.22` | `13.28` |
| E1 environment foundation | `75.06` | `13.52` |

Result:

- FPS ratio: `0.9979`, passing the required `>= 0.90`.
- p95 worsening: `1.81%`, passing the required `<= 15%`.

## Gate

- Validation: `PASS_V0173_ENVIRONMENT_FOUNDATION_VALIDATION`.
- Capture: `PASS_V0173_ENVIRONMENT_FOUNDATION_CAPTURE`.
- Benchmark: `PASS_V0173_ENVIRONMENT_FOUNDATION_BENCHMARK`.
- Boundary: `PASS_V0173_ENVIRONMENT_FOUNDATION_BOUNDARY`.
- Retention: `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`.
- Windows app review: `PASS_V0173_ENVIRONMENT_FOUNDATION_COMPUTER_USE_REVIEW`.

`PASS_V0173_ENVIRONMENT_SHELL_HARDENING_QA_AND_BENCHMARK`
