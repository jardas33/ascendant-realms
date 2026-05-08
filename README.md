# Ascendant Realms

Ascendant Realms is a frozen v0.3 Cinderfen route baseline for a long-term fantasy RTS/RPG hybrid, with v0.3.1 frozen as its polish/readability layer, v0.4 serving as technical/UX/planning groundwork, and v0.5 adding a save, content-validation, determinism, and expansion-readiness gate. The visible main menu labels the playable build as `Prototype v0.3` with the subtitle `Cinderfen Route Baseline`; v0.2 remains the previous systems baseline, while v0.3 promotes the compact Chapter 2 Cinderfen route on top of that technical foundation. You create a persistent hero, enter campaign nodes or skirmishes, capture magical resource sites, build a small army, fight enemies and named rival commanders, level up, earn loot with item affixes, claim small rival victory rewards and trophies, spend campaign resources on Stronghold upgrades and Cinderfen preparation services, make compact reputation-shifting choices, and save progress locally.

This is the engine-first foundation, not the full game. Everything is intentionally simple and expandable.

Current v0.3 feature snapshot:

- Compact Chapter 2 Cinderfen route after Ashen Outpost: Overlook, optional Waystation, Crossing, Watch, and Aftermath. The current playable v0.3 slice ends at Cinderfen Aftermath; more Cinderfen content is upcoming.
- Named enemy heroes/rival commanders on important Ashen campaign battles, with compact persistent rival state.
- Rival Rewards and Trophies V1 with once-only first-defeat rewards and cosmetic trophy records.
- Retinue Camp V1 for a small save-backed roster of surviving veteran units.
- Unit Veterancy V1 with Recruit, Seasoned, Veteran, and Elite ranks.
- Stronghold Development Tier II with compact persistent upgrade effects.
- Randomized item affixes V1 on reward-generated item instances.
- Reputation hooks for modest campaign choice consequences and preparation effects.
- CampaignRules split into focused pure-rule modules behind a compatibility facade.
- HUD/fog polish for stable command hover, side-panel scroll preservation, and captured-site local reveal behavior.
- Cinderfen reward-economy audit and Chapter 2 Playwright helper cleanup, with first-clear rewards useful and repeat rewards kept tiny.
- v0.5 save fixture tests, standalone content validation, campaign graph/reward validation, simulator determinism checks, and a non-playable Tutorial / Proving Grounds metadata scaffold for future onboarding work.

## Design Pillars

The long-term goal is to grow around four pillars:

- Persistent hero fantasy.
- Faction asymmetry.
- Living campaign map.
- Data-driven and mod-friendly content.

Early versions may look rough. The important thing is that the project stays playable, expandable, and easy to change.

## Install

1. Install Node.js if you do not already have it.
2. Open a terminal in this project folder.
3. Run:

```bash
npm install
```

## Run

```bash
npm run dev
```

Then open the local URL shown in the terminal, usually:

```text
http://localhost:5173
```

## Build

```bash
npm run build
```

Latest v0.5 gate checkpoint status, 2026-05-08: build passes. App JS is about 445.42 kB / 119.69 kB gzip, `vendor-phaser` is about 1,481.79 kB / 339.86 kB gzip, and CSS is about 42.04 kB / 8.74 kB gzip. Vite may warn that the Phaser vendor chunk is larger than 500 kB; that warning is known and is not a build failure.

## Test Content And Pure Rules

```bash
npm run validate:content
npm run test
```

Run `npm run validate:content` after changing data files or adding future campaign content. It runs the data validator without opening the game UI and fails with a plain list of broken references or duplicate IDs. Then run `npm run test` for the broader pure-rule suite. Together they check the level curve, hero progression rules, building placement rules, save migration fixtures, and whether units, buildings, abilities, skill trees, reward tables, maps, objectives, resources, capture sites, terrain zones, campaign graphs, AI plans, rivals, Stronghold upgrades, and Cinderfen-specific modifiers reference valid IDs.

Latest v0.5 gate checkpoint status, 2026-05-08: `npm run validate:content` passes, and `npm test` passes with 40 test files and 298 tests, including save fixture migration coverage, campaign graph/reward validation, simulator determinism checks, Tutorial / Proving Grounds metadata validation, Retinue rules, enemy hero/rival reward data validation, Cinderfen reward and launch references, campaign presentation view-model coverage, save/load, launch, retry, Results trophy display, simulator coverage, and Chapter 2 selected chapter/node save preservation.

