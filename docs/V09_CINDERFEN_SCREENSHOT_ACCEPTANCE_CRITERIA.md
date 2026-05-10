# v0.9 Cinderfen Screenshot Acceptance Criteria

Date: 2026-05-10  
Status: future acceptance criteria only. No screenshot baselines, generated art, imported assets, runtime replacement, renderer change, or pixel-perfect tests are included.

## Purpose

This document defines what future Cinderfen visuals must pass before runtime integration. It is meant for later generated, commissioned, manually created, or otherwise obtained visual candidates after source/license metadata exists.

The current v0.9 sprint remains docs/specs/prompts only.

## Global Rules

- No pixel-perfect diffing yet.
- Human screenshot review is required.
- Source/license metadata is required before commit.
- Manifest validation is required before commit.
- Production approval requires evidence: source/license proof, reviewer notes, screenshot QA results, and conservative manifest metadata.
- Unknown-source assets remain prototype-only and not production-safe.
- Screenshot artifacts stay ignored unless a future goal explicitly creates a reviewed report.
- Automated checks can confirm app load, zero console errors, and content validation; they cannot approve art quality alone.

## Acceptance 1 - Main Battlefield Readability

Pass condition:

- The player can understand active units, selected units, enemy units, routes, capture sites, minimap, objective panel, resources, and battle status from the first desktop battle view without hunting for labels.

Fail condition:

- New visuals make the battlefield feel denser but not clearer, hide unit clusters, obscure objective/status copy, or require labels to compensate for newly noisy terrain.

Screenshot target:

- `cinderfen-crossing-desktop.png`
- `cinderfen-watch-desktop.png`

Reviewer notes:

- Check default camera distance first.
- Review both Cinderfen Crossing and Cinderfen Watch because shrine and road-pressure contexts differ.

Automated/non-automated status:

- Automated: app load, console error capture, existing e2e flow.
- Non-automated: visual clarity and art-direction approval.

## Acceptance 2 - Cinderfen Road Readability

Pass condition:

- Main causeways and pressure-relevant routes read immediately as passable constructed lanes. Side routes are visible but secondary.

Fail condition:

- Roads look like decorative paint, merge into ash mud, imply incorrect pathing, or become so detailed that units/projectiles are hard to read.

Screenshot target:

- `cinderfen-crossing-desktop.png`
- `cinderfen-crossing-tablet.png`
- `cinderfen-watch-pressure-desktop.png`

Reviewer notes:

- The first visual read should be road direction, not terrain ornament.
- Check tablet because route and HUD density collide there fastest.

Automated/non-automated status:

- Automated: screenshot capture, no console errors.
- Non-automated: route readability and material identity.

## Acceptance 3 - Cinder Shrine Visibility

Pass condition:

- The Cinder Shrine is recognizable as a landmark before reading its label, while the capture ring still clearly communicates gameplay boundary.

Fail condition:

- Shrine remains a small icon inside a large ring, disappears under fog/units, or becomes so large that it reads like a building.

