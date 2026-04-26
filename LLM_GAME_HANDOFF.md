# Ascendant Realms LLM Handoff

Last updated: 2026-04-26

Workspace: `D:\Code for projects\WB game like\ascendant-realms`

Git repository: `https://github.com/jardas33/ascendant-realms.git`

Current branch: `main`, tracking `origin/main`

Initial GitHub commit: `8762c11 Initial Ascendant Realms prototype`

Important state note: the repository is initialized and pushed, but the local worktree currently contains many uncommitted changes from the recent pacing, construction, minimap, skirmish-map, loot, and campaign-skeleton work. Do not assume `origin/main` has those systems yet unless they have been committed after this handoff.

## Project Identity

Ascendant Realms is a browser-based RTS/RPG hybrid built with Phaser, TypeScript, and Vite. The current game loop is:

1. Create or load a persistent hero.
2. Enter campaign or skirmish mode.
3. Launch a real-time battle on a data-driven map.
4. Select the hero and command units.
5. Capture resource sites.
6. Build production structures.
7. Train troops and research basic upgrades.
8. Fight AI waves.
9. Destroy the enemy stronghold.
10. Earn XP, items, and progression.
11. Save hero, inventory, equipment, and campaign progress.

The project is still a prototype, but it now has enough structure for campaign nodes, multiple skirmish maps, live minimap support, post-battle loot, equipment, construction, training queues, and RTS battle pacing.

## Current Verification Status

Most recent full verification before this handoff update:

- `npm test` passed.
- `npm run build` passed.
- Browser smoke testing could not be completed because the Browser Use connector reported no active or reachable Codex browser pane during the prior run.

This handoff update is documentation-only. If you continue implementation work, rerun:

```powershell
npm test
npm run build
```

Use `npm run dev` to run the game locally. The app has been opened at `http://127.0.0.1:5173/` in the in-app browser in recent sessions.

## Common Commands

Run all commands from:

```powershell
D:\Code for projects\WB game like\ascendant-realms
```

Development server:

```powershell
npm run dev
```

Unit tests:

```powershell
npm test
```

Production build:

```powershell
npm run build
```

Refresh generated asset documentation:

```powershell
npm run assets:refresh
```

The Vite production build may warn about a large Phaser chunk. That warning is currently expected.

## Technology Stack

- Phaser for 2D rendering and gameplay scenes.
- TypeScript for game logic.
- Vite for dev/build tooling.
- Vitest for tests.
- DOM overlays for menus, HUD panels, selected building UI, campaign UI, inventory UI, and results UI.
- Local storage save system under the key `ascendant-realms-save-v1`.

## High-Level Architecture

Important source directories:

- `src/game/core`: shared types, save system, campaign rules, hero progression rules.
- `src/game/battle`: battle launch validation and runtime state helpers.
- `src/game/data`: data-driven content such as maps, units, buildings, heroes, items, rewards, upgrades, campaign nodes, pacing, and validation.
- `src/game/entities`: Phaser entities such as hero and units.
- `src/game/scenes`: Phaser scenes and DOM screen orchestration.
- `src/game/systems`: battle systems such as building, training, upgrades, combat, capture, resources, and enemy AI.
- `src/game/ui`: HUD and minimap UI pieces.
- `src/game/styles`: DOM overlay CSS.

The intended direction is data-driven content with thin scene orchestration. Avoid hardcoding First Claim, fixed rewards, or one-off UI assumptions where data already exists.

## Scene Registry

Scene keys are defined in `src/game/core/SceneKeys.ts` and registered in `src/game/config.ts`.

Current scenes:

- `BootScene`
- `MainMenuScene`
- `AssetGalleryScene`
- `HeroCreationScene`
- `CampaignMapScene`
- `SkirmishSetupScene`
- `BattleScene`
- `ResultsScene`
- `HeroProgressionScene`

## Main Menu Flow

`src/game/scenes/MainMenuScene.ts` currently exposes:

- New Campaign
- Continue Campaign
- Skirmish
- Hero Inventory
- Asset Gallery
- Reset Save
- Credits / Info

Behavior:

- New Campaign with no hero save starts `HeroCreationScene` with `{ nextMode: "campaign" }`.
- New Campaign with an existing hero creates a fresh started campaign save and opens `CampaignMapScene`.
- Continue Campaign loads campaign state and opens `CampaignMapScene`.
- Skirmish with no hero save starts `HeroCreationScene` with `{ nextMode: "skirmish" }`.
- Skirmish with a hero save opens `SkirmishSetupScene`.
- Hero Inventory opens `HeroProgressionScene`.

## Hero Creation Flow

`src/game/scenes/HeroCreationScene.ts` accepts:

