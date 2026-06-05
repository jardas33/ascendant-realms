# v0.132 Site Guidance Gate

Classification: `SITE_GUIDANCE_GREEN`

Latest local gate source: `PASS_V0132_SITE_SEMANTICS_VALIDATION` from the packaged `npm run godot:headed:site-semantics-smoke` run.

## Green Criteria

- The live target is visibly named `West Stone Cut Mine`.
- Aster can be selected and moved there with normal packaged-build mouse input.
- Conversion progress is visible after Aster enters the capture radius.
- The mine becomes controlled through the real movement/capture path.
- Tutorial objectives do not regress during duplicate selection or movement events.
- The Worker is highlighted after control, selected normally, assigned by right-clicking the controlled mine, and produces visible boost feedback.
- No private harness shortcut, debug shortcut, direct state injection, save write, stable-ID change, browser-runtime change, art import, or routine Godot editor work is used.

## Scope

This gate only covers v0.132 site semantics and Worker guidance for the existing player-facing Godot Salto slice. It does not choose Godot finally, start a full port, import art, change saves, add broad economy, or start v0.133.
