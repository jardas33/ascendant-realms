# v0.417 Secondary Barn Wall-Body Material Value Hierarchy

## Scope

This opt-in checkpoint evaluates a single existing material boundary: the visible secondary-barn wall-body surfaces. It does not reopen v0.409, v0.410, v0.415, or v0.416 and does not modify geometry, gameplay, camera, lighting, the main house, bridge, route, terrain, roof, gable, doorway, or foundation.

## Baseline and decision

- Base HEAD: `ca50f2a4ab547d0f9210cd59e378cbf0670a991d`
- Branch: `codex/v0215-v0226-recovery`
- Dynamic role: `BARN_WALL_BODY`
- Exclusions: roof, gable, eaves, doorway, windows, posts, beams, base, foundation, shadow, hidden or occluded surfaces
- Candidate material: existing visible wall-body nodes only, `#5b5147`, roughness `0.96`, specular `0.08`
- Fail-closed status when the accepted asset does not expose a safe isolated wall body: `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_WALLS`

The runtime audit is the authority. Real colour, grayscale, diagnostic, and comparison renders are retained; a material candidate is not accepted from validator text alone.

The live inventory exposed one eligible node, `V0399_Barn_Main_Walls`, and no other wall-body candidate was admitted. The reviewed close colour and comparison captures are nonblank and show the secondary structure in context; roof, gable, trim, doorway, and adjacent main-house surfaces remain visually separate. The candidate is retained as a deliberately subordinate wall value, not as a new asset or a geometry workaround.

## Preservation

The accepted barn roof/gable/door/foundation silhouette and all inherited v0.416 material-only evidence remain unchanged. The audit records material-only operation, zero new mesh instances, unchanged geometry/topology/indices/vertices/surfaces/transforms/AABB/UV arrays, unchanged state/default/fallback/debug renderers, and no gameplay mutation.

## Evidence and validation

- Runtime evidence: `desktop-spikes/godot-salto/artifacts/runtime/v0417/`
- Review pack: `artifacts/manual-review/v0417-secondary-barn-wall-value-hierarchy/`
- Launch: `npm run godot:play:v0417-secondary-barn-walls`
- Smoke: `npm run godot:smoke:v0417-secondary-barn-walls`
- Capture: `npm run godot:capture:v0417-secondary-barn-walls`
- Validator: `npm run godot:validate:v0417-secondary-barn-walls`

The v0.417 smoke and capture wrappers both completed successfully. The dedicated validator passed with one dynamic wall node and seven real PNG captures. Retained validators v0.400, v0.401, and v0.406-v0.416 also passed; v0.409, v0.410, v0.415, and v0.416 remained explicitly fail-closed where their asset boundaries were not safely isolatable.

The retained ladder covers v0.416 through v0.400, including the earlier fail-closed asset-boundary gates, followed by tests, build, content/art/runtime/artifact validation, `npm run godot:all`, and `git diff --check` before checkpoint closeout.

## Conclusion

v0.417 remains a narrow secondary-barn wall-body material study. If the live asset inventory cannot expose a semantically isolated wall-body surface, the checkpoint closes honestly as `ASSET_MATERIAL_LIMITATION_SECONDARY_BARN_WALLS` with no replacement geometry or visual workaround.
