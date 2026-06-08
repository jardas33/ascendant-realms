# v0.165 Billboard Scale Aspect Pivot Audit

Status: `PASS_V0165_BILLBOARD_SCALE_ASPECT_PIVOT_AUDIT`

## Worker

- Slot: `worker_billboard_static_v0147`
- Approach: `HYBRID_WORKER_TRIMMED_1024`
- SHA-256: `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`
- Source dimensions: 1024 x 1024
- Alpha bounds: left 271, right 752, top 46, bottom 987, size 482 x 942
- Alpha aspect: 0.5117
- Pivot: bottom-center, normalized x 0.5, normalized y 0.9639
- Before repair runtime quad: 0.55 x 0.74
- After repair runtime quad: 0.74 x 0.74
- Aspect status: source aspect preserved

## Militia

- Slot: `militia_billboard_static_v0154`
- Approach: `HYBRID_MILITIA_TRIMMED_1024`
- SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`
- Source dimensions: 1024 x 1024
- Alpha bounds: left 319, right 704, top 46, bottom 987, size 386 x 942
- Alpha aspect: 0.4098
- Pivot: bottom-center, normalized x 0.5, normalized y 0.9648
- Before repair runtime quad: 0.50 x 0.68
- After repair runtime quad: 0.68 x 0.68
- Aspect status: source aspect preserved

## Evidence

Generated machine-readable audit:

- `artifacts/desktop-spikes/godot-salto/v0165/audit/v0165-billboard-scale-aspect-pivot-audit.json`
