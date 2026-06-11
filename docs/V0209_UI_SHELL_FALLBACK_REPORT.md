# v0.209 UI Shell Fallback Report

## Fallback Contract

The opt-in launcher accepts `--salto-ui-shell-force-fallback`. When present, the new overlay does not render and the existing readable procedural Godot HUD remains active.

## Proved Behaviors

- `--salto-ui-shell-experiment` requests the opt-in shell.
- `--salto-ui-shell-force-fallback` disables the overlay without blocking the player slice.
- The old scene HUD remains visible in fallback.
- Required controls are not hidden in fallback.
- No unknown art substitution occurs because v0.209 imports no UI textures or assets.

## Evidence

The review pack includes `10_fallback.png`, copied from the forced-fallback packaged capture.

Validation executed:

```powershell
npm run godot:validate:salto-ui-shell-opt-in
```

The validation writes `PASS_V0209_UI_SHELL_VALIDATION`, `PASS_V0209_UI_SHELL_BOUNDARY`, `PASS_V0167_SALTO_EXPERIMENTAL_ARTIFACT_RETENTION`, and `PASS_V0209_UI_SHELL_OPT_IN_VALIDATION_READY`.
