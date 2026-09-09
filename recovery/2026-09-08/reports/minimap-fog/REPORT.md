# Ascendant Realms — Minimap Fog Presentation R1

## Terminal classification

`CANDIDATE_MINIMAP_FOG_R1_PROVISIONAL_HUMAN_REVIEW_REQUIRED`

Candidate A removes the visible minimap grid/seam artifact at normal 1920×1080 gameplay scale by using the same neighboring-state corner interpolation pattern already present in the world visibility overlay. It is a presentation-only candidate, not a qualified promotion: the visual gain is clear in the matched runtime captures, but independent human classification is still required.

## Exact boundary

```text
AUTHORITATIVE_BASELINE=8bd0f417ae5d30174b67881c495d17fe3f3b2172
FOG_PRESENTATION_PARENT=2220de3d0339c1f200073accefa0ae82efd8e1ed
FROZEN_ANIMATION_CANDIDATE=195b4b2a6443dabebfbd557ea64d4f8a29ed7a17
PROTECTED_CANONICAL=b9812797bba626a3b51e0b79739bc6e2cdf0bca4
```

The final visual worktree was restored to `codex/visual-convergence-r1` at `195b4b2a6443dabebfbd557ea64d4f8a29ed7a17`; the candidate remains evidence-only and uncommitted.

## Rendering diagnosis

```text
MINIMAP_FOG_OWNER_FILE=production/ascendant-realms-godot/scripts/ui/hud.gd
MINIMAP_FOG_DRAW_FUNCTION=_draw_minimap_visibility
MINIMAP_FOG_GRID_DIMENSIONS=68 columns x 68 rows; 4.0m cells over 272m playable span
MINIMAP_FOG_CELL_MAPPING=states[row * columns + column]; x=column * size.x / columns; y=row * size.y / rows
MINIMAP_FOG_DRAW_PRIMITIVE=CanvasItem draw_rect per fog cell at baseline; draw_polygon with four interpolated corner colors in Candidate A
MINIMAP_UNEXPLORED_COLOR=Color(0.025, 0.040, 0.060, 0.72)
MINIMAP_EXPLORED_COLOR=Color(0.045, 0.065, 0.085, 0.32)
MINIMAP_VISIBLE_REGION_RENDERING=state 2 is skipped, leaving the cached minimap terrain/background visible; live markers are drawn afterward
MINIMAP_UPDATE_CADENCE=HUD redraw every 0.15s; world visibility state update interval is 0.2s
```

The baseline presentation is per-cell rectangles, not a texture, interpolated polygon, or overlay mesh. The world presentation is a separate 3D overlay and already averages neighboring cell colors at mesh corners; the minimap did not.

## Observed baseline defect

The fresh baseline frame at normal scale shows a dark grid/seam pattern across fogged minimap cells. The 68×68 state grid maps to roughly 3.24×3.24 pixels at a 220×220 minimap, so the `draw_rect` coverage and cell boundaries are directly visible. The defect is implementation-grid exposure, not a visibility-truth defect.

```text
VISIBLE_GRID_BLOCKINESS=true
HARD_CELL_EDGES=true
CHECKERBOARD_EFFECT=false
JAGGED_REVEAL_BOUNDARY=true
EXCESSIVE_ALPHA=false
INSUFFICIENT_CONTRAST=false
FOG_OBSCURES_MAP_GEOGRAPHY=false
EXPLORED_VS_UNEXPLORED_TOO_SIMILAR=false
VISIBLE_REGION_TOO_ABRUPT=true
FOG_LAYER_COMPETES_WITH_UNIT_MARKERS=false
```

The tactical markers remained distinguishable in the captures. No information leak was observed or introduced.

## Candidate A

Candidate A changes only `production/ascendant-realms-godot/scripts/ui/hud.gd`: it replaces the minimap fog `draw_rect` call with four-corner `draw_polygon` colors averaged from the neighboring visibility states. The unexplored and explored colors are unchanged. No shader, viewport, render texture, grid, vision radius, visibility rule, or update cadence was added or changed.

