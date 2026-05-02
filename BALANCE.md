# Balance Notes

These numbers are prototype values. They are designed for readability and fast testing, not final balance.

## Current First-Campaign Baseline - 2026-05-02 Retinue Balance Pass

The values in this section are the current first-campaign balance baseline. Older dated sections below explain how they changed, but should not be read as newer than this checkpoint.

- Latest simulator verdict: `npm run playtest:sim` passes with 180 deterministic runs across 5 campaign battle nodes and 12 profiles, including no-retinue, one Veteran Militia, one Veteran Ranger, mixed retinue, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II; no structural `too_hard` nodes, no structural `too_easy` nodes, no Stronghold warnings, and Ashen Outpost remains beatable by the Safe Beginner script without retinue.
- Current starting battle resources: 380 Crowns, 255 Stone, 140 Iron, 75 Aether.
- Current First Claim site income: Crown Shrine +30 Crowns/5s, Stone Quarry +25 Stone/5s, Iron Vein +20 Iron/5s, Aether Well +15 Aether/5s.
- Current Broken Ford site income: Ford Toll +34 Crowns/5s, West Stone Cut +22 Stone/6s, South Iron Cache +18 Iron/6s, North Aether Spring +14 Aether/6s.
- Current Ashen Outpost site income: Burned Shrine +26 Aether/5s, West Supply Pyre +30 Crowns/6s, South Iron Pit +22 Iron/6s, North Stone Scar +26 Stone/6s.
- Current broad difficulty pacing baseline: Story is the learning/testing lane with no fog, Easy is for tutorial battles with survivable pressure, and Normal is the first real baseline once build/train/rally is understood.
- Current Stronghold Development is a small persistent campaign-resource sink with five Tier I upgrades and five compact Tier II follow-ups. Purchased upgrades apply only to later battle launches and do not alter the current battle retroactively.
- Current reputation hooks are intentionally modest: Friendly starts at +25, Honored at +50, Disliked at -25, and Hostile at -50. Reputation effects adjust preparation costs/rewards or add one minor Ashen pressure unit; they do not create diplomacy, new factions, or alternate maps.
- Current item affixes are V1 only: small stat packages rolled onto reward-generated item instances, visible in Results/Inventory, and applied only while the item instance is equipped. They do not add crafting, durability, item art, affix rerolls, or proc-heavy loot complexity.
- Current Unit Veterancy and Retinue Camp are V1 only: ordinary player units can rank up inside a battle, campaign victories can save a small number of surviving Seasoned+ units, and campaign launches redeploy saved retinue units without adding a large army-management layer.

| Difficulty | Enemy income | First attack | Attack interval | Wave target | Train interval | Commander timing |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Story | 0.45x | 300s | 100s | 2 | 9.0s | 840s |
| Easy | 0.65x | 240s | 82s | 3 | 7.0s | 750s |
| Normal | 0.82x | 195s | 72s | 5 | 6.2s | 630s |

- Current map-level pacing is authoritative where present: First Claim currently uses the softened Easy opener from the telemetry follow-up, and Ashen Outpost currently uses the reduced fortress economy, one gate Watchtower, four starting Militia, two Rangers, and Burned Shrine gate-Watchtower weakening.
- Current human-review focus: Aether Well Ruins, Bandit Hillfort, and Ashen Outpost need feel/readability review before more numeric tuning.
- Current Stronghold tuning focus: Tier I has readable value in telemetry without an overpowered warning, while Tier II stays optional and route-specific. Watch Post I/II improve warning/readability telemetry, Quartermaster Stores I/II improve build-order resources, Chapel Corner I/II add modest hero durability, and Ranger Paths II adds one starting Ranger only after the scout path is already purchased.

## Reputation Hooks

Reputation effects are current as of the 2026-05-01 campaign consequence slice. They are deliberately smaller than Stronghold upgrades because they can be unlocked through event choices and should make prior decisions visible without becoming a diplomacy system.

| Faction rank | Threshold | Implemented effect | Balance intent |
| --- | ---: | --- | --- |
| Common Folk Friendly | >= 25 | Marcher Camp services cost 10% fewer resources. | Makes generous caravan play visible in town preparation without creating free services. |
| Free Marches Friendly | >= 25 | Stronghold upgrades cost 10% fewer Crowns. | Rewards local legitimacy with a small persistent-upgrade discount, while Stone/Iron/Aether gates remain intact. |
| Old Faith Friendly | >= 25 | Chapel choices with Aether rewards grant +5 Aether. | Makes chapel trust matter on the support route without adding revival or stronger blessing logic. |
| Ashen Covenant Hostile | <= -50 | Ashen Covenant battles start with one extra Raider. | Lets openly antagonizing Ashen forces create visible pressure while staying below a full difficulty bump. |

Honored and Disliked ranks currently display in UI but do not add extra effects. That is intentional; future effects should stay sparse and easy to preview. Choice cards now show the resulting reputation value and rank, such as `+8 Common Folk (to +33 Friendly)`, so threshold progress is visible without adding a diplomacy screen.

## Item Affixes V1

