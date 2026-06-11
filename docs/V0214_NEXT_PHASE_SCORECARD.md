# v0.214 Next-Phase Scorecard

Status: PASS

Exactly one next milestone is selected:

`v0.215 Salto production-art battlefield content direction packet`

## Why This Milestone

The v0.207 through v0.213 HUD path now has a coherent original RTS shell, fallback proof, benchmark proof and cleanup proof. The biggest remaining visual weakness is no longer HUD organization; it is the production quality of the battlefield content inside the shell:

- terrain and vegetation still read as prototype material rather than authored place
- structures remain simplified compared with the reference target
- units and hostile pressure are readable but not production-rich
- battlefield density and environmental storytelling are sparse
- lighting and atmospheric detail are restrained but still functional rather than evocative

## Alternatives Rejected For Immediate Next Step

| Alternative | Decision |
| --- | --- |
| More HUD feature expansion | Rejected for now; UI direction is frozen and should not keep growing before content art catches up. |
| New gameplay systems | Rejected; v0.214 scope preserves gameplay, pathing, objectives, AI, saves, stable IDs and balance. |
| New runtime art slots without planning | Rejected; slot expansion should remain frozen until the next content-art direction is explicitly reviewed. |
| Browser runtime wiring | Rejected; the Godot review path remains isolated. |
| Default launcher enablement | Rejected; default launcher remains procedural. |

## Recommended v0.215 Outcome

Prepare a bounded production-art/content contract for the Salto battlefield that can later drive asset generation or implementation choices without mutating runtime defaults. The packet should define:

- battlefield art priorities by surface and entity type
- structure identity targets for Command Hall, Barracks, mine, bridge and hostile landmarks
- unit and hostile readability requirements
- material and lighting constraints
- what can stay procedural
- what must become authored or generated art later
- acceptance gates for any future art source, import or opt-in integration

## Stop Condition

Do not start v0.215 in v0.214. The next milestone requires a new explicit prompt from a clean, synced, pushed and CI-green v0.214 checkpoint.
