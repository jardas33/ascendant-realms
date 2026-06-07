# v0.151 Aster Billboard Validation Report

Status: validation passed locally with the final v0.151 evidence refresh.

Validation checks:

- The tracked diagnostic fallback reproduces deterministically.
- The ignored local Aster source count is exactly one.
- The ignored local metadata matches the current cutout hash, dimensions, alpha stats, trim bounds, and bottom-center pivot.
- The selected v0.148 Worker derivative remains `HYBRID_WORKER_TRIMMED_1024`.
- The selected v0.150 Barracks repair remains `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.
- The Godot root dispatch exposes only `--aster-billboard-single-slot`.
- Normal player launchers do not reference the private v0.151 path.

Expected markers:

- `PASS_V0151_ASTER_BILLBOARD_FALLBACK_REPRODUCIBILITY`
- `PASS_V0151_ASTER_BILLBOARD_LOCAL_METADATA`
- `PASS_V0151_ASTER_BILLBOARD_VALIDATION`
- `PASS_V0151_ASTER_BILLBOARD_RUNTIME_VALIDATION`

Final local source:

- Source count: `1`
- Cutout hash: `aa1572e26dcbfeaddd0b53c48a2c5e4713ddb35a002af5939f54b271621a3b72`
- Dimensions: `1024 x 1536`
- Alpha posture: `flat-matte-source-deterministic-chroma-to-alpha-transparent-png`

This report is not production art approval.
