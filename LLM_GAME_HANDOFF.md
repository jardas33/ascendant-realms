# Ascendant Realms LLM Handoff

Last updated: 2026-04-26 22:18 -04:00

This file is the main continuation note for future LLMs working on Ascendant Realms. It supersedes older scattered status notes when they disagree.

## Project Identity

Ascendant Realms is a Phaser 3, TypeScript, and Vite browser-game prototype for a fantasy RTS/RPG hybrid.

The current playable loop:

1. Create or load a persistent hero.
2. Enter the Border Marches mini-campaign or a standalone skirmish.
3. Play an RTS battle with hero abilities, capture sites, construction, training queues, upgrades, rally points, pathfinding, fog of war, live minimap, and enemy pressure waves.
4. Resolve victory or defeat through the shared Results scene.
5. Persist hero XP, skill points, inventory item instances, equipment, campaign node progress, event choices, town purchases, campaign modifiers, campaign resources, settings, and save migrations in localStorage.

The project is still a prototype, but it now has a broad playable RTS/RPG spine. The worktree is dirty with useful in-progress changes. Do not reset, delete, checkout, or revert them unless the user explicitly asks.

## Current Git State

Project root:

```text
D:\Code for projects\WB game like\ascendant-realms
```

Current branch:

```text
main
```

Current HEAD:

```text
06085916752aede8be67894b0ba47a0bdae5ac82
```

Known shell/tool note:

- `rg.exe` has returned access-denied errors in this workspace. Use PowerShell `Select-String`, `Get-ChildItem`, and targeted `Get-Content` if `rg` fails.
- Browser Use was mentioned during recent prompts. The latest handoff audit did not need live in-app browser control; Playwright e2e remains the verified browser automation surface for the latest pass.

Current dirty files at this handoff audit time:

```text
 M BALANCE.md
 M LLM_GAME_HANDOFF.md
 M QA_RUN.md
 M src/game/ai/EnemyAIController.test.ts
 M src/game/core/CampaignRules.test.ts
 M src/game/core/FirstExperienceGuidance.ts
 M src/game/core/SaveSystem.test.ts
 M src/game/core/SaveSystem.ts
 M src/game/data/aiPersonalities.ts
 M src/game/data/battlePacing.test.ts
 M src/game/data/battlePacing.ts
 M src/game/data/campaignModifiers.ts
 M src/game/data/campaignNodes.ts
 M src/game/data/maps/ashenOutpost.ts
 M src/game/data/rewards.ts
 M src/game/scenes/BattleScene.ts
 M src/game/styles/battle-hud.css
 M src/game/styles/responsive.css
 M src/game/ui/HUD.ts
 M tests/e2e/deep-flow.spec.ts
 M tests/e2e/layout.spec.ts
?? src/game/battle/BattleSceneSystems.ts
?? src/game/save/SaveDefaults.ts
?? src/game/save/SaveImportExport.ts
?? src/game/save/SaveMigrations.ts
?? src/game/save/SaveNormalization.ts
?? src/game/save/SaveSystem.ts
```

## Commands

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

- `npm run test:e2e` starts Vite through Playwright.
- The e2e suite intentionally uses one worker for stability.
- Use a long shell timeout for e2e. A 3-minute shell timeout is too short; the latest full run took 8.3 minutes.
- `npm run assets:refresh` is only needed after changing asset registry, manual art, processed sprites, or manifest inputs.

## Latest Verified Status

Fresh verification completed after this handoff audit on 2026-04-26 at about 22:18 -04:00:

```text
npm test
PASS: 25 test files, 118 tests

npm run build
PASS: TypeScript compile and Vite production build
Known warning: main Phaser bundle exceeds Vite's 500 kB chunk warning threshold

npm run test:e2e -- --reporter=line
PASS: 25 Playwright tests in 8.3m
```

An earlier e2e run hit a 3-minute shell timeout before results were returned. It was rerun with a longer timeout and passed.

## Most Recent Completed Work

### First Real Human-Paced Campaign Balance Pass

Goal: make the first 30 minutes of the mini-campaign coherent, fair, and rewarding without adding systems, maps, factions, workers, enemy construction, affixes, or new strategic layers.

Files touched by this pass:

