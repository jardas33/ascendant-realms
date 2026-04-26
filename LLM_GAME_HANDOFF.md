# Ascendant Realms LLM Handoff

Last updated: 2026-04-26 12:49 -04:00

## Current Project Identity

Ascendant Realms is a Phaser 3, TypeScript, and Vite browser-game prototype for a fantasy RTS/RPG hybrid. The current playable shape is:

1. Create or load a persistent hero.
2. Enter a small node-based campaign or choose a skirmish.
3. Play an RTS battle with hero abilities, capture sites, construction, training queues, upgrades, rally points, minimap, fog of war, and enemy pressure waves.
4. Resolve victory or defeat through a shared Results scene.
5. Persist hero XP, skill points, inventory, equipment, campaign node progress, event choices, and campaign resources in local storage.

The project is still a prototype. It has enough structure for iteration, but the worktree currently contains many uncommitted feature-pass changes.

## Current Command List

Use these from the project root:

```bash
npm install
npm run dev
npm test
npm run build
npm run preview
npm run assets:prompts
npm run assets:ui-kit
npm run assets:process-battle-sprites
npm run assets:manifest
npm run assets:validate
npm run assets:refresh
```

`assets:refresh` runs battle sprite processing, manifest rebuild, and asset validation. It was not needed in the latest handoff pass because no asset registry, source-art, or manifest inputs had pending diffs.

## Current Scenes

Scene keys live in `src/game/core/SceneKeys.ts`.

- `BootScene`: loads manifests/assets and enters the menu.
- `MainMenuScene`: New Campaign, Continue Campaign, Skirmish, Hero Inventory, Asset Gallery, Reset Save.
- `HeroCreationScene`: hero name/class/origin creation, then campaign or skirmish handoff.
- `CampaignMapScene`: campaign node map, hero summary, campaign bank, selected node details, event choices, campaign battle launch.
- `SkirmishSetupScene`: map selection, hero summary, difficulty selection, enemy faction placeholder, start battle.
- `BattleScene`: main RTS runtime and Phaser entity orchestration.
- `ResultsScene`: victory/defeat summary, rewards, Equip Now, retry/return flow.
- `HeroProgressionScene`: inventory/equipment and skill allocation.
- `AssetGalleryScene`: local/manual asset inspection.

## Current Campaign Flow

Campaign data lives in `src/game/data/campaignNodes.ts`. Rules live in `src/game/core/CampaignRules.ts`.

The Border Marches mini-campaign currently has seven nodes:

- `border_village`: battle, Easy, First Claim, available at start.
- `old_stone_road`: battle, Easy, First Claim, unlocks after Border Village.
- `aether_well_ruins`: battle, Normal, Broken Ford, unlocks after Old Stone Road.
- `bandit_hillfort`: battle, Normal, Broken Ford, unlocks after Old Stone Road.
- `chapel_of_the_marches`: shrine/event choices, unlocks after Aether Well Ruins.
- `refugee_caravan`: event choices, unlocks after Old Stone Road.
- `ashen_outpost`: battle, Normal, dedicated Ashen Outpost fortress map, requires Bandit Hillfort and Chapel of the Marches.

Campaign node state is saved, not stored on the node definition. Nodes can be locked, available, or completed. Battle nodes launch through `createCampaignBattleLaunchRequest`, using the same `BattleLaunchRequest` pathway as skirmish.

On campaign battle victory:

- `BattleRuntime` grants battle rewards.
- map-specific secondary objective completions are preserved in battle stats
- `ResultsScene` applies campaign node completion.
- One-time node rewards are applied if not already claimed.
- Campaign resources are added to the persistent campaign bank.
- Hero and campaign state are saved.
- The player can return to the campaign map.

On campaign battle defeat:

- Rewards are not granted.
- Campaign node completion is not granted.
- secondary objective progress is displayed only as part of that battle result and does not persist.
- The player can retry the battle or return to the campaign map.

## Current Skirmish Flow

Skirmish mode remains separate from campaign mode.

Flow:

1. Main Menu -> Skirmish.
2. If no hero exists, create a hero first.
3. `SkirmishSetupScene` shows map selection, hero summary, difficulty selection, enemy faction placeholder, and Start Battle.
4. Start Battle creates a skirmish `BattleLaunchRequest`.
5. `BattleScene` resolves the selected map and reward table.
6. `ResultsScene` shows victory/defeat, rewards, Equip Now, and return/retry options.

