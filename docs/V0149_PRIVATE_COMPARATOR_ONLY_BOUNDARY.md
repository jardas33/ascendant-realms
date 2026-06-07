# v0.149 Private Comparator-Only Boundary

v0.149 tests only one Barrosan Barracks material slot inside the private hybrid comparator.

## Allowed

- Use exactly one new generated material source image.
- Generate deterministic 512, 768, and 1024 derivatives from that same source.
- Add a tracked deterministic diagnostic fallback.
- Use the selected v0.148 Worker derivative as existing comparator context when present.
- Build one low-complexity procedural Barracks shell inside the private comparator.
- Benchmark and capture Tier S/M/L private evidence.
- Update docs and handoff files for the review stop.

## Forbidden

- No third runtime-art slot.
- No second Barracks material slot.
- No extra generated images.
- No existing reference candidate import.
- No generated reference image import.
- No downloaded assets.
- No normal map, roughness map, metallic map, emissive map, model, sprite, animation, HUD art, Aster art, Worker art, or environment scene generation.
- No production runtime-art integration.
- No normal Salto player-facing scene mutation.
- No default launcher replacement.
- No browser runtime mutation.
- No runtime manifest mutation.
- No production art-slot registry mutation.
- No production package inclusion.
- No save changes.
- No stable-ID changes.
- No final Barracks architecture approval.
- No final material-pack approval.
- No final runtime-art approval.
- No final engine choice.
- No full port.
- No multiplayer, campaign, economy, broad content, or v0.150 work.

## Current Posture

The material source and derivatives are ignored local evidence only. `HYBRID_BARRACKS_LOCAL_768` passed the preserved Tier L gate and is the selected human-review derivative, but passing the gate still stops for human review and does not authorize importing the Barracks material into the normal Salto player slice.
