# Developer Command Guide

Date: 2026-05-11

Use this guide to pick the smallest useful verification gate during implementation while keeping the full release gate intact for checkpoints. Run commands from the project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

## Fast Local Confidence

Commands:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
git diff --check
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Docs-only work, small tooling docs, metadata docs, or before committing a narrow phase | About 30 to 60 seconds locally | Unit/pure rules, TypeScript build, production bundle creation, gameplay content validation, art-intake metadata validation, whitespace | Broken pure rule, TS error, content schema/reference error, unsafe art-intake metadata, or whitespace issue | `npm run build`; it catches production-only type/build issues and records the known Phaser warning state |

## Tutorial-Related Changes

Commands:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
git diff --check
```

Add layout and visual checks for overlay/layout changes:

```bash
npm run test:e2e:layout
npm run visual:qa
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Tutorial copy, step metadata, no-reward clarity, tutorial launch/exit, or small overlay hierarchy work | Fast smoke about 2-3m locally; full smoke about 5m; layout about 12 to 15m; visual QA about 3m | No-save/no-reward tutorial path, battle launch, menu return, tutorial metadata validation, responsive overlay readability | Broken tutorial signal, changed test copy, lost no-save/no-reward behavior, or layout overlap | `npm run test:e2e:smoke` for tutorial source changes; it carries the release-critical no-save/no-reward tutorial path |

## Visual-Intake Changes

Commands:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
git diff --check
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Editing `art-review/`, Cinderfen candidate metadata, review manifests, or source/license docs | About 30 to 60 seconds locally | Source/license gates, unknown-source production denial, high-IP-risk approval denial, runtime manifest separation | Missing `candidateId`, missing source fields, unsafe approval state, bad submitted-file reference | `npm run validate:art-intake`; it is the safe empty-intake gate and should stay independent from runtime art |

## Visual QA Changes

Commands:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run visual:qa
git diff --check
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Editing screenshot QA harness, visual review docs, or a scoped UI/visual surface that needs screenshots | Visual QA about 3m | 18 screenshot capture flow, generated index, browser console error capture, review artifact consistency | App failed to reach a captured view, screenshot path issue, or browser console error | The human review policy; screenshots are artifacts, not pixel-perfect baselines |

## Content/Data Changes

Commands:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
npm run playtest:sim
git diff --check
```

Add deeper coverage when content affects campaign flow, battle outcomes, rewards, pressure, or saves:

```bash
npm run test:e2e:deep
npm run test:e2e:release
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Editing units, buildings, abilities, maps, campaign nodes, rewards, saves, rival state, retinue rules, pressure metadata, or balance-adjacent data | Smoke about 5m; simulator usually under 1m; deep/release much longer | Content references, save compatibility, campaign/battle launch, deterministic simulator balance checks | Bad ID/reference, changed reward persistence, broken save normalization, changed campaign outcome | `npm run validate:content` before broad browser checks; it catches many data mistakes cheaply |

## E2E Release Verification

Commands:

```bash
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
npm run test:e2e:release
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
npm run test:e2e:release:hosted:deep-meta
npm run test:e2e:release:hosted:deep-battle
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run test:e2e:release:hosted:layout-core
npm run test:e2e:release:hosted:layout-cinderfen
npm run test:e2e:release:hosted:smoke
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Final gates, release freezes, broad gameplay/content changes, or CI lane validation | Fast smoke about 2-3m locally; full smoke about 5m; full release about 29-36m; local 3-way shards about 14 to 17m and 6m recently; hosted explicit groups are smaller CI jobs but add local overhead when run sequentially | Full browser behavior suite, hosted-group distributability, smoke/deep/layout/pressure coverage, production-preview release environment | Real browser regression, hosted grouping issue, preview-server issue, timeout or stale-process issue | Full release before major freezes; hosted groups are GitHub CI ergonomics and do not delete the one-command lane |

Run `npm run build` before running hosted release groups locally; CI release matrix jobs already do this before starting production preview.

Timeout policy lives in `docs/V11_RELEASE_LANE_RELIABILITY_PLAN.md`.

## Full Final Gate

Commands:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke:fast
npm run test:e2e:smoke
npm run test:e2e:release
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
npm run test:e2e:release:shard1of3
npm run test:e2e:release:shard2of3
npm run test:e2e:release:shard3of3
npm run test:e2e:release:hosted:deep-meta
npm run test:e2e:release:hosted:deep-battle
npm run test:e2e:release:hosted:deep-campaign-pressure
npm run test:e2e:release:hosted:layout-core
npm run test:e2e:release:hosted:layout-cinderfen
npm run test:e2e:release:hosted:smoke
npm run visual:qa
npm run playtest:sim
npm run smoke:preview
git diff --check
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| End of a long goal or release handoff | More than an hour locally because release lanes are repeated in full and shards | Complete local release confidence, screenshot QA, simulator, production preview, whitespace | Any critical release surface may be broken or flaky | `git diff --check` at the end; it catches whitespace issues after docs edits |

## Preview Smoke

Commands:

```bash
npm run build
npm run smoke:preview
```

Manual fallback:

```bash
npm run preview
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| After build-output/chunking/tooling changes, final gates, or preview reliability checks | `smoke:preview` about 30s after a build | Production `dist/` boot, title/menu copy, Tutorial launch/exit, New Campaign, Continue Campaign, Skirmish Setup, browser console errors, process cleanup | Missing build, port conflict, production-only crash, WebGL/headless issue, or process cleanup bug | `npm run build` first; preview serves `dist/` |

