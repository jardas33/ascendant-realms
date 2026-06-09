# v0.176 Terrain Material Risk And Rollback

Status: `PASS_V0176_TERRAIN_MATERIAL_RISK_PACKET`

This report documents future v0.177 risks without implementing the terrain-material slot.

## Primary Risks

Visual readability:

- The selected material may lower road, bridge, river-bank, site-marker, selection-ring, or unit silhouette contrast.
- The material may look too dark or too noisy at normal RTS distance.
- Tiling may become obvious when the camera zooms out.

Technical:

- Incorrect UV scale could make the material read as either mud noise or giant stones.
- Missing-art/hash-mismatch fallback could accidentally disable the existing five selected opt-in slots if wired too broadly.
- Texture import settings could create blur, shimmer, or mipmap transitions that weaken tactical readability.
- A player-slice material path could accidentally load private comparator fallback assets or ignored local files without explicit contract checks.

Scope:

- Broad terrain replacement would exceed the approved next step.
- Road, river, bridge, site-marker, structure, and minimap art changes would exceed the approved next step.
- Any default launcher art enablement would violate the established boundary.

## Rollback Design

Future v0.177 should be reversible by removing only:

- The new opt-in terrain-material launcher and wrappers.
- The single terrain-material slot contract.
- The normal-slice terrain-material binding.
- The future validation/capture/benchmark evidence and docs created by v0.177.

Rollback should not require touching:

- Default procedural launchers.
- Prior Worker/Barracks/Militia/Aster/Ashen opt-in launchers.
- Browser runtime.
- Saves or stable IDs.
- Gameplay rules, objectives, AI, balance, or campaign state.
- v0.175 private comparator evidence.

## Fallback Requirements

Future v0.177 must prove two fallback modes:

- Missing selected terrain material.
- Hash-mismatched selected terrain material.

Both fallback modes must render a playable procedural ground posture, keep the five selected character/material slots intact when using the new opt-in launcher, and report the fallback reason clearly in evidence.

## Stop Conditions For v0.177

Stop and do not push as accepted if any of these occur:

- Default launcher gains art by default.
- Browser runtime changes.
- More than one terrain-material slot is added.
- Any character slot is added.
- The selected v0.175 material is replaced or regenerated.
- Road/river/bridge/site-marker readability regresses and cannot be repaired without broad scope.
- Benchmark falls below the defined performance gates.
- Missing-art or hash-mismatch fallback fails.
- Cleanup detects unknown files.

## v0.176 Boundary

v0.176 generated zero images, added zero slots, modified no runtime code, deleted no historical evidence, and did not start v0.177.
