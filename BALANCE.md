# Balance Notes

These numbers are prototype values. They are designed for readability and fast testing, not final balance.

## Current First-Campaign Baseline - 2026-05-04 Chapter 2 Reward Economy Audit

The values in this section are the current first-campaign balance baseline. Older dated sections below explain how they changed, but should not be read as newer than this checkpoint.

- Latest simulator verdict: `npm run playtest:sim` passes with 255 deterministic runs across 85 campaign battle node/profile summaries. This includes the current Chapter 2 scenarios `cinderfen_crossing` and `cinderfen_watch` plus one Cinderfen-only Waystation Shrine Attunement profile that applies only when the Cinder Shrine exists; no structural `too_hard` nodes, no structural `too_easy` nodes, no Stronghold warnings, and Ashen Outpost remains beatable by the Safe Beginner script without retinue.
- Latest Chapter 2 reward-economy audit result: Cinderfen first-clear rewards remain unchanged and useful, while Cinderfen repeat clears are no longer item or base-payout farms. `cinderfen_causeway_rewards` and `cinderfen_watchpost_rewards` now make their weighted battle item pools plus base battle XP/resources first-clear-only; repeat clears pay only the explicit repeat bonus, currently 4 XP / 11 resources for Crossing and 3 XP / 8 resources for Watchpost. No Chapter 1 reward, map, unit, faction, or service value changed.
- Current Chapter 2 first-clear chain totals after Cinderfen Overlook, Crossing, Watch, and Aftermath: the two battle/node first clears grant 253 XP and 340 campaign/battle resources before event choices; choosing one normal Overlook preparation and one normal Aftermath resolution brings the gross route to 285-290 XP and 346-360 rewarded resources before Waystation service spending. After event costs, the same normal-choice route nets about 242-306 resources depending on which choices are taken. Malrec trophy-only choices are lower-payout flavor/consequence options and are not reward farms.
- Current Chapter 2 item frequency: the mandatory Cinderfen battle chain grants two first-clear battle item rolls across Crossing and Watch plus the fixed `Scout's Bow` from Cinderfen Crossing. `Study the Cinders` can add Emberglass Wand, and `Study the Ashen Marks` can add Pilgrim Crook, but those event choices complete once and cannot be repeated. Cinderfen repeat clears now grant no battle item roll.
- Latest Chapter 2 event result: `cinderfen_overlook` is a playable preparation gate after `ashen_outpost`. Its three baseline choices spend campaign resources and grant existing rewards/modifiers only: Scout the Causeway costs 30 Crowns for 20 XP, 8 Stone, Free Marches/Common Folk reputation, and Local Support; Aid the Marsh Refugees costs 55 Crowns for 25 XP, 10 Iron, Common Folk/Free Marches reputation, and Inspired Militia; Study the Cinders costs 24 Aether for 20 XP, Emberglass Wand, Old Faith reputation, Ashen Covenant reputation loss, and Blessed Road. If the player earned `trophy_malrec_outpost_standard`, the event also offers Raise Malrec's Standard for no resource cost, 10 XP, +3 Free Marches reputation, and Well Rested.
- Latest Chapter 2 slice result: `cinderfen_crossing` is a Normal Cinderfen Road battle on `cinderfen_causeway`, and `cinderfen_watch` is a second compact Normal Cinderfen Road battle on `cinderfen_watchpost`. Both use existing Ashen Covenant units, the Hexfire Cult AI personality, no named enemy hero, no new unit types, and no enemy construction.
- Latest Chapter 2 aftermath result: `cinderfen_aftermath` is a compact non-battle event after Cinderfen Watch. Secure the Watch Road costs 45 Crowns and 18 Stone for 12 XP, 10 Stone, +4 Free Marches, and Local Support; Aid the Fenfolk costs 40 Crowns for 12 XP, 8 Iron, and +5 Common Folk; Study the Ashen Marks costs 18 Aether for 12 XP, 6 Aether, Pilgrim Crook, +4 Old Faith, and -1 Ashen Covenant. If the player earned `trophy_malrec_outpost_standard`, Display Malrec's Standard offers only +1 Free Marches reputation as a small intimidation/flavor consequence. The node is event-only and excluded from battle simulator profiles.
- Latest Cinderfen tactical identity result: the central `cinder_crossing` site is now the Cinder Shrine. Its first capture by a side grants a one-time `Cinder Shrine Surge` of +20 Aether, then the site behaves like the existing Aether income site. The effect is battle-local, modeled in the simulator, does not persist to campaign resources, and cannot be repeated by recapturing the same shrine with the same team.
- Latest Chapter 2 support result: `cinderfen_waystation` is a compact town/service node after Cinderfen Overlook. Marsh Guides costs 35 Crowns for the next Cinderfen battle's +60 base vision and +20s warning lead; Ash Filters costs 35 Crowns and 15 Aether for +8% hero HP/Mana in the next Cinderfen battle; Refugee Scouts costs 25 Crowns once for 10 XP and +2 Common Folk; Shrine Attunement costs 12 Aether and adds +5 Aether to the next Cinderfen battle's Cinder Shrine Surge. These services are modest campaign-resource sinks, not a broad shop or power spike.
- Latest Enemy Hero / Rival Commander tuning result: no numeric gameplay changes. Old Stone Road remains unassigned; Veyra, Gorak, and Captain Malrec stay on their current HP/damage/ability/XP/map assignments because telemetry shows late, readable pressure without structural unfairness.
- Latest Rival / Nemesis Persistence result: no enemy hero balance numbers changed. Rival state persists, first defeats grant a small one-time reward and trophy record, escaped rivals can return with +5% HP, triumphant rivals can return with +5% damage, and the simulator records before/outcome/after/reward/trophy fields without creating structural `too_easy` or `too_hard` nodes.
- Latest Rival Rewards balance result: no XP/resource/item reward values changed. Telemetry shows one-time reward/trophy grants only on winning commander defeats, no baseline duplicate grants, no structural reward snowball, and no active rematch modifier runs in the first-encounter suite; UI/report copy now labels those rewards as one-time.
- Current starting battle resources: 380 Crowns, 255 Stone, 140 Iron, 75 Aether.
- Current First Claim site income: Crown Shrine +30 Crowns/5s, Stone Quarry +25 Stone/5s, Iron Vein +20 Iron/5s, Aether Well +15 Aether/5s.
- Current Broken Ford site income: Ford Toll +34 Crowns/5s, West Stone Cut +22 Stone/6s, South Iron Cache +18 Iron/6s, North Aether Spring +14 Aether/6s.
- Current Ashen Outpost site income: Burned Shrine +26 Aether/5s, West Supply Pyre +30 Crowns/6s, South Iron Pit +22 Iron/6s, North Stone Scar +26 Stone/6s.
- Current Cinderfen Causeway site income: Causeway Toll +30 Crowns/5s, Reedcut Quarry +22 Stone/6s, Sunken Iron Cache +18 Iron/6s, Cinder Shrine +16 Aether/6s plus a one-time +20 Aether first-capture surge. Shrine Attunement can raise that one next-Cinderfen-battle surge to +25 Aether.
- Current Cinderfen Watchpost site income: Watch Road Toll +28 Crowns/5s, Blackreed Stonecut +20 Stone/6s, Ash Cistern +14 Aether/6s. There is no Cinder Shrine on Watchpost, so Shrine Attunement is not consumed by that battle.
- Current broad difficulty pacing baseline: Story is the learning/testing lane with no fog, Easy is for tutorial battles with survivable pressure, and Normal is the first real baseline once build/train/rally is understood.
- Current Stronghold Development is a small persistent campaign-resource sink with five Tier I upgrades and five compact Tier II follow-ups. Purchased upgrades apply only to later battle launches and do not alter the current battle retroactively.
- Current reputation hooks are intentionally modest: Friendly starts at +25, Honored at +50, Disliked at -25, and Hostile at -50. Reputation effects adjust preparation costs/rewards or add one minor Ashen pressure unit; they do not create diplomacy, new factions, or alternate maps.
- Current item affixes are V1 only: small stat packages rolled onto reward-generated item instances, visible in Results/Inventory, and applied only while the item instance is equipped. They do not add crafting, durability, item art, affix rerolls, or proc-heavy loot complexity.
- Current Unit Veterancy and Retinue Camp are V1 only: ordinary player units can rank up inside a battle, campaign victories can save a small number of surviving Seasoned+ units, and campaign launches redeploy saved retinue units without adding a large army-management layer.
- Current Enemy Hero / Rival Commander V1 is data-driven and compact: named Ashen commanders replace the existing `enemy_commander` slot on assigned campaign nodes, stay gated by commander join timing, grant XP/objective/results credit, and expose simulator telemetry. They do not add enemy construction, workers, new factions, diplomacy, or raid-boss tuning.
- Current Rival / Nemesis Persistence V1 and Rival Rewards and Trophies V1 are intentionally small: campaign saves remember rival outcomes, disposition, and earned trophies; Campaign Map displays Rival Intel and Rival Trophies; Results reports rival consequences and first-defeat rewards; battle launch can apply only +5% HP or +5% damage in a later encounter.

