# v0.289 Barrosan reserve support order prepared step Report

- Verdict: `PASS`.
- Base commit: `094788075cfa2933cc67477283e0bc5aa33ebc07`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0289-barrosan-reserve-support-order-prepared-step/`.

## What changed

- Added a static opt-in `Prepare` state after the accepted v0.288 `RESERVE ACK` state.
- The Field Barracks card exposes `Prepare support available`, then `Support order ready` / `Awaiting deployment approval`.
- The East bridge defender card acknowledges `Support order ready` without deployment or movement.
- Repeating Prepare preserves one `ORDER READY` label, one support order, and one static reserve marker.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.289 review steps.
- v0.288 Signal / Reserve ACK, v0.287 Reserve Assigned, v0.286 Reserve Ready, and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before support-order preparation.
- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, route preview, AI, waves, fog, economy, deployment, or default mutation was added.

## Pixel validation

- Required review images: 43.
- PNG files inspected for black-frame rejection: 39.
- Minimum PNG bytes: 39273.
- Minimum sampled unique colors: 309.
- Minimum mean brightness: 22.552.
- Minimum brightness standard deviation: 9.827.

Stop before v0.290.
