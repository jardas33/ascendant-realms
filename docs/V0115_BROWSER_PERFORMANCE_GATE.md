# v0.115 Browser Performance Gate

## Result: RED

This is the only v0.115 browser performance gate result. The browser prototype remains too slow for runtime visual expansion or integrated art work. Continue only with documentation, evidence review, and a separately approved architecture/performance decision.

## Gate Rules

These are decision rules, not additional outcomes.

| Status | Rule |
| --- | --- |
| GREEN | Tier M representative battle is at least 30 FPS average, p95 frame time is 50 ms or lower, and long tasks are 1 or fewer. |
| AMBER | Tier M representative battle is at least 18 FPS average, p95 frame time is 120 ms or lower, and max frame time is 500 ms or lower. |
| RED | Anything below AMBER, or evidence that a serious bottleneck still blocks browser visual expansion. |

v0.115 uses the v0.110 gate rule and the consolidated v0.109-v0.114 evidence. The latest comparable Tier M rows remain around 2.4-2.5 FPS average with 533.3-633.3 ms p95 frame time, so the gate is RED.

## Trusted Evidence Snapshot

| Source | Evidence | Interpretation |
| --- | --- | --- |
| [v0.109 trusted summary](../artifacts/performance/v0109/trusted-benchmark-summary.json) | Preview Tier M baseline 2.5 FPS / 533.4 ms p95 / 58 long tasks after the v0.115 refresh. | Trusted production-preview sampling confirmed the old lag was real. |
| [v0.110 browser gate](../artifacts/performance/v0110/trusted-browser-gate.json) | RED at 2.5 FPS / 533.2 ms p95 / 650 ms max / 53 long tasks. | Phase profiling and density ladders did not clear the gate. |
| [v0.111 browser controls](../artifacts/performance/v0111/browser-control-baselines.json) | Blank page, simple DOM, simple canvas, and true Phaser empty scene are about 60 FPS with 16.7 ms p95. | Host/browser shell can sustain normal frames outside the game workload. |
| [v0.111 clean profile](../artifacts/performance/v0111/clean-profile-benchmark.json) | Clean-profile Tier M is still 2.4 FPS / 533.3 ms p95 after the v0.115 refresh. | User profile or extension overhead is not the dominant explanation. |
| [v0.112 idle matrix](../artifacts/performance/v0112/idle-cost-matrix.json) | Empty/static battle shell rows still sit around 2.7 FPS with about 500-583.4 ms p95. | A fixed battle-shell cost remains even before representative density. |
| [v0.113 query profile](../artifacts/performance/v0113/query-profile.json) | Tier M/Tier L path and targeting counters remain large; production duplicate path-cache hits were 0 in representative rows. | Exact-semantics spatial/pathing work helped safety and instrumentation but did not move the browser gate. |
| [v0.114 render lifecycle audit](../artifacts/performance/v0114/lifecycle-audit.json) | Tier M combat 2.4 FPS / 566.6 ms p95; Tier M moving 2.4 FPS / 633.3 ms p95; campaign map 9 FPS / 216.7 ms p95 after the v0.115 refresh. | Renderer churn was bounded, but frame-time cost remains far beyond AMBER. |

## Required Contributions

Host-pressure contribution: low based on current automated evidence. The [v0.111 machine classification](V0111_MACHINE_PRESSURE_CLASSIFICATION.md) reports `HOST_PRESSURE_UNLIKELY` and `BATTLE_CODE_DOMINANT`.

Browser-environment contribution: low to moderate. The true outside-game controls in [v0.111 browser controls](V0111_BROWSER_CONTROL_BASELINES.md) hold 60 FPS. The browser can run simple DOM, simple canvas, and Phaser empty scenes at normal cadence, but the game shells do not.

Phaser-empty contribution: not the blocker in the true control. The v0.111 true Phaser empty scene is 60 FPS / 16.7 ms p95. The v0.114 `v0114_phaser_empty` row is a private BattleScene shell row and remains slow because it still carries the game shell and DOM/HUD environment.

Battle fixed cost: high. v0.112 empty/static battle shell rows remain around 2.7 FPS with p95 frame time near or above 500 ms. That means a meaningful baseline battle cost remains before normal density and combat pressure.

Density cost: high. v0.109 Tier S/M/L, v0.110 density rows, and v0.114 Tier S/M/L rows all remain below AMBER. Tier L was worst in v0.109 at 2 FPS / 716.5 ms p95, and later bounded work did not produce a trusted Tier M recovery.

Pathing/spatial cost: present but not isolated as the only blocker. v0.113 proves large target-acquisition and pathing counters under representative rows, while exact duplicate path-request reuse did not hit in production representative combat rows. A broad spatial index remains intentionally deferred because tie order and invalidation risk exceed the narrow checkpoint boundary.

Renderer cost: reduced in churn, unresolved in total frame time. v0.114 reduced procedural and presentation churn with no-save visual parity, but the audited Tier M rows still fail the gate.

DOM cost: meaningful in game shells, not in simple DOM controls. Campaign map and Results remain DOM-heavy surfaces with p95 frame time far above 50 ms, while simple DOM controls are healthy. The app-specific DOM/HUD/status/results/campaign composition remains part of the unresolved cost.

Remaining uncertainty: headed/manual human runs may vary after a clean restart. The automated evidence is strong enough to block runtime art integration, but Emmanuel's clean-restart retest packet should be used to confirm whether host pressure changes materially after a fresh machine state.

Trusted execution modes: use production preview first, headless preview for repeatability, clean-profile preview for reproducibility, dev server only as comparison evidence, and manual headed runs as supplemental evidence. Do not treat dev-only or overlay-heavy samples as acceptance proof.

Before/after evidence: v0.109 established the trusted baseline, v0.110 classified the browser gate as RED, v0.111 separated host/browser controls from game cost, v0.112 reduced safe allocation and idle work, v0.113 added exact spatial/pathing evidence, and v0.114 reduced renderer lifecycle churn. The consolidated gate remains RED.

## Decision

Stop browser visual expansion and do not integrate generated art into the browser runtime on this evidence. Move the reviewed architecture or earlier engine-spike discussion forward before approving broad visual runtime work.
