# v0.8 Visual Debt Audit

Date: 2026-05-10  
Scope: current browser prototype visual state, with emphasis on Cinderfen battle readability and future 2026 art-direction needs.

## Purpose

This audit records the current visual debt before any art overhaul. It is intentionally observational: no gameplay, map, unit, faction, asset, renderer, UI redesign, desktop-port, or 2026-graphics implementation is included in this phase.

The current game is functionally readable enough for a browser mechanics prototype, but it does not yet express the long-term visual target for Ascendant Realms. The main issue is not one broken sprite or one bad color. The issue is that terrain, units, buildings, capture sites, and UI come from different visual languages.

## Evidence Used

- Current live gameplay screenshot from the Cinderfen battlefield review.
- `src/game/battle/BattleSceneMapRenderer.ts`
- `src/game/entities/BaseEntity.ts`
- `src/game/entities/Unit.ts`
- `src/game/entities/Building.ts`
- `src/game/ui/MinimapView.ts`
- `src/game/ui/hudPanels/MinimapPanel.ts`
- `src/game/styles/*.css`
- `src/game/data/maps/cinderfenCauseway.ts`
- `src/game/data/maps/cinderfenWatchpost.ts`
- Runtime/final/manual assets under `public/assets/`

## Terrain And Map Art

### Roads

Current roads are wide procedural strokes with dark underlay, brown body, and a small highlight. They are readable as movement lanes, which is good for a prototype, but they look like painted guide strokes rather than a grounded road material.

Debt:

- Road edges do not imply mud, stone, packed ash, causeway boards, or terrain wear.
- Road width is readable but visually soft and artificial.
- Branching paths are tactically understandable, but the art does not communicate age, construction, danger, or faction presence.

Acceptable now:

- The player can identify main routes and side paths quickly.
- The road system supports existing objectives and pressure review.

Unacceptable before a desktop-quality game:

- Main travel routes cannot remain simple translucent strokes.
- Cinderfen roads need a material identity: blackened causeway, wet ash, broken stone, or another original terrain kit.

### Water And Swamp

Current water/swamp areas are large filled ellipses with outlines, highlights, and simple ripple strokes. They read as blocked or special terrain in broad strokes, but not as a coherent wetland material.

Debt:

- Water shapes are blob-like and disconnected from terrain flow.
- Swamp edges do not blend into mud, reeds, or banks.
- Ripple marks read as annotation rather than natural surface detail.

Acceptable now:

- Water zones do not usually confuse the player about lanes.
- The dark palette supports Cinderfen mood.

Unacceptable before a desktop-quality game:

- Wetlands need authored material transitions, prop language, and stronger silhouette separation from passable ground.

### Fog

Fog and visibility systems are mechanically useful and supported by e2e coverage. Visually, fog is functional rather than atmospheric.

Debt:

- Fog does not yet feel like Cinderfen-specific mist, ash, smoke, or magical occlusion.
- Fog masks are utilitarian and not integrated with terrain lighting.

Acceptable now:

- Fog supports tactical information hiding without requiring a new visual pipeline.

Unacceptable before a desktop-quality game:

- Fog should eventually become part of the mood and readability stack, not only a gameplay mask.

### Capture Sites

Capture sites use large circular ground markers plus icons and labels. They are very readable but icon-like.

Debt:

- Capture rings are visually dominant compared with the terrain underneath.
- Site identity is mostly UI-symbolic rather than environmental.
- Cinder Shrine salience remains a watchpoint because the ring is clear, but the shrine itself is not yet a strong object.

Acceptable now:

- Players can identify sites and ownership.
- Pressure and objective tests can reliably target the sites.

Unacceptable before a desktop-quality game:

- Important sites should have original shrine/ruin/flag/object silhouettes, not only rings and labels.

### Neutral Camps

Neutral camp markers are readable through map symbols and labels, but they do not yet look like lived-in tactical locations.

Debt:

- Camps are more marker than environment.
- They do not convey creature type, risk, or reward visually.

