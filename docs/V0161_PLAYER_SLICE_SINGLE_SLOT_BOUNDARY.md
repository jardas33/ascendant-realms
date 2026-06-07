# V0161 Player-Slice Single-Slot Boundary

Status: boundary contract for v0.161.

## Allowed

- Inspect and validate the existing Worker-art opt-in path.
- Add v0.161 validation, benchmark, capture, Computer Use, real-input, and boundary tooling.
- Add v0.161 docs and one-click review/validation wrappers.
- Preserve the v0.160 Worker slot exactly.

## Forbidden

- Generate a new AI image.
- Add a second player-facing art slot.
- Import Aster, Militia, Ashen Raider, Barracks material, HUD art, terrain art, environment art, or any reference candidate into the normal slice.
- Enable art in `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`.
- Wire anything into the browser runtime.
- Mutate production art manifests, saves, stable IDs, gameplay rules, objectives, input semantics, AI, balance, or campaign state.
- Begin v0.162.

## Gate

The boundary report must pass:

```text
PASS_V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY
```

The package leakage scan must confirm the ignored selected Worker derivative and metadata are not ordinarily included in the package ZIP.

Latest gate status:

```text
PASS_V0161_PLAYER_SLICE_SINGLE_SLOT_BOUNDARY
```

Latest boundary evidence confirms the default stabilized launcher hash stayed `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`, package leakage stayed `false`, no browser runtime path changed, no save or stable-ID path changed, no second normal-slice art slot appeared, and no v0.162 work started.
