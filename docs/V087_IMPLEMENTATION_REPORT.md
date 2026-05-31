# v0.87 Implementation Report

## Summary

v0.87 is a campaign-shell and Results information-architecture polish milestone. It improves presentation density, map-first campaign readability, tab hierarchy, and ordinary Results progressive disclosure without changing gameplay systems, campaign progression, rewards, saves, stable ids, maps, factions, or runtime art assets.

## Runtime Changed

- Campaign nodes now expose presentation-only `mapX`, `mapY`, and `chapterId` fields for map layout.
- The Map tab now uses a wider map-first shell with chapter lanes, route lines, clearer node states, and larger node spacing.
- Border Village remains selected for a fresh campaign and locked Aether Well Ruins remains previewable.
- The selected mission panel is compact by default and keeps secondary campaign prose behind `More Details`.
- Stronghold, Hero, Inventory, Intel, and Reputation tabs use card hierarchy and details disclosures for long explanatory copy.
- Ordinary Results screens now render a compact overview, primary actions, visible key reward/progression actions, and a collapsed `Show Full Battle Details` section for telemetry-heavy information.
- The v0.85 private-demo Results branch remains separate and unchanged.

## Save Format

No save format change. No migration, version bump, localStorage key, persistent setting, reward field, or campaign-progress field was added.

## Tests

Added or updated tests for:

- campaign presentation coordinates and chapter metadata,
- node state/class readability,
- fresh campaign view at 1920x1080 and 1366x768,
- node non-overlap,
- selected Border Village and locked Aether Well preview,
- tab navigation and relocated guidance copy,
- selected mission `More Details` disclosure,
- normal victory Results overview,
- normal defeat Results overview,
- replay Results overview and action,
- private-demo Results preservation through existing coverage,
- package validation requiring all v0.87 docs.

## Verification

Final pre-commit verification evidence:

- `npm test` - PASS, 91 files / 675 tests.
- `npm run build` - PASS with the known Phaser vendor chunk-size warning.
- `npm run validate:content` - PASS.
- `npm run validate:art-intake` - PASS.
- `npm run playtest:controls` - PASS, 18 scenarios / 18 pass rows.
- `npm run playtest:controls:extended` - PASS, 90 pass rows.
- `npm run playtest:controls:verify` - PASS, 1658 checks.
- `npm run playtest:act1` - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
- `npm run test:e2e:smoke:fast` - PASS, 9 tests.
- `npm run test:e2e:smoke` - PASS, 16 tests.
- `npm run test:e2e:layout` - PASS, 32 tests.
- `npm run test:e2e:release:hosted:deep-battle` - PASS, 29 tests.
- `npm run test:e2e:release:hosted:smoke` - PASS, 16 tests.
- `npm run test:e2e:release:hosted:deep-campaign-pressure` - PASS, 8 tests.
- `npm run visual:qa` - PASS, 6 tests / 36 screenshots / 0 browser console errors / 0 screenshot retries.

Non-pass evidence:

- A broad local `npm run test:e2e:release` attempt exceeded a 40-minute command timeout without returning a usable summary. The layout shard later passed 32/32, and the required hosted release lanes passed.
- Early local hosted attempts exposed dev-server occupancy and heavy Worker scenario timing pressure before exact reruns and the final hosted deep-battle suite passed.

Final package generation and package verification run after the final checkpoint commit so package build info can reference the exact clean commit.
