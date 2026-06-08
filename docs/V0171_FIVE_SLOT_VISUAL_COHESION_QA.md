# v0.171 Salto Five-Slot Visual Cohesion QA

Status: `PASS_V0171_FIVE_SLOT_VISUAL_COHESION_QA`

This checkpoint reviews the already-selected five-slot Godot Salto opt-in posture after v0.170. It generates zero images, adds zero slots, preserves the default procedural launcher, preserves all prior opt-in launchers, and freezes additional character-slot integration before the environment-foundation phase.

## Scope

- Default procedural mode: `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat` and `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` remain procedural.
- Opt-in reviewed mode: Worker + Barracks + Militia + Aster + Ashen only.
- Character-slot count: frozen at five selected slots.
- Browser runtime: untouched.
- Player-facing integration: no new integration beyond the already-existing five opt-in slots.
- Cleanup: safe-only sidecar cleanup and retention verification only.

## Windows-Side Visual Review

Computer Use inspected the packaged Windows Godot app through title, briefing, and live battle:

- Title and briefing screens clearly identify the five-slot experimental opt-in mode.
- The live battle frame is usable and materially stronger than the earlier three-slot concern.
- Worker billboards read as small non-combatants instead of duplicate procedural bodies.
- Aster hierarchy is clear enough to identify the hero role at battle scale.
- The restrained Ashen Raider slot reads as a hostile character without overpowering the lane.
- The source-status overlay remains useful for identifying loaded art versus procedural fallback.
- No accidental procedural duplicate body was observed for the target art-backed characters.

Honest visual finding: the character-billboard posture is no longer the main quality bottleneck. The dominant weakness is now the procedural world shell: block-like terrain/roads/water/bridge/structure presentation, marker readability, and the relationship between environment shape and tactical lanes.

## Evidence

| Evidence | Status |
| --- | --- |
| `artifacts/desktop-spikes/godot-salto/v0170/capture/five-slot-art-opt-in-capture-report.json` | `PASS_V0170_ASHEN_OPT_IN_CAPTURE` |
| `artifacts/desktop-spikes/godot-salto/v0170/real-input/five-slot-art-opt-in-real-input-report.json` | `PASS_V0170_ASHEN_OPT_IN_REAL_INPUT` |
| `artifacts/desktop-spikes/godot-salto/v0170/boundary/five-slot-art-opt-in-boundary-report.json` | `PASS_V0170_ASHEN_OPT_IN_BOUNDARY` |
| `artifacts/desktop-spikes/godot-salto/v0171/artifact-cleanup/retention/salto-experimental-artifact-retention-report.json` | `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION` |

Representative capture paths:

- `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/01_title.png`
- `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/02_briefing.png`
- `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/03_battle_default.png`
- `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/09_squad_crowding.png`
- `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/10_camera_min_zoom.png`
- `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/11_camera_max_zoom.png`
- `artifacts/desktop-spikes/godot-salto/v0170/real-input/worker-barracks-militia-aster-ashen-post-mine-flow/screenshots/16_combat_onset.png`
- `artifacts/desktop-spikes/godot-salto/v0170/real-input/worker-barracks-militia-aster-ashen-post-mine-flow/screenshots/21_results.png`

## Interaction Coverage

The v0.170 five-slot real-input evidence remains valid and covers the v0.171 review target:

- Worker assignment: `PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE`.
- Barracks restoration: `PASS_BARRACKS_RESTORATION_PROOF`.
- Militia recruitment: `PASS_MILITIA_RECRUIT_PROOF`.
- Four-Ashen combat onset and wave resolution: `PASS_LUME_RESTORE_PROOF` plus post-mine screenshot manifest.
- Restart and replay integrity: `PASS_V0134_TRIPLE_NATURAL_PLAYTHROUGH`, `PASS_V0134_RECOVERY_CASES`, `PASS_V0134_RESTART_INTEGRITY`, `PASS_V0134_NO_SOFTLOCK_PROOF`, and `PASS_V0134_NO_SHORTCUT_PROOF`.
- Camera pan/zoom and minimap/HUD review: covered by the five-slot capture suite.

## Conclusion

The five selected character/material slots are coherent enough to freeze character-slot expansion. The next quality work should improve the procedural environment foundation: terrain hierarchy, roads, river, bridge, site markers, review framing, and tactical readability.
