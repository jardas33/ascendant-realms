# Ascendant Realms LLM Handoff

This file is a complete practical handoff for another LLM or developer to understand what exists in the Ascendant Realms prototype as of this workspace state. Source files remain the authority, but this document gathers the architecture, gameplay rules, content data, asset workflow, UI behavior, recent visual changes, and known limitations in one place.

## Project Identity

- Name: Ascendant Realms.
- Genre: Small first-playable fantasy RTS/RPG hybrid.
- Runtime: Browser game using Phaser 3, TypeScript, and Vite.
- Core fantasy: Create a persistent hero, enter a skirmish, capture magical resource sites, build a small army, defeat enemies, gain XP, receive item rewards, and save hero progress locally.
- Current scope: Engine-first playable prototype, not a full game.
- Long-term pillars:
  - Persistent hero fantasy.
  - Faction asymmetry.
  - Living campaign map.
  - Data-driven and mod-friendly content.

## Repository Shape

- Outer launcher folder: `D:\Code for projects\WB game like`.
- Real project folder: `D:\Code for projects\WB game like\ascendant-realms`.
- Main package: `ascendant-realms/package.json`.
- Convenience package: outer `package.json` forwards common npm scripts into `ascendant-realms`.
- There is no `.git` folder visible in this workspace snapshot.

## Commands

Run from `ascendant-realms`:

```bash
npm run dev
npm test
npm run build
npm run assets:refresh
```

Outer-folder equivalents are also available:

```bash
npm run dev
npm test
npm run build
npm run assets:refresh
```

Script meanings:

- `dev`: starts Vite on `0.0.0.0`.
- `build`: runs TypeScript with `tsc -p tsconfig.json`, then Vite build.
- `preview`: serves the production build.
- `test`: runs Vitest.
- `assets:prompts`: generates manual image prompt book.
- `assets:ui-kit`: generates a free procedural starter UI kit.
- `assets:process-battle-sprites`: converts manually supplied battle sprites into game-ready PNGs.
- `assets:manifest`: rebuilds the runtime asset manifest.
- `assets:validate`: validates asset paths.
- `assets:refresh`: processes battle sprites, rebuilds the manifest, and validates everything.

Known build note: Vite may warn that the Phaser bundle is large. The build still succeeds.

## Entry Points

- `index.html`: provides `#game-root` for Phaser and `#ui-root` for DOM UI.
- `src/main.ts`: imports global CSS, disables context menu, starts `new Phaser.Game(gameConfig)`, and stores it on `window.ascendantRealmsGame`.
- `src/game/config.ts`: Phaser config and scene registration.
- `src/game/styles/ui.css`: all DOM UI styling.

## Scene Flow

Scene keys live in `src/game/core/SceneKeys.ts`.

Main flow:

1. `BootScene`
   - Loads the asset manifest.
   - Queues available images.
   - Applies UI-kit CSS variables.
2. `MainMenuScene`
   - Shows new hero, continue, reset, asset gallery, and supporting options.
3. `HeroCreationScene`
   - Lets the player enter a name, choose hero class, choose origin, and start a skirmish.
4. `BattleScene`
   - Main RTS skirmish scene.
   - Spawns bases, hero, starting units, neutral camps, capture sites, enemy army, systems, and DOM HUD.
5. `HeroProgressionScene`
   - Victory progression, skill allocation, item display, and follow-up battle launch.
6. `ResultsScene`
   - Defeat or result state.
7. `AssetGalleryScene`
   - Shows asset manifest status and whether browser-loaded images are available.

## Core Gameplay Loop