```ts
{ nextMode?: "campaign" | "skirmish" }
```

Campaign mode:

- Creates and saves the hero.
- Creates a started campaign save.
- Opens `CampaignMapScene`.

Skirmish mode:

- Creates and saves the hero.
- Opens `SkirmishSetupScene`.

## Campaign Skeleton

The campaign is intentionally small. It is a node-based foundation, not a full campaign simulation.

Data file:

- `src/game/data/campaignNodes.ts`

Main rules file:

- `src/game/core/CampaignRules.ts`

Main UI scene:

- `src/game/scenes/CampaignMapScene.ts`

Battle launch helper:

- `createCampaignBattleLaunchRequest` in `src/game/battle/BattleLaunchRequest.ts`

Save data:

- `CampaignSaveData` in `src/game/save/SaveTypes.ts`

### Campaign Node Types

Defined type:

```ts
type CampaignNodeType =
  | "battle"
  | "shrine"
  | "town"
  | "ruin"
  | "fortress"
  | "event";
```

Only battle nodes launch combat right now. Non-battle nodes can resolve directly and grant their one-time rewards.

### Campaign Node Definition

Each node can define:

- `id`
- `name`
- `description`
- `nodeType`
- `difficulty`
- `mapId`
- `enemyFactionId`
- `prerequisiteNodeIds`
- `reward`
- `unlockNodeIds`
- `position`

Campaign save state determines whether each node is:

- `locked`
- `available`
- `completed`

### Current Campaign Nodes

The mini-campaign has six nodes.

`border_village`

- Name: Border Village
- Type: battle
- Difficulty: easy
- Map: First Claim
- Enemy faction: Ashen Covenant
- Available at start
- Rewards: XP, crowns, Weathered Command Sword
- Unlocks: Old Stone Road

`old_stone_road`

- Name: Old Stone Road
- Type: battle
- Difficulty: easy
- Map: First Claim
- Prerequisite: Border Village
- Rewards: XP, crowns, stone
- Unlocks: Aether Well Ruins and Bandit Hillfort

`aether_well_ruins`

- Name: Aether Well Ruins
- Type: battle
- Difficulty: normal
- Map: Broken Ford
- Prerequisite: Old Stone Road
- Rewards: XP, aether, Aether Lens
- Unlocks: Chapel of the Marches

`bandit_hillfort`

- Name: Bandit Hillfort
- Type: battle
- Difficulty: normal
- Map: Broken Ford
- Prerequisite: Old Stone Road
- Rewards: XP, crowns, iron, Captain's Seal
- Unlocks: Ashen Outpost

`chapel_of_the_marches`

- Name: Chapel of the Marches
- Type: shrine
- Difficulty: story
- Map: First Claim
- Prerequisite: Aether Well Ruins
- Resolves directly for now.
- Rewards: XP, aether, Green Chapel Icon
- Unlocks: Ashen Outpost

`ashen_outpost`

- Name: Ashen Outpost
- Type: battle
- Difficulty: normal
- Map: Broken Ford
- Prerequisites: Bandit Hillfort and Chapel of the Marches
- Rewards: XP, crowns, iron, aether, Ashbound Censer
- Final current node.

### Campaign Rules

`src/game/core/CampaignRules.ts` handles:

- `createStartedCampaignSave`
- `arePrerequisitesMet`
- `getCampaignNodeStatus`
- `refreshCampaignUnlocks`
- `completeCampaignNode`
- `completeCampaignNodeWithRewards`
- `getCampaignProgressSummary`

Campaign rewards are claimed once using `nodeRewardsClaimedIds`.

### Campaign Battle Integration

When a campaign battle starts:

- `CampaignMapScene` creates a campaign battle launch request.
- `BattleScene` receives mode `campaign_node`.
- The battle uses the node map, difficulty, enemy faction, and hero save.

On victory:

- `BattleRuntime` grants battle rewards.
- Campaign node completion grants node rewards.
- Hero and campaign are saved through `SaveSystem.saveGame`.
- The player returns to `CampaignMapScene`.

On defeat:

- `ResultsScene` shows campaign-aware options.
- The player can retry or return to the campaign map.

### Campaign Limitations

Current placeholders:

- No world map art beyond DOM node layout.
- No shops.
- No dialogue system.
- No diplomacy.
- No branching consequences.
- No procedural generation.
- No campaign resource bank yet.
- Resource rewards are defined and displayed, but they do not currently feed a persistent spendable campaign economy.
- Non-battle nodes resolve instantly.

## Skirmish Setup

`src/game/scenes/SkirmishSetupScene.ts` lets the player choose:

- Map
- Difficulty
- Enemy faction placeholder
- Start battle

It also shows a hero summary.

Skirmish mode remains separate from campaign mode.

