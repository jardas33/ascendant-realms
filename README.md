# Ascendant Realms

Ascendant Realms is a small first playable prototype for a long-term fantasy RTS/RPG hybrid. You create a persistent hero, enter campaign nodes or skirmishes, capture magical resource sites, build a small army, fight enemies, level up, earn loot, and save progress locally.

This is the engine-first foundation, not the full game. Everything is intentionally simple and expandable.

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

## Test Content And Pure Rules

```bash
npm run test
```

Run this after changing data files. It checks the level curve, hero progression rules, building placement rules, and whether units, buildings, abilities, skill trees, reward tables, maps, objectives, resources, capture sites, terrain zones, and AI plans reference valid IDs.

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

## Campaign

Use `New Campaign` from the main menu to create or reuse a hero and open the Border Marches campaign map. Select an available node, read its details, then start the battle or resolve the non-battle node. Victories complete nodes, claim node rewards once, save progress, and unlock connected nodes. Defeats can be retried or returned to the campaign map.

The first skeleton campaign has six nodes:

- Border Village.
- Old Stone Road.
- Aether Well Ruins.
- Bandit Hillfort.
- Chapel of the Marches.
- Ashen Outpost.

Skirmish mode remains separate through the `Skirmish` button.

## Controls

- Left click: select a friendly unit or building.
- Drag with left mouse: box-select friendly units.
- Right click ground: move selected units.
- Right click enemy: attack selected enemy.
- `Shift+A`, then right click: attack-move selected units.
- `H`: select hero.
- `1`, `2`, `3`: use unlocked hero abilities.
- `Space`: center camera on hero.
- Click minimap: center camera on that map location.
- `Esc`: clear selection or cancel building placement.
- `WASD` or arrow keys: pan camera.

## Current Features

- Main menu, hero creation, campaign map, skirmish setup, reset save, credits/info.
- Six-node campaign skeleton with locked, available, and completed node states.
- Hero inventory screen from the main menu.
- Asset gallery for checking manual/final/placeholder art.
- Three hero classes: Warlord, Arcanist, Shepherd.
- Three origins with small stat modifiers.
- Three skill trees: Combat, Magic, Leadership.
- Three data-defined abilities per class.
- Skill point allocation after level-up.
- Rarity-weighted item rewards after victory.
- Equipment slots: weapon, armor, trinket.
- Two playable skirmish maps: First Claim and Broken Ford.
- Player base, enemy base, neutral camps, and capturable resource sites.
- Four resources: Crowns, Stone, Iron, Aether.
- Building placement for Barracks, Mystic Lodge, and Watchtower with valid/invalid previews.
- Automatic construction with under-construction visuals and disabled production until complete.
- Unit training queues from Barracks and Mystic Lodge, with visible progress and cancel/refund.
- Data-driven tech prerequisites and basic upgrades.
- Live RTS minimap with units, buildings, capture sites, camera viewport, click-to-pan, and alert pings.
- Simple RTS selection, movement, combat, projectiles, XP, level-up, and ability use.
- Simple enemy AI that expands, trains, and sends attack waves.
- Victory progression screen, defeat results screen, and local hero save.
- Pure `BattleRuntime` tests for setup, objectives, battle results, rewards, and save-output decisions.
- `BattleLaunchRequest` contract so skirmish, campaign nodes, and future scenario missions can all start battles through one clean pathway.
- Clean procedural UI skin for menus, result panels, HUD panels, and info boxes.
- Optional dedicated UI-kit assets for panel frames, button states, resource frames, dividers, tooltip frames, minimap frame, ability slot frame, inventory slot frame, victory panel, and defeat panel.

## Known Limitations

- Gameplay units and buildings use dedicated battle sprites when available, then fall back to concept art or simple Phaser shapes if art is missing.
- Movement uses direct steering with light separation, not full A* pathfinding yet.
- Fog of war, workers, retinue persistence, shops, and diplomacy are postponed. The minimap is snapshot-driven so fog can mask markers later without changing HUD controls.
- Campaign is a skeleton only: no diplomacy, shops, random events, invasions, or world simulation yet.
- Skill choices do not support respec yet.
- AI is intentionally simple and predictable.
- Balance is prototype-only and expected to change often.
- Some engine classes still combine simulation data with Phaser visuals. That is acceptable for this slice, but should be split before multiplayer or replay work.
- `BattleScene` still owns Phaser spawning, rendering, input, and system wiring. `BattleRuntime` now owns the first pure battle state/results boundary, but live entity state is not fully serializable yet.
- The UI-kit assets are optional and currently missing until generated manually. The game falls back to CSS styling when they are not present.

## How To Ask Codex For The Next Feature

Good next prompts are specific and small. Examples:

- "Add worker builders on top of the automatic construction system."
- "Add a respec button to the hero progression screen."
- "Add rarity-weighted item rewards after victory."
- "Create a second skirmish map and explain how I can tune it."
- "Improve enemy AI wave timing and document the knobs in BALANCE.md."
- "Split entity simulation state from Phaser view objects without changing gameplay."
- "Generate the 12 UI-kit images from the prompt book, then ask Codex to verify the HUD and tune the frame slices."

## Troubleshooting

- If `npm install` fails, check that Node.js is installed and restart the terminal.
- If the browser page is blank, run `npm run build` and look for TypeScript errors.
- If the game feels stuck after edits, stop the dev server with `Ctrl+C`, run `npm install`, and start it again.
- If `Continue Campaign` is disabled, start a new campaign first.
- If `Hero Inventory` is disabled, create a hero first.
