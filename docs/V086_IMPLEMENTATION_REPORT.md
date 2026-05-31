# v0.86 Implementation Report

## Summary

v0.86 is a presentation-only battlefield-shell rescue. It does not change saves, gameplay rules, balance, Lume rules, maps, factions, runtime art assets, command IDs, or objective/reward logic.

## Runtime Changed

- Compact command panel entries now show action, cost, short lock reason, and accessible label first.
- Long command descriptions and effect text moved into details disclosures.
- Battlefield status messages now map to critical, important, routine, or debug categories.
- Routine command confirmations are shortened and deduplicated.
- Objective tracker no longer shows misleading `Objectives 0/0` when special context exists without ordinary objectives.
- Battlefield event and doctrine rows use compact details for counterplay.
- Capture-site labels now use contrast chips and state prefixes.
- Selection rings now use restrained team-specific presentation.
- Fog overlay uses softer rounded cells for unexplored and explored-muted states while preserving visibility logic.
- Minimap capture-site markers now distinguish neutral, owned, and objective sites more clearly.

## Save Format

No save format change. No migration, version bump, or persistent settings were added.

## Tests

Added or updated tests for:

- notification priority/category/dedupe behavior,
- compact command details,
- objective tracker special-context presentation,
- capture-site presentation,
- selection presentation,
- fog presentation,
- minimap objective-site markers,
- existing attack-order e2e copy expectation after routine command shortening.

## Verification

- `npm test -- --run src/game/battle/BattleStatusPriority.test.ts src/game/ui/hudPanels/CommandPanel.test.ts src/game/ui/hudPanels/ObjectivePanel.test.ts src/game/ui/MinimapView.test.ts src/game/ui/CaptureSitePresentation.test.ts src/game/ui/FogPresentation.test.ts src/game/ui/SelectionPresentation.test.ts` - PASS, 7 files / 37 tests.
- `npm run build` - PASS, with known Phaser vendor chunk warning.
- `npm test` - PASS, 91 files / 672 tests.
- `npm run validate:content` - PASS.
- `npm run validate:art-intake` - PASS.
- `npm run test:e2e:smoke:fast` - PASS, 9 tests.
- `npm run test:e2e:smoke` - PASS, 15 tests after an exact Broken Ford scene-transition rerun.
- `npm run playtest:controls` - PASS, 18 scenarios / 18 pass rows.
- `npm run playtest:controls:extended` - PASS, 90 pass rows.
- `npm run playtest:controls:verify` - PASS, 1658 checks.
- `npm run playtest:act1` - PASS, 180 Act 1 runs summarized from 255 deterministic simulator runs.
- `npm run test:e2e:release:hosted:deep-battle` - PASS, 29 tests after compact-command/minimap/details expectation updates and exact reruns.
- `npm run test:e2e:release:hosted:smoke` - PASS, 15 tests.
- `npm run test:e2e:release:hosted:deep-campaign-pressure` - PASS, 8 tests after an exact compact-upgrade-details rerun.
- `npm run visual:qa` - PASS, 6 tests / 31 screenshots / 0 console errors / 0 screenshot retries.

Final clean package generation and package verification run after the final checkpoint commit so package build info can reference the exact commit without a dirty suffix.
