# v0.250 Barrosan Explicit Attack Order Bridge

Verdict: `PARTIAL`

## Exact facts

- Resolved base commit: `61d8671d5b8a15dc137273124c6e775082c13822`.
- Base exact-SHA CI: https://github.com/jardas33/ascendant-realms/actions/runs/27911616624.
- Implementation commit: `PENDING_PUBLICATION`.
- Final repository HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Blender used: no. New GLB exported: no. Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Files changed: opt-in runtime subclass, capture dispatch, v0.250 evidence/validator/report tooling, package scripts and this report.
- Runtime systems touched: opt-in Militia Attack targeting state, one Raider target, order-authorized closing/contact, HUD and target marker.
- Default systems untouched: browser/default Godot runtime, global combat, AI, waves, buildings, economy, saves, pathfinding and assets.

## Bounded bridge

- Construction: one Field Barracks, -180 Crowns / -120 Stone.
- Production: one Militia, -60 Crowns / -20 Iron.
- Raider ID/count: `v0247_ashen_raider_00` / 1.
- Attack implementation: Attack arms targeting mode; next hostile click targets the only scripted Raider.
- Attack arms targeting mode; the next hostile click accepts only the single scripted Raider.
- Combat starts only after accepted order plus Militia and Raider within 115-unit intercept/contact radius.
- HP sequence: 100/60 -> 90/40 -> 80/20 -> 70/0.
- Raider removed: true; minimap removed: true; contained by attack order: true.
- Resources unchanged after combat: true; buildings unharmed: true; Aster/Worker unharmed: true.
- Existing Barracks / Keep / Mine preserved: true / true / true.
- Shells remain non-producing: true.
- Default runtime proof: opt-in skin disabled, no Raider, targeting marker, attack ladder, or bounded combat state.
- Pathing honesty: review-grade rectangular destination-nudge only.

## Validation results

- v0.250 capture and dedicated validator: pass.
- Full local validation: pass (887 tests, production build, content/art/runtime gates, Godot tests, retention, and `godot:all`).
- Exact-SHA GitHub Actions: pending publication.

## Honest assessment

The explicit two-step order is real and readable, but remains a single-target bounded bridge over review-grade closing/pathing and deterministic contact ticks. Verdict remains PARTIAL.
Recommendation for v0.251: harden natural player-issued targeting feedback without adding waves, broad AI, building damage, or general combat.

Stop after v0.250. Do not begin v0.251.
