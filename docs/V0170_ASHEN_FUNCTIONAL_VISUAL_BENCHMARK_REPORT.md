# v0.170 Ashen Functional Visual Benchmark Report

Status: `PASS_V0170_ASHEN_OPT_IN_SUMMARY`

This report covers only the new fifth opt-in Ashen Raider player-slice path and its fallbacks.

## Gates

- Exact Ashen hash in M5 only: `PASS`.
- Missing-art fallback with other four slots active: `PASS`.
- Hash-mismatch fallback with other four slots active: `PASS`.
- Four-attacker wave readability: `PASS`.
- Militia-vs-Ashen clarity: `PASS`.
- Aster hierarchy: `PASS`.
- Worker non-combatant distinction: `PASS`.
- Hostile markers/rings: `PASS`.
- Overlap/sort and pan/zoom checks: `PASS`.
- Results/restart/replay: `PASS`.
- M5 FPS ratios vs M0/M4 `>= 0.90`: `PASS`.
- M5 p95 worsening vs M0/M4 `<= 15%`: `PASS`.

## Evidence Roots

- `artifacts/desktop-spikes/godot-salto/v0170/validation/`
- `artifacts/desktop-spikes/godot-salto/v0170/capture/`
- `artifacts/desktop-spikes/godot-salto/v0170/benchmark/`
- `artifacts/desktop-spikes/godot-salto/v0170/real-input/`
- `artifacts/desktop-spikes/godot-salto/v0170/computer-use/`
- `artifacts/desktop-spikes/godot-salto/v0170/scorecard/`

## Current Benchmark Result

`PASS_V0170_ASHEN_OPT_IN_BENCHMARK`

| Scenario | Expected | FPS avg | p95 ms | Loaded/requested slots |
| --- | --- | ---: | ---: | --- |
| M0 procedural baseline | procedural | 75.09 | 13.33 | 0/0 |
| M4 Worker + Barracks + Militia + Aster | four-loaded | 75.39 | 13.37 | 4/4 |
| M5 Worker + Barracks + Militia + Aster + Ashen | five-loaded | 75.33 | 13.34 | 5/5 |
| Ashen missing-art fallback | ashen-missing | 75.19 | 13.36 | 4/5 |
| Ashen hash-mismatch fallback | ashen-hash | 75.44 | 13.37 | 4/5 |

M5 ratios: FPS vs M0 `1.0032`, FPS vs M4 `0.9992`; p95 worsening vs M0 `1.0008`, p95 worsening vs M4 `0.9978`.

## Visual Review Result

`PASS_V0170_ASHEN_OPT_IN_COMPUTER_USE_REVIEW`

- Live Windows Godot battle window inspected through Computer Use: `artifacts/desktop-spikes/godot-salto/v0170/computer-use/windows-five-slot-review-battle.jpg`.
- Live Windows Godot title window evidence: `artifacts/desktop-spikes/godot-salto/v0170/computer-use/windows-five-slot-review-title-live.jpg`.
- First battle screenshot after repair: `artifacts/desktop-spikes/godot-salto/v0170/capture/worker-barracks-militia-aster-ashen/screenshots/03_battle_default.png`.
- Combat-onset screenshot with the four-Ashen wave: `artifacts/desktop-spikes/godot-salto/v0170/real-input/worker-barracks-militia-aster-ashen-post-mine-flow/screenshots/16_combat_onset.png`.
- The opening battle view no longer leaks unrecruited friendly military billboards; only Aster and Workers are visible before progression.
- Post-review five-slot screenshots use larger review-scale arguments for the already-selected Worker, Militia, Aster, and Ashen derivatives, plus softer review rings so the art reads before the guide markers.
- The squad-comparison review frame now stages Aster, Workers, and selected Militia in an open lane rather than under the foreground Barracks shell.
- The combat-onset view restores the defenders and shows four Ashen attackers with hostile markers/rings.

Computer Use advanced the rebuilt Windows executable through Start Salto Review into the battle screen; the regenerated capture and real-input artifacts remain the broader battle/combat evidence set.