- `BALANCE.md`
- `src/game/core/FirstExperienceGuidance.ts`
- `src/game/data/aiPersonalities.ts`
- `src/game/data/battlePacing.ts`
- `src/game/data/campaignModifiers.ts`
- `src/game/data/campaignNodes.ts`
- `src/game/data/maps/ashenOutpost.ts`
- `src/game/data/rewards.ts`
- `src/game/ai/EnemyAIController.test.ts`
- `src/game/core/CampaignRules.test.ts`
- `src/game/data/battlePacing.test.ts`
- `tests/e2e/deep-flow.spec.ts`

Core tuning:

- Story is now more clearly the learning/testing lane.
- Easy has more breathing room for Border Village and Old Stone Road.
- Normal remains the first serious baseline but spikes less abruptly.
- Raider Rush still pressures greedy play, but Old Stone Road should be readable.
- Fortress Keeper and Hexfire Cult were trimmed so identity comes more from composition/behavior than raw economy.
- Marcher Camp costs and usefulness were rebalanced.
- Refugee Caravan choices are more distinct and less dominated by Demand Tribute.
- Aether Well Ruins and Bandit Hillfort rewards are stronger for the first Normal branch.
- Chapel guidance now explicitly scouts without completing the node.
- Ashen Outpost player/enemy starting banks and enemy income were softened so fortress/towers/composition create the challenge.
- Reward weights now lean toward understandable early gear on First Claim and slightly more exciting branch/milestone drops later.

`BALANCE.md` now records before/after values, reasons, intended first-30-minute arc, and remaining human testing notes.

### Save System Split

The public import path still works:

```ts
import { SaveSystem } from "../core/SaveSystem";
```

But `src/game/core/SaveSystem.ts` is now a small compatibility re-export:

```ts
export * from "../save/SaveSystem";
```

New focused save modules are untracked in the dirty worktree:

- `src/game/save/SaveDefaults.ts`
- `src/game/save/SaveImportExport.ts`
- `src/game/save/SaveMigrations.ts`
- `src/game/save/SaveNormalization.ts`
- `src/game/save/SaveSystem.ts`

The facade still owns localStorage IO. Defaults, import/export, migrations, and normalization now live in focused modules. Tests in `src/game/core/SaveSystem.test.ts` cover the split and migration behavior.

### BattleScene System Wiring Split

`BattleScene` is still the live Phaser coordinator, but system construction/wiring has moved into:

- `src/game/battle/BattleSceneSystems.ts`

This helper owns constructor ordering and callback wiring between systems. `BattleScene` still owns Phaser lifecycle, runtime state, entity arrays, fog overlay rendering, rally markers, input callbacks, settings/audio integration, and update order.

### Battle HUD And Responsive Polish

Recent dirty changes also include battle HUD and responsive updates:

- `src/game/styles/battle-hud.css`
- `src/game/styles/responsive.css`
- `src/game/ui/HUD.ts`
- `tests/e2e/layout.spec.ts`

The e2e suite verifies command-panel reachability and horizontal overflow across desktop, tablet, and mobile viewports.

## Current Scenes

Scene keys live in `src/game/core/SceneKeys.ts`.

- `BootScene`: loads manifests/assets and enters the menu.
- `MainMenuScene`: New Campaign, Continue Campaign, Skirmish, Hero Inventory, Asset Gallery, Settings, Reset Save, Credits / Info.
- `SettingsScene`: audio, accessibility, UI scale, fog override, minimap palette, and keyboard reference.
- `HeroCreationScene`: hero name/class/origin creation, then campaign or skirmish handoff.
- `CampaignMapScene`: campaign node map, hero summary, campaign bank, reputation, modifiers, selected node details, event choices, town services, and campaign battle launch.
- `SkirmishSetupScene`: map selection, hero summary, difficulty selection, enemy faction placeholder, AI personality selection, and start battle.
- `BattleScene`: main RTS runtime and Phaser entity orchestration.
- `ResultsScene`: victory/defeat summary, rewards, Equip Now, retry/return flow.
- `HeroProgressionScene`: inventory/equipment and skill allocation.
- `AssetGalleryScene`: local/manual asset inspection.

## Current Campaign Flow

Campaign data lives in `src/game/data/campaignNodes.ts`. Rules live in `src/game/core/CampaignRules.ts`.

The Border Marches mini-campaign has eight nodes:

