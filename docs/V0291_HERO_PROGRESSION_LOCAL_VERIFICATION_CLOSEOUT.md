# v0.29.1 Hero Progression Local Verification Closeout

Date: 2026-05-26

## Scope

v0.29.1 is a closeout and documentation checkpoint for the v0.28-v0.29 hero progression and ability foundation. It adds no gameplay systems, no balance changes, no maps, no factions, no runtime art/assets, no save migration, no pathing rewrite, and no test weakening.

## Baseline

- Baseline commit: `aa6fc05`
- Baseline package: `ascendant-realms-private-playtest-aa6fc05`
- Runtime checkpoint being closed out: v0.28-v0.29 hero progression and ability foundation
- Remote CI status: blocked before checkout by GitHub HTTP 403 account-suspension response; see `docs/V0291_BLOCKED_REMOTE_CI_STATUS.md`

## Package And Retest Guidance

The private package continues to include the v0.28-v0.29 hero progression material:

- `V028_HERO_PROGRESSION_SPEC.md`
- `V028_IMPLEMENTATION_REPORT.md`
- `V029_HERO_ABILITIES_AND_REWARDS_SPEC.md`
- `V029_IMPLEMENTATION_REPORT.md`
- `V029_EMMANUEL_RETEST_CHECKLIST.md`

v0.29.1 also includes:

- `V0291_BLOCKED_REMOTE_CI_STATUS.md`
- `V0291_HERO_PROGRESSION_LOCAL_VERIFICATION_CLOSEOUT.md`

## Emmanuel Retest Focus

Use the v0.29.1 package once regenerated from the closeout commit. Retest the same v0.28-v0.29 hero progression surfaces:

- Hero gains XP from valid combat participation.
- Hero gains one-time XP from first player capture of a resource site.
- Hero level, XP progress, damage, armor, skill points, and ability unlock state remain readable in the HUD.
- Rally Banner and Cleave show ready, cooldown, and disabled states clearly.
- Abilities cannot be spammed while on cooldown.
- Tutorial / Proving Grounds remains no-save and no-reward.
- Victory results summarize battle XP, reward XP, level-ups, and skill points.
- v0.22/v0.23 Worker/resource-site behavior and v0.24-v0.27 enemy site/base/tech pressure still regress cleanly.

## Local Fallback Verification

Remote GitHub Actions is blocked before checkout, so this local matrix is the v0.29.1 fallback evidence:

```text
npm test PASS, 72 files / 533 tests.
npm run build PASS with the known Vite Phaser chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS, 1 candidate metadata JSON and 0 review manifest JSON files checked.
npm run test:e2e:smoke:fast PASS, 8 tests.
npm run test:e2e:smoke PASS, 14 tests.
npm run playtest:controls PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended PASS, 18 scenarios / 90 pass rows.
npm run playtest:controls:verify PASS, 1658 checks.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS, 5 tests / 18 screenshots / 0 browser console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty package artifacts/playtest/ascendant-realms-private-playtest-aa6fc05-dirty generated.
npm run verify:playtest-package PASS, 85 checks.
```

Run `git diff --check` after these docs are synchronized. After committing v0.29.1, regenerate the package from the clean final commit and rerun `npm run verify:playtest-package` before sending the package to testers.
