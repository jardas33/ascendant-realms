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
13. Box-select defenders and issue a normal attack command against the Ashen wave.
14. Observe combat onset and simulation-backed wave defeat.
15. Restore highlighted Lume link.
16. Reach Results.

Computer Use packaged-window proof additionally reached `Salto Review Complete` from the rebuilt executable with visible mouse input: title, briefing, Aster selection, mine conversion, Worker assignment, Restore, Barracks selection, Train, countdown, wave launch, visible Attack command, Lume click, and Results.

Objective 8 accepts the original right-click attack path and also has a raw mouse fallback for the visible `Attack` button rectangle, so the player-facing command cannot be lost by HUD routing while the wave is active.

No private-harness shortcut, debug trigger, state injection, fixture-only helper proof, screenshot-only proof, save write, stable-ID change, browser runtime change, runtime art import, or Godot editor work was used.
