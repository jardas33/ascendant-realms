# Combat direction

Combat should be readable before it is complex. The minimum trustworthy loop is select → approach/order → target → visible hit/damage → health change → casualty or retreat → destruction/result. Ownership, health, target, and command state must be distinguishable at gameplay zoom.

Use a deterministic one-player-unit/one-enemy-unit/one-enemy-building scenario for causal debugging. Use a natural match only after that scenario passes. Never infer combat causality from a beauty shot or a debug-only marker.
