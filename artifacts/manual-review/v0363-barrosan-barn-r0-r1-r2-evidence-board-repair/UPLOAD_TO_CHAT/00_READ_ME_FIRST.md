# v0.363 Barrosan Barn R0 / R1 / R2 Evidence Board Repair

READY FOR HUMAN V0363 BARROSAN BARN R0-R1-R2 EVIDENCE BOARD REVIEW.

The v0.362 contextual placement was human-approved. Board 07 alone was rejected because its centre panel omitted the R1 opt-in Barn visual and showed a second zero-Barn rollback view instead. v0.363 repairs only that evidence sequence.

Board 07 now contains three genuine non-headless Godot captures from the same fixture, camera, viewport, lighting, House02 state, workers, terrain, river, bridge and road:
- R0 DEFAULT | Barn 0
- R1 OPT-IN | Barn 1 at (4.000, 0.180, -1.000)
- R2 ROLLBACK | Barn 0

R0 and R2 have matching raw pixels and state signatures. R1 has one canonical Barn and differs only by that accepted Barn root and descendants. No asset, placement, runtime, gameplay, benchmark or validation-rule mutation occurred in this checkpoint. The canonical Barn source and frozen roof remain unchanged.

Capture: npm run godot:capture:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair
Pack: npm run godot:pack:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair
Validator: npm run godot:validate:salto-v0363-barrosan-barn-r0-r1-r2-evidence-board-repair
Human review stop: true. Do not begin another asset or gameplay change without explicit approval.