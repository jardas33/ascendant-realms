# v0.16.8 Long Soak Results

Date: 2026-05-22

## Purpose

Use Emmanuel's away time for extra automated confidence after v0.16.7 changed runtime combat/control behaviour.

## Long Checks Run

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "manual combat contact regression" --repeat-each=5 --reporter=line
PASS: 5/5 in 1.6m.
```

```text
npm run test:e2e:release:hosted:deep-battle
PASS: 14 tests in 4.4m.
```

```text
npm run test:e2e:release:hosted:smoke
First run failed on a stale transient status-line assertion.
After test-only fix, full rerun PASS: 14 tests in 2.9m.
```

```text
npm run test:e2e:release
PASS: 79 tests in 38.7m.
```

```text
npm run visual:qa
PASS: 5 tests in 4.4m.
18 screenshots, 0 browser console errors, 0 screenshot retries.
```

## Watchpoints

- GitHub Actions manual workflow-dispatch release matrix for the v0.16.7/v0.16.8 runtime-change stack still needs an authenticated run because the remote v0.16.7 push run only executed Fast confidence.
- Existing DOM-control fallbacks appeared in smoke/layout/deep-flow logs for DOM buttons. No force clicks or canvas/world DOM fallback were added or used.
- Public tracked image assets remain prototype assets with source/license proof still needed before production approval.

## Decision

No runtime fix was needed during the long soak. The only code fix was test-harness stabilization for a transient status-line assertion in hosted smoke.
