# v0.34 Relic Reward Choice Spec

Date: 2026-05-27

## Goal

Make eligible rival champion victories feel more intentional by replacing the v0.32-v0.33 auto-grant with a tiny inline Results choice flow. The feature must stay inside existing Results and inventory surfaces, keep the current save shape, and avoid a broad loot or inventory system.

## Reward Choice Rules

Eligible relic choice requires:

- victory,
- campaign-node mode,
- rewards enabled,
- non-Tutorial launch,
- a known rival champion,
- the rival champion defeated.

The source champion strongly influences the choice:

- the source champion relic is always the first choice when it is not already owned;
- one additional unowned relic from the tiny pool can appear as the second choice;
- if only one valid unowned relic remains, Results shows a one-choice confirmation;
- if all relics are already owned during an otherwise eligible first-defeat or catch-up grant, the source relic uses the existing unique duplicate conversion rule;
- repeat clears do not repeatedly create duplicate conversions.

## Relic Rarity And Tags

The v0.34 pool remains the three existing relics:

- `emberbrand_shard`: rare Warrior / damage relic.
- `cinderseer_focus`: rare Seer / mana relic.
- `outpost_command_signet`: epic Commander / durability relic.

Each relic definition carries rarity, source, tags, archetype, effect summary, duplicate policy, and acquisition copy. No new relics are required for the first choice flow.

## Duplicate Handling

Relics remain unique. Duplicate copies are not allowed.

If a selected relic somehow resolves as already owned, the grant path falls back to the same unique duplicate conversion rule instead of adding a second instance. Normal player-facing choices hide owned relics while at least one unowned relic remains.

## UI Copy

Results uses an inline `Relic Reward Choice` block:

- champion/source copy,
- one or two relic option cards,
- rarity and archetype tags,
- owned/available state,
- effect summary,
- stat summary,
- a clear choose button.

After selection, the block becomes the existing `Relic Reward` result with inventory state and `Equip Relic` action.

## Deferrals

- Modal reward picker.
- Random relic rolls.
- Large relic pool.
- Relic reroll, shop, crafting, sell, or upgrade systems.
- Account-wide relic collection.
- Runtime art, icons, portraits, or VFX.

