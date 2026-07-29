# v0.276 Barrosan Manual Engage Command Armature Report

- Verdict: `PARTIAL`.
- Base commit: `65517b41d61b265a896136f08850e4ad735684cc`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0276-barrosan-manual-engage-command-armature/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- v0.276 adds the first explicit player-owned Militia-only Manual Engage command armature.
- Engage appears only after Field Barracks, Militia, Watchpost, Guard Bridge, Bridge Held / Engagement Contained, and first contact resolved at Ashen pressure 90/100.
- Engage click arms intent only; it does not attack, damage, spawn a projectile, kill, despawn, slow, stop, redirect, alter pathing/AI/waves/economy/fog, or mutate default runtime.
- Re-clicks do not stack. Clear Guard cancels Engage. Reguard may make Engage available again and can re-arm without damage.
- Watchpost and Barracks never show Engage. Field Barracks remains the Militia training source.
- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.
- Resource sequence unchanged: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- v0.275 label arbitration remains the retained readability layer; long detail remains HUD-first.

## Pixel validation

- Required screenshots: 29.
- Runtime capture count: 25.
- PNG files inspected for black-frame rejection: 26.
- Minimum PNG bytes: 132105.
- Minimum sampled unique colors: 1939.
- Minimum mean brightness: 57.203.
- Minimum brightness standard deviation: 15.916.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.277

- If separately authorized, connect the armed Engage intent to a bounded downstream order preview while preserving the no-damage/no-projectile/no-enemy-HP boundary until combat is explicitly scoped.

Stop before v0.277.
