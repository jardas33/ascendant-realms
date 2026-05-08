# v0.5 Save Fixture Plan

Date: 2026-05-08

Scope: design the save-fixture strategy for the v0.5 Save, Content Validation, Determinism, and Expansion Readiness Gate. This phase is planning-only. It does not add fixtures, change save behavior, bump the save version, change gameplay, or change balance.

## Goal

Ascendant Realms already has useful inline save tests for V1 migration, V2 normalization, settings-only saves, campaign resources, Cinderfen route progress, item instances, affixes, equipment, Stronghold upgrades, retinue units, rivals, trophies, and Chapter 2 selected state.

The v0.5 fixture gate should make those protections easier to review and harder to accidentally weaken by storing representative legacy/current saves as small files. Future migrations should add new fixtures before changing runtime migration behavior.

## Current Save Surface

Current save version: `2`.

Save entrypoint:

- `src/game/save/SaveSystem.ts`
- `src/game/save/SaveImportExport.ts`
- `src/game/save/SaveMigrations.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/save/SaveDefaults.ts`
- `src/game/save/SaveTypes.ts`

Current tests:

- `src/game/core/SaveSystem.test.ts`

Persistent domains that need fixture coverage:

| Domain | Current field or path | Fixture coverage intent |
| --- | --- | --- |
| Hero identity | `hero.heroName`, `classId`, `originId` | Valid hero base data must survive migration. Invalid hero base data must reject the save. |
| Hero level, XP, skill points | `hero.level`, `xp`, `skillPoints` | Numeric fields clamp to safe minimums and meaningful values persist. |
| Skills | `hero.unlockedAbilities`, `allocatedSkills` | Ability IDs and allocated skill ranks persist without overasserting skill-tree copy. |
| Inventory item instances | `hero.inventory` | Current item instances preserve `instanceId`, `itemId`, timestamps, source, flags, and affixes. |
| Legacy inventory | `hero.items` or string entries in `inventory` | Legacy catalog IDs migrate into item instances. |
| Affixes | `hero.inventory[].affixes` | Valid affix IDs persist and duplicates dedupe inside a single item instance. |
| Equipment | `hero.equipment` | Current instance IDs persist; legacy catalog-ID equipment creates/links a migrated instance. |
| Duplicate conversions | Claimed reward IDs plus resulting resources/items | Unique reward conversion state should be represented by save outcomes, not by transient Results copy. |
| Settings | `settings` | Accessibility/audio/UI scale settings normalize and persist. |
| Settings-only saves | `statistics.settingsOnly` | Settings writes must not create a playable campaign save until a real hero write happens. |
| Campaign resources | `campaign.resources`, `resourcesSpent` | Resource banks and spending totals survive migration and clamp safely. |
| Campaign node completion | `completedNodeIds`, `unlockedNodeIds`, `lockedNodeIds`, `nodeRewardsClaimedIds` | Chapter 1 and Cinderfen route progress persists without requiring UI text assertions. |
| Event choices | `choiceIdsClaimed` | One-time event choices persist and block duplicate rewards. |
| Town purchases | `townServiceClaimedIds`, `townServiceUseCounts` | One-time and repeatable service state persists. |
| Stronghold upgrades | `strongholdUpgradeRanks`, legacy `strongholdUpgradeIds` | Rank data persists; legacy upgrade IDs migrate to rank 1. |
| Reputation | `hero.factionReputation` | Known and future-ish reputation IDs preserve numeric values while known defaults fill missing fields. |
| Campaign modifiers | `activeModifierIds` | Valid modifier IDs persist; invalid IDs are filtered. |
| Retinue units | `retinueUnits` | Unit identity, type, name, rank, XP, kills, source, acquired timestamp, and status persist. |
| Rival state | `rivals` | Encounter counts, outcomes, dispositions, modifiers, and known-player state persist. |
| Rival trophies | `rivalTrophies` | Trophy identity, enemy hero, source node, label, description, and effect copy persist. |
| Chapter 2 state | `selectedChapterId`, `selectedNodeId`, Cinderfen node IDs | Valid `cinderfen_road` and Cinderfen selected node values persist. |
| Legacy V1/V2 saves | `version: 1`, `version: 2` | V1 migrates to current V2; V2 normalizes without bumping version. |
| Invalid JSON | raw import/load string | Invalid JSON returns `null`/`false` and does not clear storage. |

