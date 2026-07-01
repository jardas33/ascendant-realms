# v0.273 Barrosan Militia Brace Bridge Post-Contact Hold Report

- Verdict: `PARTIAL`.
- Base commit: `45d85d2686679784c2d00da45a67f4de4fe95a6b`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0273-barrosan-militia-brace-bridge-post-contact-hold/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- v0.273 adds Brace Bridge / Bridge Held post-contact hold readability only, while preserving Guard Bridge and Clear Guard from v0.271-v0.272.
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
- Watchpost never shows Train Militia, Guard Bridge, or Clear Guard as a Watchpost action.
- Barracks never shows full Watchpost relay card.

## State confirmation

- Readiness states retained: none, training, ready.
- Positioning states retained: none, pending, not in position, holding east bridge.
- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.
- Contact states retained: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.
- Feedback/cooldown states retained: first contact feedback active, first contact feedback expired, first contact resolved/cooldown locked.
- Guard-order states retained/extended: unavailable, available, pending, holding east bridge, cleared, resolved after contact.
- Post-contact hold states added: not braced, brace available, bracing bridge, bridge held, brace cleared.
- Label clutter remains improved versus v0.269 by replacing resolved contact ping/label with one subtle Bridge Held marker.

## Pixel validation

- Required screenshots: 47.
- Runtime capture count: 43.
- PNG files inspected for black-frame rejection: 44.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 15.78.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.274

- Next slice can safely add one bounded downstream response to Bridge Held. Do not infer combat, attack animation, projectiles, death/despawn, fog, economy, AI, pathing, or broad vision.

Stop before v0.274.
