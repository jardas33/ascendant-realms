# v0.168 Aster Fourth Opt-In Spec

Status: `PASS_V0168_SPEC_READY`

Scope:

- Add exactly one fourth Godot normal-slice opt-in art slot: `aster_billboard_static_v0151`.
- Use only `HYBRID_ASTER_TRIMMED_1024`.
- Require SHA-256 `b256f96f762187c05d68f2c2de62bedec0248896210767e98cb8f210dac2829a`.
- Keep default launchers procedural.
- Preserve Worker-only, Worker + Barracks, and Worker + Barracks + Militia launchers.
- Generate zero images.
- Do not import Ashen.
- Do not add a fifth slot.
- Do not wire browser runtime, saves, stable IDs, production manifests, gameplay, AI, objectives, or balance.

Runtime contract:

- Aster is off unless `--aster-art-opt-in` is explicitly supplied.
- Runtime verifies exact source hash, metadata hash, dimensions, derivative kind, alpha posture, trim bounds, and bottom-center pivot.
- Valid Aster source loads once and is reused as a billboard material/mesh.
- Missing or hash-mismatched Aster fails closed to the procedural Aster capsule while Worker, Barracks, and Militia remain active.
- Rings, markers, labels, health bars, movement, selection, and microloop behavior are preserved.

Launcher:

- `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_REVIEW_SALTO_FOUR_SLOT_ART_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_WORKER_BARRACKS_MILITIA_ASTER_ART_EXPERIMENT_WINDOWS.bat`

Human review remains required before any broader integration.