## Browser E2E Test Lanes

```bash
npm run test:e2e:smoke
```

The browser suite uses Playwright and starts the Vite dev server automatically. The fast default lane runs `tests/e2e/smoke.spec.ts` and currently covers 11 tests: main menu boot, Tutorial / Proving Grounds no-reward shell launch, Settings persistence, New Campaign into Campaign Map, locked-node blocking, Border Village battle launch, Cinderfen Overlook/Waystation/Crossing reward persistence, Cinderfen Watch and Aftermath completion, Malrec trophy event behavior, skirmish launch, difficulty/fog setup, and inventory reachability.

Additional lanes keep the slower coverage available without making it the default frequent-iteration command:

```bash
npm run test:e2e:layout
npm run test:e2e:deep
npm run test:e2e:release
```

`test:e2e:layout` runs responsive layout and mobile/readability checks from `tests/e2e/layout.spec.ts`. `test:e2e:deep` runs the release-critical full-flow gameplay checks from `tests/e2e/deep-flow.spec.ts`, including at least one full first-battle campaign path. `test:e2e:release` runs the full Playwright suite with line reporter; `npm run test:e2e` remains the full suite as well.

The e2e suite runs with one worker for stability because live Phaser scenes, video capture, and the Vite dev server can time out when several full game flows run at once on a local machine. The full release gate is intentionally slower than the smoke lane; the latest tutorial shell smoke check passed 11 tests in 5.1 minutes, and the latest full v0.5 release-gate verification passed 59 tests in 28.4 minutes.

For CI, the full release gate can also be split into two Playwright shards:

```bash
npm run test:e2e:release:shard1
npm run test:e2e:release:shard2
```

Both shards together equal the full `test:e2e:release` suite; neither removes coverage. These scripts are mainly for CI matrix jobs. Running both sequentially on a local machine usually has similar total runtime to the full release gate and produces split logs, so local developers can keep using `test:e2e:smoke` for frequent checks and `test:e2e:release` for one-piece release verification.

Latest full-shard verification for the v0.5 gate, 2026-05-08: smoke passed 10 tests in 4.5 minutes, release shard 1 passed 49 tests in 23.9 minutes, and release shard 2 passed 10 tests in 4.4 minutes. The split is intentionally optional and currently uneven; CI parallelism is the main benefit.

For a visible browser run:

```bash
npm run test:e2e:headed
```

## Playtest Simulation

```bash
npm run playtest:sim
```

This runs the deterministic campaign battle simulator and regenerates `PLAYTEST_TELEMETRY.md` and `PLAYTEST_TELEMETRY.json`. Latest v0.5 gate checkpoint status, 2026-05-08: passed with 255 simulated runs across 85 campaign battle node/profile summaries, no too-easy nodes, no structural too-hard nodes, Ashen Outpost beatable, no Stronghold warnings, Cinderfen Crossing and Cinderfen Watch covered, and Cinderfen repeat rewards reduced to tiny non-item payouts.

## Preview A Build

```bash
npm run preview
```

## Manual Asset Workflow (No API Costs)

This project does not use paid image APIs. You can generate images manually in ChatGPT, download them, and place them in `public/assets/manual`.

1. Run `npm run assets:prompts`.
2. Open `public/assets/manual/ASSET_PROMPT_BOOK.md`.
3. Copy one prompt into ChatGPT image generation.
4. Download the image.
5. Save it in the folder listed in the prompt book.
6. The exact snake_case filename is best, such as `warlord_hero_portrait.png`.
7. Human-readable names such as `Warlord Hero Portrait.png` also work.
8. Run `npm run assets:manifest` to let the project find the image.
9. Run `npm run assets:validate` to check for missing or broken paths.
10. Or run `npm run assets:refresh` to process battle sprites, rebuild the manifest, and validate everything at once.
11. Run or refresh the game.

Asset priority is `final`, then `manual`, then `placeholders`, then built-in runtime fallbacks. Missing art is okay; the game should keep running.

Use the `Asset Gallery` button on the main menu to confirm which images the game can see. Each card says `Image loaded` when the browser has actually loaded that file.

If the terminal is open in the outer `WB game like` folder instead of the `ascendant-realms` folder, the same `npm run ...` commands now work there too.

## Dedicated UI Art Kit

The game now has a dedicated optional UI-kit lane for reusable interface art. These are not backgrounds. They are frames, slots, dividers, and button states that the CSS uses carefully through scalable frame rules.

