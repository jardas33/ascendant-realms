# v0.436 H3 Command Panel Readability

## Scope

H3 is a bounded player-facing command-panel readability slice. It does not
change command semantics, production rules, costs, queues, placement, or
simulation state.

## Change

`_mk_command_button` now gives command actions a larger 150x58 minimum
surface, explicit normal/hover/pressed/disabled style boxes, stronger but
restrained borders, and a readable disabled color. Existing tooltip text is
retained and disabled actions append the existing `Unavailable: ...` reason.

## Evidence

Fresh certified headed captures were produced by
`node tools/godot/p1r22CommandCardTool.mjs capture` with the evidence root:

`D:/CodexData/evidence/ascendant-realms-playtest3-remediation-h/H3-command-panel/`

The capture returned exit 0 and includes worker, HQ, production, research,
disabled-state, 1366 build/train, and build-placement gameplay frames. The
frames are real rendered PNGs, not title cards. The source checkout used for
this capture was the H1 base with the H2/H3 working-tree presentation patches;
the final H3 commit is the authoritative source for the style change.

## Preserved

The command grid, action routing, disabled reasons, production behavior,
resource behavior, selected-card layout, and debug/review tooling remain
unchanged. No movement, pathfinding, combat, economy, or save/state behavior
was added.
