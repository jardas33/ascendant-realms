# v0.279 Barrosan Engage Armed World-Label Hard Fail Fix Report

- Verdict: `PASS`.
- Base commit: `4b63949d9931e2a9d72bf9fdecc46da8461a7c8c`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0279-barrosan-engage-armed-world-label-hard-fail-fix/`.

## Boundary confirmation

- v0.278 screenshot truth failed: yes. The v0.278 armed screenshot visibly retained `ENGAGEMENT CONTAINED` with `ENGAGE ARMED` in world space.
- v0.279 is screenshot-truth/readability only: yes.
- Combat, attack, projectile, enemy HP/death/despawn, and damage added: no.
- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- Engage remains Militia-only and remains unavailable outside the valid v0.276 post-contact bridge-held / engagement-contained path.
- Engage Armed uses exactly one world-space tactical label: `ENGAGE ARMED`.
- `ENGAGEMENT CONTAINED` is not visible anywhere as a competing world label while Engage is armed.
- `BRIDGE HELD` is not visible anywhere as a competing world label while Engage is armed.
- Stale/fading/pooled previous world labels are hidden while armed.
- Competing world labels are suppressed/demoted while armed: `ENGAGEMENT CONTAINED`, `BRIDGE HELD`, `CONTACT RESOLVED`, `DEFENDER POSITION`, `GUARD BRIDGE`, `CONTACT THRESHOLD`, `ASHEN SCOUTED CURRENT`, `INTERCEPT READY`, `HOLDING EAST BRIDGE`.
- HUD/card carries detailed state: Manual engage armed, Engagement contained, Bridge held, Pressure contained 90/100, No attack committed, No projectile, No damage.
- Repeat Engage clicks do not stack labels, markers, attacks, projectiles, or damage.
- Clear Guard cancels Engage cleanly and shows Guard cleared / engage cancelled state with cooldown locked at pressure 90/100.
- Reguard can make Engage available again and re-arm without repeated damage.
- Watchpost and Barracks never show Engage. Field Barracks remains the only Militia training source.
- Watchpost remains passive/advisory/intel only.
- Ashen pressure invariant retained: first contact drops 100/100 -> 90/100 only once; no damage below 90/100.

## Pixel validation

- Required screenshots: 18.
- Runtime capture count: 14.
- PNG files inspected for black-frame rejection: 15.
- Minimum PNG bytes: 137905.
- Minimum sampled unique colors: 1991.
- Minimum mean brightness: 57.298.
- Minimum brightness standard deviation: 15.916.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.280

- If separately authorized, v0.280 can begin a bounded explicit combat-resolution bridge from this armed state. Keep it narrow: one order, one target, one consequence, and preserve this rendered-node hard-fail arbitration.

Stop before v0.280.
