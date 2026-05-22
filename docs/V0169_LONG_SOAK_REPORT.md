# v0.16.9 Long Soak Report

Date: 2026-05-22

## Scope

Long automated verification for v0.16.9's manual-retest proxy and tester-readiness checkpoint. v0.16.9 does not change runtime gameplay.

## Focused Proxy And Edge Checks

```text
npm test -- CombatSystem.test.ts ControlBehaviourScenarioLab.test.ts
PASS: 2 files, 29 tests.

Focused repeat:
same command repeated 5 times.
PASS: 5/5, no flakes.

npm run playtest:controls
PASS: 18 scenarios, 18 pass rows, 0 fail rows.

npm run playtest:controls:extended
PASS: 18 scenarios, 5 iterations, 90 pass rows, 0 fail rows.

npm run playtest:controls:verify
PASS: 1658 checks.

npx playwright test --config=playwright.hosted-release.config.ts tests/e2e/deep-flow.spec.ts --grep "behaviour mode control gauntlet|manual combat contact regression" --repeat-each=3 --reporter=line
PASS: 6 tests in 2.8m.
```

## Required Gates

```text
npm test
PASS: 57 files, 415 tests.

npm run build
PASS: TypeScript and Vite production build. Known Phaser vendor chunk warning only.

npm run validate:content
PASS.

npm run validate:art-intake
PASS: 1 candidate metadata JSON, 0 review manifests.

npm run test:e2e:smoke:fast
PASS: 8 tests in 2.4m.

npm run test:e2e:smoke
PASS: 14 tests in 6.8m.

npm run test:e2e:release:hosted:deep-battle
PASS: 14 tests in 4.2m.

npm run test:e2e:release:hosted:smoke
PASS: 14 tests in 2.7m.

npm run test:e2e:release
PASS: 79 tests in 38.4m.

npm run visual:qa
PASS: 5 tests in 4.2m; 18 screenshots, 0 browser console errors, 0 screenshot retries.
```

`npm run package:playtest`, `npm run verify:playtest-package`, and final `git diff --check` are run after the final docs are synchronized and the clean commit exists, so the package name can use the final commit short hash without `-dirty`.

## Notes

- Existing verified DOM button fallbacks appeared in smoke/layout/deep-flow logs for DOM buttons. No force clicks or canvas/world DOM fallback were added.
- No deterministic combat/contact, building aggro, retreat, hover, minimap, or Results regression reproduced.
- GitHub Actions run #80 later provided the enabled workflow-dispatch release matrix evidence on `ad4eee0`: Fast confidence, release simulator, and hosted release matrix deep-meta, deep-battle, deep-campaign-pressure, layout-core, layout-cinderfen, and smoke all passed. Optional visual QA and full release e2e were skipped remotely and remain local evidence from this soak.
