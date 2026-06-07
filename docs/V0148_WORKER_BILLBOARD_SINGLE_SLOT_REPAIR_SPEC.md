# v0.148 Worker Billboard Single-Slot Repair Spec

Status: private comparator-only repair pass complete; final evidence stops for human review.

## Goal

Repair and fairly benchmark only the existing v0.147 private hybrid Worker billboard single-slot path. This checkpoint does not create a new art slot, does not import any reference-art candidate, and does not wire anything into the normal Salto player slice or browser runtime.

## Start State

- Start commit: `f0bb252bb6767d5c24d6c3e4764ba83534b4ce36`.
- Branch: `main`.
- Sync: `HEAD...@{u}` was `0 0`.
- Baseline GitHub Actions run: `27076917234`, completed successfully.
- v0.147 local Worker average FPS ratio: `0.8464`, below the `0.90` gate.
- v0.147 local Worker p95 frame-time ratio: `1.3697`, above the `1.15` gate.

## Source Rules

- Use only the existing ignored v0.147 Worker source and cutout.
- Generate zero new AI-generated images.
- Preserve the original source image unchanged.
- Keep all v0.148 derivatives ignored under `artifacts/desktop-spikes/godot-salto/v0148/local-worker-slot/`.
- Keep the tracked fallback as diagnostic comparator material only.

## Allowed Deterministic Derivatives

Exactly these deterministic repair derivatives are allowed:

```text
worker_billboard_static_v0147_trimmed_512.png
worker_billboard_static_v0147_trimmed_768.png
worker_billboard_static_v0147_trimmed_1024.png
```

The full-resolution v0.147 matte-to-alpha cutout remains available only as the source-quality comparator.

## Original Acceptance Gate

The original acceptance gate is preserved:

- Tier L average FPS ratio versus `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE` must be at least `0.90`.
- Tier L p95 frame-time worsening ratio versus `HYBRID_DIAGNOSTIC_FALLBACK_BASELINE` must be at most `1.15`.
- Absolute p95 delta is context only and cannot override a failed ratio.

Final captured result:

- Gate status: `PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE`.
- Selected recommended derivative: `HYBRID_WORKER_TRIMMED_1024`.
- Selected hash: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Baseline Tier L mean FPS: `858.41`.
- Selected Tier L mean FPS: `851.14`.
- Average FPS ratio: `0.9915`.
- Baseline Tier L mean p95 frame time: `1.87 ms`.
- Selected Tier L mean p95 frame time: `1.88 ms`.
- p95 frame-time ratio: `1.0053`.

## Runtime Boundary

- Private Godot comparator dispatch flag only: `--worker-billboard-single-slot-repair`.
- No second runtime-art slot.
- No production runtime-art integration.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
- No v0.149 work.
