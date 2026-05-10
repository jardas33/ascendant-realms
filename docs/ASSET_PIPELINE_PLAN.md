# Ascendant Realms Asset Pipeline Plan

Date: 2026-05-10  
Status: planning document. No new assets are added by this phase.

## Purpose

This plan defines how future Ascendant Realms assets should be created, tracked, reviewed, and integrated. It supports the current browser prototype and the long-term desktop-quality 2026 visual direction, while avoiding full art overhaul work during v0.8.

## Current Asset Situation

Current assets are useful for a mechanics prototype, but they are not yet a complete production pipeline.

Current state:

- Runtime assets exist under `public/assets/final/`.
- Manual/reference assets exist under `public/assets/manual/`.
- Some entity sprites are present and used by the runtime.
- The map renderer still creates terrain procedurally with Phaser graphics.
- Capture sites rely on resource icons, rings, labels, and procedural ground marks.
- UI styling is mostly CSS and DOM, split across domain files under `src/game/styles/`.
- The game has content validation and e2e/layout coverage, but not asset-style validation beyond runtime existence and UI flow.

## Current Problems

### Inconsistent Scale

Units, buildings, capture sites, map lanes, and UI overlays are readable, but they do not come from a single scale sheet.

Problems:

- Source sprites have inconsistent proportions.
- Runtime scale makes assets usable but does not make them stylistically coherent.
- Capture-site icons are much smaller than their rings.
- Buildings have practical footprints but limited ground contact/foundation art.

### Inconsistent Style

The game currently mixes procedural terrain, cutout-like sprites, symbolic UI markers, and fantasy DOM panels.

Problems:

- Terrain and sprites do not share material/detail density.
- Unit/building palettes and line treatment are not governed by one style rule.
- UI panels are readable but not yet a final interface art system.

### Rough Map Art

Map visuals are generated from broad strokes, ellipses, and procedural details.

Problems:

- Roads read as guide strokes.
- Swamp/water reads as blobs.
- Blockers read as markers, not physical objects.
- Boundaries are functional but not immersive.

### Placeholder Sprites

Placeholder sprites help playtesting, but should not become invisible debt.

Problems:

- Some visuals carry a generated/concept-art feel.
- Animation standards are not yet defined.
- Character role identity still relies too much on labels.

## Future Asset Categories

### Unit Sprites Or Models

Needed categories:

- Hero classes.
- Militia/common infantry.
- Rangers/ranged infantry.
- Acolytes/casters.
- Ashen Covenant raiders.
- Ashen Covenant hexers.
- Ashen Covenant brutes.
- Enemy commanders/rivals.
- Wild creatures.
- Future retinue variants only when explicitly approved.

Required metadata:

- Asset id.
- Unit id or role.
- Faction id.
- Placeholder or production status.
- Source/license.
- Intended visual height.
- Anchor/origin.
- Direction count, if animated.
- Animation clips, if animated.
- Notes for VFX and health-bar/selection placement.

### Building Sprites Or Models

Needed categories:

- Command Hall.
- Barracks.
- Mystic Lodge.
- Watchtower.
- Enemy Stronghold.
- Enemy Barracks.
- Future capture-site landmarks.

Required metadata:

- Asset id.
- Building id.
- Faction id.
- Footprint size.
- Visual bounds.
- Anchor/origin.
- Construction state availability.
- Damaged/destroyed state availability.
- Source/license.
- Placeholder or production status.

### Terrain Tiles Or Materials

Needed categories:

- Grass.
- Dirt road.
- Blackened causeway.
- Marsh.
- Shallow water.
- Ash glass.
- Ruins.
- Blockers.
- Map boundary pieces.

Required metadata:

- Terrain id.
- Biome.
- Passable/blocked role.
- Repeat/tile rules.
- Edge-transition rules.
- Minimap color.
- Source/license.

### UI Frames And Icons

Needed categories:

- Resource icons.
- Command icons.
- Build/train/research icons.
- Hero ability icons.
- Objective icons.
- Warning/pressure status icons.
- Results/progression/inventory frames.
- Minimap markers.

Required metadata:

- Asset id.
- UI use.
- Size variants.
- Disabled/hover/active states.
- Accessibility contrast notes.
- Source/license.

### VFX

Needed categories:

- Projectiles.
- Hit sparks.
- Hero ability effects.
- Capture progress.
- Shrine surge.
- Enemy pressure warning.
- Building construction.
- Rally marker.
- Veterancy/level-up.

Required metadata:

- Effect id.
- Gameplay trigger.
- Duration.
- Max screen coverage.
- Team/faction color variants.
- Reduced-motion behavior.
- Source/license.

### Audio

Needed categories:

- UI clicks.
- Confirmation/error sounds.
- Unit acknowledgements later.
- Combat impacts.
- Building placement/complete.
- Capture and shrine sounds.
- Warning/pressure stings.
- Music loops.
- Ambience by biome.

Required metadata:

- Audio id.
- Source/license.
- Loop or one-shot.
- Loudness target.
- Category bus.
- Reduced-audio behavior.

### Portraits

Needed categories:

- Hero classes.
- Enemy commanders/rivals.
- Campaign contacts.
- Stronghold or faction representatives later.

Required metadata:

- Portrait id.
- Character/faction id.
- Source/license.
- Crop variants.
- Placeholder or production status.

## Browser Prototype Pipeline

### File Naming

Use predictable lowercase kebab-case ids:

- `unit-free-marches-militia-idle.png`
- `unit-ashen-raider-idle.png`
- `building-free-command-hall.png`
- `building-ashen-stronghold.png`
- `terrain-cinderfen-causeway-edge-a.png`
- `ui-command-train-militia.png`
- `vfx-capture-site-progress.png`

Avoid:

- Spaces.
- Ambiguous names such as `new-image-final-final.png`.
- Source names tied to external copyrighted material.

### Folder Shape

Recommended future shape:

```text
public/assets/
  runtime/
    units/
    buildings/
    terrain/
    ui/
    vfx/
    portraits/
    audio/
  reference/
    concepts/
    style-frames/
    scale-sheets/
  manifest/
    assets.json
```

The current `final` and `manual` folders do not need to be reorganized in v0.8. This folder shape is a future target.

### Atlas And Spritesheet Expectations

Future browser prototype sprites should define:

- Frame width/height.
- Origin/anchor.
- Visual height at default camera.
- Animation names.
- Frame rate.
- Loop behavior.
- Direction count.
- Fallback static frame.

Do not introduce a large atlas build step until the current runtime asset count justifies it.

### Scale Metadata

Every production candidate should record:

- `worldRadius` or intended collision radius.
- `visualHeight`.
- `visualWidth`.
- `originX`.
- `originY`.
- `selectionRingWidth`.
- `selectionRingHeight`.
- `healthBarOffsetY`.
- `labelOffsetY`.

These may live in data files later, but v0.8 only documents the requirement.

### License And Source Tracking

Every non-code asset should have a source record:

- Created by project team.
- Created by contractor.
- Generated with approved tool and prompt, if explicitly allowed.
- Licensed asset with license name and URL.
- Public-domain or CC asset with exact attribution.
- Placeholder created internally.

No asset should enter the repo without a trackable source and license status.

### Placeholder Vs Production Tags

Use explicit status labels in future manifest metadata:

- `placeholder`
- `prototype`
- `style-frame`
- `production-candidate`
- `production`
- `deprecated`

Do not label a mixed-style placeholder as production.

## Future Desktop Pipeline

The future desktop-quality version may use high-end 2D, 2.5D, or 3D assets. That decision should wait until the browser game proves the core systems.

### Concept Art

Concept work should establish:

- Faction identity.
- Unit silhouettes.
- Building sets.
- Terrain material palette.
- Capture-site landmarks.
- UI style frame.
- VFX palette.

### 3D Models Or High-Resolution 2D

If 3D:

- Model scale rules.
- Rigging standards.
- Animation clips.
- LOD policy.
- Material naming.
- Collision proxies.
- Engine import settings.

If high-resolution 2D or 2.5D:

- Direction count.
- Normal maps or lighting layers if used.
- Sprite atlas policy.
- Animation frame standards.
- Shadow and ground-contact conventions.

### Animation

Minimum future animation set:

- Idle.
- Move.
- Attack.
- Cast.
- Capture.
- Build/construct.
- Die.
- Rally/acknowledge later if approved.

### Material And VFX

Define:

- Team-color rules.
- Faction material rules.
- Biome material rules.
- Reduced-motion VFX fallback.
- Maximum effect duration and screen coverage.

### Engine Import

Do not choose desktop engine import rules in v0.8. Future decisions should be made after technical prototypes compare 2.5D and 3D risks.

## Legal And IP Safety

Ascendant Realms must remain original.

Rules:

- Do not copy protected art, names, factions, units, buildings, maps, UI, music, lore, icons, terrain, cinematics, or other expression.
- Do not ask for assets "in the style of" a living artist or protected game.
- Do not mimic one source too closely even if names are changed.
- Track licenses for every external asset.
- Prefer original design briefs, mood constraints, and functional requirements.
- Build original faction identity from Ascendant Realms lore and gameplay needs.

## How Codex Should Handle Future Assets

Codex may:

- Write asset briefs.
- Write prompt templates for approved tools.
- Create naming conventions and manifests.
- Add lightweight placeholder metadata.
- Build validation scripts for manifest consistency.
- Add screenshot-based review plans.
- Suggest asset breakdowns by sprint.

Codex should not:

- Invent hidden copyrighted sources.
- Commit large binary assets without permission.
- Require paid APIs.
- Pull unlicensed web images into the repo.
- Treat generated images as production art without source/license metadata.
- Use art planning as a reason to switch engines or rewrite the renderer.

## Recommended First Visual Asset Sprint Later

When the user explicitly approves a visual sprint, start small:

1. Unit scale sheet.
   - Hero, infantry, ranger, caster, brute, commander, small monster.
   - Includes visual height, footprint, selection ring, health bar, and label offsets.

2. Terrain style frame.
   - One Cinderfen terrain board with road, grass, marsh, water, blocked zone, and boundary treatment.

3. Cinderfen map visual mock.
   - One existing Cinderfen battlefield, no new map.
   - Focus on road readability, capture-site salience, and material identity.

4. UI style frame.
   - Resource bar, objective panel, minimap, selected entity panel, command buttons, results header.

5. Asset manifest prototype.
   - Small JSON or TypeScript manifest for current and future assets.
   - Tracks id, path, status, source, license, scale metadata, and owner notes.

## v0.8 Decision

No asset files were created, moved, deleted, renamed, or generated in v0.8. The safest next step is to use this plan together with `docs/ART_DIRECTION_2026_BIBLE.md`, `docs/V08_VISUAL_DEBT_AUDIT.md`, and `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md` before any visual asset sprint.
