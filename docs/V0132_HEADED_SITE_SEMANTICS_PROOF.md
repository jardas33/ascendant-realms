# v0.132 Headed Site Semantics Proof

Status: `PASSED_PACKAGED_REAL_INPUT_PROOF`

## Required Pass Statuses

- `PASS_V0132_HEADED_SITE_SEMANTICS_SMOKE`.
- `PASS_V0132_SITE_SEMANTICS_SCREENSHOTS`.
- `PASS_MINE_CONVERSION_PROOF`.
- `PASS_WORKER_ASSIGNMENT_PROOF`.
- `PASS_OBJECTIVE_MONOTONICITY_PROOF`.
- `PASS_V0132_SITE_SEMANTICS_VALIDATION`.

Latest run: `npm run godot:headed:site-semantics-smoke` passed and generated the artifact packet under `artifacts/desktop-spikes/godot-salto/v0132/`.

## Computer Use Packaged-Window Pass

Codex also ran the real packaged build through Computer Use inside `AscendantRealmsGodotSalto.exe` only:

- clicked `Start Salto Review`;
- clicked `Start Battle`;
- selected visible Aster normally;
- right-clicked the highlighted `West Stone Cut Mine`;
- observed the move marker, Aster movement, Objective 3 conversion guidance, visible conversion progress, controlled-mine feedback, and no objective regression;
- selected the highlighted Worker normally;
- right-clicked the controlled `West Stone Cut Mine`;
- observed `Worker assigned; production boosted` and Objective 5 advancement.

## Required Captures

The v0.132 manifest records 15 captures:

1. battle initial view
2. canonical mine highlight
3. Aster selected
4. move marker
5. Aster inside capture radius
6. conversion progress 25 percent
7. conversion progress 75 percent
8. mine controlled
9. objective no regression
10. Worker highlight
11. Worker selected
12. Worker assignment right-click
13. Worker assignment feedback
14. production boost feedback
15. objective advanced after Worker assignment

## Evidence Boundary

The proof source is packaged Godot player-slice mouse input. Private-harness shortcuts, direct state mutation, scripted objective skipping, and screenshot-only evidence are not accepted.
