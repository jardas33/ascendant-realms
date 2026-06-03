# v0.112 Implementation Report

v0.112 implements battle-loop scheduler documentation, hot-path allocation audit artifacts, idle-cost profiling, and bounded runtime allocation reductions.

## Runtime Changes

- Fog source creation and fog overlay traversal use reusable/visitor paths.
- Empty status-effect carriers no longer allocate or tick helper work.
- Idle movement frames without move targets or same-team overlap skip grid construction.
- Combat and minimap marker collection avoid spread/filter/map allocation chains.
- Private phase-profiler count snapshots are disabled when the profiler is off.

## Scope Guard

No gameplay semantics, AI decision rules, pathfinding outputs, saves, stable IDs, art, engine posture, desktop work, balance, or public content were intentionally changed.

Idle matrix rows measured: 8.
