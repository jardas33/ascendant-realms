# Current v0.303 Gap Analysis

The current evidence is the real non-headless capture in `current-v0303/`, not the earlier black/headless frames. It is a valid diagnosis of the opt-in PLAYER presentation, not an accepted visual target.

| Category | v0.141 R1 / v0.236 target evidence | v0.303 actual runtime | Gap |
|---|---|---|---|
| Camera / projection | High three-quarter authored composition with visible elevation and depth | Controlled orthographic camera, but framing remains close to a flat board | Camera setting exists; authored spatial composition does not. |
| Terrain | Wet granite, worked earth, grass, rock edges, readable ford and crossings | Large uniform plane with translucent procedural overlays | Missing authored terrain surface language and edge transitions. |
| Roads | Continuous stone/earth routes with believable wear and junctions | Flat strips that overlap the board | Missing continuous constructed road geometry. |
| Bridge | Bridge has deck, abutment, approach and water contact | Rectangular bridge band over a rectangular channel | Missing structure mass, support logic and landing integration. |
| Water | Recessed, reflective, irregular river/ford with banks | Narrow vertical strip with overlay value treatment | Missing bank volume and water/land relationship. |
| Buildings | Landmark silhouette, roof planes, side faces, foundation and props | Small procedural blocks with square pads and weak side planes | Missing architecture, scale hierarchy and construction grammar. |
| Units | Tiny figures grounded into a believable environment | Token/cylinder-like procedural units with broad selection circles | Missing original readable unit silhouettes and contact scale. |
| Shadows / lighting | Consistent directional light with environmental value hierarchy | Broad translucent boxes/halos and muddy values | Missing authored shadow receivers, material response and lighting composition. |
| Palette / material | Cool wet highland base, warm Barrosan construction, restrained teal accents, controlled Ashen edge | Low-contrast green/brown board with teal UI-like bands | Missing material identity and value separation. |
| UI integration | UI-safe composition is part of the frame | Actual v0.303 frame shows `Select Aster.` over the selected-card band | Concrete HUD regression in the opt-in capture/runtime path. |

## Diagnosis

This is a representation gap, not a missing polish constant. v0.303 added more procedural layers to a board-shaped representation. The historical chain changed representation: authored 2.5D references, then orthographic 3D proof, then Blender-authored modular geometry and composed environment slices. Another small shadow/material pass would not close the gap.
