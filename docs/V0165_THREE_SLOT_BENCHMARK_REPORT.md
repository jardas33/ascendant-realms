# v0.165 Three-Slot Benchmark Report

Status: `PASS_V0165_THREE_SLOT_BENCHMARK`

## Scenarios

Benchmarks are rerun across:

- M0 procedural baseline
- M1 Worker only
- M2 Worker + Barracks
- M3 Worker + Barracks + Militia
- M4 Militia missing-art fallback
- M5 Militia hash-mismatch fallback

## Gates

M3 must pass:

- FPS ratio versus M0: `>= 0.90`
- p95 frame-time worsening versus M0: `<= 15%`
- FPS ratio versus M2: `>= 0.90`
- p95 frame-time worsening versus M2: `<= 15%`
- no per-frame decode
- no per-frame metadata parse
- no repeated texture/material creation
- no package leakage
- no browser wiring

## Evidence

- `artifacts/desktop-spikes/godot-salto/v0165/benchmark/v0165-three-slot-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0165/benchmark/v0165-three-slot-benchmark-scorecard.json`

## Result

- M3 FPS ratio versus M0: `1.0029`.
- M3 p95 frame-time ratio versus M0: `1.041`.
- M3 FPS ratio versus M2: `1.0015`.
- M3 p95 frame-time ratio versus M2: `1.0000`.
- The benchmark gate passed with no per-frame decode, no per-frame metadata parse, and no package leakage.
