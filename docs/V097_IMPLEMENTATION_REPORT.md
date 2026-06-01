# v0.97 Implementation Report

Status: implemented and locally verified; final clean package is generated from the final commit.

## Scope

`v0.97 Camera, Selection, Orders, and Tactical Feedback Polish` improves controls readability and tactical feedback. It does not add gameplay systems, alter unit stats, change combat balance, change pathing rules, change saves, rename stable IDs, add art, import assets, start desktop work, add multiplayer, or begin v0.98.

## Runtime Changes

- Added `CommandFeedbackMarker` presentation rules for move, attack-move, attack, Patrol, rally, build, ability, invalid, and focus feedback.
- Added short-lived Phaser command markers in BattleScene with reduced-motion-safe cleanup.
- Emitted markers from existing move, attack, Patrol, rally, construction placement, ability cast, minimap focus, and invalid no-selection/placement flows.
- Added selection focus cards for hero, Worker, combat unit, squad, building, site, and enemy inspection states.
- Added read-only enemy inspection without exposing player behavior controls.
- Focus hotkey now prioritizes the current selection before falling back to the hero.
- Camera clamping moved into a small pure helper used by camera center/scroll calls.
- Command-panel disclosure text now reads `More Details`.
- Help copy now explains selection focus, minimap jump, and command destination feedback more directly.

## Save Format

- No save-version bump.
- No new save fields.
- No new localStorage keys.
- No persistent settings added.
- Existing reduced-motion setting is reused.
- Stable IDs, serialized values, mission IDs, map IDs, node IDs, site IDs, unit IDs, building IDs, reward IDs, and save fields are unchanged.

## Verification

```text
npm test - PASS, 97 files / 696 tests.
npm run build - PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content - PASS.
npm run validate:art-intake - PASS, 1 candidate metadata JSON file checked and 0 review manifests.
npm run test:e2e:smoke:fast - PASS, 9 tests.
npm run test:e2e:smoke - PASS, 16 tests.
npm run playtest:controls - PASS, 18 scenarios / 18 pass rows.
npm run playtest:controls:extended - PASS, 90 pass rows.
npm run playtest:controls:verify - PASS, 1658 checks.
npm run playtest:act1 - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
npm run test:e2e:release:hosted:deep-battle - PASS, 30 tests.
npm run test:e2e:release:hosted:smoke - PASS, 16 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure - PASS, 8 tests.
npm run visual:qa - PASS, 13 tests / 118 screenshots / 0 console errors / 0 screenshot retries.
npm run visual:review-pack - PASS, 118 screenshots / 7 contact sheets.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "Worker assignment and site upgrade boost a captured resource site" --reporter=line - PASS, 1 test.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "battle HUD preserves side-panel scroll across forced refreshes" --timeout=120000 --reporter=line - PASS, 1 test after one startup actionability rerun.
npx playwright test tests/e2e/deep-flow.spec.ts --grep "captured resource sites stay locally visible under fog after units leave" --timeout=120000 --reporter=line - PASS, 1 test.
```

Non-pass evidence: an attempted full local `npm run test:e2e:release` exceeded the 60-minute local tool timeout with no pass/fail output. A follow-up `npm run test:e2e:release:shard1of3` attempt produced three startup/timeout-style failures in older deep-flow coverage; the three exact failed tests were rerun and passed. The required hosted lanes listed above passed after the v0.97 changes.

## Package

Package metadata now points at v0.97 and requires the v0.97 docs. The final clean package is generated after the final commit so the package hash and dirty flag match the committed tree.

## Push

Final commit and push status are reported in the closeout response.
