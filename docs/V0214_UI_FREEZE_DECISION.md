# v0.214 UI Freeze Decision

Status: PASS_V0214_UI_DIRECTION_FREEZE

Decision: freeze the current Salto fantasy RTS HUD direction for the isolated Godot shell-v2 opt-in review path.

This is not a production-art parity claim. The provided reference image remains substantially ahead in battlefield art density, structure finish, unit density, lighting, environmental storytelling and illustration quality. The v0.214 pass freezes the UI direction because the HUD now reads as a coherent original fantasy RTS shell rather than a debug-box overlay, and the remaining major gap is content production quality.

## Evidence Reviewed

| Checkpoint | Evidence |
| --- | --- |
| v0.207 UI architecture style lock | `docs/V0207_UI_ARCHITECTURE_STYLE_LOCK.md`, `artifacts/manual-review/v0207-ui-architecture/` |
| v0.208 private UI comparator | `docs/V0208_UI_SHELL_COMPARATOR_REPORT.md`, `artifacts/manual-review/v0208-ui-shell-comparator/` |
| v0.209 opt-in UI shell | `docs/V0209_UI_SHELL_OPT_IN_REPORT.md`, `artifacts/manual-review/v0209-ui-shell-opt-in/` |
| v0.210 selection command panel | `docs/V0210_SELECTION_COMMAND_PANEL_REPORT.md`, `artifacts/manual-review/v0210-selection-command-panel/` |
| v0.211 production, objective and event log | `docs/V0211_PRODUCTION_OBJECTIVES_EVENT_LOG_REPORT.md`, `artifacts/manual-review/v0211-production-objectives-log/` |
| v0.212 minimap, tooltip and accessibility | `docs/V0212_MINIMAP_TOOLTIP_ACCESSIBILITY_REPORT.md`, `artifacts/manual-review/v0212-minimap-tooltip-accessibility/` |
| v0.213 full UI QA | `docs/V0213_FULL_UI_QA_SCORECARD.md`, `artifacts/manual-review/v0213-full-ui-qa/` |

Reference benchmark:
`C:\Users\barro\AppData\Local\Temp\REFERENCE_UI_TARGET.png`

Final review pack:
`D:\Code for projects\WB game like\ascendant-realms\artifacts\manual-review\v0213-full-ui-qa\`

## Freeze Criteria

| Criterion | Result | Notes |
| --- | --- | --- |
| Opt-in UI no longer reads as debug boxes | PASS | Panel grouping, trim, resource ledger, objective/log stack, minimap, selection and command surfaces now read as one designed RTS shell. |
| Resources are coherent | PASS | Top ledger is compact and consistent. |
| Objective and event log are coherent | PASS | Left stack communicates current task and recent progression without overlap. |
| Minimap is coherent | PASS | Bounds, camera, routes, friendly, hostile and objective markers remain readable. |
| Selection, commands and production are coherent | PASS | Aster, Worker, Barracks, Militia, production and tooltip states are represented. |
| Alerts are coherent | PASS | Ashen pressure has distinct restrained warning/hostile treatment. |
| Playthrough works | PASS | v0.213 packaged capture, validation, real-input and replay evidence passed. |
| Fallbacks are safe | PASS | Procedural and portrait fallback evidence passed. |
| Performance acceptable | PASS | Full UI opt-in averaged 75.24 FPS versus 74.94 FPS for the pre-v0.203 comparator. |
| Reference-art parity | NOT CLAIMED | Remaining limitations are mostly art density, structures, unit production art and battlefield richness. |

## Boundary Decision

- No generated images.
- No downloaded assets.
- No new art slots.
- No browser runtime wiring.
- No default launcher mutation.
- Prior launchers remain preserved.
- No gameplay, pathing, collision, objective, AI, economy, save, stable-ID or balance changes.
- Character and environment slot integrations remain frozen.

## Decision

PASS_V0214_UI_DIRECTION_FREEZE. Continue with the frozen UI direction and move the next bounded phase toward production-art/content quality for the Salto battlefield.
