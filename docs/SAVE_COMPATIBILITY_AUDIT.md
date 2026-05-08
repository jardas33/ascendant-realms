# Save Compatibility Audit

Date: 2026-05-08

Latest update: v0.5 save fixture gate.

Scope: audit persistent player data before future expansion. This pass does not bump the save version, change save format, change gameplay, change campaign rules, alter balance, add systems, or remove existing migration behavior.

## Current Save Version

Current save version: `2`

Source of truth:

- `src/game/save/SaveDefaults.ts` exports `CURRENT_SAVE_VERSION = 2`.
- `src/game/save/SaveTypes.ts` defines `StoredGameSaveV1`, `StoredGameSaveV2`, and `CurrentStoredGameSave`.
- `src/game/save/SaveMigrations.ts` accepts V1 and V2 only.
- `src/game/save/SaveSystem.ts` is the storage facade and writes through `createCurrentStoredGameSave`.
- `tests/fixtures/saves/` now stores representative V1/V2 save fixtures for compatibility regression tests.

Decision: do not bump the save version for v0.5 safety work. The fixture gate adds regression coverage only; it does not require a schema migration.

## Migration Behavior

| Area | Current behavior | Coverage | Risk |
| --- | --- | --- | --- |
| V1 saves | `migrateV1ToV2` normalizes hero and campaign, fills settings with `DEFAULT_SETTINGS`, keeps timestamps when present, and writes empty statistics. | `SaveSystem.test.ts` covers direct V1 migration and localStorage loading; `v1-basic-hero.json` now protects a file-backed legacy save. | Low. |
| V2 saves | `migrateSaveToCurrent` normalizes V2 saves in place and fills missing V2 fields safely. | `SaveSystem.test.ts` covers V2 settings normalization and missing V2 fields; V2 fixture files now cover campaign progress, settings-only saves, affixed inventory, retinue/rivals/trophies, missing optional fields, and future-ish unknown fields. | Low. |
| Invalid versions | Unknown versions return `null`. | Import/load invalid-shape coverage exists. | Low. |
| Invalid JSON | Parse failure returns `null` and does not clear localStorage. | Covered by `SaveSystem.test.ts` and `invalid-json.txt` fixture tests. | Low. |
| Import/export | Import validates through migration before replacing the current save. Export writes current JSON. | Covered by valid legacy import and invalid import preservation, including fixture-backed invalid import preservation. | Low. |

## v0.5 Fixture Gate Update

New files:

- `docs/V05_SAVE_FIXTURE_PLAN.md`
- `docs/V05_SAVE_FIXTURE_REPORT.md`
- `tests/fixtures/saves/README.md`
- `tests/fixtures/saves/SaveFixtureTestUtils.ts`
- `tests/fixtures/saves/SaveFixtureTestUtils.test.ts`
- `tests/fixtures/saves/SaveMigrationFixtures.test.ts`
- `tests/fixtures/saves/v1-basic-hero.json`
- `tests/fixtures/saves/v2-settings-only.json`
- `tests/fixtures/saves/v2-campaign-progress.json`
- `tests/fixtures/saves/v2-affixed-inventory.json`
- `tests/fixtures/saves/v2-legacy-equipment-catalog-id.json`
- `tests/fixtures/saves/v2-retinue-rivals-cinderfen.json`
- `tests/fixtures/saves/v2-missing-optional-fields.json`
- `tests/fixtures/saves/v2-future-extra-fields.json`
- `tests/fixtures/saves/invalid-json.txt`

Fixture coverage added:

- Malformed JSON parser/import safety.
- Settings-only saves that must not count as playable progress.
- V1 to current V2 migration.
- Current V2 campaign progress, resources, choices, town services, Stronghold upgrades, modifiers, and selected Chapter 2 state.
- Affixed item instances, locked/favorite flags, and equipment instance links.
- Legacy catalog-ID equipment references inside a V2-shaped save.
- Retinue units, rival state, rival trophies, and completed Cinderfen route progress.
- Missing optional V2 fields defaulting safely.
- Future-ish unknown fields not crashing current normalization.
- A fixture sweep proving every current fixture still loads through the migration path.

## Field Audit

