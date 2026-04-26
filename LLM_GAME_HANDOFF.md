# Ascendant Realms LLM Handoff

Last updated: 2026-04-26 19:34 -04:00

## Current Project Identity

Ascendant Realms is a Phaser 3, TypeScript, and Vite browser-game prototype for a fantasy RTS/RPG hybrid.

The current playable loop is:

1. Create or load a persistent hero.
2. Enter the Border Marches mini-campaign or a standalone skirmish.
3. Play an RTS battle with hero abilities, capture sites, construction, training queues, upgrades, rally points, pathfinding, fog of war, live minimap, and enemy pressure waves.
4. Resolve victory or defeat through a shared Results scene.
5. Persist hero XP, skill points, inventory item instances, equipment, campaign node progress, event choices, town purchases, campaign modifiers, campaign resources, and user settings in localStorage.

This is still a prototype, but it now has a broad playable RTS/RPG spine. The current local worktree also contains uncommitted changes from multiple major passes. Preserve them unless the user explicitly asks otherwise.

## Current Command List

Run these from the project root:

```bash
npm install
npm run dev
npm test
npm run build
npm run preview
npm run test:e2e
npm run test:e2e:headed
npm run assets:prompts
npm run assets:ui-kit
npm run assets:process-battle-sprites
npm run assets:manifest
npm run assets:validate
npm run assets:refresh
```

Notes:

- `npm run test:e2e` starts the Vite dev server through Playwright.
- `npm run assets:refresh` runs battle sprite processing, manifest rebuild, and asset validation. It is only needed after asset registry, manual art, processed sprite, or manifest input changes.
- Current e2e suite is intentionally one worker for stability.

## Latest Verified Status

Latest verification from the battle selection indicator polish:

- `npm test`: passed, 25 test files, 117 tests.
- `npm run build`: passed.
- `npm run test:e2e -- --reporter=line`: passed, 25 Playwright tests.
- Playwright screenshot check: selected units in Border Village now use flat ground-footprint ellipses instead of upright circles; screenshot saved at `test-results/ui-audit/selection-rings-after.png`.

Build warning:

- Vite still reports the known large-chunk warning for the main Phaser bundle. This is not a failing build.

Tool note:

- A plain `npm run test:e2e` command once hit a 5-minute shell-tool timeout without returning output. The suite was then rerun with a longer timeout and passed.
- Browser Use was requested during recent UI/playtest turns, but the required Node REPL bridge was not exposed by tool discovery in this session. Playwright against `http://127.0.0.1:5173/` was used for screenshot and pointer-click verification instead.

## Current Scenes

Scene keys live in `src/game/core/SceneKeys.ts`.

- `BootScene`: loads manifests/assets and enters the menu.
- `MainMenuScene`: New Campaign, Continue Campaign, Skirmish, Hero Inventory, Asset Gallery, Settings, Reset Save, Credits / Info.
- `SettingsScene`: audio, accessibility, UI scale, fog override, minimap palette, and keyboard reference.
- `HeroCreationScene`: hero name/class/origin creation, then campaign or skirmish handoff.
- `CampaignMapScene`: campaign node map, hero summary, campaign bank, reputation, modifiers, selected node details, event choices, town services, campaign battle launch.
- `SkirmishSetupScene`: map selection, hero summary, difficulty selection, enemy faction placeholder, AI personality selection, start battle.
- `BattleScene`: main RTS runtime and Phaser entity orchestration.
- `ResultsScene`: victory/defeat summary, rewards, Equip Now, retry/return flow.
- `HeroProgressionScene`: inventory/equipment and skill allocation.
- `AssetGalleryScene`: local/manual asset inspection.

## Current Campaign Flow

Campaign data lives in `src/game/data/campaignNodes.ts`. Rules live in `src/game/core/CampaignRules.ts`.

The Border Marches mini-campaign currently has eight nodes:

- `border_village`: battle, Easy, First Claim, available at start.
- `old_stone_road`: battle, Easy, First Claim, unlocks after Border Village.
- `marcher_camp`: town/services node, unlocks after Old Stone Road and remains reusable.
- `aether_well_ruins`: battle, Normal, Broken Ford, unlocks after Old Stone Road.
- `bandit_hillfort`: battle, Normal, Broken Ford, unlocks after Old Stone Road.
- `chapel_of_the_marches`: shrine/event choices, unlocks after Aether Well Ruins.
- `refugee_caravan`: event choices, unlocks after Old Stone Road.
- `ashen_outpost`: battle, Normal, dedicated Ashen Outpost fortress map, requires Bandit Hillfort and Chapel of the Marches.

Campaign node state is saved, not stored on node definitions. Nodes can be locked, available, or completed. Battle nodes launch through `createCampaignBattleLaunchRequest`, using the same `BattleLaunchRequest` pathway as skirmish.

