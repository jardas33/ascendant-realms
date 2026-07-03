# v0.283 Barrosan Non-Lethal Ashen Pressure Response Report

- Verdict: `PASS`.
- Base commit: `5bca383ea33454a2b720a0af5e6bfd4636b36633`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0283-barrosan-non-lethal-ashen-pressure-response/`.

## What changed

- Opt-in v0.283 Commit Engage now produces one passive Ashen response state: `ASHEN BRACED`.
- Player-side `PRESSURE CHECKED` remains exactly one.
- Pressure still changes from 90 to 80 exactly once; repeat commit does not stack.
- Clear Guard removes/settles both player commit and Ashen response labels cleanly.
- Watchpost and Barracks do not receive Engage, Commit Engage, or Ashen-braced actions.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.283 review steps.
- No projectile, HP damage, enemy damage, death, despawn, movement, pathing, AI, waves, fog, economy, or default mutation was added.
- Stale labels remain absent: `ENGAGE ARMED` after commit, `ASHEN APPROACH`, `ENGAGEMENT CONTAINED`, `BRIDGE HELD`, `GUARD BRIDGE`, `CONTACT RESOLVED`, and `INTERCEPT READY`.

## Pixel validation

- Required review images: 18.
- PNG files inspected for black-frame rejection: 15.
- Minimum PNG bytes: 35419.
- Minimum sampled unique colors: 294.
- Minimum mean brightness: 22.411.
- Minimum brightness standard deviation: 9.704.

Stop before v0.284.
