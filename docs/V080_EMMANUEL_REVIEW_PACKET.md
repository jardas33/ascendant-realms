# v0.80 Emmanuel Review Packet

Status: docs-only review packet.

## What v0.80 Did

v0.80 inventoried current runtime-facing terminology and created a safe migration plan. It did not change runtime strings, gameplay, saves, IDs, art, assets, desktop packaging, or the Lume Network.

Start with:

1. `docs/V080_RUNTIME_FACING_STRING_INVENTORY.json`
2. `docs/V080_TERMINOLOGY_TAXONOMY.md`
3. `docs/V080_DISPLAY_COPY_MIGRATION_MAP.md`
4. `docs/V080_SAFE_COPY_BATCHES.md`
5. `docs/V080_TEST_AND_ROLLBACK_PLAN.md`

## Key Counts

- Inventory rows: 72.
- Surfaces inventoried: 8.
- Keep runtime copy now: 32.
- Low-risk copy candidates: 5.
- Approval-required copy candidates: 8.
- Lume/Aether review items: 12.
- Prohibited identifier changes: 15.

## Recommended Decisions For Emmanuel

### 1. Lume, Mana, And Aether

Recommended:

- Approve Lume as the world-facing living land-power term.
- Keep Mana as the tactical hero ability resource for now.
- Review Aether case by case instead of blanket-renaming it.

Decision needed:

- Should Aether remain as a refined battle magic/resource term, or should most player-facing Aether references eventually become Lume?

### 2. First Salto Runtime Copy

Recommended:

- Do not start runtime Salto copy until one narrow batch is approved.
- Best first candidate later: campaign chapter/opening-node display copy, not IDs.

Decision needed:

- Should `Border Village` eventually become Salto-adjacent copy such as `Salto Outskirts`, or should Salto remain narrative/home copy outside the current battle map for longer?

### 3. Barrosan Freeholds

Recommended:

- Treat `Barrosan Freeholds` as the future player-facing name for the current player faction display.
- Keep `free_marches` as the stable internal ID.

Decision needed:

- Is `Barrosan Freeholds` approved for future runtime display-copy testing?

### 4. Title Migration

Recommended:

- Keep `Ascendant Realms` in runtime for now.
- Migrate browser/main-menu title only after title/legal/storefront/product hierarchy are explicitly green.

Decision needed:

- Is the first runtime title-copy test desired before, during, or after the Lume Site Network design gate?

### 5. Class Names

Recommended:

- Defer Warlord/Arcanist display renames.
- Keep Warrior/Seer/Commander build labels.

Decision needed:

- Should Warlord map toward Marshal or Warden in future runtime class copy?
- Should Arcanist map toward Seer or Binder in future runtime class copy?

## Approved For Future Copy Planning

Good candidates, with later approval:

- The Free Marches -> Barrosan Freeholds.
- Chapter 1: Border Marches -> Act 1 - Ashes over Salto.
- Border Village -> Salto-adjacent copy if desired.
- Aether Well Ruins -> Lume Well Ruins or Old Spring Ruins.
- Aether Surge -> Lume Surge if taxonomy supports it.

## Explicitly Not Approved By v0.80

- Runtime copy migration.
- Runtime title rebrand.
- Internal ID migration.
- Save migration.
- Lume Network implementation.
- Race/class implementation.
- Art generation/import.
- Desktop engine or packaging work.
- v0.81 start.

## Reviewer Checklist

- [ ] Approve or revise the Lume/Mana/Aether taxonomy.
- [ ] Decide whether Barrosan Freeholds is ready for future display-copy testing.
- [ ] Decide whether Salto should enter runtime copy through the opening mission or wait.
- [ ] Decide whether title runtime migration should wait until after Lume Site Network design.
- [ ] Confirm all stable IDs stay unchanged for the next copy batch.
