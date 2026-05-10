# v0.9 Cinderfen Style-Frame Research Packet

Date: 2026-05-10  
Status: v0.9 research packet for future Cinderfen style frames. This document does not generate, import, download, replace, or approve art assets.

## Purpose

This packet defines the source-safe research posture for Cinderfen before any visual generation or runtime replacement work begins. It turns the v0.8 visual audits, v0.8.1 manifest work, and v0.8.2 source/license screenshot gate into a words-only direction brief for future style frames.

The goal is to describe what Cinderfen should become while keeping the current browser prototype untouched.

## Current Visual Problems

### Paint-Like Roads

Current Cinderfen roads are readable as tactical lanes, but they look like broad guide strokes rather than built terrain.

Problems:

- road edges do not imply stone, timber, ash mud, roadbed height, or wear,
- route branches are understandable but not memorable,
- roads do not yet show why they matter as pressure paths or causeways through dangerous ground.

Research implication: future Cinderfen roads should read first as blackened raised causeways, then as playable lanes.

### Blob-Like Water And Swamp

Current water and swamp zones are useful for map reading, but they are visually broad and shape-led.

Problems:

- pools feel like filled shapes instead of wet materials,
- edges do not blend through reeds, banks, ash mud, or broken stone,
- reflective wetland atmosphere is not yet present.

Research implication: future water needs shallow reflective surfaces, deep swamp contrast, and believable wet edges while staying readable at RTS camera distance.

### Unclear Material Identity

Cinderfen currently communicates "dark battlefield" more than a specific place.

Problems:

- ash mud, marsh ground, road, water, ruin, and blocked terrain do not have enough distinct material logic,
- unit and building sprites feel placed on top of the map rather than grounded in it,
- terrain detail density does not match future unit/building detail expectations.

Research implication: style frames should separate material roles before any texture or renderer work starts.

### Icon/Ring-Led Capture Sites

Cinder Shrine and Watch Road sites are tactically clear because of rings, labels, icons, and objective text.

Problems:

- the ring is more memorable than the captured object,
- the shrine depends too much on labels and the objective panel,
- ownership is readable, but place identity is weak.

Research implication: future capture sites need landmark silhouettes that remain recognizable without labels. Rings can remain as gameplay overlays.

### Unit/Building Scale Mismatch

The current browser prototype is playable, but unit, hero, enemy commander, building, capture-site, and terrain proportions are not yet governed by one production scale sheet.

Problems:

- current sprites are practical but not fully coherent,
- labels and bars carry too much unit identity,
- enemy buildings are functional but not visually distinctive enough.

Research implication: future style frames should define scale classes and negative space around assets before runtime replacement.

### Text-Heavy HUD Dependence

The HUD and objective panels keep the game understandable, especially for pressure warnings and tutorial steps, but they carry too much identity.

Problems:

- battlefield labels, objective text, and status messages do more visual work than future art should,
- mobile/tablet battle views are dense,
- final art should reduce dependence on text without harming current prototype clarity.

Research implication: terrain and landmarks must be readable even when UI labels are reduced later.

## Desired Cinderfen Identity

Cinderfen should feel like an ash-glass wetland: wet, hostile, old, and ember-lit, with routes that make tactical sense at a glance.

Core identity terms:

- ash-glass wetland,
- blackened raised causeways,
- ember-lit shrine sites,
- dead reeds and drowned ruins,
- wet reflective pools,
- blue-green fog and cinder haze,
- hostile but readable battlefield,
- old road markers half-swallowed by marsh,
- scorched stone and charred timber,
- ritual heat under cold wet air.

The mood should be dangerous and solemn, not generic dark fantasy sludge. It should support battle decisions before ornamental detail.

## Original IP Guardrails

Ascendant Realms must remain original.

Required guardrails:

- no Warcraft copy,
- no Warlords Battlecry copy,
- no copied factions, units, maps, UI, terrain, building silhouettes, icon language, art, lore, music, sound, or other protected expression,
- no direct copyrighted reference ingestion,
- no "in the style of" protected games, living artists, or identifiable franchise art directions,
- no renamed lookalikes,
- no protected symbols, logos, faction marks, or UI compositions,
- no imported reference images as assets.

Future style-frame prompts should describe function, mood, material, camera, scale, and gameplay readability. They should not name protected visual references as style targets.

