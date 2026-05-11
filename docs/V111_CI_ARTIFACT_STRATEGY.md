# v0.11.1 CI Artifact Strategy

Date: 2026-05-11

Scope: define which CI artifacts are useful for Ascendant Realms release reliability and which artifacts should remain local or ignored. This phase is documentation-only unless a small workflow adjustment is required. It does not change gameplay, content, saves, tutorial behavior, campaign progression, visuals, runtime art, tests, or production assets.

## Current Workflow Artifact Uploads

`.github/workflows/ci.yml` now uploads short-retention artifacts from browser jobs:

| Job | Artifact | Source path | Retention | Purpose |
| --- | --- | --- | ---: | --- |
| `fast-confidence` | `playwright-fast-confidence` | `test-results/`, `playwright-report/` | 7 days | Failure traces, screenshots, videos, or reports from smoke/preview jobs when present. |
| `visual-qa` | `visual-qa-latest` | `visual-qa/latest/` | 7 days | Human-review screenshots and generated visual QA index. |
| `visual-qa` | `playwright-visual-qa` | `test-results/`, `playwright-report/` | 7 days | Visual QA failure diagnostics when present. |
| `release-shards` | `playwright-release-${shard}` | `test-results/`, `playwright-report/` | 7 days | Per-shard Playwright diagnostics. |
| `full-release` | `playwright-full-release` | `test-results/`, `playwright-report/` | 7 days | Full release lane diagnostics when manually requested. |

The workflow uses `if-no-files-found: ignore` so successful jobs without generated artifacts do not fail.

## Visual QA Screenshots

`npm run visual:qa` writes review evidence under:

```text
visual-qa/latest/
```

Expected contents include:

- 18 screenshot files when green
- generated `index.md`
- screenshot count
- console error count
- viewport coverage metadata
- harness path

CI should upload this folder only for the manual visual QA job. These screenshots are for human inspection and should not become pixel-perfect baselines.

## Playwright Failure Artifacts

Playwright configs currently retain:

- traces on failure
- screenshots on failure
- videos on failure

Relevant paths:

```text
test-results/
playwright-report/
```

Upload these paths for browser jobs so a failed CI run can be inspected without rerunning immediately. Keep retention short because videos and traces can grow quickly.

## Bundle Analysis Artifacts

`npm run build:analyze` writes ignored output under:

```text
bundle-analysis/
```

Do not upload this on every PR. A future manual bundle-analysis workflow can upload it only when explicitly requested, using the same short-retention policy. The current v0.11 bundle/performance refresh is documentation-based and does not require a standing CI artifact.

## Preview Smoke Artifacts

`npm run smoke:preview` prints direct pass/fail evidence and fails on browser console errors. It does not currently write a separate artifact. If the preview helper later gains traces or screenshots, they should go under `test-results/` or another ignored diagnostics folder and follow the same short-retention policy.

## Simulator Artifacts

`npm run playtest:sim` regenerates:

```text
PLAYTEST_TELEMETRY.md
PLAYTEST_TELEMETRY.json
```

These are tracked local files and release evidence, not CI artifacts by default. The first workflow should simply run the simulator and fail if it detects a regression. Uploading telemetry can be considered later if CI diagnosis needs it.

## When To Upload

Upload artifacts when they help answer a concrete review/debug question:

- A Playwright browser lane failed.
- Manual visual QA was requested.
- A manual release matrix shard failed or timed out.
- A future manual bundle-analysis run was explicitly requested.

Avoid uploading artifacts that do not add diagnostic value for routine green runs.

## When Not To Upload

Do not upload:

- `dist/` by default; rebuild on the checked commit.
- `node_modules/`; use npm cache instead.
- generated Vite cache folders.
- raw candidate art binaries.
- ignored Cinderfen intake inbox/reviewed/rejected image files.
- screenshots as source/license proof.
- large videos outside short-retention failure diagnostics.

## Retention Suggestions

| Artifact type | Suggested retention |
| --- | ---: |
| Playwright failure diagnostics | 7 days |
| Manual visual QA screenshots | 7 days |
| Manual bundle analysis | 7 days |
| Long-term release evidence | Commit docs/handoff summaries, not CI artifacts |

Short retention keeps CI useful without turning artifacts into a storage system.

## Artifact Size Risks

- Playwright videos and traces can grow quickly when many tests fail.
- Visual QA images are manageable now but could grow if new viewport captures are added.
- Bundle analyzer output is small now, but should remain manual.
- Candidate art binaries could become large and source/license-sensitive; keep them ignored unless explicitly approved for review.

## Source And License Concerns

Visual QA screenshots are captures of the current prototype and are fine as temporary CI artifacts. Future candidate style-frame images are different:

- They may be user-provided or generated outside Codex.
- They require source/license metadata before commit.
- They must not be uploaded as CI artifacts just because they exist locally.
- They must not be marked production-safe from artifact presence.
- Unknown-source art remains not production-safe.

The non-runtime art-intake policy remains controlled by `docs/V091_STYLE_FRAME_INTAKE_PROTOCOL.md`, `docs/V091_SOURCE_LICENSE_METADATA_GUIDE.md`, and `npm run validate:art-intake`.

## Workflow Adjustment Decision

No additional workflow change is required in this phase. The current v0.11.1 workflow already:

- uploads Playwright diagnostics for browser jobs
- uploads visual QA screenshots only for the manual visual job
- uses short retention
- ignores missing artifact folders
- avoids `dist/`, `node_modules/`, candidate art, and bundle-analysis uploads by default