## Battle Launch Requests

`src/game/battle/BattleLaunchRequest.ts` supports:

- `skirmish`
- `campaign_node`
- `scenario_mission`

Helpers:

- `createSkirmishBattleLaunchRequest`
- `createCampaignBattleLaunchRequest`

Validation checks include:

- Map ID exists.
- Reward table exists.
- Difficulty is valid.
- Hero save is valid.
- Campaign node ID exists for campaign-node launches.

Do not hardcode First Claim in new launch paths. Use map IDs.

## Skirmish Maps

Maps live in:

- `src/game/data/maps.ts`

Default map:

- `first_claim`

Current maps:

- First Claim
- Broken Ford

### First Claim

Role:

- Balanced tutorial skirmish.
- Teaches capture, building, training, defense, hero abilities, and final base assault.

Size:

- `2400x1600`

Starts:

- Player base: west side, around `x260 y800`
- Enemy base: east side, around `x2140 y800`

Capture sites:

- Crown Shrine
- Stone Quarry
- Iron Vein
- Aether Well

Neutral camps:

- Sunken Road Pack
- Quarry Imps
- Old Well Guard

Reward table:

- `first_claim_rewards`

Current enemy AI config is paced for a slower first match:

- Income interval: 5 seconds
- Training interval: 5.4 seconds before difficulty scaling
- Expand interval: 21 seconds before difficulty scaling
- Initial expansion delay: 18 seconds
- Attack interval: 62 seconds before difficulty scaling
- Initial attack delay: 180 seconds before tutorial gating
- Minimum attack army size: 2
- Attack wave size: 7 before phase and difficulty limits
- Expansion squad size: 2
- Defense radius: 400
- Defense unit count: 6
- Unit plan: raider, raider, hexer, raider, brute

### Broken Ford

Role:

- Second playable skirmish map.
- A ruined river crossing with more blocked terrain and a different strategic rhythm.
- Center is more dangerous but valuable.
- Side resources are safer but slower.

Size:

- `2600x1700`

Starts:

- Player base: bottom-left/west, around `x290 y1320`
- Enemy base: top-right/east, around `x2320 y330`

Capture sites:

- Ford Toll
- West Stone Cut
- South Iron Cache
- North Aether Spring

Neutral camps:

- West Bank Pack
- East Bank Imps
- Ford Guardians

Reward table:

- `broken_ford_rewards`

Enemy AI config:

- Training interval: 5.7 seconds before difficulty scaling
- Expand interval: 24 seconds before difficulty scaling
- Initial expansion delay: 20 seconds
- Attack interval: 66 seconds before difficulty scaling
- Initial attack delay: 190 seconds before tutorial gating
- Defense radius: 430
- Intended to feel more positional and lane-driven than First Claim.

## Battle Pacing Model

Data file:

- `src/game/data/battlePacing.ts`

Default difficulty:

- `normal`

Battle phases:

1. Opening, 0:00 to 2:00
2. Expansion, 2:00 to 5:00
3. Pressure, 5:00 to 8:00
4. Assault, 8:00+

The enemy AI reads phase data to control:

- Whether base attacks are allowed.
- Maximum attack wave size.
- Whether commander participation is allowed.
- Allowed attack unit IDs.
- Preferred attack composition.
- Training unit IDs.
- Unit-specific caps in attack waves.

### Opening Phase

Time:

- `0` to `120` seconds

Behavior:

- Base attacks disabled.
- Commander disabled.
- Wave size capped at 0.
- Enemy can still scout, capture, or fight neutrals through non-base-attack behavior.

### Expansion Phase

Time:

- `120` to `300` seconds

Behavior:

- Base attacks allowed after difficulty and tutorial gates.
- Wave size capped at 3.
- Commander disabled.
- Early composition is raider-heavy with at most one hexer.

### Pressure Phase

Time:

- `300` to `480` seconds

Behavior:

- Attacks become real pressure.
- Wave size capped at 5.
- Commander disabled.
- Brutes can appear.

### Assault Phase

Time:

- `480` seconds and later

Behavior:

- Full attacks allowed.
- Wave size capped at 8.
- Commander allowed.
- Mixed raider, hexer, brute, and commander support can appear.

## Difficulty Presets

Difficulties live in:

- `src/game/data/battlePacing.ts`

Current presets:

### Story

- Enemy starting units: `enemy_raider_1`
- Enemy income multiplier: `0.55`
- First attack delay: `240`
- Attack interval: `82`
- Attack wave size: `2`
- Expansion interval: `30`
- Training interval: `7.5`
- Minimum attack army size: `2`
- Expansion squad size: `1`
- Commander join delay: `720`

### Easy

