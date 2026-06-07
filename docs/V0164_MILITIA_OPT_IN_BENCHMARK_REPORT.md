# v0.164 Militia Opt-In Benchmark Report

Status: `PASS_V0164_MILITIA_OPT_IN_BENCHMARK`.

Thresholds:

- Minimum M3 FPS ratio versus procedural M0: `0.9000`
- Maximum M3 P95 frame-time ratio versus procedural M0: `1.1500`
- Minimum M3 FPS ratio versus Worker + Barracks M2: `0.9000`
- Maximum M3 P95 frame-time ratio versus Worker + Barracks M2: `1.1500`
- Maximum source loads, metadata parses, decodes, textures, or material creates per process: `1`

Scorecard:

| Scenario | FPS | P95 ms | Worker | Barracks | Militia | Militia fallback |
| --- | ---: | ---: | --- | --- | --- | --- |
| `procedural-baseline` | `74.96` | `13.26` | off | off | off | opt-in flag absent |
| `worker-only` | `74.96` | `13.75` | on | off | off | opt-in flag absent |
| `worker-barracks` | `74.97` | `13.21` | on | on | off | opt-in flag absent |
| `worker-barracks-militia` | `74.98` | `12.52` | on | on | on | none |
| `militia-missing-art-fallback` | `74.97` | `13.32` | on | on | off | missing source file |
| `militia-hash-mismatch-fallback` | `75.12` | `13.38` | on | on | off | metadata hash mismatch |

Ratios:

- M3 FPS ratio versus M0: `1.0003`
- M3 P95 frame-time ratio versus M0: `0.9442`
- M3 FPS ratio versus M2: `1.0001`
- M3 P95 frame-time ratio versus M2: `0.9478`

Evidence:

- Benchmark report: `artifacts/desktop-spikes/godot-salto/v0164/benchmark/worker-barracks-militia-art-opt-in-benchmark-report.json`
- Scorecard: `artifacts/desktop-spikes/godot-salto/v0164/benchmark/worker-barracks-militia-art-opt-in-scorecard.json`
