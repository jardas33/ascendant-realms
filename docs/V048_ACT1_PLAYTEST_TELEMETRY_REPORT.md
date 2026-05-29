# v0.48 Act 1 Playtest Telemetry Report

## Evidence Type

This report summarizes deterministic scripted simulator evidence from `npm run playtest:act1`. The machine-readable artifacts are:

- `ACT1_PLAYABILITY_TELEMETRY.json`
- `ACT1_PLAYABILITY_TELEMETRY.md`

The data is useful for structural timing and failure-pattern checks. It is not human fun, stress, readability, or audio evidence.

## Summary

- Source simulator: Ascendant Realms deterministic scripted playtest v3.
- Source runs: 255.
- Act 1 campaign battle runs: 180.
- Tutorial / Proving Grounds: intentionally excluded from persistent campaign telemetry; remains no-save/no-reward.
- Safe Beginner wins every Act 1 campaign node.
- Numeric tuning recommendation: no numeric tuning from simulator evidence alone.
- Copy polish recommendation: remind players to stabilize economy, production, army staging, skills, and relics before harder pushes.

## Act 1 Node Read

| Step | Node | Record | Avg duration | First site | First building | First combat | Avg losses | Verdict |
| ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 2 | Border Village | 36-0-0 | 4:08 | 0:22 | 1:27 | 3:53 | 0.6 | stable_forgiving |
| 3 | Old Stone Road | 36-0-0 | 4:11 | 0:22 | 1:27 | 3:24 | 1.4 | stable |
| 4 | Aether Well Ruins | 12-12-12 | 9:59 | 0:23 | 1:27 | 3:54 | 4.9 | watch_strategy_spread |
| 5 | Bandit Hillfort | 12-23-1 | 9:10 | 0:23 | 1:26 | 4:20 | 6.3 | watch_strategy_spread |
| 6 | Ashen Outpost | 22-0-14 | 9:39 | 0:21 | 1:27 | 4:10 | 2.9 | watch_strategy_spread |

## Script Spread

| Node | Safe Beginner | Greedy Economy | Fast Army | Read |
| --- | ---: | ---: | ---: | --- |
| Border Village | 12-0-0 | 12-0-0 | 12-0-0 | First persistent battle is forgiving. |
| Old Stone Road | 12-0-0 | 12-0-0 | 12-0-0 | Base-development step is stable. |
| Aether Well Ruins | 12-0-0 | 0-0-12 | 0-12-0 | Strategy spread, not opening-pressure failure. |
| Bandit Hillfort | 12-0-0 | 0-11-1 | 0-12-0 | Strategy spread and commander/army attrition. |
| Ashen Outpost | 12-0-0 | 3-0-9 | 7-0-5 | Clear-speed/staging spread after champion progress. |

## Failure Cause Read

- Border Village: no non-victory runs.
- Old Stone Road: no non-victory runs.
- Aether Well Ruins: 12 army attrition defeats and 12 post-commander clear-speed timeouts.
- Bandit Hillfort: 12 army attrition defeats, 11 commander attrition defeats, and 1 post-commander clear-speed timeout.
- Ashen Outpost: 14 post-commander clear-speed timeouts.

## Tuning Decision

No gameplay number changed from this report. The data supports copy/onboarding polish because the safe route clears every Act 1 battle, first combat is not immediate, and failures concentrate in greedy/rushed scripts. Harder nodes should tell players to stabilize production, assign Workers to sites, stage a mixed army, spend skill points, equip relics, and push after waves rather than quietly lowering enemy pressure.

## Follow-Up Watchpoints

- Aether Well Ruins: human testers should confirm whether resource-control copy is enough to avoid center-rush frustration.
- Bandit Hillfort: human testers should confirm commander pressure reads as a staging lesson, not a surprise spike.
- Ashen Outpost: human testers should confirm the relic/skill reminder helps players prepare before replay and Chapter 2.
