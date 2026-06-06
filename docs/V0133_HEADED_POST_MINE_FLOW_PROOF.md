# v0.133 Headed Post-Mine Flow Proof

Status: `PASS_V0133_HEADED_POST_MINE_FLOW_SMOKE`

Validation status: `PASS_V0133_POST_MINE_FLOW_VALIDATION`

Evidence root: `artifacts/desktop-spikes/godot-salto/v0133/`

Required screenshot count: `21/21`

Proof files:

- `headed-post-mine-flow-smoke.json`
- `post-mine-trace.json`
- `post-mine-trace.md`
- `objective-prerequisite-report.json`
- `barracks-restoration-proof.json`
- `militia-recruit-proof.json`
- `pressure-countdown-proof.json`
- `wave-launch-proof.json`
- `combat-onset-proof.json`
- `wave-defeat-proof.json`
- `lume-restore-proof.json`
- `screenshot-manifest.json`
- `post-mine-flow-validation.json`

Verified path:

1. Launch player-facing slice.
2. Click Start Salto Review.
3. Click Start Battle.
4. Complete West Stone Cut Mine conversion.
5. Assign Worker to the controlled mine.
6. Restore Barracks through Worker right-click.
7. Observe construction progress.
8. Select Barracks.
9. Train Militia.
10. Observe recruit progress and Militia spawn.
11. Observe countdown.
12. Observe automatic wave launch and enemy movement.
13. Confirm the Objective 8 defender handoff, then issue a normal attack command against the marked Ashen wave.
14. Observe combat onset and simulation-backed wave defeat.
15. Restore highlighted Lume link.
16. Reach Results.

Computer Use packaged-window proof additionally reached `Salto Review Complete` from the rebuilt executable with visible mouse input: title, briefing, Aster selection, mine conversion, Worker assignment, Restore, Barracks selection, Train, countdown, wave launch, visible Attack command, highlighted field Lume click, and Results.

The maximized-window `test11` follow-up proof confirmed that the pre-wave red reserve wall is hidden, the top instruction chrome no longer blocks the playfield, the visible `Attack` command defeats the review wave through normal simulation, and the highlighted Lume field click reaches Results.

Objective 8 now performs a player-readable combat handoff at wave launch: the defender squad is selected, only the active four Ashen attackers remain visible in the review lane, and all active attackers are marked. Empty combat box-select attempts preserve the defender squad instead of wiping the selection.

Objective 8 accepts the original right-click attack path and also has raw and scaled mouse fallbacks for the visible `Attack` button rectangle. The visible `Attack` button issues a wave-defense order that keeps defenders assigned across the live wave until all four active attackers are defeated.

The `test11` manual recording repair is documented in `docs/V0133_TEST11_RECORDING_COMBAT_READABILITY_REPAIR.md`.

No private-harness shortcut, debug trigger, state injection, fixture-only helper proof, screenshot-only proof, save write, stable-ID change, browser runtime change, runtime art import, or Godot editor work was used.
