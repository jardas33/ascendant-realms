# v0.188 Environment-Shell Full Cohesion QA

Status: `PASS_V0188_ENVIRONMENT_SHELL_FULL_COHESION_QA`

Scope: Windows-side cohesion review of the current Godot Salto opt-in battlefield shell after v0.187. This pass uses zero images, adds zero slots, changes no runtime code, keeps the default launcher procedural, keeps all prior opt-in launchers available, keeps browser runtime untouched, and preserves gameplay, pathing, collisions, objectives, AI, saves, stable IDs, selected art, metadata, fallbacks, and required evidence.

## Reviewed Posture

Reviewed:

- Default procedural comparison path.
- Explicit `GODOT_REVIEW_SALTO_RIVERBANK_BRIDGE_APPROACH_WINDOWS.bat` posture.
- Existing five selected character/material slots.
- Existing Barrosan foothold ground material and road material opt-ins.
- Procedural terrain shell, road continuity, river continuity, bridge crossing, bridge approaches, hardened structures, tactical markers, HUD, minimap, title, briefing, battle, and Results.
- Existing fallback/playthrough automation for Worker assignment, Barracks restoration, Militia recruitment, box-select, four-Ashen combat, restart, replay, recoverable mistake, pan/zoom, and minimap.

Representative evidence:

- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0187/capture/v0187-riverbank-bridge-approach-contact-sheet.svg`
- Tactical overview: `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/03_full_overview.png`
- Bridge close review: `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/08_bridge_close.png`
- Combat crossing posture: `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/12_combat_crossing_posture.png`
- Minimap review: `artifacts/desktop-spikes/godot-salto/v0187/capture/r1-riverbank-bridge-approach/screenshots/15_minimap.png`

## Visual Findings

The current shell is coherent enough to freeze for Emmanuel review:

- The overall Barrosan foothold mood is readable: damp dark ground, restrained road material, muted water, practical structures, and heavier crossing massing now point in one direction.
- Terrain masks no longer read primarily as diagnostic overlays at normal RTS distance.
- Road continuity is acceptable through the main lane and bridge approach; the road material remains distinct from the ground material.
- River continuity is acceptable after the v0.187 channel and bank shaping pass.
- The bridge reads as the crossing point because deck, rail, abutment, landing-shadow, and road-contact cues are visible.
- Structure massing is still primitive, but Command Hall, mine, Barracks/restoration area, and smaller site elements now have a clearer hierarchy.
- Character grounding is readable enough for Aster, Worker, Militia, Ashen, and mixed combat review.
- Tactical markers and selection rings remain visible without swallowing the scene.
- Minimap correlation remains clear after pan/zoom and bridge/crossing review.

Remaining visible weakness is honest prototype debt, not an unexpected v0.188 blocker:

- Some block-like elements are intentional procedural terrain, shell masses, tactical markers, rings, and future-scope placeholders.
- Structures remain simplified primitive shells.
- The bridge and banks are still procedural geometry without final wet-stone material.
- Lighting, water treatment, and HUD foundation are still future bounded phases.

No accidental duplicate procedural-unit rendering, fallback visibility defect, or boundary-breaking visual mutation was observed.

## Computer Use Review

Windows-side live review covered:

- Title screen with the explicit opt-in label visible and not clipped.
- Briefing screen readability.
- Battle start in the current opt-in shell.
- Aster selection and movement smoke using normal input.
- Bridge-adjacent order feedback.
- Camera pan/zoom smoke.
- Minimap correlation.

Automated headed gates covered the longer flow:

- Worker assignment.
- Barracks restoration.
- Militia recruitment.
- Box-select.
- Four-Ashen combat onset and wave defeat.
- Lume restoration.
- Results.
- Restart.
- Replay.
- Recoverable mistake handling.
- Browser/runtime unchanged and save/stable-ID boundaries.

## Performance

Current v0.187 R1 shell benchmark against the S1 structure-shell baseline:

| Scenario | FPS average | p95 frame ms |
| --- | ---: | ---: |
| S1 structure-shell baseline | 75.24 | 13.95 |
| R1 riverbank/bridge approach shell | 75.01 | 13.70 |

Result:

- FPS ratio: `0.9969`.
- p95 worsening: `-1.79%`.
- Required threshold: FPS ratio `>= 0.90`, p95 worsening `<= 15%`.
- Status: `PASS_V0187_RIVERBANK_BRIDGE_APPROACH_BENCHMARK`.

## Runtime Gates

Passed in this v0.188 review:

```text
PASS: npm run godot:validate:salto-riverbank-bridge-approach
PASS: npm run godot:validate:salto-ground-road-material-opt-in
PASS: npm run godot:validate:salto-five-slot-art-experiment
PASS: npm run godot:headed:post-mine-flow-smoke
PASS: npm run godot:headed:triple-natural-playthrough
PASS: PASS_V0187_SALTO_RIVERBANK_BRIDGE_APPROACH_AUTOMATION_READY
PASS: PASS_V0181_SALTO_GROUND_ROAD_MATERIAL_OPT_IN_AUTOMATION_READY
PASS: PASS_V0170_WORKER_BARRACKS_MILITIA_ASTER_ASHEN_ART_OPT_IN_AUTOMATION_READY
PASS: PASS_V0133_POST_MINE_FLOW_VALIDATION
PASS: PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH_VALIDATION
```

## Freeze Recommendation

Freeze procedural shell work for Emmanuel manual review. Do not add a new material slot or start bridge/riverbank material integration until the freeze packet is reviewed.

Recommended next bounded direction, if approved separately: private-comparator-only bridge/riverbank wet-granite material intake. Do not integrate that source into the player-facing slice during the intake step.
