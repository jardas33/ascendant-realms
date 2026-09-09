# Minimap Fog Presentation R2 — Residual Diagnosis

## Disposition

`CANDIDATE_MINIMAP_FOG_R2_HUMAN_REVIEW_REQUIRED`

Candidate A was temporarily reapplied to `hud.gd`, verified as the only production diff (`24 additions / 2 removals`), inspected at the actual 220px minimap size in the existing 1920×1080 captures, and restored byte-exact. No Candidate B was created because no second concrete visual defect was identified.

## Candidate A residual checks

```text
POLYGON_TRIANGULATION_ARTIFACT=false
DIAGONAL_OR_PINWHEEL_PATTERN=false
OVER_SMOOTHED_BOUNDARY=false
UNDER_SMOOTHED_BOUNDARY=false
STATE_BLEED_ACROSS_VISIBILITY_EDGE=false
DARK_HALO_AT_BOUNDARY=false
LIGHT_HALO_AT_BOUNDARY=false
PATCHY_ALPHA_FIELD=false
VISIBLE_VERTEX_PATTERN=false
LOCAL_GEOGRAPHY_WASHOUT=false
TACTICAL_MARKER_COMPETITION=false
BOUNDARY_SHAPE_FEELS_ARTIFICIAL=false
OTHER_RESIDUAL=none observed at normal gameplay scale
```

Candidate A’s remaining boundary is still ultimately derived from the discrete 4m visibility grid, but the three runtime frames do not show a separate actionable artifact beyond that source discretization. Inventing a second smoothing or weighting pass without a concrete failure would risk changing the already healthy fog hierarchy.

```text
PRIMARY_RESIDUAL_VISUAL_DEFECT=none identified
PRIMARY_RESIDUAL_OWNER=none
CANDIDATE_B_CREATED=false
SELECTED_MINIMAP_FOG_CANDIDATE=A
MINIMAP_FOG_COLORS_CHANGED=false
MINIMAP_FOG_ALPHA_CHANGED=false
NORMAL_GAMEPLAY_SCALE_REVIEW=true
```

## R2 invariants

```text
THREE_STATE_VISIBILITY_MODEL_CHANGED=false
VISIBILITY_GRID_CHANGED=false
VISION_RADIUS_CHANGED=false
FOG_UPDATE_CADENCE_CHANGED=false
ENEMY_WORLD_VISIBILITY_RULES_CHANGED=false
ENEMY_MINIMAP_VISIBILITY_RULES_CHANGED=false
CAPTURE_POINT_VISIBILITY_RULES_CHANGED=false
WORLD_MINIMAP_INFORMATION_LEAK=false
NEW_SHADER=false
NEW_VIEWPORT=false
NEW_RENDER_TEXTURE=false
NEW_TEXTURE=false
NEW_ASSET=false
```

## Restore proof

```text
CANDIDATE_A_PATCH_EXISTS=true
CANDIDATE_A_PATCH_REAPPLY_CHECK=PASS
CANDIDATE_A_REAPPLIED=true
GIT_DIFF_CHECK=PASS after restore
HEAD_AFTER_RESTORE=195b4b2a6443dabebfbd557ea64d4f8a29ed7a17
BRANCH_AFTER_RESTORE=codex/visual-convergence-r1
STAGED_COUNT=0
GODOT_PROCESS_COUNT=0
LOCAL_COMMIT_SHA=NONE
SCREENSHOT_COUNT_NEW=0
```

The six R1 PNGs and `CANDIDATE_A.patch` remain preserved in this evidence root. Candidate A remains a strong provisional fix for the proven grid-seam defect, but Emanuel’s complaint is only `PARTIALLY_RESOLVED` until human review confirms the minimap reads as deliberate at gameplay scale.
