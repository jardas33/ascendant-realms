# v0.114 Procedural Batching Spec

Allowed batching and caching are presentation-only and deterministic.

- Static battlefield terrain flecks, shadow patches, grass strokes, and pebbles are cached by map identity/size/count signature before being drawn into the existing Phaser Graphics surface.
- Road, water, blocked-ground, buildable-ground, and capture-site placeholder geometry keeps the same draw order and colors; polyline strokes avoid transient sliced arrays.
- Capture rings, labels, health bars, fog overlay, Lume links, command markers, minimap snapshots, and HUD markup use no-op guards or due/dirty caches only where the incoming presentation state is unchanged.
- Command feedback markers reuse one Graphics plus one Text child per pooled container and clear state before reuse.

No art, gameplay, balance, AI, pathing, fog simulation, saves, stable IDs, engine posture, desktop, multiplayer, content, public benchmark posture, or v0.115 work changed.
