# V0160 01 Godot Player-Slice Worker Billboard Opt-In Integration

Status: future prompt/contract only. Do not execute v0.160 in v0.159.

## Future Bounded Goal

Implement exactly one Godot player-facing Salto Worker billboard opt-in experiment using the already-selected private Worker derivative.

Authorized candidate:

- Slot id: `worker_billboard_static_v0147`.
- Derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Required SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.

## Required Launcher Contract

Add exactly one new opt-in launcher:

```text
GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat
```

Preserve these default launchers unchanged:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`.
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.

The Worker art experiment must be off by default. The default Salto player slice must continue to use the procedural Worker fallback.

## Required Runtime Contract

Future v0.160 must:

- Load the Worker candidate only when the opt-in launcher or explicit opt-in flag is active.
- Verify the exact SHA-256 before using the local candidate.
- Fail closed to the procedural Worker fallback if the file is missing, the hash is wrong, metadata is invalid, or loading fails.
- Cache textures/materials so steady-state frames do not recreate them.
- Report opt-in, hash, fallback, and load state in diagnostic evidence.
- Preserve normal Worker selection, assignment, mine-work, and Barracks-repair behavior.

## Forbidden Scope

Future v0.160 must not:

- Generate images.
- Add a second slot.
- Import Aster, Barracks, Militia, Ashen Raider, or v0.156 archived Ashen evidence.
- Add animations or directional variants.
- Wire anything into the browser runtime.
- Mutate production art-slot manifests.
- Package ignored local art into ordinary builds.
- Change saves, stable IDs, gameplay, AI, objectives, maps, input, balance, campaign state, or browser behavior.
- Change default launcher behavior.
- Claim final runtime-art approval, final Worker art approval, final Godot choice, or full-port approval.
- Begin v0.161.

## Acceptance Gates

Future v0.160 must include:

- Default-launcher proof: procedural Worker remains the default.
- Opt-in-launcher proof: selected Worker candidate appears only when opted in.
- Missing-file or hash-mismatch proof: procedural Worker fallback appears and diagnostics explain why.
- Visual captures: Worker selection ring, assignment, mine work, Barracks-repair proximity, group crowding, edge treatment, normal camera, and zoomed camera.
- Performance proof against procedural fallback.
- Boundary scans: no browser wiring, no second slot, no production manifest mutation, no save/stable-ID mutation, no package leakage, no default launcher mutation.
- Emmanuel review guide and implementation report.

## Required Stop

Stop for Emmanuel review after the one-slot Worker opt-in proof. Do not broaden the experiment in v0.160.
