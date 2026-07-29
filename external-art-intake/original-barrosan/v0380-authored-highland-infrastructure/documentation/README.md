# Ascendant Realms v0.380 Corrected Highland Infrastructure

This delivery is a direct source-level correction of the v0.379 authored infrastructure kit.
It is limited to terrain, embedded road, recessed river/banks, bridge and sparse natural dressing.

## Corrections made

- exports explicit vertex normals to prevent the repeating triangular/corrugated shading visible in v0.379;
- uses a lower, cleaner terrain grid and consistent triangle orientation;
- keeps one continuous water mesh through and beneath the bridge;
- prevents road grading from raising a land plug across the river channel;
- narrows the road and its feathered shoulders;
- deepens and darkens the river channel and wet-bank transition;
- reduces bridge width and rail mass while retaining planks, beams and granite landings;
- uses a darker, higher-contrast highland palette.

## Exact files

- Source generator: `source/generate_v0380_highland_infrastructure.py`
- GLB: `exports/barrosan_highland_infrastructure_v0380.glb`
- GLB SHA-256: `746b27eb0e0d52470ce090cf58b7e8515ffa900267d5479649e105262afcd5fb`
- Generator SHA-256: `4b8eafeac69f16a87bd6899a69ab6c6bb8cb5d49103c5ba9cb3da325f38f3e19`

The source is deterministic and uses seed 380. The GLB is intended for an isolated, opt-in Godot presentation before any later gameplay integration.