Skirmish victories can grant map reward-table items, XP, and first-clear/repeat-clear rewards.

## Current Maps

Map data lives in `src/game/data/maps.ts`.

### First Claim

- ID: `first_claim`
- Size: 2400 x 1600
- Role: balanced tutorial skirmish.
- Player starts west; enemy starts east.
- Four capture sites: Crown Shrine, Stone Quarry, Iron Vein, Aether Well.
- Three neutral camps.
- Reward table: `first_claim_rewards`.
- Intended to teach hero selection, movement, capture, construction, training, hero abilities, first wave defense, and base assault.

### Broken Ford

- ID: `broken_ford`
- Size: 2600 x 1700
- Role: contested ruined river crossing.
- Player starts southwest; enemy starts northeast.
- Two main lanes and a dangerous central ford.
- Four capture sites.
- Three neutral camps, including a harder central camp.
- Reward table: `broken_ford_rewards`.
- Intended to test lane choice, safer side expansion, and risky center control.

### Ashen Outpost

- ID: `ashen_outpost`
- Size: 2600 x 1800
- Role: current mini-campaign milestone/boss-style fortress assault.
- Player starts lower-left; enemy fortress starts upper-right.
- Theme: scorched frontier outpost with ash roads, burned central shrine, side supply paths, and a fortified Ashen base.
- Four capture sites:
  - Burned Shrine: Aether, dangerous central objective.
  - West Supply Pyre: Crowns, safer western staging route.
  - South Iron Pit: Iron, slower southern side route.
  - North Stone Scar: Stone, northern pressure route near enemy approach.
- Three neutral camps:
  - West Cinder Pack.
  - North Ash Imps.
  - Shrine Ember Guardians, the harder central camp.
- Enemy fortress includes:
  - Enemy Stronghold.
  - Enemy Barracks.
  - Two enemy Watchtower spawns used as defensive tower placeholders.
- Player starts with slightly higher battle resources and one extra Militia compared with the earlier maps.
- Enemy AI config uses more Hexer-heavy production, larger defense radius, stronger income, and delayed but serious pressure.
- Campaign node uses Ashen Covenant plus Hexfire Cult personality on Normal difficulty.
- Reward table: `ashen_outpost_rewards`.
- Special objectives:
  - Primary: destroy the Ashen Stronghold.
  - Secondary: capture the Burned Shrine.
  - Secondary: destroy Enemy Barracks.
  - Secondary: defeat the Outpost Captain / Ashen Commander.
- Intended to be winnable after the player has completed earlier campaign nodes, equipped rewards, spent skill points, and learned construction/training/rally basics.

## Current Hero System

Hero data lives in `src/game/data/heroes.ts`, `heroClasses.ts`, `origins.ts`, `abilities.ts`, and `skillTrees.ts`.

Current hero classes:

- Warlord
- Arcanist
- Shepherd

Current origins:

- Exiled Noble
- Border Outrider
- Temple Orphan

Hero save data tracks:

- name, class, origin
- level and XP
- skill points
- unlocked abilities
- completed battles
- cleared map IDs
- inventory
- equipment
- allocated skill ranks
- faction reputation
- primary stats

Hero progression rules live in `src/game/core/HeroProgressionRules.ts`.

Current skill trees:

- Combat: damage, HP, Warlord Cleave.
- Magic: mana, armor, Arcanist Arcane Burst/Blink, Shepherd Sanctify Ground.
- Leadership: command, faith, Warlord War Cry, Shepherd Blessing.

Battle hero stats are recalculated from class base stats, origin modifiers, level bonuses, skill ranks, and equipped item stat modifiers.

## Current Inventory And Equipment System

Item data lives in `src/game/data/items.ts`. Reward tables live in `src/game/data/rewards.ts`.

Current item fields:

- id
- name
- rarity
- slot
- description
- stat modifiers
- optional class affinity
- optional faction origin
- optional icon asset key
- flavor text
- tags

Current equipment slots:

- weapon
- armor
- trinket
- relic is typed for future use but not in the default active equipment slot list.

Reward tables support:

- guaranteed item IDs
- weighted item pools
- deterministic item IDs for tests
- map-specific item pool filters
- first-clear-only and repeat-clear-only entries
- resource rewards
- XP rewards
- first-clear bonus
- repeat-clear reward

