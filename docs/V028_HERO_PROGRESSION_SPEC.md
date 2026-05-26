# v0.28 Hero Progression Spec

Date: 2026-05-26

## Mission

Make the player hero read as a real battlefield commander during normal RTS battles by formalizing live battle XP, level-up gains, and safe reward persistence. v0.28 uses the existing hero save, reward, skill, and stat systems. It does not add a save migration, new maps, new factions, runtime art, inventory overhaul, enemy hero progression, or broad balance changes.

## XP Sources

Battle XP is conservative and visible:

- Enemy unit and building kills grant their existing `xpValue` when the hero participates directly or is close enough to share credit.
- First player capture of each resource site grants a small one-time battle XP award.
- Victory reward tables can add XP at results, as they already do.
- Campaign node rewards can add XP after the battle when the node is first completed.
- Tutorial mode remains no-save and no-reward; any training XP is discarded and should not persist.

Repeated recaptures of the same site in one battle must not farm XP.

## Level Curve And Stat Gains

The existing shared level curve remains:

| Level | Total XP |
| --- | --- |
| 2 | 100 |
| 3 | 250 |
| 4 | 450 |
| 5 | 700 |

Each level grants modest live and saved stat growth:

- +18 max HP
- +10 max Mana
- +2 hero damage
- +1 armor on every other level, matching saved stat recalculation
- +1 skill point

On a live level-up, HP and Mana refill so the moment is readable and useful without making the hero invincible.

## Ability Unlocks

The hero starts with the class primary ability. Additional abilities remain unlocked through existing skill-tree spending after level-up grants skill points. v0.28 does not auto-unlock a large ability roster from level alone.

## Persistence

Victory persists the hero state through the existing `HeroSaveData` and reward flow. Defeat and Tutorial runs do not save battle XP, rewards, items, or campaign progress.

No save migration is required because `HeroSaveData` already stores level, XP, skill points, unlocked abilities, inventory, equipment, and allocated skills.

## UI Display

Battle HUD should show:

- hero level,
- HP/Mana,
- XP progress,
- skill points,
- short damage/armor summary,
- level-up message when XP crosses a threshold.

Results should show total XP gained, before/after XP progress, level-up count, and skill points gained.

## Deferrals

- Persistent enemy hero progression.
- New hero classes or a large ability roster.
- Inventory, relic, or loot overhaul.
- New art, animation, or VFX assets.
- Post-level skill allocation inside the battle HUD.
