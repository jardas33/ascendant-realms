# v0.284 Barrosan HUD/Text Layout Repair Report

- Verdict: `PASS`.
- Base commit: `57a229804fd3e37cb9e55f0219b34742b17b5de4`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0284-barrosan-hud-text-layout-repair/`.

## What changed

- Added an opt-in v0.284 HUD/text layout wrapper over the retained v0.283 state bridge.
- Selected-unit card now uses four short game-facing rows: name/role, primary state, tactical facts, and readiness.
- Button row is explicitly separated from the text rect and checked by deterministic layout diagnostics.
- Top status strip uses concise vocabulary only.
- The manual fixture `Select Aster.` copy is held inside the selected-card facts row instead of floating beside the card.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.284 review steps.
- v0.283 pressure/ASHEN BRACED state proof remains the source of truth.
- No projectile, HP damage, enemy damage, death, despawn, movement, pathing, AI, waves, fog, economy, or default mutation was added.

## Pixel validation

- Required review images: 20.
- PNG files inspected for black-frame rejection: 16.
- Minimum PNG bytes: 35698.
- Minimum sampled unique colors: 297.
- Minimum mean brightness: 22.418.
- Minimum brightness standard deviation: 9.71.

Stop before v0.285.
