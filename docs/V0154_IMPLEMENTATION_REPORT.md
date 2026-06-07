# v0.154 Implementation Report

Status: implemented as a private comparator-only Militia static billboard intake with the v0.154 gate passed.

Implemented private-only surfaces:

- `--militia-billboard-single-slot` root dispatch.
- `GODOT_MILITIA_BILLBOARD_SINGLE_SLOT_EXPERIMENT_WINDOWS.bat`.
- `godot:militia-billboard:*` npm scripts.
- Militia source/cutout metadata, tracked fallback, validation, benchmark, capture, scorecard, contact-sheet, and audit tooling.

Boundary:

- Exactly one AI image.
- Militia only.
- No animations.
- Private comparator only.
- Fourth private comparator runtime-art intake check only.
- No fifth runtime-art slot.
- No normal Salto player-slice mutation.
- No browser runtime wiring.
- No v0.155 work inside this checkpoint.

Final local evidence:

- Gate: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_GATE`.
- Evidence: `PASS_V0154_MILITIA_BILLBOARD_SINGLE_SLOT_EVIDENCE_RECORDED`.
- Fair-path audit: `PASS_V0154_MILITIA_BILLBOARD_FAIR_PATH_AUDIT`.
- Source SHA-256: `b53e94150bd3fb9b1fde36268655df251deca286f336e6faed72ba1d264d8de0`.
- Cutout SHA-256: `eb007174023e2a4339d45e62ef7bb28769126bd7635ca4ca00115daaafa78996`.
- Fallback SHA-256: `8b262f722cc28b346109f0578a0ca151ef8ff01fd4e149075cf7e539a5ab767c`.
- Tier L local average-FPS ratio: `1.0055`.
- Tier L local p95 frame-time ratio: `1.0199`.
- Screenshot count: `22`; benchmark row count: `21`.
- Fair-path cache posture: `5` texture cache entries, `5` material cache entries, one texture/material create per source key, and no metadata parsing during steady-state frames.

Remote CI confirmation is recorded in the checkpoint closeout after commit and push.
