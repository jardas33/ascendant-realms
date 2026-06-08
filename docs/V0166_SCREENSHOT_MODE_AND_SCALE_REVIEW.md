# v0.166 Screenshot Mode And Scale Review

Status: `PASS_V0166_SCREENSHOT_CONCERN_REPRODUCED_AND_CLASSIFIED`

The v0.165 Windows captures reproduce the human concern honestly: the scene remains prototype-like, imported humanoids are small at gameplay distance, Barracks material is subtle, and the launched mode is not self-evident from the screenshot.

## Worker

- Source: `worker_billboard_static_v0147_trimmed_1024.png`.
- Source dimensions: 1024 x 1024.
- Trim dimensions: 482 x 942 alpha bounds.
- Runtime world size: 0.74 x 0.74.
- Runtime aspect: 1.0, preserved.
- Pivot: bottom-center, metadata normalized Y about 0.964.
- Selection ring diameter: 0.308 world units.
- Procedural Worker visual: hidden while selected Worker art is active.
- Generated visual: visible in M1/M2/M3 when source and hash pass.
- Marker state: selection and feedback markers remain separate from the billboard mesh.
- Initial player camera rendered size: 72 x 72 px at camera size 9.25.
- Final review-framed 1600 x 900 capture: about 98.19 x 98.19 px at camera size 7.8 with review scale 1.15.
- Ratio versus procedural Aster height: 1.0115.
- Ratio versus selection-ring diameter: 2.4026.

## Militia

- Source: `militia_billboard_static_v0154_trimmed_1024.png`.
- Source dimensions: 1024 x 1024.
- Trim dimensions: 386 x 942 alpha bounds.
- Runtime world size: 0.68 x 0.68.
- Runtime aspect: 1.0, preserved.
- Pivot: bottom-center, metadata normalized Y about 0.965.
- Selection ring diameter: 0.374 world units.
- Procedural friendly Militia visual: hidden while selected Militia art is active.
- Generated visual: visible in M3 when source and hash pass.
- Marker state: selection and squad markers remain separate from the billboard mesh.
- Initial player camera rendered size: 66.16 x 66.16 px at camera size 9.25.
- Final review-framed 1600 x 900 capture: about 87.88 x 87.88 px at camera size 7.8 with review scale 1.12.
- Ratio versus procedural Aster height: 0.9295.
- Ratio versus selection-ring diameter: 1.8182.

## Classification

- Compression: fixed already by v0.165 and revalidated by v0.166 status.
- Duplicate rendering: fixed already by v0.165 and revalidated by v0.166 status.
- Prototype-like presentation: intentional limitation of the procedural slice.
- Mode ambiguity: real remaining review issue, repaired with an experimental-only label.
- Small imported humanoids: intentional RTS scale, improved for human review with tighter safe review framing, review-only scale overrides, and subtler Worker/Militia anchor rings.
- Live Windows review: repaired review launcher now uses the v0.166 executable and shows the mode label on title, briefing, and battle surfaces.