| Difficulty | Enemy income | First attack | Attack interval | Wave target | Train interval | Commander timing |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Story | 0.45x | 300s | 100s | 2 | 9.0s | 840s |
| Easy | 0.65x | 240s | 82s | 3 | 7.0s | 750s |
| Normal | 0.82x | 195s | 72s | 5 | 6.2s | 630s |

- Current map-level pacing is authoritative where present: First Claim currently uses the softened Easy opener from the telemetry follow-up, Ashen Outpost currently uses the reduced fortress economy, Cinderfen Causeway uses a constrained player start, lower capture income, three neutral camps, four capture sites, a static enemy staging tower, a one-time Cinder Shrine Aether surge, optional Waystation preparation modifiers, and slightly faster Ashen staging production. Cinderfen Watchpost uses 500 / 335 / 205 / 115 player resources, 280 / 210 / 155 / 110 enemy resources, 80 / 40 / 36 / 30 enemy income, 6.4s enemy training, 195s first attack delay, 74s attack interval, a 6-unit wave target, and a 4-unit base defense squad.
- Current human-review focus: Aether Well Ruins, Bandit Hillfort, Ashen Outpost, Cinderfen Crossing, and Cinderfen Watch with Retinue + Training Yard II need feel/readability review before more numeric tuning.
- Current Stronghold tuning focus: Tier I has readable value in telemetry without an overpowered warning, while Tier II stays optional and route-specific. Watch Post I/II improve warning/readability telemetry, Quartermaster Stores I/II improve build-order resources, Chapel Corner I/II add modest hero durability, and Ranger Paths II adds one starting Ranger only after the scout path is already purchased.

