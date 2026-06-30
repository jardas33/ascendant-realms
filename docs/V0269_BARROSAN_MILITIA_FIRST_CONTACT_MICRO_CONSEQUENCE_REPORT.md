# v0.269 Barrosan Militia First Contact Micro-Consequence Report

- Verdict: `PARTIAL`.
- Base commit: `4f172ecbacbfdeb383f1b982fe62c62f4278b315`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0269-barrosan-militia-first-contact-micro-consequence/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- Watchpost remains passive/intel/advisory/readiness/positioning/intercept-preview/contact-reporting only.
- Watchpost does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.
- Only new allowed mutation: local Ashen pressure integrity 100/100 -> 90/100 during confirmed Militia first contact.
- Repeated damage below 90/100: no.
- Enemy death/despawn: no.
- Militia HP loss: no.
- Watchpost HP loss: no.
- Projectiles: no.
- Tower attack: no.
- Enemy slow/redirect: no.
- Collision/pathing/AI/wave/economy mutation: no.
- Fog-of-war or broad vision system: no.
- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.
- Resource sequence retained: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Field Barracks remains the only Militia training source.
- Barracks still trains Militia.
- Watchpost never shows Train Militia.
- Barracks never shows full Watchpost relay card.

## State confirmation

- Readiness states retained: none, training, ready.
- Positioning states retained: none, pending, not in position, holding east bridge.
- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.
- Contact states: unavailable, pending, awaiting pressure, armed, engaged, ended.
- Contact requires current detection, ready Militia, holding east bridge, intercept ready, and confirmed contact threshold.
- Last-seen memory cannot trigger new contact damage.
- Outside-zone state does not trigger false alarm/contact.
- Label clutter around intercept/contact was reduced by prioritizing HUD/relay contact text and reserving world contact label for engaged state only.

## Pixel validation

- Required screenshots: 36.
- Runtime capture count: 32.
- PNG files inspected for black-frame rejection: 33.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 15.794.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.270

- If authorized, v0.270 can separately decide whether to graduate from this bounded integrity check into a tiny combat/animation or consequence follow-up. Do not infer projectiles, tower attacks, death/despawn, pathing, AI, fog, economy, or broad RTS vision from v0.269.

Stop before v0.270.
