# v0.295 Barrosan Static Deployment Route Preview Gate

## Scope

One opt-in, static authored preview gate after FINAL RELEASE READY. It adds no deployment, movement, pathfinding, unit launch, combat, AI, fog, economy, resource, or true-default-runtime mutation.

## Base

- Base HEAD: `91d250132c3a911a5cf5d86004f211d896e2fa64`
- Branch: `codex/v0215-v0226-recovery`

## Behavior

Field Barracks exposes `Preview Route` after FINAL RELEASE READY. The preview locks `ROUTE PREVIEW LOCKED`, draws exactly five fixed guide segments toward the east-bridge support area, and creates exactly one `ROUTE PREVIEW` marker. The segments are authored `MeshInstance3D` overlays: there is no path computation or route following.

## Preserved and absent systems

The accepted v0.287–v0.294 chain and labels remain intact. Aster, reserve militia, and defender remain static. The v0.292 selected-card/global-prompt separation remains enforced, including no raw validator prose, no text/button overlap, and no stale `Select Aster` text in selected cards.

## Evidence

- Review pack: `artifacts/manual-review/v0295-barrosan-static-deployment-route-preview-gate/`
- Validator: `tools/godot/saltoV0295BarrosanStaticDeploymentRoutePreviewGateTool.mjs`
- Command: `npm run godot:validate:salto-barrosan-static-deployment-route-preview-gate`
- Retained v0.294 through v0.269 validators and the v0.259 UI invariant validator passed.
- Full local suite passed: 887 tests, production build, content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check`.
- Exact-SHA CI and final clean/sync evidence are recorded after push.
