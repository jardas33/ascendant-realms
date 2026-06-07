# v0.151 Aster Billboard Scorecard

Status: final values were written by `npm run godot:aster-billboard:benchmark:headed` and refreshed by capture.

Evidence artifacts:

- `artifacts/desktop-spikes/godot-salto/v0151/evidence/aster-billboard-single-slot-evidence.json`
- `artifacts/desktop-spikes/godot-salto/v0151/evidence/aster-billboard-single-slot-scorecard.json`
- `artifacts/desktop-spikes/godot-salto/v0151/evidence/aster-billboard-single-slot-threshold-report.json`
- `artifacts/desktop-spikes/godot-salto/v0151/evidence/aster-billboard-single-slot-fair-path-audit.json`
- `artifacts/desktop-spikes/godot-salto/v0151/evidence/contact-sheet.svg`

Scorecard rows must cover:

- `HYBRID_ASTER_DIAGNOSTIC_FALLBACK_BASELINE`
- `HYBRID_ASTER_LOCAL_STATIC_BILLBOARD`
- `HYBRID_WORKER_CONTEXT_BASELINE`
- `HYBRID_BARRACKS_CONTEXT_BASELINE`
- `ORTHO_3D_MESH_FALLBACK_COMPARATOR`

Final gate:

- `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_GATE`
- Selected approach: `HYBRID_ASTER_LOCAL_STATIC_BILLBOARD`
- Selected hash: `aa1572e26dcbfeaddd0b53c48a2c5e4713ddb35a002af5939f54b271621a3b72`
- Tier L FPS ratio: `0.9273`
- Tier L p95 frame-time ratio: `1.1081`
- Recognition posture: `true`
- Evidence: `PASS_V0151_ASTER_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`
- Fair-path audit: `PASS_V0151_ASTER_BILLBOARD_FAIR_PATH_AUDIT`
- Screenshots: `32`
- Benchmark rows: `35`

Failure rule:

- Missing Tier S/M/L rows, missing five-trial Tier L local/fallback evidence, or failed local-vs-fallback performance/readability checks are blockers.
