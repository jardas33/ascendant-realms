# v0.16.9 Baseline Status

Date: 2026-05-22

## Starting Point

- Branch: `main`
- Starting commit: `ad4eee0a80a43f81df41ff30640a14f8434a5797`
- Short commit: `ad4eee0`
- Commit message: `Checkpoint v0.16.8 post-combat-fix CI verification and soak audit`
- Branch state at intake: clean and synced with `origin/main`
- `git rev-list --left-right --count origin/main...HEAD`: `0 0`

## Prior Runtime Change

The most recent runtime gameplay change remains v0.16.7:

- Commit: `169bb21d54bd1599f5241b15bbfb1a187276d921`
- Scope: melee contact/reacquisition semantics, local melee enemy building aggro, retreat/move-away suppression reliability, and attack-hover/click hit tolerance.

v0.16.8 did not change runtime gameplay. It added soak evidence, control-lab coverage, CI/public-repo docs, one hosted smoke assertion stabilization, and a clean package.

## Documents Read

- `LLM_GAME_HANDOFF.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `CHANGELOG.md`
- `docs/V0167_EMMANUEL_MANUAL_RETEST_INTAKE.md`
- `docs/V0167_COMBAT_CONTACT_AGGRO_AUDIT.md`
- `docs/V0167_COMBAT_CONTACT_AGGRO_FIX_REPORT.md`
- `docs/V0167_COMBAT_CONTACT_AGGRO_REPRODUCTION_PLAN.md`
- `docs/V0167_DEFERRED_WORKER_CONSTRUCTION_NOTE.md`
- `docs/V0168_BASELINE_AND_REMOTE_CI_AUDIT.md`
- `docs/V0168_REMOTE_CI_VERIFICATION.md`
- `docs/V0168_CI_TRIAGE_FIX.md`
- `docs/V0168_COMBAT_FIX_SOAK_REPORT.md`
- `docs/V0168_CONTROL_LAB_V0167_COVERAGE_REVIEW.md`
- `docs/V0168_PUBLIC_REPO_SAFETY_AUDIT.md`
- `docs/V0168_EMMANUEL_RETEST_AFTER_V0167_CHECKLIST.md`
- `docs/V0168_LONG_SOAK_RESULTS.md`

## v0.16.9 Scope

This checkpoint is an automated evidence and tester-readiness pass. It is not v0.17 and not a feature pass.

Allowed work:

- inspect remote CI status
- strengthen deterministic manual-retest proxy coverage
- add automated combat edge-case matrix evidence
- prepare first external tester docs
- write worker construction design-only notes
- write visual/readability audit notes
- run required verification and package gates

Not changed in v0.16.9:

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

