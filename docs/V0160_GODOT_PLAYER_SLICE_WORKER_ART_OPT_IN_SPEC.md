# V0160 Godot Player-Slice Worker Art Opt-In Spec

Status: implementation checkpoint for human review. This is not final runtime-art approval, final Worker art approval, a final Godot decision, or a full port.

## Scope

v0.160 integrates exactly one validated Worker billboard candidate into the normal Godot Salto review slice behind an explicit opt-in launcher only.

Authorized slot:

- Slot id: `worker_billboard_static_v0147`.
- Derivative: `HYBRID_WORKER_TRIMMED_1024`.
- SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Source: ignored local v0.148 repaired Worker derivative.

## Entry Points

New opt-in launchers:

- `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`

Package scripts:

- `npm run godot:launch:salto-worker-art-experiment`
- `npm run godot:validate:salto-worker-art-experiment`
- `npm run godot:capture:salto-worker-art-experiment`
- `npm run godot:benchmark:salto-worker-art-experiment`

Default launchers preserved:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`

## Runtime Contract

The Worker billboard loads only when `--worker-art-opt-in` is present. The scene verifies source existence, metadata existence, slot id, metadata hash, exact source SHA-256, 1024 by 1024 dimensions, image load, and texture creation before replacing the procedural Worker visual.

If any check fails, the scene fails closed to the existing procedural Worker silhouette and records the fallback reason in `workerArtExperiment`.

## Non-Goals

- No image generation.
- No second player-facing art slot.
- No Aster, Barracks, Militia, Ashen Raider, or archived Ashen import.
- No animation or directional variants.
- No browser-runtime wiring.
- No production manifest mutation.
- No save, stable-ID, gameplay, AI, objective, map, input, balance, campaign, or browser behavior change.
- No v0.161 work.