- Enemy starting units: `enemy_raider_1`, `enemy_raider_2`
- Enemy income multiplier: `0.72`
- First attack delay: `210`
- Attack interval: `72`
- Attack wave size: `3`
- Expansion interval: `25`
- Training interval: `6.2`
- Minimum attack army size: `2`
- Expansion squad size: `2`
- Commander join delay: `660`

### Normal

- Enemy starting units: `enemy_raider_1`, `enemy_raider_2`, `enemy_hexer_1`, `enemy_commander_1`
- Enemy income multiplier: `0.9`
- First attack delay: `180`
- Attack interval: `62`
- Attack wave size: `7`
- Expansion interval: `21`
- Training interval: `5.4`
- Minimum attack army size: `2`
- Expansion squad size: `2`
- Commander join delay: `540`

Normal should no longer defeat a new player around 1:15. Serious base pressure should not happen before roughly 2:30 to 3:00, and phase rules plus first-match protection keep the first wave survivable.

### Hard

- Enemy starting units: `enemy_raider_1`, `enemy_raider_2`, `enemy_hexer_1`, `enemy_brute_1`, `enemy_commander_1`
- Enemy income multiplier: `1.15`
- First attack delay: `150`
- Attack interval: `48`
- Attack wave size: `8`
- Expansion interval: `15`
- Training interval: `3.8`
- Minimum attack army size: `3`
- Expansion squad size: `3`
- Commander join delay: `480`

Hard is intended for players who already know the early build order.

## First-Match Tutorial Protection

Data:

- `FIRST_MATCH_TUTORIAL_PROTECTION` in `src/game/data/battlePacing.ts`

Current values:

- First attack allowed after: `150` seconds
- First attack forced after: `180` seconds
- Large attacks allowed after: `240` seconds
- Early attack max wave size: `2`

Protection intent:

- Allow scouting, capture pressure, and neutral fights before the first serious base attack.
- Delay large attacks until the player has had enough time to capture a site, build a Barracks, or survive at least the first few minutes.
- Keep the logic framed as scenario pacing rather than a visible invulnerability rule.

## Enemy AI

Main file:

- `src/game/systems/EnemyAIController.ts`

The AI remains simple and has not been rewritten. It now consumes map config, battle phase data, difficulty presets, and tutorial protection.

Current behavior categories:

- Gains scaled income on an interval.
- Trains units from enemy barracks.
- Expands toward capture sites.
- Defends owned buildings.
- Forms attack waves.
- Gates commander participation until later.
- Emits battle alerts and minimap pings for incoming attacks.

Known AI limits:

- No strategic build orders.
- Enemy buildings are prebuilt.
- Enemy does not use the player-style construction system yet.
- No fog of war.
- No long-term adaptive planning.

## Player Starting Situation

Core constants live in:

- `src/game/data/Constants.ts`

Current starting player resources:

- Crowns: `360`
- Stone: `240`
- Iron: `130`
- Aether: `70`

Player Command Hall:

- HP: `1450`
- Armor: `4`

The player is expected to have enough resources to place at least one production building and begin training without waiting for a perfect economy opening.

## Resources

Resource IDs:

- `crowns`
- `stone`
- `iron`
- `aether`

Capture sites generate resources over time. Resource site definitions live in map data. Content validation checks that capture site resource IDs are valid.

## Buildings

Building definitions live in:

- `src/game/data/buildings.ts`

Current building IDs:

- `command_hall`
- `barracks`
- `mystic_lodge`
- `watchtower`
- `enemy_stronghold`
- `enemy_barracks`

### Command Hall

- Faction: Free Marches
- HP: `1450`
- Armor: `4`
- Construction time: `0`
- Build options: Barracks, Mystic Lodge, Watchtower
- Upgrade options: Infantry Weapons I, Reinforced Armor I
- Losing it causes defeat.

### Barracks

- Cost: `180 crowns`, `120 stone`
- HP: `600`
- Armor: `3`
- Construction time: `25` seconds
- Trains: Militia, Ranger
- Upgrade options: Ranger Training I

### Mystic Lodge

- Cost: `160 crowns`, `100 stone`, `80 aether`
- HP: `450`
- Armor: `2`
- Construction time: `30` seconds
- Trains: Acolyte
- Upgrade options: Aether Study I

### Watchtower

- Cost: `120 crowns`, `100 stone`, `40 iron`
- HP: `350`
- Armor: `2`
- Construction time: `20` seconds
- Static attack:
  - Damage: `14`
  - Range: `220`
  - Cooldown: `1.1`

### Enemy Stronghold

- HP: `1000`
- Armor: `4`
- Construction time: `0`
- Destroying it wins the battle.

### Enemy Barracks

