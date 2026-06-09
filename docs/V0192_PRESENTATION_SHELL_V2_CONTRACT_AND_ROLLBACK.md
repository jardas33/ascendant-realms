# v0.192 Presentation Shell V2 Contract And Rollback

Status: `PASS_V0192_PRESENTATION_SHELL_V2_CONTRACT`

Scope: documentation-only contract for one future isolated opt-in Godot presentation-shell v2 prototype. This file does not implement shell v2.

## Selected Architecture

Use a parallel visual-only compositor path inside the existing Godot Salto spike.

The safest Godot-compatible representation is:

- One new explicit opt-in flag, expected as `--salto-presentation-shell-v2`.
- One new v2 visual root, separate from the legacy terrain/root presentation nodes.
- Read-only reuse of the existing runtime state for unit, structure, site, route, objective, and selection positions.
- Procedural geometry only: route ribbons, shaped quads/polygons, simple box masses, and cached `StandardMaterial3D` resources.
- Prefer `ArrayMesh` or other built-in Godot procedural mesh support for road, river, bank, and terrain ribbons when a single coherent surface is clearer than many box strips.
- No collision shapes, navigation shapes, pathing adapters, stable-ID changes, save writes, AI changes, objective changes, or gameplay state mutation.
- Explicit material/hash reporting for existing five character slots plus selected ground and road materials.
- Fallback to the prior opt-in shell if v2 initialization fails.

This architecture is safer than a production-renderer rewrite because it keeps the same Godot scene, the same runtime fixture, the same launch/build tooling shape, and the same validation artifact model. It is visually meaningful because it gives roads, river, banks, bridge, and terrain a new composition root instead of layering more corrective rectangles on the old shell.

## Required V2 Surface Contract

| Surface | V2 requirement | Forbidden in v2 |
| --- | --- | --- |
| Scoped foothold terrain | A small number of coherent ground surfaces that frame play space and existing materials | Full terrain rewrite, default-art enablement, new image generation |
| Roads | Route-following ribbons that connect Command Hall, mine, Barracks, bridge, and hostile approach | Wide unrelated bands, floating diagnostic crowns, road material outside opt-in |
| River | One continuous channel with limited bends and clear under-bridge continuity | Disconnected water strips, water shader pipeline, wet-granite integration |
| Banks | Shaped lips/edges that frame the channel and crossing | Repeated thin bank strips used as the main read |
| Bridge | Deck, abutments, and simple low rails that read as one crossing | More material slots, stacked decorative rectangles, broad stone replacement |
| Structures | Command Hall, mine, Barracks, and site shells as coherent masses | New structure material slot, gameplay production changes, collision changes |
| Characters | Restrained contact grounding under existing selected character slots | New character slot, changed pivots/hashes/sources, default art enablement |
| Markers/overlays | Minimal rings, labels, and minimap support only where already needed for review | Broad translucent review pads or diagnostic overlays |

## Runtime Boundary

The shell-v2 path must not mutate:

- Browser runtime.
- Default procedural launcher.
- Existing prior launchers.
- Gameplay rules.
- Pathing or collision truth.
- Objectives.
- AI behavior.
- Saves or localStorage.
- Stable IDs.
- Campaign data.
- Selected source art, derivatives, metadata, or tracked fallbacks.
- Wet-granite bridge-riverbank material posture.

## Fallback Contract

The future v0.193 implementation must report:

- Whether shell v2 was requested.
- Whether shell v2 initialized.
- Whether fallback to the prior opt-in shell was used.
- The fallback reason if v2 does not initialize.
- Node counts for v2 versus the legacy comparator.
- Ground and road selected hashes.
- Five character-slot selected hashes.
- Confirmation that wet-granite bridge-riverbank material was not loaded into the player-facing slice.

If v2 fails, the prior ground+road+five-slot R1 posture must remain available and playable.

## Rollback

To roll back a future v0.193 shell-v2 implementation:

1. Remove the explicit shell-v2 launcher and matching validate/capture wrappers.
2. Remove the `--salto-presentation-shell-v2` script argument dispatch.
3. Remove the shell-v2 compositor functions/root and v2 status reporting.
4. Remove only v0.193 shell-v2 evidence/docs/tooling that the future checkpoint adds.
5. Preserve legacy shell code, default launcher, prior launchers, selected local art, active derivatives, metadata, tracked fallbacks, historical review evidence, and unknown files.

Rollback must not touch gameplay/runtime truth because v2 is required to be visual-only.

## Gate

This contract selects one bounded architecture and preserves the old shell as fallback/comparator. v0.193 is prepared but not started by v0.192.
