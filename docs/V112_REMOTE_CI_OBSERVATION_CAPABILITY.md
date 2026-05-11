# v0.11.2 Remote CI Observation Capability

Date: 2026-05-11

Scope: determine whether this local Codex environment can inspect the newly pushed GitHub Actions workflow from v0.11.1. This phase is observation and documentation only; it does not change gameplay, content, saves, tutorial behavior, visuals, runtime art, campaign progression, workflow coverage, or application code.

## Repository State

Phase 0 started from a clean, synced repository:

```text
git status -sb
## main...origin/main

git rev-list --left-right --count origin/main...HEAD
0 0
```

Current commit inspected:

```text
f0651afaf66c1622f454b751c118e4443a7590a7
Checkpoint v0.11.1 CI release matrix dry-run
```

Remote:

```text
origin https://github.com/jardas33/ascendant-realms.git
```

The repository URL is a GitHub repository, so GitHub Actions would normally be inspected through `gh`, the GitHub connector, or the GitHub REST API.

## Observation Methods Attempted

| Method | Result | Notes |
| --- | --- | --- |
| `gh --version` | Unavailable | `gh` is not installed in this Codex environment. No global tool install was attempted. |
| GitHub connector Actions tools | Unavailable | The connector returned `Provided authentication token is expired. Please try signing in again.` |
| Public GitHub REST Actions API | Unavailable | `GET /repos/jardas33/ascendant-realms/actions/runs?branch=main&per_page=10` returned `404 Not Found`. This is consistent with private repository or unauthenticated Actions visibility limits. |
| Local git remote metadata | Available | Confirms the GitHub remote and latest pushed commit, but cannot reveal Actions job state. |
| Local dry-run-equivalent verification | Available | Phase 0 local gates passed and later phases can continue with static workflow review plus local script verification. |

No `GITHUB*` environment variable names were present in the local environment, and no credentials or secrets were read, printed, installed, or requested.

## Capability Decision

Remote GitHub Actions run evidence cannot be fetched from this environment right now. The limiting factors are tooling/authentication, not a project code failure:

- the GitHub CLI is absent;
- the authenticated GitHub connector token is expired;
- the public REST API does not expose the repository's Actions runs anonymously.

Because v0.11.2 is explicitly allowed to document inaccessible remote CI and perform static/local-equivalent review, the safe path is:

1. Document the remote-observation limitation.
2. Inspect `.github/workflows/ci.yml` statically.
3. Run the relevant local gates without weakening coverage.
4. Create an owner-facing GitHub UI checklist so Emmanuel can capture the first hosted-run evidence from an authenticated browser.
5. Avoid CI-only YAML changes unless later evidence proves they are required.

## Workflow Run URL

No workflow run URL is available from this environment. Emmanuel should open the repository's GitHub Actions tab in an authenticated browser and inspect the `CI Release Matrix Dry Run` workflow for commit `f0651afaf66c1622f454b751c118e4443a7590a7`.

Expected workflow page pattern:

```text
https://github.com/jardas33/ascendant-realms/actions
```

## What Still Requires Human GitHub UI Observation

The following evidence cannot be confirmed locally without GitHub Actions access:

- whether the first push-triggered `fast-confidence` job completed on GitHub-hosted Linux;
- hosted-run job durations;
- hosted Playwright Chromium install behavior;
- hosted `npm run smoke:preview` behavior;
- artifact upload presence for failed or manual jobs;
- manual visual QA and release-matrix job visibility;
- any GitHub-side YAML parsing issue that is only visible in Actions UI.

## Phase 1 Verification

Baseline verification before writing this report passed:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
git diff --check
```

The build still reports the known Phaser vendor chunk-size warning; this is unchanged and expected.