- Player starts with a hero, a Command Hall, two Militia, and one Ranger.
- Enemy starts with an Enemy Stronghold, Enemy Barracks, several enemy units, and an Ashen Commander.
- Player captures resource sites by standing nearby for `CAPTURE_TIME_SECONDS = 4`.
- Captured sites periodically add resources.
- Player selects units and buildings with RTS-style click/drag.
- Player right-clicks ground to move or right-clicks enemies to attack.
- Player builds production/defense buildings from the Command Hall.
- Player trains units from Barracks or Mystic Lodge.
- Enemy AI gains income, trains units, expands to capture sites, defends, and sends attack waves.
- Victory occurs when the enemy objective building is dead.
- Defeat occurs when the player objective building is dead.
- On victory, hero progress is saved and item rewards are granted.
- On defeat, hero progress is not saved.

## Controls

- Left click: select a friendly unit or building.
- Drag with left mouse: box-select friendly units.
- Shift plus selection: additive selection.
- Right click ground: move selected units.
- Right click enemy: attack selected enemy.
- `Shift+A`, then right click: attack-move selected units.
- `H`: select hero.
- `1`, `2`, `3`: cast unlocked hero ability slots.
- `Space`: center camera on hero.
- `Esc`: clear selection or cancel building placement.
- `WASD` or arrow keys: pan camera.

## Save System

- Save key: `ascendant-realms-save-v1`.
- Storage: browser local storage.
- Save file includes hero name, class, origin, level, XP, skill points, unlocked abilities, completed battle count, inventory, equipment, allocated skills, faction reputation, and stats.
- `SaveSystem.load()` returns the active save.
- `SaveSystem.saveHero()` persists hero state after victory.
- `createFallbackHeroSave()` gives the game a safe default if no save exists.

## Pure Battle Boundary

`src/game/battle/BattleLaunchRequest.ts` and `src/game/battle/BattleRuntime.ts` define the clean battle contract.

`BattleLaunchRequest` exists so skirmish, future campaign nodes, and future scenario missions can all launch battles through the same pathway.

`BattleRuntime` owns:

- Request metadata.
- Initial resource cloning.
- Battle elapsed time.
- Battle stats.
- Objective evaluation.
- Completion result.
- Victory reward decisions.
- Whether the hero should be saved.

`BattleScene` still owns live Phaser entities, input, rendering, systems, spawning, and most moment-to-moment gameplay.

## Core Constants

From `src/game/core/Constants.ts`:

- Starting player resources: Crowns 300, Stone 200, Iron 100, Aether 50.
- Starting enemy resources: Crowns 220, Stone 160, Iron 120, Aether 80.
- Level XP thresholds: level 2 at 100 XP, level 3 at 250, level 4 at 450, level 5 at 700.
- Hero HP per level: 18.
- Hero Mana per level: 10.
- Camera pan speed: 520.
- Capture time: 4 seconds.
- Hero XP share radius: 460.
- Attack-move search radius: 260.
- Default aggro radius: 260.
- Formation spacing: 34.
- Resource tick floating text time: 1300 ms.
- Build radius from owned building: 560.

## Resources

Resources live in `src/game/data/resources.ts`.

- Crowns: color `0xf2c14e`; used for units, buildings, campaign payments.
- Stone: color `0x9da3a4`; used for halls, towers, lodges.
- Iron: color `0xc96f53`; used for weapons and armored troops.
- Aether: color `0x74d3f2`; used for spells, rituals, and arcane units.

## Factions

Factions live in `src/game/data/factions.ts`.

- The Free Marches, `free_marches`, color `0x4f8f68`: border-town militias, scouts, oathbound mystics fighting for self-rule.
- Ashen Covenant, `ashen_covenant`, color `0xb64b42`: raiders, hex-magic, brutal champions.
- Sylvan Concord, `sylvan_concord`, color `0x6ab06e`: future faction with forest spirits, wardens, beasts, living sanctuaries.
- Untamed Wilds, `wilds`, color `0x8b6f43`: neutral beasts and monsters guarding old places of power.

## Hero Classes

Hero classes live in `src/game/data/heroClasses.ts`.

Warlord:

- Description: strong melee commander who makes nearby soldiers hit harder.
- Primary ability: `rally_banner`.
- Ability list: `rally_banner`, `cleave`, `war_cry`.
- Color: `0xe2b34b`.
- Stats: HP 260, Mana 60, Damage 18, Armor 4, Speed 110, Range 34, Attack Cooldown 1.1, Might 8, Command 8, Arcana 2, Faith 3.

Arcanist:

- Description: magic damage specialist who burns priority targets.
- Primary ability: `firebolt`.
- Ability list: `firebolt`, `arcane_burst`, `blink`.
- Color: `0xf07d3c`.
- Stats: HP 160, Mana 180, Damage 10, Armor 1, Speed 105, Range 150, Attack Cooldown 1.25, Might 2, Command 4, Arcana 10, Faith 4.

Shepherd:

- Description: healer and holy commander who keeps a small force alive.
- Primary ability: `heal`.
- Ability list: `heal`, `blessing`, `sanctify_ground`.
- Color: `0x8ed98f`.
- Stats: HP 200, Mana 130, Damage 12, Armor 2, Speed 105, Range 120, Attack Cooldown 1.2, Might 3, Command 6, Arcana 4, Faith 10.

## Origins

Origins live in `src/game/data/origins.ts`.

- Exiled Noble: command +2, max HP +10.
- Temple Orphan: faith +2, max mana +15.
- Wildland Raider: might +1, speed +8, damage +2.

## Hero Abilities

Abilities live in `src/game/data/abilities.ts`.

Warlord:

- Rally Banner, hotkey 1: nearby allied units gain +25 percent damage for 8 seconds. Mana 25, cooldown 18, radius 160.
- Cleave, hotkey 2: strike nearby enemies for 38 damage. Mana 20, cooldown 7, radius 82.
- War Cry, hotkey 3: nearby enemies take 24 damage and allies rally briefly. Mana 35, cooldown 16, radius 150, duration 5.

Arcanist:

- Firebolt, hotkey 1: projectile at nearest enemy for 55 damage. Mana 30, cooldown 6, range 520.
- Arcane Burst, hotkey 2: area damage around nearest enemy for 42. Mana 45, cooldown 10, range 440, radius 110.
- Blink, hotkey 3: short teleport toward nearest enemy, or forward if none are near. Mana 30, cooldown 12, range 190.

Shepherd:

- Heal, hotkey 1: restore 60 HP to selected wounded ally or hero. Mana 25, cooldown 8, range 420.
- Blessing, hotkey 2: heal nearby allies for 24 and grant +15 percent damage for 7 seconds. Mana 35, cooldown 14, radius 150.
- Sanctify Ground, hotkey 3: holy pulse heals allies and damages enemies around hero for 32. Mana 50, cooldown 18, radius 150.

## Skill Trees

Skill data lives in `src/game/data/skillTrees.ts`.

Trees:

- Combat: personal damage, toughness, front-line presence.
- Magic: mana, spell power, battlefield control.
- Leadership: command, army support, force multiplication.

Nodes:

- `combat_drill`: Battle Drill, Combat, max rank 3, cost 1 per rank, damage +2 and might +1 per rank.
- `combat_endurance`: Endurance, Combat, max rank 3, cost 1 per rank, max HP +24 per rank.
- `warlord_cleave`: Cleave, Combat, Warlord only, max rank 1, unlocks `cleave`, requires `combat_drill` rank 1.
- `magic_focus`: Aether Focus, Magic, max rank 3, cost 1 per rank, max Mana +18 and arcana +1 per rank.
- `magic_warding`: Warding, Magic, max rank 2, cost 1 per rank, armor +1 per rank.
- `arcanist_arcane_burst`: Arcane Burst, Magic, Arcanist only, max rank 1, unlocks `arcane_burst`, requires `magic_focus` rank 1.
- `arcanist_blink`: Blink, Magic, Arcanist only, max rank 1, unlocks `blink`, requires `magic_focus` rank 2.
- `leadership_presence`: Command Presence, Leadership, max rank 3, cost 1 per rank, command +1 and max HP +8 per rank.
- `leadership_field_rites`: Field Rites, Leadership, max rank 3, cost 1 per rank, faith +1 and max Mana +10 per rank.
- `warlord_war_cry`: War Cry, Leadership, Warlord only, max rank 1, unlocks `war_cry`, requires `leadership_presence` rank 2.
- `shepherd_blessing`: Blessing, Leadership, Shepherd only, max rank 1, unlocks `blessing`, requires `leadership_field_rites` rank 1.
- `shepherd_sanctify_ground`: Sanctify Ground, Magic, Shepherd only, max rank 1, unlocks `sanctify_ground`, requires `leadership_field_rites` rank 2.