## Telemetry-Based Chapter 2 Balance Pass - 2026-05-03

Source: `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json` generated by `npm run playtest:sim` after the Cinderfen event/battle slice.

Telemetry read before tuning:

- Cinderfen Crossing is structurally reasonable at 26 wins / 0 defeats / 13 timeouts across the current 219-run simulator scope. Safe Beginner wins consistently, Greedy Economy mostly times out, and Fast Army still often ends before the first enemy wave matters.
- First enemy contact was fair, around 4:15-4:16 on average, with Safe Beginner and Greedy Economy completing Barracks before pressure in all Cinderfen runs.
- Barracks remained useful in every script, Mystic Lodge showed up in Safe Beginner and Greedy Economy, and Watchtower mostly helped the Safe Beginner route. Fast Army still acted as the rush pressure read.
- Retinue impact was visible but not automatically structural: Veteran Militia and mixed retinue sped up Cinderfen, Veteran Ranger slowed Fast Army into a timeout, and Retinue + Training Yard II swept Cinderfen at 3 wins / 0 defeats / 0 timeouts.
- Stronghold Tier II impact stayed below an automated warning: Retinue + Quartermaster II remained 2 wins / 0 defeats / 1 timeout on Cinderfen, while Retinue + Training Yard II is the stronger human-review profile.
- Rival state impact on the Cinderfen Crossing battle remains none in the simulator: the current node has no named rival and 0 Cinderfen simulator runs applied rival persistence modifiers. The live campaign event can now react to Malrec's existing trophy with one optional Well Rested choice, but that choice completes the event and cannot stack with the three baseline preparations.
- Reward strength was useful but high enough to trim because the fastest wins could collect the first-clear package quickly. The pass reduces the Cinderfen first-clear total from 145 XP / 205 resources to 125 XP / 170 resources before event rewards, while keeping one battle item roll and Scout's Bow.
- Chapter 2 event choices were useful but too generous relative to Marcher Camp services. The pass raises costs and trims XP/resources while keeping each choice's identity: intel/resources, one-battle extra Militia, or Old Faith item/blessing.
- Chapter 1 remains unchanged: the pass edits only Cinderfen map data, Cinderfen node/reward data, and Cinderfen-specific defeat copy.

Tuning applied:

| Knob | Before | After | Reason |
| --- | --- | --- | --- |
| Cinderfen player starting bank | 500 / 340 / 205 / 120 | 480 / 325 / 195 / 110 | Keeps Chapter 2 better supplied than early Chapter 1 while reducing rush and float headroom. |
| Cinderfen enemy starting bank | 230 / 180 / 125 / 90 | 250 / 195 / 140 / 100 | Gives the Ashen staging camp slightly more ability to absorb fast attacks without adding units. |
| Cinderfen enemy income per tick | 78 / 38 / 34 / 28 | 80 / 40 / 36 / 30 | Keeps late pressure present after lower player site income. |
| Cinderfen enemy train interval | 6.8s | 6.4s | Lets the existing Barracks matter more against rush paths without changing wave rules. |
| Cinderfen capture site income | 32 Crowns, 24 Stone, 20 Iron, 18 Aether | 30 Crowns, 22 Stone, 18 Iron, 16 Aether | Reduces excessive floating and farm pressure while preserving useful route rewards. |
| Cinderfen battle first-clear reward | 75 XP, 35 / 25 / 20 / 15 resources | 65 XP, 30 / 20 / 16 / 12 resources | Keeps a meaningful battle payoff below the Ashen milestone and below Chapter 1 branch spikes. |
| Cinderfen campaign node reward | 70 XP, 45 / 25 / 25 / 15 resources | 60 XP, 40 / 20 / 20 / 12 resources | Reduces first-clear power spike while preserving Scout's Bow. |
| Cinderfen repeat reward | 40 XP, 26 / 12 / 14 / 10 resources plus item roll | 34 XP, 22 / 10 / 11 / 8 resources plus item roll | Makes repeat clears less attractive as a resource farm. |
| Scout the Causeway | 25 Crowns for 25 XP, 10 Stone, Local Support | 30 Crowns for 20 XP, 8 Stone, Local Support | Keeps the intel/prep choice useful without making it a cheap resource exchange. |
| Aid the Marsh Refugees | 40 Crowns for 35 XP, 15 Iron, Inspired Militia, +8 Common Folk | 55 Crowns for 25 XP, 10 Iron, Inspired Militia, +6 Common Folk | Prices the extra-Militia battle impact closer to Marcher Camp's volunteer service. |
| Study the Cinders | 18 Aether for 30 XP, Emberglass Wand, Blessed Road, +6 Old Faith | 24 Aether for 20 XP, Emberglass Wand, Blessed Road, +5 Old Faith | Keeps the item/blessing identity while reducing the Aether-to-item bargain. |
| Cinder Shrine Surge | +24 battle-local Aether on first capture | +20 battle-local Aether on first capture | Keeps the Cinderfen tactical feature visible while trimming a frequently claimed tempo prize that Fast Army does not rely on. |
| Cinderfen defeat tips | Generic or Ashen-only objective tips | Cinderfen route tips for side income, Cinder Guardians, and Enemy Barracks | Improves readability without changing combat systems. |