```text
CANDIDATES_TESTED=1
TRACKED_PRODUCTION_FILE_COUNT=1
TRACKED_PRODUCTION_FILES=production/ascendant-realms-godot/scripts/ui/hud.gd
NEW_SHADER=false
NEW_VIEWPORT=false
NEW_RENDER_TEXTURE=false
```

### Normal-scale scorecard (0–10)

| Metric | Baseline | Candidate A | Result |
|---|---:|---:|---|
| Fog boundary smoothness | 2 | 8 | clear gain; visible grid seams removed |
| Explored/unexplored distinction | 7 | 7 | colors and state hierarchy preserved |
| Map geography legibility | 6 | 7 | no longer cut by repeated dark seams |
| Tactical marker legibility | 7 | 7 | not worse; blue/red markers remain readable |
| Visual noise control | 2 | 8 | clear gain |
| Commercial minimap readability | 4 | 7 | meaningful gain at 220px HUD scale |

```text
FOG_BOUNDARY_SMOOTHNESS_GAIN=+6
VISUAL_NOISE_CONTROL_GAIN=+6
COMMERCIAL_MINIMAP_READABILITY_GAIN=+3
TACTICAL_MARKER_LEGIBILITY_NOT_WORSE=true
MAP_GEOGRAPHY_LEGIBILITY_NOT_WORSE=true
INFORMATION_TRUTH_NOT_WORSE=true
```

## Runtime evidence

Both sets were captured fresh at 1920×1080 through the existing `tests/current_short_public_capture.gd` hook on exact baseline `8bd0f417...`; Godot 4.6.3 headed Vulkan Forward+ exited 0 in each run. Three matched route states are preserved under `baseline/` and `candidate-a/`:

```text
A_MOSTLY_UNEXPLORED.png
B_PARTIAL_EXPLORED_EDGE.png
C_MIXED_VISIBLE_REGION.png
```

The original generated capture directory was restored byte-for-byte after each run. The candidate frames show the fogged minimap without the baseline’s repeated grid seams; the underlying world fog remains unchanged and is not being used as minimap proof.

```text
THREE_STATE_VISIBILITY_MODEL_CHANGED=false
VISIBILITY_GRID_CHANGED=false
VISION_RADIUS_CHANGED=false
FOG_UPDATE_CADENCE_CHANGED=false
WORLD_MINIMAP_INFORMATION_LEAK=false
FRIENDLY_MARKERS_READABLE=true
ENEMY_MARKERS_WHEN_VISIBLE_READABLE=true
CAMERA_FOOTPRINT_READABLE=true
CAPTURE_POINT_MARKERS_READABLE=true
```

## Disposition and restore

```text
EMANUEL_REPORTED_MINIMAP_FOG_LOOKS_WEIRD=PARTIALLY_RESOLVED
ASTRA_CANDIDATE_ACTIVE_IN_WORKTREE=false
LOCAL_CANDIDATE_BRANCH=NONE
LOCAL_COMMIT_SHA=NONE
PROJECT_PARSE=PASS (Godot 4.6.3 headed capture exit 0)
EDITOR_IMPORT=NOT_REQUIRED
GIT_DIFF_CHECK=PASS after restore; hud.gd byte-exact to HEAD
HEAD_AFTER_RESTORE=195b4b2a6443dabebfbd557ea64d4f8a29ed7a17
FROZEN_ANIMATION_CANDIDATE_PRESERVED=true
STAGED_COUNT=0
BASELINE_NEXT_CHANGED=false
CANONICAL_CHANGED=false
PUSH=false
MERGE=false
REBASE=false
CHERRY_PICK=false
NEW_WORKTREE_CREATED=false
SCREENSHOT_COUNT=6 (3 baseline + 3 candidate)
VIDEO=false
```

Candidate A is retained as a patch and matched visual evidence for human review. No promotion or commit is authorized by this result alone.
