# v0.163 Player-Slice Two-Slot Boundary

Status: `PASS_V0163_PLAYER_SLICE_TWO_SLOT_BOUNDARY`.

Default stabilized launcher SHA-256:

- Expected: `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`.

Worker-only launcher SHA-256:

- Expected: `87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb`.

Combined Worker + Barracks launcher SHA-256:

- Expected: `a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a`.

Allowed in v0.163:

- v0.163 review launcher wrapper.
- v0.163 hardening validation wrapper.
- v0.163 reporting and scorecard tool.
- v0.163 documentation and handoff updates.

Forbidden in v0.163:

- No third player-facing art slot.
- No image generation.
- No import of any private comparator candidate beyond the already-selected Worker and Barracks sources.
- No browser runtime wiring.
- No save, stable-ID, gameplay, objective, balance, AI, pathing, or default launcher mutation.
- No start of the next milestone.

Boundary artifact:

- `artifacts/desktop-spikes/godot-salto/v0163/boundary/worker-barracks-art-opt-in-boundary-scan.json`.

Boundary result:

- Default stabilized launcher unchanged.
- Worker-only launcher unchanged.
- Combined Worker + Barracks launcher unchanged.
- Exactly two opt-in normal-slice slots remain available in the combined posture.
- Zero new images were generated or tracked.
- Package leakage reported `false`.
