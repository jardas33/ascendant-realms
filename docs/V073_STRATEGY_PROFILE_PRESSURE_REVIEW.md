# v0.7.3 Strategy Profile Pressure Review

Date: 2026-05-09

Status: Phase 5 strategy-profile review. This document combines the v0.7.3 browser-input observations with current simulator telemetry. It does not add or tune gameplay, maps, units, factions, rewards, saves, workers, enemy construction, economy AI, live reinforcements, capture-site contest AI, defensive holds, or broad systems.

## 1. Evidence Used

Controlled browser-input evidence:

- `docs/V073_CINDERFEN_CROSSING_REAL_INPUT_REVIEW.md`
- `docs/V073_CINDERFEN_WATCH_REAL_INPUT_REVIEW.md`

Simulator evidence:

- `PLAYTEST_TELEMETRY.md`
- `PLAYTEST_TELEMETRY.json`
- v0.7.2 strategy profile reviews

No true direct human manual pass was available in this environment. The browser evidence confirms that current warnings can be seen and read in controlled flows; it does not replace Emmanuel's manual playtest.

## 2. Current Pressure Snapshot

Pressure-enabled scoped Cinderfen runs: 75

Triggered pressure runs: 63

Quiet or untriggered pressure runs: 12

Warnings shown: 149

Simulated reinforcement applications: 0

Enemy-pressure analyzer warnings: none

Structural verdicts: no `too_easy`, no `too_hard`

This keeps v0.7.3 in the review lane rather than the tuning lane. Pressure is visible and safe enough to review, but not enough evidence exists to make it stronger.

## 3. Safe Beginner

Telemetry read:

| Node | Runs | Wins | Defeats | Timeouts | Pressure triggers |
| --- | ---: | ---: | ---: | ---: | ---: |
| Cinderfen Crossing | 13 | 13 | 0 | 0 | 13 |
| Cinderfen Watch | 12 | 12 | 0 | 0 | 12 |

Browser-input read:

- Crossing: the shrine reward status remained readable, and the delayed pressure warning stayed clear in the status surface.
- Watch: a right-click order naturally captured Watch Road, the immediate warning appeared early, and the delayed road warning stayed readable.

Feel decision:

Safe Beginner pressure looks fair. It teaches caution by connecting objective capture to enemy attention without producing defeats or blocking normal victory. No warning timing, status duration, or pressure-plan change is justified.

## 4. Greedy Economy

Telemetry read:

| Node | Runs | Wins | Defeats | Timeouts | Pressure triggers | Warnings | Avg first pressure |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Cinderfen Crossing | 13 | 1 | 0 | 12 | 13 | 38 | 0:35 |
| Cinderfen Watch | 12 | 3 | 0 | 9 | 12 | 33 | 0:07 |
| Total | 25 | 4 | 0 | 21 | 25 | 71 | - |

Browser-input read:

- Crossing pressure copy tells the player that enemy attention follows the shrine route.
- Watch pressure copy tells the player to protect income after claiming the raised-road toll.

Feel decision:

Greedy Economy still times out often, but this is a closure and build-order pacing read rather than an unfair pressure spike. There are 0 Greedy defeats on the pressure nodes, and pressure triggers in every Greedy pressure-node run. No timing or defeat-tip change is justified in Phase 5.

Manual watchpoint:

A human player may still need clearer Results guidance if greedy play feels like an opaque timeout. That should be judged through the manual checklist before changing copy.

## 5. Fast Army

Telemetry read:

| Node | Runs | Wins | Defeats | Timeouts | Pressure triggers | Warnings | Avg first pressure |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Cinderfen Crossing | 13 | 12 | 0 | 1 | 1 | 1 | 6:30 |
| Cinderfen Watch | 12 | 10 | 0 | 2 | 12 | 20 | 0:44 |
| Total | 25 | 22 | 0 | 3 | 13 | 21 | - |

Browser-input read:

- Crossing Fast Army bypass was not directly proven in the browser pass, but existing telemetry still shows it often wins before shrine-route pressure matters.
- Watch browser input showed a fast road capture still triggers pressure cleanly, which matches telemetry: Watch catches Fast Army pressure without turning it into a hard punishment.

Feel decision:

Fast Army remains acceptable strategy expression. Making pressure earlier or harsher to catch Crossing rushes would probably make pressure feel arbitrary for normal players. No tuning is justified.

Manual watchpoint:

The player should judge whether Crossing quick-clear feels clever or cheap. If it feels cheap, the first safe response is a future simulator-only experiment, not live reinforcement.

## 6. Retinue + Training Yard II

Telemetry read:

| Node | Script | Result | Duration | Pressure stages | First pressure | Warnings |
| --- | --- | --- | ---: | --- | ---: | ---: |
| Cinderfen Crossing | Safe Beginner | victory | 6:10 | Shrine route warning, Causeway contest timing | 4:42 | 2 |
| Cinderfen Crossing | Greedy Economy | victory | 4:39 | Shrine route warning, Causeway contest timing | 0:35 | 2 |
| Cinderfen Crossing | Fast Army | victory | 1:21 | none | - | 0 |
| Cinderfen Watch | Safe Beginner | victory | 5:39 | Watch road response, Raised-road pressure warning | 0:07 | 2 |
| Cinderfen Watch | Greedy Economy | victory | 4:39 | Watch road response, Raised-road pressure warning | 0:07 | 2 |
| Cinderfen Watch | Fast Army | victory | 1:16 | Watch road response | 0:44 | 1 |

Profile summary:

- 6 wins
- 0 defeats
- 0 timeouts
- 5 pressure-triggered runs
- 9 warnings
- 0 simulated reinforcement applications

Feel decision:

Retinue + Training Yard II makes current Cinderfen pressure mostly cosmetic, but this is a saved-progress power watchpoint rather than a pressure bug. The stacked profile includes earned saved units plus Training Yard I/II. Making Cinderfen pressure harsher for everyone to challenge this profile would likely punish ordinary players first.

Manual watchpoint:

Human play should decide whether this feels like earned dominance or boredom. If it becomes a problem, review retinue/Stronghold balance directly rather than buffing pressure.

## 7. Combined Decision

No Phase 5 gameplay, data, copy, timing, status-duration, defeat-tip, telemetry, e2e, balance, reward, save, map, unit, faction, worker, construction, economy AI, live reinforcement, capture-site contest AI, defensive-hold, or campaign progression change is justified.

Reason:

- Safe Beginner wins reliably while seeing pressure.
- Greedy Economy receives pressure warnings but times out without pressure-caused defeats.
- Fast Army can bypass Crossing pressure and still trigger Watch pressure, which preserves strategy expression.
- Retinue + Training Yard II is powerful, but the correct watchpoint is saved-progress balance, not pressure escalation.
- v0.7.3 browser-input observations found warnings readable, not broken.

## 8. Next Evidence Needed

The manual playtest should focus on:

- Whether Safe Beginner players notice the warning without looking for it.
- Whether Greedy players understand that delay and unspent bank are the problem.
- Whether Fast Army Crossing feels fun or too cheap.
- Whether Retinue + Training Yard II feels rewarding or boring.
- Whether any copy-only Results guidance is needed after actual human play.
