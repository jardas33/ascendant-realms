# v0.104 Profiler Triage Report

## Evidence Boundary

This triage uses the v0.103 private profiler artifacts in `artifacts/performance/v0103/` and the v0.103 reports. The data is local deterministic QA evidence, not a hardware-independent benchmark. No v0.104 optimization work begins until this ranked triage exists.

Baseline commit: `230cca71f5fcb4b78428791dd36df663ab24884f`

## Ranked Cost Triage

1. Top measured cost: `perf_selected_worker`
   - p95 frame time: 683.3 ms.
   - max frame time: 683.3 ms.
   - long-task total: 1002 ms.
   - Counters: 573 DOM nodes, 2 HUD updates/s, 2 minimap refreshes/s, 1 fog redraw/s.
   - Triage: selected-entity HUD density and repeated battle HUD/minimap refresh work are justified targets, as long as command availability and Worker teaching remain visible.

2. Second measured cost: `perf_lume_activation_pulse`
   - p95 frame time: 583.3 ms.
   - max frame time: 583.3 ms.
   - long-task total: 992 ms.
   - Counters: 627 DOM nodes, 2 HUD updates/s, 2 minimap refreshes/s, 1 fog redraw/s, 2 Lume links.
   - Triage: Lume display work is justified only around hidden or unchanged visual states. Lume rules, benefits, objective logic, and `linked_ward` remain untouched.

3. Third measured cost: `perf_fog_heavy_camera`
   - p95 frame time: 566.7 ms.
   - max frame time: 566.7 ms.
   - long-task total: 893 ms.
   - Counters: 503 DOM nodes, 2.22 HUD updates/s, 2.22 minimap refreshes/s.
   - Triage: redundant fog/minimap/HUD refreshes are justified targets when the underlying view model has not changed. Fog rules and visibility semantics remain untouched.

4. Costs that appeared significant but secondary
   - `perf_selected_squad`: p95 516.7 ms, long-task total 1621 ms, recurring HUD/minimap updates.
   - `perf_minimap_interaction`: p95 466.7 ms, long-task total 1804 ms, recurring HUD/minimap updates.
   - `perf_battle_baseline`: p95 466.7 ms, recurring HUD/minimap/fog counters.
   - Triage: these support optimizing repeated HUD/minimap work rather than broad renderer rewrites.

5. Costs that appeared insignificant for this pass
   - `perf_campaign_map_interaction`: no long tasks and no HUD/minimap/fog counters despite p95 400 ms.
   - `perf_results_disclosure`: no long tasks and no HUD/minimap/fog counters, p95 333.3 ms.
   - Triage: campaign/results rendering is not a v0.104 optimization target.

6. Costs that remain uncertain
   - Absolute FPS and frame times vary by machine and Playwright sampling window.
   - The profiler reports counters, not stack-level attribution, so exact Phaser renderer cost is not proven.
   - Long-task totals show battle-scene pressure, but they do not prove a single subsystem owns the whole cost.
   - Triage: pursue narrow, reversible reductions with before/after profiler comparison rather than speculative batching or broad scene rewrites.

## v0.103 Changes Already Applied

- Stable capture-site ring opacity and width were reduced.
- Quiet friendly/neutral capture-site labels were hidden by default.
- Lume Auto hides stable active links after transition pulses unless an endpoint is selected.
- Lume Hidden and Always remain explicit modes.
- Optional Lume link prose moved behind Details.
- Private Performance Lab and profiler artifacts were added for future evidence-backed optimization.

## v0.104 Changes Still Justified

- Skip HUD DOM rerendering when the battle HUD view model is unchanged.
- Throttle or skip minimap redraws when the minimap state signature is unchanged.
- Avoid drawing hidden or unchanged Lume lines.
- Avoid label work when labels are hidden or unchanged.
- Reduce redundant fog visual redraws when visible-cell state is unchanged.
- Defer hidden private/debug panel rendering and remove inactive profiler observation work when disabled.
- Collapse public battle HUD density by default while preserving critical commands, objective, alerts, resources, hero status, minimap, Tutorial, and Help.

## Rejected For Insufficient Evidence

- Broad Phaser renderer batching or object pooling beyond existing patterns.
- Gameplay, balance, AI, pathing, save, reward, progression, stable-ID, map, faction, art, desktop, multiplayer, PvP, co-op, or networking changes.
- Final art, generated images, imported assets, or terrain dressing.
- New global settings architecture or save-persistent HUD density.
- Any optimization that cannot be mapped to v0.103 evidence and compared in v0.104 profiler artifacts.
