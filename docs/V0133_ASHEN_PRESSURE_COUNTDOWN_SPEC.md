# v0.133 Ashen Pressure Countdown Spec

Status: `PASS_PRESSURE_COUNTDOWN_PROOF`

After the Militia spawns, the player-facing slice now:

- Advances to `Objective 7: Prepare for Ashen pressure`.
- Starts a visible five-second Ashen-pressure countdown.
- Records countdown ticks.
- Launches the Ashen wave automatically when the countdown reaches zero.
- Records `waveTriggerSource: countdown`.

Verified captures:

- `12_ashen_incoming_countdown`
- `13_road_entry_pulse`
- `14_wave_launched`

This closes the v0.132 manual-test blocker where `Objective 5: Prepare for Ashen pressure` appeared without countdown, guidance, wave launch, or enemy movement.
