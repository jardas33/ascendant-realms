# v0.370 Quaternius Cohesive Art-Family Proof

This is an isolated, opt-in PLAYER visual sandbox for one Salto bridge sector.
It is not the accepted v0.368 runtime and it does not change gameplay, saves,
stable IDs, resources, pressure, movement, combat, or the true default route.

## Open the evidence

1. Start with `01_QUATERNIUS_WIDE.png` for the full rendered composition.
2. Use `02_QUATERNIUS_RTS_CAMERA.png` for ordinary RTS framing.
3. Use `03_QUATERNIUS_CLOSE_DETAIL.png` for building/unit scale.
4. Use `04_QUATERNIUS_BRIDGE_CONTACT.png` for bridge, road, and recessed stream.
5. Use `05_QUATERNIUS_HOSTILE_CAMP.png` for authored camp composition.
6. Use `06_ORIGINAL_VS_QUATERNIUS_COMPARISON.png` for the v0.368 baseline comparison.

## Commands

- `npm run godot:play:quaternius-proof`
- `npm run godot:smoke:quaternius-proof`
- `npm run godot:capture:quaternius-proof`
- `npm run godot:validate:quaternius-proof`

The scene is `res://scenes/v0370_quaternius_visual_proof.tscn` and is routed
only by the explicit `--v0370-quaternius-*` flags.

## Reading the result

The bridge, buildings, props, trees, rocks, and characters are imported
Quaternius meshes. The terrain, riverbed, banks, and organic route are small
engine-authored composition meshes supporting that imported family. The
current result is a feasibility proof, not production-wide integration.
