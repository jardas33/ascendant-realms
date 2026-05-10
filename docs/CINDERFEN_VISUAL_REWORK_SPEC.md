# Cinderfen Visual Rework Spec

Date: 2026-05-10  
Status: future visual planning only. No new art, maps, units, factions, rewards, or gameplay changes are included.

## Purpose

This spec defines how Cinderfen should eventually look and how its visuals should support gameplay. It is not a v0.8 graphics implementation. It should guide a future visual sprint after the current browser prototype remains stable and fun.

## Current Problems

### Paint-Like Roads

Current roads are readable as lanes but are built from broad procedural strokes.

Problems:

- They look like guide marks rather than material.
- They do not imply planks, stone, ash, mud, or causeway construction.
- Their edges do not communicate weathering, water intrusion, or battlefield wear.

### Unclear Terrain Material

Cinderfen currently uses dark terrain fills, procedural ellipses, water blobs, and line details.

Problems:

- Grass, marsh, ash, mud, and cinder are not visually distinct enough.
- The terrain does not yet communicate a specific place.
- Unit/building sprites feel placed on top rather than grounded in the map.

### Rough Swamp And Water Areas

Water and marsh zones are readable but blob-like.

Problems:

- Edges lack natural bank or reed transitions.
- Ripple strokes read as annotation.
- Wetland areas do not yet sell depth, danger, reflection, or ash contamination.

### Capture Sites Too Icon-Like

Cinder Shrine and other resource sites are tactically clear, but their identity comes mostly from rings, labels, and resource icons.

Problems:

- The Cinder Shrine is not yet memorable as an environmental landmark.
- The capture boundary is clearer than the object being captured.
- Site ownership is readable, but site story is weak.

### Unit Scale Mismatch

Units remain playable, but source art, scale, shadows, and map terrain do not share a full production standard.

Problems:

- Characters can look like cutouts against procedural terrain.
- Labels and health bars do too much identity work.
- Future art needs a scale sheet before replacing sprites.

## Future Cinderfen Visual Identity

Cinderfen should feel like an ash-glass wetland: wet, dangerous, old, and ember-lit.

Core identity:

- Ash-glass wetland.
- Blackened causeways.
- Ember-lit shrine sites.
- Wet reflective pools.
- Dead reeds.
- Ruined watch markers.
- Cinder fog.
- Low, warm light against cold wet terrain.
- Road pressure and shrine routes that are readable at RTS camera distance.

## Gameplay Readability Requirements

### Roads Must Be Obvious

Requirements:

- Main route must be readable immediately from default camera.
- Side routes must be visible but visually secondary.
- Road edges should show passability.
- Pressure-relevant routes, including shrine route and Watch Road, must be easy to recognize.

### Capture Sites Must Pop

Requirements:

- Capture-site landmark must be visible before the player reads the label.
- Ownership/capture state must remain clear.
- Cinder Shrine should stand out from ordinary resource sites.
- The capture boundary should support the landmark, not replace it.

### Enemy Base Path Must Be Readable

Requirements:

- The path from player start to enemy base must be clear.
- Enemy base should have visible faction identity.
- Fortified areas should read as dangerous without needing new mechanics.

### Fog Must Not Hide Ownership Clarity

Requirements:

- Explored/unseen/visible states must remain readable.
- Captured sites should stay locally understandable under current fog rules.
- Fog should not obscure pressure warning comprehension.

### Units Must Remain Visible

Requirements:

- Units need contrast against marsh, road, water, and ash terrain.
- Health bars and labels should remain readable until source art can carry more identity.
- Selection rings should be visible on roads and wetland terrain.

## Browser Prototype Safe Improvements

These are possible later without a full asset pipeline, but are not automatically justified in v0.8:

### Overlays

Potential use:

- Slight road-edge accent.
- Capture-site ground contrast.
- Soft ownership accents.

Risk:

- Can add more UI-like paint instead of real material.

### Tinting

Potential use:

- Make Cinderfen grass/marsh/water zones more distinct.
- Improve terrain contrast around shrine routes.

Risk:

- Color-only fixes may reduce accessibility or make the palette muddy.

### Simple Material Zones

Potential use:

- Separate ash mud, blackwater, road, and ruined ground.

Risk:

- Without actual material art, zones can still look like blobs.

### Label And Marker Consistency

Potential use:

- Make Cinder Shrine, Watch Road, and other important sites use consistent label hierarchy.

Risk:

- Labels can become more dominant and less immersive.

