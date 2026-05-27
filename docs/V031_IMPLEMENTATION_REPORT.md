# v0.31 Relic Reward Foundation Implementation Report

Date: 2026-05-27

## Scope

v0.31 adds a preview-only relic reward foundation for rival champion defeats. It is deliberately not an inventory system, not a loot-table expansion, and not a save migration.

## Implemented

- Added `src/game/data/relicRewards.ts` with three preview-only relic definitions.
- Added `src/game/core/RelicRewardRules.ts` to select relic previews from battle result state.
- Added content validation for relic ids, source enemy heroes, modest preview XP/resources, and `preview_only` persistence.
- Added results-screen rendering for `Relic Reward Preview`.
- Added explicit persistence copy stating the relic is not added to inventory or saved.
- Updated package metadata/validation to include the v0.30-v0.31 docs.

## Tutorial Impact

Tutorial remains protected:

- Tutorial launch requests still set rewards disabled.
- Relic previews do not appear in Tutorial mode.
- No Tutorial XP, item, resource, campaign, inventory, or relic state is saved.

## Runtime Impact

Runtime changed: yes, narrowly.

The results screen now displays a preview-only relic reward block after a victorious rival champion defeat. No relic effects are applied to hero stats, resources, saves, or inventory.

## Tests Added Or Extended

- Relic preview appears for victorious known rival champion defeats.
- Relic preview is blocked for champion escapes, defeats, unknown heroes, and Tutorial rewards-disabled runs.
- Results summary renders the relic preview and future-persistence warning.
- Tutorial results do not render relic previews.
- Content validation covers relic reward definitions.
- Hosted Ashen Outpost proxy checks the results relic preview.

## Verification Status

Passed during implementation:

- focused v0.30-v0.31 unit/content/package tests, 5 files / 77 tests;
- targeted hosted Ashen Outpost commander/relic proxy;
- `npm test`, 73 files / 540 tests;
- `npm run build`;
- `npm run validate:content`;
- `npm run validate:art-intake`;
- `npm run test:e2e:smoke:fast`;
- `npm run test:e2e:smoke`;
- `npm run playtest:controls`;
- `npm run playtest:controls:extended`;
- `npm run playtest:controls:verify`;
- `npm run test:e2e:release:hosted:deep-meta`;
- `npm run test:e2e:release:hosted:deep-battle`;
- `npm run test:e2e:release:hosted:smoke`;
- `npm run test:e2e:release:hosted:deep-campaign-pressure`;
- `npm run visual:qa`;
- `git diff --check`.

`npm run test:e2e:release` was attempted and found one deep-meta transition-helper issue after a New Campaign click had already reached hero creation. The narrow helper call fix passed in targeted rerun and hosted deep-meta.