Generate these from the prompt book when you want the HUD and menus to feel more like a polished game:

- `ui_panel_frame.png`
- `ui_button_idle.png`
- `ui_button_hover.png`
- `ui_button_pressed.png`
- `ui_resource_frame.png`
- `ui_divider_ornament.png`
- `ui_tooltip_frame.png`
- `ui_minimap_frame.png`
- `ui_ability_slot_frame.png`
- `ui_inventory_slot_frame.png`
- `ui_victory_panel_frame.png`
- `ui_defeat_panel_frame.png`

Put them in `public/assets/manual/ui`, then run `npm run assets:refresh` and refresh the browser. Missing UI-kit files are safe; the game uses the current CSS fallback.

See `UI_ART_KIT.md` for the full filename list and rules for good frame art.

For in-battle unit, hero, and building sprites, see `BATTLE_ASSET_PROMPTS.md`. The battle renderer now uses dedicated battle sprite files when they exist, falls back to concept art or portraits where possible, and finally falls back to simple Phaser shapes.

To create a free starter set without any image API, run:

```bash
npm run assets:ui-kit
npm run assets:refresh
```

This writes original procedural PNG frames into `public/assets/manual/ui`. They are meant as prototype UI art and can be replaced later with polished manual or final art.

## Reset Save

Use the `Reset Save` button on the main menu. You can also clear the browser's local storage for this site.

## Save Data

The game stores one local save under the browser localStorage key defined in `src/game/core/Constants.ts`. Current saves write `version: 2` and include `createdAt`, `updatedAt`, `hero`, `campaign`, `settings`, and a placeholder `statistics` object.

Settings currently include master/music/SFX volume, screen shake enabled, floating text enabled, fog override, reduced motion, UI scale, and a colorblind-friendly minimap palette. Saving settings before creating a hero creates a settings-only save marker; starting a campaign or skirmish later keeps those settings and replaces the placeholder hero data.

Older `version: 1` saves are migrated in memory when loaded. Invalid JSON or invalid save shapes are rejected safely and do not clear or overwrite the existing localStorage value. New writes always use the current version 2 shape.

## Campaign

Use `New Campaign` from the main menu to create or reuse a hero and open the Border Marches campaign map. Select an available node, read its details, then start the battle or choose an event outcome. Victories complete battle nodes, claim node rewards once, add node resource rewards to the persistent campaign bank, save progress, and unlock connected nodes. Defeats can be retried or returned to the campaign map.

The first skeleton campaign has eight nodes:

- Border Village.
- Old Stone Road.
- Marcher Camp.
- Aether Well Ruins.
- Bandit Hillfort.
- Chapel of the Marches.
- Refugee Caravan.
- Ashen Outpost.

After Ashen Outpost, the current v0.3 baseline adds the compact Cinderfen route:

- Cinderfen Overlook.
- Cinderfen Waystation.
- Cinderfen Crossing.
- Cinderfen Watch.
- Cinderfen Aftermath.

Cinderfen Aftermath is the end of the current playable v0.3 Chapter 2 slice. Completing it should leave the campaign map in a clear route-secured state; any later Cinderfen nodes should remain upcoming/locked until their maps and content exist.

Chapel of the Marches and Refugee Caravan use simple data-driven choices. Marcher Camp is the first town sink: it stays available after Old Stone Road and lets you spend campaign Crowns on rest, volunteers, supplies, and a small fixed item stock. The Campaign Map also includes the Stronghold panel, where two tiers of persistent upgrades spend Crowns, Stone, Iron, and Aether and apply to later battle launches. Choices can be locked by resource costs, hero level, ownership, previous purchase, or faction reputation; pay from the campaign resource bank; grant XP/items/resources; change faction reputation; unlock nodes; and save once-only claims. Reputation ranks and active effects are visible before the player commits.

Skirmish mode remains separate through the `Skirmish` button.

## Post-Battle Rewards

After victory, the Results screen summarizes the map, difficulty, battle time, XP gained, level progress before and after, level-ups, skill points gained, battle rewards, and campaign node rewards when applicable. Earned equipment creates an inventory instance immediately. Equippable rewards show rarity, slot, stat modifiers, source details, the currently equipped item in that slot, and an Equip Now comparison.

Using Equip Now equips the earned item instance, saves the updated hero equipment, and recalculates stats, including valid affix stat modifiers. Leaving the screen without equipping keeps the instance in inventory. Campaign node item rewards are claimed once. If a unique reward is already owned, the reward converts into campaign Crowns or Aether and the Results screen shows the conversion.