## Future Production Art Requirements

### Terrain Kit

Needed:

- Blackened causeway straight, bend, fork, edge, and broken variants.
- Ash mud ground.
- Shallow blackwater.
- Wet reflective pools.
- Dead reeds.
- Ash-glass outcrops.
- Burned carts, palisades, road markers, and ruin props.
- Boundary pieces for dense swamp, collapsed road, or fog wall.

### Capture-Site Model Or Icon Set

Needed:

- Cinder Shrine landmark.
- Watch Road toll/marker.
- Refugee-related site marker if needed later.
- Resource-site variants for crowns, stone, iron, and aether.
- Ownership VFX states for neutral, player, and enemy.

### Environmental Props

Needed:

- Dead reeds.
- Charred stumps.
- Ember stones.
- Wet ash ripples.
- Broken signposts.
- Glass ribs.
- Ruin fragments.
- Small road lamps or braziers if they fit the original world.

### Lighting Palette

Needed:

- Cold blackwater shadows.
- Green-brown marsh base.
- Muted gray ash.
- Ember orange accents.
- Pale shrine glow.
- Enemy base warm hostile light.

### Minimap Consistency

Needed:

- Cinderfen terrain colors that correspond to the main view.
- Strong capture-site markers.
- Clear fog state.
- Pressure-relevant route readability.

## Art Prompt Templates

These are future brief templates only. They should be used with approved tools or artists and must include source/license tracking.

### Cinderfen Terrain Style Frame

Prompt brief:

```text
Original dark heroic fantasy RTS terrain style frame for an ash-glass wetland called Cinderfen. Show blackened causeways, wet ash mud, dead reeds, shallow reflective blackwater, ember-lit stones, ruined road markers, and clear tactical paths. Readable from an overhead RTS camera. Do not imitate any existing game, franchise, faction, map, UI, or protected art style. No characters, no logos, no copyrighted references.
```

### Cinder Shrine / Capture-Site Concept

Prompt brief:

```text
Original fantasy RTS capture-site landmark for Cinderfen: an ember-lit shrine built from black stone and ash-glass, with a readable circular capture boundary, subtle ritual glow, and wet marsh ground around it. Designed for top-down or 2.5D gameplay readability. Original IP only, no copied symbols, no existing franchise references.
```

### Cinderfen Road / Causeway Concept

Prompt brief:

```text
Original RTS road material concept for Cinderfen: blackened raised causeway across ash marsh, broken stone edges, wet mud margins, dead reeds, subtle ember flecks, readable path edges for gameplay. Overhead game camera readability, modular terrain-kit thinking, original IP only.
```

### Ashen Enemy Outpost Concept

Prompt brief:

```text
Original enemy outpost concept for a dark heroic fantasy RTS: blackened timber, hard stone, ember-lit banners, guarded road pressure, readable hostile silhouette, built for top-down gameplay. Avoid copying any existing game faction, building, logo, UI, color scheme, or protected expression.
```

## Implementation Phases

### Phase A - Visual Audit

Use:

- `docs/V08_VISUAL_DEBT_AUDIT.md`
- `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`
- Current gameplay screenshots.
- Human feedback on Cinder Shrine salience and route readability.

Output:

- Confirm the highest-value Cinderfen visual target.
- Choose whether first work is terrain, capture site, or UI marker clarity.

### Phase B - Style Frame

Output:

- One Cinderfen terrain style frame.
- One Cinder Shrine/capture-site style frame.
- One UI marker/ownership treatment sample.

Rules:

- No runtime import until source/license metadata exists.
- No broad renderer rewrite.

### Phase C - Prototype Terrain Pass

Possible scope:

- Improve existing map rendering style on current Cinderfen maps only.
- Preserve map dimensions, capture-site positions/radii, rewards, pressure plans, and campaign progression.
- Add screenshot/layout checks before and after.

Rules:

- No new map.
- No new units.
- No new factions.
- No save changes.

### Phase D - Production Asset Pass Later

Possible scope:

- Terrain kit.
- Capture-site landmark art.
- Building foundations.
- Unit scale-sheet application.
- Minimap style update.

Rules:

- Requires approved asset pipeline.
- Requires source/license records.
- Requires screenshot gates.
- Should wait until browser prototype systems remain stable.

## v0.8 Decision

No new art was generated or committed. No Cinderfen map data, rewards, pressure plans, campaign progression, units, buildings, renderer behavior, UI layout, or save format changed. This spec is a future visual target and implementation guardrail only.
