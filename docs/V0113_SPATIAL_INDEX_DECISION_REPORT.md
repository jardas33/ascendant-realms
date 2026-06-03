# v0.113 Spatial Index Decision Report

Decision: do not add a quadtree, grid index, or broad spatial-index rewrite in v0.113.

Rationale:

- Existing target acquisition depends on unit-then-building scan order and first same-distance winner behavior.
- A broad index would require new tie-order, invalidation, and collision/visibility rules beyond this checkpoint.
- The exact cache and same-frame path request reuse provide lower-risk evidence-backed wins inside the authorized boundary.

Measured profile rows available: 14.

No AI strategy, target priority, path results, movement outcomes, collision/capture/combat balance, saves, IDs, art, engine posture, desktop, multiplayer, or content changes.