Campaign resource awards are added to a persistent campaign bank with Crowns, Stone, Iron, and Aether. That bank is separate from temporary battle resources. Marcher Camp and Stronghold Development spend from it now; later shops, mercenaries, repairs, and broader upgrades should use the same bank.

## Controls

- Left click: select a friendly unit or building.
- Drag with left mouse: box-select friendly units.
- Right click ground: move selected units.
- Right click ground with a completed Barracks or Mystic Lodge selected: set its rally point.
- Right click enemy: attack selected enemy.
- `Shift+A`, then right click: attack-move selected units.
- `H`: select hero.
- `1`, `2`, `3`: use unlocked hero abilities.
- `Space`: center camera on hero.
- Click minimap: center camera on that map location.
- `F`: debug-toggle fog of war on difficulties where fog is enabled.
- `Esc`: clear selection or cancel building placement.
- `WASD` or arrow keys: pan camera.

## Current Features

- Main menu, hero creation, campaign map, skirmish setup, reset save, credits/info.
- Settings screen for audio, reduced motion, floating text, UI scale, fog override, colorblind minimap colors, and keyboard controls.
- Lightweight generated WebAudio cues for UI clicks, selection, build start/complete, unit trained, ability cast, victory, and defeat. Audio fails silently when the browser or test environment blocks it.
- Eight-node Chapter 1 campaign skeleton plus the compact Chapter 2 Cinderfen route with locked, available, completed, town-service, choice-driven node states, and route-complete copy after Cinderfen Aftermath.
- Persistent campaign resource bank for node rewards, event choice costs, Marcher Camp services, and Stronghold upgrades.
- Stronghold Development panel with five Tier I upgrades and five matching Tier II upgrades, prerequisite locks, campaign-resource costs, and battle-launch effects.
- Reputation ranks for Free Marches, Common Folk, Old Faith, Ashen Covenant, and Sylvan Concord placeholder, with small active effects for Marcher Camp discounts, Stronghold Crown discounts, Chapel Aether bonuses, and Ashen hostile pressure.
- Hero inventory screen from the main menu.
- Asset gallery for checking manual/final/placeholder art.
- Three hero classes: Warlord, Arcanist, Shepherd.
- Three origins with small stat modifiers.
- Three skill trees: Combat, Magic, Leadership.
- Three data-defined abilities per class.
- Skill point allocation after level-up.
- Rarity-weighted item rewards after victory.
- Randomized item affixes V1 with slot-filtered stat packages, deterministic test generation, save persistence, equipment stat contribution, and Results/Inventory display.
- Equipment slots: weapon, armor, trinket.
- Five playable skirmish/campaign battle maps: First Claim, Broken Ford, Ashen Outpost, Cinderfen Causeway, and Cinderfen Watchpost.
- Player base, enemy base, neutral camps, and capturable resource sites.
- Four resources: Crowns, Stone, Iron, Aether.
- Building placement for Barracks, Mystic Lodge, and Watchtower with valid/invalid previews.
- Automatic construction with under-construction visuals and disabled production until complete.
- Unit training queues from Barracks and Mystic Lodge, with visible progress and cancel/refund.
- Rally points for completed production buildings, with world markers and selected-building minimap markers.
- Data-driven tech prerequisites and basic upgrades.
- Live RTS minimap with units, buildings, capture sites, camera viewport, click-to-pan, and alert pings.
- Lightweight grid fog of war with unseen, explored, and visible states. Enemy and neutral units/buildings are hidden outside current vision.
- Simple RTS selection, movement, combat, projectiles, XP, level-up, and ability use.
- Unit Veterancy V1 with battle-local unit XP, Recruit/Seasoned/Veteran/Elite ranks, selected-unit rank display, rank-up feedback, and Notable Veterans in victory Results.
- Retinue Camp V1 with a small save-backed campaign roster, Results recruitment for eligible veterans, Campaign Map display/dismiss, campaign battle deployment, and permanent removal when a retinue unit dies.
- Enemy Hero / Rival Commander V1 with Gorak Emberhand, Veyra of the Cinders, and Captain Malrec assigned to important campaign battles, plus scout feedback, minimap markers, modest abilities, XP/objective/results credit, and playtest telemetry.
- Rival/Nemesis Persistence V1 with save-backed rival encounters, defeats, victories against the player, last outcomes, dispositions, small repeat-encounter modifiers, Campaign Map intel, Results consequences, and simulator telemetry.
- Rival Rewards and Trophies V1 with data-driven first-defeat rewards, duplicate prevention, persistent trophy records, Campaign Map trophy display, Results reward copy, and simulator telemetry.
- Simple enemy AI that expands, trains, defends, sends attack waves, and uses selectable/campaign-assigned personalities.
- Shared victory/defeat Results screen with XP summary, item rewards, Equip Now, campaign node completion details, retry/return flow, and local hero save.
- Pure `BattleRuntime` tests for setup, objectives, battle results, rewards, and save-output decisions.
- `BattleLaunchRequest` contract so skirmish, campaign nodes, and future scenario missions can all start battles through one clean pathway.
- Clean procedural UI skin for menus, result panels, HUD panels, and info boxes.
- Optional dedicated UI-kit assets for panel frames, button states, resource frames, dividers, tooltip frames, minimap frame, ability slot frame, inventory slot frame, victory panel, and defeat panel.
- Automated playtest simulator coverage for no-upgrade, Tier I Stronghold, Tier II Quartermaster, Retinue/Training Yard II, and Chapter 2 Cinderfen campaign paths.