Telemetry read after tuning:

- Cinderfen Crossing remains structurally reasonable with no structural `too_easy` or `too_hard` flag.
- Safe Beginner still wins 12/12 and keeps fair first contact around 4:16, so there is no difficulty cliff after Chapter 1.
- Greedy Economy remains mostly timeout-prone, which preserves the map's staging lesson.
- Fast Army remains the rush/readability watchpoint, but the reduced reward totals keep its quick wins from becoming a large power spike.
- Cinderfen Watchpost, added after the support-node checkpoint, is structurally reasonable at 25 wins / 0 defeats / 11 timeouts across 36 runs. It sits just below Cinderfen Crossing's 26 wins and above Ashen Outpost's 22 wins, with average first enemy contact around 3:57.
- Post-feature Cinder Shrine impact is modest: 26/39 Cinderfen simulator runs captured it and received a one-time battle-local surge, with two Waystation-attuned captures at +25 Aether instead of +20. The post-Waystation/Watchpost pass left enemy pacing, wave size, AI income/training, starting resources, capture-site income, event rewards, Cinder Shrine strength, and Malrec's event-only Well Rested consequence unchanged. It only lowered Shrine Attunement to 12 Aether and trimmed Watchpost reward values because the risk was service value and fast-clear farming, not a structural difficulty cliff.
- Chapter 1 node records remain stable because no Chapter 1 values changed in this pass.

## Second Chapter 2 Battle Balance Read - 2026-05-03

Source: `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json` generated after adding `cinderfen_watch`.

- `cinderfen_watch` launches `cinderfen_watchpost`, a compact raised-road battle with three capture sites, two neutral camps, one central Watchtower objective, and no Cinder Shrine.
- Current record: 25 wins / 0 defeats / 11 timeouts across 36 Watchpost runs, with no structural `too_easy` or `too_hard` flags.
- Script read: Safe Beginner 12 wins / 0 defeats / 0 timeouts; Greedy Economy 3 wins / 0 defeats / 9 timeouts; Fast Army 10 wins / 0 defeats / 2 timeouts.
- First enemy contact averages about 3:57, earlier than Crossing. The simulator still marks first attack timing fair, but human play should verify the Watch Road Toll and tower threat are readable.
- Watchpost rewards are modest after the compact reward pass: full first clear grants 128 XP, 170 total campaign/battle resources, and one existing weighted item roll with affixes. There is no rival trophy-level reward.
- Shrine Attunement is intentionally not consumed on Watchpost because the map has no `cinder_crossing` shrine site.
- Chapter 1 values and telemetry remain unchanged by this addition.

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

Conservative telemetry pass, 2026-05-02:

| Knob | Before | After | Reason |
| --- | --- | --- | --- |
| Retinue capacity | 2 active units by default, +1 from Training Yard II | Unchanged | Single veterans help without becoming mandatory; mixed profiles are strong but still human-review, not structural `too_easy`. |
| Unit XP thresholds | Seasoned 55, Veteran 130, Elite 230 | Unchanged | Telemetry does not show rank-up frequency creating structural early-node trivialization. |
| Rank stat bonuses | +4% / +8% / +12% HP and damage | Unchanged | The softened bonuses make saved units satisfying while one-Veteran profiles remain optional. |
| Elite armor bonus | +1 armor at Elite only | Unchanged | No evidence that Elite armor is common enough or strong enough to drive the Ashen result. |
| Retinue eligibility | Surviving player non-hero units, Seasoned or better | Unchanged | Already blocks recruits, buildings, heroes, and enemies from filling the camp by default. |
| Death/removal rule | Permanent removal after the battle | Unchanged | This remains the clearest V1 pressure valve against retinue becoming a mandatory permanent army. |
| Training Yard II interaction | +1 retinue capacity after purchase | Unchanged | Route-specific payoff is strong with mixed retinue, but no structural too-easy node appears. |
| Quartermaster II interaction | Starter resource package only; no retinue capacity bonus | Unchanged | The mixed-retinue Quartermaster profile is strong, but telemetry flags it for human review rather than a numeric nerf. |
| Ashen Outpost outcome | No-retinue 1-0-2, one Veteran 2-0-1, mixed/combined 3-0-0 `needs_human_review` | Unchanged | Ashen remains beatable without retinue and notably helped by retinue; human-paced review should judge whether the sweep feels trivial before tuning numbers. |

