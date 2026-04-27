# Balance Notes

These numbers are prototype values. They are designed for readability and fast testing, not final balance.

## First Real Human-Paced Campaign Balance Pass - 2026-04-26

Goal: make the first 30 minutes of the mini-campaign coherent, fair, and rewarding without adding systems, maps, factions, construction AI, workers, or affixes. This pass only changes pacing values, rewards, campaign costs, reward weights, and guidance text.

Intended first-30-minute arc:

- Border Village: low-stress tutorial battle. The player learns capture, build, train, defend the first wave, win, and collect the Weathered Command Sword.
- Old Stone Road: first real battle. Raider Rush should pressure a greedy opening but still leave time to build Barracks, set a rally point, and meet the first attack with trained units.
- Marcher Camp and Refugee Caravan: first campaign-bank spend and first consequence choice. The player should understand that Crowns buy short-term safety, fixed items, supplies, or reputation outcomes.
- Aether Well Ruins or Bandit Hillfort: first Normal branch. The difficulty spike should come from map pressure and AI personality, while the reward jump makes the risk feel worthwhile.
- Chapel of the Marches into Ashen Outpost: support preparation and milestone fortress assault. Chapel guidance should scout without accidentally closing the node, and Ashen Outpost should feel fortified without becoming an early wall.

### Difficulty And AI Timing Changes

| Area | Before | After | Reason |
| --- | --- | --- | --- |
| Story difficulty | 0.50x enemy income, first attack 260s, 90s attack interval, 8s train interval, commander 780s | 0.45x enemy income, first attack 300s, 100s attack interval, 9s train interval, commander 840s | Makes Story a clearer learning/testing lane with the longest warning window and no fog. |
| Easy difficulty | 0.68x enemy income, first attack 225s, 78s attack interval, 6.6s train interval, commander 720s | 0.65x enemy income, first attack 240s, 82s attack interval, 7s train interval, commander 750s | Gives Border Village and Old Stone Road enough time for capture, Barracks, rally, and first defense. |
| Normal difficulty | 0.90x enemy income, first attack 180s, 62s attack interval, 7-unit wave target, 5.4s train interval, commander 540s | 0.86x enemy income, first attack 195s, 66s attack interval, 6-unit wave target, 5.8s train interval, commander 570s | Keeps Normal dangerous after the opening while reducing the first branch spike. |
| Raider Rush personality | 0.80x first attack, 0.82x attack interval, 0.78x expansion interval, 0.92x income | 0.86x first attack, 0.88x attack interval, 0.82x expansion interval, 0.88x income | Preserves early pressure but makes Old Stone Road feel like a readable lesson instead of a surprise check. |
| Fortress Keeper personality | 1.05x income, 1.12x wave size | 1.02x income, 1.08x wave size | Keeps the hillfort defensive identity while trimming the raw late-wave spike. |
| Hexfire Cult personality | 1.05x first attack and interval, 1.08x income | 1.08x first attack and interval, 1.02x income | Makes caster pressure distinct through composition, not simply a stronger economy. |

### Campaign Economy And Reward Changes

