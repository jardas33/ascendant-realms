# v0.115 Emmanuel Performance Decision Packet

## Decision Summary

The trusted browser performance gate remains RED. Do not start runtime art integration or broad browser visual expansion from this evidence.

Recommended next decision: move the reviewed architecture or engine-spike discussion earlier, before more browser-runtime visual work.

## Contributions

Host pressure contribution: low in automated evidence. v0.111 controls and clean-profile runs show healthy blank, simple DOM, simple canvas, and true Phaser-empty rows.

Browser environment contribution: limited. Browser controls are healthy, but app-specific game surfaces are not.

Battle code contribution: high. Tier M battle remains around 2.4-2.6 FPS with p95 frame time around 500-566.7 ms across trusted rows.

Fixed costs: high. Empty/static battle shell rows remain slow before full representative density, which means a baseline scene/HUD/game-shell cost is still present.

Density costs: high. Tier S, Tier M, and Tier L all remain below AMBER, and Tier L historically reached 716.5 ms p95.

Safe gains: real but insufficient. v0.112 removed safe allocation/idle work, v0.113 added exact-semantics spatial/pathing reuse and counters, and v0.114 reduced renderer lifecycle churn with visual parity.

Unresolved costs: fixed battle shell cost, representative density cost, app-specific DOM/HUD/campaign/results cost, and remaining pathing/targeting cost.

## Art Integration

Runtime art integration should not begin. Browser-runtime visual expansion should stay stopped until either the browser gate moves to AMBER/GREEN or a separately approved architecture direction accepts a different runtime target.

Non-runtime art discussion can continue only as planning material. Do not mark assets loadable, import generated art, change runtime asset paths, or widen visual runtime scope under v0.115.

## Engine Or Architecture Timing

The engine-spike or reviewed architecture discussion should move earlier. The current evidence says bounded local browser optimizations have not changed the acceptance posture enough to support more visual runtime work.

## What Would Change This Decision

- Clean-restart evidence shows Tier M consistently reaches AMBER or GREEN thresholds.
- A reviewed architecture plan accepts the browser prototype's current performance limits and narrows the runtime goal.
- A separately approved performance rescue produces trusted before/after evidence that moves the gate out of RED without changing gameplay, saves, stable IDs, or art posture unsafely.