Result: no gameplay balance values changed in this pass. Retinue and Unit Veterancy stay useful but not required by the structural bot.

Tuning watchpoints:

- If early nodes feel trivial with a single Veteran Militia, keep tuning XP thresholds before cutting the retinue cap.
- If Ashen Outpost feels mandatory with retinue, review whether the issue is mixed-retinue starting body count before changing map structure.
- Do not add replacement UI, wounded timers, unit equipment, crafting, or broader barracks management until the basic retinue loop has been human-played.

## Enemy Hero / Rival Commander V1

Enemy Hero V1 is current as of the 2026-05-02 rival-commander slice. It gives important Ashen battles a named RPG threat without changing the overall army-management or AI-construction model.

Definitions:

| Enemy hero | Campaign node | Role | Ability package | Balance intent |
| --- | --- | --- | --- | --- |
| Gorak Emberhand, Ashen Raider Captain | Bandit Hillfort | Aggressive melee commander | Ember Strike, Rally Raiders | Stronger than a normal Raider/Brute mix, but still gated by fortress pacing and late commander attacks. |
| Veyra of the Cinders, Hexfire Seer | Aether Well Ruins | Ranged magic commander | Hexfire Bolt, Rally Raiders | Punishes exposed troops around the ford without becoming a raid boss. |
| Captain Malrec, Outpost Commander | Ashen Outpost | Fortress commander | Hold the Line, Rally Raiders, Ember Strike | Makes the milestone fortress feel led by a character and satisfies the commander objective. |

Rules:

| Rule | Current value | Balance intent |
| --- | --- | --- |
| Spawn model | Campaign node `enemyHeroId` upgrades the existing `enemy_commander` spawn for that battle. | Reuses current commander slot, objectives, AI pacing, and difficulty filters. |
| Early rush prevention | Commander still follows existing commander join phase and delay: Normal commander timing is 630s before attack-wave participation. | Rivals can defend when attacked but should not suicide into the player at minute 1. |
| Ability scale | Cooldown-based direct damage, short burn, small damage rally, or short armor aura. | Readable pressure that makes the commander memorable without replacing army fights. |
| Defeat rewards | Uses the enemy hero's unit XP value and normal kill/objective paths. | Defeating a rival should feel rewarding without adding a separate reward layer. |
| Ashen objective | Ashen Outpost now names the commander objective `Defeat Captain Malrec`. | Keeps the old objective structure but gives it character identity. |

Telemetry read:

- `npm run playtest:sim` now writes `enemyHeroId`, `enemyHeroDefeated`, `timeEnemyHeroJoinedAttack`, and `lossesInvolvingEnemyHero` into `PLAYTEST_TELEMETRY.json` and the Markdown scenario table.
- Latest 180-run output still reports `too_easy: none`, `too_hard: none`, Ashen Outpost beatable `yes`, and Stronghold warnings `none`.
- Latest hero-specific simulator read: Veyra appears in 36 runs, is defeated in 24, joins attacks in 17, and is involved in 12 player losses; Gorak appears in 36 runs, is defeated in 13, joins attacks in 12, and is involved in 12 losses; Captain Malrec appears in 36 runs, is defeated in 36, joins attacks in 14, and is involved in 14 losses.
- Commander join timing appears late in non-winning or slow scripts, while safe winning routes often defeat the rival during the final base assault before a commander wave leaves the base.
- Human review should watch whether Captain Malrec's Hold the Line aura reads clearly near the fortress and whether Veyra's ranged pressure feels fair in fog.

Telemetry-based enemy hero tuning pass, 2026-05-02:

| Knob | Before | After | Reason |
| --- | --- | --- | --- |
| Old Stone Road assignment | No enemy hero | Unchanged | 36/36 Old Stone Road simulations already win on the Easy lane; adding Gorak here would create early commander noise before mid-campaign. |
| Aether Well Ruins assignment | Veyra of the Cinders | Unchanged | Veyra is relevant but not structurally unfair: Safe Beginner wins, joins happen around 10:31-10:32, and losses concentrate in greedy/fast scripts. |
| Bandit Hillfort assignment | Gorak Emberhand | Unchanged | Gorak creates identity and pressure at 11:40-11:41 in slow Greedy Economy runs without an early rush; Safe Beginner still wins. |
| Ashen Outpost assignment | Captain Malrec | Unchanged | Malrec is defeated in all simulated runs, but Ashen still has no-retinue and Stronghold-path timeouts, so the milestone remains intact. |
| Enemy hero HP/damage | Gorak 235 HP / 17 damage, Veyra 180 HP / 12 damage, Malrec 265 HP / 16 damage | Unchanged | No structural too-hard or too-easy node isolates HP/damage as a problem. |
| Ability cooldowns/ranges | Ember Strike 10s/48, Rally Raiders 18s/210, Hexfire Bolt 8s/185, Hold the Line 20s/230 | Unchanged | Abilities provide readable identity; losses involving enemy heroes stay late and one-unit-scale in telemetry. |
| Join-attack timing | Existing commander phase and Normal 630s commander delay | Unchanged | First commander attack joins are around 10:31 for Veyra, 11:40 for Gorak, and 10:41 for Malrec, so no minute-1 unfair rush appears. |
| XP reward/objective reward | Current unit XP values; Ashen uses existing `defeat_unit` objective credit | Unchanged | Defeat payoff is visible without adding a separate reward layer; no objective reward inflation is needed. |
| Retinue/Stronghold interaction | Retinue and Stronghold paths can help Ashen; mixed retinue sweeps are human-review | Unchanged | The strong Ashen outcomes are not isolated to enemy hero stats, so changing rival numbers would be premature. |

