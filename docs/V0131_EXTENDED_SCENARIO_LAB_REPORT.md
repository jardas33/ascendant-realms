# v0.13.1 Extended Scenario Lab Report

Date: 2026-05-18

Scope: build Extended Automated Scenario Lab, Multi-Run Evidence, and Balance Regression Dashboard. This pass adds deeper deterministic tooling, generated reports, regression thresholds, dashboard outputs, tests, and documentation. It does not use or invent human tester feedback.

## What Was Built

New tooling:

- `src/game/playtest/ScenarioLabExtendedRunner.ts`
- `src/game/playtest/ScenarioLabExtendedReportWriter.ts`
- `src/game/playtest/ScenarioLabRegressionThresholds.ts`
- `src/game/playtest/ScenarioLabExtended.test.ts`

Extended metric fields added to quick lab rows:

- `primaryObjectiveCompleted`
- `pressureTriggered`
- `firstWaveSurvived`
- `lossesAfterPressure`

New scripts:

- `npm run playtest:lab:extended`
- `npm run playtest:watchpoints:extended`
- `npm run playtest:profiles:compare`
- `npm run playtest:lab:verify` (added by the v0.13.1a integrity pass)

CLI support:

- `--extended`
- `--watchpoints-only`
- `--runs`
- `--seed`
- `--output`
- `--json=false` / `--no-json`
- `--markdown=false` / `--no-markdown`
- `--compare` for profile comparison generation
- invalid `--runs` values now fail instead of silently falling back

## Outputs Generated

- `PLAYTEST_SCENARIO_LAB_EXTENDED.json`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.md`
- `PLAYTEST_PROFILE_COMPARISON.md`
- `PLAYTEST_PROFILE_COMPARISON.csv`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`
- `PLAYTEST_WATCHPOINTS_EXTENDED.md`

Quick v0.13 outputs remain separate:

- `PLAYTEST_SCENARIO_LAB.json`
- `PLAYTEST_SCENARIO_LAB.md`
- `PLAYTEST_WATCHPOINT_SUMMARY.md`
- `PLAYTEST_SCENARIO_PROFILES.json`
- `PLAYTEST_SCENARIO_PROFILES.md`

## Extended Run Size

Default extended batch:

- 5 deterministic iterations.
- 255 source simulator runs per iteration.
- 1,275 source simulator runs total.
- 355 derived profile-run metric rows per iteration.
- 1,775 derived extended metric rows total.
- 355 unique deterministic metric fingerprints.
- 10 regression watchpoints.

Important interpretation: the five iterations are deterministic repeatability checks. They are intentionally identical replays from the same simulator matrix, not random samples or independent player attempts.

## Tests Added

`src/game/playtest/ScenarioLabExtended.test.ts` covers:

- extended batch generation
- seed/iteration metadata
- profile comparison calculations
- profile x node x script aggregation
- node risk dashboard
- watchpoint threshold classifier
- required report sections
- no human-feedback claims
- quick lab shape remaining intact after extended runs
- generated JSON/Markdown/CSV artifact consistency through the v0.13.1a verifier

`npm run playtest:lab:verify` checks:

- required generated output files
- extended JSON shape and count consistency
- deterministic fingerprint counts
- profile and watchpoint coverage
- CSV and Markdown profile ranking agreement
- dashboard JSON and Markdown agreement
- unavailable metrics staying explicitly unavailable
- absence of forbidden human-feedback claim phrases

## Profile Comparison Summary

- Top-ranked stable profile: Mixed-Veterans.
- Strongest watchpoint profile: Retinue + Training Yard II.
- Weakest / most failure-prone profile: Greedy Economy.
- Fastest profile: Pressure-Ignoring.
- Fast Army remains decisive but mixed across the whole suite.
- Safe Beginner and No-Retinue remain structurally stable.

## Regression Dashboard Summary

- Biggest timeout risk: Ashen Outpost.
- Biggest pressure-risk signal: Cinderfen Watch.
- Highest loss-risk node: Bandit Hillfort, driven by aggressive/greedy profile rows.
- Cinderfen Crossing and Watch remain Safe Beginner stable.
- Objective completion and resource starvation are OK under current thresholds.

## Watchpoint Verdicts

| Watchpoint | v0.13.1 status | Verdict |
| --- | --- | --- |
| Retinue + Training Yard II dominance | Human testing required | Strong watchpoint, no automated nerf. |
| Greedy Economy collapse | Monitor | Conversion/time risk, no buff. |
| Fast Army trivialization | Monitor | Decisive but not a whole-suite sweep, no slowdown. |
| Early defeat spike | OK | No change. |
| Pressure warning fairness | Human testing required | Structurally actionable, noticeability unknown. |
| Cinderfen Crossing fairness | OK | No structural tuning. |
| Cinderfen Watch fairness | OK | No structural tuning. |
| Ashen Outpost timeout spike | OK | Monitor pacing/final assault. |
| Objective completion drop | OK | No change. |
| Resource starvation spike | OK | No change. |

## What Remains Unknown

- Human pressure-warning noticeability.
- Route fun and stress.
- Whether Retinue + Training Yard II feels earned or mandatory.
- Whether Greedy Economy feels clear.
- Whether Fast Army feels decisive or trivial.
- Whether Cinderfen visual debt changes play decisions.

## How Emmanuel Should Use This

Use v0.13.1 as an automated regression dashboard and route-priority map while waiting for real tester feedback.

Do not paste automated rows into human intake forms.

Do not run human-feedback triage until completed tester forms exist.

Do not tune gameplay numbers from this evidence alone.
