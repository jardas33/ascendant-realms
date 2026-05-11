# v0.11.1 CI Matrix Audit

Date: 2026-05-11

Scope: audit current CI readiness before adding or changing workflow files. This phase is documentation-only and does not change gameplay, content, tutorial behavior, saves, campaign progression, visuals, runtime art, Playwright coverage, package scripts, or application code.

## Inputs Inspected

```text
git status -sb
git rev-list --left-right --count origin/main...HEAD
.github/workflows/
package.json
playwright.config.ts
playwright.visual-qa.config.ts
docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md
docs/DEVELOPER_COMMAND_GUIDE.md
docs/E2E_CI_SHARDING_PLAN.md
docs/V11_E2E_RUNTIME_AUDIT_REFRESH.md
tests/e2e/
npx playwright test --list
```

Phase 0 baseline also passed before this audit:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
git diff --check
```

## Existing Workflow State

No GitHub Actions workflow directory is currently present:

```text
.github/workflows/: not present
```

That means v0.11.1 can add a conservative first workflow without needing to migrate or weaken an existing CI convention. The first workflow should avoid expensive duplicated release work on every push and should not require secrets, paid services, or external asset access.

## Current Commands Available

| Command | Current role | CI suitability |
| --- | --- | --- |
| `npm test` | Vitest pure-rule/unit suite, 46 files / 351 tests | Good for every PR/push confidence job. |
| `npm run build` | TypeScript compile plus Vite production build | Good for every PR/push confidence job. Keep known Phaser vendor warning documented. |
| `npm run validate:content` | Data/content/runtime visual manifest validation | Good for every PR/push confidence job. |
| `npm run validate:art-intake` | Non-runtime art-intake metadata validation | Good for every PR/push confidence job; safe with empty intake. |
| `npm run test:e2e:smoke` | 12-test Playwright smoke lane | Good for PR confidence if CI time is acceptable. |
| `npm run smoke:preview` | Production preview smoke helper for built `dist/` | Good for PR confidence after `npm run build`; needs browser install and process-portability watch. |
| `npm run visual:qa` | Optional screenshot capture, 18 review screenshots | Better as manual/optional CI because artifacts are human-reviewed. |
| `npm run test:e2e:release` | Full 67-test Playwright release lane | Too slow for every push; good for major freeze/manual verification. |
| `npm run test:e2e:release:shard1of3` | 3-way release shard, 28 tests | Good manual release matrix lane. |
| `npm run test:e2e:release:shard2of3` | 3-way release shard, 27 tests | Good manual release matrix lane. |
| `npm run test:e2e:release:shard3of3` | 3-way release shard, 12 tests | Good manual release matrix lane. |
| `npm run playtest:sim` | Deterministic simulator, 255 campaign battle runs | Good manual release or content-risk lane; cheap enough to pair with release gate. |
| `npm run build:analyze` | Bundle analysis artifacts under ignored output | Manual measurement lane, not needed on every PR. |

## Current E2E Inventory

`npx playwright test --list` reports 67 tests across 4 e2e spec files:

| Spec | Count | CI meaning |
| --- | ---: | --- |
| `tests/e2e/deep-flow.spec.ts` | 28 | Long campaign, battle, reward, retinue, rival, save, HUD, minimap, ability, and progression flows. |
| `tests/e2e/enemy-pressure.spec.ts` | 2 | Pressure warning activation and tutorial/skirmish no-pressure guardrails. |
| `tests/e2e/layout.spec.ts` | 25 | Responsive layout, HUD fit, tutorial overlay readability, Cinderfen readability, and Ashen Outpost fit. |
| `tests/e2e/smoke.spec.ts` | 12 | Main menu, tutorial no-save/no-reward, settings, campaign, skirmish, difficulty, and inventory smoke paths. |

Current shard shape:

| Lane | Count | Latest local runtime role |
| --- | ---: | --- |
| Full release | 67 | About 28-29 minutes locally; use as final major checkpoint evidence. |
| 2-way shard 1 | 55 | Still heavy; not recommended as the primary new CI split. |
| 2-way shard 2 | 12 | Smoke-sized; uneven with shard 1. |
| 3-way shard 1 | 28 | Deep-flow family; better-balanced manual release matrix lane. |
| 3-way shard 2 | 27 | Layout plus pressure family; better-balanced manual release matrix lane. |
| 3-way shard 3 | 12 | Smoke family; fastest release matrix lane. |

## Recommended CI Lanes

### Pull Request / Fast Confidence

Use for routine branches:

```text
npm ci
npx playwright install --with-deps chromium
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke
npm run smoke:preview
```

Why: this protects TypeScript, production build output, source/content gates, browser smoke behavior, no-save/no-reward tutorial smoke, and production preview boot without running the full release suite on every push.

### Manual Visual QA

Use on `workflow_dispatch` or when a maintainer intentionally wants screenshot artifacts:

```text
npm run visual:qa
```

Upload `visual-qa/latest/` as an artifact if it exists. Do not use pixel-perfect diffing or make screenshot review block unrelated docs/tooling changes by default.

### Manual Release Gate

Use on `workflow_dispatch` before releases, major freezes, or long-goal final checks:

```text
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
npm run playtest:sim
```

Keep `npm run test:e2e:release` as the canonical local one-command release lane and use it for major freezes when local time permits. The 3-way shards are the preferred CI wall-clock split because they are materially more balanced than the 2-way shards.

## Commands Too Slow For Every Push

These should not run automatically on every push unless the project later accepts much longer CI time:

- `npm run test:e2e:release`
- `npm run test:e2e:release:shard1`
- `npm run test:e2e:release:shard2`
- all three 3-way release shards
- `npm run visual:qa`
- `npm run build:analyze`

The full release suite is valuable, but running it on every push would duplicate expensive browser coverage and slow routine feedback. v0.11.1 should prefer manual release workflows for heavy lanes.

## Browser Install Needs

CI must install the Chromium browser used by Playwright. Recommended first step:

```text
npx playwright install --with-deps chromium
```

This keeps the primary e2e config, visual QA config, and `smoke:preview` helper aligned around Chromium. The current Playwright configs already use SwiftShader/ANGLE launch args for headless WebGL stability.

## Cache Opportunities

Safe first caches:

- npm cache through `actions/setup-node` with `cache: npm`
- Playwright browser cache only if later CI runtime needs it and artifact/cache behavior is understood

Avoid caching generated `dist/`, `visual-qa/latest/`, `test-results/`, or candidate art. Build and review artifacts should be generated fresh for the commit under test.

## Artifact Opportunities

Useful artifacts when present:

- `test-results/` for Playwright traces, screenshots, and videos on failure
- `playwright-report/` if a future reporter creates it
- `visual-qa/latest/` for manual screenshot review
- `bundle-analysis/` only for manually requested bundle-analysis runs

Artifacts should use short retention windows because Playwright videos and screenshots can grow. Visual QA artifacts should remain review evidence, not a source/license approval for new art.

## smoke:preview Portability Risks

Current local v0.11 result is green, but CI should watch:

- Windows versus Linux child-process spawning
- reliable shutdown of the Vite preview process tree
- port `4173` conflicts
- Chromium/WebGL headless GPU behavior
- console-error capture differences
- timeout messaging when preview never starts

Phase 2 should inspect `tools/smokePreview.ts` and make only small portability improvements if they are obvious and safe.

## What Not To Automate Yet

Do not automate these as required every-push gates in v0.11.1:

- full release e2e on every push
- both 2-way shards on every push
- visual QA as a required pull-request gate
- bundle analyzer on every push
- candidate-art ingestion or runtime asset workflows
- deployment, desktop packaging, or paid-service integration

Do not weaken local release gates just because a first CI workflow exists.

## Phase 1 Decision

It is safe to add a conservative GitHub Actions workflow later in v0.11.1 if it follows this shape:

- fast pull-request/push confidence job
- optional manual visual QA job
- manual 3-way release matrix job
- Playwright Chromium install
- npm cache
- short-retention failure artifacts
- no secrets
- no paid services
- no gameplay/content/save/runtime-art changes