Result: no enemy hero gameplay values changed in this pass. Keep the current commanders and focus human playtests on visibility, ability readability, and whether mixed retinue makes Malrec feel too easy before changing numbers.

## Rival / Nemesis Persistence V1

Rival persistence is current as of the 2026-05-02 nemesis slice. It makes named enemy commanders remember campaign outcomes without turning them into scaling raid bosses.

Rules:

| Outcome | Saved result | Disposition | Current consequence | Balance intent |
| --- | --- | --- | --- | --- |
| Player wins and defeats rival | `defeated` | First defeat `humiliated`, later defeats `enraged` | First defeat grants a data-driven XP/resource/reputation/item reward plus a trophy once; no combat buff remains active. | Makes the first commander takedown feel meaningful without creating repeat-farm loot. |
| Player wins and rival survives | `escaped` | `wary` | Next encounter with that rival gets +5% HP. | Creates a visible rematch note while staying below a full difficulty bump. |
| Player loses | `triumphant` | `emboldened` | Next encounter with that rival gets +5% damage. | Lets losses matter without changing map assignments or enemy economy. |

Telemetry read:

- The 180-run scripted suite still reports `too_easy: none`, `too_hard: none`, Stronghold warnings `none`, and Ashen Outpost beatable `yes`.
- The simulator currently treats each commander battle as a first encounter, so `rivalStateBefore` is Unseen/Wary and `rivalModifiersApplied` is empty in baseline runs.
- Safe Beginner victories produce `rivalOutcome: defeated` on commander nodes; timeouts/defeats produce `rivalOutcome: triumphant` for persistence telemetry.
- Current rival outcome counts across 108 commander-node runs: 46 winning commander defeats, 0 escaped-rival victories, and 38 non-winning runs with rival pressure. Veyra produces 12 wins / 12 defeats / 12 timeouts, Gorak 12 / 23 / 1, and Malrec 22 / 0 / 14.
- Rival Rewards and Trophies V1 telemetry now records `rivalFirstDefeatRewardEarned`, `rivalDuplicateRewardPrevented`, and `rivalTrophyEarned`. Baseline first-encounter wins earn the trophy once (46 total first-reward/trophy grants), while repeat live defeats are blocked by save-backed trophy records and covered by unit/e2e tests rather than the first-encounter simulator path.
- No structural result changed after adding persistence fields and live launch modifiers. Keep +5% HP/damage as the ceiling until human playtests confirm rematches feel too flat.

Telemetry-based rival persistence balance pass, 2026-05-02:

| Knob | Before | After | Reason |
| --- | --- | --- | --- |
| Rival modifier strength | Escaped +5% HP, triumphant +5% damage | Unchanged | Baseline suite has 0 active rematch modifier runs and no structural too-hard nodes; keep the current tiny ceiling until a future rematch-profile pass or human play shows the modifiers are unfair or invisible. |
| First-defeat XP/resources | Gorak +80 XP/+25 Crowns/+15 Iron; Veyra +90 XP/+20 Aether; Malrec +140 XP/+60 Crowns/+25 Iron | Unchanged | Rewards are one-time, post-battle, and do not change the current fight. Telemetry shows no structural reward snowball; reduce XP/resources only if later campaign play shows these first defeats becoming mandatory. |
| First-defeat items/trophies | One themed item and one trophy per rival | Unchanged | The item/trophy payoff is the main RPG satisfaction beat. Duplicate prevention is save-backed, so repeats cannot farm the item or trophy. |
| Escape condition | Victory with enemy hero surviving | Unchanged | Current deterministic victories defeat the commander before the Stronghold falls, so no escapes are observed. Changing the condition now would be speculative. |
| Copy/readability | First-defeat reward copy was present but could read like a repeatable payout | Tightened | Results, Rival Intel, trophy effect copy, and telemetry now call the reward one-time and clarify that V1 rematch modifiers are only +5% HP/damage. |
| Telemetry warning threshold | Structural too-hard/easy plus reward/trophy fields | Unchanged structurally, clearer report | The report now summarizes reward grants, duplicate-prevention observations, modifier-run count, and per-rival pressure so future snowball signals are easier to spot without adding new gameplay. |
| Retinue interaction | Mixed retinue and combined paths remain human-review, especially Ashen | Unchanged | Strong Ashen outcomes come from retinue/Stronghold profiles, not a rival reward or modifier signal. |
| Stronghold Tier II interaction | Quartermaster II and Training Yard II remain optional path boosts | Unchanged | No Stronghold warnings appear and no rival modifier runs are active; changing rival rewards to compensate for Stronghold would be premature. |
| Captain Malrec / Ashen Outpost | Malrec defeated in all 36 Ashen commander runs; Ashen still has no-retinue and Stronghold-path timeouts | Unchanged | Malrec is a milestone reward/completion beat, while mixed-retinue Ashen sweeps remain human-review rather than structural `too_easy`. |

