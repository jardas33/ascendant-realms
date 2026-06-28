# v0.261 Barrosan Watchpost Foundation

Verdict: `PARTIAL`

## Exact facts

- Base commit: `4164a8060c9c3ba75a1744421aa85200b692ac53`.
- Implementation commit: `fd41519` local pre-publication commit.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Review pack: `artifacts/manual-review/v0261-barrosan-watchpost-foundation/`.
- Default runtime unchanged: yes.
- Blender used: no.
- New GLB exported: no.
- Combat/projectiles/waves added: no.
- Economy generation/resource gathering added: no.
- Watchpost is passive only: yes.
- Watchpost cost: 100 Crowns / 30 Stone / 10 Iron / 0 Aether.
- Watchpost HP: 120/120.
- Resource sequence: 420/160/90/38 -> 240/40/90/38 -> 140/10/80/38.
- Existing Field Barracks construction/rebuild/training sequences remain validated in their own v0.259/v0.260 path.

## Watchpost proof

- Watchpost runtime status: PASS.
- HUD/state resolver invariant status: PASS.
- Resource sequence status: PASS.
- Minimap marker status: PASS.
- WATCH ZONE overlay status: PASS.
- Barracks training after Watchpost status: PASS.
- Impossible HUD combinations: absent in proof snapshots.

## Pixel / screenshot validation

- Required screenshots: 21.
- Runtime capture count: 17.
- PNG files inspected for black-frame rejection: 18.
- Minimum PNG bytes: 127982.
- Minimum sampled unique colors: 1792.
- Minimum mean brightness: 56.929.
- Minimum brightness standard deviation: 15.398.
- Screenshots are non-black/readable: yes.

## Recommendation for v0.262

- Promote the passive Watchpost foundation into an explicit detection/vision or command-aura slice only after preserving this UI-state separation; do not add tower attacks/projectiles until that is separately authorized.

Stop before v0.262.
