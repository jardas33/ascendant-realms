# v0.13 Automated Playtest Scenario Lab Report

Date: 2026-05-18

Scope: build Automated Playtest Scenario Lab And Balance Telemetry V1. This pass adds deterministic tooling, generated reports, watchpoint classification, and tests. It does not use or invent human tester feedback.

## What Was Built

New scenario-lab tooling:

- `src/game/playtest/ScenarioLabTypes.ts`
- `src/game/playtest/ScenarioLabProfiles.ts`
- `src/game/playtest/ScenarioLabRunner.ts`
- `src/game/playtest/ScenarioLabClassifier.ts`
- `src/game/playtest/ScenarioLabReportWriter.ts`
- `src/game/playtest/ScenarioLab.test.ts`
- `tools/runPlaytestLab.ts`
- `tools/runPlaytestProfiles.ts`

New scripts:

- `npm run playtest:lab`
- `npm run playtest:watchpoints`
- `npm run playtest:profiles`

Generated outputs:

- `PLAYTEST_SCENARIO_LAB.json`
- `PLAYTEST_SCENARIO_LAB.md`
- `PLAYTEST_WATCHPOINT_SUMMARY.md`
- `PLAYTEST_SCENARIO_PROFILES.json`
- `PLAYTEST_SCENARIO_PROFILES.md`

## Profile List

- Baseline Cautious.
- No-Retinue.
- One-Veteran.
- Mixed-Veterans.
- Retinue + Training Yard II.
- Greedy Economy.
- Fast Army.
- Pressure-Ignoring.
- Objective-Rush.
- Safe Beginner.

## Metrics Tracked

Available or derived:

- win/loss/timeout
- failure reason
- battle node
- automated profile
- clear time
- army survival
- unit losses
- units trained
- resource surplus
- final/peak Aether
- objective completion count
- pressure warnings
- pressure reaction window when measurable
- retinue marker
- Training Yard II marker
- Greedy Economy marker
- Fast Army marker
- route verdict
- confidence level

Unavailable and not faked:

- human noticeability
- human confusion
- fun
- final hero HP/death
- base HP/base damage
- visual readability

## Automated Evidence Summary

The scenario lab generated:

- 10 profile summaries.
- 355 derived profile-run metrics.
- 7 node-risk summaries.
- 8 watchpoint classifications.

Current automated strongest watchpoint profile:

- Retinue + Training Yard II.

Current weakest / most failure-prone route:

- Greedy Economy.

Fastest profile:

- Pressure-Ignoring, a narrow proxy that uses Fast Army on pressure-enabled Cinderfen nodes.

## Watchpoint Verdicts

| Watchpoint | Automated action | Summary |
| --- | --- | --- |
| Retinue + Training Yard II | needs human testing | Strongest and very clean on Ashen/Cinderfen, but not a whole-suite sweep. |
| Greedy Economy | monitor | Fails through timing/conversion, with first wave survived in Greedy runs. |
| Fast Army | monitor | Decisive in Cinderfen but still has broad-suite failures. |
| Early defeats | no change | Early nodes have no defeats in the automated evidence. |
| Pressure fairness | needs human testing | Structurally actionable, but noticeability is unknown. |
| Cinderfen Crossing fairness | no change | Safe Beginner wins all current rows; route feel remains human-test work. |
| Cinderfen Watch fairness | no change | Safe Beginner wins all current rows; pressure noticeability remains human-test work. |
| Ashen Outpost stability | monitor | Beatable and stable for safe play, but timeouts keep it a pacing watchpoint. |

## Why Human Testing Is Still Needed

The lab can show structural timing, losses, wins, timeouts, resources, and warning counts. It cannot show:

- whether a player noticed a warning
- whether pressure text was readable during combat
- whether a victory felt earned
- whether a defeat felt fair
- whether ugly art blocked understanding
- whether the route was fun

## Future Goal Guidance

v0.13.1 follow-up: the extended automated lab now lives in `docs/V0131_EXTENDED_SCENARIO_LAB_REPORT.md`, with generated dashboard outputs in `PLAYTEST_SCENARIO_LAB_EXTENDED.md`, `PLAYTEST_PROFILE_COMPARISON.md`, `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`, and `PLAYTEST_WATCHPOINTS_EXTENDED.md`. Those outputs deepen deterministic regression evidence, but they still are not human feedback.

Next recommended long goal: run real human playtests using the v0.12.6 packet, then use v0.12.5 intake to classify completed forms. Use v0.13 automated evidence as prioritization context, not as a substitute for real feedback.

Priority human tests:

1. Retinue + Training Yard II through Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch.
2. Greedy Economy with notes on resource-to-army conversion.
3. Fast Army through Cinderfen to judge whether speed trivializes or simply rewards decisiveness.
4. Pressure warning noticeability in real combat stress.
5. Ashen Outpost pacing and final-assault clarity.

## Runtime / Tuning Decision

No runtime gameplay code changed.

No gameplay numbers changed.

No tuning was made.

No human feedback was used.