On campaign battle victory:

- `BattleRuntime` grants battle rewards.
- Map-specific secondary objective completions are preserved in battle stats.
- `ResultsScene` applies campaign node completion.
- One-time node rewards are applied if not already claimed.
- Campaign resources are added to the persistent campaign bank.
- Unique duplicate item rewards convert into campaign resources.
- Hero and campaign state are saved.
- The player can return to the campaign map.

On campaign battle defeat:

- Rewards are not granted.
- Campaign node completion is not granted.
- Secondary objective progress is displayed only as part of that battle result and does not persist.
- The player can retry the battle or return to the campaign map.

## Current Skirmish Flow

Skirmish mode remains separate from campaign mode.

Flow:

1. Main Menu -> Skirmish.
2. If no playable hero save exists, create a hero first.
3. `SkirmishSetupScene` shows map selection, hero summary, difficulty selection, enemy faction placeholder, AI personality selection, and Start Battle.
4. Start Battle creates a skirmish `BattleLaunchRequest`.
5. `BattleScene` resolves the selected map and reward table.
6. `ResultsScene` shows victory/defeat, rewards, Equip Now, and return/retry options.

Skirmish victories can grant map reward-table item instances, XP, and first-clear/repeat-clear rewards.

## Current Maps

Map data has been split into per-map modules:

- `src/game/data/maps/firstClaim.ts`
- `src/game/data/maps/brokenFord.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/maps/index.ts`
- `src/game/data/maps.ts` remains a compatibility barrel export.

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
- Four capture sites: Burned Shrine, West Supply Pyre, South Iron Pit, North Stone Scar.
- Three neutral camps: West Cinder Pack, North Ash Imps, Shrine Ember Guardians.
- Enemy fortress includes Enemy Stronghold, Enemy Barracks, and two enemy Watchtower spawns as defensive tower placeholders.
- Campaign node uses Ashen Covenant plus Hexfire Cult personality on Normal difficulty.
- Reward table: `ashen_outpost_rewards`.
- Special objectives:
  - Primary: destroy the Ashen Stronghold.
  - Secondary: capture the Burned Shrine.
  - Secondary: destroy Enemy Barracks.
  - Secondary: defeat the Outpost Captain / Ashen Commander.

## Current Hero System

Hero data lives in `src/game/data/heroes.ts`, `heroClasses.ts`, `origins.ts`, `abilities.ts`, and `skillTrees.ts`.

Current hero classes:

- Warlord
- Arcanist
- Shepherd

Current origins:

- Exiled Noble
- Temple Orphan
- Wildland Raider

Hero save data tracks:

- name, class, origin
- level and XP
- skill points
- unlocked abilities
- completed battles
- cleared map IDs
- inventory item instances
- equipment instance IDs
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
- optional `unique` flag

Equipment slots:

- weapon
- armor
- trinket
- relic is typed for future use but not fully active in the default UI loop.

Inventory model:

- Item catalog definitions remain static.
- The save inventory stores item instances with `instanceId`, `itemId`, `acquiredAt`, `source`, `affixes`, and optional locked/favorite flags.
- Equipment references item instance IDs where possible.
- Legacy saves with catalog IDs in inventory/equipment migrate into item instances.
- If legacy equipment points at a catalog ID not present in inventory, normalization creates a safe `legacy_equipped` instance.
- Unique duplicate rewards convert into campaign resources. Common/uncommon duplicates convert to Crowns; rare/epic/legendary duplicates convert to Aether. Non-unique duplicates remain separate instances.

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
- `ashen_outpost_rewards`: milestone pool, higher XP/resources, one weighted roll, first-clear Ashbound Censer, rare/epic chase items, and legendary Ascendant Signet as a repeat-clear chase.

`HeroProgressionScene` shows inventory and equipment. `ResultsScene` shows earned items and supports Equip Now through `src/game/core/ResultsFlow.ts` plus result helper modules.

Equip Now:

- checks the earned reward instance exists in inventory
- equips the instance to the item's slot
- recalculates hero stats
- saves updated hero/campaign state
- shows stat deltas and current equipped replacement context

Known limitation: item instances currently have placeholder affix arrays only. Randomized affixes, durability, crafting, and full item-icon presentation are future work.

## Current Campaign Resource Bank

Campaign resources are saved separately from temporary battle resources.

Bank resources:

- crowns
- stone
- iron
- aether

Campaign resources are stored on `CampaignSaveData.resources`. They are displayed in `CampaignMapScene`, added by campaign node rewards and event choices, and spent by campaign event choices and Marcher Camp services. They are intended to later support shops, mercenaries, repairs, upgrades, stronghold development, and node choices.

`CampaignSaveData.resourcesSpent` tracks campaign spending totals.

