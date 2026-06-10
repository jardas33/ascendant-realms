# v0.195 Implementation Report

Status: `PASS_V0195_IMPLEMENTATION_REPORT`

Date: 2026-06-09

## Summary

v0.195 restores restrained scoped terrain and road hierarchy only inside the isolated Godot Salto presentation-shell v2 review path. It preserves the clean v0.194 topology, avoids broad material masks and detached islands, keeps the wet-granite bridge-riverbank source unintegrated, and stops before v0.196.

## Implementation

Runtime changes:

- Updated the shell-v2 status checkpoint to `v0.195` with scoped-material recovery assertions.
- Tuned ground and road material alpha/tint/filtering so the selected Barrosan foothold materials read at review distance.
- Expanded `_create_presentation_shell_v2_terrain()` with six connected ground-material surfaces, ten connected road-material surfaces, route crowns, route cores, shoulder shadows, and readability ticks.
- Added v0.195-specific review focus actions for road network, intersections, road-to-bridge transition, and bridge close-up captures.
- Preserved terrain base count, detached-island count, floating-fragment count, river continuity, bridge alignment, and legacy-shell fallback posture.

Tooling changes:

- Added v0.195 launch, review, validate, and capture Windows wrappers.
- Added `tools/godot/saltoShellV2ScopedMaterialRecoveryTool.mjs` for validation, capture, benchmark, boundary scan, and retention evidence.
- Added npm scripts for `godot:launch/review/capture/validate:salto-shell-v2-scoped-material-recovery`.

Docs added:

- `docs/V0195_SCOPED_MATERIAL_RECOVERY_QA_BENCHMARK.md`
- `docs/V0195_SCOPED_MATERIAL_BOUNDARY_ROLLBACK.md`
- `docs/V0195_IMPLEMENTATION_REPORT.md`

## Validation

Final v0.195 gates:

- `npm run godot:validate:salto-shell-v2-scoped-material-recovery`
- `npm run godot:capture:salto-shell-v2-scoped-material-recovery`
- `npm run godot:cleanup:salto-experimental-artifacts -- --apply-safe-only --output-root=artifacts/desktop-spikes/godot-salto/v0195/cleanup-safe-only`
- `npm run godot:validate:salto-experimental-artifact-retention -- --output-root=artifacts/desktop-spikes/godot-salto/v0195/artifact-retention-post-cleanup`

Latest gate results:

- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_VALIDATION`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BENCHMARK`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_BOUNDARY_SCAN`
- `PASS_V0195_SHELL_V2_SCOPED_MATERIAL_CAPTURE_PACKET`
- `PASS_V0166_EXPERIMENTAL_ARTIFACT_SAFE_ONLY_CLEANUP`
- `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`
- `PASS_V0195_SALTO_SHELL_V2_SCOPED_MATERIAL_RECOVERY_VALIDATION_READY`

Benchmark result: v0.195 average FPS `75.28` versus retained v0.194 average FPS `75.17`; v0.195 p95 `13.34` ms versus retained v0.194 p95 `13.30` ms.

## Human Review

Screenshots are available under:

- `artifacts/desktop-spikes/godot-salto/v0195/capture/shell-v2-scoped-material-recovery/screenshots/`

Recommended review screenshots:

- `08_connected_road_network.png`
- `09_road_intersection.png`
- `10_road_to_bridge_transition.png`
- `12_bridge_close_view.png`

The current v0.195 shell-v2 path is more legible than the over-pruned v0.194 view, while keeping the v0.194 topology repair intact. It is still an isolated review shell, not approval to integrate wet-granite material or enable art by default.

## Stop Condition

The checkpoint stops here for human review. Do not begin v0.196.
