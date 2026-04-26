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

Create a hero, enter a battle, capture resources, build an army, defeat enemies, earn XP, collect an item reward, spend skill points, equip gear, save hero progress, and return stronger for the next battle.

## 4. Battle Loop

The prototype battle starts with a hero, a Command Hall, and a few soldiers. The player explores, uses the live minimap to read the battlefield, captures resource sites, places production structures, protects them while they automatically construct, trains units, researches small upgrades, fights neutral camps and enemy waves, then destroys the enemy stronghold.

Unit movement now uses a simple grid-based pathfinding layer inside the existing movement system. Commands still set move targets as before, but units calculate coarse A* paths around blocked terrain, water, and live building footprints, then follow waypoints with local same-team separation to reduce stacking. If the pathfinder cannot reach the exact target, units try to move as close as possible and player commands show a brief warning.

Battles use a lightweight grid fog model with three states: unseen, explored, and visible. Friendly units and buildings reveal nearby cells from data-defined `visionRadius` values. Unseen cells are heavily covered, explored cells remain dim, and visible cells are clear. Enemy and neutral units/buildings are only rendered when currently visible. Capture sites become visible after discovery; their ownership is currently shown as live global state once discovered to keep the prototype readable.

## 5. Campaign Loop

The campaign begins as a small node-based Border Marches map. The hero selects available nodes, launches battles through the shared battle request path, resolves simple event choices, completes nodes, claims one-time rewards, adds campaign resource rewards to a persistent bank, saves progress, and unlocks the next branch.

Long term, the campaign map should grow into the living heart of the game: quests, shops, faction reputation, strongholds, random events, persistent rewards, invasions, alliances, and regional consequences.

## 6. Hero Design

Heroes are RPG characters first and RTS commanders second. The prototype supports class, origin, level, XP, mana, stats, skill points, three skill trees, class ability unlocks, inventory, and weapon/armor/trinket equipment.

The current skill trees are:

- Combat: personal damage, HP, and Warlord front-line unlocks.
- Magic: mana, armor, Arcanist spell unlocks, and Shepherd sanctified magic.
- Leadership: command, faith, army support, and support unlocks.

Each class has three total abilities in data. The first ability is available at hero creation, while later abilities are unlocked through skill nodes.

Loot should make the hero feel persistent without replacing RTS decision-making. Items are small, readable stat packages with rarity, slot, flavor text, tags, optional class affinity, and optional faction origin. Rewards are rolled from map-specific weighted tables, with first-clear bonuses to make a new map feel meaningful and repeat-clear rewards to keep skirmishes useful.

Equipment is allowed to change battle feel through HP, mana, damage, armor, speed, range, primary stats, and attack cadence. It should not become so strong that army composition, expansion, upgrades, and hero ability timing stop mattering.

Post-battle rewards should feel like a compact RPG payoff rather than an accounting screen. The Results screen is the shared victory/defeat handoff: victory shows XP before/after, level-ups, skill points, item rarity, item slot, stat comparison, Equip Now, inventory confirmation, campaign node completion rewards, and the campaign bank after resource rewards are added. Defeat shows contextual recovery tips from the actual battle stats.

## 7. Faction Design

The prototype player faction is The Free Marches. Free Marches are the baseline army: balanced economy, reliable infantry and Rangers, defensive Watchtowers, and hero leadership/reputation scaling.

The Ashen Covenant is now the first asymmetric enemy faction rather than a palette swap. Ashen play is aggressive: cheaper early Raiders, higher damage pressure, fragile Hexers, durable Brutes, burn damage from Hexfire, low-health damage spikes through Ashen Fury, and slightly faster attack-wave movement through Smoke March. Their defenses are intentionally weaker than their attack rhythm.

Faction data lives in `src/game/data/factions.ts`. Each faction declares economy, military, and magic style text; available units, buildings, and upgrades; preferred AI personalities; campaign reputation hooks; and data-driven faction modifiers. Runtime support currently covers burn-on-hit, low-health damage, and wave-speed modifiers.

Sylvan Concord remains a future placeholder. It should be the next faction to receive mechanics once Free Marches versus Ashen Covenant is stable.

## 8. Resource Design

Resources are Crowns, Stone, Iron, and Aether. In battle, they are temporary combat economy generated by captured sites instead of worker harvesting. In campaign, the same four resource types also exist as a persistent campaign bank earned from node rewards. Event choices can already spend that bank; future shops, mercenaries, repairs, upgrades, and stronghold development should use it too.

## 9. Campaign Map Design

Campaign nodes are data-driven. Each node defines an ID, display copy, node type, battle map, difficulty, enemy faction, prerequisites, rewards, unlocks, optional event text, optional choices, and a UI position. Locked, available, completed, claimed reward, and claimed choice state comes from the save file rather than the node definition.

