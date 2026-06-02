# v0.104 Evidence-Backed Optimization Report

## Evidence Boundary

This pass starts from the committed v0.103 profiler artifacts in `artifacts/performance/v0103/` and the ranked triage in `docs/V0104_PROFILER_TRIAGE_REPORT.md`. Those artifacts are local deterministic QA evidence, not hardware-independent benchmark proof.

## Implemented Changes

- Moved the battle HUD cadence gate ahead of snapshot construction. Forced refreshes still update immediately, and ordinary frame updates now skip resource/minimap/objective/selection snapshot work until the existing 0.1s UI cadence is reached.
- Added public Minimal HUD density by visually hiding optional detail copy while keeping essential controls, resources, minimap, selected entity posture, tutorial, status, and menu surfaces usable.
- Added private-only Standard and Debug HUD density controls for review and profiler comparison.
- Added Debug density counters for HUD updates, minimap refreshes, fog redraws, Lume links/endpoints, graphics, labels, DOM, and display object posture.
- Cached minimap markup by a deterministic render signature so unchanged marker/camera/ping/fog state returns the prior SVG markup.
- Skipped redundant fog overlay redraws when the non-visible fog-cell state signature has not changed.
- Skipped redundant Lume graphics clear/redraw cycles when the rendered link and endpoint signature is unchanged.
- Added v0.104 profiler scenarios for Minimal, Standard, and Debug HUD densities.
- Updated profiler scripts to write v0.104 artifacts under `artifacts/performance/v0104/` and produce a v0.103-to-v0.104 delta report.

## Guardrails Preserved

- No gameplay, balance, AI, pathing, map, faction, art, reward, save, Retinue, relic, reputation, localStorage, Lume damage multiplier, or stable ID change.
- No save migration.
- No production Debug controls.
- No broad renderer rewrite or unmeasured batching system.

## Expected Signals

- Lower HUD/minimap snapshot work during ordinary frames because unchanged frames return before snapshot construction.
- Lower fog redraw counts in stable camera/fog states.
- Lower Lume graphics redraw work for stable hidden/auto/standard postures.
- DOM reduction is expected only where Minimal density hides optional visible copy; full-detail Standard remains available for private review.

## Profiler Result

`npm run perf:profile:private` completed 20 v0.104 scenarios and wrote artifacts under `artifacts/performance/v0104/`. `npm run perf:report:private` refreshed `performance-summary.md` and `performance-delta.md`.

The generated v0.104 delta shows HUD/minimap update-rate reductions across every matching battle scenario in the 1200 ms local sample window. The reductions range from -1.54/s to -3.16/s in matching battle scenarios, while campaign/results non-battle scenarios remain unchanged at 0/s. Absolute p95 frame timing is mixed on this local machine, so this checkpoint claims reduced redundant rendering work rather than a universal FPS improvement.

Notable matching-scenario deltas:

- `perf_selected_worker`: p95 683.3 ms to 466.7 ms, HUD/minimap -2/s.
- `perf_fog_heavy_camera`: p95 566.7 ms to 466.6 ms, HUD/minimap -2.22/s.
- `perf_lume_activation_pulse`: p95 583.3 ms to 500 ms, HUD/minimap -2/s.
- `perf_battle_baseline`: p95 466.7 ms to 700 ms, HUD/minimap -1.54/s, documenting the mixed p95 boundary.
- `perf_results_disclosure`: p95 333.3 ms to 733.4 ms, HUD/minimap unchanged at 0/s, documenting non-battle timing noise outside the rendering-skip target.

v0.104-only HUD density scenarios were captured as `perf_hud_minimal`, `perf_hud_standard`, and `perf_hud_debug`; each completed with 0/s HUD/minimap rates in the sampled summary.
