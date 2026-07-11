# v0.296 Barrosan Static Deployment Order Authorization Gate

## Scope

This opt-in review-only checkpoint adds one narrow visual state after v0.295
`ROUTE PREVIEW LOCKED`: `Authorize Deploy` resolves to the static top strip
`DEPLOYMENT ORDER AUTHORIZED` and one world marker reading `DEPLOY AUTHORIZED`.
The five v0.295 authored route-guide segments remain visible and unchanged.

## Boundaries

The checkpoint is not a deployment implementation. It adds no movement,
pathfinding, route following, launch, combat, damage, HP loss, projectiles,
death/despawn, AI, waves, fog, economy/resource mutation, or true-default
runtime mutation. Aster, reserve militia, defender, and Field Barracks remain
static. Repeat authorization is idempotent.

## Visual contract

- `Authorize Deploy` is available only after the retained route-preview state.
- `DEPLOYMENT ORDER AUTHORIZED` appears once in the top strip.
- `DEPLOY AUTHORIZED` appears once at the route end.
- Defender and Field Barracks selected cards show their final-ready static
  states without a global prompt in the card, text overlap, or button-row
  overlap.

## Evidence and validation

- Base: `2f1853ae510af667253c47c1d50214b27338bbea`
- Branch: `codex/v0215-v0226-recovery`
- Runtime capture root:
  `artifacts/desktop-spikes/godot-salto/v0296/static-deployment-order-authorization-gate-runtime/`
- Review pack:
  `artifacts/manual-review/v0296-barrosan-static-deployment-order-authorization-gate/`
- Dedicated validator:
  `npm run godot:validate:salto-barrosan-static-deployment-order-authorization-gate`

The review pack contains 35 numbered capture artifacts: availability, click,
authorized strip and marker, retained route, static role cards, repeat action,
negative boundary proof, contact sheet, and black-frame rejection report.
