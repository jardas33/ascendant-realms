# v0.162 Player-Slice Two-Slot Boundary

Status: `PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY`.

Allowed in v0.162:
- One new combined Worker + Barracks opt-in launcher.
- One second normal-slice opt-in art slot for `barrosan_barracks_material_v0149`.
- One v0.162 validation/capture/benchmark evidence tool and wrappers.
- Documentation for the v0.162 human-review stop.

Required preserved files:
- `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat`
- `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`

Required hashes:
- Default stabilized launcher SHA-256: `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`
- Worker-only launcher SHA-256: `87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb`

Forbidden in v0.162:
- A third player-facing art slot.
- Aster, Militia, or Ashen Raider player-facing art.
- Browser runtime wiring.
- Save or stable-ID mutation.
- Production runtime-art package leakage.
- Default launcher mutation.
- Worker-only launcher mutation.
- v0.163 work.

Boundary evidence path:
- `artifacts/desktop-spikes/godot-salto/v0162/boundary/worker-barracks-art-opt-in-boundary-scan.json`

Expected PASS gate:
- `PASS_V0162_PLAYER_SLICE_TWO_SLOT_BOUNDARY`

Observed boundary results:
- Default stabilized launcher unchanged: `true`.
- Worker-only launcher unchanged: `true`.
- Exactly two combined opt-in normal-slice slots: `true`.
- Third slot added: `false`.
- Browser runtime changed: `false`.
- Save or stable-ID mutation: `false`.
- Production package leakage: `false`.
