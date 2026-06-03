# v0.112 Evidence-Backed Optimization Report

Implemented optimizations are limited to allocation and idle-work rescue where parity can be preserved.

- Status effects skip empty carriers and avoid expiry filtering unless an effect expires.
- Fog vision sources, fog current sources, and fog overlay traversal now reuse or avoid scratch allocations.
- Movement skips pathfinding-grid construction only on frames with no move target and no same-team overlap, while still updating unit buffs.
- Combat attacker collection and minimap snapshot marker construction now use ordered loops instead of spread/filter/map chains.
- Private phase-profiler count snapshots are constructed only when the profiler is enabled.

Idle matrix rows available: 8.
