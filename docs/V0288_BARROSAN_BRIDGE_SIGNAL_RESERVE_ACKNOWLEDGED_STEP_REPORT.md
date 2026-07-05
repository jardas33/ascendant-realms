# v0.288 Barrosan bridge signal reserve acknowledged step Report

- Verdict: `PASS`.
- Base commit: `04da01acfa5ee5fa8e6bdaab258750b81c957354`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0288-barrosan-bridge-signal-reserve-acknowledged-step/`.

## What changed

- Added a static opt-in `Signal` state after the accepted v0.287 `RESERVE ASSIGNED` state.
- The East bridge defender card exposes `Signal available`, then `Signal sent` / `Reserve acknowledged`.
- The Field Barracks card acknowledges `Bridge signal received` without receiving a Signal action.
- Repeating Signal preserves one `SIGNAL SENT` label, one `RESERVE ACK` label, and one static reserve marker.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.288 review steps.
- v0.287 Reserve Assigned, v0.286 Reserve Ready, and v0.285 Engage -> Commit -> Hold Line flow remain unchanged before signal acknowledgement.
- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, deployment, or default mutation was added.

## Pixel validation

- Required review images: 37.
- PNG files inspected for black-frame rejection: 33.
- Minimum PNG bytes: 39110.
- Minimum sampled unique colors: 310.
- Minimum mean brightness: 22.563.
- Minimum brightness standard deviation: 9.837.

Stop before v0.289.
