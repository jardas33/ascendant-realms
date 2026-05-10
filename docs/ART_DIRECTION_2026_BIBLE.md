# Ascendant Realms 2026 Art Direction Bible

Date: 2026-05-10  
Status: future visual target document. This is not an implementation plan for v0.8 graphics work.

## Purpose

This bible defines the future visual promise for Ascendant Realms while keeping the current browser prototype mechanics-first. It is meant to guide future art, UI, asset-pipeline, and technical decisions without triggering a desktop port, engine switch, 3D rewrite, paid asset dependency, external generated asset drop, or full graphics overhaul.

## Visual Promise

Ascendant Realms should become an original dark heroic fantasy RTS/RPG with a readable battlefield, commanding heroes, grounded settlements, memorable rivals, and tactical pressure that can be understood at a glance.

The long-term dream is a desktop-quality 2026 RTS/RPG, but the browser prototype remains a systems laboratory. Future visuals should elevate the same game, not distract from unfinished mechanics.

Core promise:

- Original dark heroic fantasy, not a clone of any existing franchise.
- Readable RTS battlefield first, atmosphere second, detail third.
- Hero RPG identity visible in silhouette, gear, powers, and UI.
- Tactical scale that lets the player understand units, buildings, routes, capture sites, and threats quickly.
- Production values that feel modern, tactile, and coherent when the project eventually leaves prototype visuals behind.

## Visual Pillars

### 1. Silhouette Clarity

Every unit type, hero, enemy commander, building, capture site, and important objective should be identifiable from silhouette before labels are needed.

Targets:

- Hero reads larger and more authored than common units.
- Infantry, ranged units, brutes, casters, and monsters have distinct pose and weapon language.
- Buildings are identifiable by roofline, footprint, function, and activity.
- Capture sites read as landmarks first and UI markers second.

### 2. Readable Tactical Scale

The game should feel like a battlefield, not a board of unrelated icons.

Targets:

- Infantry scale, building scale, capture-site scale, road width, projectile size, and UI overlays should come from one scale standard.
- Unit footprints and visible bodies should agree enough that selection and targeting feel honest.
- Camera distance should support quick group decisions without turning units into unreadable thumbnails.

### 3. Grounded Terrain

Terrain should imply physical material and history.

Targets:

- Roads show wear, material, edge breakup, and direction.
- Marsh, grass, ash, stone, ruins, and water have distinct material logic.
- Boundaries explain themselves through cliffs, dense reeds, flooded land, ruins, smoke, or other believable blockers.
- Terrain supports path readability without looking like debug strokes.

### 4. Distinctive Original Factions

Faction identity must be original and legally safe.

Targets:

- Free Marches should feel like frontier oath-bound settlements, field repairs, banners, practical armor, and stubborn local defense.
- Ashen Covenant should feel like ember-lit zeal, blackened relics, hard silhouettes, ritual marks, and disciplined road pressure without copying any protected faction.
- Wilds should feel territorial, old, and environmental rather than a generic monster list.

### 5. Modern Lighting And VFX Later

Lighting and VFX should eventually make spells, pressure, shrine surges, capture state, hero abilities, and enemy commanders feel alive.

Targets:

- VFX should clarify decisions, not obscure combat.
- Capture and pressure effects should be readable even in dense battles.
- Lighting should reinforce map identity and faction ownership.

### 6. Tactile UI

The UI should feel like a command interface for a fantasy battlefield, not a generic overlay.

Targets:

- Clean hierarchy, legible typography, responsive layout, and predictable controls.
- Old metal, parchment, glass, ash, or carved materials can inspire surfaces, but the final system must be cleaner and more scalable than prototype panels.
- Command buttons, resource display, objective tracking, minimap, results, inventory, and progression screens should share one style language.

## What To Avoid

Avoid:

