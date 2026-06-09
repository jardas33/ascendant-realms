# v0.178 Ground Material Benchmark And Boundary

Status: `PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BOUNDARY`

v0.178 benchmarks the hardened ground-material opt-in path against the E0 environment-foundation baseline and proves the same missing-art and hash-mismatch fallbacks as v0.177.

## Evidence Root

`artifacts/desktop-spikes/godot-salto/v0178/`

Primary reports:

- Validation: `artifacts/desktop-spikes/godot-salto/v0178/validation/ground-material-opt-in-validation-report.json`
- Capture: `artifacts/desktop-spikes/godot-salto/v0178/capture/ground-material-opt-in-capture-report.json`
- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0178/capture/v0178-ground-material-uv-noise-hardening-contact-sheet.svg`
- Benchmark: `artifacts/desktop-spikes/godot-salto/v0178/benchmark/ground-material-opt-in-benchmark-scorecard.json`
- Boundary: `artifacts/desktop-spikes/godot-salto/v0178/boundary/ground-material-opt-in-boundary-report.json`
- Cleanup dry-run: `artifacts/desktop-spikes/godot-salto/v0178/cleanup-dry-run/salto-experimental-cleanup-report.json`
- Retention: `artifacts/desktop-spikes/godot-salto/v0178/artifact-retention/salto-experimental-artifact-retention-report.json`

## Benchmark

| Mode | Average FPS | p95 frame time |
| --- | ---: | ---: |
| E0 environment foundation baseline | `75.42` | `12.94 ms` |
| E1 hardened ground-material opt-in | `75.27` | `13.30 ms` |

Gate results:

- FPS ratio: `0.998` against required `>= 0.90`.
- p95 worsening: `2.78%` against allowed `<= 15%`.
- Ground source load count: `1`.
- Metadata parse count: `1`.
- Image decode count: `1`.
- Texture create count: `1`.
- Material create count: `1`.
- Applied ground surface count: `2`.

Status: `PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BENCHMARK`.

## Fallbacks

Both fallback modes keep the five frozen character/material slots active and fall back only the ground material:

- Missing source fallback: `ground-missing-art-fallback`, reason `missing source file`.
- Hash mismatch fallback: `ground-hash-mismatch-fallback`, reason `metadata hash mismatch`.

Fallback modes do not import the selected source, do not activate the texture overlay, and do not apply material surfaces.

## Boundary

Boundary report:

- AI images generated: `0`.
- Runtime character slots added: `0`.
- Environment material slots added: `1`.
- Hardened UV scale: `0.56`.
- Previous UV scale: `0.72`.
- Maximum noise-control alpha: `0.52`; actual runtime alpha: `0.48`.
- Default launcher procedural: `true`.
- Prior launchers preserved: `true`.
- Browser runtime changed: `false`.
- Save writes allowed: `false`.
- Stable IDs changed: `false`.
- Gameplay/pathing changed: `false`.
- Navigation semantics changed: `false`.
- Selected hash: `818b7743fbf192fe95dd95a0fbadb59ea92b1cb36c420dac5526c0f4d1af18a8`.

## Validation Command

```text
npm run godot:validate:salto-ground-material-opt-in
```

Result:

```text
PASS_V0178_SALTO_GROUND_MATERIAL_UV_NOISE_HARDENING_AUTOMATION_READY
PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_VALIDATION
PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_CAPTURE
PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BENCHMARK
PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING_BOUNDARY
PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION
PASS_V0166_EXPERIMENTAL_ARTIFACT_CLEANUP_DRY_RUN
```

## Stop Line

v0.178 performs zero image generation, adds zero new slots, preserves the existing single environment-material opt-in slot, and does not begin v0.179 inside this checkpoint.