| Node | Type | Difficulty | Map | Role |
| --- | --- | --- | --- | --- |
| `border_village` | Battle | Easy | First Claim | Tutorial battle: capture, build, train, defend, win. |
| `old_stone_road` | Battle | Easy | First Claim | First real battle with Raider Rush pressure. |
| `marcher_camp` | Town | Story | First Claim placeholder | First spending sink; reusable services and one-time item purchases. |
| `refugee_caravan` | Event | Story | First Claim placeholder | First consequence choice. |
| `aether_well_ruins` | Battle | Normal | Broken Ford | First Normal branch, Hexfire Cult pressure. |
| `bandit_hillfort` | Battle | Normal | Broken Ford | First Normal branch, Fortress Keeper pressure. |
| `chapel_of_the_marches` | Shrine | Story | First Claim placeholder | Spiritual/support event and route guidance. |
| `ashen_outpost` | Battle | Normal | Ashen Outpost | Milestone fortress assault. |

Unlock shape:

- Start: Border Village.
- Border Village -> Old Stone Road.
- Old Stone Road -> Aether Well Ruins, Bandit Hillfort, Refugee Caravan, Marcher Camp.
- Aether Well Ruins -> Chapel of the Marches.
- Bandit Hillfort + Chapel of the Marches -> Ashen Outpost.
- Chapel guidance can also reveal Refugee Caravan/Ashen Outpost without completing the chapel.

On campaign battle victory:

- `BattleRuntime` grants battle rewards.
- `ResultsScene` applies campaign node completion.
- One-time node rewards are applied if not already claimed.
- Campaign resources go to the persistent campaign bank.
- Unique duplicate item rewards convert into campaign resources.
- Hero and campaign state are saved.

On campaign battle defeat:

- Rewards are not granted.
- Campaign node completion is not granted.
- The player can retry or return to campaign map.

## Intended First-30-Minute Campaign Arc

1. Border Village teaches capture/build/train/defend/win with low pressure.
2. Old Stone Road asks the player to use Barracks and rally behavior against readable Raider Rush pressure.
3. Marcher Camp teaches spending the campaign bank on rest, volunteers, supplies, or early fixed gear.
4. Refugee Caravan teaches that choices trade resources, reputation, modifiers, and item rewards.
5. Aether Well Ruins or Bandit Hillfort introduces the first Normal branch with stronger rewards.
6. Chapel of the Marches supports the player before the milestone and now explains that guidance does not close the node.
7. Ashen Outpost is the current boss-style fortress map. It should feel fortified, not impossible.

Remaining human-feel checks:

- Fresh novice Border Village timing.
- Greedy vs clean Old Stone Road openings.
- Marcher Camp spend preference after two clears.
- Both Normal branches after typical early spending.
- Ashen Outpost with and without Chapel repair.

## Current Maps

Map data is split into per-map modules:

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
- Capture sites: Crown Shrine, Stone Quarry, Iron Vein, Aether Well.
- Reward table: `first_claim_rewards`.
- Used by Border Village and Old Stone Road.

### Broken Ford

- ID: `broken_ford`
- Size: 2600 x 1700
- Role: contested ruined river crossing.
- Player starts southwest; enemy starts northeast.
- Two main lanes and a risky central ford.
- Capture sites: Ford Toll, West Stone Cut, South Iron Cache, North Aether Spring.
- Reward table: `broken_ford_rewards`.
- Used by Aether Well Ruins and Bandit Hillfort.

### Ashen Outpost

- ID: `ashen_outpost`
- Size: 2600 x 1800
- Role: current mini-campaign milestone fortress assault.
- Player starts lower-left; enemy fortress starts upper-right.
- Capture sites: Burned Shrine, West Supply Pyre, South Iron Pit, North Stone Scar.
- Enemy fortress starts with Enemy Stronghold, Enemy Barracks, and two defensive Watchtowers.
- Reward table: `ashen_outpost_rewards`.
- Special objectives:
  - Destroy the Ashen Stronghold.
  - Capture the Burned Shrine.
  - Destroy Enemy Barracks.
  - Defeat the Outpost Captain / Ashen Commander.

Ashen Outpost tuning after the balance pass:

- Player starting bank: 460 Crowns, 320 Stone, 180 Iron, 95 Aether.
- Enemy starting bank: 280 Crowns, 220 Stone, 160 Iron, 125 Aether.
- Enemy income every 5s: 100 Crowns, 50 Stone, 50 Iron, 40 Aether.

## Current Battle Pacing

Pacing data lives in `src/game/data/battlePacing.ts`.

