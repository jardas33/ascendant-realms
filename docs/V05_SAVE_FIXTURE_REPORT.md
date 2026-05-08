# v0.5 Save Fixture Report

Date: 2026-05-08

Scope: report the v0.5 save-fixture safety gate. This work adds fixture-based tests and documentation only. It does not bump the save version, change save format, change gameplay, change balance, add content, add maps, add units, add workers, add enemy construction, or implement future systems.

## Summary

The v0.5 save gate now has file-backed fixtures for representative old and current save shapes. These fixtures protect the existing persistent player data before future systems add more state.

Implementation files:

- `tests/fixtures/saves/README.md`
- `tests/fixtures/saves/SaveFixtureTestUtils.ts`
- `tests/fixtures/saves/SaveFixtureTestUtils.test.ts`
- `tests/fixtures/saves/SaveMigrationFixtures.test.ts`

Planning/report files:

- `docs/V05_SAVE_FIXTURE_PLAN.md`
- `docs/V05_SAVE_FIXTURE_REPORT.md`
- `docs/SAVE_COMPATIBILITY_AUDIT.md`

## Fixture List

| Fixture | Protects | Expected outcome |
| --- | --- | --- |
| `v1-basic-hero.json` | Legacy V1 hero identity, XP, legacy inventory/equipment catalog IDs, resources, completed nodes, and choice claims. | Migrates to current V2, default settings, empty statistics, migrated item instance/equipment links, preserved resources and choices. |
| `v2-settings-only.json` | Settings-only local save marker and accessibility/audio/UI settings. | Loads as current V2, settings normalize, `SaveSystem.isSettingsOnlySave` true, `SaveSystem.hasSave` false. |
| `v2-campaign-progress.json` | Current V2 Chapter 1/Cinderfen progress, resources, spending, choices, town services, modifiers, Stronghold upgrades, and Chapter 2 selection. | Loads as V2 with campaign banks, services, choices, upgrades, `cinderfen_road`, and `cinderfen_watch` preserved. |
| `v2-affixed-inventory.json` | Current item instances, affixes, locked/favorite flags, equipment instance links, and town purchase state. | Preserves item instances and equipment links, dedupes duplicate affix IDs. |
| `v2-legacy-equipment-catalog-id.json` | V2-shaped saves with legacy catalog-ID inventory/equipment references. | Migrates catalog IDs into item instances and rewrites equipment to instance IDs. |
| `v2-retinue-rivals-cinderfen.json` | Retinue units, rival state, rival trophies, full Cinderfen route completion, selected Aftermath state, and Stronghold Tier II state. | Preserves retinue/rival/trophy records and completed Cinderfen route progress. |
| `v2-missing-optional-fields.json` | Sparse V2 saves missing newer optional campaign/settings/statistics fields. | Fills safe defaults, keeps version 2, and does not crash. |
| `v2-future-extra-fields.json` | Future-ish unknown top-level, hero, campaign, and statistics fields. | Does not crash; known fields normalize; unknown top-level/hero/campaign fields are ignored; unknown `statistics` fields are preserved. |
| `invalid-json.txt` | Malformed import/localStorage payload. | Parser returns `null`, load/import fail safely, and invalid import does not replace the current stored save. |

## Covered Migration Paths

Covered now:

- Raw malformed JSON to safe `null`.
- V1 save to current V2 save.
- V2 save to normalized current V2 save.
- V2 sparse save to normalized current V2 with safe defaults.
- V2 settings-only save through `SaveSystem.load` and `SaveSystem.hasSave`.
- V2 save with future-ish unknown fields through current normalization.
- V2 save with current item instances and affixes.
- V2 save with legacy catalog-ID equipment references.

Still intentionally not covered:

- Unknown future save versions, beyond returning `null`.
- Full browser localStorage dumps.
- Live battle-state serialization, because live battle entities are not save data.
- Multiplayer or command-log save formats, because they do not exist yet.

## Unsupported Old Save Shapes

Known unsupported or intentionally rejected shapes:

