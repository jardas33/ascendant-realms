# v0.110 Battle-Loop Phase Profiler Spec

The phase profiler is private Playtest Hub instrumentation. It records BattleScene.update phase timings only when v0.110 diagnostics enable `phaseProfiler=on`; the default runtime mode is off.

## Phases

- Scene/update total: Whole BattleScene.update frame envelope while private phase profiling is on.
- Input: Input-facing state changes and minimap/status timers that precede simulation work.
- Simulation clock: Runtime clock, status timers, and battle-time counters.
- Camera: Camera tracking and camera command processing.
- Abilities: Player and enemy ability update surfaces.
- Movement/pathing: MovementSystem path and unit-position update work.
- Combat/projectiles: CombatSystem, targeting, hit resolution, and projectile-facing work.
- Status effects: Timed buffs, debuffs, and veteran/status upkeep.
- Economy/production: Building, repair, resource, training, and upgrade updates.
- Lume simulation: Lume network state update using existing Linked Ward rules.
- Lume presentation: Private Lume link and endpoint graphics rendering.
- AI/strategy: Enemy pressure, Act 1 finale, battle event, and AI controller work.
- Events/cleanup: Dead entity cleanup, wave tracking, tutorial hint, and status bookkeeping.
- Fog simulation: Fog-of-war visibility source evaluation and cell-state update.
- Fog presentation: Fog overlay redraw and entity visibility application.
- HUD DOM: Battle HUD, minimap snapshot, objective, and debug counter DOM patch work.
- End conditions: Victory/defeat condition checks.

## Boundary

- Session-only diagnostics, no persistence.
- Public battle behavior and save format remain unchanged.
- Results include total, average, max, count, percent, p50, p95, and entity/count snapshots.
