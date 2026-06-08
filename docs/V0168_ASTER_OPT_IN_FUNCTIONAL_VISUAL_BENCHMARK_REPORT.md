# v0.168 Aster Opt-In Functional Visual Benchmark Report

Status: `PASS_V0168_ASTER_OPT_IN_HUMAN_REVIEW_READY`

Validation command:

```text
npm run godot:validate:salto-worker-barracks-militia-aster-art-experiment
```

Required evidence:

- M0 default procedural validation and capture.
- M1 Worker-only validation and capture.
- M2 Worker + Barracks validation and capture.
- M3 Worker + Barracks + Militia validation, capture, and benchmark.
- M4 Worker + Barracks + Militia + Aster validation, capture, benchmark, and real-input playthrough.
- Aster missing-art fallback validation, capture, and benchmark.
- Aster hash-mismatch fallback validation, capture, and benchmark.
- Windows Computer Use visual review packet.

Acceptance gates:

- Exact Aster hash loads only in M4.
- Missing/hash fallback restores procedural Aster while Worker, Barracks, and Militia stay active.
- Procedural Aster body is suppressed only when validated Aster art loads.
- Aster reads as hero hierarchy above Militia and Worker.
- No double render, compression, halo, pivot, selection-ring, movement, or overlap defect.
- M4 FPS ratio versus M0 and M3 is at least `0.90`.
- M4 p95 frame-time ratio versus M0 and M3 is at most `1.15`.
- Full bounded playthrough, Results, restart, and replay remain green.
- Artifact retention and cleanup dry-run remain green.

The generated scorecard lives under `artifacts/desktop-spikes/godot-salto/v0168/` after validation.

Completed evidence:

- Functional validation: `artifacts/desktop-spikes/godot-salto/v0168/validation/worker-barracks-militia-aster-art-opt-in-functional-report.json` / `PASS_V0168_ASTER_OPT_IN_FUNCTIONAL`.
- Capture report: `artifacts/desktop-spikes/godot-salto/v0168/capture/worker-barracks-militia-aster-art-opt-in-capture-report.json` / `PASS_V0168_ASTER_OPT_IN_CAPTURE`.
- Benchmark scorecard: `artifacts/desktop-spikes/godot-salto/v0168/benchmark/worker-barracks-militia-aster-art-opt-in-scorecard.json` / `PASS_V0168_ASTER_OPT_IN_BENCHMARK`; M4 FPS ratio versus M0 `1.0000`, M4 FPS ratio versus M3 `1.0027`, M4 p95 ratio versus M0 `0.9720`, M4 p95 ratio versus M3 `0.9630`.
- Real-input report: `artifacts/desktop-spikes/godot-salto/v0168/real-input/worker-barracks-militia-aster-art-opt-in-real-input-report.json` / `PASS_V0168_ASTER_OPT_IN_REAL_INPUT`.
- Windows-side Computer Use gate: `artifacts/desktop-spikes/godot-salto/v0168/computer-use/worker-barracks-militia-aster-art-opt-in-computer-use-gate.json` / `PASS_V0168_ASTER_OPT_IN_COMPUTER_USE_GATE`.
- Human-review scorecard: `artifacts/desktop-spikes/godot-salto/v0168/worker-barracks-militia-aster-art-opt-in-human-review-scorecard.json` / `PASS_V0168_ASTER_OPT_IN_HUMAN_REVIEW_READY`.
