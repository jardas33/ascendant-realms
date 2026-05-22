# v0.16.10 Release-Candidate Baseline

Date: 2026-05-22

## Starting Point

- Branch: `main`
- Starting commit: `83f146e1a0c9a4092a0457c504e4f3d767078c01`
- Short commit: `83f146e`
- Commit message: `Checkpoint v0.16.9 autonomous manual-retest proxy and tester readiness`
- Branch state at intake: clean and synced with `origin/main`
- `git rev-list --left-right --count origin/main...HEAD`: `0 0`

## Current Evidence

- v0.16.7 is the latest runtime combat/control change.
- v0.16.8 and v0.16.9 added verification, soak, deterministic proxy coverage, tester docs, and package validation.
- GitHub Actions run #80 was a `workflow_dispatch` run on `ad4eee0` and passed the enabled release-matrix lanes.
- GitHub Actions run #83 was a push run on `83f146e` and passed Fast confidence.
- Package `artifacts/playtest/ascendant-realms-private-playtest-83f146e` existed, was clean, and passed package verification.

## Documents Read

- `LLM_GAME_HANDOFF.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `RELEASE_CHECKLIST.md`
- `docs/V0169_BASELINE_STATUS.md`
- `docs/V0169_REMOTE_RELEASE_MATRIX_STATUS.md`
- `docs/V0169_AUTONOMOUS_MANUAL_RETEST_PROXY_SPEC.md`
- `docs/V0169_AUTONOMOUS_MANUAL_RETEST_PROXY_REPORT.md`
- `docs/V0169_COMBAT_EDGE_CASE_MATRIX.md`
- `docs/V0169_FIRST_EXTERNAL_TESTER_PLAN.md`
- `docs/V0169_TESTER_MESSAGE_SHORT.md`
- `docs/V0169_TESTER_FEEDBACK_FORM_SHORT.md`
- `docs/V0169_ROUTE_ASSIGNMENTS_SMALL_BATCH.md`
- `docs/V0169_WORKER_CONSTRUCTION_DESIGN_BRIEF.md`
- `docs/V0169_CONTROL_VISUAL_READABILITY_AUDIT.md`
- `docs/V0169_LONG_SOAK_REPORT.md`

## Scope

v0.16.10 is a release-candidate freeze, backlog triage, public-safety check, and tester-kit polish pass.

Not changed in this pass:

- runtime gameplay
- gameplay numbers
- unit stats
- enemy wave timings
- save format
- runtime art/assets
- units, buildings, maps, factions
- worker construction implementation
- Patrol runtime or formations
- broad AI/pathing
