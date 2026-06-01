# v0.98 Implementation Report

Status: implemented and verified.

## Scope

`v0.98 Hero, Retinue, Inventory, and Stronghold UX Rescue` is a presentation-only meta-progression milestone. It changes hierarchy, markup, CSS, tests, visual QA, package metadata, and docs. It does not change progression rules, XP, relic stats, equipment rules, Retinue rules, Stronghold rules, saves, stable IDs, rewards, campaign progression, art, imported assets, desktop work, or gameplay systems.

## Runtime Changed

- Hero Progression scene now opens with a Hero Overview card and concise Results-to-meta guidance.
- Skill trees now present available / purchased / locked state, cost, requirement, concise effect, and details disclosure.
- Equipment now reads as a loadout, with details collapsed.
- Inventory now groups equipped gear, stored gear, and relics.
- Retinue Camp now surfaces Ready, Deployed, Recovering, Reserve, reinforcement eligibility, recovery block reason, and member details disclosure.
- Stronghold now surfaces tier, available/locked/purchased counts, cost, prerequisite, benefit, and collapsed details.
- Results now include a compact `Progression Summary` for XP, rewards, relics, Retinue, and Stronghold/campaign resources.

## Tests Added

- `src/game/progression/MetaProgressionUx.test.ts`
- Extended campaign presentation tests for Stronghold hierarchy and Retinue wording.
- Extended Results helper tests for the progression summary.
- Extended visual QA with eight v0.98 captures.

## Save Format

No save-version bump. No save fields changed. Rendering helpers are presentation-only and do not mutate saves.

## Package

Package metadata now names v0.98 and includes the v0.98 docs/retest checklist.

## Verification

```text
npm test - PASS, 98 files / 700 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests after updating the inventory smoke assertion for the new Hero Overview default and rerunning an unrelated transient settings click test.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 30 tests after one transient behaviour-gauntlet timeout passed on exact rerun and full-lane rerun.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run test:e2e:release:hosted:layout-core - PASS, 27 tests.
npm run test:e2e:release:hosted:layout-cinderfen - PASS, 12 tests.
npm run visual:qa - PASS, 14 tests / 126 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 126 screenshots / 7 contact sheets.
npm run package:playtest - PASS for the pre-commit dirty package; final clean package is generated after commit.
npm run verify:playtest-package - PASS, 350 checks on the pre-commit dirty package.
```