## Units

Units live in `src/game/data/units.ts`.

Player units:

- Militia: Free Marches, cheap melee infantry. Cost Crowns 60, Iron 20. Train 4s. Radius 13. Color `0x8fcf91`. HP 90, Damage 9, Range 28, Cooldown 1, Speed 90, Armor 1, XP value 15.
- Ranger: Free Marches, ranged skirmisher. Cost Crowns 80, Iron 30. Train 5s. Radius 12. Color `0x6eb5d8`. Projectile `0xc7e8a2`. HP 65, Damage 8, Range 160, Cooldown 1.35, Speed 95, Armor 0, XP value 20.
- Acolyte: Free Marches, magic support. Cost Crowns 70, Aether 40. Train 6s. Radius 12. Color `0xb6e6d3`. Projectile `0x8ff7ff`. HP 55, Damage 6, Range 140, Cooldown 1.2, Speed 85, Armor 0, XP value 20.

Enemy units:

- Raider: Ashen Covenant, melee attacker. Cost Crowns 55, Iron 20. Train 4s. Radius 13. Color `0xc75f4e`. HP 85, Damage 9, Range 28, Cooldown 1, Speed 98, Armor 1, XP value 15.
- Hexer: Ashen Covenant, ranged magic. Cost Crowns 75, Aether 35. Train 5s. Radius 12. Color `0xb36ee2`. Projectile `0xdd8cff`. HP 60, Damage 8, Range 150, Cooldown 1.25, Speed 88, Armor 0, XP value 20.
- Brute: Ashen Covenant, tank. Cost Crowns 110, Iron 50. Train 7s. Radius 16. Color `0x9f4a36`. HP 160, Damage 13, Range 30, Cooldown 1.25, Speed 72, Armor 3, XP value 30.
- Ashen Commander: enemy hero placeholder. No cost. Radius 18. Color `0xf06a43`. HP 260, Damage 16, Range 34, Cooldown 1.1, Speed 92, Armor 3, XP value 150.

Neutral units:

- Wild Hound: Wilds, fast monster. No cost. Radius 12. Color `0x8f7a54`. HP 55, Damage 7, Range 24, Cooldown 0.9, Speed 105, Armor 0, XP value 12.
- Stone Imp: Wilds, tough monster. No cost. Radius 14. Color `0x948a7a`. HP 85, Damage 8, Range 26, Cooldown 1.2, Speed 72, Armor 2, XP value 18.

## Buildings

Buildings live in `src/game/data/buildings.ts`.

Player:

- Command Hall: Free Marches. Losing it means defeat. Cost none. HP 1200, Armor 4, Size 96x82, Color `0x5f8c6f`. Build options: Barracks, Mystic Lodge, Watchtower. Trains nothing. XP value 80.
- Barracks: Free Marches. Trains Militia and Ranger. Cost Crowns 180, Stone 120. HP 600, Armor 3, Size 82x64, Color `0x7a9d73`. XP value 80.
- Mystic Lodge: Free Marches. Trains Acolytes. Cost Crowns 160, Stone 100, Aether 80. HP 450, Armor 2, Size 72x62, Color `0x6097a8`. XP value 80.
- Watchtower: Free Marches. Defensive long-range attack. Cost Crowns 120, Stone 100, Iron 40. HP 350, Armor 2, Size 48x72, Color `0xb2a15e`. Attack: Damage 14, Range 220, Cooldown 1.1, Projectile `0xffdf75`. XP value 80.

