# v0.123 Godot Continuation Gate

Status: decision packet only. This does not select Godot finally, start a port, create a Unity project, import art, generate images, change browser runtime, alter saves, rename stable IDs, or start v0.124.

## Classification

GODOT_SPIKE_GREEN

Godot is green as the next carefully expanded workflow spike candidate. It is not green as a final engine decision.

## Evidence

| Gate | Result | Evidence |
| --- | --- | --- |
| AI-first workflow proved credible | Pass | v0.117 through v0.122 prove repository-driven scene generation, validation, tests, benchmarks, export, packaging, scorecards, fresh-checkout validation, and adapter reports without routine editor work. Latest scorecard records AI-operability `24 / 25`. |
| Zero-editor reproducibility passed | Pass | `artifacts/desktop-spikes/godot-salto/v0120/fresh-checkout-validation.json` reports `PASS_GODOT_FRESH_CHECKOUT_VALIDATION` and `routineEditorUseRequired: false`. |
| Packaged headed smoke passed | Pass | `artifacts/desktop-spikes/godot-salto/v0118/headed-smoke.json` reports `PASS_PACKAGED_HEADED_SMOKE` and `routineEditorUseRequired: false`. |
| Representative Tier M credible | Pass | v0.119 and latest Godot runs exercise the Tier M Salto fixture with 43 units, three capture sites, one active Lume link, bounded pressure, movement, targeting, Results readiness, and zero stuck units. |
| 2.5D procedural mode viable enough for visual review | Pass | v0.121 reports `PASS_GODOT_PROCEDURAL_VISUAL_CAPTURE` with 32 captures and `PASS_GODOT_PROCEDURAL_VISUAL_FOUNDATION_PERFORMANCE_COMPARISON`; normal review default is `CLEAN_READABILITY`. |
| Adapter proof passed | Pass | `artifacts/desktop-spikes/godot-salto/v0122/adapter-validation.json` reports `PASS_GODOT_CONTENT_ADAPTER_VALIDATION`; `linked_ward` remains exactly `0.92`, unknown IDs are rejected, saves are read-only, and no full port is started. |

## Recommendation

Expand the Godot vertical slice carefully in the next explicitly approved milestone, only if Emmanuel agrees after reviewing this decision packet and the packaged Godot review build.

Recommended expansion posture:

- Keep the browser prototype authoritative for content and behavior.
- Keep Godot as a repository-driven spike, not a final selected engine.
- Keep 2D as the readability/control lane.
- Keep 2.5D `CLEAN_READABILITY` as the leading visual-review lane.
- Continue to require one-command validation, fresh-checkout proof, Windows packaging, and no routine Godot editor assembly.
- Use the v0.123 reference-art prompts for external style review only; do not import any generated image into runtime.

## Uncertainty

- The current visuals are procedural placeholders, not final art.
- Headless performance and packaged smoke are workflow evidence, not final production certification.
- Pathing, AI planning depth, campaign progression, rewards, UI production quality, audio, and full content migration are not proven.
- Human feel on Emmanuel's display and input devices still needs a short video review.
- Unity remains a valid comparator if Godot visual quality, editor-optional workflow, or reproducibility regresses.

## Decision Boundary

This gate authorizes no code port, no engine choice, no art generation, no runtime art import, no Unity project, and no v0.124 work.
