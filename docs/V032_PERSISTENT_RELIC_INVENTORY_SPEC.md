# v0.32 Persistent Relic Inventory Spec

Date: 2026-05-27

## Goal

Turn the v0.31 relic reward preview into a tiny persistent relic reward loop using existing hero inventory and equipment structures. This checkpoint must not add maps, factions, runtime art/assets, a large loot table, crafting, shops, paper-doll UI, broad AI/pathing changes, Patrol, formations, or global rebalance.

## Inventory Model

Relics are unique `ItemDefinition` entries with `slot: "relic"`.

- Acquired relic ids are derived from `HeroSaveData.inventory` entries whose item definition has `slot: "relic"`.
- The equipped/loadout relic id is derived from `HeroSaveData.equipment.relic`.
- The save schema does not add a new field in v0.32 because the existing save shape already supports inventory item instances and a `relic` equipment slot.
- Unknown relic or item ids are ignored by relic inventory helpers and hidden by existing inventory rendering instead of corrupting the save.

## Initial Relic Pool

The v0.32 pool uses the three v0.31 definitions only:

- `emberbrand_shard`: Gorak Emberhand source, unique relic, modest damage/might effect.
- `cinderseer_focus`: Veyra of the Cinders source, unique relic, modest mana/arcana effect.
- `outpost_command_signet`: Captain Malrec source, unique relic, modest HP/armor/command effect.

Each relic keeps a short description, effect summary, tags/category, acquisition source, rarity, and explicit duplicate policy. Duplicate copies are not allowed.

## Acquisition Rules

Eligible acquisition requires:

- victory,
- rewards enabled,
- non-Tutorial launch mode,
- a known rival champion,
- the rival champion defeated.

The first safe v0.32 implementation auto-grants the matching source relic instead of adding a choice modal. A later choice UI can offer alternatives, but it must still use the same small pool, no-farm gates, and duplicate rules.

## Duplicate Handling

Relics are unique. If the matching relic is already present during an otherwise eligible grant, the duplicate converts through the existing unique-item duplicate conversion rule and no second relic instance is added.

Repeat defeated-rival clears do not repeatedly convert relic duplicates. Old v0.31 saves that already defeated a rival but have no relic can receive a one-time catch-up relic the next time that rival is defeated, after which the inventory blocks further grants.

## Tutorial And No-Reward Protection

Tutorial / Proving Grounds and any `rewardsDisabled` launch do not grant relics, do not show relic reward acquisition, and do not persist relic inventory changes.

## Save Compatibility

No save version bump is required for v0.32. Existing v1/v2 saves normalize through the current loader:

- missing inventory stays empty,
- missing equipment stays empty,
- legacy equipment references are normalized to item instances,
- `equipment.relic` is accepted only when it points at an inventory instance or legacy item id.

If a future checkpoint adds account-wide relic state, that future change must use an explicit migration and fixture coverage.

## UI Scope

Use existing surfaces only:

- Results: show the relic gained, duplicate conversion if any, inventory status, and equip hint.
- Hero Inventory: show the relic slot in Equipment and relic entries in Inventory.
- Battle HUD: show the equipped relic summary.

No new art, portraits, icon assets, inventory grid, shop, crafting, or paper-doll UI is part of this spec.

## Deferrals

- Relic reward choice modal.
- Random relic rolls.
- More than the three source relics.
- Account-wide collection.
- Stacking relic copies.
- Relic upgrade/crafting/sell/disenchant systems.