Affixes are current as of the randomized item affix V1 slice. Their job is to make item instances feel a little less static without letting loot replace battle execution, army composition, or campaign preparation.

Generation rules:

| Item rarity | Affix count |
| --- | ---: |
| Common | 0-1 |
| Uncommon | 1 |
| Rare | 1-2 |
| Epic | 2 |
| Legendary | 2-3 |

Initial affixes:

| Affix | Allowed slots | Effect | Balance intent |
| --- | --- | --- | --- |
| Sturdy | Armor, Trinket | +14 HP | Small survivability bump without replacing armor items. |
| Sharp | Weapon | +2 damage | Makes weapon drops feel meaningfully sharper but below a full rarity jump. |
| Guarding | Armor, Trinket | +1 armor | Readable defense bump that stacks modestly with item base armor. |
| Aether-Touched | Weapon, Armor, Trinket | +12 Mana | Supports ability use without matching larger class/origin mana swings. |
| Commanding | Weapon, Armor, Trinket | +1 Command | Supports Warlord/army routes without changing unit data. |
| Faithful | Weapon, Armor, Trinket | +1 Faith | Supports Shepherd and Chapel-flavored rewards. |
| Swift | Weapon, Armor, Trinket | +3 speed | Small movement feel bonus; deliberately below map/pathing significance. |
| Embered | Weapon, Trinket | +1 damage, +1 Arcana | Ashen/magic flavor without adding burn procs to equipment yet. |
| Ranger's | Weapon | +16 range | Ranged identity hook; still modest next to base weapon ranges. |

Deterministic tests use weighted slot-filtered affix selection so item reward e2e can assert exact UI text. Normal play uses the same weights with randomness, and unknown/invalid saved affix IDs are ignored by stat application.

## Unit Veterancy V1

Unit Veterancy is current as of the 2026-05-02 runtime-veterancy slice. It should make ordinary troops feel more personal during a battle and feed the compact Retinue Camp layer without persisting every normal unit.

XP sources:

| Source | XP rule | Balance intent |
| --- | ---: | --- |
| Damage dealt | 1 XP per 4 actual damage, minimum 1 for positive damage | Rewards participation without making chip damage explosive. |
| Kill | Target XP value | Lets finishing blows matter and reuses existing unit/building XP values. |
| Survival on victory | 12 XP | Highlights surviving units in Results without save persistence. |

Ranks:

| Rank | XP threshold | Bonus |
| --- | ---: | --- |
| Recruit | 0 | No bonus. |
| Seasoned | 55 | +4% max HP, +4% damage. |
| Veteran | 130 | +8% max HP, +8% damage. |
| Elite | 230 | +12% max HP, +12% damage, +1 armor. |

Battle-runtime intent:

- Rank bonuses apply immediately to player non-hero units only.
- Enemy unit ranks are intentionally unused for V1, though the rank data can support them later.
- Selected-unit UI shows rank, unit XP, kills, HP, damage, range, and armor.
- Rank-up feedback uses the existing floating/status message path.
- Victory Results show ranked-up units, the top surviving unit, kills, damage dealt, and campaign-retinue recruitment for eligible campaign victories.
- Save persistence is intentionally selective: only player-chosen retinue units are written to the campaign save.

Tuning watchpoints:

- If ranks still happen too often in normal early battles, raise Seasoned in another 10 XP step before changing retinue capacity.
- If ranks are invisible, lower survival XP only after checking that kill XP is credited correctly.
- Do not widen this into automatic whole-army persistence; the retinue cap and permanent-death rule are the pressure valves.

## Retinue Camp V1

Retinue Camp is current as of the 2026-05-02 persistent-retinue slice. It is a small bridge between battle-local veterancy and campaign identity, not an army roster manager.

Rules:

| Rule | Current value | Balance intent |
| --- | ---: | --- |
| Base capacity | 2 active units | Lets a few favorites matter without replacing normal battle production. |
| Training Yard II capacity | +1 active unit | Gives the drill path a light identity payoff without adding more free bodies. |
| Eligibility | Surviving player non-hero units, Seasoned or better | Prevents buildings, heroes, enemies, and disposable recruits from filling the camp by default. |
| Deployment | Campaign battles only | Keeps skirmish setup clean and avoids surprising power in standalone battles. |
| Death rule | Permanent removal after the battle | Simpler and clearer than wounded timers for V1. |

Telemetry read:

- Retinue profiles are modeled as no retinue, one Veteran Militia, one Veteran Ranger, mixed Veteran Militia plus Seasoned Ranger, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II.
- Retinue helps Ashen Outpost in the deterministic suite: single-veteran profiles move Ashen to 2 wins / 1 non-win, while mixed and combined paths sweep Ashen but stay flagged as `needs_human_review` rather than structural `too_easy`.
- No-retinue Ashen Outpost remains beatable by Safe Beginner, so retinue is useful but not required by the structural bot.
- The simulator now respects the same retinue capacity as campaign launch: 2 active units by default, +1 only after Training Yard II is purchased.
- No structural too-easy nodes appear in the full simulator output after retinue and combined Stronghold profiles are included.