Event choices are intentionally small data objects, not a dialogue engine. They can require campaign resources, hero level, completed nodes, owned items, or faction reputation; pay campaign resource costs; grant XP, items, resources, reputation, or node unlocks; and either complete the node or keep it open for another once-only choice.

The first campaign is intentionally small:

- Border Village starts available.
- Old Stone Road unlocks after Border Village.
- Aether Well Ruins and Bandit Hillfort unlock after Old Stone Road.
- Refugee Caravan also unlocks after Old Stone Road as an optional event branch.
- Chapel of the Marches unlocks after Aether Well Ruins.
- Ashen Outpost unlocks after Bandit Hillfort and Chapel of the Marches.

Only battle nodes launch combat. Non-battle nodes either resolve direct rewards or present choices in the campaign map. Chapel of the Marches and Refugee Caravan prove the first choice layer with resource costs, locked choices, reputation shifts, item rewards, and optional node unlocks.

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

## 13. AI Design

The MVP AI is a simple state machine. It expands to sites, gains income, trains units, defends threatened ground, and sends attack waves. AI personalities now sit on top of the shared pacing model so the same battle map can feel different without rewriting the controller.

Current personalities:

- Balanced Warlord: mixed expansion and attacks, used as the default tutorial baseline.
- Raider Rush: faster early pressure with lighter units, meant to punish greedy expansion but fall off later.
- Fortress Keeper: slower attacks, larger defensive radius, heavier late waves, and protection for enemy-held sites.
- Hexfire Cult: more Hexers and bursty ranged pressure, with a thinner frontline.

Personalities adjust preferred units, training plan, attack and expansion timing, wave caps, defense radius, defensive reserves, capture-site protection, and commander participation timing. They do not yet understand true scouting paths, counter-builds, retreat micro, or rebuilding destroyed production.

## 14. Data-Driven Content Philosophy

Units, buildings, abilities, resources, factions, maps, hero classes, origins, skill trees, reward tables, items, and campaign nodes live in `src/game/data`. Engine code should read these definitions instead of hard-coding content names and numbers.

Manual art assets live in the manual asset pipeline. The UI art kit is also data-driven: reusable frame, button, divider, slot, minimap, victory, and defeat panel assets are registered in `tools/manual-asset-pipeline/assetRegistry.ts`, discovered through the manifest, and exposed to CSS as optional variables. The game must keep working without those files.

UI-kit art should be edge and slot art, not full UI screenshots. Frames should use transparent centers so live text, numbers, icons, and panels remain readable and scalable.

## 15. What Is Implemented Now

- Phaser/Vite/TypeScript project.
- Menu, hero creation, campaign map, skirmish setup, battle, progression screen, inventory screen, local save.
- Seven-node campaign skeleton with save-backed node unlocks, completion, one-time node rewards, event choices, and a persistent campaign resource bank.
- RTS selection, movement, capture sites, resource income, combat, projectiles.
- Lightweight fog of war with grid visibility, dim explored areas, hidden enemies outside vision, and minimap masking.
- Two playable skirmish maps: First Claim and Broken Ford.
- Building placement, automatic construction, unit training, research queues, upgrades, watchtower attacks.
- Live minimap snapshots for units, buildings, capture sites, neutral camps, camera position, and alert pings.
- Data-driven prerequisites for units, buildings, upgrades, and future ability gates.
- Hero XP, level-up, mana, three abilities per class, skill point allocation.
- Passive stat upgrades through Combat, Magic, and Leadership skill trees.
- Weighted item rewards, inventory, weapon/armor/trinket equipment, equip previews, first-clear reward tracking, and reward XP.
- Basic data-configured enemy AI.
- First-pass faction asymmetry: Free Marches baseline identity, Ashen Covenant burn/status pressure, Ashen Fury damage spikes, Smoke March wave speed, and faction style display in setup/campaign/battle start.
- Data validation tests for content references.
- Pure tests for hero progression, rewards, and equipment rules.
- Manual prompt pipeline for portraits, icons, concept art, backgrounds, and a dedicated UI art kit.
- Documentation for design, roadmap, content, and balance.

## 16. What Is Intentionally Postponed

- Worker harvesting and worker-driven construction.
- Campaign depth beyond the first skeleton: shops, diplomacy, multi-step dialogue, invasions, quest chains, and world-state consequences.
- More complex item affixes, duplicate conversion, shops, item crafting, and equipment art.
- Full class-specific skill trees with choices, prerequisites, and respec rules.
- Retinue persistence.
- Tilemap-based terrain and full A*.
- Multiplayer.
- Production art, animation, sound, music, settings, and tutorial polish.
