# v0.16.1 Fast Confidence CI Failure Audit

Date: 2026-05-20

Scope: triage GitHub Actions CI Release Matrix Dry Run #64 after v0.16 commit `c28f19d`, limited to the automatic Fast confidence smoke regression.

## Baseline

- Local branch before work: `main`.
- Local HEAD before work: `c28f19d82205a1dd8358c4412fdf030d3d9e3b7b`, `Checkpoint v0.16 behaviour mode gauntlet and playtest diagnostics`.
- Local sync status before work: clean and `origin/main...HEAD` reported `0 0`.
- Fast confidence workflow command: `npm run test:e2e:smoke:fast`.
- Fast confidence Playwright config: default `playwright.config.ts`, Vite dev server, 35s global test timeout, one worker, CI retry count 1.

## Remote Evidence

Supplied GitHub Actions evidence from Emmanuel:

- Workflow: CI Release Matrix Dry Run
- Run: #64, `Checkpoint v0.16 behaviour mode gauntlet and playtest diagnostics`
- Commit: `c28f19d`
- Failed job: Fast confidence
- Duration: 6m 59s
- Result: 1 failed, 1 flaky, 5 passed
- Primary failed test: `tests/e2e/smoke.spec.ts:834`, `settings screen persists accessibility options @ci-fast`
- Secondary flaky test: `tests/e2e/smoke.spec.ts:1529`, `inventory screen opens without crashing @ci-fast`
- Secondary error excerpt: `Test timeout of 35000ms exceeded while setting up "context"` and `browser.newContext: Protocol error (Browser.setDownloadBehavior): Failed to find browser context for id ...`

Artifact paths mentioned by the remote run:

- `test-results/smoke-Ascendant-Realms-bro-950d8-cessibility-options-ci-fast-chromium-retry1/error-context.md`
- `test-results/smoke-Ascendant-Realms-bro-2e1c9-ns-without-crashing-ci-fast-chromium/error-context.md`
- matching `trace.zip` files under the same result folders

Direct artifact/log inspection was not available:

- `gh` CLI is not installed locally.
- The GitHub connector can fetch jobs/artifacts only by numeric Actions run id, not the displayed run number `#64`; using `64` as a run id returned 404.
- The connector returned no PR-triggered runs or combined statuses for `c28f19d`.
- Public GitHub REST calls returned 404 for this private repository.

## Failure Classification

Settings failure classification: likely timeout/actionability-resource pressure, not a protected settings assertion failure and not a gameplay/runtime regression.

Evidence:

- The remote artifact name includes `retry1`, so the settings test reached the retry attempt and still produced failure context.
- The job duration of 6m 59s is consistent with the long settings test consuming substantial retry budget and leaving the browser runner unstable for the later inventory context.
- The settings test already had a 90s scoped timeout from v0.14.2 because it combined settings persistence, direct battle launch, runtime settings assertions, colorblind minimap assertions, and pause/resume behavior.
- Local targeted settings repro on `c28f19d` passed but took about 50.6s with trace enabled.
- Local repeated settings repro passed 3/3 before the fix, but the test remained one long multi-scene smoke path.

Inventory failure classification: likely downstream browser/context instability, not an independent inventory app bug.

Evidence:

- The reported error happened while setting up Playwright context before inventory assertions could run.
- Local targeted inventory passed independently before and after the settings fix.
- After the settings split, inventory passed in 24.5s with trace enabled.

## Local Reproduction

Initial local baseline:

```text
npm run test:e2e:smoke:fast
PASS, 7 tests in 2.5m.

npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line
PASS, 1 test in 50.6s.

npx playwright test tests/e2e/smoke.spec.ts --grep "inventory screen opens without crashing" --retries=1 --trace=on --reporter=line
PASS, 1 test in 36.9s.

npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 2.6m.
```

During full smoke after the first split, local Playwright exposed the concrete actionability race:

```text
npm run test:e2e:smoke
FAIL, settings screen persists accessibility options @ci-fast.
Error: settings smoke reopen settings: DOM click fallback refused: no matched elements.
```