- HP: `550`
- Armor: `3`
- Construction time: `0`
- Trains enemy units: Raider, Hexer, Brute

## Construction System

Construction state was added to make base building feel like an RTS rather than instant placement.

Relevant types:

- `BuildingConstructionState`
- `constructionState`
- `constructionProgress`
- `constructionTimeSeconds`

States:

- `planned`
- `underConstruction`
- `completed`

Current behavior:

- Player places a preview first.
- If valid, resources are paid and a building entity is created under construction.
- Under-construction buildings are visually tinted/transparent.
- Under-construction buildings have reduced or unavailable functionality.
- Training, research, attacks, and build options are disabled until completion.
- Construction progresses automatically over time.
- Buildings become fully functional when complete.

Construction times:

- Barracks: `25` seconds
- Mystic Lodge: `30` seconds
- Watchtower: `20` seconds
- Command Hall and enemy scenario buildings: `0` seconds

Worker units have not been added. Construction is automatic by design for now.

## Building Placement UX

Placement behavior:

- Valid placement preview.
- Invalid placement preview.
- Esc cancels placement.
- Placement checks resource cost before committing.
- Placement checks terrain and collision constraints.
- Placement checks distance from owned buildings.

Invalid reasons shown to the player include:

- Insufficient resources
- Blocked terrain
- Too far from owned building
- Overlaps another structure
- Not buildable terrain

Current build radius from owned buildings:

- `560`

## Training Queues

Training system file:

- `src/game/systems/TrainingSystem.ts`

Current behavior:

- Barracks and Mystic Lodge support production queues.
- Unit costs are paid when queued.
- Queue progress is visible in the selected building panel.
- Units spawn when training completes.
- Queue cancellation is supported where simple.
- Cancellation refunds the queued cost.
- Unfinished buildings cannot train.

Known limits:

- Queue UI is functional but still utilitarian.
- No rally points yet.
- No multi-building production overview yet.

## Tech Prerequisites

Prerequisite foundation exists for:

- Units
- Buildings
- Upgrades
- Future abilities

Current prerequisite fields can include:

- Required building IDs
- Required upgrade IDs
- Required hero level

Current use:

- Acolyte requires Mystic Lodge.
- Ranger is tied to Barracks availability.
- Upgrades require appropriate buildings.
- Future abilities can use hero level or structure requirements.

Locked buttons should show reasons when prerequisites are unmet.

## Upgrade System

Upgrade definitions live in:

- `src/game/data/upgrades.ts`

Upgrade queue/research system:

- `src/game/systems/UpgradeSystem.ts`

Upgrade effects helper:

- `src/game/systems/UpgradeEffects.ts`

Current upgrades:

### Infantry Weapons I

- Cost: `120 crowns`, `70 iron`
- Research time: `18` seconds
- Prerequisite: Command Hall
- Effect: Militia and Raider-style melee units gain `+10%` damage.

### Ranger Training I

- Cost: `120 crowns`, `60 iron`
- Research time: `20` seconds
- Prerequisite: Barracks
- Effect: Ranger gains `+10%` range and faster attack cooldown through a `0.9` cooldown multiplier.

### Reinforced Armor I

- Cost: `130 crowns`, `70 stone`, `50 iron`
- Research time: `22` seconds
- Prerequisite: Command Hall
- Effect: Militia, Ranger, and Acolyte gain `+1` armor.

### Aether Study I

- Cost: `100 crowns`, `90 aether`
- Research time: `24` seconds
- Prerequisite: Mystic Lodge
- Effects:
  - Acolyte gains `+10%` damage.
  - Hero mana regen is multiplied by `1.25`.

Upgrade limitations:

- Upgrade UI is basic.
- No upgrade icons yet.
- No multi-tier upgrade chains yet.
- Enemy upgrades are not a focus yet.

## Units

Unit definitions live in:

- `src/game/data/units.ts`

Current player-side trainable units:

- Militia
- Ranger
- Acolyte

Current enemy units:

- Raider
- Hexer
- Brute
- Enemy Commander

Neutral units/camps exist in map data and unit data. Content validation checks referenced unit IDs.

Training and combat stats are data-driven. Upgrade and item systems can modify effective stats in battle.

## Heroes

Hero data lives in:

- `src/game/data/heroes.ts`

The current hero save supports:

- Hero name
- Class ID
- Origin ID
- Level
- XP
- Skill points
- Unlocked abilities
- Completed battles
- Cleared map IDs
- Inventory
- Equipment
- Allocated skills
- Faction reputation
- Stats

Hero battle entity:

- `src/game/entities/Hero.ts`

Equipment effects are applied to hero battle stats when the hero enters combat.

## Hero Progression

Progression rules live in:

- `src/game/core/HeroProgressionRules.ts`

