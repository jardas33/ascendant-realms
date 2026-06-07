# v0.148 Worker Billboard Alpha Pivot Review Guide

Status: final private comparator screenshot capture is available. Use this guide only for private comparator review.

One-click wrapper:

```text
GODOT_WORKER_BILLBOARD_SINGLE_SLOT_REPAIR_WINDOWS.bat
```

Capture command:

```text
npm run godot:worker-billboard-repair:capture
```

Expected review evidence:

```text
artifacts/desktop-spikes/godot-salto/v0148/evidence/alpha-pivot-review-guide.md
artifacts/desktop-spikes/godot-salto/v0148/evidence/screenshot-manifest.json
artifacts/desktop-spikes/godot-salto/v0148/evidence/contact-sheet.svg
artifacts/desktop-spikes/godot-salto/v0148/evidence/screenshots/
```

Final selected derivative:

```text
HYBRID_WORKER_TRIMMED_1024
```

Final gate:

```text
PASS_V0148_WORKER_BILLBOARD_ORIGINAL_GATE
```

Final capture notes:

- `018_hybrid_worker_trimmed_1024_checkerboard_alpha_edge_closeup_tier_s_scale_1_0.png` shows the selected Worker against checkerboard alpha-review background.
- `021_hybrid_worker_trimmed_1024_normal_rts_gameplay_distance_tier_m_scale_1_0.png` shows the selected Worker at gameplay distance.
- `022_hybrid_worker_trimmed_1024_zoomed_out_readability_tier_l_scale_1_0.png` shows Tier L readability.
- `024_hybrid_worker_trimmed_1024_selection_ring_tier_s_scale_1_0.png` shows selection-ring posture.

## Human Review Checks

- Check alpha edges against checkerboard, dark, and light backgrounds.
- Check whether feet and selection ring feel pinned at RTS camera distance.
- Compare `0.90x`, `1.00x`, and `1.10x` scale captures.
- Check repeated-overlap readability in a crowded Tier L posture.
- Compare the selected repair derivative against the diagnostic fallback.

## Non-Approval Boundary

This review does not approve production Worker art. It only determines whether the repaired private comparator path is worth a future bounded integration decision.

- No second runtime-art slot.
- No normal Salto player-facing scene mutation.
- No browser runtime wiring.
- No v0.149 work.
