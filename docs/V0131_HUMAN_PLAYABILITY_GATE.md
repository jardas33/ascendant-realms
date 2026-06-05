# v0.131 Human Playability Gate

Classification: `HUMAN_PLAYABILITY_GREEN`

This is a narrow v0.131 classification for the first player-control path in the packaged Godot Salto review slice. It is not a final engine decision, production readiness claim, full-port approval, or runtime art approval.

## Green Requirements

| Requirement | Status |
| --- | --- |
| Actual packaged headed input path | PASS |
| No debug shortcut | PASS |
| No internal state injection | PASS |
| Aster discoverable | PASS |
| Aster selectable | PASS |
| Visible hover and selection feedback | PASS |
| HUD selection feedback | PASS |
| Right-click move | PASS |
| Visible move marker | PASS |
| Visible Aster movement | PASS |
| Objective advances after real movement | PASS |
| Worker selectable | PASS |
| Squad box-select works | PASS |
| Zero-editor routine workflow preserved | PASS |

## Gate Decision

`HUMAN_PLAYABILITY_GREEN` is granted for v0.131 because the packaged real-input smoke passed and produced the required artifact packet under `artifacts/desktop-spikes/godot-salto/v0131/`.

Do not start v0.132 automatically. A future milestone still needs a separate explicit prompt and clean/synced gate.

