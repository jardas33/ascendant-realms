# v0.263 Barrosan Watchpost Intel Memory

Verdict: `PARTIAL`

## Exact facts

- Base commit: `4f42d4dbdb21f8d28931b5be1192632f1a754fc4`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack: `artifacts/manual-review/v0263-barrosan-watchpost-intel-memory/`.
- Default runtime unchanged: yes.
- Blender used: no.
- New GLB exported: no.
- Combat/projectiles/tower attack added: no.
- Enemy AI/pathing/wave timing changed: no.
- Economy generation/resource gathering added: no.
- Watchpost remains passive/intel-only: yes.
- Watchpost cost: 100 Crowns / 30 Stone / 10 Iron / 0 Aether.
- Watchpost HP: 120/120.
- Resource sequence: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Field Barracks construction/rebuild/training sequences are retained and separately validated.

## Passive intel-memory proof

- Intel memory status: PASS.
- Current detection status: PASS.
- Outside-zone false-positive status: PASS.
- Last-seen memory-after-detection status: PASS.
- Memory-not-current status: PASS.
- No precomplete intel status: PASS.
- Current/memory minimap status: PASS.
- World memory marker status: PASS.
- Passive/intel-only status: PASS.
- Resource sequence status: PASS.
- Impossible HUD combinations: absent in proof snapshots.
- Current detection only appears while the Ashen marker touches/enters WATCH ZONE.
- Last-seen memory only appears after a real detection, and uses last-seen copy/ghosting instead of `ASHEN SCOUTED`.
- No threat ever scouted shows `No threat in watch zone` / `No prior Ashen intel`.
- Watchpost incomplete shows no detection and no memory.

## Pixel / screenshot validation

- Required screenshots: 21.
- Runtime capture count: 17.
- PNG files inspected for black-frame rejection: 18.
- Minimum PNG bytes: 127739.
- Minimum sampled unique colors: 1865.
- Minimum mean brightness: 57.074.
- Minimum brightness standard deviation: 15.851.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.264

- If authorized, use the passive memory to drive a bounded command-aura or player-facing warning-history loop. Do not add attacks, projectiles, fog-of-war, enemy retiming, or broad RTS vision without a new scope.

Stop before v0.264.
