# v0.162 Barracks Material Opt-In Visual Review Guide

Status: `PASS_V0162_BARRACKS_MATERIAL_OPT_IN_CAPTURE`.

Review the five captured scenarios:
- Default procedural baseline.
- Worker-only opt-in baseline.
- Combined Worker + Barracks opt-in.
- Barracks missing-art fallback with Worker still active.
- Barracks hash-mismatch fallback with Worker still active.

Review checklist:
- Default launcher remains procedural.
- Worker-only launcher changes only the Worker.
- Combined launcher applies the selected Barracks material only to the friendly Barracks shell.
- The Barracks remains readable during build placement, completed restoration, selection, and recruit flow.
- The Worker remains readable near the mine and Barracks.
- Missing-art and hash-mismatch scenarios visibly keep the Worker art but use procedural Barracks presentation.
- No Aster, Militia, Ashen Raider, browser-runtime, save, or production manifest path appears.

Evidence path:
- `artifacts/desktop-spikes/godot-salto/v0162/capture/worker-barracks-art-opt-in-capture-report.json`
- `artifacts/desktop-spikes/godot-salto/v0162/capture/worker-barracks-art-opt-in-contact-sheet.svg`

Windows-side smoke:
- Computer Use opened the packaged combined opt-in app, verified the Salto title screen, clicked through the briefing, reached the battle view, and closed the Godot window cleanly.
