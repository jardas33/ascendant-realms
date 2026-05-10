# v0.9 Cinderfen Visual Pillars

Date: 2026-05-10  
Status: v0.9 style rules for future Cinderfen visuals. This document does not generate, import, download, replace, or approve art assets.

## Purpose

This document defines the visual language rules future Cinderfen assets must obey. It translates the research packet into practical constraints for terrain materials, roads, shrine landmarks, Ashen outposts, unit/building scale, prompts, manifest templates, and screenshot review.

The rules are intentionally gameplay-first. Cinderfen should become more atmospheric only when the battlefield remains readable.

## Pillar 1 - Roads Read First

Meaning: Cinderfen is a wetland battlefield where the road network is survival infrastructure. The player should see the main causeway before noticing ornamental detail.

Why it matters for gameplay: current Cinderfen pressure, shrine routing, neutral camps, and enemy approach paths depend on the player reading road direction quickly.

Visual do:

- use clear value contrast between blackened causeway and ash mud,
- show passable road edges with broken stone, charred timber, compacted ash, or raised embankments,
- keep main routes stronger than side routes,
- leave quiet road-adjacent space for unit silhouettes and selection rings.

Visual avoid:

- paint-stroke roads with no material logic,
- road clutter that looks like units, pickups, or capture-site markers,
- ultra-detailed stones that break route readability,
- decorative cracks that make path edges ambiguous.

Screenshot QA target:

- `cinderfen-crossing-desktop.png`
- `cinderfen-crossing-tablet.png`
- `cinderfen-watch-desktop.png`

Future asset implication: road/causeway materials need straight, bend, fork, edge, broken-edge, and transition variants before runtime terrain replacement.

## Pillar 2 - Shrines Glow Second

Meaning: Cinder Shrine and related capture sites should be the second visual read after roads. They should feel like places, not only rings.

Why it matters for gameplay: the Cinder Shrine surge, Shrine Attunement service, pressure routes, and capture-site ownership all depend on site recognition.

Visual do:

- use a small vertical landmark silhouette,
- include ember cracks or controlled ritual glow,
- keep wet ash ground contact visible,
- preserve a clean capture boundary as a gameplay overlay,
- make neutral, player, enemy, active, and depleted states readable from the same base shape.

Visual avoid:

- giant symbols that replace the landmark,
- copied shrine or faction shapes from existing games,
- effects that hide capture progress or ownership,
- landmarks that disappear under fog or labels.