Battle phases:

- Opening, 0:00 to 2:00: no base attacks.
- Expansion, 2:00 to 5:00: small base attacks allowed, no commander.
- Pressure, 5:00 to 8:00: mixed waves, no commander.
- Assault, 8:00 onward: larger waves and commander support allowed.

Difficulty presets after the balance pass:

| Difficulty | Enemy income | First attack | Attack interval | Wave target | Train interval | Commander | Fog |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Story | 0.45x | 300s | 100s | 2 | 9s | 840s | Off |
| Easy | 0.65x | 240s | 82s | 3 | 7s | 750s | On |
| Normal | 0.86x | 195s | 66s | 6 | 5.8s | 570s | On |
| Hard | 1.15x | 150s | 48s | 8 | 3.8s | 480s | On |

First-match tutorial protection:

- No first attack before 150s.
- If the player has not captured a site, first attack waits until 180s.
- Large attacks are capped to 2 units until the player has built production or 240s has passed.
- Enemy commander is excluded from the first attack and cannot join until assault pacing allows it.

Expected Normal waves:

- First wave around 3:15 baseline or around 3:30 on Hexfire Cult.
- First wave is usually 2 Raiders, or 2 Raiders plus 1 Hexer if the player has already built production.
- Mid waves, 5:00 to 8:00: 3 to 5 mixed Raiders, Hexers, and occasional Brutes.
- Late waves, 8:00 onward: Brute and Hexer support, commander after about 9:30 baseline.

## Current Enemy AI Behavior

Enemy AI lives in `src/game/ai/EnemyAIController.ts`.

The AI:

- Gains scaled income on a timer.
- Trains from completed enemy production buildings.
- Expands toward capture sites.
- Defends its base when player units approach.
- Selects phase-limited attack waves.
- Respects difficulty timing, wave size, income, training speed, expansion speed, and commander join timing.
- Sends alerts such as scouts moving, enemy forces gathering, and attack incoming.

AI personality data lives in `src/game/data/aiPersonalities.ts`.

Current personalities:

- Balanced Warlord: mixed expansion and attacks; Border Village default.
- Raider Rush: 0.86x first attack, 0.88x attack interval, 0.82x expansion interval, 0.88x income, mostly Raiders/Hexers, weaker late posture.
- Fortress Keeper: 1.22x first attack, 1.18x attack interval, 1.02x income, defensive reserves, protects captured sites, Brute-heavy later waves.
- Hexfire Cult: 1.08x first attack and attack interval, 1.02x income, more Hexers, burstier caster pressure, thinner frontline.

AI limitations:

- No enemy construction.
- No workers.
- No true scouting memory.
- No retreat logic.
- No counter-unit strategy.
- No pathfinding-aware threat routing.
- No long-term strategy beyond personality/timing/composition modifiers.

## Current Campaign Economy

Campaign resources are saved separately from temporary battle resources.

Bank resources:

- Crowns
- Stone
- Iron
- Aether

Starting battle resources for First Claim/Broken Ford come from `STARTING_PLAYER_RESOURCES`:

- 380 Crowns
- 255 Stone
- 140 Iron
- 75 Aether

Marcher Camp after the balance pass:

- Rest and Recovery: 30 Crowns for Well Rested, next-battle +15% hero max HP.
- Hire Volunteers: 55 Crowns for Inspired Militia, next battle starts with one extra Militia.
- Buy Supplies: 45 Crowns for 30 Stone, 18 Iron, 8 Aether.
- Emberglass Wand: 60 Crowns, one-time common weapon purchase.
- Marcher Plate: 80 Crowns and 18 Iron, one-time uncommon armor purchase.
- Green Chapel Icon: 90 Crowns and 18 Aether, one-time trinket purchase.

Refugee Caravan after the balance pass:

- Protect Them: costs 45 Crowns; grants 35 XP, Scout's Bow, Inspired Militia, +8 Common Folk, +2 Free Marches.
- Recruit Volunteers: requires hero level 2, costs 20 Crowns; grants 25 XP, 25 Iron, Marcher Plate, Inspired Militia, -4 Common Folk, +2 Free Marches.
- Demand Tribute: grants 65 Crowns, Angered Raiders, -8 Common Folk, -2 Free Marches, -3 Ashen Covenant.

Chapel of the Marches:

