# v0.133 Combat Onset Spec

Status: `PASS_COMBAT_ONSET_PROOF`

After the countdown launches the wave, the player-facing slice now:

- Stages a readable four-attacker Ashen lane and a visible defender line for the player-facing review fight.
- Selects the defender squad at wave launch and records `combat_defender_handoff`.
- Preserves defender selection if an empty combat box-select misses the units.
- Lets the visible `Attack` button issue a wave-defense order instead of only attacking the first live target.
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

The `Attack` HUD command has raw and scaled mouse fallbacks scoped to the visible button rectangle while Objective 8 is active. It selects live defenders and issues a wave-defense runtime command that keeps defender pressure active across remaining wave targets, avoiding private shortcuts or direct result mutation. The runtime stores only the active four-attacker wave and review defender IDs for this loop, and non-review combat reserves are moved offstage so maximized windows do not imply an unwinnable larger fight.

The redundant player-shell battle banner was removed so the top playfield is not covered by repeated objective text during combat.
