# v0.16.11 Exact-Final CI And Release Note

Date: 2026-05-22

## Baseline

- Starting commit: `7cc6eff95123c0dfa90d05a66d5a9305e1f44eff`
- Short commit: `7cc6eff`
- Commit message: `Checkpoint v0.16.10 release-candidate freeze and backlog triage`
- Starting package: `artifacts/playtest/ascendant-realms-private-playtest-7cc6eff`
- Branch state at intake: clean and synced with `origin/main`

## Exact-Final CI Status For `7cc6eff`

- Workflow: `CI Release Matrix Dry Run`
- Run number: `84`
- Run id: `26310892599`
- Trigger: `push`
- Status: completed
- Conclusion: success
- URL: `https://github.com/jardas33/ascendant-realms/actions/runs/26310892599`

Jobs:

| Job | Status | Conclusion | Notes |
| --- | --- | --- | --- |
| Fast confidence | completed | success | Unit tests, production build, content validation, art-intake validation, fast smoke, and production preview smoke passed. |
| Release simulator | completed | skipped | Push trigger. |
| Release matrix `${{ matrix.name }}` | completed | skipped | Push trigger. |
| Optional visual QA | completed | skipped | Push trigger. |
| Full release e2e | completed | skipped | Push trigger. |

No exact-final `workflow_dispatch` release matrix was found for `7cc6eff`.

## Matrix Evidence Still In Force

Run #80 remains the latest enabled workflow-dispatch release-matrix evidence for the post-v0.16.7 runtime combat/control stack:

- Run number: `80`
- Trigger: `workflow_dispatch`
- Commit: `ad4eee0a80a43f81df41ff30640a14f8434a5797`
- Status: completed
- Conclusion: success
- Passed enabled jobs: Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, smoke.
- Skipped jobs: Optional visual QA, Full release e2e.

Do not claim the manual release matrix passed on `7cc6eff`. The exact-final remote evidence is Fast confidence only.

## Release Note

The release-candidate package is ready for Emmanuel manual retest and small-batch tester launch prep, but the next confidence increase must come from human/manual testing. Additional autonomous code work should wait for a real manual failure, repeated tester evidence, or an explicitly opened v0.17 design goal.
