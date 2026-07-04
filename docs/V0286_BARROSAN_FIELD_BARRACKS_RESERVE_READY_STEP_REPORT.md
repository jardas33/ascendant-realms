# v0.286 Barrosan Field Barracks Reserve Ready Step Report

- Verdict: `PASS`.
- Base commit: `049ffefc6303a81cce19ecdc91cac16098a0d78e`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0286-barrosan-field-barracks-reserve-ready-step/`.

## What changed

- Added a static opt-in `RESERVE READY` marker after the accepted v0.285 Hold Line state.
- Field Barracks selected-card text now shows Train Militia availability, then reserve ready / no deployment.
- Repeating Train preserves one marker and records no duplicate reserve state.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.286 review steps.
- v0.285 Engage -> Commit -> Hold Line flow remains unchanged before Barracks Train.
- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, deployment, or default mutation was added.

## Pixel validation

- Required review images: 27.
- PNG files inspected for black-frame rejection: 23.
- Minimum PNG bytes: 39453.
- Minimum sampled unique colors: 312.
- Minimum mean brightness: 22.548.
- Minimum brightness standard deviation: 9.821.

Stop before v0.287.
