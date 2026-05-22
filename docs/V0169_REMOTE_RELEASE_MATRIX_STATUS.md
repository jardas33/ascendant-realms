# v0.16.9 Remote Release Matrix Status

Date: 2026-05-22

## Remote Runs Inspected

Repository: `jardas33/ascendant-realms`

### Latest v0.16.8 Push Run

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
| Release simulator | completed | skipped | Requires manual `workflow_dispatch` release-matrix options. |
| Release matrix `${{ matrix.name }}` | completed | skipped | No deep-meta/deep-battle/deep-campaign/layout/smoke matrix lanes ran. |
| Optional visual QA | completed | skipped | Requires manual dispatch option. |
| Full release e2e | completed | skipped | Requires manual dispatch option. |

Fast confidence steps that passed:

- checkout
- Node setup
- dependency install
- Playwright Chromium install
- unit and pure-rule tests
- production build
- content validation
- art-intake validation
- E2E fast smoke
- production preview smoke

### Previous v0.16.7 Push Run

- Run number: `78`
- Trigger: `push`
- Commit: `169bb21d54bd1599f5241b15bbfb1a187276d921`
- Status: completed
- Conclusion: success
- Meaning: Fast confidence green only; release matrix lanes skipped.

### Last True Workflow-Dispatch Release Matrix Found Nearby

- Run number: `77`
- Trigger: `workflow_dispatch`
- Commit: `3737c167aa86f05a733514873e30bb2995cda845`
- Status: completed
- Conclusion: success
- Meaning: this confirmed the v0.16.6 baseline, not the v0.16.7/v0.16.8/v0.16.9 combat-control stack.

## Decision

No remote CI failure is currently blocking v0.16.9 work.

Do not claim the full GitHub release matrix has passed for `ad4eee0`. The only remote run for `ad4eee0` was a push-triggered Fast confidence run. The manual workflow-dispatch release matrix still needs a user or token with Actions write permission.

