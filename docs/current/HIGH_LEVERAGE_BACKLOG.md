# High-leverage backlog

Priorities are provisional and should be re-scored after fresh normal-play evidence. `P0` blocks ordinary play; `P1` blocks comprehension or confidence; `P2` improves depth after the shell is reliable.

| ID | Priority | Player-facing task | Evidence of done | Dependencies |
| --- | --- | --- | --- | --- |
| GAME-01 | P0 | Reproduce and repair the highest-impact Easy Hollowspan opening blocker | normal match segment plus focused test | current environment/window access |
| GAME-02 | P0 | Make unit selection and command feedback reliable | select/move/order trace at two resolutions | viewport contract |
| GAME-03 | P0 | Repair camera bounds and walkable-space obstruction | bounded camera and navigation proof | map geometry audit |
| GAME-04 | P0 | Prove deterministic one-unit combat causality | HP, damage, casualty, destruction trace | selection/navigation |
| GAME-05 | P0 | Close natural Results/Continue/Play Again flow | natural win/loss video | combat and result state |
| GAME-06 | P0 | Align setup/loading/runtime match identity | setup-to-runtime capture | content audit |
| UX-01 | P1 | Reduce debug-heavy normal-player HUD labels | clean normal-player before/after | no state change |
| UX-02 | P1 | Clarify selected-object cards and portraits | unit/building cards at gameplay scale | selection |
| UX-03 | P1 | Clarify action icons, tooltips, and disabled reasons | action matrix | command contract |
| UX-04 | P1 | Improve production/research queues and progress | queue/complete capture | economy rules |
| UX-05 | P1 | Make rally points and resource feedback explicit | click-to-feedback trace | production |
| UX-06 | P1 | Repair minimap readability and relation to world | paired minimap/world capture | viewport |
| UX-07 | P1 | Validate responsive safe-area layout at 1920x1080/1366x768 | resolution matrix | viewport |
| VIS-01 | P1 | Improve unit silhouette, ownership, health, and selection contrast | gameplay-scale before/after | art metadata |
| VIS-02 | P1 | Improve building identity and grounding | structure close/wide captures | terrain |
| VIS-03 | P1 | Improve road/clearing/river/bridge tactical hierarchy | wide gameplay capture | geometry contract |
| VIS-04 | P1 | Add restrained combat readability cues | combat before/after | combat proof |
| VIS-05 | P2 | Establish coherent Barrosan environment kit slice | opt-in authored slice | source/license |
| VIS-06 | P2 | Establish distinct Lioraen visual language | faction review pack | faction design |
| PLAY-01 | P1 | Establish Easy Hollowspan opening build order | normal player video | GAME-01 |
| PLAY-02 | P1 | Make worker gathering and construction understandable | gather/build trace | UX-03 |
| PLAY-03 | P1 | Make production and rally behavior readable | queue/rally trace | UX-04/05 |
| AI-01 | P1 | Tune Lioraen Easy pressure for readable first contact | natural match evidence | GAME-01 |
| AI-02 | P2 | Clarify AI target choice and retreat feedback | combat review | combat proof |
| AI-03 | P2 | Validate difficulty differences without hidden unfairness | profile comparison | telemetry |
| SAVE-01 | P0 | Protect stable IDs and save compatibility during feature work | save translation tests | any rules change |
| QA-01 | P0 | Enforce fresh, normal-scale, fail-closed evidence | capture audit | all lanes |
| QA-02 | P1 | Add a cheap deterministic scenario harness | repeatable trace | test architecture |
| QA-03 | P1 | Separate browser, Godot, and debug/review claims | runtime-tagged reports | docs system |
| QA-04 | P2 | Make visual review packs readable and comparable | contact sheet plus originals | visual lanes |
| CONTENT-01 | P1 | Audit Hollowspan objectives, roster, and identity data | content report | data validation |
| CONTENT-02 | P2 | Audit Barrosan/Lioraen roster completeness and provenance | manifest report | art bible |
| PERF-01 | P2 | Keep ordinary gameplay responsive at supported resolutions | benchmark plus human review | viewport |

Each row is a candidate task. Create a bounded task from [`../codex/TASK_TEMPLATE.md`](../codex/TASK_TEMPLATE.md) before implementation.

## I1 evidence note — 2026-08-14

The following bounded player-facing slices are locally integrated and rehearsed on the canonical D: lane at `195d265b991d359afd6c12c1ecc31c74a6864fb7`: resource identity/readability, building placement readability, normal-player construction-label cleanup, and combat impact presentation. Fresh current-source proof is recorded in `D:\CodexData\evidence\i1-resources-final`, `artifacts/manual-review/v0432-war-hall-clan-levy-production-loop`, and `artifacts/manual-review/v0434-first-combat-casualty-loop`.

The next uncompleted high-value player-facing priority is PLAY-01A / AI-01: a trustworthy Easy Hollowspan opening through first contact. WORLD-02 is parked yellow and is not part of canonical integration. The retained v0.433 headed economy capture still has an independent timing/contract failure at `tests/v0433_capture.gd:190`; focused economy tests and RESOURCES-01 readability proof remain green.
