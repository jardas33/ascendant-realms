# v0.178 Implementation Report

Status: `PASS_V0178_GROUND_MATERIAL_UV_NOISE_HARDENING`

v0.178 hardens the existing ground-material opt-in path only. It does not generate images, does not add a second environment-material slot, does not add character slots, does not modify the normal default launcher, and does not touch browser runtime.

## Work Completed

Changed:

- Reduced the player-slice ground-material UV scale from `0.72` to `0.56`.
- Reduced texture opacity to `0.48` and applied a restrained tint.
- Added a procedural value underlay beneath the texture overlay for the two authorized foothold ground surfaces.
- Updated runtime status to report `visualHardeningCheckpoint`, hardened UV scale, noise-control alpha, mipmap filter posture, and underlay visibility.
- Updated launch, review, validate, capture, and report tooling to write v0.178 evidence and reject the old v0.177 UV/noise posture.
- Updated capture checkpoint detection so v0.178 uses the bounded ground-material review steps.

Created:

- `docs/V0178_GROUND_MATERIAL_VISUAL_QA_UV_HARDENING.md`
- `docs/V0178_GROUND_MATERIAL_BENCHMARK_BOUNDARY.md`
- `docs/V0178_IMPLEMENTATION_REPORT.md`

## Launcher

Use:

```text
GODOT_REVIEW_SALTO_GROUND_MATERIAL_OPT_IN_WINDOWS.bat
```

Equivalent npm script:

```text
npm run godot:review:salto-ground-material-opt-in
```

The review posture remains:

```text
Experimental opt-in art: 5 slots + Barrosan foothold ground
```

## Validation

Command:

```text
npm run godot:validate:salto-ground-material-opt-in
```

Result:

```text
PASS_V0178_SALTO_GROUND_MATERIAL_UV_NOISE_HARDENING_AUTOMATION_READY
```

Primary evidence:

- Validation: `artifacts/desktop-spikes/godot-salto/v0178/validation/ground-material-opt-in-validation-report.json`
- Capture: `artifacts/desktop-spikes/godot-salto/v0178/capture/ground-material-opt-in-capture-report.json`
- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0178/capture/v0178-ground-material-uv-noise-hardening-contact-sheet.svg`
- Benchmark: `artifacts/desktop-spikes/godot-salto/v0178/benchmark/ground-material-opt-in-benchmark-scorecard.json`
- Boundary: `artifacts/desktop-spikes/godot-salto/v0178/boundary/ground-material-opt-in-boundary-report.json`
- Cleanup dry-run: `artifacts/desktop-spikes/godot-salto/v0178/cleanup-dry-run/salto-experimental-cleanup-report.json`
- Retention: `artifacts/desktop-spikes/godot-salto/v0178/artifact-retention/salto-experimental-artifact-retention-report.json`

## Visual Decision

v0.178 accepts the hardened material posture. The texture still reads as a rough Barrosan foothold material, but lower UV repetition, alpha damping, and the procedural underlay reduce the v0.177 high-frequency carpet effect. Roads, river, bridge, site markers, selection rings, character billboards, Barracks material, HUD, and minimap remain legible in automated captures and live Windows-side Computer Use review.

## Boundary

Zero images generated. Zero slots added. The existing single ground-material environment slot remains opt-in only. Character-slot integration stays frozen at five. Default launchers remain procedural. All earlier launchers remain preserved. No browser wiring, save, stable-ID, gameplay, pathing, objective, AI, balance, campaign, production-manifest, or package-leak mutation was made.

v0.179 is not part of this checkpoint.
