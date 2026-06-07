# v0.164 Militia Opt-In Functional Report

Status: `PASS_V0164_MILITIA_OPT_IN_FUNCTIONAL`.

Validated postures:

| Posture | Worker | Barracks | Militia | Militia fallback |
| --- | --- | --- | --- | --- |
| `default-procedural` | off | off | off | opt-in flag absent |
| `worker-only` | on | off | off | opt-in flag absent |
| `worker-barracks` | on | on | off | opt-in flag absent |
| `worker-barracks-militia` | on | on | on | none |
| `militia-missing-art-fallback` | on | on | off | missing source file |
| `militia-hash-mismatch-fallback` | on | on | off | metadata hash mismatch |

Functional findings:

- The new launcher requests exactly three normal-slice opt-in slots.
- The selected Militia source loads only when `--militia-art-opt-in` is present.
- Militia missing-art and hash-mismatch cases fail closed to the procedural Militia path.
- Worker and Barracks remain active during Militia fallback.
- The default stabilized launcher, Worker-only launcher, and Worker + Barracks launcher remain behaviorally separate.
- `fourthPlayerFacingArtSlotAdded` remains `false`.
- Browser runtime, production manifests, save writes, and stable IDs remain unchanged.

Automation evidence:

- `artifacts/desktop-spikes/godot-salto/v0164/validation/worker-barracks-militia-art-opt-in-validation.json`
- `artifacts/desktop-spikes/godot-salto/v0164/validation/worker-barracks-militia-art-opt-in-functional-report.json`