## Current Campaign Event, Choice, And Town Service System

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
- lock node IDs
- campaign modifiers
- once-only behavior
- whether the choice completes the node

Supported requirements:

- campaign resource thresholds
- hero level
- completed campaign node IDs
- owned item IDs, resolved through item instances
- faction reputation

Supported effects:

- campaign resource costs
- XP rewards
- item rewards
- campaign resource rewards
- faction reputation changes
- unlock/lock node IDs
- campaign modifiers
- remove campaign modifiers
- recover hero placeholder
- complete or keep the node open

Once-only choices are saved in `CampaignSaveData.choiceIdsClaimed` using `nodeId:choiceId`. Town service claims and usage counts are saved separately.

Current event/town nodes:

- Chapel of the Marches: Pray for Strength, Repair the Chapel, Ask for Guidance.
- Refugee Caravan: Protect Them, Recruit Volunteers, Demand Tribute.
- Marcher Camp: repeatable Rest and Recovery, Hire Volunteers, Buy Supplies, plus one-time item purchases for Emberglass Wand, Marcher Plate, and Green Chapel Icon.

## Current Campaign Modifiers And Reputation

Faction reputation is stored on the hero save and clamped from -100 to +100.

Current reputation entries:

- Free Marches
- Ashen Covenant
- Sylvan Concord
- Common Folk
- Old Faith

Campaign modifiers live in `src/game/data/campaignModifiers.ts`. They can be granted by choices/services, saved in `CampaignSaveData.activeModifierIds`, applied at battle launch, and consumed when appropriate.

Current modifier examples:

- Inspired Militia: next battle starts with one extra Militia.
- Blessed Road: next battle hero gets a mana-related bonus.
- Angered Raiders: next matching Ashen battle receives extra pressure.
- Local Support: campaign resource rewards can be boosted.
- Well Rested: next battle hero starts with a max-HP bonus.

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

Default battle difficulty is currently `normal`; fallback campaign save difficulty is `easy`.

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
- `sylvan_concord`: future placeholder faction with early identity hooks and item origins, but not yet playable or fully implemented.

Ashen-specific mechanics currently implemented:

- `hexfire_burn`: burn status effect applied by relevant Ashen modifiers, with damage over time and floating feedback.
- `ashen_fury`: low-health damage pressure trait.
- `smoke_march`: wave movement-speed modifier for matching Ashen units.

Faction validation checks unit, building, upgrade, AI personality, reputation hook, and modifier references.

## Current Construction, Building, Training, And Rally System

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

Recent building-command feedback fix:

- Build buttons now carry the source building ID through the HUD callback path.
- Clicking a build command starts placement with the source building as the anchor.
- The placement ghost immediately appears near the source building on a valid nearby site when one is found, instead of starting off-screen at `(0, 0)`.
- The status line immediately shows `Placing <building> - click a highlighted site or choose another location.`
- Pointer-hovering the battlefield still updates valid/invalid placement reasons from `BuildingPlacementRules`.
- E2E now verifies Build Barracks creates a visible placement ghost near the Command Hall before cancellation.

Training lives in `src/game/systems/TrainingSystem.ts`.

Training behavior:

- only completed production buildings can train
- resources are paid when queued
- queues track remaining/total time
- canceling a queued unit refunds paid cost
- completed units spawn near the production building
- spawned units receive the source building rally command when present

Rally-point pure logic lives in `src/game/systems/RallyPointSystem.ts`.

Current rally behavior:

- completed friendly production buildings can hold `rallyPoint` and optional `rallyTargetId`
- right-click ground with completed Barracks or Mystic Lodge selected sets rally for selected production buildings
- a world marker is shown for selected production building rally points
- selected production building rally points appear on the minimap
- newly trained units automatically receive a move command to the rally point
- rally points do not persist between battles
- rally target IDs are present for future capture-site or enemy-objective rallying, but ground rally is the only implemented behavior

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
- Settings can force fog enabled, force fog disabled, or leave it on difficulty default

Known limitation: fog is not blocker-aware and does not do line-of-sight around terrain.

## Current Minimap Behavior

Minimap rendering lives in `src/game/ui/MinimapView.ts`. `BattleScene` builds minimap snapshots through `src/game/battle/BattleSceneSnapshots.ts`.

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

Accessibility:

- Settings can enable a colorblind-friendly minimap palette.

Known limitation: no drag-to-pan, no last-known enemy icons, and no fog memory for enemy positions.

## Current Settings, Audio, And Accessibility Foundation

Settings data lives in `src/game/core/Settings.ts` and `src/game/save/SaveTypes.ts`. The screen is `src/game/scenes/SettingsScene.ts`. Audio is `src/game/systems/AudioManager.ts`.

Current settings:

- `masterVolume`: 0-1, default 0.8
- `musicVolume`: 0-1, default 0.55
- `sfxVolume`: 0-1, default 0.75
- `screenShakeEnabled`: default true
- `floatingTextEnabled`: default true
- `fogEnabledOverride`: `default`, `enabled`, or `disabled`
- `reducedMotionEnabled`: default false
- `uiScale`: clamped 0.85-1.25, default 1
- `colorblindMinimapPalette`: default false

Settings behavior:

- Main Menu has a Settings button.
- Settings can be saved before or after hero creation.
- Saving settings before hero creation creates a settings-only save marker; starting a real campaign/skirmish preserves settings and clears the marker.
- `applySettingsToDocument` sets CSS variables/dataset flags for UI scale, reduced motion, and minimap palette.
- `FloatingText` respects `floatingTextEnabled` and `reducedMotionEnabled`.
- `BattleScene` respects fog override and minimap colorblind palette.

Audio behavior:

- `AudioManager` uses small generated WebAudio tones.
- Cues currently exist for UI click, unit selected, build started, build complete, unit trained, ability cast, victory, and defeat.
- Audio fails silently if browser/test environment blocks or lacks WebAudio.
- `musicVolume` is saved but reserved until music exists.
- `screenShakeEnabled` is saved but there is no active screen-shake system to gate yet.

Settings UI includes a compact keyboard controls reference.

## Current Objective Tracking

Primary battle objectives are still simple base survival/destruction:

- player loses if the Command Hall objective building dies
- player wins if the enemy Stronghold objective building dies

Maps can define optional `secondaryObjectives` under `scenario.objectives`.

Supported secondary objective types:

- `capture_site`
- `destroy_building`
- `defeat_unit`

Runtime tracking lives in `BattleRuntime.stats.completedObjectiveIds`. `BattleScene` records secondary objectives from capture and kill hooks. `ResultsScene` displays completion status for maps that define special objectives. Current secondary objectives are informational only; they do not yet alter rewards, campaign unlocks, or score.

## Current Save Format

Save key is defined in `src/game/core/Constants.ts`. Save logic lives in `src/game/core/SaveSystem.ts`. Save types live in `src/game/save/SaveTypes.ts`.

Stored saves are versioned. V1 is accepted as legacy input; V2 is the current write shape.

```ts
interface StoredGameSaveV2 {
  version: 2;
  createdAt: string;
  updatedAt: string;
  hero: HeroSaveData;
  campaign: CampaignSaveData;
  settings: SaveSettingsData;
  statistics: SaveStatisticsData;
}
```

Current `SaveSettingsData`:

```ts
interface SaveSettingsData {
  masterVolume: number;
  musicVolume: number;
  sfxVolume: number;
  screenShakeEnabled: boolean;
  floatingTextEnabled: boolean;
  fogEnabledOverride: "default" | "enabled" | "disabled";
  reducedMotionEnabled: boolean;
  uiScale: number;
  colorblindMinimapPalette: boolean;
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
- inventory as item instances
- equipment as item instance IDs where possible
- allocatedSkills
- legacy `items` migration input
- factionReputation
- stats

Campaign save:

- started
- difficulty
- resources
- resourcesSpent
- completedNodeIds
- unlockedNodeIds
- lockedNodeIds
- nodeRewardsClaimedIds
- choiceIdsClaimed
- townServiceClaimedIds
- townServiceUseCounts
- activeModifierIds
- selectedNodeId

Save normalization:

- current save version is 2
- `migrateSaveToCurrent(input)` accepts valid V1 or V2 saves and returns a normalized V2 save
- `migrateV1ToV2(input)` converts legacy V1 saves without dropping campaign resources, inventory, equipment, reward claims, or choice claims
- invalid JSON and invalid save shapes return `null` without clearing or overwriting localStorage
- new writes always use the V2 shape with `createdAt`, `updatedAt`, settings, and statistics
- `SaveSystem.exportSaveJson()` returns the current save JSON for backup/debugging
- `SaveSystem.importSaveJson(raw)` safely imports valid V1/V2 JSON and writes it as V2
- rejects invalid save versions or invalid hero base data
- migrates legacy `items` and raw catalog-ID inventories into item instances
- migrates legacy catalog-ID equipment to matching instances or creates a safe equipped instance
- normalizes missing campaign save to fallback
- normalizes missing campaign resources to zero
- normalizes missing settings to `DEFAULT_SETTINGS`
- preserves settings across later hero/campaign writes
- normalizes settings-only saves so the menu does not treat them as playable hero saves
- dedupes item instances by instance ID plus cleared maps, node rewards, unlocks, completions, and choice claims
- clamps negative numeric resources/stats where appropriate

## Current Results Scene Architecture

`ResultsScene` has been safely reduced to a coordinator. Helper modules live in `src/game/results/`.

Current results helper files:

- `ResultsCampaignFlow.ts`
- `ResultsEquipActions.ts`
- `ResultsFormatting.ts`
- `ResultsNavigation.ts`
- `ResultsObjectiveSummary.ts`
- `ResultsRewardPanel.ts`
- `ResultsTypes.ts`
- `ResultsViewModel.ts`
- `ResultsViewModel.test.ts`

`ResultsScene` still owns:

- Phaser scene lifecycle
- DOM root binding
- click routing
- calling helpers for view model/rendering/actions
- scene navigation

Behavior intentionally unchanged:

- Equip Now persists equipped reward instance.
- Victory grants rewards and campaign completion.
- Defeat does not grant rewards.
- Retry, campaign return, skirmish return, inventory, and main menu actions still work.

## Current CampaignMapScene Helper Architecture

`CampaignMapScene` has been reduced and now delegates view-model creation and panel rendering to helpers in `src/game/campaign/`.

Current campaign helper files:

- `CampaignChoicePanel.ts`
- `CampaignMapViewModel.ts`
- `CampaignMapViewModel.test.ts`
- `CampaignNavigation.ts`
- `CampaignNodePanel.ts`
- `CampaignPresentationTypes.ts`
- `CampaignResourcePanel.ts`
- `CampaignTownServicesPanel.ts`

`CampaignMapScene` still owns:

- Phaser scene lifecycle
- DOM root binding
- click routing
- selected node state
- applying choices/services through campaign rules
- save calls
- navigation to battle, inventory, and main menu

Behavior intentionally unchanged:

- Marcher Camp services and one-time purchases still work.
- Event choices still apply costs, rewards, reputation, modifiers, and completion state.
- Campaign battle launch still uses the shared `BattleLaunchRequest` path.
- Campaign bank, reputation, active modifiers, and selected node details still render through the same DOM surface.

## Current HeroProgressionScene Helper Architecture

`HeroProgressionScene` has been reduced and now delegates inventory, equipment, skill tree, comparison, and stat presentation to helpers in `src/game/progression/`.

Current progression helper files:

- `EquipmentPanel.ts`
- `HeroProgressionViewModel.ts`
- `HeroStatsPanel.ts`
- `InventoryPanel.ts`
- `ItemComparison.ts`
- `ItemComparison.test.ts`
- `SkillTreePanel.ts`

`HeroProgressionScene` still owns:

- Phaser scene lifecycle
- DOM root binding
- click routing
- equip/unequip actions
- skill allocation actions
- save persistence after progression changes
- navigation back to campaign/main menu

Behavior intentionally unchanged:

- Inventory still displays item instances.
- Equipment still references item instance IDs.
- Skill point spending persists.
- Item stat comparison formatting is covered by pure tests.

## Current BattleScene Helper Architecture

`BattleScene` remains the live Phaser coordinator, but helper modules live in `src/game/battle/`.

Current battle helper files:

- `BattleLaunchRequest.ts`
- `BattleRuntime.ts`
- `BattleSceneAlerts.ts`
- `BattleSceneMapRenderer.ts`
- `BattleSceneObjectives.ts`
- `BattleSceneResults.ts`
- `BattleSceneSnapshots.ts`
- `BattleSceneSpawner.ts`

`BattleScene` still owns:

- live Phaser scene lifecycle
- current units/buildings/projectiles/sites arrays
- system construction and wiring
- input callbacks
- fog overlay rendering
- rally marker graphics
- runtime update order
- audio/settings integration

Next safe refactor target here is system construction/wiring, which is still bulky.

## Current CSS Architecture

`src/game/styles/ui.css` is now a central import file. Domain CSS lives in:

- `asset-gallery.css`
- `base.css`
- `battle-feedback.css`
- `battle-hud.css`
- `campaign.css`
- `forms.css`
- `inventory.css`
- `main-menu.css`
- `minimap.css`
- `responsive.css`
- `results.css`
- `settings.css`

UI scale is handled through `--ui-scale` on `:root`; reduced-motion mode disables transitions/animations through a root dataset flag.

Recent battle HUD polish:

- Battle resource chips, hero card, selected-entity panel, minimap frame, status chip, and hint chip were visually lightened and tightened.
- Hero-selected state now uses a compact command panel for Damage, Range, Armor, and abilities; HP, mana, XP, and skill points remain in the persistent hero card.
- Building command buttons were simplified to clearer command rows.
- Mobile/tablet responsive rules were updated so hero-selected and building-selected panels remain inside the viewport.
- Screenshots from before/after battle HUD checks live under `test-results/ui-audit/`.

## Current Tests

Latest verified suite status:

- `npm test`: passed, 25 test files, 117 tests.
- `npm run build`: passed.
- `npm run test:e2e -- --reporter=line`: passed, 25 Playwright tests.

Current pure/unit test files:

- `src/game/ai/EnemyAIController.test.ts`
- `src/game/battle/BattleLaunchRequest.test.ts`
- `src/game/battle/BattleRuntime.test.ts`
- `src/game/campaign/CampaignMapViewModel.test.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/core/FirstExperienceGuidance.test.ts`
- `src/game/core/HeroProgressionRules.test.ts`
- `src/game/core/ResultsFlow.test.ts`
- `src/game/core/SaveSystem.test.ts`
- `src/game/data/aiPersonalities.test.ts`
- `src/game/data/battlePacing.test.ts`
- `src/game/data/campaignModifiers.test.ts`
- `src/game/data/contentValidation.test.ts`
- `src/game/progression/ItemComparison.test.ts`
- `src/game/results/ResultsViewModel.test.ts`
- `src/game/systems/AudioManager.test.ts`
- `src/game/systems/BuildingPlacementRules.test.ts`
- `src/game/systems/FogOfWarSystem.test.ts`
- `src/game/systems/PathfindingGrid.test.ts`
- `src/game/systems/PrerequisiteSystem.test.ts`
- `src/game/systems/RallyPointSystem.test.ts`
- `src/game/systems/StatusEffectSystem.test.ts`
- `src/game/systems/UpgradeEffects.test.ts`
- `src/game/systems/UpgradeSystem.test.ts`
- `src/game/ui/MinimapView.test.ts`

Current e2e test files:

- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/smoke.spec.ts`

