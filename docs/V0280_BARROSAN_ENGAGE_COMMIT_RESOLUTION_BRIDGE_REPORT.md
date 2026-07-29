# v0.280 Barrosan Engage Commit Resolution Bridge Report

- Verdict: `PASS`.
- Base commit: `12e21632e8af6f2fb24d830972fad58f059bd07d`.
- Implementation commit: recorded in the final handoff after publication.
- Final HEAD: recorded in the final handoff after publication.
- Exact-SHA GitHub Actions run: recorded in the final handoff after publication.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0280-barrosan-engage-commit-resolution-bridge/`.

## Boundary confirmation

- v0.279 armed-state screenshot truth retained: yes. Armed state still renders exactly `ENGAGE ARMED`.
- v0.280 is a manual/stateful resolution bridge only: yes.
- Combat, attack, projectile, unit HP damage, enemy HP damage, enemy death/despawn, and recurring combat added: no.
- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- Engage and Commit Engage remain Militia-only and remain unavailable outside the valid post-contact bridge-held / engagement-contained armed path.
- Engage Armed uses exactly one world-space tactical label: `ENGAGE ARMED`.
- Commit Engage appears only in the valid armed Militia Defender state.
- One manual Commit Engage changes pressure state from 90/100 to 80/100 exactly once.
- Post-commit uses exactly one world-space tactical label: `PRESSURE CHECKED`.
- `ENGAGEMENT CONTAINED`, `BRIDGE HELD`, `CONTACT RESOLVED`, `FIRST CONTACT`, `DEFENDER POSITION`, `GUARD BRIDGE`, `CONTACT THRESHOLD`, `ASHEN SCOUTED CURRENT`, `INTERCEPT READY`, and `HOLDING EAST BRIDGE` are not visible as competing world labels while armed or committed.
- HUD/card carries detailed state: Manual engage armed, Engagement contained, Bridge held, Pressure contained 90/100, No attack committed, No projectile, No damage.
- HUD/card after commit carries: Engagement committed, Bridge held, Pressure checked 80/100, No projectile, No unit damage, No enemy death/despawn, Commit locked.
- Repeat Commit Engage clicks do not stack pressure, labels, markers, attacks, projectiles, or damage.
- Clear Guard after commit removes the commit world label cleanly and does not restore pressure automatically.
- Reguard after Clear Guard restores availability without repeating the already committed consequence.
- Watchpost and Barracks never show Engage or Commit Engage. Field Barracks remains the only Militia training source.
- Watchpost remains passive/advisory/intel only.
- Ashen pressure invariant retained: first contact drops 100/100 -> 90/100 once; manual Commit Engage checks pressure to 80/100 once; no unit/enemy damage.

## Pixel validation

- Required screenshots: 17.
- Runtime capture count: 13.
- PNG files inspected for black-frame rejection: 14.
- Minimum PNG bytes: 157347.
- Minimum sampled unique colors: 2088.
- Minimum mean brightness: 56.239.
- Minimum brightness standard deviation: 19.052.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.281

- If separately authorized, v0.281 can decide whether this stateful checked-pressure result becomes a true combat-resolution order. Keep it narrow and preserve rendered-node arbitration.

Stop before v0.281.
