# v0.163 Barracks Material Opt-In Hardening Report

Status: `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.

This checkpoint hardens the existing combined Worker + Barracks-material opt-in path by adding a v0.163-only review wrapper, validation wrapper, scorecard, Computer Use gate, and docs. The runtime integration itself remains the v0.162 two-slot implementation.

Generated evidence root:

- `artifacts/desktop-spikes/godot-salto/v0163/`.

Required PASS gates:

- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_QA_VALIDATION`.
- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_CAPTURE`.
- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_BENCHMARK`.
- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_REAL_INPUT`.
- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_COMPUTER_USE_GATE`.
- `PASS_V0163_PLAYER_SLICE_TWO_SLOT_BOUNDARY`.
- `PASS_V0163_BARRACKS_MATERIAL_OPT_IN_HUMAN_REVIEW_READY`.

Boundaries:

- Zero new images.
- Zero new slots.
- No normal Salto gameplay mutation.
- No browser-runtime wiring.
- Default stabilized launcher remains procedural.
- Worker-only launcher remains preserved.
- Human review is required before any later milestone.

Benchmark scorecard:

- Worker-only FPS ratio versus procedural: `0.9940`.
- Combined FPS ratio versus procedural: `0.9939`.
- Combined FPS ratio versus Worker-only: `0.9999`.
- Worker-only P95 frame-time ratio versus procedural: `0.9837`.
- Combined P95 frame-time ratio versus procedural: `1.0186`.
- Combined P95 frame-time ratio versus Worker-only: `1.0354`.

Final scorecard artifact:

- `artifacts/desktop-spikes/godot-salto/v0163/worker-barracks-art-opt-in-human-review-scorecard.json`.
