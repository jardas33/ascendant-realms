# v0.164 Militia Opt-In Rollback Report

Status: `PASS_V0164_PLAYER_SLICE_THREE_SLOT_BOUNDARY`.

Rollback posture:

- Remove or stop using `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_MILITIA_ART_EXPERIMENT_WINDOWS.bat`.
- Continue using `GODOT_LAUNCH_STABILIZED_SALTO_REVIEW_WINDOWS.bat` for the default procedural review slice.
- Continue using `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat` for Worker-only review.
- Continue using `GODOT_LAUNCH_SALTO_WORKER_BARRACKS_ART_EXPERIMENT_WINDOWS.bat` for Worker + Barracks review.

Fallback proof:

- Missing Militia source: `PASS_PLAYER_SLICE_VALIDATION`; Militia source is not loaded, fallback reason is `missing source file`, Worker and Barracks remain active.
- Militia hash mismatch: `PASS_PLAYER_SLICE_VALIDATION`; Militia source is not loaded, fallback reason is `metadata hash mismatch`, Worker and Barracks remain active.

Preserved launcher hashes:

- Default stabilized launcher: `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`
- Worker-only launcher: `87fd8b106ef02518c9fdd73c2ff5d6b1be92dc885e4b7aac607ce0fa5ce3a3bb`
- Worker + Barracks launcher: `a795b154fb08abd2664321a802050db6d73808aa73fd2ae34038c8db4c42be1a`

Rollback risk:

- Low, because the default launcher does not opt in to Worker, Barracks, or Militia art.
- Low, because the prior Worker-only and Worker + Barracks launchers are unchanged and hash-verified.
- Low, because the Militia slot has fail-closed runtime checks for path, metadata, hash, derivative, dimensions, and decode.
