# v0.287 Barrosan Reserve Assigned To Bridge Step Report

- Verdict: `PASS`.
- Base commit: `465aa5eb3fe0a5b1745fe06d2500c12aa89ac2ab`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0287-barrosan-reserve-assigned-to-bridge-step/`.

## What changed

- Added a static opt-in `Assign` state after the accepted v0.286 `RESERVE READY` state.
- Field Barracks selected-card text now shows Assign availability, then `RESERVE ASSIGNED` / bridge support pending.
- The East bridge defender card acknowledges pending reserve support without changing combat behavior.
- Repeating Assign preserves one assignment marker and records no duplicate assignment state.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.287 review steps.
- v0.286 Reserve Ready and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before assignment.
- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, deployment, or default mutation was added.

## Pixel validation

- Required review images: 31.
- PNG files inspected for black-frame rejection: 27.
- Minimum PNG bytes: 39643.
- Minimum sampled unique colors: 306.
- Minimum mean brightness: 22.565.
- Minimum brightness standard deviation: 9.835.

Stop before v0.288.
