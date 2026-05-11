# v0.11 E2E Runtime Audit Refresh

Date: 2026-05-11

Scope: refresh the current Playwright lane facts after v0.10 Tutorial v2. This phase is documentation-only. It does not change gameplay, content, tutorial behavior, save format, campaign progression, Playwright coverage, visual assets, bundle config, or runtime code.

## Commands And Files Inspected

```text
git status -sb
git rev-list --left-right --count origin/main...HEAD
npm test
npm run build
npm run validate:content
npm run validate:art-intake
git diff --check
node -e "<print relevant package scripts>"
rg --files tests/e2e tests/visual-qa
npx playwright test --list
npx playwright test --list --shard=1/2
npx playwright test --list --shard=2/2
npx playwright test --list --shard=1/3
npx playwright test --list --shard=2/3
npx playwright test --list --shard=3/3
```

Read inputs included:

- `package.json`
- `playwright.config.ts`
- `playwright.visual-qa.config.ts`
- `vite.config.ts`
- `tests/e2e/`
- `tests/visual-qa/`
- `docs/V10_TUTORIAL_E2E_LANE_REVIEW.md`
- `docs/V10_TUTORIAL_VISUAL_QA_REVIEW.md`
- `docs/V10_TUTORIAL_V2_ONBOARDING_REPORT.md`
- `docs/V08_E2E_RUNTIME_SHARD_AUDIT.md`
- `docs/V08_E2E_RUNTIME_IMPROVEMENT_PLAN.md`
- `docs/E2E_RUNTIME_AUDIT.md`
- `docs/E2E_CI_SHARDING_PLAN.md`

## Current E2E Scripts

| Script | Command | Current role |
| --- | --- | --- |
| `npm run test:e2e` | `playwright test` | Full local Playwright suite using the default reporter. |
| `npm run test:e2e:smoke` | `playwright test tests/e2e/smoke.spec.ts --reporter=line` | Fastest broad browser confidence lane. |
| `npm run test:e2e:layout` | `playwright test tests/e2e/layout.spec.ts --reporter=line` | Responsive layout and HUD fit lane. |
| `npm run test:e2e:deep` | `playwright test tests/e2e/deep-flow.spec.ts --reporter=line` | Deep campaign, battle, save, retinue, rival, reward, and flow lane. |
| `npm run test:e2e:release` | `playwright test --reporter=line` | Complete e2e release lane. |
| `npm run test:e2e:release:shard1` | `playwright test --reporter=line --shard=1/2` | 2-way shard, currently the heavy shard. |
| `npm run test:e2e:release:shard2` | `playwright test --reporter=line --shard=2/2` | 2-way shard, currently the smoke-sized shard. |
| `npm run test:e2e:release:shard1of3` | `playwright test --reporter=line --shard=1/3` | 3-way shard, deep-flow family. |
| `npm run test:e2e:release:shard2of3` | `playwright test --reporter=line --shard=2/3` | 3-way shard, layout plus pressure family. |
| `npm run test:e2e:release:shard3of3` | `playwright test --reporter=line --shard=3/3` | 3-way shard, smoke family. |
| `npm run test:e2e:headed` | `playwright test --headed` | Manual debugging lane. |
| `npm run visual:qa` | `playwright test --config=playwright.visual-qa.config.ts --reporter=line` | Optional screenshot QA capture lane. |

## Playwright Configuration

The primary e2e config is intentionally conservative:

- `testDir`: `./tests/e2e`
- browser project: Chromium desktop profile
- `workers`: `1`
- `fullyParallel`: `false`
- per-test timeout: `35_000`
- assertion timeout: `10_000`
- retries: `1` only in CI
- dev server: `npm run dev` at `http://127.0.0.1:5173`
- server reuse: enabled locally, disabled in CI
- failure artifacts: retain traces and videos, screenshots only on failure
- Chromium launch args: `--use-gl=angle`, `--use-angle=swiftshader`, and `--enable-unsafe-swiftshader`

The visual QA config mirrors the single-worker, single-browser shape but uses `./tests/visual-qa`, a `120_000` per-test timeout, and no retries. That lane is for human screenshot review, not pixel-perfect assertion.

## Current Test Inventory

`npx playwright test --list` reports 67 tests across 4 e2e spec files:

| Spec file | Count | Main coverage |
| --- | ---: | --- |
| `tests/e2e/deep-flow.spec.ts` | 28 | Long campaign, battle, reward, retinue, rival, save, HUD, minimap, ability, and node-progression flows. |
| `tests/e2e/enemy-pressure.spec.ts` | 2 | Scoped pressure warning activation and pressure-free tutorial/skirmish guardrails. |
| `tests/e2e/layout.spec.ts` | 25 | Desktop/tablet/mobile responsive layout, battle HUD fit, tutorial overlay readability, Cinderfen readability, and Ashen Outpost fit. |
| `tests/e2e/smoke.spec.ts` | 12 | Main menu, tutorial launch/exit/no-save, settings, campaign launch/progression, skirmish, difficulty, and inventory smoke flows. |