## Intended Fixture Location

Use a test-only fixture directory:

```text
tests/fixtures/saves/
```

This keeps fixtures out of the production source tree and makes it obvious that production code must not import them.

Because `tsconfig.json` currently includes only `src`, the implemented fixture helper code lives beside the fixtures under `tests/fixtures/saves/`:

```text
tests/fixtures/saves/SaveFixtureTestUtils.ts
```

Runtime code must not import `SaveFixtureTestUtils.ts`, and fixture JSON must remain under `tests/fixtures/saves/`.

## Planned Fixture Files

| Filename | Category | Protects | Expected migration or normalization outcome |
| --- | --- | --- | --- |
| `tests/fixtures/saves/v1-basic-hero.json` | Legacy V1 | Hero identity, XP, legacy inventory item IDs, legacy equipment by catalog ID, campaign resources, node completion, and event choice claims. | `migrateSaveToCurrent` returns version 2, preserves created/updated timestamp policy, applies default settings, migrates item/equipment to instance IDs, preserves campaign resources and choice claims. |
| `tests/fixtures/saves/v2-settings-only.json` | Settings-only V2 | Audio/accessibility/UI scale settings and `statistics.settingsOnly`. | Loads as version 2, settings normalize, `SaveSystem.isSettingsOnlySave` is true, and `SaveSystem.hasSave` remains false when stored alone. |
| `tests/fixtures/saves/v2-campaign-progress.json` | Current V2 campaign | Chapter 1 completion, Cinderfen unlocks, resources, spending, event choices, town services, active modifiers, Stronghold upgrades, and selected Chapter 2 state. | Loads as version 2 with `selectedChapterId: "cinderfen_road"`, valid `selectedNodeId`, deduped progress arrays, preserved resources, and preserved purchase/choice/upgrade state. |
| `tests/fixtures/saves/v2-affixed-inventory.json` | Current item identity | Item instances, valid affixes, duplicate affix dedupe, locked/favorite flags, and equipment by instance ID. | Normalization preserves meaningful item instance fields, dedupes repeated affix IDs, preserves equipment links, and does not convert current instances into legacy IDs. |
| `tests/fixtures/saves/v2-legacy-equipment-catalog-id.json` | Legacy equipment in V2 shape | Current V2 hero data with legacy catalog-ID inventory/equipment references. | Normalization migrates catalog IDs into item instances and equipment points at migrated instance IDs. |
| `tests/fixtures/saves/v2-retinue-rivals-cinderfen.json` | Current v0.3 route systems | Retinue unit state, rival state, rival trophies, Cinderfen completed nodes, route unlocks, selected Watch/Aftermath state, and known modifiers. | Loads as version 2 with valid retinue/rival/trophy records intact and Cinderfen route progress preserved. |
| `tests/fixtures/saves/v2-missing-optional-fields.json` | Backward-compatible V2 | Minimal V2 save missing optional/newer campaign fields, settings, statistics, selected chapter, retinue, rivals, trophies, resources spent, and modifiers. | Normalization fills safe defaults, keeps a valid fallback campaign shape, keeps current save version, and does not crash. |
| `tests/fixtures/saves/v2-future-extra-fields.json` | Future-ish tolerance | Unknown top-level, hero, campaign, and statistics fields. | Loader does not crash; known fields normalize; top-level unknown fields are ignored; `statistics` unknown fields remain copied because current policy preserves the statistics object. |
| `tests/fixtures/saves/invalid-json.txt` | Parser rejection | Malformed localStorage/import payload. | `parseSaveJson` returns `null`, `SaveSystem.load` returns `null`, and invalid import does not replace the current stored save. |

These files should be small, hand-authored, and reviewable. Do not store large browser localStorage dumps unless a future migration genuinely requires one.

## Expected Test Harness Behavior

