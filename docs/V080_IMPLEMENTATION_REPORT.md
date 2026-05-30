# v0.80 Implementation Report

Status: docs-only checkpoint report. Verification details will be updated during closeout.

## Scope

v0.80 creates the Salto, Lume, and display-copy migration plan after the v0.79 Emmanuel direction lock. It inventories current runtime-facing terminology, separates safe display candidates from prohibited identifier changes, defines the Lume/Mana/Aether taxonomy question, and prepares a review packet for Emmanuel.

## Runtime Changed

None.

No runtime strings were migrated. No gameplay, balance, enemy AI, pathing, controls, save data, UI behavior, art, assets, races, maps, units, buildings, classes, desktop work, multiplayer, PvP, co-op, or Lume Network behavior was added.

## Files Created

- `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`.
- `docs/V080_TERMINOLOGY_TAXONOMY.md`.
- `docs/V080_DISPLAY_COPY_MIGRATION_MAP.md`.
- `docs/V080_SAFE_COPY_BATCHES.md`.
- `docs/V080_TEST_AND_ROLLBACK_PLAN.md`.
- `docs/V080_EMMANUEL_REVIEW_PACKET.md`.
- `docs/V080_IMPLEMENTATION_REPORT.md`.

## Inventory

- Inventory rows: 72.
- Surfaces inventoried: 8.
- Title/brand/package rows: 7.
- Faction/world rows: 8.
- Campaign node/briefing rows: 15.
- Resource/economy/site rows: 14.
- Hero/ability/build rows: 9.
- Item/relic/reward rows: 8.
- Battle event/AI/Results rows: 7.
- Tutorial/onboarding rows: 4.

## Change Categories

- Keep runtime copy now: 32.
- Low-risk copy candidates: 5.
- Copy candidates needing approval: 8.
- Lume/Aether review items: 12.
- Prohibited identifier changes: 15.

## Lume, Mana, And Aether Recommendation

- Lume should become the world-facing living land-power term.
- Mana should remain the tactical hero ability resource for now.
- Aether should be reviewed case by case. Do not blanket-rename it in runtime.
- The `aether` resource id and `maxMana` stat field must remain unchanged unless a future migration gate explicitly handles old saves and data references.

## Copy Candidates

Strong future candidates:

- `The Free Marches` -> `Barrosan Freeholds`.
- `Chapter 1: Border Marches` -> `Act 1 - Ashes over Salto`.
- `Border Village` -> a Salto-adjacent display label only if Emmanuel wants Salto in the first runtime campaign screen.
- `Aether Well Ruins` -> `Lume Well Ruins` or `Old Spring Ruins`.
- `Aether Surge` -> `Lume Surge` only if the taxonomy approves it.

## Prohibited Identifier Changes

v0.80 explicitly prohibits renaming:

- `ascendant-realms`.
- `free_marches`.
- `ashen_covenant`.
- `sylvan_concord`.
- `border_marches`.
- `ashen_outpost`.
- `aether`.
- `maxMana`.
- `mission_aether_surge`.
- `aether_surge`.
- `warlord`.
- `arcanist`.
- `aether_lens`.
- `cinderseer_focus`.
- `proving_grounds_basics`.

## Save Format

No save-version bump.

No save fields were added, removed, renamed, or migrated.

No persisted IDs were changed.

## Package

Package metadata and package validation are updated to include the v0.80 docs and inventory. The playable build remains the unchanged browser prototype plus docs.

## Verification

```text
npm test PASS, 86 files / 644 tests.
npm run build PASS with the known Vite Phaser vendor chunk-size warning.
npm run validate:content PASS.
npm run validate:art-intake PASS.
npm test -- src/game/playtest/PlaytestPackageValidation.test.ts PASS, 1 file / 3 tests.
node -e JSON inventory parse PASS, 72 rows.
npm run package:playtest PASS, dirty pre-commit package `ascendant-realms-private-playtest-535c388-dirty` generated.
npm run verify:playtest-package PASS, 233 checks against the dirty pre-commit package.
git diff --check PASS.
```

## Deferred

- Runtime title/copy migration.
- Runtime rebrand.
- Save/ID migration.
- Lume Network design and implementation.
- v0.81.
- Art or asset work.
- Desktop/engine work.
