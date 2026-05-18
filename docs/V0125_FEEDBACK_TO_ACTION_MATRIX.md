# v0.12.5 Feedback To Action Matrix

Date: 2026-05-18

Use this matrix after classification and severity assignment. It maps feedback patterns to next action without jumping straight to implementation.

| Feedback pattern | Minimum evidence | Recommended action | Forbidden reaction | Next Codex goal type |
| --- | --- | --- | --- | --- |
| Actual bug | Repro steps, current build/commit, expected vs actual result, node/screen. | Bug investigation or focused repro. | Tune balance around the bug or weaken tests. | Bug fix / repro goal. |
| Repeated clarity issue | 2+ similar reports or 1 report with obvious text mismatch. | Copy/readability candidate. | Change gameplay numbers first. | Small polish goal. |
| Repeated pressure miss | 2+ reports with node, combat state, seen/missed warning, and reaction time. | Pressure-warning readability review; maybe copy/UI. | Assume telemetry warning count proves humans noticed it. | Pressure polish goal. |
| Repeated unfair defeat | 3+ similar reports with route, army state, objectives, resources, pressure state, and result. | Candidate for tiny tuning only after clarity/control/art causes are ruled out. | Nerf or buff from one loss. | Balance evidence/tuning proposal. |
| Repeated too-easy route | 3+ reports showing low-loss wins while skipping objectives/pressure/production. | Candidate for tiny tuning or more testing. | Nerf Retinue + Training Yard II because it feels powerful once. | Balance evidence/tuning proposal. |
| Single too-easy complaint | One report, incomplete route or army state. | Monitor; ask for another run. | Slow Fast Army immediately or nerf retinue immediately. | More testing. |
| Art complaint blocking readability | Screenshot or clear note showing blocked decision. | Tag UI/readability plus future visual/UI overhaul. | Import new art or tune combat to compensate. | Visual/readability planning. |
| Art complaint aesthetic only | Screenshot or note says ugly but understandable. | Future visual overhaul backlog. | Start runtime art replacement now. | Visual overhaul backlog. |
| Feature request | Request is outside current slice. | Backlog or future systems pass. | Implement under intake goal. | Future systems planning. |
| Contradictory reports | Different testers report opposite outcomes with unclear setup. | Preserve both; gather route/save details. | Average into a tuning decision. | More testing / evidence triage. |

## Specific Watchpoint Examples

Single complaint: "Fast Army is too fast."

- Minimum evidence: insufficient unless route, node, losses, objectives skipped, and result are included.
- Recommended action: monitor or request another run.
- Forbidden reaction: slow Fast Army immediately.
- Next goal: more testing.

Repeated complaint: "Three testers missed Cinderfen Watch pressure while fighting at Watch Road and could not react."

- Minimum evidence: met if each report records combat state and result.
- Recommended action: pressure-warning readability review.
- Forbidden reaction: broad enemy pressure redesign.
- Next goal: pressure polish.

Repeated complaint: "Two testers say Greedy Economy is weak, but both floated high resources and delayed production."

- Minimum evidence: suggests conversion clarity, not economy weakness.
- Recommended action: monitor or copy/readability around resource-to-army conversion.
- Forbidden reaction: buff economy.
- Next goal: clarity polish or more testing.

Repeated complaint: "Retinue + Training Yard II cleared Ashen, Crossing, and Watch with no losses while ignoring objectives across three testers."

- Minimum evidence: potentially met.
- Recommended action: balance tuning proposal, smallest possible change, with simulator rerun.
- Forbidden reaction: broad retinue redesign.
- Next goal: tiny tuning proposal.
