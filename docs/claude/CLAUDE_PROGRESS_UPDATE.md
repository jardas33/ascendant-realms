# Ascendant Realms: Claude progress update

Last updated: 2026-09-27, 07:45 UTC. Claude updates this file after every pass.

## Where the work is

- **Game:** Godot 4.6.3 project at `production/ascendant-realms-godot`.
- **Branch:** `claude/perf-placeholders-r1`, in the clone at `D:\ClaudeWork\ar-lane`.
  - It is based on Codex's `codex/current-godot-baseline-next` (ebef47ae).
  - It merges Codex's ornate HUD branch (b6bcbe25).
  - About 140 commits.
- **Status:** not pushed and not merged. Emanuel pushes it with:
  `cd D:\ClaudeWork\ar-lane; git push https://github.com/jardas33/ascendant-realms.git claude/perf-placeholders-r1`
- **Codex work included:** the branch merges Codex's newest committed work: the UI convergence branch (ad35fe9f: War Chest armory, HUD icon atlases, skill constellation, top metrics, production/research legibility, hero ability art, living Groveheart HQ) and the Clan Levy character branch (f5283cd9). All tests pass on the combined build.
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

- **AI playtest fixes (plan item 1):** 20-minute AI-vs-AI soaks on Hollowspan and Autumn Reach found and fixed:
  - the new timber, food and gold models had wide collision that walled workers out of the gather ring (a regression from the model pass), so the AI economy starved;
  - builders could freeze beside their sites when the route solver returned a path that ended short; units now re-plan once a second in that case;
  - the AI placed buildings behind its base where the settlement dressing could wall them off; it now builds on the side facing the battlefield, keeps at most two sites open and cancels (with a refund) any site nobody could start within 90 seconds;
  - AI squads sent to capture points attack-moved into the solid landmark and stayed stuck forever; they now stand inside the capture ring.
  After the fixes the enemy AI builds armies of 25 to 50 and destroys the opponent.

- **Fog of war:** it is now drawn from a GPU texture instead of rebuilding an 18,000-vertex mesh every 0.2 s. Speed at 4x game speed went from 6 FPS to the vsync cap.
- **Mid-match stalls:** building collision is cached, and every unit, building, effect and projectile is warmed up while the match loads. The worst frame in a 10-minute run at 4x went from 300 ms to about 33 ms.
- **Enemy AI deadlock:** the AI economy could stall. It now rebalances gatherers, rescues stuck gatherers and finishes abandoned construction. On Normal and above it builds an army and attacks.
- **Large battles:** unit and building lists are snapshotted once per physics frame. Chase re-planning is throttled, and path solving has a per-frame budget. Big-battle physics time went from 19 ms to 9 ms, and 4x battle stalls dropped from 150–260 ms to under 100 ms.
- **Edge scrolling:** it only happens while the game window is focused and the cursor is inside it.
- **Static batching (plan item 3):** the hamlet, holdfast, grove and base dressing are merged into one mesh per material at match start (scripts/world/static_batcher.gd). The hamlet went from 191 draw surfaces to 22 and the holdfast from 55 to 19; total draw calls in the opening view fell from about 3,240 to about 2,690 with no visible change. The remaining cost is mostly the multi-part building models.
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
  - A scorched Vorthak holdfast with charred walls, ash-glass shards and violet braziers, on cracked basalt ground with glowing ember seams.
  - A living Lioraen grove with a bloom meadow, moonstones, glowing blooms and floating motes.
  - Every map dresses each faction's start this way.
- **Blender-made props** (scripts in `tools/blender/`):
  - a dry-stone wall
  - a granite quarry (the stone resource)
  - cairns and heather
  - Vorthak and Lioraen dressing
  - a grain harvest (the food resource, which used to reuse the timber pile)
  - a stacked log pile with ringed end grain, a chopping stump and an axe (the timber resource, which used to be a flat orange block)
  - a rock outcrop split by glowing gold veins, with an ore pile and a pickaxe (the gold resource)
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
- **Damaged buildings:** smoke rises from a building below 70% health, and flames break out below 40%. Both disappear when it is repaired.
- **Collapse dust and grain (plan item 9):** the collapse dust cloud is twice as dense and larger so it reads at normal zoom, and the food site grain is a richer gold.
- **Destroyed buildings:** they list to one side and sink into a dust cloud with thrown debris and a short camera shake, leaving a rubble heap and scorched ground for the rest of the match. Before, they just shrank into the ground.
- **Hero battle levels:** heroes now level up during a match from kills made within 18 m of them (soldiers 12 XP, workers 6, enemy heroes 60), up to level 5 at 60/150/280/450 XP. Each level adds 10% health, heals a quarter, adds 8% damage, bursts with golden light and fires the "Hero reached level N" alert, which existed but never fired before.
- **Veterans:** when a unit is promoted after three kills, a golden flare marks it and your promotions get an alert. Before, promotion had no visible sign at all.
- **New recruits:** a freshly trained unit arrives in a burst of team-coloured light with a small ring.
- **Banners:** every building flies a waving banner in its owner's colour.
- **Orders:** a soft ring shrinks onto the clicked spot. Attack orders also show inward chevrons.

## Sound