The visual QA lane currently has 1 capture spec in `tests/visual-qa/visual-qa.spec.ts`. It produces 18 indexed screenshots when green.

## Current Shard Inventory

| Lane | Current count | Current file spread |
| --- | ---: | --- |
| Full release | 67 tests | 4 files |
| 2-way shard 1 | 55 tests | 3 files |
| 2-way shard 2 | 12 tests | 1 file |
| 3-way shard 1 | 28 tests | 1 file |
| 3-way shard 2 | 27 tests | 2 files |
| 3-way shard 3 | 12 tests | 1 file |

The current 2-way split remains uneven because Playwright's file/test ordering puts deep-flow, enemy-pressure, and layout work into shard 1 while shard 2 receives the smoke family. The 3-way split is more balanced because the first shard is deep-flow, the second shard is layout plus enemy-pressure, and the third shard is smoke.

## Latest Known Runtime Facts

The latest full v0.10 final gate recorded these local runtimes:

| Lane | Latest known result |
| --- | --- |
| `npm run test:e2e:smoke` | PASS, 12 tests in about 4.9m |
| `npm run test:e2e:release` | PASS, 67 tests in about 29.0m |
| `npm run test:e2e:release:shard1` | PASS, 55 tests in about 24.3m |
| `npm run test:e2e:release:shard2` | PASS, 12 tests in about 4.8m |
| `npm run test:e2e:release:shard1of3` | PASS, 28 tests in about 11.5m |
| `npm run test:e2e:release:shard2of3` | PASS, 27 tests in about 12.9m |
| `npm run test:e2e:release:shard3of3` | PASS, 12 tests in about 4.9m |
| `npm run test:e2e:layout` | PASS, 25 tests in about 12.5m during v0.10 overlay verification |
| `npm run visual:qa` | PASS, 1 capture test in about 3.2m, 18 screenshots, 0 recorded console errors |

These are local observations, not strict performance budgets. The suite should be judged by failures, repeated timeouts, and trends rather than one exact stopwatch value.

## Why Full Release Is Slow

The current runtime is expected for the coverage it provides:

- The suite runs with a single worker to protect Phaser/WebGL stability, local storage isolation, and deterministic UI flows.
- Many tests boot a real Vite dev server, create live Phaser scenes, and wait for actual HUD, campaign, battle, save, and results transitions.
- Deep-flow tests intentionally cover long player journeys rather than mocked state transitions.
- Layout tests visit several viewport families and inspect live DOM/canvas-adjacent HUD surfaces.
- Smoke still includes full Tutorial / Proving Grounds completion because it protects the no-save/no-reward onboarding path.
- Failure artifacts are retained for debugging, which is worthwhile but not free.

The full release lane should therefore remain a release-confidence gate, not an every-edit loop.

## Recommended Lane Use

| Situation | Recommended lane |
| --- | --- |
| Tiny docs-only change | `npm test`, `npm run build`, `npm run validate:content`, `npm run validate:art-intake`, `git diff --check` |
| Routine source change with no layout risk | Add `npm run test:e2e:smoke` |
| Tutorial/UI/layout change | Add `npm run test:e2e:layout`; use `npm run visual:qa` when screenshots matter |
| Content/data/save/campaign risk | Add `npm run test:e2e:deep` or full release, plus simulator when campaign balance can be affected |
| CI or long release confidence | Prefer the 3-way shards because they are more balanced |
| Major freeze or handoff | Run the full final gate, including full release, all shard lanes, visual QA, simulator, diff check, and preview smoke |

## Safe Opportunities For v0.11

The safe opportunities are process and tooling clarity, not reduced coverage:

- Document the timeout and transient-rerun policy in one release lane plan.
- Add or document a production preview smoke helper if it can reliably shut down its process tree.
- Improve visual QA reporting if a tiny metadata or summary change makes screenshot review easier.
- Refresh bundle/performance facts after v0.10 and keep the Phaser vendor warning documented.
- Add a developer command guide so future goals choose the smallest useful gate while preserving release confidence.
- Tighten the release checklist around docs-only, tutorial/UI, visual-intake, content/data, and final-freeze paths.

## Explicit Non-Goals

Do not use v0.11 to:

- delete tests for speed
- skip release coverage
- replace behavior checks with fake assertions
- change workers or parallelism without a dedicated stability investigation
- add brittle pixel-perfect screenshot tests
- change gameplay, content, tutorial behavior, save format, campaign progression, visual assets, or runtime art
- hide the known Phaser vendor warning by changing `chunkSizeWarningLimit` without an explicit warning-policy decision

## Phase 1 Verification

Phase 1 verification is the docs-only gate:

```text
npm test
npm run build
npm run validate:content
npm run validate:art-intake
git diff --check
```
