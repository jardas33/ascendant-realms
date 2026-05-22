# v0.16.9 Remote Release Matrix Status

Date: 2026-05-22

## Remote Runs Inspected

Repository: `jardas33/ascendant-realms`

### First v0.16.9 Push Run

- Workflow: `CI Release Matrix Dry Run`
- Run number: `81`
- Run id: `26308583642`
- Trigger: `push`
- Commit: `e596675b7944e78a08ffd8cc5cb83e7bace10128`
- Status when inspected after push: in progress
- Meaning: automatic Fast confidence was running; release simulator, release matrix groups, optional visual QA, and full release e2e were skipped for the push trigger.

Jobs at inspection:

| Job | Status | Conclusion | Notes |
| --- | --- | --- | --- |
| Fast confidence | in progress | pending | Unit tests, build, validators had passed; E2E fast smoke was in progress. |
| Release simulator | completed | skipped | Requires manual `workflow_dispatch` release-matrix option. |
| Release matrix `${{ matrix.name }}` | completed | skipped | No hosted release matrix group ran for the push trigger. |
| Optional visual QA | completed | skipped | Requires manual dispatch option. |
| Full release e2e | completed | skipped | Requires manual dispatch option. |

### v0.16.8 Workflow-Dispatch Release Matrix

- Workflow: `CI Release Matrix Dry Run`
- Run number: `80`
- Run id: `26305208490`
- Trigger: `workflow_dispatch`
- Commit: `ad4eee0a80a43f81df41ff30640a14f8434a5797`
- Status: completed
- Conclusion: success
- Created: `2026-05-22T18:31:21Z`
- Completed: `2026-05-22T18:37:51Z`
- URL: `https://github.com/jardas33/ascendant-realms/actions/runs/26305208490`

Jobs:

| Job | Status | Conclusion |
| --- | --- | --- |
| Fast confidence | completed | success |
| Release simulator | completed | success |
| Release matrix (deep-meta) | completed | success |
| Release matrix (deep-battle) | completed | success |
| Release matrix (deep-campaign-pressure) | completed | success |
| Release matrix (layout-core) | completed | success |
| Release matrix (layout-cinderfen) | completed | success |
| Release matrix (smoke) | completed | success |
| Optional visual QA | completed | skipped |
| Full release e2e | completed | skipped |

Meaning: the normal enabled workflow-dispatch release matrix did run and pass on the v0.16.8 commit that already included the v0.16.7 runtime combat/control fix. Optional visual QA and full release e2e were not part of that dispatch and must not be claimed as remote-passed from run #80.

### v0.16.8 Push Run

- Workflow: `CI Release Matrix Dry Run`
- Run number: `79`
- Run id: `26294553424`
- Trigger: `push`
- Commit: `ad4eee0a80a43f81df41ff30640a14f8434a5797`
- Status: completed
- Conclusion: success
- Created: `2026-05-22T14:45:43Z`
- Completed: `2026-05-22T14:49:59Z`
- URL: `https://github.com/jardas33/ascendant-realms/actions/runs/26294553424`

Jobs:

| Job | Status | Conclusion | Notes |
| --- | --- | --- | --- |
| Fast confidence | completed | success | Unit tests, build, validators, fast smoke, and production preview smoke passed. |
| Release simulator | completed | skipped | Push trigger. |
| Release matrix `${{ matrix.name }}` | completed | skipped | Push trigger. |
| Optional visual QA | completed | skipped | Push trigger. |
| Full release e2e | completed | skipped | Push trigger. |

### Previous v0.16.7 Push Run

- Run number: `78`
- Trigger: `push`
- Commit: `169bb21d54bd1599f5241b15bbfb1a187276d921`
- Status: completed
- Conclusion: success
- Meaning: Fast confidence green only; release matrix lanes skipped.

## Decision

No remote CI failure is currently blocking v0.16.9 work.

The enabled workflow-dispatch release matrix did pass on `ad4eee0`, which is the v0.16.8 checkpoint built on top of the v0.16.7 runtime combat/control fix. v0.16.9 itself is test/docs/package readiness only and does not change runtime gameplay, so an additional workflow-dispatch release matrix on the final v0.16.9 commit is optional rather than runtime-mandatory. The final push Fast confidence run should still be inspected after the closing commit is pushed.