Acceptable now:

- Camps are not the main v0.8 focus and remain readable enough for prototype flow.

Unacceptable before a desktop-quality game:

- Camps need environmental composition, props, and faction-neutral identity.

### Player And Enemy Bases

Player and enemy base areas use procedural build zones plus building sprites. They work mechanically, but ground contact and scale are only approximate.

Debt:

- Build zones use rectangle overlays that read as debug/planning UI.
- Building placement does not strongly imply foundations, paths, or settlement layout.
- Enemy bases do not yet carry a distinct original architectural language.

Acceptable now:

- Command Hall and enemy base positions are readable.
- Buildable zones support current placement and validation.

Unacceptable before a desktop-quality game:

- Bases need coherent settlement silhouettes, terrain dressing, faction architecture, and clear production structure hierarchy.

### Map Boundaries

Map boundaries use simple strokes and terrain-fill edges. They are serviceable, but not spatially convincing.

Debt:

- Edges do not yet imply cliffs, dense swamp, ruins, palisades, fog walls, or believable blockers.
- Boundary treatment is not consistently tied to map identity.

Acceptable now:

- Boundaries are clear enough for current camera and pathing.

Unacceptable before a desktop-quality game:

- Every battlefield needs art-directed boundaries that explain why units cannot leave.

## Unit Visuals

### Scale Consistency

Current unit scale is driven by runtime radius and target sprite height. Heroes are intentionally larger than common units, which helps selection and identity. However, sprite source style, proportions, and ground contact vary enough that the army can look assembled from mismatched placeholders.

Debt:

- Hero, militia, ranger, and enemy silhouettes do not share a strict style sheet.
- Runtime scaling makes the units usable, but cannot fix inconsistent source proportions.
- Some sprites read like high-detail cutouts against simple procedural terrain.

Acceptable now:

- The player can select units, read health, and distinguish hero from army units.

Unacceptable before a desktop-quality game:

- Units need a shared scale bible, pose language, material palette, animation standard, and ground-shadow convention.

### Hero, Militia, Ranger Readability

Hero readability is strong because the hero is larger and labeled. Militia and ranger readability is adequate through labels, bars, and selection rings rather than through pure silhouette.

Debt:

- Unit roles rely too much on text labels and HUD selection panels.
- Militia and ranger need stronger weapon/pose silhouettes.

Acceptable now:

- The labels and health bars carry the role-reading burden in a prototype.

Unacceptable before a desktop-quality game:

- A player should be able to read unit role primarily from silhouette, movement, weapon shape, and animation.

### Enemy Silhouettes

Enemy units are readable as hostile through color, labels, health bars, and faction positioning. The silhouettes themselves are not yet an original, coherent enemy identity.

Debt:

- Hostility is mostly UI/color-coded.
- Enemy visual identity is not yet strong enough for faction memory.

Acceptable now:

- Enemy identification is sufficient for battles and automated tests.

Unacceptable before a desktop-quality game:

- Enemy forces need original silhouettes, armor language, banners, VFX, and architectural connection to their bases.

### Selection Circles

Selection rings are readable and relatively elegant for the prototype. They sit underneath entities and avoid a full UI redesign.

Debt:

- Rings remain generic and can feel like overlay UI rather than part of the world.
- Ring width/opacity may need future tuning once real art arrives.

Acceptable now:

- Selection clarity is more important than visual subtlety.
- Current rings help avoid misclick confusion.

Unacceptable before a desktop-quality game:

- Rings should eventually match the final UI/VFX language and scale consistently across unit classes.

### Health Bars

Health bars are functional and clear. Offsets are generally reasonable, though they contribute to battlefield text density.

Debt:

- Bars are UI-heavy and not stylized to the fantasy frame.
- They compete with labels in clusters.

Acceptable now:

- Bars are essential for prototype combat readability.

Unacceptable before a desktop-quality game:

- Bars need clearer hierarchy, optional decluttering, and final UI styling.

### Labels

