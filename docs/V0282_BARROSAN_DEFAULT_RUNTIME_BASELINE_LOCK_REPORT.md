# v0.282 Barrosan Default Runtime Baseline Lock Report

- Verdict: `PASS`.
- Base commit: `242815a1802521cb01670f9a14150f5829806707`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Ledger: `docs/V0282_BARROSAN_DEFAULT_RUNTIME_BASELINE_LEDGER.json`.
- Review pack path: `artifacts/manual-review/v0282-barrosan-default-runtime-baseline-lock/`.

## Baseline ledger separation

- True default runtime: captured without Barrosan opt-in and without the v0.281 manual review fixture path.
- Barrosan manual review fixture: retained v0.281 review steps are active, Barrosan opt-in remains disabled.
- Opt-in readability runtime: retained v0.281 review steps are active and Barrosan opt-in is enabled.
- The pack no longer labels a fixture capture as `default runtime unchanged`.

## Boundary confirmation

- Gameplay expansion: no.
- Combat/projectile/HP damage/enemy death/despawn/pathing/AI/economy/fog/waves/runtime mutation: no.
- v0.281 Engage/Commit readability behavior retained: yes.
- v0.281 removed v0.280 review-card overlay remains absent: yes.
- Real HUD/card remains single and clean: yes.
- Watchpost/Barracks still do not expose Engage or Commit: yes.
- Manual Commit Engage still checks pressure 90/100 -> 80/100 once, with no projectile, unit damage, enemy death/despawn, repeat stack, pathing, AI, economy, or fog change.

## Pixel validation

- Required review images: 19.
- PNG files inspected for black-frame rejection: 16.
- Minimum PNG bytes: 35899.
- Minimum sampled unique colors: 300.
- Minimum mean brightness: 22.436.
- Minimum brightness standard deviation: 9.713.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.283

- Proceed only after this baseline lock remains green remotely; the next slice may then decide whether to extend combat, but this checkpoint intentionally does not.

Stop before v0.283.
