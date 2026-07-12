# v0.304 Runtime Transition Options

| Option | Description | Decision |
|---|---|---|
| Keep v0.302/v0.303 as PLAYER baseline | Continue polishing procedural depth/material layers | Reject as the primary art route. Retain only as deterministic fallback and evidence renderer. |
| Keep v0.302/v0.303 as DEBUG/proof layer | Preserve the accepted state/marker/capture contracts and use the procedural scene for validation | Accept. This protects the long gameplay/state chain while visual work moves to a separate opt-in presentation path. |
| Replace the stable runtime immediately | Import historical references or v0.236 assets directly into the current player fixture | Reject. Historical frames are reference-only; v0.236 is isolated and partial. |
| Add a new opt-in authored environment lane | Build one bounded R1-aligned sector from the retained Blender/GLB pipeline; keep current gameplay IDs and presentation contracts outside it until visual review passes | Recommend. This is the safest route to a credible vertical slice. |
| Full 3D units now | Replace procedural/billboard units with animated 3D characters | Defer. Use original billboard/sprite units first, with exact pivots, scale and contact proof. |

## Proposed transition contract

1. Keep the current v0.303 PLAYER/DEBUG_REVIEW implementation unchanged as fallback/proof.
2. Create a new opt-in authored-environment presentation flag in a future checkpoint, never true-default.
3. Reuse stable IDs, positions, selection semantics, minimap data, HUD information architecture and state chain.
4. Introduce only one representative sector first: river crossing, road junction, Main Hall/Keep, Field Barracks and one mine/ruin/shrine landmark.
5. Do not import the reference PNGs into runtime. Re-author original geometry/materials from the R1/R2 rules and verify IP posture before any production asset intake.
6. Compare the authored lane against v0.303 with real non-headless screenshots before reconnecting more gameplay or expanding the roster.