| Node or Table | Before | After | Reason |
| --- | --- | --- | --- |
| Old Stone Road node reward | 45 XP, 50 Crowns, 40 Stone | 50 XP, 60 Crowns, 45 Stone, 15 Iron | Makes the second Easy battle pay enough to make Marcher Camp choices understandable. |
| Well Rested | +10% next-battle hero max HP for 35 Crowns | +15% next-battle hero max HP for 30 Crowns | Gives the first rest service an immediately legible defensive benefit. |
| Hire Volunteers | 50 Crowns | 55 Crowns | Keeps the extra starting Militia useful but slightly more premium than rest. |
| Buy Supplies | 40 Crowns for 30 Stone, 14 Iron, 6 Aether | 45 Crowns for 30 Stone, 18 Iron, 8 Aether | Makes the conversion feel worthwhile for later repairs/items without becoming a power buy. |
| Marcher Plate purchase | 85 Crowns, 20 Iron | 80 Crowns, 18 Iron | Makes the first armor purchase reachable after early battles and one branch reward. |
| Green Chapel Icon purchase | 100 Crowns, 20 Aether | 90 Crowns, 18 Aether | Keeps the trinket expensive but less likely to be impossible after normal spending. |
| Aether Well Ruins node reward | 60 XP, 50 Aether, Aether Lens | 70 XP, 35 Stone, 55 Aether, Aether Lens | Gives the first Normal caster branch both progression and repair-relevant resources. |
| Bandit Hillfort node reward | 65 XP, 70 Crowns, 45 Iron, Captain's Seal | 70 XP, 75 Crowns, 25 Stone, 50 Iron, Captain's Seal | Makes the fortress branch a stronger prep route toward Ashen Outpost. |
| Chapel repair | 55 Crowns, 65 Stone for 35 Aether, Green Chapel Icon, Local Support, recovery | 50 Crowns, 60 Stone for the same reward | Makes the support/preparation choice viable after reasonable early spending. |
| Chapel guidance text | Warned about Ashen Outpost but read like a normal completion choice | Explicitly scouts without closing the chapel | Reduces confusion and supports planning before the milestone fight. |
| Protect Them caravan choice | 30 Crowns, 10 Iron for 30 XP, Scout's Bow, +6 Common Folk, +2 Free Marches | 45 Crowns for 35 XP, Scout's Bow, +8 Common Folk, +2 Free Marches | Makes the generous choice costly in Crowns but not punishing to Iron progression. |
| Recruit Volunteers caravan choice | Level 2 requirement, no cost, 25 XP, 30 Iron, Marcher Plate, Inspired Militia, -2 Common Folk | Level 2 requirement, 20 Crowns, 25 XP, 25 Iron, Marcher Plate, Inspired Militia, -4 Common Folk | Makes it a distinct pragmatic choice rather than a nearly free item/resource bundle. |
| Demand Tribute caravan choice | 80 Crowns, Angered Raiders, -8 Common Folk, -2 Free Marches, -3 Ashen Covenant | 65 Crowns with the same consequences | Keeps the selfish option tempting but not the obvious best economy line. |
| Ashen Outpost starting banks | Player 440/300/165/95, enemy 300/220/175/140 | Player 460/320/180/95, enemy 280/220/160/125 | Lets the player stage a fortress assault while reducing enemy snowball. |
| Ashen Outpost enemy income | 105 Crowns, 52 Stone, 52 Iron, 42 Aether every 5s | 100 Crowns, 50 Stone, 50 Iron, 40 Aether every 5s | Keeps pressure steady but lowers attrition from repeated fortress waves. |
| First Claim reward weights | Starter weapons 28 each, Scout's Bow 18, rare trinkets 7 each | Starter weapons 30 each, Scout's Bow 20, rare trinkets 5 each | Makes the first two battles more likely to award understandable early gear instead of spiky rare trinkets. |
| Broken Ford reward weights | Scout's Bow 18, rare trinkets 13 each, Ashbound Censer 9, epics 4 each | Scout's Bow 16, rare trinkets 14 each, Ashbound Censer 10, epics 5 each | Slightly improves Normal-branch reward excitement after the guaranteed Fordbreaker Halberd. |
| Ashen Outpost reward weights | Green Chapel Icon 12, Oathbound Aegis 7, Starfall Prism 5 | Green Chapel Icon 10, Oathbound Aegis 6, Starfall Prism 7 | Avoids overpaying the guaranteed campaign Aegis while making the milestone caster trinket less vanishingly rare. |

### Text And Guidance Changes

- Chapel guidance now says the guidance option scouts the road without completing the node.
- Defeat guidance now tells players to equip prior rewards, capture a resource site, build a Barracks before the first attack, and use a rally point.
- The intended role split is now clearer: Story is for learning and testing, Easy is for tutorial battles with survivable pressure, and Normal is the first real baseline once the player understands build/train/rally.

### Remaining Human Testing Notes

- Time a fresh Border Village run with no prior RTS knowledge: confirm the first enemy gathering warning lands after the player has captured a site and started Barracks construction.
- Time Old Stone Road with a greedy opener and a clean opener: Raider Rush should punish ignoring Barracks, not punish normal tutorial play.
- Check Marcher Camp after two clears: the player should afford one item or one to two services, but not feel the only correct choice is Hire Volunteers.
- Play both Aether Well Ruins and Bandit Hillfort on Normal from a campaign save with typical early spending; confirm the branch reward feels strong enough after a defeat or narrow win.
- Try Ashen Outpost with and without Chapel repair. Towers should make the final approach tense, while the trimmed enemy economy should prevent endless recovery waves.

## Starting Resources

- Crowns: 380
- Stone: 255
- Iron: 140
- Aether: 75

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

Ashen Outpost:

- Burned Shrine: +26 Aether every 5 seconds.
- West Supply Pyre: +30 Crowns every 6 seconds.
- South Iron Pit: +22 Iron every 6 seconds.
- North Stone Scar: +26 Stone every 6 seconds.

## Map Notes

