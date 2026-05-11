# v0.11.2 GitHub Actions Evidence Report

Date: 2026-05-11

Scope: document the first remote GitHub Actions evidence for the v0.11.1 workflow if available, or document the exact limitation and local substitute evidence if remote Actions data cannot be inspected. This report does not change gameplay, content, saves, tutorial behavior, visuals, runtime art, campaign progression, coverage strength, or workflow behavior.

## Evidence Status

Remote GitHub Actions evidence is not accessible from this Codex environment at this time.

The project repository and pushed commit were confirmed locally:

```text
Repository: jardas33/ascendant-realms
Remote: https://github.com/jardas33/ascendant-realms.git
Branch: main
Commit: f0651afaf66c1622f454b751c118e4443a7590a7
Commit message: Checkpoint v0.11.1 CI release matrix dry-run
```

## Exact Access Limitation

Three observation methods were attempted:

| Method | Result |
| --- | --- |
| `gh --version` | Failed because GitHub CLI is not installed. |
| GitHub connector Actions tool | Failed because the connector token is expired. |
| Public GitHub REST Actions API | Failed with `404 Not Found` for `GET /repos/jardas33/ascendant-realms/actions/runs?branch=main&per_page=10`. |

The public API result is consistent with a private repository or a repository whose Actions metadata is not anonymously visible. No credentials, secrets, or global GitHub tooling were added.

## What Was Verified Locally Instead

The local v0.11.2 Phase 0 gate passed before this report:

| Command | Result |
| --- | --- |
| `npm test` | PASS, 46 files / 351 tests. |
| `npm run build` | PASS with the known Phaser vendor chunk-size warning. |
| `npm run validate:content` | PASS. |
| `npm run validate:art-intake` | PASS, checked 1 candidate metadata JSON file and 0 review manifest JSON files. |
| `git diff --check` | PASS. |

These checks confirm that the repository remains locally healthy, but they do not replace hosted GitHub Actions evidence.

## Expected Workflow Run

The v0.11.1 workflow is:

```text
.github/workflows/ci.yml
Workflow name: CI Release Matrix Dry Run
```

Expected automatic trigger for the first pushed commit:

```text
event: push
branch: main
commit: f0651afaf66c1622f454b751c118e4443a7590a7
```

Expected automatically running job:

| Job | Expected state | Notes |
| --- | --- | --- |
| `fast-confidence` | Should run on push and pass | Installs Node 22 dependencies, installs Playwright Chromium, runs unit/build/content/art-intake/smoke/preview gates. |

Expected manual-only jobs:

| Job | Expected state on push | How it runs |
| --- | --- | --- |
| `visual-qa` | Skipped or absent | Runs only from `workflow_dispatch` with `run_visual_qa: true`. |
| `release-shards` | Skipped or absent | Runs only from `workflow_dispatch` with `run_release_matrix: true`. |
| `release-simulator` | Skipped or absent | Runs only from `workflow_dispatch` with `run_release_matrix: true`. |
| `full-release` | Skipped or absent | Runs only from `workflow_dispatch` with `run_full_release: true`. |

Skipped manual jobs on a push are expected and should not be treated as a CI failure.

## Expected Fast Confidence Steps

Emmanuel should verify that `fast-confidence` includes these steps:

1. Checkout
2. Setup Node 22
3. Install dependencies with `npm ci`
4. Install Playwright Chromium with Linux dependencies
5. Run `npm test`
6. Run `npm run build`
7. Run `npm run validate:content`
8. Run `npm run validate:art-intake`
9. Run `npm run test:e2e:smoke`
10. Run `npm run smoke:preview`
11. Upload Playwright diagnostics if present

The known Phaser vendor chunk-size warning during `npm run build` is expected and should not fail the job.

## What Counts As Pass

The first remote workflow should be considered healthy if:

- the workflow file is accepted by GitHub Actions;
- the push-triggered `fast-confidence` job concludes `success`;
- `npm run smoke:preview` passes on hosted Linux with 0 browser console errors;
- manual visual/release jobs are skipped or absent on push;
- no secrets or paid service setup is requested;
- any uploaded failure artifacts are only diagnostics, not required source assets.

## What Counts As Failure

The first remote workflow needs follow-up if:

- the workflow file fails to parse;
- `npm ci`, Playwright browser install, or Linux dependencies fail;
- a real test/build/validation command fails;
- `npm run smoke:preview` fails on hosted Linux due to port, timeout, process cleanup, or browser console errors;
- artifacts fail because a configured path is invalid in a way that marks the job failed;
- manual jobs run automatically on push unexpectedly;
- any failure would tempt coverage reduction. Coverage must not be reduced.

## Evidence Still Needed From GitHub UI

Please capture the following from the authenticated GitHub Actions page:

- workflow run URL;
- run id;
- event, branch, and commit SHA;
- `fast-confidence` conclusion and duration;
- step-level failure if any;
- `npm run smoke:preview` result and duration;
- whether manual jobs are skipped or absent as expected;
- artifact names, if any;
- logs around any failed setup, browser install, Playwright, preview, or upload step.

## Phase 2 Decision

No workflow or helper change is justified from this phase because no hosted failure evidence is available. Continue v0.11.2 with static workflow review, timeout review, preview-helper remote portability review, artifact review, and a manual GitHub UI checklist.
