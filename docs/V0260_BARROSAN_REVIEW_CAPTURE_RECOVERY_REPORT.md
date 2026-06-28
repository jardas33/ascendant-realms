# v0.260 Barrosan Review Capture Recovery

Verdict: `PARTIAL`

## Exact facts

- Base commit: `de5d043a00658fcb89d9ba541b6881413d9a7cf1`.
- Implementation commit: `PENDING_PUBLICATION`.
- Final HEAD: `PENDING_PUBLICATION`.
- Exact-SHA GitHub Actions run: PENDING_PUBLICATION.
- Scene: `res://scenes/salto_barrosan_playable_runtime_skin.tscn`.
- Old evidence issue: v0.259 uploaded review screenshots 02-29 were black/blank dummy frames.
- Root cause: v0.259 capture used headless Godot dummy rendering; when viewport texture was unavailable the v0.259 code accepted a near-black fallback image for that checkpoint.
- Capture changes made: v0.260 uses standard rendered Godot editor capture for v0.259 proof steps and adds pixel-level black-frame rejection.
- Gameplay mechanics changed: no.
- UI lifecycle resolver logic changed: no.
- Costs changed: no.
- HP/timing changed: no.
- Blender used: no.
- New GLB exported: no.
- Existing v0.239 GLB reused unchanged: yes (B7A68A4442071FB29A9DB0468B9A2A56BE724E80E2C69C0E5846539BA193D0EB).
- Default runtime unchanged: true.

## Pixel / blank-frame validation

- PNG files inspected: 28.
- Minimum PNG bytes: 124843.
- Minimum sampled unique colors: 1771.
- Minimum mean brightness: 56.827.
- Minimum brightness standard deviation: 15.439.
- Every runtime screenshot is non-black and visually readable: yes.
- HUD, minimap, terrain, buildings, and lifecycle overlays are visible in the regenerated review pack: yes.

## v0.259 invariant proof retained

- Single-source status: PASS.
- Impossible combination status: PASS.
- Forbidden text status: PASS.
- Visual overlay sync status: PASS.
- Retained mechanics status: PASS.
- Impossible UI combinations remain prevented: no build phase with rebuild/destroyed text; no rebuild phase with build/place text; no rebuilt phase with stale destroyed/rebuild text; no Select Aster beyond initial phase; no Rebuild not yet implemented.

## Mechanical proof retained

- Full resources: Construction 420/160/90/38 -> 240/40/90/38; Rebuild 240/40/90/38 -> 150/0/90/38; Train 150/0/90/38 -> 90/0/70/38.
- Full HP: 200 -> 175 -> 150 -> 125 -> 100 -> 75 -> 50 -> 25 -> 0; Rebuild 0 -> 25 -> 50 -> 75 -> 100.
- Production rule: available while HP > 0; unavailable at HP 0; unavailable during rebuild; returns at rebuilt 100/200.
- Repair remains HP 1-199 only; Rebuild remains HP 0 only. No passive collapse, rebuild, repair, or refund.

## Validation and recommendation

- Dedicated v0.260 capture and black-frame validator: pass.
- Dedicated v0.260 UI-state invariant validator: pass.
- Exact-SHA GitHub Actions: pending publication.
- Honest recommendation for v0.261: use this restored visible evidence as the review baseline; do not start new gameplay/art work without a separately authorized v0.261 prompt.

Stop before v0.261.
