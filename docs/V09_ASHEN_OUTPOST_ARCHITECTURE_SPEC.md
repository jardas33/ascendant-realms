# v0.9 Ashen Outpost Architecture Spec

Date: 2026-05-10  
Status: future architecture specification only. No art, runtime asset, map, building, faction, gameplay, renderer, or save change is included.

## Purpose

This document defines the future Ashen outpost and building visual identity for Cinderfen. It prepares a category sheet for later concept art or asset replacement work without generating, importing, wiring, or approving any image asset.

The current browser prototype remains unchanged. Existing enemy structures, labels, health bars, selection rings, tinting, attacks, victory conditions, and pathing stay as they are.

## Current Problem

Enemy buildings are functional but not visually distinctive enough.

Current facts:

- Enemy buildings are readable through location, team color, labels, health bars, and red-tinted runtime sprites.
- `enemy_stronghold` is the win-condition building with data size 104 x 88 and current max sprite height about 124.96 px.
- `enemy_barracks` is the enemy production building with data size 82 x 64 and current max sprite height about 90.88 px.
- Existing Cinderfen watch/tower pressure is readable in map/objective context, but the Ashen architecture family is not yet authored as one original set.
- Building scale is practical for the prototype but not grounded by authored foundations, road relationships, or a shared construction language.

Problems:

- enemy identity is carried too much by tint and labels,
- stronghold silhouette does not yet define a memorable original faction presence,
- production structure identity is functional rather than architectural,
- road markers and watch points are not visually systematized,
- structures can feel placed on terrain instead of embedded in the Cinderfen causeway/marsh world.

## Future Ashen Visual Identity

Ashen architecture should feel like disciplined road pressure, ember-lit zeal, and scorched occupation of a wetland battlefield.

Core identity:

- scorched timber,
- black iron braces,
- basalt stones,
- ember-lit slits,
- ritual banners and original sigil shapes,
- angular hostile silhouettes,
- hard rooflines and braced walls,
- wet ash foundations,
- causeway-facing watch geometry.

Emotional target:

- hostile but readable,
- ritualized but functional,
- militarized rather than chaotic,
- original dark heroic fantasy, not copied from an existing RTS/RPG faction.

## Required Building Categories

### Stronghold

Purpose: enemy base anchor and win-condition target.

Visual role:

- largest Ashen building silhouette,
- most fortified,
- strongest ground contact,
- clearest hostile identity,
- should read as the command target before the label is read.

Design direction:

- basalt lower mass,
- scorched timber upper construction,
- black iron straps and braces,
- ember-lit command slits,
- harsh roof or broken crown shape,
- small ritual banner treatment that is original and not a franchise symbol.

Avoid:

- copied fortress silhouettes,
- giant skull or spike shorthand,
- over-tall castle shape that implies a different footprint,
- details that hide health bars or selection rings.

### Barracks / War Camp

Purpose: enemy production structure.

Visual role:

- read as where raiders, hexers, and brutes gather or are trained,
- smaller than stronghold but more active than props,
- clearly distinct from player barracks.

Design direction:

- long low war-camp mass,
- charred beams,
- weapon racks or guarded entry shapes,
- ember slits or forge glow kept subtle,
- staging yard edge that does not imply new unit spawning behavior beyond current systems.

Avoid:

- looking like a stronghold,
- looking like a neutral camp,
- visual clutter that reads as extra units,
- production effects that imply workers, construction, or economy AI.

### Watchtower

Purpose: future enemy threat landmark for road control where the map/supporting systems already imply tower pressure.

Visual role:

- tall and narrow enough to read as a threat,
- smaller footprint than stronghold and barracks,
- strong vertical silhouette,
- should communicate "ranged danger" if used for an actual tower later.

Design direction:

- black timber frame,
- basalt footing,
- iron-bound lookout slot,
- restrained ember lantern or slit,
- causeway-facing orientation.

Avoid:

- over-wide shape that reads as production,
- huge flame or beacon that looks like a capture site,
- protected faction tower silhouettes,
- any implication of new tower mechanics unless the building already exists in data.

### Shrine / Ritual Support

Purpose: architectural support for Ashen ritual presence near strongholds, pressure routes, or future set dressing.

Visual role:

- supports Ashen identity without replacing the Cinder Shrine,
- should read as hostile support architecture, not a player objective by default,
- can echo ember cracks and black stone language.

Design direction:

- low ritual plinths,
- black iron cages or braces,
- original sigil stones,
- ember-lit cracks,
- wet ash base.

Avoid:

- looking like the Cinder Shrine capture site,
- looking like a resource node,
- giant symbols or UI-like objective markers,
- lore-specific protected motifs.

### Small Barricade / Road Marker

Purpose: future small prop or route marker for Ashen-controlled causeways and road pressure.

Visual role:

