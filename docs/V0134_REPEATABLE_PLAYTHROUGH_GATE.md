# v0.134 Repeatable Playthrough Gate

Classification: `GREEN`

Gate: `REPEATABLE_PLAYTHROUGH_GREEN`

Reason:

- Three natural packaged-window playthroughs are defined and gated across normal, recoverable-mistake, and restart-and-replay profiles.
- The deliberate-mistake profile covers invalid clicks, conversion leave/re-enter, Worker miss, Barracks precondition feedback, combat empty box-select, defender reselect, and Attack with no valid selection.
- Restart from Results and Return-to-Title start-again paths are checked from public scene state.
- `no-softlock-proof.json` requires all profiles to reach Results without objective regression.
- `no-shortcut-proof.json` rejects private harness, debug, direct state injection, scripted objective skipping, fixture-only helper proof, and screenshot-only proof.

Boundary confirmations:

- Routine Godot editor work is not required.
- No art was generated, imported, or runtime-integrated.
- No save fields, localStorage keys, stable IDs, browser runtime code, rewards, campaign progression, broad economy, broad building tree, broad recruitment, full hero progression, final engine choice, full port, Unity, Unreal, Electron, or v0.135 work changed.
- `linked_ward` remains exactly `0.92`.
