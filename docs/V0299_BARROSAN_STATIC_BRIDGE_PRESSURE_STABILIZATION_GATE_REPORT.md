# v0.299 Barrosan Static Bridge Pressure Stabilization Gate

Base: `d41847989b2d29bb22d13b22b136081022a54b08`

Branch: `codex/v0215-v0226-recovery`

## Scope

This checkpoint adds one opt-in static review gate after `SUPPORT INTEGRATED`. Selecting Reserve Support exposes `Stabilize Line`; the review fixture then shows `BRIDGE PRESSURE STABILIZED`, one `PRESSURE STABILIZED` marker, and deterministic `Pressure 70/100` support text.

The true default runtime is unchanged. This slice adds no movement, pathfinding, route following, combat, damage, HP loss, projectiles, death/despawn, AI, waves, fog, economy/resource mutation, or dynamic deployment behavior.

## Preserved contract

The v0.287-v0.298 static chain remains intact, including the v0.295 five-segment controlled route preview, v0.297 static Reserve Support presence, and v0.298 static bridge-line integration visual. Repeat stabilization is idempotent and does not stack pressure or duplicate markers/visuals.

## Evidence

- Dedicated runtime capture: `artifacts/desktop-spikes/godot-salto/v0299/static-bridge-pressure-stabilization-gate-runtime/`
- Dedicated validator: `tools/godot/saltoV0299BarrosanStaticBridgePressureStabilizationGateTool.mjs`
- Review pack: `artifacts/manual-review/v0299-barrosan-static-bridge-pressure-stabilization-gate/`
- Capture command: `npm run godot:capture:salto-barrosan-static-bridge-pressure-stabilization-gate`
- Validator command: `npm run godot:validate:salto-barrosan-static-bridge-pressure-stabilization-gate`

The deterministic state proof is recorded in the v0.299 runtime manifest. The current headless renderer reports expected viewport-texture-unavailable warnings; the retained windowed capture frames in the manual-review pack are the visual evidence used for the non-black review and contact-sheet gate.

## Validation ledger

The closeout runs the v0.299 validator, retained v0.298 through v0.269 validators, the v0.259 UI invariant validator, core npm/content/art/runtime checks, artifact retention, `npm run godot:all`, and `git diff --check` before commit and exact-SHA CI confirmation.