| Field family | Compatibility read | Existing protection |
| --- | --- | --- |
| Settings-only saves | `saveSettings` creates a fallback hero/campaign and marks `statistics.settingsOnly`; later hero writes preserve settings and clear settings-only semantics. | Covered by inline save tests and `v2-settings-only.json`. |
| Campaign resources | `resources` and `resourcesSpent` normalize every resource key, clamp to non-negative integers, and default missing banks to zero. | Covered by campaign normalization, V1 load, Cinderfen choice saves, town purchase saves, Stronghold spending tests, `v1-basic-hero.json`, `v2-campaign-progress.json`, and `v2-retinue-rivals-cinderfen.json`. |
| Event choices | `choiceIdsClaimed`, `townServiceClaimedIds`, and `townServiceUseCounts` dedupe/normalize and persist event/town service state. | Covered by Overlook, Waystation, Malrec Standard, Aftermath, town purchases, older campaign saves, and V2 campaign/Cinderfen fixtures. |
| Stronghold upgrades | `strongholdUpgradeRanks` persists rank data. Legacy `strongholdUpgradeIds` migrate to rank 1 when valid. | Covered by normalization and save/load tests for tiered upgrades plus V2 campaign/Cinderfen fixtures. |
| Retinue units | Retinue units dedupe by `retinueUnitId`, validate unit type and rank, clamp XP/kills, and default status to active unless wounded. | Covered by normalization, save/load through campaign data, and `v2-retinue-rivals-cinderfen.json`. |
| Rival state | Rival state dedupes by enemy hero id, validates known enemy heroes, clamps counters, validates outcome/disposition/modifiers, and preserves known-player state. | Covered by normalization, save/load through campaign data, and `v2-retinue-rivals-cinderfen.json`. |
| Rival trophies | Trophy records dedupe by trophy id, validate enemy hero ids, require label/description, preserve optional effect, and fall back invalid source nodes to `unknown`. | Covered by normalization, save/load through campaign data, and `v2-retinue-rivals-cinderfen.json`. |
| Affixed item instances | Inventory accepts legacy item ids and current item instances, preserves affixes/locked/favorite, dedupes instance ids, and resolves equipment to instance ids. | Covered by hero normalization, town purchase affix save/load tests, `v2-affixed-inventory.json`, and `v2-legacy-equipment-catalog-id.json`. |
| Chapter 2 progress | Cinderfen completed/unlocked nodes, choices, services, modifiers, and Aftermath completion persist through V2 saves. | Covered by Cinderfen Overlook, Waystation, Malrec Standard, Aftermath, smoke e2e, layout seeded saves, `v2-campaign-progress.json`, and `v2-retinue-rivals-cinderfen.json`. |
| `selectedChapterId` | Valid chapter ids are preserved; invalid/missing ids fall back to `border_marches`. | Covered by inline save tests and V2 campaign/Cinderfen fixtures. |
| `selectedNodeId` | String values are preserved for UI focus; invalid non-strings clear to `undefined`. | Covered by normalization tests and V2 campaign/Cinderfen fixtures. |

## Tests Added

v0.4 added a narrow unit test in `src/game/core/SaveSystem.test.ts`:

```text
preserves valid Chapter 2 selected chapter and node state
```

This closes the only clear audit gap found: V2 normalization already handled valid `selectedChapterId`, but the test suite only asserted invalid fallback. The new test protects `cinderfen_road` and `cinderfen_watch` selection persistence without changing runtime behavior.

v0.5 added fixture-backed tests in:

```text
tests/fixtures/saves/SaveFixtureTestUtils.test.ts
tests/fixtures/saves/SaveMigrationFixtures.test.ts
```

These tests add 13 new save-fixture/harness assertions on top of the existing save suite.

## Risks For Future Expansion

| Future change | Save risk | Guardrail |
| --- | --- | --- |
| Workers/economy | New persistent worker assignments could require versioned migration and empty defaults. | Do not add worker fields without a documented persistence boundary, current V2 fixtures, and migration tests. |
| Enemy construction | Enemy base state may be battle-local or campaign-persistent; unclear persistence can corrupt old saves. | Decide persistence boundary before adding fields. |
| New factions | Reputation defaults must not drop existing faction values. | Extend `DEFAULT_FACTION_REPUTATION`, add fixture coverage, and prove unknown existing reputation values are not lost unintentionally. |
| New chapters/maps | `selectedChapterId`, node ids, and chapter ordering must remain valid for older saves. | Add fixtures for each new chapter id and old selected nodes before launch paths change. |
| Crafting/affix rerolling | Item instance mutations need history, locks, and equipment stability. | Add item-instance migration fixtures before changing item fields. |
| Multiplayer/modding | Save trust boundary becomes higher risk. | Keep local save parser strict and avoid executing imported data. |

## Recommendation

Save compatibility is currently stable enough for v0.5 validation hardening. Keep save version `2` until a real schema change appears. Before any broad persistent expansion, add or update fixtures first, then adjust migration/normalization only after the expected old and current save outcomes are explicit.

## Verification

Most recent fixture-gate verification:

```text
npm test
npm run build
git diff --check
```

Verification completed:

```text
npm test
PASS: 40 test files, 284 tests.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-90WGArXv.js, 436.35 kB / gzip 117.34 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.7m during Phase 3 fixture test verification.

git diff --check
PASS.
```