Browser-level tests currently verify:

- main menu boots
- Settings opens and persists audio/accessibility options
- hero creation
- new campaign creation
- locked-node behavior
- Border Village battle launch
- campaign choices
- Marcher Camp services/purchases
- inventory equip/unequip
- skill spending
- ResultsScene Equip Now
- defeat tips
- skirmish launches for all maps
- minimap click handling
- fog toggle
- building placement cancellation feedback
- Build Barracks creates a visible placement ghost near the Command Hall before cancellation
- first-battle RTS loop with capture, Barracks construction, Militia training, rally point, and accelerated result
- live BattleScene victory/defeat objective resolution into Results
- responsive layout reachability/horizontal overflow across desktop, tablet, and mobile viewports

Full real-time human-style victory from first click to enemy base kill remains manual QA.

## Current Build And Asset Status

Latest build:

- `npm run build`: passed.
- Known large-chunk warning remains.

Asset refresh:

- `npm run assets:refresh` was not run in the latest settings pass because no asset registry, manual source-art, processed sprite, or manifest input files changed.
- Run it next if `tools/manual-asset-pipeline/*`, `public/assets/manual/*`, processed battle sprites, or manifests change.

## Current Known Bugs

No deterministic runtime bug is currently reproduced by unit tests, build, or Playwright e2e.

Known current issues:

- Vite reports a large bundle chunk warning.
- Plain full e2e can exceed a short shell-tool timeout; use a longer timeout for local automation.
- Full battle win/loss through normal human input is still manual; automated tests cover accelerated and live objective-resolution paths.
- Balance remains prototype-level and needs human playtesting after each larger AI/map/economy change.

Recently fixed:

- User-reported building commands feeling nonresponsive. The build click path worked internally, but the placement ghost started off-screen and the status line could appear unchanged until pointer movement. Build commands now immediately show a nearby placement ghost and clear status instruction.

## Current Known Limitations

- Campaign is still a skeleton, not a full strategic layer.
- No broad vendor economy, mercenaries, repairs, stronghold development, diplomacy, invasions, or world simulation beyond Marcher Camp and simple choices.
- Event choices are compact cards, not a dialogue engine.
- `recoverHero` is a placeholder event reward.
- Item instances exist, but randomized affixes, crafting, durability, and item art pipeline integration for all item UI are not implemented.
- Relic slot is typed but not fully used.
- Music is not implemented; `musicVolume` is reserved.
- `screenShakeEnabled` is saved but no active screen shake system currently exists to gate.
- Fog of war is grid-based and not blocker-aware.
- Minimap has no drag-to-pan or last-known enemy memory.
- Enemy AI is paced but simple; it does not construct, retreat, scout intelligently, or adapt composition.
- Player construction is automatic; no workers.
- Pathfinding uses A* waypoints, but it is not formation-aware, flow-field based, or fully dynamic around every temporary obstruction.
- Campaign and skirmish balance are prototype-level.
- Scene UI is DOM-heavy and still duplicated across several scenes.

## Files Becoming Too Large Or Risky

Current rough line counts:

- `tools/manual-asset-pipeline/assetRegistry.ts`: 1343 lines. Risk: large asset metadata file, easy conflict point.
- `src/game/data/contentValidation.ts`: 939 lines. Risk: validation logic keeps growing with each data system.
- `src/game/scenes/BattleScene.ts`: 904 lines. Risk: still coordinates live scene input, systems, fog overlay, audio/settings, and entity arrays.
- `src/game/core/GameTypes.ts`: 561 lines. Risk: central type file is accumulating every domain.
- `src/game/core/HeroProgressionRules.ts`: 484 lines. Risk: skills, equipment, rewards, XP, duplicate conversion, and stat math share one rules module.
- `src/game/core/SaveSystem.ts`: 468 lines. Risk: permissive migration and normalization must keep old localStorage saves safe.
- `src/game/core/CampaignRules.ts`: 404 lines. Risk: node completion, choice costs/rewards, town services, modifiers, and reward claims converge here.
- `src/game/ui/HUD.ts`: 376 lines. Risk: battle panel, selected entity UI, training, upgrades, alerts, and minimap container are concentrated.
- `src/game/scenes/CampaignMapScene.ts`: 267 lines. Risk reduced by helper extraction; still owns save calls and navigation.
- `src/game/scenes/HeroProgressionScene.ts`: 268 lines. Risk reduced by helper extraction; still owns equip/skill actions and persistence.

Recently improved:

- `src/game/scenes/ResultsScene.ts` is now about 162 lines after helper extraction.
- `src/game/scenes/CampaignMapScene.ts` is now about 267 lines after campaign helper extraction.
- `src/game/scenes/HeroProgressionScene.ts` is now about 268 lines after progression helper extraction.
- `src/game/data/maps.ts` is now a barrel export; authored maps are split into per-map modules.
- CSS is split by UI domain with `ui.css` as the import hub.
- Battle HUD visual weight was reduced, and building placement now gives immediate ghost/status feedback.

## Most Fragile Systems

1. `BattleScene` integration layer: still coordinates live scene input and system orchestration.
2. Results and campaign reward saving: battle reward, node reward, Equip Now, first-clear, duplicate conversion, and campaign-bank logic meet here.
3. Save normalization: old V1/V2 localStorage saves, item-instance migration, settings-only saves, and campaign migration must remain safe.
4. Campaign choices and town services: pure rules are covered, but UI flow can get crowded.
5. Fog/minimap visibility: visibility filters entity rendering and minimap markers.
6. Input mode overlap: selection, right-click move/attack, rally assignment, placement ghost, minimap click, ability hotkeys, fog debug, and Esc behavior share player input.
7. Content validation: high value, but growing into a catch-all validator.
8. DOM UI styling: CSS is split, but global selectors can still collide.
9. Asset fallback chain: optional manual/final/placeholder assets need regular validation after art changes.
10. Enemy AI pacing: data-driven and safer than before, but still depends on milestone gates and phase math.

## Current Git Status

Current HEAD at handoff update time:

```text
ee4e29de30ca1ea969e7deabaaff08d53b24c26f
```

Current branch tracking line:

```text
main...origin/main
```

Current worktree is dirty with uncommitted changes. Do not reset, checkout, delete, or revert them.

Current modified files:

```text
BALANCE.md
DEVELOPMENT_CHECKPOINT.md
LLM_GAME_HANDOFF.md
src/game/battle/BattleRuntime.test.ts
src/game/core/CampaignRules.test.ts
src/game/core/Constants.ts
src/game/data/battlePacing.ts
src/game/data/campaignNodes.ts
src/game/data/maps/ashenOutpost.ts
src/game/data/rewards.ts
src/game/scenes/BattleScene.ts
src/game/scenes/CampaignMapScene.ts
src/game/scenes/HeroProgressionScene.ts
src/game/styles/battle-feedback.css
src/game/styles/battle-hud.css
src/game/styles/minimap.css
src/game/styles/responsive.css
src/game/systems/BuildingSystem.ts
src/game/ui/HUD.ts
tests/e2e/deep-flow.spec.ts
```

Current untracked paths:

```text
QA_RUN.md
src/game/campaign/
src/game/progression/
```

Before starting another large feature, make a clean checkpoint commit if the user agrees.

## Current Manual QA Checklist

Run this before starting another large feature pass and after any checkpoint commit that changes gameplay/UI:

1. Start dev server and open `http://127.0.0.1:5173/`.
2. Main menu appears.
3. Settings opens from main menu.
4. Change audio volume, reduced motion, floating text, UI scale, fog override, and colorblind minimap palette.
5. Save settings, return to menu, reopen Settings, and verify persistence.
6. Reset Save works from the main menu.
7. New Campaign with no playable save opens hero creation.
8. Create each hero class at least once.
9. Campaign map opens after hero creation.
10. Campaign bank displays Crowns, Stone, Iron, and Aether.
11. Reputation and active modifiers display.
12. Border Village is available at campaign start.
13. Locked nodes cannot start.
14. Border Village launches First Claim.
15. In battle, select hero with click and `H`.
16. Move hero/units with right-click.
17. Capture Crown Shrine.
18. Select Command Hall.
19. Place Barracks and verify valid/invalid placement reasons.
20. Barracks appears under construction and cannot train until complete.
21. Completed Barracks can train Militia and Ranger.
22. Queue progress displays and cancel/refund works.
23. Set Barracks rally point with right-click ground.
24. Rally marker appears and trained units move to it.
25. Build Mystic Lodge and train Acolyte.
26. Build Watchtower and verify it attacks when enemies approach.
27. Research Infantry Weapons I, Ranger Training I, Reinforced Armor I, and Aether Study I.
28. Verify locked train/upgrade buttons show reasons.
29. Use hero abilities with `1`, `2`, `3`.
30. Verify audio cues are audible when volume is on and silent/muted when volume is zero.
31. Verify floating text can be disabled.
32. Verify reduced motion removes floating text tweening and CSS motion.
33. Verify fog hides enemy/neutral entities outside vision.
34. Press `F` on fog-enabled difficulty and verify fog debug toggles.
35. Verify Settings fog override can disable/enable fog regardless of difficulty default.
36. Verify minimap shows units, buildings, sites, camera rectangle, rally marker, and pings.
37. Verify colorblind minimap palette changes player/enemy/neutral colors.
38. Click minimap and confirm the camera recenters.
39. Survive or intentionally lose the first wave.
40. Defeat screen shows contextual tips and retry/campaign return.
41. Victory screen shows map, difficulty, battle time, XP, level progress, item rewards, campaign rewards, and campaign bank.
42. Equip Now changes stats and persists after leaving Results.
43. Send-to-inventory behavior leaves item in inventory.
44. Campaign victory completes Border Village and unlocks Old Stone Road.
45. Continue Campaign returns to saved campaign state.
46. Complete Old Stone Road and verify Aether Well Ruins, Bandit Hillfort, Marcher Camp, and Refugee Caravan unlock.
47. Open Marcher Camp and verify repeatable services, once-only purchases, costs, locked reasons, and save persistence.
48. Open Refugee Caravan and verify choices, costs, locked reasons, and reputation/resource effects.
49. Open Chapel of the Marches and verify choices, non-completing guidance choice, and completing choices.
50. Verify once-only choices cannot be repeated.
51. Verify campaign node rewards cannot be claimed repeatedly.
52. Skirmish Setup opens separately from campaign.
53. First Claim launches from Skirmish Setup.
54. Broken Ford launches from Skirmish Setup.
55. Ashen Outpost launches from Skirmish Setup.
56. Ashen Outpost shows fortress layout, Burned Shrine, side resources, neutral camps, and defensive towers.
57. Ashen Outpost Results screen shows special objective completion states.
58. Difficulty selection changes AI pacing/fog behavior.
59. AI personality selection changes displayed enemy style and launches without errors.
60. Hero Inventory opens from main menu.
61. Equipping/unequipping items changes hero stats.
62. Skill point spending persists.
63. Asset Gallery opens without crashing.
64. Browser console has no new hard errors.
65. Production build preview boots if using `npm run preview`.

## Recommended Next 10 Development Priorities

1. Checkpoint the current dirty worktree after confirming the user wants a commit.
2. Run a targeted manual browser QA pass on building commands, placement, train/cancel/refund, rally, and mobile command-panel usability.
3. Run one fuller human-paced campaign QA pass through the checklist above, especially audible audio behavior and normal-play victory/defeat.
4. Split `BattleScene` system construction/wiring into a helper; it is still the largest live-scene risk.
5. Improve the building command panel on mobile so build/train/research actions feel like a command tray rather than a scrolling form.
6. Split `SaveSystem` migration/normalization into focused modules before adding more persistent systems.
7. Add randomized item affixes only after instance-based inventory has more browser QA coverage.
8. Improve formation/pathing behavior and dynamic blockers before building larger maps.
9. Add enemy construction or adaptive AI only after player construction/rally/fog/manual QA is stable.
10. Rebalance the first 30-minute campaign after several human playthroughs on Easy and Normal.

## Guidance For Future LLMs

- Preserve campaign and skirmish as separate entry flows that share `BattleLaunchRequest`.
- Preserve all current uncommitted work unless explicitly told to reset/revert.
- Prefer data additions in `src/game/data` and pure rules in `src/game/core` or `src/game/systems`.
- Keep browser smoke testing close to every UI-heavy change.
- Keep save migrations explicit and add tests for any persistent field.
- Do not add more campaign complexity before checkpointing and manually QAing the current prototype.
- Never run destructive git commands without explicit user approval.