Responsibilities include:

- XP gain.
- Level-up thresholds.
- Skill point gain.
- Item reward grants.
- Equipment stat calculations.
- Battle reward rolling.
- Legacy deterministic reward helper support.

The system still aims to be simple enough for deterministic tests.

## Items and Loot

Item data lives in:

- `src/game/data/items.ts`

Reward tables live in:

- `src/game/data/rewards.ts`

Item types support:

- `id`
- `name`
- `rarity`
- `slot`
- `description`
- `statMods`
- `classAffinity`
- `factionOrigin`
- `iconAssetKey`
- `flavorText`
- `tags`

Equipment slots:

- `weapon`
- `armor`
- `trinket`
- `relic`

Rarities:

- `common`
- `uncommon`
- `rare`
- `epic`
- `legendary`

Current item catalog contains 15 items:

- Weathered Command Sword
- Emberglass Wand
- Pilgrim Crook
- Scout's Bow
- Marcher Plate
- Runewoven Robes
- Dawnward Vestments
- Captain's Seal
- Aether Lens
- Green Chapel Icon
- Fordbreaker Halberd
- Ashbound Censer
- Oathbound Aegis
- Starfall Prism
- Ascendant Signet

Reward tables support:

- Guaranteed item IDs
- Weighted item pools
- Resource rewards
- XP rewards
- Map-specific rewards
- First-clear bonuses
- Repeat-clear rewards
- Deterministic item IDs for tests and compatibility

Current reward behavior:

- Victory rolls rewards using the battle's reward table.
- First clears use first-clear bonus logic.
- Repeat clears use repeat-clear reward logic.
- Earned items are added to inventory.
- XP rewards feed hero progression.
- Result data includes XP progress and level-up information.

Known loot limitations:

- No item instance IDs yet.
- No randomized affixes.
- No duplicate conversion.
- No item icons are displayed yet.
- Resource rewards are displayed but are not yet part of a persistent campaign resource bank.

## Inventory and Equipment UI

Main file:

- `src/game/scenes/HeroProgressionScene.ts`

The Hero Inventory screen now shows:

- Hero summary.
- Hero stats.
- Equipped weapon, armor, and trinket.
- Inventory list.
- Item rarity.
- Item description.
- Flavor text.
- Tags.
- Stat preview.
- Equip and unequip actions.

Equipped items affect battle hero stats, including supported modifiers such as:

- Damage
- Armor
- HP
- Mana
- Might
- Arcana
- Command
- Faith
- Speed where relevant

## Results Screen

Main file:

- `src/game/scenes/ResultsScene.ts`

The results screen now supports:

- Victory and defeat states.
- Survival time.
- Map name.
- Difficulty.
- First captured site status.
- Buildings built.
- Units trained.
- Enemy waves survived.
- XP gained.
- Reward items.
- Rarity display.
- XP progress.
- Skill points gained on level-up.
- Defeat tips.
- Campaign-aware retry and campaign-map return flow.

The victory reward screen offers item reward visibility. Equipping directly from results was started as a UX direction, but verify exact current behavior before promising a polished final flow.

## Save System

Save system file:

- `src/game/core/SaveSystem.ts`

Save type file:

- `src/game/save/SaveTypes.ts`

Local storage key:

- `ascendant-realms-save-v1`

Current `StoredGameSave` shape:

```ts
{
  version: 1;
  hero: HeroSaveData;
  campaign: CampaignSaveData;
  updatedAt: number;
}
```

Hero save includes:

- `heroName`
- `classId`
- `originId`
- `level`
- `xp`
- `skillPoints`
- `unlockedAbilities`
- `completedBattles`
- `clearedMapIds`
- `inventory`
- `equipment`
- `allocatedSkills`
- `items` as a legacy compatibility field
- `factionReputation`
- `stats`

Campaign save includes:

- `started`
- `difficulty`
- `completedNodeIds`
- `unlockedNodeIds`
- `nodeRewardsClaimedIds`
- `selectedNodeId`

SaveSystem helpers include:

- `load`
- `saveHero`
- `saveCampaign`
- `saveGame`
- `clear`
- `createFallbackHeroSave`
- `createFallbackCampaignSave`
- normalization helpers for older saves

Compatibility behavior:

- Older hero saves with legacy `items` are normalized into inventory.
- Missing campaign data is normalized into a fallback campaign save.
- `saveHero` preserves existing campaign data.

## Battle Runtime

Main files:

- `src/game/battle/BattleRuntime.ts`
- `src/game/battle/BattleRuntime.test.ts`

Battle runtime tracks:

- Hero save.
- Map definition.
- Difficulty.
- Result stats.
- Resource and production state.
- Reward table result on victory.
- Campaign node context when applicable.

