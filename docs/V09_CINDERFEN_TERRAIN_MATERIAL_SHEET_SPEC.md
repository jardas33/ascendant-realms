# v0.9 Cinderfen Terrain Material Sheet Spec

Date: 2026-05-10  
Status: future material specification only. No textures, images, assets, renderer changes, maps, gameplay changes, or runtime imports are included.

## Purpose

This document specifies the future Cinderfen terrain material sheet before any art is generated, purchased, commissioned, imported, or wired into the game. It turns the v0.9 visual pillars into a concrete terrain brief for roads, marsh, water, reeds, fog, ruin edges, and ritual accents.

The current browser prototype remains the gameplay truth. This spec does not authorize changing map data, passability, capture radii, terrain collision, fog rules, camera behavior, minimap behavior, or save data.

## Global Material Rules

- Roads must read first.
- Cinder Shrine and capture sites must read second.
- Unit silhouettes, selection rings, labels, health bars, projectiles, and pressure warnings must remain clear.
- Materials must support top-down or high 2.5D RTS readability, not close-up illustration only.
- Cinderfen should feel like an ash-glass wetland: cold wet terrain, blackened construction, dead reeds, drowned ruins, and controlled ember accents.
- No material should copy Warcraft, Warlords Battlecry, or any other protected franchise, terrain kit, map, faction language, UI, symbol, or art style.
- No material should imply new mechanics such as burning damage, slow zones, stealth, bridges, destructible roads, or resource harvest nodes unless those mechanics already exist.

## Material 1 - Blackened Causeway Road

Purpose: define the main travel lanes as constructed, raised, weathered routes through the wetland.

Gameplay readability role: primary route language. The player should recognize roads before terrain ornament, shrine glow, or enemy architecture.

Color/value direction:

- dark basalt gray, charred timber brown-black, compacted ash gray,
- slightly higher value edge highlights than surrounding ash mud,
- restrained wet glints, not bright puddle noise,
- no saturated lava treatment.

Texture detail level: medium-low frequency at gameplay scale. Road body can show long planks, broken stone slabs, compacted ash, or wheel-worn streaks, but small gravel detail should not vibrate under units.

Edge/blend behavior:

- raised or built edge must separate road from mud and water,
- broken stone, charred stakes, shallow bank shadow, and mud creep can soften edges,
- fork and bend transitions must remain readable,
- side paths should use lower contrast than main causeways.

Scale notes:

- road width should visually support group movement at current RTS camera scale,
- edge pieces should be large enough to read without becoming capture-site markers,
- avoid repeating tiles that form accidental arrows or symbols.

Browser prototype target: if later adapted, it should still read clearly under existing labels, health bars, selection rings, fog, and minimap colors. It may remain simpler and flatter than a production terrain kit.

Future desktop target: modular material kit with straight, bend, fork, T-junction, broken edge, flooded edge, ruin-edge, and road-to-shrine transition variants.

Risks:

- over-detailing can hide infantry and projectiles,
- road markings can look like UI strokes if not grounded,
- warm ember flecks can be mistaken for pickups or objectives,
- low contrast can collapse route readability.

Prompt fragment for future asset generation:

```text
Original dark heroic fantasy RTS blackened raised causeway material for Cinderfen, built from basalt slabs, charred timber braces, compacted ash, wet mud margins, and dead reed edges. Clear passable road silhouette from a top-down or high 2.5D camera, modular straight/bend/fork thinking, no copied franchise terrain, no protected symbols, no UI-like arrows.
```

Manifest metadata expectations:

- `category: "terrain"`
- `currentStatus: "candidate"` or `reference` until reviewed
- `sourceType` must identify manual, generated, purchased, original, or external-reference source
- `licenseStatus` must not be `owned` or `licensed` without evidence
- `usage: "docs-reference"` or `unused` until runtime integration is approved
- `visualFamily: "cinderfen"`
- `scaleClass: "terrain"`
- `replacementPriority: "critical"`
- `allowedInProduction: false` until source/license and screenshot review are complete
- `needsReview: true`

## Material 2 - Ash Mud / Dark Marsh Ground

Purpose: provide the default Cinderfen ground plane: wet, ashen, hostile, but quiet enough for tactical play.

Gameplay readability role: low-noise support surface for units, buildings, roads, shrine rings, and enemy pressure.

Color/value direction:

- wet charcoal, dark olive mud, soot gray, muted brown-green,
- cooler and lower contrast than ember sites,
- matte in broad areas with occasional wet sheen.

Texture detail level: low frequency. Use broad mud seams, ash smears, and shallow depressions rather than dense speckle.

Edge/blend behavior:

- blends into road edges through mud creep and compacted ash,
- blends into water through darker wet margins and reed clumps,
- should not create random islands that imply blockers.

Scale notes:

- detail should be larger than individual unit feet at current camera distance,
- avoid repeating blotches that look like decals or enemy shadows.

Browser prototype target: a restrained base material that improves place identity without requiring renderer or pathfinding changes.

Future desktop target: layered ground material with wetness variation, ash deposits, subtle normal/lighting support, and authored transitions to water, reeds, roads, and ruin edges.

Risks:

- can become generic dark sludge,
- can swallow dark unit silhouettes,
- can make selection rings too bright by contrast if the ground is too dark,
- can imply impassable swamp if over-saturated with muck.

Prompt fragment for future asset generation:

```text
Original Cinderfen ash-mud ground material for an RTS battlefield, wet charcoal and dark olive marsh soil with muted ash smears, low-noise tactical readability, broad muddy variation, no clutter, designed to sit beneath units and selection rings from a top-down or high 2.5D camera.
```

Manifest metadata expectations: same terrain metadata pattern as the causeway, with `replacementPriority: "critical"` when intended to replace the current procedural Cinderfen ground.

## Material 3 - Shallow Reflective Water

Purpose: define shallow blackwater, puddles, flooded road margins, and reflective wetland surfaces.

Gameplay readability role: identify wetland character and terrain transition without confusing passability or unit selection.

Color/value direction:

- muted blue-green reflection,
- cold gray highlights,
- near-black shadow in deeper pockets,
- minimal warm reflection except near shrine or outpost light.

Texture detail level: low to medium-low. Use broad reflection bands and subtle ripple direction, not dense wave lines.

Edge/blend behavior:

- water should meet mud through dark wet margins, drowned reeds, and soft bank shapes,
- flooded causeway edges should still preserve road silhouette,
- shallow water must be visually distinct from deep swamp pools.

Scale notes:

- highlight shapes must not resemble projectile trails, selection rings, capture arcs, or resource icons,
- water patches should avoid circular blobs unless gameplay requires a circular marker.

Browser prototype target: should improve current blob-like water while staying subordinate to road and unit readability.

Future desktop target: reflective material set with edge variants, flooded road margins, shrine-lit pools, and lowland fog interaction.

Risks:

- bright highlights can compete with UI overlays,
- ripple strokes can look like annotation,
- reflection detail can break unit silhouettes,
- water edges can imply pathing changes that do not exist.

Prompt fragment for future asset generation:

```text
Original Cinderfen shallow blackwater material for a dark heroic fantasy RTS, muted blue-green wet reflections, ash-contaminated puddles, soft mud and dead-reed edges, readable from high 2.5D gameplay view, no bright UI-like rings, no copied terrain style.
```

Manifest metadata expectations: terrain entry, `visualFamily: "cinderfen-water"`, source/license proof required before production approval, screenshot targets should include water near roads and units.

## Material 4 - Deep Swamp Pool

Purpose: mark darker, more dangerous-looking pools and blocked or non-command spaces where the map already supports that read.

Gameplay readability role: communicate "not ordinary ground" without adding new hazard rules.

Color/value direction:

- almost-black blue-green,
- soft cold rim light,
- subtle oily surface depth,
- occasional drowned ash flecks.

Texture detail level: low. Deep pools should be broad, calm, and ominous rather than noisy.

Edge/blend behavior:

- strong enough edge to separate from ash mud,
- reed beds and broken stone can mark boundaries,
- avoid perfect circles except for authored landmark composition.

Scale notes:

- large enough shapes to read as terrain features, not decals,
- interior highlights should not resemble enemy units, loot, or VFX.

Browser prototype target: clarify current swamp blobs as wetland features while preserving existing pathing and blocked-zone expectations.

Future desktop target: authored pool shapes with bank pieces, submerged ruin fragments, fog interaction, and controlled reflection.

Risks:

- too much black can hide units or imply holes,
- too much green can turn into generic toxic sludge,
- bright rims can look like capture boundaries,
- hazard visuals can imply unimplemented damage.

Prompt fragment for future asset generation:

```text
Original deep Cinderfen swamp pool material, almost-black blue-green water with wet ash banks, dead reeds, drowned ruin fragments, subdued reflection, high RTS readability, no toxic-sludge cliche, no copied franchise terrain, no implied damage icons.
```

Manifest metadata expectations: terrain entry, `replacementPriority: "high"` unless it replaces core procedural terrain, `allowedInProduction: false` until source/license and screenshot review pass.

## Material 5 - Dead Reed Beds

Purpose: define wetland edges, blocked margins, and environmental texture without filling the command space with clutter.

