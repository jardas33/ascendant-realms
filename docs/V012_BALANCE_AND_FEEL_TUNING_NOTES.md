# v0.12 Balance And Feel Tuning Notes

Date: 2026-05-16

Scope: Phase 4 evidence note for the v0.12 Core Game Feel and Battle Readability Pass. This pass used simulator/playtest evidence before changing numbers. It deliberately avoided broad balance changes because the safe implementation slice was mostly feedback, status priority, HUD hierarchy, objective copy, pressure copy, and result guidance.

## Summary

No numeric gameplay tuning was applied in v0.12.

The simulator still reports:

- 255 deterministic runs across 85 campaign battle node/profile summaries.
- 0 structural `too_easy` nodes.
- 0 structural `too_hard` nodes.
- 0 Stronghold warnings.
- 0 enemy-pressure balance warnings.
- Ashen Outpost remains beatable.

The simulator does still recommend human review for strategy-spread and attrition cases, especially stronger retinue/Stronghold profiles and some Greedy Economy / Fast Army outcomes. Those remain balance-review leads, not proof that v0.12 should flatten challenge.

## Observed Metrics

| Metric observed | Player-facing issue | Tuning change | Expected effect | Risk | Test / simulator result |
| --- | --- | --- | --- | --- | --- |
| Command feedback could be overwritten by income ticks. | Valid move/build/train/research/rally/ability commands felt easy to miss. | No unit, resource, timing, cooldown, or enemy-number changes. Added command-priority status/read-window changes instead. | Player reads accepted commands without changing battle difficulty. | Low; status-priority tests and smoke/deep coverage protect it. | `npm test` and browser lanes protect behavior; final run recorded in `docs/V012_CORE_GAME_FEEL_PASS_REPORT.md`. |
| Pressure-enabled Cinderfen runs still show timeouts for some scripted strategies but no structural too-hard warning. | Enemy pressure can feel sudden if the player does not know the counterplay. | No pressure timing, reinforcement, contest, defensive hold, worker, economy, or construction change. Copy now names counterplay. | Warnings feel fairer while keeping scoped V1 pressure semantics. | Low; exact warning-copy tests updated. | `npm run playtest:sim` remains 255 runs / 85 summaries, 0 pressure balance warnings. |
| Retinue + Training Yard II remains a strong Chapter 2 watchpoint. | Strong player preparations can overperform in Cinderfen. | No retinue, veterancy, Training Yard, Quartermaster, or enemy stat tuning. | Avoids nerfing a profile without human play evidence. | Low; unchanged mechanics. | Simulator keeps the profile as a human-review watchpoint rather than a structural `too_easy` flag. |
| Greedy Economy and Fast Army still show timeout/readability signals in some Cinderfen paths. | Failure can read like unclear pacing rather than earned attrition. | No campaign difficulty reduction. Improved pressure/objective/result language. | Player gets clearer route sequencing before any numeric pass. | Low; copy-only. | Simulator suggests conservative future review, not immediate numeric changes. |

## Rationale

The v0.12 target was game feel/readability, not a balance flattening pass. The safest high-value changes were to make existing commands, objectives, pressure warnings, selected orders, and results more legible. Numeric movement, cooldown, wave, reward, retinue, and enemy changes were deferred because the current structural evidence does not prove unfairness.

## Deferred Tuning

- Movement acceleration / arrival feel: deferred because current `Moving` and pathing assertions remain green and no playtest evidence isolated acceleration as the core issue.
- Enemy wave timing: deferred because pressure-node timeouts are strategy/readability watchpoints, not structural defeat spikes.
- Early campaign difficulty: deferred because the simulator reports no structural `too_hard` nodes.
- Retinue + Training Yard II strength: deferred to human-paced review.
- Fast Army quick-clear feel: deferred; no default campaign nerf without direct play evidence.
- Greedy Economy timeout clarity: addressed through copy/readability only, with numeric changes deferred.

## Next Tuning Gate

Run a human-paced playtest focused on Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch with:

- no retinue,
- one Veteran unit,
- mixed retinue,
- Training Yard II,
- Quartermaster II,
- Safe Beginner / Greedy Economy / Fast Army routes.

Only after that evidence should a future pass consider numeric tuning.
