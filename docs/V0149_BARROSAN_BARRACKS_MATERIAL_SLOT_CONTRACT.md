# v0.149 Barrosan Barracks Material Slot Contract

Status: single experimental material slot contract for private comparator intake.

## Slot

```text
barrosan_barracks_material_v0149
```

The slot is private comparator-only and represents one generated material source for a simple procedural Barrosan Barracks shell. It is not a production material pack or final Barracks architecture approval.

## Local Experimental Source

Path:

```text
artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/barrosan_barracks_material_v0149_source.png
```

Metadata:

```text
artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/barrosan_barracks_material_v0149_source.metadata.json
```

Current local source metadata:

- SHA-256: `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c`.
- Dimensions: `1254 x 1254`.
- Role: single original Barrosan Barracks material source.
- Source posture: square material sheet, no structure render, no runtime import.
- Color-space posture: sRGB PNG opaque material source.
- `privateComparatorOnly = true`.
- `productionApproval = forbidden`.
- `playerSliceIntegration = forbidden`.
- `browserIntegration = forbidden`.

## Local Deterministic Derivatives

| Derivative | Dimensions | SHA-256 | UV scale |
| --- | ---: | --- | ---: |
| `barrosan_barracks_material_v0149_512.png` | `512 x 512` | `bb4fbe0ff9a18066dc969b9d8f6f721040161575fd0c1b60d24722f67b007199` | `1.15` |
| `barrosan_barracks_material_v0149_768.png` | `768 x 768` | `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3` | `1.05` |
| `barrosan_barracks_material_v0149_1024.png` | `1024 x 1024` | `913af0ca774c7ab02e12173f7be8d0144b18273c44bcc0c7360520823d22b090` | `1.00` |

## Tracked Deterministic Diagnostic Fallback

Path:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.png
```

Contract:

```text
desktop-spikes/godot-salto/comparators/runtime_art_pipeline/fallback/barrosan_barracks_material_v0149_fallback.contract.json
```

Fallback contract:

- SHA-256: `473ea8fd00a42716d2130109d2d3eb30f0a5eb3751fe0445af773a5bf0731767`.
- Dimensions: `512 x 512`.
- Role: tracked deterministic diagnostic fallback.
- Original geometric diagnostic only.
- `privateComparatorOnly = true`.
- `productionApproval = forbidden`.
- `playerSliceIntegration = forbidden`.
- `browserIntegration = forbidden`.

## Loader Contract

The private comparator loader:

1. Prefers validated ignored local derivatives when present.
2. Otherwise loads the tracked deterministic diagnostic fallback.
3. Reports the source loaded.
4. Refuses unknown or hash-mismatched sources.
5. Loads each texture once and reuses one material instance where safe.

`npm run godot:barracks-material:fallback:reproduce` verifies clean-checkout fallback reproducibility without the ignored local source.

## Final Selected Review Derivative

```text
HYBRID_BARRACKS_LOCAL_768
```

- Source kind: `local-barracks-material-768`.
- SHA-256: `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3`.
- Dimensions: `768 x 768`.
- Gate: `PASS_V0149_BARRACKS_MATERIAL_ORIGINAL_GATE`.
- Posture: private comparator-only human review evidence.