Enemy:

- Enemy Stronghold: Ashen Covenant. Destroy this to win. Cost none. HP 1000, Armor 4, Size 104x88, Color `0x8f443b`. XP value 80.
- Enemy Barracks: Ashen Covenant. Trains Raider, Hexer, Brute. Cost none. HP 550, Armor 3, Size 82x64, Color `0x93483e`. XP value 80.

## Current Map

Map data lives in `src/game/data/maps.ts`.

Default map:

- ID: `first_claim`.
- Name: First Claim.
- Size: 2400x1600.
- Player start: x 260, y 800.
- Enemy start: x 2140, y 800.

Terrain zones:

- `central_grass`: grass, x 0, y 0, w 2400, h 1600.
- `player_build`: buildable, x 70, y 590, w 520, h 440.
- `enemy_build`: buildable, x 1800, y 560, w 520, h 480.
- `north_water`: water, x 720, y 160, w 380, h 140.
- `south_water`: water, x 1280, y 1250, w 420, h 130.
- `broken_ridge`: blocked, x 1060, y 660, w 260, h 100.
- `old_ruins`: blocked, x 820, y 1030, w 160, h 140.

Capture sites:

- Crown Shrine: `crown_shrine`, crowns, x 850, y 780, radius 76, income 30 every 5s.
- Stone Quarry: `stone_quarry`, stone, x 1180, y 390, radius 76, income 25 every 5s.
- Iron Vein: `iron_vein`, iron, x 1390, y 1010, radius 76, income 20 every 5s.
- Aether Well: `aether_well`, aether, x 1580, y 610, radius 76, income 15 every 5s.

Neutral camps:

- Sunken Road Pack: x 710, y 1110, units Wild Hound, Wild Hound, Stone Imp.
- Quarry Imps: x 1160, y 520, units Stone Imp, Stone Imp.
- Old Well Guard: x 1650, y 760, units Wild Hound, Stone Imp, Wild Hound.

Scenario spawns:

- Player Command Hall: `command_hall`, player, x 260, y 800.
- Enemy Stronghold: `enemy_stronghold`, enemy, x 2140, y 800.
- Enemy Barracks: `enemy_barracks`, enemy, x 2010, y 890.
- Hero: x 340, y 760.
- Player Militia 1: x 350, y 845.
- Player Militia 2: x 390, y 835.
- Player Ranger 1: x 370, y 715.
- Enemy Raider 1: x 2050, y 740.
- Enemy Raider 2: x 2010, y 760.
- Enemy Hexer 1: x 2045, y 825.
- Enemy Brute 1: x 2100, y 870.
- Enemy Commander 1: x 2110, y 705.

Objectives:

- Player base building ID: `command_hall`.
- Enemy base building ID: `enemy_stronghold`.

Enemy AI config:

- Income interval: 5s.
- Income per tick: Crowns 90, Stone 45, Iron 45, Aether 35.
- Train interval: 3.5s.
- Expand interval: 7s.
- Initial expand delay: 5s.
- Attack interval: 36s.
- Initial attack delay: 12s.
- Minimum attack army size: 4.
- Attack wave size: 8.
- Expand squad size: 3.
- Defense squad size: 6.
- Defend radius: 400.
- Base building ID: `enemy_stronghold`.
- Production building ID: `enemy_barracks`.
- Attack target building ID: `command_hall`.
- Unit plan: Raider, Raider, Hexer, Raider, Brute.

Reward table: `first_claim_rewards`.

## Items And Rewards

Items live in `src/game/data/items.ts`.

Weapons:

- Weathered Command Sword, common weapon: damage +4, might +1, command +1.
- Emberglass Wand, common weapon: damage +2, max Mana +20, arcana +2.
- Pilgrim Crook, common weapon: damage +2, max Mana +12, faith +2.

Armor:

- Marcher Plate, uncommon armor: max HP +36, armor +2, speed -4.
- Runewoven Robes, uncommon armor: max HP +18, max Mana +28, armor +1, arcana +1.
- Dawnward Vestments, uncommon armor: max HP +24, armor +1, faith +2.

Trinkets:

- Captain's Seal, rare trinket: command +3, max HP +16.
- Aether Lens, rare trinket: arcana +3, max Mana +30.
- Green Chapel Icon, rare trinket: faith +3, command +1, max Mana +16.

Reward table `first_claim_rewards` includes all nine current items.

## Entity Rendering

Base entity behavior lives in `src/game/entities/BaseEntity.ts`.

Common entity state:

- ID.
- Kind.
- Team.
- Position.
- Radius.
- Max HP.
- Current HP.
- Armor.
- Alive flag.
- Selected flag.
- Optional Phaser container.
- Selection ring.
- Health back/fill rectangles.
- Text label.

Recent health-bar UI update:

- Health bars are framed dark strips with light trim.
- Bar widths and heights can be configured per entity type.
- Bars are positioned relative to actual sprite visual bounds, not collision radius.
- Unit and hero bars now sit above the visible sprite art.
- Building bars now sit above the visible building art and are wider.
- Labels are positioned below visible art and shadows.
- This avoids health bars cutting across the new 512x512 unit sprites or 768x768 building sprites.

Unit rendering:

- `Unit.ts` looks for battle sprite assets via `unitBattleAssetIds`.
- If an asset exists, it renders a scaled Phaser image with an ellipse shadow.
- If no asset exists, it falls back to a colored circle.
- Hero sprites are slightly taller than normal unit sprites.
- Damage buffs tint the sprite and stroke fallback bodies.

Building rendering:

- `Building.ts` looks for battle sprite assets via `buildingBattleAssetIds`.
- If an asset exists, it renders a scaled building image with an ellipse shadow.
- Enemy buildings are tinted slightly red.
- If no asset exists, it falls back to a colored rectangle.

Capture site rendering:

- `CaptureSite.ts` extends `BaseEntity` but hides health.
- It draws a colored capture ring, a progress ring, and a resource icon if available.
- Ownership recolors the ring.

## Battle Background Rendering

`BattleScene.drawMap()` now paints a more finished battlefield instead of a flat rectangle.

Current visual layers:

- Deep green base terrain.
- Large soft biome patches.
- Deterministic grass, dirt, and fleck texture.
- Dirt roads connecting player base, center, capture points, and enemy base.
- Buildable encampment grounds with tinted ground panels, faint planning lines, and corner stakes.
- Water rendered as oval ponds with shadow, highlights, shore rings, and ripple strokes.
- Blocked areas rendered as rocky mounds with layered stone shapes.
- Capture-site ground halos under each site.
- Grass tuft strokes and small stone flecks.
- Dark map-edge vignette and border.

This is all runtime Phaser graphics. There is not yet a single painted battle-background bitmap file.

## DOM HUD

`src/game/ui/HUD.ts` builds the battle HUD as HTML inside `#ui-root`. `src/game/styles/ui.css` styles it.

HUD surfaces:

- Top resource row: Crowns, Stone, Iron, Aether.
- Menu button.
- Hero panel in lower-left: portrait, name, level, HP, mana, HP meter, XP meter, XP, skill points.
- Side panel in lower-right: selected entity title, stats, build buttons, train buttons, hero abilities.
- Minimap shell in upper-right with simple dots for player, enemy, and site.
- Status line near the top center.

Recent HUD polish:

- Battle UI now has a subtle edge vignette so the playfield reads more like a game scene.
- Resource pills and panels use blur-backed game panels.
- Meters have subtle borders.
- Selection grid text truncates cleanly.
- Top resource row is constrained so it leaves room for the menu button.

