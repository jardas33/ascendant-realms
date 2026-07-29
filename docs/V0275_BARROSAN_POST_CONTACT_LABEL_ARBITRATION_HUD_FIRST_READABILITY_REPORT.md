# v0.275 Barrosan Post-Contact Label Arbitration and HUD-First Readability Report

- Verdict: `PASS`.
- Base commit: `7a3cbfd4c5f80273470405cc37585bff16670372`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: `PENDING_PUBLICATION`.
- Scene path: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack path: `artifacts/manual-review/v0275-barrosan-post-contact-label-arbitration-hud-first-readability/`.

## Boundary confirmation

- Default runtime unchanged: yes.
- Blender used: no.
- GLB exported: no.
- v0.275 adds label arbitration/readability only.
- v0.274 Engagement Stance, v0.273 Bridge Held, v0.272 Clear Guard, v0.271 Guard Bridge, v0.270 cooldown, and v0.269 one-time pressure consequence are retained.
- Label priority table exists: FIRST CONTACT, CONTACT RESOLVED, BRIDGE HELD, ENGAGEMENT CONTAINED, INTERCEPT READY, HOLDING EAST BRIDGE, DEFENDER POSITION, ASHEN SCOUTED CURRENT, CONTACT THRESHOLD, GUARD BRIDGE, memory/last-seen.
- First-contact, contact-resolved, bridge-held, and engagement-contained labels suppress lower-priority overlapping labels.
- HUD carries long detail; world labels are concise and limited to at most two nearby labels.
- Engagement stance does not auto-move, auto-attack, damage, or spawn projectiles; engagement visual is not a projectile.
- Ashen pressure integrity remains 90/100 after resolved contact; no damage below 90/100 and no repeated damage after clear/reguard.
- Clearing guard after contact removes engagement marker/indicator and does not restore pressure.
- Current detection without guard order, last-seen memory, and outside-zone state cannot trigger contact damage.
- No enemy death/despawn, no Militia HP loss, no Watchpost HP loss, no projectiles, no tower attack, no slow/stop/redirect, no pathing/AI/wave/economy/default-runtime mutation, no fog-of-war or broad vision.
- Watchpost remains passive/advisory/intel only and does not attack, damage, fire, train, spawn, slow, redirect, or path enemies.
- Watchpost cost/HP unchanged: 100 Crowns / 30 Stone / 10 Iron / 0 Aether; HP 120/120.
- Resource sequence unchanged: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Field Barracks remains the only Militia training source; Watchpost never shows Train Militia, Guard Bridge, Clear Guard, Brace Bridge, or Engagement Stance; Barracks never shows full Watchpost relay card.

## State confirmation

- Readiness states retained: none, training, ready.
- Positioning states retained: none, pending, not in position, holding east bridge.
- Intercept-preview states retained: unavailable, pending, cannot intercept, guarding lane, intercept ready, guarding last-seen lane.
- Contact states retained: unavailable, pending, awaiting pressure, armed, engaged, resolved, ended.
- Feedback/cooldown states retained: first contact feedback active, first contact feedback expired, first contact resolved/cooldown locked.
- Guard-order states retained: unavailable, available, pending, holding east bridge, cleared, resolved after contact.
- Brace/bridge-held states retained: not braced, brace available, bracing bridge, bridge held, brace cleared.
- Engagement stance states retained: no engagement stance, engagement stance available, engagement stance active, engagement stance cleared, engagement stance retained after reguard.
- Label clutter is improved versus v0.274 by deterministic arbitration and HUD-first detail routing.

## Pixel validation

- Required screenshots: 55.
- Runtime capture count: 51.
- PNG files inspected for black-frame rejection: 52.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 15.734.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.276

- If separately authorized, add one bounded downstream post-contact response without adding combat resolution, enemy HP/death/despawn, fog, pathing, AI, economy, or default-runtime changes.

Stop before v0.276.
