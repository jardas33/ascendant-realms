# v0.153 Hybrid Three-Slot Fair-Path Audit

Status: `PASS_V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT`.

Expected PASS marker: `PASS_V0153_HYBRID_THREE_SLOT_FAIR_PATH_AUDIT`.

The private comparator must prove:

- Selected and fallback Aster paths share the same Aster billboard render path.
- Selected and fallback Worker paths share the same Worker billboard render path.
- Selected and fallback Barracks paths share the same Barracks material shell path.
- Texture and material creation happen once per source/material key.
- No texture creation, material creation, or metadata parsing occurs during steady-state measured frames.
- Initialization and warmup are excluded from benchmark timing.

Boundary:

- Zero new AI images.
- Zero new runtime-art slots.
- Private comparator only.
- No normal Salto player-slice mutation.
- No browser runtime wiring.

Final audit evidence:

- Texture cache entries: `6`.
- Material cache entries: `6`.
- Texture create counts: one per selected/fallback Aster, Worker, and Barracks source.
- Material create counts: one per selected/fallback Aster, Worker, and Barracks material key.
- Repeated texture creation during steady state: `false`.
- Repeated material creation during steady state: `false`.
- Metadata parsing during steady state: `false`.
- Initialization and warmup excluded from benchmark timing: `true`.
- Unknown or hash-mismatched sources fail closed: `true`.