Result: no gameplay balance values changed in this pass. Rival persistence remains dramatic through saved outcomes, one-time trophies, and tiny rematch modifiers without creating a structural snowball in the automated suite.

First-defeat rewards:

| Rival | First-defeat reward | Trophy | Balance intent |
| --- | --- | --- | --- |
| Gorak Emberhand | One-time +80 XP, +25 Crowns, +15 Iron, Ember Raider Blade, +2 Free Marches reputation | Gorak's Emberbrand | Makes Bandit Hillfort feel like a raider-camp victory without adding a farmable Iron source. |
| Veyra of the Cinders | One-time +90 XP, +20 Aether, Cinder-Seer Lens, +1 Old Faith reputation | Cinder-Seer's Cracked Lens | Gives Aether Well Ruins a magic-flavored payoff without adding spellcraft, crafting, or repeat Aether farming. |
| Captain Malrec | One-time +140 XP, +60 Crowns, +25 Iron, Malrec's Bastion Sigil, +4 Free Marches reputation | Malrec's Outpost Standard | Makes Ashen Outpost feel like a milestone while keeping the reward one-time and post-battle only. |

Tuning watchpoints:

- If escaped-rival rematches feel invisible, improve warning/UI copy before increasing the HP modifier.
- If triumphant-rival rematches feel punitive, reduce or remove the +5% damage modifier before changing base enemy hero stats.
- If first-defeat rewards make a later campaign route feel mandatory, reduce reward XP/resources before changing rival combat stats or retinue rules.
- Do not add rival leveling trees, new maps, procedural rematches, capture/recruit outcomes, workers, enemy construction, or new factions through this layer.

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
- Ashen Outpost defeat tips now point failed players toward Burned Shrine, Enemy Barracks, and Captain Malrec sequencing before falling back to generic opening advice.

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

Cinderfen Causeway:

- Causeway Toll: +30 Crowns every 5 seconds.
- Reedcut Quarry: +22 Stone every 6 seconds.
- Sunken Iron Cache: +18 Iron every 6 seconds.
- Cinder Shrine: +16 Aether every 6 seconds, plus `Cinder Shrine Surge` for +20 Aether the first time a team captures it in that battle.

## Map Notes

- First Claim is the balanced tutorial skirmish. Its first Crown site is close, the side camps are readable, and the direct lane keeps the first attack easy to understand.
- Broken Ford is wider at 2600x1700 and has more blocked terrain. The center pays better but is guarded and exposed, while side resources are safer but slower.
- Ashen Outpost is the current mini-campaign milestone map at 2600x1800. It gives the player a stronger starting economy, four Militia, and two Rangers, while the enemy fortress keeps one gate Watchtower, tighter upper-right terrain, Hexfire Cult pressure, and a central Burned Shrine that now weakens the gate Watchtower as the safe staged approach. The enemy's starting bank and income are intentionally below the first fortress draft so the challenge comes from position, tower cover, and wave composition rather than raw economy alone.
- Cinderfen Causeway is the first Chapter 2 map at 2600x1700. It gives the player a constrained southwest start, a diagonal burned-road approach, four slightly trimmed capture sites, three neutral camps, a central contested Cinder Shrine with a one-time +20 Aether surge on first capture, and a safer northern Stone route. The enemy base uses existing Ashen structures, a single prebuilt Watchtower, a modestly stronger starting bank, and faster staging-camp training so the first Chapter 2 assault asks for staging without exceeding Ashen Outpost.
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
- Cinderfen Causeway grants one first-clear-only weighted affix-capable item roll, 30 first-clear-only base victory XP/resources, and a modest first-clear battle bonus of 35 XP plus 14 Crowns, 10 Stone, 8 Iron, and 6 Aether. The `cinderfen_crossing` campaign node separately grants 60 XP, 40 Crowns, 20 Stone, 20 Iron, 12 Aether, and `Scout's Bow`, keeping the first Chapter 2 payoff useful at 125 XP / 170 resources while repeat clears fall to 4 XP / 11 resources and no battle item roll.
- Cinderfen Watchpost grants one first-clear-only weighted affix-capable item roll and a modest first-clear battle reward of 66 XP plus 34 Crowns, 20 Stone, 16 Iron, and 10 Aether. The `cinderfen_watch` campaign node separately grants 62 XP, 40 Crowns, 22 Stone, 18 Iron, and 10 Aether, keeping the second Chapter 2 first-clear read at 128 XP / 170 resources without a trophy-level reward while repeat clears fall to 3 XP / 8 resources and no battle item roll.
- Cinderfen Aftermath adds one modest post-Watch event payout. It is intentionally smaller than a battle reward and cannot be repeated because each choice completes the node and records a once-only choice claim.
- The Cinder Shrine's +20 Aether surge is battle-only tactical tempo, not a Results reward or campaign-bank payout. It is intentionally smaller than several seconds of normal site income and cannot be farmed through repeated recapture by the same team.
- Weighted item rolls prefer unowned catalog items when possible. Non-unique duplicate rewards remain separate instances. Unique duplicate rewards convert into campaign resources: common/uncommon items convert to Crowns, while rare/epic/legendary items convert to Aether.

