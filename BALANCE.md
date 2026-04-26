# Balance Notes

These numbers are prototype values. They are designed for readability and fast testing, not final balance.

## Starting Resources

- Crowns: 360
- Stone: 240
- Iron: 130
- Aether: 70

## Site Income

First Claim:

- Crown Shrine: +30 Crowns every 5 seconds.
- Stone Quarry: +25 Stone every 5 seconds.
- Iron Vein: +20 Iron every 5 seconds.
- Aether Well: +15 Aether every 5 seconds.

Broken Ford:

- Ford Toll: +34 Crowns every 5 seconds.
- West Stone Cut: +22 Stone every 6 seconds.
- South Iron Cache: +18 Iron every 6 seconds.
- North Aether Spring: +14 Aether every 6 seconds.

## Map Notes

- First Claim is the balanced tutorial skirmish. Its first Crown site is close, the side camps are readable, and the direct lane keeps the first attack easy to understand.
- Broken Ford is wider at 2600x1700 and has more blocked terrain. The center pays better but is guarded and exposed, while side resources are safer but slower.
- Both maps use the same global difficulty presets. Map-level `scenario.enemyAI` values can nudge expand and attack rhythm, but difficulty still controls income multiplier, attack delay, wave size, training speed, and commander timing.

## Construction Times

Construction time lives on each building definition in `src/game/data/buildings.ts`.

- Barracks: 25 seconds.
- Mystic Lodge: 30 seconds.
- Watchtower: 20 seconds.
- Command Hall, Enemy Stronghold, and Enemy Barracks: 0 seconds because they are scenario-start structures.

New player buildings start under construction at partial HP, appear translucent, cannot train, research, or attack, and complete automatically. This keeps the opening readable without adding worker pathing yet.

## Training And Research Queues

Unit costs are paid when the unit is queued, not when it finishes. Canceling a queued or active unit refunds the full paid cost for now.

Research also pays up front and completes after its `researchTimeSeconds`. Current upgrades:

- Infantry Weapons I: 18 seconds, +10% damage for Militia and Raider-style melee units.
- Ranger Training I: 20 seconds, +10% Ranger range and 10% faster Ranger attacks.
- Reinforced Armor I: 22 seconds, +1 armor for Militia, Ranger, and Acolyte.
- Aether Study I: 24 seconds, +10% Acolyte damage and +25% hero mana regeneration.

Upgrade costs and effects live in `src/game/data/upgrades.ts`.

## How To Tune Costs

Raise costs when units or buildings appear too quickly. Lower costs when the opening feels empty. For early testing, change costs in increments of 10 to 25.

## How To Tune Damage

Damage is reduced by armor. Raise unit damage if fights feel slow. Raise HP or armor if units die before the player can react.

## How To Tune XP

XP values live on unit and building definitions. If heroes level too quickly, raise the level thresholds in `Constants.ts` or lower XP rewards. If leveling feels invisible, lower the Level 2 threshold first.

## Hero Progression

Skill points are gained when the hero levels up. Skill nodes live in `src/game/data/skillTrees.ts`.

Current passive tuning:

- `combat_drill`: +2 damage and +1 Might per rank.
- `combat_endurance`: +24 HP per rank.
- `magic_focus`: +18 Mana and +1 Arcana per rank.
- `magic_warding`: +1 armor per rank.
- `leadership_presence`: +1 Command and +8 HP per rank.
- `leadership_field_rites`: +1 Faith and +10 Mana per rank.

If heroes become too durable, lower HP and armor passives before changing enemy damage. If abilities dominate every fight, raise mana costs and cooldowns in `src/game/data/abilities.ts`.

## Equipment And Rewards

Items live in `src/game/data/items.ts`. Battle reward tables live in `src/game/data/rewards.ts`, and each map points to one reward table through `scenario.rewardTableId`.

Use small equipment bonuses while the roster is tiny:

- Weapons should usually add 2 to 4 damage or primary stats.
- Armor should usually add HP and 1 to 2 armor, with speed penalties only when meaningful.
- Trinkets should mostly add primary stats or mana.

The current reward picker is deterministic and gives one new item after a victory when possible. This is useful for testing, but later campaign rewards should support rarity weights, shops, quest rewards, and duplicate handling.

## How To Tune AI Wave Timing

AI timing now comes from the battle pacing model in `src/game/data/battlePacing.ts`, with map-level defaults still living in each map's `scenario.enemyAI` block in `src/game/data/maps.ts`.

The first skirmish is paced around four battle phases:

- Opening, 0:00 to 2:00: no base attacks. Enemy can train, scout, and move toward sites.
- Expansion, 2:00 to 5:00: first small base attack becomes legal after the difficulty delay and tutorial gates.
- Pressure, 5:00 to 8:00: mixed waves grow to 3 to 5 units.
- Assault, 8:00 onward: larger waves can include Brutes, Hexers, and eventually the enemy commander.

Difficulty presets:

- Story: 1 starting Raider, 0.55x income, first attack at 4:00, 82s interval, 2-unit waves, commander after 12:00.
- Easy: 2 starting Raiders, 0.72x income, first attack at 3:30, 72s interval, 3-unit waves, commander after 11:00.
- Normal: 2 Raiders, 1 Hexer, commander at base, 0.9x income, first attack at 3:00, 62s interval, phase-capped waves, commander after 9:00.
- Hard: Raiders, Hexer, Brute, commander, 1.15x income, first attack at 2:30, 48s interval, larger waves, commander after 8:00.

First-match protection:

- The first battle will not send the first attack before 2:30.
- If the player has not captured a site, the first attack waits until 3:00.
- Large attacks are capped to 2 units until the player has built production or 4:00 has passed.
- The enemy commander is excluded from the first attack and cannot join until assault pacing allows it.

Expected enemy waves on Normal:

- First wave, around 3:00: 2 Raiders, or 2 Raiders plus 1 Hexer if the player has already built production.
- Mid waves, 5:00 to 8:00: 3 to 5 mixed Raiders, Hexers, and occasional Brutes.
- Late waves, 8:00 onward: Brute and Hexer support, with commander participation after about 9:00.

Intended first 10 minutes:

- 0:00 to 1:00: select the hero, gather starting troops, move toward the Crown Shrine.
- 1:00 to 2:00: capture the Crown Shrine, learn site income, and choose a build location.
- 2:00 to 3:30: build a Barracks, start training Militia, and receive enemy gathering warnings.
- 3:00 to 5:00: survive the first small attack near the Command Hall.
- 5:00 to 8:00: expand to Stone or Iron, train a mixed army, use hero abilities during pressure waves.
- 8:00 to 10:00: counterattack or prepare for commander-backed assaults against the player base.

The key knobs are:

- `incomeInterval` and `incomePerTick`.
- Difficulty `enemyIncomeMultiplier`.
- Difficulty `trainInterval`.
- Difficulty `expandInterval`.
- Difficulty `firstAttackDelay` and `attackInterval`.
- `minAttackArmySize`.
- Difficulty and phase `attackWaveSize`.
- Phase `allowedAttackUnitIds`, `preferredAttackUnitIds`, and `maxAttackByUnitId`.
- Map `unitPlan`.

Shorter wave timing creates more pressure. Longer timing gives the player more room to learn controls.
