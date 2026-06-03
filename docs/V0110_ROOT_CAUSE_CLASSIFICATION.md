# v0.110 Root Cause Classification

Classification is evidence-backed only for rows present in the latest artifact set. Missing rows remain unresolved rather than guessed.

## Slowest Rows

1. v0110_tier_l_density: p95 666.7 ms, top phase Status effects.
2. v0110_ai_paused: p95 566.7 ms, top phase Status effects.
3. v0110_simulation_paused: p95 550 ms, top phase Lume presentation.
4. v0110_labels_hidden: p95 533.3 ms, top phase Status effects.
5. v0110_hud_dom_paused: p95 533.3 ms, top phase Status effects.

## Current Finding

Use subsystem deltas and phase summaries to target a later approved optimization goal. v0.110 does not start a broad renderer or engine rewrite.
