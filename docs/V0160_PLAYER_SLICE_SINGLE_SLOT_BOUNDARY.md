# V0160 Player-Slice Single Slot Boundary

Status: hard boundary for v0.160.

## Allowed

- Exactly one player-facing Godot opt-in art slot.
- Slot id: `worker_billboard_static_v0147`.
- Approach: `HYBRID_WORKER_TRIMMED_1024`.
- New explicit opt-in launcher: `GODOT_LAUNCH_SALTO_WORKER_ART_EXPERIMENT_WINDOWS.bat`.
- Missing-art and hash-mismatch fallback proof.
- Benchmark proof against the procedural baseline.

## Forbidden

- No second player-facing art slot.
- No Aster, Barracks, Militia, Ashen Raider, or archived Ashen import.
- No image generation.
- No animation, directional variants, atlas expansion, or alternate Worker candidates.
- No browser runtime wiring.
- No production runtime-art manifest mutation.
- No normal default launcher mutation.
- No save or stable-ID mutation.
- No gameplay, AI, objective, map, input, balance, campaign, or browser behavior change.
- No final runtime-art approval, final Worker art approval, final Godot choice, full port, or v0.161 work.

## Default Launcher Proof

Default stabilized launcher hash before v0.160:

```text
47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d
```

The v0.160 boundary scan verifies that hash and checks the default launchers for Worker-art opt-in tokens.

Generated scan:

- `artifacts/desktop-spikes/godot-salto/v0160/validation/worker-art-opt-in-boundary-scan.json`
