# v0.162 Barracks Material Opt-In Benchmark Report

Status: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_BENCHMARK`.

Benchmark modes:
- M0 procedural baseline.
- M1 Worker-only opt-in.
- M2 combined Worker + Barracks opt-in.
- M3 Barracks missing-art fallback with Worker active.
- Hash fallback: Barracks hash mismatch with Worker active.

Required evidence path:
- `artifacts/desktop-spikes/godot-salto/v0162/benchmark/worker-barracks-art-opt-in-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0162/benchmark/worker-barracks-art-opt-in-scorecard.json`

Provisional gates:
- M1 and M2 average-FPS ratio versus M0 must remain at or above `0.75`.
- M1 and M2 P95 frame-time ratio versus M0 must remain at or below `1.5`.
- Barracks source load, metadata parse, image decode, texture create, and material create counts must not exceed `1` in the combined benchmark process.

Observed scorecard:
- Worker-only average-FPS ratio versus procedural: `0.9975`.
- Combined Worker + Barracks average-FPS ratio versus procedural: `1.0028`.
- Worker-only P95 frame-time ratio versus procedural: `1.0106`.
- Combined Worker + Barracks P95 frame-time ratio versus procedural: `1.0334`.
- Combined Barracks source load, metadata parse, image decode, texture create, and material create counts remained at or below `1`.

Final production certification:
- Not claimed.
- Human review remains required.
