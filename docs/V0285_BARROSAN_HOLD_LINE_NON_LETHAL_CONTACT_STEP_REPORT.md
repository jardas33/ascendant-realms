# v0.285 Barrosan Hold Line Non-Lethal Contact Step Report

- Verdict: `PASS`.
- Base commit: `f5e0c81b8cf221d2637a8ed19fc511d525a4a15c`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Review pack path: `artifacts/manual-review/v0285-barrosan-hold-line-non-lethal-contact-step/`.

## What changed

- Added the opt-in `HOLD LINE` follow-up after the v0.283/v0.284 Commit Engage locked state.
- Hold Line changes the selected Militia Defender card to `Line held` and shows `Bridge held | Pressure 80/100 | Ashen contained`.
- The post-Hold world state renders `LINE HELD` near the defender and `ASHEN CONTAINED` near the Ashen side exactly once.
- Repeating Hold Line is locked to the same state and cannot duplicate labels or stack pressure.

## Boundaries retained

- True default runtime remains unmodified and does not dispatch v0.285 review steps.
- v0.284 HUD/text layout contract remains the layout source: four readable rows, button row separated, concise top strip.
- v0.283 pressure/ASHEN BRACED state remains unchanged until Hold Line is invoked.
- No projectile, HP damage, enemy HP loss, unit HP loss, death, despawn, movement, pathing, AI, waves, fog, economy, or default mutation was added.

## Pixel validation

- Required review images: 22.
- PNG files inspected for black-frame rejection: 18.
- Minimum PNG bytes: 38777.
- Minimum sampled unique colors: 309.
- Minimum mean brightness: 22.544.
- Minimum brightness standard deviation: 9.813.

Stop before v0.286.
