# V0161 Worker Art Opt-In Player-Slice Visual QA Spec

Status: bounded v0.161 visual-QA hardening spec for the existing Worker-art opt-in player slice.

## Scope

v0.161 inspects and hardens only the existing Godot Salto Worker-art opt-in path created in v0.160.

Authorized slot:

- Slot: `worker_billboard_static_v0147`.
- Derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Required SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Default fallback: procedural Worker silhouette.

## Required Comparisons

- P1 procedural baseline through `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- P2 validated opt-in through `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
- P3 safe missing-art fallback.
- P4 safe hash-mismatch fallback.
- P5 same-source scale comparison between `1.00x` and review-only `0.90x`.

## Gate

Run:

```text
GODOT_VALIDATE_SALTO_WORKER_ART_OPT_IN_HARDENING_WINDOWS.bat
```

Expected ignored artifact reports:

- `artifacts/desktop-spikes/godot-salto/v0161/validation/worker-art-opt-in-hardening-validation.json`
- `artifacts/desktop-spikes/godot-salto/v0161/capture/worker-art-opt-in-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0161/benchmark/worker-art-opt-in-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0161/real-input/worker-art-opt-in-real-input-report.json`
- `artifacts/desktop-spikes/godot-salto/v0161/boundary/worker-art-opt-in-boundary-scan.json`
- `artifacts/desktop-spikes/godot-salto/v0161/worker-art-opt-in-hardening-report.json`

## Non-Goals

No new AI image, second slot, default-art enablement, browser wiring, production manifest migration, save or stable-ID change, gameplay change, final engine choice, full port, or v0.162 work is authorized.
