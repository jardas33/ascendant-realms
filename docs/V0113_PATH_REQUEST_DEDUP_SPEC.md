# v0.113 Path Request Dedup Spec

Authorized behavior is exact same-frame reuse only.

- Cache key: current world start point, current world target point, and `allowPartial` posture.
- Cache lifetime: one `MovementSystem.update` call.
- Reuse boundary: identical request only; no fuzzy clustering, no path simplification, no target snapping, and no cooldown/timing change.
- Result boundary: waypoints are cloned into each unit state so no unit shares mutable path arrays.
- Existing unchanged-destination reuse remains per-unit and is now counted for private evidence.

No AI strategy, target priority, path results, movement outcomes, collision/capture/combat balance, saves, IDs, art, engine posture, desktop, multiplayer, or content changes.
