# Proposed first parallel sprint

This sprint is proposed only. The throughput reset does not execute it.

| Lane | Owner | Bounded objective | Likely areas | Exit evidence |
| --- | --- | --- | --- | --- |
| Gameplay | A | Reproduce the highest-impact normal Easy Hollowspan blocker in command, navigation, combat, conquest, or results; repair one causal blocker | `src/game/battle`, `entities`, `pathfinding`, `results` | focused tests + one normal rehearsal |
| UX/readability | D | Implement P1-HUD-001 for normal player mode; keep debug/review overlays explicit | `src/game/ui`, `styles`, scenes | 1920/1366 normal-scale captures |
| Visual/presentation | C | Improve one bounded unit/building silhouette or terrain-lane readability issue | `src/game/art`, manifest, opt-in Godot lane | before/after gameplay captures |
| Combat feel | E | Build the smallest deterministic combat readability proof without adding systems | `src/game/battle`, UI feedback | one causal scenario + review |
| QA/evidence | G | Consolidate cheap validation and capture integrity checks | `tools`, `tests/visual-qa` | command ledger and rejected-capture report |
| Integration/critic | H | Compare candidates, reject scope creep, integrate only passing work locally | fresh integration worktree | combined regression + critic verdict |

Dependencies: Gameplay must establish the reproduction before Combat Feel changes; UX and Visual can proceed independently if they do not change gameplay semantics; QA can work in parallel but cannot weaken gates; Integration waits for all selected lanes. No lane may mutate the protected checkout or push.
