# v0.11.1 CI / Local Parity Check

Date: 2026-05-11

Scope: compare local release commands, documentation, and the new GitHub Actions workflow. This phase is documentation-only unless a mismatch needs correction. It does not change gameplay, content, saves, tutorial behavior, campaign progression, visuals, runtime art, tests, or package scripts.

## Inputs Compared

```text
package.json
.github/workflows/ci.yml
RELEASE_CHECKLIST.md
docs/DEVELOPER_COMMAND_GUIDE.md
docs/V111_CI_RELEASE_MATRIX_PLAN.md
docs/V111_CI_MATRIX_AUDIT.md
docs/V111_CI_ARTIFACT_STRATEGY.md
```

## Command Groups That Match

### Fast Confidence

Local routine source/tooling gate:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
```

CI `fast-confidence` runs the same executable project commands after:

```text
npm ci
npx playwright install --with-deps chromium
```

This matches the v0.11.1 Tier 1 plan.

### Visual QA

Local optional visual QA command:

```text
npm run visual:qa
```

CI `visual-qa` runs the same command manually after install/build/browser setup and uploads `visual-qa/latest/`. This matches the v0.11.1 Tier 2 plan.

### Release Shards

Local 3-way shard commands:

```text
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
```

CI `release-shards` runs the same three commands in a manual matrix with `fail-fast: false`. This matches the v0.11.1 Tier 3 plan.

### Simulator

Local final gate command:

```text
npm run playtest:sim
```

CI `release-simulator` runs the same command when the manual release matrix is requested.

### Full Release Lane

Local canonical full release lane:

```text
npm run test:e2e:release
```

CI `full-release` can run the same command through a separate manual input. This keeps the one-command lane available without making it an every-push cost.

## Intentional Differences

| Difference | Why it is acceptable |
| --- | --- |
| CI runs `npm ci`; local docs use normal `npm run ...` commands after dependencies are installed. | CI needs a clean, lockfile-based install on every run. |
| CI installs Playwright Chromium explicitly. | Hosted runners need browser installation; local machines usually already have Playwright browsers after setup. |
| CI uses Node 22 while this local machine currently reports Node 24. | Node 22 aligns with the project's `@types/node` major and is a stable CI baseline. Local Node 24 remains green. |
| CI uploads short-retention artifacts; local runs keep artifacts in ignored folders. | CI artifacts make remote failures debuggable; local developers already share a filesystem with the repo. |
| CI does not run `git diff --check`. | GitHub checkout does not naturally represent the local uncommitted diff. Local phase/final gates still run `git diff --check`; a future lint job can add a PR-range whitespace check if needed. |
| CI fast job has a 35-minute timeout instead of the 25-minute planning target. | `npx playwright install --with-deps chromium` can add Linux package-install time, so the first workflow uses a safer timeout without weakening coverage. |
| CI release shard jobs build inside each shard job. | Simpler first-pass correctness. Build artifact sharing can be a later optimization after CI runtime is observed. |
| CI visual QA is manual-only. | Visual QA is human-reviewed and non-pixel-perfect; automatic PR blocking would create artifact noise. |

## Local-Only Commands

These remain local or manually run by developers:

- `git diff --check`
- `npm run test:e2e:layout`
- `npm run test:e2e:deep`
- `npm run test:e2e:headed`
- focused Playwright grep reruns
- `npm run build:analyze`
- manual `npm run preview`

They are still documented and available; the first CI workflow simply does not run every focused lane automatically.

## CI-Only Commands Or Steps

The workflow adds CI environment setup, not new project behavior:

- `actions/checkout@v4`
- `actions/setup-node@v4`
- `npm ci`
- `npx playwright install --with-deps chromium`
- `actions/upload-artifact@v4`

These steps do not change package scripts or runtime app behavior.

## Manual-Only Commands

These are intentionally behind `workflow_dispatch` inputs:

- `npm run visual:qa`
- `npm run test:e2e:release:shard1of3`
- `npm run test:e2e:release:shard2of3`
- `npm run test:e2e:release:shard3of3`
- `npm run playtest:sim` in CI release mode
- `npm run test:e2e:release` in CI full-release mode

Local final gates still run all required lanes.

## Known Runtime Expectations

- Fast CI feedback will be dominated by Playwright smoke plus Playwright browser install.
- Release matrix wall-clock should follow the slowest of the three release shards rather than the sum, assuming GitHub runs matrix jobs in parallel.
- The 3-way split remains materially better balanced than the 2-way split.
- Visual QA should produce 18 screenshots and 0 browser console errors when green.
- `smoke:preview` should pass after `npm run build` and report 0 browser console errors.

## Known Warnings Accepted

The Vite build warning remains accepted:

```text
Some chunks are larger than 500 kB after minification.
```

This is still caused by the Phaser vendor chunk. CI should not treat the warning as a failure unless a future bundle policy changes.

## Remaining Mismatches

- GitHub Actions syntax and runner behavior still need real GitHub validation after push.
- CI does not yet run a PR-range whitespace check equivalent to local `git diff --check`.
- CI release shard build duplication is simple but not optimized.
- Playwright browser caching is not enabled yet.
- Manual visual QA artifacts are useful but not a production art approval gate.

## Phase 6 Decision

The current workflow and local docs are aligned enough to continue. The mismatches are intentional first-pass choices and should be documented in the release checklist/README update phase rather than solved through risky workflow complexity.