Fixture utilities should provide:

- `loadSaveFixtureJson(filename)` to parse fixture JSON from `tests/fixtures/saves/`.
- `loadSaveFixtureText(filename)` for malformed JSON or future raw payload tests.
- `cloneFixture(value)` so tests can mutate fixtures without cross-test bleed.
- `migrateFixtureToCurrent(filename)` to pass a fixture through `migrateSaveToCurrent`.
- `parseFixtureSave(filename)` to pass raw text through `parseSaveJson`.
- focused assertions for stable domains, such as resources, Cinderfen node state, item instances, retinue, rivals, trophies, and settings-only status.

The helper should avoid asserting incidental formatting, UI copy, array order that is not semantically important, generated timestamps unless fixed in the fixture, or exact object identity.

## What Should Not Be Persisted

The fixture suite should make clear that these values are not part of save compatibility unless a future migration explicitly adds them:

- Live battle entities, health, positions, orders, cooldowns, pathfinding state, fog reveal grids, or wave timers.
- Camera position, selected UI tab, hovered entity, tooltip state, open modal, scroll position, or transient HUD status.
- Playwright hooks, debug surfaces, browser console data, production preview diagnostics, or simulator-only telemetry.
- Results-screen one-frame copy such as "conversion shown" or "Equip Now was clicked"; only the resulting saved hero/campaign state matters.
- Full generated telemetry summaries, screenshots, trace files, or huge localStorage dumps.
- Future tutorial/proving-grounds state before a save field is designed and tested.

## Backward Compatibility Policy

Current policy:

- New writes use `version: 2`.
- V1 saves migrate in memory to the current V2 shape.
- V2 saves normalize in memory and remain version 2.
- Invalid JSON and invalid save shapes are rejected safely.
- Settings-only saves preserve settings but do not count as playable progress.
- Missing newer V2 fields get safe defaults.
- Unknown top-level fields are ignored by normalization.
- Unknown `statistics` keys are preserved.

Do not bump the save version during v0.5 unless a real migration need appears and the impact is fully understood. Before any future bump:

1. Freeze at least one representative current-version fixture.
2. Add a migration test from the old version to the new version.
3. Document every field that is transformed, dropped, defaulted, or newly required.
4. Prove settings-only saves still do not become playable hero saves.
5. Prove invalid JSON/import behavior remains safe.
6. Run the full save/content validation gate and at least smoke e2e.

## Future Fixture Update Rules

When adding a future persistent system:

1. Add a small fixture for the oldest shape that must still load.
2. Add a current-shape fixture for the new field.
3. Add a missing-field fixture if the new field should default safely.
4. Add an invalid-field fixture only when invalid data is likely or the normalization rule is important.
5. Keep old fixtures immutable unless the old shape was impossible or misleading; prefer adding a new fixture over editing an old one.
6. Do not couple fixture assertions to UI text, layout, generated item names, or route copy unless the text itself becomes persisted data.

## Brittle Fixture Warning Signs

A fixture is too brittle if it:

- Requires current generated timestamps from `Date.now()`.
- Depends on random affix rolls instead of fixed affix IDs.
- Stores every localStorage value from an entire browser session.
- Asserts the full save object when only a few compatibility fields matter.
- Encodes UI labels that can change without breaking compatibility.
- Requires e2e-only hooks or production debug globals to load.
- Mixes multiple unrelated migration risks so a failure is hard to diagnose.

## Phase 2/3 Implementation Plan

Recommended next steps:

1. Add `tests/fixtures/saves/README.md` with naming and update policy.
2. Add fixture test utilities.
3. Add the planned fixtures.
4. Add fixture-based tests for parser rejection, settings-only saves, V1 migration, V2 campaign progress, affixed inventory, legacy equipment, retinue/rivals/trophies, Cinderfen route state, selected Chapter 2 state, missing optional fields, and future-ish unknown fields.
5. Keep existing inline tests where they still cover normalization edge cases that would make fixture files noisy.

## Verification

Planned verification for this docs-only phase:

```text
npm test
npm run build
git diff --check
```