- Pray for Strength: grants 35 XP, 15 Aether, Blessed Road, +3 Old Faith, +1 Common Folk, completes the node.
- Repair the Chapel: costs 50 Crowns and 60 Stone; grants 35 Aether, Green Chapel Icon, Local Support, removes Angered Raiders, recovers hero placeholder, +2 Free Marches, +6 Old Faith, +2 Common Folk, completes the node.
- Ask for Guidance: grants 15 XP, unlocks/scouts Refugee Caravan and Ashen Outpost, +1 Old Faith, does not complete the node.

## Current Rewards And Items

Item data lives in `src/game/data/items.ts`. Reward tables live in `src/game/data/rewards.ts`.

Current item model:

- Static catalog item definitions.
- Save inventory stores item instances with `instanceId`, `itemId`, `acquiredAt`, `source`, `affixes`, and optional `locked`/`favorite` flags.
- Equipment references item instance IDs where possible.
- Legacy saves with catalog IDs migrate into instances.
- Unique duplicate rewards convert into campaign resources.
- Non-unique duplicate rewards remain separate instances.

Reward tables support:

- Guaranteed item IDs.
- Weighted item pools.
- Deterministic item order for tests.
- Map-specific item pool filters.
- First-clear-only and repeat-clear-only entries.
- Resource rewards.
- XP rewards.
- First-clear and repeat-clear bonuses.

Reward pacing after the balance pass:

- First Claim: one weighted item roll, modest resources, 35 base victory XP, 40 first-clear XP, starter resources, weighted toward starter/common gear.
- Broken Ford: one weighted item roll, stronger resources, 55 base victory XP, first-clear Fordbreaker Halberd, 65 first-clear XP, slightly improved rare/epic excitement.
- Ashen Outpost: one weighted item roll, high resources, 85 base victory XP, first-clear Ashbound Censer, 95 first-clear XP, and campaign node Oathbound Aegis.

## Current Hero System

Hero data lives in:

- `src/game/data/heroes.ts`
- `src/game/data/heroClasses.ts`
- `src/game/data/origins.ts`
- `src/game/data/abilities.ts`
- `src/game/data/skillTrees.ts`

Current hero classes:

- Warlord
- Arcanist
- Shepherd

Current origins:

- Exiled Noble
- Temple Orphan
- Wildland Raider

Skill trees:

- Combat: damage, HP, Warlord Cleave.
- Magic: mana, armor, Arcanist Arcane Burst/Blink, Shepherd Sanctify Ground.
- Leadership: command, faith, Warlord War Cry, Shepherd Blessing.

Battle hero stats are recalculated from class base stats, origin modifiers, level bonuses, skill ranks, and equipped item stat modifiers.

## Current Factions

Faction data lives in `src/game/data/factions.ts`.

Current factions:

- `free_marches`: player baseline faction; balanced economy, reliable Militia/Rangers/Acolytes, defensive Watchtower, leadership and reputation hooks.
- `ashen_covenant`: main enemy faction; aggressive, cheaper early Raiders, harder-hitting but less durable units except Brutes, magic pressure through Hexers, burn/status pressure, and Ashen AI personality preferences.
- `sylvan_concord`: future placeholder faction with early identity hooks and item origins, not yet playable or fully implemented.

Implemented Ashen mechanics:

- `hexfire_burn`: damage over time with floating feedback.
- `ashen_fury`: low-health damage pressure trait.
- `smoke_march`: wave movement-speed modifier for matching Ashen units.

## Current Construction, Training, Research, And Rally

Building data lives in `src/game/data/buildings.ts`.

Player buildings:

- Command Hall
- Barracks
- Mystic Lodge
- Watchtower

Enemy buildings:

- Enemy Stronghold
- Enemy Barracks

Construction times:

- Command Hall: 0s.
- Barracks: 25s.
- Mystic Lodge: 30s.
- Watchtower: 20s.
- Enemy prebuilt structures: 0s.

Construction behavior:

- Player placement uses a ghost preview.
- Resources are paid on final placement.
- Under-construction buildings appear at partial HP and cannot train/research/attack.
- Construction completes automatically.
- There are no workers.

Training:

- Only completed production buildings train.
- Resources are paid when queued.
- Canceling a queued or active unit refunds the full paid cost for now.
- Rally points can be set by right-clicking ground with a rally-capable building selected.

Research:

- Research pays up front and completes after `researchTimeSeconds`.
- Current upgrades: Infantry Weapons I, Ranger Training I, Reinforced Armor I, Aether Study I, Ember Blades placeholder trait.

## Current UI And CSS

`src/game/styles/ui.css` is the import hub. Domain CSS files:

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

Recent HUD/responsive behavior:

- Battle HUD panels are visually tighter.
- Hero-selected state uses a compact command panel.
- Building command rows were simplified.
- Mobile/tablet rules keep hero/building command panels inside the viewport.
- E2E verifies command reachability and horizontal overflow.

## Current Save Architecture

Current save modules:

- `src/game/core/SaveSystem.ts`: compatibility re-export.
- `src/game/save/SaveDefaults.ts`: versions and fallback/current save creation.
- `src/game/save/SaveImportExport.ts`: JSON parse/stringify boundary.
- `src/game/save/SaveMigrations.ts`: legacy migration.
- `src/game/save/SaveNormalization.ts`: hero/campaign shape checks and normalization.
- `src/game/save/SaveSystem.ts`: public localStorage facade.
- `src/game/save/SaveTypes.ts`: save-facing types.

Current save version is V2. Save normalization protects:

- Settings-only saves.
- Legacy catalog-ID inventory/equipment.
- Item instance migration.
- Campaign resource and resource-spent bags.
- Choice IDs.
- Town service claimed IDs and use counts.
- Active modifier IDs.
- Completed/unlocked/locked/node-reward IDs.
- Negative numeric resource/stat clamping where appropriate.

## Current Helper Architecture

### Results

`ResultsScene` is now a coordinator. Helper modules live in `src/game/results/`:

- `ResultsCampaignFlow.ts`
- `ResultsEquipActions.ts`
- `ResultsFormatting.ts`
- `ResultsNavigation.ts`
- `ResultsObjectiveSummary.ts`
- `ResultsRewardPanel.ts`
- `ResultsTypes.ts`
- `ResultsViewModel.ts`

### Campaign Map

`CampaignMapScene` delegates view-model creation and panel rendering to helpers in `src/game/campaign/`:

- `CampaignChoicePanel.ts`
- `CampaignMapViewModel.ts`
- `CampaignNavigation.ts`
- `CampaignNodePanel.ts`
- `CampaignPresentationTypes.ts`
- `CampaignResourcePanel.ts`
- `CampaignTownServicesPanel.ts`

### Hero Progression

`HeroProgressionScene` delegates inventory, equipment, skill tree, comparison, and stat presentation to helpers in `src/game/progression/`:

- `EquipmentPanel.ts`
- `HeroProgressionViewModel.ts`
- `HeroStatsPanel.ts`
- `InventoryPanel.ts`
- `ItemComparison.ts`
- `SkillTreePanel.ts`

### Battle

Battle helpers live in `src/game/battle/`:

- `BattleLaunchRequest.ts`
- `BattleRuntime.ts`
- `BattleSceneAlerts.ts`
- `BattleSceneMapRenderer.ts`
- `BattleSceneObjectives.ts`
- `BattleSceneResults.ts`
- `BattleSceneSnapshots.ts`
- `BattleSceneSpawner.ts`
- `BattleSceneSystems.ts`

`BattleSceneSystems.ts` is currently untracked and should be preserved.

## Current Tests

Latest verified suite status, refreshed during this handoff audit:

- `npm test`: passed, 25 test files, 118 tests.
- `npm run build`: passed.
- `npm run test:e2e -- --reporter=line`: passed, 25 Playwright tests in 8.3m.

Current unit/pure test files:

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

Current e2e files:

- `tests/e2e/deep-flow.spec.ts`
- `tests/e2e/layout.spec.ts`
- `tests/e2e/smoke.spec.ts`

Browser-level tests currently cover:

- Main menu boot.
- Settings persistence.
- Hero creation.
- Campaign map and locked-node behavior.
- Border Village battle launch.
- Campaign choices and Marcher Camp services/purchases.
- Inventory equip/unequip.
- Skill spending.
- Results Equip Now.
- Defeat tips.
- Skirmish launches for all maps and AI personalities.
- Minimap click handling.
- Fog toggle.
- Building placement cancellation feedback.
- Build Barracks placement ghost near Command Hall.
- First-battle loop: capture, Barracks construction, Militia training, rally point, accelerated result.
- Live objective resolution into Results.
- Responsive layout reachability and overflow across desktop, tablet, and mobile.