- Copying Warcraft names, factions, units, building silhouettes, UI frames, terrain art, icon language, music, lore, color compositions, or map language.
- Copying Warlords Battlecry names, factions, units, UI, terrain, lore, campaign structure, art, music, or other protected expression.
- Copying any protected names, factions, places, stories, art, maps, music, voice, UI, unit designs, or lore from any source.
- Generic AI fantasy soup with no stable design rules.
- Overly detailed units that cannot be read at gameplay camera distance.
- Mismatched painterly terrain with cutout sprites.
- Inconsistent sprite scale.
- UI that hides the playfield.
- Full-screen effects that make RTS decisions harder.
- Dark palettes with no tactical contrast.
- Purple/blue fantasy gradients as a default identity.
- Beige parchment overload as a default identity.

## Unit Style Targets

### Hero

Hero visuals should show class, origin, and progression without relying only on labels.

Targets:

- Larger authored silhouette than common infantry.
- Distinct weapon, stance, cloak/banner/relic, or spell focus by class.
- Readable selection and ability VFX.
- Future gear progression should alter the hero enough to feel RPG-like while preserving class silhouette.

### Infantry

Common infantry should be the baseline human scale.

Targets:

- Clear shield/spear/sword or other role-defining shape.
- Practical frontier armor and cloth, not ornate clutter.
- Strong walk/attack readability.

### Ranged

Ranged units should read through weapon and spacing.

Targets:

- Bow, crossbow, javelin, or magical focus clearly visible at camera scale.
- Lighter armor and clearer back-line silhouette.
- Projectiles visible but not noisy.

### Brute

Brutes should read as pressure units, not just bigger infantry.

Targets:

- Broader stance, heavy shoulders, large weapon or shield.
- Slightly slower animation with impact.
- Larger than infantry, smaller than buildings.

### Caster

Casters should be fragile but visually distinct.

Targets:

- Vertical staff, ritual gesture, lantern, book, or relic silhouette.
- Low armor and high VFX clarity.
- Team/faction palette kept readable under effects.

### Monster

Monsters should feel tied to terrain and local myth.

Targets:

- Wild hounds, stone imps, and future creatures should look like they belong in the map biome.
- Avoid generic fantasy creature clutter.
- Threat tier should be clear from silhouette and animation.

## Building Style Targets

### Command Hall

The Command Hall should anchor the player base.

Targets:

- Large readable structure with frontier authority.
- Banners, work lights, stored supplies, and visible repair/construction logic.
- Grounded foundation and entry path.

### Barracks

Barracks should communicate infantry production.

Targets:

- Training yard, weapon racks, practice dummies, open gate, or banner cues.
- Clear footprint and rally relationship.
- Construction state readable.

### Shrine Or Capture Site

Capture sites should be landmarks with gameplay affordance.

Targets:

- Cinder Shrine: ember-lit relic stone, ash-glass base, ritual scorch marks, readable capture boundary.
- Resource sites: visual link to crowns, stone, iron, or aether without relying only on UI icons.
- Capture state should be obvious through color/VFX, not a huge ring alone.

### Enemy Stronghold

Enemy strongholds should embody commander intent.

Targets:

- Hard silhouettes, blackened material, ember light, pressure banners, guarded approach.
- Distinct from player architecture.
- Readable as the win target.

## Terrain Style Targets

### Roads

Roads should be tactically obvious and materially grounded.

Targets:

- Packed dirt, blackened causeway, broken stone, plank roads, ash tracks, or similar authored material.
- Strong edges where gameplay demands clarity.
- Worn margins, footprints, wheel ruts, and props where performance allows.

### Grass

Grass should be a calm baseline, not a flat filler.

Targets:

- Subtle value variation.
- Pathing clarity.
- Low clutter under combat zones.

### Marsh And Cinderfen

Cinderfen should be wet, ashen, dangerous, and original.

Targets:

- Ash-glass wetlands.
- Blackened causeways.
- Ember-lit shrine sites.
- Wet reflective pools.
- Dead reeds.
- Cinder fog.
- Ruined markers that guide routes without looking like icons.

### Ruins

Ruins should imply history and tactical blockers.

Targets:

- Broken foundations, fallen stones, collapsed watch markers, old roads.
- Clear passable vs blocked silhouette.

### Water

Water should read as depth, hazard, or swamp.

Targets:

- Edge breakup.
- Reflections and muted movement.
- Avoid simple blue ponds unless the biome calls for it.

### Fog And Shadow

Fog should support mood and information hiding.

Targets:

- Readable explored/unseen states.
- Cinderfen ash haze, smoke, and wet mist later.
- No confusion around ownership or selectable units.

## UI Style Targets

The current old-metal/fantasy frame can remain as prototype inspiration, but the future UI should be cleaner, more consistent, scalable, and easier to scan.

Targets:

- Resource bar: compact, icon-led, high contrast.
- Objective panel: clear priority, collapsible density later if needed.
- Selection panel: unit identity, stats, commands, rank, and status in predictable zones.
- Minimap: strong marker hierarchy, fog clarity, camera rectangle readability.
- Results: satisfying progression, rewards, veterans, rivals, and pressure telemetry without crowding.
- Inventory/progression: RPG clarity with strong compare/equip affordances.
- Buttons: stable states, tooltips, readable disabled reasons.

## Future Desktop Visual Standard

### 2.5D Option

Value:

- Keeps RTS readability.
- Can use high-quality authored sprites, lighting layers, normal maps, and VFX.
- Lower risk than full 3D.

Risk:

- Animation and directional consistency are expensive.
- Camera flexibility remains limited.

### 3D Option

Value:

- Modern lighting, animation, camera, VFX, and unit/building scale can become more coherent.
- Easier long-term asset reuse across views.

Risk:

- Engine and tooling demands are much higher.
- Requires real art production discipline.
- Would be inappropriate before browser prototype systems are fun and stable.

### Lighting

Future lighting should reinforce readable ownership, time, pressure, and magic without hiding units.

### Animation

Animation must clarify intent:

- Idle.
- Move.
- Attack.
- Cast.
- Capture.
- Build/construct.
- Die.
- Rally.
- Pressure or commander response.

### VFX

VFX should be short, readable, and role-specific:

- Hero ability VFX.
- Shrine surge.
- Capture progress.
- Enemy pressure warnings.
- Tower shots.
- Ranged projectiles.
- Unit veterancy or retinue identity.

### Camera

The future camera should preserve RTS command readability. Cinematic camera options should never make normal commands harder.

## Asset Pipeline Implications

The art direction requires:

- A scale sheet before new units/buildings.
- Source-file tracking and license tracking.
- Placeholder vs production asset tags.
- Naming conventions for units, buildings, terrain, VFX, UI, and portraits.
- Atlas/spritesheet rules for browser prototypes.
- Future import conventions for desktop assets.
- Screenshot gates for default camera, selected units, selected buildings, capture sites, minimap, and HUD.

## What Remains Prototype-Only

The following are acceptable as prototype-only:

- Procedural road strokes.
- Blob water/swamp zones.
- Large symbolic capture rings.
- Always-visible unit/building labels.
- Generic minimap marker shapes.
- Mixed manual/final placeholder asset styles.
- Current old-metal UI surfaces.
- Current Vite Phaser vendor warning.

These should not be mistaken for the final visual target.

## Implementation Guardrails

Future visual work must not:

- Add external generated assets without explicit permission.
- Commit large binary art packs without explicit permission.
- Require paid APIs.
- Copy protected art, maps, names, units, factions, lore, music, UI, or other expression.
- Implement desktop packaging before the browser prototype proves the game.
- Switch engines as a side effect of art planning.
- Rewrite BattleScene broadly for a visual experiment.
- Break existing save compatibility, content validation, tests, campaign progression, tutorial/skirmish separation, or pressure guardrails.

## First Recommended Future Visual Sprint

When a real visual sprint is approved, start with documentation and a controlled style frame:

1. Unit scale sheet.
2. Terrain style frame.
3. Cinderfen map visual mock.
4. UI style frame.
5. Screenshot comparison gate.

Do not begin with a full game art overhaul.
