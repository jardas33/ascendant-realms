# v0.147 Worker Billboard Slot Contract

Status: single experimental slot contract for private comparator intake.

## Slot

```text
worker_billboard_static_v0147
```

The slot is private comparator-only and represents one static Worker billboard cutout. It is not a production unit asset.

## Local Experimental Cutout

Path:

```text
artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/worker_billboard_static_v0147.png
```

Metadata:

```text
artifacts/desktop-spikes/godot-salto/v0147/local-worker-slot/worker_billboard_static_v0147.metadata.json
```

Current local metadata:

- SHA-256: `e294115817821eb84a459f6c86110d7b6951ad34182802bf6b0c07f560cab88a`.
- Source SHA-256: `1e9c52ced826a0221c6f50e7b7ffecf98ab9612968d2c2cf0aee36e565e4a17d`.
- Dimensions: `1254 x 1254`.
- Alpha posture: matte-to-alpha transparent PNG, original chroma source preserved.
- Trim bounds: left `316`, top `55`, right `904`, bottom `1201`.
- Pivot posture: bottom-center foot pivot, normalized `x=0.4868`, `y=0.9577`.
- `privateComparatorOnly = true`.
- `productionApproval = forbidden`.
- `playerSliceIntegration = forbidden`.
- `browserIntegration = forbidden`.

The local cutout is ignored and must never be treated as a production art slot without a future explicit checkpoint.

## Tracked Diagnostic Fallback

Path:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.png
```

Contract:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/worker_billboard_static_v0147_fallback.contract.json
```

Fallback contract:

- SHA-256: `fa60b6e6a86b41cb449c3a16a0401cf44fbab8b5faefd7f19147b3a8c6161419`.
- Dimensions: `512 x 512`.
- Alpha posture: tracked transparent diagnostic fallback.
- Trim bounds: left `119`, top `118`, right `389`, bottom `451`.
- Pivot posture: bottom-center foot pivot, normalized `x=0.4971`, `y=0.8809`.
- `privateComparatorOnly = true`.
- `productionApproval = forbidden`.
- `playerSliceIntegration = forbidden`.
- `browserIntegration = forbidden`.

## Loader Contract

The private comparator loader:

1. Prefers the ignored local experimental cutout when present.
2. Requires local metadata to match slot ID, SHA-256, and boundary flags.
3. Falls back to the tracked deterministic diagnostic fallback when the local cutout is absent.
4. Requires the fallback contract hash to match the deterministic repository generator.
5. Refuses invalid or unknown sources.

## Clean-Checkout Reproducibility

`npm run godot:worker-billboard:fallback:reproduce` verifies that the tracked fallback still matches the deterministic repository generator. This allows validation and private comparator smoke to run without the ignored local cutout.
