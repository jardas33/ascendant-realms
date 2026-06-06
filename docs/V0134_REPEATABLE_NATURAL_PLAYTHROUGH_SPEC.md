# v0.134 Repeatable Natural Playthrough Spec

Scope: prove the existing Godot player-facing Salto slice can be completed repeatedly through ordinary packaged-build mouse input and normal simulation.

Authorized path:

- Run `GODOT_TRIPLE_NATURAL_PLAYTHROUGH_WINDOWS.bat` or `npm run godot:headed:triple-natural-playthrough`.
- Use the packaged player-facing Godot slice, not the private harness.
- Complete three profiles: `normal_direct_path`, `recoverable_mistakes`, and `restart_and_replay`.
- Reach Results and Return to Title through normal UI input.
- Keep all generated evidence ignored under `artifacts/desktop-spikes/godot-salto/v0134/`.

Forbidden proof:

- Private-harness shortcuts.
- Debug triggers.
- Direct state mutation or state injection.
- Scripted objective skipping.
- Fixture-only helper calls as proof.
- Screenshot-only validation.
- Routine Godot-editor work.

Preserved boundaries:

- No imported or generated art.
- No save writes or new save fields.
- No stable-ID changes.
- No browser runtime replacement.
- No full port and no final engine choice.
- `linked_ward` remains exactly `0.92`.
