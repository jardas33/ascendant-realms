# v0.35 Hero Build Identity Implementation Report

Date: 2026-05-27

## Scope

v0.35 adds readable hero build identity to the existing one-slot relic loadout. It does not add a skill tree, class restrictions, extra relic slots, paper-doll UI, inventory overhaul, new art, save migration, shop, crafting, or broad balance changes.

## Build Identity

Each relic now carries a required build archetype and short build copy:

- Warrior: `emberbrand_shard`, damage and might support.
- Seer: `cinderseer_focus`, mana and arcana support.
- Commander: `outpost_command_signet`, durability, armor, and command support.

Relic content validation now requires a valid archetype, matching archetype tag, build summary, choice copy, acquisition source, effect summary, and duplicate policy.

## Loadout UX

- Hero Inventory relic rows show the build identity before equip.
- Equipment rows show the equipped relic's build identity.
- Results choice cards show archetype, effect summary, stat summary, build support copy, tags, and owned state before selection.
- Results final relic block shows the selected build identity and the final equipped relic state.
- Battle HUD now renders equipped relic state as `Relic: <name> active - <Build> build`.

## Save Format

No save-version bump was added. The feature continues to use:

- `HeroSaveData.inventory` for acquired relic item instances;
- `HeroSaveData.equipment.relic` for the equipped relic instance id;
- existing save normalization for old saves without relic fields;
- existing known-item filtering so unknown relic ids do not apply effects or break load.

## Deferrals

Still deferred:

- multiple relic slots;
- class/build tree progression;
- relic comparison modal;
- inventory filtering or sorting;
- relic shop, crafting, rerolling, upgrading, selling, or salvage;
- new runtime art, icons, portraits, or VFX.

## Verification

v0.35 shared the v0.34 verification matrix. Focused and broad evidence includes:

```text
npm test PASS, 73 files / 549 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm run test:e2e:smoke:fast PASS on rerun, 8 tests.
npm run test:e2e:smoke PASS on rerun, 14 tests.
npm run test:e2e:release:hosted:deep-battle PASS, 27 tests.
npm run test:e2e:release:hosted:smoke PASS, 14 tests.
npm run test:e2e:release:hosted:deep-campaign-pressure PASS, 7 tests.
npm run visual:qa PASS on rerun, 5 tests / 18 screenshots / 0 console errors / 0 screenshot retries.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-2a411ed-dirty` generated.
npm run verify:playtest-package PASS, 105 checks against the dirty pre-commit package.
git diff --check PASS.
```

Package generation and final clean package verification are recorded in `DEVELOPMENT_CHECKPOINT.md` after the final checkpoint commit.
