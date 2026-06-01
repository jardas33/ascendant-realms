# v0.95 Implementation Report

## Runtime

- Added `src/game/ui/PlaceholderBattlefieldPresentation.ts` to centralize placeholder silhouette and label-priority rules.
- Updated unit placeholders with clearer hero/commander, Worker, frontline, ranged/caster, hostile, and elite presentation using existing Phaser primitives.
- Updated building placeholders with clearer command, barracks, shrine, watchtower, and utility silhouettes.
- Added label default-visibility controls so routine units are quieter while selected/statused, hero, commander/elite, building, and capture-site labels remain readable.
- Improved battle terrain rendering with deterministic road, water, blocked-ground, terrain scuff, and site-ground readability details.
- Softened fog presentation without changing visibility or exploration logic.
- Tuned capture-site ring intensity and objective relevance using existing secondary objective metadata.
- Slightly enlarged minimap presentation and marker families.
- Added 18 v0.95 visual-QA screenshots and raised the deterministic screenshot set to 102.
- Updated package generation/validation metadata to require and copy all v0.95 docs.

## Save Format

No save-version bump. No save fields, localStorage keys, stable IDs, serialized values, mission IDs, map IDs, site IDs, Lume IDs, unit IDs, building IDs, reward IDs, hero rules, campaign progression, rewards, XP, or persistent settings changed.

## QA

Passed:

- `npm test` - 94 files / 686 tests.
- `npm run build` - passed with the known Vite Phaser vendor chunk-size warning.
- `npm run validate:content`.
- `npm run validate:art-intake`.
- `npm run test:e2e:smoke:fast` - 9 tests.
- `npm run test:e2e:smoke` - 16 tests.
- `npm run playtest:controls` - 18 scenarios / 18 pass rows.
- `npm run playtest:controls:extended` - 90 pass rows.
- `npm run playtest:controls:verify` - 1658 checks.
- `npm run playtest:act1` - 180 Act 1 runs summarized from 255 deterministic simulator runs.
- `npm run test:e2e:release:hosted:deep-battle` - 29 tests.
- `npm run test:e2e:release:hosted:smoke` - 16 tests.
- `npm run test:e2e:release:hosted:deep-campaign-pressure` - 8 tests.
- `npm run test:e2e:release:hosted:layout-core` - 27 tests.
- `npm run test:e2e:release:hosted:layout-cinderfen` - 12 tests.
- `npm run visual:qa` - 11 tests / 102 screenshots / 0 console errors / 0 retries.
- `npm run visual:review-pack` - 102 screenshots / 7 contact sheets.

Non-pass evidence resolved:

- Initial full `npm test` caught unsupported triangle primitives in existing Phaser test doubles. Placeholder silhouettes now use rectangle/ellipse/circle primitives.
- A targeted v0.95-only visual-QA grep run failed only the global expected-screenshot count because the suite was intentionally filtered. The full visual-QA suite passed afterward.
- Hosted lanes still log existing verified actionability fallbacks in older tests. v0.95 did not add or broaden canvas/world click fallbacks.

## Package

Final clean package generation and verification are performed after committing so the package has no dirty suffix and uses the final v0.95 commit hash.
