# Desktop 2026 Visual Direction

Last updated: 2026-05-08

## Status

Planning only.

This document does not authorize a desktop port, engine switch, 3D rewrite, new assets, external generated assets, paid APIs, packaging scripts, new maps, new units, new factions, rewards, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, or broad systems.

## Long-Term Goal

Ascendant Realms can eventually become a real desktop-quality RTS/RPG with modern 2026 production values:

- A readable real-time battlefield with hero-led armies.
- A persistent RPG hero and campaign consequence layer.
- Original fantasy factions, places, units, characters, UI language, music direction, and lore.
- Strong tutorial/onboarding, save compatibility, deterministic testing, content validation, and release gates before broad expansion.

The long-term inspiration is broad genre spirit only: fantasy RTS/RPG hybridity, hero progression, bases, armies, campaign consequence, and tactical pacing. The project must not copy protected expression from Warlords Battlecry, Warcraft, or any other game.

## What The Browser Prototype Must Prove First

Before desktop or premium visuals matter, the browser prototype must prove that the game is worth enlarging.

Required proof:

- Fun core loop: select hero, capture resources, build, train, rally, use abilities, survive pressure, and win/lose clearly.
- Campaign structure: nodes, choices, rewards, route-complete states, chapter boundaries, and safe future expansion.
- Hero progression: level, XP, skills, equipment, affixes, duplicate prevention, and save migration safety.
- Army control: selection clarity, unit veterancy, retinue identity, rally behavior, command stability, and readable battle HUD.
- Base building: existing Command Hall/Barracks/Mystic Lodge/Watchtower loops remain understandable before workers or enemy construction.
- Persistence: save fixtures, migration tests, settings-only handling, campaign state, retinue, rivals, trophies, Cinderfen progress, and future compatibility rules.
- Tutorial/onboarding: Tutorial / Proving Grounds must teach the current loop without rewards, save pollution, new content, or broad systems.
- Performance and testing foundation: build, content validation, smoke/release/layout e2e, sharding, simulator determinism, command-log V1 test-only helper, and production preview smoke remain reliable.

If the browser loop is not fun and stable, a desktop shell or visual upgrade will only make problems more expensive.

## Possible Future Routes

### Keep Phaser And Wrap Later

Potential path:

- Continue proving the RTS/RPG loop in Phaser.
- Improve asset pipeline, content validation, and browser performance.
- Later evaluate desktop wrapping only after gameplay and UX are compelling.

Possible wrappers:

- Tauri.
- Electron.
- Platform-specific webview packaging.

Why it may work:

- Lowest short-term disruption.
- Keeps current tests, scenes, TypeScript, and content data useful.
- Supports fast iteration.

Risks:

- Desktop expectations for performance, windowing, input, file IO, modding, accessibility, and graphics may outgrow the browser stack.
- WebGL/DOM overlay architecture can limit premium battlefield presentation.
- Packaging can become a maintenance burden if attempted too early.

### Migrate To A Different Engine Later

Potential path:

- Preserve gameplay/data lessons in TypeScript/docs/tests.
- Create a separate engine spike later, after the browser prototype proves the loop.
- Port only a tiny vertical slice first.

Candidate engine categories:

- 2D/2.5D engine with strong tooling.
- 3D engine with good RTS camera, terrain, VFX, and UI integration.
- Custom rendering layer only if the team size and risk budget justify it.

Risks:

- Migration can stall the project if attempted before design is stable.
- Systems must be revalidated: save compatibility, campaign data, UI, tests, simulator, and content validation.

### Full 3D Or 2.5D Rewrite Later

Potential path:

- Build a separate desktop prototype spike after the browser game has a sticky tutorial, satisfying first-hour loop, stable campaign shell, and proven faction/economy direction.
- Target one tiny battlefield, one hero, one base chain, one enemy pressure pattern, and no campaign persistence first.

Risks:

- Visual ambition can outrun gameplay.
- Asset production can dominate engineering.
- Camera/readability can regress if 3D spectacle reduces tactical clarity.

## Visual Pillars

1. Readable battlefield:
   - Units, buildings, capture sites, hero, enemies, projectiles, selection, rally markers, and danger states must read instantly.
   - Readability beats decoration.

2. Modern lighting and materials:
   - Use lighting, terrain blending, weather, VFX, and material detail to create atmosphere without hiding tactics.
   - Avoid effects that obscure silhouettes, target priority, or build placement.

