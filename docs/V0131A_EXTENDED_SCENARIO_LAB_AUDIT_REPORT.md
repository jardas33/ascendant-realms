# v0.13.1a Extended Scenario Lab Audit Report

Date: 2026-05-18

Scope: integrity audit and gap-fix pass for v0.13.1 Extended Automated Scenario Lab.

## Adequacy Verdict

v0.13.1 was adequate as a real first extended lab implementation, but it had reporting integrity gaps that made it too easy to over-trust generated artifacts.

The implementation was real:

- Extended scripts ran the simulator.
- Counts came from generated data.
- JSON/Markdown reports contained real profile comparisons, node risk rows, and watchpoint classifications.
- Tests existed for the extended runner and reports.

The implementation was shallow in three places:

- No standalone generated-output verification command existed.
- CSV ordering did not match ranked Markdown ordering.
- Deterministic repetition was documented, but not strongly enough in the generated report shape.

## What Was Fixed

- Added `npm run playtest:lab:verify`.
- Added `src/game/playtest/ScenarioLabOutputValidation.ts`.
- Added `tools/verifyPlaytestLabOutputs.ts`.
- Extended tests now validate generated JSON, Markdown, and CSV artifacts together.
- CSV profile comparison rows now use the same ranked order as Markdown.
- Extended JSON now includes `uniqueDerivedMetricFingerprints`.
- Extended JSON/Markdown now include metric availability.
- Extended Markdown now states that five iterations are identical deterministic replays, not random samples.
- CLI `--runs` now rejects non-numeric, zero, negative, or greater-than-25 values.
- Threshold docs now include rationale for conservative status rules.

## Deliberately Not Changed

- Runtime gameplay.
- Gameplay numbers.
- Campaign data.
- Maps, factions, units, rewards, or save format.
- Runtime art/assets.
- Pressure behavior.
- Hosted release patterns.
- Human feedback intake.

## Final Output Counts

Expected final generated evidence:

- 5 deterministic iterations.
- 255 source simulator runs per iteration.
- 1,275 total source simulator runs.
- 355 derived profile-run metrics per iteration.
- 1,775 total derived profile-run metrics.
- 355 unique deterministic metric fingerprints.
- 10 regression watchpoints.
- 10 profile comparison rows.
- 7 node-risk rows.

## Final Profile Ranking

1. Mixed-Veterans.
2. One-Veteran.
3. Pressure-Ignoring.
4. Safe Beginner.
5. No-Retinue.
6. Baseline Cautious.
7. Objective-Rush.
8. Retinue + Training Yard II.
9. Fast Army.
10. Greedy Economy.

## Final Watchpoint Statuses

| Watchpoint | Status | Action |
| --- | --- | --- |
| Retinue + Training Yard II dominance | Human testing required | Test earned power before any tuning proposal. |
| Greedy Economy collapse | Monitor | Watch conversion/timing clarity; do not buff from automation alone. |
| Fast Army trivialization | Monitor | Watch Cinderfen speed feel; do not slow from speed alone. |
| Early defeat spike | OK | No change. |
| Pressure warning fairness | Human testing required | Automation cannot prove noticeability. |
| Cinderfen Crossing fairness | OK | No structural tuning. |
| Cinderfen Watch fairness | OK | No structural tuning. |
| Ashen Outpost timeout spike | OK | Monitor pacing/final assault. |
| Objective completion drop | OK | No change. |
| Resource starvation spike | OK | No change. |

## Remaining Limitations

- No human noticeability evidence.
- No fun/stress/frustration evidence.
- No final hero HP or base HP telemetry.
- No visual readability evidence.
- No stochastic variation or confidence intervals.
- Profile rows intentionally overlap source telemetry, so they are route evidence views rather than independent populations.

## Trust Decision

Trust v0.13.1/v0.13.1a for deterministic regression evidence and route-priority planning.

Do not trust it as human balance proof, stochastic statistics, or a tuning authorization.

## Recommended Next Action

Run real human playtests using the v0.12.6 tester packet. Use the v0.13.1a dashboard to prioritize routes, then ingest only completed real tester forms through the v0.12.5 intake hub.
