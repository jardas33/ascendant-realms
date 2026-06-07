# v0.150 Barracks Material Fair Path Audit

Status: runtime audit produced by `npm run godot:barracks-material-seam-repair:audit`.

The private comparator must prove:

- Local and fallback candidates share the same Barracks shell render path.
- Textures are decoded and material instances are created only during initialization.
- No texture creation, material creation, metadata parsing, derivative generation, or UV rebuild occurs during measured steady-state frames.
- Initialization and warmup are separated from measured frame timing.
- Unknown or hash-mismatched sources fail closed.

The expected PASS marker is `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_FAIR_PATH_AUDIT`.

Final audit result:

- PASS marker: `PASS_V0150_BARRACKS_MATERIAL_SEAM_REPAIR_FAIR_PATH_AUDIT`
- Texture cache entries: `6`
- Material cache entries: `18`
- Barracks shell rebuild count: `1158`
- Worker context rebuild count: `1253`
- Source loading: one load per local derivative, Worker context source, and tracked fallback.
- Steady state: no repeated texture create, material create, metadata parse, derivative generation, or UV rebuild.
