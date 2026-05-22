# v0.16.8 Remote CI Verification

Date: 2026-05-22

## Remote Run Inspected

- Workflow: `CI Release Matrix Dry Run`
- Repository: `jardas33/ascendant-realms`
- Run number: `78`
- Run id: `26267552395`
- Event: `push`
- Commit: `169bb21d54bd1599f5241b15bbfb1a187276d921`
- Status: completed
- Conclusion: success
- URL: `https://github.com/jardas33/ascendant-realms/actions/runs/26267552395`
- Created: `2026-05-22T03:56:25Z`
- Fast confidence job started: `2026-05-22T10:02:31Z`
- Run updated/completed: `2026-05-22T10:06:51Z`
- Executed job duration: about 4 minutes 20 seconds from Fast confidence start to workflow completion

## Jobs

| Job | Result | Notes |
| --- | --- | --- |
| Fast confidence | success | Push-triggered lane ran unit tests, build, validators, fast smoke, and production preview smoke. |
| Release simulator | skipped | Requires `workflow_dispatch` with `run_release_matrix=true`. |
| Release matrix deep-meta/deep-battle/deep-campaign-pressure/layout-core/layout-cinderfen/smoke | skipped | Matrix job skipped because this was a push run, not workflow dispatch. |
| Optional visual QA | skipped | Requires `workflow_dispatch` with `run_visual_qa=true`. |
| Full release e2e | skipped | Requires `workflow_dispatch` with `run_full_release=true`. |

## Fast Confidence Steps

All executed steps passed:

- checkout
- Node setup
- dependency install
- Playwright Chromium install
- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run test:e2e:smoke:fast`
- `npm run smoke:preview`

## Dispatch Status

No authenticated workflow-dispatch path is available in this local environment:

- `gh --version` failed because GitHub CLI is not installed.
- The available GitHub connector exposes inspection/rerun helpers but no workflow-dispatch creation tool.
- Public GitHub API inspection works, but workflow dispatch requires Actions write permission.

## Decision

Remote CI is not red. The v0.16.7 push-triggered Fast confidence lane is green.

However, the full manual release matrix for v0.16.7 has not been run remotely yet. This checkpoint must not claim remote release-matrix green for v0.16.7. Local hosted release lanes and soak runs are still useful while Emmanuel is away, and a user with GitHub Actions write access should dispatch the normal enabled release matrix when available.