- **Battle ambience:** matches used to have music and no ambience at all; the highland wind recording in the project was never played. Now every map has gusting wind, green maps add birdsong phrases, volcanic maps add fire crackle, and highland and verdant maps also play the wind recording. The sounds are synthesised once at match start (no downloads, about 70 ms) and sit on the Sound Effects slider.
- **Combat feel (plan item 4):** checked: hits, flinches and impact sounds already line up, and the two combat-audio timing tests cover it. No change needed.

## Interface

- **Rally points:** a selected building shows its rally point as a small banner in the owner's colour, with a dashed trail flowing to it from the building.
- **Alert pings:** alerts with a location (base under attack, building lost, point captured) flash a ring on the minimap, red for threats and gold otherwise. Backspace jumps the camera to the latest alert, and the key is listed in the pause menu and the Settings field manual.
- **Settings:** a new Graphics Quality option. Low turns off shadows, ambient occlusion, grass and weather and cuts draw calls from about 2,800 to about 1,000. Medium halves the grass and shortens shadows. High is the full look. A new Reduce Screen Shake toggle controls the camera shake; that setting existed but had no switch.
- **Tutorial:** the step panel covered the Population, Opponents and idle counters that the steps refer to, and long steps spilled their goal line out below the panel. The panel now sits under the top bar, grows to fit, and shows the goal as a separate gold line. The attack step wrongly said A for attack-move; it now says J.
- **Loading screen:** a gilded progress bar and a random tip on every load, covering controls, capture points, veterans, repair and scouting.
- **Main menu:** the painted background drifts slowly, gold motes rise across the realm, a vignette frames it, the title and buttons fade in, and buttons lift on hover.
- **Minimap:** it shows a real top-down picture of the battlefield, taken at match start with units and fog left out. Unexplored areas are shaded lighter so the terrain still reads.
- **Skirmish setup:** rebuilt as a war-council screen, with faction banner cards, a dossier and a tactical map preview.
- **Other screens:** the hero forge preview, skill tree, War Chest and campaign map are reskinned to match.
- **Victory and defeat:** a result ledger on the ornate plate.
- **Campaign map:** the briefing now opens on your next battle with a "Click to march" hint (it used to show whichever region the cursor last crossed), the next battle gently pulses, and sealed regions recede so the path forward stands out.
- **Buttons:** every button uses a forged-bronze frame. The pause menu sits on the ornate plate, and its control list is easier to read.

## Top-10 plan (started 2026-09-27)

1. DONE. Full AI-vs-AI playtests on several maps and difficulties to catch gameplay bugs: stuck units, AI stalls, matches that never end.
2. DONE. Hero progression in battle: the level-up alert exists but nothing ever fires it; wire in-match hero XP and level-ups.
3. DONE. Rendering cost: cut the ~2,800 draw calls in the opening by merging static base dressing.
4. CHECKED. Combat feel audit: attack timing, hit reactions and impact sounds lining up.
5. DONE. Audio atmosphere: per-map ambience and missing sound cues, using only free or generated sound.
6. REVIEWED. Lioraen and Vorthak units: a free material and silhouette pass. The full model rebuild still needs the Hugging Face token run.
7. DONE. Tutorial and first-match onboarding review.
8. DONE (all working). Verify recent features in real play: Medium quality, Backspace jump, veteran flare.
9. DONE. Polish known weak spots: collapse dust at normal zoom and pale grain on the food site.
10. DONE. Campaign map screen polish with what is available now; the painted map still needs the token.

- **Lioraen and Vorthak units (plan item 6):** reviewed up close; they read clearly at play zoom with team colours and silhouettes. A worthwhile upgrade needs the model rebuild, which still waits on the Hugging Face token run.

## Second plan (started 2026-09-27)

1. DONE. Matches now reach a result. AI-vs-AI games ran 20 minutes with no winner. Three causes, all fixed:
   - **Food ran out for good around minute 8.** Each base had one 600-food node and every unit costs food. Food nodes now hold 1,200, and every finished house adds 2 food every 4 seconds. This applies to the player too.
   - **Soldiers reaching an enemy base stood idle beside buildings.** Idle AI soldiers near a hostile building now attack the nearest one.
   - **A lone construction site kept a beaten side alive**, because attackers ignored unbuilt sites. The AI now targets them too.
   - Attack waves also stop growing after the third, so the AI keeps attacking.
   A Hard Vorthak AI now wins a 20-minute soak at about minute 18.
2. DONE. A Vorthak player on Hollowspan now gets the scorched holdfast (Lioraen already had its grove). Noted for Codex: the Vorthak worker (Bondservant) selection portrait shows a T-posed model instead of portrait art.
3. Units pushing against obstacles near their own base.
4. DONE. Frame cost: a feature-by-feature GPU bisect showed the ground shader alone cost about 11 ms of GPU per frame at 1600x900, mostly the Vorthak/Lioraen zone noise and cracks being computed on every pixel of the map. Zones and the ford now skip that work outside their area, and the broad low-frequency fields use two noise octaves instead of four. GPU time for the whole frame dropped from about 16.7 ms to about 12 ms with no visible change.

## Still open

- **Characters:** the Lioraen and Vorthak workers and the military units still need the same character rebuild as the Barrosan worker. This needs Emanuel's Hugging Face token run.
- **Campaign map:** the painted campaign map script (`D:\ClaudeWork\charpipe\make_campaign_map.py`) is ready. It is waiting on the same token run.
- **Draw calls:** about 2,800 draw calls in the opening. Instancing the decor would be the next rendering win.
