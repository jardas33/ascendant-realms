# v0.193 Implementation Report

Status: `PASS_V0193_PRESENTATION_SHELL_V2_IMPLEMENTATION`

v0.193 implements exactly one isolated opt-in Godot Salto presentation-shell v2 prototype. The implementation follows the v0.192 contract: preserve the legacy shell as comparator/fallback, reuse the existing selected five character slots plus selected ground and road materials, generate zero images, add zero imported art slots, integrate no wet-granite bridge-riverbank material, and stop before v0.194.

## Added

- `GODOT_REVIEW_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`
- `GODOT_VALIDATE_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`
- `GODOT_CAPTURE_SALTO_PRESENTATION_SHELL_V2_WINDOWS.bat`
- `tools/godot/launchGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/reviewGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/validateGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/captureGodotSaltoPresentationShellV2Windows.ps1`
- `tools/godot/saltoPresentationShellV2Tool.mjs`
- `docs/V0193_SHELL_V2_PROTOTYPE_QA_BENCHMARK.md`
- `docs/V0193_SHELL_V2_BOUNDARY_ROLLBACK.md`
- `docs/V0193_IMPLEMENTATION_REPORT.md`

## Modified

- `desktop-spikes/godot-salto/scripts/salto_spike_root.gd`
- `desktop-spikes/godot-salto/scripts/salto_spike_scene_3d.gd`
- `package.json`
- Standard checkpoint docs and the Salto experimental artifact index.

## Runtime Summary

The v2 compositor is visual-only. It creates scoped terrain patches, route-following roads, a continuous river channel, bank framing, bridge crossing surfaces, simplified site markers, structure masses, and unit contact shadows. The legacy shell is not removed and remains a comparator/fallback.

The v2 review launcher copies the same selected opt-in art context used by the existing five-slot and ground+road material posture. It does not include the wet-granite bridge-riverbank material flag and does not add a new art slot.

## Validation Summary

Passed gates:

```text
PASS_V0193_PRESENTATION_SHELL_V2_VALIDATION
PASS_V0193_PRESENTATION_SHELL_V2_BENCHMARK
PASS_V0193_PRESENTATION_SHELL_V2_BOUNDARY
PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION
PASS_V0193_SALTO_PRESENTATION_SHELL_V2_VALIDATION_READY
PASS_V0193_PRESENTATION_SHELL_V2_CAPTURE
```

Benchmark result:

```text
Legacy L1 FPS: 75.15
V2 FPS: 75.16
FPS ratio: 1.0001
Legacy L1 p95: 14.29 ms
V2 p95: 13.32 ms
p95 worsening: -6.79%
```

## Human Review Notes

Windows-side review showed the initial v2 implementation still had too much broad rectangular terrain coverage. That issue was repaired by changing the v2 ground-material usage to scoped patches instead of one battlefield-sized sheet.

The resulting v2 shell is a stronger presentation prototype and a better human-review comparator. It remains intentionally procedural and should not be treated as final environment art.

## Stop Condition

v0.193 stops here for human review. Do not begin v0.194, do not integrate the wet-granite material, do not enable art by default, and do not wire anything into the browser runtime.

