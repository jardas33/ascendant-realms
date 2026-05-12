# v0.11.2 Remote CI Observation Report

Date: 2026-05-11

Scope: observe or document access to the first remote GitHub Actions run from v0.11.1, review likely CI timeout/portability/artifact risks, and make only tiny CI-only fixes if evidence requires them. This checkpoint makes no gameplay, content, save, tutorial behavior, campaign progression, visual asset, runtime art, Playwright coverage, or app runtime changes.

## What Changed

v0.11.2 adds documentation around the first remote CI observation pass:

- `docs/V112_REMOTE_CI_OBSERVATION_CAPABILITY.md`
- `docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md`
- `docs/V112_WORKFLOW_STATIC_REVIEW.md`
- `docs/V112_CI_TIMEOUT_TUNING_REVIEW.md`
- `docs/V112_PREVIEW_HELPER_REMOTE_PORTABILITY_REVIEW.md`
- `docs/V112_CI_ARTIFACT_REMOTE_REVIEW.md`
- `docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md`
- `docs/V112_CI_NO_FIX_DECISION.md`

## What Did Not Change

No change was made to:

- `.github/workflows/ci.yml`;
- `tools/smokePreview.ts`;
- `package.json`;
- Playwright configs;
- tests or coverage;
- gameplay/content data;
- save format;
- tutorial behavior;
- campaign progression;
- runtime art or visual assets.

## Remote CI Observation Status

Remote GitHub Actions evidence could not be fetched from this environment.

Observed limitations:

- `gh` is not installed.
- The GitHub connector Actions tools returned an expired-token error.
- The public GitHub Actions REST API returned `404 Not Found` for `jardas33/ascendant-realms`.

This is an access/tooling limitation, not a known project failure. The repository remote and pushed v0.11.1 commit were confirmed locally:

```text
Repository: jardas33/ascendant-realms
Commit: f0651afaf66c1622f454b751c118e4443a7590a7
Message: Checkpoint v0.11.1 CI release matrix dry-run
```

## GitHub Actions Evidence

No hosted job result, run id, duration, artifact list, or step log could be inspected from Codex.

`docs/V112_GITHUB_ACTIONS_EVIDENCE_REPORT.md` documents:

- the exact access failures;
- expected automatic `fast-confidence` behavior;
- expected skipped/absent manual jobs on push;
- what counts as pass/fail;
- which GitHub UI evidence Emmanuel should capture.

## Static Workflow Review

Static review found no clear YAML issue:

- `pull_request`, `push` to `main`, and `workflow_dispatch` triggers are present.
- Heavy visual/release jobs are manual-only.
- Permissions remain `contents: read`.
- Node 22, `npm ci`, npm cache, and Playwright Chromium install are configured.
- All referenced package scripts exist.
- Artifact paths use `if-no-files-found: ignore`.
- Timeouts are conservative first-pass values.

No workflow edit was justified.

## Timeout Review

Local v0.11.1/v0.11.2 evidence suggests current timeouts are reasonable first-pass values:

- fast confidence: 35 minutes;
- visual QA: 20 minutes;
- release shards: 35 minutes;
- simulator: 10 minutes;
- full release: 45 minutes.

No hosted timeout failure is known, so no timeout was changed.

## Preview Helper Remote Review

`npm run smoke:preview` remains locally green and CI-oriented:

- host/port env overrides exist;
- startup/action timeout env overrides exist;
- Chromium uses the project SwiftShader/ANGLE args;
- console errors and page errors fail the helper;
- Linux/macOS process groups and Windows `taskkill` cleanup are already handled.

No helper or workflow env change was made without hosted Linux evidence.

## Artifact Review

Expected artifact paths match local output:

- `test-results/`;
- `playwright-report/`;
- `visual-qa/latest/`.

Visual QA locally produces 18 screenshots plus `index.md`, and the folder remains ignored by git. Artifacts are temporary CI evidence, not source/license proof or runtime art.

## Manual GitHub Checklist

`docs/V112_MANUAL_GITHUB_ACTIONS_CHECKLIST.md` gives Emmanuel a concrete UI procedure to:

- inspect the `CI Release Matrix Dry Run` workflow;
- confirm fast confidence results;
- trigger manual visual QA;
- trigger manual 3-way release shards plus simulator;
- trigger manual full release if needed;
- collect useful URLs, durations, logs, and artifacts.

## CI-Only Fixes Made

No CI-only fix was made. `docs/V112_CI_NO_FIX_DECISION.md` records why no YAML, helper, timeout, artifact, script, app, or test change is justified without hosted failure evidence.

## Remaining Risks

- The first GitHub Actions hosted run still requires authenticated GitHub UI observation.
- Hosted Linux timing for `fast-confidence` remains unmeasured.
- Hosted `npm run smoke:preview` behavior remains unconfirmed.
- Manual visual QA and release shard artifacts remain unconfirmed in GitHub UI.
- Full release e2e remains slow.
- The 2-way shard split remains lopsided; 3-way shards remain the better CI split.
- The known Phaser vendor chunk-size warning remains.
- Visual QA remains optional, human-reviewed, and non-pixel-perfect.

## Next Recommended Long Goal

If Emmanuel provides GitHub Actions screenshots/logs from the manual checklist, run a narrow **v0.11.3 GitHub Actions Evidence Follow-Up and Minimal Tuning** goal. It should make only evidence-backed CI-only changes, such as a timeout/env/artifact tweak.

If Emmanuel provides tutorial feedback, run **v0.10.1 Tutorial v2 Human-Feedback Polish**.

If Emmanuel provides source/license-documented Cinderfen candidate images, run **v0.9.2 Controlled Cinderfen Style-Frame Candidate Review**.

Otherwise, pause autonomous changes that need new external evidence and keep the local release gates authoritative.