## Campaign Resource Spending

Marcher Camp is the first campaign-bank sink and unlocks after Old Stone Road. It is intentionally small: one town node, repeatable services, and three one-time item purchases.

Current Marcher Camp costs:

- Rest and Recovery: 30 Crowns for Well Rested, a next-battle +20% hero maximum HP modifier.
- Hire Volunteers: 50 Crowns for Inspired Militia, a next-battle extra Militia.
- Buy Supplies: 40 Crowns for 30 Stone, 18 Iron, and 10 Aether.

Cinderfen Overlook event costs:

- Scout the Causeway: 30 Crowns for Local Support, 20 XP, 8 Stone, +3 Free Marches reputation, and +1 Common Folk reputation.
- Aid the Marsh Refugees: 55 Crowns for Inspired Militia, 25 XP, 10 Iron, +6 Common Folk reputation, and +2 Free Marches reputation.
- Study the Cinders: 24 Aether for Blessed Road, 20 XP, Emberglass Wand, +5 Old Faith reputation, and -2 Ashen Covenant reputation.
- Raise Malrec's Standard: requires `trophy_malrec_outpost_standard`, costs no resources, grants Well Rested, 10 XP, and +3 Free Marches reputation. It completes Cinderfen Overlook, so it replaces the other preparation choices rather than stacking with them.

Cinderfen Waystation service costs:

- Marsh Guides: 35 Crowns for Marsh Guides, a next-Cinderfen-battle modifier that adds +60 player-building vision and +20 seconds of enemy warning lead.
- Ash Filters: 35 Crowns and 15 Aether for Ash Filters, a next-Cinderfen-battle +8% hero maximum HP and Mana modifier.
- Refugee Scouts: 25 Crowns, one-time, for 10 XP and +2 Common Folk reputation. It previews the Cinder Shrine / central guardian route through service copy rather than adding a reveal system.
- Shrine Attunement: 12 Aether for Shrine Attunement, a next-Cinderfen-battle modifier that increases the Cinder Shrine Surge from +20 Aether to +25 Aether on first player capture.
- Emberglass Wand: 60 Crowns, one-time common weapon purchase.
- Marcher Plate: 75 Crowns and 15 Iron, one-time uncommon armor purchase.
- Green Chapel Icon: 85 Crowns and 16 Aether, one-time trinket purchase.

The 2026-05-04 reward-economy audit left Waystation service costs unchanged. Telemetry shows Shrine Attunement at 2 wins / 0 defeats / 1 timeout in its small profile, and the other services are sinks rather than payout multipliers.

Cinderfen Aftermath event costs:

- Secure the Watch Road: 45 Crowns and 18 Stone for Local Support, 12 XP, 10 Stone, and +4 Free Marches reputation. It is a resource sink plus route-consequence choice; Local Support can help a future resource-reward node but does not currently add a battle simulator profile.
- Aid the Fenfolk: 40 Crowns for 12 XP, 8 Iron, and +5 Common Folk reputation.
- Study the Ashen Marks: 18 Aether for 12 XP, 6 Aether, Pilgrim Crook, +4 Old Faith reputation, and -1 Ashen Covenant reputation.
- Display Malrec's Standard: requires `trophy_malrec_outpost_standard`, costs no resources, grants only +1 Free Marches reputation, and completes the node.

These costs are tuned so Border Village plus Old Stone Road rewards let the player buy one or two meaningful services or an early item immediately, but not clear the whole stock. Cinderfen Aftermath spends some of the Watchpost first-clear bank back down without adding a large power spike. Future economy passes should add more sinks before raising reward payouts.

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
- Cinderfen Crossing: Hexfire Cult on Normal using the dedicated Cinderfen Causeway ash-marsh map.

Ashen Outpost special objectives:

- Primary: destroy the Ashen Stronghold.
- Secondary: capture the Burned Shrine.
- Secondary: destroy the Enemy Barracks.
- Secondary: defeat Captain Malrec.

Cinderfen Crossing special objectives:

- Primary: destroy the Ashen Stronghold.
- Secondary: claim the Cinder Shrine, triggering the one-time Cinder Shrine Surge if it has not already been claimed by the player's side.
- Secondary: clear the central Cinder Guardians camp by defeating its Brute anchor.
- Secondary: destroy the Enemy Barracks.

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