Gameplay readability role: edge language for water, swamp, roads, and impassable-looking terrain. Reeds should clarify transitions, not hide units.

Color/value direction:

- dead straw gray,
- soot brown,
- muted ochre,
- low saturation against charcoal mud.

Texture detail level: medium at edges, sparse in command spaces. Clumps should read as groups rather than individual needle lines.

Edge/blend behavior:

- strongest at water and swamp margins,
- sparse along roads except where they help explain raised causeways,
- should break up blob edges without creating visual walls unless a map boundary already exists.

Scale notes:

- reed height should stay below small-unit silhouette priority at current camera scale,
- clumps should not look like units, resource nodes, or projectiles.

Browser prototype target: future overlays or material art could use reeds to explain water/mud transitions without changing collision.

Future desktop target: prop and material variants for small clumps, bank strips, dense blocked reed masses, drowned reeds, and shrine-adjacent scorched reeds.

Risks:

- dense reeds can hide infantry,
- repeated clumps can form visual noise,
- high-contrast reeds can look like arrows or bone piles,
- dense reed beds can imply new harvest or cover mechanics.

Prompt fragment for future asset generation:

```text
Original dead reed bed material and prop sheet for Cinderfen, soot-brown and gray straw marsh reeds, sparse tactical edge language for blackwater and ash mud, readable top-down RTS scale, no clutter in unit command spaces, no copied fantasy game plant kit.
```

Manifest metadata expectations: `category: "terrain"` or `reference` depending on sheet purpose, `scaleClass: "terrain"` or `reference`, screenshot QA must verify units and selection rings over/near reeds.

## Material 6 - Cinder Fog / Shadow Overlay

Purpose: define atmospheric cinder haze, wet fog, and shadow overlays as a style-frame target.

Gameplay readability role: frame uncertainty and mood while preserving fog-of-war state clarity, ownership, route reading, and pressure warnings.

Color/value direction:

- blue-green haze,
- cool gray cinder smoke,
- low-opacity charcoal shadow,
- no dominant purple-blue gradient identity.

Texture detail level: very low frequency. Fog should be atmosphere, not surface clutter.

Edge/blend behavior:

- fog should feather into terrain and avoid hard rings except where current gameplay fog requires them,
- shadow overlays should not erase road edges or shrine ownership,
- fog must remain distinct from minimap and gameplay visibility states if later rendered differently.

Scale notes:

- broad shapes only,
- no small particles that read as resources, projectiles, or UI icons.

Browser prototype target: documentation target only unless a later small rendering pass is approved. Any runtime fog work must preserve current visibility rules and e2e coverage.

Future desktop target: layered atmospheric treatment with camera-safe haze, cold wet pools, cinder drift, and clear visibility-state transitions.

Risks:

- hiding capture-site ownership,
- making enemy approach paths hard to read,
- adding performance cost,
- implying stealth or new hidden mechanics,
- making screenshots feel darker without becoming clearer.

Prompt fragment for future asset generation:

```text
Original Cinderfen cinder fog and wet shadow overlay style frame, cold blue-green lowland haze, cool gray ash smoke, broad readable atmosphere for RTS gameplay, roads and shrine ownership still clear, no heavy smoke clutter, no copied game fog style.
```

Manifest metadata expectations: `category: "vfx"` or `terrain` depending on final asset, `usage: "docs-reference"` until runtime approval, screenshot targets must include pressure warning and shrine ownership views.

## Material 7 - Ruined Stone Edging

Purpose: ground roads, shrines, pools, and old watch routes in a drowned ruin history.

Gameplay readability role: clarify constructed boundaries, passable edges, and important route/site transitions.

Color/value direction:

- basalt gray,
- ash-stained stone,
- wet moss-black edges,
- tiny ember reflection only near ritual sites.

Texture detail level: medium but chunked. Use readable slabs and broken blocks, not pebble noise.

Edge/blend behavior:

- appears along causeways, shrine pads, watch-road fragments, and swamp borders,
- should break silhouettes without obscuring road width,
- should not create false walls inside passable lanes.

Scale notes:

- blocks must read at RTS camera distance,
- pieces should be visually below buildings but above ground texture,
- avoid shapes that mimic unit bases or capture rings.

Browser prototype target: future material or prop reference for making current roads and capture-site surroundings feel built.

Future desktop target: modular ruin edge kit: slabs, collapsed curb, broken bridge lip, shrine plinth edge, waterline stones, and old watch-road marker bases.

Risks:

- too much edging can narrow perceived lanes,
- stone props can resemble buildings or blockers,
- repeated pieces can reveal tiling,
- high contrast can compete with shrine landmarks.

