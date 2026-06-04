# v0.120 Emmanuel One-Click Guide

Emmanuel does not need to assemble Godot scenes manually for v0.120.

## Main Script

From the repository root on Windows:

```text
GODOT_RUN_ALL_WINDOWS.bat
```

This now runs the existing Godot all-in flow and then the v0.120 fresh-checkout validation.

## Focused Fresh-Checkout Script

```text
GODOT_FRESH_CHECKOUT_VALIDATE_WINDOWS.bat
```

This runs only the temp-checkout reproducibility proof.

## What To Check

- The script finishes without asking for editor work.
- The package ZIP still opens through its generated `RUN_GODOT_SALTO_SPIKE.bat`.
- The report exists at `artifacts/desktop-spikes/godot-salto/v0120/fresh-checkout-validation.json`.
- The report status is `PASS_GODOT_FRESH_CHECKOUT_VALIDATION`.
- `routineEditorUseRequired` is false.

## What Not To Do

- Do not drag assets into Godot.
- Do not assemble scenes in the Godot editor.
- Do not import artwork.
- Do not choose Godot finally from this proof.
- Do not start a full port or v0.121 without a new explicit goal.