Tuning watchpoints:

- If early nodes feel trivial with a single Veteran Militia, keep tuning XP thresholds before cutting the retinue cap.
- If Ashen Outpost feels mandatory with retinue, review whether the issue is mixed-retinue starting body count before changing map structure.
- Do not add replacement UI, wounded timers, unit equipment, crafting, or broader barracks management until the basic retinue loop has been human-played.

## Stronghold Development

Stronghold costs and effects are current as of the 2026-05-01 feature slice. These are intentionally modest because the campaign resource bank already feeds Marcher Camp services and event choices. The Tier I balance response below supersedes the older simulator read where Watch Post I and Quartermaster Stores I did not improve deterministic outcomes.

| Upgrade | Cost | Current implemented effect |
| --- | --- | --- |
| Training Yard I | 80 Crowns, 35 Iron | Future battles start with +1 Militia near the Command Hall. |
| Training Yard II | 70 Crowns, 35 Iron; requires Training Yard I | Militia and Rangers train 10% faster in future battles, and Retinue capacity increases by +1. |
| Watch Post I | 70 Crowns, 45 Stone | First enemy wave warning arrives 25s earlier, player buildings reveal +80 more vision radius, and player Watchtowers gain +10% attack range. |
| Watch Post II | 95 Crowns, 55 Stone, 25 Aether; requires Watch Post I | First enemy wave warning arrives 15s earlier on top of Watch Post I, and player Watchtowers reach +20% total attack range. |
| Quartermaster Stores I | 85 Crowns, 50 Stone | Future battles start with +60 Crowns, +40 Stone, +20 Iron, and +10 Aether; the first player building completes 10% faster. |
| Quartermaster Stores II | 105 Crowns, 55 Stone, 35 Iron; requires Quartermaster Stores I | Future battles start with an additional +80 Crowns, +50 Stone, +35 Iron, and +20 Aether. |
| Chapel Corner I | 75 Crowns, 25 Aether | The hero starts future battles with +5% maximum HP and Mana. |
| Chapel Corner II | 95 Crowns, 45 Aether; requires Chapel Corner I | The hero starts future battles with +8% maximum HP and Mana total. |
| Ranger Paths I | 90 Crowns, 40 Iron; requires Training Yard I | Rangers train 10% faster in future battles. |
| Ranger Paths II | 75 Crowns, 35 Iron; requires Ranger Paths I | Future battles start with +1 Ranger near the Command Hall. |

Balance intent:

- Training Yard I is an early safety valve, not a replacement for building production.
- Training Yard II improves production tempo and adds one Retinue capacity slot instead of adding more free starting bodies.
- Watch Post I supports fog readability, earlier attack awareness, and defensive tower reach without changing enemy attack timing.
- Watch Post II doubles down on warning and tower reach, but still does not delay or weaken enemy attacks.
- Quartermaster Stores I accelerates the first build/train sequence slightly without increasing campaign-bank rewards.
- Quartermaster Stores II is the clearest Tier II economy route; its extra Iron/Aether is moderate and front-loaded only into battle starts.
- Chapel Corner I is deliberately smaller than the Marcher Camp Well Rested next-battle modifier because it is permanent.
- Chapel Corner II stays a simple +8% total HP/Mana bonus rather than introducing revival or death-prevention logic.
- Ranger Paths I now supports Ranger-focused production instead of adding a second free starting unit on top of Training Yard I.
- Ranger Paths II adds a single starting Ranger only after the player has already paid into Training Yard I and Ranger Paths I.
- Human review should watch whether players can buy too many Stronghold upgrades before Ashen Outpost after normal Marcher Camp spending.

Automated Stronghold simulator read:

- The deterministic simulator now runs No Stronghold upgrades, Training Yard path, Defensive Watch Post path, Economy Quartermaster path, Tier II Quartermaster path, Chapel Corner path, Ranger Paths path, one Veteran Militia, one Veteran Ranger, mixed retinue, mixed retinue plus Training Yard II, and mixed retinue plus Quartermaster II across Border Village, Old Stone Road, Aether Well Ruins, Bandit Hillfort, and Ashen Outpost.
- The simulated campaign bank compares no-upgrade, Tier I Quartermaster, and Tier II Quartermaster paths directly. Tier II Quartermaster becomes affordable before Ashen Outpost on the default reward route.
- Training Yard I remains useful in the structural bot: it changes the Ashen Outpost profile from 1 win / 2 non-wins to 2 wins / 1 non-win, with the Fast Army script converting from timeout to victory.
- Watch Post I's weak version was only +80 player-building vision. That was useful to humans in fog but did not move the deterministic scripts. The current Tier I effect makes its value visible through first-wave warning timing, building vision, and player Watchtower reach.
- Watch Post I now improves 9 runs through earlier first-wave warning telemetry while preserving the same 9-3-3 profile record.
- Quartermaster Stores I's weak version was +50 Crowns and +30 Stone. That mostly became floated resources instead of changing the first build order. The current Tier I effect adds a broader resource package plus a small first-building construction boost.
- Quartermaster Stores I now improves 6 runs through earlier Barracks/first-unit timing while preserving the same 9-3-3 profile record.
- Chapel Corner I improves 1 run through the permanent hero durability/mana profile and stays intentionally modest at 9-2-4.
- Ranger Paths I plus Training Yard I improves 2 runs, matches Training Yard's 10-3-2 profile record, and avoids the earlier extra-Ranger overpowered read that made Ashen Outpost too easy.
- No Stronghold path triggers too-expensive, useless-upgrade, overpowered, `too_easy`, or structural `too_hard` warnings after this pass.

