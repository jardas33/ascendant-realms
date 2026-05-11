# v0.11.1 CI Release Matrix Report

Date: 2026-05-11

Scope: make release verification safer to run in CI and across environments without changing gameplay, content, saves, tutorial behavior, campaign progression, visuals, runtime art, maps, units, factions, rewards, or Playwright coverage strength.

## What Changed

- Added CI matrix audit: `docs/V111_CI_MATRIX_AUDIT.md`.
- Added preview helper portability audit: `docs/V111_PREVIEW_HELPER_PORTABILITY_AUDIT.md`.
- Hardened `tools/smokePreview.ts` with validated port/timeout env overrides, clearer startup errors, and POSIX helper-owned process-group shutdown.
- Added CI release matrix plan: `docs/V111_CI_RELEASE_MATRIX_PLAN.md`.
- Added first conservative GitHub Actions workflow: `.github/workflows/ci.yml`.
- Added CI artifact strategy: `docs/V111_CI_ARTIFACT_STRATEGY.md`.
- Added CI/local command parity check: `docs/V111_CI_LOCAL_PARITY_CHECK.md`.
- Updated README, `RELEASE_CHECKLIST.md`, `docs/DEVELOPER_COMMAND_GUIDE.md`, `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`, `ROADMAP.md`, `CHANGELOG.md`, `DEVELOPMENT_CHECKPOINT.md`, and `LLM_GAME_HANDOFF.md`.

## What Did Not Change

v0.11.1 did not change:

- gameplay
- balance
- campaign progression
- tutorial behavior
- rewards
- save schema or save version
- maps, units, factions, workers, enemy construction, economy AI, diplomacy, crafting, procedural generation, multiplayer, monetization, or desktop packaging
- generated, downloaded, imported, moved, renamed, replaced, or wired runtime art
- runtime asset manifests or runtime art approvals
- Playwright coverage strength
- e2e worker/parallelism policy
- pixel-perfect screenshot policy
- the known Phaser vendor warning policy

## CI Matrix Audit Summary

No `.github/workflows/` directory existed before v0.11.1. The audit confirmed that the current package scripts already support a safe first CI matrix:

- fast PR/push confidence
- optional manual visual QA
- manual 3-way release shard matrix
- manual simulator
- optional manual full release lane

The current e2e suite remains 67 tests across 4 files, with 3-way shards at 28, 27, and 12 tests. The 2-way split remains lopsided at 55 and 12 tests.

## Preview Helper Portability Findings

`npm run smoke:preview` already launched the local Vite CLI through the current Node executable, which avoids the earlier Windows `npm.cmd` spawn issue. v0.11.1 added:

- `ASCENDANT_PREVIEW_PORT` validation
- `ASCENDANT_PREVIEW_TIMEOUT_MS`
- `ASCENDANT_PREVIEW_ACTION_TIMEOUT_MS`
- clearer preview startup failure messaging
- POSIX process-group shutdown for Linux/macOS CI runners

The helper still verifies the same production flows and still fails on browser console errors.

## Release Matrix Plan

The plan defines three tiers:

| Tier | Trigger | Commands |
| --- | --- | --- |
| Tier 1 PR / fast confidence | `pull_request`, `push` to `main`, manual dispatch | `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `npm run test:e2e:smoke`, `npm run smoke:preview` |
| Tier 2 optional visual QA | manual `workflow_dispatch` input | `npm run visual:qa` plus screenshot artifact upload |
| Tier 3 release gate manual | manual `workflow_dispatch` input | 3-way release shards plus `npm run playtest:sim`; optional full release input for major freezes |

The plan intentionally avoids running full release, 2-way shards, visual QA, and bundle analysis on every push.

## Workflow Created

Added:

```text
.github/workflows/ci.yml
```

Jobs:

- `fast-confidence`: automatic for pull requests, pushes to `main`, and manual dispatch.
- `visual-qa`: manual optional screenshot QA.
- `release-shards`: manual 3-way release matrix.
- `release-simulator`: manual simulator paired with the release matrix input.
- `full-release`: manual one-command release lane for major freeze confidence.

The workflow uses:

- Node 22
- `npm ci`
- `npx playwright install --with-deps chromium`
- npm cache
- short-retention artifact uploads
- no secrets
- no paid services

GitHub-side syntax, runner timing, and artifact behavior still need validation after push.

## Artifact Strategy

CI uploads only diagnostic or review-useful artifacts:

- `test-results/`
- `playwright-report/`
- `visual-qa/latest/` for the manual visual QA job

The workflow does not upload:

- `dist/`
- `node_modules/`
- candidate art binaries
- ignored intake inbox/reviewed/rejected images
- bundle-analysis output by default

Visual QA artifacts remain human-review evidence and are not source/license proof or runtime-art approval.

## CI / Local Parity Check

The executable project commands match the local docs. Intentional differences are documented:

- CI uses `npm ci`.
- CI installs Playwright Chromium.
- CI uses Node 22 as a stable baseline while local Node 24 remains green.
- CI uploads artifacts; local runs keep ignored folders.
- CI does not have a direct `git diff --check` equivalent for uncommitted local changes.
- CI heavy lanes are manual-only.
- CI release shards rebuild independently for simplicity.

## Release Docs Updates

README, release checklist, command guide, and release-lane plan now document:

- the new workflow path
- fast PR/push confidence
- manual workflow inputs
- 3-way release shard interpretation
- preview helper portability
- artifact strategy
- known Phaser warning
- known slow release lane
- continued local final-gate authority

## Verification Summary

Phase gates passed through v0.11.1:

- `npm test`: PASS, 46 files / 351 tests.
- `npm run build`: PASS with the known Phaser vendor chunk-size warning.
- `npm run validate:content`: PASS.
- `npm run validate:art-intake`: PASS.
- `npm run test:e2e:smoke`: PASS during workflow/tooling phases.
- `npm run smoke:preview`: PASS during preview/workflow phases with 0 browser console errors.
- `git diff --check`: PASS.

Report-gate verification additionally passed:

- `npm run visual:qa`
- `npm run playtest:sim`

Final full verification is still required after this report.

## Remaining Risks

- GitHub Actions workflow syntax and runner behavior must be validated after push.
- Full release e2e remains slow.
- 2-way shard 1 remains much heavier than shard 2.
- 3-way shards are better balanced but still need remote timing evidence.
- Playwright browser install can dominate first-run CI time.
- `smoke:preview` is locally green and more portable, but hosted Linux evidence is still pending.
- Visual QA remains optional, non-pixel-perfect, and human-reviewed.
- The known Phaser vendor chunk-size warning remains.
- v0.10.1 tutorial polish should wait for Emmanuel's manual tutorial feedback.
- v0.9.2 visual candidate review should wait for source/license-documented candidate art.

## Next Recommended Long Goal

If Emmanuel provides tutorial feedback, run **v0.10.1 Tutorial v2 Human-Feedback Polish**.

If Emmanuel provides source/license-documented Cinderfen candidate images, run **v0.9.2 Controlled Cinderfen Style-Frame Candidate Review**.

If neither input is available, the next safe autonomous technical goal is **v0.11.2 GitHub Actions Remote CI Observation and Timeout Tuning**, limited to inspecting the pushed workflow run, documenting runner timing/artifacts, and making tiny CI-only adjustments if evidence requires them.

