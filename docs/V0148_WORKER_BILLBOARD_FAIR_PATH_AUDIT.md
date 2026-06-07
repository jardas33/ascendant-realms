# v0.148 Worker Billboard Fair Path Audit

Status: audit passed with final runtime counters from the headed paired benchmark.

## Fairness Requirements

- Local/fallback billboard approaches use the same render path where possible.
- Textures are loaded once and reused.
- Materials are created once per source and reused.
- No per-instance decode, texture creation, or material creation is allowed during steady-state benchmark frames.
- Initialization and warmup frames are recorded separately from measured benchmark frames.
- Equivalent Tier S/M/L workload shape is used for each approach.
- Tier L uses five trials per hybrid billboard approach.
- Trial order is rotated to reduce ordering bias.
- The original acceptance gate is preserved.

## Implemented Audit Counters

The private comparator records:

```text
sourceLoadCounts
textureCreateCounts
materialCreateCounts
nodeRebuildCount
initializationDurationMs
steadyStateWarmupFrames
```

The generated fair-path audit report is:

```text
artifacts/desktop-spikes/godot-salto/v0148/evidence/worker-billboard-repair-fair-path-audit.json
```

## Current Finding

Final audit status:

```text
PASS_V0148_WORKER_BILLBOARD_FAIR_PATH_AUDIT
```

The final headed capture proved:

- `textureCacheEntries`: `5`.
- `materialCacheEntries`: `10`.
- `textureLoadedOnceAndReused`: `true`.
- `materialsCreatedOncePerSourceTintAndReused`: `true`.
- `repeatedTextureCreateDuringSteadyState`: `false`.
- `repeatedMaterialCreateDuringSteadyState`: `false`.
- `benchmarkExcludesInitializationAndWarmup`: `true`.

Each image source was decoded once, converted to one texture, and paired with cached friendly/opponent materials before benchmark measurement.

## Boundary

- No gate relaxation.
- No jitter override.
- No normal player-slice wiring.
- No browser runtime wiring.
- No v0.149 work.
