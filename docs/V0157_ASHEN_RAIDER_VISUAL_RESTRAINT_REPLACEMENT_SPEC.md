# v0.157 Ashen Raider Visual-Restraint Replacement Spec

v0.157 is a private-comparator-only replacement test for the existing Ashen Raider hostile slot.

- Existing slot: `ashen_raider_billboard_static_v0156`
- New replacement source: `artifacts/desktop-spikes/godot-salto/v0157/local-ashen-raider-restrained-replacement/ashen_raider_billboard_static_v0157_restrained_source.png`
- Archived comparison source: `artifacts/desktop-spikes/godot-salto/v0156/local-ashen-raider-slot/ashen_raider_billboard_static_v0156_source.png`
- Comparator: `desktop-spikes/godot-salto/comparators/runtime_art_pipeline/ashen_raider_visual_restraint_replacement_comparator.gd`

The replacement exists because v0.156 was technically valid but had a large weapon silhouette review concern. v0.157 preserves that v0.156 source/cutout as comparison evidence, generates exactly one restrained replacement source, creates deterministic fullres/512/768/1024 candidates, and stops for human review.

Scope boundaries:

- Exactly one new AI image for v0.157.
- Same hostile Ashen Raider private comparator slot only.
- No sixth runtime-art slot.
- No normal Salto player-slice mutation.
- No browser runtime wiring.
- No final art approval or production import.
- Do not begin v0.158.

Acceptance gate:

- The tracked fallback, archived v0.156 cutout, and all v0.157 derivatives must be benchmarked through the same billboard render path.
- Tier L requires at least five headed trials per approach.
- A preferred v0.157 derivative can be selected only if it passes the preserved performance/readability gate and the visual-restraint flags.
