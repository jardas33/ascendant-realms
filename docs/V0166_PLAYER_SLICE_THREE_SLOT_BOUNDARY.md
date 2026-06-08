# v0.166 Player Slice Three-Slot Boundary

Status: `PASS_V0166_PLAYER_SLICE_THREE_SLOT_BOUNDARY`

v0.166 preserves the already-selected three-slot opt-in posture:

- Worker: `worker_billboard_static_v0147` / `HYBRID_WORKER_TRIMMED_1024` / `a628065ca92b231b0d4f6a0625d9e259dea080e80d530ee688483611d70049bc`.
- Barracks: `barrosan_barracks_material_v0149` / `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND` / `58a60b750370df084b60a1d92077da9367c0ba8a763781e2c3a8a7d96f1c980f`.
- Militia: `militia_billboard_static_v0154` / `HYBRID_MILITIA_TRIMMED_1024` / `c25349f00c422a0b3c9d5862027351bd70008e9314d4e3cd4001676e914321cb`.

Preserved launchers:

- Default stabilized launcher remains procedural.
- Default player-slice launcher remains procedural.
- Worker-only launcher remains Worker-only.
- Worker + Barracks launcher remains two-slot.
- Worker + Barracks + Militia launcher remains three-slot.

Forbidden in v0.166:

- Aster normal-slice import.
- Ashen normal-slice import.
- Any new image generation.
- Any fourth slot.
- Browser runtime wiring.
- Save, stable-ID, gameplay, input, objective, AI, balance, or campaign mutation.
