# v0.150 Barracks Material UV Seam Repair Spec

Status: private comparator-only implementation complete; human visual review pending.

This checkpoint repairs or quantifies the v0.149 Barrosan Barracks material seam/repeat risk using zero new AI images. Every v0.150 candidate is a deterministic derivative of the same v0.149 material source:

- Source: `artifacts/desktop-spikes/godot-salto/v0149/local-barracks-material-slot/barrosan_barracks_material_v0149_source.png`
- Source SHA-256: `bd07ef2179dde28161a1c32624eac9efd253de7956c4455e992cb716eb367c6c`
- Preserved selected 768 hash: `2731c342024271b2babaac8681d33f060df83e30c47ce56722f9595cd8004ce3`

The v0.150 path keeps the existing slot id `barrosan_barracks_material_v0149`. It adds no new runtime-art slot, imports no reference candidate, and does not wire anything into the normal Salto player slice or browser runtime.

Generated ignored variants:

- `HYBRID_BARRACKS_768_ORIGINAL`
- `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`
- `HYBRID_BARRACKS_768_WRAPSAFE_QUADRANT`
- `HYBRID_BARRACKS_768_WRAPSAFE_SOFTSEAM`
- tracked fallback comparison: `HYBRID_BARRACKS_V0150_FALLBACK`

Final automated selection:

- Selected repair: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`
- Selected SHA-256: `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`
- Final gate marker: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_GATE`
- Final evidence marker: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_EVIDENCE_RECORDED`

Acceptance gate:

- Tier L FPS ratio must be at least `0.90` versus fallback.
- Tier L p95 frame-time ratio must be at most `1.15` versus fallback.
- Candidate must improve automated edge-seam risk versus the original 768 control.
- Captures must be produced for source, 2x2 and 4x4 tiling boards, seam diagnostics, normal/zoomed RTS shells, wet-overcast, restrained hearth, Worker+BARRACKS composition, zoom transition, repeated-shell stress, and fallback comparison.
- Human review remains required for distracting seams, shimmer, UV stretch, visual mud, and ring readability.
