# v0.162 Barracks Material Opt-In Functional Report

Status: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_FUNCTIONAL`.

Functional scenarios:
- `default-procedural`: no opt-in art flags.
- `worker-only`: existing Worker opt-in only.
- `worker-barracks`: Worker plus Barracks material opt-in.
- `barracks-missing-art-fallback`: Worker active, Barracks source path missing.
- `barracks-hash-mismatch-fallback`: Worker active, Barracks expected hash mismatched.

Required evidence path:
- `artifacts/desktop-spikes/godot-salto/v0162/validation/worker-barracks-art-opt-in-validation.json`
- `artifacts/desktop-spikes/godot-salto/v0162/validation/worker-barracks-art-opt-in-functional-report.json`

Expected PASS gate:
- `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_VALIDATION`
- `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_FUNCTIONAL`

Observed scenario results:
- `default-procedural`: requested `0`, loaded `0`.
- `worker-only`: requested `1`, loaded `1`.
- `worker-barracks`: requested `2`, loaded `2`, Barracks material loaded and applied to `5` friendly Barracks surfaces.
- `barracks-missing-art-fallback`: requested `2`, loaded `1`, Worker loaded, Barracks fallback reason `missing source file`.
- `barracks-hash-mismatch-fallback`: requested `2`, loaded `1`, Worker loaded, Barracks fallback reason `metadata hash mismatch`.

Preserved behaviors:
- Salto title, briefing, battle, objective, and results flow.
- Worker selection and assignment to West Stone Cut Mine.
- Barracks restoration target and construction flow.
- Militia recruitment and Lume restoration path.
- Existing Worker-only opt-in path.