Full real-time human-style victory from first click to enemy base kill remains manual QA.

## Current Known Bugs

No deterministic runtime bug is currently reproduced by unit tests, build, or Playwright e2e.

Known issues and caveats:

- Vite reports a large bundle chunk warning.
- Full e2e is slow and can exceed short shell-tool timeouts.
- Full human-paced battle victory/defeat through normal input remains manual.
- Balance remains prototype-level and needs human playtesting after each larger AI/map/economy change.
- `QA_RUN.md` contains earlier manual QA notes; latest automated verification counts in this handoff are newer.

## Current Known Limitations

- Campaign is a mini-campaign skeleton, not a full strategic layer.
- No broad vendor economy, mercenaries, repairs, stronghold development, diplomacy, invasions, or world simulation beyond Marcher Camp and compact event choices.
- Event choices are compact cards, not a dialogue engine.
- `recoverHero` is a placeholder reward effect.
- Item instances exist, but randomized affixes, crafting, durability, and full item-icon presentation are not implemented.
- Relic slot is typed but not fully used.
- Music is not implemented; `musicVolume` is reserved.
- `screenShakeEnabled` is saved but no active screen shake system currently gates it.
- Fog of war is grid-based and not blocker-aware.
- Minimap has no drag-to-pan or last-known enemy memory.
- Enemy AI is paced but simple; it does not construct, retreat, scout intelligently, or adapt composition.
- Player construction is automatic; no workers.
- Pathfinding uses A* waypoints, but it is not formation-aware, flow-field based, or fully dynamic around every temporary obstruction.
- Scene UI is DOM-heavy and still duplicated across several scenes.

## Large Or Risky Files

Current rough line counts:

- `src/game/data/contentValidation.ts`: 973 lines.
- `src/game/scenes/BattleScene.ts`: 819 lines.
- `src/game/core/GameTypes.ts`: 624 lines.
- `src/game/core/HeroProgressionRules.ts`: 528 lines.
- `src/game/ui/HUD.ts`: 458 lines.
- `src/game/core/CampaignRules.ts`: 433 lines.
- `src/game/core/SaveSystem.test.ts`: 409 lines.
- `src/game/systems/PathfindingGrid.ts`: 397 lines.
- `src/game/battle/BattleSceneSystems.ts`: 355 lines.
- `src/game/ai/EnemyAIController.ts`: 352 lines.
- `src/game/data/campaignNodes.ts`: 310 lines.
- `src/game/scenes/CampaignMapScene.ts`: 291 lines.
- `src/game/data/aiPersonalities.ts`: 288 lines.
- `src/game/scenes/HeroProgressionScene.ts`: 286 lines.

Risk notes:

- `BattleScene` is smaller than before but still the highest live-scene integration risk.
- `GameTypes.ts` continues accumulating cross-domain types.
- `HeroProgressionRules.ts` mixes skills, equipment, reward, XP, duplicate conversion, and stat math.
- `CampaignRules.ts` joins node completion, costs/rewards, modifiers, town services, and reward claims.
- `HUD.ts` is still a concentrated battle UI surface.
- `contentValidation.ts` is valuable but has become a catch-all validator.

## Most Fragile Systems

1. `BattleScene` integration: live scene lifecycle, system update order, input mode overlap, fog/minimap/rally wiring.
2. Results and campaign reward saving: battle rewards, node rewards, Equip Now, first-clear, duplicate conversion, campaign bank.
3. Save migration/normalization: old localStorage saves, item-instance migration, settings-only saves, campaign state.
4. Campaign choices and town services: pure rules are covered, but UI crowding can regress.
5. Fog/minimap visibility: filters rendering and minimap markers.
6. Input modes: selection, move/attack, rally, placement, minimap, abilities, fog debug, Esc.
7. Enemy AI pacing: data-driven but dependent on milestone gates and phase math.
8. DOM CSS: split by domain but global selectors can still collide.
9. Asset fallback chain: optional manual/final/placeholder assets need validation after art changes.

## Manual QA Checklist

Run this before a checkpoint commit after gameplay/UI changes:

1. Start dev server and open `http://127.0.0.1:5173/`.
2. Main menu appears.
3. Settings opens and persists audio, UI scale, reduced motion, floating text, fog override, and minimap palette.
4. Reset Save works in an isolated test context before using on a real save.
5. New Campaign opens hero creation when no playable save exists.
6. Create Warlord, Arcanist, and Shepherd at least once.
7. Campaign map opens after creation.
8. Campaign bank, reputation, and active modifiers display.
9. Border Village is available and locked nodes cannot start.
10. Border Village launches First Claim.
11. Select hero with click and `H`.
12. Move units with right-click.
13. Capture Crown Shrine.
14. Select Command Hall.
15. Place Barracks and verify valid/invalid placement reasons.
16. Barracks appears under construction and cannot train until complete.
17. Completed Barracks trains Militia and Ranger.
18. Queue progress displays and cancel/refund works.
19. Set Barracks rally point and verify marker plus trained-unit movement.
20. Build Mystic Lodge and train Acolyte.
21. Build Watchtower and verify it attacks.
22. Research all current upgrades through UI.
23. Verify locked train/upgrade buttons show reasons.
24. Use hero ability hotkeys.
25. Verify audio cues with human ears.
26. Verify floating text and reduced motion visually.
27. Verify fog hides unexplored/undetected entities.
28. Press `F` on fog-enabled difficulty and verify fog debug.
29. Verify settings fog override changes battle fog behavior.
30. Verify minimap units/buildings/sites/camera/rally/pings and colorblind palette.
31. Survive or lose the first wave through normal play.
32. Defeat screen shows contextual tips and retry/campaign return.
33. Victory screen shows map, difficulty, time, XP, level progress, battle rewards, node rewards, and campaign bank.
34. Equip Now changes stats and persists after leaving Results.
35. Campaign victory completes Border Village and unlocks Old Stone Road.
36. Complete Old Stone Road and verify Aether Well Ruins, Bandit Hillfort, Marcher Camp, and Refugee Caravan unlock.
37. Marcher Camp repeatable services, once-only purchases, costs, locked reasons, and save persistence work.
38. Refugee Caravan choices and reputation/resource effects work.
39. Chapel choices work, especially non-completing guidance.
40. Campaign node rewards cannot be claimed repeatedly.
41. Skirmish Setup opens separately.
42. First Claim, Broken Ford, and Ashen Outpost launch from skirmish.
43. Ashen Outpost shows fortress layout, Burned Shrine, side resources, neutral camps, and defensive towers.
44. Ashen Outpost Results show special objective completion states.
45. Difficulty selection changes pacing/fog behavior.
46. AI personality selection changes displayed style and launches without errors.
47. Hero Inventory opens from main menu.
48. Equipping/unequipping items changes hero stats.
49. Skill point spending persists.
50. Asset Gallery opens.
51. Browser console has no new hard errors.
52. Production build preview boots if doing release-style QA.

## Recommended Next Priorities

1. Ask the user whether to checkpoint/commit the current dirty worktree before more feature work.
2. Do a human-paced Border Village and Old Stone Road playtest on Easy, timing the first warning, Barracks completion, first trained unit, and first attack contact.
3. Play both Aether Well Ruins and Bandit Hillfort on Normal from a typical early campaign save.
4. Play Ashen Outpost with and without Chapel repair to validate fortress pressure.
5. Update `QA_RUN.md` to reflect the latest 118-test balance verification if it will remain a canonical QA artifact.
6. Continue reducing `BattleScene` only in small, behavior-preserving slices.
7. Split `GameTypes.ts` or `contentValidation.ts` only after a checkpoint, because both are central conflict/risk files.
8. Add e2e/manual coverage for Chapel choices, Mystic Lodge/Acolyte, Watchtower combat, research UI, and Ashen Outpost special objectives.
9. Do not add enemy construction, workers, affixes, or new campaign systems until the current mini-campaign balance is human-tested.
10. Keep Vite chunk-size warning as a known build warning unless the user asks for bundle optimization.

## Guidance For Future LLMs

- Preserve current dirty work unless explicitly told to reset/revert.
- Keep campaign and skirmish separate entry flows that share `BattleLaunchRequest`.
- Prefer data tuning in `src/game/data` and pure rules in `src/game/core` or `src/game/systems`.
- Add or update tests for persistent save fields and data contracts.
- Use Playwright for browser verification when UI/gameplay changes.
- Use Browser Use only when the user asks for in-app browser inspection or visible local-browser interaction.
- Keep changes conservative until the current first-hour campaign balance has human playtesting.
- Never run destructive git commands without explicit user approval.