### Stronghold Development Tier II - 2026-05-02 Recheck

The Tier II layer remains intentionally small: five upgrades and one matching prerequisite each. Training Yard II uses 10% Militia/Ranger training speed plus one Retinue capacity slot instead of adding another free squad. Watch Post II stacks more warning and total Watchtower reach onto Watch Post I. Quartermaster Stores II expands the starter bundle with Iron and Aether but does not change campaign income. Chapel Corner II stays a simple +8% HP/Mana blessing. Ranger Paths II adds one starting Ranger only after the player has already bought the scout path.

This keeps Tier II useful for route expression without adding workers, enemy construction, diplomacy, new maps, randomized affixes, or a large tech tree.

### Stronghold Tier I Telemetry Response - 2026-05-01

| Upgrade | Old effect | New effect | Reason | Expected effect | Telemetry after change |
| --- | --- | --- | --- | --- | --- |
| Training Yard I | +1 starting Militia. | Unchanged; copy tightened to `+1 Militia`. | It already improved Ashen Outpost without trivializing the suite. | Preserve the Ashen Fast Army timeout-to-victory improvement. | Training Yard path remains 10-3-2 with 2 improved runs and no warnings. |
| Watch Post I | +80 player-building vision. | +80 player-building vision, first enemy wave warning 25s earlier, +10% player Watchtower range. | Pure vision was readable to humans but invisible to deterministic outcome scoring. | Make defensive awareness measurable while keeping attack timing unchanged. | Defensive Watch Post path is 9-3-3 with 9 improved warning/readability runs and no warnings. |
| Quartermaster Stores I | +50 Crowns, +30 Stone. | +60 Crowns, +40 Stone, +20 Iron, +10 Aether, and first player building construction 10% faster. | The old bundle mostly increased floated resources and did not move build-order timing. | Let the first Barracks/unit timing improve without granting a free army. | Economy Quartermaster path is 9-3-3 with 6 improved timing runs and no warnings. |
| Chapel Corner I | +5% hero maximum HP. | +5% hero maximum HP and Mana. | The upgrade needed to match the intended chapel fantasy and visible hero stat copy. | Small permanent hero durability/casting support, weaker than one-battle Well Rested. | Chapel Corner path is 9-2-4 with 1 improved run and no warnings. |
| Ranger Paths I | +1 starting Ranger, 90 Crowns/45 Iron. | Rangers train 10% faster, 90 Crowns/40 Iron. | A full Ranger profile showed that Training Yard plus a free Ranger could make Ashen Outpost too easy. | Reward Ranger production without stacking too many free starting bodies. | Ranger Paths path is 10-3-2 with 2 improved runs, no too-easy node, and no warnings. |

## First Claim Opening Readability - 2026-04-30

Source: Browser Use visible playtest after the opening squad-selection polish.

- Moved the `sunken_road_pack` neutral camp from `(710, 1110)` to `(650, 1240)`.
- Reason: the first tutorial instruction asks the player to right-click the Crown Shrine with the starting squad. With the full squad selected, the old camp position could pull neutral creatures into the capture beat before the player had built production.
- Intended result: Crown Shrine remains a clean first capture lesson; the Sunken Road Pack remains visible as an optional nearby risk after the player understands capture and construction.
- Added a content-data guard so the first Crown Shrine stays farther from the Sunken Road Pack than capture radius plus normal aggro and opening formation spacing.
- No enemy attack timing, resources, reward tables, unit stats, or campaign economy values changed in this pass.

## Telemetry Follow-Up - 2026-04-27

Source: `npm run playtest:sim` after aligning the automated driver with the live enemy AI config.

Key fix before tuning: `EnemyAIController` and `ScriptedBattlePlaytest` now both use map-level `scenario.enemyAI` for initial attack delay, attack interval, wave size, training cadence, expansion cadence, and unit plan. Before this fix, several map-level timing changes were real data but were not fully represented in live attacks or automated telemetry.

Telemetry read after this pass:

- Border Village: 3 wins / 0 losses. First contact moved later and Barracks timing is fair again.
- Old Stone Road: 3 wins / 0 losses. Raider Rush still pressures, but at least two scripts complete Barracks before contact.
- Aether Well Ruins: 1 win / 2 non-wins. Safe Beginner wins; Greedy and Fast remain deliberate risk openings.
- Bandit Hillfort: 1 win / 2 losses. Safe Beginner wins; Greedy Economy and Fast Army remain a known human-review risk.
- Ashen Outpost: 1 win / 2 timeouts. Safe Beginner now wins after capturing Burned Shrine; Greedy and Fast Army still fail to finish.