## Allowed Concept Reference Categories

These categories are safe as broad real-world or public-domain concept language when used as descriptive inspiration, not as copied assets:

- volcanic wetlands,
- peat bogs,
- basalt causeways,
- ruined watch roads,
- medieval marsh fortifications,
- ember-lit ritual sites,
- foggy lowland battlefields,
- charred timber roadworks,
- old stone causeway edges,
- reed-choked water channels,
- wet ash and cinder fields,
- smoke-stained frontier outposts.

Allowed use:

- extract general material ideas,
- define mood and shape language,
- describe how passable routes should contrast with hazards,
- guide original prompt/spec wording.

Disallowed use:

- copying a specific photo, illustration, map, game scene, symbol, or building,
- tracing or using a copyrighted image as input,
- treating broad reference as source/license proof for an asset.

## Reference Categories To Avoid

Avoid:

- direct franchise lookalikes,
- orc, undead, human, demon, or holy-order visual cliches copied from major RTS games,
- generic AI dark fantasy sludge with no road/site readability,
- unreadable ultra-detail that hides units or routes,
- saturated one-color biomes that crush tactical contrast,
- giant symbols that make capture sites feel like UI stickers,
- enemy architecture that copies a known faction silhouette,
- UI or minimap treatments lifted from another game.

## Cinderfen Mood Board In Words

No images are part of this mood board.

Cinderfen at default camera distance:

- a dark marsh cut by raised black roads,
- wet ash reflecting a weak cold sky,
- shallow pools that catch pale blue-green fog,
- dead reeds combed flat by old war traffic,
- charred posts marking safe ground,
- broken basalt stones along road edges,
- occasional ember cracks under shrine stones,
- an old watch road held together by timber braces and iron pins,
- drowned ruin fragments near capture sites,
- enemy outposts glowing through slits and watch-fires,
- player units readable because the terrain is low-noise where commands happen,
- danger expressed through material and silhouette, not clutter.

Cinderfen should feel like a place where armies must stay on roads because the marsh itself is hungry.

## Gameplay Readability Constraints

### Roads Obvious

Roads must be the first read in Cinderfen battle screenshots.

Rules:

- main routes need clear value separation from marsh ground,
- route edges should communicate passable vs dangerous terrain,
- pressure-relevant roads need stronger route identity,
- road detail must not look like units, pickups, or capture-site markers.

### Capture Sites Visible

Capture sites must remain visible with or without labels.

Rules:

- landmark silhouette should read before icon text,
- capture boundary can remain as a gameplay overlay,
- ownership state should be readable without forcing a huge ring to carry all identity,
- shrine variants must preserve the same base silhouette.

### Units Readable

Units must stay above terrain noise.

Rules:

- terrain under combat zones should be lower-frequency than unit sprites,
- health bars and selection rings must remain legible,
- unit silhouettes should not disappear over road, swamp, fog, or ember light,
- future art should reduce but not remove readability aids too early.

### Enemy Approach Readable

The path toward hostile bases and pressure routes must be legible.

Rules:

- enemy base silhouettes should sit at the end of readable approach routes,
- watchtower or stronghold threat should be visually obvious,
- fog should frame uncertainty without hiding core path logic,
- road markers should not be confused with capture-site landmarks.

### Fog Atmospheric But Not Confusing

Fog should make Cinderfen feel wet and ashen, but it must not hide ownership or commands.

Rules:

- explored/unseen/visible states remain distinct,
- captured-site readability survives fog,
- pressure warnings remain readable,
- blue-green haze and cinder smoke stay subtle around unit clusters.

## What This Research Packet Does Not Do

This packet does not:

- generate art,
- call image APIs,
- import art,
- download images,
- add assets,
- move or replace runtime files,
- add manifest entries for nonexistent files,
- approve unknown-source assets,
- change renderer behavior,
- change CSS,
- change gameplay, maps, units, factions, rewards, save shape, campaign progression, pressure behavior, or tutorial behavior,
- choose a desktop engine,
- authorize a graphics overhaul.

## Next Packet Step

The next v0.9 step should define Cinderfen visual pillars and style rules so future terrain, shrine, architecture, scale, prompt, manifest, and screenshot acceptance docs all use the same language.
