# v0.270 Barrosan Militia Contact Feedback and Cooldown Bridge Report

- Verdict: `PARTIAL`.
- Base commit: `7487beae674e39b34f0abd83fd27072219b56b12`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0270-barrosan-militia-contact-feedback-cooldown-bridge/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- Watchpost remains passive/advisory/intel only.
- Watchpost does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.
- v0.269 consequence preserved: Ashen pressure integrity 100/100 -> 90/100 only once.
- v0.270 adds feedback/cooldown/readability only.
- New damage below 90/100: no.
- Enemy death/despawn: no.
- Militia HP loss: no.
- Watchpost HP loss: no.
- Projectiles: no.
- Tower attack: no.
- Enemy slow/stop/redirect: no.
- Pathing/AI/wave/economy/default-runtime mutation: no.
- Fog-of-war or broad vision system: no.
- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.
- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Field Barracks remains the only Militia training source.
- Watchpost never shows Train Militia.
- Barracks never shows full Watchpost relay card.

## State confirmation

- Readiness states retained: none, training, ready.
- Positioning states retained: none, pending, not in position, holding east bridge.
- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.
- Contact states retained/extended: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.
- Feedback/cooldown state: first contact feedback active, feedback expired, resolved/cooldown locked.
- Contact requires current detection, ready Militia, holding east bridge, intercept ready, and confirmed contact threshold.
- Last-seen memory cannot trigger new contact damage.
- Outside-zone state does not trigger false contact.
- Label clutter around first contact improved versus v0.269 by hiding/moving local world labels and preferring HUD/relay contact text.

## Pixel validation

- Required screenshots: 37.
- Runtime capture count: 33.
- PNG files inspected for black-frame rejection: 34.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 15.794.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.271

- If authorized, v0.271 can separately decide whether to add a tiny animation/combat follow-up. Do not infer projectiles, tower attacks, death/despawn, pathing, AI, fog, economy, or broad RTS vision from v0.270.

Stop before v0.271.
