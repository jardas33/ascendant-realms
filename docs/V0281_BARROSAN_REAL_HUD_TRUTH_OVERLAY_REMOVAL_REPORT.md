# v0.281 Barrosan Real HUD Truth Overlay Removal Report

- Verdict: `PASS`.
- Base commit: `e971ed1948f7efdf3674beaa5911e7b449343c51`.
- Implementation commit: recorded by Git history for this report commit; exact SHA is reported in final handoff after publication.
- Final HEAD: reported in final handoff after push.
- Exact-SHA GitHub Actions run: reported in final handoff after push.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0281-barrosan-real-hud-truth-overlay-removal/`.

## Boundary confirmation

- v0.279 armed-state screenshot truth retained: yes. Armed state still renders exactly `ENGAGE ARMED`.
- v0.281 removes the v0.280 review-only card overlay from the normal/manual review capture path: yes.
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
- Real selected-unit HUD/card while armed carries: Militia Defender | East bridge, Engage armed, Engagement stance: contained, Bridge held, Pressure contained 90/100, No auto-move, No ranged attack, No projectile, No attack committed, Commit Engage available.
- Real selected-unit HUD/card after commit carries: Militia Defender | East bridge, Engagement committed, Pressure checked 80/100, Commit locked, Bridge held, No projectile, No unit damage, No enemy death/despawn, No repeat pressure effect.
- Repeat Commit Engage clicks do not stack pressure, labels, markers, attacks, projectiles, or damage.
- Clear Guard after commit removes the commit world label cleanly and does not restore pressure automatically.
- Reguard after Clear Guard restores availability without repeating the already committed consequence.
- Watchpost and Barracks never show Engage or Commit Engage. Field Barracks remains the only Militia training source.
- Watchpost remains passive/advisory/intel only.
- Ashen pressure invariant retained: first contact drops 100/100 -> 90/100 once; manual Commit Engage checks pressure to 80/100 once; no unit/enemy damage.

## Pixel validation

- Required screenshots: 18.
- Runtime capture count: 14.
- PNG files inspected for black-frame rejection: 15.
- Minimum PNG bytes: 127739.
- Minimum sampled unique colors: 1865.
- Minimum mean brightness: 57.074.
- Minimum brightness standard deviation: 17.506.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.282

- If separately authorized, a future slice can decide whether this stateful checked-pressure result becomes a true combat-resolution order. Keep it narrow and preserve rendered-node arbitration.

Stop before v0.282.
