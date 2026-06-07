# V0160 Worker Art Opt-In Benchmark Report

Status: benchmark contract for procedural baseline versus Worker opt-in.

## Benchmark Scenarios

The packaged benchmark runs:

- `procedural-baseline`
- `worker-opt-in`
- `missing-art-fallback`
- `hash-mismatch-fallback`

Each scenario drives the same representative player-slice sequence: battle default, Worker selection, mine conversion, Worker assignment, Barracks placement/completion, and squad crowding.

## Metrics

Runtime reports include:

- Average FPS.
- Average frame time.
- P95 and P99 frame time.
- Source load count.
- Metadata parse count.
- Image decode count.
- Texture create count.
- Material create count.
- Mesh create count.

The opt-in gate requires the selected source to load exactly once per process and not recreate texture/material assets during steady-state frames.

## Gate

Run:

```text
npm run godot:benchmark:salto-worker-art-experiment
```

Expected generated reports:

- `artifacts/desktop-spikes/godot-salto/v0160/benchmark/worker-art-opt-in-benchmark-report.json`
- `artifacts/desktop-spikes/godot-salto/v0160/benchmark/worker-art-opt-in-scorecard.json`

Recorded acceptance status:

- `PASS_V0160_WORKER_ART_OPT_IN_BENCHMARK`

Recorded scorecard:

| Scenario | FPS avg | P95 frame ms | Source loaded | Fallback | Decode count | Texture count |
| --- | ---: | ---: | --- | --- | ---: | ---: |
| `procedural-baseline` | 75.17 | 13.88 | false | true | 0 | 0 |
| `worker-opt-in` | 75.27 | 11.70 | true | false | 1 | 1 |
| `missing-art-fallback` | 75.09 | 13.12 | false | true | 0 | 0 |
| `hash-mismatch-fallback` | 75.08 | 13.69 | false | true | 0 | 0 |

Opt-in versus procedural:

- Average FPS ratio: `1.0013`.
- P95 frame-time ratio: `0.8429`.
