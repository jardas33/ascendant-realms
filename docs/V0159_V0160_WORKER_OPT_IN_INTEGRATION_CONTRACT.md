# V0159 V0160 Worker Opt-In Integration Contract

Status: future implementation contract only. v0.159 does not execute this contract and does not begin v0.160.

## Future v0.160 Scope

v0.160 may integrate exactly one local hybrid-art Worker billboard candidate into the Godot player-facing Salto review slice as an opt-in experiment.

The only authorized slot for v0.160 is:

- Slot id: `worker_billboard_static_v0147`.
- Selected derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Required SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Source family: existing private Worker billboard repair evidence from v0.148.
- Asset posture: local ignored source, hash-verified at opt-in runtime only.

## Required Opt-In Surface

Future v0.160 must add a new experimental launcher with a clear opt-in name:

```text
GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat
```

The default launchers must stay unchanged:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`.
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.

The default player-facing Salto path must keep procedural Worker presentation unless the future v0.160 opt-in launcher is used.

## Required Failure Behavior

The future v0.160 path must fail closed to the existing procedural Worker fallback when any of these are true:

- The local candidate file is missing.
- The SHA-256 does not match `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Candidate metadata is absent, malformed, or names a different slot.
- The opt-in flag is absent.
- Any load or texture creation error occurs.

The fail-closed result must be visible in diagnostic evidence and must not crash the slice.

## Forbidden In v0.160

Future v0.160 must not:

- Add a second art slot.
- Import Aster, Barracks, Militia, Ashen Raider, or archived v0.156 Ashen evidence.
- Generate images.
- Add animation assets or directional variants.
- Wire any runtime-art output into the browser runtime.
- Mutate production art-slot manifests.
- Change saves, stable IDs, gameplay rules, objectives, balance, maps, campaign state, input rules, or browser behavior.
- Package ignored local art into ordinary builds.
- Change the default launcher behavior.
- Claim final runtime-art approval, final Worker art approval, final Godot selection, or full-port approval.

## Required Evidence For Future v0.160

Future v0.160 must produce:

- Default-launcher proof showing procedural Worker fallback remains unchanged.
- Opt-in launcher proof showing the Worker candidate appears only when explicitly requested.
- Missing-file or hash-mismatch proof showing procedural fallback and diagnostic reporting.
- Selection ring, assignment, mine-work, Barracks-repair proximity, crowd, and camera-distance captures.
- Performance comparison against procedural fallback.
- Boundary scans proving no browser wiring, no production manifest mutation, no save/stable-ID mutation, no second slot, and no default launcher mutation.
- A review guide for Emmanuel with default-vs-opt-in captures.

## Required Stop

Future v0.160 must stop for Emmanuel review after the Worker opt-in proof. It must not begin v0.161.
