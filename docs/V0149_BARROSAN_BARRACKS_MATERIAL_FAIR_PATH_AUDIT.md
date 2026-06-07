# v0.149 Barracks Material Fair Path Audit

Status: final counters are recorded by the private comparator after headed benchmark and capture.

## Fairness Requirements

- Local and fallback scenarios use equivalent procedural Barracks shell complexity.
- Worker context, camera path, lighting posture, selection-ring posture, and benchmark semantics remain equivalent.
- Texture loaded once per source.
- Material created once per source and reused where safe.
- No texture decode, texture creation, material creation, derivative generation, metadata parsing, UV rebuild, or material-slot mutation occurs per Barracks instance or per steady-state frame.
- Initialization and warmup are recorded separately from measured benchmark frames.
- Tier L uses five trials and rotated scenario order.
- Unknown or hash-mismatched sources fail closed.

## Final Runtime Counters

The private comparator records:

```text
sourceLoadCounts
textureCreateCounts
materialCreateCounts
materialReuseCounts
barracksShellNodeRebuildCount
workerContextNodeRebuildCount
initializationDurationMs
steadyStateWarmupFrames
textureMemoryProxyBytes
renderedObjectProxy
```

Generated audit report:

```text
artifacts/desktop-spikes/godot-salto/v0149/evidence/barracks-material-fair-path-audit.json
```

Expected pass marker:

```text
PASS_V0149_BARRACKS_MATERIAL_FAIR_PATH_AUDIT
```

Observed final audit:

| Field | Value |
| --- | --- |
| `textureCacheEntries` | `5` |
| `materialCacheEntries` | `5` |
| `textureLoadedOnceAndReused` | `true` |
| `materialCreatedOnceAndReusedWhereSafe` | `true` |
| `repeatedTextureCreateDuringSteadyState` | `false` |
| `repeatedMaterialCreateDuringSteadyState` | `false` |
| `derivativeGenerationDuringRuntime` | `false` |
| `metadataParsingDuringSteadyState` | `false` |
| `uvRebuildDuringSteadyState` | `false` |
| `benchmarkExcludesInitializationAndWarmup` | `true` |
| `unknownOrHashMismatchedSourcesFailClosed` | `true` |
| `barracksShellNodeRebuildCount` | `798` |
| `workerContextNodeRebuildCount` | `957` |

Each of the five sources loaded once: the v0.148 selected Worker context derivative, the three v0.149 local Barracks derivatives, and the tracked Barracks fallback. Each matching material key was created once and then reused where safe.

## Boundary

- No gate relaxation.
- No third runtime-art slot.
- No normal player-slice wiring.
- No browser runtime wiring.
- No v0.150 work.
