# v0.277 Barrosan Engage Armed Readability and HUD-First Arbitration Report

- Verdict: `PASS`.
- Base commit: `4671036f5733d5f16f9d79efa03eecc132a9f523`.
- Implementation commit: `1dae51592c5499d1e9986a6c2fa1decbac97f551`.
- Final HEAD: `PENDING_PUBLICATION`; finalized in post-push handoff after exact-SHA CI completes.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`; finalized in post-push handoff after exact-SHA CI completes.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0277-barrosan-engage-armed-readability-hud-first-arbitration/`.

## Boundary confirmation

- v0.277 is readability only: yes.
- Combat, attack, projectile, enemy HP/death/despawn, and damage added: no.
- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- Engage remains Militia-only and remains unavailable outside the valid v0.276 post-contact bridge-held / engagement-contained path.
- Engage Armed uses one high-priority world label maximum: `ENGAGE ARMED`.
- Lower-priority world labels are suppressed/demoted while armed: `ENGAGEMENT CONTAINED`, `BRIDGE HELD`, `CONTACT RESOLVED`, `DEFENDER POSITION`, `GUARD BRIDGE`.
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

## Recommendation for v0.278

- If separately authorized, v0.278 can begin a bounded explicit combat-resolution bridge from this armed state. Keep it narrow: one order, one target, one consequence, and preserve this HUD-first label arbitration.

Stop before v0.278.
