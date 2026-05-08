# v0.4 Save Compatibility Audit

Date: 2026-05-08

Scope: audit persistent player data before future expansion. This pass does not bump the save version, change save format, change gameplay, change campaign rules, alter balance, add systems, or remove existing migration behavior.

## Current Save Version

Current save version: `2`

Source of truth:

- `src/game/save/SaveDefaults.ts` exports `CURRENT_SAVE_VERSION = 2`.
- `src/game/save/SaveTypes.ts` defines `StoredGameSaveV1`, `StoredGameSaveV2`, and `CurrentStoredGameSave`.
- `src/game/save/SaveMigrations.ts` accepts V1 and V2 only.
- `src/game/save/SaveSystem.ts` is the storage facade and writes through `createCurrentStoredGameSave`.

Decision: do not bump the save version for v0.4 technical/UX groundwork. The current changes do not require a schema migration.

## Migration Behavior

| Area | Current behavior | Coverage | Risk |
| --- | --- | --- | --- |
| V1 saves | `migrateV1ToV2` normalizes hero and campaign, fills settings with `DEFAULT_SETTINGS`, keeps timestamps when present, and writes empty statistics. | `SaveSystem.test.ts` covers direct V1 migration and loading V1 saves through localStorage. | Low. |
| V2 saves | `migrateSaveToCurrent` normalizes V2 saves in place and fills missing V2 fields safely. | `SaveSystem.test.ts` covers V2 settings normalization and missing V2 fields. | Low. |
| Invalid versions | Unknown versions return `null`. | Import/load invalid-shape coverage exists. | Low. |
| Invalid JSON | Parse failure returns `null` and does not clear localStorage. | Covered by `rejects invalid JSON and invalid save shapes without clearing storage`. | Low. |
| Import/export | Import validates through migration before replacing the current save. Export writes current JSON. | Covered by valid legacy import and invalid import preservation. | Low. |

## Field Audit

| Field family | Compatibility read | Existing protection |
| --- | --- | --- |
| Settings-only saves | `saveSettings` creates a fallback hero/campaign and marks `statistics.settingsOnly`; later hero writes preserve settings and clear settings-only semantics. | Covered by `saves settings and keeps them through later hero writes`. |
| Campaign resources | `resources` and `resourcesSpent` normalize every resource key, clamp to non-negative integers, and default missing banks to zero. | Covered by campaign normalization, V1 load, Cinderfen choice saves, town purchase saves, and Stronghold spending tests. |
| Event choices | `choiceIdsClaimed`, `townServiceClaimedIds`, and `townServiceUseCounts` dedupe/normalize and persist event/town service state. | Covered by Overlook, Waystation, Malrec Standard, Aftermath, town purchases, and older campaign saves. |
| Stronghold upgrades | `strongholdUpgradeRanks` persists rank data. Legacy `strongholdUpgradeIds` migrate to rank 1 when valid. | Covered by normalization and save/load tests for tiered upgrades. |
| Retinue units | Retinue units dedupe by `retinueUnitId`, validate unit type and rank, clamp XP/kills, and default status to active unless wounded. | Covered by normalization and save/load through campaign data. |
| Rival state | Rival state dedupes by enemy hero id, validates known enemy heroes, clamps counters, validates outcome/disposition/modifiers, and preserves known-player state. | Covered by normalization and save/load through campaign data. |
| Rival trophies | Trophy records dedupe by trophy id, validate enemy hero ids, require label/description, preserve optional effect, and fall back invalid source nodes to `unknown`. | Covered by normalization and save/load through campaign data. |
| Affixed item instances | Inventory accepts legacy item ids and current item instances, preserves affixes/locked/favorite, dedupes instance ids, and resolves equipment to instance ids. | Covered by hero normalization and town purchase affix save/load tests. |
| Chapter 2 progress | Cinderfen completed/unlocked nodes, choices, services, modifiers, and Aftermath completion persist through V2 saves. | Covered by Cinderfen Overlook, Waystation, Malrec Standard, Aftermath, smoke e2e, and layout seeded saves. |
| `selectedChapterId` | Valid chapter ids are preserved; invalid/missing ids fall back to `border_marches`. | New v0.4 audit test preserves valid `cinderfen_road`; existing tests cover invalid fallback. |
| `selectedNodeId` | String values are preserved for UI focus; invalid non-strings clear to `undefined`. | Covered by normalization tests and the new Chapter 2 selected-node test. |

## New Test Added

Added a narrow unit test in `src/game/core/SaveSystem.test.ts`:

```text
preserves valid Chapter 2 selected chapter and node state
```

This closes the only clear audit gap found: V2 normalization already handled valid `selectedChapterId`, but the test suite only asserted invalid fallback. The new test protects `cinderfen_road` and `cinderfen_watch` selection persistence without changing runtime behavior.

## Risks For Future Expansion

| Future change | Save risk | Guardrail |
| --- | --- | --- |
| Workers/economy | New persistent worker assignments could require versioned migration and empty defaults. | Do not add worker fields without V3 migration tests and old-save fixtures. |
| Enemy construction | Enemy base state may be battle-local or campaign-persistent; unclear persistence can corrupt old saves. | Decide persistence boundary before adding fields. |
| New factions | Reputation defaults must not drop existing faction values. | Extend `DEFAULT_FACTION_REPUTATION` and normalization tests. |
| New chapters/maps | `selectedChapterId`, node ids, and chapter ordering must remain valid for older saves. | Add tests for each new chapter id and old selected nodes. |
| Crafting/affix rerolling | Item instance mutations need history, locks, and equipment stability. | Add item-instance migration fixtures before changing item fields. |
| Multiplayer/modding | Save trust boundary becomes higher risk. | Keep local save parser strict and avoid executing imported data. |

## Recommendation

Save compatibility is currently stable enough for v0.4 technical/UX groundwork. Keep save version `2` until a real schema change appears. The next save-related milestone should be a fixture-based migration suite before any broad v0.5 system expansion.

## Verification

Required for this phase:

```text
npm test
npm run build
npm run test:e2e:smoke
```

Verification completed:

```text
npm test
PASS: 38 test files, 271 tests, 8.51s.

npm run build
PASS: TypeScript compile and Vite production build.
App JS: assets/index-90WGArXv.js, 436.35 kB / gzip 117.34 kB.
Vendor JS: assets/vendor-phaser-B61OQUcB.js, 1,481.79 kB / gzip 339.86 kB.
CSS: assets/index-CeqfGaMI.css, 42.04 kB / gzip 8.74 kB.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.4m.
```
