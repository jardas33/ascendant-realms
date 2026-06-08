# v0.166 Three-Slot Visual QA Report

Status: `PASS_V0166_THREE_SLOT_VISUAL_QA`

v0.166 keeps the selected Worker, Barracks, and Militia context and improves the reviewability of that exact posture. It does not change the normal default procedural launcher.

## QA Findings

- Worker and Militia are not compressed; their runtime width is derived from source aspect.
- Worker and Militia billboard roots have no accidental procedural child overlay.
- Barracks material remains bound to five Barracks surfaces.
- Barracks procedural shell elements intentionally remain visible: weapon rack silhouette, drill-yard edge, construction scaffold, and construction progress bar.
- Normal gameplay distance still reads as an RTS prototype, not final art.
- The new review launcher makes the mode visible and uses tighter safe camera framing for review screenshots.
- Final review framing renders Worker at about 98.19 px and Militia at about 87.88 px in 1600 x 900 captures, with smaller translucent review anchors and a clearer Barracks material sheen.
- Computer Use live review reproduced the stale-executable launcher issue first, then confirmed the repaired launcher shows the v0.166 label in title, briefing, and battle.
- Scorecard status: `PASS_V0166_THREE_SLOT_VISUAL_COHERENCE_HUMAN_REVIEW_READY`.

## Benchmark Ratios

- M3 FPS ratio vs M0: 1.0013.
- M3 FPS ratio vs M2: 1.0012.
- M3 p95 ratio vs M0: 0.9985.
- M3 p95 ratio vs M2: 1.0506.

## Barracks Visibility

- Close/review framing: visible material contribution on base, wings, and roof split.
- Normal distance: correctly applied but restrained.
- Zoomed out: subtle, with procedural shell doing most silhouette work.
- UV scale: 1.0.
- Filter/mipmap posture: linear with mipmaps.

## Required Follow-Up Boundary

Future slot additions remain separate queued milestones only. v0.166 authorizes no Aster, Ashen, browser, save, stable-ID, gameplay, or default-launcher change.
