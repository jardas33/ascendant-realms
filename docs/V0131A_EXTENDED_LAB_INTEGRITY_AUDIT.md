# v0.13.1a Extended Lab Integrity Audit

Date: 2026-05-18

Baseline commit inspected: `1e59f8c` (`Checkpoint v0.13.1 extended scenario lab`).

Branch state at audit start: `main` clean and synced with `origin/main`.

Purpose: independently verify whether v0.13.1 is real tooling and useful evidence, then fix only genuine lab/reporting gaps.

## Files Inspected

- `LLM_GAME_HANDOFF.md`
- `package.json`
- `src/game/playtest/ScenarioLabTypes.ts`
- `src/game/playtest/ScenarioLabProfiles.ts`
- `src/game/playtest/ScenarioLabClassifier.ts`
- `src/game/playtest/ScenarioLabRunner.ts`
- `src/game/playtest/ScenarioLabReportWriter.ts`
- `src/game/playtest/ScenarioLabRegressionThresholds.ts`
- `src/game/playtest/ScenarioLabExtendedRunner.ts`
- `src/game/playtest/ScenarioLabExtendedReportWriter.ts`
- `src/game/playtest/ScenarioLabExtended.test.ts`
- `tools/runPlaytestLab.ts`
- `tools/runPlaytestProfiles.ts`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.json`
- `PLAYTEST_SCENARIO_LAB_EXTENDED.md`
- `PLAYTEST_PROFILE_COMPARISON.md`
- `PLAYTEST_PROFILE_COMPARISON.csv`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.md`
- `PLAYTEST_BALANCE_REGRESSION_DASHBOARD.json`
- `PLAYTEST_WATCHPOINTS_EXTENDED.md`
- `docs/V0131_SCENARIO_LAB_LIMITATIONS_AUDIT.md`
- `docs/V0131_NODE_RISK_DASHBOARD_SPEC.md`
- `docs/V0131_BALANCE_REGRESSION_THRESHOLDS.md`
- `docs/V0131_EXTENDED_AUTOMATED_EVIDENCE_REVIEW.md`
- `docs/V0131_TUNING_AND_ACTION_DECISION.md`
- `docs/V0131_EXTENDED_SCENARIO_LAB_REPORT.md`

## Integrity Verdict

v0.13.1 was a real implementation, not merely a docs pass.

Evidence:

- `playtest:lab:extended` calls `tools/runPlaytestLab.ts --extended --runs=5`.
- The extended tool calls `runExtendedScenarioLab`, which reruns `runScenarioLab()` per iteration.
- `runScenarioLab()` calls `runScriptedPlaytestSuite()` by default, so the source simulator is actually executed.
- Counts are computed from generated reports and metric arrays, not printed from static constants.
- Generated JSON contains full extended metric rows, profile comparisons, node risk rows, regression watchpoints, and dashboard JSON.

## Immediate Concerns Found

The audit found real gaps:

- The five extended iterations are identical deterministic reruns. This is acceptable for repeatability, but it must not be described as stochastic variation.
- `PLAYTEST_PROFILE_COMPARISON.csv` was in profile-catalog order while Markdown was ranked order.
- No standalone generated-output verifier existed, so stale or inconsistent report artifacts could be committed.
- The extended JSON did not expose metric-availability metadata, even though unavailable metrics are important to the no-fake-evidence guardrail.
- CLI `--runs` accepted invalid values by silently falling back/defaulting through helper behavior.

## Fix Scope

This pass fixes tooling/reporting integrity only:

- Add generated-output validation.
- Align CSV and Markdown ranking order.
- Expose deterministic fingerprint and metric-availability data in generated reports.
- Harden CLI run-count validation.
- Improve deterministic-repeatability wording and threshold rationale docs.

No runtime gameplay, gameplay numbers, maps, factions, units, saves, art, campaign data, pressure behavior, or release-lane behavior should change.
