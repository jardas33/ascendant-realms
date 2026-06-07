# v0.157 Ashen Raider Fair Path Audit

Runtime audit target:

- Evidence: `artifacts/desktop-spikes/godot-salto/v0157/evidence/ashen-raider-visual-restraint-replacement-fair-path-audit.json`
- Command: `npm run godot:ashen-raider-replacement:audit`

Fair-path requirements:

- Fallback, archived v0.156 cutout, and v0.157 derivatives share the Ashen Raider billboard render path.
- Texture/material creation happens once per source/material key.
- Benchmark timing excludes initialization and warmup frames.
- Metadata is not parsed during steady-state frames.
- Selected Worker, Barracks, Aster, and Militia context remains the already-approved private comparator context.

Result:

- Status: `PASS_V0157_ASHEN_RAIDER_REPLACEMENT_FAIR_PATH_AUDIT`.
- Texture cache entries: `10`.
- Material cache entries: `10`.
- Source load entries: `10`.
- `textureLoadedOnceAndReused`: `true`.
- `materialCreatedOnceAndReusedWhereSafe`: `true`.
- `localAndFallbackShareAshenRaiderBillboardRenderPath`: `true`.
- `benchmarkExcludesInitializationAndWarmup`: `true`.
- `metadataParsingDuringSteadyState`: `false`.
- `repeatedTextureCreateDuringSteadyState`: `false`.
- `repeatedMaterialCreateDuringSteadyState`: `false`.
- `preservesArchivedV0156ComparisonEvidence`: `true`.
- `sameHostileSlotOnly`: `true`.
- `noSixthRuntimeArtSlot`: `true`.

Fairness conclusion:

The tracked fallback, archived v0.156 cutout, and every v0.157 derivative are exercised through the same Ashen Raider billboard material path. The selected Worker, Barracks, Aster, and Militia context assets load once per source key, and no metadata parsing or repeated texture/material creation is recorded during steady-state frames.