Labels are highly useful for testing and prototype orientation. They are also a major visual-debt marker because they make the battlefield feel more like a debug board.

Debt:

- Labels carry too much identity burden.
- Dense label clusters reduce the sense of embodied units.

Acceptable now:

- Labels help human review, e2e assertions, screenshots, and quick prototype comprehension.

Unacceptable before a desktop-quality game:

- Labels should be optional, contextual, or reduced once silhouettes and UI panels can carry identity.

## Building Visuals

### Command Hall

The Command Hall is strongly visible and appropriately important, but its scale and ground contact remain prototype-stylized.

Debt:

- The building reads as a placed sprite more than an anchored structure.
- It does not yet have authored surroundings, foundation, flags, paths, or faction identity.

Acceptable now:

- It is unmistakable as the player base anchor.

Unacceptable before a desktop-quality game:

- The main base needs a production-quality silhouette, grounded foundation, destruction state, and architectural identity.

### Barracks And Production Structures

Production structures benefit from clear selection, labels, and health bars. Their visual identity is still driven more by sprite/icon recognition than by a broader architectural set.

Debt:

- Structure family relationships are not visually systematized.
- Construction state and finished state remain functional rather than expressive.

Acceptable now:

- Players can identify and use production structures.

Unacceptable before a desktop-quality game:

- Production structures need an authored building kit, construction VFX, scale consistency, and clear faction language.

### Enemy Structures

Enemy structures are tinted and positioned to read as hostile. They do not yet carry enough original identity.

Debt:

- Enemy structure identity is mostly color/tint and location.
- Enemy base language does not yet communicate commander personality or faction culture.

Acceptable now:

- Enemy base and target readability is sufficient for prototype combat.

Unacceptable before a desktop-quality game:

- Enemy structures need original form language, materials, banners, and readable threat hierarchy.

### Capture-Site Icons

Capture-site icons are useful but overly symbolic. They work as UI, not as environmental landmarks.

Debt:

- Icons and circles dominate the site identity.
- Landmarks are not memorable enough without labels.

Acceptable now:

- They keep objective flow clear.

Unacceptable before a desktop-quality game:

- Capture sites need distinct environmental models/sprites that remain readable without relying on giant rings.

## UI Visuals

### Resource Bar

The resource bar is readable and compact. It serves the prototype well.

Debt:

- Visual styling is still generic fantasy UI.
- Icon, typography, and spacing language are not yet part of a final system.

Acceptable now:

- Resource information is easy to scan.

Unacceptable before a desktop-quality game:

- Economy and resource UI needs a polished, scalable visual system.

### Objective Panel

The objective panel is highly useful and supports tutorial, pressure, and campaign clarity.

Debt:

- It is text-heavy.
- It can feel like mission-debug output rather than an immersive command interface.

Acceptable now:

- Objective clarity matters more than final art treatment.

Unacceptable before a desktop-quality game:

- Objectives need clearer information hierarchy, iconography, and final surface styling.

### Selected Unit Panel

The selected unit panel is functionally valuable but visually heavy on the playfield.

Debt:

- It occupies a large right-bottom area and can visually crowd the battlefield.
- It is more operational than cinematic or tactile.

Acceptable now:

- It exposes stats, ranks, commands, and prototype systems clearly.

Unacceptable before a desktop-quality game:

- Selection UI needs a more polished frame, better information hierarchy, and stronger integration with command buttons.

### Minimap

The minimap is clear and testable. It reads tactically, not artistically.

Debt:

- It is diagrammatic rather than a miniature art representation.
- Marker language is basic and not fully integrated with final UI direction.

Acceptable now:

- The minimap does its job.

Unacceptable before a desktop-quality game:

- Minimap materials, marker hierarchy, camera rectangle, fog, and faction colors need a coherent final pass.

### Battle Status Banner

The battle status banner is valuable, especially after v0.7.1 pressure priority work.

Debt:

- Status feedback is mostly text treatment.
- It is readable but not yet emotionally expressive.

Acceptable now:

- It protects player comprehension for pressure warnings and objective feedback.

Unacceptable before a desktop-quality game:

- Important battlefield events need stronger audio/visual feedback, while still avoiding noise.

### Menus And Buttons

Menus and buttons are functional and theme-adjacent. They are not yet a disciplined UI art system.

Debt:

- Surfaces, borders, buttons, and text treatments vary by screen.
- The current look suggests fantasy, but not an original premium identity.

Acceptable now:

- Menus are usable, testable, and consistent enough for prototype development.

Unacceptable before a desktop-quality game:

- UI needs a complete style frame with typography, spacing, states, command iconography, and accessibility targets.

## Style Mismatch

The largest visual problem is mismatch.

Current mismatch examples:

- Procedural painterly terrain vs high-detail sprite cutouts.
- Large symbolic capture rings vs rough environmental landmarks.
- Runtime-scaled units/buildings vs inconsistent source proportions.
- Functional labels/bars vs a desired immersive fantasy battlefield.
- Generic fantasy UI surfaces vs an original Ascendant Realms identity.

This mismatch is acceptable while the browser prototype proves systems, but it is not acceptable for the long-term 2026 desktop-quality goal.

## Acceptable For The Browser Prototype

The following are acceptable in the near term:

- Procedural terrain that keeps lanes and blocked zones readable.
- Text labels for units, buildings, sites, and objectives.
- Functional health bars and selection rings.
- Simple minimap markers.
- Symbolic capture-site rings.
- Placeholder or mixed-style sprites, as long as they do not block gameplay review.
- Known Phaser vendor warning and current app chunk size.
- No new art assets while technical and gameplay risk remains high.

## Unacceptable Before A Desktop-Quality Game

Before a future desktop-quality RTS/RPG, the following must be replaced or heavily upgraded:

- Paint-like roads and blob terrain.
- Capture sites that are mostly giant UI rings.
- Units that rely on labels instead of silhouettes.
- Buildings without coherent faction architecture or ground contact.
- Enemy identity carried mostly by tint and labels.
- UI surfaces that feel assembled screen-by-screen rather than governed by one system.
- Terrain, unit, building, and UI assets created without a scale/style bible.
- Any art direction that copies protected names, factions, units, terrain, UI, music, lore, maps, or other expression from existing games.

## Improvements Possible Without New Assets

Small safe future improvements could include:

- Selection ring opacity/scale tuning.
- Health bar and label offset tuning.
- Minimap marker contrast tuning.
- Objective/status text contrast and duration tuning.
- Capture-site label consistency.
- Terrain overlay opacity adjustments.
- CSS spacing and responsive readability cleanup.

These should be treated as readability fixes, not visual modernization.

## Improvements Requiring A Real Asset Pipeline

The following need a real asset pipeline:

- Terrain tiles or material kits.
- Road/causeway edge pieces.
- Cinderfen reeds, pools, ruins, ash, embers, and fog props.
- Unit style sheets with consistent scale, pose, and animation.
- Building kit with construction/ruin/damage states.
- Capture-site landmark art.
- Enemy commander/faction silhouette language.
- Final UI frames, buttons, icons, portraits, and command glyphs.
- VFX for capture, pressure warnings, attacks, shrine effects, and hero abilities.
- Audio and music direction.

## Work That Must Wait

The following should wait until the visual pipeline direction is chosen:

- Desktop packaging.
- Engine switching.
- 3D rewrite.
- 2.5D camera and lighting implementation.
- Production asset import rules.
- Large binary art commits.
- Full UI redesign.
- Large renderer changes.
- Shader/VFX system.
- New animation system.
- Full Cinderfen terrain rework.

## v0.8 Decision

No visual code change is justified by this audit alone. The current prototype has serious visual debt, but the debt is structural and pipeline-level. A tiny readability tweak may still be considered in Phase 7 after the scale audit, but the safest v0.8 outcome is to document the target, define scale/readability rules, and avoid pretending that small constants can solve an art-direction problem.
