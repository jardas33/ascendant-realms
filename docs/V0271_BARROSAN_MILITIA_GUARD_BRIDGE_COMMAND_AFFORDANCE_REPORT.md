# v0.271 Barrosan Militia Guard Bridge Command Affordance Report

- Verdict: `PARTIAL`.
- Base commit: `64384021d8ca06931d760fbd14dd422469e63ef8`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0271-barrosan-militia-guard-bridge-command-affordance/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- v0.271 adds player-facing Guard Bridge command affordance only.
- Automatic movement: no.
- Automatic attack: no.
- Watchpost remains passive/advisory/intel only and does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.
- v0.269/v0.270 consequence preserved: Ashen pressure integrity 100/100 -> 90/100 only once.
- New damage below 90/100: no.
- Guard order is required for contact eligibility: yes.
- Guard pending does not trigger contact; Militia away from bridge does not trigger contact; current detection without guard order does not trigger contact.
- Last-seen memory cannot trigger new contact damage; outside-zone state does not trigger false contact.
- Enemy death/despawn: no. Militia HP loss: no. Watchpost HP loss: no.
- Projectiles/tower attack: no. Enemy slow/stop/redirect: no.
- Pathing/AI/wave/economy/default-runtime mutation: no.
- Fog-of-war or broad vision system: no.
- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.
- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Field Barracks remains the only Militia training source.
- Watchpost never shows Train Militia and never shows Guard Bridge as a Watchpost action.
- Barracks never shows full Watchpost relay card.

## State confirmation

- Readiness states retained: none, training, ready.
- Positioning states retained: none, pending, not in position, holding east bridge.
- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.
- Contact states retained: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.
- Feedback/cooldown states retained: first contact feedback active, first contact feedback expired, first contact resolved/cooldown locked.
- New guard-order states: unavailable, available, pending, holding east bridge, cancelled reserved/not exposed, resolved after contact.
- Label clutter remains improved versus v0.269 by preferring HUD/objective copy and using one subtle guard bridge marker.

## Pixel validation

- Required screenshots: 45.
- Runtime capture count: 41.
- PNG files inspected for black-frame rejection: 42.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 15.798.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.272

- Next slice can safely add a small explicit cancel/clear-guard affordance or one bounded post-contact follow-up. Do not infer combat, attack animation, projectiles, death/despawn, fog, economy, AI, pathing, or broad vision.

Stop before v0.272.
