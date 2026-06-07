# V0160 Worker Art Opt-In Slot Contract

Status: one-slot contract for human review.

## Slot

- Slot id: `worker_billboard_static_v0147`.
- Approach: `HYBRID_WORKER_TRIMMED_1024`.
- Required SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Expected dimensions: `1024 x 1024`.
- Expected pivot posture: bottom-center foot pivot.
- Local file posture: ignored source, hash-verified at opt-in runtime only.

## Loader Rules

The opt-in loader must:

- Require `--worker-art-opt-in`.
- Verify metadata and source before use.
- Cache the texture, material, and quad mesh per scene instance.
- Reuse the existing `worker_00` gameplay entity and all selection, assignment, mine-work, Barracks-repair, and results behavior.
- Report cache counters and fallback state.

## Fallback Rules

Procedural Worker fallback must be used when:

- The opt-in flag is absent.
- The source file is missing.
- Metadata is absent, malformed, or for a different slot.
- Metadata or source SHA-256 does not match.
- Dimensions are wrong.
- Image load or texture creation fails.

## Evidence Artifacts

Runtime evidence is generated under ignored artifact roots:

- `artifacts/desktop-spikes/godot-salto/v0160/validation/`
- `artifacts/desktop-spikes/godot-salto/v0160/capture/`
- `artifacts/desktop-spikes/godot-salto/v0160/benchmark/`

Tracked source code and docs contain the contract only. The ignored image is not imported into the browser runtime or production runtime-art manifests.
