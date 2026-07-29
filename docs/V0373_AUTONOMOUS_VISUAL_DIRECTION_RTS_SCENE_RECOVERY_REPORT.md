# v0.373 Autonomous Visual-Direction Loop and Fail-Closed RTS Scene Recovery

## Status

BLOCKED — V0373 VISUAL QUALITY GATE NOT MET

The isolated prototype was rendered and inspected through six autonomous visual
iterations. It is intentionally not presented as accepted or ready for human
review. No final human upload pack was created because the rendered score did
not meet the required 50/60 threshold and multiple critical visual defects
remained.

## Baseline and preservation

Branch: `codex/v0215-v0226-recovery`

Base HEAD: `0bfe2240b3bd3a70c610a6847cd6cdc91365275a`

The true default runtime and the accepted v0.370, v0.371, and v0.372 scenes and
scripts remain unchanged. The new route is opt-in only through
`--v0373-autonomous-visual-direction`, `--v0373-autonomous-capture`, or
`--v0373-autonomous-smoke`. No gameplay, HUD, selection, AI, navigation,
economy, combat, persistence, or production integration was added.

## Prototype

Scene:
`desktop-spikes/godot-salto/scenes/v0373_autonomous_visual_direction_rts_sector.tscn`

Launch: `npm run godot:play:autonomous-visual-direction`

Capture: `npm run godot:capture:autonomous-visual-direction`

The scene uses actual Quaternius characters and village/nature assets, a compact
settlement, worked resource area, bridge, curved river, roads, and fenced camp.
It is a world-only visual experiment, not a gameplay scene.

## Autonomous visual evidence

Private audit:
`artifacts/work/v0373-internal-visual-audit.md`

Iteration log and scores:
`artifacts/work/v0373-iteration-log.md`

Rendered iterations:
`artifacts/work/v0373-iteration-01/` through
`artifacts/work/v0373-iteration-06/`

The six passes changed composition, settlement spacing, resource visibility,
camp enclosure, river curvature/extension, bank treatment, camera framing,
roof scale, and material overrides. Every iteration was rendered at 1920x1080
and the primary, settlement/resource, and bridge/camp frames were visually
inspected before the next correction.

## Gate result

Final score: **34/60**.

The required minimum is 50/60 with every category at least 4. The gate failed
because:

- the settlement still reads as a tightly packed asset demonstration rather
  than a believable village edge and yard;
- the river and paths still read as hard-edged authored ribbons rather than
  terrain-integrated natural space;
- the hostile camp is a small fenced wagon yard without a strong hostile
  silhouette or territory hierarchy;
- the resource deposit is readable but visually awkward and too close to the
  settlement mass;
- the camera still leaves excessive low-value olive foreground;
- Quaternius roof/prop colours remain brighter and less unified than the
  intended Barrosan direction;
- a flat roof material override was tested and rejected because it destroyed
  the authored roof texture, then reverted.

## Honest blocker classification

The primary limitation is **asset-family and composition quality**, not missing
runtime semantics. The available Quaternius village family supplies useful
parts but not enough coherent architectural variety, natural terrain dressing,
or hostile-camp identity to reach the visual bar through this small procedural
composition alone. Godot implementation is sufficient to render the route; it
is not sufficient to make weak silhouettes and material relationships look
authored.

The safest next repair would require a human art-direction decision and a
stronger authored asset set: a distinct Barrosan settlement kit, an actual
resource outcrop, a purpose-built hostile encampment, and natural terrain/river
bank geometry. Do not continue by adding more scattered props or by applying
flat material overrides to the existing family.

## Fail-closed delivery

The required final pack
`artifacts/manual-review/v0373-autonomous-visual-direction/` was intentionally
not created. Rejected frames remain only under `artifacts/work/` and are not
human-review evidence. No `READY FOR HUMAN V0373 AUTONOMOUS VISUAL-DIRECTION
REVIEW` claim is made.

The focused smoke route passed as an isolated world-only load. Full repository
validation and commit/push are intentionally not claimed for a visually
rejected checkpoint.
