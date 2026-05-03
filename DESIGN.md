# Ascendant Realms Design

## 1. Game Vision

Ascendant Realms is a fantasy RTS/RPG hybrid about a persistent hero becoming a legendary warlord through tactical battles, faction alliances, captured sites, items, and campaign consequences.

The first goal is not content volume. The first goal is a clean engine foundation that can grow without rewriting the whole project.

## 2. Long-Term Winning Formula

Ascendant Realms should become bigger and better than classic RTS/RPG hybrids by protecting four pillars throughout development.

1. Persistent hero fantasy.
The hero must feel personal. Race, class, origin, items, scars, titles, retinue, reputation, and choices should all matter over time.

2. Faction asymmetry.
Factions must not be palette swaps. Each faction needs a different economy, combat rhythm, army identity, building pattern, and strategic weakness.

3. Living campaign map.
The campaign map is the main chance to surpass older RTS games. The world should react through alliances, betrayals, invasions, shops, temples, ruins, mercenary contracts, holy orders, cursed lands, ancient monsters, and regional consequences.

4. Data-driven and mod-friendly content.
New factions, units, buildings, spells, items, campaign nodes, and quests should mostly come from data files and art assets. Engine rewrites should be rare.

The first versions are allowed to look ugly. They are not allowed to become rigid. The goal is a working, expandable fantasy RTS/RPG skeleton that can grow phase by phase.

## 3. Core Loop

Create a hero, enter a battle, capture resources, build an army, defeat enemies, earn XP, collect item rewards, claim compact rival trophies, spend skill points, equip gear, spend campaign resources on persistent preparation, save progress, and return stronger for the next battle.

## 4. Battle Loop

The prototype battle starts with a hero, a Command Hall, and a few soldiers. The player explores, uses the live minimap to read the battlefield, captures resource sites, places production structures, protects them while they automatically construct, trains units, researches small upgrades, fights neutral camps and enemy waves, then destroys the enemy stronghold.

Unit movement now uses a simple grid-based pathfinding layer inside the existing movement system. Commands still set move targets as before, but units calculate coarse A* paths around blocked terrain, water, and live building footprints, then follow waypoints with local same-team separation to reduce stacking. If the pathfinder cannot reach the exact target, units try to move as close as possible and player commands show a brief warning.

Battles use a lightweight grid fog model with three states: unseen, explored, and visible. Friendly units and buildings reveal nearby cells from data-defined `visionRadius` values. Unseen cells are heavily covered, explored cells remain dim, and visible cells are clear. Enemy and neutral units/buildings are only rendered when currently visible. Capture sites become visible after discovery; their ownership is currently shown as live global state once discovered to keep the prototype readable.

## 5. Campaign Loop

The campaign begins as a small node-based Border Marches map. The hero selects available nodes, launches battles through the shared battle request path, resolves simple event choices, changes faction reputation, spends resources at the Marcher Camp town node or Stronghold panel, completes nodes, claims one-time rewards, adds campaign resource rewards to a persistent bank, saves progress, and unlocks the next branch.

Named enemy commanders now persist as lightweight rivals. The campaign save tracks known rivals, encounters, defeats, victories against the player, last outcome, disposition, small active modifiers, and first-defeat trophy records. The Campaign Map shows Rival Intel, earned Rival Trophies, and node previews for known commanders, while battle launch can apply tiny next-encounter effects such as +5% HP after an escape or +5% damage after a rival victory.

Long term, the campaign map should grow into the living heart of the game: quests, shops, faction reputation, strongholds, random events, persistent rewards, invasions, alliances, and regional consequences.

## 6. Hero Design

Heroes are RPG characters first and RTS commanders second. The prototype supports class, origin, level, XP, mana, stats, skill points, three skill trees, class ability unlocks, inventory, and weapon/armor/trinket equipment.

The current skill trees are:

- Combat: personal damage, HP, and Warlord front-line unlocks.
- Magic: mana, armor, Arcanist spell unlocks, and Shepherd sanctified magic.
- Leadership: command, faith, army support, and support unlocks.