Tracked result details include:

- Survival time.
- First site captured.
- Buildings built.
- Units trained.
- Enemy waves survived.
- XP gained.
- Reward items.
- Level-up summary.

## Battle Scene

Main file:

- `src/game/scenes/BattleScene.ts`

BattleScene responsibilities:

- Load a battle launch request.
- Create map terrain, buildings, units, hero, capture sites, and neutral camps.
- Wire systems together.
- Run the simulation update loop.
- Handle battle alerts.
- Handle victory/defeat.
- Save hero and campaign state when needed.
- Open ResultsScene.

Recent systems integrated here:

- Data-driven battle difficulty.
- Data-driven maps.
- Construction and building placement.
- Training queues.
- Upgrade queue/research.
- Live minimap pings.
- Tutorial hints and alerts.
- Campaign victory/defeat flow.
- Reward table results.

This file is large and should not absorb every future feature. Prefer adding focused helpers or systems when new behavior becomes self-contained.

## Battle Feedback and Tutorial Hints

Current battle alerts include messages such as:

- Enemy scouts are moving.
- Enemy forces are gathering.
- Enemy attack incoming.
- Your Command Hall is under attack.
- Capture resource sites to grow your army.
- Build a Barracks to train troops.

First-match hint sequence exists to guide:

- Select your hero.
- Move to the Crown Shrine.
- Capture the Crown Shrine.
- Select Command Hall.
- Build Barracks.
- Train Militia.
- Defend against the first attack.
- Destroy the enemy Stronghold.

The hints are meant to be non-intrusive and scenario-flavored.

## HUD and Selected Building UI

HUD file:

- `src/game/ui/HUD.ts`

CSS:

- `src/game/styles/ui.css`

Selected building panel should show:

- Construction progress if incomplete.
- Available train buttons if complete.
- Queue.
- Upgrade options if available.
- Locked items with reasons.

The panel is functional, but it is still a prototype UI. Keep future changes readable and compact because the player is managing real-time combat while using it.

## Minimap

Main minimap view:

- `src/game/ui/MinimapView.ts`

HUD integration:

- `src/game/ui/HUD.ts`

The minimap is now a live RTS minimap rather than static symbolic art.

Current minimap features:

- Player units.
- Enemy units.
- Neutral units and camps.
- Player buildings.
- Enemy buildings.
- Capture sites.
- Camera viewport rectangle.
- Map bounds.
- Alert pings.
- Click-to-center camera.

Color conventions:

- Player: green/blue.
- Enemy: red.
- Neutral: yellow/brown.
- Capture sites: resource-colored or pale outline.
- Camera viewport: pale frame.

Alert pings:

- Player base under attack.
- Resource site attacked.
- Enemy wave incoming.

Fog compatibility:

- Fog of war is not implemented.
- The minimap has been structured so a future visibility/fog layer can filter or dim entities without rewriting the whole HUD.

Performance:

- Minimap updates are throttled rather than fully redrawn every possible moment.

## Content Validation

Content validation file:

- `src/game/data/contentValidation.ts`

Tests:

- `src/game/data/contentValidation.test.ts`

Validation covers:

- Map-referenced unit IDs.
- Map-referenced building IDs.
- Capture resource IDs.
- AI config unit references.
- Objective building references.
- Reward table item references.
- Campaign node map IDs.
- Campaign node enemy faction IDs.
- Campaign node prerequisites and unlocks.
- Campaign node reward item IDs.

Keep adding validation when new content types are made data-driven.

## Documentation Files

Primary documentation:

- `README.md`
- `DESIGN.md`
- `BALANCE.md`
- `CONTENT_GUIDE.md`
- `ROADMAP.md`
- `TECHNICAL_AUDIT.md`
- `LLM_GAME_HANDOFF.md`

Recent docs were updated for:

- First battle pacing and difficulty.
- Construction and RTS base building.
- Minimap controls.
- Multiple skirmish maps.
- Item rewards and loot philosophy.
- Campaign skeleton and node authoring.

This handoff should be treated as the highest-level orientation doc, not a replacement for the source or detailed design docs.

## Assets

Asset policy:

- Do not add new art unless explicitly requested.
- Current work has focused on systems and DOM/Phaser visuals.
- Use the existing generated/available assets where possible.

Relevant command:

```powershell
npm run assets:refresh
```

The asset gallery is available from the main menu.

## Current Tests

Known tests after the recent systems:

- Battle launch request tests.
- Battle runtime tests.
- Battle pacing tests.
- Campaign rules tests.
- Content validation tests.
- Hero progression rules tests.
- Save system tests.

Recent passing count from the prior full run:

- 13 test files.
- 47 tests.

Run `npm test` after any implementation change.