### Applied Follow-Up Changes

| Area | Before | After | Telemetry reason |
| --- | --- | --- | --- |
| Live enemy AI timing source | Difficulty defaults for attack/train/expand pacing | Map `scenario.enemyAI` after personality modifiers | Map tuning and telemetry were diverging; balance numbers must drive the actual runtime. |
| Playtest enemy AI timing source | Difficulty defaults for attack/train/expand pacing | Map `scenario.enemyAI` after personality modifiers | Keeps automated telemetry aligned with live battles. |
| First Claim train interval | 5.4s | 5.6s | Config alignment moved Easy pressure earlier than intended; the opener needed a little more room. |
| First Claim initial attack | 180s | 210s | Restores fair Barracks-before-contact timing on Border Village and Old Stone Road. |
| First Claim attack interval | 62s | 68s | Reduces repeated Easy pressure while preserving Raider Rush identity. |
| First Claim wave target | 7 | 6 | Prevents Easy follow-up waves from reading like Normal pressure after config alignment. |
| Fortress Keeper commander join | 0.95x | 1.05x | Keeps commander-backed hillfort waves from spiking as early. |
| Fortress Keeper assault cap | 7 units, up to 2 Brutes | 5 units, up to 1 Brute | Safe Beginner already wins; this trims late attrition while preserving the defensive identity. |
| Fortress Keeper defense radius / squad / reserve | 1.28x radius, +2 squad, 2 reserve | 1.18x radius, +1 squad, 1 reserve | Reduces sticky late defensive pull that was overwhelming non-safe scripts. |
| Hexfire train interval multiplier | 0.95x | 1.00x | Slows repeated caster replacement without changing opening warning timing. |
| Hexfire assault cap | 6 units | 5 units | Ashen and Aether failures were sustained-pressure failures after first-wave survival. |
| Ashen player starting bank | 520/360/210/120 | 560/390/235/140 | Gives the milestone a little more staging economy. |
| Ashen starting army | 3 Militia, 1 Ranger | 4 Militia, 2 Rangers | Safe Beginner needed enough force to turn a correct staged opening into a win. |
| Ashen enemy watchtowers | 2 | 1 | The shrine-side tower made the Burned Shrine approach read as a trap rather than a staging objective. |
| Ashen enemy income per tick | 88/44/42/34 | 80/40/38/30 | Reduces fortress wave replacement after first-wave survival. |
| Ashen map train interval | 6.2s | 7.0s | Slows enemy rebuild during the milestone fight. |
| Ashen map attack interval | 68s | 78s | Gives more rebuild time after each survived wave. |
| Ashen wave target | 8, then 7 | 6 | Keeps Hexfire pressure present without turning every later wave into an army wipe. |
| Ashen defense squad / radius | 8 and 560, then 6 and 500 | 5 and 460 | Makes the fortress defend itself without pulling the entire map into every approach. |
| Ashen simulator fortress approach | Flat Ashen fortress bonus | Lower bonus after Burned Shrine capture | Models the map objective as a real staged approach advantage for telemetry. |
| Ashen live Burned Shrine effect | Objective completion only | Capturing Burned Shrine deals 45% max-HP damage to the gate Watchtower without destroying it | Aligns live play with telemetry: the staged route should visibly soften the fortress approach. |

Telemetry report refinement after this pass:

- `PLAYTEST_TELEMETRY.md` now separates structural `too_hard` failures from `needs_human_review` strategy-spread cases.
- No current campaign battle node reports `too_hard`: first attack timing is fair across all five nodes, and Barracks timing is not the remaining problem.
- Aether Well Ruins, Bandit Hillfort, and Ashen Outpost now report `needs_human_review`: Safe Beginner wins while riskier scripts fail or time out.
- Greedy and Fast Army timing on Normal should be judged by intended design: if those scripts should be viable on milestone maps, tune final-assault attrition or route rewards; if they are supposed to be punished, leave them as risk reads.
- Ashen Outpost defeat tips now point failed players toward Burned Shrine, Enemy Barracks, and Outpost Captain sequencing before falling back to generic opening advice.

## Telemetry-Based Balance Pass - 2026-04-26

Source: `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json` generated by `npm run playtest:sim`.

Telemetry read before this pass:

- Border Village: 3 wins / 0 losses. Easy is forgiving and the first attack is fair.
- Old Stone Road: 3 wins / 0 losses. Raider Rush is readable, though broad openings still win.
- Aether Well Ruins: 1 win / 2 losses. First wave is survivable, but Normal attrition was too abrupt.
- Bandit Hillfort: 1 win / 2 losses. Fortress pressure is survivable early but over-punishes non-safe scripts.
- Ashen Outpost: 0 wins / 3 losses. Barracks and first unit timing are fine, but the fortress remains structurally unbeaten.

Telemetry read after this pass:

- Border Village and Old Stone Road stayed unchanged at 3 wins / 0 losses.
- Aether Well Ruins improved from `too_hard` to `reasonable` in the simulator.
- Bandit Hillfort remains `too_hard`: Safe Beginner wins, Greedy Economy and Fast Army still lose.
- Ashen Outpost remains `too_hard` and not beatable by the scripted suite.
- First enemy contact remains fair on all five battle nodes, and Barracks completes before first pressure on the relevant scripts.

### Applied Timing And AI Changes

| Area | Before | After | Telemetry reason |
| --- | --- | --- | --- |
| Normal enemy income | 0.86x | 0.82x | Normal losses came after surviving the first wave, so pressure needed less snowball without delaying the first lesson. |
| Normal first attack | 195s | 195s | First contact was already fair on all Normal nodes. |
| Normal attack interval | 66s | 72s | Gives more recovery time between the first survived wave and the later attrition waves. |
| Normal attack wave target | 6 | 5 | Lowers follow-up wave ceiling without changing Easy. |
| Normal train interval | 5.8s | 6.2s | Slows enemy reserve rebuild after waves are launched. |
| Normal commander join | 570s | 630s | Keeps commander-backed waves from arriving as abruptly during the first Normal branch and Ashen midpoint. |
| Hexfire Cult income | 1.02x | 0.98x | Aether Well and Ashen both failed through sustained caster pressure, not first-contact unfairness. |
| Hexfire commander multiplier | 0.92x | 1.00x | Prevents the commander from joining caster waves too early on Ashen. |
| Hexfire pressure wave cap | 5 units, up to 3 Hexers | 4 units, up to 2 Hexers | Telemetry showed the first wave survived, but repeated Hexer waves caused late collapse. |
| Hexfire assault wave cap | 8 units, up to 3 Hexers and 2 Brutes | 6 units, up to 2 Hexers and 1 Brute | Keeps caster identity while reducing late-wave wipe pressure. |
| Fortress Keeper income | 1.02x | 0.94x | Bandit Hillfort still beat non-safe scripts through attrition after the first wave. |
| Fortress Keeper train interval multiplier | 1.02x | 1.25x | Reduces reserve rebuild and follow-up pressure. |
| Fortress Keeper wave size multiplier | 1.08x | 1.00x | Keeps the defensive identity from becoming raw wave-size advantage. |
| Fortress Keeper pressure cap | 5 units, up to 2 Brutes | 4 units, up to 1 Brute | Telemetry showed pressure-wave attrition, not an opening timing failure. |
| Fortress Keeper assault cap | 9 units, up to 3 Brutes | 7 units, up to 2 Brutes | Preserves the late fortress threat while trimming endless collapse waves. |
| Ashen player starting bank | 460 Crowns / 320 Stone / 180 Iron / 95 Aether | 520 Crowns / 360 Stone / 210 Iron / 120 Aether | Ashen scripts had enough timing but not enough structural force for a fortress assault. |
| Ashen enemy starting bank | 280 Crowns / 220 Stone / 160 Iron / 125 Aether | 240 Crowns / 190 Stone / 135 Iron / 105 Aether | Reduces initial snowball on the milestone map. |
| Ashen enemy income per tick | 100/50/50/40 | 88/44/42/34 | Reduces repeated fortress pressure while keeping map identity. |
| Ashen map train interval | 5.2s | 6.2s | Slows runtime enemy replacement on the fortress map. |
| Ashen map attack interval | 60s | 68s | Gives more rebuild time between milestone waves. |

### Applied Campaign Economy And Reward Changes

| Area | Before | After | Telemetry reason |
| --- | --- | --- | --- |
| Hire Volunteers | 55 Crowns | 50 Crowns | Normal failures make the extra Militia a useful prep option rather than a premium luxury. |
| Buy Supplies | 45 Crowns for 30 Stone, 18 Iron, 8 Aether | 40 Crowns for 30 Stone, 18 Iron, 10 Aether | Makes supplies a clearer bridge from Easy rewards into Chapel and item costs. |
| Marcher Plate | 80 Crowns, 18 Iron | 75 Crowns, 15 Iron | Border Village plus Old Stone Road telemetry leaves 15 Iron, so the first armor purchase should be reachable. |
| Green Chapel Icon | 90 Crowns, 18 Aether | 85 Crowns, 16 Aether | Makes the trinket less likely to miss the first branch economy by a tiny amount. |
| Well Rested | +15% hero max HP | +20% hero max HP | Normal losses are attrition losses after surviving first contact, so HP support should matter. |
| Blessed Road | +10% hero max mana | +15% hero max mana | Makes the Chapel blessing more relevant before the milestone. |
| Local Support | +10% next node resource reward | +15% next node resource reward | Makes Chapel repair more useful as Ashen preparation. |
| Aether Well Ruins node reward | 70 XP, 35 Stone, 55 Aether | 80 XP, 45 Stone, 65 Aether | The first Normal branch needs to better fund recovery after a hard win. |
| Bandit Hillfort node reward | 70 XP, 75 Crowns, 25 Stone, 50 Iron | 80 XP, 85 Crowns, 35 Stone, 60 Iron | Fortress branch remains hard, so the win should clearly prep Ashen. |
| Pray for Strength | 35 XP, 15 Aether | 40 XP, 20 Aether | Makes the low-cost Chapel option more legible. |
| Repair the Chapel | 50 Crowns, 60 Stone | 45 Crowns, 55 Stone | Keeps repair viable after branch rewards and supports Ashen prep. |
| Protect Them | 45 Crowns, 35 XP | 40 Crowns, 40 XP | Makes the generous caravan line less punishing when Normal is already demanding. |
| Recruit Volunteers | 20 Crowns, 25 Iron | 15 Crowns, 30 Iron | Makes the pragmatic line a clearer army-prep choice. |
| Chapel guidance text | Warned about Hexers massing | Warns that Ashen needs a staged army, not an early probe | Matches telemetry: Ashen failures are attack-strength failures, not Barracks timing failures. |

