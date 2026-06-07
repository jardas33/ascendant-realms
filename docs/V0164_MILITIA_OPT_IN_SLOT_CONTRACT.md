# v0.164 Militia Opt-In Slot Contract

Status: `PASS_V0164_MILITIA_OPT_IN_FUNCTIONAL`.

Militia slot contract:

- Slot ID: `militia_billboard_static_v0154`
- Derivative: `HYBRID_MILITIA_TRIMMED_1024`
- Expected SHA-256: `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`
- Expected dimensions: `1024x1024`
- Runtime surface: friendly recruited Militia defender billboard only.
- Default fallback: procedural Militia defender silhouette.
- Stable unit ID preserved: `recruited_militia_00`.
- Default scale: `1.00x`.

Load requirements:

- Source path must exist.
- Metadata path must exist and parse as JSON.
- Metadata slot ID, derivative kind, SHA-256, and dimensions must match the selected v0.155 repair evidence.
- Source file SHA-256 must match the metadata and expected SHA.
- Image decode must produce the expected dimensions.
- Texture, material, and mesh creation must happen at most once per process for the Militia slot.

Fallback requirements:

- Missing Militia source falls back to procedural Militia.
- Militia metadata hash mismatch falls back to procedural Militia.
- Worker and Barracks art remain active during Militia fallback.
- Selection rings, stable IDs, HUD, minimap, and real-input flow remain unchanged.

Isolation requirements:

- Default procedural launcher does not request the slot.
- Worker-only launcher does not request the slot.
- Worker + Barracks launcher does not request the slot.
- Only the new Worker + Barracks + Militia launcher requests all three opt-in slots.
- No fourth art slot is added.
