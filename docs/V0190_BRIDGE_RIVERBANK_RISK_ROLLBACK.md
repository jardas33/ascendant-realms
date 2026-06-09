# v0.190 Bridge-Riverbank Material Risk And Rollback

Status: `PASS_V0190_BRIDGE_RIVERBANK_RISK_PACKET`

This report documents future bridge-riverbank material opt-in risks without implementing the slot.

## Primary Risks

Visual readability:

- The selected wet-granite material is dark and can overpower the crossing if used beyond abutments and retaining edges.
- Road-to-bridge continuity may weaken if the material replaces road shoulders or approach lanes.
- River water contrast may collapse if the material is used on banks too broadly.
- Ground, road, bridge, and structure hierarchy may become muddy if the same stone language spreads across multiple surface families.
- Tiling, shimmer, or mipmap transitions may distract at normal RTS distance.

Technical:

- Incorrect UV scale could read as either noise or giant slabs.
- Missing-art and hash-mismatch fallback could accidentally disable the existing ground and road material opt-ins if wired too broadly.
- Texture import settings could blur the retaining-edge detail or introduce high-frequency shimmer.
- A player-slice material path could accidentally load private comparator fallbacks or ignored local files without explicit contract checks.

Scope:

- Broad stone replacement would exceed the approved next step.
- Ground, road, water, structure, minimap, HUD, marker, and character changes would exceed the approved next step.
- Any default launcher art enablement would violate the established boundary.
- Any gameplay, pathing, collision, objective, AI, save, or stable-ID mutation would violate the shell-freeze constraints.

## Rollback Design

Future implementation should be reversible by removing only:

- The new opt-in bridge-riverbank material launcher and wrappers.
- The single bridge-riverbank material slot contract.
- The normal-slice bridge-riverbank material binding.
- The future validation, capture, benchmark, boundary, fallback, and documentation evidence created by that checkpoint.

Rollback should not require touching:

- Default procedural launchers.
- Prior Worker, Barracks, Militia, Aster, Ashen Raider, ground-material, or road-material opt-in launchers.
- Browser runtime.
- Saves or stable IDs.
- Gameplay rules, pathing, collisions, objectives, AI, balance, production, restoration logic, or campaign state.
- v0.189 private comparator evidence.
- Selected local art, active derivatives, metadata, tracked fallbacks, current evidence, historical review material, or unknown files.

## Fallback Requirements

Future implementation must prove two fallback modes:

- Missing selected bridge-riverbank material.
- Hash-mismatched selected bridge-riverbank material.

Both modes must render playable procedural bridge and riverbank visuals, keep the five selected character slots plus existing ground and road material opt-ins intact when using the future launcher, and report the fallback reason clearly in evidence.

## Stop Conditions For Future Implementation

Stop and do not push as accepted if any of these occur:

- Default launcher gains art by default.
- Browser runtime changes.
- More than one bridge-riverbank material slot is added.
- Any character slot is added.
- The selected v0.189 material is replaced or regenerated.
- Ground, road, water, structure, minimap, HUD, marker, or character surfaces are modified outside the scoped bridge-riverbank binding.
- Road continuity, riverbank shape, bridge readability, or tactical crossing hierarchy regresses and cannot be repaired within the authorized scope.
- Benchmark falls below the defined performance gates.
- Missing-art or hash-mismatch fallback fails.
- Cleanup detects unknown files.

## v0.190 Boundary

v0.190 generated zero images, added zero slots, modified no runtime code, deleted no historical evidence, and did not start v0.191.
