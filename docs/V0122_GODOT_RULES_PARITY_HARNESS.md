# v0.122 Godot Rules Parity Harness

Status: implemented as a bounded deterministic fixture harness.

The v0.122 harness compares expected fixture outcomes against Godot outputs for both placeholder modes. It is a rules-posture proof for the selected Salto subset, not a claim of full browser/Godot simulation parity.

## Covered Checks

- Entity spawn counts.
- Initial positions.
- Unit ownership.
- Health and damage posture.
- Movement acceptance.
- Fixed target acquisition result.
- Capture-site ownership transition.
- Lume active, severed, and restored transition.
- Results transition.
- Read-only save-fixture acceptance.
- Unknown-ID rejection.
- Same fixture exercised by both 2D and 2.5D placeholder modes.

## Fixed Inputs

- Checkpoint: `v0.122`
- Fixture authority: generated desktop-spike fixture data.
- Parity tier: representative Tier M.
- Seed posture: fixed fixture seed.
- Required `linked_ward`: `0.92`

## Output

The Godot headless test flow writes:

- `desktop-spikes/godot-salto/reports/godot-v0122-adapter-validation.json`
- `desktop-spikes/godot-salto/reports/godot-v0122-parity-report.json`

The repository tool then mirrors the ignored evidence under:

- `artifacts/desktop-spikes/godot-salto/v0122/adapter-validation.json`
- `artifacts/desktop-spikes/godot-salto/v0122/parity-report.json`

## Boundary

The harness intentionally does not validate full browser pathfinding, complete combat semantics, AI planning depth, campaign progression, save mutation, reward mutation, runtime art integration, or full UI parity.