3. Expressive heroes:
   - Heroes should have strong silhouettes, animation readability, clear ability tells, and meaningful progression feedback.
   - Hero identity must be original to Ascendant Realms.

4. Distinct original factions:
   - Factions need original names, visual motifs, economy rhythms, UI colors, sound palettes, and tactical weaknesses.
   - Existing anchors such as Free Marches, Ashen Covenant, and Cinderfen can evolve, but must stay original.

5. High-clarity UI:
   - Desktop-quality UI should be dense, stable, readable, and fast.
   - HUDs must protect the playfield and avoid decorative clutter.

6. Scalable VFX:
   - VFX should scale by settings, remain colorblind-readable, and expose gameplay state rather than just spectacle.

7. Cohesive world tone:
   - Frontier defense, ash-glass wetlands, oathbound enemies, ruined shrines, and civic logistics can become original visual anchors.
   - Do not lean on inherited genre shorthand when original symbols can do the work.

## Original IP Guardrails

Do not copy:

- Faction names.
- Unit names.
- Hero names.
- Building names.
- Spell names.
- Lore beats.
- Campaign structures.
- Map layouts.
- UI layout or iconography.
- Art direction.
- Music, sound, voice, or interface cues.
- Specific mechanics expression, tooltips, or progression framing.

Allowed:

- Broad genre concepts such as hero-led armies, base construction, resource sites, campaign nodes, abilities, fantasy factions, and RPG progression.
- Original implementations, terminology, visual identity, and rules created for Ascendant Realms.

Every future faction, map, hero, and ability should pass an originality review before implementation.

## Future Asset Pipeline

A serious desktop-quality visual direction will need a real asset pipeline before production content begins.

Future pipeline needs:

- Concept art:
  - Original faction silhouettes.
  - Hero shape language.
  - Battlefield mood boards.
  - UI style frames.

- Models and animation:
  - Hero rigs and readable ability animations.
  - Unit movement, attack, hit, death, build, and idle cycles.
  - Building construction and damage states.

- VFX:
  - Ability telegraphs.
  - Capture-site state.
  - Rally markers.
  - Damage/healing/status feedback.
  - Fog and scout readability.

- Terrain:
  - Modular battlefield kits.
  - Pathability markers.
  - Resource and capture-site readability.
  - Biome identity without hidden obstacles.

- UI:
  - Icon set.
  - Command panels.
  - Inventory/progression surfaces.
  - Campaign map panels.
  - Accessibility/responsive scale rules.

- Audio:
  - Original music direction.
  - Faction interface cues.
  - Ability and combat feedback.
  - Ambient biome sound.

- Build and validation:
  - Asset manifest validation.
  - File-size budget.
  - Compression policy.
  - License/source tracking.
  - Preview-smoke validation for packaged builds.

Do not begin asset-heavy production until gameplay direction, originality guardrails, and validation rules are stable.

## What Not To Do Now

Do not do any of this in the current browser prototype checkpoint:

- No desktop port.
- No Tauri/Electron integration.
- No engine switch.
- No 3D rewrite.
- No asset-production dependency.
- No external generated assets.
- No paid API dependency.
- No new maps, units, factions, rewards, workers, enemy construction, crafting, diplomacy, procedural generation, multiplayer, or broad systems.
- No save-version change.
- No campaign progression change.
- No Cinderfen balance change.

Current work should continue strengthening the browser prototype and its safety gates.

## Recommended Future Milestone

After the browser gameplay is genuinely fun, stable, and well-tested, create a separate desktop prototype spike.

Suggested entry criteria:

- Tutorial / Proving Grounds passes human play review.
- First-hour campaign loop is fun without test hooks.
- Save/content validation remains green.
- Command-log V1 remains test-only and useful.
- Performance and e2e lanes remain manageable.
- At least one future faction/economy direction is specified but not bloated.
- Original IP style guide exists.

Suggested desktop spike:

- One tiny battlefield.
- One original hero.
- One existing base chain equivalent.
- One capture site.
- One small enemy pressure group.
- No campaign persistence.
- No rewards.
- No broad systems.
- No production migration promise.

The spike's purpose should be to answer: can Ascendant Realms achieve stronger battlefield readability, controls, and visual identity in a desktop-quality environment without losing the proven browser prototype lessons?