- Saves without a valid `version` value.
- Versions other than `1` or `2`.
- Hero data missing required base fields such as `heroName`, `classId`, `originId`, `unlockedAbilities`, progression numbers, or primary stats.
- Campaign data missing required `started` or `difficulty`.
- Campaign saves with unsupported difficulty values.
- Retinue records with unknown unit IDs or invalid rank IDs.
- Rival records with unknown enemy hero IDs.
- Rival trophy records without a valid trophy ID, enemy hero, label, or description.
- Invalid JSON.

These are rejected or normalized by current policy. Do not loosen this behavior without a specific player-save recovery need and matching fixtures.

## Current Save Version Policy

Current save version remains `2`.

Policy:

- New writes use version 2.
- V1 migrates in memory to version 2.
- V2 normalizes in memory as version 2.
- Missing optional V2 fields default safely.
- Invalid JSON and invalid shapes fail safely.
- Settings-only saves do not count as playable campaign progress.
- Unknown top-level fields are ignored.
- Unknown `statistics` fields are preserved.

No v0.5 save fixture work requires a version bump.

## Future Migration Fixture Procedure

Before changing persistent data:

1. Identify whether the field is truly persistent, not battle-local or UI-local.
2. Add or update `docs/V05_SAVE_FIXTURE_PLAN.md` with the intended fixture shape.
3. Add a small old-shape fixture for the oldest supported save.
4. Add a current-shape fixture for the new field.
5. Add a sparse/missing-field fixture if the field should default safely.
6. Add an invalid-field fixture only when invalid recovery behavior is important.
7. Add tests in `SaveMigrationFixtures.test.ts`.
8. Run `npm test`, `npm run build`, `npm run test:e2e:smoke`, and `git diff --check` for save-facing changes.

Before any future save-version bump:

1. Freeze a representative current-version fixture.
2. Add a new old-to-current migration test.
3. Document every transformed, defaulted, dropped, or newly required field.
4. Prove settings-only saves still do not become playable saves.
5. Prove invalid import still cannot replace the current save.
6. Update this report, `docs/SAVE_COMPATIBILITY_AUDIT.md`, `README.md`, and `LLM_GAME_HANDOFF.md`.

## Protected Domains

Retinue:

- `v2-retinue-rivals-cinderfen.json` protects retinue IDs, unit type IDs, names, ranks, XP, kills, source battle IDs, acquired timestamps, and active status.
- Fixture tests assert a current Cinderfen ranger retinue record survives normalization.

Rivals and trophies:

- `v2-retinue-rivals-cinderfen.json` protects Malrec and Veyra rival states plus Malrec's trophy record.
- Fixture tests assert encounter counters, outcomes, dispositions, known-player state, trophy enemy hero, trophy source node, and label survive normalization.

Affixes and equipment:

- `v2-affixed-inventory.json` protects item instance identity, valid affix IDs, duplicate affix dedupe, locked/favorite flags, and equipment links by instance ID.
- `v2-legacy-equipment-catalog-id.json` protects legacy catalog-ID equipment migration into item instance IDs.

Chapter 2 and Cinderfen route:

- `v2-campaign-progress.json` protects active Cinderfen progress through Crossing and selected Watch state.
- `v2-retinue-rivals-cinderfen.json` protects completed Cinderfen route state through Aftermath.
- Tests assert `selectedChapterId: "cinderfen_road"` and Cinderfen selected nodes survive.

## Remaining Gaps

Future work should add fixtures when these systems become real:

- Any new save version.
- New campaign chapters and selected chapter/node combinations.
- New faction reputation defaults and unknown/retired faction policy.
- Worker/economy persistence, if workers ever become campaign-persistent.
- Enemy construction persistence, if enemy base development ever leaves battle-local state.
- Crafting, affix rerolling, item mutation history, or durability, if implemented later.
- Tutorial/proving-grounds progress, if it becomes persisted.
- Command-log or replay metadata, if it becomes persisted.
- Modding/import trust boundary fixtures, if user-provided data is ever accepted.

## Verification

Phase 3 fixture test verification:

```text
npm test
PASS: 40 test files, 284 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Known Vite warning remains for vendor-phaser.

npm run test:e2e:smoke
PASS: 10 Playwright tests in 4.7m.

git diff --check
PASS.
```

Phase 4 report-only verification:

```text
npm test
PASS: 40 test files, 284 tests.

npm run build
PASS: TypeScript compile and Vite production build.
Known Vite warning remains for vendor-phaser.

git diff --check
PASS.
```
