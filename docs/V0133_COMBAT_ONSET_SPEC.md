# v0.133 Combat Onset Spec

Status: `PASS_COMBAT_ONSET_PROOF`

After the countdown launches the wave, the player-facing slice now:

- Moves Ashen enemies toward the defended area through normal runtime movement.
- Requires normal player-facing attack input before friendly pressure targeting is seeded.
- Supports both box-select plus right-click Ashen target input and the visible `Attack` HUD command during Objective 8.
- Records combat onset only after runtime combat ticks increase following attack input.
- Defeats the wave through normal combat simulation.

Verified captures:

- `15_enemy_movement`
- `16_combat_onset`
- `17_enemy_remaining_counter`
- `18_wave_defeated`

The proof does not call `defeat_pressure_wave()` or any fixture-only defeat helper.

The `Attack` HUD command has a raw mouse fallback scoped to the visible button rectangle while Objective 8 is active. It selects live defenders and issues the same runtime attack command used by the right-click path, avoiding private shortcuts or direct result mutation.