Current map reward tables:

- `first_claim_rewards`: starter pool, modest resources/XP, first-clear onboarding bonus.
- `broken_ford_rewards`: stronger mid-campaign pool, Fordbreaker Halberd first-clear reward.
- `ashen_outpost_rewards`: milestone pool, higher XP/resources, one weighted roll, first-clear Ashbound Censer, rare/epic chase items including Oathbound Aegis and Starfall Prism, legendary Ascendant Signet as a repeat-clear chase.

`HeroProgressionScene` shows inventory and equipment. `ResultsScene` shows earned items and supports Equip Now through `src/game/core/ResultsFlow.ts`.

Equip Now:

- checks the reward item exists and is in inventory
- equips to the item's slot
- recalculates hero stats
- saves updated hero/campaign state
- shows stat deltas and current equipped replacement context

ResultsScene also displays map-specific special objectives when the map defines `secondaryObjectives`. Ashen Outpost currently uses this to show whether the player captured the Burned Shrine, destroyed Enemy Barracks, and defeated the Outpost Captain.

Known limitation: items do not yet have instance IDs, randomized affixes, durability, crafting, duplicate conversion, or icon slot art in every UI surface.

## Current Campaign Resource Bank

Campaign resources are saved separately from temporary battle resources.

Bank resources:

- crowns
- stone
- iron
- aether

Campaign resources are stored on `CampaignSaveData.resources`. They are displayed in `CampaignMapScene`, added by campaign node rewards and event choices, and spent by campaign event choices. They are intended to later support shops, mercenaries, repairs, upgrades, stronghold development, and node choices.

## Current Campaign Event And Choice System

Choice types live in `src/game/core/GameTypes.ts`. Choice rules live in `src/game/core/CampaignRules.ts`.

Campaign choices can define:

- id
- label
- description
- requirements
- costs
- rewards
- reputation changes
- unlock node IDs
- once-only behavior
- whether the choice completes the node

Supported requirements:

- campaign resource thresholds
- hero level
- completed campaign node IDs
- owned item IDs
- faction reputation

Supported effects:

- campaign resource costs
- XP rewards
- item rewards
- campaign resource rewards
- faction reputation changes
- unlock node IDs
- recover hero placeholder
- complete or keep the node open

Once-only choices are saved in `CampaignSaveData.choiceIdsClaimed` using `nodeId:choiceId`. Completing an event node locks remaining choices on that node. `completesNode: false` lets a choice apply once while keeping the node available for another choice.

Current event-choice nodes:

- Chapel of the Marches: Pray for Strength, Repair the Chapel, Ask for Guidance.
- Refugee Caravan: Protect Them, Recruit Volunteers, Demand Tribute.

## Current Battle Pacing

Battle pacing data lives in `src/game/data/battlePacing.ts`.

Battle phases:

- Opening: 0:00-2:00. No base attacks.
- Expansion: 2:00-5:00. Small base attacks, no commander.
- Pressure: 5:00-8:00. Mixed waves, still no commander.
- Assault: 8:00+. Larger waves and commander support allowed.

Difficulty presets:

- Story: low income, long first delay, small waves, fog off.
- Easy: forgiving tutorial pace, small waves, fog on.
- Normal: intended baseline, first serious attack around 3:00, fog on.
- Hard: faster pressure, larger waves, fog on.

First-match tutorial protection:

- first attack not allowed before 150 seconds
- first attack forced only after 180 seconds if the player still has not captured a site
- large attacks delayed until 240 seconds or production milestone
- early attack wave size capped at 2

Default battle difficulty is currently `normal`, while fallback campaign save difficulty is `easy`.

## Current Enemy AI Behavior

Enemy AI lives in `src/game/ai/EnemyAIController.ts`.

The AI:

- gains scaled income on a timer
- trains from completed enemy production buildings
- expands toward capture sites
- defends its base when player units approach
- selects phase-limited attack waves
- respects difficulty timing, wave size, income, training speed, expansion speed, and commander join timing
- sends alerts such as scouts moving, forces gathering, and attack incoming

AI personality data lives in `src/game/data/aiPersonalities.ts`.

Current AI personalities:

- Balanced Warlord: mixed expansion and attacks; current default behavior and Border Village style.
- Raider Rush: faster early pressure, lighter unit preference, punishes greedy expansion, weaker late-game posture.
- Fortress Keeper: slower attacks, larger defense radius, defensive reserves, protects captured sites, stronger later waves.
- Hexfire Cult: more Hexers and ranged/magic pressure, fewer melee bodies, burstier waves, weaker frontline.

Campaign personality assignments:

- Border Village: Balanced Warlord on Easy.
- Old Stone Road: Raider Rush on Easy.
- Aether Well Ruins: Hexfire Cult on Normal.
- Bandit Hillfort: Fortress Keeper on Normal.
- Ashen Outpost: Hexfire Cult on Normal with dedicated fortress-map AI tuning.

Current AI limitations:

- no enemy construction yet
- no worker logic
- no true scouting memory
- no retreat logic
- no counter-unit strategy
- no pathfinding-aware threat routing
- no true long-term strategic planning beyond personality/timing/composition modifiers

## Current Faction Asymmetry

Faction data lives in `src/game/data/factions.ts`.

Current factions:

- `free_marches`: player baseline faction; balanced economy, reliable Militia/Rangers/Acolytes, defensive Watchtower, leadership and reputation hooks.
- `ashen_covenant`: main enemy faction; aggressive, cheaper early Raiders, harder-hitting but less durable units except Brutes, magic pressure through Hexers, burn/status pressure, and Ashen AI personality preferences.
- `sylvan_concord`: future placeholder faction with early identity hooks and item origins, but not yet a playable or fully implemented faction.

Ashen-specific mechanics currently implemented:

- `hexfire_burn`: burn status effect applied by relevant Ashen modifiers, with damage over time and floating feedback.
- `ashen_fury`: low-health damage pressure trait.
- `smoke_march`: wave movement-speed modifier for matching Ashen units.

Faction validation checks unit, building, upgrade, AI personality, reputation hook, and modifier references.

## Current Construction, Building, And Training System

Building data lives in `src/game/data/buildings.ts`. Building runtime state lives in `src/game/entities/Building.ts`.

Current player buildings:

- Command Hall
- Barracks
- Mystic Lodge
- Watchtower

Current enemy buildings:

- Enemy Stronghold
- Enemy Barracks

Construction states:

- planned/ghost preview during placement
- underConstruction after resources are paid
- completed when construction finishes

Construction times:

- Command Hall: 0 seconds
- Barracks: 25 seconds
- Mystic Lodge: 30 seconds
- Watchtower: 20 seconds
- enemy prebuilt structures: 0 seconds

Placement rules live in `src/game/systems/BuildingPlacementRules.ts`.

Placement validates:

- resources
- map bounds
- blocked/water terrain
- buildable terrain
- distance from owned building
- overlaps with structures
- overlaps with capture sites

Training lives in `src/game/systems/TrainingSystem.ts`.

Training behavior:

- only completed production buildings can train
- resources are paid when queued
- queues track remaining/total time
- canceling a queued unit refunds paid cost
- completed units spawn near the production building
- spawned units receive the source building rally command when present

## Current Upgrades

Upgrade data lives in `src/game/data/upgrades.ts`. Runtime queueing lives in `src/game/systems/UpgradeSystem.ts`. Effects live in `src/game/systems/UpgradeEffects.ts`.

Current upgrades:

- Infantry Weapons I: Militia/Raider-style melee units +10% damage.
- Ranger Training I: Ranger range +10% and attack cooldown x0.9.
- Reinforced Armor I: Militia/Ranger/Acolyte +1 armor.
- Aether Study I: Acolyte +10% damage and hero mana regen multiplier 1.25.

Upgrades:

- use the shared prerequisite system
- pay costs immediately
- queue on eligible completed buildings
- can be canceled for refunds before completion
- are tracked per team by researched ID

## Current Rally Point System

Rally-point pure logic lives in `src/game/systems/RallyPointSystem.ts`.

Current behavior:

- completed friendly production buildings can hold `rallyPoint` and optional `rallyTargetId`
- right-click ground with completed Barracks or Mystic Lodge selected sets rally for selected production buildings
- a map marker is shown for selected production building rally points
- newly trained units automatically receive a move command to the rally point
- rally points do not persist between battles
- rally target IDs are present for future capture-site or enemy-objective rallying but ground rally is the only implemented behavior

## Current Movement And Pathfinding System

