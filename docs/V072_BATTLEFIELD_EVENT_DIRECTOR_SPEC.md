# V072 Battlefield Event Director Spec

## Goal

Add a small battle-session event director that makes eligible campaign battles react to mission type, enemy doctrine, modifiers, tactical plan, Retinue state, and resource-site state without random chaos or save migration.

## Event Pool

- Site Under Threat: Raider/control-friendly pressure against a valuable player site.
- Hold the Line: timed Command Hall or site defense window for Fortress/Warband pressure.
- Elite Strike: readable elite-squad push in battles that already allow elite squads.
- Reinforcement Window: reminder/opportunity to use the once-per-battle Retinue call when a Ready reserve exists.
- Aether Surge: short ability-readiness window when Aether Surge or Champion Hunt support is active.

## Director Rules

- Battle-session only; no persistent event state.
- Disabled for Tutorial/no-reward routes.
- Maximum one active major event at a time.
- Cooldown-gated between events.
- Conservative battle cap to avoid event spam.
- Doctrine, mission type, modifiers, tactical plan, elite presence, and Retinue availability influence weighting.
- If no valid event is available, the director stays quiet.

## Runtime Effects

- Events can provide a small battle-local resource or mana opportunity.
- Events can nudge existing pressure timing but must not replace AI doctrine or rewrite pathing.
- Events must be readable, counterable, and modest.
- Tactical plans can help matching events but never auto-win them.

## Save Compatibility

- No save-version bump.
- Event ids, completion, failure, and telemetry live only in battle stats for Results.
- Existing saves load unchanged.

## Deferrals

- Persistent campaign event history.
- New art, VFX, or map-specific event scripting.
- Randomized narrative event decks.
- Broad enemy AI adaptation.