## Systems

Important systems live in `src/game/systems`.

- `InputSystem`: pointer selection, drag box, right-click movement/attack, keyboard hotkeys, attack-move, building placement input.
- `SelectionSystem`: selects player units/buildings by point or box.
- `CameraSystem`: camera bounds and WASD/arrow panning.
- `MovementSystem`: direct steering, light separation, map blocking.
- `CollisionSystem`: entity picking and overlap helpers.
- `CombatSystem`: target acquisition, cooldowns, projectiles, damage, kills.
- `AbilitySystem`: hero ability effects, projectiles, buffs, heals, blink.
- `ResourceSystem`: capture progress, site ownership, income ticks.
- `BuildingSystem`: building placement rules, ghost preview, cost payment.
- `TrainingSystem`: building training queues and unit spawn.
- `AISystem`: wraps enemy AI controller updates.
- `XPSystem`: awards hero XP for kills within share range and handles level-ups.
- `UISystem`: updates/destroys HUD.

## AI

Enemy behavior is split between `src/game/ai/AIStateMachine.ts`, `EnemyAIController.ts`, and `systems/AISystem.ts`.

The current enemy AI:

- Receives periodic resource income.
- Trains units from Enemy Barracks according to the configured unit plan.
- Expands toward capture sites.
- Keeps a defense force around its base.
- Sends attack waves toward the player Command Hall.
- Is intentionally simple and predictable.

## Assets

Asset code:

- `src/game/assets/AssetKeys.ts`: canonical asset IDs and helpers.
- `src/game/assets/AssetLoader.ts`: manifest loading, CSS URL helpers, image tag helpers, texture queueing, UI-kit CSS variable application.
- `src/game/assets/AssetManifestTypes.ts`: manifest types.

Asset locations:

- Manual source art: `public/assets/manual`.
- Cleaned game-ready art: `public/assets/final`.
- Runtime manifest: `public/assets/manifests/assetManifest.json`.

Asset priority:

1. `final`
2. `manual`
3. `placeholder`
4. Runtime fallback shapes if needed.

Important recent asset state from the prior pass:

- Manifest had 62/62 file-backed assets.
- Unit final battle sprites were processed as 512x512 PNGs with alpha.
- Building final battle sprites were processed as 768x768 PNGs with alpha.
- Missing battle assets were 0.
- Original manual files remain untouched in `public/assets/manual`.
- Cleaned copies live in `public/assets/final`.
- `npm run assets:refresh` now processes sprites, rebuilds the manifest, and validates assets.

Battle texture asset IDs include:

- Hero portraits: Warlord, Arcanist, Shepherd, Enemy Commander.
- Hero battle sprites: Warlord, Arcanist, Shepherd.
- Resource icons: Crown Shrine, Stone Quarry, Iron Vein, Aether Well.
- Unit sprites: Militia, Ranger, Acolyte, Raider, Hexer, Brute, Enemy Commander, Wild Hound, Stone Imp.
- Unit concepts: Militia, Ranger, Acolyte.
- Building sprites: Command Hall, Barracks, Mystic Lodge, Watchtower, Enemy Stronghold, Enemy Barracks.
- Building concepts: Command Hall, Barracks, Mystic Lodge, Watchtower.

UI-kit asset IDs:

- `ui_panel_frame`
- `ui_button_idle`
- `ui_button_hover`
- `ui_button_pressed`
- `ui_resource_frame`
- `ui_divider_ornament`
- `ui_tooltip_frame`
- `ui_minimap_frame`
- `ui_ability_slot_frame`
- `ui_inventory_slot_frame`
- `ui_victory_panel_frame`
- `ui_defeat_panel_frame`
- `battle_hud_panel`

Other UI/background assets:

- Main menu background.
- Victory screen background.
- Defeat screen background.
- Ascendant Realms key art.

