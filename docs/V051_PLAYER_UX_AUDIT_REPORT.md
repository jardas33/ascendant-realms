# v0.51 Player UX Audit Report

## Scope

This audit covers the existing Act 1 battle and campaign loop after v0.48-v0.50. It focuses on player-facing clarity only: cursor affordance, command feedback, combat readability, objective density, Results clarity, and tester confidence. No save fields, maps, factions, gameplay systems, runtime art, broad UI redesigns, AI rewrites, pathing rewrites, Patrol, or formations are added.

## Findings

- Attack cursor: hostile hover had a native crosshair, but the canvas did not expose a readable intent label for browser/hosted verification.
- Worker build/resume construction: the command panel described incomplete structures, but hovering an incomplete friendly building with a Worker selected did not expose a distinct build intent.
- Worker repair: repair commands were explicit, but hover intent over damaged friendly buildings reused the default cursor.
- Worker resource-site assignment: captured sites had command copy, but hover intent did not distinguish "assign Worker" from ordinary movement.
- Invalid target feedback: neutral/enemy/full resource-site or full-health friendly building targeting could be clearer without changing command semantics.
- Command disabled reasons: most reasons were already visible in button text, but machine-readable disabled reason state was inconsistent.
- Hero ability readability: cooldown and Mana copy existed; the active reason was not exposed as a stable button attribute for hosted checks.
- Combat status readability: Burn status was labeled and separated from health bars, but the badge was still small during crowded combat.
- Objective and Results density: required first-clear, replay, relic, skill, and optional objective lines were present. The risk is clutter, so this pass should avoid adding long new paragraphs.
- Minimap/world click confidence: existing hosted coverage already protects minimap movement and world-click attack intent. No input semantic change is justified.

## Implemented Direction

- Add a pure cursor-intent rule for attack, build, repair, assign, invalid, and neutral/default states.
- Use native CSS cursors only: `crosshair`, `copy`, `alias`, `not-allowed`, and default.
- Add readable canvas intent labels through existing DOM state (`data-battle-cursor-label` and `title`) without adding art assets.
- Add command-state and disabled-reason attributes to existing command buttons while keeping visible copy short.
- Make the Burn badge slightly larger and higher contrast while preserving existing placement.
- Keep Results and campaign copy largely intact unless required information is missing.

## Deferrals

- Custom cursor art, animated targeting rings, and runtime art-pipeline work.
- Full accessibility pass.
- Large HUD layout redesign.
- New onboarding steps or gameplay systems.
