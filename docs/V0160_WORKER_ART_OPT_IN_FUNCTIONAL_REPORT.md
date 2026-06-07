# V0160 Worker Art Opt-In Functional Report

Status: evidence report for the single Worker opt-in player-slice path.

## Functional Scenarios

The validation workflow runs four packaged Godot player-slice scenarios:

| Scenario | Expected result |
| --- | --- |
| `default-procedural` | Opt-in absent, procedural Worker remains active. |
| `worker-opt-in` | Exact `HYBRID_WORKER_TRIMMED_1024` source loads for Worker only. |
| `missing-art-fallback` | Missing source fails closed to procedural Worker. |
| `hash-mismatch-fallback` | Hash mismatch fails closed to procedural Worker. |

## Preserved Gameplay Behaviors

- Title and briefing shell.
- Battle default state.
- Worker selection ring and context card.
- Mine conversion.
- Worker assignment to West Stone Cut Mine.
- Barracks placement, construction, and completion.
- Militia recruit path.
- Pressure wave, Lume restore, minimap, and Results.

## Gate

Run:

```text
npm run godot:validate:salto-worker-art-experiment
```

Expected generated report:

- `artifacts/desktop-spikes/godot-salto/v0160/validation/worker-art-opt-in-functional-report.json`

Recorded acceptance status:

- `PASS_V0160_WORKER_ART_OPT_IN_FUNCTIONAL`

Recorded scenario evidence:

| Scenario | Status | Source loaded | Fallback |
| --- | --- | --- | --- |
| `default-procedural` | `PASS_PLAYER_SLICE_VALIDATION` | false | `opt-in flag absent` |
| `worker-opt-in` | `PASS_PLAYER_SLICE_VALIDATION` | true | false |
| `missing-art-fallback` | `PASS_PLAYER_SLICE_VALIDATION` | false | `missing source file` |
| `hash-mismatch-fallback` | `PASS_PLAYER_SLICE_VALIDATION` | false | `metadata hash mismatch` |

Boundary scan:

- `PASS_V0160_WORKER_ART_OPT_IN_BOUNDARY`
- Default stabilized launcher hash: `47ea4cdef721451dfd4e55511a6b7c580bc666332c7cf216c7cc0319969a6c3d`