The local error context showed the Settings screen was already open when the helper reported no remaining `menu-settings` element. That means the reopen click succeeded or advanced the UI, but the click helper did not treat the reached Settings screen as success before trying DOM fallback against a now-gone main-menu button.

A later accidental parallel run of two Playwright targets was discarded because both commands contended for the same dev-server port. The orphaned Node/Playwright processes were stopped before sequential verification continued.

## Root Cause

The root cause was an oversized and actionability-sensitive Fast confidence settings smoke path:

1. The original `settings screen persists accessibility options @ci-fast` test covered both settings save/reopen persistence and in-battle runtime settings application in one browser context.
2. On slower hosted CI, that one test had enough scene transitions, DOM re-renders, trace/video overhead, and direct BattleScene setup to consume retry budget and destabilize the next browser context.
3. The local full-smoke failure showed one concrete race inside that path: the reopen Settings button click could succeed while Playwright still reported click actionability trouble, and the helper then failed because the main-menu button was gone.

This is related to the earlier v0.11.3/v0.14.2 settings timeout pattern: the settings smoke assertions are valid but expensive for GitHub-hosted automatic confidence. v0.16 did not directly break settings runtime behavior, but the v0.16 release increased total smoke/release surface and made the long `@ci-fast` settings path a fresh CI pressure point.

## Smallest Safe Fix

The smallest safe fix is test-only:

- Split settings persistence and in-battle runtime settings application into two focused `@ci-fast` tests.
- Keep the original `settings screen persists accessibility options @ci-fast` test for save/reopen, localStorage, and document dataset assertions.
- Add `settings accessibility options apply in battle @ci-fast` for floating text, fog override, reduced motion, colorblind minimap runtime state, minimap marker colors, and pause/resume behavior.
- Add a success check to the Settings menu click so reaching `settings-screen` after a transient actionability error is accepted before DOM fallback.

No settings assertions are weakened. Inventory assertions remain unchanged. No runtime gameplay, save format, content, package, or CI matrix structure changes are required.

## Final Verification

Final local verification after the fix:

```text
npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --reporter=line
PASS, 1 test in 38.2s.

npx playwright test tests/e2e/smoke.spec.ts --grep "inventory screen opens without crashing" --retries=1 --trace=on --reporter=line
PASS, 1 test in 28.8s.

npm run test:e2e:smoke:fast
PASS, 8 tests in 2.6m.

npm run test:e2e:smoke
PASS, 14 tests in 7.4m.

npm test
PASS, 56 files / 406 tests.

npm run build
PASS with the known Phaser vendor chunk warning.

npm run validate:content
PASS.

npm run validate:art-intake
PASS, 1 candidate metadata JSON and 0 review manifests checked.

npm run playtest:controls
PASS, 10 scenario rows / 10 pass.

npm run playtest:controls:verify
PASS, 930 checks.

npm run test:e2e:release:hosted:smoke
FAIL on first run in unrelated extended smoke status copy: Cinderfen Crossing battle launched, but transient `Normal` difficulty text was already replaced by `AI: EXPAND - Time 0:12`.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/smoke.spec.ts --grep "post-Ashen campaign resolves Cinderfen Overlook" --retries=1 --trace=on --reporter=line
PASS, 1 test in 35.6s.

npm run test:e2e:release:hosted:smoke
PASS on full rerun, 14 tests in 3.3m.

npm run test:e2e:release
PASS, 77 tests in 38.4m.

npx playwright test tests/e2e/smoke.spec.ts --grep "settings screen persists accessibility options" --retries=1 --trace=on --repeat-each=3 --reporter=line
PASS, 3 tests in 1.5m.

git diff --check
PASS.
```

The first hosted smoke failure was not the reported Fast confidence failure, not settings persistence, and not inventory. It was treated as a rerun-cleared extended-smoke transient because the targeted hosted case passed immediately and the full hosted smoke lane then passed 14/14 without code changes.
