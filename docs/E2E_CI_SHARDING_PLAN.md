# E2E CI Sharding Plan

Date: 2026-05-07

Continuation refresh: 2026-05-09. Re-verified the existing 2-shard scripts during the overnight continuation. The later Tutorial / Proving Grounds playable-shell pass raised the smoke lane from 10 to 12 tests, the Phase 11 tutorial readability pass added four layout tests, and v0.7 Enemy Strategic Pressure V1 added two targeted release tests. The current release gate lists 67 tests across 4 spec files.

Scope: plan and minimal script implementation for CI sharding of the full Playwright release gate. This pass does not change tests, remove coverage, change gameplay, change UI behavior, change selectors, or change Playwright configuration.

## Current E2E Lanes

The current npm scripts already split local/test intent by file:

| Lane | Command | Files | Current role |
| --- | --- | --- | --- |
| Smoke/default | `npm run test:e2e:smoke` | `tests/e2e/smoke.spec.ts` | Fastest frequent browser iteration lane. Covers boot, Tutorial / Proving Grounds completion/exit, Settings, campaign launch, Cinderfen route smoke, skirmish, difficulty, and inventory. |
| Layout/responsive | `npm run test:e2e:layout` | `tests/e2e/layout.spec.ts` | Responsive, mobile density, Tutorial overlay readability, battle HUD, Results, Asset Gallery reachability, and Ashen/Cinderfen layout checks. |
| Deep-flow | `npm run test:e2e:deep` | `tests/e2e/deep-flow.spec.ts` | Release-critical gameplay, save, campaign, Results, HUD, minimap, retinue, rival, and first-battle full-flow coverage. |
| Enemy pressure | `npx playwright test tests/e2e/enemy-pressure.spec.ts --reporter=line` | `tests/e2e/enemy-pressure.spec.ts` | Targeted v0.7 pressure warning and tutorial/skirmish no-pressure guard. |
| Release gate | `npm run test:e2e:release` or `npm run test:e2e` | All e2e specs | Full 67-test release/checkpoint gate. |
| Release shard 1 | `npm run test:e2e:release:shard1` | Playwright shard `1/2` | First half of the full release gate for CI matrix usage. |
| Release shard 2 | `npm run test:e2e:release:shard2` | Playwright shard `2/2` | Second half of the full release gate for CI matrix usage. |

Current `playwright.config.ts` shape:

- `testDir: "./tests/e2e"`
- `workers: 1`
- `fullyParallel: false`
- one Chromium project
- `retries: process.env.CI ? 1 : 0`
- Playwright `webServer` starts `npm run dev` on `http://127.0.0.1:5173`
- `reuseExistingServer: !process.env.CI`

## Current Known Runtimes

Recent recorded runtimes:

| Lane | Tests | Runtime | Notes |
| --- | ---: | ---: | --- |
| Smoke/default | 12 | 5.2m in the latest final tutorial-shell gate | Good frequent iteration lane, but not a release substitute. Includes the first full tutorial completion smoke. |
| Release gate | 65 | 28.5m in the latest final tutorial-shell gate | Suitable for freeze/checkpoint gates but slow for CI feedback. |
| Release shard 1 | 53 | 24.4m in the latest final tutorial-shell gate | Contains the deep-flow and layout-heavy side of the split; useful in CI, not a local speedup when run sequentially. |
| Release shard 2 | 12 | 4.9m in the latest final tutorial-shell gate | Currently maps to the smoke side of the split. |
| Layout/responsive | 25 | 13.1m in the latest tutorial readability run | Slowest file family along with deep-flow. |
| Deep-flow | 28 | 10.8-11.1m inside the latest shard/release runs | Slowest file family along with layout. |

The long runtime is expected because the suite intentionally runs with one worker, repeats Phaser scene boot, uses live campaign/battle flows, and keeps layout/deep coverage broad.

## Sharding Strategy

Playwright sharding should split the full release suite without changing test files. The initial implementation should use Playwright's built-in `--shard=x/y` option in CI.

### 2-Shard Plan

Commands:

```bash
npx playwright test --reporter=line --shard=1/2
npx playwright test --reporter=line --shard=2/2
```

Expected behavior:

- Both shards together preserve the full 65-test release gate.
- Each shard keeps `workers: 1` inside the shard, preserving the current stability posture.
- CI wall-clock should trend toward roughly half of the release gate, but not exactly half because tests differ in cost and Playwright distributes tests rather than equalizing runtime perfectly.
- Local behavior stays unchanged unless a developer explicitly runs a shard command.