Screenshot target:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-crossing-desktop.png`

Reviewer notes:

- Compare recognition with and without relying on objective text.
- Ring can remain visible; the test is whether the landmark now contributes identity.

Automated/non-automated status:

- Automated: current visual QA capture target.
- Non-automated: landmark recognition.

## Acceptance 4 - Shrine Ownership State Clarity

Pass condition:

- Neutral, player-owned, enemy-owned, active surge, and depleted/claimed states remain readable from the same base silhouette and do not fight the gameplay ring colors.

Fail condition:

- State art changes the footprint too much, hides progress/ownership rings, looks like a different object, or makes active surge/ownership color ambiguous.

Screenshot target:

- `cinderfen-crossing-shrine-desktop.png`
- `cinderfen-crossing-pressure-desktop.png`
- future before/after ownership-state screenshots if integrated.

Reviewer notes:

- State accents should support current overlays, not replace them prematurely.
- Active surge must not bury pressure warning or objective feedback.

Automated/non-automated status:

- Automated: e2e can validate shrine status copy and resource effect.
- Non-automated: ownership/state visual clarity.

## Acceptance 5 - Unit Silhouette Clarity Over New Terrain

Pass condition:

- Hero, infantry, ranged units, casters, brutes, commander/enemy hero, labels, health bars, projectiles, and selection rings stay readable over roads, ash mud, reeds, water edges, fog, and shrine ground.

Fail condition:

- Terrain detail or lighting causes units to blend into the background, makes projectiles look like terrain highlights, or makes rings/bars hard to see.

Screenshot target:

- `tutorial-desktop.png`
- `tutorial-mobile.png`
- `cinderfen-crossing-tablet.png`
- `cinderfen-watch-pressure-desktop.png`

Reviewer notes:

- Use tutorial as a non-Cinderfen comparison.
- Check clustered units, selected units, and active combat.

Automated/non-automated status:

- Automated: existing unit tests/e2e prove behavior, not silhouette quality.
- Non-automated: silhouette clarity.

## Acceptance 6 - Enemy Base Readability

Pass condition:

- Enemy stronghold reads as the main target, barracks reads as production, tower/threat structures read as threats only where gameplay supports that, and Ashen architecture remains distinct from player structures.

Fail condition:

- Enemy buildings look like props, capture sites, neutral camps, player buildings, or new mechanics; health bars/labels become hard to read.

Screenshot target:

- `cinderfen-watch-desktop.png`
- `cinderfen-watch-pressure-desktop.png`
- `cinderfen-crossing-desktop.png`

Reviewer notes:

- Better enemy architecture can shift perceived difficulty, so review defeat/victory contexts if threat presentation changes.

Automated/non-automated status:

- Automated: e2e can prove battles still launch and finish.
- Non-automated: architectural role clarity.

## Acceptance 7 - Minimap Consistency

Pass condition:

- Minimap markers and terrain/category colors still align with the main battlefield: roads, capture sites, buildings, enemy pressure, fog, and unit hierarchy remain easy to scan.

Fail condition:

- Main view materials and minimap colors contradict each other, capture sites/buildings lose priority, or fog state becomes ambiguous.

Screenshot target:

- all Cinderfen battle screenshots,
- `tutorial-desktop.png` for baseline minimap comparison.

Reviewer notes:

- Minimap should remain diagrammatic unless a separate UI pass approves a new style.

Automated/non-automated status:

- Automated: minimap tests and screenshot capture.
- Non-automated: visual consistency and marker hierarchy.

## Acceptance 8 - Mobile / Tablet Battle HUD Compatibility

Pass condition:

- On tablet and mobile battle views, new visuals do not worsen objective panel, minimap, selected-unit panel, command buttons, resource chips, labels, health bars, or tutorial overlay readability.

Fail condition:

- Terrain or landmark art becomes hidden by HUD, creates visual clutter under panels, or makes the already-dense mobile battle view harder to understand.

Screenshot target:

- `cinderfen-crossing-tablet.png`
- `tutorial-mobile.png`
- future mobile Cinderfen capture if a runtime visual change affects battle density.

Reviewer notes:

- Mobile battle is already dense; "not worse" is the minimum bar.

Automated/non-automated status:

- Automated: visual QA capture and layout/e2e coverage where available.
- Non-automated: density judgment.

## Acceptance 9 - Results / Inventory / Gallery Visual Consistency If Affected

Pass condition:

- If future visual work touches shared UI assets, backgrounds, icons, portraits, or asset-gallery surfaces, Results, Hero Inventory, and Asset Gallery remain readable and consistent.

Fail condition:

- New art or metadata changes cause dense screens to clip important copy, hide buttons, lose image-load status, or conflict with source/license review workflows.

Screenshot target:

- `results-victory-desktop.png`
- `results-defeat-desktop.png`
- `hero-inventory-desktop.png`
- `asset-gallery-desktop.png`

Reviewer notes:

- Most Cinderfen terrain/shrine changes should not affect these screens. If they do, expand scope deliberately.

Automated/non-automated status:

- Automated: e2e/layout checks and asset-gallery load status.
- Non-automated: visual consistency.

## Acceptance 10 - Performance / Bundle Impact

Pass condition:

- Runtime asset additions, if later approved, are small enough for the browser prototype, do not create new console errors, do not noticeably slow battle load, and do not worsen the known vendor chunk warning into a new app-code issue.

Fail condition:

- Large binaries are committed without approval, runtime load becomes unreliable, texture preload fails, visual QA logs errors, or production build regresses.

Screenshot target:

- all visual QA screenshots if runtime assets are added,
- build output and preview smoke notes.

Reviewer notes:

- v0.9 adds no assets. This acceptance item applies to later visual replacement work.

Automated/non-automated status:

- Automated: `npm run build`, visual QA console capture, preview smoke.
- Non-automated: asset-size judgment and production-readiness review.

## Acceptance 11 - Source / License Metadata Completeness

Pass condition:

- Every future asset or reference has source/tool/artist/vendor, prompt/source notes, license terms, reviewer/date, `allowedInProduction`, `needsReview`, and review status recorded conservatively.

Fail condition:

- Asset has unknown or ambiguous source but is marked production-safe, runtime, final, or approved without proof.

Screenshot target:

- not primarily visual; source/license docs and manifest entries are the review target.

Reviewer notes:

- Metadata completeness is a hard gate before commit, not a cleanup task.

Automated/non-automated status:

- Automated: `npm run validate:content` for manifest rules.
- Non-automated: source/license evidence quality.

## Acceptance 12 - Screenshot QA Coverage

Pass condition:

- Future runtime visual replacements include before/after screenshot review covering the affected viewports and surfaces, with `visual-qa/latest/index.md` used as the capture index when applicable.

Fail condition:

- Runtime art changes land with no screenshot QA, no human review notes, or only a narrow view that misses shrine, pressure, tablet, mobile, minimap, or affected UI contexts.

Screenshot target:

- affected targets from the current 18-screenshot set,
- new focused targets only if genuinely needed.

Reviewer notes:

- Do not create brittle pixel-perfect baseline tests.
- A screenshot report is enough when it names what passed, what failed, and what remains risky.

Automated/non-automated status:

- Automated: `npm run visual:qa` capture and console-error recording.
- Non-automated: human acceptance decision.

## Required Future Gate Before Runtime Integration

At minimum, a later runtime visual replacement should run:

- `npm test`
- `npm run build`
- `npm run validate:content`
- `npm run visual:qa`
- `git diff --check`

Broader replacements should also run the full release gate and preview smoke described in `LLM_GAME_HANDOFF.md`.

## v0.9 Decision

These criteria define the future acceptance bar. They do not create screenshot baselines, generated assets, imported assets, manifest runtime entries, renderer changes, gameplay changes, or production approval.