Each class has three total abilities in data. The first ability is available at hero creation, while later abilities are unlocked through skill nodes.

Loot should make the hero feel persistent without replacing RTS decision-making. Catalog items are small, readable stat packages with rarity, slot, flavor text, tags, optional class affinity, optional faction origin, and optional uniqueness. Rewards and town purchases create item instances with source history and optional V1 affixes, while equipment references the equipped instance. Rewards are rolled from map-specific weighted tables, with first-clear bonuses to make a new map feel meaningful and repeat-clear rewards to keep skirmishes useful.

Item affixes are intentionally small in V1. Common items can roll zero or one affix, uncommon items roll one, rare items roll one or two, epic items roll two, and legendary items roll two or three. Affixes are slot-filtered stat packages such as Sharp, Sturdy, Guarding, Aether-Touched, Commanding, Faithful, Swift, Embered, and Ranger's. They add visible item-instance flavor and modest stat variation, not crafting depth, durability, art variants, proc chains, or a loot treadmill.

Equipment is allowed to change battle feel through HP, mana, damage, armor, speed, range, primary stats, and attack cadence. It should not become so strong that army composition, expansion, upgrades, and hero ability timing stop mattering.

Post-battle rewards should feel like a compact RPG payoff rather than an accounting screen. The Results screen is the shared victory/defeat handoff: victory shows XP before/after, level-ups, skill points, item rarity, item slot, affixes, stat comparison, Equip Now for the earned instance, inventory confirmation, unique duplicate conversion, campaign node completion rewards, Notable Veterans from surviving battle units, rival outcome/trophy rewards when a commander is defeated, and the campaign bank after resource rewards are added. Defeat shows contextual recovery tips from the actual battle stats.

## 7. Faction Design

The prototype player faction is The Free Marches. Free Marches are the baseline army: balanced economy, reliable infantry and Rangers, defensive Watchtowers, and hero leadership/reputation scaling.

The Ashen Covenant is now the first asymmetric enemy faction rather than a palette swap. Ashen play is aggressive: cheaper early Raiders, higher damage pressure, fragile Hexers, durable Brutes, burn damage from Hexfire, low-health damage spikes through Ashen Fury, and slightly faster attack-wave movement through Smoke March. Their defenses are intentionally weaker than their attack rhythm.

Faction data lives in `src/game/data/factions.ts`. Each faction declares economy, military, and magic style text; available units, buildings, and upgrades; preferred AI personalities; campaign reputation hooks; and data-driven faction modifiers. Runtime support currently covers burn-on-hit, low-health damage, and wave-speed modifiers.

Sylvan Concord remains a future placeholder. It should be the next faction to receive mechanics once Free Marches versus Ashen Covenant is stable.

## 8. Resource Design

Resources are Crowns, Stone, Iron, and Aether. In battle, they are temporary combat economy generated by captured sites instead of worker harvesting. In campaign, the same four resource types also exist as a persistent campaign bank earned from node rewards. Event choices, Marcher Camp services, and Stronghold Development spend that bank now; future shops, mercenaries, repairs, and broader upgrades should use the same spending path.

## 9. Campaign Map Design

Campaign nodes are data-driven. Each node defines an ID, display copy, node type, battle map, difficulty, enemy faction, prerequisites, rewards, unlocks, optional event text, optional choices or town services, and a UI position. Locked, available, completed, claimed reward, claimed choice, town purchase, service use, and campaign resource spending state comes from the save file rather than the node definition.

Event choices, town services, and Stronghold upgrades are intentionally small data objects, not a city-builder or vendor engine. Choices and services can require campaign resources, hero level, completed nodes, owned items, or faction reputation; pay campaign resource costs; grant XP, items, resources, modifiers, reputation, or node unlocks; and either complete the node or keep it open. Town services default to keeping the node open and can be repeatable or once-only purchases. Stronghold upgrades are persistent campaign purchases that apply only to later battle launches.