Pros:

- Smallest meaningful CI change.
- Easy to reason about and rollback.
- Keeps smoke/layout/deep/release scripts intact.
- Avoids test tagging, test deletion, or spec restructuring.

Cons:

- The two shards may not balance perfectly if one receives more of `layout.spec.ts` or `deep-flow.spec.ts`.
- Reports/artifacts are split unless CI merges them.
- Each CI job starts its own Vite dev server by default, so total CI compute increases even as wall-clock decreases.

### 3-Shard Plan

Commands:

```bash
npx playwright test --reporter=line --shard=1/3
npx playwright test --reporter=line --shard=2/3
npx playwright test --reporter=line --shard=3/3
```

Expected behavior:

- Better possible wall-clock reduction than two shards.
- More report and artifact fragments.
- More Vite dev server instances in CI.
- More chances for environment-specific contention if CI runners share constrained CPU/GPU resources.

Pros:

- Useful if the two-shard release gate remains too slow.
- May bring the full gate closer to smoke-lane feedback time if CI runners are strong and isolated.

Cons:

- Higher coordination and artifact overhead.
- Higher chance of uneven shard runtimes because there are only 59 tests and two very slow spec families.
- Larger CI cost.

### Recommended First Shard Count

Start with the 2-shard plan.

Reason:

- It is the smallest safe sharding implementation.
- It should materially reduce release-gate wall-clock time without creating too many report/artifact fragments.
- It preserves the single-worker setting inside each shard.
- It can be added in CI without changing specs or coverage.
- If the slowest shard remains too long, then move to 3 shards after observing one or two CI runs.

## Local Vs CI Behavior

Local defaults should remain unchanged:

```bash
npm run test:e2e:smoke
npm run test:e2e:release
npm run test:e2e
```

CI can use shard commands directly. Sharding should not become the normal local default because local developers usually want one process, one report, one dev server, and easy reproduction.

Recommended CI sequence:

1. `npm ci`
2. `npm test`
3. `npm run build`
4. Playwright release shards in a matrix:
   - shard `1/2`
   - shard `2/2`

For a failed shard, reproduce locally with the exact shard command first. If the failure points to a specific test, rerun that test/file directly afterward.

## Built App And Server Strategy

### Same Built App

All shards should test the same commit and should be gated by the same `npm run build` result.

Smallest first implementation:

- Run `npm run build` before the Playwright matrix.
- Keep Playwright's existing `webServer` using `npm run dev` for the shard run.
- Treat the build as a required compile/production-bundle check, while e2e shards continue using the current dev-server behavior.

More release-faithful future implementation:

- Build once.
- Upload `dist/` as a CI artifact.
- Download the same `dist/` artifact in each shard job.
- Run shards against `npm run preview` or a dedicated static server.

Do not combine this preview-server switch with the first sharding change. It changes the app serving mode and should be tested as a separate CI hardening pass.

### Server Per Shard Or Shared Server

Recommended first implementation: start one Vite server per shard job.

Why:

- Current Playwright config already manages server lifecycle.
- Separate CI jobs usually cannot share a single localhost server cleanly.
- Per-shard servers avoid cross-shard localStorage, browser context, and server-state interference.
- Server startup cost is acceptable compared with the current 29-minute full release gate.

Avoid sharing one Vite dev server across parallel CI shards unless the CI platform provides a reliable service container or all shards run inside the same job with careful port management. Sharing one local server creates more contention and makes failures harder to reproduce.

If Playwright projects are later used inside one CI job, keep the current single Chromium project and avoid turning on `fullyParallel` until test isolation has been proven.

## Report And Artifact Strategy

Smallest first implementation:

- Keep `--reporter=line` for readable CI logs.
- Upload each shard's `test-results/` artifacts separately.
- Name artifacts with the shard id, for example `playwright-results-shard-1-of-2`.
- Review failures shard-by-shard.

Future merged-report implementation:

- Use Playwright's blob reporter in CI shards.
- Upload blob reports from each shard.
- Run a follow-up merge job with `npx playwright merge-reports`.
- Publish one HTML report from the merged output.

Do not make report merging a blocker for first sharding. Sharded line logs plus per-shard artifacts are enough for the first safe pass.

## Package Scripts

The minimal 2-shard scripts are now implemented:

```json
{
  "test:e2e:release:shard1": "playwright test --reporter=line --shard=1/2",
  "test:e2e:release:shard2": "playwright test --reporter=line --shard=2/2"
}
```

Equivalent CI-only commands:

```bash
npx playwright test --reporter=line --shard=1/2
npx playwright test --reporter=line --shard=2/2
```

Do not make these mandatory for local developers. `npm run test:e2e:release` and `npm run test:e2e` still run the complete suite in one command.

Optional 3-shard scripts for a later pass, if CI data shows the 2-shard split is still too slow:

```json
{
  "test:e2e:release:shard1of3": "playwright test --reporter=line --shard=1/3",
  "test:e2e:release:shard2of3": "playwright test --reporter=line --shard=2/3",
  "test:e2e:release:shard3of3": "playwright test --reporter=line --shard=3/3"
}
```

Avoid adding the 3-shard scripts until there is CI evidence that they are needed.

Example CI matrix values:

```text
SHARD=1/2
SHARD=2/2

npx playwright test --reporter=line --shard=$SHARD
```

On Windows PowerShell CI, the command shape would be:

```powershell
npx playwright test --reporter=line --shard=$env:SHARD
```

## Risk Analysis

| Risk | Level | Notes | Mitigation |
| --- | --- | --- | --- |
| Flakiness | Medium | Parallel CI jobs increase CPU/GPU pressure and can expose timing-sensitive Phaser/WebGL tests. | Keep `workers: 1` inside each shard, start with 2 shards, keep Chromium launch args, observe CI before moving to 3 shards. |
| Report fragmentation | Medium | Failures and traces split across shard jobs. | Upload per-shard artifacts first; add blob report merging later if needed. |
| Shared localStorage/test isolation | Low-medium | Playwright creates fresh browser contexts per test, but shared servers or reused browser state could confuse diagnosis. | Use one server per shard job and keep current page/context isolation. Do not share browser state. |
| Server startup contention | Medium | Multiple shard jobs each start Vite. Port conflicts can happen on shared runners. | Separate jobs usually isolate localhost. If running shards in one job, use separate ports/configs or run shards sequentially. |
| Artifacts | Medium | Trace/video/screenshot output can grow when multiple shards fail. | Retain current failure-only artifact behavior; name artifacts by shard. |
| Uneven shard duration | Medium | Layout and deep-flow tests dominate runtime and may not split perfectly. | Start with 2 shards and inspect timing. Move to 3 shards only if one shard remains too slow. |
| Built app mismatch | Low-medium | Current e2e runs dev server while `npm run build` separately validates production bundling. | Keep `npm run build` required before shards. Consider a later preview-server e2e pass if release fidelity becomes the goal. |

## Recommendation

Recommended smallest safe implementation:

1. Keep all current e2e tests and existing package scripts.
2. Use the new 2-shard scripts for the full Playwright release gate in CI:

   ```bash
   npm run test:e2e:release:shard1
   npm run test:e2e:release:shard2
   ```

3. Keep `workers: 1` and `fullyParallel: false`.
4. Let each shard start its own Vite dev server through the existing Playwright `webServer`.
5. Run `npm test` and `npm run build` before shards.
6. Upload per-shard Playwright artifacts and review failures by shard.
7. After one or two green CI runs, evaluate whether 2 shards are enough. Move to 3 shards only if the slowest shard still blocks feedback.

Do not split specs, retag tests, switch to preview server, enable extra workers, or merge reports in the first implementation. Those are separate improvements with their own verification cost.

## Verification For This Implementation Pass

Required checks:

```bash
npm test
npm run build
npm run test:e2e:smoke
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Result:

```text
npm test
PASS: 38 test files, 270 tests, 9.19s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-Bi19pD8P.js, 436.32 kB / gzip 117.33 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.2m.

npm run test:e2e:release:shard1
PASS: 49 Playwright tests in 23.0m.
Slow files: tests/e2e/layout.spec.ts 12.0m and tests/e2e/deep-flow.spec.ts 10.8m.

npm run test:e2e:release:shard2
PASS: 10 Playwright tests in 4.2m.

npm run playtest:sim
PASS: 255 deterministic runs across 85 campaign battle nodes.

git diff --check
PASS.
```

Local verification note: the 2-shard split is coverage-preserving but uneven on this suite because Playwright's first shard currently receives the deep-flow and layout-heavy files. Treat the shard scripts as CI matrix tools first. Running both shards sequentially on a local machine is not expected to beat the one-piece release gate.