Historical telemetry risks from this 2026-04-26 pass, superseded by the 2026-05-01 checkpoint baseline above:

- At that time, Bandit Hillfort still reported `too_hard`; the safe opening won, but Greedy Economy and Fast Army failed after survived waves.
- At that time, Ashen Outpost still reported `too_hard` and the older simulator could not beat it.
- Ashen needs a later pass on fortress assault structure if the design goal is for the scripted suite to beat it without human control.
- No further Easy tuning is recommended from this telemetry.

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
| Normal difficulty | 0.90x enemy income, first attack 180s, 62s attack interval, 7-unit wave target, 5.4s train interval, commander 540s | 0.82x enemy income, first attack 195s, 72s attack interval, 5-unit wave target, 6.2s train interval, commander 630s | Keeps Normal dangerous after the opening while reducing the first branch spike and later telemetry attrition. |
| Raider Rush personality | 0.80x first attack, 0.82x attack interval, 0.78x expansion interval, 0.92x income | 0.86x first attack, 0.88x attack interval, 0.82x expansion interval, 0.88x income | Preserves early pressure but makes Old Stone Road feel like a readable lesson instead of a surprise check. |
| Fortress Keeper personality | 1.05x income, 1.12x wave size | 0.94x income, 1.00x wave size, slower training, lower Brute caps | Keeps the hillfort defensive identity while trimming the raw late-wave spike. |
| Hexfire Cult personality | 1.05x first attack and interval, 1.08x income | 1.08x first attack and interval, 0.98x income, lower Hexer and assault caps | Makes caster pressure distinct through composition, not simply a stronger economy. |

### Campaign Economy And Reward Changes

| Node or Table | Before | After | Reason |
| --- | --- | --- | --- |
| Old Stone Road node reward | 45 XP, 50 Crowns, 40 Stone | 50 XP, 60 Crowns, 45 Stone, 15 Iron | Makes the second Easy battle pay enough to make Marcher Camp choices understandable. |
| Well Rested | +10% next-battle hero max HP for 35 Crowns | +20% next-battle hero max HP for 30 Crowns | Gives the first rest service an immediately legible defensive benefit. |
| Hire Volunteers | 50 Crowns | 50 Crowns | Keeps the extra starting Militia useful as a prep option after telemetry showed Normal attrition. |
| Buy Supplies | 40 Crowns for 30 Stone, 14 Iron, 6 Aether | 40 Crowns for 30 Stone, 18 Iron, 10 Aether | Makes the conversion feel worthwhile for later repairs/items without becoming a power buy. |
| Marcher Plate purchase | 85 Crowns, 20 Iron | 75 Crowns, 15 Iron | Makes the first armor purchase reachable after early battles. |
| Green Chapel Icon purchase | 100 Crowns, 20 Aether | 85 Crowns, 16 Aether | Keeps the trinket expensive but less likely to be impossible after normal spending. |
| Aether Well Ruins node reward | 60 XP, 50 Aether, Aether Lens | 80 XP, 45 Stone, 65 Aether, Aether Lens | Gives the first Normal caster branch both progression and repair-relevant resources. |
| Bandit Hillfort node reward | 65 XP, 70 Crowns, 45 Iron, Captain's Seal | 80 XP, 85 Crowns, 35 Stone, 60 Iron, Captain's Seal | Makes the fortress branch a stronger prep route toward Ashen Outpost. |
| Chapel repair | 55 Crowns, 65 Stone for 35 Aether, Green Chapel Icon, Local Support, recovery | 45 Crowns, 55 Stone for the same reward | Makes the support/preparation choice viable after reasonable early spending. |
| Chapel guidance text | Warned about Ashen Outpost but read like a normal completion choice | Explicitly scouts without closing the chapel and warns against early fortress probes | Reduces confusion and supports planning before the milestone fight. |
| Protect Them caravan choice | 30 Crowns, 10 Iron for 30 XP, Scout's Bow, +6 Common Folk, +2 Free Marches | 40 Crowns for 40 XP, Scout's Bow, +8 Common Folk, +2 Free Marches | Makes the generous choice costly in Crowns but not punishing to Iron progression. |
| Recruit Volunteers caravan choice | Level 2 requirement, no cost, 25 XP, 30 Iron, Marcher Plate, Inspired Militia, -2 Common Folk | Level 2 requirement, 15 Crowns, 25 XP, 30 Iron, Marcher Plate, Inspired Militia, -4 Common Folk | Makes it a distinct pragmatic choice rather than a nearly free item/resource bundle. |
| Demand Tribute caravan choice | 80 Crowns, Angered Raiders, -8 Common Folk, -2 Free Marches, -3 Ashen Covenant | 65 Crowns with the same consequences | Keeps the selfish option tempting but not the obvious best economy line. |
| Ashen Outpost starting banks | Player 440/300/165/95, enemy 300/220/175/140 | Player 520/360/210/120, enemy 240/190/135/105 | Lets the player stage a fortress assault while reducing enemy snowball. |
| Ashen Outpost enemy income | 105 Crowns, 52 Stone, 52 Iron, 42 Aether every 5s | 88 Crowns, 44 Stone, 42 Iron, 34 Aether every 5s | Keeps pressure steady but lowers attrition from repeated fortress waves. |
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
- Ashen Outpost is the current mini-campaign milestone map at 2600x1800. It gives the player a stronger starting economy, four Militia, and two Rangers, while the enemy fortress keeps one gate Watchtower, tighter upper-right terrain, Hexfire Cult pressure, and a central Burned Shrine that now weakens the gate Watchtower as the safe staged approach. The enemy's starting bank and income are intentionally below the first fortress draft so the challenge comes from position, tower cover, and wave composition rather than raw economy alone.
- Difficulty still controls broad enemy income and commander timing, while map-level `scenario.enemyAI` now controls live attack delay, attack interval, wave target, training cadence, expansion cadence, and unit plan after personality modifiers.

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

