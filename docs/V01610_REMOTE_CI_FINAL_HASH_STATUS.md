# v0.16.10 Remote CI Final-Hash Status

Date: 2026-05-22

Repository: `jardas33/ascendant-realms`

## Exact v0.16.9 Final Hash

- Commit: `83f146e1a0c9a4092a0457c504e4f3d767078c01`
- Workflow: `CI Release Matrix Dry Run`
- Run number: `83`
- Run id: `26308879618`
- Trigger: `push`
- Status: completed
- Conclusion: success
- URL: `https://github.com/jardas33/ascendant-realms/actions/runs/26308879618`

Jobs:

| Job | Status | Conclusion | Notes |
| --- | --- | --- | --- |
| Fast confidence | completed | success | Unit tests, build, validators, fast smoke, and production preview smoke passed. |
| Release simulator | completed | skipped | Push trigger. |
| Release matrix `${{ matrix.name }}` | completed | skipped | Push trigger. |
| Optional visual QA | completed | skipped | Push trigger. |
| Full release e2e | completed | skipped | Push trigger. |

No `workflow_dispatch` release matrix was found for exact commit `83f146e`.

## Nearby Manual Matrix Evidence

- Run number: `80`
- Trigger: `workflow_dispatch`
- Commit: `ad4eee0a80a43f81df41ff30640a14f8434a5797`
- Status: completed
- Conclusion: success
- Passed jobs: Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, smoke.
- Skipped jobs: Optional visual QA, Full release e2e.

Meaning: run #80 validates the post-v0.16.7 combat/control runtime stack through the enabled release matrix. It does not validate the exact v0.16.9 or v0.16.10 final hash through manual workflow dispatch.

## Dispatch Capability

This local environment does not have the GitHub CLI installed, and the available GitHub connector exposes run/job inspection and rerun helpers but no workflow-dispatch creation tool. No exact-final manual matrix was triggered from this pass.

## Manual GitHub UI Steps

If Emmanuel wants exact-final remote parity after v0.16.10:

1. Open GitHub repository `jardas33/ascendant-realms`.
2. Go to `Actions`.
3. Select `CI Release Matrix Dry Run`.
4. Choose `Run workflow`.
5. Select branch `main`.
6. Enable `run_release_matrix`.
7. Leave `run_visual_qa` off unless screenshot artifacts are needed.
8. Leave `run_full_release` off unless exact remote full-release evidence is desired.
9. Start the workflow and verify these jobs: Fast confidence, Release simulator, deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, smoke.

Do not count Optional visual QA or Full release e2e as remote-passed unless those inputs are explicitly enabled and the jobs complete successfully.