- gives roads an occupied, hostile feel,
- must remain below unit/building visual priority unless it is a real blocker,
- should not look capturable.

Design direction:

- charred stake groups,
- black iron road braces,
- broken basalt marker stones,
- small ember slit or hanging tag only when needed,
- wet mud contact and dead reed intrusion.

Avoid:

- capture-site circles,
- interactable resource shape,
- unit-sized silhouettes that look like enemies,
- props that imply new barricade mechanics if map data is unchanged.

## Gameplay Readability Requirements

- Stronghold must be obvious as the primary enemy base target.
- Barracks must read as production.
- Tower must read as threat, not decoration, if introduced later.
- Road marker must not look like a capture site.
- Shrine/ritual support must not compete with the Cinder Shrine landmark.
- Player structures must remain visually distinct from Ashen structures.
- Health bars, labels, selection rings, construction bars, and attack/projectile reads must remain clear.
- Enemy building art must preserve current perceived footprints unless a separate gameplay goal changes building data.
- Architecture should not imply enemy construction, worker economy, new spawned buildings, destructible blockers, or extra campaign rewards.
- Minimap building hierarchy should remain clear if any future building visual changes also affect marker language.

## Scale Rules

Current scale facts:

- enemy stronghold: data size 104 x 88, runtime radius 52, current max sprite height about 124.96 px,
- enemy barracks: data size 82 x 64, runtime radius 41, current max sprite height about 90.88 px,
- player watchtower: data size 48 x 72, current max sprite height about 102.24 px; there is no separate enemy tower asset in the current building data,
- common infantry render heights are roughly 43.8 to 47.45 px,
- brutes render around 58.4 px,
- player heroes render around 82.65 px.

Future scale direction:

- stronghold: visually dominant, broad footprint, about command-building tier,
- barracks/war camp: production-building tier, lower than stronghold, clear entrance/staging read,
- watchtower: tall, narrow, threat silhouette, smaller footprint than production,
- ritual support: below production building tier unless it is a gameplay structure,
- road marker/barricade: prop tier, below units and clearly below capture-site landmark priority.

Silhouette height:

- stronghold may exceed all units and small buildings,
- barracks should sit in the production-building band,
- tower may be tall but must stay visually narrow,
- props must not outrank units or capture-site landmarks.

Footprint clarity:

- future art must document intended visual bounds and current footprint relationship,
- foundations should explain ground contact without changing placement rules,
- overhangs must not make selectable/collidable bounds feel deceptive.

Label/bar compatibility:

- leave space above roofs for health bars,
- preserve label position readability,
- avoid bright roof details directly behind health bars,
- preserve selection ring visibility around building bases.

Future desktop scale:

- desktop-quality art can have richer depth, lighting, and foundation detail,
- footprint, threat hierarchy, and gameplay readability still outrank close-up ornament.

## Prompt Template - Architecture Sheet

```text
Create an original dark heroic fantasy RTS architecture sheet for Ashen outposts in Cinderfen. Show a coherent building family using scorched timber, black iron braces, basalt stones, wet ash foundations, ember-lit slits, angular hostile silhouettes, and original ritual banner shapes. Include stronghold, barracks/war camp, watchtower, ritual support, and small road marker categories. Designed for top-down or high 2.5D gameplay readability. Original IP only. Do not copy Warcraft, Warlords Battlecry, or any protected faction, building, UI, icon, terrain, map, symbol, logo, color scheme, or art style.
```

Output expectations:

- one coherent category sheet,
- scale relationships visible,
- no runtime asset extraction unless separately approved,
- labels may identify categories in the concept sheet only,
- no copied symbols or franchise silhouettes.

## Prompt Template - Stronghold Concept

```text
Design an original Ashen stronghold for a Cinderfen RTS battlefield: black basalt base, scorched timber upper mass, black iron braces, hard angular roofline, ember-lit command slits, wet ash foundation, and a hostile but readable silhouette from a high 2.5D camera. It is the largest enemy base target and must leave room for health bars, labels, and selection rings in the browser prototype. Original IP only; no Warcraft, no Warlords Battlecry, no copied fortress, faction, symbol, UI, terrain, or art style.
```

Output expectations:

- transparent background if delivered as a sprite candidate,
- visible foundation and footprint notes,
- no giant logo,
- no implied new mechanics.

## Prompt Template - Barracks Concept

```text
Design an original Ashen barracks or war camp building for a dark heroic fantasy RTS. It should read as enemy production from a high 2.5D camera: charred beams, guarded entry, weapon-rack shapes, black iron binding, basalt stones, restrained ember forge glow, and wet ash ground contact. Smaller than the stronghold, distinct from player buildings, compatible with labels and health bars. Original IP only; do not copy protected RTS factions, barracks silhouettes, symbols, UI, terrain, or art style.
```

Output expectations:

- clear production read,
- lower/longer mass than stronghold,
- no extra visible units that could be mistaken for gameplay entities,
- transparent background if intended as a candidate sprite.

## Prompt Template - Watchtower Concept

```text
Design an original Ashen watchtower concept for a Cinderfen causeway: tall narrow black timber and basalt tower, black iron braces, guarded sight slot, small ember lantern, wet ash footing, road-facing threat silhouette, readable from top-down or high 2.5D RTS camera. It must not copy any protected tower or faction design and must not look like a capture shrine. Original IP only; no Warcraft, no Warlords Battlecry, no copied symbols, no existing game architecture.
```

Output expectations:

- narrow vertical silhouette,
- threat read at small size,
- not a stronghold or capture-site shape,
- no mechanics implied beyond future approved tower use.

## Prompt Template - Small Prop Sheet

```text
Create an original small Ashen road prop sheet for Cinderfen: charred barricade fragments, black iron road braces, basalt marker stones, small ember slits, wet ash bases, dead reed contact, and non-interactable route dressing. Props must stay below unit/building priority and must not look like capture sites, resource nodes, enemies, or new blockers. Original IP only; no copied franchise props, symbols, terrain kit, UI, or art style.
```

Output expectations:

- small prop silhouettes,
- clear non-interactable read,
- no capture rings or objective markers,
- scale notes relative to units, shrine, and buildings.

## Manifest Requirements

Future Ashen architecture entries must include:

- `id`
- `filePath`
- `category: "building-concept"`, `"building-sprite"`, `"terrain"`, or `"reference"` as appropriate
- `displayName`
- `currentStatus`
- `sourceType`
- `licenseStatus`
- `reviewStatus`
- `usage`
- `usedBy`
- `visualFamily: "Ashen outpost"` or a more specific family
- `scaleClass`
- `intendedWorldHeightPx` where applicable
- `currentRenderHeightPx` for runtime candidates
- `silhouetteReadability`
- `styleConsistency`
- `replacementPriority`
- `notes`
- `sourceReviewNotes`
- `allowedInProduction`
- `needsReview`
- `screenshotQaTargets`

Recommended future ids:

- `ashen_outpost_architecture_sheet_reference`
- `ashen_stronghold_concept_reference`
- `ashen_stronghold_sprite_candidate`
- `ashen_barracks_concept_reference`
- `ashen_barracks_sprite_candidate`
- `ashen_watchtower_concept_reference`
- `ashen_ritual_support_concept_reference`
- `ashen_road_marker_prop_sheet_reference`

Policy:

- concept sheets are reference-only until implementation planning says otherwise,
- sprite candidates stay unused until runtime replacement is approved,
- source/license proof is required before production approval,
- no current unknown-source asset should be marked production-safe because of this spec.

## Screenshot QA Requirements

Future Ashen building work must be reviewed against:

- `cinderfen-watch-desktop.png`: enemy road/base approach readability.
- `cinderfen-watch-pressure-desktop.png`: pressure warning plus enemy threat context.
- `cinderfen-crossing-desktop.png`: Cinderfen battle baseline with routes and structures.
- `cinderfen-crossing-pressure-desktop.png`: pressure route and shrine relationship.
- `results-defeat-desktop.png`: defeat-tip context if perceived enemy threat changes.
- Future selected-building screenshots if runtime building replacement begins.

Review questions:

- Is the stronghold obvious as the primary target?
- Is the barracks obvious as production?
- Does tower art read as threat without implying unimplemented mechanics?
- Does any road marker look too much like a capture site?
- Do health bars, labels, and selection rings remain readable?
- Does the architecture sit on Cinderfen terrain rather than floating over it?
- Does the art avoid protected faction/building/symbol lookalikes?
- Is source/license metadata complete before commit?

## IP Guardrails

- Do not copy Warcraft or Warlords Battlecry buildings, factions, silhouettes, banners, symbols, unit motifs, terrain art, UI, names, music, lore, or maps.
- Do not ask for "in the style of" a protected franchise, living artist, or specific copyrighted source.
- Do not ingest copyrighted reference images as direct source material.
- Do not use or adapt trademarked faction symbols, skull-spike cliches that closely resemble a known faction, or recognizable building profiles.
- Keep Ashen architecture original to Ascendant Realms: ember-lit zeal, blackened road discipline, and wetland occupation are broad concepts, not copied expression.

## What This Spec Does Not Do

- No generated art.
- No image API calls.
- No imported art.
- No downloaded images.
- No runtime asset replacement.
- No new building data.
- No enemy construction, workers, economy AI, new pressure actions, campaign rewards, or map changes.
- No building size, radius, pathing, minimap, attack, victory, or save changes.
- No broad BattleScene or Building renderer rewrite.

## v0.9 Decision

Ashen outposts need a coherent architecture sheet before individual building replacement begins. This document defines that future direction while keeping the current browser prototype stable and source/license safe.