Reward tables now use weighted pools, fixed rewards, resource payouts, XP payouts, first-clear bonuses, and repeat-clear rewards. Deterministic item order remains available for tests. Each item reward creates an inventory instance so affixes and provenance can attach to individual copies.

Current reward pacing:

- First Claim grants one weighted item roll, modest resources, 35 base victory XP, and a first-clear bonus of 40 XP plus starter resources. Its weighted pool now leans slightly toward starter/common gear and away from early rare trinkets.
- Broken Ford grants one weighted item roll, stronger resource payouts, 55 base victory XP, and a first-clear Fordbreaker Halberd plus 65 bonus XP. Its weighted pool gives a small bump to branch-defining trinkets and rare/epic excitement.
- Ashen Outpost grants one weighted item roll, high milestone resources, 85 base victory XP, and a first-clear Ashbound Censer plus 95 bonus XP. The Ashen Outpost campaign node also grants a larger campaign-bank payout and an Oathbound Aegis for the milestone clear, so the weighted pool favors Starfall Prism slightly more than a duplicate Aegis.
- Weighted item rolls prefer unowned catalog items when possible. Non-unique duplicate rewards remain separate instances. Unique duplicate rewards convert into campaign resources: common/uncommon items convert to Crowns, while rare/epic/legendary items convert to Aether.

## Campaign Resource Spending

Marcher Camp is the first campaign-bank sink and unlocks after Old Stone Road. It is intentionally small: one town node, repeatable services, and three one-time item purchases.

Current Marcher Camp costs:

- Rest and Recovery: 30 Crowns for Well Rested, a next-battle +20% hero maximum HP modifier.
- Hire Volunteers: 50 Crowns for Inspired Militia, a next-battle extra Militia.
- Buy Supplies: 40 Crowns for 30 Stone, 18 Iron, and 10 Aether.
- Emberglass Wand: 60 Crowns, one-time common weapon purchase.
- Marcher Plate: 75 Crowns and 15 Iron, one-time uncommon armor purchase.
- Green Chapel Icon: 85 Crowns and 16 Aether, one-time trinket purchase.

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
- Normal: 2 Raiders, 1 Hexer, commander at base, 0.82x income, first attack at 3:15, 72s interval, phase-capped 5-unit waves, commander after 10:30, fog enabled.
- Hard: Raiders, Hexer, Brute, commander, 1.15x income, first attack at 2:30, 48s interval, larger waves, commander after 8:00, fog enabled.

AI personalities live in `src/game/data/aiPersonalities.ts` and modify the base difficulty/map pacing:

- Balanced Warlord: 1.0x baseline timing, mixed Raider/Hexer/Brute training, default for Border Village.
- Raider Rush: 0.86x first-attack delay, 0.88x attack interval, 0.82x expansion interval, 0.88x income, mostly Raiders and Hexers, smaller late waves.
- Fortress Keeper: 1.22x first-attack delay, 1.18x attack interval, 0.94x income, slower training, larger defense radius, defensive reserves, Brute-heavy late waves.
- Hexfire Cult: 1.08x first-attack delay and attack interval, 0.98x income, more Hexers, dangerous caster bursts with fewer melee bodies.

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
- Mid waves, 5:00 to 8:00: 3 to 4 mixed Raiders, Hexers, and occasional Brutes on the current Normal branch personalities.
- Late waves, 8:00 onward: Brute and Hexer support, with commander participation after about 10:30 baseline.

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
