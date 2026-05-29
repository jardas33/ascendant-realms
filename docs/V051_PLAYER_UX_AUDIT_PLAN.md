# v0.51 Player UX Audit Plan

## Goal

Audit the current player-facing battle and Act 1 campaign loop for command clarity, cursor affordance, combat readability, objective density, and Results confidence. This checkpoint is a polish pass over existing systems only. It does not add maps, factions, gameplay systems, save fields, runtime art assets, broad UI redesigns, AI rewrites, pathing rewrites, global balance changes, Patrol, formations, or canvas/world force-click fallbacks.

## Audit Surfaces

- Battle cursor intent for attack, repair, construction, site assignment, invalid target, and neutral movement.
- Selected unit, building, resource-site, and enemy hover clarity.
- Worker command feedback for construction, repair, site assignment, and explicit attack.
- Hero ability button states for cooldown, Mana, disabled reasons, and readable cast summaries.
- Building production and research disabled reasons.
- Resource-site upgrade, worker slot, ownership, and assignment reasons.
- Damage numbers, Burn/status chips, attacking/idle state, and enemy building HP loss readability.
- Campaign briefing, active objective, optional objective, replay, relic, skill, and Results copy density.
- Minimap and world-click confidence without changing input semantics.

## Evidence Sources

- Pure rule and view-model tests for cursor state, command disabled reasons, objective copy, Results copy, and package validation.
- Existing hosted Playwright flows for Worker commands, attack intent, hero abilities, and Results clarity.
- `visual:qa` screenshots for combat/HUD readability after CSS or UI copy changes.
- Deterministic Act 1 telemetry as context only; it does not stand in for human feel.

## Change Rules

- Prefer native CSS cursors, existing DOM state, and short status copy over custom art.
- Keep command copy practical and compact.
- Do not introduce new persistent state or migrate saves.
- Do not weaken test assertions or use force clicks / DOM fallbacks for canvas and world interactions.
- If a requested affordance needs new cursor art, document it as future work and provide a text/native-cursor fallback.

## Deferrals

- Custom cursor sprites or a runtime art pipeline.
- Large HUD layout redesign.
- New combat VFX, new animations, or balance changes.
- New tutorial steps, quest systems, maps, units, or factions.
- Full accessibility pass beyond the scoped readability and affordance improvements.
