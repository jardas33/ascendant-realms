# V0161 Worker Art Opt-In Hardening Report

Status: human-review readiness report for the v0.161 Worker-art opt-in hardening pass.

## Acceptance Gate

The v0.161 hardening gate passes only when:

- Default stabilized launcher hash remains `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`.
- Default path remains procedural and functional without local art.
- Opt-in path loads only `worker_billboard_static_v0147` with SHA-256 `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Missing-art and hash-mismatch both fail closed to procedural Worker fallback.
- Worker selection, Worker assignment, Barracks restoration, restart/replay, and recoverable-mistake postures pass.
- `1.00x` remains preferred unless evidence proves a bounded repair.
- Opt-in FPS ratio versus procedural is at least `0.90`.
- Opt-in P95 frame-time worsening is no more than `15%`.
- No package leakage, browser wiring, second slot, save/stable-ID mutation, gameplay mutation, or v0.162 work appears.

## Implementation Decision

No runtime edit is expected unless evidence proves a narrow Worker opt-in defect. The hardening pass is primarily tooling, evidence, documentation, and Windows-side review.

## Evidence Root

```text
artifacts/desktop-spikes/godot-salto/v0161/
```

The final ignored scorecard is:

```text
artifacts/desktop-spikes/godot-salto/v0161/worker-art-opt-in-human-review-scorecard.json
```

## Latest Gate Result

The hardened v0.161 wrapper produced:

- `PASS_V0161_WORKER_ART_OPT_IN_QA_VALIDATION`
- `PASS_V0161_WORKER_ART_OPT_IN_CAPTURE`
- `PASS_V0161_WORKER_ART_OPT_IN_BENCHMARK`
- `PASS_V0161_WORKER_ART_OPT_IN_REAL_INPUT`
- `PASS_V0161_WORKER_ART_OPT_IN_COMPUTER_USE_GATE`
- `PASS_V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY`
- `PASS_V0161_WORKER_ART_OPT_IN_HUMAN_REVIEW_READY`

Benchmark scorecard: opt-in FPS ratio `1.0023`, opt-in P95 frame-time ratio `0.8784`, package leakage `false`, default stabilized launcher hash `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`.
