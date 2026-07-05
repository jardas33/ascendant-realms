# v0.290 Barrosan reserve deployment approval gate step Report

- Verdict: `PASS`.
- Base commit: `6b57472202aefe0eb37025b6b8ea663d2eb2b56f`.
- Baseline exact-SHA GitHub Actions run: `28743865693` (`success`).
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0290-barrosan-reserve-deployment-approval-gate-step/`.

## What changed

- Added a static opt-in `Approve` gate after the accepted v0.289 `SUPPORT ORDER READY` / `ORDER READY` state.
- Selecting the Field Barracks after support order readiness exposes `Approve` without deployment, movement, route preview, pathing, or cost.
- Approving creates one concise `DEPLOYMENT APPROVED` top status and one static `APPROVED` world label near the reserve/Barracks area.
- The Field Barracks card reads `Deployment approved` / `Awaiting launch order`; the East bridge defender card reads `Support approved` / `Bridge held | Awaiting launch`.
- Repeat Approve stays idempotent: no duplicate approval, no second state, no second marker, and no stack.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.290 review steps.
- v0.289 Support Order, v0.288 Signal / Reserve ACK, v0.287 Reserve Assigned, v0.286 Reserve Ready, and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before approval.
- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, route preview, AI, waves, fog, economy, deployment, or default mutation was added.

## Pixel validation

- Required review images: 48.
- PNG files inspected for black-frame rejection: 44.
- Minimum PNG bytes: 38428.
- Minimum sampled unique colors: 306.
- Minimum mean brightness: 22.542.
- Minimum brightness standard deviation: 9.827.

Stop before v0.291.