## Git State and Caution

The repository is connected to GitHub, but the current local worktree is dirty.

At the time of this handoff, modified files included:

- `BALANCE.md`
- `CONTENT_GUIDE.md`
- `DESIGN.md`
- `README.md`
- `ROADMAP.md`
- `src/game/battle/BattleLaunchRequest.test.ts`
- `src/game/battle/BattleLaunchRequest.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/battle/BattleRuntime.ts`
- `src/game/config.ts`
- `src/game/core/GameTypes.ts`
- `src/game/core/HeroProgressionRules.test.ts`
- `src/game/core/HeroProgressionRules.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/core/SaveSystem.ts`
- `src/game/core/SceneKeys.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/data/contentIndex.ts`
- `src/game/data/contentValidation.test.ts`
- `src/game/data/contentValidation.ts`
- `src/game/data/heroes.ts`
- `src/game/data/items.ts`
- `src/game/data/rewards.ts`
- `src/game/entities/Hero.ts`
- `src/game/save/SaveTypes.ts`
- `src/game/scenes/BattleScene.ts`
- `src/game/scenes/HeroCreationScene.ts`
- `src/game/scenes/HeroProgressionScene.ts`
- `src/game/scenes/MainMenuScene.ts`
- `src/game/scenes/ResultsScene.ts`
- `src/game/styles/ui.css`

Untracked files included:

- `src/game/core/CampaignRules.test.ts`
- `src/game/core/CampaignRules.ts`
- `src/game/scenes/CampaignMapScene.ts`

This handoff file itself is also modified by this update.

Do not run destructive git commands. Do not reset or checkout over these changes unless the user explicitly asks.

## Current Known Limitations

Major known limitations:

- Campaign is a skeleton, not a full strategic layer.
- Non-battle campaign nodes resolve instantly.
- No campaign resource bank.
- No shops or vendors.
- No campaign dialogue.
- No fog of war.
- No rally points.
- No workers.
- Enemy does not construct buildings.
- Enemy AI is paced but still simple.
- Item system has no instance IDs, affixes, duplicate handling, or icon UI.
- Results equip-now flow should be verified before relying on it.
- Minimap does not hide unknown information because fog is not implemented.
- Browser smoke testing was blocked by Browser Use availability in the prior run.

## Manual QA Checklist

After the next implementation pass, manually verify:

1. Main menu opens without save.
2. New Campaign creates a hero and opens the campaign map.
3. Border Village is available at campaign start.
4. Locked campaign nodes cannot be launched.
5. Border Village launches a battle on First Claim.
6. Victory completes Border Village and unlocks Old Stone Road.
7. Defeat allows retry or return to campaign map.
8. Continue Campaign returns to saved campaign progress.
9. Skirmish opens setup instead of campaign.
10. First Claim and Broken Ford both launch from skirmish setup.
11. Difficulty selection affects enemy pacing.
12. Player can place Barracks, Mystic Lodge, and Watchtower.
13. Unfinished buildings cannot train units.
14. Completed Barracks can queue Militia and Ranger.
15. Completed Mystic Lodge can queue Acolyte.
16. Queue cancellation refunds cost.
17. Upgrades can be researched from eligible buildings.
18. Locked buttons show sensible reasons.
19. Minimap shows live units, buildings, sites, and camera viewport.
20. Clicking the minimap recenters the camera.
21. Base attack and enemy wave alerts create minimap pings.
22. Victory grants XP and item rewards.
23. Inventory displays earned items.
24. Equipping items changes hero stats.
25. Equipped item stats apply in battle.
26. Reset Save returns the game to a clean state.

## Suggested Next Work

Best next steps, in priority order:

1. Commit the current local feature set after rerunning `npm test` and `npm run build`.
2. Browser-smoke the menu to campaign to battle to results loop once Browser Use is available.
3. Polish ResultsScene reward actions and verify equip-now behavior.
4. Add a persistent campaign resource bank or explicitly remove displayed campaign resource reward ambiguity.
5. Add rally points for production buildings.
6. Add lightweight fog of war using the minimap-compatible visibility layer.
7. Improve campaign node presentation with event text and small choices.
8. Add item instance IDs before randomized affixes or duplicate item rewards become important.
9. Make enemy construction a future AI milestone only after player construction is stable.

## Principle for Future LLMs

Preserve the current direction:

- Keep content data-driven.
- Keep campaign and skirmish separate.
- Keep the first battle readable and fair.
- Prefer small systems over expanding `BattleScene` forever.
- Do not add campaign complexity before the skeleton is stable.
- Do not add new art unless the user asks.
- Verify with tests and build after code changes.
- Respect the dirty worktree and never revert user or prior-agent changes without explicit instruction.
