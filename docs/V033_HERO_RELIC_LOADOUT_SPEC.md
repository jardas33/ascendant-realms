# v0.33 Hero Relic Loadout Spec

Date: 2026-05-27

## Goal

Add the first safe hero relic loadout foundation: one equipped relic can apply a modest effect to the hero using the existing equipment/stat pipeline. The feature should feel like a small RPG reward loop, not a full equipment overhaul.

## Loadout Rules

- The hero has one relic slot: `equipment.relic`.
- Equipping a relic replaces the previously equipped relic.
- Unequipping a relic clears `equipment.relic`.
- Relic effects are active only while equipped.
- Relic effects do not stack accidentally because duplicate relic instances are blocked.
- Relics can be equipped from Results when newly granted or from the existing Hero Inventory screen between battles.

## Effect Application

Effects use existing hero stat modifiers:

- `Emberbrand Shard`: small hero damage/might boost.
- `Cinder-Seer Focus`: small max Mana/arcana boost.
- `Outpost Command Signet`: small max HP/armor/command boost.

The existing stat recalculation path applies these effects in battle startup, Results stat previews, and Hero Inventory. Unequipping removes the effect on the next recalculation.

## Reward Choice Model

v0.33 documents a reward-choice model but does not implement a risky new modal:

- eligible rival champion defeat identifies a tiny candidate set from the source champion;
- v0.33 auto-grants the matching relic;
- future choice UI may offer 2-3 choices only after it can preserve no-reward Tutorial gates, duplicate handling, and save safety.

## Results UI

Results should show:

- relic name and source champion,
- whether it was added to inventory or converted as a duplicate,
- effect summary,
- "Relic effects are active when equipped.",
- an Equip Relic action when a newly granted relic instance exists and is not already equipped.

## Hero Inventory UI

The existing Hero Inventory remains the loadout surface:

- Equipment lists the Relic slot.
- Inventory lists relic item rows with rarity, total stat modifiers, description, source, tags, and equip action.
- No large inventory redesign is allowed.

## Battle HUD UI

The battle hero panel shows a compact equipped relic summary:

- `Relic: Empty` when no relic is equipped.
- `Relic: <name> active` when a known relic item is equipped.

## Save Migration Plan

No migration is needed for v0.33 because `HeroSaveData.equipment` already permits `relic`. Old saves without `equipment.relic` load with an empty relic loadout. Old saves with unknown relic ids keep loading; unknown ids do not apply effects or render as known relics.

## Deferrals

- Multiple relic slots.
- Relic skill trees.
- Passive economy effects, starting-resource bonuses, or XP multipliers.
- Relic comparison modal.
- Relic filtering, sorting, locking, favorites, or bulk management.
- New art/assets or visual icon pass.
