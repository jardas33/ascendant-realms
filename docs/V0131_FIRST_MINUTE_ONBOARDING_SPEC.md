# v0.131 First-Minute Onboarding Spec

Status: `FIRST_MINUTE_ONBOARDING_REPAIRED`

This spec is limited to the first player-facing minute of the Godot Salto slice.

## Sequence

1. Title opens with `Start Salto Review`.
2. Briefing opens with `Start Battle`.
3. Battle starts with the camera centered on Aster.
4. Objective strip says `Select Aster`.
5. Aster pulses, carries a compact `ASTER` label, and is mirrored by the minimap hero marker.
6. Hovering Aster shows hover feedback.
7. Left-clicking Aster selects him and updates the HUD card.
8. Objective changes to `Right-click near the quarry to move`.
9. A destination pulse appears near the quarry.
10. Right-clicking near the quarry shows a move marker and Aster moves.
11. Objective advances only after meaningful visible displacement.
12. Worker selection and squad box-select remain available for the next microloop steps.

## Copy Rules

- Keep prompts compact.
- Use player language only.
- Do not mention debug state, fixture validation, private harnesses, or developer jargon in the player-facing surface.
- Do not rely on color alone; use ring, label, silhouette, minimap marker, and motion.