- First Claim is the balanced tutorial skirmish. Its first Crown site is close, the side camps are readable, and the direct lane keeps the first attack easy to understand.
- Broken Ford is wider at 2600x1700 and has more blocked terrain. The center pays better but is guarded and exposed, while side resources are safer but slower.
- Ashen Outpost is the current mini-campaign milestone map at 2600x1800. It gives the player a stronger starting economy and one extra Militia, but the enemy fortress has two defensive towers, tighter upper-right terrain, Hexfire Cult pressure, and a central Burned Shrine that is valuable but dangerous. The enemy's starting bank and income are intentionally below the first fortress draft so the challenge comes from position, towers, and wave composition rather than raw economy alone.
- All maps use the same global difficulty presets. Map-level `scenario.enemyAI` values can nudge expand and attack rhythm, but difficulty still controls income multiplier, attack delay, wave size, training speed, and commander timing.

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
- Ember Blades: Ashen Covenant data trait placeholder; Raiders gain a small damage bump in data, while live burn pressure currently comes from Hexers through faction modifiers.

Upgrade costs and effects live in `src/game/data/upgrades.ts`.

## Faction Asymmetry

Faction style and trait data lives in `src/game/data/factions.ts`.

Free Marches are the player baseline:

- Balanced economy and training costs.
- Reliable Militia, Rangers, Acolytes, and defensive Watchtowers.
- Better long-term scaling through hero leadership, campaign reputation, and equipment.

Ashen Covenant is tuned for pressure:

- Raiders are cheaper and hit harder than before, but have lower HP.
- Hexers have lower HP but higher damage and apply `hexfire_burn`.
- Brutes remain the durable Ashen exception and anchor late waves.
- `hexfire_burn`: 3 damage per second for 4 seconds, ticking once per second.
- `ashen_fury`: Raiders, Hexers, Brutes, and the enemy commander deal 15% more damage below 50% HP.
- `smoke_march`: Raiders and Hexers in launched AI waves move 6% faster.

Ashen should feel more dangerous when the player lets waves reach the base, but still fair because their lighter units can be picked off with hero abilities, Watchtowers, and focused army control. If burn becomes frustrating, reduce duration before reducing DPS so the effect remains readable but less punishing.

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

- Common weapons should usually add 2 to 4 damage or 1 to 2 primary stats.
- Uncommon armor should usually add 18 to 40 HP and 1 to 2 armor, with speed penalties only when meaningful.
- Rare trinkets should mostly add 3 primary stats, mana, or small hybrid bonuses.
- Epic items can combine a strong defensive or caster bonus with 1 to 2 secondary stats.
- Legendary items should feel broad and special, but not invalidate skill trees or army control.

Reward tables now use weighted pools, fixed rewards, resource payouts, XP payouts, first-clear bonuses, and repeat-clear rewards. Deterministic item order remains available for tests. Each item reward creates an inventory instance so future affixes and provenance can attach to individual copies.

Current reward pacing:

- First Claim grants one weighted item roll, modest resources, 35 base victory XP, and a first-clear bonus of 40 XP plus starter resources. Its weighted pool now leans slightly toward starter/common gear and away from early rare trinkets.
- Broken Ford grants one weighted item roll, stronger resource payouts, 55 base victory XP, and a first-clear Fordbreaker Halberd plus 65 bonus XP. Its weighted pool gives a small bump to branch-defining trinkets and rare/epic excitement.
- Ashen Outpost grants one weighted item roll, high milestone resources, 85 base victory XP, and a first-clear Ashbound Censer plus 95 bonus XP. The Ashen Outpost campaign node also grants a larger campaign-bank payout and an Oathbound Aegis for the milestone clear, so the weighted pool favors Starfall Prism slightly more than a duplicate Aegis.
- Weighted item rolls prefer unowned catalog items when possible. Non-unique duplicate rewards remain separate instances. Unique duplicate rewards convert into campaign resources: common/uncommon items convert to Crowns, while rare/epic/legendary items convert to Aether.

## Campaign Resource Spending

Marcher Camp is the first campaign-bank sink and unlocks after Old Stone Road. It is intentionally small: one town node, repeatable services, and three one-time item purchases.

Current Marcher Camp costs:

- Rest and Recovery: 30 Crowns for Well Rested, a next-battle +15% hero maximum HP modifier.
- Hire Volunteers: 55 Crowns for Inspired Militia, a next-battle extra Militia.
- Buy Supplies: 45 Crowns for 30 Stone, 18 Iron, and 8 Aether.
- Emberglass Wand: 60 Crowns, one-time common weapon purchase.
- Marcher Plate: 80 Crowns and 18 Iron, one-time uncommon armor purchase.
- Green Chapel Icon: 90 Crowns and 18 Aether, one-time trinket purchase.

These costs are tuned so Border Village plus Old Stone Road rewards let the player buy one or two meaningful services or an early item immediately, but not clear the whole stock. Future economy passes should add more sinks before raising reward payouts.

Rarity philosophy:

- Common: early identity and starter class support.
- Uncommon: practical build-shaping stats.
- Rare: noticeable hero specialization.
- Epic: map-defining or class-defining rewards.
- Legendary: very rare repeat-clear chase items.

