# v0.13.1a Script And Output Verification

Date: 2026-05-18

Scope: verify what each scenario-lab script executes, what it writes, whether it runs simulation, and whether counts are computed honestly.

## Script Findings

| Script | Entry point | Simulation path | Outputs | Verdict |
| --- | --- | --- | --- | --- |
| `npm run playtest:lab` | `tsx tools/runPlaytestLab.ts` | Calls `runScenarioLab()`, which defaults to `runScriptedPlaytestSuite()` | `PLAYTEST_SCENARIO_LAB.json`, `PLAYTEST_SCENARIO_LAB.md`, `PLAYTEST_WATCHPOINT_SUMMARY.md` | Real quick lab generation |
| `npm run playtest:watchpoints` | `tsx tools/runPlaytestLab.ts` | Same as quick lab | Same as quick lab, including watchpoint summary | Real, but intentionally regenerates full quick lab |
| `npm run playtest:profiles` | `tsx tools/runPlaytestProfiles.ts` | Does not run battle simulation; writes the static typed profile catalog | `PLAYTEST_SCENARIO_PROFILES.json`, `PLAYTEST_SCENARIO_PROFILES.md` | Correct profile catalog generation |
| `npm run playtest:lab:extended` | `tsx tools/runPlaytestLab.ts --extended --runs=5` | Calls `runExtendedScenarioLab()`, which reruns `runScenarioLab()` per iteration | Extended lab JSON/Markdown, dashboard JSON/Markdown, profile comparison Markdown/CSV, extended watchpoints | Real extended generation |
| `npm run playtest:watchpoints:extended` | `tsx tools/runPlaytestLab.ts --extended --watchpoints-only --runs=5` | Calls full extended lab in memory, then writes watchpoints only | `PLAYTEST_WATCHPOINTS_EXTENDED.md` | Real watchpoint regeneration |
| `npm run playtest:profiles:compare` | `tsx tools/runPlaytestProfiles.ts --compare --runs=5` | Calls `runExtendedScenarioLab()` to compute profile comparisons | `PLAYTEST_PROFILE_COMPARISON.md`, `PLAYTEST_PROFILE_COMPARISON.csv` | Real comparison generation |
| `npm run playtest:lab:verify` | `tsx tools/verifyPlaytestLabOutputs.ts` | Does not regenerate; validates checked-in generated artifacts | Validation output only | Added in v0.13.1a |

## Count Verification

Counts are computed from generated data:

- `totalSourceRuns` sums each iteration's `sourceRunCount`.
- `totalDerivedMetrics` is the `extendedRunMetrics.length`.
- `watchpointRegressions.length` is the generated threshold-classifier result.
- `uniqueDerivedMetricFingerprints` is computed from metric identity excluding iteration/run labels.

The current extended output should verify as:

- 5 iterations.
- 255 source simulator runs per iteration.
- 1,275 total source simulator runs.
- 355 derived profile-run metrics per iteration.
- 1,775 total derived profile-run metrics.
- 355 unique deterministic metric fingerprints.
- 10 regression watchpoints.

## Gap Found And Fixed

The original v0.13.1 outputs were internally useful but not fully protected:

- CSV profile rows did not match the ranked Markdown order.
- Generated artifacts had no separate verification command.
- Metric availability was present in quick reports but not carried into extended JSON/Markdown.
- Invalid `--runs` input could be accepted too quietly.

v0.13.1a adds `playtest:lab:verify` to check generated JSON, Markdown, and CSV consistency before commit.
