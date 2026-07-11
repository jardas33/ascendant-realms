# v0.297 Barrosan Static Reserve Support Deployment Execution Gate

## Scope

Opt-in review-only static confirmation after v0.296 authorization. `Execute Deploy` resolves to `RESERVE SUPPORT DEPLOYED`, one `SUPPORT DEPLOYED` marker, and one static East bridge support presence.

## Base HEAD and branch

- Base: `3c2feb5d3be1f0bb96784959d5f126754f72a201`
- Branch: `codex/v0215-v0226-recovery`

## What changed

- Static Execute Deploy selected-card state after deployment authorization.
- One static support marker and one static support-presence disc at East bridge.
- Deployed Barracks, Defender, and selectable Reserve Support card truth.

## What did not change

The accepted v0.287-v0.296 chain, v0.295 five-segment route preview, true default runtime, positions of existing units, pressure, and resources are retained. No animation, movement, pathfinding, route following, combat, damage, HP, projectiles, death, AI, waves, or fog was added.

## Evidence

The dedicated proof asserts exactly one deployed strip, marker, and support presence; five controlled static route segments; idempotence; readable card layout; and all forbidden systems absent.

- Review pack: `artifacts/manual-review/v0297-barrosan-static-reserve-support-deployment-execution-gate/`
- Validator: `npm run godot:validate:salto-barrosan-static-reserve-support-deployment-execution-gate`

The final closeout records the retained validator ladder, full local checks, exact-SHA CI, and clean synchronized repository state.
