# v0.117 Godot Benchmark Report

## Status

Godot benchmark status:

```text
PASS_GODOT_BENCHMARK
```

Both placeholder modes ran through the headless benchmark workflow.

## Method Boundary

These metrics are directional workflow evidence only. They measure a small headless placeholder loop and command-acceptance flow. They are not final production performance certification and do not represent final art, final animation, final VFX, final UI, final AI, or final battle simulation complexity.

## Metrics

| Mode | Startup ms | Scene launch ms | FPS average | 1 percent low | p95 frame ms | Input latency ms | Results transition ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `2D_PLACEHOLDER` | 9.959 | 9.959 | 240 | 240 | 0.01 | 0.027 | 0.002 |
| `2_5D_ORTHOGRAPHIC_PLACEHOLDER` | 6.989 | 6.989 | 240 | 240 | 0.01 | 0.004 | 0.001 |

Memory working set was not reported by this Godot headless placeholder runner.

## Generated Ignored Evidence

- `artifacts/desktop-spikes/godot-salto/latest/benchmark-2d.json`
- `artifacts/desktop-spikes/godot-salto/latest/benchmark-2_5d.json`
- `artifacts/desktop-spikes/godot-salto/latest/benchmark-summary.md`
- `artifacts/desktop-spikes/godot-salto/latest/scorecard.json`

Scorecard total:

```text
74 / 100
```

Approval status:

```text
workflow-spike-complete-not-final-engine-choice
```