Movement lives in `src/game/systems/MovementSystem.ts`. Grid pathing support lives in `src/game/systems/PathfindingGrid.ts`.

Current behavior:

- map terrain creates a grid-based walkability layer
- blocked and water terrain are treated as impassable
- static building footprints influence path blocking where integrated
- A* computes waypoint paths around blocked rectangles and impassable zones
- units follow waypoints while retaining local separation to reduce stacking
- attack-move remains compatible with path-following and can still stop for enemies
- simple repath/stuck handling exists, with throttling to avoid constant recalculation

Current limitations:

- no multiplayer determinism
- no formation movement
- no true crowd flow fields
- dynamic building blockers are still intentionally conservative
- blocked terrain does not yet influence fog line-of-sight

## Current Fog Of War System

Fog logic lives in `src/game/systems/FogOfWarSystem.ts`.

Visibility states:

- unseen
- explored
- visible

Current behavior:

- grid-based visibility using a default 160-pixel cell size
- friendly units/buildings reveal cells using data-defined `visionRadius`
- visible cells become explored when no longer in current vision
- enemy and neutral units/buildings are hidden outside current vision
- capture sites remain visible after discovery; ownership/status is currently shown as live state once discovered for readability
- Story difficulty disables fog; other current difficulties enable it
- `F` toggles fog debug reveal in BattleScene

Known limitation: fog is not blocker-aware and does not do line-of-sight around terrain.

## Current Minimap Behavior

Minimap rendering lives in `src/game/ui/MinimapView.ts`. `BattleScene` builds minimap snapshots.

The minimap shows:

- map bounds
- player units
- visible enemy units
- visible neutral units/camps
- player buildings
- visible enemy buildings
- discovered capture sites
- selected production building rally points
- current camera viewport rectangle
- alert pings
- fog dimming for unexplored/explored cells

Controls:

- click minimap to center camera on the clicked world position
- alert pings appear for enemy waves/base/resource attacks

Known limitation: no drag-to-pan, no last-known enemy icons, and no fog memory for enemy positions.

## Current Objective Tracking

Primary battle objectives are still simple base survival/destruction:

- player loses if the Command Hall objective building dies
- player wins if the enemy Stronghold objective building dies

Maps can now define optional `secondaryObjectives` under `scenario.objectives`.

Supported secondary objective types:

- `capture_site`
- `destroy_building`
- `defeat_unit`

Runtime tracking lives in `BattleRuntime.stats.completedObjectiveIds`. `BattleScene` records secondary objectives from capture and kill hooks. `ResultsScene` displays completion status for maps that define special objectives. Current secondary objectives are informational/satisfaction goals only; they do not yet alter rewards, campaign unlocks, or score.

## Current Save Format

Save key is defined in `src/game/core/Constants.ts`. Save logic lives in `src/game/core/SaveSystem.ts`. Save types live in `src/game/save/SaveTypes.ts`.

Stored save:

```ts
interface StoredGameSave {
  version: 1;
  hero: HeroSaveData;
  campaign: CampaignSaveData;
  updatedAt: string;
}
```

Hero save:

- heroName
- classId
- originId
- level
- xp
- skillPoints
- unlockedAbilities
- completedBattles
- clearedMapIds
- inventory
- equipment
- allocatedSkills
- legacy `items` migration input
- factionReputation
- stats

Campaign save:

- started
- difficulty
- resources
- completedNodeIds
- unlockedNodeIds
- nodeRewardsClaimedIds
- choiceIdsClaimed
- selectedNodeId

Save normalization:

- rejects invalid save version or invalid hero base data
- migrates legacy `items` into inventory
- normalizes missing campaign save to fallback
- normalizes missing campaign resources to zero
- normalizes missing choice claim IDs to an empty array
- dedupes inventory, cleared maps, node rewards, unlocks, completions, and choice claims
- clamps negative numeric resources/stats where appropriate

## Current Tests

Latest verified suite status after the Ashen Outpost map pass:

- `npm test`: passed
- 21 test files passed
- 89 tests passed

Current test files:

- `src/game/ai/EnemyAIController.test.ts`
- `src/game/battle/BattleLaunchRequest.test.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/core/FirstExperienceGuidance.test.ts`
- `src/game/core/HeroProgressionRules.test.ts`
- `src/game/core/ResultsFlow.test.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/data/aiPersonalities.test.ts`
- `src/game/data/battlePacing.test.ts`
- `src/game/data/campaignModifiers.test.ts`
- `src/game/data/contentValidation.test.ts`
- `src/game/systems/BuildingPlacementRules.test.ts`
- `src/game/systems/FogOfWarSystem.test.ts`
- `src/game/systems/PathfindingGrid.test.ts`
- `src/game/systems/PrerequisiteSystem.test.ts`
- `src/game/systems/RallyPointSystem.test.ts`
- `src/game/systems/StatusEffectSystem.test.ts`
- `src/game/systems/UpgradeEffects.test.ts`
- `src/game/systems/UpgradeSystem.test.ts`
- `src/game/ui/MinimapView.test.ts`

Test coverage is strongest around pure rules, launch validation, battle runtime stats, save normalization, reward flow, content validation, AI personalities, campaign modifiers, pathfinding, fog, rally, placement, status effects, and upgrades. Browser-level scene flow remains mostly manual.

## Current Build And Asset Status

Latest verified build status after the Ashen Outpost map pass:

- `npm run build`: passed
- Vite emitted the known large-chunk warning for the main JS bundle, approximately 1.7 MB minified and 400 KB gzip.

Asset refresh status:

- `npm run assets:refresh` was not run in this pass because no `tools` or `public` asset files had pending diffs.
- Run it next if asset registry, manual source art, processed sprites, or manifest inputs change.

## Current Known Bugs

No deterministic runtime bug was reproduced by automated tests in this pass.

Known current issues:

- Browser Use could not attach to the in-app browser pane during this pass, so a full browser automation smoke was not completed.
- `rg --files` failed with Windows access denied in this workspace; PowerShell enumeration was used instead.
- Vite reports a large bundle chunk warning.
- Manual browser flow needs another smoke once Browser Use is available.

## Current Known Limitations

- Campaign is still a skeleton, not a full strategic layer.
- No shops, vendors, mercenaries, repairs, stronghold development, diplomacy, invasions, or world simulation.
- Event choices are compact cards, not a dialogue engine.
- `recoverHero` is a placeholder event reward.
- No item instance IDs, randomized affixes, duplicate conversion, crafting, durability, or item art pipeline integration for all item UI.
- Relic slot is typed but not fully used.
- Fog of war is grid-based and not blocker-aware.
- Minimap has no drag-to-pan or last-known enemy memory.
- Enemy AI is paced but simple; it does not construct, retreat, scout intelligently, or adapt composition.
- Player construction is automatic; no workers.
- Pathfinding now uses A* waypoints, but it is not formation-aware, flow-field based, or fully dynamic around every temporary obstruction.
- Campaign and skirmish balance are prototype-level.
- Audio, music, settings, accessibility pass, and production UI polish are still absent.
- Scene UI is DOM-heavy and duplicated across scenes.

## Files Becoming Too Large Or Risky

Line counts from the current audit:

- `src/game/styles/ui.css`: 1556 lines. Risk: broad global UI styling, scene-specific styles, and HUD styles in one file.
- `tools/manual-asset-pipeline/assetRegistry.ts`: 1343 lines. Risk: asset metadata is large and easy to conflict.
- `src/game/scenes/BattleScene.ts`: 1285 lines. Risk: owns spawning, rendering, input wiring, fog, minimap snapshots, combat hooks, results transitions, and many systems.
- `src/game/data/contentValidation.ts`: 929 lines. Risk: validation logic keeps growing with each data system.
- `src/game/data/maps.ts`: 592 lines. Risk: authored map data is growing quickly; future maps should move to separate files or grouped exports.
- `src/game/scenes/ResultsScene.ts`: 557 lines. Risk: reward UI, campaign reward flow, equip-now behavior, special objectives, save behavior, and navigation are coupled.
- `src/game/core/GameTypes.ts`: 542 lines. Risk: central type file is accumulating every domain.
- `src/game/scenes/CampaignMapScene.ts`: 485 lines. Risk: campaign UI, choice application, save calls, and node rendering are coupled.
- `src/game/scenes/HeroProgressionScene.ts`: 441 lines. Risk: inventory/equipment/skill UI in one DOM scene.
- `src/game/core/HeroProgressionRules.ts`: 420 lines. Risk: skills, equipment, rewards, XP, and stat math are sharing one rules module.
- `src/game/ui/HUD.ts`: 366 lines. Risk: battle panel, selected entity UI, training, upgrades, alerts, and minimap container are concentrated.

