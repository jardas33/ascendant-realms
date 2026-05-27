# v0.29.2 Long Soak Report

Date: 2026-05-27
Scope: extra soak because the hosted deep-battle fix landed before broader release closeout.

## Soak Commands

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet" --repeat-each=5 --retries=0 --trace=retain-on-failure --reporter=line
```

Result:

```text
PASS, 5 tests.
```

```text
npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "battle HUD supports minimap movement|battle HUD keeps hovered command buttons stable|behaviour mode control gauntlet|Worker assignment and site upgrade boost" --retries=0 --trace=retain-on-failure --reporter=line
```

Result:

```text
PASS, 4 tests.
```

```text
npm run test:e2e:release:hosted:deep-battle
```

Result:

```text
PASS, 27 tests.
```

## Notes

- No runtime gameplay files changed during the soak.
- No broad retries were added.
- The fixed gauntlet was repeated without retries.
- The full hosted deep-battle lane passed locally after the targeted soak.
- Visual QA later passed with 5 tests, 18 screenshots, 0 browser console errors, and 0 screenshot retries.
- Additional full verification and remote release-matrix evidence are tracked in `docs/V0292_RELEASE_MATRIX_CLOSEOUT.md`.