## How To Tune AI Wave Timing

AI timing now comes from the battle pacing model in `src/game/data/battlePacing.ts`, with map-level defaults still living in each map's `scenario.enemyAI` block in `src/game/data/maps.ts`.

The first skirmish is paced around four battle phases:

- Opening, 0:00 to 2:00: no base attacks. Enemy can train, scout, and move toward sites.
- Expansion, 2:00 to 5:00: first small base attack becomes legal after the difficulty delay and tutorial gates.
- Pressure, 5:00 to 8:00: mixed waves grow to 3 to 5 units.
- Assault, 8:00 onward: larger waves can include Brutes, Hexers, and eventually the enemy commander.

Difficulty presets:

- Story: 1 starting Raider, 0.45x income, first attack at 5:00, 100s interval, 2-unit waves, commander after 14:00, fog disabled.
- Easy: 2 starting Raiders, 0.65x income, first attack at 4:00, 82s interval, 3-unit waves, commander after 12:30, fog enabled.
- Normal: 2 Raiders, 1 Hexer, commander at base, 0.86x income, first attack at 3:15, 66s interval, phase-capped 6-unit waves, commander after 9:30, fog enabled.
- Hard: Raiders, Hexer, Brute, commander, 1.15x income, first attack at 2:30, 48s interval, larger waves, commander after 8:00, fog enabled.

AI personalities live in `src/game/data/aiPersonalities.ts` and modify the base difficulty/map pacing:

- Balanced Warlord: 1.0x baseline timing, mixed Raider/Hexer/Brute training, default for Border Village.
- Raider Rush: 0.86x first-attack delay, 0.88x attack interval, 0.82x expansion interval, 0.88x income, mostly Raiders and Hexers, smaller late waves.
- Fortress Keeper: 1.22x first-attack delay, 1.18x attack interval, 1.02x income, larger defense radius, defensive reserves, Brute-heavy late waves.
- Hexfire Cult: 1.08x first-attack delay and attack interval, 1.02x income, more Hexers, dangerous caster bursts with fewer melee bodies.

Campaign assignments:

- Border Village: Balanced Warlord on Easy.
- Old Stone Road: Raider Rush on Easy.
- Aether Well Ruins: Hexfire Cult on Normal.
- Bandit Hillfort: Fortress Keeper on Normal.
- Ashen Outpost: Hexfire Cult on Normal using the dedicated Ashen Outpost fortress map.

Ashen Outpost special objectives:

- Primary: destroy the Ashen Stronghold.
- Secondary: capture the Burned Shrine.
- Secondary: destroy the Enemy Barracks.
- Secondary: defeat the Outpost Captain.

## Fog Of War

Fog tuning lives in three places:

- Difficulty presets in `src/game/data/battlePacing.ts` set `fogOfWarEnabled`.
- Unit, hero class, and building definitions set `visionRadius`.
- `FogOfWarSystem` uses a 160px grid cell size by default for stable, inexpensive updates.

Current prototype vision ranges:

- Hero classes: 540 to 560.
- Basic units: 300 to 430.
- Command Hall and enemy stronghold: 560.
- Barracks and Mystic Lodge: 430.
- Watchtower: 720.

Story disables fog for accessibility and onboarding. Easy, Normal, and Hard enable it. Capture sites are hidden until explored, then remain known; ownership is shown live after discovery for prototype readability rather than using last-known ownership.

First-match protection:

- The first battle will not send the first attack before 2:30.
- If the player has not captured a site, the first attack waits until 3:00.
- Large attacks are capped to 2 units until the player has built production or 4:00 has passed.
- The enemy commander is excluded from the first attack and cannot join until assault pacing allows it.

Expected enemy waves on Normal:

- First wave, around 3:15 baseline or around 3:30 on Hexfire Cult: 2 Raiders, or 2 Raiders plus 1 Hexer if the player has already built production.
- Mid waves, 5:00 to 8:00: 3 to 5 mixed Raiders, Hexers, and occasional Brutes.
- Late waves, 8:00 onward: Brute and Hexer support, with commander participation after about 9:30 baseline.

Intended first 10 minutes:

- 0:00 to 1:00: select the hero, gather starting troops, move toward the Crown Shrine.
- 1:00 to 2:00: capture the Crown Shrine, learn site income, and choose a build location.
- 2:00 to 3:30: build a Barracks, start training Militia, and receive enemy gathering warnings.
- 3:15 to 5:00: survive the first small attack near the Command Hall.
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
- Personality timing multipliers, unit plan, phase overrides, defense radius, defensive reserves, and commander rules.

Shorter wave timing creates more pressure. Longer timing gives the player more room to learn controls.
