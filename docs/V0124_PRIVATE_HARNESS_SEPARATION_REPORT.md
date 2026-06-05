# v0.124 Private Harness Separation Report

Status: separated.

The existing adapter-review harness is preserved behind explicit private paths:

- `GODOT_LAUNCH_PRIVATE_HARNESS_WINDOWS.bat`
- `npm run godot:launch:private-harness`
- `tools/godot/launchGodotPrivateHarnessWindows.ps1`
- `GODOT_LAUNCH_REVIEW_WINDOWS.bat` remains private by default when launched with no arguments.

The default human-review path is now:

- `GODOT_LAUNCH_PLAYER_SLICE_WINDOWS.bat`
- `npm run godot:launch:player-slice`

Player-facing screens avoid adapter, fixture, repository, parity, benchmark, diagnostic, stable-ID, and localStorage terminology. Those engineering details remain in reports and the private harness only.

No private-harness evidence was removed.
