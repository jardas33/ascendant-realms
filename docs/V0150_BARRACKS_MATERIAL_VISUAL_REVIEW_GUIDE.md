# v0.150 Barracks Material Visual Review Guide

Status: capture packet for human review. Automated capture produced `62` screenshots and `49` benchmark rows.

Required review captures:

- Source boards for the original 768 control and every deterministic repair variant.
- 2x2 and 4x4 tiling boards.
- Seam diagnostic overlays.
- Normal RTS shell and zoomed RTS shell.
- Wet-overcast lighting and restrained hearth lighting.
- Worker+BARRACKS composition.
- Mipmap zoom transition near/far.
- Repeated-shell stress.
- Fallback comparison.

Human review questions:

- Are seams distracting at gameplay distance?
- Does the selected repair reduce repeat risk without obvious mirroring or visual mud?
- Is there severe shimmer through zoom transition?
- Is UV stretch acceptable on the shell?
- Do selection rings remain readable?

Final selected repair for review: `HYBRID_BARRACKS_768_WRAPSAFE_OFFSET_BLEND`.

Primary evidence:

- Contact sheet: `artifacts/desktop-spikes/godot-salto/v0150/evidence/contact-sheet.svg`
- Screenshot manifest: `artifacts/desktop-spikes/godot-salto/v0150/evidence/barracks-material-seam-repair-screenshot-manifest.json`
- Visual guide artifact: `artifacts/desktop-spikes/godot-salto/v0150/evidence/visual-review-guide.md`

Spot-check captures to review first:

- `37_normal_rts_shell_offset_blend.png`
- `38_zoomed_rts_shell_offset_blend.png`
- `44_repeated_shell_stress_offset_blend.png`
- `30_tiling_4x4_offset_blend.png`
- `34_seam_diagnostic_offset_blend.png`
- `61_fallback_comparison.png`
