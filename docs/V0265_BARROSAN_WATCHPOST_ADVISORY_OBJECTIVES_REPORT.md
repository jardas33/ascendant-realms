# v0.265 Barrosan Watchpost Advisory Objectives

Verdict: `PARTIAL`

## Exact facts

- Base commit: `e1f164c41cc52b6be10fae9ac6860df9b3eeadf4`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack: `artifacts/manual-review/v0265-barrosan-watchpost-advisory-objectives/`.
- Default runtime unchanged: yes.
- Blender used: no.
- New GLB exported: no.
- Combat/projectiles/tower attack added: no.
- Enemy AI/pathing/wave timing changed: no.
- Economy generation/resource gathering added: no.
- Watchpost remains passive/intel/advisory-only: yes.
- Watchpost cost: 100 Crowns / 30 Stone / 10 Iron / 0 Aether.
- Watchpost HP: 120/120.
- Resource sequence: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Field Barracks construction/rebuild/training sequences are retained and separately validated.

## Passive advisory-objectives proof

- Advisory objectives status: PASS.
- Advisory state status: PASS.
- Current detection status: PASS.
- Outside-zone false-positive status: PASS.
- Last-seen memory-after-detection status: PASS.
- Memory-not-current status: PASS.
- No precomplete advisory status: PASS.
- Barracks advisory-line status: PASS.
- Militia training path status: PASS.
- Current/memory minimap status: PASS.
- World label clutter status: PASS.
- Forbidden combination status: PASS.
- Passive/advisory-only status: PASS.
- Resource sequence status: PASS.
- Impossible HUD combinations: absent in proof snapshots.
- Current detection only appears while the Ashen marker touches/enters WATCH ZONE, and tells the player to prepare/train defenders.
- Last-seen memory only appears after a real detection, and uses last-seen copy/ghosting instead of current `Threat in WATCH ZONE` wording.
- No prior intel shows `Watchpost online` / `Monitor Ashen pressure` and no threat text.
- Barracks may show one Watchpost advisory line, but keeps Train Militia as existing Barracks production.
- Watchpost incomplete shows no detection, advisory, or memory.

## Pixel / screenshot validation

- Required screenshots: 25.
- Runtime capture count: 21.
- PNG files inspected for black-frame rejection: 22.
- Minimum PNG bytes: 131377.
- Minimum sampled unique colors: 1912.
- Minimum mean brightness: 57.171.
- Minimum brightness standard deviation: 16.375.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.266

- If authorized, build a bounded defender-readiness or next-action coaching loop from the passive advisory layer. Do not add attacks, projectiles, fog-of-war, enemy retiming, or broad RTS vision without a new v0.266 scope.

Stop before v0.266.