## Manual Art Workflow

The project intentionally avoids paid image APIs.

Manual workflow:

1. Run `npm run assets:prompts`.
2. Open `public/assets/manual/ASSET_PROMPT_BOOK.md`.
3. Generate images manually in ChatGPT or another tool.
4. Save them to the specified `public/assets/manual` subfolders.
5. Exact snake_case filenames are best, but human-readable names are accepted.
6. Run `npm run assets:refresh`.
7. Refresh the browser.
8. Use Asset Gallery to confirm `Image loaded`.

For free prototype UI kit:

```bash
npm run assets:ui-kit
npm run assets:refresh
```

## Tests

Current test areas:

- Battle launch request contract.
- Battle runtime setup, objectives, results, rewards, save decisions.
- Content validation for referenced IDs.
- Hero progression rules.
- Save system.
- Building placement rules.

Run all tests:

```bash
npm test
```

## Current Known Limitations

- There is only one playable skirmish map.
- The battle background is procedural Phaser graphics, not a dedicated painted bitmap.
- Movement uses direct steering with light separation, not full A* pathfinding.
- Fog of war is not implemented.
- Workers, construction time, shops, diplomacy, campaign nodes, retinue persistence, and respec are not implemented.
- Item rewards are deterministic for testability and do not have rarity-weighted rolls yet.
- Enemy AI is simple and predictable.
- Balance is prototype-only.
- `BattleScene` still owns spawning, rendering, input, and system wiring.
- `BattleRuntime` is the first pure battle-state/results boundary, but live entity state is not fully serializable.
- Some engine classes still combine simulation data with Phaser visuals.
- The minimap is symbolic/static rather than a live scaled map.
- UI and gameplay are designed for prototype readability, not final art direction.

## Suggested Next Work

Good next requests:

- Add construction time and worker builders.
- Add a second skirmish map.
- Add rarity-weighted item rewards.
- Improve enemy AI wave timing and document balance knobs.
- Split simulation state from Phaser view objects.
- Add fog of war.
- Replace procedural battle terrain with a dedicated painted battlefield bitmap plus collision overlays.
- Make the minimap live.
- Add build previews and placement affordances for exact blocked/buildable terrain.
- Add a respec button to hero progression.

## Files Most Likely To Change For Common Tasks

- New unit: `data/units.ts`, `AssetKeys.ts`, prompt book tooling if art is needed, tests through content validation.
- New building: `data/buildings.ts`, `systems/BuildingSystem.ts` if behavior changes, `AssetKeys.ts`, map/build options.
- New map: `data/maps.ts`, content validation tests, maybe background drawing in `BattleScene`.
- New ability: `data/abilities.ts`, `systems/AbilitySystem.ts`, `AssetKeys.ts`, ability icon asset/prompt.
- New hero class: `data/heroClasses.ts`, hero asset IDs, portraits, battle sprite IDs, creation UI.
- HUD change: `ui/HUD.ts`, `styles/ui.css`, sometimes `ui/AbilityBar.ts`, `ui/BuildMenu.ts`, `ui/SelectionPanel.ts`.
- Battle rendering change: `entities/BaseEntity.ts`, `entities/Unit.ts`, `entities/Building.ts`, `entities/CaptureSite.ts`, `scenes/BattleScene.ts`.
- Save/progression change: `core/SaveSystem.ts`, `save/SaveTypes.ts`, `core/HeroProgressionRules.ts`, `core/Progression.ts`, tests.

## Recent Work In This Handoff Pass

- Repositioned in-world health bars above actual visual sprite bounds rather than collision radius.
- Added framed health-bar treatment.
- Reduced unit and building sprite display height slightly to leave clean UI space.
- Moved building health bars further above roofs.
- Added a procedural battlefield background with roads, ponds, build grounds, rocky blockers, texture, capture-site halos, and a border.
- Added subtle battle HUD polish in CSS.
- Created this handoff document.