## Most Fragile Systems

1. `BattleScene` integration layer: it coordinates almost every live system and is the easiest place to introduce regressions.
2. Results and campaign reward saving: battle reward, node reward, Equip Now, first-clear, and campaign-bank logic all meet here.
3. Save normalization: older saves are supported through permissive migration, but save version remains `1` while fields have grown.
4. Campaign choices: pure rules are covered, but browser UI flow needs manual smoke testing.
5. Fog/minimap visibility: visibility filters entity rendering and minimap markers; it can easily hide too much or too little.
6. Input mode overlap: selection, right-click move/attack, rally assignment, placement ghost, minimap click, ability hotkeys, and Esc behavior share player input.
7. Content validation: high value, but it is expanding into a catch-all validator.
8. DOM UI styling: one CSS file styles menus, HUD, results, inventory, campaign, minimap, and construction hints.
9. Asset fallback chain: optional manual/final/placeholder assets need regular validation after art changes.
10. Enemy AI pacing: currently data-driven and safer than before, but still depends on milestone gates and phase math.

## Current Git Status

Latest commit hash at handoff time:

```text
18af42d9520b689ae958f49b41ba9c21346f8e9b
```

Branch status:

```text
main...origin/main [ahead 2]
```

The worktree is dirty with many uncommitted feature-pass changes. Do not reset, checkout, or delete these changes unless the user explicitly asks.

Modified files at handoff time:

- `BALANCE.md`
- `CONTENT_GUIDE.md`
- `DESIGN.md`
- `DEVELOPMENT_CHECKPOINT.md`
- `LLM_GAME_HANDOFF.md`
- `README.md`
- `ROADMAP.md`
- `TECHNICAL_AUDIT.md`
- `src/game/ai/EnemyAIController.ts`
- `src/game/battle/BattleLaunchRequest.test.ts`
- `src/game/battle/BattleLaunchRequest.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/battle/BattleRuntime.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/core/CampaignRules.ts`
- `src/game/core/GameTypes.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/core/SaveSystem.ts`
- `src/game/data/battlePacing.ts`
- `src/game/data/buildings.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/data/contentIndex.ts`
- `src/game/data/contentValidation.test.ts`
- `src/game/data/contentValidation.ts`
- `src/game/data/factions.ts`
- `src/game/data/heroClasses.ts`
- `src/game/data/heroes.ts`
- `src/game/data/maps.ts`
- `src/game/data/rewards.ts`
- `src/game/data/units.ts`
- `src/game/data/upgrades.ts`
- `src/game/entities/BaseEntity.ts`
- `src/game/entities/Building.ts`
- `src/game/entities/Hero.ts`
- `src/game/entities/Unit.ts`
- `src/game/save/SaveTypes.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/CampaignMapScene.ts`
- `src/game/scenes/HeroCreationScene.ts`
- `src/game/scenes/HeroProgressionScene.ts`
- `src/game/scenes/ResultsScene.ts`
- `src/game/scenes/SkirmishSetupScene.ts`
- `src/game/styles/ui.css`
- `src/game/systems/CombatSystem.ts`
- `src/game/systems/InputSystem.ts`
- `src/game/systems/MovementSystem.ts`
- `src/game/systems/TrainingSystem.ts`
- `src/game/ui/HUD.ts`
- `src/game/ui/MinimapView.ts`

Untracked files at handoff time:

- `src/game/core/ResultsFlow.test.ts`
- `src/game/core/ResultsFlow.ts`
- `src/game/data/aiPersonalities.test.ts`
- `src/game/data/aiPersonalities.ts`
- `src/game/data/campaignModifiers.test.ts`
- `src/game/data/campaignModifiers.ts`
- `src/game/systems/FogOfWarSystem.test.ts`
- `src/game/systems/FogOfWarSystem.ts`
- `src/game/systems/PathfindingGrid.test.ts`
- `src/game/systems/PathfindingGrid.ts`
- `src/game/systems/RallyPointSystem.test.ts`
- `src/game/systems/RallyPointSystem.ts`
- `src/game/systems/StatusEffectSystem.test.ts`
- `src/game/systems/StatusEffectSystem.ts`

## Current Manual QA Checklist

Run this before committing or before starting another large feature pass:

1. Start dev server and open `http://127.0.0.1:5173/`.
2. Main menu appears.
3. Reset Save works from the main menu.
4. New Campaign with no save opens hero creation.
5. Create each hero class at least once.
6. Campaign map opens after hero creation.
7. Campaign bank displays Crowns, Stone, Iron, and Aether.
8. Border Village is available at campaign start.
9. Locked nodes cannot start.
10. Border Village launches First Claim.
11. In battle, select hero with click and `H`.
12. Move hero/units with right-click.
13. Capture Crown Shrine.
14. Select Command Hall.
15. Place Barracks and verify valid/invalid placement reasons.
16. Barracks appears under construction and cannot train until complete.
17. Completed Barracks can train Militia and Ranger.
18. Queue progress displays and cancel/refund works.
19. Set Barracks rally point with right-click ground.
20. Rally marker appears and trained units move to it.
21. Build Mystic Lodge and train Acolyte.
22. Build Watchtower and verify it attacks when enemies approach.
23. Research Infantry Weapons I, Ranger Training I, Reinforced Armor I, and Aether Study I.
24. Verify locked train/upgrade buttons show reasons.
25. Use hero abilities with `1`, `2`, `3`.
26. Verify fog hides enemy/neutral entities outside vision.
27. Press `F` on fog-enabled difficulty and verify fog debug toggles.
28. Verify minimap shows units, buildings, sites, camera rectangle, rally marker, and pings.
29. Click minimap and confirm the camera recenters.
30. Survive or intentionally lose the first wave.
31. Defeat screen shows contextual tips and retry/campaign return.
32. Victory screen shows map, difficulty, battle time, XP, level progress, item rewards, campaign rewards, and campaign bank.
33. Equip Now changes stats and persists after leaving Results.
34. Send-to-inventory behavior leaves item in inventory.
35. Campaign victory completes Border Village and unlocks Old Stone Road.
36. Continue Campaign returns to saved campaign state.
37. Complete Old Stone Road and verify Aether Well Ruins, Bandit Hillfort, and Refugee Caravan unlock.
38. Open Refugee Caravan and verify choices, costs, locked reasons, and reputation/resource effects.
39. Open Chapel of the Marches and verify choices, non-completing guidance choice, and completing choices.
40. Verify once-only choices cannot be repeated.
41. Verify campaign node rewards cannot be claimed repeatedly.
42. Skirmish Setup opens separately from campaign.
43. First Claim launches from Skirmish Setup.
44. Broken Ford launches from Skirmish Setup.
45. Ashen Outpost launches from Skirmish Setup.
46. Ashen Outpost shows fortress layout, Burned Shrine, side resources, neutral camps, and defensive towers.
47. Ashen Outpost Results screen shows special objective completion states.
48. Difficulty selection changes AI pacing/fog behavior.
49. Hero Inventory opens from main menu.
50. Equipping/unequipping items changes hero stats.
51. Asset Gallery opens without crashing.
52. Browser console has no new hard errors.
53. Production build preview boots if using `npm run preview`.

## Recommended Next 10 Development Priorities

1. Commit the current dirty worktree as a checkpoint after one full manual browser QA pass.
2. Split `BattleScene` into smaller orchestration helpers: spawning, input wiring, minimap/fog snapshots, result transition, and alerts.
3. Split `ui.css` by scene or UI domain to reduce style collisions.
4. Add browser-level smoke tests for menu -> campaign -> battle -> results and skirmish -> Broken Ford.
5. Add save version migration discipline before adding more persistent systems.
6. Build the first campaign resource spending sink, preferably a small town/shop or repair node using the existing bank.
7. Add item instance IDs and duplicate reward conversion before randomized affixes.
8. Add enemy construction only after player construction/rally/fog/manual QA is stable.
9. Improve pathing and terrain-aware movement before adding larger maps or blocker-aware fog.
10. Add lightweight audio/settings/accessibility pass once core loops are stable.

## Guidance For Future LLMs

- Preserve campaign and skirmish as separate entry flows that share `BattleLaunchRequest`.
- Do not add campaign complexity before stabilizing and committing this feature set.
- Prefer data additions in `src/game/data` and pure rules in `src/game/core` or `src/game/systems`.
- Keep browser smoke testing close to every UI-heavy change.
- Avoid broad rewrites while the worktree is dirty.
- Never reset or checkout over the current uncommitted work without explicit user approval.
