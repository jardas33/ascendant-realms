# Ascendant Realms: Claude progress update

Last updated: 2026-09-26, 21:40 UTC. Claude updates this file after every pass.

## Where the work is

- **Game:** Godot 4.6.3 project at `production/ascendant-realms-godot`.
- **Branch:** `claude/perf-placeholders-r1`, in the clone at `D:\ClaudeWork\ar-lane`.
  - It is based on Codex's `codex/current-godot-baseline-next` (ebef47ae).
  - It merges Codex's ornate HUD branch (b6bcbe25).
  - About 140 commits.
- **Status:** not pushed and not merged. Emanuel pushes it with:
  `cd D:\ClaudeWork\ar-lane; git push https://github.com/jardas33/ascendant-realms.git claude/perf-placeholders-r1`
- **Handoff notes:** the commit-by-commit notes for Codex are in `docs/claude/CLAUDE_LANE_HANDOFF.md`.
- **Constraints kept throughout:**
  - Everything lives on disk D.
  - No paid tools.
  - Codex worktrees are never touched.
- **Tests:** the nine self-checking tests pass after every change:
  - economy
  - identity
  - combat
  - easy AI wave
  - conquest victory
  - navigation repair
  - combat-hit audio, in both modes
  - projectile-impact audio

## Performance and stability

- **Fog of war:** it is now drawn from a GPU texture instead of rebuilding an 18,000-vertex mesh every 0.2 s. Speed at 4x game speed went from 6 FPS to the vsync cap.
- **Mid-match stalls:** building collision is cached, and every unit, building, effect and projectile is warmed up while the match loads. The worst frame in a 10-minute run at 4x went from 300 ms to about 33 ms.
- **Enemy AI deadlock:** the AI economy could stall. It now rebalances gatherers, rescues stuck gatherers and finishes abandoned construction. On Normal and above it builds an army and attacks.
- **Large battles:** unit and building lists are snapshotted once per physics frame. Chase re-planning is throttled, and path solving has a per-frame budget. Big-battle physics time went from 19 ms to 9 ms, and 4x battle stalls dropped from 150–260 ms to under 100 ms.
- **Edge scrolling:** it only happens while the game window is focused and the cursor is inside it.
- **Error sweep:** these all ran with zero script errors:
  - a 10-minute match at 4x
  - the tutorial
  - the campaign opening
  - starts as all three factions

## World and terrain

- **Lighting:** there is a golden-hour grade on the highland maps and a battlefield grade on every other theme, including tropical.
- **Ground:**
  - Anti-tiling, broad painterly colour fields, rolling relief shading and soft cloud shadows drifting across it.
  - Fixed a real bug: the noise function lost precision on the GPU and drew hard 20–50 m squares across the ground and water.
- **Grass and wildflowers:**
  - About 20,000 instanced tufts that sway in travelling wind gusts. Colour and density follow the theme.
  - They stay off roads, water, start yards, bare dirt and rock.
  - They clear under buildings, resources and capture points, and get trampled where units die.
- **Trees:**
  - They sway in the wind, with a shaded understory, a sunlit crown and light coming through the leaves.
  - They are about a quarter smaller than before, so canopies no longer hide whole squads.
  - They are no longer rendered as shiny metal. The imported models had been metallic.
- **River:** there is a walkable ford under the bridge on the six bridge maps. The water has current streaks, a foam line at the banks and clearer shallows.
- **Weather per map:** pollen over meadows, falling leaves in autumn, snow, blowing sand, and embers and ash on volcanic maps.
- **Fog of war:** it looks like drifting mist with soft, moving edges and extends past the map border.
- **Faction starting bases:**
  - A lived-in Barrosan hamlet with houses, chimney smoke, lanterns, woodpiles and fences.
  - A scorched Vorthak holdfast with charred walls, ash-glass shards and violet braziers.
  - A living Lioraen grove with a bloom meadow, moonstones, glowing blooms and floating motes.
  - Every map dresses each faction's start this way.
- **Blender-made props** (scripts in `tools/blender/`):
  - a dry-stone wall
  - a granite quarry (the stone resource)
  - cairns and heather
  - Vorthak and Lioraen dressing
  - a grain harvest (the food resource, which used to reuse the timber pile)
- **Capture sites:**
  - Each has its own landmark: a ruined pillar-circle chapel, and a rocky lookout with a signal brazier. Before, they reused the Lume Spire and gold-mine models.
  - A rune circle marks the real capture area. While a team is capturing, an arc fills around it in that team's colour.
- **Base tracks and yards:** they fade softly into the grass instead of looking like hard, translucent strips.
- **Fixes:** stone walls were rendering nearly black, and a boundary marker was lying on its side. Both are fixed.

## Units, buildings and combat

- **Barrosan worker:** replaced with a sculpted, AI-generated character. The pipeline is free (FLUX, then Hunyuan3D, then a Blender rig fit) and lives in `tools/charpipe/`. Emanuel runs the Hugging Face step himself.
- **Unit materials:** the metallic sheen on unit materials is capped, so cloth and skin no longer look grey-teal.
- **Combat effects:** sparks, flash, dust, death clouds, new arrows and ember bolts, all pre-built so they cost nothing mid-fight.
- **Hero abilities:**
  - Soft shockwave rings.
  - Glowing motes on allies touched by Rally and Heal.
  - Dust, clods and a short camera shake for Slam. The existing reduce-shake setting turns the shake off.
- **Readability:**
  - Team-coloured combat rings.
  - Health bars that appear for 5 seconds after any hit.
  - Glowing selection rings with slowly turning brackets.
  - Team-coloured silhouettes for units hidden behind trees or buildings.
- **Battle marks:** fallen units leave churned, darkened ground that fades after about 25 seconds.
- **Construction:** a building rises behind a moving work line, with its walls and floors going up, instead of a see-through fade.
- **Placement preview:** it shows the real, textured building.
- **Banners:** every building flies a waving banner in its owner's colour.
- **Orders:** a soft ring shrinks onto the clicked spot. Attack orders also show inward chevrons.

## Interface

- **Minimap:** it shows a real top-down picture of the battlefield, taken at match start with units and fog left out.
- **Skirmish setup:** rebuilt as a war-council screen, with faction banner cards, a dossier and a tactical map preview.
- **Other screens:** the hero forge preview, skill tree, War Chest and campaign map are reskinned to match.
- **Victory and defeat:** a result ledger on the ornate plate.
- **Buttons:** every button uses a forged-bronze frame. The pause menu sits on the ornate plate, and its control list is easier to read.

## Still open

- **Characters:** the Lioraen and Vorthak workers and the military units still need the same character rebuild as the Barrosan worker. This needs Emanuel's Hugging Face token run.
- **Campaign map:** the painted campaign map script (`D:\ClaudeWork\charpipe\make_campaign_map.py`) is ready. It is waiting on the same token run.
- **Draw calls:** about 2,800 draw calls in the opening. Instancing the decor would be the next rendering win.
