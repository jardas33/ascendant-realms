# v0.267 Barrosan Watchpost Defender Positioning Bridge Report

- Verdict: `PARTIAL`.
- Base commit: `42877dba3cef802b2e575bbb80929f1663024b14`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0267-barrosan-watchpost-defender-positioning-bridge/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- Combat/projectiles/tower attack/damage/slow/redirect/spawn/despawn added: no.
- Enemy AI/pathing/wave timing changed: no.
- Economy mutation/resource generation/discount/speedup added: no.
- Fog-of-war or broad RTS vision added: no.
- Watchpost remains passive/intel/advisory/readiness/positioning only.
- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.
- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Militia training remains existing Field Barracks production only; Watchpost never trains Militia.

## Positioning confirmation

- Readiness states retained: none, training, ready.
- Positioning states added: none, pending, not in position, holding east bridge.
- Positioning derives from existing Militia source position and the passive east bridge defensive-area radius.
- Current detection and last-seen memory remain distinct.
- Outside-zone state does not trigger ASHEN SCOUTED, Threat in WATCH ZONE, or holding-position alarm.
- No positioning/advisory appears before Watchpost completion.
- No impossible UI combinations were accepted.
- v0.264/v0.265/v0.266 readability retained by dedicated validators plus v0.267 world-label proof.

## Pixel validation

- Required screenshots: 29.
- Runtime capture count: 25.
- PNG files inspected for black-frame rejection: 26.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 15.687.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.268

- If authorized, build a bounded next tactical coaching layer from this passive positioning proof. Do not add attacks, projectiles, fog-of-war, enemy retiming, auto-move, or broad RTS vision without a new v0.268 scope.

Stop before v0.268.