Prompt fragment for future asset generation:

```text
Original ruined basalt stone edging kit for Cinderfen RTS terrain, ash-stained road curbs, broken wet slabs, drowned watch-road fragments, modular edges for causeway and shrine pads, readable from high 2.5D camera, no protected franchise architecture or symbols.
```

Manifest metadata expectations: terrain or reference entry, source/license fields complete, `usedBy` should name planned surfaces only after integration planning.

## Material 8 - Embers / Ritual Scorch Marks

Purpose: provide controlled warm accents for shrines, Ashen outposts, ritual scars, and route story.

Gameplay readability role: focus attention on landmarks and hostile architecture without turning every terrain patch into an objective.

Color/value direction:

- dull ember orange,
- dark red heat cracks,
- black scorch halos,
- occasional pale aether glint only for shrine contexts.

Texture detail level: sparse and intentional. Embers should be accents, not a full terrain carpet.

Edge/blend behavior:

- scorch marks should sit on stone, ash mud, or shrine/outpost pads,
- warm accents should fade before they reach unit command clusters,
- avoid circular scorch shapes that look like capture boundaries unless attached to a landmark spec.

Scale notes:

- small enough to feel like material detail,
- large enough near shrine landmarks to read at gameplay scale,
- no tiny bright particles that mimic loot, VFX, or projectiles.

Browser prototype target: future reference only until capture-site and outpost landmarks are specified and reviewed.

Future desktop target: authored scorch decals, cracked ember stones, ritual lines, shrine activation glow, and outpost window/slit light that all share one accent language.

Risks:

- can be mistaken for active gameplay effects,
- can over-warm the palette,
- can make roads look hazardous,
- can compete with ownership color.

Prompt fragment for future asset generation:

```text
Original Cinderfen ember and ritual scorch material accents, dull orange heat cracks in black ash and basalt, sparse shrine/outpost focus detail for RTS readability, no lava field, no copied symbols, no UI-like objective marker, transparent decal variants if applicable.
```

Manifest metadata expectations: `category: "terrain"` or `vfx`, `currentStatus: "candidate"` only after reviewed, `licenseStatus` evidence required, screenshot QA must confirm ownership and VFX are not confused.

## Tile And Material Naming Convention Proposal

Future terrain candidates should use descriptive ids that separate region, material, variant, and status:

```text
cinderfen_terrain_<material>_<variant>_<status>
```

Examples:

- `cinderfen_terrain_causeway_straight_candidate`
- `cinderfen_terrain_causeway_fork_reference`
- `cinderfen_terrain_ash_mud_base_reference`
- `cinderfen_terrain_shallow_blackwater_edge_candidate`
- `cinderfen_terrain_deep_pool_bank_reference`
- `cinderfen_terrain_dead_reeds_bank_candidate`
- `cinderfen_terrain_cinder_fog_overlay_reference`
- `cinderfen_terrain_ruin_edge_broken_candidate`
- `cinderfen_terrain_ember_scorch_decal_reference`

File path placeholders, if future assets are approved, should stay outside runtime folders until integration:

```text
docs/asset-review/cinderfen/<material>/<asset-name>.png
```

Do not create those folders or files during v0.9.

## Screenshot QA Requirements

Future material candidates must be reviewed through screenshots before runtime replacement:

- `cinderfen-crossing-desktop.png`: main route, shrine context, water/mud edges.
- `cinderfen-crossing-tablet.png`: road and unit readability at tablet density.
- `cinderfen-crossing-pressure-desktop.png`: pressure warning plus road/shrine readability.
- `cinderfen-watch-desktop.png`: enemy road/base approach and swamp edges.
- `cinderfen-watch-pressure-desktop.png`: enemy pressure path and outpost readability.
- `tutorial-desktop.png`: unit readability comparison against non-Cinderfen baseline.
- `tutorial-mobile.png`: label/bar/selection readability at high density.
- Future before/after screenshots for any actual runtime replacement.

Review expectations:

- roads are obvious without reading labels,
- water and swamp no longer look like arbitrary blobs,
- unit silhouettes sit above terrain noise,
- capture-site rings and ownership remain clear,
- minimap and battlefield materials do not contradict each other,
- no screenshot review relies on pixel-perfect diffing,
- human review is required before approval.

## No-Runtime-Import Warning

This spec does not authorize generated art, imported textures, downloaded images, asset folder creation, manifest runtime entries, map renderer changes, terrain replacement, feature flags, CSS visual overhaul, gameplay changes, or production approval.

Any future terrain asset must first pass source/license review, manifest metadata validation, screenshot QA, and a separate scoped implementation plan.
