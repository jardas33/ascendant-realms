# v0.11.5 Fast Confidence Lane Split

Date: 2026-05-12

## Purpose

v0.11.5 splits GitHub Actions browser smoke coverage into a smaller automatic fast-confidence subset and the existing full smoke/release lanes. This keeps push/PR CI stable on GitHub-hosted runners without deleting tests, skipping coverage, weakening assertions, changing gameplay, changing saves, changing campaign progression, changing content, or touching runtime art.

## GitHub Failure Evidence

Emmanuel reported that the v0.11.4 push still failed the automatic `Fast confidence` job in the `CI Release Matrix Dry Run` workflow.

Failed step:

```text
Run npm run test:e2e:smoke
playwright test tests/e2e/smoke.spec.ts --reporter=line
```

Important result: the previous settings timeout was no longer the main issue. The hosted runner got past settings, then hit longer campaign/skirmish smoke flows.

Reported failures/flakes:

- `campaign Border Village launches a battle scene`: browser context setup failure.
- `post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards`: timeout clicking `campaign-node-cinderfen_crossing`; retry hit `page.reload: net::ERR_ABORTED`.
- `post-Crossing campaign launches Cinderfen Watch and persists completion`: timeout clicking `campaign-node-cinderfen_aftermath`; retry could not find `.results-panel`.
- `skirmish setup lists maps and launches Broken Ford`: flaky `main-menu` boot wait.
- `skirmish difficulty selection changes fog and starting pressure`: flaky timeout clicking `setup-start-battle`.

Final hosted result was about 16.1 minutes with 2 failed, 3 flaky, and 7 passed.

## Why v0.11.4 Was Not Enough

v0.11.4 made the seeded-save helper more deterministic and preserved all local coverage. Local final verification passed full smoke, full release, 3-way shards, visual QA, simulator, and preview smoke.

The new hosted evidence shows a broader lane-design problem: the whole 12-test smoke file is too heavy and context-sensitive for an automatic push/PR confidence job on GitHub-hosted runners. Continuing to raise timeouts would make the automatic job slower while still running the longest campaign and skirmish flows in the most failure-prone CI slot.

## New Lane Split

`npm run test:e2e:smoke:fast` is the automatic GitHub fast-confidence browser lane. It runs only tests tagged `@ci-fast`.

Fast CI smoke tests:

- `main menu boots @ci-fast`
- `tutorial entry launches a no-reward shell and returns to menu @ci-fast`
- `tutorial exit returns to menu without saving @ci-fast`
- `settings screen persists accessibility options @ci-fast`
- `new campaign flow opens the campaign map and blocks locked nodes @ci-fast`
- `inventory screen opens without crashing @ci-fast`

`npm run test:e2e:smoke` is unchanged as the full smoke lane. It still runs all 12 smoke tests, including the fast tests and the extended tests.

Extended smoke tests:

- `campaign Border Village launches a battle scene @extended-smoke`
- `post-Ashen campaign resolves Cinderfen Overlook, wins Cinderfen Crossing, and persists rewards @extended-smoke`
- `post-Crossing campaign launches Cinderfen Watch and persists completion @extended-smoke`
- `post-Ashen Cinderfen event reacts to Malrec's trophy standard @extended-smoke`
- `skirmish setup lists maps and launches Broken Ford @extended-smoke`
- `skirmish difficulty selection changes fog and starting pressure @extended-smoke`

## GitHub Actions Change

The automatic `Fast confidence` job now runs:

```bash
npm run test:e2e:smoke:fast
```

instead of:

```bash
npm run test:e2e:smoke
```

The job still runs:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run validate:art-intake`
- `npm run smoke:preview`

Manual workflow lanes remain unchanged:

- optional visual QA
- manual 3-way release matrix
- manual simulator
- manual full release lane

## Coverage Preservation

No tests were deleted. No tests were skipped globally. No assertions were weakened.

Coverage is preserved because:

- `npm run test:e2e:smoke` still runs all 12 smoke tests locally and in final gates.
- `npm run test:e2e:release` still runs the full 67-test Playwright suite.
- the manual 3-way release matrix still includes the smoke file through shard 3.
- final local gates still require full smoke, full release, 3-way shards, visual QA, simulator, preview smoke, and `git diff --check`.

The automatic GitHub push/PR lane is now a fast confidence indicator, not a replacement for full smoke or release verification.

## How Emmanuel Should Verify

After this commit is pushed, check the next automatic GitHub Actions run:

1. Open `CI Release Matrix Dry Run`.
2. Open the automatic `Fast confidence` job.
3. Confirm the e2e step name is `E2E fast smoke`.
4. Confirm it runs `npm run test:e2e:smoke:fast`.
5. Confirm the listed browser tests are the six `@ci-fast` smoke tests.
6. Confirm the job continues to `npm run smoke:preview`.
7. Confirm manual visual/release jobs remain skipped unless explicitly triggered.

If the automatic job passes, use manual `workflow_dispatch` release lanes or local final gates for the extended campaign/skirmish smoke coverage.

## Full Local Verification

```text
npm test
PASS: 46 test files, 351 tests.

npm run build
PASS: TypeScript compile and Vite production build. The known Phaser vendor chunk-size warning remains.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: checked 1 candidate metadata JSON file and 0 review manifest JSON files.

npm run test:e2e:smoke:fast
PASS: 6 tests in about 2.1m.

npm run test:e2e:smoke
PASS: 12 tests in about 5.2m.

npm run smoke:preview
PASS: production preview checks passed with 0 browser console errors.

git diff --check
PASS: no whitespace errors; PowerShell reported only the normal workflow line-ending notice.

npm run test:e2e:release
PASS: 67 tests in about 31.2m.

npm run test:e2e:release:shard1of3
PASS: 28 tests in about 11.1m.

npm run test:e2e:release:shard2of3
PASS: 27 tests in about 15.2m.

npm run test:e2e:release:shard3of3
PASS: 12 tests in about 5.7m.

npm run visual:qa
PASS: 18 screenshots, 0 browser console errors.

npm run playtest:sim
PASS: 255 simulated runs across 85 campaign battle nodes.
```
