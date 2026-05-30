# v0.59 Tactical Combat Feedback Spec

## Goal

Improve moment-to-moment combat readability by making selected-unit intent, role, rank, control-group state, and Patrol behavior easier to understand.

## Feedback Rules

- Attack orders should name the target when known.
- Movement, repositioning, attack-move, Patrol, Hold Ground, Guard Area, and Press Attack remain distinct in the order summary.
- Worker build, repair, and site assignment copy stays explicit and unaffected by army role polish.
- Veteran rank and role identity should be visible in selected-unit stats without crowding command buttons.
- Results should explain battle-only veteran summaries in short copy.

## Control Group And Patrol Interaction

- Control groups recall living veteran units normally.
- Dead members are pruned by the existing control group system.
- Patrol state remains session-only and cancels through explicit orders.
- Formation-aware move targets remain unchanged except for copy/readability.

## Readability Limits

- No new art, VFX pipeline, or cursor asset.
- No extra combat spam.
- No new enemy formation AI.
- No broad pathing rewrite.
- No global balance changes.

## Deferrals

- No damage-type counter chart.
- No battle log.
- No per-unit floating role icon.
- No replay timeline.
