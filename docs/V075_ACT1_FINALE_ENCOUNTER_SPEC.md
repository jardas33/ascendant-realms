# v0.75 Act 1 Finale Encounter Spec

## Goal

Turn Ashen Outpost into the Act 1 finale using the existing Ashen Outpost map, Captain Malrec rival commander, mission modifiers, enemy doctrine, elite squad, tactical plan, Retinue, battlefield event, and Results systems.

## Finale Node

- Campaign node: `ashen_outpost`.
- Map: `ashen_outpost`.
- Rival commander: `captain_malrec`.
- Mission type: Assault.
- Modifier: Fortified Enemy.
- No new map, faction, art, save schema, loot table, or boss framework.

## Phase Structure

The finale has a maximum of three deterministic battle-local phases.

1. **Secure the Foothold**
   - Player goal: capture the Burned Shrine or another resource foothold.
   - Completion signal: `capture_burned_shrine`, any player site capture, or resource capture telemetry.
   - Intended event: Site Under Threat if a site is held; Hold the Line is a safe fallback.
   - Best plan support: Resource Push.

2. **Break the Fortified Line**
   - Player goal: destroy the enemy Barracks and absorb the outpost counter-pressure.
   - Completion signal: `destroy_enemy_barracks` or the enemy production building being gone.
   - Intended event: Elite Strike when an eligible elite squad exists.
   - Best plan support: Guarded Advance.

3. **Defeat Captain Malrec**
   - Player goal: finish the commander defense and break the Stronghold.
   - Completion signal: Captain Malrec defeated.
   - Intended event: Reinforcement Window if a Ready reserve exists; Aether Surge remains eligibility-gated by existing event rules.
   - Best plan support: Champion Hunt.

## Encounter Rules

- Phases are battle-session-only and deterministic.
- Only one major battlefield event may be active at a time.
- Captain Malrec should not be selected for coordinated attack waves until the final phase opens.
- The existing victory condition remains destroying the enemy Stronghold.
- Captain Malrec defeat remains the milestone commander credit source and drives the existing rival/relic reward flow.
- Replay preserves the finale structure but does not duplicate first-clear, optional objective, rival, relic, or milestone rewards.

## UI Scope

- Use existing HUD objective and battle-status surfaces.
- Show a short phase title and objective.
- Show event rows through the existing battlefield event HUD.
- Show commander alerts through existing floating/status text and minimap pings.
- No new art or large UI.

## Save Compatibility

- No save-version bump.
- No persistent finale-specific field.
- Act 1 completion is derived from existing campaign completion state for `ashen_outpost`.
- Old saves with missing node reward or optional objective state continue using existing campaign normalization.

## Deferrals

- No cinematic sequence.
- No new commander ability tree.
- No permanent Act 2 state beyond existing Chapter 2 unlock rules.
- No unique boss arena, cutscene, or new reward currency.
