# v0.8 Prototype Visual Readability Decision

Date: 2026-05-10  
Phase: v0.8 Phase 7 - prototype-safe visual readability tweaks

## Purpose

Phase 7 allowed at most one tiny prototype-safe visual/readability fix if the visual debt and scale audits found a clear, low-risk issue. This document records the decision not to make a runtime visual tweak in v0.8.

## Evidence Reviewed

- `docs/V08_VISUAL_DEBT_AUDIT.md`
- `docs/V08_VISUAL_SCALE_READABILITY_AUDIT.md`
- Current Cinderfen gameplay screenshot evidence from the v0.8 browser preview review
- Entity rendering constants in `BaseEntity`, `Unit`, `Hero`, `Building`, and `CaptureSite`
- Minimap marker rules in `BattleSceneSnapshots` and `MinimapView`
- Current map renderer and Cinderfen map data

## Candidate Tweaks Considered

### Selection ring size or opacity

Potential value:

- Could make selected units/buildings feel less like debug overlays.

Reason not applied:

- Current rings are highly readable and support playtesting.
- Ring debt is stylistic, not a verified usability failure.
- Tuning selection visuals now could require screenshot updates without solving the deeper terrain/sprite mismatch.

### Label spacing

Potential value:

- Could reduce battlefield text crowding.

Reason not applied:

- Labels currently carry essential prototype identity.
- Moving labels globally risks overlap with health bars, sprites, or selection panels on crowded scenes.
- The right fix is future silhouette and UI hierarchy work, not a blind offset tweak.

### Health bar offset

Potential value:

- Could slightly improve tall-sprite readability.

Reason not applied:

- No current evidence shows health bars hiding critical unit or building art.
- Bar offsets are already differentiated for hero, unit, and building layouts.

### Unit or building scale constants

Potential value:

- Could make some sprites feel more proportionate.

Reason not applied:

- Runtime scaling is only a partial solution because source assets are stylistically inconsistent.
- Changing unit radii or building sizes would affect collision, pathfinding, placement, capture, targeting, minimap markers, and selection.
- Changing sprite-only scale without source art standards may make some assets better and others worse.

### Capture-site icon or ring tuning

Potential value:

- Could help Cinder Shrine salience.

Reason not applied:

- Capture sites are currently readable and pressure/objective flows depend on that clarity.
- Cinder Shrine salience remains a human-play watchpoint, but current evidence does not prove a safe global icon/ring change.
- The long-term fix is landmark art, not ring-size guessing.

### Minimap contrast or marker scale

Potential value:

- Could improve marker scan speed.

Reason not applied:

- The minimap is currently readable and covered by tests.
- Marker hierarchy is already clear: sites/buildings outrank units.
- No current evidence shows minimap readability blocking play.

### Terrain overlay opacity

Potential value:

- Could reduce the paint-like look.

Reason not applied:

- Opacity changes would not create a real terrain material language.
- Roads, water, blocked zones, and capture grounds need an authored art direction, not a single opacity shift.

## Decision

No code or CSS change was applied in Phase 7.

The current prototype readability is functional. The visual problems are real, but they are structural and mostly require art direction, asset pipeline, source-art consistency, and future terrain/capture-site production work. A tiny constant tweak would create churn without enough evidence that it improves player comprehension.

## Validation Plan

Even with no runtime visual change, Phase 7 will run the requested visual/readability verification gate:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run test:e2e:smoke`
- `npm run test:e2e:layout`
- `git diff --check`

## Future Trigger For A Tiny Visual Fix

A future tiny readability fix is justified only if one of these appears in browser review or human feedback:

- A selected unit/building cannot be identified because the ring or bar is hidden.
- Labels overlap badly enough to block a normal command decision.
- Cinder Shrine or another capture site is missed despite objective copy and camera framing.
- Minimap markers cannot be distinguished during normal play.
- A specific HUD surface blocks important battle information on supported viewports.

Until then, v0.8 should preserve behavior and invest in visual foundation documents.