The helper is documented in `docs/V11_PREVIEW_SMOKE_RELIABILITY_NOTES.md`.

## Art-Intake Validation

Command:

```bash
npm run validate:art-intake
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Editing future Cinderfen style-frame metadata or review manifests | A few seconds | Metadata completeness, source/license proof, approval gates, unknown-source/high-IP-risk denial | Unsafe candidate approval, missing source fields, rejected candidate without reason | This command after any `art-review/cinderfen-style-frames/metadata/` edit |

## Bundle Analysis

Commands:

```bash
npm run build
npm run build:analyze
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Measuring bundle growth, warning policy, possible production leaks, or optimization candidates | Build about 15 to 30s; analyzer about 30 to 60s | Current chunk sizes, Phaser vendor warning state, analyzer artifacts under `bundle-analysis/` | Unexpected app/CSS growth, changed vendor chunk, accidental test/dev code in production | Measurement before optimization; do not lazy-load or change warning limits without evidence |

The latest refresh is `docs/V11_BUNDLE_PERFORMANCE_REFRESH.md`.

## GitHub Actions CI

Workflow:

```text
.github/workflows/ci.yml
```

Automatic fast confidence runs on pull requests and pushes to `main`:

```bash
npm test
npm run build
npm run validate:content
npm run validate:art-intake
npm run test:e2e:smoke:fast
npm run smoke:preview
```

Manual workflow inputs:

```text
run_visual_qa
run_release_matrix
run_full_release
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Remote PR/push confidence or manual release dry-runs | Fast CI runs the 6-test `@ci-fast` smoke subset; manual release matrix now runs six explicit hosted groups against production preview with a 45m per-group timeout | Clean install, build, validators, fast smoke, preview smoke, optional visual artifacts, optional release groups, optional simulator | Missing CI browser dependency, Linux/CI preview portability issue, real browser regression, hosted-group failure, or artifact upload issue | Full local smoke/release gates before handoff; CI supplements local release evidence |

CI design docs: `docs/V111_CI_MATRIX_AUDIT.md`, `docs/V111_CI_RELEASE_MATRIX_PLAN.md`, `docs/V111_CI_ARTIFACT_STRATEGY.md`, and `docs/V111_CI_LOCAL_PARITY_CHECK.md`.

v0.11.8 hosted release note: the release helpers remain coverage-preserving. If a shard logs `retrying app boot navigation` or `retrying click actionability`, treat that as expected transient recovery only when the same test still reaches its real assertions and passes. Do not remove shard coverage or switch to force-clicks for speed; use `docs/V118_HOSTED_RELEASE_MATRIX_STABILITY_FIX.md` for the current helper policy.

v0.11.9 hosted release note: the manual GitHub `run_release_matrix` input briefly used six hosted shard scripts, `test:e2e:release:hosted:shard1of6` through `shard6of6`, with test-level sharding, `--workers=1`, and a 45-minute per-shard timeout.

v0.11.10 hosted release note: GitHub run #15 showed that the native 6-way split was still unstable across hosted runners. The manual GitHub `run_release_matrix` input now uses explicit hosted groups: `deep-meta`, `deep-battle`, `deep-campaign-pressure`, `layout-core`, `layout-cinderfen`, and `smoke`. Local full release, local 2-way shards, and local 3-way shards remain available for developer and final-gate confidence.

v0.11.11 hosted release note: GitHub run #17 showed the explicit groups were still unstable when served by Vite dev server. Hosted release groups now use `playwright.hosted-release.config.ts`, `npm run preview:hosted`, production preview on `127.0.0.1:5173`, and hosted-only Chromium stability args. The workflow already installs Chromium with Linux dependencies via `npx playwright install --with-deps chromium`.

## Simulator

Command:

```bash
npm run playtest:sim
```

| Use when | Expected runtime | Protects | Common failure meaning | Do not skip |
| --- | --- | --- | --- | --- |
| Campaign battle balance, pressure metadata, rewards, node/battle changes, or final gates | Usually under 1m | 255 scripted campaign battle runs across 85 node/profile summaries, deterministic telemetry, too-easy/too-hard warning signals | Balance regression, impossible route, pressure telemetry warning, structural campaign battle issue | Simulator after content changes that affect battle outcomes |

## Default Rule

When uncertain, run the fast local confidence set first. Add the browser, visual, simulator, release, or preview lanes according to the touched surface. Never reduce real coverage just to make a lane faster.