## Known Limitations

- Gameplay units and buildings use dedicated battle sprites when available, then fall back to concept art or simple Phaser shapes if art is missing.
- Movement uses a coarse A* pathfinding grid plus local separation. It is not formation-aware or flow-field based yet.
- Fog of war is grid-based and does not do line-of-sight around blockers yet. Story difficulty disables it; other difficulties can tune it through `fogOfWarEnabled`.
- Workers, broad vendors, full diplomacy, and enemy construction are postponed.
- Retinue Camp V1, Enemy Hero / Rival Commander V1, Rival/Nemesis Persistence V1, and Rival Rewards and Trophies V1 are intentionally small: no replacement UI, wounded timers, deep nemesis branches, unit biographies, scars/titles, full trophy room, crafting, durability, broad loot complexity, broad army management, enemy construction, or raid-boss layer yet.
- Campaign is a skeleton only: Marcher Camp, Stronghold Development, Cinderfen Waystation, Cinderfen Aftermath, and reputation effects prove small resource sinks and consequences, but there is no full diplomacy, procedural random event system, invasion layer, or world simulation yet.
- Skill choices do not support respec yet.
- AI personalities change timing and composition, but AI is still intentionally simple and predictable compared with a full scouting/counter-build system.
- Balance is prototype-only and expected to change often.
- Some engine classes still combine simulation data with Phaser visuals. That is acceptable for this slice, but should be split before multiplayer or replay work.
- `BattleScene` is partly split into helper modules for spawning, map rendering, alerts, snapshots, objectives, and results. It still owns live Phaser orchestration and input, and live entity state is not fully serializable yet.
- The UI-kit assets are optional and currently missing until generated manually. The game falls back to CSS styling when they are not present.

## How To Ask Codex For The Next Feature

Good next prompts are specific and small. Examples:

- "Verify the v0.3 Cinderfen route end to end and polish readability without adding gameplay or changing balance."
- "Human-review Border Village through Ashen Outpost with no retinue, one Veteran Militia, one Veteran Ranger, and mixed retinue."
- "Tune Retinue Camp V1 if saved veterans trivialize early nodes or feel mandatory for Ashen Outpost."
- "Human-review Stronghold Tier II, reputation effects, retinue, rival commanders, and affixed reward readability in the current campaign."
- "Review Rival/Nemesis Persistence V1 balance and readability without adding enemy construction or new factions."
- "Review Rival Rewards and Trophies V1 balance and readability without adding crafting, durability, or a full trophy room."
- "Split ResultsScene into smaller reward, campaign-return, and item-comparison helpers."
- "Split maps.ts into one file per map without changing map behavior."
- "Improve formation movement and dynamic path blockers without changing combat balance."
- "Add a respec button to the hero progression screen."
- "Implement the first Tutorial / Proving Grounds playable shell using existing content only, with no rewards and no save-version bump."

## Troubleshooting

- If `npm install` fails, check that Node.js is installed and restart the terminal.
- If the browser page is blank, run `npm run build` and look for TypeScript errors.
- If the game feels stuck after edits, stop the dev server with `Ctrl+C`, run `npm install`, and start it again.
- If `Continue Campaign` is disabled, start a new campaign first.
- If `Hero Inventory` is disabled, create a hero first.
