# v0.113 Evidence-Backed Optimization Report

Implemented optimizations:

- Combat target acquisition now uses a cached frame entity list and first-ID lookup map, preserving old unit-then-building order.
- Movement pathing now reuses identical same-frame path requests and clones path waypoints for each unit.
- Optional counters record path requests, path cache hits, entity lookup counts, target scans, visited entities, and distance calculations while private phase profiling is enabled.

Combat signal rows: 5.
Path signal rows: 7.

No AI strategy, target priority, path results, movement outcomes, collision/capture/combat balance, saves, IDs, art, engine posture, desktop, multiplayer, or content changes.
