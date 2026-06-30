# v0.268 Barrosan Watchpost Militia Intercept Preview Bridge Report

- Verdict: `PARTIAL`.
- Base commit: `59bd21888f1ad78349abf0cfaa9b430349ca8743`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0268-barrosan-watchpost-militia-intercept-preview-bridge/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- Combat/projectiles/tower attack/damage/slow/redirect/spawn/despawn added: no.
- Enemy AI/pathing/wave timing changed: no.
- Economy mutation/resource generation/discount/speedup added: no.
- Fog-of-war or broad RTS vision added: no.
- Watchpost remains passive/intel/advisory/readiness/positioning/intercept-preview only.
- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.
- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Militia training remains existing Field Barracks production only; Watchpost never trains Militia.

## Intercept preview confirmation

- Readiness states retained: none, training, ready.
- Positioning states retained: none, pending, not in position, holding east bridge.
- Intercept-preview states: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.
- Intercept ready requires current detection, ready Militia, holding east bridge, and Ashen inside the intercept-preview envelope.
- Intercept preview causes no damage, slow, redirect, attack, projectile, collision, or pathing effect.
- Current detection and last-seen memory remain distinct.
- Outside-zone state does not trigger ASHEN SCOUTED, Threat in WATCH ZONE, or intercept ready.
- No intercept-preview appears before Watchpost completion.
- No impossible UI combinations were accepted.
- v0.264/v0.265/v0.266/v0.267 readability retained by dedicated validators plus v0.268 proof.

## Pixel validation

- Required screenshots: 33.
- Runtime capture count: 29.
- PNG files inspected for black-frame rejection: 30.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 15.687.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.269

- If authorized, use this as the final pre-combat readability proof before a separately scoped first real engagement/consequence slice. Do not add attacks, projectiles, fog-of-war, enemy retiming, auto-move, or broad RTS vision without a new v0.269 scope.

Stop before v0.269.