Reputation now has simple readable ranks across Free Marches, Common Folk, Old Faith, Ashen Covenant, and the Sylvan Concord placeholder: Friendly at +25, Honored at +50, Disliked at -25, and Hostile at -50. Active effects stay small and data-driven: Common Folk Friendly discounts Marcher Camp services, Free Marches Friendly discounts Stronghold Crown costs, Old Faith Friendly improves Chapel Aether rewards, and Ashen Covenant Hostile adds minor Ashen battle pressure. The campaign map shows values, ranks, active effects, and choice previews before the player commits, including the resulting reputation value and rank after each choice.

The first campaign is intentionally small:

- Border Village starts available.
- Old Stone Road unlocks after Border Village.
- Marcher Camp, Aether Well Ruins, and Bandit Hillfort unlock after Old Stone Road.
- Refugee Caravan also unlocks after Old Stone Road as an optional event branch.
- Chapel of the Marches unlocks after Aether Well Ruins.
- Ashen Outpost unlocks after Bandit Hillfort and Chapel of the Marches.

Only battle nodes launch combat. Non-battle nodes either resolve direct rewards, present choices, or present town services in the campaign map. Chapel of the Marches and Refugee Caravan prove the first consequence layer with resource costs, locked choices, reputation shifts, item rewards, and optional node unlocks. Marcher Camp proves the first town sink with repeatable services, one-time item stock, and next-battle modifiers. Stronghold Development proves the first persistent strategic sink, with purchased camp upgrades carried in the campaign save and converted into launch modifiers for future battles.

Stronghold Development currently has two small tiers, not a city-builder. Tier II upgrades require their matching Tier I upgrades and deepen strategy through simple launch effects: faster basic troop training, earlier first-wave warning with better Watchtower reach, a broader starting resource package, a small hero HP/Mana bump, and one extra starting Ranger on the scout path. Tier II uses the same data-driven launch modifier path as Tier I; it does not add workers, enemy construction, diplomacy, new maps, or a large tech tree.

## 10. Skirmish Map Design

Skirmish maps should be data-driven battlefields with distinct roles, not only different spawn coordinates. Each map defines setup metadata, dimensions, starts, decorative paths, terrain zones, capture sites, neutral camps, scenario spawns, objectives, enemy AI defaults, and rewards.

First Claim remains the balanced tutorial skirmish. Broken Ford is the second proof point: a larger ruined river crossing with more blocked terrain, two lanes, safer side resources, and a more dangerous central ford. Future maps should clearly state what decision they test, such as fast expansion, center control, defensive turtling, or multi-front pressure.

## 11. Base-Building Design

Buildings now move through a simple RTS lifecycle:

- Planned: the placement ghost previews the footprint before resources are spent.
- Under construction: the building exists in the world, appears translucent, starts with partial HP, and cannot train, research, or attack.
- Completed: production, upgrades, and defensive attacks become available.

Construction is automatic for now. Workers remain postponed until the game has enough economy and pathing depth to justify them. Placement is constrained to buildable terrain near owned buildings and reports explicit invalid-site reasons.

Training and research queues pay costs immediately. Training can be canceled for a full refund. Completed production buildings can set non-persistent ground rally points so newly trained units automatically move toward the army staging area. Upgrades are data-driven and use the same prerequisite foundation intended for future buildings, units, abilities, and tech.

## 12. Unit Design

Units have HP, damage, range, cooldown, speed, armor, cost, train time, role, and XP value. The first roster is intentionally small: Militia, Ranger, Acolyte, Raider, Hexer, and Brute.

Unit Veterancy V1 gives ordinary player battle units a lightweight runtime progression layer. Units track a battle-local instance ID, unit type, XP, rank, kills, damage dealt, and survival state. They earn small XP from dealing damage, getting kills, and surviving victory. Ranks are Recruit, Seasoned, Veteran, and Elite; bonuses are deliberately modest at +4%, +8%, and +12% HP/damage, with +1 armor at Elite. Rank bonuses apply immediately in battle, selected-unit UI shows rank/XP/kills, rank-up feedback appears in combat, and the Results screen summarizes Notable Veterans.

