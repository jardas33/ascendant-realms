# v0.123 Godot Scorecard Update

Status: decision-packet scorecard update only. It summarizes v0.117 through v0.122 evidence and does not replace the ignored JSON scorecard artifacts.

Latest artifact scorecard: `artifacts/desktop-spikes/godot-salto/latest/scorecard.json`

Current posture: `workflow-spike-content-adapter-parity-not-final-engine-choice`

## Score Summary

| Category | Score | Evidence |
| --- | ---: | --- |
| AI operability | 24 / 25 | Scripts cover setup, generation, validation, tests, benchmark, export, package, scorecard, fresh checkout, and review. |
| Zero-editor workflow | 10 / 10 | v0.120 fresh-checkout proof and v0.122 adapter reports keep `routineEditorUseRequired: false`. |
| Reproducibility | 10 / 10 | Fresh-checkout validation passes from a temporary clone with `npm ci`, fixture regeneration, Godot tests, benchmark, export, and package. |
| Packaged Windows launch | 9 / 10 | v0.118 headed smoke and v0.122 Windows package pass; human launch feel still needs Emmanuel video review. |
| Benchmark credibility | 8 / 10 | S/M/L workloads are deterministic and representative enough for workflow decisions, not production certification. |
| Tier S/M/L scalability | 8 / 10 | Both modes run S/M/L with zero stuck units; Tier L remains a stress row, not a final performance target. |
| Navigation | 7 / 10 | Movement, obstacle nudges, query counts, and stuck-unit checks are captured; production pathing parity is not proven. |
| Placeholder AI pressure | 7 / 10 | Bounded pressure beats and target acquisition are credible for spike review; full AI strategy is not ported. |
| 2D readability | 8 / 10 | 2D remains the stable control lane with clear placeholder tactical readability. |
| 2.5D potential | 8 / 10 | Procedural clean and atmospheric presets support modern fixed-camera review; final art quality is unresolved. |
| Visual pipeline compatibility | 7 / 10 | Reference-art planning and no-art runtime boundary are clear; final asset import workflow remains unproven. |
| Content adapter | 9 / 10 | v0.122 adapters validate generated JSON, deterministic ordering, unknown/missing/duplicate rejection, and fixture hash. |
| Stable-ID posture | 10 / 10 | Selected IDs remain stable, unknown probe is rejected, and no stable IDs are renamed. |
| Save posture | 10 / 10 | Save fixtures remain read-only; no localStorage access or save writes are allowed. |
| Automated tests | 9 / 10 | Local and Godot test stacks are broad for the spike; future visual-art import tests are deferred. |
| CI-style workflow | 8 / 10 | Fresh-checkout and GitHub Actions proof are strong; full official Godot CI remains manually dispatchable rather than default required. |

Overall interpretation: 86 / 100 for continuing Godot as a carefully bounded spike candidate.

This is intentionally higher than the v0.122 JSON scorecard total of `78 / 100` because v0.123 consolidates the complete v0.117-v0.122 evidence chain for continuation planning. It is not a final engine score.

## Risks

- Placeholder visuals can hide production art and readability costs.
- Godot import settings can still become editor-state-heavy if future asset work is not manifest-driven.
- The current navigation and AI pressure are bounded spike logic.
- Full browser/Godot simulation parity is not claimed.
- UI, audio, campaign progression, rewards, saves, Retinue, relics, Stronghold, and multiplayer are not migrated.
- Human feel is not yet proven by Emmanuel's short video review.

## Unresolved Questions

- Does `CLEAN_READABILITY` or `ATMOSPHERIC_BALANCED` feel closer to the desired 2026 RTS/RPG look?
- Does Tier M feel smooth enough in the packaged build on Emmanuel's machine?
- Does Tier L remain usable enough as a stress read?
- Can final reference art be reviewed without drifting into protected-IP lookalikes?
- Can future asset registration remain manifest-driven without manual editor drag-and-drop?
- Would Unity beat Godot on visual quality while still matching the AI-first workflow contract?

## Scorecard Decision

Use `GODOT_SPIKE_GREEN` for continuation planning. Do not select Godot finally. Keep Unity comparator criteria ready if a future Godot slice fails visual, automation, packaging, or reproducibility gates.