Screenshot QA target:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-crossing-pressure-desktop.png`

Future asset implication: Cinder Shrine requires a landmark sheet with ownership and activation states before ring/icon reduction is considered.

## Pillar 3 - Units Always Sit Above Terrain Noise

Meaning: terrain supports decisions; units are the decisions. Ground detail must never compete with command readability.

Why it matters for gameplay: current unit identity still relies on labels, health bars, and selection rings. Future terrain can improve mood only if it keeps combat legible.

Visual do:

- keep combat surfaces lower frequency than units,
- reserve high-contrast ember detail for landmarks and enemy architecture,
- keep selection rings and health bars readable over roads, marsh, water edges, and fog,
- use terrain values that preserve player/enemy contrast.

Visual avoid:

- noisy reeds under infantry clusters,
- reflective water highlights that look like projectiles or selection rings,
- dark units on equally dark road patches without edge contrast,
- fog color that swallows bars, labels, or spell VFX.

Screenshot QA target:

- `tutorial-desktop.png`
- `tutorial-mobile.png`
- `cinderfen-crossing-tablet.png`
- `cinderfen-watch-pressure-desktop.png`

Future asset implication: terrain materials and unit replacement sheets must be reviewed together, not as isolated art tasks.

## Pillar 4 - Wetland Is Dangerous But Not Messy

Meaning: Cinderfen should feel hostile, drowned, and ashen, but not visually chaotic.

Why it matters for gameplay: swamp and blocked terrain need to communicate danger without hiding lanes or implying new mechanics.

Visual do:

- separate shallow reflective water from deep swamp pools,
- use dead reeds as edge language, not blanket noise,
- place ruins and stones to clarify terrain transitions,
- show wet ash and cinder haze as atmosphere rather than obstruction.

Visual avoid:

- generic dark sludge,
- excessive reeds or debris in normal command spaces,
- water shapes that look like random blobs,
- hazard treatment that implies unimplemented damage or slow mechanics.

Screenshot QA target:

- `cinderfen-crossing-desktop.png`
- `cinderfen-watch-desktop.png`

Future asset implication: terrain material sheets should define edge and blend behavior before any map renderer pass.

## Pillar 5 - Ashen Architecture Is Angular, Scorched, And Ritualized

Meaning: Ashen outposts should feel hostile through shape and material, not only tint or labels.

Why it matters for gameplay: enemy strongholds, barracks, watchtowers, and road markers must communicate target priority and threat.

Visual do:

- use scorched timber, black iron braces, basalt stones, ember-lit slits, and harsh rooflines,
- make the stronghold the largest and most threatening silhouette,
- make towers narrow and vertical enough to read as ranged threats,
- make barracks/war camps read as production structures.

Visual avoid:

- copied faction architecture,
- generic evil spikes without construction logic,
- building silhouettes that resemble player structures too closely,
- road markers that look like capture sites.

Screenshot QA target:

- `cinderfen-watch-desktop.png`
- `cinderfen-watch-pressure-desktop.png`
- `results-defeat-desktop.png`

Future asset implication: Ashen architecture needs a category sheet before individual stronghold, barracks, tower, or prop replacement.

## Pillar 6 - Player Structures Remain Grounded And Readable

Meaning: future Cinderfen art should not make the player's base feel pasted onto the marsh.

Why it matters for gameplay: player base structures, training flow, and selection panels are core RTS verbs.

Visual do:

- preserve readable building footprints,
- show foundations, entry paths, and ground contact,
- leave space for bars, labels, rally markers, and construction feedback,
- keep player materials distinct from Ashen materials.

Visual avoid:

- terrain overlays that obscure building placement,
- background props that look like player buildings,
- new art that changes perceived footprint without data changes,
- decorative foundations that imply unimplemented terrain blockers.

Screenshot QA target:

- `tutorial-desktop.png`
- `skirmish-setup-desktop.png` for pre-battle context
- future before/after Cinderfen battle screenshots

Future asset implication: player building replacements need footprint notes, visual bounds, and label/bar compatibility before runtime use.

## Pillar 7 - Fog Frames Decisions, Not Hides Them

Meaning: Cinderfen fog should express wet ash and uncertainty while preserving commands, ownership, and pressure feedback.

Why it matters for gameplay: fog is part of scouting and pressure, but hidden information should never become visual confusion.

Visual do:

- use blue-green wet haze and cinder smoke as low-intensity atmosphere,
- keep explored/unseen/visible states distinct,
- preserve captured-site visibility under existing reveal rules,
- keep pressure warnings and objective feedback legible.

Visual avoid:

- fog that hides capture ownership,
- heavy smoke over command clusters,
- palette shifts that make enemy/player color unreliable,
- atmospheric effects that imply new stealth or damage rules.

Screenshot QA target:

- `cinderfen-crossing-pressure-desktop.png`
- `cinderfen-watch-pressure-desktop.png`
- layout fog/minimap e2e screenshots when runtime visuals later change.

Future asset implication: fog style frames should be reviewed with minimap and pressure-warning views, not only as mood art.

## Pillar 8 - UI Labels Support, But Do Not Carry, Identity

Meaning: labels, rings, health bars, and panels can remain in the prototype, but future art should carry more identity itself.

Why it matters for gameplay: the current interface is readable because text is doing heavy lifting. Future visuals should let the UI become less noisy without losing clarity.

Visual do:

- preserve current semantic labels until art proves it can replace them,
- design landmarks and buildings with distinct silhouettes,
- use UI overlays as confirmation, not primary identity,
- keep mobile/tablet density in every review.

Visual avoid:

- removing labels before silhouettes are proven,
- making asset art depend on tiny text,
- solving landmark identity by adding more UI copy,
- using art detail as a reason to weaken accessibility/readability.

Screenshot QA target:

- `tutorial-mobile.png`
- `hero-inventory-desktop.png`
- `asset-gallery-desktop.png`
- `results-victory-desktop.png`
- `results-defeat-desktop.png`

Future asset implication: every future replacement should include a "can this be recognized without its label?" review note.

## Color Palette Direction In Words

Cinderfen should not become a one-note dark green or brown field. Use contrast families rather than a single hue.

Palette direction:

- base: wet charcoal, black ash, dark olive mud,
- road: blackened basalt, charred timber, compacted gray ash,
- water: muted blue-green reflection, almost-black deep pools,
- reeds: dead straw gray, soot brown, muted ochre,
- shrine/accent: ember orange, dull red heat, pale aether glints,
- fog: blue-green haze, cool gray cinder smoke,
- Ashen architecture: black iron, scorched wood, basalt stone, controlled ember windows,
- UI/gameplay overlays: retain high contrast and team/ownership readability.

Avoid:

- saturated lava everywhere,
- purple-blue fantasy gradients as the identity,
- beige parchment overload,
- brown/orange-only mud fields,
- palettes too dark for unit silhouettes.

## Material Language

Primary materials:

- blackened raised causeway,
- wet ash mud,
- shallow reflective blackwater,
- deep swamp pools,
- dead reed beds,
- basalt stone edging,
- charred timber braces,
- ember cracks and ritual scorch marks,
- cinder fog and wet haze.

Material rules:

- roads are built and raised,
- water is reflective but subdued,
- ash mud is matte and low-noise,
- reeds define edges and danger,
- embers identify sites and Ashen architecture,
- ruins and stones explain old route structure.

## Lighting Direction

Cinderfen lighting should be cold environment plus warm points.

Rules:

- ambient world: cold, wet, blue-green gray,
- shrine/outpost points: small warm ember lights,
- no broad lava glow unless a future map explicitly supports it,
- unit silhouettes should not be backlit into unreadability,
- warm light marks important locations but does not replace capture ownership color.

## Scale Direction

Cinderfen visual scale should preserve the current prototype's tactical relationships:

- roads wide enough for group movement and readable paths,
- capture-site landmarks larger than icons but smaller than buildings,
- infantry lower than heroes and commanders,
- brutes larger than infantry but below building scale,
- towers tall and narrow,
- strongholds visually dominant,
- environmental props below unit/building priority unless used as blockers.

Runtime radii, building sizes, capture-site radii, camera zoom, pathfinding cell size, fog cell size, and map dimensions should not change in v0.9.

## Camera And Readability Assumptions

Assumptions:

- default browser battle camera remains the primary review camera,
- screenshots are review artifacts, not pixel-perfect baselines,
- visual direction must work for desktop and tablet battle views,
- mobile battle remains a density watchpoint,
- minimap remains diagrammatic until a future UI pass.

Future style frames should be judged from top-down or high 2.5D RTS readability, not only as close-up concept art.

## Browser-Prototype-Safe Scope

Safe in the current prototype:

- docs/specs/prompts,
- source/license checklists,
- manifest templates for future assets,
- screenshot acceptance criteria,
- no-runtime future implementation planning.

Not safe in this phase:

- asset generation,
- asset import,
- runtime replacement,
- renderer changes,
- CSS redesign,
- gameplay or balance changes.

## Future Desktop-Quality Production Scope

Future production work may eventually need:

- coherent terrain material kits,
- authored 2.5D or 3D style frames,
- unit/building scale sheets,
- animation and VFX standards,
- final UI art direction,
- source files and production metadata,
- stronger performance and asset-size rules,
- possible future engine/desktop analysis.

Those decisions are outside v0.9. The browser prototype remains the source of gameplay truth.

## v0.9 Decision

These pillars authorize only documentation, prompt, manifest-template, and acceptance-criteria work. They do not authorize new art, generated images, imported assets, runtime replacement, renderer work, gameplay expansion, or production approval of unknown-source assets.