Retinue Camp V1 is the compact save-backed layer on top of veterancy. After a campaign victory, surviving player-owned non-hero, non-building units that are Seasoned or better can be added from Results. Capacity starts at 2 active units, and Training Yard II raises it to 3. A saved retinue record stores unit type, optional name, rank, XP, kills, source battle, acquired timestamp, and active status. The Campaign Map shows a Retinue Camp section with capacity, saved units, rank/type, and a dismiss action.

Campaign battle launches deploy active retinue units near the hero/Command Hall and reapply their saved rank, XP, kills, and stat bonuses. Skirmish does not deploy retinue by default. V1 uses permanent-loss death handling: if a retinue unit dies in a campaign battle, it is removed from the campaign retinue after the battle rather than entering a wounded/recovery system.

## 13. AI Design

The MVP AI is a simple state machine. It expands to sites, gains income, trains units, defends threatened ground, and sends attack waves. AI personalities now sit on top of the shared pacing model so the same battle map can feel different without rewriting the controller.

Current personalities:

- Balanced Warlord: mixed expansion and attacks, used as the default tutorial baseline.
- Raider Rush: faster early pressure with lighter units, meant to punish greedy expansion but fall off later.
- Fortress Keeper: slower attacks, larger defensive radius, heavier late waves, and protection for enemy-held sites.
- Hexfire Cult: more Hexers and bursty ranged pressure, with a thinner frontline.

Personalities adjust preferred units, training plan, attack and expansion timing, wave caps, defense radius, defensive reserves, capture-site protection, and commander participation timing. They do not yet understand true scouting paths, counter-builds, retreat micro, or rebuilding destroyed production.

Enemy Hero / Rival Commander V1 adds a compact data-driven identity layer to important Ashen battles. Campaign nodes can reference an `enemyHeroId`, and the existing `enemy_commander` spawn becomes the named rival for that launch while preserving the same delayed commander AI behavior. The first rivals are Gorak Emberhand on Bandit Hillfort, Veyra of the Cinders on Aether Well Ruins, and Captain Malrec on Ashen Outpost. They use small ability packages, grant XP when defeated, can complete commander objectives such as Ashen Outpost's Captain Malrec objective, appear in campaign preview/battle start/scout feedback/results, and report telemetry fields in the playtest simulator. V1 does not add enemy construction, workers, new factions, diplomacy, procedural campaign, or raid-boss scale encounters.

Rival / Nemesis Persistence V1 builds on those enemy heroes without adding a new system layer. After a battle, a defeated commander becomes humiliated or enraged, an escaped commander becomes wary, and a commander who beats the player becomes emboldened. Results show the rival outcome and consequence. Rival Rewards and Trophies V1 adds data-driven first-defeat rewards for Gorak, Veyra, and Malrec: a small XP/resource/reputation grant, one themed item where defined, and a save-backed trophy record. Repeat defeats do not duplicate first-defeat rewards. Escapes and rival victories only create small next-encounter stat modifiers. This keeps rival memory visible while avoiding raid-boss escalation, crafting, durability, or a full trophy room.

## 14. Data-Driven Content Philosophy

Units, buildings, abilities, resources, factions, maps, hero classes, origins, skill trees, reward tables, rival reward tables, items, item affixes, campaign nodes, enemy heroes, reputation effects, and Stronghold upgrades live in `src/game/data`. Engine code should read these definitions instead of hard-coding content names and numbers.

Manual art assets live in the manual asset pipeline. The UI art kit is also data-driven: reusable frame, button, divider, slot, minimap, victory, and defeat panel assets are registered in `tools/manual-asset-pipeline/assetRegistry.ts`, discovered through the manifest, and exposed to CSS as optional variables. The game must keep working without those files.

