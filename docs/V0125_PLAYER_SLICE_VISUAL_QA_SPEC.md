# v0.125 Player-Slice Visual QA Spec

v0.125 adds an automated screenshot-driven QA pass for the Godot player-facing Salto review slice. The command is:

```text
npm run godot:audit:player-slice
```

The command refreshes the packaged player-slice screenshots and writes ignored audit artifacts under:

```text
artifacts/desktop-spikes/godot-salto/v0125/
```

The audit checks title, briefing, battle, and Results captures for player-facing copy, no debug leakage, no raw fixture IDs in visible player HUD feedback, useful terrain coverage, coherent battle HUD visibility, private-harness separation, screenshot dimensions, and healthy non-final performance smoke.

This QA pass is blockout review evidence only. It does not approve final art, import artwork, change browser runtime, change saves, change stable IDs, choose Godot finally, or start a full port.
