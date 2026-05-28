# v0.35 Hero Build Identity Spec

Date: 2026-05-27

## Goal

Make the one-slot relic loadout read as a tiny hero build identity layer without adding a full skill tree, paper-doll UI, large inventory overhaul, or new art.

## Build Archetypes

Relics expose three readable archetypes:

- Warrior: damage, might, direct fighting pressure.
- Seer: mana, arcana, ability support.
- Commander: durability, armor, command, army leadership.

The archetype is descriptive only in v0.35. It does not unlock skills, gate equipment, add class restrictions, or create a new build tree.

## Loadout Readability

Existing Hero Inventory and Equipment panels should show:

- equipped relic clearly in the Relic slot,
- available relics clearly in the Inventory list,
- rarity, tags, and archetype,
- effect summary before equip,
- stat preview before equip,
- equipped/owned state,
- unequip support through the existing equipment row.

## Results Readability

Results should show:

- champion defeated state in the Battle and Rival blocks,
- XP and normal rewards,
- relic choice options before selection,
- owned/duplicate state,
- final relic gained after selection,
- `Equip Relic` after a relic is added,
- final equipped state after equip.

## Save Safety

No save-version bump is needed. The checkpoint continues to use:

- `HeroSaveData.inventory` for acquired relic item instances,
- `HeroSaveData.equipment.relic` for the one-slot loadout,
- existing save normalization for old equipment references,
- known-item filtering for unknown relic ids.

## Deferrals

- Multiple relic slots.
- Full hero build tree.
- Relic comparison modal.
- Inventory filtering, sorting, favoriting, or locking pass.
- Shop, crafting, upgrades, or salvage.
- Starting-resource, XP multiplier, or aura systems beyond modest existing stat modifiers.