UI-kit art should be edge and slot art, not full UI screenshots. Frames should use transparent centers so live text, numbers, icons, and panels remain readable and scalable.

## 15. What Is Implemented Now

- Phaser/Vite/TypeScript project.
- Menu, hero creation, campaign map, skirmish setup, battle, progression screen, inventory screen, local save.
- Eight-node campaign skeleton with save-backed node unlocks, completion, one-time node rewards, event choices, town services, Stronghold Development, and a persistent campaign resource bank.
- Reputation ranks and small reputation effects for campaign costs, Chapel rewards, and hostile Ashen pressure.
- Data-driven Stronghold upgrades on the campaign map: five Tier I upgrades and five compact Tier II follow-ups, each purchased with campaign resources and each requiring its matching Tier I upgrade.
- RTS selection, movement, capture sites, resource income, combat, projectiles.
- Lightweight fog of war with grid visibility, dim explored areas, hidden enemies outside vision, and minimap masking.
- Three playable skirmish maps: First Claim, Broken Ford, and Ashen Outpost.
- Building placement, automatic construction, unit training, research queues, upgrades, watchtower attacks.
- Live minimap snapshots for units, buildings, capture sites, neutral camps, camera position, and alert pings.
- Data-driven prerequisites for units, buildings, upgrades, and future ability gates.
- Hero XP, level-up, mana, three abilities per class, skill point allocation.
- Passive stat upgrades through Combat, Magic, and Leadership skill trees.
- Weighted item rewards, modest randomized item affixes, item instance inventory, weapon/armor/trinket equipment, equip previews, unique duplicate conversion, first-clear reward tracking, and reward XP.
- Unit Veterancy V1: battle-local unit XP, Recruit/Seasoned/Veteran/Elite ranks, modest stat bonuses, selected-unit rank display, rank-up feedback, and victory Results veteran summaries.
- Retinue Camp V1: up to 2 saved veteran units by default, +1 capacity from Training Yard II, Campaign Map display/dismiss, campaign battle deployment, save/load, and permanent removal on retinue death.
- Enemy Hero / Rival Commander V1: three named Ashen commanders, data validation, campaign node preview, battle start/scout feedback, modest combat abilities, XP/objective/results credit, and simulator telemetry.
- Rival / Nemesis Persistence V1: campaign-save rival state, Rival Intel panel, node preview state, Results outcome consequences, small next-encounter modifiers, safe old-save normalization, and simulator telemetry fields.
- Rival Rewards and Trophies V1: data-driven first-defeat XP/resource/reputation/item rewards, save-backed trophy records, Results reward/trophy copy, Campaign Map trophy display, duplicate prevention, and simulator telemetry.
- Basic data-configured enemy AI.
- First-pass faction asymmetry: Free Marches baseline identity, Ashen Covenant burn/status pressure, Ashen Fury damage spikes, Smoke March wave speed, and faction style display in setup/campaign/battle start.
- Data validation tests for content references.
- Pure tests for hero progression, rewards, and equipment rules.
- Manual prompt pipeline for portraits, icons, concept art, backgrounds, and a dedicated UI art kit.
- Documentation for design, roadmap, content, and balance.

## 16. What Is Intentionally Postponed

- Worker harvesting and worker-driven construction.
- Campaign depth beyond the first skeleton: broader shops, diplomacy, multi-step dialogue, invasions, quest chains, larger stronghold trees beyond this compact two-tier slice, and larger world-state consequences.
- Deeper affix tiers/effect families, broader shops, item crafting, durability, and equipment art.
- Full class-specific skill trees with choices, prerequisites, and respec rules.
- Larger army management, complex retinue replacement UI, wounded recovery, scars, titles, and unit biography systems.
- Deep nemesis escalation, rival skill trees, rival death cinematics, capture/recruit options, and multi-map procedural rival arcs.
- Tilemap-based terrain and full A*.
- Multiplayer.
- Production art, animation, sound, music, settings, and tutorial polish.
